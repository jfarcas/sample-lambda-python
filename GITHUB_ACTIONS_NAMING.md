# GitHub Actions Dynamic Workflow Naming

## 🎯 Problem Solved

**Before:** Generic workflow names in GitHub Actions UI, especially for manual deployments
- Manual deployments: "Deploy Lambda Function"
- Push deployments: "Deploy Lambda Function" 
- No context about version, environment, or commit details

**After:** Dynamic, context-rich workflow names showing deployment details
- Manual deployments: "🚀 Manual Deploy | john.doe → prod | v1.0.1 | main"
- Push deployments: "📦 Push Deploy | v1.0.1 | main | Add new feature..."
- PR deployments: "🔍 PR Deploy | v1.0.1 | PR #123 | Fix critical bug"

## 🏷️ Dynamic Run Names

### Basic Implementation
```yaml
name: Deploy Lambda Function

run-name: >-
  ${{
    github.event_name == 'workflow_dispatch' && 
    format('🚀 Manual Deploy | {0} → {1} | v{2}', 
      github.actor,
      inputs.environment,
      '1.0.1'
    ) ||
    github.event_name == 'push' &&
    format('📦 Push Deploy | {0} | {1}',
      github.ref_name,
      github.event.head_commit.message
    ) ||
    format('🔄 Lambda Deploy | {0}',
      github.ref_name
    )
  }}
```

### Advanced Implementation with Version Detection
```yaml
# Step 1: Detect version from project files
- name: Get Version
  id: get-version
  run: |
    # Try pyproject.toml first
    if [[ -f "pyproject.toml" ]]; then
      VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
    fi
    
    # Fallback to version.txt
    if [[ -z "$VERSION" && -f "version.txt" ]]; then
      VERSION=$(cat version.txt)
    fi
    
    # Fallback to git tags
    if [[ -z "$VERSION" ]]; then
      VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
    fi
    
    echo "version=$VERSION" >> $GITHUB_OUTPUT

# Step 2: Use version in deployment
- name: Deploy Lambda
  uses: ./.github/actions/lambda-deploy
  with:
    version: ${{ steps.get-version.outputs.version }}
```

## 📋 Run Name Formats

### Manual Deployment (workflow_dispatch)
```
🚀 Manual Deploy | john.doe → prod | v1.0.1 | main
Format: 🚀 Manual Deploy | {actor} → {environment} | v{version} | {branch}
```

### Push Deployment
```
📦 Push Deploy | v1.0.1 | main | Add new feature for user authentication
Format: 📦 Push Deploy | v{version} | {branch} | {commit_message}
```

### Pull Request Deployment
```
🔍 PR Deploy | v1.0.1 | PR #123 | Fix critical authentication bug
Format: 🔍 PR Deploy | v{version} | PR #{number} | {pr_title}
```

### Fallback
```
🔄 Lambda Deploy | v1.0.1 | feature/new-auth
Format: 🔄 Lambda Deploy | v{version} | {branch}
```

## 🎨 Emoji Legend

| Emoji | Trigger | Description |
|-------|---------|-------------|
| 🚀 | workflow_dispatch | Manual deployment |
| 📦 | push | Automatic push deployment |
| 🔍 | pull_request | Pull request deployment |
| 🔄 | other | Fallback for other triggers |

## 📊 Context Information Shown

### Manual Deployments
- ✅ **Actor:** Who triggered the deployment
- ✅ **Environment:** Target environment (dev/pre/prod)
- ✅ **Version:** Version being deployed
- ✅ **Branch:** Source branch

### Push Deployments
- ✅ **Version:** Version being deployed
- ✅ **Branch:** Branch that was pushed
- ✅ **Commit Message:** What changed (truncated)

### Pull Request Deployments
- ✅ **Version:** Version being deployed
- ✅ **PR Number:** Pull request number
- ✅ **PR Title:** Pull request title

## 🔧 Implementation Examples

