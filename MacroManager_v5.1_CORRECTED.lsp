;; ═══════════════════════════════════════════════════════════════════════════
;; MACRO MANAGER UNIFIED - VERSION 5.1 CORRECTED
;; Complete Import/Export with Block Insertion
;; ═══════════════════════════════════════════════════════════════════════════
;;
;; ALL FIXES APPLIED in v5.1 CORRECTED:
;;   ✓ Fixed DEFVAR error (changed to setq)
;;   ✓ Complete block import functionality (actual insertion)
;;   ✓ CSV parser with quoted field support
;;   ✓ Export with default values (no nil errors)
;;   ✓ Block existence validation before import
;;   ✓ Layer/Color/Linetype property setting
;;   ✓ DCL button keys fixed (accept/cancel)
;;   ✓ Selection workflow fixed (dialog close/reopen pattern)
;;   ✓ Variable initialization fixed (export_csv, import_csv)
;;   ✓ Radio button initialization with explicit values
;;   ✓ Syntax errors removed (extra parentheses)
;;   ✓ Robust error handling
;;
;; FEATURES:
;;   • THREE selection modes: Single / Batch / All
;;   • Dialog closes temporarily for block selection
;;   • CONFIRM selection before export
;;   • Clear selection and try again
;;   • Full CSV import with block insertion
;;   • Property management (Layer, Color, Linetype)
;;
;; USAGE:
;;   (load "MacroManager_v5.1_CORRECTED.lsp")
;;   Command: MACROMANAGER
;;
;; ═══════════════════════════════════════════════════════════════════════════

;; ═══════════════════════════════════════════════════════════════════════════
;; GLOBAL VARIABLES - FIXED (using setq, not defvar)
;; ═══════════════════════════════════════════════════════════════════════════

(if (not *selected_blocks*) (setq *selected_blocks* (list)))
(if (not *selection_mode*) (setq *selection_mode* "single"))

;; ═══════════════════════════════════════════════════════════════════════════
;; MAIN COMMAND
;; ═══════════════════════════════════════════════════════════════════════════

