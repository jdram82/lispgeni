;;;============================================================================
;;; INTERACTIVE BLOCK EXPORT TEST
;;; Select blocks visually, export step-by-step with full diagnostics
;;;============================================================================

(defun C:TESTEXPORT ( / ss block_list block_name block_ent export_path method_choice
                       old_cmdecho old_filedia old_expert old_attreq result)
  
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║   INTERACTIVE BLOCK EXPORT TEST                          ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  (princ "\n")
  (princ "\nThis test will:")
  (princ "\n  1. Let you SELECT blocks in the drawing")
  (princ "\n  2. Extract block names from selections")
  (princ "\n  3. Export each block with live feedback")
  (princ "\n  4. Show exactly what works and what fails")
  (princ "\n")
  
  ;; Step 1: Select blocks
  (princ "\n→ STEP 1: SELECT BLOCKS")
  (princ "\n  Please select block references in the drawing...")
  (setq ss (ssget '((0 . "INSERT"))))
  
  (if (not ss)
    (progn
      (princ "\n✗ No blocks selected")
      (princ))
    (progn
      (princ (strcat "\n✓ Selected " (itoa (sslength ss)) " block references"))
      
      ;; Step 2: Extract unique block names
      (princ "\n\n→ STEP 2: EXTRACTING BLOCK NAMES")
      (setq block_list '())
      (setq i 0)
      (while (< i (sslength ss))
        (setq block_ent (ssname ss i))
        (setq block_name (cdr (assoc 2 (entget block_ent))))
        
        ;; Add to list if not already there
        (if (not (member block_name block_list))
          (progn
            (setq block_list (cons block_name block_list))
            (princ (strcat "\n  ✓ Found: " block_name))))
        
        (setq i (1+ i)))
      
      (princ (strcat "\n\n✓ Total unique blocks: " (itoa (length block_list))))
      
      ;; Step 3: Choose export location
      (princ "\n\n→ STEP 3: CHOOSE EXPORT LOCATION")
      (setq export_folder (getfiled "Select folder for exported DWG files" "" "" 1))
      
      (if (not export_folder)
        (progn
          (princ "\n✗ No folder selected")
          (princ))
        (progn
          (princ (strcat "\n✓ Export folder: " export_folder))
          
          ;; Step 4: Choose method
          (princ "\n\n→ STEP 4: CHOOSE EXPORT METHOD")
          (princ "\n  1 = COMMAND (recommended for ACADE)")
          (princ "\n  2 = vl-cmdf")
          (princ "\n  3 = VLA/ObjectDBX")
          (initget "1 2 3")
          (setq method_choice (getkword "\nSelect method [1/2/3] <1>: "))
          (if (not method_choice) (setq method_choice "1"))
          
          (princ (strcat "\n✓ Using Method " method_choice))
          
          ;; Step 5: Export each block
          (princ "\n\n→ STEP 5: EXPORTING BLOCKS")
          (princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
          
          ;; Save system variables
          (setq old_cmdecho (getvar "CMDECHO"))
          (setq old_filedia (getvar "FILEDIA"))
          (setq old_expert (getvar "EXPERT"))
          (setq old_attreq (getvar "ATTREQ"))
          
          (setvar "CMDECHO" 0)
          (setvar "FILEDIA" 0)
          (setvar "EXPERT" 5)
          (setvar "ATTREQ" 1)
          
          (setq success_count 0)
          (setq fail_count 0)
          
          ;; Process each block
          (foreach blk block_list
            (princ (strcat "\n\n[" (itoa (1+ (+ success_count fail_count))) "/" 
                          (itoa (length block_list)) "] Block: " blk))
            
            (setq export_path (strcat export_folder "\\" blk ".dwg"))
            (princ (strcat "\n    Target: " export_path))
            
            ;; Delete existing file
            (if (findfile export_path)
              (progn
                (princ "\n    Deleting existing file...")
                (vl-file-delete export_path)))
            
            ;; Export based on method
            (cond
              ;; Method 1: COMMAND
              ((= method_choice "1")
               (princ "\n    Method: COMMAND")
               (princ (strcat "\n    Executing WBLOCK..."))
               (setq result
                 (vl-catch-all-apply
                   (function (lambda ()
                     ;; Use pause to avoid path issues with spaces
                     (command "._-WBLOCK")
                     (command export_path)
                     (command "=")
                     (command blk)
                     (princ "\n    Waiting...")
                     (while (> (getvar "CMDACTIVE") 0)
                       (command ""))
                     T)))))
              
              ;; Method 2: vl-cmdf
              ((= method_choice "2")
               (princ "\n    Method: vl-cmdf")
               (setq result
                 (vl-catch-all-apply
                   (function (lambda ()
                     (vl-cmdf "._-WBLOCK")
                     (vl-cmdf export_path)
                     (vl-cmdf "=")
                     (vl-cmdf blk)
                     (while (> (getvar "CMDACTIVE") 0)
                       (vl-cmdf ""))
                     T)))))
              
              ;; Method 3: VLA
              ((= method_choice "3")
               (princ "\n    Method: VLA")
               (setq result
                 (vl-catch-all-apply
                   (function (lambda ( / acad doc)
                     (setq acad (vlax-get-acad-object))
                     (setq doc (vla-get-activedocument acad))
                     (vla-wblock doc export_path blk)
                     T)))))
            )
            
            ;; Check result
            (if (vl-catch-all-error-p result)
              (progn
                (princ (strcat "\n    ✗ ERROR: " (vl-catch-all-error-message result)))
                (setq fail_count (1+ fail_count)))
              (progn
                ;; Check if file exists
                (if (findfile export_path)
                  (progn
                    (princ (strcat "\n    ✓ SUCCESS - File created (" 
                                  (itoa (vl-file-size export_path)) " bytes)"))
                    (setq success_count (1+ success_count)))
                  (progn
                    (princ "\n    ✗ FAILED - Command ran but file not created")
                    (princ "\n    Possible causes:")
                    (princ "\n      • WBLOCK silently failed")
                    (princ "\n      • Security/permissions blocking file creation")
                    (princ "\n      • AutoCAD Electrical restriction")
                    (setq fail_count (1+ fail_count))))))
          )
          
          ;; Restore system variables
          (setvar "CMDECHO" old_cmdecho)
          (setvar "FILEDIA" old_filedia)
          (setvar "EXPERT" old_expert)
          (setvar "ATTREQ" old_attreq)
          
          ;; Summary
          (princ "\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
          (princ "\n→ EXPORT SUMMARY")
          (princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
          (princ (strcat "\n  Total blocks: " (itoa (length block_list))))
          (princ (strcat "\n  ✓ Successful: " (itoa success_count)))
          (princ (strcat "\n  ✗ Failed: " (itoa fail_count)))
          (princ (strcat "\n  Export folder: " export_folder))
          (princ "\n")
          
          (if (> success_count 0)
            (alert (strcat "✓ Export Complete!\n\n"
                          (itoa success_count) " blocks exported successfully\n"
                          (itoa fail_count) " blocks failed\n\n"
                          "Location: " export_folder))
            (alert (strcat "✗ Export Failed\n\n"
                          "No blocks were exported.\n\n"
                          "Possible issues:\n"
                          "• WBLOCK command is disabled\n"
                          "• File permissions\n"
                          "• AutoCAD Electrical restrictions\n\n"
                          "Try running CHECKWBLOCK command for diagnostics.")))
        ))
    ))
  (princ)
)

;;;============================================================================
;;; QUICK SINGLE BLOCK TEST
;;;============================================================================

(defun C:TESTBLOCK ( / blk_ent blk_name export_path result)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║   QUICK SINGLE BLOCK TEST                                ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (princ "\n\nSelect ONE block to test export...")
  (setq blk_ent (car (entsel "\nSelect block: ")))
  
  (if (not blk_ent)
    (princ "\n✗ No block selected")
    (progn
      (setq blk_name (cdr (assoc 2 (entget blk_ent))))
      (princ (strcat "\n✓ Selected: " blk_name))
      
      (setq export_path (strcat "C:\\TEMP\\" blk_name ".dwg"))
      (princ (strcat "\n✓ Export to: " export_path))
      
      ;; Delete existing
      (if (findfile export_path)
        (vl-file-delete export_path))
      
      ;; Try export
      (princ "\n\nExecuting WBLOCK...")
      (setvar "CMDECHO" 0)
      (setvar "FILEDIA" 0)
      (setvar "EXPERT" 5)
      (setvar "ATTREQ" 1)
      
      (setq result
        (vl-catch-all-apply
          (function (lambda ()
            (command "._-WBLOCK")
            (command export_path)
            (command "=")
            (command blk_name)
            (while (> (getvar "CMDACTIVE") 0)
              (command ""))
            T))))
      
      (if (vl-catch-all-error-p result)
        (princ (strcat "\n✗ ERROR: " (vl-catch-all-error-message result)))
        (progn
          (if (findfile export_path)
            (progn
              (princ "\n✓✓✓ SUCCESS! ✓✓✓")
              (princ (strcat "\n  File: " export_path))
              (princ (strcat "\n  Size: " (itoa (vl-file-size export_path)) " bytes")))
            (progn
              (princ "\n✗ File not created")
              (princ "\n  WBLOCK command ran but produced no output")))))
    ))
  (princ)
)

;;;============================================================================
;;; CHECK IF WBLOCK IS BLOCKED/DISABLED
;;;============================================================================

(defun C:CHECKWBLOCK ( / test_result)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║   CHECK WBLOCK AVAILABILITY                              ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (princ "\n\n→ Testing WBLOCK command availability...")
  
  ;; Try to start WBLOCK and cancel
  (setq test_result
    (vl-catch-all-apply
      (function (lambda ()
        (command "._-WBLOCK")
        (command)  ; Cancel
        T))))
  
  (if (vl-catch-all-error-p test_result)
    (progn
      (princ "\n✗ WBLOCK COMMAND IS BLOCKED OR DISABLED")
      (princ (strcat "\n  Error: " (vl-catch-all-error-message test_result)))
      (princ "\n\n→ This explains why exports are failing!")
      (princ "\n→ AutoCAD Electrical may have WBLOCK disabled for security.")
      (princ "\n\n→ ALTERNATIVE SOLUTIONS:")
      (princ "\n  1. Use BLOCK command to export blocks")
      (princ "\n  2. Use SAVE AS to create DWG files")
      (princ "\n  3. Check with IT about WBLOCK restrictions")
      (princ "\n  4. Try running AutoCAD as Administrator"))
    (progn
      (princ "\n✓ WBLOCK command is available")
      (princ "\n  The command works, but exports may still fail")))
  
  ;; Check security settings
  (princ "\n\n→ Security settings:")
  (princ (strcat "\n  SECURELOAD = " (itoa (getvar "SECURELOAD"))))
  (if (> (getvar "SECURELOAD") 0)
    (princ " ⚠ Restricted - may affect file operations"))
  
  (princ (strcat "\n  SECUREREMOTEACCESS = " (itoa (getvar "SECUREREMOTEACCESS"))))
  
  (princ)
)

;;;============================================================================
;;; LIST ALL BLOCKS IN DRAWING
;;;============================================================================

(defun C:LISTBLOCKS ( / blk_table blk_entry blk_list blk_name flags)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║   LIST ALL EXPORTABLE BLOCKS                             ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (princ "\n\n→ Scanning block table...")
  
  (setq blk_table (tblnext "BLOCK" T))
  (setq blk_list '())
  
  (while blk_table
    (setq blk_name (cdr (assoc 2 blk_table)))
    (setq flags (cdr (assoc 70 blk_table)))
    
    ;; Check if exportable (not XREF, not anonymous, not layout)
    (if (and (= (logand flags 4) 0)  ; Not XREF
             (not (wcmatch blk_name "`**"))  ; Not anonymous
             (not (wcmatch (strcase blk_name) "*MODEL_SPACE*,*PAPER_SPACE*")))  ; Not layout
      (setq blk_list (cons blk_name blk_list)))
    
    (setq blk_table (tblnext "BLOCK")))
  
  (princ (strcat "\n✓ Found " (itoa (length blk_list)) " exportable blocks:\n"))
  (princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  
  (foreach blk (reverse blk_list)
    (princ (strcat "\n  • " blk)))
  
  (princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  (princ "\n\nUse TESTEXPORT to export selected blocks")
  (princ)
)

(princ "\n╔══════════════════════════════════════════════════════════╗")
(princ "\n║ Interactive Block Export Tests Loaded                    ║")
(princ "\n╠══════════════════════════════════════════════════════════╣")
(princ "\n║ TESTEXPORT  - Select & export blocks interactively      ║")
(princ "\n║ TESTBLOCK   - Quick test with one selected block        ║")
(princ "\n║ LISTBLOCKS  - Show all exportable blocks in drawing     ║")
(princ "\n║ CHECKWBLOCK - Check if WBLOCK is disabled               ║")
(princ "\n╚══════════════════════════════════════════════════════════╝")
(princ)
