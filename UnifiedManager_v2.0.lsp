;; ═══════════════════════════════════════════════════════════════════════════
;; UNIFIED CIRCUIT & BLOCK MANAGER v2.0
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
;;   (load "UnifiedManager_v2.0.lsp")
;;   UCB  or  UNIFIEDMANAGER
;;
;; ═══════════════════════════════════════════════════════════════════════════

;; Global variables
(if (not *ucb_library_folder*) 
  (setq *ucb_library_folder* "C:\\Temp\\Circuit_Library"))

(if (not *ucb_operation_mode*) 
  (setq *ucb_operation_mode* "export"))  ; "export" or "import"

(if (not *ucb_content_type*) 
  (setq *ucb_content_type* "blocks"))    ; "blocks" or "circuits"

(if (not *ucb_export_method*) 
  (setq *ucb_export_method* 0))          ; 0-4

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

(defun ucb:show_dialog ( / dcl_id result)
  (setq dcl_id (load_dialog "UnifiedManager_v2.0.dcl"))
  
  (if (not (new_dialog "unified_manager" dcl_id))
    (progn
      (princ "\n✗ Cannot load dialog")
      (unload_dialog dcl_id)
      nil)
    (progn
      (ucb:init_dialog)
      (setq result (start_dialog))
      (unload_dialog dcl_id)
      result)))

(defun ucb:init_dialog ( / )
  ;; Set operation mode
  (set_tile "op_export" (if (= *ucb_operation_mode* "export") "1" "0"))
  (set_tile "op_import" (if (= *ucb_operation_mode* "import") "1" "0"))
  
  ;; Set content type
  (set_tile "type_blocks" (if (= *ucb_content_type* "blocks") "1" "0"))
  (set_tile "type_circuits" (if (= *ucb_content_type* "circuits") "1" "0"))
  
  ;; Initialize export panel
  (set_tile "export_mode" "0")
  (start_list "export_method")
  (mapcar 'add_list *ucb_export_methods*)
  (end_list)
  (set_tile "export_method" (itoa *ucb_export_method*))
  
  (start_list "category_list")
  (mapcar 'add_list *ucb_categories*)
  (end_list)
  (set_tile "category_list" "0")
  
  ;; Initialize import panel
  (set_tile "import_source" "0")
  (start_list "import_method")
  (mapcar 'add_list *ucb_import_methods*)
  (end_list)
  (set_tile "import_method" (itoa *ucb_import_method*))
  
  (set_tile "insert_scale" "1.0")
  (set_tile "insert_rotation" "0.0")
  
  ;; Refresh library list
  (ucb:refresh_library_list)
  
  ;; Setup callbacks
  (action_tile "op_export" "(setq *ucb_operation_mode* \"export\") (ucb:mode_changed)")
  (action_tile "op_import" "(setq *ucb_operation_mode* \"import\") (ucb:mode_changed)")
  (action_tile "type_blocks" "(setq *ucb_content_type* \"blocks\") (ucb:type_changed)")
  (action_tile "type_circuits" "(setq *ucb_content_type* \"circuits\") (ucb:type_changed)")
  
  (action_tile "export_method" "(setq *ucb_export_method* (atoi $value))")
  (action_tile "import_method" "(setq *ucb_import_method* (atoi $value))")
  (action_tile "category_list" "(setq *ucb_category* (nth (atoi $value) *ucb_categories*))")
  
  (action_tile "btn_browse" "(ucb:browse_folder)")
  (action_tile "btn_refresh" "(ucb:refresh_library_list)")
  
  (action_tile "btn_export_single" "(ucb:do_export_single)")
  (action_tile "btn_export_batch" "(ucb:do_export_batch)")
  (action_tile "btn_export_all" "(ucb:do_export_all)")
  
  (action_tile "btn_import" "(ucb:do_import)")
  (action_tile "btn_import_csv" "(ucb:do_import_csv)")
  
  (action_tile "cancel" "(done_dialog 0)")
  (action_tile "accept" "(done_dialog 1)")
  
  (ucb:mode_changed))

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
  (start_list "library_list")
  
  (setq file_list (ucb:get_library_files *ucb_content_type*))
  (mapcar '(lambda (item) 
             (add_list (strcat (car item) " [" (cadr item) "]"))) 
          file_list)
  
  (end_list)
  (set_tile "status_text" 
    (strcat "Found " (itoa (length file_list)) " " *ucb_content_type* " in library")))

(defun ucb:browse_folder ( / folder)
  (setq folder (getfiled "Select Library Folder" *ucb_library_folder* "" 1))
  (if folder
    (progn
      (setq *ucb_library_folder* (vl-filename-directory folder))
      (set_tile "library_path" *ucb_library_folder*)
      (ucb:refresh_library_list))))


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
      ;; Circuit export
      (setq item_name (getstring "\nEnter circuit name: "))
      (if item_name
        (progn
          (setq base_pt (getpoint "\nSelect base point for circuit: "))
          (if base_pt
            (progn
              (setq export_path 
                (strcat (ucb:create_category_folder *ucb_category*) 
                        "\\" item_name ".dwg"))
              
              (setq result (ucb:circuit_export item_name export_path base_pt))
              
              (if result
                (progn
                  (ucb:save_to_csv item_name *ucb_category* export_path base_pt base_pt)
                  (princ (strcat "\n✓ Exported circuit: " item_name)))
                (princ (strcat "\n✗ Failed to export circuit: " item_name))))
            (princ "\n✗ No base point selected")))
        (princ "\n✗ No circuit name entered")))))

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

