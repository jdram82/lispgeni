// ===========================================================================
// UNIFIED CIRCUIT & BLOCK MANAGER v2.4 DCL
// ===========================================================================

ucbmanager : dialog {
  label = "Unified Manager v2.4 - Circuit & Block Export/Import";
  initial_focus = "btn_step1";
  
  // Compact header row with mode and type
  : row {
    : boxed_column {
      label = "Mode";
      width = 22;
      : radio_column {
        key = "operation_mode";
        : radio_button {
          key = "mode_export";
          label = "Export";
          value = "1";
        }
        : radio_button {
          key = "mode_import";
          label = "Import";
        }
      }
    }
    
    : boxed_column {
      label = "Content Type";
      width = 22;
      : radio_column {
        key = "content_type";
        : radio_button {
          key = "type_blocks";
          label = "Blocks";
          value = "1";
        }
        : radio_button {
          key = "type_circuits";
          label = "Circuits";
        }
      }
    }
  }
  
  : spacer { height = 0.3; }
  
  // Compact library folder row
  : row {
    : text {
      label = "Library:";
      width = 8;
    }
    : edit_box {
      key = "library_folder";
      width = 30;
    }
    : button {
      key = "btn_browse_folder";
      label = "...";
      width = 3;
      fixed_width = true;
    }
  }
  
  : spacer { height = 0.3; }
  
  // Export Panel - Compact and visual
  : boxed_column {
    label = "▼ EXPORT Workflow";
    key = "export_panel";
    
    // Compact settings row
    : row {
      : column {
        width = 20;
        : text {
          label = "Category:";
        }
        : popup_list {
          key = "export_category";
          width = 18;
        }
      }
      : column {
        width = 22;
        : text {
          label = "Method:";
        }
        : popup_list {
          key = "export_method";
          width = 20;
        }
      }
    }
    
    : spacer { height = 0.2; }
    
    // Visual step workflow with icons
    : boxed_column {
      label = "› Quick Export Steps";
      
      : button {
        key = "btn_step1";
        label = "① SELECT Entities";
        width = 42;
      }
      
      : text {
        key = "txt_selection_count";
        label = "No entities selected";
        alignment = centered;
      }
      
      : spacer { height = 0.2; }
      
      : row {
        : text {
          label = "② Name:";
          width = 8;
        }
        : edit_box {
          key = "export_name";
          width = 32;
          edit_width = 30;
        }
      }
      
      : spacer { height = 0.2; }
      
      : button {
        key = "btn_step3";
        label = "③ PICK Base Point";
        width = 42;
      }
      
      : spacer { height = 0.2; }
      
      : row {
        : text {
          label = "④ CSV File:";
          width = 10;
        }
        : button {
          key = "btn_browse_csv";
          label = "Browse...";
          width = 12;
        }
        : text {
          key = "txt_csv_path";
          label = "(Default)";
          width = 18;
        }
      }
      
      : spacer { height = 0.2; }
      
      : text {
        key = "txt_export_status";
        label = "⚡ Ready to start";
        alignment = centered;
      }
      
      : button {
        key = "btn_complete_export";
        label = "✓ COMPLETE EXPORT";
        width = 42;
        is_default = true;
      }
    }
  }
  
  : spacer { height = 0.3; }
  
  // Import Panel - Compact
  : boxed_column {
    label = "▼ IMPORT Workflow";
    key = "import_panel";
    
    : row {
      : text {
        label = "Import From:";
        width = 10;
      }
      : edit_box {
        key = "import_folder";
        width = 27;
      }
      : button {
        key = "btn_browse_import_folder";
        label = "...";
        width = 3;
        fixed_width = true;
      }
    }
    
    : spacer { height = 0.2; }
    
    : list_box {
      key = "import_list";
      height = 6;
      width = 42;
      multiple_select = true;
    }
    
    : row {
      : button {
        key = "btn_refresh_list";
        label = "↻ Refresh";
        width = 10;
      }
      : button {
        key = "btn_load_csv";
        label = "📄 CSV";
        width = 10;
      }
      : popup_list {
        key = "import_method";
        width = 18;
      }
    }
    
    : row {
      : text {
        label = "Scale:";
        width = 6;
      }
      : edit_box {
        key = "import_scale";
        value = "1.0";
        width = 6;
      }
      : text {
        label = "Rotate:";
        width = 6;
      }
      : edit_box {
        key = "import_rotation";
        value = "0";
        width = 6;
      }
      : button {
        key = "btn_start_import";
        label = "▶ IMPORT";
        width = 12;
      }
    }
  }
  
  : spacer { height = 0.2; }
  
  // Compact status bar
  : row {
    : text {
      key = "status_text";
      label = "Ready";
      width = 32;
    }
    : button {
      key = "accept";
      label = "✓ Close";
      width = 8;
    }
  }
}
