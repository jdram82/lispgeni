# MacroManager v5.4 - Release Notes

## 🎉 Version 5.4 Release - Auto-Execute & Multiple Export Methods

**Release Date:** November 4, 2025

---

## 📦 Files

- **MacroManager_v5.4.lsp** (1,193 lines, 55KB)
- **MacroManager_v5.4.dcl** (231 lines, 6.3KB)

---

## 🆕 What's New in v5.4

### **1. Auto-Execute Script** 🚀
- **No more manual SCRIPT commands!**
- Script automatically executes after CSV export
- Watch command line for DWG creation progress
- Instant workflow: Export → CSV created → Script runs → DWG files created

### **2. Three Export Methods** 🔧
User can now choose from 3 different export methods:

| Method | Description | Stability | Best For |
|--------|-------------|-----------|----------|
| **Script** (Default) | Creates script file, auto-executes | ⭐⭐⭐⭐⭐ | Large exports (100+ blocks) |
| **ActiveX/VLA** | Uses Visual LISP ActiveX | ⭐⭐⭐⭐ | Medium exports, if script fails |
| **Direct WBLOCK** | Direct command execution | ⭐⭐ | Small exports, last resort |

### **3. User-Selectable Export Method** 📻
- Radio buttons in dialog to choose export method
- Default: Script method (most stable)
- Try alternative methods if one fails
- Method selection persists across sessions

### **4. Alternative WBLOCK Functions** 🛠️
Added 4 fallback WBLOCK implementations:
```lisp
mm:wblock_vla        ; ActiveX/VLA method
mm:wblock_direct     ; Direct command method
mm:wblock_saveas     ; SAVEAS method (future)
mm:wblock_objectdbx  ; ObjectDBX method (future)
```

---

## ✨ Key Features (from v5.3)

### **Export Features:**
- ✅ Three selection modes (Single/Batch/All)
- ✅ Block Library folder management
- ✅ Type/Category dropdown (8 categories)
- ✅ 7-column CSV format with Type column
- ✅ Auto-execute script for DWG creation
- ✅ Alternative export methods

### **Import Features:**
- ✅ CSV preview before import
- ✅ Shows: "BlockName at (X, Y, Z) - Type: Category"
- ✅ Block count display
- ✅ Missing DWG file detection
- ✅ Property assignment (Type/Color/Linetype)

---

## 🚀 Quick Start

### **Installation:**
```lisp
;; Copy both files to your AutoCAD working directory
;; In AutoCAD Command Line:
(load "C:\\YourPath\\MacroManager_v5.4.lsp")
MACROMANAGER
```

### **Export Workflow (Auto-Execute):**
```
1. MACROMANAGER → Dialog opens
2. Select blocks → Click "1. SELECT BLOCKS..."
3. Choose Type → Select from dropdown (e.g., "Power")
4. Keep "Script Method" selected (default)
5. Browse Block Library folder
6. Browse CSV file location
7. Click "► START EXPORT (CSV + DWG)"
8. ✨ Script auto-executes → DWG files created automatically!
```

### **Alternative Export Methods:**
```
If Script Method doesn't work:
1. Select "ActiveX/VLA Method" radio button
2. Export → DWG files created immediately
3. No script file needed

If VLA Method doesn't work:
1. Select "Direct WBLOCK" radio button
2. ⚠️ Warning: May crash on some systems
3. Save your drawing first!
4. Export → Attempts direct WBLOCK
```

---

## 📋 Dialog Layout

```
╔════════════════════════════════════════════════════════╗
║ EXPORT - Select and Export Blocks to CSV + DWG Library║
╠════════════════════════════════════════════════════════╣
║ Block Library Folder: [________________] [Browse...]  ║
║                                                        ║
║ ⦿ Single Block Export                                 ║
║ ○ Batch Mode (Multiple Blocks)                        ║
║ ○ Export All Blocks (Full Drawing)                    ║
║                                                        ║
║ Selected Blocks: 0 blocks                              ║
║ [1. SELECT BLOCKS...] [2. CLEAR SELECTION]           ║
║                                                        ║
║ ┌──────────────────────────────────────────────────┐  ║
║ │ Block Type/Category Assignment                   │  ║
║ │ Set Type: [General ▼]                           │  ║
║ │ (This type will be saved in CSV 'Type' column)  │  ║
║ └──────────────────────────────────────────────────┘  ║
║                                                        ║
║ ┌──────────────────────────────────────────────────┐  ║
║ │ DWG Export Method                                │  ║
║ │ ⦿ Script Method (Recommended - Most Stable)     │  ║
║ │ ○ ActiveX/VLA Method (Try if script fails)      │  ║
║ │ ○ Direct WBLOCK (May crash on some systems)     │  ║
║ │ (Script method auto-executes after CSV export)  │  ║
║ └──────────────────────────────────────────────────┘  ║
║                                                        ║
║ CSV File: [________________] [Browse...]              ║
║ [► START EXPORT (CSV + DWG)]                          ║
╠════════════════════════════════════════════════════════╣
║ IMPORT - Import Blocks from CSV + DWG Library         ║
╠════════════════════════════════════════════════════════╣
║ Block Library Folder: [________________] [Browse...]  ║
║ CSV File: [________________] [Browse...]              ║
║                                                        ║
║ ┌──────────────────────────────────────────────────┐  ║
║ │ Import Preview                                   │  ║
║ │ Select a CSV file to preview blocks              │  ║
║ │ ┌──────────────────────────────────────────────┐│  ║
║ │ │ BlockName at (X, Y, Z) - Type: Category     ││  ║
║ │ │ ...                                          ││  ║
║ │ └──────────────────────────────────────────────┘│  ║
║ └──────────────────────────────────────────────────┘  ║
║                                                        ║
║ [► PREVIEW CSV] [► START IMPORT]                      ║
╠════════════════════════════════════════════════════════╣
║              [Close]              [Cancel]             ║
╚════════════════════════════════════════════════════════╝
```

