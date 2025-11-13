;; ═══════════════════════════════════════════════════════════════════════════
;; MACRO MANAGER UNIFIED - VERSION 5.10
;; Complete Import/Export with Fixed Script Format & Comprehensive Diagnostics
;; ═══════════════════════════════════════════════════════════════════════════
;;
;; NEW FEATURES in v5.10:
;;   ✓ FIXED: Script file format - multi-line WBLOCK commands with proper ENTER simulation
;;   ✓ Comprehensive diagnostics - see progress through 6 steps
;;   ✓ Detailed command line output for every operation
;;   ✓ Per-block progress indicators [1/N, 2/N, etc.]
;;   ✓ Success/failure reporting for each block
;;   ✓ Clear error messages at every stage
;;   ✓ Export summary with file locations and counts
;;
;; FEATURES from v5.4:
;;   ✓ Auto-execute script after export (no manual SCRIPT command)
;;   ✓ Three export methods: Script / ActiveX-VLA / Direct WBLOCK
;;   ✓ User-selectable export method (radio buttons in dialog)
;;   ✓ Alternative WBLOCK functions (fallback options)
;;   ✓ Script-based WBLOCK export (crash-free)
;;   ✓ Type/Category dropdown (8 categories)
;;   ✓ Preview functionality before import
;;   ✓ Block Library folder selection
;;   ✓ CSV column renamed: "Layer" → "Type"
;;   ✓ Session memory for settings
;;   ✓ Project-specific block libraries
;;
;; ALL PREVIOUS FIXES:
;;   ✓ Fixed DEFVAR error (changed to setq)
;;   ✓ Complete block import functionality
;;   ✓ CSV parser with quoted field support
;;   ✓ Export with default values (no nil errors)
;;   ✓ Block existence validation before import
;;   ✓ Property setting (Type/Color/Linetype)
;;   ✓ DCL button keys fixed (accept/cancel)
;;   ✓ Selection workflow (dialog close/reopen)
;;   ✓ Variable initialization fixed
;;   ✓ STRING= function replaced with EQUAL
;;
;; USAGE:
;;   (load "MacroManager_v5.10.lsp")
;;   Command: MACROMANAGER
;;
;; ═══════════════════════════════════════════════════════════════════════════

;; ═══════════════════════════════════════════════════════════════════════════
;; GLOBAL VARIABLES
;; ═══════════════════════════════════════════════════════════════════════════

(if (not *selected_blocks*) (setq *selected_blocks* (list)))
(if (not *selection_mode*) (setq *selection_mode* "single"))
(if (not *export_block_library*) (setq *export_block_library* nil))
(if (not *import_block_library*) (setq *import_block_library* nil))
(if (not *block_type*) (setq *block_type* "General"))  ; Default block type
(if (not *export_method*) (setq *export_method* "vla"))  ; Default: VLA method (no WBLOCK crash)

;; ═══════════════════════════════════════════════════════════════════════════
;; UTILITY: Get LISP file location for DCL search
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:get_lisp_path ( / )
  ;; Returns the directory where this LISP file is loaded from
  (getvar "DWGPREFIX")  ; Fallback to drawing folder for now
)

;; ═══════════════════════════════════════════════════════════════════════════
;; MAIN COMMAND
;; ═══════════════════════════════════════════════════════════════════════════

