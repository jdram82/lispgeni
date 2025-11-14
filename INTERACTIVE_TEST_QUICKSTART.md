# Quick Start: Interactive Block Export Test

## Load the Tool

```
Command: (load "INTERACTIVE_BLOCK_EXPORT_TEST.lsp")
```

## Available Commands

### 1. TESTEXPORT (Main Interactive Tool)
**What it does:** Let you select blocks visually from the drawing and export them

**How to use:**
```
Command: TESTEXPORT
```

**Steps:**
1. Select blocks in the drawing (it will find block references)
2. Choose export folder
3. Choose export method (1=COMMAND, 2=vl-cmdf, 3=VLA)
4. Watch real-time export with success/fail for each block

**Advantages:**
- ✓ Works with actual blocks in your drawing
- ✓ Visual selection (not typing block names)
- ✓ Tests multiple blocks at once
- ✓ Shows exactly which succeed and which fail
- ✓ Real-time feedback

---

### 2. TESTBLOCK (Quick Single Test)
**What it does:** Test export of ONE block

**How to use:**
```
Command: TESTBLOCK
```

**Steps:**
1. Select one block in the drawing
2. Automatically exports to C:\TEMP\
3. Shows immediate success/failure

**Use when:** You want to quickly test if WBLOCK works at all

---

### 3. LISTBLOCKS (See What's Exportable)
**What it does:** Lists all blocks that can be exported

**How to use:**
```
Command: LISTBLOCKS
```

**Shows:**
- All exportable blocks in the drawing
- Excludes XREFs, anonymous blocks, layouts

**Use when:** You want to see what blocks are available before exporting

---

### 4. CHECKWBLOCK (Diagnostic)
**What it does:** Tests if WBLOCK command is disabled/blocked

**How to use:**
```
Command: CHECKWBLOCK
```

**Checks:**
- Is WBLOCK command available?
- Security settings that might block it
- Why exports might be failing

**Use when:** Exports fail and you want to know if WBLOCK itself is the problem

---

## Recommended Testing Sequence

### Step 1: Check if WBLOCK works
```
Command: CHECKWBLOCK
```
→ If this says WBLOCK is blocked, that's your problem!

### Step 2: See what blocks are available
```
Command: LISTBLOCKS
```
→ Verify you have exportable blocks

### Step 3: Quick single block test
```
Command: TESTBLOCK
[Select a block]
```
→ Tests if WBLOCK can export anything at all

### Step 4: Full interactive export
```
Command: TESTEXPORT
[Select multiple blocks]
[Choose folder]
[Choose method 1 = COMMAND]
```
→ Export all your blocks with live feedback

---

## Why This Approach is Better

### Old Way (MMTEST):
- Had to type block names manually
- Used test blocks that might not exist
- No visual selection
- Lambda scope bug caused failures

### New Way (TESTEXPORT):
- ✓ Select blocks visually in drawing
- ✓ Works with YOUR actual blocks
- ✓ Real-time success/fail feedback
- ✓ Tests multiple blocks at once
- ✓ No variable scope issues
- ✓ Shows exact file paths and sizes

---

## Expected Output Example

```
╔══════════════════════════════════════════════════════════╗
║   INTERACTIVE BLOCK EXPORT TEST                          ║
╚══════════════════════════════════════════════════════════╝

→ STEP 1: SELECT BLOCKS
  Please select block references in the drawing...
✓ Selected 3 block references

→ STEP 2: EXTRACTING BLOCK NAMES
  ✓ Found: LM105 Analog IC
  ✓ Found: Capacitor_100nF
  ✓ Found: Resistor_10K

✓ Total unique blocks: 3

→ STEP 3: CHOOSE EXPORT LOCATION
✓ Export folder: C:\Test

→ STEP 4: CHOOSE EXPORT METHOD
✓ Using Method 1

→ STEP 5: EXPORTING BLOCKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/3] Block: LM105 Analog IC
    Target: C:\Test\LM105 Analog IC.dwg
    Method: COMMAND
    ✓ SUCCESS - File created (2456 bytes)

[2/3] Block: Capacitor_100nF
    Target: C:\Test\Capacitor_100nF.dwg
    Method: COMMAND
    ✓ SUCCESS - File created (1823 bytes)

[3/3] Block: Resistor_10K
    Target: C:\Test\Resistor_10K.dwg
    Method: COMMAND
    ✓ SUCCESS - File created (1654 bytes)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
→ EXPORT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Total blocks: 3
  ✓ Successful: 3
  ✗ Failed: 0
  Export folder: C:\Test
```

---

## What If It Still Fails?

If TESTEXPORT still shows "✗ FAILED - Command ran but file not created":

1. **Run CHECKWBLOCK** - See if WBLOCK is disabled
2. **Check export folder permissions** - Try C:\TEMP\ instead
3. **Check AutoCAD Electrical security** - May need administrator
4. **Try Method 3 (VLA)** instead of Method 1 (COMMAND)

---

## Integration with MacroManager

Once you find which method works (1, 2, or 3), use that method in MacroManager v5.18:
- Method 1 = MacroManager Method 4 (Basic COMMAND)
- Method 2 = MacroManager Method 1 (vl-cmdf)
- Method 3 = MacroManager Method 3 (ObjectDBX)

---

**File:** INTERACTIVE_BLOCK_EXPORT_TEST.lsp  
**Created:** November 14, 2025  
**Purpose:** Visual block selection and export testing
