# Unified Circuit & Block Manager v2.0 - Implementation Plan

## Overview
Combining MacroManager (Block Definitions) + Circuit Manager (Assemblies) into ONE unified tool.

## User Requirements
✅ Same functionality as MacroManager for blocks
✅ Circuit assembly export/import capability  
✅ Option to choose between Blocks OR Circuits
✅ CSV coordinate tracking for auto-positioning
✅ Professional UI matching MacroManager style

## Architecture

### 1. **Content Type Selection**
```
┌─────────────────────────────────┐
│ Content Type:                   │
│  ○ Block Definitions            │
│  ○ Circuit Assemblies           │
└─────────────────────────────────┘
```

**Block Definitions:**
- Exports ONLY the block definition (using WBLOCK with "=" method)
- Import adds block to block table (no placement)
- Use case: Building block library for later use

**Circuit Assemblies:**
- Exports selected geometry + block references (complete assembly)
- Import places entire circuit with all blocks intact
- Use case: Saving/loading complete circuit sections

### 2. **Export Workflow**

**For BLOCKS:**
1. User selects "Block Definitions" mode
2. Choose blocks from drawing block table
3. Select export method (0-4, from MacroManager)
4. Export each block as separate .DWG file
5. Save to CSV: `BlockName, Type, FilePath, Date, Time`

**For CIRCUITS:**
1. User selects "Circuit Assemblies" mode  
2. User selects entities in drawing (including block references)
3. Pick base point for insertion reference
4. Export as single .DWG file with all content
5. Save to CSV: `CircuitName, Type, FilePath, BaseX, BaseY, BaseZ, Date, Time`

### 3. **Import Workflow**

**For BLOCKS:**
1. Browse block library list
2. Select blocks to import (multi-select)
3. Choose import method (0-4, from MacroManager)
4. Blocks added to drawing block table
5. User can insert them manually after

**For CIRCUITS:**
1. Browse circuit library OR load from CSV
2. If CSV mode: Coordinates auto-loaded
3. If manual: Pick insertion point
4. Set scale/rotation
5. INSERT command places complete assembly

### 4. **CSV File Structure**

**For Blocks:**
```csv
BlockName,Category,DWG_File,Export_Date,Export_Time
MOTOR_01,Motor_Circuit,C:\Library\Motor_Circuit\MOTOR_01.dwg,2025-11-14,10:30:00
SWITCH_A2,Control_Panel,C:\Library\Control_Panel\SWITCH_A2.dwg,2025-11-14,10:31:15
```

**For Circuits:**
```csv
CircuitName,Category,DWG_File,BaseX,BaseY,BaseZ,InsertX,InsertY,InsertZ,Export_Date,Export_Time
Motor_Control_01,Motor_Circuit,C:\Library\Motor_Circuit\Motor_Control_01.dwg,0.0,0.0,0.0,1500.0,2000.0,0.0,2025-11-14,10:35:00
Panel_Assembly,Control_Panel,C:\Library\Control_Panel\Panel_Assembly.dwg,0.0,0.0,0.0,3000.0,4000.0,0.0,2025-11-14,10:40:00
```

### 5. **CSV Import Features**

**Batch Import from CSV:**
- Load CSV file
- Display all circuits with saved coordinates
- Multi-select circuits to import
- "Import All" button for batch operations
- Each circuit placed at CSV coordinates automatically

**Benefits:**
- Save layout once, import multiple times
- Consistent positioning across drawings
- Document circuit placement
- Batch operations for efficiency

## Implementation Files

### Current Status:
✅ **UnifiedManager_v2.0.dcl** - Complete UI (280 lines)
   - Operation mode toggle (Export/Import)
   - Content type toggle (Blocks/Circuits)
   - Export panel with all options
   - Import panel with CSV support
   - Status bar and progress tracking

🔄 **UnifiedManager_v2.0.lsp** - In Development
   - Will merge MacroManager_v5.19.lsp (block functions)
   - Will merge CircuitManager_v1.0.lsp (circuit functions)
   - Add CSV coordinate handling
   - Add unified dialog logic
   - Estimated: ~1500-2000 lines

### Key Functions to Implement:

**Blocks (from MacroManager):**
- `ucb:export_blocks()` - Export block definitions
- `ucb:import_blocks()` - Import block definitions  
- `ucb:get_block_list()` - List all blocks in drawing
- `ucb:wblock_methods()` - 5 export methods (0-4)
- `ucb:insert_methods()` - 5 import methods (0-4)

**Circuits (from CircuitManager):**
- `ucb:export_circuit()` - Export selected entities
- `ucb:import_circuit()` - Import complete assembly
- `ucb:select_entities()` - User selection of geometry
- `ucb:get_base_point()` - Pick reference point

**CSV Integration (NEW):**
- `ucb:save_to_csv()` - Write export data
- `ucb:read_from_csv()` - Load saved data
- `ucb:import_from_csv()` - Batch import with coordinates
- `ucb:parse_csv()` - CSV parsing
- `ucb:update_csv()` - Update coordinates after import

**Dialog Management:**
- `ucb:show_dialog()` - Main dialog controller
- `ucb:mode_changed()` - Handle export/import toggle
- `ucb:type_changed()` - Handle blocks/circuits toggle
- `ucb:refresh_list()` - Update library browser
- `ucb:start_operation()` - Execute export/import

## Usage Example

### Export Blocks:
```lisp
(load "UnifiedManager_v2.0.lsp")
UCB  ; or UNIFIEDMANAGER

; In dialog:
; 1. Select "Export" mode
; 2. Select "Block Definitions"
; 3. Choose "Batch Mode"
; 4. Select export method "0 - Platform Optimized"
; 5. Click START EXPORT
; 6. Select blocks from list
; Result: Blocks exported to C:\Library\[Category]\[BlockName].dwg
;         CSV updated with block info
```

### Import Circuits from CSV:
```lisp
UCB

; In dialog:
; 1. Select "Import" mode
; 2. Select "Circuit Assemblies"
; 3. Choose "Import from CSV"
; 4. Click LOAD CSV
; 5. Select circuits from list (uses CSV coordinates)
; 6. Click START IMPORT
; Result: Circuits inserted at saved coordinates automatically
```

## Benefits of Unified Approach

1. **Single Interface** - One tool for all needs
2. **Consistent UI** - Familiar MacroManager layout
3. **CSV Integration** - Coordinate tracking built-in
4. **Flexible Workflow** - Switch between blocks/circuits easily
5. **Batch Operations** - Export/import multiple items
6. **Organized Library** - Category-based folder structure
7. **Complete Solution** - No need for multiple tools

## Next Steps

1. Create UnifiedManager_v2.0.lsp (merging existing code)
2. Test block export/import with all 5 methods
3. Test circuit export/import with CSV
4. Add batch operations
5. Add preview functionality
6. Create user documentation
7. Final testing in AutoCAD Electrical 2024

## File Structure
```
C:\Temp\Circuit_Library\
├── Block_Coordinates.csv          (Block library index)
├── Circuit_Coordinates.csv        (Circuit coordinate tracking)
├── General\
│   ├── BLOCK_01.dwg
│   └── Circuit_A.dwg
├── Motor_Circuit\
│   ├── MOTOR_01.dwg
│   └── Motor_Control_Panel.dwg
├── Control_Panel\
│   ├── SWITCH_A2.dwg
│   └── Panel_Assembly.dwg
└── [Other Categories...]\
```

---
**Status:** DCL Complete ✅ | LSP In Progress 🔄 | Testing Pending ⏳
