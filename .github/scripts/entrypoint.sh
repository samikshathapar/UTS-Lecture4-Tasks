
#!/bin/bash
set -euo pipefail

cd /app

echo "Executing todo.py"
python3 .github/scripts/todo.py | tee todo_output.txt

echo "Executing todo-test.py"
python3 .github/scripts/todo-test.py | tee test_output.txt

echo "Executing update_index.sh"
bash .github/scripts/update_index.sh \
    todo_output.txt test_output.txt

if [ -d /output ]; then
    cp index.html /output/index.html
fi

echo "Done!"

