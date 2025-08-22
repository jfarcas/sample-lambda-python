# Lambda Version Naming Improvements

## 🎯 Problem Solved

**Before:** Lambda versions had generic names like "1", "2", "3" making it impossible to distinguish which environment each version was deployed from.

**After:** Environment-specific version descriptions and aliases for clear identification.

## 🏷️ New Version Descriptions

### Development Environment
```
Description: "DEV: v1.0.0 | abc123 | 2025-08-22 12:30:00 UTC"
Format: DEV: v{VERSION} | {COMMIT_SHORT} | {TIMESTAMP}
```

### Pre/Staging Environment
```
Description: "PRE: v1.0.0 | main | abc123 | 2025-08-22 12:30:00 UTC"
Format: PRE: v{VERSION} | {BRANCH} | {COMMIT_SHORT} | {TIMESTAMP}
```

### Production Environment
```
Description: "PROD: v1.0.0 | main | abc123 | 2025-08-22 12:30:00 UTC"
Format: PROD: v{VERSION} | {BRANCH} | {COMMIT_SHORT} | {TIMESTAMP}
```

### Rollback Versions
```
Description: "PROD-ROLLBACK: v1.0.0 | by john.doe | 2025-08-22 12:45:00 UTC"
Format: {ENV}-ROLLBACK: v{VERSION} | by {USER} | {TIMESTAMP}
```

## 🔗 Environment Aliases

Each deployment creates/updates an environment-specific alias:

### Aliases Created
- `dev-current` → Points to latest dev version
- `pre-current` → Points to latest pre version  
- `prod-current` → Points to latest prod version

### Alias Descriptions
- **Normal deployment:** "Current dev environment version: v1.0.0"
- **Rollback deployment:** "Rolled back prod environment to: v1.0.0"

## 📋 Benefits

### 1. Clear Environment Identification
```
Lambda Versions List:
├── Version 1: "DEV: v1.0.0 | abc123 | 2025-08-22 10:00:00 UTC"
├── Version 2: "PRE: v1.0.0 | main | def456 | 2025-08-22 11:00:00 UTC"  
├── Version 3: "PROD: v1.0.0 | main | def456 | 2025-08-22 12:00:00 UTC"
└── Version 4: "PRE: v1.0.1 | feature/fix | ghi789 | 2025-08-22 13:00:00 UTC"
```

### 2. Easy Current Version Identification
```
Lambda Aliases:
├── dev-current → Version 1 (DEV: v1.0.0)
├── pre-current → Version 4 (PRE: v1.0.1)
└── prod-current → Version 3 (PROD: v1.0.0)
```

### 3. Rollback Tracking
```
Version 5: "PROD-ROLLBACK: v1.0.0 | by john.doe | 2025-08-22 14:00:00 UTC"
```

### 4. Deployment History
Each version description includes:
- ✅ **Environment** (DEV/PRE/PROD)
- ✅ **Version number** (v1.0.0)
- ✅ **Git branch** (main, feature/fix)
- ✅ **Commit hash** (short form)
- ✅ **Deployment timestamp**
- ✅ **Rollback information** (if applicable)

## 🚀 Usage Examples

### Invoke Specific Environment
```bash
# Invoke current dev version
aws lambda invoke --function-name my-function:dev-current response.json

# Invoke current prod version  
aws lambda invoke --function-name my-function:prod-current response.json

# Invoke specific version
aws lambda invoke --function-name my-function:3 response.json
```

### List Versions with Descriptions
```bash
aws lambda list-versions-by-function --function-name my-function
```

### Check Current Environment Versions
```bash
aws lambda list-aliases --function-name my-function
```

## 🔧 Implementation Details

### Version Description Format
```bash
case "$ENV" in
  "dev")
    VERSION_DESCRIPTION="DEV: v$VERSION | $COMMIT_SHORT | $TIMESTAMP"
    ;;
  "pre")
    VERSION_DESCRIPTION="PRE: v$VERSION | $BRANCH | $COMMIT_SHORT | $TIMESTAMP"
    ;;
  "prod")
    VERSION_DESCRIPTION="PROD: v$VERSION | $BRANCH | $COMMIT_SHORT | $TIMESTAMP"
    ;;
esac
```

### Alias Management
```bash
# Delete existing alias
aws lambda delete-alias --function-name "$FUNCTION" --name "${ENV}-current"

# Create new alias
aws lambda create-alias \
  --function-name "$FUNCTION" \
  --name "${ENV}-current" \
  --function-version "$LAMBDA_VERSION" \
  --description "Current $ENV environment version: v$VERSION"
```

## 📊 Before vs After Comparison

### Before (Generic)
```
Lambda Versions:
├── Version 1: "$LATEST"
├── Version 2: "$LATEST"  
├── Version 3: "$LATEST"
└── Version 4: "$LATEST"

❌ No way to distinguish environments
❌ No deployment information
❌ No current version tracking
```

### After (Environment-Specific)
```
Lambda Versions:
├── Version 1: "DEV: v1.0.0 | abc123 | 2025-08-22 10:00:00 UTC"
├── Version 2: "PRE: v1.0.0 | main | def456 | 2025-08-22 11:00:00 UTC"
├── Version 3: "PROD: v1.0.0 | main | def456 | 2025-08-22 12:00:00 UTC"
└── Version 4: "PRE: v1.0.1 | feature/fix | ghi789 | 2025-08-22 13:00:00 UTC"

Aliases:
├── dev-current → Version 1
├── pre-current → Version 4  
└── prod-current → Version 3

✅ Clear environment identification
✅ Complete deployment information
✅ Easy current version tracking
✅ Rollback history
```

## 🎯 Key Improvements

1. **Environment Prefixes:** DEV/PRE/PROD clearly identify deployment target
2. **Version Information:** Semantic version included in description
3. **Git Context:** Branch and commit hash for traceability
4. **Timestamps:** Exact deployment time for audit trail
5. **Current Aliases:** Easy identification of active versions per environment
6. **Rollback Tracking:** Special naming for rollback deployments
7. **User Attribution:** Who performed rollbacks

This makes Lambda version management much more user-friendly and provides complete deployment visibility! 🚀
