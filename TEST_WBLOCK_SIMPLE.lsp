;;;============================================================================
;;; SIMPLE WBLOCK TEST - Space in Block Name Handler
;;; Test if spaces in block names cause WBLOCK to fail
;;;============================================================================

(defun C:TESTWBLOCK ( / block_name safe_name test_path result)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ SIMPLE WBLOCK TEST - Space Handler                      ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  ;; Get block name from user
  (setq block_name (getstring T "\nEnter block name to test: "))
  
  (if (not block_name)
    (princ "\n✗ No block name entered")
    (progn
      ;; Check if block exists
      (if (not (tblsearch "BLOCK" block_name))
        (princ (strcat "\n✗ Block '" block_name "' not found"))
        (progn
          (princ (strcat "\n→ Testing block: " block_name))
          
          ;; Check for spaces
          (if (vl-string-search " " block_name)
            (progn
              (princ "\n⚠ WARNING: Block name contains spaces!")
              (princ "\n  This may cause WBLOCK to fail.")
              (setq safe_name (vl-string-subst "_" " " block_name))
              (princ (strcat "\n  Suggested safe filename: " safe_name ".dwg")))
            (princ "\n✓ Block name has no spaces"))
          
          ;; Test in temp directory with safe filename
          (setq test_path (strcat (getenv "TEMP") "\\" 
                                  (if (vl-string-search " " block_name)
                                      safe_name
                                      block_name)
                                  ".dwg"))
          
          (princ (strcat "\n\n→ Test 1: Export to TEMP folder"))
          (princ (strcat "\n  Path: " test_path))
          
          ;; Delete existing
          (if (findfile test_path)
            (vl-file-delete test_path))
          
          ;; Try WBLOCK
          (princ "\n  Executing WBLOCK...")
          (setq result
            (vl-catch-all-apply
              '(lambda ()
                 (command "._-WBLOCK" test_path "=" block_name)
                 (while (> (getvar "CMDACTIVE") 0)
                   (command ""))
                 T)))
          
          (if (vl-catch-all-error-p result)
            (princ (strcat "\n  ✗ ERROR: " (vl-catch-all-error-message result)))
            (progn
              (if (findfile test_path)
                (progn
                  (princ "\n  ✓ SUCCESS! File created")
                  (princ (strcat "\n  Size: " (itoa (vl-file-size test_path)) " bytes")))
                (progn
                  (princ "\n  ✗ FAILED: File not created")
                  (princ "\n  → The WBLOCK command executed but no file was written")
                  (princ "\n  → This suggests AutoCAD Electrical may block WBLOCK")))))
          
          ;; Test 2: Try with quoted block name
          (princ "\n\n→ Test 2: Using PAUSE for manual input")
          (princ "\n  This will let you manually respond to WBLOCK prompts")
          (princ "\n  When prompted:")
          (princ (strcat "\n    File name: " test_path))
          (princ (strcat "\n    Block: " block_name))
          (princ "\n\n  Press ENTER to continue or ESC to skip...")
          
          (if (grread)
            (progn
              (if (findfile test_path)
                (vl-file-delete test_path))
              
              (princ "\n  Starting manual WBLOCK...")
              (command "._-WBLOCK")
              (princ "\n  → Enter file path when prompted...")
              (command pause)
              (princ "\n  → Enter = and block name when prompted...")
              (command pause)
              
              (if (findfile test_path)
                (princ "\n  ✓ Manual WBLOCK succeeded!")
                (princ "\n  ✗ Manual WBLOCK also failed")))
            (princ "\n  Test 2 skipped"))
          
          (princ "\n\n✓ Test completed")
        )
      )
    )
  )
  (princ)
)

;;;============================================================================
;;; TEST: Direct WBLOCK with no spaces
;;;============================================================================

(defun C:TESTWBLOCK2 ( / )
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ DIRECT WBLOCK TEST - No Variables                       ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (princ "\n→ This will execute WBLOCK with hardcoded test values")
  (princ "\n  File: C:\\TEMP\\TEST.DWG")
  (princ "\n  Block: [you specify]")
  
  (setq tblock (getstring T "\nEnter block name: "))
  
  (if tblock
    (progn
      (if (findfile "C:\\TEMP\\TEST.DWG")
        (vl-file-delete "C:\\TEMP\\TEST.DWG"))
      
      (princ "\n\nExecuting: (command \"._-WBLOCK\" \"C:\\\\TEMP\\\\TEST.DWG\" \"=\" blockname)")
      (command "._-WBLOCK" "C:\\TEMP\\TEST.DWG" "=" tblock)
      (while (> (getvar "CMDACTIVE") 0)
        (command ""))
      
      (if (findfile "C:\\TEMP\\TEST.DWG")
        (princ "\n✓ SUCCESS!")
        (princ "\n✗ FAILED - file not created")))
    (princ "\n✗ No block name entered"))
  
  (princ)
)

;;;============================================================================
;;; TEST: Check WBLOCK availability
;;;============================================================================

(defun C:CHECKWBLOCK ( / cmd_result)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ CHECK WBLOCK COMMAND                                     ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (princ "\n→ Checking if WBLOCK command is available...")
  
  ;; Try to get command name
  (setq cmd_result
    (vl-catch-all-apply
      '(lambda ()
         (command "._-WBLOCK")
         (command)  ; Cancel
         T)))
  
  (if (vl-catch-all-error-p cmd_result)
    (progn
      (princ "\n✗ WBLOCK command error:")
      (princ (strcat "\n  " (vl-catch-all-error-message cmd_result)))
      (princ "\n\n→ Possible causes:")
      (princ "\n  • WBLOCK is disabled in AutoCAD Electrical")
      (princ "\n  • Security settings block WBLOCK")
      (princ "\n  • Command is redirected/overridden"))
    (princ "\n✓ WBLOCK command is available"))
  
  ;; Check system variables
  (princ "\n\n→ System variables that affect WBLOCK:")
  (princ (strcat "\n  SECURELOAD = " (itoa (getvar "SECURELOAD"))
                 (if (= (getvar "SECURELOAD") 0) " ✓ (unrestricted)" " ⚠ (restricted)")))
  (princ (strcat "\n  FILEDIA = " (itoa (getvar "FILEDIA"))
                 (if (= (getvar "FILEDIA") 0) " ✓ (no dialogs)" " ⚠ (dialogs)")))
  
  (princ)
)

(princ "\n╔══════════════════════════════════════════════════════════╗")
(princ "\n║ WBLOCK Tests Loaded                                      ║")
(princ "\n║ Commands: TESTWBLOCK, TESTWBLOCK2, CHECKWBLOCK           ║")
(princ "\n╚══════════════════════════════════════════════════════════╝")
(princ)
