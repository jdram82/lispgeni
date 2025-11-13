# MacroManager v5.2 ENHANCED - User Guide

## 📁 Folder Selection - TWO METHODS

### METHOD 1: Browse Button (Recommended)
1. Click **"Browse..."** button next to Block Library Folder
2. **Select ANY file** in the target folder (e.g., a DWG, TXT, or any file)
3. The system will extract the folder path automatically
4. Dialog returns immediately

**Example:**
- You want to use folder: `C:\Projects\ProjectA\BlockLibrary\`
- Browse and select any file inside: `C:\Projects\ProjectA\BlockLibrary\test.dwg`
- System will use: `C:\Projects\ProjectA\BlockLibrary\`

### METHOD 2: Type Path Directly (Alternative)
1. Click in the "Block Library Folder" text box
2. Type or paste the folder path directly: `C:\Projects\ProjectA\BlockLibrary`
3. Press Tab or click elsewhere
4. Path is saved automatically

**Note:** Do NOT include trailing backslash

---

## 🚀 EXPORT WORKFLOW

### Step 1: Set Block Library Folder
```
Block Library Folder: C:\Projects\ProjectA\BlockLibrary
```
- Use Browse button OR type directly
- Folder will be created automatically if it doesn't exist

### Step 2: Select Blocks
1. Choose mode: Single / Batch / All
2. Click **"1. SELECT BLOCKS..."**
3. Select your blocks in the drawing
4. Dialog closes → Select blocks → Dialog reopens automatically
5. Verify count: "Selected: 5 blocks"

### Step 3: Set CSV File Location
```
CSV File: C:\Projects\ProjectA\Data\exported_blocks.csv
```
- Click "Browse..." to select CSV save location
- Can be different folder from Block Library

### Step 4: Export
1. Click **"START EXPORT (CSV + DWG)"**
2. System will:
   - Create Block Library folder if needed
   - Save each block as separate DWG:
     * `C:\Projects\ProjectA\BlockLibrary\RELAY_52.dwg`
     * `C:\Projects\ProjectA\BlockLibrary\PLC_01.dwg`
     * etc.
   - Save CSV with metadata:
     ```csv
     Block Name,X Coordinate,Y Coordinate,Z Coordinate,Type,Color,Linetype
     RELAY_52,100.0000,200.0000,0.0000,Power,1,ByLayer
     PLC_01,150.0000,250.0000,0.0000,Controls,3,ByLayer
     ```

---

## 📥 IMPORT WORKFLOW

### Step 1: Set Block Library Folder
```
Block Library Folder: C:\Projects\ProjectA\BlockLibrary
```
- Browse to folder containing DWG files OR type path
- Must contain the block DWG files exported earlier

### Step 2: Select CSV File
```
CSV File: C:\Projects\ProjectA\Data\exported_blocks.csv
```
- Browse to CSV file with block data

### Step 3: Preview (Optional)
- Click **"PREVIEW CSV"** to see first 15 lines
- Verify data is correct

### Step 4: Import
1. Click **"START IMPORT"**
2. System will:
   - Check for missing DWG files
   - Load each block from DWG file:
     * Loads `RELAY_52.dwg` from Block Library
     * Inserts at coordinates from CSV
   - Apply properties (Type/Color/Linetype)
   - Report: "✓ Inserted: 5 blocks"

---

## 📂 File Organization Example

```
C:\CAD_Tools\MacroManager\
  ├── MacroManager_v5.2_ENHANCED.lsp  ← Load once from here
  ├── MacroManager_v5.2_ENHANCED.dcl  ← Auto-found

C:\Projects\ProjectA\
  ├── Drawing1.dwg                    ← Your working drawing
  ├── BlockLibrary\                   ← User selects this folder
  │   ├── RELAY_52.dwg                ← Exported blocks (DWG)
  │   ├── PLC_01.dwg
  │   └── BREAKER_15.dwg
  └── Data\
      └── exported_blocks.csv         ← Exported metadata (CSV)

C:\Projects\ProjectB\
  ├── Drawing2.dwg
  ├── BlockLibrary\                   ← Different folder for different project
  │   ├── RELAY_52.dwg
  │   └── TRANSFORMER_01.dwg
  └── Data\
      └── exported_blocks.csv
```

---

## ⚠️ Important Notes

### Folder Selection Tips:
1. **When browsing:** Select ANY file in the target folder (the file itself doesn't matter)
2. **When typing:** Use format: `C:\Path\To\Folder` (no trailing backslash)
3. **Validation:** System checks if folder exists during export/import
4. **Auto-creation:** Export automatically creates folder if missing

### CSV Column Changes:
- **OLD:** "Layer" column
- **NEW:** "Type" column (renamed for semantic meaning)
- Excel VBA must read "Type" column instead of "Layer"

### Block DWG Files:
- Each block saved as: `BlockName.dwg`
- File names match block names exactly
- Example: Block "RELAY_52" → File "RELAY_52.dwg"

---

## 🔧 Troubleshooting

### "No folder selected" message
- **Solution:** Click Browse and select a file in the folder, OR type path manually

### Browse dialog asks for DWG file
- **Expected:** This is normal! Select ANY file in your target folder
- **Result:** System uses the folder path, not the file itself

### Export fails - "No Block Library folder"
- **Solution:** Make sure folder path is set before clicking START EXPORT
- Check the path is valid: `C:\Valid\Path\Format`

### Import fails - "Block file not found"
- **Solution:** Verify DWG files exist in Block Library folder
- Check file names match block names exactly
- Use PREVIEW to see which blocks are in CSV

---

## 📝 Version History

### v5.2 ENHANCED (Current)
- ✓ Block Library folder selection
- ✓ WBLOCK export to separate DWG files
- ✓ Block loading from DWG files
- ✓ CSV column: "Layer" → "Type"
- ✓ Editable folder path in dialog
- ✓ Browse with folder path extraction
- ✓ Project-specific block libraries

### v5.1 CORRECTED
- ✓ STRING= function fixed
- ✓ Dialog stability improved
- ✓ Complete import/export functionality

---

**Questions? Check command line output for detailed progress messages!**
