#!/bin/bash

# Test script to demonstrate version conflict scenarios
# This script simulates different version conflict situations

set -e

echo "🧪 Version Conflict Testing Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
print_status $YELLOW "📋 Test Scenarios:"
echo ""

# Test Case 1: Dev environment - version exists
echo "Test 1: Dev environment with existing version"
check_version_conflict "dev" "1.0.0" "false" "true"
echo ""

# Test Case 2: Prod environment - version exists, no force
echo "Test 2: Prod environment with existing version (no force deploy)"
check_version_conflict "prod" "1.0.0" "false" "true" || true
echo ""

# Test Case 3: Prod environment - version exists, with force
echo "Test 3: Prod environment with existing version (force deploy enabled)"
check_version_conflict "prod" "1.0.0" "true" "true"
echo ""

# Test Case 4: Prod environment - new version
echo "Test 4: Prod environment with new version"
check_version_conflict "prod" "1.0.1" "false" "false"
echo ""

# Test Case 5: Staging environment - version exists
echo "Test 5: Staging environment with existing version"
check_version_conflict "staging" "1.0.0" "false" "true" || true
echo ""

print_status $YELLOW "📊 Summary of Behaviors:"
echo ""
echo "Environment | Version Exists | Force Deploy | Result"
echo "------------|----------------|--------------|--------"
echo "dev         | Yes            | No           | ✅ Deploy (overwrites)"
echo "dev         | Yes            | Yes          | ✅ Deploy (overwrites)"
echo "prod        | Yes            | No           | ❌ Fail (version conflict)"
echo "prod        | Yes            | Yes          | ✅ Deploy (overwrites)"
echo "prod        | No             | No           | ✅ Deploy (new version)"
echo "staging     | Yes            | No           | ❌ Fail (version conflict)"
echo ""

print_status $YELLOW "🚨 Risk Analysis:"
echo ""
echo "HIGH RISK scenarios:"
echo "- Prod deployment with force-deploy: true"
echo "- Code changes without version increment"
echo "- Multiple deployments with same version"
echo ""
echo "MEDIUM RISK scenarios:"
echo "- Dev environment version overwrites"
echo "- Staging deployments without proper versioning"
echo ""
echo "LOW RISK scenarios:"
echo "- New version deployments"
echo "- Proper version increment workflow"
echo ""

print_status $YELLOW "💡 Recommendations:"
echo ""
echo "1. Always increment version for code changes"
echo "2. Use force-deploy only for emergencies"
echo "3. Implement pre-commit hooks to check version updates"
echo "4. Use semantic versioning (major.minor.patch)"
echo "5. Tag releases in Git for better tracking"
echo ""

print_status $BLUE "🔧 Version Increment Examples:"
echo ""
echo "Current version: 1.0.0"
echo ""
echo "Bug fix:       1.0.0 → 1.0.1  (patch)"
echo "New feature:   1.0.1 → 1.1.0  (minor)"
echo "Breaking:      1.1.0 → 2.0.0  (major)"
echo ""
echo "Commands:"
echo "  echo 'version = \"1.0.1\"' > pyproject.toml"
echo "  # or use bump2version:"
echo "  pip install bump2version"
echo "  bump2version patch"
echo ""

print_status $GREEN "🎯 Test completed!"
