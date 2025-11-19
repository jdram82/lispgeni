# 12-COLUMN CSV FORMAT SPECIFICATION
## Excel VBA ↔ AutoCAD UnifiedManager Auto Integration

---

## **Format Overview**

All CSV files exchanged between Excel and AutoCAD use a standardized **12-column format** for complete round-trip compatibility.

### **Column Structure:**
```
Sl.No | Block/Circuit Name | Category | DWG File Location | X Coordinate | Y Coordinate | Z Coordinate | Layer | Color | Linetype | Export Date | Export Time
```

---

## **Column Definitions**

| Column | Name | Data Type | Description | Example |
|--------|------|-----------|-------------|---------|
| A | Sl.No | Integer | Sequential number (auto-generated in Excel) | `1`, `2`, `3` |
| B | Block/Circuit Name | Text | Block reference name or circuit identifier | `PowerPanel_MCC01`, `MOTOR_STARTER_01` |
| C | Category | Text | Functional category (user-selected during export) | `Power`, `Control`, `Protection` |
| D | DWG File Location | Text | Full absolute path to source DWG file | `C:\Projects\Panel_Design\MCC01.dwg` |
| E | X Coordinate | Decimal (4 places) | Insertion point X coordinate | `100.5000`, `250.7500` |
| F | Y Coordinate | Decimal (4 places) | Insertion point Y coordinate | `200.3000`, `180.6000` |
| G | Z Coordinate | Decimal (4 places) | Insertion point Z coordinate (elevation) | `0.0000`, `50.0000` |
| H | Layer | Text | AutoCAD layer name where block resides | `POWER`, `CONTROL`, `0` |
| I | Color | Integer/Text | AutoCAD color number (256 = ByLayer) | `256`, `1`, `ByLayer` |
| J | Linetype | Text | AutoCAD linetype | `ByLayer`, `CONTINUOUS`, `DASHED` |
| K | Export Date | Date (YYYY-MM-DD) | Date when exported from AutoCAD | `2025-11-19` |
| L | Export Time | Time (HH:MM:SS) | Time when exported from AutoCAD | `14:30:45` |

---

## **Sample CSV Data**

### **CSV Header (Row 1):**
```csv
Block/Circuit Name,Category,DWG File Location,X Coordinate,Y Coordinate,Z Coordinate,Layer,Color,Linetype,Export Date,Export Time
```

### **Sample Data Rows:**
```csv
PowerPanel_MCC01,Power,C:\Projects\Electrical\Panel_MCC01.dwg,100.5000,200.3000,0.0000,POWER,256,ByLayer,2025-11-19,14:30:45
MotorStarter_M01,Control,C:\Projects\Electrical\Motor_Circuits.dwg,150.7500,250.4000,0.0000,CONTROL,1,CONTINUOUS,2025-11-19,14:31:22
VFD_Drive_01,Power,C:\Projects\Electrical\VFD_Panel.dwg,75.2500,180.6000,0.0000,POWER,256,ByLayer,2025-11-19,14:32:10
Transformer_T01,Protection,C:\Projects\Electrical\Transformers.dwg,200.0000,300.0000,0.0000,PROTECTION,3,DASHED,2025-11-19,14:33:05
```

---

## **Field Details**

### **1. Sl.No (Column A)**
- **Purpose**: Tracking and reference number
- **Excel**: Auto-generated sequence (1, 2, 3...)
- **AutoCAD**: Not used (Excel adds during import)

### **2. Block/Circuit Name (Column B)**
- **Purpose**: Unique identifier for the block or circuit
- **Requirements**:
  - No commas or special characters (CSV safety)
  - Preferably no spaces (use underscores)
  - Must match AutoCAD block definition name
- **Examples**: `MCB_3P_63A`, `CONTACTOR_LC1D18`, `RELAY_RXM2AB2P7`

### **3. Category (Column C)**
- **Purpose**: Functional grouping for filtering in Excel
- **Source**: User-prompted dropdown during AutoCAD export
- **Standard Categories**:
  - Power
  - Control
  - Protection
  - Instrumentation
  - Communication
  - Lighting
  - HVAC
  - Safety
  - General
  - Custom (user-defined)

### **4. DWG File Location (Column D)**
- **Purpose**: Source file traceability
- **Format**: Full absolute path
- **AutoCAD Export**: Captures current drawing path: `(getvar "DWGPREFIX")` + `(getvar "DWGNAME")`
- **Excel Import**: Stored for reference and documentation
- **AutoCAD Import**: Can validate or prompt if file not found
- **Example**: `C:\Users\Engineer\Documents\Projects\Electrical_2025\Panel_MCC01.dwg`

