;; ═══════════════════════════════════════════════════════════════════════════
;; UNIFIED CIRCUIT & BLOCK MANAGER v2.3
;; Complete solution: Block Definitions + Circuit Assemblies
;; ═══════════════════════════════════════════════════════════════════════════
;;
;; FEATURES:
;;   • Export/Import Block Definitions (MacroManager functionality)
;;   • Export/Import Circuit Assemblies (complete sections)
;;   • CSV coordinate tracking and batch import
;;   • 5 Export methods + 5 Import methods for blocks
;;   • Professional UI with mode switching
;;   • Category-based organization
;;
;; USAGE:
;;   (load "UnifiedManager_v2.3.lsp")
;;   UCB  or  UNIFIEDMANAGER
;;
;; ═══════════════════════════════════════════════════════════════════════════

;; Global variables
(if (not *ucb_library_folder*) 
  (setq *ucb_library_folder* "C:\\Temp\\Circuit_Library"))

;; Store the path where this LSP was loaded from
(if (not *ucb_lsp_path*)
  (setq *ucb_lsp_path* (findfile "UnifiedManager_v2.3.lsp")))

(if (not *ucb_operation_mode*) 
  (setq *ucb_operation_mode* "export"))  ; "export" or "import"

(if (not *ucb_content_type*) 
  (setq *ucb_content_type* "blocks"))    ; "blocks" or "circuits"

(if (not *ucb_export_method*) 
  (setq *ucb_export_method* 0))          ; 0-4

;; Step-by-step workflow variables
(setq *ucb_step1_ss* nil)           ; Step 1: Selected entities
(setq *ucb_selection_count* nil)    ; Count of selected entities
(setq *ucb_step2_name* nil)         ; Step 2: Circuit/block name
(setq *ucb_step3_basepoint* nil)    ; Step 3: Base point

;; Import workflow variables
(setq *ucb_import_scale* 1.0)       ; Import scale factor
(setq *ucb_import_rotation* 0.0)    ; Import rotation angle
(setq *ucb_import_selection* nil)   ; Selected item from list
(setq *ucb_csv_file* nil)           ; Selected CSV file for import
(setq *ucb_csv_file* nil)           ; Selected CSV file for import

(if (not *ucb_import_method*) 
  (setq *ucb_import_method* 0))          ; 0-4

(if (not *ucb_category*) 
  (setq *ucb_category* "General"))

;; Categories for organization
(setq *ucb_categories* 
  '("General" "Control_Panel" "Motor_Circuit" "Power_Distribution" 
    "Lighting_Circuit" "Instrumentation" "Communication" "Safety_System"
    "HVAC_System" "Custom"))

;; Export methods
(setq *ucb_export_methods* 
  '("0 - Platform Optimized (Recommended)"
    "1 - Direct vl-cmdf (Forced)"
    "2 - Script Method (Batch)"
    "3 - ObjectDBX/VLA (API)"
    "4 - Basic COMMAND"))

;; Import methods
(setq *ucb_import_methods* 
  '("0 - XREF Attach (Reference)"
    "1 - INSERT + Explode (Break apart)"
    "2 - INSERT as Block (Keep structure)"
    "3 - Direct INSERT"
    "4 - VLA Method (API)"))

;; ═══════════════════════════════════════════════════════════════════════════
;; MAIN COMMANDS
;; ═══════════════════════════════════════════════════════════════════════════

(defun C:UCB ( / )
  (ucb:show_dialog)
  (princ))

(defun C:UNIFIEDMANAGER ( / )
  (ucb:show_dialog)
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; PLATFORM DETECTION (from MacroManager)
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:detect_platform ( / product acetutil wdproj)
  (setq product (getvar "PRODUCT"))
  (setq acetutil (findfile "acetutil.arx"))
  (setq wdproj (getvar "WDPROJECTNAMEEX"))
  
  (cond
    ((and acetutil wdproj) "ACADE")
    ((wcmatch product "*Brics*") "BricsCAD")
    (T "AutoCAD")))

;; ═══════════════════════════════════════════════════════════════════════════
;; CSV FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:get_csv_path (content_type / )
  (strcat *ucb_library_folder* "\\" 
    (if (= content_type "blocks")
      "Block_Coordinates.csv"
      "Circuit_Coordinates.csv")))

