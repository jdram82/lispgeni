# MacroManager v5.3 - Complete Import/Export System

## 📦 Version 5.3 Release

### **Files:**
- `MacroManager_v5.3.lsp` (1,042 lines, 48KB)
- `MacroManager_v5.3.dcl` (202 lines, 5.4KB)

---

## 🆕 What's New in v5.3

### **1. Script-Based WBLOCK Export (Crash-Free)** 🛡️
- **Problem Solved:** Direct WBLOCK calls from AutoLISP caused fatal crashes (exception c0000027)
- **Solution:** Writes WBLOCK commands to `.scr` script file, executes separately
- **Benefits:** 
  - No more AutoCAD crashes during export
  - User can review script before execution
  - Option to run script immediately or later
  - Progress visible in command line

### **2. Type/Category Dropdown** 🏷️
- **8 Predefined Categories:**
  1. General (default)
  2. Power
  3. Control
  4. Protection
  5. Communication
  6. Instrumentation
  7. Safety
  8. Custom
- **Features:**
  - Select category before export
  - Applied to all selected blocks
  - Saved in CSV "Type" column
  - Session memory (persists across dialog reopens)

### **3. Preview Before Import** 👁️
- **What It Shows:**
  - Complete list of blocks from CSV
  - Format: "BlockName at (X, Y, Z) - Type: Category"
  - Block count: "Ready to import X blocks from CSV"
  - Scrollable list (8 lines visible)
- **Benefits:**
  - Verify blocks before importing
  - Check coordinates and types
  - Catch errors early

---

## 📋 Complete Feature List

### **Export Features:**
✅ Three selection modes:
   - Single Block Export
   - Batch Mode (Multiple Blocks)
   - Export All Blocks (Full Drawing)

✅ Block Library Management:
   - User-defined folder location
   - Separate from LISP/DCL files
   - Project-specific organization
   - Auto-creation if folder doesn't exist

✅ Type/Category Assignment:
   - Dropdown selection (8 categories)
   - Applied during export
   - Stored in CSV "Type" column

✅ CSV Export:
   - 7-column format
   - Header: Block Name, X, Y, Z, Type, Color, Linetype
   - Quoted field support
   - Coordinate precision (4 decimals)

✅ DWG Export (Script Method):
   - Creates export_blocks.scr in Block Library
   - One WBLOCK command per block
   - User prompted: "Run export script now? [Yes/No]"
   - Individual DWG file per block
   - Crash-free execution

### **Import Features:**
✅ CSV Preview:
   - Browse CSV file
   - Click "PREVIEW CSV" button
   - List shows all blocks with details
   - Status displays block count

✅ Block Library Import:
   - Browse Block Library folder
   - Loads DWG files during import
   - Missing file detection and warnings

✅ Block Insertion:
   - Coordinates from CSV (X, Y, Z)
   - Type/Layer assignment
   - Color application (if specified)
   - Linetype application (if specified)
   - Property validation

✅ Import Validation:
   - Checks for missing DWG files
   - Reports skipped blocks
   - Success/error counts
   - Detailed console output

---

## 🎯 Usage Instructions

### **Installation:**
```
1. Copy MacroManager_v5.3.lsp to your AutoCAD folder
2. Copy MacroManager_v5.3.dcl to the same folder
3. In AutoCAD Command Line:
   (load "C:\\YourPath\\MacroManager_v5.3.lsp")
   MACROMANAGER
```

### **Export Workflow:**
```
1. Open dialog → Select mode (Single/Batch/All)
2. Click "1. SELECT BLOCKS..." → Choose blocks in drawing
3. Select Type/Category from dropdown (e.g., "Power")
4. Browse Block Library folder (where DWG files will be saved)
5. Browse CSV file path (where to save coordinates)
6. Click "► START EXPORT (CSV + DWG)"
7. Prompt: "Run export script now? [Yes/No]"
   - Yes: Script executes immediately, DWG files created
   - No: Run manually later with: SCRIPT "path\export_blocks.scr"
```

### **Import Workflow:**
```
1. Open dialog → Go to IMPORT section
2. Browse CSV file (with block coordinates)
3. Click "► PREVIEW CSV" → Review block list
4. Browse Block Library folder (containing DWG files)
5. Click "► START IMPORT" → Blocks inserted with properties
```

---

## 📊 CSV Format

### **Structure (7 Columns):**
```csv
Block Name,X Coordinate,Y Coordinate,Z Coordinate,Type,Color,Linetype
A5CG864B714,10.5000,20.3000,0.0000,Power,256,ByLayer
B3XK127C589,15.2000,25.8000,0.0000,Control,1,ByLayer
C1YT456D892,20.0000,30.5000,0.0000,Protection,256,DASHED
```

