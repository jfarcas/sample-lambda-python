#!/bin/bash

# Debug script to check actual S3 structure and version checking for pre environment
# This helps identify why pre environment version check might not be working as expected

set -e

echo "🔍 Pre Environment Version Check Debug"
echo "======================================"

# Configuration
BUCKET="lambda-deploy-action"
FUNCTION="lambda-deploy-python"
VERSION="1.0.1"  # Use a version that should exist

echo "Configuration:"
echo "  S3 Bucket: $BUCKET"
echo "  Function: $FUNCTION"
echo "  Version: $VERSION"
echo ""

# Check current S3 structure
echo "📦 Current S3 Structure:"
echo "========================"

echo "1. Checking root function directory:"
aws s3 ls "s3://$BUCKET/$FUNCTION/" --recursive | head -20 || echo "❌ Failed to list S3 contents"
echo ""

echo "2. Checking environments directory:"
aws s3 ls "s3://$BUCKET/$FUNCTION/environments/" --recursive | head -20 || echo "❌ No environments directory found"
echo ""

echo "3. Checking pre environment specifically:"
aws s3 ls "s3://$BUCKET/$FUNCTION/environments/pre/" --recursive || echo "❌ No pre environment directory found"
echo ""

echo "4. Checking pre versions directory:"
aws s3 ls "s3://$BUCKET/$FUNCTION/environments/pre/versions/" --recursive || echo "❌ No pre versions directory found"
echo ""

echo "5. Checking specific version in pre:"
PRE_VERSION_PATH="s3://$BUCKET/$FUNCTION/environments/pre/versions/$VERSION/"
echo "Checking: $PRE_VERSION_PATH"
aws s3 ls "$PRE_VERSION_PATH" || echo "❌ Version $VERSION not found in pre environment"
echo ""

# Check what the version check logic would actually do
echo "🧪 Version Check Logic Test:"
echo "============================"

echo "Testing version check command:"
CHECK_COMMAND="aws s3 ls \"$PRE_VERSION_PATH\" > /dev/null 2>&1"
echo "Command: $CHECK_COMMAND"

if aws s3 ls "$PRE_VERSION_PATH" > /dev/null 2>&1; then
    echo "✅ Version $VERSION EXISTS in pre environment"
    echo "   Expected behavior: Show warnings but allow deployment"
    echo "   Expected output: can-deploy=true"
else
    echo "❌ Version $VERSION does NOT exist in pre environment"
    echo "   Expected behavior: Allow deployment normally"
    echo "   Expected output: can-deploy=true"
fi
echo ""

# Check if there might be versions in the old structure
echo "🔍 Checking Old S3 Structure (Legacy):"
echo "======================================"

echo "1. Checking old structure (without environments):"
aws s3 ls "s3://$BUCKET/$FUNCTION/$VERSION/" || echo "❌ No old structure found"
echo ""

echo "2. Checking old versions directory:"
aws s3 ls "s3://$BUCKET/$FUNCTION/versions/$VERSION/" || echo "❌ No old versions directory found"
echo ""

# Summary
echo "📋 Debug Summary:"
echo "================="
echo ""
echo "EXPECTED PRE ENVIRONMENT BEHAVIOR:"
echo "✅ Version exists: Show warnings, allow deployment (can-deploy=true)"
echo "✅ Version new: Allow deployment normally (can-deploy=true)"
echo "✅ Force deploy: Bypass checks, allow deployment (can-deploy=true)"
echo ""
echo "CURRENT ISSUE ANALYSIS:"
echo ""
echo "If pre environment is not showing warnings when version exists:"
echo ""
echo "POSSIBLE CAUSES:"
echo "1. 🔍 S3 Path Mismatch:"
echo "   - Expected: s3://bucket/function/environments/pre/versions/VERSION/"
echo "   - Actual: Check the S3 structure above"
echo ""
echo "2. 🔍 Environment Detection Issue:"
echo "   - Check deployment logs for: '🧪 Staging environment: Check for version conflicts'"
echo "   - If missing, environment might not be detected as 'pre'"
echo ""
echo "3. 🔍 Version Check Logic Issue:"
echo "   - aws s3 ls command might be failing silently"
echo "   - Check for AWS permissions or S3 access issues"
echo ""
echo "4. 🔍 Expected vs Actual Behavior:"
echo "   - You expect: Error/warning when version exists"
echo "   - Current logic: Warning but allow deployment"
echo "   - Question: Do you want pre to BLOCK like prod, or WARN and allow?"
echo ""

echo "🎯 CLARIFICATION NEEDED:"
echo "========================"
echo ""
echo "Current pre environment logic:"
echo "  - Version exists → Show WARNING, allow deployment"
echo "  - Version new → Allow deployment normally"
echo ""
echo "Do you want pre environment to:"
echo "  A) Show warnings but allow deployment (current behavior)"
echo "  B) Block deployment like production (stricter behavior)"
echo "  C) Something else?"
echo ""

echo "🔧 Next Steps:"
echo "=============="
echo "1. Check the S3 structure above to verify paths"
echo "2. Run a pre deployment and check logs for environment detection"
echo "3. Clarify expected behavior for pre environment version conflicts"
echo "4. If needed, adjust the logic based on requirements"
