# Go Conventions — Index

Entry point for the `go-conventions` sub-skill. This file is a **map**, not the rules:
load the `src/<file>.md` named below to get the full rule, and cite that file when
raising a finding. Do not paste this whole file into a review.

## How to use

1. Identify the topic in the change or plan (e.g. "error handling", "a new struct").
2. Load the matching `src/*.md` file(s) listed under that heading.
3. Apply the rule exactly as written; every finding references its source file.

---

## Guidelines (core correctness)

- `interface-pointer.md` — pass/return interfaces as values, never `*Interface`
- `interface-compliance.md` — assert interface compliance at compile time (`var _ T = (*Impl)(nil)`)
- `interface-receiver.md` — receiver and interface-ownership decisions
- `mutex-zero-value.md` — mutexes are zero-value fields, never embedded
- `container-copy.md` — copy slices/maps at API boundaries (on receive and on return)
- `defer-clean.md` — `defer` for lock/file/connection cleanup
- `channel-size.md` — channel buffering is one or none
- `enum-start.md` — start enums (`iota`) at 1 unless zero is the default
- `time.md` — use `time.Time` / `time.Duration`, never raw int/string
- `builtin-name.md` — don't shadow built-in names (`error`, `string`)
- `struct-tag.md` — tag every field in marshaled structs
- `embed-public.md` — don't embed types in public structs
- `global-mut.md` — avoid mutable globals; inject instead (`now func() time.Time`)
- `atomic.md` — atomics vs mutexes
- `panic.md` — return errors, don't panic (tests excepted)

## Errors

- `error-type.md` — `errors.New` vs sentinel `var ErrX` vs custom `XError`
- `error-wrap.md` — wrap with `%w` (default) / `%v` (obfuscate)
- `error-name.md` — `Err*`/`err*` vars, `*Error` types
- `error-once.md` — handle each error once; never log-then-return

## Concurrency & goroutines

- `goroutine-forget.md` — no fire-and-forget; every goroutine has a stop signal and is waited on
- `goroutine-exit.md` — wait for goroutines to exit / shutdown
- `goroutine-init.md` — no goroutines in `init()`

## Lifecycle & exit

- `init.md` — deterministic `init()`: no I/O, env, args, goroutines
- `exit-main.md` — `os.Exit`/`log.Fatal` only in `main`, via `run() error`
- `exit-once.md` — exit at most once

## Types & assertions

- `type-assert.md` — always use the comma-ok form

## Performance

- `performance.md` — performance rules overview (apply to hot paths only)
- `strconv.md` — `strconv` over `fmt` for conversions/formatting
- `string-byte-slice.md` — avoid repeated `[]byte(str)` conversions
- `container-capacity.md` — set capacity in `make` when known

## Style & naming

- `consistency.md` — when styles clash, consistency wins
- `line-length.md` — soft 99-char lines
- `decl-group.md` — group `const`/`var`/`type` declarations
- `import-group.md` — two import groups (stdlib, then everything else)
- `import-alias.md` — alias imports only when needed
- `package-name.md` — lowercase, short, non-plural; never `common|util|shared|lib`
- `function-name.md` — MixedCaps, no underscores
- `function-order.md` — exported first, grouped, leaf helpers last
- `nest-less.md` — reduce nesting via early return/continue
- `else-unnecessary.md` — drop unnecessary `else`
- `global-decl.md` — top-level variable declarations
- `global-name.md` — prefix unexported package vars with `_`
- `var-decl.md` — local variable declarations
- `var-scope.md` — reduce variable scope
- `param-naked.md` — avoid naked parameters
- `string-escape.md` — raw string literals
- `slice-nil.md` — `nil` is a valid slice
- `printf-const.md` — format strings as constants
- `printf-name.md` — name Printf-style funcs with an `f` suffix

## Structs & maps

- `struct-embed.md` — embedding in structs
- `struct-field-key.md` — initialize structs with field names
- `struct-field-zero.md` — omit zero-value fields
- `struct-zero.md` — `var` for zero-value structs
- `struct-pointer.md` — `&T{}`, not `new(T)`
- `map-init.md` — `make` for empty maps; literals for fixed content

## Patterns

- `test-table.md` — table-driven tests (`give`/`want`, sub-branch-free `t.Run`)
- `functional-option.md` — constructors with optional params → functional options

## Linting

- `lint.md` — the default linter set

## Reference

- `intro.md` — guide introduction & scope (background, not an enforceable rule)
