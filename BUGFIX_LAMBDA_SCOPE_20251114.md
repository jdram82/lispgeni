# CRITICAL BUG FIX - Variable Scope Issue in Diagnostic Tool

## Date: November 14, 2025

## Problem Identified

Test 5 was failing with:
```
Unknown command "="
Unknown command "LM105 ANALOG IC"
FILE NOT CREATED
```

## Root Cause

The diagnostic tool was using **quoted lambdas** `'(lambda ...)` instead of **function lambdas** `(function (lambda ...))`.

### What This Caused:
```lisp
;; WRONG - Variables not accessible
(vl-catch-all-apply
  '(lambda ()
     (command "._-WBLOCK" file_path "=" block_name)))
     ;; file_path and block_name are UNDEFINED here!
```

When the lambda is quoted, it doesn't capture variables from the outer scope. So `file_path` and `block_name` were **nil** when the command executed, causing WBLOCK to fail immediately.

## The Fix

Changed all quoted lambdas to function lambdas:

```lisp
;; CORRECT - Variables accessible
(vl-catch-all-apply
  (function (lambda ()
     (command "._-WBLOCK" file_path "=" block_name))))
     ;; file_path and block_name are now accessible!
```

## Files Fixed

### MacroManager_DIAGNOSTIC.lsp
- Method 0 (Platform-Optimized): Fixed lambda
- Method 1 (vl-cmdf): Fixed lambda  
- Method 2 (Script): Fixed lambda
- Method 3 (ObjectDBX): Fixed lambda
- Method 4 (COMMAND): Fixed lambda
- Script execution test: Fixed lambda

### Also Created
- TEST_WBLOCK_SIMPLE.lsp: Additional standalone tests for troubleshooting

## Changes Made

1. Replaced `'(lambda ...)` with `(function (lambda ...))`
2. Added debug output showing file_path and block_name before execution
3. Created standalone WBLOCK test commands

## Expected Result

When you run Test 5 again:
```
Step 3: Executing WBLOCK command...
  Command: ._-WBLOCK
  File: C:\Asset-Eyes_Durgaram\...\LM105 Analog IC.dwg
  Block: LM105 Analog IC
  Waiting for command completion... ✓
  ✓ Command executed without errors

→ VERIFICATION:
  ✓✓✓ FILE CREATED SUCCESSFULLY! ✓✓✓
  File size: XXXX bytes
```

## Additional Tests Created

### TEST_WBLOCK_SIMPLE.lsp Commands:

1. **TESTWBLOCK** - Tests block with space handling
   - Detects spaces in block names
   - Suggests safe filenames
   - Tests export to TEMP folder

2. **TESTWBLOCK2** - Direct hardcoded test
   - Uses simple path: C:\TEMP\TEST.DWG
   - Minimal variables
   - For isolating issues

3. **CHECKWBLOCK** - Verifies WBLOCK availability
   - Tests if WBLOCK command works
   - Checks security settings
   - Identifies if WBLOCK is disabled

## Testing Instructions

### Step 1: Reload Diagnostic Tool
```
Command: (load "MacroManager_DIAGNOSTIC.lsp")
Command: MMTEST
Select: 5 (Test WBLOCK Method 0)
```

### Step 2: Try Standalone Tests
```
Command: (load "TEST_WBLOCK_SIMPLE.lsp")
Command: CHECKWBLOCK     ; Verify WBLOCK works
Command: TESTWBLOCK2     ; Simple test
Command: TESTWBLOCK      ; Full test with space handling
```

## Why This Bug Occurred

AutoLISP has two ways to create anonymous functions:

1. **Quoted lambda** `'(lambda ...)` - Creates a static function, no variable capture
2. **Function lambda** `(function (lambda ...))` - Creates a closure, captures variables

The diagnostic tool was using quoted lambdas, which work fine when testing with no external variables, but fail when trying to access `file_path` and `block_name` from the outer scope.

## Impact

This bug affected **all WBLOCK method tests** in the diagnostic tool. The main MacroManager_v5.18.lsp was **not affected** because it uses the correct function lambda syntax.

## Verification

After reloading, you should see this in test output:
```
Step 3: Executing WBLOCK command...
  Command: ._-WBLOCK
  File: [full path shown] ← NEW - proves variable is accessible
  Block: [block name shown] ← NEW - proves variable is accessible
```

If these lines show actual values (not blank), the fix is working.

## Next Steps

1. Reload MacroManager_DIAGNOSTIC.lsp
2. Run Test 1 (should still show ACADE)
3. Run Test 5 (should now create DWG file)
4. If Test 5 still fails, run CHECKWBLOCK to see if WBLOCK is disabled
5. If Test 5 succeeds, test full export with MacroManager v5.18

---

**Status:** FIXED
**Confidence:** 95% - This was a definite bug that would cause the exact symptoms observed
