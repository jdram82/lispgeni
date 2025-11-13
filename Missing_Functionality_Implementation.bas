' ============================================================================
' MODULE: Missing_Functionality_Implementation
' PURPOSE: Complete the missing Import and Generate Drawings functionality
' VERSION: 3.0 - FORMULA-BASED WORKFLOW (AVAILABLE MACROS REMOVED)
' ============================================================================
' NOTE: This module requires worksheet variables (wsMacroLibrary,
'       wsSelectedMacros, wsSettings) to be declared globally in another module
'       OR you must call InitializeWorksheetReferences before using these functions
' ============================================================================

Option Explicit

' ============================================================================
' ENHANCED CSV PARSING FOR VERIFIED AUTOLISP FORMAT
' ============================================================================

Sub ImportFromCSV_Click()
    'Import CSV file to Macro Library - STREAMLINED WORKFLOW
    Dim csvPath As String
    Dim macroCount As Long
    Dim defaultPath As String
    
    On Error GoTo ErrorHandler
    
    ' Initialize worksheet references if not already set
    If wsMacroLibrary Is Nothing Then
        Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")
        Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")
        Set wsSettings = ThisWorkbook.Sheets("Settings")
    End If
    
    ' Set default directory to CSVFilesPath for file browser
    defaultPath = GetSettingValue("CSVFilesPath")
    If defaultPath <> "" Then
        On Error Resume Next
        If Dir(defaultPath, vbDirectory) <> "" Then
            ChDir defaultPath  ' Change to CSV files directory
        End If
        On Error GoTo ErrorHandler
    End If
    
    ' Browse for CSV file (will open in CSVFilesPath if valid)
    csvPath = BrowseForFile("csv")
    
    If csvPath <> "" Then
        ' Store the selected path for future use
        wsMacroLibrary.Range("Z1").Value = csvPath  ' Store in hidden cell
        
        ' Setup headers first
        Call SetupMacroLibraryHeaders
        
        ' Import CSV data using enhanced parser
        Call ImportVerifiedCSVFormat(csvPath)
        
        ' Get macro count
        macroCount = wsMacroLibrary.Cells(wsMacroLibrary.Rows.Count, 1).End(xlUp).Row - 1
        
        ' Log action
        Call LogAction("ImportFromCSV", "SUCCESS", "Imported " & macroCount & " macros from: " & csvPath)
        
        MsgBox "CSV imported successfully!" & vbCrLf & vbCrLf & _
               "✓ " & macroCount & " macros loaded to Macro Library" & vbCrLf & vbCrLf & _
               "Next Step:" & vbCrLf & _
               "→ Selected Macros tab will auto-populate based on your formulas" & vbCrLf & _
               "→ Go to Project Config tab to Generate Drawings", _
               vbInformation, "Import Complete"
    Else
        MsgBox "No file selected.", vbExclamation
    End If
    
    Exit Sub
ErrorHandler:
    MsgBox "Error importing CSV: " & Err.Description, vbCritical
    Call LogAction("ImportFromCSV", "ERROR", Err.Description)
End Sub

Sub ImportVerifiedCSVFormat(csvPath As String)
    'Import CSV file in the verified AutoLISP export format
    'Format: MacroID,MacroName,Category,X,Y,Path,Timestamp
    
    Dim fso As Object
    Dim csvFile As Object
    Dim line As String
    Dim fields() As String
    Dim row As Long
    Dim serialNo As Long
    
    On Error GoTo ErrorHandler
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' Validate file exists
    If Not fso.FileExists(csvPath) Then
        MsgBox "File not found: " & csvPath, vbCritical
        Exit Sub
    End If
    
    ' Open CSV file
    Set csvFile = fso.OpenTextFile(csvPath, 1)  ' 1 = ForReading
    row = 2  ' Start from row 2 (headers already set)
    serialNo = 1
    
    ' Skip header line if it exists
    If Not csvFile.AtEndOfStream Then
        line = csvFile.ReadLine
        ' Check if first line looks like data (starts with M for Macro ID)
        If Left(Trim(line), 1) <> "M" Then
            ' This was a header line, continue to data
        Else
            ' This is data, process it
            GoTo ProcessLine
        End If
    End If
    
    ' Read and parse each line
    Do While Not csvFile.AtEndOfStream
        line = csvFile.ReadLine
        