(defun ucb:do_import ( / selected_items file_list item_data item_path insert_pt scale rotation)
  (done_dialog 2)
  
  (setq selected_items (get_tile "library_list"))
  (setq file_list (ucb:get_library_files *ucb_content_type*))
  
  (if (and selected_items file_list)
    (progn
      (setq item_data (nth (atoi selected_items) file_list))
      (setq item_path (caddr item_data))
      
      (setq scale (atof (get_tile "insert_scale")))
      (setq rotation (atof (get_tile "insert_rotation")))
      
      (if (= *ucb_content_type* "blocks")
        (progn
          (princ (strcat "\n→ Importing block: " (car item_data)))
          (ucb:block_import item_path *ucb_import_method*))
        
        (progn
          (setq insert_pt (getpoint "\nSelect insertion point: "))
          (if insert_pt
            (progn
              (princ (strcat "\n→ Importing circuit: " (car item_data)))
              (ucb:circuit_import item_path insert_pt scale rotation nil))
            (princ "\n✗ No insertion point selected")))))
    (princ "\n✗ No item selected")))

(defun ucb:do_import_csv ( / csv_path csv_data item_name item_path insert_pt scale rotation count)
  (done_dialog 2)
  
  (setq csv_path (ucb:get_csv_path *ucb_content_type*))
  
  (if (not (findfile csv_path))
    (princ (strcat "\n✗ CSV file not found: " csv_path))
    
    (progn
      (setq csv_data (ucb:read_csv csv_path))
      (setq count 0)
      
      (if (= *ucb_content_type* "blocks")
        (progn
          (princ "\n→ BATCH IMPORT FROM CSV (Blocks)")
          (foreach entry (cdr csv_data)  ; Skip header
            (setq item_name (car entry))
            (setq item_path (caddr entry))
            
            (if (findfile item_path)
              (progn
                (princ (strcat "\n  Importing: " item_name))
                (ucb:block_import item_path *ucb_import_method*)
                (setq count (1+ count)))
              (princ (strcat "\n  ✗ File not found: " item_path)))))
        
        (progn
          (princ "\n→ BATCH IMPORT FROM CSV (Circuits)")
          (foreach entry (cdr csv_data)  ; Skip header
            (setq item_name (car entry))
            (setq item_path (caddr entry))
            
            (if (and (findfile item_path)
                     (>= (length entry) 7))
              (progn
                (setq insert_pt 
                  (list (atof (nth 6 entry))   ; InsertX
                        (atof (nth 7 entry))   ; InsertY
                        (atof (nth 8 entry)))) ; InsertZ
                
                (princ (strcat "\n  Importing: " item_name 
                               " at " (vl-princ-to-string insert_pt)))
                
                (ucb:circuit_import item_path insert_pt 1.0 0.0 nil)
                (setq count (1+ count)))
              
              (princ (strcat "\n  ✗ Cannot import: " item_name))))))
      
      (princ (strcat "\n✓ Batch import complete: " (itoa count) " items imported")))))

;; ═══════════════════════════════════════════════════════════════════════════
;; INITIALIZATION
;; ═══════════════════════════════════════════════════════════════════════════

(princ "\n╔════════════════════════════════════════════════════════════════╗")
(princ "\n║           UNIFIED CIRCUIT & BLOCK MANAGER v2.0                ║")
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

