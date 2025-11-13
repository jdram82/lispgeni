;;;============================================================================
;;; MACROMANAGER DIAGNOSTIC & TEST UTILITY
;;; Purpose: Test each export/import method step-by-step to identify failures
;;; Version: 1.0
;;; Date: November 13, 2025
;;;============================================================================

(defun C:MMTEST ( / choice)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║   MACROMANAGER DIAGNOSTIC & TEST UTILITY                ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  (princ "\n")
  (princ "\n  1. Test Platform Detection")
  (princ "\n  2. Test Block Validation")
  (princ "\n  3. Test System Variables")
  (princ "\n  4. Test File Path Creation")
  (princ "\n  5. Test WBLOCK Method 0 (Platform-Optimized)")
  (princ "\n  6. Test WBLOCK Method 1 (vl-cmdf)")
  (princ "\n  7. Test WBLOCK Method 2 (Script Generation)")
  (princ "\n  8. Test WBLOCK Method 3 (ObjectDBX)")
  (princ "\n  9. Test WBLOCK Method 4 (COMMAND)")
  (princ "\n 10. Test Script File Execution")
  (princ "\n 11. Test Single Block Export (All Methods)")
  (princ "\n 12. Verify Exported DWG File")
  (princ "\n  0. Exit")
  (princ "\n")
  (initget "1 2 3 4 5 6 7 8 9 10 11 12 0")
  (setq choice (getkword "\nSelect test [1-12/0]: "))
  
  (cond
    ((= choice "1") (test_platform_detection))
    ((= choice "2") (test_block_validation))
    ((= choice "3") (test_system_variables))
    ((= choice "4") (test_file_path_creation))
    ((= choice "5") (test_wblock_method0))
    ((= choice "6") (test_wblock_method1))
    ((= choice "7") (test_wblock_method2))
    ((= choice "8") (test_wblock_method3))
    ((= choice "9") (test_wblock_method4))
    ((= choice "10") (test_script_execution))
    ((= choice "11") (test_single_block_all_methods))
    ((= choice "12") (test_verify_dwg))
    ((= choice "0") (princ "\n>>> Exiting diagnostic utility."))
    (T (princ "\n>>> Invalid choice."))
  )
  (princ)
)

;;;============================================================================
;;; TEST 1: PLATFORM DETECTION
;;;============================================================================
(defun test_platform_detection ( / product platform)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ TEST 1: PLATFORM DETECTION                              ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (setq product (getvar "PRODUCT"))
  (princ (strcat "\n✓ PRODUCT variable: " product))
  
  ;; Check for Electrical-specific indicators
  (princ "\n\n→ Checking for AutoCAD Electrical indicators:")
  (princ (strcat "\n  PRODUCT contains 'ELECTRICAL': " 
    (if (wcmatch (strcase product) "*ELECTRICAL*") "YES" "NO")))
  
  ;; Check for ACET (AutoCAD Electrical Toolkit)
  (princ (strcat "\n  ACETUTIL.ARX found: " 
    (if (findfile "acetutil.arx") "YES" "NO")))
  
  ;; Check for Electrical project variable
  (princ (strcat "\n  WDPROJECTNAMEEX variable: " 
    (if (vl-catch-all-error-p (vl-catch-all-apply 'getvar '("WDPROJECTNAMEEX")))
        "NOT FOUND (not Electrical)"
        (strcat "FOUND - Value: " (vl-princ-to-string (getvar "WDPROJECTNAMEEX"))))))
  
  ;; Detect platform with enhanced logic
  (setq platform
    (cond
      ((wcmatch (strcase product) "*BRICSCAD*") "BRICSCAD")
      ((or (wcmatch (strcase product) "*ELECTRICAL*")
           (findfile "acetutil.arx")
           (not (vl-catch-all-error-p (vl-catch-all-apply 'getvar '("WDPROJECTNAMEEX")))))
       "ACADE")
      ((wcmatch (strcase product) "*AUTOCAD*") "AUTOCAD")
      (T "UNKNOWN")
    ))
  
  (princ (strcat "\n\n✓ Detected platform: " platform))
  
  (cond
    ((equal platform "ACADE")
     (princ "\n✓ AutoCAD Electrical detected")
     (princ "\n  → Will use COMMAND method (Method 4 pattern)")
     (princ "\n  → ATTREQ will be set to 1 (preserve attributes)"))
    ((equal platform "BRICSCAD")
     (princ "\n✓ BricsCAD detected")
     (princ "\n  → Will use vl-cmdf method"))
    (T
     (princ "\n✓ Standard AutoCAD detected")
     (princ "\n  → Will use vl-cmdf method"))
  )
  
  (princ "\n✓ Test completed successfully")
  (princ)
)