(defun ucb:save_to_csv (item_name category dwg_file base_pt insert_pt content_type / 
                        csv_path csv_handle date_str time_str)
  (setq csv_path (ucb:get_csv_path content_type))
  
  ;; Create CSV with header if doesn't exist
  (if (not (findfile csv_path))
    (progn
      (setq csv_handle (open csv_path "w"))
      (if csv_handle
        (progn
          (write-line 
            (if (= content_type "blocks")
              "BlockName,Category,DWG_File,Export_Date,Export_Time"
              "CircuitName,Category,DWG_File,BaseX,BaseY,BaseZ,InsertX,InsertY,InsertZ,Export_Date,Export_Time")
            csv_handle)
          (close csv_handle)))))
  
  ;; Append data
  (setq csv_handle (open csv_path "a"))
  (if csv_handle
    (progn
      (setq date_str (menucmd "M=$(edtime,$(getvar,DATE),YYYY-MM-DD)"))
      (setq time_str (menucmd "M=$(edtime,$(getvar,DATE),HH:MM:SS)"))
      
      (if (= content_type "blocks")
        (write-line 
          (strcat item_name "," category "," dwg_file "," date_str "," time_str)
          csv_handle)
        (write-line 
          (strcat 
            item_name "," category "," dwg_file ","
            (rtos (car base_pt) 2 4) "," (rtos (cadr base_pt) 2 4) "," (rtos (caddr base_pt) 2 4) ","
            (if insert_pt (rtos (car insert_pt) 2 4) "") ","
            (if insert_pt (rtos (cadr insert_pt) 2 4) "") ","
            (if insert_pt (rtos (caddr insert_pt) 2 4) "") ","
            date_str "," time_str)
          csv_handle))
      
      (close csv_handle)
      T)
    nil))

(defun ucb:read_csv (content_type / csv_path csv_handle line item_list)
  (setq csv_path (ucb:get_csv_path content_type))
  (setq item_list '())
  
  (if (findfile csv_path)
    (progn
      (setq csv_handle (open csv_path "r"))
      (if csv_handle
        (progn
          (read-line csv_handle)  ; Skip header
          (while (setq line (read-line csv_handle))
            (setq item_list (cons (ucb:parse_csv_line line) item_list)))
          (close csv_handle)
          (reverse item_list)))
      item_list)))

(defun ucb:parse_csv_line (line / parts)
  (setq parts '())
  (while (vl-string-search "," line)
    (setq parts (cons (substr line 1 (vl-string-search "," line)) parts))
    (setq line (substr line (+ (vl-string-search "," line) 2))))
  (setq parts (cons line parts))
  (reverse parts))

(defun ucb:get_csv_data (item_name content_type / item_list item)
  (setq item_list (ucb:read_csv content_type))
  (foreach entry item_list
    (if (= (car entry) item_name)
      (setq item entry)))
  item)


;; ═══════════════════════════════════════════════════════════════════════════
;; BLOCK VALIDATION (from MacroManager)
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:validate_block (block_name / block_obj flags)
  (setq block_obj (tblsearch "BLOCK" block_name))
  
  (cond
    ((not block_obj)
     (princ (strcat "\n      ⚠ Block not found: " block_name))
     nil)
    
    (T
     (setq flags (cdr (assoc 70 block_obj)))
     (cond
       ((= (logand flags 1) 1)
        (princ "\n      ⚠ Cannot export anonymous block")
        nil)
       
       ((= (logand flags 4) 4)
        (princ "\n      ⚠ Cannot export xref block")
        nil)
       
       ((= (logand flags 32) 32)
        (princ "\n      ⚠ Cannot export layout block")
        nil)
       
       (T T)))))

;; ═══════════════════════════════════════════════════════════════════════════
;; BLOCK EXPORT FUNCTIONS (from MacroManager)
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:wblock_export (block_name dwg_path method / platform result)
  (if (not (ucb:validate_block block_name))
    nil
    (progn
      (setq platform (ucb:detect_platform))
      
      (setvar "CMDECHO" 0)
      (setvar "FILEDIA" 0)
      (setvar "EXPERT" 5)
      (if (= platform "ACADE")
        (setvar "ATTREQ" 1))
      
      (if (findfile dwg_path)
        (vl-file-delete dwg_path))
      
      (cond
        ;; Method 0: Platform Optimized
        ((= method 0)
         (if (= platform "ACADE")
           (command "._-WBLOCK" dwg_path "=" block_name)
           (vl-cmdf "._-WBLOCK" dwg_path "=" block_name)))
        
        ;; Method 1: Direct vl-cmdf
        ((= method 1)
         (vl-cmdf "._-WBLOCK" dwg_path "=" block_name))
        
        ;; Method 2: Script (for batch)
        ((= method 2)
         (ucb:wblock_script block_name dwg_path))
        
        ;; Method 3: ObjectDBX/VLA
        ((= method 3)
         (ucb:wblock_vla block_name dwg_path))
        
        ;; Method 4: Basic COMMAND
        ((= method 4)
         (command "._-WBLOCK" dwg_path "=" block_name)))
      
      (while (> (getvar "CMDACTIVE") 0)
        (command ""))
      
      (setvar "CMDECHO" 1)
      (setvar "FILEDIA" 1)
      (setvar "EXPERT" 0)
      
      (if (findfile dwg_path)
        T
        nil))))

