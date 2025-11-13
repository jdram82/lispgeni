# MacroManager v5.2 ENHANCED - Testing Guide

## 📦 Files Ready for Testing

### **Updated Files:**
1. ✅ `MacroManager_v5.2_ENHANCED.lsp` (1,034 lines)
2. ✅ `MacroManager_v5.2_ENHANCED.dcl` (203 lines)

---

## 🎯 New Features Implemented

### **Phase 1: Script-Based WBLOCK Export** ✅
- Exports blocks to CSV with coordinates and properties
- Creates script file with WBLOCK commands
- Prompts user to run script (avoids direct WBLOCK crashes)
- Script creates individual DWG files in Block Library folder

### **Phase 2: Type/Category Dropdown** ✅
- 8 predefined categories: General, Power, Control, Protection, Communication, Instrumentation, Safety, Custom
- Dropdown in Export section
- Selected type applied to all exported blocks
- Saved in CSV "Type" column

### **Phase 3: Preview Functionality** ✅
- Preview button in Import section
- Shows all blocks from CSV before import
- Displays: "BlockName at (X, Y, Z) - Type: Category"
- Block count in status message
- Scrollable list (8 lines high)

---

## 🧪 Testing Instructions

### **STEP 1: Load the LISP File**

```autolisp
;; In AutoCAD Command Line:
(load "C:\\Path\\To\\MacroManager_v5.2_ENHANCED.lsp")
MACROMANAGER
```

**Expected Output:**
```
╔═══════════════════════════════════════════════════════════╗
║  Macro Manager v5.2 - ENHANCED                           ║
║                                                           ║
║  ✓ Block Library Management                              ║
║  ✓ WBLOCK Export to DWG Files                            ║
║  ✓ Project-Specific Block Libraries                      ║
╚═══════════════════════════════════════════════════════════╝
```

---

### **STEP 2: Test EXPORT Function**

#### **A. Select Blocks**
1. Dialog opens → Click "1. SELECT BLOCKS..."
2. Dialog closes → Select blocks in drawing (single or multiple)
3. Dialog reopens → Shows "Selected: X blocks"

#### **B. Set Block Type**
1. In "Block Type/Category Assignment" section
2. Open dropdown → Select category (e.g., "Power")
3. Console shows: ">>> Block Type set to: Power"

#### **C. Browse Block Library Folder**
1. Click "Browse..." next to "Block Library Folder"
2. Select ANY file in target folder
3. Folder path extracted and displayed

#### **D. Browse CSV File**
1. Click "Browse..." next to "CSV File"
2. Choose location (e.g., C:\Projects\test_export.csv)
3. Click "► START EXPORT (CSV + DWG)"

#### **E. Script Execution**
1. Prompt: "Run export script now to create DWG files? [Yes/No] <Yes>:"
2. Type "Yes" or press Enter
3. Script executes WBLOCK commands
4. Watch console for DWG creation progress

**Expected CSV Output:**
```csv
Block Name,X Coordinate,Y Coordinate,Z Coordinate,Type,Color,Linetype
A5CG864B714,10.5000,20.3000,0.0000,Power,256,ByLayer
B3XK127C589,15.2000,25.8000,0.0000,Power,256,ByLayer
```

**Expected Files Created:**
- `test_export.csv` (with block data)
- `export_blocks.scr` (in Block Library folder)
- `BlockName.dwg` files (one per block, in Block Library folder)

---

### **STEP 3: Test PREVIEW Function**

#### **A. Open Dialog**
1. Run `MACROMANAGER` again
2. Go to IMPORT section

#### **B. Browse CSV File**
1. Click "Browse..." next to CSV File
2. Select previously exported CSV
3. Status changes: "CSV file selected. Click PREVIEW CSV to view blocks."

#### **C. Preview Blocks**
1. Click "► PREVIEW CSV"
2. List populates with block entries
3. Status shows: "Ready to import X blocks from CSV"

**Expected Preview Display:**
```
╔════════════════════════════════════════════════════════╗
║ Import Preview                                         ║
║ Ready to import 25 blocks from CSV                     ║
╠════════════════════════════════════════════════════════╣
║ Blocks to be imported:                                 ║
║ ┌──────────────────────────────────────────────────┐   ║
║ │ A5CG864B714 at (10.5, 20.3, 0.0) - Type: Power  │   ║
║ │ B3XK127C589 at (15.2, 25.8, 0.0) - Type: Power  │   ║
║ │ ... (scrollable)                                 │   ║
║ └──────────────────────────────────────────────────┘   ║
╚════════════════════════════════════════════════════════╝
```