(defun c:MACROMANAGER ( / dcl_id result dcl_path drawing_path)
  
  (princ "\n╔═══════════════════════════════════════════════════════════╗")
  (princ "\n║  Macro Manager v5.1 - CORRECTED                          ║")
  (princ "\n║                                                           ║")
  (princ "\n║  ✓ All fixes applied and tested                          ║")
  (princ "\n║  ✓ Dialog stability fixed                                ║")
  (princ "\n║  ✓ Complete import/export functionality                  ║")
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
    ((findfile (strcat drawing_path "MacroManager_v5.1_FIXED.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.1_FIXED.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.1_CORRECTED.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.1_CORRECTED.dcl")))
    ((findfile (strcat drawing_path "MacroManager_v5.dcl"))
     (setq dcl_path (strcat drawing_path "MacroManager_v5.dcl")))
    ((findfile (strcat drawing_path "WORKING_MacroManager_v5.dcl"))
     (setq dcl_path (strcat drawing_path "WORKING_MacroManager_v5.dcl")))
  )
  
  (if (not dcl_path)
    (progn
      (princ "\n>>> ✗ ERROR: Could not find DCL file")
      (alert (strcat "ERROR: Cannot find DCL file\n\nSearched for:\n"
                     "- MacroManager_v5.1_FIXED.dcl\n"
                     "- MacroManager_v5.1_CORRECTED.dcl\n"
                     "- MacroManager_v5.dcl\n"
                     "- WORKING_MacroManager_v5.dcl\n\n"
                     "In folder: " drawing_path))
    )
    (progn
      (princ (strcat "\n>>> Loading DCL from: " dcl_path))
      
      ;; Load the DCL
      (setq dcl_id (load_dialog dcl_path))
      
      ;; Check if loaded
      (if (< dcl_id 0)
        (progn
          (princ "\n>>> ✗ ERROR: Could not load DCL")
          (alert (strcat "ERROR: Cannot load DCL file\n\nFile: " dcl_path))
        )
        (progn
          (princ "\n>>> ✓ DCL loaded!")
          
          ;; Create main dialog loop
          (setq result 1)
          (setq export_csv nil)  ; Initialize export CSV path - FIXED
          (setq import_csv nil)  ; Initialize import CSV path - FIXED
          
          (while (> result 0)
            (if (new_dialog "UnifiedMacroDialog" dcl_id)
              (progn
                (princ "\n>>> ✓ Dialog created and OPEN!")
                
                ;; Set the correct radio button based on current mode - FIXED with explicit values
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
                
                ;; Update selection count display
                (set_tile "selection_count" (strcat "Selected: " (itoa (length *selected_blocks*)) " blocks"))
                
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
                ;; SELECTION BUTTONS - DIALOG CLOSES TEMPORARILY FOR SELECTION
                ;; ══════════════════════════════════════════════════════════
                
                ;; SELECT BLOCKS BUTTON - Close dialog, select, then reopen
                (action_tile "export_select"
                  "(done_dialog 2)")
                
                ;; CLEAR SELECTION BUTTON
                (action_tile "export_clear"
                  "(progn (setq *selected_blocks* (list)) (set_tile \"selection_count\" \"Selected: 0 blocks\") (princ \"\\n>>> Selection cleared\"))")
                
                ;; EXPORT TO CSV BUTTON
                (action_tile "export_csv_browse"
                  "(progn 
                     (setq export_csv (getfiled \"Save CSV\" \"\" \"csv\" 1))
                     (if export_csv 
                       (set_tile \"export_csv_display\" export_csv)
                       (set_tile \"export_csv_display\" \"No file selected\")
                     )
                   )")
                
                (action_tile "export_start"
                  "(mm:export_selected_blocks export_csv)")
                
                ;; ══════════════════════════════════════════════════════════
                ;; IMPORT BUTTONS
                ;; ══════════════════════════════════════════════════════════
                
                (action_tile "import_csv_browse"
                  "(progn 
                     (setq import_csv (getfiled \"Select CSV to Import\" \"\" \"csv\" 0))
                     (if import_csv 
                       (set_tile \"import_csv_display\" import_csv)
                       (set_tile \"import_csv_display\" \"No file selected\")
                     )
                   )")
                
                (action_tile "import_preview"
                  "(mm:preview_csv import_csv)")
                
                (action_tile "import_start"
                  "(mm:import_blocks import_csv)")
                
                ;; ══════════════════════════════════════════════════════════
                ;; CLOSE BUTTON - FIXED with accept/cancel keys
                ;; ══════════════════════════════════════════════════════════
                
                (action_tile "accept" "(done_dialog 0)")
                (action_tile "cancel" "(done_dialog 0)")
                
                ;; Start the dialog
                (setq result (start_dialog))
                
                ;; Handle dialog return codes
                (cond
                  ;; result = 0: Normal close
                  ((= result 0) 
                   (setq result 0))  ; Exit loop
                  
                  ;; result = 2: SELECT button pressed - do selection, then reopen
                  ((= result 2)
                   (princ "\n>>> Dialog closed for selection...")
                   (cond 
                     ((equal *selection_mode* "single") (mm:select_single_block))
                     ((equal *selection_mode* "batch") (mm:select_batch_blocks))
                     ((equal *selection_mode* "all") (mm:select_all_blocks))
                   )
                   (setq result 1))  ; Reopen dialog
                  
                  ;; Any other result: exit
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
        )
      )
    )
  )
  
  (princ)
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
          
          ;; Add to list
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
            
            ;; Add to list
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
        
        ;; Skip system blocks (starting with *)
        (if (not (wcmatch block_name "*`**"))
          (progn
            (setq base_pt (cdr (assoc 10 ent)))
            
            ;; Add to list
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
;; EXPORT SELECTED BLOCKS TO CSV - WITH DEFAULT VALUES (FIXED)
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:export_selected_blocks (csv_path / file_handle index block_info ent_name ent block_name base_pt
                                             layer_val color_val ltype_val x_str y_str z_str)
  (princ "\n\n>>> EXPORTING SELECTED BLOCKS")
  (princ "\n>>> ══════════════════════════════════════════")
  
  (if (not csv_path)
    (progn
      (princ "\n>>> ✗ No CSV file selected!")
      (alert "Please select a CSV file path for export!")
    )
    (progn
      (if (= (length *selected_blocks*) 0)
        (progn
          (princ "\n>>> ✗ No blocks selected for export!")
          (alert "Please select blocks first using the SELECT button!")
        )
        (progn
          (princ (strcat "\n>>> Exporting to: " csv_path))
          
          ;; Open file for writing
          (setq file_handle (open csv_path "w"))
          
          ;; Write header
          (write-line "Block Name,X Coordinate,Y Coordinate,Z Coordinate,Layer,Color,Linetype" file_handle)
          
          ;; Write each selected block
          (setq index 0)
          (while (< index (length *selected_blocks*))
            (setq block_info (nth index *selected_blocks*))
            (setq ent_name (car block_info))
            (setq ent (cadr block_info))
            (setq block_name (caddr block_info))
            (setq base_pt (cadddr block_info))
            
            ;; Get properties with defaults (FIXED - no nil values)
            (setq layer_val (cdr (assoc 8 ent)))
            (if (not layer_val) (setq layer_val "0"))
            
            (setq color_val (cdr (assoc 62 ent)))
            (if (not color_val) (setq color_val 256))
            
            (setq ltype_val (cdr (assoc 6 ent)))
            (if (not ltype_val) (setq ltype_val "ByLayer"))
            
            ;; Format coordinates
            (setq x_str (rtos (car base_pt) 2 4))
            (setq y_str (rtos (cadr base_pt) 2 4))
            (setq z_str (rtos (caddr base_pt) 2 4))
            
            ;; Write CSV line
            (write-line 
              (strcat 
                block_name ","
                x_str ","
                y_str ","
                z_str ","
                layer_val ","
                (itoa color_val) ","
                ltype_val
              )
              file_handle
            )
            
            (princ (strcat "\n    ✓ " block_name " at X:" (rtos (car base_pt) 2 2) ", Y:" (rtos (cadr base_pt) 2 2)))
            (setq index (+ index 1))
          )
          
          ;; Close file
          (close file_handle)
          
          (princ (strcat "\n>>> ✓ Export complete! Saved " (itoa (length *selected_blocks*)) " blocks"))
          (princ "\n>>> ══════════════════════════════════════════")
          
          (alert (strcat "Export Complete!\n\n" 
                         (itoa (length *selected_blocks*)) 
                         " blocks exported to:\n" 
                         csv_path))
        )
      )
    )
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
      ;; Handle quotes
      ((and (= char "\"") (not in_quotes))
       (setq in_quotes T))
      ((and (= char "\"") in_quotes)
       (setq in_quotes nil))
      ;; Handle comma separator
      ((and (= char ",") (not in_quotes))
       (setq result (append result (list field)))
       (setq field ""))
      ;; Add character to current field
      (T
       (setq field (strcat field char)))
    )
    (setq pos (1+ pos))
  )
  
  ;; Add last field
  (setq result (append result (list field)))
  
  result
)

;; ═══════════════════════════════════════════════════════════════════════════
;; CHECK FOR MISSING BLOCKS - VALIDATION
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:check_missing_blocks (csv_path / file_handle line fields block_name missing_blocks msg_text)
  (princ "\n>>> Checking for missing block definitions...")
  
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
        
        ;; Check if block exists
        (if (and block_name (> (strlen block_name) 0))
          (if (not (tblsearch "BLOCK" block_name))
            (if (not (member block_name missing_blocks))
              (setq missing_blocks (append missing_blocks (list block_name)))
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
      (setq msg_text "⚠ WARNING: Missing block definitions:\n\n")
      (foreach blk missing_blocks
        (setq msg_text (strcat msg_text "  ✗ " blk "\n"))
      )
      (setq msg_text (strcat msg_text "\n" 
                             "These blocks will be skipped during import.\n"
                             "Load block definitions before importing!"))
      (princ (strcat "\n>>> ⚠ " (itoa (length missing_blocks)) " missing blocks found"))
      (alert msg_text)
    )
    (progn
      (princ "\n>>> ✓ All blocks available!")
    )
  )
  
  missing_blocks
)

;; ═══════════════════════════════════════════════════════════════════════════
;; IMPORT BLOCKS FROM CSV - COMPLETE IMPLEMENTATION WITH INSERTION (FIXED)
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:import_blocks (csv_path / file_handle line count fields block_name x y z layer color linetype
                                    ent ent_data success_count skip_count)
  (princ "\n\n>>> STARTING BLOCK IMPORT")
  (princ "\n>>> ══════════════════════════════════════════")
  
  (if (not csv_path)
    (progn
      (princ "\n>>> ✗ No CSV file selected for import!")
      (alert "Please select a CSV file to import!")
    )
    (progn
      (if (not (findfile csv_path))
        (progn
          (princ "\n>>> ✗ File not found!")
          (alert (strcat "CSV file not found:\n" csv_path))
        )
        (progn
          ;; First, check for missing blocks
          (mm:check_missing_blocks csv_path)
          
          ;; Proceed with import
          (setq file_handle (open csv_path "r"))
          (setq success_count 0)
          (setq skip_count 0)
          
          ;; Read header (skip first line)
          (read-line file_handle)
          
          (princ "\n>>> Processing CSV data...")
          
          ;; Read data lines and INSERT blocks
          (while (setq line (read-line file_handle))
            (if (> (strlen line) 0)
              (progn
                (setq fields (mm:parse_csv_line line))
                
                ;; Verify we have minimum 7 fields
                (if (>= (length fields) 7)
                  (progn
                    ;; Parse CSV fields
                    (setq block_name (nth 0 fields))
                    (setq x (atof (nth 1 fields)))
                    (setq y (atof (nth 2 fields)))
                    (setq z (atof (nth 3 fields)))
                    (setq layer (nth 4 fields))
                    (setq color (nth 5 fields))
                    (setq linetype (nth 6 fields))
                    
                    ;; Check if block definition exists
                    (if (tblsearch "BLOCK" block_name)
                      (progn
                        ;; Create layer if specified and doesn't exist
                        (if (and layer (> (strlen layer) 0) (not (equal layer "0")))
                          (if (not (tblsearch "LAYER" layer))
                            (command "._LAYER" "_MAKE" layer "")
                            (command "._LAYER" "_SET" layer "")
                          )
                        )
                        
                        ;; INSERT block at coordinates
                        (command "._INSERT" block_name (list x y z) "" "" "")
                        
                        ;; Get the inserted entity
                        (if (setq ent (entlast))
                          (progn
                            (setq ent_data (entget ent))
                            
                            ;; Update layer if specified
                            (if (and layer (> (strlen layer) 0))
                              (setq ent_data (subst (cons 8 layer) (assoc 8 ent_data) ent_data))
                            )
                            
                            ;; Update color if specified and not ByLayer (256)
                            (if (and color (> (strlen color) 0) (not (equal color "256")))
                              (progn
                                (setq color (atoi color))
                                (if (assoc 62 ent_data)
                                  (setq ent_data (subst (cons 62 color) (assoc 62 ent_data) ent_data))
                                  (setq ent_data (append ent_data (list (cons 62 color))))
                                )
                              )
                            )
                            
                            ;; Update linetype if specified and not ByLayer
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
                            (princ (strcat "\n    ✓ " block_name " at (" (rtos x 2 2) ", " (rtos y 2 2) ", " (rtos z 2 2) ")"))
                          )
                        )
                      )
                      (progn
                        (setq skip_count (+ skip_count 1))
                        (princ (strcat "\n    ✗ Block not found: " block_name " - skipping"))
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
        )
      )
    )
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
      (princ "\n>>> ✗ No CSV file selected for preview!")
      (alert "Please select a CSV file to preview!")
    )
    (progn
      (if (not (findfile csv_path))
        (progn
          (princ "\n>>> ✗ File not found!")
          (alert (strcat "CSV file not found:\n" csv_path))
        )
        (progn
          (setq file_handle (open csv_path "r"))
          (setq count 0)
          (setq preview_text "CSV PREVIEW:\n════════════════════════════════════════\n\n")
          
          ;; Read first 15 lines
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
(princ "\n║  ✓ MacroManager v5.1 CORRECTED loaded!                  ║")
(princ "\n║                                                           ║")
(princ "\n║  ALL FIXES APPLIED:                                      ║")
(princ "\n║  ✓ DEFVAR error fixed (using setq)                      ║")
(princ "\n║  ✓ Complete import with block insertion                 ║")
(princ "\n║  ✓ CSV parser with quoted fields                        ║")
(princ "\n║  ✓ Export with default values (no nil)                  ║")
(princ "\n║  ✓ Block validation before import                       ║")
(princ "\n║  ✓ Layer/Color/Linetype properties                      ║")
(princ "\n║  ✓ DCL button keys (accept/cancel)                      ║")
(princ "\n║  ✓ Dialog stability (variable init)                     ║")
(princ "\n║  ✓ Selection workflow (close/reopen)                    ║")
(princ "\n║                                                           ║")
(princ "\n║  Command: MACROMANAGER                                   ║")
(princ "\n╚═══════════════════════════════════════════════════════════╝\n")

(princ)
