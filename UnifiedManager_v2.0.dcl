// ═══════════════════════════════════════════════════════════════════════════
// UNIFIED CIRCUIT & BLOCK MANAGER v2.0 DCL
// Complete solution for Blocks + Circuits Export/Import
// ═══════════════════════════════════════════════════════════════════════════

ucbmanager : dialog {
  label = "Unified Circuit & Block Manager v2.0";
  initial_focus = "operation_mode";
  
  : row {
    fixed_width = true;
    alignment = centered;
    
    : column {
      width = 55;
      
      // ═══════════════════════════════════════════════════════════════
      // OPERATION MODE SELECTION
      // ═══════════════════════════════════════════════════════════════
      
      : boxed_radio_row {
        label = "Operation Mode";
        key = "operation_mode";
        fixed_width = true;
        
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
      
      : spacer { height = 0.5; }
      
      // ═══════════════════════════════════════════════════════════════
      // CONTENT TYPE SELECTION
      // ═══════════════════════════════════════════════════════════════
      
      : boxed_radio_row {
        label = "Content Type";
        key = "content_type";
        fixed_width = true;
        
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
      
      : spacer { height = 0.5; }
      
      // ═══════════════════════════════════════════════════════════════
      // LIBRARY FOLDER SECTION
      // ═══════════════════════════════════════════════════════════════
      
      : boxed_column {
        label = "Library Configuration";
        fixed_width = true;
        
        : row {
          : text_part {
            label = "Library Folder:";
            width = 15;
          }
        }
        
        : row {
          : edit_box {
            key = "library_folder";
            edit_width = 38;
            fixed_width = true;
          }
          : button {
            key = "btn_browse_folder";
            label = "Browse...";
            fixed_width = true;
            width = 10;
          }
        }
      }
      
      : spacer { height = 0.5; }
      
      // ═══════════════════════════════════════════════════════════════
      // EXPORT PANEL
      // ═══════════════════════════════════════════════════════════════
      
      : boxed_column {
        label = "EXPORT Settings";
        key = "export_panel";
        fixed_width = true;
        
        : text {
          label = "Selection Mode:";
          alignment = left;
        }
        
        : radio_column {
          key = "export_selection_mode";
          
          : radio_button {
            key = "export_single";
            label = "Single Item (Select one block/circuit)";
            value = "1";
          }
          
          : radio_button {
            key = "export_batch";
            label = "Batch Mode (Select multiple)";
          }
          
          : radio_button {
            key = "export_all";
            label = "Export All (All blocks in drawing)";
          }
        }
        
        : spacer { height = 0.3; }
        
        : text {
          label = "Export Method (for Blocks):";
          alignment = left;
        }
        
        : popup_list {
          key = "export_method";
          width = 45;
          fixed_width = true;
        }
        
        : spacer { height = 0.3; }
        
        : row {
          : text_part {
            label = "Category/Type:";
            width = 15;
          }
          : popup_list {
            key = "export_category";
            width = 28;
            fixed_width = true;
          }
        }
        
        : spacer { height = 0.3; }
        
        : row {
          : toggle {
            key = "export_save_csv";
            label = "Save coordinates to CSV file";
            value = "1";
          }
        }
        
        : row {
          : toggle {
            key = "export_create_preview";
            label = "Create preview image (PNG)";
          }
        }
        
        : spacer { height = 0.5; }
        
        : button {
          key = "btn_start_export";
          label = "▶ START EXPORT";
          fixed_width = true;
          width = 35;
          alignment = centered;
        }
      }
      
      : spacer { height = 0.5; }
      
      // ═══════════════════════════════════════════════════════════════
      // IMPORT PANEL
      // ═══════════════════════════════════════════════════════════════
      
      : boxed_column {
        label = "IMPORT Settings";
        key = "import_panel";
        fixed_width = true;
        
        : text {
          label = "Source Selection:";
          alignment = left;
        }
        
        : radio_column {
          key = "import_source_mode";
          
          : radio_button {
            key = "import_from_library";
            label = "Import from Library (Browse list)";
            value = "1";
          }
          
          : radio_button {
            key = "import_from_csv";
            label = "Import from CSV (Use saved coordinates)";
          }
          
          : radio_button {
            key = "import_manual";
            label = "Manual Selection (Pick DWG file)";
          }
        }
        
        : spacer { height = 0.3; }
        
        : text {
          label = "Available Items:";
          alignment = left;
        }
        
        : list_box {
          key = "import_list";
          height = 8;
          width = 50;
          fixed_width = true;
          fixed_height = true;
          multiple_select = true;
          allow_accept = true;
        }
        
        : row {
          : button {
            key = "btn_refresh_list";
            label = "Refresh";
            fixed_width = true;
            width = 12;
          }
          : button {
            key = "btn_preview_item";
            label = "Preview";
            fixed_width = true;
            width = 12;
          }
          : button {
            key = "btn_load_csv";
            label = "📄 Load CSV";
            fixed_width = true;
            width = 12;
          }
        }
        
        : spacer { height = 0.3; }
        
        : text {
          label = "Import Options:";
          alignment = left;
        }
        
        : row {
          : column {
            : row {
              : text_part {
                label = "Scale:";
                width = 8;
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
                label = "Rotation:";
                width = 8;
              }
              : edit_box {
                key = "import_rotation";
                edit_width = 10;
                fixed_width = true;
                value = "0";
              }
            }
          }
          
          : column {
            : toggle {
              key = "import_explode";
              label = "Explode on import";
            }
            : toggle {
              key = "import_use_csv_coords";
              label = "Use CSV coordinates";
            }
          }
        }
        
        : spacer { height = 0.3; }
        
        : text {
          label = "Import Method (for Blocks):";
          alignment = left;
        }
        
        : popup_list {
          key = "import_method";
          width = 45;
          fixed_width = true;
        }
        
        : spacer { height = 0.5; }
        
        : button {
          key = "btn_start_import";
          label = "▶ START IMPORT";
          fixed_width = true;
          width = 35;
          alignment = centered;
        }
      }
    }
  }
  
  : spacer { height = 0.3; }
  
  // ═══════════════════════════════════════════════════════════════════
  // STATUS AND PROGRESS
  // ═══════════════════════════════════════════════════════════════════
  
  : boxed_column {
    label = "Status & Progress";
    fixed_width = true;
    
    : text {
      key = "status_text";
      label = "Ready - Select operation mode and content type";
      width = 50;
      alignment = left;
    }
    
    : text {
      key = "progress_text";
      label = "";
      width = 50;
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
      label = "❓ Help";
      fixed_width = true;
      width = 12;
    }
    
    : button {
      key = "btn_open_folder";
      label = "📁 Open Library";
      fixed_width = true;
      width = 14;
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