ProcessLine:
        If line <> "" Then
            ' Parse CSV line
            fields = ParseCSVLine(line)
            
            ' Verify we have minimum required fields (AutoLISP format: Block Name, X, Y, Z, Layer, Color, Linetype)
            ' Minimum 7 fields expected
            If UBound(fields) >= 6 Then
                ' Map to Excel columns based on NEW AutoLISP format
                wsMacroLibrary.Cells(row, 1).Value = serialNo         ' Sl.No
                wsMacroLibrary.Cells(row, 2).Value = Trim(fields(0))  ' Block Name
                wsMacroLibrary.Cells(row, 3).Value = Trim(fields(1))  ' X Coordinate
                wsMacroLibrary.Cells(row, 4).Value = Trim(fields(2))  ' Y Coordinate
                wsMacroLibrary.Cells(row, 5).Value = Trim(fields(3))  ' Z Coordinate
                wsMacroLibrary.Cells(row, 6).Value = Trim(fields(4))  ' Layer
                wsMacroLibrary.Cells(row, 7).Value = Trim(fields(5))  ' Color
                wsMacroLibrary.Cells(row, 8).Value = Trim(fields(6))  ' Linetype
                
                row = row + 1
                serialNo = serialNo + 1
            End If
        End If
        
        ' Reset the line processing flag
        line = ""
    Loop
    
    csvFile.Close
    Set csvFile = Nothing
    Set fso = Nothing
    
    ' Format the data
    Call FormatMacroLibraryData
    
    Exit Sub
ErrorHandler:
    MsgBox "Error importing CSV data: " & Err.Description, vbCritical
    Call LogAction("ImportVerifiedCSVFormat", "ERROR", Err.Description)
End Sub

Sub FormatMacroLibraryData()
    'Format the Macro Library data for better visibility
    
    On Error Resume Next
    
    With wsMacroLibrary
        ' Format coordinate columns as numbers
        .Columns("E:F").NumberFormat = "0.00"
        
        ' Auto-fit columns
        .Columns.AutoFit
        
        ' Add borders
        Dim lastRow As Long
        lastRow = .Cells(.Rows.Count, 1).End(xlUp).Row
        If lastRow > 1 Then
            .Range("A1:H" & lastRow).Borders.LineStyle = xlContinuous
        End If
        
        ' Freeze header row
        .Range("A2").Select
        ActiveWindow.FreezePanes = True
    End With
    
    On Error GoTo 0
End Sub

Sub BrowseCSVFile_Click()
    'Browse and display selected CSV file path - MISSING FUNCTIONALITY
    Dim csvPath As String
    
    csvPath = BrowseForFile("csv")
    
    If csvPath <> "" Then
        ' Display path in cell B2 of Macro Library
        wsMacroLibrary.Range("B2").Value = csvPath
        MsgBox "CSV file selected: " & vbCrLf & csvPath & vbCrLf & vbCrLf & _
               "Click 'Import from CSV' to load the data.", vbInformation, "File Selected"
    End If
End Sub

Sub RefreshMacroLibrary_Click()
    'Refresh library from last imported CSV
    Dim csvPath As String
    Dim macroCount As Long
    
    ' Initialize worksheet references if not already set
    If wsMacroLibrary Is Nothing Then
        Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")
        Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")
        Set wsSettings = ThisWorkbook.Sheets("Settings")
    End If
    
    csvPath = wsMacroLibrary.Range("Z1").Value  ' Get stored path from hidden cell
    
    If csvPath <> "" And Dir(csvPath) <> "" Then
        ' Setup headers
        Call SetupMacroLibraryHeaders
        
        ' Import CSV data
        Call ImportVerifiedCSVFormat(csvPath)
        
        ' Get macro count
        macroCount = wsMacroLibrary.Cells(wsMacroLibrary.Rows.Count, 1).End(xlUp).Row - 1
        
        Call LogAction("RefreshMacroLibrary", "SUCCESS", "Refreshed " & macroCount & " macros from: " & csvPath)
        MsgBox "Macro Library refreshed!" & vbCrLf & vbCrLf & _
               "✓ " & macroCount & " macros reloaded" & vbCrLf & _
               "From: " & csvPath, vbInformation
    Else
        MsgBox "Please select a CSV file first using 'Import from CSV' button!", vbExclamation
    End If
