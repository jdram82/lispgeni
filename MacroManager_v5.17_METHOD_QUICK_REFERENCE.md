# MacroManager v5.17 - Quick Method Reference

## Export Methods Summary

| # | Method Name | Creates Script? | Executes Immediately? | Platform Aware? | Risk Level |
|---|-------------|-----------------|----------------------|-----------------|------------|
| 0 | Platform-Optimized | ACADE: Yes<br>Others: No | ACADE: No<br>Others: Yes | ✅ YES | ⭐⭐⭐⭐⭐ SAFEST |
| 1 | Direct vl-cmdf (Forced) | No | Yes | ❌ NO | ⚠️⚠️⚠️ HIGH RISK |
| 2 | Script Method | Yes | No (manual SCRIPT) | ❌ NO | ⭐⭐⭐⭐ SAFE |
| 3 | ObjectDBX/VLA | No | Yes | ❌ NO | ⚠️⚠️ UNKNOWN |
| 4 | Basic COMMAND | No | Yes | ❌ NO | ⚠️⚠️⚠️ HIGH RISK |

## Import Methods Summary

| # | Method Name | Creates Script? | Executes Immediately? | Result Type | Risk Level |
|---|-------------|-----------------|----------------------|-------------|------------|
| 0 | XREF Attach | Yes | No (manual SCRIPT) | External References | ⭐⭐⭐⭐⭐ SAFEST |
| 1 | INSERT + Explode | Yes | No (manual SCRIPT) | Loose Geometry | ⭐⭐⭐⭐ SAFE |
| 2 | INSERT No Explode | Yes | No (manual SCRIPT) | Block References | ⭐⭐⭐⭐ SAFE |
| 3 | Direct Command INSERT | No | Yes | Block References | ⚠️⚠️ MEDIUM RISK |
| 4 | VLA/ActiveX INSERT | No | Yes | Block References | ⚠️⚠️ UNKNOWN |

---

## Method Details

### Export Method 0: Platform-Optimized ⭐ RECOMMENDED

**Function:** `mm:wblock_direct_vl`

**Logic:**
```
Detect Platform
  ↓
AutoCAD Electrical? → Create Script → Execute SCRIPT command
Standard AutoCAD?   → Execute vl-cmdf directly
BricsCAD?          → Execute vl-cmdf directly
```

**Pros:**
- ✅ Automatically adapts to platform
- ✅ Safest for AutoCAD Electrical
- ✅ Fastest for Standard AutoCAD/BricsCAD

**Cons:**
- None (ideal choice)

---

### Export Method 1: Direct vl-cmdf (Forced)

**Function:** `mm:wblock_direct_forced`

**Logic:**
```
Force vl-cmdf execution (no platform detection)
```

**Pros:**
- ✅ Fast execution when it works

**Cons:**
- ❌ Crashes on AutoCAD Electrical (Exception c0000027)
- ❌ No safety checks

**Use case:** Testing/debugging only

---

### Export Method 2: Script Method

**Function:** Script generation in export loop

**Logic:**
```
Write commands to export_blocks.scr
User manually runs: SCRIPT → export_blocks.scr
```

**Pros:**
- ✅ Safe (buffered execution)
- ✅ Inspectable (can view script file)

**Cons:**
- ⚠️ Manual step required
- ⚠️ Slightly slower

**Use case:** When Method 0 fails or for troubleshooting

---

### Export Method 3: ObjectDBX/VLA

**Function:** `mm:wblock_objectdbx`

**Logic:**
```
Use COM objects: vla-wblock
```

**Pros:**
- ✅ Uses native ActiveX interface

**Cons:**
- ❓ Unknown stability on ACADE
- ⚠️ May freeze AutoCAD
- ⚠️ Requires Visual LISP extensions

**Use case:** Testing alternative approaches

---

### Export Method 4: Basic COMMAND

**Function:** `mm:wblock_command`

**Logic:**
```
Use basic COMMAND function (not vl-cmdf)
```

**Pros:**
- ✅ Simple syntax

**Cons:**
- ❌ Likely crashes like Method 1
- ❌ Synchronous (blocks AutoCAD)

**Use case:** Testing if COMMAND vs vl-cmdf makes difference

---

## Import Method 0: XREF Attach ⭐ RECOMMENDED

**Function:** `mm:import_xref_attach`

**Logic:**
```
Generate script:
  -XREF → Detach (ignore errors)
  -XREF → Attach → Specify path, name, coordinates
Execute via: SCRIPT command
```

