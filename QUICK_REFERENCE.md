# ⚡ QUICK REFERENCE CARD - Excel to AutoCAD Workflow

**Version 3.0** | **Status: ✅ READY** | **Date: Nov 3, 2025**

---

## 🎯 5-MINUTE WORKFLOW

```
┌────────────────────────────────────────────────────────────┐
│  EXCEL SIDE (Configure & Export)                          │
└────────────────────────────────────────────────────────────┘

1️⃣ Import CSV to Macro Library
   └─ Button: "Import from CSV"
   └─ File: sample_dt.csv (or your macro export)
   └─ Result: 8 macros loaded ✅

2️⃣ Set Project Conditions
   └─ Tab: Project Config
   └─ Cell C3: "Ice Rink" (or your project type)
   └─ Result: Selected Macros auto-filters ✅

3️⃣ Generate Drawings
   └─ Button: "Generate Drawings"
   └─ File created: Project_Macros_IceRink.csv
   └─ Location: [ExportPath] folder ✅

┌────────────────────────────────────────────────────────────┐
│  AUTOCAD SIDE (Import & Create)                           │
└────────────────────────────────────────────────────────────┘

4️⃣ Load AutoLISP (First time only)
   └─ Command: (load "WORKING_MacroManager_v5.lsp")
   └─ Or: Auto-load via acaddoc.lsp
   └─ Result: MACROMANAGER available ✅

5️⃣ Import Macros
   └─ Command: MACROMANAGER
   └─ Tab: Import
   └─ Browse: Project_Macros_IceRink.csv
   └─ Button: "Start Import"
   └─ Result: Blocks inserted at X,Y! 🎯
```

---

## 📋 CSV FORMAT CHEAT SHEET

### **Excel Format (What You See):**
```
Macro Name              | Type  | X  | Y
MCC_DOL_150HP_480V_BUS | POWER | 0  | 0
```

### **AutoLISP Format (What Gets Exported):**
```
Block Name,X Coordinate,Y Coordinate,Z Coordinate,Layer,Color,Linetype
MCC_DOL_150HP_480V_BUS,0,0,0,POWER_LAYER,256,ByLayer
```

### **Column Mapping:**
```
Excel Column C → Block Name
Excel Column E → X Coordinate
Excel Column F → Y Coordinate
Excel Column D → Layer (from "Type of Macros")
Default Values → Z=0, Color=256, Linetype=ByLayer
```

---

## ⚙️ SETTINGS QUICK CONFIG

| Setting | Purpose | Example Value |
|---------|---------|---------------|
| **ProjectName** | CSV filename | "Ice Rink" |
| **ExportPath** | CSV save location | D:\Exports |
| **CSVFilesPath** | CSV import default | D:\Imports |
| **LogsPath** | Error logs | D:\Logs |
| **AutoLaunchAutoCAD** | Auto-open CAD | Yes / No |

---

## 🔧 AUTOLISP COMMANDS

```lisp
; Load the manager
(load "WORKING_MacroManager_v5.lsp")

; Start the dialog
MACROMANAGER

; Check if loaded
!*selected_blocks*  ; Should return list or nil
```

---

## 🎯 FORMULA EXAMPLES (Selected Macros)

### **Simple Filter (Single Condition):**
```excel
=IF('Project Config'!C3="Ice Rink",'Macro Library'!C2,"")
```

### **Multiple Conditions:**
```excel
=IF(AND('Project Config'!C3="Ice Rink",'Macro Library'!D2="POWER"),
    'Macro Library'!C2,"")
```

### **Excel 365 FILTER Function:**
```excel
=FILTER('Macro Library'!A2:H100,
        'Macro Library'!D2:D100="POWER",
        "No matches")
```

---

## 🚨 COMMON ISSUES & QUICK FIXES

| Problem | Quick Fix |
|---------|-----------|
| ❌ "Subscript out of range" | Check sheet names have SPACES |
| ❌ No macros in Selected | Check formulas & Project Config |
| ❌ CSV export empty | Verify Selected Macros has data |
| ❌ MACROMANAGER not found | Load .lsp file in AutoCAD |
| ❌ AutoCAD won't launch | Set AutoLaunchAutoCAD = "Yes" |
| ❌ Blocks not inserting | Ensure block definitions exist |

---

## 📂 FILE LOCATIONS

### **Excel Files:**
```
MacroManager.xlsm          → Main workbook
├─ Macro Library           → Import destination
├─ Selected Macros         → Filtered results
├─ Settings                → Configuration
└─ Project Config          → User selections
```

