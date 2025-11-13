// ═══════════════════════════════════════════════════════════════════════════
// PROFESSIONAL MACRO MANAGER v5.10 DCL
// With Fixed Script Format & Comprehensive Diagnostics
// ═══════════════════════════════════════════════════════════════════════════
// NEW in v5.10:
//   - Fixed script file format (multi-line WBLOCK commands)
//   - Comprehensive diagnostics (6-step progress indicators)
//   - Detailed command line output for every operation
//   - Per-block progress tracking [1/N, 2/N, etc.]
//   - Success/failure reporting for each block
//   - Clear error messages at every stage
//   - Export summary with file locations and counts
// ═══════════════════════════════════════════════════════════════════════════

UnifiedMacroDialog : dialog {
  label = "Professional Macro Manager v5.10";
  initial_focus = "export_mode_single";
  
  : boxed_column {
    label = "EXPORT - Select and Export Blocks to CSV + DWG Library";
    fixed_width = true;
    
    // Block Library Path - EDITABLE
    : row {
      : edit_box {
        label = "Block Library Folder:";
        edit_width = 45;
        edit_limit = 256;
        key = "export_block_library";
      }
      : button {
        label = "Browse...";
        key = "export_block_library_browse";
        width = 10;
      }
    }
    
    : row {
      : column {
        : radio_button {
          key = "export_mode_single";
          label = "Single Block Export";
        }
        : radio_button {
          key = "export_mode_batch";
          label = "Batch Mode (Multiple Blocks)";
        }
        : radio_button {
          key = "export_mode_all";
          label = "Export All Blocks (Full Drawing)";
        }
      }
    }
    
    : row {
      : text {
        label = "Selected Blocks:";
        edit_width = 40;
        edit_limit = 100;
        key = "selection_count";
      }
    }
    
    : row {
      : button {
        label = "1. SELECT BLOCKS...";
        key = "export_select";
        width = 18;
      }
      : button {
        label = "2. CLEAR SELECTION";
        key = "export_clear";
        width = 18;
      }
    }
    
    // Block Type/Category Selection
    : boxed_column {
      label = "Block Type/Category Assignment";
      : row {
        : text {
          label = "Set Type for Selected Blocks:";
          width = 25;
        }
        : popup_list {
          key = "block_type";
          width = 20;
          list = "General\nPower\nControl\nProtection\nCommunication\nInstrumentation\nSafety\nCustom";
          value = "0";
        }
      }
      : text {
        label = "(This type will be saved in CSV 'Type' column)";
        width = 50;
      }
    }
    
    // DWG Export Method Selection
    : boxed_column {
      label = "DWG Export Method";
      : radio_column {
        : radio_button {
          key = "export_method_vla";
          label = "ActiveX/VLA Method (Recommended - Most Stable)";
          value = "1";
        }
        : radio_button {
          key = "export_method_script";
          label = "Script Method (May crash on some systems)";
          value = "0";
        }
        : radio_button {
          key = "export_method_direct";
          label = "Direct WBLOCK (May crash on some systems)";
          value = "0";
        }
      }
      : text {
        label = "(VLA method creates DWG files directly without WBLOCK)";
        width = 50;
      }
    }
    
    : row {
      : text {
        label = "CSV File:";
        edit_width = 40;
        edit_limit = 256;
        key = "export_csv_display";
      }
      : button {
        label = "Browse...";
        key = "export_csv_browse";
        width = 10;
      }
    }
    
    : row {
      : button {
        label = "► START EXPORT (CSV + DWG)";
        key = "export_start";
        width = 40;
      }
    }
  }
  
  : boxed_column {
    label = "IMPORT - Import Blocks from CSV + DWG Library";
    fixed_width = true;
    
    // Block Library Path - EDITABLE
    : row {
      : edit_box {
        label = "Block Library Folder:";
        edit_width = 45;
        edit_limit = 256;
        key = "import_block_library";
      }
      : button {
        label = "Browse...";
        key = "import_block_library_browse";
        width = 10;
      }
    }
    
    : row {
      : text {
        label = "CSV File:";
        edit_width = 40;
        edit_limit = 256;
        key = "import_csv_display";
      }
      : button {
        label = "Browse...";
        key = "import_csv_browse";
        width = 10;
      }
    }
    
    // Preview Section
    : boxed_column {
      label = "Import Preview";
      : text {
        key = "preview_status";
        label = "Select a CSV file to preview blocks";
        width = 50;
      }
      : list_box {
        key = "preview_list";
        label = "Blocks to be imported:";
        width = 50;
        height = 8;
        multiple_select = false;
      }
    }
    
    : row {
      : button {
        label = "► PREVIEW CSV";
        key = "import_preview";
        width = 18;
      }
      : button {
        label = "► START IMPORT";
        key = "import_start";
        width = 18;
      }
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // Standard OK/Cancel buttons
  // ═══════════════════════════════════════════════════════════
  : row {
    : button {
      label = "Close";
      key = "accept";
      width = 10;
      is_default = true;
      fixed_width = true;
    }
    : button {
      label = "Cancel";
      key = "cancel";
      width = 10;
      is_cancel = true;
      fixed_width = true;
    }
  }
}
