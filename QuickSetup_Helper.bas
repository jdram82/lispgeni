' ============================================================================
' QUICK SETUP HELPER - Run this after InitializeWorksheets()
' ============================================================================
' PURPOSE: Automatically configure all sheet headers and basic structure
' HOW TO USE: Press Alt+F8 → Run "QuickSetupAllSheets" → Done!
' ============================================================================

Sub QuickSetupAllSheets()
    'Complete setup for all 5 worksheets
    
    On Error GoTo ErrorHandler
    
    ' Ensure worksheets are initialized
    If wsMacroLibrary Is Nothing Then Call InitializeWorksheets
    
    ' Setup each sheet
    Call SetupMacroLibrarySheet
    Call SetupSelectedMacrosSheet
    Call SetupProjectConfigSheet
    Call SetupSettingsSheet
    Call SetupLogsSheet
    
    MsgBox "✅ QUICK SETUP COMPLETE!" & vbCrLf & vbCrLf & _
           "All 5 sheets configured:" & vbCrLf & _
           "  ✓ Macro Library (headers + formatting)" & vbCrLf & _
           "  ✓ Selected Macros (headers + formatting)" & vbCrLf & _
           "  ✓ Project_Config (layout + sample data)" & vbCrLf & _
           "  ✓ Settings (defaults)" & vbCrLf & _
           "  ✓ Logs (headers + formatting)" & vbCrLf & vbCrLf & _
           "NEXT STEPS:" & vbCrLf & _
           "1. Update Settings sheet with your paths" & vbCrLf & _
           "2. Test import with SAMPLE_TEST_DATA.txt" & vbCrLf & _
           "3. Check QUICK_REFERENCE_CARD.md for usage", _
           vbInformation
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Setup Error: " & Err.Description, vbCritical
End Sub

' ============================================================================
' INDIVIDUAL SHEET SETUP FUNCTIONS
' ============================================================================

Sub SetupMacroLibrarySheet()
    'Configure Macro Library sheet
    
    With wsMacroLibrary
        ' Clear existing
        .Cells.Clear
        
        ' Headers
        .Range("A1").Value = "Sl.No"
        .Range("B1").Value = "Block/Circuit Name"
        .Range("C1").Value = "Category"
        .Range("D1").Value = "DWG File Location"
        .Range("E1").Value = "X Coordinate"
        .Range("F1").Value = "Y Coordinate"
        .Range("G1").Value = "Z Coordinate"
        .Range("H1").Value = "Layer"
        .Range("I1").Value = "Color"
        .Range("J1").Value = "Linetype"
        .Range("K1").Value = "Export Date"
        .Range("L1").Value = "Export Time"
        
        ' Format headers
        With .Range("A1:L1")
            .Font.Bold = True
            .Interior.Color = RGB(68, 114, 196)
            .Font.Color = RGB(255, 255, 255)
            .HorizontalAlignment = xlCenter
            .Borders.LineStyle = xlContinuous
        End With
        
        ' Column widths
        .Columns("A:A").ColumnWidth = 8
        .Columns("B:B").ColumnWidth = 25
        .Columns("C:C").ColumnWidth = 20
        .Columns("D:D").ColumnWidth = 50
        .Columns("E:G").ColumnWidth = 12
        .Columns("H:H").ColumnWidth = 15
        .Columns("I:J").ColumnWidth = 12
        .Columns("K:L").ColumnWidth = 15
        
        ' Number format for coordinates
        .Columns("E:G").NumberFormat = "0.0000"
        
        ' Freeze panes
        .Range("A2").Select
        ActiveWindow.FreezePanes = True
        
        ' Instructions in M1
        .Range("M1").Value = "← Import CSV using button (add button later)"
        .Range("M1").Font.Italic = True
        .Range("M1").Font.Color = RGB(150, 150, 150)
    End With
End Sub

Sub SetupSelectedMacrosSheet()
    'Configure Selected Macros sheet
    
    With wsSelectedMacros
        ' Clear existing
        .Cells.Clear
        
        ' Same headers as Macro Library
        .Range("A1").Value = "Sl.No"
        .Range("B1").Value = "Block/Circuit Name"
        .Range("C1").Value = "Category"
        .Range("D1").Value = "DWG File Location"
        .Range("E1").Value = "X Coordinate"
        .Range("F1").Value = "Y Coordinate"
        .Range("G1").Value = "Z Coordinate"
        .Range("H1").Value = "Layer"
        .Range("I1").Value = "Color"
        .Range("J1").Value = "Linetype"
        .Range("K1").Value = "Export Date"
        .Range("L1").Value = "Export Time"
        
        ' Format headers (green background)
        With .Range("A1:L1")
            .Font.Bold = True
            .Interior.Color = RGB(100, 200, 100)
            .Font.Color = RGB(255, 255, 255)
            .HorizontalAlignment = xlCenter
            .Borders.LineStyle = xlContinuous
        End With
        
        ' Same column widths
        .Columns("A:A").ColumnWidth = 8
        .Columns("B:B").ColumnWidth = 25
        .Columns("C:C").ColumnWidth = 20
        .Columns("D:D").ColumnWidth = 50
        .Columns("E:G").ColumnWidth = 12
        .Columns("H:H").ColumnWidth = 15
        .Columns("I:J").ColumnWidth = 12
        .Columns("K:L").ColumnWidth = 15
        
        .Columns("E:G").NumberFormat = "0.0000"
        
        ' Instructions
        .Range("M1").Value = "← Auto-populated by filter criteria"
        .Range("M1").Font.Italic = True
        .Range("M1").Font.Color = RGB(150, 150, 150)
    End With
