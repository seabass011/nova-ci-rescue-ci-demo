#!/usr/bin/env bash
set -euo pipefail

# Nova CI Flow Test Script - VERBOSE VERSION
# This script tests the GitHub Actions CI workflow with detailed explanations and user interaction

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Nova CI-Rescue GitHub Actions Test - VERBOSE MODE${NC}"
echo "=========================================================="
echo
echo -e "${CYAN}This script will demonstrate the complete Nova CI-Rescue workflow:${NC}"
echo "1. 📊 Check current CI status"
echo "2. 🌿 Create a test branch with intentional bugs"
echo "3. 🐛 Introduce calculator bugs to trigger test failures"
echo "4. 📤 Push changes and create a pull request"
echo "5. 👀 Monitor Nova CI-Rescue as it automatically fixes the bugs"
echo "6. 🎉 Verify the fix and cleanup"
echo
read -p "Press Enter to begin the demonstration..."
echo

# Check if we have the required environment variables before unsetting
echo -e "${PURPLE}🔍 Checking prerequisites...${NC}"
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo -e "${RED}❌ Error: GITHUB_TOKEN not set${NC}"
    echo
    echo "To run this demo, you need a GitHub Personal Access Token."
    echo "Please set your GitHub token first:"
    echo -e "${YELLOW}  export GITHUB_TOKEN=your_github_token${NC}"
    echo
    echo "The token needs these permissions:"
    echo "  - repo (full repository access)"
    echo "  - workflow (update GitHub Action workflows)"
    echo "  - pull_requests (create and manage PRs)"
    exit 1
fi

echo -e "${GREEN}✅ GitHub token is configured${NC}"
echo

# Unset GH_TOKEN as requested (but keep GITHUB_TOKEN for gh CLI)
echo -e "${PURPLE}🔒 Security: Unsetting GH_TOKEN environment variable${NC}"
echo "   (This ensures we use only the GITHUB_TOKEN for GitHub CLI operations)"
unset GH_TOKEN || true
echo -e "${GREEN}✅ Environment prepared${NC}"
echo

read -p "Press Enter to check current CI status..."

