# EXCEL WORKSHEET CONFIGURATION TEMPLATE
## Setup Instructions for Excel VBA Integration

---

## 📊 **SHEET 1: Macro Library**

### **Column Headers (Row 1):**
```
A1: Sl.No
B1: Block/Circuit Name
C1: Category
D1: DWG File Location
E1: X Coordinate
F1: Y Coordinate
G1: Z Coordinate
H1: Layer
I1: Color
J1: Linetype
K1: Export Date
L1: Export Time
```

### **Header Formatting:**
- Font: Bold, White
- Background: Blue (RGB: 68, 114, 196)
- Alignment: Center
- Border: All borders

### **Column Widths:**
- A: 8
- B: 25
- C: 20
- D: 50
- E-G: 12
- H: 15
- I-J: 12
- K-L: 15

### **Data Formatting:**
- Columns E, F, G: Number format `0.0000` (4 decimal places)
- Freeze panes at A2

### **Buttons:**
- **Import from CSV** → Macro: `ImportMacrosFromCSV_Click`
- **Refresh Library** → Macro: `RefreshMacroLibrary_Click`
- **Clear Library** → Macro: `ClearMacroLibrary_Click`

### **Hidden Storage:**
- Z1: Last imported CSV path (hidden column)

---

## 📊 **SHEET 2: Selected Macros**

### **Column Headers (Row 1):**
Same as Macro Library (A1:L1)

### **Header Formatting:**
- Font: Bold, White
- Background: Green (RGB: 100, 200, 100)
- Alignment: Center

### **Data Source:**
Formula-based or VBA-populated from Macro Library based on filter criteria

### **Example Formula in A2:**
```excel
=IFERROR(INDEX('Macro Library'!A:A,SMALL(IF('Macro Library'!$C$2:$C$1000=Project_Config!$B$2,ROW('Macro Library'!$A$2:$A$1000)),ROW(1:1))),"")
```
*Note: This is an array formula - press Ctrl+Shift+Enter*

### **Copy formula across all columns (A2:L2)**
### **Copy down for 100+ rows**

**Alternative: VBA Population**
```vba
' Auto-filter and copy matching records
Sub PopulateSelectedMacros()
    Dim filterCategory As String
    filterCategory = wsProjectConfig.Range("B2").Value
    
    ' Clear existing
    wsSelectedMacros.Range("A2:L1000").ClearContents
    
    ' Copy filtered data
    wsMacroLibrary.Range("A1:L1000").AutoFilter Field:=3, Criteria1:=filterCategory
    wsMacroLibrary.Range("A2:L1000").SpecialCells(xlCellTypeVisible).Copy _
        wsSelectedMacros.Range("A2")
    wsMacroLibrary.AutoFilterMode = False
End Sub
```

---

## 📊 **SHEET 3: Project_Config**

### **Layout:**

| Cell | Label | Input Cell | Description |
|------|-------|------------|-------------|
| A2 | Project Name: | B2 | User enters project name |
| A4 | Category Filter: | B4 | Dropdown with categories |
| A6 | Voltage Level: | B6 | User input (e.g., 415V) |
| A8 | Panel Type: | B8 | User input (e.g., MCC) |
| A10 | Location: | B10 | User input (e.g., Building A) |

### **Dropdown for Category (B4):**
Data Validation → List:
```
General,Control_Panel,Motor_Circuit,Power_Distribution,Lighting_Circuit,Instrumentation,Communication,Safety_System,HVAC_System,Custom
```

### **Buttons:**
```
Button: "Generate Drawings"
Position: D2:F4
Macro: GenerateDrawings_Click
```

### **Instructions Text Box:**
```
Position: A12:F20
Text:
"WORKFLOW:
1. Set filter criteria above
2. Check Selected Macros tab to verify filtered results
3. Click 'Generate Drawings' to:
   - Export CSV
   - Launch AutoCAD
   - Prompt for target drawing
4. In AutoCAD:
   - Type: UCB
   - Import CSV
   - Blocks placed at coordinates"
```

---

## 📊 **SHEET 4: Settings**

### **Layout:**

| Row | Setting Name (A) | Value (B) | Browse Button (D) |
|-----|------------------|-----------|-------------------|
| 2 | Macro Library Path: | C:\Projects\Macros | [Browse...] |
| 4 | Project Name: | New Project | - |
| 6 | Export Path: | C:\Projects\Exports | [Browse...] |
| 8 | CSV Files Path: | C:\Projects\CSVs | [Browse...] |
| 10 | Logs Path: | C:\Projects\Logs | [Browse...] |
| 12 | Block Library Path: | C:\Projects\Blocks | [Browse...] |
| 14 | Auto Launch AutoCAD: | No | Dropdown (Yes/No) |

### **Browse Buttons (Column D):**
- D2: `BrowseMacroLibraryButton_Click`
- D6: `BrowseExportPathButton_Click`
- D8: `BrowseCSVFilesPathButton_Click`
- D10: `BrowseLogsPathButton_Click`
- D12: `BrowseBlockLibraryPathButton_Click`

### **Action Buttons:**
```
Button: "Save Settings"
Position: B16:C17
Macro: SaveSettings_Click

Button: "Reset Defaults"
Position: D16:E17
Macro: ResetDefaults_Click
```

### **Hidden Storage (Column F):**
Same structure as column B, but hidden
- F2: Stored Macro Library Path
- F4: Stored Project Name
- F6: Stored Export Path
- F8: Stored CSV Files Path
- F10: Stored Logs Path
- F12: Stored Block Library Path
- F14: Stored Auto Launch setting

**Hide Column F:**
Right-click column F → Hide

---