End Sub

Sub SetupProjectConfigSheet()
    'Configure Project_Config sheet
    
    With wsProjectConfig
        ' Clear existing
        .Cells.Clear
        
        ' Title
        .Range("A1").Value = "PROJECT CONFIGURATION & FILTERS"
        .Range("A1").Font.Size = 14
        .Range("A1").Font.Bold = True
        .Range("A1").Font.Color = RGB(68, 114, 196)
        
        ' Project Settings
        .Range("A3").Value = "Project Name:"
        .Range("B3").Value = "New Project"
        .Range("B3").Interior.Color = RGB(255, 255, 200)
        
        .Range("A5").Value = "Category Filter:"
        .Range("B5").Value = "All"
        .Range("B5").Interior.Color = RGB(255, 255, 200)
        
        .Range("A7").Value = "Voltage Level:"
        .Range("B7").Value = "415V"
        .Range("B7").Interior.Color = RGB(255, 255, 200)
        
        .Range("A9").Value = "Panel Type:"
        .Range("B9").Value = "MCC"
        .Range("B9").Interior.Color = RGB(255, 255, 200)
        
        .Range("A11").Value = "Location:"
        .Range("B11").Value = "Building A"
        .Range("B11").Interior.Color = RGB(255, 255, 200)
        
        ' Format labels
        .Range("A3,A5,A7,A9,A11").Font.Bold = True
        
        ' Column widths
        .Columns("A:A").ColumnWidth = 20
        .Columns("B:B").ColumnWidth = 30
        
        ' Instructions
        .Range("A14").Value = "WORKFLOW INSTRUCTIONS:"
        .Range("A14").Font.Bold = True
        .Range("A15").Value = "1. Import CSV to Macro Library"
        .Range("A16").Value = "2. Set filter criteria above"
        .Range("A17").Value = "3. Check Selected Macros tab"
        .Range("A18").Value = "4. Click 'Generate Drawings' button"
        .Range("A19").Value = "5. In AutoCAD: UCB → Import CSV"
        
        .Range("A15:A19").Font.Italic = True
        .Range("A15:A19").Font.Color = RGB(100, 100, 100)
        
        ' Note for button
        .Range("D3").Value = "[Add 'Generate Drawings' button here]"
        .Range("D3").Font.Italic = True
        .Range("D3").Font.Color = RGB(200, 100, 100)
    End With
End Sub

Sub SetupSettingsSheet()
    'Configure Settings sheet
    
    With wsSettings
        ' Clear existing
        .Cells.Clear
        
        ' Title
        .Range("A1").Value = "SYSTEM SETTINGS"
        .Range("A1").Font.Size = 14
        .Range("A1").Font.Bold = True
        .Range("A1").Font.Color = RGB(68, 114, 196)
        
        ' Settings
        .Range("A4").Value = "Project Name:"
        .Range("B4").Value = "New Project"
        
        .Range("A6").Value = "Export Path:"
        .Range("B6").Value = "C:\Projects\Exports"
        
        .Range("A8").Value = "CSV Files Path:"
        .Range("B8").Value = "C:\Projects\CSVs"
        
        .Range("A10").Value = "Logs Path:"
        .Range("B10").Value = "C:\Projects\Logs"
        
        .Range("A12").Value = "AutoCAD Path:"
        .Range("B12").Value = "C:\Program Files\Autodesk\AutoCAD 2024"
        
        ' Highlight input cells
        .Range("B4,B6,B8,B10,B12").Interior.Color = RGB(255, 255, 200)
        .Range("B4,B6,B8,B10,B12").Borders.LineStyle = xlContinuous
        
        ' Format labels
        .Range("A4,A6,A8,A10,A12").Font.Bold = True
        
        ' Column widths
        .Columns("A:A").ColumnWidth = 20
        .Columns("B:B").ColumnWidth = 50
        
        ' Instructions
        .Range("A15").Value = "NOTE: Update paths above according to your system"
        .Range("A15").Font.Italic = True
        .Range("A15").Font.Color = RGB(200, 0, 0)
    End With
End Sub

Sub SetupLogsSheet()
    'Configure Logs sheet
    
    With wsLogs
        ' Clear existing
        .Cells.Clear
        
        ' Headers
        .Range("A1").Value = "Timestamp"
        .Range("B1").Value = "Action"
        .Range("C1").Value = "Status"
        .Range("D1").Value = "Details"
        
        ' Format headers
        With .Range("A1:D1")
            .Font.Bold = True
            .Interior.Color = RGB(200, 200, 200)
            .HorizontalAlignment = xlCenter
            .Borders.LineStyle = xlContinuous
        End With
        
        ' Column widths
        .Columns("A:A").ColumnWidth = 20
        .Columns("B:B").ColumnWidth = 30
        .Columns("C:C").ColumnWidth = 12
        .Columns("D:D").ColumnWidth = 60
        
        ' Sample log entry
        .Range("A2").Value = Format(Now, "yyyy-mm-dd hh:mm:ss")
        .Range("B2").Value = "System Setup"
        .Range("C2").Value = "SUCCESS"
        .Range("D2").Value = "Quick setup completed successfully"
        .Range("C2").Interior.Color = RGB(200, 255, 200)
        
        ' Freeze panes
        .Range("A2").Select
        ActiveWindow.FreezePanes = True
    End With
End Sub
