#!/usr/bin/env python3

import re
from collections import Counter
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
ROOT = PROJECT_ROOT / 'lib/pages'
PATTERN = re.compile(
    r"Text\(\s*'[^']+'|"
    r'Text\(\s*\"[^\"]+\"|'
    r"hintText\s*:\s*'[^']+'|"
    r'hintText\s*:\s*\"[^\"]+\"|'
    r"labelText\s*:\s*'[^']+'|"
    r"title\s*:\s*'[^']+'|"
    r"AppToast\.(?:error|success|warning|info)\(\s*'[^']+'|"
    r"label:\s*const Text\("
)


rows = []
for file_path in ROOT.rglob('*.dart'):
    lines = file_path.read_text(encoding='utf-8', errors='ignore').splitlines()
    for index, line in enumerate(lines, 1):
        stripped = line.strip()
        if 'l10n.' in stripped or 'AppLocalizations' in stripped:
            continue
        if PATTERN.search(stripped):
            rows.append((file_path.relative_to(PROJECT_ROOT).as_posix(), index, stripped))

workspace_reports_dir = PROJECT_ROOT / 'scripts/reports'
workspace_reports_dir.mkdir(parents=True, exist_ok=True)
workspace_raw_report = workspace_reports_dir / 'pages_i18n_candidates_raw.txt'
workspace_summary_report = workspace_reports_dir / 'pages_i18n_candidates_by_file.txt'

workspace_raw_report.write_text(
    '\n'.join(f"{file_path}:{line_no}: {content}" for file_path, line_no, content in rows),
    encoding='utf-8',
)

counter = Counter(file_path for file_path, _, _ in rows)
workspace_summary_report.write_text(
    '\n'.join(f"{count:4d} {file_path}" for file_path, count in counter.most_common()),
    encoding='utf-8',
)

print(f'RAW {len(rows)}')
print(f'FILES {len(counter)}')
print('TOP')
for file_path, count in counter.most_common(30):
    print(f"{count:4d} {file_path}")
print(f'RAW_FILE {workspace_raw_report.relative_to(PROJECT_ROOT).as_posix()}')
print(f'SUM_FILE {workspace_summary_report.relative_to(PROJECT_ROOT).as_posix()}')