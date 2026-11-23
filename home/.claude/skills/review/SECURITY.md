# Security checklist

What the Security sub-agent checks; `code-review` step 5 gives it this file's path, and it reads the parts its prompt names.

## Groups

1. **Authorisation** on every new or changed entry point: checked on the server, never only in the UI or middleware; "admin" and the user id come from the session or database, never the request; one user can't reach another's records by changing an id; errors fail closed.
2. **Authentication and sessions**: tokens verified, not just decoded (JWT signature and pinned `alg`); secrets compared in constant time; cookie flags; CSRF on cookie-authenticated changes; CORS that reflects the origin with credentials.
3. **Input at the boundary**: every route, action and handler checks its body, params and query against a schema on the server: types, required fields, sizes and lengths, unknown keys rejected. A gap is a finding when the input reaches a query, a command, a file, HTML or storage and the attack can be named: an oversized value stored on every request, an extra key that sets a field the user shouldn't.
4. **Mass assignment**: request data spread into a create or update, so a user can set `role`, `ownerId`, `price`, `status` or `published_at`; responses that return whole records.
5. **Paid, private and draft content**, on every path that can carry it: page render, metadata, search, lists, feeds and sitemaps, APIs, client fetches, and caches shared between users.
6. **Injection**: SQL (interpolated values or identifiers), NoSQL operators, OS commands and their arguments, templates, XSS through raw HTML, Markdown or `javascript:` links, XXE.
7. **Code execution**: `eval`, `new Function`, unsafe deserialisation, prototype pollution that reaches a sink.
8. **Files and URLs**: path traversal, zip slip, uploads (type, size, where they land), SSRF to a host or scheme the attacker picks, open redirects with a concrete chain.
9. **Data exposure**: server-only fields reaching the client; secrets or personal data in error messages or logs.
10. **Business logic and races**: check-then-act on a balance, stock, a redemption or a progression without a transaction or lock; a one-time action that can be replayed; a sensitive flow (coupon, one-time code, purchase) that can be repeated without limit.
11. **Secrets and privilege**: committed secrets, broad database grants, debug mode in production, weak randomness for tokens.
12. **Supply chain and CI**: a new dependency (a typosquat, an install script), `curl | sh`, untrusted `${{ github.event.* }}` in a workflow `run:`, `pull_request_target` checking out PR code, actions not pinned to a SHA.

## Out of scope

A finding is a concrete attack on this diff. These fall below that bar unless the diff gives a concrete chain to data, money or control:

- denial of service by request volume, ReDoS, and missing rate limits, apart from group 10's repeatable sensitive flows;
- missing hardening, headers or audit logs with no exploit;
- theoretical races, and timing attacks other than comparing a secret (an API key, a token, a webhook signature) with plain equality;
- vulnerable dependency versions, which `npm audit`, Dependabot and `govulncheck` report;
- anything a linter or scanner in the repo already reports;
- test files and docs;
- attacks that need control of the program's own environment variables or the flags its operator passes (data that reaches a command as an argument is group 6);
- missing checks in client-side code, since the server's check is the one that counts.

Precedents: React escapes text except through `dangerouslySetInnerHTML`; a UUID counts as a secret only while no other user can see it (in a list, a link or a feed); a shell injection finding needs a path from untrusted input.

## Language sections

**JavaScript / TypeScript (Node)**: `child_process.exec` or `shell: true` with input; `eval`, `new Function`, `vm`; deep merge or set-by-path with user-chosen keys (`__proto__`, `constructor.prototype`), fixed with `Map` or `Object.create(null)`; `fs` paths joined from input; a query param that arrives as an array where a string was expected; `===` on secrets instead of `crypto.timingSafeEqual`. TypeScript types are not checked at runtime.

**Next.js / React**: every exported `"use server"` function is a public endpoint and checks the user and each argument itself; `.bind()` arguments are not encrypted; props passed to a `"use client"` component send every field to the browser; `NEXT_PUBLIC_` variables, and server modules without `server-only`, reach the client; middleware is never the only auth check; `route.ts` handlers need their own CSRF protection; `revalidate` or static rendering on a page whose content depends on the user; `dangerouslySetInnerHTML`.

**Python**: `subprocess(..., shell=True)` or `os.system` with input; `pickle`, `yaml.load`, `jsonpickle`; `tarfile`/`zipfile` `extractall` without `filter='data'`; f-string SQL; Jinja with autoescape off, `|safe`, or `render_template_string` on input; `requests` to a user-supplied URL.

**Shell**: unquoted expansions; `eval` or `sh -c` on data; no `--` before user-supplied arguments; predictable `/tmp` paths instead of `mktemp`.

**Go**: `text/template` for HTML; `filepath.Join` with untrusted names (use `os.Root` or `filepath.IsLocal`); `exec.Command("sh", "-c", ...)`; `fmt.Sprintf` SQL; `InsecureSkipVerify`.

**SQL migrations**: `GRANT ... TO PUBLIC` or other broad grants; `SECURITY DEFINER` without `SET search_path` and `REVOKE ... FROM PUBLIC`; a new table without row-level security where the app relies on it.