;;;============================================================================
;;; TEST 2: BLOCK VALIDATION
;;;============================================================================
(defun test_block_validation ( / block_name block_def)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ TEST 2: BLOCK VALIDATION                                ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (setq block_name (getstring T "\nEnter block name to test: "))
  
  (if (not block_name)
    (progn
      (princ "\n✗ No block name entered")
      (princ))
    (progn
      (princ (strcat "\n→ Testing block: " block_name))
      
      ;; Test 1: tblsearch
      (setq block_def (tblsearch "BLOCK" block_name))
      (if block_def
        (progn
          (princ "\n✓ Block found in BLOCK table")
          (princ (strcat "\n  Block name: " (cdr (assoc 2 block_def))))
          (princ (strcat "\n  Block flags: " (itoa (cdr (assoc 70 block_def))))))
        (princ "\n✗ Block NOT found in BLOCK table"))
      
      ;; Test 2: Check if external reference
      (if (and block_def (> (logand (cdr (assoc 70 block_def)) 4) 0))
        (princ "\n✗ Block is an external reference (XREF)")
        (princ "\n✓ Block is not an XREF"))
      
      ;; Test 3: Check if anonymous
      (if (and block_def (wcmatch block_name "`**"))
        (princ "\n✗ Block is anonymous (starts with *)")
        (princ "\n✓ Block is not anonymous"))
      
      ;; Test 4: Check if layout
      (if (and block_def (wcmatch (strcase block_name) "*MODEL_SPACE*,*PAPER_SPACE*"))
        (princ "\n✗ Block is a layout block")
        (princ "\n✓ Block is not a layout block"))
      
      ;; Final verdict
      (if (and block_def
               (= (logand (cdr (assoc 70 block_def)) 4) 0)
               (not (wcmatch block_name "`**"))
               (not (wcmatch (strcase block_name) "*MODEL_SPACE*,*PAPER_SPACE*")))
        (princ "\n\n✓ Block is VALID for export")
        (princ "\n\n✗ Block is INVALID for export"))
      
      (princ)
    )
  )
)

