;; ═══════════════════════════════════════════════════════════════════════════
;; CIRCUIT MANAGER v1.0 - Professional UI
;; Export/Import entire drawing sections with blocks intact
;; ═══════════════════════════════════════════════════════════════════════════

;; Global variables
(if (not *circuit_export_folder*) 
  (setq *circuit_export_folder* "C:\\Temp\\Circuit_Library"))

(if (not *circuit_type*) 
  (setq *circuit_type* "General"))

(if (not *export_mode*) 
  (setq *export_mode* 0))  ; 0=single, 1=batch

;; Circuit types for categorization
(setq *circuit_types* '("General" "Control_Panel" "Motor_Circuit" "Power_Distribution" 
                        "Lighting_Circuit" "Instrumentation" "Communication" "Safety_System"
                        "HVAC_System" "Custom"))

;; ═══════════════════════════════════════════════════════════════════════════
;; MAIN COMMAND - Show Circuit Manager Dialog
;; ═══════════════════════════════════════════════════════════════════════════

(defun C:CM ( / )
  (cm:show_dialog)
  (princ))

(defun C:CIRCUITMANAGER ( / )
  (cm:show_dialog)
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; DIALOG FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun cm:show_dialog ( / dcl_id result dcl_file)
  
  ;; Find DCL file
  (setq dcl_file (findfile "CircuitManager_v1.0.dcl"))
  
  (if (not dcl_file)
    (progn
      (alert "Error: CircuitManager_v1.0.dcl not found!\n\nMake sure both .LSP and .DCL files are in the same folder.")
      nil)
    (progn
      ;; Load DCL
      (setq dcl_id (load_dialog dcl_file))
      
      (if (not (new_dialog "circuitmanager" dcl_id))
        (progn
          (alert "Error: Cannot load Circuit Manager dialog!")
          (unload_dialog dcl_id)
          nil)
        (progn
          ;; Initialize dialog
          (cm:init_dialog)
          
          ;; Set up callbacks
          (action_tile "mode_export" "(cm:mode_changed \"export\")")
          (action_tile "mode_import" "(cm:mode_changed \"import\")")
          
          (action_tile "btn_browse_export" "(cm:browse_folder \"export\")")
          (action_tile "btn_browse_import" "(cm:browse_folder \"import\")")
          
          (action_tile "btn_start_export" "(cm:start_export)")
          (action_tile "btn_start_import" "(cm:start_import)")
          
          (action_tile "btn_refresh" "(cm:refresh_circuit_list)")
          (action_tile "btn_preview" "(cm:preview_circuit)")
          (action_tile "btn_help" "(cm:show_help)")
          
          (action_tile "circuit_list" "(cm:circuit_selected)")
          
          (action_tile "accept" "(done_dialog 1)")
          (action_tile "cancel" "(done_dialog 0)")
          
          ;; Show dialog
          (setq result (start_dialog))
          
          (unload_dialog dcl_id)
          result
        ))
    ))
)

