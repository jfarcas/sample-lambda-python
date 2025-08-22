# Pre Environment Analysis

## 🔍 Current Logic Analysis

### Version Conflict Check Logic:
```yaml
# Skip version check for dev environment or if force deploy is enabled
if [[ "$ENV" == "dev" || "$FORCE_DEPLOY" == "true" ]]; then
  echo "Skipping version conflict check"
  echo "can-deploy=true"
  exit 0
fi

# For ALL other environments (including pre):
if version_exists_in_s3; then
  echo "::error::Version conflict detected"
  echo "can-deploy=false"
  exit 1
fi
```

## 📊 Environment Behavior Matrix

| Environment | Version Check | Behavior | Use Case |
|-------------|---------------|----------|----------|
| `dev` | ❌ **SKIPPED** | Always deploys (overwrites) | Development iteration |
| `pre` | ✅ **ENFORCED** | Fails on version conflict | Staging validation |
| `prod` | ✅ **ENFORCED** | Fails on version conflict | Production deployment |

## 🚨 Pre Environment Issues

### Problem 1: Same Strict Rules as Production
```yaml
environments:
  pre:
    trigger_branches: ["main", "release/**"]
    aws:
      auth_type: "oidc"
```

**Current Behavior:**
- ✅ Version conflicts **blocked** (same as prod)
- ❌ **No flexibility** for staging testing
- ❌ **Forces version increment** for every staging test

### Problem 2: Staging Workflow Friction
**Typical Staging Workflow:**
1. Deploy to `pre` for testing
2. Find issues, fix code
3. Want to redeploy to `pre` with same version
4. **BLOCKED** - version conflict error

**Current Result:**
```
❌ Version 1.0.0 already exists in S3
❌ Version conflict detected. Use force-deploy: true to override, or increment the version.
```

### Problem 3: Version Inflation
**Scenario:**
- Deploy v1.0.0 to `pre` for testing
- Find bug, fix it
- Need to deploy again to `pre`
- Forced to increment to v1.0.1
- Find another bug, fix it
- Forced to increment to v1.0.2
- Finally ready for prod
- Deploy v1.0.2 to prod (but v1.0.0 and v1.0.1 never went to prod)

**Result:** Version numbers don't reflect actual production releases

## 🔧 Proposed Solutions

### Solution 1: Environment-Specific Policies
```yaml
# Enhanced version conflict check
case "$ENV" in
  "dev")
    echo "Dev environment: Always allow deployment"
    can_deploy=true
    ;;
  "pre"|"staging")
    if version_exists; then
      echo "::warning::Version exists in staging - allowing overwrite for testing"
      echo "::notice::Consider using pre-release versions (1.0.0-rc.1)"
    fi
    can_deploy=true
    ;;
  "prod"|"production")
    if version_exists; then
      echo "::error::Version conflict in production"
      can_deploy=false
      exit 1
    fi
    can_deploy=true
    ;;
esac
```

### Solution 2: Pre-Release Versioning
```yaml
# Use pre-release versions for staging
project:
  version: "1.0.0-rc.1"  # Release candidate
  # or
  version: "1.0.0-pre.1" # Pre-release
  # or  
  version: "1.0.0-staging.1" # Staging version
```

### Solution 3: Environment-Specific S3 Paths
```yaml
# Different S3 paths per environment
dev: s3://bucket/function/dev/timestamp/
pre: s3://bucket/function/pre/version/
prod: s3://bucket/function/prod/version/
```

## 🧪 Testing Pre Environment Behavior

### Test Scenario 1: First Deployment to Pre
```bash
# Deploy version 1.0.0 to pre
ENV=pre VERSION=1.0.0 FORCE_DEPLOY=false VERSION_EXISTS=false
# Expected: ✅ Deploy successfully
```

