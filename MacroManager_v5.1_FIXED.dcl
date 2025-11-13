// ═══════════════════════════════════════════════════════════════════════════
// PROFESSIONAL MACRO MANAGER v5.1 - FIXED DCL
// Unified Import/Export Macro Manager with Selection Modes
// ═══════════════════════════════════════════════════════════════════════════
// FIXES:
//   - Changed button keys from "ok_btn"/"cancel_btn" to "accept"/"cancel"
//   - Added is_default and is_cancel attributes
//   - Dialog now closes properly
// ═══════════════════════════════════════════════════════════════════════════

UnifiedMacroDialog : dialog {
  label = "Professional Macro Manager v5.1 - FIXED";
  initial_focus = "export_mode_single";
  
  : boxed_column {
    label = "EXPORT - Select and Export Blocks to CSV";
    fixed_width = true;
    
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
        label = "► START EXPORT";
        key = "export_start";
        width = 40;
      }
    }
  }
  
  : boxed_column {
    label = "IMPORT - Import Blocks from CSV File";
    fixed_width = true;
    
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
  // FIXED: Standard OK/Cancel buttons with proper keys
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