;;;============================================================================
;;; TEST 3: SYSTEM VARIABLES
;;;============================================================================
(defun test_system_variables ( / vars)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ TEST 3: SYSTEM VARIABLES                                ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (princ "\n→ Current System Variable Values:")
  (princ (strcat "\n  CMDECHO = " (itoa (getvar "CMDECHO")) 
                 (if (= (getvar "CMDECHO") 0) " ✓ (silent)" " ⚠ (echo on)")))
  (princ (strcat "\n  FILEDIA = " (itoa (getvar "FILEDIA"))
                 (if (= (getvar "FILEDIA") 0) " ✓ (no dialogs)" " ⚠ (dialogs on)")))
  (princ (strcat "\n  EXPERT = " (itoa (getvar "EXPERT"))
                 (if (= (getvar "EXPERT") 5) " ✓ (suppress all)" " ⚠ (prompts on)")))
  (princ (strcat "\n  ATTREQ = " (itoa (getvar "ATTREQ"))
                 (if (= (getvar "ATTREQ") 1) " ✓ (attributes on)" " ⚠ (attributes off)")))
  (princ (strcat "\n  CMDACTIVE = " (itoa (getvar "CMDACTIVE"))
                 (if (= (getvar "CMDACTIVE") 0) " ✓ (no command)" " ⚠ (command active)")))
  (princ (strcat "\n  OSMODE = " (itoa (getvar "OSMODE"))
                 (if (= (getvar "OSMODE") 0) " ✓ (osnap off)" " ⚠ (osnap on)")))
  
  (princ "\n\n→ Testing system variable changes:")
  (setq vars (list
    (cons "CMDECHO" (getvar "CMDECHO"))
    (cons "FILEDIA" (getvar "FILEDIA"))
    (cons "EXPERT" (getvar "EXPERT"))
    (cons "ATTREQ" (getvar "ATTREQ"))
  ))
  
  (princ "\n  Setting test values...")
  (setvar "CMDECHO" 0)
  (setvar "FILEDIA" 0)
  (setvar "EXPERT" 5)
  (setvar "ATTREQ" 1)
  (princ " ✓")
  
  (princ "\n  Verifying changes...")
  (if (and (= (getvar "CMDECHO") 0)
           (= (getvar "FILEDIA") 0)
           (= (getvar "EXPERT") 5)
           (= (getvar "ATTREQ") 1))
    (princ " ✓ All variables set correctly")
    (princ " ✗ Some variables failed to set"))
  
  (princ "\n  Restoring original values...")
  (foreach var vars
    (setvar (car var) (cdr var)))
  (princ " ✓")
  
  (princ "\n✓ System variable test completed")
  (princ)
)

;;;============================================================================
;;; TEST 4: FILE PATH CREATION
;;;============================================================================
(defun test_file_path_creation ( / folder_path block_name file_path file_handle)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ TEST 4: FILE PATH CREATION                              ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (setq folder_path (getfiled "Select folder for test" "" "" 1))
  
  (if (not folder_path)
    (progn
      (princ "\n✗ No folder selected")
      (princ))
    (progn
      (setq block_name (getstring T "\nEnter test block name: "))
      
      (if (not block_name)
        (progn
          (princ "\n✗ No block name entered")
          (princ))
        (progn
          (setq file_path (strcat folder_path "\\" block_name ".dwg"))
          
          (princ "\n→ Testing file path creation:")
          (princ (strcat "\n  Folder: " folder_path))
          (princ (strcat "\n  Block: " block_name))
          (princ (strcat "\n  Full path: " file_path))
          
          ;; Test path length
          (princ (strcat "\n  Path length: " (itoa (strlen file_path)) " characters"))
          (if (> (strlen file_path) 260)
            (princ " ⚠ WARNING: Path exceeds 260 character Windows limit!")
            (princ " ✓"))
          
          ;; Test folder writable
          (princ "\n\n→ Testing folder write permissions:")
          (setq file_handle (open (strcat folder_path "\\test_write.tmp") "w"))
          (if file_handle
            (progn
              (princ "\n  ✓ Folder is writable")
              (close file_handle)
              (vl-file-delete (strcat folder_path "\\test_write.tmp"))
              (princ "\n  ✓ Temporary file deleted"))
            (princ "\n  ✗ Folder is NOT writable"))
          
          ;; Test if file already exists
          (princ "\n\n→ Checking if target file exists:")
          (if (findfile file_path)
            (progn
              (princ (strcat "\n  ⚠ File already exists: " file_path))
              (princ "\n  → WBLOCK will overwrite this file"))
            (princ "\n  ✓ File does not exist (ready for creation)"))
          
          (princ "\n\n✓ File path test completed")
          (princ)
        )
      )
    )
  )
)

;;;============================================================================
;;; TEST 5-9: WBLOCK METHODS (Individual)
;;;============================================================================
(defun test_wblock_method0 ( / block_name folder_path file_path result)
  (test_wblock_method_generic "METHOD 0: Platform-Optimized" 0)
)

(defun test_wblock_method1 ( / block_name folder_path file_path result)
  (test_wblock_method_generic "METHOD 1: Direct vl-cmdf" 1)
)

