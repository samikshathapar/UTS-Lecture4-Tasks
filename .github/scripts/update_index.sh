
#!/bin/bash
set -e

HTML_FILE="index.html"

TODO_TASKS=$(sed -n '/^ToDo Tasks:/,/^Done Tasks:/p' "$1" |
    sed '1d;$d')

DONE_TASKS=$(sed -n '/^Done Tasks:/,$p' "$1" |
    sed '1d')

UNIT_TEST_RESULTS=$(cat "$2")

export TODO_TASKS DONE_TASKS UNIT_TEST_RESULTS

python3 - <<'PY'
import os
import re
from html import escape
from pathlib import Path

path = Path("index.html")
html = path.read_text(encoding="utf-8")

sections = {
    "pending": os.environ["TODO_TASKS"],
    "completed": os.environ["DONE_TASKS"],
    "unittest": os.environ["UNIT_TEST_RESULTS"],
}

for section_id, content in sections.items():
    pattern = (
        rf'(<pre id="{section_id}">)'
        rf'.*?(</pre>)'
    )
    html, count = re.subn(
        pattern,
        lambda m: m.group(1) + "\n" +
                  escape(content) + "\n" + m.group(2),
        html,
        flags=re.DOTALL,
    )
    if count != 1:
        raise RuntimeError(f"Missing pre section: {section_id}")

path.write_text(html, encoding="utf-8")
PY

echo "index.html updated successfully"
