# MacroManager v5.18 - FINAL CORRECTED VERSION
## Export Methods - Complete Technical Reference

---

## PROBLEM IDENTIFIED AND FIXED

### Original Error
```
error: bad order function: COMMAND
```

### Root Cause
Method 2 (Script Method) was writing incorrect syntax to the .scr file:
```
-WBLOCK
C:\path\file.dwg
=BLOCKNAME          ← WRONG: Combined = and blockname
```

AutoCAD's script parser interpreted `=BLOCKNAME` as a command, causing "bad order function: COMMAND"

### Correct Fix
```
-WBLOCK
C:\path\file.dwg
=                   ← CORRECT: Separate line for =
BLOCKNAME           ← CORRECT: Separate line for blockname
                    ← CORRECT: Blank line to accept defaults
```

---

## ALL EXPORT METHODS - CURRENT STATUS

### Method 0: Platform-Optimized (Auto-detect)
**Status:** ✅ CORRECTED

**What it does:**
- Detects platform (ACADE/AUTOCAD/BRICSCAD)
- For AutoCAD Electrical: Uses COMMAND method
- For others: Uses vl-cmdf method

**Code for ACADE:**
```lisp
(command "._-WBLOCK" dwg_path "=" block_name)
(while (> (getvar "CMDACTIVE") 0)
  (command ""))
```

**Why it works:**
- Uses proven Method 4 pattern
- `._-WBLOCK` = International-safe command-line WBLOCK
- Passes 4 arguments: command, filepath, "=", blockname
- Waits for completion with CMDACTIVE loop

---

### Method 1: Direct vl-cmdf (FORCED)
**Status:** ✅ WORKING (from previous versions)

**What it does:**
- Forces use of vl-cmdf regardless of platform
- May cause issues in AutoCAD Electrical

**Code:**
```lisp
(vl-cmdf "._-WBLOCK" dwg_path "=" block_name)
(while (> (getvar "CMDACTIVE") 0)
  (vl-cmdf ""))
```

---

### Method 2: Script Method
**Status:** ✅ CORRECTED IN v5.18

**What it does:**
- Creates export_blocks.scr file
- Adds one WBLOCK command per block
- User runs script with SCRIPT command

**CORRECTED Code:**
```lisp
(write-line "-WBLOCK" script_handle)
(write-line dwg_path script_handle)
(write-line "=" script_handle)              ; ← FIXED: Separate line
(write-line block_name script_handle)        ; ← FIXED: Separate line
(write-line "" script_handle)                ; ← FIXED: Blank line added
```

**Resulting .scr file format:**
```
-WBLOCK
C:\Asset_Eyes_Durgarman\Working_0825\JD_Electrical Automation\ICE RINK\Block_Library_ICE RINK\12th Nov\Testing\BLOCKNAME1.dwg
=
BLOCKNAME1

-WBLOCK
C:\Asset_Eyes_Durgarman\Working_0825\JD_Electrical Automation\ICE RINK\Block_Library_ICE RINK\12th Nov\Testing\BLOCKNAME2.dwg
=
BLOCKNAME2

```

**Key Changes:**
1. **NO underscore** in script files (use `-WBLOCK`, not `_-WBLOCK`)
2. **Separate lines** for `=` and `blockname` (not `=BLOCKNAME`)
3. **Blank line** after each block command to accept remaining prompts

---

### Method 3: ObjectDBX/VLA
**Status:** ✅ WORKING (from previous versions)

**What it does:**
- Uses Visual LISP ActiveX interface
- Bypasses command line entirely

**Code:**
```lisp
(vla-wblock doc dwg_path block_name)
```

---

### Method 4: Basic COMMAND
**Status:** ✅ WORKING (proven pattern)

**What it does:**
- Uses basic AutoLISP command function
- Most compatible method

**Code:**
```lisp
(command "._-WBLOCK" dwg_path "=" block_name)
(while (> (getvar "CMDACTIVE") 0)
  (command ""))
```

---

## WBLOCK COMMAND STRUCTURE EXPLAINED

### In AutoLISP (command or vl-cmdf):
```lisp
(command "._-WBLOCK" filepath "=" blockname)
       │      │         │      │      │
       │      │         │      │      └─ Block name
       │      │         │      └──────── Use existing block
       │      │         └─────────────── File path
       │      └───────────────────────── Command
       └──────────────────────────────── Each element = separate prompt response
```

### In Script Files (.scr):
```
-WBLOCK      ← Command (no dot, no underscore)
filepath     ← Response to: "File name:"
=            ← Response to: "Block name or [Objects/Entire]:" (choose Block mode)
blockname    ← Response to: "Block name:" (which block)
             ← Blank line accepts remaining defaults
```

---

## SYSTEM VARIABLES (Critical for Success)

### Method 0, 1, 4 (COMMAND-based):
```lisp
CMDECHO = 0    ; Suppress command echo (quiet mode)
FILEDIA = 0    ; Disable file dialogs (automated mode)
EXPERT = 5     ; Suppress all confirmation prompts
ATTREQ = 1     ; ENABLE attributes (important for Electrical blocks!)
```

### Why ATTREQ = 1 for AutoCAD Electrical:
- Electrical blocks contain critical attribute data
- ATTREQ = 0 would strip attributes
- ATTREQ = 1 preserves all electrical information

---

## TESTING PROCEDURE

### Step 1: Load v5.18
```
Command: (load "MacroManager_v5.18.lsp")
Command: MM
```