(defun ucb:wblock_script (block_name dwg_path / script_path script_handle)
  (setq script_path (strcat (getvar "TEMPPREFIX") "wblock_temp.scr"))
  (setq script_handle (open script_path "w"))
  (if script_handle
    (progn
      (write-line (strcat "._-WBLOCK " dwg_path " = " block_name " ") script_handle)
      (close script_handle)
      (command "._SCRIPT" script_path))))

(defun ucb:wblock_vla (block_name dwg_path / acad doc result)
  (setq result
    (vl-catch-all-apply
      (function (lambda ()
        (setq acad (vlax-get-acad-object))
        (setq doc (vla-get-activedocument acad))
        (vla-wblock doc dwg_path block_name)
        T))))
  (not (vl-catch-all-error-p result)))

;; ═══════════════════════════════════════════════════════════════════════════
;; BLOCK IMPORT FUNCTIONS (from MacroManager)
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:block_import (dwg_path method / result)
  (setvar "CMDECHO" 0)
  (setvar "FILEDIA" 0)
  
  (cond
    ;; Method 0: XREF
    ((= method 0)
     (command "._-XATTACH" dwg_path "" "" "" "")
     (while (> (getvar "CMDACTIVE") 0)
       (command "")))
    
    ;; Method 1: INSERT + Explode
    ((= method 1)
     (command "._-INSERT" (strcat "*" dwg_path) '(0 0 0) 1 1 0)
     (while (> (getvar "CMDACTIVE") 0)
       (command "")))
    
    ;; Method 2: INSERT as block
    ((= method 2)
     (command "._-INSERT" dwg_path)
     (command "_C")
     (while (> (getvar "CMDACTIVE") 0)
       (command "")))
    
    ;; Method 3: Direct INSERT
    ((= method 3)
     (command "._-INSERT" dwg_path '(0 0 0) 1 1 0)
     (while (> (getvar "CMDACTIVE") 0)
       (command "")))
    
    ;; Method 4: VLA
    ((= method 4)
     (ucb:insert_vla dwg_path)))
  
  (setvar "CMDECHO" 1)
  (setvar "FILEDIA" 1)
  T)

(defun ucb:insert_vla (dwg_path / acad doc result)
  (setq result
    (vl-catch-all-apply
      (function (lambda ()
        (setq acad (vlax-get-acad-object))
        (setq doc (vla-get-activedocument acad))
        (vla-sendcommand doc (strcat "_.-INSERT " dwg_path " "))
        T))))
  (not (vl-catch-all-error-p result)))


;; ═══════════════════════════════════════════════════════════════════════════
;; CIRCUIT EXPORT/IMPORT FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:circuit_export (circuit_name export_path base_pt / ss result)
  (princ "\n→ SELECT CIRCUIT ENTITIES")
  (princ "\n  Select all entities (lines, blocks, text, etc.)...")
  (setq ss (ssget))
  
  (if (not ss)
    (progn
      (princ "\n✗ No entities selected")
      nil)
    (progn
      (princ (strcat "\n✓ Selected " (itoa (sslength ss)) " entities"))
      
      (setvar "CMDECHO" 0)
      (setvar "FILEDIA" 0)
      (setvar "EXPERT" 5)
      
      (if (findfile export_path)
        (vl-file-delete export_path))
      
      (command "._-WBLOCK" export_path "" base_pt ss "")
      (while (> (getvar "CMDACTIVE") 0)
        (command ""))
      
      (setvar "CMDECHO" 1)
      (setvar "FILEDIA" 1)
      (setvar "EXPERT" 0)
      
      (if (findfile export_path)
        (progn
          (princ (strcat "\n✓ Circuit exported: " export_path))
          T)
        (progn
          (princ "\n✗ Export failed")
          nil)))))

(defun ucb:circuit_import (circuit_file insert_pt scale rotation explode / )
  (setvar "CMDECHO" 0)
  (setvar "FILEDIA" 0)
  (setvar "EXPERT" 5)
  
  (setq rotation (* rotation (/ pi 180.0)))
  
  (if explode
    (command "._INSERT" (strcat "*" circuit_file) insert_pt scale scale rotation)
    (command "._INSERT" circuit_file insert_pt scale scale rotation))
  
  (while (> (getvar "CMDACTIVE") 0)
    (command ""))
  
  (setvar "CMDECHO" 1)
  (setvar "FILEDIA" 1)
  (setvar "EXPERT" 0)
  
  (princ "\n✓ Circuit imported")
  T)

;; ═══════════════════════════════════════════════════════════════════════════
;; UTILITY FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:get_block_list ( / block_table block_list block_name)
  (setq block_table (tblnext "BLOCK" T))
  (setq block_list '())
  
  (while block_table
    (setq block_name (cdr (assoc 2 block_table)))
    
    (if (and block_name
             (not (wcmatch block_name "`**"))
             (not (wcmatch block_name "*|*"))
             (ucb:validate_block block_name))
      (setq block_list (cons block_name block_list)))
    
    (setq block_table (tblnext "BLOCK")))
  
  (reverse block_list))