### Test Scenario 2: Redeploy Same Version to Pre
```bash
# Try to deploy version 1.0.0 to pre again
ENV=pre VERSION=1.0.0 FORCE_DEPLOY=false VERSION_EXISTS=true
# Current: ❌ Version conflict error
# Desired: ✅ Allow overwrite with warning
```

### Test Scenario 3: Force Deploy to Pre
```bash
# Force deploy version 1.0.0 to pre
ENV=pre VERSION=1.0.0 FORCE_DEPLOY=true VERSION_EXISTS=true
# Current: ✅ Deploy successfully (bypasses check)
```

## 📋 Real-World Pre Environment Use Cases

### Use Case 1: Staging Testing Cycle
```
1. Deploy v1.0.0 to pre
2. QA finds bug
3. Fix bug, want to test fix
4. Deploy v1.0.0 to pre again (same version, updated code)
5. Current: BLOCKED ❌
6. Desired: ALLOWED with warning ✅
```

### Use Case 2: Release Candidate Testing
```
1. Deploy v1.0.0-rc.1 to pre
2. Test passes
3. Deploy v1.0.0 to prod
4. Current: Works ✅
5. Better: Automatic RC versioning
```

### Use Case 3: Hotfix Testing
```
1. Production issue found
2. Create hotfix branch
3. Deploy v1.0.1 to pre for testing
4. Test hotfix
5. Deploy v1.0.1 to prod
6. Current: Works if no version conflicts ✅
```

## 💡 Recommended Pre Environment Strategy

### Option A: Relaxed Pre Environment (Recommended)
```yaml
# Allow overwrites in pre environment with warnings
if [[ "$ENV" == "pre" || "$ENV" == "staging" ]]; then
  if version_exists; then
    echo "::warning::Overwriting version $VERSION in $ENV environment"
    echo "::notice::Consider using pre-release versions for better tracking"
  fi
  can_deploy=true
fi
```

**Benefits:**
- ✅ Flexible staging testing
- ✅ No version inflation
- ✅ Clear warnings about overwrites
- ✅ Maintains audit trail

### Option B: Pre-Release Versioning
```yaml
# Encourage pre-release versions for staging
if [[ "$ENV" == "pre" && ! "$VERSION" =~ -rc\.|pre\.|staging\. ]]; then
  echo "::warning::Consider using pre-release version for staging"
  echo "::notice::Example: 1.0.0-rc.1, 1.0.0-pre.1, 1.0.0-staging.1"
fi
```

**Benefits:**
- ✅ Clear version semantics
- ✅ Distinguishes staging from production versions
- ✅ Follows semantic versioning standards
- ✅ Better release management

### Option C: Environment-Specific Paths
```yaml
# Use different S3 paths per environment
case "$ENV" in
  "dev")
    S3_PATH="$LAMBDA_FUNCTION/dev/$(date +%s)/"
    ;;
  "pre")
    S3_PATH="$LAMBDA_FUNCTION/pre/$VERSION/"
    # Allow overwrites in pre path
    ;;
  "prod")
    S3_PATH="$LAMBDA_FUNCTION/prod/$VERSION/"
    # Strict version checking
    ;;
esac
```

**Benefits:**
- ✅ Environment isolation
- ✅ Different policies per environment
- ✅ Clear separation of concerns
- ✅ Flexible deployment strategies

## 🎯 Current State Summary

**Pre Environment Currently:**
- ❌ **Same strict rules as production**
- ❌ **Blocks version conflicts** (may be too restrictive)
- ❌ **Forces version increment** for staging retests
- ❌ **Can cause version inflation**
- ✅ **Can use force-deploy as workaround**

**Recommendations:**
1. **Implement relaxed pre environment policy** (Option A)
2. **Add pre-release version guidance** (Option B)
3. **Consider environment-specific S3 paths** (Option C)
4. **Add clear documentation** about pre environment behavior
5. **Provide staging-specific examples** in configuration

The current implementation treats `pre` environment the same as `prod`, which may be too restrictive for typical staging workflows.