# Phase 1: Check current CI status
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📊 Phase 1: Checking Current CI Status${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Let's see the recent workflow runs for the Nova CI-Rescue Demo:"
echo
gh run list --workflow="Nova CI-Rescue Demo" --limit 5 || echo "No previous runs found"
echo
echo -e "${CYAN}💡 This shows us the baseline - we'll create a new run that demonstrates Nova's capabilities.${NC}"
echo

read -p "Press Enter to create a test branch..."

# Phase 2: Create a test branch
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}🌿 Phase 2: Creating Test Branch${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

BRANCH_NAME="test-nova-ci-$(date +%Y%m%d-%H%M%S)"
echo -e "${CYAN}Creating a new branch: ${YELLOW}$BRANCH_NAME${NC}"
echo
echo "This branch will contain intentional bugs that Nova CI-Rescue will detect and fix."
echo

git checkout -b "$BRANCH_NAME"
echo -e "${GREEN}✅ Branch created and checked out${NC}"
echo

read -p "Press Enter to introduce bugs into the calculator..."

# Phase 3: Introduce bugs
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${RED}🐛 Phase 3: Introducing Bugs to Trigger CI Failure${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${CYAN}We're about to introduce several bugs into the calculator.py file:${NC}"
echo
echo "🔧 Planned bugs:"
echo "  1. add() function will subtract instead of adding"
echo "  2. multiply() function will add instead of multiplying"
echo "  3. power() function will multiply instead of exponentiating"
echo "  4. percentage() will multiply by 10 instead of dividing by 100"
echo "  5. average() will return sum instead of average"
echo
echo "These bugs will cause multiple test failures, giving Nova plenty to fix!"
echo

# First restore calculator to clean state if backup exists
if [ -f "src/calculator.py.original" ]; then
    echo "🔄 Restoring calculator.py to clean state from backup..."
    cp src/calculator.py.original src/calculator.py
    echo -e "${GREEN}✅ Calculator restored to clean state${NC}"
else
    echo "📝 Creating backup of current calculator.py..."
    cp src/calculator.py src/calculator.py.original
    echo -e "${GREEN}✅ Backup created${NC}"
fi
echo

read -p "Press Enter to run the bug introduction script..."
echo

# Now introduce bugs
echo "🐛 Running bug introduction script..."
./introduce-bugs.sh
echo

read -p "Press Enter to commit and push these changes to trigger CI..."

# Phase 4: Commit and push to trigger CI
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📤 Phase 4: Pushing Changes to Trigger GitHub Actions${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "📝 Staging the modified calculator.py file..."
git add src/calculator.py

echo "📝 Creating a detailed commit message..."
git commit -m "Test Nova CI-Rescue: Introduce calculator bugs

This commit intentionally breaks several calculator functions to test
Nova CI-Rescue's ability to automatically fix failing tests.

Bugs introduced:
- add() now subtracts
- multiply() now adds  
- power() now multiplies
- percentage() calculation is wrong
- average() returns sum instead of average

Expected workflow:
1. CI tests will fail
2. Nova CI-Rescue will detect failures
3. Nova will analyze and create fixes
4. Nova will apply fixes and re-run tests
5. All tests should pass after Nova's intervention"

echo -e "${GREEN}✅ Changes committed locally${NC}"
echo

echo "🚀 Pushing branch to GitHub to trigger the workflow..."
git push origin "$BRANCH_NAME"
echo -e "${GREEN}✅ Branch pushed successfully${NC}"
echo

read -p "Press Enter to create a pull request..."

# Phase 5: Create PR to trigger workflow
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}🔄 Phase 5: Creating Pull Request${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "📋 Creating a pull request with detailed description..."
echo "   This will trigger the Nova CI-Rescue workflow automatically."
echo

PR_URL=$(gh pr create \
    --title "🧪 Test Nova CI-Rescue: Calculator bugs for demo" \
    --body "# Nova CI-Rescue Demonstration

This PR contains **intentional bugs** to showcase Nova CI-Rescue's capabilities.

## 🎯 Expected Workflow:
1. ❌ **CI tests will fail** due to the bugs introduced
2. 🤖 **Nova CI-Rescue will activate** and detect the test failures  
3. 🔍 **Nova will analyze** the failing tests and source code
4. 🛠️ **Nova will generate fixes** for each failing test
5. ✅ **Nova will apply fixes** and verify all tests pass
6. 🎉 **CI will turn green** automatically!

## 🐛 Bugs Introduced:
- \`add(a, b)\` → now subtracts: \`return a - b\`
- \`multiply(a, b)\` → now adds: \`return a + b\`  
- \`power(a, b)\` → now multiplies: \`return a * b\`
- \`percentage(value, percent)\` → wrong calculation: \`return value * percent * 10\`
- \`average(numbers)\` → returns sum: \`return sum(numbers)\`

## 🔬 What to Watch:
- Check the **Actions** tab to see Nova in action
- Nova will create detailed logs of its analysis and fixes
- The commit history will show Nova's automatic fixes
- All tests should pass after Nova's intervention

**Sit back and watch the magic happen!** ✨🎩" \
    --base main \
    --head "$BRANCH_NAME")

echo -e "${GREEN}✅ Pull request created successfully!${NC}"
echo "🔗 PR URL: $PR_URL"
echo

read -p "Press Enter to start monitoring the GitHub Actions workflow..."

# Phase 6: Monitor CI workflow  
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}👀 Phase 6: Monitoring GitHub Actions Workflow${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "⏳ Waiting for GitHub Actions workflow to start..."
echo "   (GitHub typically takes 10-30 seconds to start a workflow)"
echo

# Wait a bit for the workflow to start
for i in {10..1}; do
    echo -ne "\r⏱️  Waiting ${i} seconds for workflow to initialize..."
    sleep 1
done
echo
echo

# Get the run ID
echo "🔍 Looking for the latest workflow run..."
RUN_ID=$(gh run list --workflow="Nova CI-Rescue Demo" --limit 1 --json databaseId --jq '.[0].databaseId // empty')

if [ -n "${RUN_ID:-}" ]; then
    echo -e "${GREEN}✅ Workflow run found: #$RUN_ID${NC}"
    echo
    echo "🌐 View in browser: https://github.com/novasolve/nova-rescue-ci-demo/actions/runs/$RUN_ID"
    echo
    echo -e "${CYAN}📊 What you'll see in the workflow:${NC}"
    echo "  1. 🧪 Pre-check tests (will fail due to our bugs)"
    echo "  2. 🤖 Nova CI-Rescue installation and activation"  
    echo "  3. 🔍 Nova analyzing failing tests and source code"
    echo "  4. 🛠️ Nova generating and applying fixes"
    echo "  5. ✅ Verification that all tests now pass"
    echo
    
    read -p "Press Enter to start following the workflow progress in real-time..."
    echo
    echo "📡 Following workflow progress (this will stream live logs)..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Follow the workflow (this will stream logs)
    gh run watch "$RUN_ID" --interval 5
    
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🏁 Workflow completed! Getting final status..."
    
    # Get final status
    STATUS=$(gh run view "$RUN_ID" --json conclusion --jq '.conclusion')
    
    if [ "$STATUS" = "success" ]; then
        echo -e "${GREEN}🎉 Workflow completed successfully!${NC}"
        echo
        echo -e "${CYAN}This means:${NC}"
        echo "  ✅ Nova successfully detected the failing tests"
        echo "  ✅ Nova analyzed the code and identified the bugs"
        echo "  ✅ Nova generated appropriate fixes"
        echo "  ✅ Nova applied the fixes automatically"
        echo "  ✅ All tests are now passing!"
        
        # Check for Nova's changes in the current branch
        echo
        echo "🔍 Checking for Nova's fixes in the current branch..."
        
        # Pull the latest changes to see Nova's fixes
        git pull origin "$BRANCH_NAME" || echo "No new changes to pull"
        
        # Show what Nova changed
        if ! git diff --quiet HEAD~1 HEAD; then
            echo -e "${GREEN}📝 Nova made the following changes:${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            git diff --stat HEAD~1 HEAD
            echo
            echo "🔍 Detailed changes:"
            git diff HEAD~1 HEAD src/calculator.py || echo "Changes may be in other files"
        else
            echo "ℹ️  Nova's changes may have been applied to a different branch or PR"
        fi
        
    elif [ "$STATUS" = "failure" ]; then
        echo -e "${RED}❌ Workflow failed with status: $STATUS${NC}"
        echo
        echo "This could mean:"
        echo "  • Nova encountered an issue during analysis"
        echo "  • The bugs were too complex for Nova to fix automatically"
        echo "  • There was an environment or configuration issue"
        echo
        echo "💡 Check the workflow logs for details:"
        echo "   https://github.com/novasolve/nova-rescue-ci-demo/actions/runs/$RUN_ID"
    else
        echo -e "${YELLOW}⚠️  Workflow completed with status: $STATUS${NC}"
        echo "Check the logs for more details."
    fi
    
else
    echo -e "${YELLOW}⚠️  Could not find workflow run automatically.${NC}"
    echo
    echo "This might happen if:"
    echo "  • The workflow is still starting up"
    echo "  • There was an issue with the PR creation"
    echo "  • GitHub is experiencing delays"
    echo
    echo "🔗 Check manually at:"
    echo "   https://github.com/novasolve/nova-rescue-ci-demo/actions"
    echo "   $PR_URL"
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📋 Demo Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo -e "${CYAN}🎯 What we demonstrated:${NC}"
echo "  1. ✅ Created a test branch with intentional bugs"
echo "  2. ✅ Triggered GitHub Actions CI workflow"
echo "  3. ✅ Nova CI-Rescue detected and analyzed failing tests"
echo "  4. ✅ Nova automatically generated and applied fixes"
echo "  5. ✅ All tests passed after Nova's intervention"
echo
echo -e "${CYAN}📊 Key resources:${NC}"
echo "  • Test branch: $BRANCH_NAME"
echo "  • Pull request: $PR_URL"
echo "  • Workflow runs: https://github.com/novasolve/nova-rescue-ci-demo/actions"
echo
echo -e "${CYAN}🚀 Next steps:${NC}"
echo "  1. Review Nova's fixes in the PR or workflow logs"
echo "  2. Merge the PR to see the fixes in main branch"
echo "  3. Run more tests with different types of bugs"
echo "  4. Integrate Nova CI-Rescue into your own projects!"
echo

read -p "Press Enter to clean up GitHub tokens..."

# Final cleanup - unset tokens for security
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${PURPLE}🔒 Security Cleanup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "🧹 Clearing GitHub tokens from environment for security..."
unset GH_TOKEN || true
unset GITHUB_TOKEN || true
unset TEMP_GITHUB_TOKEN || true
echo -e "${GREEN}✅ All tokens cleared from environment${NC}"
echo
echo -e "${GREEN}🎉 Nova CI-Rescue demonstration completed successfully!${NC}"
echo
echo "Thank you for trying Nova CI-Rescue! 🚀"
