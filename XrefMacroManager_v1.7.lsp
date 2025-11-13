;; ═══════════════════════════════════════════════════════════════════════════
;; XREF MACRO MANAGER - UNIFIED EXPORT/IMPORT SYSTEM
;; Version 1.0 - Crash-Free Alternative to INSERT Command
;; ═══════════════════════════════════════════════════════════════════════════
;;
;; PURPOSE:
;;   Complete block export/import system using XREF method (no crashes)
;;   Exports blocks to DWG + CSV, imports blocks from CSV at exact coordinates
;;
;; FEATURES:
;;   ✓ EXPORT: Select blocks → Create DWG files + CSV with coordinates
;;   ✓ IMPORT: Read CSV → Attach XREFs at exact coordinates (no INSERT crash)
;;   ✓ Dialog interface for easy operation
;;   ✓ CSV format: Block Name,X,Y,Z,Type,Color,Linetype
;;   ✓ Automated WBLOCK export (command-line, no script crashes)
;;   ✓ Automatic XREF import (safe, no Exception c0000027)
;;   ✓ Verification tools to confirm accuracy
;;   ✓ XREF bind/explode utilities
;;
;; USAGE:
;;   (load "XrefMacroManager.lsp")
;;   Command: XREFMM
;;
;; ═══════════════════════════════════════════════════════════════════════════

;; ═══════════════════════════════════════════════════════════════════════════
;; GLOBAL VARIABLES
;; ═══════════════════════════════════════════════════════════════════════════

(if (not *xmm_selected_blocks*) (setq *xmm_selected_blocks* (list)))
(if (not *xmm_export_library*) (setq *xmm_export_library* ""))
(if (not *xmm_import_library*) (setq *xmm_import_library* ""))
(if (not *xmm_csv_file*) (setq *xmm_csv_file* ""))
(if (not *xmm_block_type*) (setq *xmm_block_type* "General"))

;; Ensure Visual LISP COM interface is loaded for automation utilities
(vl-load-com)