**Pros:**
- ✅ Safest (no INSERT command)
- ✅ Blocks remain editable externally
- ✅ No crashes reported

**Cons:**
- ⚠️ Creates XREFs not block definitions
- ⚠️ Manual SCRIPT step required

**Result:**
- Blocks appear as XREFs
- Can be edited by modifying source DWG
- Can convert to INSERT later if needed

---

## Import Method 1: INSERT with Explode

**Function:** `mm:import_insert_explode`

**Logic:**
```
Generate script:
  -INSERT → Path → Coordinates → Explode=YES
Execute via: SCRIPT command
```

**Pros:**
- ✅ Creates loose geometry (no block references)
- ✅ Safe via script execution

**Cons:**
- ⚠️ Loses block association
- ⚠️ Cannot update in bulk

**Result:**
- Exploded geometry at each position
- Lines, arcs, etc. (not grouped)

---

## Import Method 2: INSERT without Explode

**Function:** `mm:import_insert_no_explode`

**Logic:**
```
Generate script:
  -INSERT → Path → Coordinates → Explode=NO
Execute via: SCRIPT command
```

**Pros:**
- ✅ Keeps blocks as references
- ✅ Traditional AutoCAD workflow

**Cons:**
- ⚠️ Block definitions stored in drawing

**Result:**
- Block references at each position
- Grouped entities (single selection)

---

## Import Method 3: Direct Command INSERT

**Function:** `mm:import_direct_command`

**Logic:**
```
Execute COMMAND directly in AutoLISP (no script)
```

**Pros:**
- ✅ Immediate execution
- ✅ No script file needed

**Cons:**
- ⚠️ May crash on some platforms
- ⚠️ Similar issues to export crashes

**Use case:** Testing if direct INSERT works better than script

---

## Import Method 4: VLA/ActiveX INSERT

**Function:** `mm:import_vla_insert`

**Logic:**
```
Use COM objects: vla-insertblock
```

**Pros:**
- ✅ Uses native ActiveX interface

**Cons:**
- ❓ Unknown stability
- ⚠️ Requires Visual LISP extensions

**Use case:** Testing alternative approaches

---

## Recommended Combinations

### For AutoCAD Electrical 2024:
```
Export: Method 0 (Platform-Optimized)
Import: Method 0 (XREF Attach)
```

**Why:**
- Export Method 0 auto-detects ACADE → uses safe Script method
- Import Method 0 avoids INSERT crashes via XREF

---

### For Standard AutoCAD:
```
Export: Method 0 (Platform-Optimized)
Import: Method 2 (INSERT No Explode)
```

**Why:**
- Export Method 0 uses fast vl-cmdf
- Import Method 2 creates traditional block references

---

### For BricsCAD:
```
Export: Method 0 (Platform-Optimized)
Import: Method 2 (INSERT No Explode)
```

**Why:**
- Export Method 0 uses fast vl-cmdf
- Import Method 2 creates traditional block references

---

## Testing Commands

```lisp
; Check current methods
!*export_method*  ; Returns 0-4
!*import_method*  ; Returns 0-4

; Manually set methods
(setq *export_method* 0)  ; Platform-Optimized
(setq *import_method* 0)  ; XREF Attach

; Check detected platform
!*cad_platform*  ; Returns "ACADE", "AUTOCAD", or "BRICSCAD"
```

---

## Troubleshooting

### Export crashes immediately:
- ✅ Switch to Method 2 (Script Method)
- ✅ Or use Method 0 (should auto-switch to Script on ACADE)

### Import creates XREFs instead of blocks:
- ✅ This is Method 0 behavior (intentional)
- ✅ Switch to Method 2 for traditional INSERTs

### Script method requires manual step:
- ✅ This is intentional (safest approach)
- ✅ Command: `SCRIPT` → Select `.scr` file

### ObjectDBX/VLA methods fail:
- ✅ May not be supported on your platform
- ✅ Use Method 0 or 2 instead

---

**Quick Selection Guide:**

Want **fastest + safest**? → Method 0 (both export and import)

Want **traditional blocks**? → Export: Method 0, Import: Method 2

Need **manual control**? → Export: Method 2, Import: Method 0

Testing **alternatives**? → Try Methods 3 & 4, report results

---

**Version:** MacroManager v5.17  
**Last Updated:** 2025-01-13
