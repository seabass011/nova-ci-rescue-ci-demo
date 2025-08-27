#!/usr/bin/env bash
set -euo pipefail

# Bug Introduction Script for Nova CI-Rescue Demo
# This script introduces specific bugs into calculator.py to test Nova's fixing capabilities

echo "🐛 Introducing bugs in calculator.py for Nova CI-Rescue demo..."

# Check if calculator.py exists
if [ ! -f "src/calculator.py" ]; then
    echo "❌ Error: src/calculator.py not found!"
    exit 1
fi

# Create a backup if it doesn't exist
if [ ! -f "src/calculator.py.original" ]; then
    cp src/calculator.py src/calculator.py.original
    echo "📝 Created backup: src/calculator.py.original"
fi

# Read the original file and apply bugs
python3 << 'EOF'
import re

# Read the calculator file
with open('src/calculator.py', 'r') as f:
    content = f.read()

# Bug 1: Make add() subtract instead
content = re.sub(
    r'def add\(self, a, b\):\s*return a \+ b',
    'def add(self, a, b):\n        return a - b  # BUG: Should be a + b',
    content,
    flags=re.MULTILINE
)

# Bug 2: Make multiply() add instead  
content = re.sub(
    r'def multiply\(self, a, b\):\s*return a \* b',
    'def multiply(self, a, b):\n        return a + b  # BUG: Should be a * b',
    content,
    flags=re.MULTILINE
)

# Bug 3: Make power() multiply instead
content = re.sub(
    r'def power\(self, a, b\):\s*return a \*\* b',
    'def power(self, a, b):\n        return a * b  # BUG: Should be a ** b',
    content,
    flags=re.MULTILINE
)

# Bug 4: Break percentage calculation
content = re.sub(
    r'def percentage\(self, value, percent\):\s*return \(value \* percent\) / 100',
    'def percentage(self, value, percent):\n        return value * percent * 10  # BUG: Should be (value * percent) / 100',
    content,
    flags=re.MULTILINE
)

# Bug 5: Make average() return sum instead
content = re.sub(
    r'def average\(self, numbers\):\s*if not numbers:\s*raise ValueError\("Cannot calculate average of empty list"\)\s*return sum\(numbers\) / len\(numbers\)',
    '''def average(self, numbers):
        if not numbers:
            raise ValueError("Cannot calculate average of empty list")
        return sum(numbers)  # BUG: Should be sum(numbers) / len(numbers)''',
    content,
    flags=re.MULTILINE | re.DOTALL
)

# Write the buggy version
with open('src/calculator.py', 'w') as f:
    f.write(content)

print("✅ Bugs introduced successfully!")
EOF

echo "✅ Bugs introduced! The following functions are now broken:"
echo "  - add() now subtracts"
echo "  - multiply() now adds"
echo "  - power() now multiplies"
echo "  - percentage() multiplies by 10 instead of dividing by 100"
echo "  - average() returns sum instead of average"
echo
echo "🚀 Ready to commit and push to trigger Nova CI-Rescue!"
