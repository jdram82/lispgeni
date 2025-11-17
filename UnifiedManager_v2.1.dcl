// ===========================================================================
// UNIFIED CIRCUIT & BLOCK MANAGER v2.1 DCL
// ===========================================================================

ucbmanager : dialog {
  label = "Unified Circuit & Block Manager v2.1";
  
  // Operation Mode
  : boxed_row {
    label = "Operation Mode";
    : radio_row {
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
  
  : spacer { height = 0.5; }
  
  // Content Type
  : boxed_row {
    label = "Content Type";
    : radio_row {
      key = "content_type";
      : radio_button {
        key = "type_blocks";
        label = "Block Definitions";
        value = "1";
      }
      : radio_button {
        key = "type_circuits";
        label = "Circuit Assemblies";
      }
    }
  }
  
  : spacer { height = 0.5; }
  
  // Library Folder
  : boxed_column {
    label = "Library Configuration";
    : row {
      : text {
        label = "Library Folder:";
      }
    }
    : row {
      : edit_box {
        key = "library_folder";
        width = 40;
      }
      : button {
        key = "btn_browse_folder";
        label = "Browse...";
        width = 10;
      }
    }
  }
  
  : spacer { height = 0.5; }
  
  // Export Panel
  : boxed_column {
    label = "EXPORT Settings";
    key = "export_panel";
    
    : text {
      label = "Selection Mode:";
    }
    
    : radio_column {
      key = "export_selection_mode";
      : radio_button {
        key = "export_single";
        label = "Single Item";
        value = "1";
      }
      : radio_button {
        key = "export_batch";
        label = "Batch Mode";
      }
      : radio_button {
        key = "export_all";
        label = "Export All";
      }
    }
    
    : spacer { height = 0.3; }
    
    : text {
      label = "Export Method:";
    }
    : popup_list {
      key = "export_method";
      width = 40;
    }
    
    : spacer { height = 0.3; }
    
    : row {
      : text {
        label = "Category:";
      }
      : popup_list {
        key = "export_category";
        width = 25;
      }
    }
    
    : spacer { height = 0.5; }
    
    : button {
      key = "btn_start_export";
      label = "START EXPORT";
      width = 30;
    }
  }
  
  : spacer { height = 0.5; }
  
  // Import Panel
  : boxed_column {
    label = "IMPORT Settings";
    key = "import_panel";
    
    : text {
      label = "Source Selection:";
    }
    
    : radio_column {
      key = "import_source_mode";
      : radio_button {
        key = "import_from_library";
        label = "Import from Library";
        value = "1";
      }
      : radio_button {
        key = "import_from_csv";
        label = "Import from CSV";
      }
      : radio_button {
        key = "import_manual";
        label = "Manual Selection";
      }
    }
    
    : spacer { height = 0.3; }
    
    : text {
      label = "Available Items:";
    }
    
    : list_box {
      key = "import_list";
      height = 8;
      width = 45;
      multiple_select = true;
    }
    
    : row {
      : button {
        key = "btn_refresh_list";
        label = "Refresh";
        width = 10;
      }
      : button {
        key = "btn_load_csv";
        label = "Load CSV";
        width = 10;
      }
    }
    
    : spacer { height = 0.3; }
    
    : text {
      label = "Import Options:";
    }
    
    : row {
      : text {
        label = "Scale:";
      }
      : edit_box {
        key = "import_scale";
        value = "1.0";
        width = 8;
      }
      : text {
        label = "  Rotation:";
      }
      : edit_box {
        key = "import_rotation";
        value = "0";
        width = 8;
      }
    }
    
    : spacer { height = 0.3; }
    
    : text {
      label = "Import Method:";
    }
    : popup_list {
      key = "import_method";
      width = 40;
    }
    
    : spacer { height = 0.5; }
    
    : button {
      key = "btn_start_import";
      label = "START IMPORT";
      width = 30;
    }
  }
  
  : spacer { height = 0.3; }
  
  // Status
  : boxed_column {
    label = "Status";
    : text {
      key = "status_text";
      label = "Ready";
      width = 45;
    }
    : text {
      key = "progress_text";
      label = "";
      width = 45;
    }
  }
  
  : spacer { height = 0.3; }
  
  // Bottom Buttons
  : row {
    : button {
      key = "accept";
      label = "Close";
      is_default = true;
      width = 10;
    }
    : button {
      key = "cancel";
      label = "Cancel";
      is_cancel = true;
      width = 10;
    }
  }
}