End Sub

Sub ClearMacroLibrary_Click()
    'Clear all data from Macro Library
    Dim response As Integer
    
    ' Initialize worksheet references if not already set
    If wsMacroLibrary Is Nothing Then
        Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")
        Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")
        Set wsSettings = ThisWorkbook.Sheets("Settings")
    End If
    
    response = MsgBox("Clear all macro library data? This will also clear Selected Macros.", _
                     vbYesNo + vbQuestion, "Clear Library")
    
    If response = vbYes Then
        ' Clear all related sheets
        wsMacroLibrary.Cells.Clear
        wsSelectedMacros.Cells.Clear
        
        ' Reset headers
        Call SetupMacroLibraryHeaders
        Call SetupSelectedMacrosHeaders
        
        Call LogAction("ClearMacroLibrary", "SUCCESS", "All macro data cleared")
        MsgBox "All macro library data cleared!", vbInformation
    End If
End Sub

' ============================================================================
' PROJECT_CONFIG TAB - GENERATE DRAWINGS DUAL OPERATION
' ============================================================================

Sub GenerateDrawings_Click()
    'DUAL OPERATION: Export CSV + Import to AutoCAD - FILTER-BASED WORKFLOW
    
    On Error GoTo ErrorHandler
    
    ' Initialize worksheet references if not already set
    If wsMacroLibrary Is Nothing Then
        Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")
        Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")
        Set wsSettings = ThisWorkbook.Sheets("Settings")
    End If
    
    Dim projectName As String
    Dim csvPath As String
    Dim selectedCount As Long
    
    ' ═══════════════════════════════════════════════════════════
    ' VALIDATION PHASE
    ' ═══════════════════════════════════════════════════════════
    
    ' Validate project name
    projectName = GetSettingValue("ProjectName")
    
    If projectName = "" Or projectName = "New Project" Then
        MsgBox "Please set a valid Project Name in Settings first!" & vbCrLf & vbCrLf & _
               "Go to Settings tab and enter a project name.", vbExclamation, "Project Name Required"
        Exit Sub
    End If
    
    ' Check if macros are selected
    selectedCount = wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 1).End(xlUp).Row - 1
    
    If selectedCount <= 0 Then
        MsgBox "No macros selected!" & vbCrLf & vbCrLf & _
               "Please populate Selected Macros tab with your conditional formulas." & vbCrLf & vbCrLf & _
               "Selected Macros should contain the filtered macros based on your project requirements.", _
               vbExclamation, "No Selection"
        Exit Sub
    End If
    
    Call LogAction("GenerateDrawings", "INFO", "Starting dual operation for " & selectedCount & " macros")
    
    ' ═══════════════════════════════════════════════════════════
    ' OPERATION 1: EXPORT SELECTED MACROS TO CSV
    ' ═══════════════════════════════════════════════════════════
    
    csvPath = GetSettingValue("ExportPath") & "\Project_Macros_" & projectName & ".csv"
    
    ' Ensure export path exists
    Call EnsurePathExists(GetSettingValue("ExportPath"))
    
    ' Export selected macros to project-specific CSV
    Call ExportSelectedMacrosToProjectCSV(csvPath)
    
    ' ═══════════════════════════════════════════════════════════
    ' OPERATION 2: PREPARE AUTOCAD IMPORT
    ' ═══════════════════════════════════════════════════════════
    
    ' Create AutoCAD import trigger file
    Call CreateAutoCADImportTrigger(csvPath)
    
    ' ═══════════════════════════════════════════════════════════
    ' USER INTERACTION PHASE
    ' ═══════════════════════════════════════════════════════════
    
    ' Inform user of successful export
    Dim response As Integer
    response = MsgBox("✓ OPERATION 1 COMPLETE: CSV Export" & vbCrLf & vbCrLf & _
                     "Selected macros exported to:" & vbCrLf & _
                     csvPath & vbCrLf & vbCrLf & _
                     "✓ OPERATION 2 READY: AutoCAD Import" & vbCrLf & vbCrLf & _
                     "Do you want to open a specific CAD file for drawing generation?", _
                     vbYesNo + vbQuestion, "Generate Drawings - Step 2")
    
    If response = vbYes Then
        Call PromptForCADFile
    End If
    
    ' Optional: Auto-launch AutoCAD
    If GetSettingValue("AutoLaunchAutoCAD") = "Yes" Then
        Call LaunchAutoCAD
    End If
    
    ' ═══════════════════════════════════════════════════════════
    ' COMPLETION PHASE
    ' ═══════════════════════════════════════════════════════════
    
    Call LogAction("GenerateDrawings", "SUCCESS", "Dual operation completed successfully")
    
    MsgBox "🎯 GENERATE DRAWINGS COMPLETED!" & vbCrLf & vbCrLf & _
           "✅ OPERATION 1: " & selectedCount & " macros exported to CSV" & vbCrLf & _
           "✅ OPERATION 2: AutoCAD import trigger created" & vbCrLf & vbCrLf & _
           "📁 CSV File: " & csvPath & vbCrLf & vbCrLf & _
           "🚀 Ready for drawing generation in AutoCAD!" & vbCrLf & _
           "   Use MACROMANAGER command to import the CSV.", _
           vbInformation, "Process Complete"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "❌ Error in Generate Drawings: " & Err.Description, vbCritical
    Call LogAction("GenerateDrawings", "ERROR", Err.Description)
