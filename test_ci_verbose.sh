#!/usr/bin/env bash
set -euo pipefail

# Nova CI Flow Test Script - Verbose Version
# Simulates: Good repo → Buggy PR → Tests fail → Nova fixes → Tests pass

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🚀 Nova CI Flow Simulation (Verbose Mode)${NC}"
echo "=========================================="
echo
echo "This simulates a GitHub Actions workflow where:"
echo "1. A good repository exists"
echo "2. Someone pushes a buggy PR"
echo "3. CI runs and detects failures"
echo "4. Nova automatically proposes and applies a fix"
echo "5. CI goes green without human intervention"
echo
read -p "Press Enter to begin..."
echo

# Setup environment
echo -e "${PURPLE}📦 Environment Setup${NC}"
if [ ! -f ".venv/bin/activate" ]; then
    echo "Setting up Python environment..."
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    
    # Install Nova CI-Rescue from demo branch
    echo "Installing Nova CI-Rescue..."
    pip uninstall -y nova nova-ci-rescue 2>/dev/null || true
    pip install --force-reinstall --no-cache-dir "git+https://github.com/novasolve/ci-auto-rescue.git@demo"
else
    source .venv/bin/activate
fi
echo "Environment ready!"
echo

# Phase 1: Pre-check (good state)
echo -e "${GREEN}✅ Phase 1: Initial Repository State${NC}"
echo "Running test suite on main branch (should be green)..."
echo
pytest tests/ -v
echo
echo -e "${GREEN}All tests passing! Repository is in good state.${NC}"
echo
read -p "Press Enter to simulate a buggy PR..."
echo

# Phase 2: Simulate buggy PR
echo -e "${YELLOW}📝 Phase 2: Simulating Buggy Pull Request${NC}"
echo "A developer submits PR #42: 'Performance optimizations'"
echo
echo "Changes being applied:"
echo "----------------------"
cat breaking-changes.patch | grep -E "^[-+]" | grep -v "^[-+]{3}" | head -20
echo "... and more"
echo
echo "Applying patch..."
git apply breaking-changes.patch
echo -e "${YELLOW}Buggy changes applied to src/calculator.py${NC}"
echo
read -p "Press Enter to run CI tests..."
echo

# Phase 3: Pre-check (should fail, but continue)
echo -e "${RED}❌ Phase 3: CI Pre-check (continue-on-error: true)${NC}"
echo "Running test suite..."
echo
set +e
pytest tests/ -v --tb=short --json-report --json-report-file=junit_report.json
TEST_EXIT_CODE=$?
set -e

if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo
    echo -e "${RED}CI Status: FAILING (exit code: $TEST_EXIT_CODE)${NC}"
    
    # Parse test results
    FAILED_TESTS=$(python -c "import json; data=json.load(open('junit_report.json')); print(len([t for t in data['tests'] if t['outcome'] == 'failed']))")
    TOTAL_TESTS=$(python -c "import json; data=json.load(open('junit_report.json')); print(len(data['tests']))")
    
    echo "Test Results: $FAILED_TESTS/$TOTAL_TESTS tests failed"
    echo
    echo "Failed tests:"
    python -c "
import json
data = json.load(open('junit_report.json'))
for test in data['tests']:
    if test['outcome'] == 'failed':
        print(f\"  - {test['nodeid']}\")"
    echo
else
    echo "Unexpected: tests should have failed!"
    exit 1
fi
read -p "Press Enter to run Nova CI-Rescue..."
echo

# Phase 4: Nova Rescue
echo -e "${BLUE}🤖 Phase 4: Nova CI-Rescue Workflow${NC}"
echo "CI detected failures - triggering Nova auto-fix..."
echo
echo "Nova Configuration:"
echo "  - Max iterations: 2 (CI constraint)"
echo "  - Timeout: 120 seconds"
echo "  - Target: Failing tests only"
echo "  - Mode: Auto-apply (demo mode)"
echo

# Create artifacts directory
ARTIFACTS_DIR=".nova/artifacts_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$ARTIFACTS_DIR"

# Capture current state
git diff src/calculator.py > "$ARTIFACTS_DIR/pre_nova.patch"

# Run Nova with verbose output
echo "Running Nova..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
nova fix . \
    --max-iters 2 \
    --timeout 120 \
    --pytest-args "tests/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Generate patch artifact
git diff src/calculator.py > "$ARTIFACTS_DIR/nova_fix.patch"

echo -e "${BLUE}Nova fix complete!${NC}"
echo "Artifacts saved to: $ARTIFACTS_DIR/"
echo "  - pre_nova.patch: The buggy state"
echo "  - nova_fix.patch: Nova's fix"
echo
read -p "Press Enter to verify the fix..."
echo

# Phase 5: Verify fix
echo -e "${GREEN}✅ Phase 5: CI Verification${NC}"
echo "Re-running test suite to verify Nova's fix..."
echo
pytest tests/ -v
VERIFY_EXIT_CODE=$?
echo

if [ $VERIFY_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}🎉 CI Status: PASSING${NC}"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}        CI PIPELINE SUMMARY${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. ✅ Initial state: All tests passing"
    echo "2. ❌ PR #42 introduced $FAILED_TESTS failing tests"
    echo "3. 🤖 Nova CI-Rescue automatically fixed the issues"
    echo "4. ✅ All tests now pass - pipeline is green!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "In production, this would:"
    echo "  - Create a commit on the PR branch"
    echo "  - Add a comment explaining the fixes"
    echo "  - Update the PR status to green ✅"
    echo
    
    # Show what Nova fixed
    echo "Nova's changes:"
    echo "---------------"
    git diff "$ARTIFACTS_DIR/pre_nova.patch" src/calculator.py | head -20
    
else
    echo -e "${RED}❌ CI Status: STILL FAILING${NC}"
    echo "Tests still failing after Nova fix"
    echo "In production, this would:"
    echo "  - Attach patch as artifact"
    echo "  - Comment on PR with partial fix"
    echo "  - Keep CI status as failing"
    echo
    echo "Artifacts available at: $ARTIFACTS_DIR/"
    exit 1
fi

# Cleanup
echo
echo "Cleaning up..."
rm -f junit_report.json
git checkout -- src/calculator.py
echo "Original state restored."
echo
echo "🎉 Nova CI-Rescue demo complete!"
