# MacroManager v5.17 - QUICK START

## 🚀 Load and Run (3 Commands)

```lisp
; 1. Load the script
(load "MacroManager_v5.17.lsp")

; 2. Run MacroManager
MM

; 3. That's it! Dialog will open
```

---

## 🎯 What's New?

**5 EXPORT METHODS** - Dropdown menu in dialog:
```
0. Platform-Optimized (Auto-detect) ← RECOMMENDED
1. Direct vl-cmdf (Forced)
2. Script Method (Legacy)
3. ObjectDBX/VLA Method
4. Basic COMMAND Method
```

**5 IMPORT METHODS** - Dropdown menu in dialog:
```
0. XREF Attach (Safest) ← RECOMMENDED
1. INSERT with Explode
2. INSERT without Explode
3. Direct Command INSERT
4. VLA/ActiveX INSERT
```

---

## ⚡ Quick Test (5 minutes)

### Test Export:
1. Load: `(load "MacroManager_v5.17.lsp")`
2. Run: `MM`
3. Click **SELECT** → Pick 5 test blocks → ENTER
4. Select **Block Type** (e.g., "General")
5. Click **Browse** → Choose Block Library folder
6. **Export Method**: Keep default (0)
7. Click **EXPORT**
8. Watch console - should say: `→ WBLOCK (AutoCAD Electrical mode - SCRIPT method)...`
9. Check Block Library folder for DWG files

### Test Import:
1. Create **NEW drawing**
2. Run: `MM`
3. Click **Browse CSV** → Select exported CSV
4. Click **Browse Library** → Select Block Library folder
5. **Import Method**: Keep default (0)
6. Click **IMPORT**
7. Console shows: `Script will be saved to: ...\xref_import.scr`
8. Run command: `SCRIPT`
9. Browse to CSV folder → Select `xref_import.scr`
10. Wait for completion → Blocks appear!

---

## 📊 Test All Methods

Want to test everything? Follow this order:

### Export Testing:
```
Method 0 → Should work (auto-detects)
Method 2 → Should work (manual script)
Method 1 → May crash (test with caution)
Method 3 → Unknown (test and report)
Method 4 → May crash (test with caution)
```

### Import Testing:
```
Method 0 → Should work (XREF safest)
Method 1 → Should work (script-based)
Method 2 → Should work (script-based)
Method 3 → Unknown (test and report)
Method 4 → Unknown (test and report)
```

---

## 🛡️ Safety Tips

1. **Save your work** before testing Methods 1, 3, 4
2. **Test with 5 blocks** first, not all blocks
3. **Keep AutoCAD autosave enabled**
4. If crash occurs, note which block caused it

---

## 📝 Report Results

After testing, report using this simple format:

```
EXPORT RESULTS:
Method 0: ✅ Works / ❌ Crashes
Method 1: ✅ Works / ❌ Crashes
Method 2: ✅ Works / ❌ Crashes
Method 3: ✅ Works / ❌ Crashes
Method 4: ✅ Works / ❌ Crashes

IMPORT RESULTS:
Method 0: ✅ Works / ❌ Crashes
Method 1: ✅ Works / ❌ Crashes
Method 2: ✅ Works / ❌ Crashes
Method 3: ✅ Works / ❌ Crashes
Method 4: ✅ Works / ❌ Crashes

BEST COMBINATION:
Export: Method _____
Import: Method _____
```

---

## 🆘 Troubleshooting

**Q: Export crashes immediately?**
A: Switch to Method 2 (Script) or use Method 0 (auto-detects)

**Q: Import creates XREFs instead of blocks?**
A: That's Method 0 behavior (safest). Use Method 2 for traditional INSERTs.

**Q: Script method requires manual step?**
A: Yes, intentionally safe. Just run: `SCRIPT` → select `.scr` file

**Q: How to check current method?**
A: Type: `!*export_method*` or `!*import_method*`

**Q: How to manually set method?**
A: Type: `(setq *export_method* 0)` or `(setq *import_method* 0)`

---

## 📖 Full Documentation

Read these for complete details:

- **METHOD_TESTING_GUIDE.md** - Complete testing protocol
- **METHOD_QUICK_REFERENCE.md** - Quick reference tables  
- **METHOD_EXPLANATION.md** - Technical explanation
- **ALL_METHODS_IMPLEMENTATION.md** - Implementation summary

---

## ✅ Quick Checklist

- [ ] Loaded MacroManager_v5.17.lsp
- [ ] Tested Export Method 0 (5 blocks)
- [ ] Tested Import Method 0 (same 5 blocks)
- [ ] Blocks appear at correct positions
- [ ] No crashes occurred
- [ ] Ready to test other methods
- [ ] Ready to export all blocks

---

**RECOMMENDED FOR AUTOCAΔ ELECTRICAL:**
```
Export: Method 0 (Platform-Optimized)
Import: Method 0 (XREF Attach)
```

This combination should work without crashes!

---

**Version:** MacroManager v5.17  
**Date:** 2025-01-13  
**Status:** Ready to test ✅