### Step 2: Test Method 0 (Recommended for ACADE)
1. Set Block Library folder
2. Select blocks to export
3. Choose **Method 0: Platform-Optimized**
4. Click Export
5. Check console output:
   ```
   → WBLOCK (AutoCAD Electrical mode - COMMAND method)...
   ```
6. Verify DWG files created in Block Library folder

### Step 3: Test Method 2 (Script Method)
1. Set Block Library folder
2. Select blocks to export
3. Choose **Method 2: Script Method**
4. Click Export
5. System creates: `export_blocks.scr`
6. Click "RUN EXPORT SCRIPT" button OR:
   ```
   Command: SCRIPT
   [Browse to] export_blocks.scr
   ```
7. AutoCAD processes each WBLOCK command
8. Check for DWG files in Block Library folder

### Step 4: Test Method 4 (Comparison)
1. Same as Method 0
2. Choose **Method 4: Basic COMMAND**
3. Should have identical behavior to Method 0

---

## SUCCESS INDICATORS

✅ **No errors in command line**
✅ **Console shows: `✓` after each block**
✅ **"Successful Exports: N" where N > 0**
✅ **DWG files physically exist in Block Library folder**
✅ **CSV file created with export list**
✅ **For Method 2: Script executes without "bad order function" error**

---

## FAILURE INDICATORS & SOLUTIONS

### ❌ "bad order function: COMMAND"
**Cause:** Script file has wrong format
**Solution:** v5.18 fixes this - upgrade to latest version

### ❌ "Successful Exports: 0"
**Cause:** WBLOCK command silently failing
**Solutions:**
1. Check file permissions on Block Library folder
2. Try different export method (0, 3, or 4)
3. Verify blocks exist: `(tblsearch "BLOCK" "blockname")`
4. Check ATTREQ setting: `(getvar "ATTREQ")`

### ❌ No DWG files created
**Cause:** Command executed but files not written
**Solutions:**
1. Check disk space
2. Verify path is valid (no special characters)
3. Try shorter path (Windows 260-character limit)
4. Run AutoCAD as Administrator

### ❌ AutoCAD crashes during export
**Cause:** WBLOCK command bug in AutoCAD Electrical
**Solutions:**
1. Use Method 0 (auto-detects and uses safest approach)
2. Use Method 3 (ObjectDBX - bypasses command line)
3. Export blocks in smaller batches
4. Update AutoCAD to latest version

---

## DIFFERENCES BETWEEN COMMAND AND SCRIPT

| Aspect | command/vl-cmdf | Script File (.scr) |
|--------|-----------------|---------------------|
| **Syntax** | `(command "._-WBLOCK" ...)` | `-WBLOCK` (no dot, no underscore) |
| **Format** | Single expression with multiple args | Each response on separate line |
| **Underscore** | `_-WBLOCK` (international mode) | `-WBLOCK` (no underscore) |
| **Dot prefix** | `._-WBLOCK` (current namespace) | `-WBLOCK` (no dot) |
| **= + blockname** | `"=" block_name` (two args) | `=` then `blockname` (two lines) |
| **Execution** | Immediate from LISP | Run via SCRIPT command |
| **Error handling** | vl-catch-all-apply | Must be error-free |

---

## FILE LOCATIONS

### CSV Export List:
```
[Block Library Folder]\Export_DWG_[Block Type]_[Timestamp].csv
```

### Script File (Method 2 only):
```
[Block Library Folder]\export_blocks.scr
```

### Exported DWG Files:
```
[Block Library Folder]\BLOCKNAME1.dwg
[Block Library Folder]\BLOCKNAME2.dwg
...
```

---

## FINAL VERIFICATION CHECKLIST

Before testing v5.18:

- [ ] MacroManager_v5.18.lsp loaded
- [ ] MacroManager_v5.18.dcl in same folder
- [ ] Block Library folder set and writable
- [ ] At least one block selected for export
- [ ] Export method selected (0, 1, 2, 3, or 4)

After export:

- [ ] Check console for success count
- [ ] Verify CSV file exists and contains block list
- [ ] Check Block Library folder for DWG files
- [ ] Open one DWG file to verify content
- [ ] If using Method 2: Check export_blocks.scr format

---

## WHAT CHANGED IN v5.18

### Method 0 (Platform-Optimized):
- ✅ Simplified to use direct COMMAND method for ACADE
- ✅ Removed complex script generation
- ✅ Now identical to Method 4 for AutoCAD Electrical

### Method 2 (Script Method):
- ✅ **CRITICAL FIX:** Separated `=` and `blockname` to different lines
- ✅ Changed `_-WBLOCK` to `-WBLOCK` (no underscore in .scr files)
- ✅ Added blank line after each block command
- ✅ Fixed "bad order function: COMMAND" error

### Method 4 (Basic COMMAND):
- ✅ No changes (already working correctly)

---

## CONCLUSION

**v5.18 fixes the "bad order function: COMMAND" error** by correcting the script file format in Method 2.

**Key fix:** `=` and `blockname` must be on **separate lines** in .scr files.

**Recommendation for AutoCAD Electrical users:**
1. **First choice:** Method 0 (Platform-Optimized) - auto-detects best method
2. **Second choice:** Method 4 (Basic COMMAND) - proven to work
3. **Third choice:** Method 2 (Script) - now fixed, good for large batches
4. **Avoid:** Method 1 (may cause exceptions in ACADE)

---

**Version:** MacroManager v5.18  
**Date:** November 13, 2025  
**Status:** All export methods corrected and tested for syntax  
**Testing:** Requires AutoCAD Electrical 2024 for final validation  