End Sub

Sub ExportSelectedMacrosToProjectCSV(csvPath As String)
    'Export Selected Macros to CSV in AutoLISP-compatible format
    'Format: Block Name,X Coordinate,Y Coordinate,Z Coordinate,Layer,Color,Linetype
    
    Dim fso As Object
    Dim csvFile As Object
    Dim lastRow As Long
    Dim row As Long
    Dim blockName As String
    Dim xCoord As String
    Dim yCoord As String
    Dim zCoord As String
    Dim layer As String
    Dim color As String
    Dim linetype As String
    Dim csvLine As String
    
    On Error GoTo ErrorHandler
    
    ' Get last row from Selected Macros
    lastRow = wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 1).End(xlUp).Row
    
    If lastRow <= 1 Then
        Err.Raise vbObjectError + 1, , "No selected macros to export"
        Exit Sub
    End If
    
    ' Create CSV file
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set csvFile = fso.CreateTextFile(csvPath, True)
    
    ' ═══════════════════════════════════════════════════════════
    ' WRITE CSV HEADER - AUTOLISP FORMAT
    ' ═══════════════════════════════════════════════════════════
    csvFile.WriteLine "Block Name,X Coordinate,Y Coordinate,Z Coordinate,Layer,Color,Linetype"
    
    ' ═══════════════════════════════════════════════════════════
    ' WRITE DATA ROWS - EXPORT FROM AUTOLISP FORMAT
    ' ═══════════════════════════════════════════════════════════
    For row = 2 To lastRow
        ' Skip empty rows
        If Trim(wsSelectedMacros.Cells(row, 2).Value) <> "" Then
            ' Extract data from Selected Macros - NEW AutoLISP format
            ' Column B (2) = Block Name
            ' Column C (3) = X Coordinate
            ' Column D (4) = Y Coordinate
            ' Column E (5) = Z Coordinate
            ' Column F (6) = Layer
            ' Column G (7) = Color
            ' Column H (8) = Linetype
            
            blockName = Trim(wsSelectedMacros.Cells(row, 2).Value)    ' Block Name
            xCoord = Trim(wsSelectedMacros.Cells(row, 3).Value)       ' X Coordinate
            yCoord = Trim(wsSelectedMacros.Cells(row, 4).Value)       ' Y Coordinate
            zCoord = Trim(wsSelectedMacros.Cells(row, 5).Value)       ' Z Coordinate
            layer = Trim(wsSelectedMacros.Cells(row, 6).Value)        ' Layer
            color = Trim(wsSelectedMacros.Cells(row, 7).Value)        ' Color
            linetype = Trim(wsSelectedMacros.Cells(row, 8).Value)     ' Linetype
            
            ' Default values if missing
            If xCoord = "" Then xCoord = "0"
            If yCoord = "" Then yCoord = "0"
            If zCoord = "" Then zCoord = "0"
            If layer = "" Then layer = "0"
            If color = "" Then color = "256"
            If linetype = "" Then linetype = "ByLayer"
            
            ' Build CSV line in AutoLISP format
            csvLine = blockName & "," & xCoord & "," & yCoord & "," & zCoord & "," & layer & "," & color & "," & linetype
            
            csvFile.WriteLine csvLine
        End If
    Next row
    
    ' Close file
    csvFile.Close
    Set csvFile = Nothing
    Set fso = Nothing
    
    Call LogAction("ExportSelectedMacrosToProjectCSV", "SUCCESS", _
                  "Exported " & (lastRow - 1) & " macros to AutoLISP format: " & csvPath)
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error exporting CSV: " & Err.Description, vbCritical
    Call LogAction("ExportSelectedMacrosToProjectCSV", "ERROR", Err.Description)
    
    ' Cleanup
    On Error Resume Next
    If Not csvFile Is Nothing Then csvFile.Close
    Set csvFile = Nothing
    Set fso = Nothing
