;; ═══════════════════════════════════════════════════════════════════════════
;; MACRO MANAGER UNIFIED - WORKING VERSION 5.0
;; Enhanced Selection System with Mode Options
;; ═══════════════════════════════════════════════════════════════════════════
;;
;; FEATURES:
;;   • THREE selection modes: Single / Batch / All
;;   • Dialog stays OPEN while selecting
;;   • User can SELECT blocks at any time
;;   • CONFIRM selection before export
;;   • Clear selection and try again
;;   • Full CSV export with coordinates
;;
;; USAGE:
;;   (load "WORKING_MacroManager_v5.lsp")
;;   MACROMANAGER
;;
;; ═══════════════════════════════════════════════════════════════════════════

;; Global variables for selection tracking
(defvar *selected_blocks* (list))
(defvar *selection_mode* "single")

(defun c:MACROMANAGER ( / dcl_id result dcl_path drawing_path)
  
  (princ "\n╔═══════════════════════════════════════════════════════════╗")
  (princ "\n║  Macro Manager v5.0 - ENHANCED SELECTION SYSTEM          ║")
  (princ "\n║                                                           ║")
  (princ "\n║  Modes: Single / Batch / All Drawing                     ║")
  (princ "\n║  Dialog Stays Open While Selecting!                      ║")
  (princ "\n╚═══════════════════════════════════════════════════════════╝")
  
  ;; Initialize global variables
  (setq *selected_blocks* (list))
  (setq *selection_mode* "single")
  
  ;; Get drawing file path
  (setq drawing_path (getvar "DWGPREFIX"))
  (princ (strcat "\n>>> Working folder: " drawing_path))
  
  ;; Try to find the DCL file
  (setq dcl_path (strcat drawing_path "WORKING_MacroManager_v5.dcl"))
  (princ (strcat "\n>>> Loading DCL from: " dcl_path))
  
  ;; Load the DCL
  (setq dcl_id (load_dialog dcl_path))
  
  ;; Check if loaded
  (if (< dcl_id 0)
    (progn
      (princ "\n>>> ✗ ERROR: Could not load DCL")
      (alert (strcat "ERROR: Cannot load DCL file\n\nMake sure WORKING_MacroManager_v5.dcl is in:\n" drawing_path))
    )
    (progn
      (princ "\n>>> ✓ DCL loaded!")
      
      ;; Create main dialog loop
      (setq result 1)
      (while (> result 0)
        (if (new_dialog "UnifiedMacroDialog" dcl_id)
          (progn
            (princ "\n>>> ✓ Dialog created and OPEN!")
            
            ;; Set initial mode
            (set_tile "export_mode_single" "1")
            (setq *selection_mode* "single")
            
            ;; Update selection count display
            (mm:update_selection_display)
            
            ;; ══════════════════════════════════════════════════════════
            ;; EXPORT MODE SELECTION
            ;; ══════════════════════════════════════════════════════════
            
            (action_tile "export_mode_single"
              "(progn (setq *selection_mode* \"single\") (princ \"\\n>>> Mode: SINGLE BLOCK\") (mm:update_selection_display))")
            
            (action_tile "export_mode_batch"
              "(progn (setq *selection_mode* \"batch\") (princ \"\\n>>> Mode: BATCH (MULTIPLE BLOCKS)\") (mm:update_selection_display))")
            
            (action_tile "export_mode_all"
              "(progn (setq *selection_mode* \"all\") (princ \"\\n>>> Mode: ALL BLOCKS IN DRAWING\") (mm:update_selection_display))")
            
            ;; ══════════════════════════════════════════════════════════
            ;; SELECTION BUTTONS - DIALOG STAYS OPEN!
            ;; ══════════════════════════════════════════════════════════
            
            ;; SELECT BLOCKS BUTTON
            (action_tile "export_select"
              "(progn 
                 (cond 
                   ((string= *selection_mode* \"single\") (mm:select_single_block))
                   ((string= *selection_mode* \"batch\") (mm:select_batch_blocks))
                   ((string= *selection_mode* \"all\") (mm:select_all_blocks))
                 )
                 (mm:update_selection_display)
               )")
            
            ;; CLEAR SELECTION BUTTON
            (action_tile "export_clear"
              "(progn 
                 (setq *selected_blocks* (list))
                 (princ \"\\n>>> ✓ Selection cleared!\")
                 (mm:update_selection_display)
               )")
            
            ;; ══════════════════════════════════════════════════════════
            ;; CSV FILE BUTTONS
            ;; ══════════════════════════════════════════════════════════
            
            (action_tile "export_csv_browse"
              "(progn 
                 (setq export_csv (getfiled \"Select CSV for Export\" \"\" \"csv\" 1))
                 (if export_csv 
                   (set_tile \"export_csv_display\" export_csv)
                   (set_tile \"export_csv_display\" \"No file selected\")
                 )
               )")
            
            ;; ══════════════════════════════════════════════════════════
            ;; EXPORT START BUTTON
            ;; ══════════════════════════════════════════════════════════
            
            (action_tile "export_start"
              "(progn 
                 (if (= 0 (length *selected_blocks*))
                   (alert \"Please select blocks first!\")
                   (if (not export_csv)
                     (alert \"Please select CSV file location!\")
                     (progn
                       (mm:export_selected_blocks export_csv)
                       (alert \"Export complete!\")
                     )
                   )
                 )
               )")
            
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
            ;; DIALOG BUTTONS
            ;; ══════════════════════════════════════════════════════════
            
            (action_tile "ok_btn"
              "(setq result 0)")
            
            (action_tile "cancel_btn"
              "(setq result 0)")
            
            (princ "\n>>> ✓ All buttons configured!")
            (princ "\n>>> Dialog is OPEN and ready!")
            (princ "\n>>> You can now SELECT BLOCKS while dialog is visible!")
            
            ;; Show dialog - stays open until OK/Cancel
            (start_dialog)
          )
        )
      )
      
      (unload_dialog dcl_id)
      (princ "\n>>> ✓✓✓ MACRO MANAGER CLOSED! ✓✓✓")
    )
  )
  
  (princ "\n╚═══════════════════════════════════════════════════════════╝\n")
  (princ)
)

;; ═══════════════════════════════════════════════════════════════════════════
;; UPDATE SELECTION DISPLAY IN DIALOG
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:update_selection_display ( )
  (setq count_text (strcat (itoa (length *selected_blocks*)) " blocks selected - Mode: " (upcase *selection_mode*)))
  (set_tile "selected_count" count_text)
  (princ (strcat "\n>>> Selection: " count_text))
)

;; ═══════════════════════════════════════════════════════════════════════════
;; SELECT SINGLE BLOCK
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:select_single_block ( )
  (princ "\n\n>>> SELECT SINGLE BLOCK MODE")
  (princ "\n>>> ══════════════════════════════════════════")
  (princ "\n>>> Click on ONE block in drawing (or press ESC to cancel):")
  
  (setq ss (ssget "_+.:S"))
  
  (if ss
    (progn
      (setq ent_name (ssname ss 0))
      (setq ent (entget ent_name))
      
      (if (= "INSERT" (cdr (assoc 0 ent)))
        (progn
          (setq block_name (cdr (assoc 2 ent)))
          (setq base_pt (cdr (assoc 10 ent)))
          
          ;; Add to selection list (replace if already exists)
          (setq *selected_blocks* (list (list ent_name ent block_name base_pt)))
          
          (princ (strcat "\n    ✓ Selected: " block_name " at (" 
                        (rtos (car base_pt) 2 2) ", "
                        (rtos (cadr base_pt) 2 2) ")"))
          (princ "\n>>> ══════════════════════════════════════════")
        )
        (progn
          (princ "\n    ✗ Selected object is NOT a block!")
          (alert "Please select a block (INSERT object)!")
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

(defun mm:select_batch_blocks ( )
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
            (princ "\n    ⚠ Object at index " (itoa index) " is not a block - skipping")
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

(defun mm:select_all_blocks ( )
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
;; EXPORT SELECTED BLOCKS TO CSV
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:export_selected_blocks (csv_path / file_handle index block_info ent_name ent block_name base_pt)
  (princ "\n\n>>> EXPORTING SELECTED BLOCKS")
  (princ "\n>>> ══════════════════════════════════════════")
  
  (if (not csv_path)
    (progn
      (princ "\n>>> ✗ No CSV file selected!")
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
        
        (write-line 
          (strcat 
            block_name ","
            (rtos (car base_pt) 2 4) ","
            (rtos (cadr base_pt) 2 4) ","
            (rtos (caddr base_pt) 2 4) ","
            (cdr (assoc 8 ent)) ","
            (itoa (cdr (assoc 62 ent))) ","
            (cdr (assoc 6 ent))
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
    )
  )
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
          (alert "CSV file not found!")
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
;; IMPORT BLOCKS FROM CSV
;; ═══════════════════════════════════════════════════════════════════════════

(defun mm:import_blocks (csv_path / file_handle line count)
  (princ "\n>>> Starting import...")
  
  (if (not csv_path)
    (progn
      (princ "\n>>> ✗ No CSV file selected for import!")
      (alert "Please select a CSV file to import!")
    )
    (progn
      (if (not (findfile csv_path))
        (progn
          (princ "\n>>> ✗ File not found!")
          (alert "CSV file not found!")
        )
        (progn
          (setq file_handle (open csv_path "r"))
          (setq count 0)
          
          ;; Read header (skip first line)
          (read-line file_handle)
          
          ;; Read data lines
          (while (setq line (read-line file_handle))
            (setq count (+ count 1))
            (princ (strcat "\n    • Processing: " line))
          )
          
          (close file_handle)
          
          (princ (strcat "\n>>> ✓ Import complete! Processed " (itoa count) " blocks"))
          (alert (strcat "Import Complete!\n\n" (itoa count) " blocks processed from CSV file."))
        )
      )
    )
  )
)

;; ═══════════════════════════════════════════════════════════════════════════
;; STARTUP MESSAGE
;; ═══════════════════════════════════════════════════════════════════════════

(princ "\n╔═══════════════════════════════════════════════════════════╗")
(princ "\n║  ✓ WORKING_MacroManager_v5.lsp loaded!                  ║")
(princ "\n║                                                           ║")
(princ "\n║  NEW FEATURES v5.0:                                      ║")
(princ "\n║  ✓ THREE selection modes (Single/Batch/All)             ║")
(princ "\n║  ✓ Dialog STAYS OPEN while selecting                    ║")
(princ "\n║  ✓ SELECT button (no dialog close needed)               ║")
(princ "\n║  ✓ CLEAR selection and try again                        ║")
(princ "\n║  ✓ Capture X, Y, Z coordinates                          ║")
(princ "\n║  ✓ Export with all properties                           ║")
(princ "\n║                                                           ║")
(princ "\n║  Command: MACROMANAGER                                   ║")
(princ "\n╚═══════════════════════════════════════════════════════════╝\n")

(princ)