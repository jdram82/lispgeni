;; ═══════════════════════════════════════════════════════════════════════════
;; CIRCUIT EXPORT/IMPORT TOOL v1.0
;; Export/Import entire drawing sections with blocks intact
;; ═══════════════════════════════════════════════════════════════════════════
;;
;; PURPOSE: Export selected geometry + block references as complete circuits
;;          Import circuits back with all blocks and references preserved
;;
;; KEY FEATURES:
;;   ✅ Exports selected entities (lines, blocks, text, etc.) as complete assembly
;;   ✅ Preserves block references and hierarchy
;;   ✅ Maintains layer structure, properties, attributes
;;   ✅ Imports as complete circuit with all relationships intact
;;
;; USAGE:
;;   EXPORT: (load "CircuitExportImport_v1.0.lsp") then type EXPORTCIRCUIT
;;   IMPORT: Type IMPORTCIRCUIT
;;
;; ═══════════════════════════════════════════════════════════════════════════

;; Global variables
(if (not *circuit_export_folder*) 
  (setq *circuit_export_folder* "C:\\Temp\\Circuit_Library"))

;; ═══════════════════════════════════════════════════════════════════════════
;; EXPORT CIRCUIT - Save selected geometry as complete DWG
;; ═══════════════════════════════════════════════════════════════════════════

