// ═══════════════════════════════════════════════════════════════════════════
// XREF MACRO MANAGER - DIALOG DEFINITION
// Version 1.0 - Complete Export/Import Interface
// ═══════════════════════════════════════════════════════════════════════════

xrefmm : dialog {
    label = "XREF Macro Manager - Export/Import Blocks";
    key = "main_dialog";
    
    // ═══════════════════════════════════════════════════════════════════════
    // HEADER WITH VERSION
    // ═══════════════════════════════════════════════════════════════════════
    
    : boxed_column {
        label = "XREF Macro Manager v1.0";
        
        : text {
            key = "version";
            label = "Version 1.0 - Crash-Free Export/Import";
            alignment = centered;
        }
        
        : text {
            label = "Safe alternative to INSERT command (no Exception c0000027)";
            alignment = centered;
        }
    }
    
    : spacer { height = 1; }
    
    // ═══════════════════════════════════════════════════════════════════════
    // EXPORT SECTION
    // ═══════════════════════════════════════════════════════════════════════
    
    : boxed_column {
        label = "EXPORT - Create Block Library + CSV";
        
        : text {
            label = "Export blocks from current drawing to DWG files + CSV coordinates";
            alignment = left;
        }
        
        : spacer { height = 0.5; }
        
        : row {
            : button {
                key = "select_blocks";
                label = "1. Select Blocks";
                width = 25;
                fixed_width = true;
                mnemonic = "S";
            }
            
            : text {
                label = "← Select blocks to export from drawing";
                alignment = left;
            }
        }
        
        : spacer { height = 0.5; }
        
        : row {
            : button {
                key = "export_blocks";
                label = "2. Export Blocks";
                width = 25;
                fixed_width = true;
                mnemonic = "E";
            }
            
            : text {
                label = "← Create CSV + export instructions";
                alignment = left;
            }
        }
        
        : spacer { height = 0.5; }
        
        : text {
            label = "Export Method: Fully Automated (ObjectDBX, no user interaction)";
            alignment = left;
        }
        
        : text {
            label = "CSV Format: Block Name, X, Y, Z, Type, Color, Linetype";
            alignment = left;
        }
    }
    
    : spacer { height = 1; }
    
    // ═══════════════════════════════════════════════════════════════════════
    // IMPORT SECTION
    // ═══════════════════════════════════════════════════════════════════════
    
    : boxed_column {
        label = "IMPORT - Load Blocks from CSV";
        
        : text {
            label = "Import blocks at exact coordinates using XREF method (no crashes)";
            alignment = left;
        }
        
        : spacer { height = 0.5; }
        
        : row {
            : button {
                key = "import_blocks";
                label = "3. Import Blocks";
                width = 25;
                fixed_width = true;
                mnemonic = "I";
            }
            
            : text {
                label = "← Select CSV → Attach XREFs at coordinates";
                alignment = left;
            }
        }
        
        : spacer { height = 0.5; }
        
        : text {
            label = "Import Method: XREF attach (safe, no INSERT command)";
            alignment = left;
        }
        
        : text {
            label = "Execution Time: 5-10 minutes for 300+ blocks";
            alignment = left;
        }
    }
    
    : spacer { height = 1; }
    
    // ═══════════════════════════════════════════════════════════════════════
    // UTILITIES SECTION
    // ═══════════════════════════════════════════════════════════════════════
    
    : boxed_column {
        label = "UTILITIES - Verify & Convert";
        
        : row {
            : button {
                key = "verify_coords";
                label = "Verify Coordinates";
                width = 25;
                fixed_width = true;
                mnemonic = "V";
            }
            
            : text {
                label = "← Check if imported blocks match CSV";
                alignment = left;
            }
        }
        
        : spacer { height = 0.5; }
        
        : row {
            : button {
                key = "bind_xrefs";
                label = "Bind XREFs";
                width = 25;
                fixed_width = true;
                mnemonic = "B";
            }
            
            : text {
                label = "← Convert XREFs to permanent blocks";
                alignment = left;
            }
        }
    }
    
    : spacer { height = 1; }
    
    // ═══════════════════════════════════════════════════════════════════════
    // WORKFLOW HELP
    // ═══════════════════════════════════════════════════════════════════════
    
    : boxed_column {
        label = "WORKFLOW";
        
        : text {
            label = "EXPORT: Select Blocks → Export Blocks → Automatic DWG creation (5 min)";
            alignment = left;
        }
        
        : text {
            label = "IMPORT: Import Blocks → Select CSV & Folder → Run Script → Verify → Bind";
            alignment = left;
        }
    }
    
    : spacer { height = 1; }
    
    // ═══════════════════════════════════════════════════════════════════════
    // DIALOG BUTTONS
    // ═══════════════════════════════════════════════════════════════════════
    
    : row {
        fixed_width = true;
        alignment = centered;
        
        : button {
            key = "cancel";
            label = "Close";
            width = 15;
            fixed_width = true;
            is_cancel = true;
            mnemonic = "C";
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// END OF DIALOG DEFINITION
// ═══════════════════════════════════════════════════════════════════════════