### **AutoCAD Files:**
```
WORKING_MacroManager_v5.lsp   → AutoLISP functions
WORKING_MacroManager_v5.dcl   → Dialog definition
[ExportPath]\Project_Macros_[Name].csv → Exported macros
```

---

## 🎯 SUCCESS VERIFICATION

### **After Excel Export:**
- [ ] CSV file exists in ExportPath
- [ ] File size > 0 bytes
- [ ] Open in text editor shows data
- [ ] First line: "Block Name,X Coordinate,..."

### **After AutoCAD Import:**
- [ ] MACROMANAGER command works
- [ ] Dialog shows Import tab
- [ ] Preview shows CSV data
- [ ] Blocks appear in drawing
- [ ] X,Y coordinates match CSV

---

## ⚡ VBA FUNCTIONS REFERENCE

```vb
' Main workflow function
GenerateDrawings_Click()

' CSV export in AutoLISP format
ExportSelectedMacrosToProjectCSV(csvPath)

' AutoCAD integration
LaunchAutoCAD()           ' Open/activate AutoCAD
PromptForCADFile()        ' Browse for .dwg file

' Import functions
ImportFromCSV_Click()     ' Import to Macro Library
RefreshMacroLibrary_Click() ' Reload last CSV

' Utilities
EnsurePathExists(path)    ' Create folders
SetupMacroLibraryHeaders() ' Format headers
```

---

## 🔄 DATA FLOW DIAGRAM

```
┌──────────┐      ┌───────────┐      ┌──────────┐      ┌──────────┐
│ AutoCAD  │──►───│   Excel   │──►───│  Excel   │──►───│ AutoCAD  │
│  Export  │ CSV  │  Macro    │Filter│ Selected │ CSV  │  Import  │
│          │      │  Library  │      │  Macros  │      │          │
└──────────┘      └───────────┘      └──────────┘      └──────────┘
   Manual         VBA Import         Formulas         MACROMANAGER
```

---

## 📊 WORKFLOW STATES

```
STATE 1: EMPTY
├─ No macros in Macro Library
└─ Action: Import CSV

STATE 2: LIBRARY POPULATED  
├─ Macros in Library
├─ No selection criteria
└─ Action: Set Project Config

STATE 3: FILTERED
├─ Project Config set
├─ Selected Macros populated
└─ Action: Generate Drawings

STATE 4: EXPORTED
├─ CSV file created
└─ Action: Import to AutoCAD

STATE 5: COMPLETE ✅
├─ Blocks in drawing
└─ Ready for next project
```

---

## 🎓 TRAINING CHECKLIST

### **For Excel Users:**
- [ ] Understand Project Config → Selected Macros flow
- [ ] Know how to set project conditions
- [ ] Can verify Selected Macros formulas
- [ ] Comfortable clicking Generate Drawings

### **For AutoCAD Users:**
- [ ] Can load AutoLISP files
- [ ] Know MACROMANAGER command
- [ ] Comfortable with Import dialog
- [ ] Understand block library requirements

### **For System Administrators:**
- [ ] Can troubleshoot sheet name issues
- [ ] Understand CSV format requirements
- [ ] Can verify AutoLISP file locations
- [ ] Know where log files are stored

---

## 💾 BACKUP STRATEGY

```
Daily:  Export paths backed up
Weekly: Excel workbook saved with date
Monthly: AutoLISP files versioned
Always: Test imports on copy of drawing first!
```

---

## 📞 SUPPORT RESOURCES

1. **Complete Workflow Guide:** `COMPLETE_WORKFLOW_GUIDE.md`
2. **Integration Summary:** `INTEGRATION_SUMMARY.md`
3. **Path Configuration:** `PATH_CLEANUP_SUMMARY.md`
4. **Workflow Changes:** `SIMPLIFIED_WORKFLOW.md`
5. **Log Files:** `[LogsPath]\MacroManager_Log.txt`

---

## 🎉 QUICK WIN TEST

**5-Minute Proof of Concept:**

1. Import `sample_dt.csv` → 8 macros ✅
2. Set C3 = "Ice Rink" → 1 macro filtered ✅
3. Generate Drawings → CSV created ✅
4. MACROMANAGER → Import → Blocks inserted ✅

**If all 4 steps work → System is operational! 🚀**

---

**End of Quick Reference Card** ⚡
