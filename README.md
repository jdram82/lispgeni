# MacroManager - AutoCAD Electrical Block Export/Import Tool

## Overview
MacroManager v5.18 is a comprehensive AutoLISP utility for managing block exports and imports in AutoCAD Electrical 2024. It provides multiple export/import methods with platform-aware detection.

## Features
- **5 Export Methods**: Platform-Optimized, Direct vl-cmdf, Script, ObjectDBX, COMMAND
- **5 Import Methods**: XREF Attach, INSERT+Explode, INSERT, Direct INSERT, VLA
- **Platform Detection**: Auto-detects AutoCAD Electrical, BricsCAD, standard AutoCAD
- **Diagnostic Tool**: Comprehensive testing utility to troubleshoot export/import issues

## Files

### Main Application
- `MacroManager_v5.18.lsp` - Main program (1996 lines)
- `MacroManager_v5.18.dcl` - Dialog interface

### Diagnostic Tool
- `MacroManager_DIAGNOSTIC.lsp` - Testing and troubleshooting utility

### Documentation
- `MacroManager_v5.18_EXPORT_METHODS_EXPLAINED.md` - Complete export methods reference
- `MacroManager_v5.18_IMPORT_METHODS_EXPLAINED.md` - Complete import methods reference
- `MacroManager_v5.18_FINAL_CORRECTED_REFERENCE.md` - Technical reference guide
- `MacroManager_v5.18_DIAGNOSTIC_REPORT.md` - Diagnostic methodology
- `DIAGNOSTIC_TEST_ANALYSIS.md` - Test results and analysis

### Version History
- Previous versions: v5.1 through v5.17 (included for reference)

## Installation

1. Copy `MacroManager_v5.18.lsp` and `MacroManager_v5.18.dcl` to the same folder
2. Load in AutoCAD:
   ```
   Command: (load "MacroManager_v5.18.lsp")
   Command: MM
   ```

## Usage

### Running MacroManager
```
Command: MM
```
or
```
Command: MACROMANAGER
```

### Running Diagnostic Tool
```
Command: (load "MacroManager_DIAGNOSTIC.lsp")
Command: MMTEST
```

## Export Methods

| Method | Description | Best For |
|--------|-------------|----------|
| 0 | Platform-Optimized | General use (auto-detects best method) |
| 1 | Direct vl-cmdf | Standard AutoCAD |
| 2 | Script Method | Large batch exports |
| 3 | ObjectDBX | Background processing |
| 4 | Basic COMMAND | Maximum compatibility |

## Import Methods

| Method | Description | Best For |
|--------|-------------|----------|
| 0 | XREF Attach | Safe, non-destructive imports |
| 1 | INSERT+Explode | Converting blocks to entities |
| 2 | INSERT | Standard block insertion |
| 3 | Direct INSERT | Quick imports |
| 4 | VLA | ActiveX method |

## Platform Detection

The tool automatically detects:
- **AutoCAD Electrical** (checks PRODUCT, ACETUTIL.ARX, WDPROJECTNAMEEX)
- **BricsCAD**
- **Standard AutoCAD**

## Known Issues and Solutions

### Issue: Platform Detection Fails
**Symptom:** AutoCAD Electrical detected as "AUTOCAD" instead of "ACADE"

**Solution:** v5.18 uses enhanced detection with multiple indicators:
- PRODUCT variable
- ACETUTIL.ARX file
- WDPROJECTNAMEEX system variable

### Issue: "bad order function: COMMAND"
**Symptom:** Script execution fails with command order error

**Solution:** Fixed in v5.18 - Script format corrected:
- Separated `=` and blockname to different lines
- Removed underscore prefix in .scr files
- Added blank line after each block command

### Issue: Exports show success but no DWG files created
**Symptom:** Export count > 0 but no files in folder

**Solution:** Use diagnostic tool (MMTEST) to identify:
- File permission issues
- Path length problems
- Platform detection errors

## Diagnostic Tool Tests

The diagnostic utility (`MMTEST`) includes:
1. Platform Detection Test
2. Block Validation Test
3. System Variables Test
4. File Path Creation Test
5-9. Individual WBLOCK Method Tests
10. Script File Execution Test
11. Single Block All Methods Test
12. Verify Exported DWG Test

## Requirements
- AutoCAD Electrical 2024 (or 2018-2024)
- AutoCAD 2018+ (for standard AutoCAD)
- BricsCAD V20+ (for BricsCAD)

## Version Information
- **Current Version:** 5.18
- **Date:** November 13, 2025
- **Platform:** AutoCAD Electrical 2024 (saved as 2018 format)

## Changes in v5.18
1. Enhanced platform detection (3 detection methods)
2. Fixed script generation format (Method 2)
3. Simplified Method 0 for AutoCAD Electrical (uses COMMAND pattern)
4. Fixed "bad order function: COMMAND" error
5. Added comprehensive diagnostic tool

## Support
For issues or questions, refer to:
- `DIAGNOSTIC_TEST_ANALYSIS.md` for troubleshooting
- `MacroManager_v5.18_FINAL_CORRECTED_REFERENCE.md` for technical details
- Use `MMTEST` diagnostic tool to identify problems

## License
Internal tool for AutoCAD Electrical block management.

## Author
Developed through iterative testing and refinement for AutoCAD Electrical 2024.