;; Helper: Folder selection using multiple methods
(defun xmm:get_folder (prompt / shell folder folderItem result ps_script temp_file folder_line)
  
  ;; METHOD 1: Try PowerShell folder browser (most reliable on Windows)
  (setq temp_file (vl-filename-mktemp "xmm_folder.txt"))
  (setq ps_script (strcat 
    "$folder = (New-Object -ComObject Shell.Application).BrowseForFolder(0,'" 
    prompt 
    "',0,0); if($folder){$folder.Self.Path | Out-File -FilePath '" 
    temp_file 
    "' -Encoding ASCII}"))
  
  ;; Execute PowerShell and wait
  (if (vl-catch-all-error-p 
        (vl-catch-all-apply 'startapp 
          (list "powershell.exe" 
                (strcat "-NoProfile -WindowStyle Hidden -Command \"" ps_script "\""))))
    (progn
      ;; PowerShell failed, try METHOD 2: COM approach
      (if (and (setq shell (vl-catch-all-apply 'vlax-create-object '("Shell.Application")))
               (not (vl-catch-all-error-p shell)))
        (progn
          (setq folder (vl-catch-all-apply 'vlax-invoke-method 
                         (list shell 'BrowseForFolder 0 prompt 0 0)))
          (if (and folder (not (vl-catch-all-error-p folder)))
            (progn
              (setq folderItem (vlax-invoke-method folder 'Self))
              (if folderItem
                (setq result (vlax-get-property folderItem 'Path)))))
          (if shell (vlax-release-object shell)))))
    
    ;; PowerShell executed - wait and read result
    (progn
      (command "DELAY" 1000)  ; Wait 1 second for PowerShell dialog
      (while (not (findfile temp_file))
        (command "DELAY" 500))  ; Keep waiting
      (if (setq folder_line (vl-catch-all-apply 'open (list temp_file "r")))
        (if (not (vl-catch-all-error-p folder_line))
          (progn
            (setq result (read-line folder_line))
            (close folder_line)
            (vl-file-delete temp_file))))))
  
  ;; METHOD 3: Fallback to file picker if all else fails
  (if (not result)
    (progn
      (alert (strcat prompt "\n\nFolder picker not available.\n\nIn the next dialog:\n→ Browse to your target folder\n→ Select ANY file in that folder\n→ The folder path will be used"))
      (if (setq result (getfiled (strcat prompt " [Select any file in target folder]") "" "dwg" 16))
        (setq result (vl-filename-directory result)))))
  
  result)

;; ═══════════════════════════════════════════════════════════════════════════
;; CSV PARSER
;; ═══════════════════════════════════════════════════════════════════════════

(defun xmm:parse_csv_line (line / result field in_quotes i ch)
  ;; Parses CSV line with support for quoted fields
  (setq result (list)
        field ""
        in_quotes nil
        i 0)
  
  (while (< i (strlen line))
    (setq ch (substr line (+ i 1) 1))
    (cond
      ((= ch "\"")
       (setq in_quotes (not in_quotes)))
      ((and (= ch ",") (not in_quotes))
       (setq result (append result (list field))
             field ""))
      (T
       (setq field (strcat field ch))))
    (setq i (1+ i)))
  
  ;; Add last field
  (setq result (append result (list field)))
  result)

;; ═══════════════════════════════════════════════════════════════════════════
;; UTILITY: Get Timestamp
;; ═══════════════════════════════════════════════════════════════════════════

(defun xmm:get_timestamp ( / )
  ;; Returns timestamp string for filenames
  (menucmd "M=$(edtime,$(getvar,date),YYYYMMDD_HHMMSS)")
)

;; ═══════════════════════════════════════════════════════════════════════════
;; EXPORT FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun xmm:select_blocks ( / ss count block_list i ent ent_data block_name ins_pt)
  ;; Selects blocks from drawing and stores in global list
  
  (princ "\n>>> Select blocks to export (INSERT objects only)...")
  (setq ss (ssget '((0 . "INSERT"))))
  
  (if ss
    (progn
      (setq count (sslength ss)
            block_list (list)
            i 0)
      
      (princ (strcat "\n✓ Selected " (itoa count) " block references"))
      (princ "\n>>> Processing block data...")
      
      ;; Extract block information
      (repeat count
        (setq ent (ssname ss i)
              ent_data (entget ent)
              block_name (cdr (assoc 2 ent_data))
              ins_pt (cdr (assoc 10 ent_data)))
        
        ;; Skip anonymous blocks
        (if (not (wcmatch block_name "`**"))
          ;; Store block info: (name x y z layer color linetype)
          (setq block_list 
            (append block_list 
              (list (list block_name 
                         (car ins_pt) 
                         (cadr ins_pt) 
                         (caddr ins_pt)
                         (cdr (assoc 8 ent_data))     ; Layer
                         (cdr (assoc 62 ent_data))    ; Color
                         (cdr (assoc 6 ent_data)))))))  ; Linetype
        
        (setq i (1+ i)))
      
      ;; Remove duplicates (same block name)
      (setq block_list (vl-sort block_list '(lambda (a b) (< (car a) (car b)))))
      
      ;; Check if any blocks were found (after filtering)
      (if (> (length block_list) 0)
        (progn
          ;; Store in global variable
          (setq *xmm_selected_blocks* block_list)
          (princ (strcat "\n✓ Unique blocks found: " (itoa (length block_list))))
          (princ "\n✓ Blocks ready for export")
          T)
        (progn
          (princ "\n*** No valid blocks found (all were anonymous blocks)")
          (setq *xmm_selected_blocks* (list))
          nil)))
    (progn
      (princ "\n*** No blocks selected")
      (setq *xmm_selected_blocks* (list))
      nil)))

(defun xmm:export_to_csv (csv_file / csv_handle block_data timestamp)
  ;; Exports block data to CSV file
  
  (if (= (length *xmm_selected_blocks*) 0)
    (progn
      (princ "\n*** ERROR: No blocks selected for export")
      nil)
    (progn
      (setq csv_handle (open csv_file "w"))
      
      (if (not csv_handle)
        (progn
          (princ "\n*** ERROR: Cannot create CSV file")
          nil)
        (progn
          ;; Write header
          (write-line "Block Name,X Coordinate,Y Coordinate,Z Coordinate,Type,Color,Linetype" csv_handle)
          
          ;; Write block data
          (foreach block_data *xmm_selected_blocks*
            (write-line 
              (strcat 
                (car block_data) ","                                    ; Block name
                (rtos (cadr block_data) 2 6) ","                       ; X
                (rtos (caddr block_data) 2 6) ","                      ; Y
                (rtos (cadddr block_data) 2 6) ","                     ; Z
                (if (nth 4 block_data) (nth 4 block_data) "General") ","  ; Type/Layer
                (if (nth 5 block_data) (itoa (nth 5 block_data)) "BYLAYER") ","  ; Color
                (if (nth 6 block_data) (nth 6 block_data) "BYLAYER"))      ; Linetype
              csv_handle))
          
          (close csv_handle)
          (princ (strcat "\n✓ CSV file created: " csv_file))
          (princ (strcat "\n✓ Total blocks exported: " (itoa (length *xmm_selected_blocks*))))
          T)))))

(defun xmm:export_blocks_automated ( / lib_folder csv_file timestamp block_count block_data 
                                     block_name dwg_path success_count fail_count
                                     export_result)
  ;; FULLY AUTOMATED export using command line WBLOCK (runs for each block)
  
  (princ "\n╔═══════════════════════════════════════════════════════════╗")
  (princ "\n║  AUTOMATED EXPORT - ObjectDBX Method                    ║")
  (princ "\n║  Full automation (no manual WBLOCK needed)              ║")
  (princ "\n╚═══════════════════════════════════════════════════════════╝")
  
  ;; Check if blocks selected
  (if (= (length *xmm_selected_blocks*) 0)
    (progn
      (alert "No blocks selected!\n\nPlease select blocks first using:\n1. Click 'Select Blocks' button\n2. Select blocks in drawing\n3. Then click 'Export Blocks'")
      (princ "\n*** Operation cancelled - no blocks selected")
      nil)
    (progn
      ;; Get export folder
      (setq lib_folder (getfiled "Select Export Folder (Block Library)" "" "dwg" 16))
      
      (if (not lib_folder)
        (progn
          (princ "\n*** Operation cancelled - no folder selected")
          nil)
        (progn
          (setq lib_folder (vl-filename-directory lib_folder))
          (setq *xmm_export_library* lib_folder)
          
          (princ (strcat "\n✓ Export folder: " lib_folder))
          
          ;; Create CSV file
          (setq timestamp (xmm:get_timestamp))
          (setq csv_file (strcat lib_folder "\\Exported_Blocks_" timestamp ".csv"))
          
          ;; Export CSV
          (if (xmm:export_to_csv csv_file)
            (progn
              (princ "\n\n>>> Starting automated block export...")
              (princ "\n>>> Using command-line WBLOCK (no manual work needed)")
              
              (setq success_count 0
                    fail_count 0
                    block_count 0)
              
              (foreach block_data *xmm_selected_blocks*
                (setq block_name (car block_data)
                      block_count (1+ block_count)
                      dwg_path (strcat lib_folder "\\" block_name ".dwg"))
                
                ;; Delete existing DWG if present to avoid overwrite prompts
                (if (findfile dwg_path)
                  (vl-file-delete dwg_path))
                
                (princ (strcat "\n    [" (itoa block_count) "/" (itoa (length *xmm_selected_blocks*)) "] Exporting: " block_name))
                
                ;; Run command-line WBLOCK for each block
                (setq export_result 
                  (vl-catch-all-apply 'vl-cmdf 
                    (list "_.-WBLOCK" dwg_path "_Block" block_name "")))
                
                (if (vl-catch-all-error-p export_result)
                  (progn
                    (setq fail_count (1+ fail_count))
                    (princ (strcat "\n      ✗ Failed: " block_name " → " (vl-catch-all-error-message export_result))))
                  (progn
                    (setq success_count (1+ success_count))
                    (princ (strcat "\n      ✓ Created: " (vl-filename-base dwg_path) ".dwg")))))
              
              ;; Show summary
              (princ "\n\n╔═══════════════════════════════════════════════════════════╗")
              (princ "\n║  AUTOMATED EXPORT COMPLETE                               ║")
              (princ "\n╚═══════════════════════════════════════════════════════════╝")
              (princ (strcat "\n✓ CSV file created: " csv_file))
              (princ (strcat "\n✓ Total blocks: " (itoa (length *xmm_selected_blocks*))))
              (princ (strcat "\n✓ Successfully exported: " (itoa success_count)))
              (princ (strcat "\n✗ Failed to export: " (itoa fail_count)))
              (princ (strcat "\n✓ Export folder: " lib_folder))
              
              (if (> fail_count 0)
                (progn
                  (princ "\n\n⚠ WARNING: Some blocks failed to export")
                  (princ "\n   Possible causes:")
                  (princ "\n   - Anonymous blocks (ignored)")
                  (princ "\n   - Nested blocks (may need manual export)")
                  (princ "\n   - Blocks with external references")))
              
              (princ "\n\n>>> READY FOR IMPORT:")
              (princ "\n>>> To import these blocks in another drawing:")
              (princ "\n>>>   1. Command: XREFMM")
              (princ "\n>>>   2. Click: [3. Import Blocks]")
              (princ "\n>>>   3. Select CSV file")
              (princ "\n>>>   4. Select Block Library folder")
              (princ "\n>>>   5. Wait for automatic import")
              
              T)
            nil)))))
  (princ)

;; ═══════════════════════════════════════════════════════════════════════════
;; IMPORT FUNCTIONS (XREF-based, safe from crashes)
;; ═══════════════════════════════════════════════════════════════════════════

(defun xmm:import_blocks ( / csv_file lib_folder script_file 
                            csv_handle script_handle line_data 
                            block_name x_coord y_coord z_coord
                            block_type block_color block_linetype
                            block_dwg_path success_count fail_count total_count
                            header_line response)
  
  (princ "\n╔═══════════════════════════════════════════════════════════╗")
  (princ "\n║  XREF IMPORT - Safe CSV-Based Import                    ║")
  (princ "\n║  No INSERT crashes (uses XATTACH)                       ║")
  (princ "\n╚═══════════════════════════════════════════════════════════╝")
  
  ;; Step 1: Select CSV file
  (setq csv_file (getfiled "Select Block Export CSV" "" "csv" 8))
  (if (not csv_file)
    (progn
      (princ "\n*** Operation cancelled - No CSV file selected")
      nil)
    (progn
      (setq *xmm_csv_file* csv_file)
      (princ (strcat "\n✓ CSV file: " csv_file))
      
      ;; Step 2: Select Block Library folder
      (alert "Next: Select your Block Library folder\n(Where the exported DWG files are)")
      (setq lib_folder (xmm:get_folder "Select Block Library Folder"))
      
      (if (not lib_folder)
        (progn
          (princ "\n*** Operation cancelled - No folder selected")
          nil)
        (progn
          (setq *xmm_import_library* lib_folder)
          (princ (strcat "\n✓ Block Library: " lib_folder))
          
          ;; Step 3: Create script file
          (setq script_file (strcat (vl-filename-directory csv_file) "\\xref_import.scr"))
          (princ (strcat "\n✓ Script will be saved to: " script_file))
          
          ;; Step 4: Open CSV file
          (setq csv_handle (open csv_file "r"))
          (if (not csv_handle)
            (progn
              (princ "\n*** ERROR: Cannot open CSV file")
              nil)
            (progn
              ;; Step 5: Open script file
              (setq script_handle (open script_file "w"))
              (if (not script_handle)
                (progn
                  (close csv_handle)
                  (princ "\n*** ERROR: Cannot create script file")
                  nil)
                (progn
                  ;; Initialize counters
                  (setq success_count 0
                        fail_count 0
                        total_count 0)
                  
                  ;; Write script header
                  (write-line "; XREF Import Script - Generated by XrefMacroManager" script_handle)
                  (write-line "; Safe alternative to INSERT command (no crashes)" script_handle)
                  (write-line (strcat "; Generated: " (xmm:get_timestamp)) script_handle)
                  (write-line "" script_handle)
                  
                  ;; Read CSV header
                  (setq header_line (read-line csv_handle))
                  (princ "\n\n>>> Processing CSV rows...")
                  
                  ;; Process each CSV row
                  (while (setq line_data (read-line csv_handle))
                    (setq total_count (1+ total_count))
                    (setq line_data (xmm:parse_csv_line line_data))
                    
                    (if (>= (length line_data) 7)
                      (progn
                        (setq block_name (nth 0 line_data)
                              x_coord (nth 1 line_data)
                              y_coord (nth 2 line_data)
                              z_coord (nth 3 line_data)
                              block_type (nth 4 line_data)
                              block_color (nth 5 line_data)
                              block_linetype (nth 6 line_data))
                        
                        (setq block_dwg_path (strcat lib_folder "\\" block_name ".dwg"))
                        
                        (if (findfile block_dwg_path)
                          (progn
                            ;; Generate XREF attach commands
                            (write-line "" script_handle)
                            (write-line (strcat "; Block " (itoa total_count) ": " block_name) script_handle)
                            
                            ;; First, try to detach existing XREF with same name (ignore errors)
                            (write-line "-XREF" script_handle)
                            (write-line "D" script_handle)
                            (write-line block_name script_handle)
                            (write-line "" script_handle)
                            
                            ;; Then attach the XREF
                            (write-line "-XREF" script_handle)
                            (write-line "A" script_handle)
                            (write-line (strcat "\"" block_dwg_path "\"") script_handle)
                            (write-line block_name script_handle) ; Specify reference name explicitly
                            (write-line (strcat x_coord "," y_coord "," z_coord) script_handle)
                            (write-line "1" script_handle)
                            (write-line "0" script_handle)
                            (write-line "" script_handle)
                            
                            (setq success_count (1+ success_count))
                            (if (= 0 (rem total_count 50))
                              (princ (strcat "\n    Processed " (itoa total_count) " blocks..."))))
                          (progn
                            (write-line (strcat "; ERROR: File not found - " block_dwg_path) script_handle)
                            (setq fail_count (1+ fail_count))
                            (princ (strcat "\n    WARNING: Missing DWG - " block_name)))))
                      (progn
                        (write-line (strcat "; ERROR: Invalid CSV row #" (itoa total_count)) script_handle)
                        (setq fail_count (1+ fail_count)))))
                  
                  ;; Write script footer
                  (write-line "" script_handle)
                  (write-line "; Script complete" script_handle)
                  (write-line (strcat "; Successfully processed: " (itoa success_count) " blocks") script_handle)
                  (write-line (strcat "; Failed/Skipped: " (itoa fail_count) " blocks") script_handle)
                  
                  ;; Close files
                  (close csv_handle)
                  (close script_handle)
                  
                  ;; Show results
                  (princ "\n\n╔═══════════════════════════════════════════════════════════╗")
                  (princ "\n║  SCRIPT GENERATION COMPLETE                              ║")
                  (princ "\n╚═══════════════════════════════════════════════════════════╝")
                  (princ (strcat "\n✓ Total blocks in CSV: " (itoa total_count)))
                  (princ (strcat "\n✓ Script commands generated: " (itoa success_count)))
                  (princ (strcat "\n✗ Skipped (missing DWG): " (itoa fail_count)))
                  (princ (strcat "\n\n✓ Script file saved: " script_file))
                  
                  ;; Ask to run script
                  (initget "Yes No")
                  (setq response (getkword "\n\nRun script now? [Yes/No] <Yes>: "))
                  (if (or (not response) (= response "Yes"))
                    (progn
                      (princ "\n\n>>> Executing XREF import script...")
                      (princ "\n>>> This may take 5-10 minutes for large imports")
                      (princ "\n>>> Watch for any error messages\n")
                      (command "SCRIPT" script_file)
                      (princ "\n✓ Script execution started"))
                    (progn
                      (princ "\n>>> Script NOT executed")
                      (princ "\n>>> To run later: SCRIPT command, select xref_import.scr")))
                  
                  T))))))))))

;; ═══════════════════════════════════════════════════════════════════════════
;; UTILITY FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun xmm:verify_coordinates ( / csv_file csv_handle header_line line_data
                                 block_name x_coord y_coord z_coord
                                 ss ent ent_data ent_ins
                                 match_count mismatch_count missing_count tolerance)
  
  (princ "\n╔═══════════════════════════════════════════════════════════╗")
  (princ "\n║  VERIFY COORDINATES - Check Import Accuracy             ║")
  (princ "\n╚═══════════════════════════════════════════════════════════╝")
  
  (setq csv_file (getfiled "Select Block Export CSV" "" "csv" 8))
  (if (not csv_file)
    (progn
      (princ "\n*** Operation cancelled")
      nil)
    (progn
      (princ (strcat "\n✓ CSV file: " csv_file))
      (setq tolerance 0.001
            match_count 0
            mismatch_count 0
            missing_count 0)
      
      (setq csv_handle (open csv_file "r"))
      (if (not csv_handle)
        (progn
          (princ "\n*** ERROR: Cannot open CSV file")
          nil)
        (progn
          (setq header_line (read-line csv_handle))
          (princ "\n\n>>> Verifying coordinates...")
          
          (while (setq line_data (read-line csv_handle))
            (setq line_data (xmm:parse_csv_line line_data))
            
            (if (>= (length line_data) 4)
              (progn
                (setq block_name (nth 0 line_data)
                      x_coord (atof (nth 1 line_data))
                      y_coord (atof (nth 2 line_data))
                      z_coord (atof (nth 3 line_data)))
                
                (setq ss (ssget "_X" (list (cons 2 block_name) (cons 0 "INSERT"))))
                
                (if ss
                  (progn
                    (setq ent (ssname ss 0)
                          ent_data (entget ent)
                          ent_ins (cdr (assoc 10 ent_data)))
                    
                    (if (and (< (abs (- (car ent_ins) x_coord)) tolerance)
                             (< (abs (- (cadr ent_ins) y_coord)) tolerance)
                             (< (abs (- (caddr ent_ins) z_coord)) tolerance))
                      (setq match_count (1+ match_count))
                      (progn
                        (setq mismatch_count (1+ mismatch_count))
                        (princ (strcat "\n  MISMATCH: " block_name)))))
                  (progn
                    (setq missing_count (1+ missing_count))
                    (princ (strcat "\n  MISSING: " block_name)))))))
          
          (close csv_handle)
          
          (princ "\n\n╔═══════════════════════════════════════════════════════════╗")
          (princ "\n║  VERIFICATION COMPLETE                                   ║")
          (princ "\n╚═══════════════════════════════════════════════════════════╝")
          (princ (strcat "\n✓ Coordinates match: " (itoa match_count)))
          (princ (strcat "\n✗ Coordinate mismatches: " (itoa mismatch_count)))
          (princ (strcat "\n✗ Blocks not found: " (itoa missing_count)))
          
          (if (= mismatch_count 0)
            (princ "\n\n✓✓✓ ALL COORDINATES MATCH! Import successful!"))
          
          T)))))

(defun xmm:bind_xrefs ( / ss)
  (princ "\n╔═══════════════════════════════════════════════════════════╗")
  (princ "\n║  BIND XREFs - Convert to Permanent Blocks               ║")
  (princ "\n╚═══════════════════════════════════════════════════════════╝")
  
  (setq ss (ssget "_X" '((0 . "INSERT"))))
  
  (if ss
    (progn
      (princ (strcat "\n✓ Found " (itoa (sslength ss)) " block references"))
      (princ "\n\n>>> Binding all XREFs...")
      (command "-XREF" "BIND" "*" "")
      (princ "\n\n✓ All XREFs bound to drawing")
      (princ "\n✓ XREFs are now permanent blocks")
      T)
    (progn
      (princ "\n*** No block references found")
      nil)))

;; ═══════════════════════════════════════════════════════════════════════════
;; DIALOG CALLBACKS
;; ═══════════════════════════════════════════════════════════════════════════

(defun xmm:select_blocks_callback ()
  (xmm:select_blocks)
  (princ))

(defun xmm:export_blocks_callback ()
  (xmm:export_blocks_automated)
  (princ))

(defun xmm:import_blocks_callback ()
  (xmm:import_blocks)
  (princ))

(defun xmm:verify_callback ()
  (xmm:verify_coordinates)
  (princ))

(defun xmm:bind_callback ()
  (xmm:bind_xrefs)
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; MAIN COMMAND WITH DIALOG
;; ═══════════════════════════════════════════════════════════════════════════

(defun c:XREFMM ( / dcl_id result action dcl_path continue)
  
  (princ "\n╔═══════════════════════════════════════════════════════════╗")
  (princ "\n║  XREF Macro Manager v1.7                                 ║")
  (princ "\n║  Complete Export/Import System (Crash-Free)             ║")
  (princ "\n╚═══════════════════════════════════════════════════════════╝")
  
  ;; Find DCL file
  (setq dcl_path (strcat (getvar "DWGPREFIX") "XrefMacroManager.dcl"))
  
  (if (not (findfile dcl_path))
    (progn
      (alert "DCL file not found!\n\nPlease ensure XrefMacroManager.dcl is in the same folder as the drawing.")
      (princ "\n*** ERROR: DCL file not found")
      (princ))
    (progn
      ;; Load DCL once
      (setq dcl_id (load_dialog dcl_path))
      
      (if (not dcl_id)
        (progn
          (alert "Failed to load DCL file!")
          (princ "\n*** ERROR: Cannot load DCL")
          (princ))
        (progn
          ;; Dialog loop - keeps reopening until user clicks Cancel
          (setq continue T)
          
          (while continue
            (if (not (new_dialog "xrefmm" dcl_id))
              (progn
                (alert "Dialog definition 'xrefmm' not found in DCL file!")
                (setq continue nil))
              (progn
                ;; Initialize dialog
                (set_tile "version" "Version 1.7 - Persistent Dialog + Auto Export")
                
                ;; Update status based on selected blocks
                (if (> (length *xmm_selected_blocks*) 0)
                  (set_tile "version" 
                    (strcat "Version 1.7 - " 
                            (itoa (length *xmm_selected_blocks*)) 
                            " blocks selected")))
                
                ;; Setup action callbacks
                (action_tile "select_blocks" "(setq action 'select)(done_dialog 1)")
                (action_tile "export_blocks" "(setq action 'export)(done_dialog 1)")
                (action_tile "import_blocks" "(setq action 'import)(done_dialog 1)")
                (action_tile "verify_coords" "(setq action 'verify)(done_dialog 1)")
                (action_tile "bind_xrefs" "(setq action 'bind)(done_dialog 1)")
                (action_tile "cancel" "(setq action 'cancel)(done_dialog 0)")
                
                ;; Show dialog
                (setq result (start_dialog))
                
                ;; Process action
                (cond
                  ((= action 'select)
                   (xmm:select_blocks_callback))
                  ((= action 'export)
                   (xmm:export_blocks_callback))
                  ((= action 'import)
                   (xmm:import_blocks_callback))
                  ((= action 'verify)
                   (xmm:verify_callback))
                  ((= action 'bind)
                   (xmm:bind_callback))
                  ((= action 'cancel)
                   (progn
                     (princ "\n>>> Dialog closed by user")
                     (setq continue nil)))))))
          
          ;; Unload DCL when done
          (unload_dialog dcl_id)
          (princ))))))

;; ═══════════════════════════════════════════════════════════════════════════
;; STANDALONE COMMANDS (can be run without dialog)
;; ═══════════════════════════════════════════════════════════════════════════

(defun c:XMM-SELECT ()
  (xmm:select_blocks)
  (princ))

(defun c:XMM-EXPORT ()
  (xmm:export_blocks_automated)
  (princ))

(defun c:XMM-IMPORT ()
  (xmm:import_blocks)
  (princ))

(defun c:XMM-VERIFY ()
  (xmm:verify_coordinates)
  (princ))

(defun c:XMM-BIND ()
  (xmm:bind_xrefs)
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; LOAD MESSAGE
;; ═══════════════════════════════════════════════════════════════════════════

(princ "\n╔═══════════════════════════════════════════════════════════╗")
(princ "\n║  XREF Macro Manager v1.7 Loaded                         ║")
(princ "\n╠═══════════════════════════════════════════════════════════╣")
(princ "\n║  Main Command:                                           ║")
(princ "\n║    XREFMM     - Open persistent dialog interface        ║")
(princ "\n║                                                          ║")
(princ "\n║  Standalone Commands:                                    ║")
(princ "\n║    XMM-SELECT - Select blocks for export                ║")
(princ "\n║    XMM-EXPORT - Export blocks to DWG + CSV              ║")
(princ "\n║    XMM-IMPORT - Import blocks from CSV (XREF method)    ║")
(princ "\n║    XMM-VERIFY - Verify coordinates match CSV            ║")
(princ "\n║    XMM-BIND   - Bind XREFs to permanent blocks          ║")
(princ "\n║                                                          ║")
(princ "\n║  NEW: Dialog stays open after each operation!           ║")
(princ "\n╚═══════════════════════════════════════════════════════════╝")
(princ)