End Sub

Sub CreateAutoCADImportTrigger(csvPath As String)
    'Create trigger file for AutoCAD import with detailed information
    Dim triggerPath As String
    Dim fso As Object
    Dim triggerFile As Object
    
    triggerPath = GetSettingValue("ExportPath") & "\IMPORT_TRIGGER.txt"
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set triggerFile = fso.CreateTextFile(triggerPath, True)
    
    ' Write trigger information
    triggerFile.WriteLine "MACRO_MANAGER_IMPORT_TRIGGER"
    triggerFile.WriteLine "CSV_PATH=" & csvPath
    triggerFile.WriteLine "TIMESTAMP=" & Format(Now(), "yyyy-mm-dd hh:mm:ss")
    triggerFile.WriteLine "PROJECT=" & GetSettingValue("ProjectName")
    triggerFile.WriteLine "MACRO_COUNT=" & (wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 1).End(xlUp).Row - 1)
    
    triggerFile.Close
    
    Call LogAction("CreateAutoCADImportTrigger", "SUCCESS", "Trigger created: " & triggerPath)
End Sub

' ============================================================================
' HELPER FUNCTIONS
' ============================================================================

Sub EnsurePathExists(folderPath As String)
    'Ensure the specified folder path exists
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If Not fso.FolderExists(folderPath) Then
        fso.CreateFolder folderPath
    End If
End Sub

Sub SetupMacroLibraryHeaders()
    'Set up standard headers for Macro Library - AutoLISP Export Format
    With wsMacroLibrary
        .Range("A1").Value = "Sl.No"
        .Range("B1").Value = "Block Name"
        .Range("C1").Value = "X Coordinate"
        .Range("D1").Value = "Y Coordinate"
        .Range("E1").Value = "Z Coordinate"
        .Range("F1").Value = "Layer"
        .Range("G1").Value = "Color"
        .Range("H1").Value = "Linetype"
        
        ' Format headers
        With .Range("A1:H1")
            .Font.Bold = True
            .Interior.Color = RGB(150, 150, 150)
            .Font.Color = RGB(255, 255, 255)
        End With
        
        ' Set column widths for better visibility
        .Columns("A:A").ColumnWidth = 8   ' Sl.No
        .Columns("B:B").ColumnWidth = 20  ' Block Name
        .Columns("C:C").ColumnWidth = 12  ' X Coordinate
        .Columns("D:D").ColumnWidth = 12  ' Y Coordinate
        .Columns("E:E").ColumnWidth = 12  ' Z Coordinate
        .Columns("F:F").ColumnWidth = 15  ' Layer
        .Columns("G:G").ColumnWidth = 10  ' Color
        .Columns("H:H").ColumnWidth = 12  ' Linetype
    End With
End Sub