(defun test_wblock_method2 ( / block_name folder_path file_path result)
  (test_wblock_method_generic "METHOD 2: Script Generation" 2)
)

(defun test_wblock_method3 ( / block_name folder_path file_path result)
  (test_wblock_method_generic "METHOD 3: ObjectDBX" 3)
)

(defun test_wblock_method4 ( / block_name folder_path file_path result)
  (test_wblock_method_generic "METHOD 4: Basic COMMAND" 4)
)

;;;============================================================================
;;; GENERIC WBLOCK TEST
;;;============================================================================
(defun test_wblock_method_generic (method_name method_num / block_name folder_path file_path result
                                     old_cmdecho old_filedia old_expert old_attreq
                                     script_path script_handle start_time end_time)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ (strcat "\n║ TEST: " method_name))
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  ;; Get block name
  (setq block_name (getstring T "\nEnter block name to export: "))
  (if (not block_name)
    (progn
      (princ "\n✗ No block name entered")
      (princ))
    (progn
      ;; Validate block
      (if (not (tblsearch "BLOCK" block_name))
        (progn
          (princ (strcat "\n✗ Block '" block_name "' not found in drawing"))
          (princ))
        (progn
          ;; Get folder
          (setq folder_path (getfiled "Select export folder" "" "" 1))
          (if (not folder_path)
            (progn
              (princ "\n✗ No folder selected")
              (princ))
            (progn
              (setq file_path (strcat folder_path "\\" block_name ".dwg"))
              
              (princ "\n→ SETUP:")
              (princ (strcat "\n  Block: " block_name))
              (princ (strcat "\n  Target: " file_path))
              
              ;; Delete existing file
              (if (findfile file_path)
                (progn
                  (princ "\n  Deleting existing file...")
                  (vl-file-delete file_path)
                  (if (findfile file_path)
                    (princ " ✗ FAILED to delete")
                    (princ " ✓"))))
              
              ;; Save system variables
              (setq old_cmdecho (getvar "CMDECHO"))
              (setq old_filedia (getvar "FILEDIA"))
              (setq old_expert (getvar "EXPERT"))
              (setq old_attreq (getvar "ATTREQ"))
              
              (princ "\n\n→ EXECUTION:")
              (setq start_time (getvar "MILLISECS"))
              
              ;; Execute based on method
              (cond
                ;; Method 0: Platform-Optimized
                ((= method_num 0)
                 (princ "\n  Step 1: Detecting platform...")
                 (setq platform
                   (cond
                     ((wcmatch (strcase (getvar "PRODUCT")) "*BRICSCAD*") "BRICSCAD")
                     ((or (wcmatch (strcase (getvar "PRODUCT")) "*ELECTRICAL*")
                          (findfile "acetutil.arx")
                          (not (vl-catch-all-error-p (vl-catch-all-apply 'getvar '("WDPROJECTNAMEEX")))))
                      "ACADE")
                     ((wcmatch (strcase (getvar "PRODUCT")) "*AUTOCAD*") "AUTOCAD")
                     (T "UNKNOWN")))
                 (princ (strcat " " platform))
                 (if (equal platform "ACADE")
                   (princ " (AutoCAD Electrical detected)"))
                 
                 (princ "\n  Step 2: Setting system variables...")
                 (setvar "CMDECHO" 0)
                 (setvar "FILEDIA" 0)
                 (setvar "EXPERT" 5)
                 (setvar "ATTREQ" (if (equal platform "ACADE") 1 0))
                 (princ " ✓")
                 
                 (princ "\n  Step 3: Executing WBLOCK command...")
                 (setq result
                   (vl-catch-all-apply
                     '(lambda ()
                        (command "._-WBLOCK" file_path "=" block_name)
                        (princ "\n    Waiting for command completion...")
                        (while (> (getvar "CMDACTIVE") 0)
                          (command ""))
                        (princ " ✓")
                        T)))
                 
                 (if (vl-catch-all-error-p result)
                   (princ (strcat "\n    ✗ ERROR: " (vl-catch-all-error-message result)))
                   (princ "\n    ✓ Command executed without errors")))
                
                ;; Method 1: vl-cmdf
                ((= method_num 1)
                 (princ "\n  Step 1: Setting system variables...")
                 (setvar "CMDECHO" 0)
                 (setvar "FILEDIA" 0)
                 (setvar "EXPERT" 5)
                 (setvar "ATTREQ" 0)
                 (princ " ✓")
                 
                 (princ "\n  Step 2: Executing vl-cmdf WBLOCK...")
                 (setq result
                   (vl-catch-all-apply
                     '(lambda ()
                        (vl-cmdf "._-WBLOCK" file_path "=" block_name)
                        (princ "\n    Waiting for command completion...")
                        (while (> (getvar "CMDACTIVE") 0)
                          (vl-cmdf ""))
                        (princ " ✓")
                        T)))
                 
                 (if (vl-catch-all-error-p result)
                   (princ (strcat "\n    ✗ ERROR: " (vl-catch-all-error-message result)))
                   (princ "\n    ✓ Command executed without errors")))
                
                ;; Method 2: Script
                ((= method_num 2)
                 (setq script_path (strcat folder_path "\\test_export.scr"))
                 
                 (princ (strcat "\n  Step 1: Creating script file: " script_path))
                 (setq script_handle (open script_path "w"))
                 (if (not script_handle)
                   (princ "\n    ✗ Failed to create script file")
                   (progn
                     (write-line "-WBLOCK" script_handle)
                     (write-line file_path script_handle)
                     (write-line "=" script_handle)
                     (write-line block_name script_handle)
                     (write-line "" script_handle)
                     (close script_handle)
                     (princ " ✓")
                     
                     (princ "\n  Step 2: Verifying script content...")
                     (setq script_handle (open script_path "r"))
                     (princ "\n    ---Script Content---")
                     (while (setq line (read-line script_handle))
                       (princ (strcat "\n    " (if (= line "") "<blank>" line))))
                     (close script_handle)
                     (princ "\n    ---End Script---")
                     
                     (princ "\n  Step 3: Setting system variables...")
                     (setvar "CMDECHO" 0)
                     (setvar "FILEDIA" 0)
                     (setvar "EXPERT" 5)
                     (setvar "ATTREQ" 1)
                     (princ " ✓")
                     
                     (princ "\n  Step 4: Executing script...")
                     (setq result
                       (vl-catch-all-apply
                         '(lambda ()
                            (command "._SCRIPT" script_path)
                            (princ "\n    Waiting for script completion...")
                            (setq timeout 0)
                            (while (and (> (getvar "CMDACTIVE") 0) (< timeout 300))
                              (command "")
                              (setq timeout (1+ timeout)))
                            (princ (strcat " (loops: " (itoa timeout) ")"))
                            T)))
                     
                     (if (vl-catch-all-error-p result)
                       (princ (strcat "\n    ✗ ERROR: " (vl-catch-all-error-message result)))
                       (princ "\n    ✓ Script executed without errors"))))
                )
                
                ;; Method 3: ObjectDBX
                ((= method_num 3)
                 (princ "\n  Step 1: Getting ActiveX objects...")
                 (setq result
                   (vl-catch-all-apply
                     '(lambda ( / acad doc)
                        (setq acad (vlax-get-acad-object))
                        (princ " ✓ ACAD object")
                        (setq doc (vla-get-activedocument acad))
                        (princ " ✓ Document")
                        
                        (princ "\n  Step 2: Executing vla-wblock...")
                        (vla-wblock doc file_path block_name)
                        (princ " ✓")
                        T)))
                 
                 (if (vl-catch-all-error-p result)
                   (princ (strcat "\n    ✗ ERROR: " (vl-catch-all-error-message result)))
                   (princ "\n  ✓ VLA command executed without errors")))
                
                ;; Method 4: COMMAND
                ((= method_num 4)
                 (princ "\n  Step 1: Setting system variables...")
                 (setvar "CMDECHO" 0)
                 (setvar "FILEDIA" 0)
                 (setvar "EXPERT" 5)
                 (setvar "ATTREQ" 0)
                 (princ " ✓")
                 
                 (princ "\n  Step 2: Executing COMMAND WBLOCK...")
                 (setq result
                   (vl-catch-all-apply
                     '(lambda ()
                        (command "._-WBLOCK" file_path "=" block_name)
                        (princ "\n    Waiting for command completion...")
                        (while (> (getvar "CMDACTIVE") 0)
                          (command ""))
                        (princ " ✓")
                        T)))
                 
                 (if (vl-catch-all-error-p result)
                   (princ (strcat "\n    ✗ ERROR: " (vl-catch-all-error-message result)))
                   (princ "\n    ✓ Command executed without errors")))
              )
              
              (setq end_time (getvar "MILLISECS"))
              
              ;; Restore system variables
              (princ "\n\n→ CLEANUP:")
              (princ "\n  Restoring system variables...")
              (setvar "CMDECHO" old_cmdecho)
              (setvar "FILEDIA" old_filedia)
              (setvar "EXPERT" old_expert)
              (setvar "ATTREQ" old_attreq)
              (princ " ✓")
              
              ;; Check result
              (princ "\n\n→ VERIFICATION:")
              (princ (strcat "\n  Execution time: " (rtos (/ (- end_time start_time) 1000.0) 2 2) " seconds"))
              (princ (strcat "\n  Checking for file: " file_path))
              
              (if (findfile file_path)
                (progn
                  (princ "\n  ✓✓✓ FILE CREATED SUCCESSFULLY! ✓✓✓")
                  (setq file_info (vl-file-size file_path))
                  (princ (strcat "\n  File size: " (itoa file_info) " bytes")))
                (progn
                  (princ "\n  ✗✗✗ FILE NOT CREATED ✗✗✗")
                  (princ "\n  POSSIBLE CAUSES:")
                  (princ "\n    • WBLOCK command failed silently")
                  (princ "\n    • File permissions issue")
                  (princ "\n    • Path length too long")
                  (princ "\n    • Block contains invalid data")
                  (princ "\n    • AutoCAD Electrical specific issue")))
              
              (princ "\n\n✓ Test completed")
              (princ)
            )
          )
        )
      )
    )
  )
)

