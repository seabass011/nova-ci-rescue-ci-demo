#!/usr/bin/env bash
set -euo pipefail

# Nova CI Flow Test Script
# Simulates: Good repo → Buggy PR → Tests fail → Nova fixes → Tests pass

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Nova CI Flow Simulation${NC}"
echo "================================"
echo

# Install dependencies if needed
if [ ! -f ".venv/bin/activate" ]; then
    echo "Setting up Python environment..."
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    
    # Install Nova CI-Rescue from demo branch
    pip uninstall -y nova nova-ci-rescue 2>/dev/null || true
    pip install --force-reinstall --no-cache-dir "git+https://github.com/novasolve/ci-auto-rescue.git@demo"
else
    source .venv/bin/activate
fi

# Phase 1: Pre-check (good state)
echo -e "${GREEN}✅ Phase 1: Initial state (all tests passing)${NC}"
pytest tests/ -q --tb=no
echo

# Phase 2: Simulate buggy PR
echo -e "${YELLOW}📝 Phase 2: Applying buggy PR changes${NC}"
git apply breaking-changes.patch
echo "Bug introduced in src/calculator.py"
echo

# Phase 3: Pre-check (should fail, but continue)
echo -e "${RED}❌ Phase 3: Pre-check tests (continue-on-error)${NC}"
set +e
pytest tests/ -q --tb=no --json-report --json-report-file=junit_report.json
TEST_EXIT_CODE=$?
set -e

if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}Tests failed as expected (exit code: $TEST_EXIT_CODE)${NC}"
    FAILED_TESTS=$(python -c "import json; data=json.load(open('junit_report.json')); print(len([t for t in data['tests'] if t['outcome'] == 'failed']))")
    echo "Failed tests: $FAILED_TESTS"
else
    echo "Unexpected: tests should have failed!"
    exit 1
fi
echo

# Phase 4: Nova Rescue
echo -e "${BLUE}🤖 Phase 4: Nova CI-Rescue${NC}"
echo "Running Nova with CI constraints (2 iterations, 120s timeout)..."

# Create a temporary file to store Nova's patch
PATCH_FILE=".nova/fix_patch_$(date +%Y%m%d_%H%M%S).patch"
mkdir -p .nova

# Run Nova and capture the fix
nova fix . \
    --max-iters 2 \
    --timeout 120 \
    --pytest-args "tests/" \
    --quiet

# Generate patch artifact
git diff src/calculator.py > "$PATCH_FILE"
echo "Patch saved to: $PATCH_FILE"
echo

# Phase 5: Verify fix
echo -e "${GREEN}✅ Phase 5: Verify fix${NC}"
pytest tests/ -q --tb=no
VERIFY_EXIT_CODE=$?

if [ $VERIFY_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests pass! CI pipeline is green!${NC}"
    echo
    echo "Summary:"
    echo "- Started with working code ✅"
    echo "- Buggy PR broke $FAILED_TESTS tests ❌"
    echo "- Nova automatically fixed the issues 🤖"
    echo "- All tests pass again ✅"
else
    echo -e "${RED}❌ Tests still failing after Nova fix${NC}"
    echo "Patch artifact available at: $PATCH_FILE"
    exit 1
fi

# Cleanup
rm -f junit_report.json
git checkout -- src/calculator.py

echo
echo "🎉 Nova CI-Rescue demo complete!"