---

## 🔄 Export Flow Comparison

### **v5.3 (Manual Script):**
```
Export → CSV created → Script created
       ↓
User must manually run: SCRIPT "path\file.scr"
       ↓
DWG files created
```

### **v5.4 (Auto-Execute):**
```
Export → CSV created → Script created → Auto-executes
                                      ↓
                              DWG files created automatically!
```

---

## 📊 CSV Format

### **7-Column Structure:**
```csv
Block Name,X Coordinate,Y Coordinate,Z Coordinate,Type,Color,Linetype
A5CG864B714,10.5000,20.3000,0.0000,Power,256,ByLayer
B3XK127C589,15.2000,25.8000,0.0000,Control,1,ByLayer
C1YT456D892,20.0000,30.5000,0.0000,Protection,256,DASHED
```

---

## 🎯 Recommended Usage

### **For Your 369 Blocks:**

**1st Try: Script Method (Default)**
```
✓ Most stable
✓ Auto-executes
✓ Best for large exports
✓ No manual commands needed
→ RECOMMENDED
```

**2nd Try: ActiveX/VLA Method**
```
✓ Fast
✓ No script file
✓ Direct DWG creation
→ Use if script method fails
```

**Last Resort: Direct WBLOCK**
```
⚠️ May crash
⚠️ Save drawing first
→ Only if other methods fail
```

---

## 🐛 Troubleshooting

### **Script doesn't auto-execute?**
- Check command line for error messages
- Manually run: `SCRIPT "path\export_blocks.scr"`
- Try ActiveX/VLA method instead

### **VLA method fails?**
- Check if Visual LISP is enabled
- Try Script method instead
- Check AutoCAD version compatibility

### **Direct WBLOCK crashes?**
- Expected on some systems
- Use Script or VLA method instead
- This is why Script method is default

### **No DWG files created?**
- Check Block Library folder path
- Verify blocks exist in drawing (TBLSEARCH)
- Check command line for errors
- Review export_blocks.scr content

---

## 📈 Version History

### **v5.4** (Current - November 4, 2025)
- ✅ Auto-execute script after export
- ✅ Three export methods (Script/VLA/Direct)
- ✅ User-selectable export method
- ✅ Alternative WBLOCK functions

### **v5.3**
- Script-based WBLOCK export
- Type/Category dropdown
- Preview functionality

### **v5.2**
- Block Library folder management
- CSV "Type" column rename

### **v5.1**
- Basic CSV import/export
- Block selection modes

---

## ✅ Testing Checklist

### **Export Tests:**
- [ ] Dialog loads without errors
- [ ] Script method auto-executes
- [ ] VLA method creates DWG files
- [ ] Direct method attempts WBLOCK
- [ ] CSV file created correctly
- [ ] Type column has correct values
- [ ] 369 blocks exported successfully

### **Import Tests:**
- [ ] Preview shows all blocks
- [ ] Preview displays correct format
- [ ] Missing DWG files detected
- [ ] Blocks insert at correct coordinates
- [ ] Type/Color/Linetype applied

---

## 🎉 Ready to Test!

Copy both files to your AutoCAD directory and load MacroManager_v5.4.lsp

**Command:** `MACROMANAGER`

**Expected Banner:**
```
╔═══════════════════════════════════════════════════════════╗
║  Macro Manager v5.4                                      ║
║                                                           ║
║  ✓ Auto-Execute Script (No Manual Commands!)            ║
║  ✓ 3 Export Methods (Script/VLA/Direct)                 ║
║  ✓ Type/Category Dropdown                               ║
║  ✓ Preview Before Import                                 ║
╚═══════════════════════════════════════════════════════════╝
```

**Test with your 369 blocks and let me know the results!** 🚀

---

## 📞 Support

- Check command line output for detailed messages
- Review this document for troubleshooting
- All three export methods provide fallback options
- Script method is most stable for large exports

**Good luck testing!** 🎊