;;;============================================================================
;;; TEST 10: SCRIPT FILE EXECUTION
;;;============================================================================
(defun test_script_execution ( / script_path script_handle result)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ TEST 10: SCRIPT FILE EXECUTION                          ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (setq script_path (getfiled "Select script file to test" "" "scr" 0))
  
  (if (not script_path)
    (progn
      (princ "\n✗ No script file selected")
      (princ))
    (progn
      (princ (strcat "\n→ Script file: " script_path))
      
      ;; Show script content
      (princ "\n\n→ Script content:")
      (setq script_handle (open script_path "r"))
      (if script_handle
        (progn
          (princ "\n  ────────────────────────────────────")
          (setq line_num 0)
          (while (setq line (read-line script_handle))
            (setq line_num (1+ line_num))
            (princ (strcat "\n  " (itoa line_num) ": " (if (= line "") "<blank>" line))))
          (close script_handle)
          (princ "\n  ────────────────────────────────────")
          
          (princ "\n\n→ Executing script...")
          (princ "\n  Press ENTER to continue or ESC to cancel...")
          (if (not (grread))
            (princ "\n  Cancelled by user")
            (progn
              (setq result
                (vl-catch-all-apply
                  '(lambda ()
                     (command "._SCRIPT" script_path)
                     (princ "\n  Waiting for script completion...")
                     (setq timeout 0)
                     (while (and (> (getvar "CMDACTIVE") 0) (< timeout 300))
                       (command "")
                       (setq timeout (1+ timeout)))
                     (princ (strcat " (loops: " (itoa timeout) ")"))
                     T)))
              
              (if (vl-catch-all-error-p result)
                (princ (strcat "\n  ✗ ERROR: " (vl-catch-all-error-message result)))
                (princ "\n  ✓ Script executed")))))
        (princ "\n✗ Could not open script file"))
      
      (princ)
    )
  )
)

