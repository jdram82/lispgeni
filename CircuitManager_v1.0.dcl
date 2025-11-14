// ═══════════════════════════════════════════════════════════════════════════
// CIRCUIT MANAGER v1.0 DCL
// Professional UI for Circuit Export/Import
// ═══════════════════════════════════════════════════════════════════════════

circuitmanager : dialog {
  label = "Circuit Manager v1.0 - Export/Import Drawing Sections";
  initial_focus = "mode_tabs";
  
  : row {
    fixed_width = true;
    alignment = centered;
    
    : column {
      width = 50;
      
      // ═══════════════════════════════════════════════════════════════
      // MODE SELECTION TABS
      // ═══════════════════════════════════════════════════════════════
      
      : boxed_radio_column {
        label = "Operation Mode";
        key = "mode_tabs";
        fixed_width = true;
        
        : radio_button {
          key = "mode_export";
          label = "Export Circuit (Save Section)";
          value = "1";
        }
        
        : radio_button {
          key = "mode_import";
          label = "Import Circuit (Load Section)";
        }
      }
      
      : spacer { height = 0.5; }
      
      // ═══════════════════════════════════════════════════════════════
      // EXPORT SECTION
      // ═══════════════════════════════════════════════════════════════
      
      : boxed_column {
        label = "EXPORT - Save Drawing Section";
        key = "export_panel";
        fixed_width = true;
        
        : row {
          : text_part {
            label = "Circuit Library Folder:";
            width = 20;
          }
        }
        
        : row {
          : edit_box {
            key = "export_folder";
            edit_width = 35;
            fixed_width = true;
          }
          : button {
            key = "btn_browse_export";
            label = "Browse...";
            fixed_width = true;
            width = 10;
          }
        }
        
        : spacer { height = 0.3; }
        
        : text {
          label = "Export Mode:";
          alignment = left;
        }
        
        : radio_column {
          key = "export_mode";
          fixed_width = true;
          
          : radio_button {
            key = "export_single";
            label = "Single Circuit Export (Select entities)";
            value = "1";
          }
          
          : radio_button {
            key = "export_batch";
            label = "Batch Mode (Multiple circuits)";
          }
        }
        
        : spacer { height = 0.3; }
        
        : text {
          label = "Circuit Information:";
          alignment = left;
        }
        
        : row {
          : text_part {
            label = "Circuit Name:";
            width = 12;
          }
          : edit_box {
            key = "circuit_name";
            edit_width = 30;
            fixed_width = true;
          }
        }
        
        : row {
          : text_part {
            label = "Type/Category:";
            width = 12;
          }
          : popup_list {
            key = "circuit_type";
            width = 30;
            fixed_width = true;
          }
        }
        
        : spacer { height = 0.5; }
        
        : button {
          key = "btn_start_export";
          label = "▶ START EXPORT";
          fixed_width = true;
          width = 30;
          alignment = centered;
        }
      }
      
      : spacer { height = 0.5; }
      
      // ═══════════════════════════════════════════════════════════════
      // IMPORT SECTION
      // ═══════════════════════════════════════════════════════════════
      
      : boxed_column {
        label = "IMPORT - Load Circuit into Drawing";
        key = "import_panel";
        fixed_width = true;
        
        : row {
          : text_part {
            label = "Circuit Library Folder:";
            width = 20;
          }
        }
        
        : row {
          : edit_box {
            key = "import_folder";
            edit_width = 35;
            fixed_width = true;
          }
          : button {
            key = "btn_browse_import";
            label = "Browse...";
            fixed_width = true;
            width = 10;
          }
        }
        
        : spacer { height = 0.3; }
        
        : text {
          label = "Available Circuits:";
          alignment = left;
        }
        
        : list_box {
          key = "circuit_list";
          height = 8;
          width = 45;
          fixed_width = true;
          fixed_height = true;
          multiple_select = false;
        }
        
        : row {
          : button {
            key = "btn_refresh";
            label = "↻ Refresh List";
            fixed_width = true;
            width = 15;
          }
          : button {
            key = "btn_preview";
            label = "👁 Preview";
            fixed_width = true;
            width = 15;
          }
        }
        
        : spacer { height = 0.3; }
        
        : text {
          label = "Import Options:";
          alignment = left;
        }
        
        : row {
          : text_part {
            label = "Scale Factor:";
            width = 12;
          }
          : edit_box {
            key = "import_scale";
            edit_width = 10;
            fixed_width = true;
            value = "1.0";
          }
        }
        
        : row {
          : text_part {
            label = "Rotation (deg):";
            width = 12;
          }
          : edit_box {
            key = "import_rotation";
            edit_width = 10;
            fixed_width = true;
            value = "0";
          }
        }
        
        : row {
          : toggle {
            key = "import_explode";
            label = "Explode on import (break into individual entities)";
          }
        }
        
        : spacer { height = 0.5; }
        
        : button {
          key = "btn_start_import";
          label = "▶ START IMPORT";
          fixed_width = true;
          width = 30;
          alignment = centered;
        }
      }
    }
  }
  
  : spacer { height = 0.3; }
  
  // ═══════════════════════════════════════════════════════════════════
  // STATUS BAR
  // ═══════════════════════════════════════════════════════════════════
  
  : boxed_row {
    label = "Status";
    fixed_width = true;
    alignment = centered;
    
    : text {
      key = "status_text";
      label = "Ready - Select operation mode";
      width = 45;
      alignment = left;
    }
  }
  
  : spacer { height = 0.3; }
  
  // ═══════════════════════════════════════════════════════════════════
  // BOTTOM BUTTONS
  // ═══════════════════════════════════════════════════════════════════
  
  : row {
    fixed_width = true;
    alignment = centered;
    
    : button {
      key = "btn_help";
      label = "Help";
      fixed_width = true;
      width = 10;
    }
    
    : spacer { width = 1; }
    
    : button {
      key = "accept";
      label = "Close";
      is_default = true;
      fixed_width = true;
      width = 10;
    }
    
    : button {
      key = "cancel";
      label = "Cancel";
      is_cancel = true;
      fixed_width = true;
      width = 10;
    }
  }
}
