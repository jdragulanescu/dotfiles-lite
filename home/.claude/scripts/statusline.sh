#!/bin/bash
# Claude Code's status line: reads the session JSON on stdin and prints two
# rows. Colours are the terminal's palette slots, so they follow the Ghostty
# Aura theme the way starship does. A segment whose data
# is missing is left out, and when a row is wider than the terminal
# ($COLUMNS) the least useful segments go first.

# The session fields are set by the eval of jq's output below.
# shellcheck disable=SC2154
e=$'\033['
RESET="${e}0m"
BOLD="${e}1m"
RED="${e}38;5;1m"
DEEP_CYAN="${e}38;5;2m"
ORANGE="${e}38;5;3m"
PURPLE="${e}38;5;4m"
PINK="${e}38;5;5m"
CYAN="${e}38;5;6m"
FG="${e}38;5;7m"
GREY="${e}38;5;8m"
# Stock Aura's mint, as a true colour: the tuned palette has no green.
MINT="${e}38;2;97;255;202m"
ESC=$'\033' BEL=$'\a'

fields=$(jq -r '
	def int: if . == null then "" else floor end;
	def seconds_left: if . == null then "" else . - now | floor end;
	def model_name:
		[.model.id // "" | capture("claude-(?<family>[a-z]+)-(?<major>[0-9]+)-(?<minor>[0-9])(?![0-9])")][0] as $m
		| if $m then ($m.family | .[:1] | ascii_upcase) + ($m.family | .[1:]) + " " + $m.major + "." + $m.minor
		  else .model.display_name // "Claude" end;
	@sh "model=\(model_name)",
	@sh "effort=\(.effort.level // "")",
	@sh "fast=\(.fast_mode == true)",
	@sh "ctx_pct=\(.context_window.used_percentage // 0 | floor)",
	@sh "ctx_tokens=\(.context_window.total_input_tokens // 0)",
	@sh "ctx_size=\(.context_window.context_window_size // 200000)",
	@sh "five_pct=\(.rate_limits.five_hour.used_percentage | int)",
	@sh "five_left=\(.rate_limits.five_hour.resets_at | seconds_left)",
	@sh "week_pct=\(.rate_limits.seven_day.used_percentage | int)",
	@sh "week_left=\(.rate_limits.seven_day.resets_at | seconds_left)",
	@sh "cost=\(.cost.total_cost_usd // 0)",
	@sh "duration=\((.cost.total_duration_ms // 0) / 1000 | floor)",
	@sh "added=\(.cost.total_lines_added // 0)",
	@sh "removed=\(.cost.total_lines_removed // 0)",
	@sh "cache_hit=\(.prompt_cache.hit_ratio | if . == null then "" else . * 100 | floor end)",
	@sh "cache_warm=\(.prompt_cache.warm == true)",
	@sh "cache_seen=\(.prompt_cache.caching_observed == true)",
	@sh "cache_left=\(.prompt_cache.expires_at | seconds_left)",
	@sh "current_dir=\(.workspace.current_dir // .cwd // "")",
	@sh "project_dir=\(.workspace.project_dir // "")",
	@sh "repo=\(.workspace.repo.name // "")",
	@sh "worktree=\(.workspace.git_worktree // "")",
	@sh "pr_number=\(.pr.number // "")",
	@sh "pr_url=\(.pr.url // "")",
	@sh "pr_state=\(.pr.review_state // "")"
') && [[ -n $fields ]] || {
	echo "statusline: unreadable input"
	exit 0
}
eval "$fields"

format_tokens() {
	local tokens=$1
	if ((tokens >= 1000000)); then
		echo "$((tokens / 1000000))M"
	elif ((tokens >= 1000)); then
		echo "$((tokens / 1000))k"
	else
		echo "$tokens"
	fi
}

format_duration() {
	local seconds=$1
	local minutes=$((seconds / 60)) hours=$((seconds / 3600)) days=$((seconds / 86400))
	if ((days > 0)); then
		echo "${days}d$((hours % 24))h"
	elif ((hours > 0)); then
		echo "${hours}h$((minutes % 60))m"
	elif ((minutes > 0)); then
		echo "${minutes}m"
	else
		echo "${seconds}s"
	fi
}

# Prints the colour for $1 percent used: orange from $2 percent, red from 80.
usage_color() {
	if (($1 >= 80)); then
		echo "$RED"
	elif (($1 >= $2)); then
		echo "$ORANGE"
	else
		echo "$DEEP_CYAN"
	fi
}

# Prints a ten-cell bar for $1 percent in the colour $2, each cell 10%: a "="
# for each full one, then, for what is left over, a "-" under 5% and a "="
# from 5%.
context_bar() {
	local filled=$(($1 >= 100 ? 10 : $1 / 10)) rest=$(($1 % 10)) partial="" full empty
	if ((filled == 10 || rest == 0)); then
		partial=""
	elif ((rest < 5)); then
		partial="-"
	else
		partial="="
	fi
	printf -v full '%*s' "$filled" ''
	printf -v empty '%*s' $((10 - filled - ${#partial})) ''
	echo "${GREY}[${2}${full// /=}${partial}${empty}${GREY}]${RESET}"
}

# Prints "  5h 23% ↻1h12m" for one rate-limit window, or nothing when the
# session has no such window.
limit_usage() {
	local name=$1 pct=$2 left=$3
	[[ -n $pct ]] || return 0
	printf '  %s %s' "${GREY}${name}${RESET}" "$(usage_color "$pct" 50)${pct}%${RESET}"
	[[ -z $left ]] || printf ' %s' "${GREY}↻$(format_duration "$left")${RESET}"
}

# Prints how many terminal columns $1 takes: its colour codes and link
# wrappers removed, and each UTF-8 character counted once (its continuation
# bytes, 0x80-0xbf, not counted). Run in a subshell, so LC_ALL stays here.
visible_width() {
	LC_ALL=C
	local rest=$1 text="" low=$'\x80' high=$'\xbf'
	while [[ $rest == *"$ESC"* ]]; do
		text+=${rest%%"$ESC"*}
		rest=${rest#*"$ESC"}
		case $rest in
		"["*) rest=${rest#*m} ;;
		*) rest=${rest#*"$BEL"} ;;
		esac
	done
	text+=$rest
	local continuation=${text//[!$low-$high]/}
	echo $((${#text} - ${#continuation}))
}

# Prints the segments $@, each "<rank> <text>", joined by grey bars. While the
# row is wider than the terminal, the segment with the highest rank is left
# out (the later one on a tie); rank 0 is never left out.
print_row() {
	local segments=("$@") row i rank worst worst_rank
	while :; do
		row=""
		for i in "${!segments[@]}"; do
			[[ -z $row ]] || row+=" ${GREY}|${RESET} "
			row+=${segments[i]#* }
		done
		(($(visible_width "$row") <= ${COLUMNS:-1000})) && break
		worst="" worst_rank=0
		for i in "${!segments[@]}"; do
			rank=${segments[i]%% *}
			((rank > 0 && rank >= worst_rank)) && worst=$i worst_rank=$rank
		done
		[[ -n $worst ]] || break
		unset "segments[worst]"
	done
	printf '%s\n' "$row"
}

branch="" dirty=""
while IFS= read -r line; do
	case $line in
	"# branch.head "*) branch=${line#\# branch.head } ;;
	"#"*) ;;
	?*) dirty="*" ;;
	esac
done < <(git -C "$current_dir" --no-optional-locks status --porcelain=v2 --branch --untracked-files=no 2>/dev/null)

if [[ -n $repo ]]; then
	place=$repo
elif [[ $current_dir == "$project_dir"/* ]]; then
	place=$(basename "$project_dir")
else
	place=$(basename "$current_dir")
fi
place="${DEEP_CYAN}${place}${RESET}"
[[ -z $worktree ]] || place+=" ${GREY}wt${RESET} ${PINK}${worktree}${RESET}"
if [[ -n $branch ]]; then
	place+=" ${GREY}on${RESET} ${BOLD}${PURPLE}${branch}${RESET}"
	[[ -z $dirty ]] || place+="${PINK}${dirty}${RESET}"
fi

ctx_color=$(usage_color "$ctx_pct" 25)
head="${PINK}${model}${RESET}"
[[ -z $effort ]] || head+=" ${GREY}·${RESET} ${BOLD}${PURPLE}${effort}${RESET}"
[[ $fast != true ]] || head+=" ${PINK}fast${RESET}"
head+=" $(context_bar "$ctx_pct" "$ctx_color") ${ctx_color}${ctx_pct}%${RESET}"
head+=" ${FG}$(format_tokens "$ctx_tokens")/$(format_tokens "$ctx_size")${RESET}"
row1=("0 $head")
limits="$(limit_usage 5h "$five_pct" "$five_left")$(limit_usage 7d "$week_pct" "$week_left")"
[[ -z $limits ]] || row1+=("2 ${limits#  }")
row1+=("3 ${GREY}cost${RESET} ${ORANGE}$(printf '$%.2f' "$cost")${RESET}")

row2=("3 ${GREY}lines${RESET} ${DEEP_CYAN}+${added}${RESET}${GREY}/${RESET}${RED}-${removed}${RESET}")
if [[ -n $cache_hit ]]; then
	cache="${GREY}cache${RESET} ${CYAN}${cache_hit}%${RESET}"
	if [[ $cache_warm == true && -n $cache_left ]]; then
		cache+=" ${GREY}· cold in $(format_duration "$cache_left")${RESET}"
	elif [[ $cache_seen == true && $cache_warm != true ]]; then
		cache+=" ${GREY}·${RESET} ${ORANGE}cold${RESET}"
	fi
	row2+=("2 $cache")
fi
row2+=("4 ${GREY}time${RESET} ${PURPLE}$(format_duration "$duration")${RESET}")
row2+=("0 $place")
if [[ -n $pr_number ]]; then
	case $pr_state in
	approved) pr_state="${MINT}approved${RESET}" ;;
	changes_requested) pr_state="${RED}changes${RESET}" ;;
	pending) pr_state="${ORANGE}review${RESET}" ;;
	draft) pr_state="${GREY}draft${RESET}" ;;
	esac
	pr="${PURPLE}PR #${pr_number}${RESET}"
	[[ -z $pr_url ]] || pr="${ESC}]8;;${pr_url}${BEL}${pr}${ESC}]8;;${BEL}"
	row2+=("1 ${pr}${pr_state:+ $pr_state}")
fi

print_row "${row1[@]}"
printf ' \n'
print_row "${row2[@]}"
