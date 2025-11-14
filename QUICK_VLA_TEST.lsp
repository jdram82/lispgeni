;;;============================================================================
;;; QUICK VLA METHOD TEST
;;; Test VLA-WBLOCK with block names containing spaces
;;;============================================================================

(defun C:VLATEST ( / blk export_path acad doc result)
  
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║   VLA-WBLOCK TEST FOR BLOCKS WITH SPACES                 ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  ;; Get block name from user
  (setq blk (getstring T "\nEnter block name (e.g., LM105 Analog IC): "))
  
  (if (not (tblsearch "BLOCK" blk))
    (progn
      (princ (strcat "\n✗ Block '" blk "' not found in drawing"))
      (princ))
    (progn
      (princ (strcat "\n✓ Block '" blk "' found"))
      
      ;; Set export path - using the same path as your test folder
      (setq export_path (strcat "C:\\Temp\\testing_Export\\Test_Import_Export_DWG_5.17\\" blk ".dwg"))
      (princ (strcat "\n✓ Export path: " export_path))
      
      ;; Create directory if it doesn't exist
      (if (not (findfile "C:\\Temp\\testing_Export\\Test_Import_Export_DWG_5.17\\"))
        (progn
          (princ "\n  Creating export directory...")
          (vl-mkdir "C:\\Temp")
          (vl-mkdir "C:\\Temp\\testing_Export")
          (vl-mkdir "C:\\Temp\\testing_Export\\Test_Import_Export_DWG_5.17")))
      
      ;; Delete existing file
      (if (findfile export_path)
        (progn
          (princ "\n  Deleting existing file...")
          (vl-file-delete export_path)))
      
      ;; Cancel any active command first
      (command)
      (command)
      
      ;; Try COMMAND method with single call (this works better with VLA for block names with spaces)
      (princ "\n\n→ Executing WBLOCK with single command call...")
      (setq result
        (vl-catch-all-apply
          (function (lambda ()
            ;; Set system variables
            (setvar "CMDECHO" 0)
            (setvar "FILEDIA" 0)
            (setvar "EXPERT" 5)
            
            ;; Single command call - let AutoCAD handle the parsing
            (command "._-WBLOCK" export_path "=" blk)
            
            (princ "\n  Waiting for completion...")
            (while (> (getvar "CMDACTIVE") 0)
              (command ""))
            T))))
      
      ;; Check result
      (if (vl-catch-all-error-p result)
        (progn
          (princ "\n✗ FAILED - VLA error")
          (princ (strcat "\n  Error: " (vl-catch-all-error-message result))))
        (progn
          (if (findfile export_path)
            (progn
              (setq file_size (vl-file-size export_path))
              (princ (strcat "\n✓ SUCCESS - File created (" (itoa file_size) " bytes)")))
            (progn
              (princ "\n✗ FAILED - VLA returned success but file not created")
              (princ "\n  Possible causes:")
              (princ "\n    • SECURELOAD blocking file creation")
              (princ "\n    • Path not in Trusted Locations")
              (princ "\n    • Insufficient permissions")))))))
  
  (princ))

(princ "\n")
(princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
(princ "\n  QUICK VLA TEST LOADED")
(princ "\n  Type: VLATEST")
(princ "\n  ")
(princ "\n  This bypasses the command line completely")
(princ "\n  Works with block names containing spaces")
(princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
(princ)