(defun cm:init_dialog ( / )
  ;; Set initial values
  (set_tile "export_folder" *circuit_export_folder*)
  (set_tile "import_folder" *circuit_export_folder*)
  
  ;; Populate circuit types
  (start_list "circuit_type")
  (mapcar 'add_list *circuit_types*)
  (end_list)
  (set_tile "circuit_type" "0")
  
  ;; Set export mode
  (if (= *export_mode* 0)
    (set_tile "export_single" "1")
    (set_tile "export_batch" "1"))
  
  ;; Set default mode (export)
  (cm:mode_changed "export")
  
  (set_tile "status_text" "Ready - Select operation mode")
)

(defun cm:mode_changed (mode / )
  (cond
    ((= mode "export")
     (mode_tile "export_panel" 0)  ; Enable
     (mode_tile "import_panel" 1)  ; Disable
     (set_tile "status_text" "EXPORT mode - Select entities to save as circuit"))
    
    ((= mode "import")
     (mode_tile "export_panel" 1)  ; Disable
     (mode_tile "import_panel" 0)  ; Enable
     (set_tile "status_text" "IMPORT mode - Select circuit to load")
     (cm:refresh_circuit_list))
  )
)

(defun cm:browse_folder (type / folder)
  (setq folder (cm:select_folder 
    (if (= type "export")
      "Select Export Folder"
      "Select Import Folder")
    *circuit_export_folder*))
  
  (if folder
    (progn
      (setq *circuit_export_folder* folder)
      (set_tile "export_folder" folder)
      (set_tile "import_folder" folder)
      (if (= type "import")
        (cm:refresh_circuit_list))
    ))
)

(defun cm:select_folder (title default / folder)
  ;; Simple folder selection using getfiled for DWG (user navigates to folder)
  (setvar "FILEDIA" 1)
  (setq folder (getfiled title default "dwg" 2))  ; 2 = select folder
  (if folder
    (vl-filename-directory folder)
    default)
)

(defun cm:refresh_circuit_list ( / file_list circuit_info)
  (set_tile "status_text" "Scanning circuit library...")
  
  (if (not (findfile *circuit_export_folder*))
    (progn
      (set_tile "status_text" "Error: Library folder not found")
      (start_list "circuit_list")
      (add_list "No circuits found - folder does not exist")
      (end_list))
    (progn
      (setq file_list (vl-directory-files *circuit_export_folder* "*.dwg"))
      
      (start_list "circuit_list")
      (if (not file_list)
        (add_list "No circuits found in library")
        (foreach file file_list
          (setq full_path (strcat *circuit_export_folder* "\\" file))
          (setq file_size (/ (vl-file-size full_path) 1024))  ; KB
          (setq circuit_info (strcat file " (" (itoa file_size) " KB)"))
          (add_list circuit_info)
        ))
      (end_list)
      
      (set_tile "status_text" 
        (strcat "Found " (itoa (length (if file_list file_list '()))) " circuits in library"))
    ))
)

(defun cm:circuit_selected ( / )
  (set_tile "status_text" "Circuit selected - Click START IMPORT to load")
)

(defun cm:preview_circuit ( / selected_idx file_list selected_file)
  (setq selected_idx (atoi (get_tile "circuit_list")))
  (setq file_list (vl-directory-files *circuit_export_folder* "*.dwg"))
  
  (if (and file_list (>= selected_idx 0) (< selected_idx (length file_list)))
    (progn
      (setq selected_file (nth selected_idx file_list))
      (alert (strcat "Circuit Preview:\n\n"
                     "Name: " selected_file "\n"
                     "Path: " *circuit_export_folder* "\\" selected_file "\n"
                     "Size: " (itoa (/ (vl-file-size 
                       (strcat *circuit_export_folder* "\\" selected_file)) 1024)) " KB\n\n"
                     "Click START IMPORT to load this circuit")))
    (alert "Please select a circuit from the list first"))
)

(defun cm:show_help ( / )
  (alert (strcat 
    "CIRCUIT MANAGER v1.0 - Help\n"
    "═══════════════════════════════════════\n\n"
    "EXPORT MODE:\n"
    "  1. Select 'Export Circuit' mode\n"
    "  2. Enter circuit name\n"
    "  3. Select circuit type/category\n"
    "  4. Click START EXPORT\n"
    "  5. Select all entities in circuit\n"
    "  6. Pick base point for insertion\n\n"
    "IMPORT MODE:\n"
    "  1. Select 'Import Circuit' mode\n"
    "  2. Choose circuit from list\n"
    "  3. Set scale and rotation (optional)\n"
    "  4. Click START IMPORT\n"
    "  5. Pick insertion point in drawing\n\n"
    "FEATURES:\n"
    "  • Exports complete circuits with blocks intact\n"
    "  • Preserves block references and hierarchy\n"
    "  • Maintains layers, properties, attributes\n"
    "  • Batch export for multiple circuits\n"
    "  • Organized circuit library"))
)

;; ═══════════════════════════════════════════════════════════════════════════
;; EXPORT FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun cm:start_export ( / circuit_name circuit_type export_mode)
  ;; Get values from dialog
  (setq circuit_name (get_tile "circuit_name"))
  (setq circuit_type (nth (atoi (get_tile "circuit_type")) *circuit_types*))
  (setq export_mode (get_tile "export_single"))
  (setq *circuit_export_folder* (get_tile "export_folder"))
  
  ;; Validate
  (cond
    ((or (not circuit_name) (= circuit_name ""))
     (alert "Please enter a circuit name!")
     nil)
    
    ((not (findfile *circuit_export_folder*))
     (alert (strcat "Export folder does not exist:\n" *circuit_export_folder* "\n\nCreating folder..."))
     (vl-mkdir *circuit_export_folder*)
     (if (findfile *circuit_export_folder*)
       (progn
         (set_tile "status_text" "Folder created - Ready to export")
         (cm:do_export circuit_name circuit_type))
       (progn
         (alert "Failed to create folder!")
         nil)))
    
    (T
     (cm:do_export circuit_name circuit_type))
  )
)

(defun cm:do_export (circuit_name circuit_type / ss export_path base_pt old_osmode file_size)
  ;; Close dialog temporarily
  (done_dialog 2)
  
  (princ "\n╔════════════════════════════════════════════════════════════╗")
  (princ "\n║         CIRCUIT EXPORT - Save Drawing Section             ║")
  (princ "\n╚════════════════════════════════════════════════════════════╝")
  (princ (strcat "\n  Circuit: " circuit_name))
  (princ (strcat "\n  Type: " circuit_type))
  (princ "\n")
  
  ;; Select entities
  (princ "\n→ SELECT CIRCUIT ENTITIES")
  (princ "\n  Select all entities (lines, blocks, text, etc.)...")
  (setq ss (ssget))
  
  (if (not ss)
    (progn
      (princ "\n✗ No entities selected. Export cancelled.")
      (princ))
    (progn
      (princ (strcat "\n✓ Selected " (itoa (sslength ss)) " entities"))
      
      ;; Create export path with type subfolder
      (setq type_folder (strcat *circuit_export_folder* "\\" circuit_type))
      (if (not (findfile type_folder))
        (vl-mkdir type_folder))
      
      (setq export_path (strcat type_folder "\\" circuit_name ".dwg"))
      (princ (strcat "\n✓ Export path: " export_path))
      
      ;; Delete existing file
      (if (findfile export_path)
        (progn
          (princ "\n  Deleting existing file...")
          (vl-file-delete export_path)))
      
      ;; Get base point
      (setq old_osmode (getvar "OSMODE"))
      (setvar "OSMODE" 0)
      (princ "\n\n→ SELECT BASE POINT")
      (princ "\n  Pick base point (or press Enter for 0,0):")
      (setq base_pt (getpoint "\n  Base point: "))
      (if (not base_pt)
        (setq base_pt '(0.0 0.0 0.0)))
      (setvar "OSMODE" old_osmode)
      (princ (strcat "\n✓ Base point: " (rtos (car base_pt)) "," (rtos (cadr base_pt))))
      
      ;; Export
      (princ "\n\n→ EXPORTING CIRCUIT...")
      (setvar "CMDECHO" 0)
      (setvar "FILEDIA" 0)
      (setvar "EXPERT" 5)
      
      (command "._-WBLOCK" export_path "" base_pt ss "")
      (while (> (getvar "CMDACTIVE") 0)
        (command ""))
      
      ;; Verify
      (if (findfile export_path)
        (progn
          (setq file_size (vl-file-size export_path))
          (princ "\n\n✓ SUCCESS - Circuit exported!")
          (princ (strcat "\n  File: " export_path))
          (princ (strcat "\n  Size: " (itoa file_size) " bytes"))
          (alert (strcat "Circuit exported successfully!\n\n"
                        "Name: " circuit_name "\n"
                        "Type: " circuit_type "\n"
                        "File: " export_path "\n"
                        "Size: " (itoa (/ file_size 1024)) " KB")))
        (progn
          (princ "\n\n✗ FAILED - File not created")
          (alert "Export failed! Check folder permissions.")))
      
      (setvar "CMDECHO" 1)
      (setvar "FILEDIA" 1)
      (setvar "EXPERT" 0)
    ))
  
  (princ)
)

;; ═══════════════════════════════════════════════════════════════════════════
;; IMPORT FUNCTIONS
;; ═══════════════════════════════════════════════════════════════════════════

(defun cm:start_import ( / selected_idx file_list circuit_file scale rotation explode)
  ;; Get values
  (setq selected_idx (atoi (get_tile "circuit_list")))
  (setq file_list (vl-directory-files *circuit_export_folder* "*.dwg" 1))  ; Include subfolders
  (setq scale (atof (get_tile "import_scale")))
  (setq rotation (atof (get_tile "import_rotation")))
  (setq explode (= (get_tile "import_explode") "1"))
  
  (if (not file_list)
    (alert "No circuits found in library!")
    (progn
      (if (or (< selected_idx 0) (>= selected_idx (length file_list)))
        (alert "Please select a circuit from the list!")
        (progn
          ;; Find full path of selected circuit
          (setq circuit_file (cm:find_circuit_file 
            (nth selected_idx (vl-directory-files *circuit_export_folder* "*.dwg"))))
          
          (if circuit_file
            (progn
              (done_dialog 2)
              (cm:do_import circuit_file scale rotation explode))
            (alert "Circuit file not found!"))
        ))
    ))
)

(defun cm:find_circuit_file (filename / full_path subfolders)
  ;; Check root folder first
  (setq full_path (strcat *circuit_export_folder* "\\" filename))
  (if (findfile full_path)
    full_path
    ;; Check subfolders
    (progn
      (setq subfolders (vl-directory-files *circuit_export_folder* nil -1))
      (foreach folder subfolders
        (if (not (or (= folder ".") (= folder "..")))
          (progn
            (setq full_path (strcat *circuit_export_folder* "\\" folder "\\" filename))
            (if (findfile full_path)
              (return full_path)))))
      full_path))
)

(defun cm:do_import (circuit_file scale rotation explode / import_pt old_osmode)
  (princ "\n╔════════════════════════════════════════════════════════════╗")
  (princ "\n║         CIRCUIT IMPORT - Load Drawing Section              ║")
  (princ "\n╚════════════════════════════════════════════════════════════╝")
  (princ (strcat "\n  File: " circuit_file))
  (princ (strcat "\n  Scale: " (rtos scale)))
  (princ (strcat "\n  Rotation: " (rtos rotation) "°"))
  (princ "\n")
  
  ;; Get insertion point
  (setq old_osmode (getvar "OSMODE"))
  (setvar "OSMODE" 0)
  (princ "\n→ SELECT INSERTION POINT")
  (setq import_pt (getpoint "\n  Pick insertion point: "))
  
  (if (not import_pt)
    (progn
      (princ "\n✗ No insertion point. Import cancelled.")
      (setvar "OSMODE" old_osmode)
      (princ))
    (progn
      (setvar "OSMODE" old_osmode)
      (princ (strcat "\n✓ Insertion: " (rtos (car import_pt)) "," (rtos (cadr import_pt))))
      
      ;; Import
      (princ "\n\n→ IMPORTING CIRCUIT...")
      (setvar "CMDECHO" 0)
      (setvar "FILEDIA" 0)
      (setvar "EXPERT" 5)
      
      ;; Convert rotation to radians
      (setq rotation (* rotation (/ pi 180.0)))
      
      (if explode
        (command "._INSERT" (strcat "*" circuit_file) import_pt scale scale rotation)
        (command "._INSERT" circuit_file import_pt scale scale rotation))
      
      (while (> (getvar "CMDACTIVE") 0)
        (command ""))
      
      (princ "\n\n✓ SUCCESS - Circuit imported!")
      (alert "Circuit imported successfully!")
      
      (setvar "CMDECHO" 1)
      (setvar "FILEDIA" 1)
      (setvar "EXPERT" 0)
    ))
  
  (princ)
)

;; ═══════════════════════════════════════════════════════════════════════════
;; LOAD MESSAGE
;; ═══════════════════════════════════════════════════════════════════════════

(princ "\n")
(princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
(princ "\n  CIRCUIT MANAGER v1.0 LOADED - Professional UI")
(princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
(princ "\n")
(princ "\n  Main Commands:")
(princ "\n  ├─ CM               : Open Circuit Manager dialog")
(princ "\n  └─ CIRCUITMANAGER   : Open Circuit Manager dialog")
(princ "\n")
(princ (strcat "\n  Circuit Library: " *circuit_export_folder*))
(princ "\n")
(princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
(princ)
