#!/bin/bash

# Test script to demonstrate version conflict scenarios
# This script simulates different version conflict situations including pre environment

set -e

echo "🧪 Version Conflict Testing Script (Including Pre Environment)"
echo "=============================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to simulate version check
check_version_conflict() {
    local env=$1
    local version=$2
    local force_deploy=$3
    local version_exists=$4
    
    print_status $BLUE "🔍 Testing: ENV=$env, VERSION=$version, FORCE_DEPLOY=$force_deploy, VERSION_EXISTS=$version_exists"
    
    # Simulate the actual logic from the action
    if [[ "$env" == "dev" || "$force_deploy" == "true" ]]; then
        print_status $GREEN "✅ Skipping version conflict check for $env environment or force deployment"
        echo "   Result: can-deploy=true"
        return 0
    fi
    
    # For all other environments (including pre), check version conflicts
    if [[ "$version_exists" == "true" ]]; then
        print_status $RED "❌ Version $version already exists in S3"
        print_status $RED "❌ Version conflict detected. Use force-deploy: true to override, or increment the version."
        echo "   Result: can-deploy=false"
        return 1
    fi
    
    print_status $GREEN "✅ No version conflicts detected"
    echo "   Result: can-deploy=true"
    return 0
}

echo ""
print_status $YELLOW "📋 Test Scenarios (Current Implementation):"
echo ""

# Test Case 1: Dev environment - version exists
echo "Test 1: Dev environment with existing version"
check_version_conflict "dev" "1.0.0" "false" "true"
echo ""

# Test Case 2: Pre environment - first deployment
echo "Test 2: Pre environment with new version (first deployment)"
check_version_conflict "pre" "1.0.0" "false" "false"
echo ""

# Test Case 3: Pre environment - version exists (PROBLEM CASE)
echo "Test 3: Pre environment with existing version (staging retest scenario)"
print_status $PURPLE "📝 Scenario: QA found bug, fixed code, want to redeploy to staging"
check_version_conflict "pre" "1.0.0" "false" "true" || true
print_status $YELLOW "⚠️  This blocks typical staging workflows!"
echo ""

# Test Case 4: Pre environment - version exists with force
echo "Test 4: Pre environment with existing version (force deploy workaround)"
print_status $PURPLE "📝 Scenario: Using force-deploy to bypass staging restrictions"
check_version_conflict "pre" "1.0.0" "true" "true"
print_status $YELLOW "⚠️  This works but bypasses all safety checks"
echo ""

# Test Case 5: Prod environment - version exists
echo "Test 5: Prod environment with existing version (should be blocked)"
check_version_conflict "prod" "1.0.0" "false" "true" || true
echo ""

# Test Case 6: Prod environment - new version
echo "Test 6: Prod environment with new version"
check_version_conflict "prod" "1.0.1" "false" "false"
echo ""

print_status $YELLOW "📊 Current Behavior Summary:"
echo ""
echo "Environment | Version Exists | Force Deploy | Result | Notes"
echo "------------|----------------|--------------|--------|-------"
echo "dev         | Yes            | No           | ✅ Deploy | Always allows (good for dev)"
echo "dev         | Yes            | Yes          | ✅ Deploy | Redundant but works"
echo "pre         | No             | No           | ✅ Deploy | First deployment works"
echo "pre         | Yes            | No           | ❌ BLOCKED | 🚨 PROBLEM: Blocks staging retests"
echo "pre         | Yes            | Yes          | ✅ Deploy | Workaround but risky"
echo "prod        | Yes            | No           | ❌ BLOCKED | Good: Prevents prod conflicts"
echo "prod        | Yes            | Yes          | ✅ Deploy | Risky: Bypasses prod safety"
echo "prod        | No             | No           | ✅ Deploy | Good: Normal prod deployment"
echo ""

print_status $RED "🚨 Pre Environment Problems:"
echo ""
echo "1. STAGING RETEST BLOCKED:"
echo "   - Deploy v1.0.0 to pre for testing"
echo "   - QA finds bug, developer fixes it"
echo "   - Try to redeploy v1.0.0 to pre → BLOCKED"
echo "   - Must use force-deploy or increment version"
echo ""
echo "2. VERSION INFLATION:"
echo "   - v1.0.0 → pre (testing)"
echo "   - v1.0.1 → pre (bug fix)"
echo "   - v1.0.2 → pre (another fix)"
echo "   - v1.0.3 → prod (final version)"
echo "   - Result: v1.0.0-1.0.2 never went to production"
echo ""
echo "3. WORKFLOW FRICTION:"
echo "   - Staging should be flexible for testing"
echo "   - Current: Same strict rules as production"
echo "   - Forces workarounds (force-deploy)"
echo ""

print_status $GREEN "💡 Proposed Solutions:"
echo ""
echo "SOLUTION 1: Relaxed Pre Environment"
echo "  - Allow version overwrites in pre/staging"
echo "  - Show warnings but don't block"
echo "  - Keep strict rules for production"
echo ""
echo "SOLUTION 2: Pre-Release Versioning"
echo "  - Use: 1.0.0-rc.1, 1.0.0-pre.1, 1.0.0-staging.1"
echo "  - Clear distinction between staging and prod versions"
echo "  - Follows semantic versioning standards"
echo ""
echo "SOLUTION 3: Environment-Specific Policies"
echo "  - dev: Always allow (current)"
echo "  - pre: Allow with warnings"
echo "  - prod: Strict version checking (current)"
echo ""

print_status $BLUE "🔧 Recommended Pre Environment Logic:"
echo ""
echo 'if [[ "$ENV" == "pre" || "$ENV" == "staging" ]]; then'
echo '  if version_exists; then'
echo '    echo "::warning::Overwriting version $VERSION in staging"'
echo '    echo "::notice::Consider using pre-release versions (1.0.0-rc.1)"'
echo '  fi'
echo '  can_deploy=true'
echo 'fi'
echo ""

print_status $YELLOW "🎯 Pre-Release Version Examples:"
echo ""
echo "Release Candidates:"
echo "  1.0.0-rc.1    # First release candidate"
echo "  1.0.0-rc.2    # Second release candidate"
echo "  1.0.0         # Final production release"
echo ""
echo "Pre-release versions:"
echo "  1.0.0-pre.1   # Pre-release version 1"
echo "  1.0.0-pre.2   # Pre-release version 2"
echo "  1.0.0         # Final production release"
echo ""
echo "Staging versions:"
echo "  1.0.0-staging.1  # Staging version 1"
echo "  1.0.0-staging.2  # Staging version 2"
echo "  1.0.0            # Final production release"
echo ""

print_status $PURPLE "📋 Typical Staging Workflow (Current vs Proposed):"
echo ""
echo "CURRENT (Problematic):"
echo "1. Deploy v1.0.0 to pre → ✅ Success"
echo "2. QA finds bug → Fix code"
echo "3. Deploy v1.0.0 to pre → ❌ Version conflict"
echo "4. Must use force-deploy → ⚠️ Risky workaround"
echo ""
echo "PROPOSED (Better):"
echo "1. Deploy v1.0.0-rc.1 to pre → ✅ Success"
echo "2. QA finds bug → Fix code"
echo "3. Deploy v1.0.0-rc.2 to pre → ✅ Success"
echo "4. Deploy v1.0.0 to prod → ✅ Success"
echo ""

print_status $GREEN "🎯 Test completed!"
echo ""
print_status $YELLOW "Key Takeaway: Pre environment currently has same strict rules as production,"
print_status $YELLOW "which may be too restrictive for typical staging workflows."
