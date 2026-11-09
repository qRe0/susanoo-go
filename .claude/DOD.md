# Definition of Done (DoD) - Go

This is the only Definition of Done in the kit. Stages name the applicable tier and point here; they do not define another gate list. The only document precedence hierarchy is in [AGENTS.md](../AGENTS.md#sources-of-truth); read it there. Use the consumer repository's documented test, lint, security, generation, and integration runners from its build files, CI, and `specs/architecture.md`. If this file's command guidance disagrees with the consumer's build system, the build system wins. Record the exact commands and results. If a tool is absent, report `N/A - not configured`.

In root-folder mode, every `specs/` and `tasks/` path below is read under `.susanoo/<project>/`.

A bare `go test ./...` omits `-race`, `-count=1`, and `-shuffle=on`; it can return a cached pass without executing tests. When no project runner exists, use `go test -count=1 -shuffle=on ./...` for an uncached suite, and add `-race` when shared state or concurrency is in scope and supported. Run from the affected module root; check every affected module in a multi-module repo.

## Minimum

- [ ] No stray uncommitted changes outside the task: `git status --short`
- [ ] Changed files have no whitespace errors: `git diff --check`
- [ ] File naming follows the conventions in `tasks/` and `specs/`
- [ ] Context Summary plus Next Steps provided

## Standard

All Minimum items, plus:

- [ ] Formatting clean: `gofmt -w` was applied to changed `.go` files, and `gofmt -l` reports no changed files
- [ ] Tests pass through the repository's runner or the uncached Go fallback above
- [ ] Vet passes through the repository's configured runner or `go vet ./...`
- [ ] Lint, vulnerability, and security checks pass when configured, using the repository's commands and configuration
- [ ] Generated code is current if generators exist; run the repository's generator and review the diff
- [ ] New code has at least happy-path test coverage
- [ ] Relevant edge cases have tests; integration checks run for changed external or database boundaries when supported
- [ ] When the architecture profile requires TDD for this change or the task explicitly opts in, the handoff records an observed behavior-driven RED, GREEN, and final check (or a user-accepted exception). A final passing suite alone does not establish TDD. This check is N/A when TDD was not selected; all other test gates still apply
- [ ] Dependency-file changes are intentional and reviewed; run the repository's tidy check when dependencies change
- [ ] Blocking review/security findings and task questions are resolved or explicitly accepted
- [ ] When project-owned `.claude/client/acceptance-criteria.md` contains relevant hard rules, each applicable rule has passing automated evidence or a recorded manual review; unresolved rules are reported, never silently treated as PASS
- [ ] For a changed API surface, its API contract is updated and indexed in `specs/MANIFEST.md`
- [ ] API or generated contract validation passes through the repository's configured tooling
- [ ] Migration apply, rollback, and drift checks pass when a schema changes and the repository supports them
- [ ] No data race risks in concurrent code; run the repository's race check or a focused/uncached Go race test for shared-state or goroutine-heavy changes
- [ ] No OWASP Top 10 issue introduced
- [ ] Self-reviewed against `.claude/GOLDEN-PRINCIPLES.md` and `specs/architecture.md`

## Full

All Standard items, plus:

- [ ] Relevant CI checks are green for the commit being delivered, or a local equivalent is recorded when CI is unavailable
- [ ] If a PR is opened, its description includes summary and test plan
- [ ] `CHANGELOG.md` updated if release
- [ ] Specs updated if architecture/API changed
- [ ] No unresolved `TODO`/`FIXME`/`HACK` in production code
- [ ] Documentation updated for user-facing changes
- [ ] Relevant secrets and payment/cloud/IaC safety checks are complete

## How to Use

Use Minimum for docs-only/exploration, Standard for normal implementation, and Full for releases, merges, or high-risk auth, security, payment, webhook, cloud, schema migration, generated contract, concurrency primitive, or infrastructure work. For each applicable check, record PASS, FAIL, NOT RUN with reason, or N/A if genuinely not configured. Review dependency-file changes from any tidy/generation command before keeping them. If a check fails, fix it or escalate to `systematic-debugger`; do not report a task complete with known failing gates.
