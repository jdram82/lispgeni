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
      
      ;; Set export path
      (setq export_path (strcat "C:\\Temp\\testing_Export\\" blk ".dwg"))
      (princ (strcat "\n✓ Export path: " export_path))
      
      ;; Delete existing file
      (if (findfile export_path)
        (progn
          (princ "\n  Deleting existing file...")
          (vl-file-delete export_path)))
      
      ;; Try VLA-WBLOCK
      (princ "\n\n→ Executing VLA-WBLOCK...")
      (setq result
        (vl-catch-all-apply
          (function (lambda ()
            (setq acad (vlax-get-acad-object))
            (setq doc (vla-get-activedocument acad))
            (vla-wblock doc export_path blk)
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