;;;============================================================================
;;; TEST 11: SINGLE BLOCK - ALL METHODS
;;;============================================================================
(defun test_single_block_all_methods ( / block_name folder_path results method)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ TEST 11: SINGLE BLOCK - ALL METHODS                     ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (setq block_name (getstring T "\nEnter block name to test: "))
  (if (not block_name)
    (progn
      (princ "\n✗ No block name entered")
      (princ))
    (progn
      (if (not (tblsearch "BLOCK" block_name))
        (progn
          (princ (strcat "\n✗ Block '" block_name "' not found"))
          (princ))
        (progn
          (setq folder_path (getfiled "Select export folder" "" "" 1))
          (if (not folder_path)
            (progn
              (princ "\n✗ No folder selected")
              (princ))
            (progn
              (princ (strcat "\n→ Testing block: " block_name))
              (princ (strcat "\n→ Export folder: " folder_path))
              (princ "\n\n→ Running all export methods...\n")
              
              (setq results '())
              
              ;; Test each method
              (foreach method '(("Method 0" . 0) ("Method 1" . 1) ("Method 3" . 3) ("Method 4" . 4))
                (princ (strcat "\n─────────────────────────────────────────────"))
                (princ (strcat "\nTesting " (car method) "..."))
                (test_wblock_method_generic (car method) (cdr method))
                (princ "\nPress ENTER to continue...")
                (getstring)
              )
              
              (princ "\n\n╔══════════════════════════════════════════════════════════╗")
              (princ "\n║ SUMMARY - CHECK FILES IN FOLDER                         ║")
              (princ "\n╚══════════════════════════════════════════════════════════╝")
              (princ (strcat "\n→ Check folder: " folder_path))
              (princ (strcat "\n→ Look for: " block_name ".dwg"))
              (princ "\n→ Compare which methods created files successfully")
              (princ)
            )
          )
        )
      )
    )
  )
)

;;;============================================================================
;;; TEST 12: VERIFY EXPORTED DWG FILE
;;;============================================================================
(defun test_verify_dwg ( / dwg_path doc)
  (princ "\n╔══════════════════════════════════════════════════════════╗")
  (princ "\n║ TEST 12: VERIFY EXPORTED DWG FILE                       ║")
  (princ "\n╚══════════════════════════════════════════════════════════╝")
  
  (setq dwg_path (getfiled "Select DWG file to verify" "" "dwg" 0))
  
  (if (not dwg_path)
    (progn
      (princ "\n✗ No file selected")
      (princ))
    (progn
      (princ (strcat "\n→ File: " dwg_path))
      
      ;; Check file exists
      (if (not (findfile dwg_path))
        (princ "\n✗ File does not exist")
        (progn
          (princ "\n✓ File exists")
          
          ;; Check file size
          (setq file_size (vl-file-size dwg_path))
          (princ (strcat "\n✓ File size: " (itoa file_size) " bytes"))
          
          (if (< file_size 100)
            (princ "\n⚠ WARNING: File is very small (possibly corrupt)")
            (princ "\n✓ File size appears reasonable"))
          
          ;; Try to open it
          (princ "\n\n→ Attempting to open file in AutoCAD...")
          (princ "\n  (This will open the file - check for errors)")
          (princ "\n  Press ENTER to continue or ESC to cancel...")
          
          (if (grread)
            (command "._OPEN" dwg_path)
            (princ "\n  Cancelled by user"))))
      
      (princ)
    )
  )
)

;;;============================================================================
;;; UTILITY: Clear screen
;;;============================================================================
(defun cls () (command "._REDRAW"))

(princ "\n╔══════════════════════════════════════════════════════════╗")
(princ "\n║ MacroManager Diagnostic Utility Loaded                  ║")
(princ "\n║ Type: MMTEST to start diagnostic tests                  ║")
(princ "\n╚══════════════════════════════════════════════════════════╝")
(princ)
