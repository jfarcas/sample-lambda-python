#!/bin/bash

# Test script to verify pre environment version checking behavior
# This simulates the version check logic for pre environment

set -e

echo "🧪 Pre Environment Version Check Test"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Simulate the pre environment version check logic
simulate_pre_version_check() {
    local env=$1
    local version=$2
    local force_deploy=$3
    local version_exists=$4
    local bucket="lambda-deploy-action"
    local function="lambda-deploy-python"
    
    print_status $BLUE "🔍 Testing Pre Environment Version Check"
    echo "Environment: $env"
    echo "Version: $version"
    echo "Force Deploy: $force_deploy"
    echo "Version Exists: $version_exists"
    echo ""
    
    # Simulate the actual logic from action.yml
    case "$env" in
        "dev"|"development")
            print_status $GREEN "🔧 Development environment: Always allow deployment"
            echo "can-deploy=true"
            return 0
            ;;
            
        "pre"|"staging"|"test")
            print_status $BLUE "🧪 Staging environment: Check for version conflicts in staging"
            
            # Check if version exists in PRE environment specifically
            PRE_S3_PATH="s3://$bucket/$function/environments/pre/versions/$version/"
            echo "Checking S3 path: $PRE_S3_PATH"
            
            if [[ "$force_deploy" == "true" ]]; then
                print_status $YELLOW "🚨 Force deployment enabled - bypassing version checks"
                echo "can-deploy=true"
                return 0
            elif [[ "$version_exists" == "true" ]]; then
                print_status $YELLOW "⚠️  Version $version already exists in PRE environment"
                print_status $YELLOW "::warning::Version $version exists in staging environment"
                print_status $BLUE "::notice::Allowing overwrite for staging testing flexibility"
                print_status $BLUE "::notice::Consider using pre-release versions: $version-rc.1"
                echo "can-deploy=true"
                return 0
            else
                print_status $GREEN "✅ Version $version is new in PRE environment"
                echo "can-deploy=true"
                return 0
            fi
            ;;
            
        "prod"|"production")
            print_status $BLUE "🏭 Production environment: Strict version conflict checking"
            
            PROD_S3_PATH="s3://$bucket/$function/environments/prod/versions/$version/"
            echo "Checking S3 path: $PROD_S3_PATH"
            
            if [[ "$force_deploy" == "true" ]]; then
                print_status $YELLOW "🚨 Force deployment enabled in PRODUCTION"
                print_status $YELLOW "::warning::Force deployment bypasses all safety checks"
                echo "can-deploy=true"
                return 0
            elif [[ "$version_exists" == "true" ]]; then
                print_status $RED "❌ Version conflict in PRODUCTION environment"
                print_status $RED "::error::Version $version already exists in production"
                echo "can-deploy=false"
                return 1
            else
                print_status $GREEN "✅ Version $version is new in PRODUCTION environment"
                echo "can-deploy=true"
                return 0
            fi
            ;;
    esac
}

echo ""
print_status $YELLOW "📋 Test Scenarios:"
echo ""

# Test Case 1: Pre environment - new version
echo "Test 1: Pre environment with new version"
simulate_pre_version_check "pre" "1.0.0" "false" "false"
echo ""

# Test Case 2: Pre environment - existing version (KEY TEST)
echo "Test 2: Pre environment with existing version"
print_status $PURPLE "📝 Expected: Should allow deployment with warnings"
simulate_pre_version_check "pre" "1.0.0" "false" "true"
echo ""

# Test Case 3: Pre environment - existing version with force
echo "Test 3: Pre environment with existing version and force deploy"
simulate_pre_version_check "pre" "1.0.0" "true" "true"
echo ""

# Test Case 4: Prod environment - existing version (comparison)
echo "Test 4: Prod environment with existing version (should block)"
print_status $PURPLE "📝 Expected: Should block deployment with error"
simulate_pre_version_check "prod" "1.0.0" "false" "true" || true
echo ""

# Test Case 5: Dev environment - existing version (comparison)
echo "Test 5: Dev environment with existing version (should allow)"
simulate_pre_version_check "dev" "1.0.0" "false" "true"
echo ""

print_status $YELLOW "📊 Expected Pre Environment Behavior:"
echo ""
echo "✅ NEW VERSION: Allow deployment"
echo "✅ EXISTING VERSION: Allow deployment with warnings"
echo "✅ FORCE DEPLOY: Allow deployment (bypass checks)"
echo ""
print_status $BLUE "🎯 Key Point: Pre environment should ALWAYS allow deployment"
print_status $BLUE "   - New versions: Deploy normally"
print_status $BLUE "   - Existing versions: Deploy with warnings (for staging flexibility)"
print_status $BLUE "   - This enables staging testing workflows"
echo ""

print_status $RED "🚨 If pre environment is blocking deployments:"
echo ""
echo "POSSIBLE ISSUES:"
echo "1. S3 path mismatch - check if S3 structure matches expected paths"
echo "2. Environment detection - verify 'pre' is being detected correctly"
echo "3. Logic error - version check might be using wrong environment logic"
echo ""

print_status $GREEN "🔍 Debug Steps:"
echo ""
echo "1. Check deployment logs for environment detection:"
echo "   Look for: '🧪 Staging environment: Check for version conflicts'"
echo ""
echo "2. Verify S3 path being checked:"
echo "   Should be: s3://bucket/function/environments/pre/versions/VERSION/"
echo ""
echo "3. Confirm version exists check:"
echo "   aws s3 ls 's3://bucket/function/environments/pre/versions/1.0.0/'"
echo ""
echo "4. Check can-deploy output:"
echo "   Should always be: can-deploy=true for pre environment"
echo ""

print_status $YELLOW "🎯 Summary: Pre environment should never block deployments"
print_status $YELLOW "   It should only show warnings and allow overwrites"
