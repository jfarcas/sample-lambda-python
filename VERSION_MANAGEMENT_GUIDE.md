# Python Lambda Version Management Guide

This guide compares different approaches to version management for Python Lambda projects, similar to how Node.js projects use `package.json`.

## 🎯 **The Problem with Commit-Based Versioning**

**Issues:**
- ❌ No semantic versioning (can't tell if it's a major/minor/patch change)
- ❌ Difficult to determine version order (commit hashes are not sequential)
- ❌ No clear release management
- ❌ Hard to rollback to specific versions
- ❌ No dependency on actual code changes

## 🚀 **Recommended Solutions (Best to Worst)**

### **1. `pyproject.toml` (RECOMMENDED - Modern Python Standard)**

**File:** `pyproject.toml`
```toml
[project]
name = "lambda-test-python"
version = "1.0.0"
description = "Sample Python Lambda function"
```

**Pros:**
- ✅ Modern Python standard (PEP 518, 621)
- ✅ Replaces both `setup.py` and `requirements.txt`
- ✅ Supports semantic versioning
- ✅ Tool ecosystem support (pip, build, etc.)
- ✅ Metadata management
- ✅ Development dependencies separation

**Cons:**
- ⚠️ Requires Python 3.11+ for native TOML support (fallback available)
- ⚠️ Newer standard (some tools might not support it yet)

**Best for:** New projects, modern Python development

---

### **2. `__version__.py` + `setup.py` (Traditional Python)**

**Files:** `__version__.py` + `setup.py`
```python
# __version__.py
__version__ = "1.0.0"

# setup.py
from setuptools import setup
exec(open('__version__.py').read())
setup(name="lambda-test-python", version=__version__)
```

**Pros:**
- ✅ Traditional Python approach
- ✅ Wide tool support
- ✅ Semantic versioning
- ✅ Programmatic access to version
- ✅ Separation of concerns

**Cons:**
- ⚠️ Multiple files to maintain
- ⚠️ More complex setup

**Best for:** Existing Python projects, traditional workflows

---

### **3. `version.txt` (Simple and Clean)**

**File:** `version.txt`
```
1.0.0
```

**Pros:**
- ✅ Extremely simple
- ✅ Language agnostic
- ✅ Easy to read/write programmatically
- ✅ Clear and explicit
- ✅ No dependencies

**Cons:**
- ⚠️ No metadata support
- ⚠️ Manual management required
- ⚠️ No tool integration

**Best for:** Simple projects, microservices, minimal setups

---

### **4. `VERSION` file (Alternative Simple)**

**File:** `VERSION`
```
1.0.0
```

**Pros:**
- ✅ Simple and clean
- ✅ Common in many projects
- ✅ Easy automation

**Cons:**
- ⚠️ Same as version.txt
- ⚠️ Less descriptive filename

**Best for:** Projects following Unix conventions

---

### **5. Inline Version in Code**

**File:** `lambda_function.py`
```python
__version__ = "1.0.0"

def lambda_handler(event, context):
    return {"version": __version__}
```

**Pros:**
- ✅ Version available at runtime
- ✅ Single source of truth
- ✅ No external files

**Cons:**
- ⚠️ Couples version to code
- ⚠️ Harder to automate
- ⚠️ Version changes require code changes

**Best for:** Single-file Lambda functions

---

### **6. Git Tags (Fallback Only)**

**Usage:** `git tag v1.0.0`

**Pros:**
- ✅ Integrated with Git
- ✅ Release management
- ✅ Historical tracking

**Cons:**
- ❌ Requires Git access during build
- ❌ Not always available in CI/CD
- ❌ Couples deployment to Git state

**Best for:** Fallback mechanism only

---

### **7. Commit Hash (Last Resort)**

**Pros:**
- ✅ Always available
- ✅ Unique identifier

**Cons:**
- ❌ No semantic meaning
- ❌ Hard to order
- ❌ Not user-friendly
- ❌ No release management

**Best for:** Development builds only

## 🎯 **Our Recommendation: `pyproject.toml`**

For modern Python Lambda projects, we recommend `pyproject.toml`:

```toml
[project]
name = "lambda-test-python"
version = "1.0.0"
description = "Sample Python Lambda function"
dependencies = [
    # Your runtime dependencies
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=22.0.0",
]
```

## 🔧 **Version Detection Priority**

The deployment action detects versions in this order:

1. **Input parameter** (manual override)
2. **pyproject.toml** (modern standard)
3. **__version__.py** (traditional Python)
4. **setup.py** (traditional Python)
5. **version.txt** (simple approach)
6. **VERSION** file (alternative simple)
7. **package.json** (Node.js compatibility)
8. **lambda_function.py** (inline version)
9. **Git tags** (fallback)
10. **Commit hash** (last resort)

## 📋 **Migration Guide**

### **From Commit-Based to pyproject.toml:**

1. Create `pyproject.toml`:
```toml
[project]
name = "your-lambda-name"
version = "1.0.0"
```

2. Update your workflow:
```yaml
# No changes needed - action auto-detects
```

3. Tag your first semantic version:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### **Version Bumping:**

```bash
# Manual approach
vim pyproject.toml  # Change version to 1.0.1

# Automated approach (using bump2version)
pip install bump2version
bump2version patch  # 1.0.0 -> 1.0.1
bump2version minor  # 1.0.1 -> 1.1.0
bump2version major  # 1.1.0 -> 2.0.0
```

## 🚀 **Benefits of Proper Versioning**

1. **Clear Release Management** - Know what changed between versions
2. **Better Rollback** - Rollback to specific semantic versions
3. **Dependency Management** - Track compatibility between versions
4. **Automated Deployments** - Version-based deployment strategies
5. **Audit Trail** - Clear history of releases and changes

Choose the approach that best fits your project's complexity and team preferences!