Sub SetupSelectedMacrosHeaders()
    'Set up headers for Selected Macros - AutoLISP Export Format
    With wsSelectedMacros
        .Range("A1").Value = "Sl.No"
        .Range("B1").Value = "Block Name"
        .Range("C1").Value = "X Coordinate"
        .Range("D1").Value = "Y Coordinate"
        .Range("E1").Value = "Z Coordinate"
        .Range("F1").Value = "Layer"
        .Range("G1").Value = "Color"
        .Range("H1").Value = "Linetype"
        
        ' Format headers
        With .Range("A1:H1")
            .Font.Bold = True
            .Interior.Color = RGB(100, 200, 100)
            .Font.Color = RGB(255, 255, 255)
        End With
        
        ' Set column widths for better visibility
        .Columns("A:A").ColumnWidth = 8   ' Sl.No
        .Columns("B:B").ColumnWidth = 20  ' Block Name
        .Columns("C:C").ColumnWidth = 12  ' X Coordinate
        .Columns("D:D").ColumnWidth = 12  ' Y Coordinate
        .Columns("E:E").ColumnWidth = 12  ' Z Coordinate
        .Columns("F:F").ColumnWidth = 15  ' Layer
        .Columns("G:G").ColumnWidth = 10  ' Color
        .Columns("H:H").ColumnWidth = 12  ' Linetype
    End With
End Sub

' ============================================================================
' AUTOCAD INTEGRATION FUNCTIONS
' ============================================================================

Sub LaunchAutoCAD()
    'Launch AutoCAD application if not already running
    
    Dim acadApp As Object
    
    On Error Resume Next
    
    ' Try to get existing AutoCAD instance
    Set acadApp = GetObject(, "AutoCAD.Application")
    
    ' If not running, start new instance
    If acadApp Is Nothing Then
        Set acadApp = CreateObject("AutoCAD.Application")
    End If
    
    ' Make AutoCAD visible and bring to front
    If Not (acadApp Is Nothing) Then
        acadApp.Visible = True
        acadApp.BringToFront
        
        Call LogAction("LaunchAutoCAD", "SUCCESS", "AutoCAD launched/activated successfully")
        
        MsgBox "✓ AutoCAD is now open!" & vbCrLf & vbCrLf & _
               "Next steps:" & vbCrLf & _
               "1. Open your drawing file (or create new)" & vbCrLf & _
               "2. Type: MACROMANAGER" & vbCrLf & _
               "3. Click 'Import' tab" & vbCrLf & _
               "4. Browse to your exported CSV file" & vbCrLf & _
               "5. Click 'Start Import'", _
               vbInformation, "AutoCAD Ready"
    Else
        Call LogAction("LaunchAutoCAD", "ERROR", "Failed to launch AutoCAD")
        MsgBox "Could not launch AutoCAD." & vbCrLf & vbCrLf & _
               "Please ensure AutoCAD is installed on this system.", _
               vbExclamation, "AutoCAD Not Found"
    End If
    
    On Error GoTo 0
End Sub

Sub PromptForCADFile()
    'Prompt user to select a CAD file and open it in AutoCAD
    
    On Error GoTo ErrorHandler
    
    Dim fd As FileDialog
    Dim cadFilePath As String
    Dim shell As Object
    
    ' Open file dialog for CAD files
    Set fd = Application.FileDialog(msoFileDialogFilePicker)
    
    With fd
        .Title = "Select AutoCAD Drawing File"
        .AllowMultiSelect = False
        .Filters.Clear
        .Filters.Add "AutoCAD Drawings", "*.dwg"
        .Filters.Add "AutoCAD DXF", "*.dxf"
        .Filters.Add "All Files", "*.*"
        
        If .Show = -1 Then
            cadFilePath = .SelectedItems(1)
            
            ' Create shell object to open the file
            Set shell = CreateObject("WScript.Shell")
            
            ' Open the CAD file with default application (AutoCAD)
            shell.Run """" & cadFilePath & """", 1, False
            
            Call LogAction("PromptForCADFile", "SUCCESS", "Opened CAD file: " & cadFilePath)
            
            MsgBox "✓ CAD file opened!" & vbCrLf & vbCrLf & _
                   "File: " & cadFilePath & vbCrLf & vbCrLf & _
                   "Next steps:" & vbCrLf & _
                   "1. Wait for AutoCAD to open the drawing" & vbCrLf & _
                   "2. Type: MACROMANAGER" & vbCrLf & _
                   "3. Import your CSV file", _
                   vbInformation, "CAD File Opening"
        Else
            Call LogAction("PromptForCADFile", "INFO", "User cancelled CAD file selection")
        End If
    End With
    
    Exit Sub
    
ErrorHandler:
    Call LogAction("PromptForCADFile", "ERROR", "Error: " & Err.Description)
    MsgBox "Error opening CAD file: " & Err.Description, vbExclamation
End Sub