### **5-7. X, Y, Z Coordinates (Columns E, F, G)**
- **Purpose**: Exact insertion point for block placement
- **Precision**: 4 decimal places (`0.0000`)
- **Units**: Match current AutoCAD drawing units
- **Z Coordinate**: Usually `0.0000` for 2D drawings
- **Format**: Decimal number, no quotes
- **Examples**: 
  - X: `1250.7500`
  - Y: `3480.2500`
  - Z: `0.0000`

### **8. Layer (Column H)**
- **Purpose**: AutoCAD layer assignment
- **Source**: Extracted from block reference during export: `(cdr (assoc 8 ent_data))`
- **Default**: `"0"` (layer zero)
- **Import Behavior**: Block placed on specified layer (created if doesn't exist)
- **Examples**: `POWER`, `CONTROL_DEVICES`, `PROTECTION`, `0`

### **9. Color (Column I)**
- **Purpose**: Display color in AutoCAD
- **Format**: Integer (AutoCAD color index) or `"ByLayer"`
- **Source**: Extracted from block reference: `(cdr (assoc 62 ent_data))`
- **Common Values**:
  - `256` = ByLayer (most common)
  - `1` = Red
  - `2` = Yellow
  - `3` = Green
  - `4` = Cyan
  - `5` = Blue
  - `7` = White/Black
- **Import Behavior**: Color applied to inserted block

### **10. Linetype (Column J)**
- **Purpose**: Line appearance style
- **Source**: Extracted from block reference: `(cdr (assoc 6 ent_data))`
- **Default**: `"ByLayer"` (inherits from layer)
- **Common Values**:
  - `ByLayer` (most common)
  - `CONTINUOUS` (solid line)
  - `DASHED` (dashed line)
  - `HIDDEN` (hidden line)
  - `CENTER` (centerline)
- **Import Behavior**: Linetype applied if loaded in drawing

### **11-12. Export Date & Time (Columns K, L)**
- **Purpose**: Timestamp for tracking and version control
- **Format**: 
  - Date: `YYYY-MM-DD` (e.g., `2025-11-19`)
  - Time: `HH:MM:SS` (24-hour format, e.g., `14:30:45`)
- **AutoCAD**: Generated using `(getvar "DATE")` with `edtime` formatting
- **Excel**: Preserved during import, updated during re-export
- **Use Cases**:
  - Track when data was last synchronized
  - Identify stale data
  - Audit trail

---

## **Data Flow**

### **Phase 1: AutoCAD Export → Excel Import**
1. **AutoCAD (UnifiedManager Auto)**:
   - User selects blocks/circuits
   - Prompts for category (dropdown)
   - Extracts properties: Layer, Color, Linetype
   - Gets DWG path: `(strcat (getvar "DWGPREFIX") (getvar "DWGNAME"))`
   - Captures coordinates: Base point (X, Y, Z)
   - Generates timestamp
   - Writes 12-column CSV

2. **Excel VBA Import**:
   - Reads CSV file
   - Parses 12 columns
   - Populates **Macro Library** sheet
   - Auto-generates Sl.No sequence
   - Formats coordinates to 4 decimal places

### **Phase 2: Excel Filtering**
3. **Excel Formula/Manual Filtering**:
   - User sets criteria in **Project_Config** tab
   - Formulas filter **Macro Library** → **Selected Macros**
   - Same 12-column structure maintained

### **Phase 3: Excel Export → AutoCAD Import**
4. **Excel VBA Export**:
   - Reads **Selected Macros** sheet
   - Writes 12-column CSV (same format as import)
   - Preserves all properties

5. **AutoCAD (UnifiedManager Auto Import)**:
   - Reads CSV file
   - Validates block names exist in drawing
   - Places blocks at exact X, Y, Z coordinates
   - Applies Layer, Color, Linetype properties
   - Logs import results

---

## **Validation Rules**

### **Required Fields (Cannot be empty):**
- Block/Circuit Name (Column B)
- X Coordinate (Column E)
- Y Coordinate (Column F)

### **Optional Fields (Default values if empty):**
- Category (Column C) → `"General"`
- DWG File Location (Column D) → `"Unknown"`
- Z Coordinate (Column G) → `0.0000`
- Layer (Column H) → `"0"`
- Color (Column I) → `"256"` (ByLayer)
- Linetype (Column J) → `"ByLayer"`
- Export Date (Column K) → Current date
- Export Time (Column L) → Current time

### **Data Type Validation:**
- Coordinates (E, F, G): Must be numeric, decimal format
- Color (I): Must be integer (0-255) or "ByLayer"
- Date (K): Must be YYYY-MM-DD format
- Time (L): Must be HH:MM:SS format

---

## **Error Handling**

### **Excel Import Errors:**
- **Missing columns**: Prompt user to select correct CSV file
- **Invalid coordinates**: Skip row and log error
- **Empty Block/Circuit Name**: Skip row

### **AutoCAD Import Errors:**
- **Block not found**: Log error, prompt to browse for block file
- **Invalid coordinates**: Skip row, log coordinates
- **Layer doesn't exist**: Auto-create layer
- **Linetype not loaded**: Use CONTINUOUS or load linetype

---

## **File Naming Conventions**

### **Export from AutoCAD:**
```
Block_Coordinates_YYYYMMDD_HHMMSS.csv
Circuit_Coordinates_YYYYMMDD_HHMMSS.csv
```

### **Export from Excel:**
```
Project_Macros_[ProjectName].csv
Project_[ProjectName]_YYYYMMDD_HHMMSS.csv
```

---

## **Best Practices**

1. **Always use full absolute paths** for DWG File Location
2. **Keep Block/Circuit Names unique** within a project
3. **Use consistent category names** for easy filtering
4. **Maintain 4 decimal precision** for coordinates
5. **Use ByLayer** for Color and Linetype when possible
6. **Validate CSV format** before importing to AutoCAD
7. **Back up CSV files** before major operations
8. **Use meaningful category names** (not just numbers)
9. **Document custom categories** in project documentation
10. **Test with small dataset first** before bulk operations

---

## **Compatibility Matrix**

| Tool | Version | CSV Format | Status |
|------|---------|------------|--------|
| UnifiedManager Auto | 1.0 | 12-column | ✅ Supported |
| UnifiedManager v2.4 | 2.4 | 11-column (legacy) | ⚠️ Not compatible |
| Excel VBA Template | 3.2 | 12-column | ✅ Supported |
| VBA Master Consolidated | 3.2 | 12-column | ✅ Supported |

**Note**: UnifiedManager v2.4 uses a different CSV format (11 columns without Category field). Use UnifiedManager Auto for 12-column compatibility.

---

## **Troubleshooting**

### **"Column mismatch" error:**
- Verify CSV has exactly 12 columns
- Check for missing header row
- Ensure no extra commas in data fields

### **"Invalid coordinate" error:**
- Check for non-numeric values in X, Y, Z columns
- Verify decimal separator (use period, not comma)
- Ensure no scientific notation

### **"Block not found" during import:**
- Verify block name matches exactly (case-sensitive)
- Check if block exists in current drawing or libraries
- Load block definition before importing

### **Missing Layer/Color/Linetype properties:**
- Verify AutoCAD LSP version is UnifiedManager Auto
- Check entity properties extraction in export code
- Use default values if properties not available

---

## **Example Workflow**

### **Complete Round-Trip Example:**

**Step 1: AutoCAD Export**
```
- Select 5 power panel blocks
- Choose Category: "Power"
- Export creates: Block_Coordinates_20251119_143045.csv
```

**Step 2: Excel Import**
```
- Open Excel template
- Click "Import from CSV"
- Select: Block_Coordinates_20251119_143045.csv
- Result: 5 blocks loaded to Macro Library
```

**Step 3: Excel Filtering**
```
- Set Project_Config filter: Category = "Power"
- Selected Macros auto-populates with 5 blocks
- Verify coordinates are correct
```

**Step 4: Excel Export**
```
- Click "Generate Drawings"
- Export creates: Project_Macros_Panel_MCC01.csv
```

**Step 5: AutoCAD Import**
```
- Open target drawing
- Type: UCB or UNIFIEDMANAGER
- Switch to Import mode
- Select: Project_Macros_Panel_MCC01.csv
- Result: 5 blocks placed at exact coordinates with proper layers/colors
```

---

**Last Updated**: November 19, 2025
**Format Version**: 1.0
**Compatible Tools**: UnifiedManager Auto v1.0, Excel VBA Template v3.2
