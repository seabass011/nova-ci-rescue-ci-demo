# Nova CI-Rescue CI Demo Repository

This is a **standalone** CI demo repository for testing Nova CI-Rescue workflows.

## Purpose

This repository demonstrates the complete Nova CI-Rescue CI flow:
1. **Good State** ✅ - All tests pass initially  
2. **Bad PR** ❌ - Apply `breaking-changes.patch` to introduce bugs
3. **Nova Rescue** 🤖 - Nova automatically fixes the issues
4. **Green Again** ✅ - Tests pass after Nova's fixes

## Quick Start

### Run CI Flow Locally
```bash
# Quick test (minimal output)
./test_ci.sh

# Interactive demo (step-by-step)
./test_ci_verbose.sh
```

### Manual Testing
```bash
# Install dependencies (done automatically by scripts)
pip install -r requirements.txt
pip install git+https://github.com/seb-nova/nova-ci-rescue.git

# Run tests (should all pass)
pytest tests/ -v

# Apply breaking changes
git apply breaking-changes.patch

# Run tests again (should fail)
pytest tests/ -v

# Run Nova to fix
nova fix . --pytest-args "tests/"

# Tests should pass again
pytest tests/ -v
```

## GitHub Actions Integration

Push to this repository to trigger the CI workflow:
- **Pre-check**: Tests run (continue on error)
- **Nova Rescue**: If tests fail, Nova automatically fixes them
- **Auto-apply**: Commits fixes back to the branch
- **Verify**: Tests run again and should pass

## Repository Structure
- `test_ci.sh` - Fast CI flow simulation
- `test_ci_verbose.sh` - Interactive demo with explanations
- `src/calculator.py` - Clean calculator implementation
- `tests/test_calculator.py` - Comprehensive test suite (14 tests)
- `breaking-changes.patch` - Simulated "bad PR" changes
- `.github/workflows/nova-ci-rescue.yml` - CI workflow

## Expected Flow
1. **Initial**: 14 tests pass ✅
2. **After patch**: 6+ tests fail ❌ 
3. **After Nova**: All tests pass ✅

## Repository URL
https://github.com/seabass011/nova-ci-rescue-ci-demo