### Simple Consumer Workflow
```yaml
name: Deploy Lambda Function

run-name: >-
  ${{
    github.event_name == 'workflow_dispatch' && 
    format('🚀 Manual Deploy to {0}', inputs.environment) ||
    format('📦 Auto Deploy | {0}', github.ref_name)
  }}

on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, pre, prod]
```

### Advanced Consumer Workflow
```yaml
name: Deploy Lambda Function

on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, pre, prod]

jobs:
  deploy:
    steps:
      - name: Get Version
        id: version
        run: |
          VERSION=$(grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
          echo "version=$VERSION" >> $GITHUB_OUTPUT
      
      - name: Set Run Name Context
        run: |
          echo "🚀 Deploying v${{ steps.version.outputs.version }} to ${{ inputs.environment }}"
```

### Reusable Workflow
```yaml
name: 'Reusable Lambda Deploy Workflow'

run-name: >-
  ${{
    format('🔄 {0} | {1} | {2}',
      inputs.environment || 'auto',
      inputs.version || 'auto-version',
      github.ref_name
    )
  }}

on:
  workflow_call:
    inputs:
      environment:
        type: string
      version:
        type: string
```

## 📱 GitHub UI Benefits

### Actions Tab View
```
Recent workflow runs:
├── 🚀 Manual Deploy | john.doe → prod | v1.0.1 | main
├── 📦 Push Deploy | v1.0.1 | main | Add authentication feature
├── 🔍 PR Deploy | v1.0.1 | PR #123 | Fix critical bug
└── 🚀 Manual Deploy | jane.doe → dev | v1.0.0 | feature/test
```

### Workflow Run Details
- **Clear identification** of deployment type
- **Immediate context** without opening the run
- **Version and environment** visible at a glance
- **Actor attribution** for manual deployments

## 🎯 Best Practices

### Keep Names Concise
```yaml
# Good: Clear and concise
🚀 Manual Deploy | user → prod | v1.0.1

# Avoid: Too verbose
🚀 Manual deployment triggered by user to production environment with version 1.0.1
```

### Use Consistent Formatting
```yaml
# Consistent pattern
{emoji} {action} | {context} | {version} | {branch}
```

### Include Key Information
```yaml
# Essential info for deployments
- Who (actor)
- What (version)  
- Where (environment)
- When (implicit from timestamp)
- Why (commit message/PR title)
```

### Handle Missing Data
```yaml
run-name: >-
  ${{
    format('🚀 Deploy | {0} | {1}',
      inputs.environment || 'auto',
      inputs.version || 'auto-detect'
    )
  }}
```

## 🔍 Troubleshooting

### Run Name Not Updating
- `run-name` is set at workflow start
- Cannot be changed during workflow execution
- Use step names for dynamic updates within the workflow

### Missing Context Variables
```yaml
# Check available context
- name: Debug Context
  run: |
    echo "Event: ${{ github.event_name }}"
    echo "Actor: ${{ github.actor }}"
    echo "Branch: ${{ github.ref_name }}"
    echo "Commit: ${{ github.event.head_commit.message }}"
```

### Long Names Truncated
- GitHub truncates very long run names
- Keep essential info first
- Use abbreviations for less critical parts

## 📊 Before vs After

### Before (Generic)
```
GitHub Actions Runs:
├── Deploy Lambda Function
├── Deploy Lambda Function  
├── Deploy Lambda Function
└── Deploy Lambda Function

❌ No context about what was deployed
❌ Can't distinguish manual vs automatic
❌ No version or environment information
```

### After (Dynamic)
```
GitHub Actions Runs:
├── 🚀 Manual Deploy | john.doe → prod | v1.0.1 | main
├── 📦 Push Deploy | v1.0.1 | main | Add authentication
├── 🔍 PR Deploy | v1.0.1 | PR #123 | Fix critical bug
└── 🚀 Manual Deploy | jane.doe → dev | v1.0.0 | feature/test

✅ Clear deployment context
✅ Version and environment visible
✅ Actor attribution for manual deployments
✅ Commit/PR context for automatic deployments
```

This makes the GitHub Actions UI much more informative and user-friendly! 🚀