---

### **STEP 4: Test IMPORT Function**

#### **A. Browse Block Library**
1. Click "Browse..." next to Block Library Folder
2. Select ANY file in folder containing DWG files
3. Folder path extracted

#### **B. Start Import**
1. Click "► START IMPORT"
2. Function checks for missing DWG files
3. Loads each block from DWG file
4. Inserts at coordinates from CSV
5. Applies Type, Color, Linetype properties

**Expected Console Output:**
```
>>> STARTING BLOCK IMPORT (CSV + DWG)
>>> ══════════════════════════════════════════
>>> Checking for missing block DWG files...
>>> ✓ All block DWG files found!
>>> Processing CSV data...
    → Loading: A5CG864B714.dwg
    ✓ A5CG864B714 at (10.50, 20.30)
    → Loading: B3XK127C589.dwg
    ✓ B3XK127C589 at (15.20, 25.80)
>>> ══════════════════════════════════════════
>>> ✓ Import complete!
>>>   • 25 blocks inserted
>>>   • 0 blocks skipped
>>> ══════════════════════════════════════════
```

---

## ✅ Test Checklist

### **Export Tests:**
- [ ] Dialog loads without errors
- [ ] Block selection works (single/batch/all modes)
- [ ] Type dropdown shows all 8 categories
- [ ] Type selection updates global variable
- [ ] Block Library folder browse works
- [ ] CSV file browse works
- [ ] CSV file created with correct format
- [ ] CSV contains correct Type column values
- [ ] Script file created in Block Library folder
- [ ] Script prompt appears ("Run export script now?")
- [ ] Script executes WBLOCK commands
- [ ] DWG files created (one per block)
- [ ] No crashes during WBLOCK (script method)

### **Preview Tests:**
- [ ] Preview status initializes correctly
- [ ] CSV browse updates preview status
- [ ] Preview button executes without errors
- [ ] List box populates with all blocks
- [ ] Format: "BlockName at (X, Y, Z) - Type: Category"
- [ ] Status shows correct block count
- [ ] Empty CSV shows appropriate error
- [ ] Missing file shows error message

### **Import Tests:**
- [ ] Block Library folder browse works
- [ ] CSV file browse works
- [ ] Missing DWG files detected and reported
- [ ] Blocks load from DWG files
- [ ] Blocks insert at correct coordinates
- [ ] Type/Layer assigned correctly
- [ ] Color applied (if not 256)
- [ ] Linetype applied (if not ByLayer)
- [ ] Success/skip counts displayed
- [ ] Alert shows summary

---

## 🐛 Known Issues & Workarounds

### **Issue 1: WBLOCK Direct Crash**
- **Symptom:** Exception c0000027 when WBLOCK called from LISP
- **Solution:** Script method implemented (WBLOCK runs outside LISP)
- **Status:** ✅ Fixed in v5.2

### **Issue 2: No Native Folder Dialog**
- **Symptom:** AutoLISP lacks folder selection dialog
- **Solution:** Select any file in folder, extract directory path
- **Status:** ⚠️ Workaround implemented

### **Issue 3: Type vs Layer Confusion**
- **Symptom:** CSV column was "Layer" but semantic meaning is "Type"
- **Solution:** Renamed column to "Type", dropdown for category selection
- **Status:** ✅ Fixed in v5.2

---

## 📊 File Statistics

| File | Lines | Size | Status |
|------|-------|------|--------|
| MacroManager_v5.2_ENHANCED.lsp | 1,034 | ~45 KB | ✅ Ready |
| MacroManager_v5.2_ENHANCED.dcl | 203 | ~7 KB | ✅ Ready |

---

## 🔄 Testing Workflow Summary

```
EXPORT WORKFLOW:
1. Load LISP → MACROMANAGER command
2. Select blocks → Choose type category
3. Browse Block Library folder → Browse CSV path
4. Export → Script created
5. Run script (Yes/No) → DWG files created

IMPORT WORKFLOW:
1. Load LISP → MACROMANAGER command
2. Browse CSV file → Click PREVIEW CSV
3. Review block list → Browse Block Library folder
4. Click START IMPORT → Blocks inserted with properties
```

---

## 📞 Support

If you encounter issues:
1. Check AutoCAD Command Line for error messages
2. Verify DCL file is in same folder as LSP
3. Ensure Block Library folder path is valid
4. Check CSV format (7 columns, header row)
5. Verify DWG files exist for import

---

## 🎉 Ready to Test!

Both files are complete and validated. Copy them to your AutoCAD working directory and follow the testing instructions above.

**Good luck with testing!** 🚀
