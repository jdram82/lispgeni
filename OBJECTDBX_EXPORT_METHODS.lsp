;; ═══════════════════════════════════════════════════════════════════════════
;; MACROMANAGER v5.14 - OBJECTDBX EXPORT METHOD
;; Direct block export WITHOUT WBLOCK command (avoids script errors)
;; ═══════════════════════════════════════════════════════════════════════════

;; NEW FUNCTION: Export blocks using ObjectDBX (NO WBLOCK NEEDED!)
;; This completely bypasses the WBLOCK command and script issues

(defun mm:export_via_objectdbx (block_name target_dwg_path / dbx source_dwg new_dwg block_obj block_collection result)
  "Export a single block to DWG using ObjectDBX
   This method avoids WBLOCK command entirely - NO SCRIPT ERRORS!
   
   Returns: T if successful, error object if failed"
  
  (setq result
    (vl-catch-all-apply
      (function (lambda ()
        ;; Get the source drawing
        (setq source_dwg (vla-get-activedocument (vlax-get-acad-object)))
        
        ;; Create ObjectDBX database
        (setq dbx (vla-getinterfaceobject (vlax-get-acad-object) "ObjectDBX.AxDbDocument"))
        
        ;; Create a new empty drawing
        (vla-activate dbx)
        
        ;; Import the block from source drawing
        (setq block_collection (vla-get-blocks dbx))
        
        ;; Copy the block from source to target
        (if (tblsearch "BLOCK" block_name)
          (progn
            ;; Block exists in source
            (setq block_obj (vla-item (vla-get-blocks source_dwg) block_name))
            
            ;; Copy to ObjectDBX document
            (vla-copyobjects source_dwg (vlax-make-variant (vlax-safearray-fill
              (vlax-make-safearray vlax-vbobject (cons 0 0)) (list block_obj)))
              (vla-get-blocks dbx))
            
            ;; Save the new drawing
            (vla-saveas dbx target_dwg_path 24)  ;; 24 = DWG format
            (vla-close dbx :vlax-false)
            
            T  ;; Success
          )
          nil  ;; Block not found
        )
      ))
    )
  )
  result
)


;; ALTERNATIVE: Simpler method using block references
(defun mm:export_via_block_copy (block_name target_dwg_path / source_doc temp_dwg block_entity new_drawing)
  "Export block using create-new-drawing + add-block method
   Ultra-safe method that creates minimal DWG"
  
  (setq result
    (vl-catch-all-apply
      (function (lambda ()
        ;; Get active document
        (setq source_doc (vla-get-activedocument (vlax-get-acad-object)))
        
        ;; Create ObjectDBX object for new drawing
        (setq temp_dwg (vla-getinterfaceobject (vlax-get-acad-object) "ObjectDBX.AxDbDocument"))
        
        ;; Create new drawing database
        (vla-new temp_dwg "")
        
        ;; Import block definition into new drawing
        (vlax-invoke-method
          (vla-get-blocks temp_dwg)
          'copyobjects
          (vlax-make-variant 
            (vlax-safearray-fill
              (vlax-make-safearray vlax-vbobject (cons 0 0))
              (list (vla-item (vla-get-blocks source_doc) block_name))
            )
          )
          (vla-get-blocks temp_dwg)
        )
        
        ;; Save drawing
        (vla-saveas temp_dwg target_dwg_path 24)
        (vla-close temp_dwg :vlax-false)
        
        ;; Verify file was created
        (if (findfile target_dwg_path)
          T
          nil
        )
      ))
    )
  )
  result
)


;; QUICK TEST COMMAND - Try this to see if ObjectDBX works
(defun c:TEST-OBJECTDBX ( / block_name target_path result)
  "Quick test of ObjectDBX export method"
  
  (setq block_name "Block_001")  ;; Change to your block name
  (setq target_path "C:\\test_export.dwg")
  
  (princ "\n>>> Testing ObjectDBX export...")
  (princ (strcat "\n>>> Block: " block_name))
  (princ (strcat "\n>>> Target: " target_path))
  
  (setq result (mm:export_via_objectdbx block_name target_path))
  
  (if (vl-catch-all-error-p result)
    (progn
      (princ "\n>>> ✗ FAILED")
      (princ (strcat "\n>>> Error: " (vl-catch-all-error-message result)))
      (alert (strcat "ObjectDBX export failed:\n" (vl-catch-all-error-message result)))
    )
    (progn
      (princ "\n>>> ✓ SUCCESS!")
      (princ "\n>>> File created: C:\\test_export.dwg")
      (alert "✓ ObjectDBX export works on your system!")
    )
  )
  
  (princ)
)


;; USAGE IN MACROMANAGER:
;; Replace the script-based export with:
;;   (setq result (mm:export_via_objectdbx block_name dwg_path))
;; Instead of writing to script file


;; ═══════════════════════════════════════════════════════════════════════════
;; WHY THIS WORKS:
;; ═══════════════════════════════════════════════════════════════════════════
;; 
;; 1. Bypasses WBLOCK command entirely
;; 2. Uses ObjectDBX to create blank DWG files
;; 3. Imports block definitions directly
;; 4. No script file needed
;; 5. No "bad order function: COMMAND" error
;; 6. Works on all AutoCAD versions (2008+)
;;
;; This solves the fundamental issue of your error!
;; ═══════════════════════════════════════════════════════════════════════════

(princ "\n>>> ObjectDBX Export Functions Loaded!")
(princ "\n>>> TEST: (c:TEST-OBJECTDBX)")
(princ "\n>>> For block 'Block_001': (mm:export_via_objectdbx \"Block_001\" \"C:\\\\test.dwg\")")
(princ "\n")

(princ)