(defun ucb:get_library_files (content_type / folder file_list all_files)
  (setq all_files '())
  
  ;; Get files from category subfolders
  (foreach category *ucb_categories*
    (setq folder (strcat *ucb_library_folder* "\\" category))
    (if (findfile folder)
      (progn
        (setq file_list (vl-directory-files folder "*.dwg"))
        (foreach file file_list
          (setq all_files 
            (cons (list file category (strcat folder "\\" file)) 
                  all_files))))))
  
  ;; Get files from root folder
  (setq file_list (vl-directory-files *ucb_library_folder* "*.dwg"))
  (foreach file file_list
    (setq all_files 
      (cons (list file "Root" (strcat *ucb_library_folder* "\\" file)) 
            all_files)))
  
  (reverse all_files))

(defun ucb:create_category_folder (category / folder)
  (setq folder (strcat *ucb_library_folder* "\\" category))
  (if (not (findfile folder))
    (vl-mkdir folder))
  folder)


;; ═══════════════════════════════════════════════════════════════════════════
;; DIALOG MANAGEMENT
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:get_dcl_path ( / lsp_path dcl_path dwg_path)
  ;; Method 1: Use the stored LSP path from when file was loaded
  (if *ucb_lsp_path*
    (setq lsp_path *ucb_lsp_path*)
    ;; Fallback: Try to find it again
    (setq lsp_path (findfile "UnifiedManager_v2.2.lsp")))
  
  (if lsp_path
    (setq dcl_path (strcat (vl-filename-directory lsp_path) "\\UnifiedManager_v2.3.dcl"))
    (progn
      ;; Method 2: Try current drawing directory
      (setq dwg_path (getvar "DWGPREFIX"))
      (setq dcl_path (strcat dwg_path "UnifiedManager_v2.3.dcl"))
      
      (if (not (findfile dcl_path))
        (progn
          ;; Method 3: Try LOCALROOTPREFIX (user's local AutoCAD folder)
          (setq dcl_path (strcat (getvar "LOCALROOTPREFIX") "UnifiedManager_v2.3.dcl"))
          (if (not (findfile dcl_path))
            ;; Method 4: Just the filename (AutoCAD will search support paths)
            (setq dcl_path "UnifiedManager_v2.3.dcl"))))))
  dcl_path)

(defun ucb:show_dialog ( / dcl_id dcl_path result continue)
  (setq continue T)
  
  (while continue
    (setq dcl_path (ucb:get_dcl_path))
    (setq dcl_id (load_dialog dcl_path))
    
    (if (not dcl_id)
      (progn
        (princ (strcat "\n✗ Cannot find DCL file: " dcl_path))
        (setq continue nil))
      (if (not (new_dialog "ucbmanager" dcl_id))
        (progn
          (princ "\n✗ Cannot load dialog 'ucbmanager'")
          (unload_dialog dcl_id)
          (setq continue nil))
        (progn
          (ucb:init_dialog)
          (setq result (start_dialog))
          (unload_dialog dcl_id)
          
          ;; Handle dialog results
          (cond
            ((= result 0) (setq continue nil))  ; Cancel
            ((= result 1) (setq continue nil))  ; Close/OK
            ((= result 10) (ucb:do_step1))      ; Step 1: Select
            ((= result 12) (ucb:do_step3))      ; Step 3: Base Point
            ((= result 13)                      ; Complete Export
              (progn
                (ucb:do_complete_export)
                (setq continue nil)))
            ((= result 20)                      ; Import button
              (if *ucb_csv_file*
                ;; CSV file selected - do batch import
                (progn
                  (ucb:do_import_csv)
                  (setq continue nil))
                ;; No CSV - do regular import from list
                (ucb:do_import)))
            ((= result 21) (ucb:browse_csv))    ; CSV button - just browse
            (T (setq continue nil)))))))
  
  (princ))

(defun ucb:init_dialog ( / )
  ;; Set operation mode
  (set_tile "mode_export" (if (= *ucb_operation_mode* "export") "1" "0"))
  (set_tile "mode_import" (if (= *ucb_operation_mode* "import") "1" "0"))
  
  ;; Set content type
  (set_tile "type_blocks" (if (= *ucb_content_type* "blocks") "1" "0"))
  (set_tile "type_circuits" (if (= *ucb_content_type* "circuits") "1" "0"))
  
  ;; Set library folder
  (set_tile "library_folder" *ucb_library_folder*)
  
  ;; Initialize export panel
  (set_tile "export_single" "1")
  (start_list "export_method")
  (mapcar 'add_list *ucb_export_methods*)
  (end_list)
  (set_tile "export_method" (itoa *ucb_export_method*))
  
  (start_list "export_category")
  (mapcar 'add_list *ucb_categories*)
  (end_list)
  (set_tile "export_category" "0")
  
  ;; Initialize import panel
  (set_tile "import_from_library" "1")
  (start_list "import_method")
  (mapcar 'add_list *ucb_import_methods*)
  (end_list)
  (set_tile "import_method" (itoa *ucb_import_method*))
  
  (set_tile "import_scale" "1.0")
  (set_tile "import_rotation" "0.0")
  
  ;; Setup callbacks
  (action_tile "mode_export" "(setq *ucb_operation_mode* \"export\") (ucb:mode_changed)")
  (action_tile "mode_import" "(setq *ucb_operation_mode* \"import\") (ucb:mode_changed)")
  (action_tile "type_blocks" "(setq *ucb_content_type* \"blocks\") (ucb:type_changed)")
  (action_tile "type_circuits" "(setq *ucb_content_type* \"circuits\") (ucb:type_changed)")
  
  (action_tile "library_folder" "(setq *ucb_library_folder* $value)")
  (action_tile "export_method" "(setq *ucb_export_method* (atoi $value))")
  (action_tile "import_method" "(setq *ucb_import_method* (atoi $value))")
  (action_tile "export_category" "(setq *ucb_category* (nth (atoi $value) *ucb_categories*))")
  
  (action_tile "btn_browse_folder" "(ucb:browse_folder)")
  (action_tile "btn_refresh_list" "(ucb:refresh_library_list)")
  
  ;; Export name field
  (action_tile "export_name" "(setq *ucb_step2_name* $value)")
  
  ;; Import fields - store values
  (action_tile "import_scale" "(setq *ucb_import_scale* (atof $value))")
  (action_tile "import_rotation" "(setq *ucb_import_rotation* (atof $value))")
  (action_tile "import_list" "(setq *ucb_import_selection* $value)")
  
  ;; Update selection count display
  (if *ucb_selection_count*
    (set_tile "txt_selection_count" 
      (strcat "✓ Selected " *ucb_selection_count* " entities"))
    (set_tile "txt_selection_count" "No entities selected"))
  
  ;; Set export name if exists
  (if *ucb_step2_name*
    (set_tile "export_name" *ucb_step2_name*)
    (set_tile "export_name" ""))
  
  ;; Step-by-step workflow buttons
  (action_tile "btn_step1" "(done_dialog 10)")
  (action_tile "btn_step3" "(done_dialog 12)")
  (action_tile "btn_complete_export" "(done_dialog 13)")
  
  (action_tile "btn_start_import" "(done_dialog 20)")
  (action_tile "btn_load_csv" "(done_dialog 21)")
  
  (action_tile "cancel" "(done_dialog 0)")
  (action_tile "accept" "(done_dialog 1)")
  
  (ucb:mode_changed)
  (ucb:refresh_library_list))

(defun ucb:mode_changed ( / )
  (if (= *ucb_operation_mode* "export")
    (progn
      (mode_tile "export_panel" 0)
      (mode_tile "import_panel" 1))
    (progn
      (mode_tile "export_panel" 1)
      (mode_tile "import_panel" 0))))

(defun ucb:type_changed ( / )
  (ucb:refresh_library_list)
  (set_tile "status_text" 
    (strcat "Mode: " *ucb_content_type* " | Operation: " *ucb_operation_mode*)))

(defun ucb:refresh_library_list ( / file_list)
  (start_list "import_list")
  
  (setq file_list (ucb:get_library_files *ucb_content_type*))
  (mapcar '(lambda (item) 
             (add_list (strcat (car item) " [" (cadr item) "]"))) 
          file_list)
  
  (end_list)
  (set_tile "status_text" 
    (strcat "Found " (itoa (length file_list)) " " *ucb_content_type* " in library")))

(defun ucb:browse_folder ( / folder)
  (setq folder (getfiled "Select Library Folder" *ucb_library_folder* "" 16))
  (if folder
    (progn
      ;; If user selected a file, get its directory; if directory, use as-is
      (if (wcmatch folder "*.*")
        (setq *ucb_library_folder* (vl-filename-directory folder))
        (setq *ucb_library_folder* folder))
      (set_tile "library_folder" *ucb_library_folder*)
      (ucb:refresh_library_list))))

(defun ucb:browse_csv ( / csv_file csv_dir csv_data entry_count)
  ;; Try to get CSV from library folder first
  (setq csv_dir *ucb_library_folder*)
  (if (not csv_dir)
    (setq csv_dir (getvar "DWGPREFIX")))
  
  (setq csv_file (getfiled 
    (strcat "Select " 
      (if (= *ucb_content_type* "blocks") "Block" "Circuit") 
      " Coordinates CSV File") 
    csv_dir "csv" 4))
  
  (if csv_file
    (progn
      (setq *ucb_csv_file* csv_file)
      (princ (strcat "\n✓ CSV file selected: " csv_file))
      
      ;; Read CSV to count entries
      (if (setq csv_data (ucb:read_csv csv_file))
        (progn
          (setq entry_count (1- (length csv_data)))  ; Subtract header
          (alert (strcat "CSV File Selected!\n\n"
                        "File: " csv_file "\n"
                        "Found: " (itoa entry_count) " "
                        (if (= *ucb_content_type* "blocks") "blocks" "circuits")
                        "\n\nClick '▶ IMPORT' button to import all.")))
        (alert (strcat "Cannot read CSV file:\n" csv_file))))))


;; ═══════════════════════════════════════════════════════════════════════════
;; STEP-BY-STEP WORKFLOW FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:do_step1 (/ ss)
  (princ "\n→ Step 1: SELECT entities...")
  (setq ss (ssget))
  (if ss
    (progn
      (setq *ucb_step1_ss* ss)
      (setq *ucb_selection_count* (itoa (sslength ss)))
      (princ (strcat "\n✓ Selected " *ucb_selection_count* " entities")))
    (progn
      (setq *ucb_step1_ss* nil)
      (setq *ucb_selection_count* "0")))
  (princ))

;; Step 2 is now handled by dialog input field - no separate function needed

(defun ucb:do_step3 (/ pt)
  (if (not *ucb_step1_ss*)
    (progn
      (alert "Please SELECT entities first!\n\nClick '① SELECT Entities' button.")
      (princ))
    (if (not (and *ucb_step2_name* (> (strlen *ucb_step2_name*) 0)))
      (progn
        (alert "Please enter a NAME first!\n\nType in the '② Name' field.")
        (princ))
      (progn
        (princ "\n→ Step 3: PICK base point...")
        (setq pt (getpoint "\nPick base point (coordinate origin): "))
        (if pt
          (progn
            (setq *ucb_step3_basepoint* pt)
            (princ (strcat "\n✓ Base point: " (rtos (car pt) 2 2) "," (rtos (cadr pt) 2 2))))
          (setq *ucb_step3_basepoint* nil))
        (princ)))))

(defun ucb:do_complete_export (/ export_path)
  (if (and *ucb_step1_ss* *ucb_step2_name* *ucb_step3_basepoint*)
    (progn
      (princ "\n→ Completing export...")
      (setq export_path 
        (strcat (ucb:create_category_folder *ucb_category*) 
                "\\" *ucb_step2_name* ".dwg"))
      
      (setvar "CMDECHO" 0)
      (setvar "FILEDIA" 0)
      (setvar "EXPERT" 5)
      
      (if (findfile export_path)
        (vl-file-delete export_path))
      
      (command "._-WBLOCK" export_path "" *ucb_step3_basepoint* *ucb_step1_ss* "")
      (while (> (getvar "CMDACTIVE") 0)
        (command ""))
      
      (setvar "CMDECHO" 1)
      (setvar "FILEDIA" 1)
      (setvar "EXPERT" 0)
      
      (if (findfile export_path)
        (progn
          (ucb:save_to_csv *ucb_step2_name* *ucb_category* export_path 
                          *ucb_step3_basepoint* *ucb_step3_basepoint* *ucb_content_type*)
          (alert (strcat "SUCCESS!\n\n"
                        "Name: " *ucb_step2_name* "\n"
                        "File: " export_path "\n"
                        "Category: " *ucb_category* "\n"
                        "Entities: " (itoa (sslength *ucb_step1_ss*)) "\n"
                        "Base Point: " (rtos (car *ucb_step3_basepoint*) 2 2) "," 
                                      (rtos (cadr *ucb_step3_basepoint*) 2 2) "\n\n"
                        "Coordinates saved to CSV."))
          ;; Clear step data
          (setq *ucb_step1_ss* nil)
          (setq *ucb_selection_count* nil)
          (setq *ucb_step2_name* nil)
          (setq *ucb_step3_basepoint* nil))
        (alert "Export failed - WBLOCK error.")))
    (alert "Please complete all 3 steps!\n\n① SELECT Entities\n② Enter NAME in field\n③ PICK Base Point"))
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; EXECUTION FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun ucb:do_export_single ( / item_name export_path base_pt result)
  (done_dialog 2)
  
  (if (= *ucb_content_type* "blocks")
    (progn
      ;; Block export
      (setq item_name (getstring "\nEnter block name to export: "))
      (if (and item_name (ucb:validate_block item_name))
        (progn
          (setq export_path 
            (strcat (ucb:create_category_folder *ucb_category*) 
                    "\\" item_name ".dwg"))
          
          (setq result (ucb:wblock_export item_name export_path *ucb_export_method*))
          
          (if result
            (progn
              (ucb:save_to_csv item_name *ucb_category* export_path)
              (princ (strcat "\n✓ Exported: " item_name)))
            (princ (strcat "\n✗ Failed to export: " item_name))))
        (princ "\n✗ Invalid block name")))
    
    (progn
      ;; Circuit export - select objects FIRST
      (princ "\n╔══════════════════════════════════════════════════════╗")
      (princ "\n║         CIRCUIT ASSEMBLY EXPORT WORKFLOW             ║")
      (princ "\n╠══════════════════════════════════════════════════════╣")
      (princ "\n║  Step 1: SELECT all circuit entities (lines, blocks, ║")
      (princ "\n║          text, wires, etc.)                          ║")
      (princ "\n║  Step 2: Enter circuit name                          ║")
      (princ "\n║  Step 3: Select base point (coordinate origin)      ║")
      (princ "\n╚══════════════════════════════════════════════════════╝")
      
      (princ "\n→ Step 1: SELECT CIRCUIT ENTITIES...")
      (setq ss (ssget))
      
      (if ss
        (progn
          (princ (strcat "\n  ✓ Selected " (itoa (sslength ss)) " entities"))
          
          (princ "\n→ Step 2: ENTER CIRCUIT NAME...")
          (setq item_name (getstring T "\n  Circuit name (e.g., Motor_Control_Panel_01): "))
          
          (if (and item_name (> (strlen item_name) 0))
            (progn
              (princ "\n→ Step 3: SELECT BASE POINT (coordinate 0,0,0 for CSV)...")
              (setq base_pt (getpoint "\n  Pick base point: "))
              
              (if base_pt
                (progn
                  (setq export_path 
                    (strcat (ucb:create_category_folder *ucb_category*) 
                            "\\" item_name ".dwg"))
                  
                  (princ "\n→ Exporting circuit...")
                  (setvar "CMDECHO" 0)
                  (setvar "FILEDIA" 0)
                  (setvar "EXPERT" 5)
                  
                  (if (findfile export_path)
                    (vl-file-delete export_path))
                  
                  (command "._-WBLOCK" export_path "" base_pt ss "")
                  (while (> (getvar "CMDACTIVE") 0)
                    (command ""))
                  
                  (setvar "CMDECHO" 1)
                  (setvar "FILEDIA" 1)
                  (setvar "EXPERT" 0)
                  
                  (if (findfile export_path)
                    (progn
                      (ucb:save_to_csv item_name *ucb_category* export_path base_pt base_pt)
                      (princ "\n╔══════════════════════════════════════════════════════╗")
                      (princ (strcat "\n║ ✓ SUCCESS: " item_name))
                      (princ (strcat "\n║   File: " export_path))
                      (princ (strcat "\n║   Category: " *ucb_category*))
                      (princ (strcat "\n║   Entities: " (itoa (sslength ss))))
                      (princ (strcat "\n║   Base Point: " (rtos (car base_pt) 2 2) "," (rtos (cadr base_pt) 2 2)))
                      (princ "\n║   ✓ Coordinates saved to CSV for batch import")
                      (princ "\n╚══════════════════════════════════════════════════════╝"))
                    (princ "\n✗ Failed to export circuit - WBLOCK error")))
                (princ "\n✗ No base point selected - Export cancelled")))
            (princ "\n✗ No circuit name entered - Export cancelled")))
        (princ "\n✗ No entities selected - Export cancelled")))))

(defun ucb:do_export_batch ( / block_list item export_path result success_count fail_count)
  (done_dialog 2)
  
  (if (= *ucb_content_type* "blocks")
    (progn
      (princ "\n→ BATCH BLOCK EXPORT")
      (setq block_list (ucb:get_block_list))
      (setq success_count 0)
      (setq fail_count 0)
      
      (foreach item block_list
        (princ (strcat "\n  Exporting: " item))
        (setq export_path 
          (strcat (ucb:create_category_folder *ucb_category*) 
                  "\\" item ".dwg"))
        
        (setq result (ucb:wblock_export item export_path *ucb_export_method*))
        
        (if result
          (progn
            (ucb:save_to_csv item *ucb_category* export_path)
            (setq success_count (1+ success_count)))
          (setq fail_count (1+ fail_count))))
      
      (princ (strcat "\n✓ Batch complete: " 
                     (itoa success_count) " succeeded, " 
                     (itoa fail_count) " failed")))
    
    (progn
      (princ "\n✗ Batch export for circuits not implemented")
      (princ "\n  Use single export for each circuit"))))

(defun ucb:do_export_all ( / )
  (done_dialog 2)
  (princ "\n→ EXPORT ALL")
  (princ (strcat "\n  Exporting all " *ucb_content_type* " to category: " *ucb_category*))
  (ucb:do_export_batch))

(defun ucb:do_import ( / file_list item_data item_path insert_pt csv_path csv_data)
  (setq file_list (ucb:get_library_files *ucb_content_type*))
  
  (if (and *ucb_import_selection* file_list)
    (progn
      (setq item_data (nth (atoi *ucb_import_selection*) file_list))
      (setq item_path (caddr item_data))
      
      (if (= *ucb_content_type* "blocks")
        (progn
          (princ (strcat "\n→ Importing block: " (car item_data)))
          (ucb:block_import item_path *ucb_import_method*)
          (alert (strcat "Block imported: " (car item_data))))
        
        (progn
          ;; For circuits, check CSV for coordinates first
          (setq csv_path (ucb:get_csv_path *ucb_content_type*))
          (setq insert_pt nil)
          
          (if (and (findfile csv_path)
                   (setq csv_data (ucb:read_csv *ucb_content_type*)))
            (progn
              ;; Search for this circuit in CSV
              (foreach entry csv_data
                (if (and (not insert_pt)
                         (= (car entry) (car item_data))
                         (>= (length entry) 6))
                  (setq insert_pt 
                    (list (atof (nth 3 entry))   ; BaseX
                          (atof (nth 4 entry))   ; BaseY
                          (atof (nth 5 entry)))))) ; BaseZ
              
              (if insert_pt
                (princ (strcat "\n✓ Using CSV coordinates: " 
                              (rtos (car insert_pt) 2 2) "," 
                              (rtos (cadr insert_pt) 2 2))))))
          
          ;; If no CSV coordinates, ask user
          (if (not insert_pt)
            (progn
              (princ (strcat "\n→ Select insertion point for: " (car item_data)))
              (setq insert_pt (getpoint (strcat "\nPick insertion point for " (car item_data) ": ")))))
          
          (if insert_pt
            (progn
              (princ (strcat "\n→ Importing circuit: " (car item_data)))
              (ucb:circuit_import item_path insert_pt *ucb_import_scale* *ucb_import_rotation* nil)
              (alert (strcat "Circuit imported: " (car item_data) "\nAt: " 
                            (rtos (car insert_pt) 2 2) "," (rtos (cadr insert_pt) 2 2))))
            (princ "\n✗ No insertion point selected")))))
    (princ "\n✗ No item selected")))

(defun ucb:do_import_csv ( / csv_path csv_data item_name item_path insert_pt scale rotation count)
  ;; Use selected CSV file or default
  (if *ucb_csv_file*
    (setq csv_path *ucb_csv_file*)
    (setq csv_path (ucb:get_csv_path *ucb_content_type*)))
  
  (if (not (findfile csv_path))
    (progn
      (alert (strcat "CSV file not found!\n\nPath: " csv_path "\n\nClick '📄 CSV' to browse for file."))
      (princ (strcat "\n✗ CSV file not found: " csv_path)))
    
    (progn
      (setq csv_data (ucb:read_csv *ucb_content_type*))
      (setq count 0)
      
      (if (= *ucb_content_type* "blocks")
        (progn
          (alert "Block CSV import not supported!\n\nBlocks don't have coordinate data.\nUse regular Import for blocks.")
          (princ "\n✗ Block CSV import not supported - blocks don't have coordinates"))
        
        (progn
          (princ "\n→ BATCH IMPORT FROM CSV (Circuits)")
          (foreach entry csv_data
            (setq item_name (car entry))
            (setq item_path (caddr entry))
            
            (if (and (findfile item_path)
                     (>= (length entry) 6))
              (progn
                (setq insert_pt 
                  (list (atof (nth 3 entry))   ; BaseX
                        (atof (nth 4 entry))   ; BaseY
                        (atof (nth 5 entry)))) ; BaseZ
                
                (princ (strcat "\n  Importing: " item_name 
                               " at (" (rtos (car insert_pt) 2 2) "," 
                               (rtos (cadr insert_pt) 2 2) ")"))
                
                (ucb:circuit_import item_path insert_pt 1.0 0.0 nil)
                (setq count (1+ count)))
              
              (princ (strcat "\n  ✗ Cannot import: " item_name))))))
      
      (alert (strcat "Batch Import Complete!\n\nImported " (itoa count) " items from CSV"))
      (princ (strcat "\n✓ Batch import complete: " (itoa count) " items imported"))
      (setq *ucb_csv_file* nil))))

;; ═══════════════════════════════════════════════════════════════════════════
;; INITIALIZATION
;; ═══════════════════════════════════════════════════════════════════════════

(princ "\n╔════════════════════════════════════════════════════════════════╗")
(princ "\n║           UNIFIED CIRCUIT & BLOCK MANAGER v2.3                ║")
(princ "\n╠════════════════════════════════════════════════════════════════╣")
(princ "\n║  Commands:                                                     ║")
(princ "\n║    UCB / UNIFIEDMANAGER - Open Unified Manager Dialog         ║")
(princ "\n║                                                                 ║")
(princ "\n║  Features:                                                     ║")
(princ "\n║    • Export/Import Block Definitions                           ║")
(princ "\n║    • Export/Import Circuit Assemblies                          ║")
(princ "\n║    • 5 Export Methods & 5 Import Methods                       ║")
(princ "\n║    • CSV Coordinate Tracking                                   ║")
(princ "\n║    • Batch Operations                                          ║")
(princ "\n║    • Category Organization                                     ║")
(princ "\n║                                                                 ║")
(princ "\n║  Library: C:\\Temp\\Circuit_Library                            ║")
(princ "\n╚════════════════════════════════════════════════════════════════╝")
(princ "\n")