(defun C:EXPORTCIRCUIT ( / ss circuit_name export_path base_pt old_osmode)
  
  (princ "\n╔════════════════════════════════════════════════════════════╗")
  (princ "\n║         CIRCUIT EXPORT - Save Drawing Section             ║")
  (princ "\n╚════════════════════════════════════════════════════════════╝")
  (princ "\n")
  
  ;; Step 1: Select entities to export
  (princ "\n→ STEP 1: SELECT CIRCUIT ENTITIES")
  (princ "\n  Select all entities (lines, blocks, text, etc.) to export...")
  (setq ss (ssget))
  
  (if (not ss)
    (progn
      (princ "\n✗ No entities selected. Export cancelled.")
      (princ))
    (progn
      (princ (strcat "\n✓ Selected " (itoa (sslength ss)) " entities"))
      
      ;; Step 2: Get circuit name
      (princ "\n\n→ STEP 2: ENTER CIRCUIT NAME")
      (setq circuit_name (getstring T "\n  Enter circuit name (e.g., 'Motor_Control_Circuit'): "))
      
      (if (or (not circuit_name) (= circuit_name ""))
        (progn
          (princ "\n✗ No name entered. Export cancelled.")
          (princ))
        (progn
          (princ (strcat "\n✓ Circuit name: " circuit_name))
          
          ;; Step 3: Create export path
          (if (not (findfile *circuit_export_folder*))
            (progn
              (princ "\n  Creating export folder...")
              (vl-mkdir *circuit_export_folder*)))
          
          (setq export_path (strcat *circuit_export_folder* "\\" circuit_name ".dwg"))
          (princ (strcat "\n✓ Export path: " export_path))
          
          ;; Delete existing file if present
          (if (findfile export_path)
            (progn
              (princ "\n  Deleting existing file...")
              (vl-file-delete export_path)))
          
          ;; Step 4: Get base point for insertion
          (setq old_osmode (getvar "OSMODE"))
          (setvar "OSMODE" 0)
          (princ "\n\n→ STEP 3: SELECT BASE POINT")
          (princ "\n  Pick base point for circuit insertion (or press Enter for 0,0):")
          (setq base_pt (getpoint "\n  Base point: "))
          (if (not base_pt)
            (setq base_pt '(0.0 0.0 0.0)))
          (setvar "OSMODE" old_osmode)
          (princ (strcat "\n✓ Base point: " (rtos (car base_pt)) "," (rtos (cadr base_pt))))
          
          ;; Step 5: Export using WBLOCK
          (princ "\n\n→ STEP 4: EXPORTING CIRCUIT...")
          (princ "\n  Creating DWG file with all selected entities...")
          
          (setvar "CMDECHO" 0)
          (setvar "FILEDIA" 0)
          (setvar "EXPERT" 5)
          
          ;; Use WBLOCK with selection set (NOT block definition export)
          ;; This exports actual geometry + block references
          (command "._-WBLOCK" export_path "" base_pt ss "")
          
          (while (> (getvar "CMDACTIVE") 0)
            (command ""))
          
          ;; Step 6: Verify export
          (if (findfile export_path)
            (progn
              (setq file_size (vl-file-size export_path))
              (princ (strcat "\n\n✓ SUCCESS - Circuit exported!"))
              (princ (strcat "\n  File: " export_path))
              (princ (strcat "\n  Size: " (itoa file_size) " bytes"))
              (princ (strcat "\n  Entities: " (itoa (sslength ss))))
              (princ "\n\n  Use IMPORTCIRCUIT to load this circuit into other drawings"))
            (progn
              (princ "\n\n✗ FAILED - File not created")
              (princ "\n  Check folder permissions and try again")))
          
          (setvar "CMDECHO" 1)
          (setvar "FILEDIA" 1)
          (setvar "EXPERT" 0)
        ))
    ))
  
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; IMPORT CIRCUIT - Load circuit DWG into current drawing
;; ═══════════════════════════════════════════════════════════════════════════

(defun C:IMPORTCIRCUIT ( / circuit_file import_pt old_osmode scale_factor rotation)
  
  (princ "\n╔════════════════════════════════════════════════════════════╗")
  (princ "\n║         CIRCUIT IMPORT - Load Drawing Section              ║")
  (princ "\n╚════════════════════════════════════════════════════════════╝")
  (princ "\n")
  
  ;; Step 1: Select circuit file
  (princ "\n→ STEP 1: SELECT CIRCUIT FILE")
  (setvar "FILEDIA" 1)
  (setq circuit_file (getfiled "Select Circuit DWG File" *circuit_export_folder* "dwg" 8))
  
  (if (not circuit_file)
    (progn
      (princ "\n✗ No file selected. Import cancelled.")
      (princ))
    (progn
      (princ (strcat "\n✓ Selected: " circuit_file))
      
      ;; Step 2: Get insertion point
      (setq old_osmode (getvar "OSMODE"))
      (setvar "OSMODE" 0)
      (princ "\n\n→ STEP 2: SELECT INSERTION POINT")
      (setq import_pt (getpoint "\n  Pick insertion point: "))
      
      (if (not import_pt)
        (progn
          (princ "\n✗ No insertion point selected. Import cancelled.")
          (setvar "OSMODE" old_osmode)
          (princ))
        (progn
          (princ (strcat "\n✓ Insertion point: " (rtos (car import_pt)) "," (rtos (cadr import_pt))))
          
          ;; Step 3: Get scale (optional)
          (princ "\n\n→ STEP 3: SCALE FACTOR")
          (initget 6)  ; Positive, non-zero
          (setq scale_factor (getreal "\n  Enter scale factor (or press Enter for 1.0): "))
          (if (not scale_factor)
            (setq scale_factor 1.0))
          (princ (strcat "\n✓ Scale: " (rtos scale_factor)))
          
          ;; Step 4: Get rotation (optional)
          (princ "\n\n→ STEP 4: ROTATION ANGLE")
          (initget 4)  ; Allow zero
          (setq rotation (getangle "\n  Enter rotation angle in degrees (or press Enter for 0): "))
          (if (not rotation)
            (setq rotation 0.0))
          (princ (strcat "\n✓ Rotation: " (rtos (* rotation (/ 180.0 pi))) " degrees"))
          
          (setvar "OSMODE" old_osmode)
          
          ;; Step 5: Insert circuit
          (princ "\n\n→ STEP 5: IMPORTING CIRCUIT...")
          (princ "\n  Inserting all entities with block references intact...")
          
          (setvar "CMDECHO" 0)
          (setvar "FILEDIA" 0)
          (setvar "EXPERT" 5)
          
          ;; Use INSERT command with * prefix to insert as individual entities (not as block)
          ;; This preserves the original structure
          (command "._INSERT" (strcat "*" circuit_file) import_pt scale_factor scale_factor rotation)
          
          (while (> (getvar "CMDACTIVE") 0)
            (command ""))
          
          (princ "\n\n✓ SUCCESS - Circuit imported!")
          (princ (strcat "\n  All entities and block references loaded"))
          (princ "\n  Circuit preserves original structure and hierarchy")
          
          (setvar "CMDECHO" 1)
          (setvar "FILEDIA" 1)
          (setvar "EXPERT" 0)
        ))
    ))
  
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; BATCH EXPORT - Export multiple circuits in one session
;; ═══════════════════════════════════════════════════════════════════════════

(defun C:BATCHEXPORTCIRCUIT ( / continue_export count)
  
  (princ "\n╔════════════════════════════════════════════════════════════╗")
  (princ "\n║      BATCH CIRCUIT EXPORT - Multiple Selections           ║")
  (princ "\n╚════════════════════════════════════════════════════════════╝")
  (princ "\n")
  (princ "\n  Export multiple circuits one after another")
  (princ "\n  Press ESC or Enter blank name to stop")
  (princ "\n")
  
  (setq continue_export T)
  (setq count 0)
  
  (while continue_export
    (princ (strcat "\n\n═══════════ CIRCUIT #" (itoa (1+ count)) " ═══════════"))
    (C:EXPORTCIRCUIT)
    (setq count (1+ count))
    
    (initget "Yes No")
    (setq response (getkword "\n\nExport another circuit? [Yes/No] <Yes>: "))
    (if (or (not response) (= response "No"))
      (setq continue_export nil))
  )
  
  (princ (strcat "\n\n✓ Batch export complete - " (itoa count) " circuits processed"))
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; BROWSE CIRCUIT LIBRARY - List all exported circuits
;; ═══════════════════════════════════════════════════════════════════════════

(defun C:BROWSECIRCUITS ( / file_list)
  
  (princ "\n╔════════════════════════════════════════════════════════════╗")
  (princ "\n║           CIRCUIT LIBRARY - Available Circuits             ║")
  (princ "\n╚════════════════════════════════════════════════════════════╝")
  (princ "\n")
  
  (if (not (findfile *circuit_export_folder*))
    (princ (strcat "\n✗ Library folder not found: " *circuit_export_folder*))
    (progn
      (princ (strcat "\n  Library: " *circuit_export_folder*))
      (princ "\n")
      
      (setq file_list (vl-directory-files *circuit_export_folder* "*.dwg"))
      
      (if (not file_list)
        (princ "\n  No circuits found in library")
        (progn
          (princ (strcat "\n  Found " (itoa (length file_list)) " circuits:\n"))
          (foreach file file_list
            (setq full_path (strcat *circuit_export_folder* "\\" file))
            (setq file_size (vl-file-size full_path))
            (princ (strcat "\n    • " file " (" (itoa file_size) " bytes)"))
          )
          (princ "\n\n  Use IMPORTCIRCUIT to load any circuit")
        ))
    ))
  
  (princ))

;; ═══════════════════════════════════════════════════════════════════════════
;; LOAD MESSAGE
;; ═══════════════════════════════════════════════════════════════════════════

(princ "\n")
(princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
(princ "\n  CIRCUIT EXPORT/IMPORT TOOL v1.0 LOADED")
(princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
(princ "\n")
(princ "\n  Available Commands:")
(princ "\n  ├─ EXPORTCIRCUIT      : Export selected entities as circuit")
(princ "\n  ├─ IMPORTCIRCUIT      : Import circuit into drawing")
(princ "\n  ├─ BATCHEXPORTCIRCUIT : Export multiple circuits")
(princ "\n  └─ BROWSECIRCUITS     : List all exported circuits")
(princ "\n")
(princ (strcat "\n  Circuit Library: " *circuit_export_folder*))
(princ "\n")
(princ "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
(princ)