## 📊 **SHEET 5: Logs**

### **Column Headers (Row 1):**
```
A1: Timestamp
B1: Action
C1: Status
D1: Details
```

### **Header Formatting:**
- Font: Bold, White
- Background: Gray (RGB: 200, 200, 200)
- Alignment: Center

### **Column Widths:**
- A: 20 (Timestamp)
- B: 30 (Action)
- C: 12 (Status)
- D: 80 (Details)

### **Conditional Formatting:**
- Status = "ERROR" → Red background (RGB: 255, 200, 200)
- Status = "SUCCESS" → Green background (RGB: 200, 255, 200)
- Status = "WARNING" → Yellow background (RGB: 255, 255, 200)
- Status = "INFO" → Light gray (RGB: 240, 240, 240)

### **Buttons:**
```
Button: "Clear Logs"
Position: F2:G3
Macro: ClearLogs_Click

Button: "Export Logs"
Position: H2:I3
Macro: ExportLogsToFile
```

### **Auto-scroll:**
VBA automatically scrolls to latest entry after logging

---

## 📊 **SHEET 6: Dashboard (Optional)**

### **Summary Statistics:**

| Cell | Label | Formula/Value |
|------|-------|---------------|
| B2 | Total Macros in Library: | `=COUNTA('Macro Library'!B:B)-1` |
| B4 | Macros in Selection: | `=COUNTA('Selected Macros'!B:B)-1` |
| B6 | Current Project: | `=Settings!B4` |
| B8 | Last Import Date: | `=MAX('Macro Library'!K:K)` |
| B10 | Categories in Library: | `=SUMPRODUCT(1/COUNTIF('Macro Library'!C2:C1000,'Macro Library'!C2:C1000&""))` |

### **Charts:**
1. **Pie Chart** - Macros by Category
   - Data: Count of macros per category from Macro Library
   - Position: D2:J15

2. **Bar Chart** - Export History
   - Data: Count by Export Date
   - Position: D17:J30

---

## 🔧 **VBA MODULE IMPORT INSTRUCTIONS**

### **Step 1: Open VBA Editor**
Press `Alt + F11` in Excel

### **Step 2: Import Module**
1. File → Import File
2. Select `Excel_VBA_Integration_Complete.bas`
3. Module appears in Project Explorer

### **Step 3: Set References**
Tools → References → Check:
- ✅ Microsoft Scripting Runtime
- ✅ Microsoft Office Object Library

### **Step 4: Initialize**
Run from VBA immediate window:
```vba
InitializeWorksheets
```

---

## 🎨 **NAMED RANGES (Optional Enhancement)**

Create named ranges for easier VBA access:

| Name | Refers To | Purpose |
|------|-----------|---------|
| `ProjectName` | Settings!$B$4 | Current project name |
| `ExportPath` | Settings!$B$6 | Export folder path |
| `MacroLibraryData` | 'Macro Library'!$A$2:$L$1000 | All library data |
| `SelectedMacrosData` | 'Selected Macros'!$A$2:$L$1000 | Filtered selection |
| `CategoryFilter` | Project_Config!$B$4 | Filter criteria |

**To create:**
Formulas → Name Manager → New

**VBA Usage:**
```vba
Dim projectName As String
projectName = Range("ProjectName").Value
```

---

## 📋 **WORKBOOK PROPERTIES**

### **Workbook Name:**
`MacroManager_Integration_v1.0.xlsm`

### **File Format:**
Excel Macro-Enabled Workbook (.xlsm)

### **Security:**
Enable macros when opening

### **Auto-Open Macro (Optional):**
```vba
Private Sub Workbook_Open()
    ' Initialize on workbook open
    Call InitializeWorksheets
    
    ' Load saved settings
    Call LoadSettings
    
    ' Log startup
    Call LogAction("Workbook_Open", "SUCCESS", "Workbook opened and initialized")
End Sub
```

Add this to `ThisWorkbook` module in VBA editor.

---

## 🔐 **PROTECTION SETTINGS (Optional)**

Protect sheets to prevent accidental changes:

### **Macro Library:**
- Protect: Yes
- Allow: Filter, Sort
- Password: (optional)

### **Selected Macros:**
- Protect: Yes
- Allow: Filter, Sort

### **Settings:**
- Protect: No (user needs to edit values)

### **Logs:**
- Protect: Yes
- Allow: Filter, Sort

**Command:**
Review → Protect Sheet

---

## ✅ **FINAL CHECKLIST**

- [ ] All 5 sheets created with correct names
- [ ] Headers formatted in all sheets
- [ ] Buttons added and assigned to macros
- [ ] VBA module imported
- [ ] Worksheet references initialized
- [ ] Settings configured with default paths
- [ ] Dropdown lists created
- [ ] Formulas in Selected Macros (if using formula method)
- [ ] Column F hidden in Settings sheet
- [ ] Column Z hidden in Macro Library sheet
- [ ] Freeze panes set on Macro Library
- [ ] Conditional formatting on Logs sheet
- [ ] Named ranges created (optional)
- [ ] Auto-open macro added (optional)
- [ ] File saved as .xlsm format
- [ ] Macros enabled in Excel

---

## 🚀 **FIRST RUN TEST**

1. Open Excel workbook
2. Enable macros if prompted
3. Press `Alt + F11` → Run `InitializeWorksheets`
4. Go to Settings → Set folder paths → Save Settings
5. Test import with sample CSV
6. Verify data appears in Macro Library
7. Check Selected Macros filters correctly
8. Test Generate Drawings button
9. Verify CSV exports correctly
10. Check Logs sheet for operation history

---

**Ready for Integration!** ✅
