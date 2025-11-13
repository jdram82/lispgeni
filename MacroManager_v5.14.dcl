// ═══════════════════════════════════════════════════════════════════════════
// PROFESSIONAL MACRO MANAGER v5.14 DCL
// With XREF Import Method (CRASH-FREE!)
// ═══════════════════════════════════════════════════════════════════════════
// NEW in v5.14:
//   - XREF import method (no INSERT crashes - Exception c0000027 fixed)
//   - Script-based import using -XREF attach instead of INSERT
//   - Automatic script generation and execution
//   - Detach existing XREFs before re-attaching (handles duplicates)
//   - Export function unchanged (working perfectly)
//   - Based on working XrefMacroManager v1.7 code
// ═══════════════════════════════════════════════════════════════════════════

macromanager : dialog {
  label = "Professional Macro Manager v5.14 - XREF Import";
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
          key = "export_method_script";
          label = "Script Method (RECOMMENDED - Most Reliable)";
          value = "1";
        }
        : radio_button {
          key = "export_method_vla";
          label = "ActiveX/VLA Method (Experimental - May not work)";
          value = "0";
        }
        : radio_button {
          key = "export_method_direct";
          label = "Direct WBLOCK (May crash)";
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
    
    : row {
      : button {
        label = "▶ RUN EXPORT SCRIPT";
        key = "run_export_script";
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
