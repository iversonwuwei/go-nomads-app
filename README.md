# go-nomads-app

Flutter client for Go Nomads.

## Utility Scripts

Repository maintenance scripts live under `scripts/`.

- `scripts/` contains reusable engineering helpers such as build helpers and release checks.
- `scripts/codemods/` contains reversible or batch Dart source transforms that operate on `lib/`.
- `scripts/audits/` contains read-only or report-generating audit scripts.
- Run Python scripts from the repository root, for example: `python3 scripts/codemods/replace_print_with_log.py` or `python3 scripts/audits/i18n_pages_audit.py`.
- Do not add temporary rewrite scripts back to the repository root.