### **Column Details:**
| Column | Description | Example |
|--------|-------------|---------|
| Block Name | Block reference name | A5CG864B714 |
| X Coordinate | X position (4 decimals) | 10.5000 |
| Y Coordinate | Y position (4 decimals) | 20.3000 |
| Z Coordinate | Z position (4 decimals) | 0.0000 |
| Type | Category from dropdown | Power |
| Color | AutoCAD color number | 256 (ByLayer) |
| Linetype | Linetype name | ByLayer |

---

## 🔧 Technical Details

### **Global Variables:**
```lisp
*selected_blocks*       ; List of selected block data
*selection_mode*        ; "single" | "batch" | "all"
*export_block_library*  ; Export folder path (session memory)
*import_block_library*  ; Import folder path (session memory)
*block_type*           ; Selected category (session memory)
```

### **Key Functions:**
```lisp
c:MACROMANAGER                    ; Main command
mm:export_blocks_and_dwg          ; Export CSV + create script
mm:preview_csv                    ; Preview import blocks
mm:import_blocks_from_dwg         ; Import from CSV + DWG library
mm:parse_csv_line                 ; CSV parser (quoted fields)
mm:check_missing_block_files      ; Validate DWG files exist
mm:browse_folder                  ; Folder selection workaround
mm:select_single_block            ; Single block selection
mm:select_batch_blocks            ; Multiple block selection
mm:select_all_blocks              ; All blocks in drawing
```

### **Script File Method:**
```
Export Process:
1. LISP creates export_blocks.scr in Block Library folder
2. Script contains one line per block:
   -WBLOCK "C:\Path\BlockName.dwg" = BlockName
3. User runs script (immediately or later)
4. AutoCAD processes WBLOCK commands in batch
5. Individual DWG files created without crashes
```

---

## 🐛 Troubleshooting

### **Issue: DCL file not found**
- **Solution:** Ensure both .lsp and .dcl are in same folder
- **Check:** File names match exactly (MacroManager_v5.3.dcl)

### **Issue: Script doesn't create DWG files**
- **Check:** Block Library folder path is valid
- **Check:** Blocks exist in current drawing (TBLSEARCH)
- **Solution:** Run script manually: `SCRIPT "path\export_blocks.scr"`

### **Issue: Import shows missing blocks**
- **Check:** DWG files exist in Block Library folder
- **Check:** File names match block names (case-sensitive)
- **Solution:** Export blocks first to create DWG library

### **Issue: Preview list is empty**
- **Check:** CSV file has correct format (7 columns)
- **Check:** CSV file has header row
- **Check:** File path is accessible

---

## 📈 Version History

### **v5.3 (Current)**
- ✅ Script-based WBLOCK export
- ✅ Type/Category dropdown (8 categories)
- ✅ Preview functionality before import

### **v5.2**
- Block Library folder management
- WBLOCK export attempts (crashed)
- CSV "Type" column rename

### **v5.1**
- Basic CSV import/export
- Block selection modes
- Property handling fixes

---

## 💡 Tips & Best Practices

1. **Organize Projects:**
   - Create separate Block Library folder per project
   - Example: `C:\Projects\ProjectA\BlockLibrary\`

2. **Type Categories:**
   - Use consistent categories across projects
   - "General" for uncategorized blocks
   - "Custom" for project-specific types

3. **CSV Backup:**
   - Keep CSV files as block coordinate records
   - Use version control for CSV files
   - Edit in Excel for bulk updates

4. **Script Execution:**
   - Choose "Yes" for immediate DWG creation
   - Choose "No" to review script first
   - Script can be run multiple times safely

5. **Preview Before Import:**
   - Always preview to catch coordinate errors
   - Check block count matches expectation
   - Verify Type assignments are correct

---

## 🎉 Ready to Use!

MacroManager v5.3 is fully functional and tested. All three phases completed:
- ✅ Phase 1: Script-based WBLOCK (crash-free)
- ✅ Phase 2: Type/Category dropdown
- ✅ Phase 3: Preview functionality

**Start with:** `(load "MacroManager_v5.3.lsp")` then `MACROMANAGER`

---

## 📞 Support

For issues or questions:
1. Check command line output for error messages
2. Review this README for troubleshooting
3. Verify file paths and CSV format
4. Ensure DWG files exist for import

**Happy block managing!** 🚀
