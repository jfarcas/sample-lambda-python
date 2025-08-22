#!/bin/bash

# Test script to demonstrate S3 structure problems
# This shows the critical issues with current S3 paths and version checking

set -e

echo "🧪 S3 Structure Problems Demonstration"
echo "======================================"

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

# Simulate current S3 structure and version checking
simulate_current_behavior() {
    local env=$1
    local version=$2
    local bucket="lambda-deploy-bucket"
    local function="my-lambda-function"
    
    print_status $BLUE "🔍 Simulating: ENV=$env, VERSION=$version"
    
    # Current version check path (WRONG!)
    VERSION_CHECK_PATH="s3://$bucket/$function/versions/$version/"
    
    # Current upload paths
    if [[ "$env" == "dev" ]]; then
        TIMESTAMP=$(date +%s)
        UPLOAD_PATH="s3://$bucket/$function/dev/$TIMESTAMP/lambda.zip"
    else
        UPLOAD_PATH="s3://$bucket/$function/$version/$function-$version.zip"
    fi
    
    echo "  Version Check Path: $VERSION_CHECK_PATH"
    echo "  Upload Path:        $UPLOAD_PATH"
    
    # Check if paths match
    if [[ "$VERSION_CHECK_PATH" == *"/versions/$version/"* && "$UPLOAD_PATH" == *"/$version/"* ]]; then
        print_status $GREEN "  ✅ Paths would match (but they don't in current implementation)"
    else
        print_status $RED "  ❌ PATHS DON'T MATCH - Version check will always fail!"
    fi
    
    echo ""
}

# Simulate environment collision
simulate_environment_collision() {
    local version=$1
    local bucket="lambda-deploy-bucket"
    local function="my-lambda-function"
    
    print_status $PURPLE "🚨 Environment Collision Simulation for version $version"
    
    # Both pre and prod use same path
    PRE_PATH="s3://$bucket/$function/$version/$function-$version.zip"
    PROD_PATH="s3://$bucket/$function/$version/$function-$version.zip"
    
    echo "  Pre deployment path:  $PRE_PATH"
    echo "  Prod deployment path: $PROD_PATH"
    
    if [[ "$PRE_PATH" == "$PROD_PATH" ]]; then
        print_status $RED "  ❌ SAME PATH! Pre and prod will overwrite each other!"
    else
        print_status $GREEN "  ✅ Different paths (good)"
    fi
    
    echo ""
}

echo ""
print_status $YELLOW "📋 Problem 1: Version Check Path Mismatch"
echo ""

simulate_current_behavior "dev" "1.0.0"
simulate_current_behavior "pre" "1.0.0"
simulate_current_behavior "prod" "1.0.0"

print_status $YELLOW "📋 Problem 2: Environment Path Collision"
echo ""

simulate_environment_collision "1.0.0"
simulate_environment_collision "1.0.1"

print_status $RED "🚨 Critical Issues Summary:"
echo ""
echo "ISSUE 1: Version Check Never Works"
echo "  - Version check looks in: /versions/1.0.0/"
echo "  - Files uploaded to:      /1.0.0/"
echo "  - Result: Version conflicts never detected!"
echo ""
echo "ISSUE 2: Pre and Prod Share Same S3 Directory"
echo "  - Pre uploads to:   /1.0.0/function-1.0.0.zip"
echo "  - Prod uploads to:  /1.0.0/function-1.0.0.zip (SAME PATH!)"
echo "  - Result: Environments overwrite each other!"
echo ""
echo "ISSUE 3: Rollback Confusion"
echo "  - Rollback looks for: /1.0.0/function-1.0.0.zip"
echo "  - But which environment was it from?"
echo "  - Result: Prod rollback might use pre version!"
echo ""

print_status $GREEN "💡 Proposed Fixed S3 Structure:"
echo ""
echo "s3://lambda-deploy-bucket/"
echo "├── my-lambda-function/"
echo "│   ├── environments/"
echo "│   │   ├── dev/"
echo "│   │   │   ├── deployments/"
echo "│   │   │   │   ├── 1692123456/lambda.zip"
echo "│   │   │   │   └── 1692123789/lambda.zip"
echo "│   │   │   └── latest/lambda.zip"
echo "│   │   ├── pre/"
echo "│   │   │   ├── versions/"
echo "│   │   │   │   ├── 1.0.0/function-1.0.0.zip    ← PRE version"
echo "│   │   │   │   └── 1.0.1/function-1.0.1.zip"
echo "│   │   │   └── latest/lambda.zip"
echo "│   │   └── prod/"
echo "│   │       ├── versions/"
echo "│   │       │   ├── 1.0.0/function-1.0.0.zip    ← PROD version (separate!)"
echo "│   │       │   └── 1.0.1/function-1.0.1.zip"
echo "│   │       └── latest/lambda.zip"
echo "│   └── metadata/"
echo "│       └── deployments.json"
echo ""

print_status $BLUE "🔧 Fixed Version Check Logic:"
echo ""
echo "# Environment-specific version checking"
echo 'case "$ENV" in'
echo '  "pre")'
echo '    VERSION_CHECK_PATH="s3://bucket/function/environments/pre/versions/$VERSION/"'
echo '    UPLOAD_PATH="s3://bucket/function/environments/pre/versions/$VERSION/function-$VERSION.zip"'
echo '    ;;'
echo '  "prod")'
echo '    VERSION_CHECK_PATH="s3://bucket/function/environments/prod/versions/$VERSION/"'
echo '    UPLOAD_PATH="s3://bucket/function/environments/prod/versions/$VERSION/function-$VERSION.zip"'
echo '    ;;'
echo 'esac'
echo ""

print_status $YELLOW "🎯 Benefits of Fixed Structure:"
echo ""
echo "✅ Version check paths match upload paths"
echo "✅ Complete environment isolation"
echo "✅ No cross-environment overwrites"
echo "✅ Environment-specific rollback support"
echo "✅ Clear audit trail per environment"
echo "✅ Environment-specific latest versions"
echo ""

print_status $RED "⚠️  Current State Impact:"
echo ""
echo "🚨 HIGH SEVERITY:"
echo "  - Version conflict protection is COMPLETELY BROKEN"
echo "  - Pre deployments can overwrite prod artifacts"
echo "  - Prod rollbacks might use pre environment code"
echo "  - No environment isolation or audit trail"
echo ""
echo "🔧 IMMEDIATE ACTION REQUIRED:"
echo "  1. Fix version check paths to match upload paths"
echo "  2. Add environment isolation to S3 structure"
echo "  3. Update rollback logic for environment-specific paths"
echo "  4. Test all environments after changes"
echo ""

print_status $GREEN "🎯 Test completed!"
echo ""
print_status $YELLOW "This demonstrates critical S3 structure issues that need immediate attention."