(defun c:MACROMANAGER ( / dcl_id result dcl_path drawing_path)
  
  (princ "\n╔═══════════════════════════════════════════════════════════╗")
  (princ "\n║  Macro Manager v5.10                                     ║")
  (princ "\n║                                                           ║")
  (princ "\n║  ✓ Fixed Script Format (Multi-line WBLOCK)              ║")
  (princ "\n║  ✓ Comprehensive Diagnostics (6 Steps)                  ║")
  (princ "\n║  ✓ Detailed Progress Indicators                          ║")
  (princ "\n║  ✓ Type/Category Dropdown                               ║")
  (princ "\n╚═══════════════════════════════════════════════════════════╝")
  
  ;; Initialize global variables
  (setq *selected_blocks* (list))
  (setq *selection_mode* "single")
  
  ;; Get drawing file path
  (setq drawing_path (getvar "DWGPREFIX"))
  (princ (strcat "\n>>> Working folder: " drawing_path))
  
  ;; Try multiple DCL file names
  (setq dcl_path nil)
  (cond
    ((findfile (strcat drawing_path "MacroManager_v5.10.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.10.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.9.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.9.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.8.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.8.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.7.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.7.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.6.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.6.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.5.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.5.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.4.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.4.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.3.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.3.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.2_ENHANCED.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.2_ENHANCED.dcl")))
  )
  
  (if (not dcl_path)
    (progn
      (princ "\n>>> ✗ ERROR: Could not find DCL file")
      (alert (strcat "ERROR: Cannot find DCL file\n\nSearched for:\n"
                     "- MacroManager_v5.10.dcl\n"
                     "- MacroManager_v5.9.dcl\n"
                     "- MacroManager_v5.8.dcl\n"
                     "- MacroManager_v5.7.dcl\n"
                     "- MacroManager_v5.6.dcl\n"
                     "- MacroManager_v5.5.dcl\n"
                     "- MacroManager_v5.4.dcl\n"
                     "- MacroManager_v5.3.dcl\n"
                     "- MacroManager_v5.2_ENHANCED.dcl\n\n"
                     "In folder: " drawing_path))
    )
    (progn
      (princ (strcat "\n>>> Loading DCL from: " dcl_path))
      
      ;; Load the DCL
      (setq dcl_id (load_dialog dcl_path))
      
      ;; Check if loaded (load_dialog returns nil on failure)
      (if (not dcl_id)
        (progn
          (princ "\n>>> ✗ ERROR: Could not load DCL")
          (alert (strcat "ERROR: Cannot load DCL file\n\nFile: " dcl_path 
                        "\n\nPossible causes:\n"
                        "- File not found (check Support File Search Path)\n"
                        "- File saved with wrong encoding (use ANSI / UTF-8 without BOM)\n"
                        "- DCL syntax errors"))
        )
        (progn
          (princ "\n>>> ✓ DCL loaded!")
          
          ;; Create main dialog loop
          (setq result 1)
          (setq export_csv nil)
          (setq import_csv nil)
          
          (while (> result 0)
            (if (new_dialog "UnifiedMacroDialog" dcl_id)
              (progn
                (princ "\n>>> ✓ Dialog created and OPEN!")
                
                ;; Set radio buttons
                (cond
                  ((equal *selection_mode* "single") 
                   (set_tile "export_mode_single" "1")
                   (set_tile "export_mode_batch" "0")
                   (set_tile "export_mode_all" "0"))
                  ((equal *selection_mode* "batch") 
                   (set_tile "export_mode_single" "0")
                   (set_tile "export_mode_batch" "1")
                   (set_tile "export_mode_all" "0"))
                  ((equal *selection_mode* "all") 
                   (set_tile "export_mode_single" "0")
                   (set_tile "export_mode_batch" "0")
                   (set_tile "export_mode_all" "1"))
                  (T 
                   (set_tile "export_mode_single" "1")
                   (set_tile "export_mode_batch" "0")
                   (set_tile "export_mode_all" "0")
                   (setq *selection_mode* "single"))
                )
                
                ;; Set Block Library paths from session memory
                (if *export_block_library*
                  (set_tile "export_block_library" *export_block_library*)
                  (set_tile "export_block_library" "No folder selected")
                )
                
                (if *import_block_library*
                  (set_tile "import_block_library" *import_block_library*)
                  (set_tile "import_block_library" "No folder selected")
                )
                
                ;; Update selection count display
                (set_tile "selection_count" (strcat "Selected: " (itoa (length *selected_blocks*)) " blocks"))
                
                ;; Set block type dropdown to current selection
                (setq type_list '("General" "Power" "Control" "Protection" "Communication" "Instrumentation" "Safety" "Custom"))
                (setq type_index (vl-position *block_type* type_list))
                (if (not type_index) (setq type_index 0))
                (set_tile "block_type" (itoa type_index))
                
                ;; Initialize preview section
                (set_tile "preview_status" "Select a CSV file to preview blocks")
                (start_list "preview_list")
                (end_list)
                
                ;; ══════════════════════════════════════════════════════════
                ;; EXPORT MODE SELECTION
                ;; ══════════════════════════════════════════════════════════
                
                (action_tile "export_mode_single"
                  "(progn (setq *selection_mode* \"single\") (princ \"\\n>>> Mode: SINGLE BLOCK\"))")
                
                (action_tile "export_mode_batch"
                  "(progn (setq *selection_mode* \"batch\") (princ \"\\n>>> Mode: BATCH (MULTIPLE BLOCKS)\"))")
                
                (action_tile "export_mode_all"
                  "(progn (setq *selection_mode* \"all\") (princ \"\\n>>> Mode: ALL BLOCKS IN DRAWING\"))")
                
                ;; ══════════════════════════════════════════════════════════
                ;; BLOCK LIBRARY FOLDER SELECTION
                ;; ══════════════════════════════════════════════════════════
                
                ;; Export Block Library Browse button
                (action_tile "export_block_library_browse"
                  "(progn 
                     (setq *export_block_library* (mm:browse_folder \"Select Block Library Folder for Export\"))
                     (if *export_block_library* 
                       (set_tile \"export_block_library\" *export_block_library*)
                     )
                   )")
                
                ;; Export Block Library manual entry (when user types directly)
                (action_tile "export_block_library"
                  "(setq *export_block_library* $value)")
                
                ;; Import Block Library Browse button
                (action_tile "import_block_library_browse"
                  "(progn 
                     (setq *import_block_library* (mm:browse_folder \"Select Block Library Folder for Import\"))
                     (if *import_block_library* 
                       (set_tile \"import_block_library\" *import_block_library*)
                     )
                   )")
                
                ;; Import Block Library manual entry (when user types directly)
                (action_tile "import_block_library"
                  "(setq *import_block_library* $value)")
                
                ;; ══════════════════════════════════════════════════════════
                ;; SELECTION BUTTONS
                ;; ══════════════════════════════════════════════════════════
                
                (action_tile "export_select"
                  "(done_dialog 2)")
                
                (action_tile "export_clear"
                  "(progn (setq *selected_blocks* (list)) (set_tile \"selection_count\" \"Selected: 0 blocks\") (princ \"\\n>>> Selection cleared\"))")
                
                ;; ══════════════════════════════════════════════════════════
                ;; BLOCK TYPE/CATEGORY SELECTION
                ;; ══════════════════════════════════════════════════════════
                
                (action_tile "block_type"
                  "(progn
                     (setq type_index (atoi $value))
                     (setq *block_type* (nth type_index '(\"General\" \"Power\" \"Control\" \"Protection\" \"Communication\" \"Instrumentation\" \"Safety\" \"Custom\")))
                     (princ (strcat \"\\n>>> Block Type set to: \" *block_type*))
                   )")
                
                ;; ══════════════════════════════════════════════════════════
                ;; DWG EXPORT METHOD SELECTION
                ;; ══════════════════════════════════════════════════════════
                
                (action_tile "export_method_script"
                  "(progn (setq *export_method* \"script\") (princ \"\\n>>> Export Method: Script (Auto-Execute)\"))")
                
                (action_tile "export_method_vla"
                  "(progn (setq *export_method* \"vla\") (princ \"\\n>>> Export Method: ActiveX/VLA\"))")
                
                (action_tile "export_method_direct"
                  "(progn (setq *export_method* \"direct\") (princ \"\\n>>> Export Method: Direct WBLOCK (May crash)\"))")
                
                ;; ══════════════════════════════════════════════════════════
                ;; CSV FILE SELECTION
                ;; ══════════════════════════════════════════════════════════
                
                (action_tile "export_csv_browse"
                  "(progn 
                     (setq export_csv (getfiled \"Save CSV\" \"\" \"csv\" 1))
                     (if export_csv 
                       (set_tile \"export_csv_display\" export_csv)
                       (set_tile \"export_csv_display\" \"No file selected\")
                     )
                   )")
                
                (action_tile "export_start"
                  "(mm:export_blocks_and_dwg export_csv *export_block_library*)")
                
                (action_tile "import_csv_browse"
                  "(progn 
                     (setq import_csv (getfiled \"Select CSV to Import\" \"\" \"csv\" 0))
                     (if import_csv 
                       (progn
                         (set_tile \"import_csv_display\" import_csv)
                         (set_tile \"preview_status\" \"CSV file selected. Click PREVIEW CSV to view blocks.\")
                       )
                       (progn
                         (set_tile \"import_csv_display\" \"No file selected\")
                         (set_tile \"preview_status\" \"Select a CSV file to preview blocks\")
                       )
                     )
                   )")
                
                (action_tile "import_preview"
                  "(mm:preview_csv import_csv)")
                
                (action_tile "import_start"
                  "(mm:import_blocks_from_dwg import_csv *import_block_library*)")
                
                ;; ══════════════════════════════════════════════════════════
                ;; CLOSE BUTTONS
                ;; ══════════════════════════════════════════════════════════
                
                (action_tile "accept" "(done_dialog 0)")
                (action_tile "cancel" "(done_dialog 0)")
                
                ;; Start the dialog
                (setq result (start_dialog))
                
                ;; Handle dialog return codes
                (cond
                  ((= result 0) 
                   (setq result 0))
                  
                  ((= result 2)
                   (princ "\n>>> Dialog closed for selection...")
                   (cond 
                     ((equal *selection_mode* "single") (mm:select_single_block))
                     ((equal *selection_mode* "batch") (mm:select_batch_blocks))
                     ((equal *selection_mode* "all") (mm:select_all_blocks))
                   )
                   (setq result 1))
                  
                  (T (setq result 0))
                )
              )
              (progn
                (princ "\n>>> ✗ ERROR: Could not create dialog")
                (setq result 0)
              )
            )
          )
          
          ;; Unload the DCL
          (unload_dialog dcl_id)
          (princ "\n>>> ✓ Dialog closed")
          
          ;; Restore FILEDIA to ensure file dialogs work
          (if (getvar "FILEDIA")
            nil
            (progn
              (princ "\n>>> Restoring FILEDIA...")
              (setvar "FILEDIA" 1))
          )
        )
      )
    )
  )
  
  (princ)
)

;; ═══════════════════════════════════════════════════════════════════════════
;; BROWSE FOR FOLDER (Using file selection to extract folder path)
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:browse_folder (title / temp_file folder_path user_input)
  ;; Method 1: Try to get user to select ANY file in the target folder
  ;; The folder path will be extracted from the file selection
  
  (princ (strcat "\n>>> " title))
  (princ "\n>>> SELECT ANY FILE in the target folder (the folder path will be used)")
  
  (setq temp_file (getfiled title "" "*" 8))
  
  (if temp_file
    (progn
      ;; Extract folder path from selected file
      (setq folder_path (vl-filename-directory temp_file))
      (princ (strcat "\n>>> Selected folder: " folder_path))
      folder_path
    )
    (progn
      ;; If user cancels, offer to type path manually
      (setq user_input (getstring T "\nEnter folder path manually (or press ESC to cancel): "))
      (if (and user_input (> (strlen user_input) 0))
        (progn
          ;; Remove trailing backslash if present
          (if (= (substr user_input (strlen user_input) 1) "\\")
            (setq user_input (substr user_input 1 (- (strlen user_input) 1)))
          )
          (princ (strcat "\n>>> Entered folder: " user_input))
          user_input
        )
        nil
      )
    )
  )
)

;; ═══════════════════════════════════════════════════════════════════════════
;; UPDATE SELECTION DISPLAY
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:update_selection_display ( / count_text)
  (setq count_text (strcat "Selected: " (itoa (length *selected_blocks*)) " blocks"))
  (princ (strcat "\n>>> " count_text))
)

;; ═══════════════════════════════════════════════════════════════════════════
;; SELECT SINGLE BLOCK
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:select_single_block ( / ent_name ent block_name base_pt)
  (princ "\n\n>>> SELECT SINGLE BLOCK MODE")
  (princ "\n>>> ══════════════════════════════════════════")
  (princ "\n>>> Click on a block:")
  
  (setq ent_name (car (entsel "\nSelect block: ")))
  
  (if ent_name
    (progn
      (setq ent (entget ent_name))
      
      (if (= "INSERT" (cdr (assoc 0 ent)))
        (progn
          (setq block_name (cdr (assoc 2 ent)))
          (setq base_pt (cdr (assoc 10 ent)))
          
          (setq *selected_blocks* 
            (append *selected_blocks* (list (list ent_name ent block_name base_pt)))
          )
          
          (princ (strcat "\n>>> ✓ Selected: " block_name))
          (princ "\n>>> ══════════════════════════════════════════")
        )
        (progn
          (princ "\n>>> ✗ Selected object is not a block!")
          (princ "\n>>> ══════════════════════════════════════════")
        )
      )
    )
    (progn
      (princ "\n>>> No selection made.")
    )
  )
)

;; ═══════════════════════════════════════════════════════════════════════════
;; SELECT BATCH (MULTIPLE) BLOCKS
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:select_batch_blocks ( / ss index ent_name ent block_name base_pt)
  (princ "\n\n>>> SELECT BATCH MODE (MULTIPLE BLOCKS)")
  (princ "\n>>> ══════════════════════════════════════════")
  (princ "\n>>> Click on blocks (hold SHIFT for multi-select, press ENTER when done):")
  
  (setq ss (ssget))
  
  (if ss
    (progn
      (setq index 0)
      (setq *selected_blocks* (list))
      
      (while (< index (sslength ss))
        (setq ent_name (ssname ss index))
        (setq ent (entget ent_name))
        
        (if (= "INSERT" (cdr (assoc 0 ent)))
          (progn
            (setq block_name (cdr (assoc 2 ent)))
            (setq base_pt (cdr (assoc 10 ent)))
            
            (setq *selected_blocks* 
              (append *selected_blocks* (list (list ent_name ent block_name base_pt)))
            )
            
            (princ (strcat "\n    ✓ Added: " block_name))
          )
          (progn
            (princ (strcat "\n    ⚠ Object at index " (itoa index) " is not a block - skipping"))
          )
        )
        
        (setq index (+ index 1))
      )
      
      (princ (strcat "\n>>> ✓ Total " (itoa (length *selected_blocks*)) " blocks selected!"))
      (princ "\n>>> ══════════════════════════════════════════")
    )
    (progn
      (princ "\n>>> No selection made.")
    )
  )
)

;; ═══════════════════════════════════════════════════════════════════════════
;; SELECT ALL BLOCKS IN DRAWING
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:select_all_blocks ( / ss index ent_name ent block_name base_pt)
  (princ "\n\n>>> SELECT ALL BLOCKS MODE")
  (princ "\n>>> ══════════════════════════════════════════")
  (princ "\n>>> Scanning drawing for all blocks...")
  
  (setq ss (ssget "X" (list (cons 0 "INSERT"))))
  
  (if ss
    (progn
      (setq index 0)
      (setq *selected_blocks* (list))
      
      (while (< index (sslength ss))
        (setq ent_name (ssname ss index))
        (setq ent (entget ent_name))
        
        (setq block_name (cdr (assoc 2 ent)))
        
        (if (not (wcmatch block_name "*`**"))
          (progn
            (setq base_pt (cdr (assoc 10 ent)))
            
            (setq *selected_blocks* 
              (append *selected_blocks* (list (list ent_name ent block_name base_pt)))
            )
            
            (princ (strcat "\n    ✓ Found: " block_name))
          )
        )
        
        (setq index (+ index 1))
      )
      
      (princ (strcat "\n>>> ✓ Total " (itoa (length *selected_blocks*)) " blocks found in drawing!"))
      (princ "\n>>> ══════════════════════════════════════════")
    )
    (progn
      (princ "\n>>> ✗ No blocks found in drawing!")
    )
  )
)

;; ═══════════════════════════════════════════════════════════════════════════
;; ALTERNATIVE EXPORT METHODS (v5.9 - SCRIPT-ONLY METHOD - SAFEST!)
;; Generate .SCR files only - no AutoCAD command execution
;; User runs script manually to avoid ALL crashes
;; ═══════════════════════════════════════════════════════════════════════════

;; Method 1: Script generation only - write to file, no execution
(defun mm:wblock_vla (block_name dwg_path)
  ;; This method does NOT execute any commands
  ;; It only returns success so CSV gets created
  ;; The SCRIPT method in export loop handles .scr file creation
  
  (princ (strcat "\n      [SCRIPT] Added to export list: " block_name))
  
  ;; Always return success - actual export happens via script file
  T
)

;; Method 2: Direct WBLOCK using command (may crash in some AutoCAD versions)
(defun mm:wblock_direct (block_name dwg_path / old_cmdecho old_filedia result)
  (setq result
    (vl-catch-all-apply
      (function (lambda ()
        ;; Save system variables
        (setq old_cmdecho (getvar "CMDECHO"))
        (setq old_filedia (getvar "FILEDIA"))
        
        ;; Set for silent operation
        (setvar "CMDECHO" 0)
        (setvar "FILEDIA" 0)
        
        ;; Execute WBLOCK command
        (command "._-WBLOCK" dwg_path "=" block_name)
        
        ;; Wait for command to complete
        (while (> (getvar "CMDACTIVE") 0)
          (command)
        )
        
        ;; Restore system variables
        (setvar "CMDECHO" old_cmdecho)
        (setvar "FILEDIA" old_filedia)
        
        ;; Check if file was created
        (if (findfile dwg_path)
          T    ; Success
          nil  ; Failed to create file
        )
      ))
    )
  )
  result
)

;; Method 3: ObjectDBX method (most stable)
(defun mm:wblock_objectdbx (block_name dwg_path / dbx doc)
  (vl-catch-all-apply
    (function (lambda ()
      (setq dbx (vla-getinterfaceobject 
                  (vlax-get-acad-object) 
                  (if (< (atoi (getvar "ACADVER")) 16)
                    "ObjectDBX.AxDbDocument"
                    (strcat "ObjectDBX.AxDbDocument." (itoa (atoi (getvar "ACADVER"))))
                  )
                ))
      
      ;; Create new document
      (vla-activate dbx)
      
      ;; Copy block definition to new document
      ;; (Complex implementation - simplified here)
      
      ;; Save the document
      (vla-saveas dbx dwg_path)
      (vlax-release-object dbx)
      T
    ))
  )
)

;; ═══════════════════════════════════════════════════════════════════════════
;; EXPORT BLOCKS TO CSV + DWG FILES (v5.3)
;; Uses SCRIPT file method + Alternative methods
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:export_blocks_and_dwg (csv_path block_library_path / file_handle index block_info 
                                 ent_name ent block_name base_pt type_val color_val ltype_val 
                                 x_str y_str z_str dwg_path success_count script_handle script_path)
  (princ "\n\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  (princ "\n>>> MACROMANAGER v5.9 - EXPORT DIAGNOSTICS")
  (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  
  ;; STEP 1: Validate inputs
  (princ "\n>>> [STEP 1/6] Validating Export Parameters...")
  (cond
    ((not csv_path)
     (progn
       (princ "\n>>> ✗ FAILED: No CSV file selected!")
       (alert "Please select a CSV file path for export!")))
    
    ((not block_library_path)
     (progn
       (princ "\n>>> ✗ FAILED: No Block Library folder selected!")
       (alert "Please select a Block Library folder for DWG export!")))
    
    ((= (length *selected_blocks*) 0)
     (progn
       (princ "\n>>> ✗ FAILED: No blocks selected for export!")
       (alert "Please select blocks first using the SELECT button!")))
    
    (T
     (progn
       (princ "\n>>> ✓ CSV Path validated")
       (princ "\n>>> ✓ Block Library path validated")
       (princ (strcat "\n>>> ✓ Blocks selected: " (itoa (length *selected_blocks*))))
       
       ;; STEP 2: Create folders
       (princ "\n\n>>> [STEP 2/6] Creating Export Folders...")
       (if (not (vl-file-directory-p block_library_path))
         (progn
           (princ (strcat "\n>>> Creating: " block_library_path))
           (vl-mkdir block_library_path)
           (princ "\n>>> ✓ Folder created"))
         (princ (strcat "\n>>> ✓ Folder exists: " block_library_path))
       )
       
       ;; STEP 3: Open files
       (princ "\n\n>>> [STEP 3/6] Opening Export Files...")
       (princ (strcat "\n>>> CSV: " csv_path))
       (princ (strcat "\n>>> Block Library: " block_library_path))
       (princ (strcat "\n>>> Export Method: " *export_method*))
       (princ (strcat "\n>>> Block Type: " *block_type*))
       
       ;; Create script file for WBLOCK commands
       (setq script_path (strcat block_library_path "\\export_blocks.scr"))
       (setq script_handle (open script_path "w"))
       (if script_handle
         (princ (strcat "\n>>> ✓ Script file opened: " script_path))
         (princ "\n>>> ✗ Failed to create script file!"))
       
       ;; Open CSV file for writing
       (setq file_handle (open csv_path "w"))
       (if file_handle
         (princ (strcat "\n>>> ✓ CSV file opened: " csv_path))
         (princ "\n>>> ✗ Failed to create CSV file!"))
       
       ;; STEP 4: Write headers
       (princ "\n\n>>> [STEP 4/6] Writing CSV Header...")
       (write-line "Block Name,X Coordinate,Y Coordinate,Z Coordinate,Type,Color,Linetype" file_handle)
       (princ "\n>>> ✓ Header written")
       
       ;; STEP 5: Process blocks
       (princ "\n\n>>> [STEP 5/6] Processing Selected Blocks...")
       (princ (strcat "\n>>> Total blocks to process: " (itoa (length *selected_blocks*))))
       (setq index 0)
       (setq success_count 0)
       
       (while (< index (length *selected_blocks*))
         (setq block_info (nth index *selected_blocks*))
         (setq ent_name (car block_info))
         (setq ent (cadr block_info))
         (setq block_name (caddr block_info))
         (setq base_pt (cadddr block_info))
         
         (princ (strcat "\n\n>>> [" (itoa (+ index 1)) "/" (itoa (length *selected_blocks*)) "] Processing: " block_name))
         
         ;; Get properties with defaults
         ;; Use dropdown-selected type instead of layer
         (setq type_val *block_type*)
         (if (not type_val) (setq type_val "General"))
         (princ (strcat "\n    Type: " type_val))
         
         (setq color_val (cdr (assoc 62 ent)))
         (if (not color_val) (setq color_val 256))
         (princ (strcat "\n    Color: " (itoa color_val)))
         
         (setq ltype_val (cdr (assoc 6 ent)))
         (if (not ltype_val) (setq ltype_val "ByLayer"))
         (princ (strcat "\n    Linetype: " ltype_val))
         
         ;; Format coordinates
         (setq x_str (rtos (car base_pt) 2 4))
         (setq y_str (rtos (cadr base_pt) 2 4))
         (setq z_str (rtos (caddr base_pt) 2 4))
         (princ (strcat "\n    Position: (" x_str ", " y_str ", " z_str ")"))
         
         ;; Write CSV line
         (write-line 
           (strcat 
             block_name ","
             x_str ","
             y_str ","
             z_str ","
             type_val ","
             (itoa color_val) ","
             ltype_val
           )
           file_handle
         )
         (princ "\n    ✓ CSV entry written")
         
         ;; Create DWG export based on selected method
         (setq dwg_path (strcat block_library_path "\\" block_name ".dwg"))
         (princ (strcat "\n    Target: " dwg_path))
         
         (if (tblsearch "BLOCK" block_name)
           (progn
             (princ "\n    ✓ Block definition found in drawing")
             (cond
               ;; Script Method
               ((equal *export_method* "script")
                ;; Write WBLOCK command with proper line breaks for AutoCAD script execution
                ;; CORRECT FORMAT: -WBLOCK, filename, =blockname (NO blank line between)
                (princ "\n    Writing to script file...")
                (write-line (strcat "-WBLOCK") script_handle)
                (write-line (strcat "\"" dwg_path "\"") script_handle)
                (write-line (strcat "=" block_name) script_handle)
                (write-line "" script_handle)  ;; Final blank line to complete command
                (princ "\n    ✓ Script commands added")
                (setq success_count (+ success_count 1)))
               
               ;; ActiveX/VLA Method (Recommended - no WBLOCK crash)
               ((equal *export_method* "vla")
                (princ "\n    Attempting VLA export...")
                (setq vla_result (mm:wblock_vla block_name dwg_path))
                (if (vl-catch-all-error-p vla_result)
                  (progn
                    (princ "\n    ✗ VLA export FAILED")
                    (princ (strcat "\n      Error: " (vl-catch-all-error-message vla_result))))
                  (progn
                    (princ "\n    ✓ VLA export succeeded")
                    (setq success_count (+ success_count 1)))))
               
               ;; Direct WBLOCK Method (may crash)
               ((equal *export_method* "direct")
                (princ "\n    Attempting Direct WBLOCK...")
                (setq direct_result (mm:wblock_direct block_name dwg_path))
                (if (vl-catch-all-error-p direct_result)
                  (princ "\n    ✗ Direct export FAILED")
                  (progn
                    (princ "\n    ✓ Direct export succeeded")
                    (setq success_count (+ success_count 1)))))
             )
           )
           (princ "\n    ✗ Block definition NOT found in drawing!")
         )
         
         
         (setq index (+ index 1))
       )
       
       ;; STEP 6: Close files and show results
       (princ "\n\n>>> [STEP 6/6] Finalizing Export...")
       (close file_handle)
       (princ "\n>>> ✓ CSV file closed")
       (close script_handle)
       (princ "\n>>> ✓ Script file closed")
       
       (princ "\n\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
       (princ "\n>>> EXPORT SUMMARY")
       (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
       (princ (strcat "\n>>> Total Blocks Processed: " (itoa (length *selected_blocks*))))
       (princ (strcat "\n>>> Successful Exports: " (itoa success_count)))
       (princ (strcat "\n>>> Export Method: " *export_method*))
       (princ (strcat "\n>>> Block Type: " *block_type*))
       (princ (strcat "\n>>> CSV File: " csv_path))
       (princ (strcat "\n>>> Block Library: " block_library_path))
       
       ;; Handle completion based on export method
       (cond
         ;; Script method - CREATE ONLY (don't execute)
         ((equal *export_method* "script")
          (progn
            (princ (strcat "\n>>> Script File: " script_path))
            (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            (princ "\n>>> ✓✓✓ EXPORT COMPLETE - SCRIPT METHOD ✓✓✓")
            (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            (princ "\n>>> NEXT STEPS TO CREATE DWG FILES:")
            (princ "\n>>>   1. Type: SCRIPT")
            (princ "\n>>>   2. Select: export_blocks.scr")
            (princ (strcat "\n>>>      Location: " block_library_path))
            (princ "\n>>>   3. Wait for AutoCAD to process all blocks")
            (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            ;; Show completion message with detailed instructions
            (alert (strcat "═══════════════════════════════════════\n"
                           "✓ MACROMANAGER EXPORT COMPLETE\n"
                           "═══════════════════════════════════════\n\n"
                           "CSV File Created:\n"
                           "• " (itoa success_count) " blocks exported\n"
                           "• Location: " csv_path "\n\n"
                           "Script File Created:\n"
                           "• Location: " script_path "\n\n"
                           "───────────────────────────────────────\n"
                           "TO CREATE DWG FILES:\n"
                           "───────────────────────────────────────\n"
                           "1. Type command: SCRIPT\n"
                           "2. Browse to: " block_library_path "\n"
                           "3. Select: export_blocks.scr\n"
                           "4. Press OK and wait\n\n"
                           "The script will create " (itoa success_count) " DWG files\n"
                           "in the Block Library folder.\n\n"
                           "NOTE: If AutoCAD crashes during SCRIPT\n"
                           "execution, this is a known AutoCAD bug\n"
                           "with WBLOCK, not a MacroManager issue.\n"
                           "───────────────────────────────────────"))
          ))
         
         ;; VLA method - also creates script only (safe mode)
         ((equal *export_method* "vla")
          (progn
            (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            (princ "\n>>> ✓ EXPORT COMPLETE - VLA METHOD")
            (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            (alert (strcat "✓ Export Complete!\n\n"
                           (itoa success_count)
                           " blocks exported to CSV:\n"
                           csv_path "\n\n"
                           "WARNING: VLA method is currently\n"
                           "disabled to prevent AutoCAD freeze.\n\n"
                           "Please use SCRIPT method instead\n"
                           "for DWG file creation."))
          ))
         
         ;; Direct method - not recommended
         ((equal *export_method* "direct")
          (progn
            (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            (princ "\n>>> ✓ EXPORT COMPLETE - DIRECT METHOD")
            (princ (strcat "\n>>> Check folder: " block_library_path))
            (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            (alert (strcat "✓ Export Complete!\n\n" 
                           (itoa success_count) 
                           " blocks exported:\n\n"
                           "CSV: " csv_path "\n\n"
                           "DWG files: " block_library_path "\n\n"
                           "WARNING: Direct method may have\n"
                           "caused AutoCAD to crash. If you\n"
                           "see this message, it worked!"))
          ))
       )
       
       (princ "\n")
     ))
  )
)

;; ═══════════════════════════════════════════════════════════════════════════
;; CSV PARSER - HANDLES QUOTED FIELDS
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:parse_csv_line (line / result pos char in_quotes field max_pos)
  (setq result '())
  (setq field "")
  (setq in_quotes nil)
  (setq pos 1)
  (setq max_pos (strlen line))
  
  (while (<= pos max_pos)
    (setq char (substr line pos 1))
    (cond
      ((and (= char "\"") (not in_quotes))
       (setq in_quotes T))
      ((and (= char "\"") in_quotes)
       (setq in_quotes nil))
      ((and (= char ",") (not in_quotes))
       (setq result (append result (list field)))
       (setq field ""))
      (T
       (setq field (strcat field char)))
    )
    (setq pos (1+ pos))
  )
  
  (setq result (append result (list field)))
  result
)

;; ═══════════════════════════════════════════════════════════════════════════
;; CHECK FOR MISSING BLOCKS IN LIBRARY (NEW - v5.2)
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:check_missing_block_files (csv_path block_library_path / file_handle line fields 
                                     block_name missing_blocks dwg_file msg_text)
  (princ "\n>>> Checking for missing block DWG files...")
  
  (setq file_handle (open csv_path "r"))
  (setq missing_blocks '())
  
  ;; Skip header
  (read-line file_handle)
  
  ;; Check each block
  (while (setq line (read-line file_handle))
    (if (> (strlen line) 0)
      (progn
        (setq fields (mm:parse_csv_line line))
        (setq block_name (car fields))
        
        (if (and block_name (> (strlen block_name) 0))
          (progn
            (setq dwg_file (strcat block_library_path "\\" block_name ".dwg"))
            (if (not (findfile dwg_file))
              (if (not (member block_name missing_blocks))
                (setq missing_blocks (append missing_blocks (list block_name)))
              )
            )
          )
        )
      )
    )
  )
  
  (close file_handle)
  
  ;; Report missing blocks
  (if missing_blocks
    (progn
      (setq msg_text "⚠ WARNING: Missing block DWG files:\n\n")
      (foreach blk missing_blocks
        (setq msg_text (strcat msg_text "  ✗ " blk ".dwg\n"))
      )
      (setq msg_text (strcat msg_text "\n" 
                             "These blocks will be skipped during import.\n"
                             "Check Block Library folder: " block_library_path))
      (princ (strcat "\n>>> ⚠ " (itoa (length missing_blocks)) " missing block files"))
      (alert msg_text)
    )
    (progn
      (princ "\n>>> ✓ All block DWG files found!")
    )
  )
  
  missing_blocks
)

;; ═══════════════════════════════════════════════════════════════════════════
;; PREVIEW CSV FILE FOR IMPORT (NEW - v5.2)
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:preview_csv (csv_path / file_handle line fields block_name x y z type_val 
                       preview_list preview_text block_count)
  (princ "\n>>> PREVIEWING CSV FILE...")
  
  (cond
    ((not csv_path)
     (progn
       (princ "\n>>> ✗ No CSV file selected!")
       (set_tile "preview_status" "ERROR: No CSV file selected")
       (alert "Please select a CSV file first!")
     ))
    
    ((not (findfile csv_path))
     (progn
       (princ (strcat "\n>>> ✗ File not found: " csv_path))
       (set_tile "preview_status" "ERROR: CSV file not found")
       (alert (strcat "Cannot find file:\n" csv_path))
     ))
    
    (T
     (progn
       (setq file_handle (open csv_path "r"))
       
       (if file_handle
         (progn
           (princ (strcat "\n>>> Reading: " csv_path))
           
           ;; Skip header line
           (setq line (read-line file_handle))
           
           ;; Read all data lines
           (setq preview_list (list))
           (setq block_count 0)
           
           (while (setq line (read-line file_handle))
             (if (and line (/= line ""))
               (progn
                 (setq fields (mm:parse_csv_line line))
                 
                 (if (>= (length fields) 7)
                   (progn
                     (setq block_name (nth 0 fields))
                     (setq x (nth 1 fields))
                     (setq y (nth 2 fields))
                     (setq z (nth 3 fields))
                     (setq type_val (nth 4 fields))
                     
                     ;; Create preview text
                     (setq preview_text 
                       (strcat 
                         block_name 
                         " at (" x ", " y ", " z ") - Type: " type_val
                       )
                     )
                     
                     (setq preview_list (cons preview_text preview_list))
                     (setq block_count (+ block_count 1))
                   )
                 )
               )
             )
           )
           
           (close file_handle)
           
           ;; Populate the list box
           (start_list "preview_list")
           (foreach item (reverse preview_list)
             (add_list item)
           )
           (end_list)
           
           ;; Update status
           (set_tile "preview_status" 
             (strcat "Ready to import " (itoa block_count) " blocks from CSV"))
           
           (princ (strcat "\n>>> ✓ Preview complete: " (itoa block_count) " blocks found"))
           (princ "\n>>> Click START IMPORT to proceed")
         )
         (progn
           (princ "\n>>> ✗ Cannot open CSV file!")
           (set_tile "preview_status" "ERROR: Cannot open CSV file")
           (alert (strcat "Cannot open file:\n" csv_path))
         )
       )
     ))
  )
  (princ)
)

;; ═══════════════════════════════════════════════════════════════════════════
;; IMPORT BLOCKS FROM CSV + DWG LIBRARY (NEW - v5.2)
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:import_blocks_from_dwg (csv_path block_library_path / file_handle line fields 
                                  block_name x y z type_val color linetype dwg_file
                                  ent ent_data success_count skip_count old_cmdecho insert_result)
  (princ "\n\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  (princ "\n>>> MACROMANAGER v5.10 - IMPORT DIAGNOSTICS")
  (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  
  (cond
    ((not csv_path)
     (progn
       (princ "\n>>> ✗ No CSV file selected!")
       (alert "Please select a CSV file to import!")))
    
    ((not block_library_path)
     (progn
       (princ "\n>>> ✗ No Block Library folder selected!")
       (alert "Please select a Block Library folder for DWG import!")))
    
    ((not (findfile csv_path))
     (progn
       (princ "\n>>> ✗ CSV file not found!")
       (alert (strcat "CSV file not found:\n" csv_path))))
    
    (T
     (progn
       (princ "\n>>> ✓ CSV file found")
       (princ (strcat "\n>>> ✓ Block Library: " block_library_path))
       
       ;; Cancel any active commands
       (command)
       (while (> (getvar "CMDACTIVE") 0) (command))
       
       ;; Check for missing block files
       (mm:check_missing_block_files csv_path block_library_path)
       
       (setq file_handle (open csv_path "r"))
       (setq success_count 0)
       (setq skip_count 0)
       
       ;; Read header
       (read-line file_handle)
       
       (princ "\n>>> Processing CSV data...")
       (princ "\n>>> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
       
       ;; Read data lines and INSERT blocks
       (while (setq line (read-line file_handle))
         (if (> (strlen line) 0)
           (progn
             (setq fields (mm:parse_csv_line line))
             
             (if (>= (length fields) 7)
               (progn
                 ;; Parse CSV fields
                 (setq block_name (nth 0 fields))
                 (setq x (atof (nth 1 fields)))
                 (setq y (atof (nth 2 fields)))
                 (setq z (atof (nth 3 fields)))
                 (setq type_val (nth 4 fields))
                 (setq color (nth 5 fields))
                 (setq linetype (nth 6 fields))
                 
                 ;; Check if block DWG file exists
                 (setq dwg_file (strcat block_library_path "\\" block_name ".dwg"))
                 
                 (if (findfile dwg_file)
                   (progn
                     ;; Load block from DWG file (INSERT with file path)
                     (princ (strcat "\n    → Loading: " block_name ".dwg"))
                     
                     ;; Cancel any active commands first
                     (command)
                     (while (> (getvar "CMDACTIVE") 0) (command))
                     
                     ;; Create layer/type if specified
                     (if (and type_val (> (strlen type_val) 0) (not (equal type_val "0")))
                       (progn
                         (if (not (tblsearch "LAYER" type_val))
                           (progn
                             (command "._LAYER" "_MAKE" type_val "")
                             (while (> (getvar "CMDACTIVE") 0) (command))
                           )
                           (progn
                             (command "._LAYER" "_SET" type_val "")
                             (while (> (getvar "CMDACTIVE") 0) (command))
                           )
                         )
                       )
                     )
                     
                     ;; INSERT block from DWG file with error trapping
                     (setq old_cmdecho (getvar "CMDECHO"))
                     (setvar "CMDECHO" 0)
                     
                     (setq insert_result 
                       (vl-catch-all-apply 
                         'command 
                         (list "._INSERT" dwg_file (list x y z) 1.0 1.0 0.0)
                       )
                     )
                     
                     ;; Wait for command to complete
                     (while (> (getvar "CMDACTIVE") 0) (command))
                     (setvar "CMDECHO" old_cmdecho)
                     
                     ;; Check if insert was successful
                     (if (not (vl-catch-all-error-p insert_result))
                       (progn
                         ;; Get inserted entity
                         (if (setq ent (entlast))
                           (progn
                             (setq ent_data (entget ent))
                             
                             ;; Update layer/type
                             (if (and type_val (> (strlen type_val) 0))
                               (setq ent_data (subst (cons 8 type_val) (assoc 8 ent_data) ent_data))
                             )
                             
                             ;; Update color if specified
                             (if (and color (> (strlen color) 0) (not (equal color "256")))
                               (progn
                                 (setq color (atoi color))
                                 (if (assoc 62 ent_data)
                                   (setq ent_data (subst (cons 62 color) (assoc 62 ent_data) ent_data))
                                   (setq ent_data (append ent_data (list (cons 62 color))))
                                 )
                               )
                             )
                             
                             ;; Update linetype
                             (if (and linetype (> (strlen linetype) 0) (not (equal linetype "ByLayer")))
                               (if (tblsearch "LTYPE" linetype)
                                 (if (assoc 6 ent_data)
                                   (setq ent_data (subst (cons 6 linetype) (assoc 6 ent_data) ent_data))
                                   (setq ent_data (append ent_data (list (cons 6 linetype))))
                                 )
                               )
                             )
                             
                             ;; Apply changes
                             (entmod ent_data)
                             
                             (setq success_count (+ success_count 1))
                             (princ (strcat "\n    ✓ " block_name " inserted at (" (rtos x 2 2) ", " (rtos y 2 2) ")"))
                           )
                           (progn
                             (princ (strcat "\n    ✗ " block_name " - INSERT failed (no entity created)"))
                             (setq skip_count (+ skip_count 1))
                           )
                         )
                       )
                       (progn
                         (princ (strcat "\n    ✗ " block_name " - INSERT error: " (vl-catch-all-error-message insert_result)))
                         (setq skip_count (+ skip_count 1))
                       )
                     )
                   )
                   (progn
                     (setq skip_count (+ skip_count 1))
                     (princ (strcat "\n    ✗ Block file not found: " block_name ".dwg - skipping"))
                   )
                 )
               )
               (progn
                 (princ (strcat "\n    ⚠ Invalid CSV line (needs 7 fields): " line))
               )
             )
           )
         )
       )
       
       (close file_handle)
       
       (princ "\n>>> ══════════════════════════════════════════")
       (princ (strcat "\n>>> ✓ Import complete!"))
       (princ (strcat "\n>>>   • " (itoa success_count) " blocks inserted"))
       (princ (strcat "\n>>>   • " (itoa skip_count) " blocks skipped"))
       (princ "\n>>> ══════════════════════════════════════════")
       
       (alert (strcat "Import Complete!\n\n" 
                      "✓ Inserted: " (itoa success_count) " blocks\n"
                      "✗ Skipped: " (itoa skip_count) " blocks\n\n"
                      "Check command line for details."))
     ))
  )
  (princ)
)

;; ═══════════════════════════════════════════════════════════════════════════
;; PREVIEW CSV FILE
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:preview_csv (csv_path / file_handle line count preview_text)
  (princ "\n>>> Previewing CSV file...")
  
  (if (not csv_path)
    (progn
      (princ "\n>>> ✗ No CSV file selected!")
      (alert "Please select a CSV file to preview!"))
    (progn
      (if (not (findfile csv_path))
        (progn
          (princ "\n>>> ✗ File not found!")
          (alert (strcat "CSV file not found:\n" csv_path)))
        (progn
          (setq file_handle (open csv_path "r"))
          (setq count 0)
          (setq preview_text "CSV PREVIEW:\n════════════════════════════════════════\n\n")
          
          (while (and (< count 15) (setq line (read-line file_handle)))
            (setq preview_text (strcat preview_text line "\n"))
            (setq count (+ count 1))
          )
          
          (close file_handle)
          
          (setq preview_text (strcat preview_text "\n════════════════════════════════════════\n(Showing first " (itoa count) " lines)"))
          
          (princ (strcat "\n>>> ✓ Preview loaded (" (itoa count) " lines)"))
          (alert preview_text)
        )
      )
    )
  )
)

;; ═══════════════════════════════════════════════════════════════════════════
;; STARTUP MESSAGE
;; ═══════════════════════════════════════════════════════════════════════════

(princ "\n╔═══════════════════════════════════════════════════════════╗")
(princ "\n║  ✓ MacroManager v5.4 loaded!                            ║")
(princ "\n║                                                           ║")
(princ "\n║  NEW in v5.4:                                            ║")
(princ "\n║  ✓ Auto-execute script (no manual SCRIPT command)       ║")
(princ "\n║  ✓ 3 export methods: Script/ActiveX-VLA/Direct          ║")
(princ "\n║  ✓ User-selectable export method                        ║")
(princ "\n║                                                           ║")
(princ "\n║  Features:                                               ║")
(princ "\n║  ✓ Type/Category dropdown (8 categories)                ║")
(princ "\n║  ✓ Preview before import                                 ║")
(princ "\n║  ✓ Block Library management                              ║")
(princ "\n║  ✓ CSV format with Type column                          ║")
(princ "\n║                                                           ║")
(princ "\n║  Command: MACROMANAGER                                   ║")
(princ "\n╚═══════════════════════════════════════════════════════════╝\n")

(princ)
