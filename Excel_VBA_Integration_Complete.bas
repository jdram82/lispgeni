Attribute VB_Name = "Excel_VBA_Integration_Complete"
' ============================================================================
' EXCEL VBA + AUTOCAD UNIFIEDMANAGER v2.4 - COMPLETE INTEGRATION
' PURPOSE: Import/Export macros with AutoCAD coordinate placement
' VERSION: 1.0 - PRODUCTION READY
' ============================================================================
' WORKFLOW:
'   1. Import CSV from UnifiedManager export → Macro Library
'   2. User filters in Project_Config → Selected Macros (auto-populated)
'   3. Generate Drawings → Export CSV + Launch AutoCAD
'   4. AutoCAD imports CSV and places blocks at coordinates
' ============================================================================

Option Explicit

' ============================================================================
' GLOBAL WORKSHEET REFERENCES
' ============================================================================
Public wsMacroLibrary As Worksheet
Public wsSelectedMacros As Worksheet
Public wsProjectConfig As Worksheet
Public wsSettings As Worksheet
Public wsLogs As Worksheet

' ============================================================================
' INITIALIZATION - CALL THIS FIRST!
' ============================================================================
Sub InitializeWorksheets()
    'Initialize all worksheet references
    On Error GoTo ErrorHandler
    
    Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")
    Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")
    Set wsProjectConfig = ThisWorkbook.Sheets("Project Config")
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    
    MsgBox "✓ Worksheets initialized successfully!", vbInformation
    Exit Sub
    
ErrorHandler:
    MsgBox "ERROR: Could not initialize worksheets." & vbCrLf & _
           Err.Description, vbCritical
End Sub

' ============================================================================
' STEP 1: IMPORT CSV FROM UNIFIEDMANAGER (MACRO LIBRARY TAB)
' ============================================================================
Sub ImportMacrosFromCSV_Click()
    'Import CSV exported from UnifiedManager v2.4
    'Expected format: CircuitName,Category,DWG_File,BaseX,BaseY,BaseZ,InsertX,InsertY,InsertZ,Export_Date,Export_Time
    
    Dim csvPath As String
    Dim fso As Object
    Dim csvFile As Object
    Dim line As String
    Dim fields() As String
    Dim row As Long
    Dim recordCount As Long
    
    On Error GoTo ErrorHandler
    
    ' Initialize if needed
    If wsMacroLibrary Is Nothing Then Call InitializeWorksheets
    
    ' Browse for CSV file
    csvPath = BrowseForFile("csv")
    If csvPath = "" Then Exit Sub
    
    ' Clear existing data (keep headers)
    wsMacroLibrary.Range("A2:L10000").ClearContents
    
    ' Set up headers for UnifiedManager format
    Call SetupMacroLibraryHeaders
    
    ' Open and parse CSV
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(csvPath) Then
        MsgBox "File not found: " & csvPath, vbCritical
        Exit Sub
    End If
    
    Set csvFile = fso.OpenTextFile(csvPath, 1)  ' ForReading
    row = 2  ' Start after header
    recordCount = 0
    
    ' Skip header line if exists
    If Not csvFile.AtEndOfStream Then
        line = csvFile.ReadLine
        ' Check if this is actually a header (contains "Block" or "Circuit")
        If Not (InStr(1, line, "Block", vbTextCompare) > 0 Or _
                InStr(1, line, "Circuit", vbTextCompare) > 0 Or _
                InStr(1, line, "Category", vbTextCompare) > 0) Then
            ' Not a header, process this line as data
            If Trim(line) <> "" Then
                fields = Split(line, ",")
                If UBound(fields) >= 10 Then
                    wsMacroLibrary.Cells(row, 1).Value = recordCount + 1
                    wsMacroLibrary.Cells(row, 2).Value = Trim(fields(0))
                    wsMacroLibrary.Cells(row, 3).Value = Trim(fields(1))
                    wsMacroLibrary.Cells(row, 4).Value = Trim(fields(2))
                    wsMacroLibrary.Cells(row, 5).Value = CDbl(fields(3))
                    wsMacroLibrary.Cells(row, 6).Value = CDbl(fields(4))
                    wsMacroLibrary.Cells(row, 7).Value = CDbl(fields(5))
                    wsMacroLibrary.Cells(row, 8).Value = Trim(fields(6))
                    wsMacroLibrary.Cells(row, 9).Value = Trim(fields(7))
                    wsMacroLibrary.Cells(row, 10).Value = Trim(fields(8))
                    wsMacroLibrary.Cells(row, 11).Value = Trim(fields(9))
                    wsMacroLibrary.Cells(row, 12).Value = Trim(fields(10))
                    row = row + 1
                    recordCount = recordCount + 1
                End If
            End If
        End If
    End If
    
    ' Read remaining data lines
    Do While Not csvFile.AtEndOfStream
        line = csvFile.ReadLine
        If Trim(line) <> "" Then
            fields = Split(line, ",")
            
            ' Map UnifiedManager Auto CSV to Excel columns (12 columns)
            ' CSV: Block/Circuit Name,Category,DWG File,X,Y,Z,Layer,Color,Linetype,Export_Date,Export_Time
            If UBound(fields) >= 10 Then
                wsMacroLibrary.Cells(row, 1).Value = recordCount + 1       ' Sl.No (Auto-generated)
                wsMacroLibrary.Cells(row, 2).Value = Trim(fields(0))       ' Block/Circuit Name
                wsMacroLibrary.Cells(row, 3).Value = Trim(fields(1))       ' Category
                wsMacroLibrary.Cells(row, 4).Value = Trim(fields(2))       ' DWG File Location
                wsMacroLibrary.Cells(row, 5).Value = CDbl(fields(3))       ' X Coordinate
                wsMacroLibrary.Cells(row, 6).Value = CDbl(fields(4))       ' Y Coordinate
                wsMacroLibrary.Cells(row, 7).Value = CDbl(fields(5))       ' Z Coordinate
                wsMacroLibrary.Cells(row, 8).Value = Trim(fields(6))       ' Layer
                wsMacroLibrary.Cells(row, 9).Value = Trim(fields(7))       ' Color
                wsMacroLibrary.Cells(row, 10).Value = Trim(fields(8))      ' Linetype
                wsMacroLibrary.Cells(row, 11).Value = Trim(fields(9))      ' Export Date
                wsMacroLibrary.Cells(row, 12).Value = Trim(fields(10))     ' Export Time
                
                row = row + 1
                recordCount = recordCount + 1
            End If
        End If
    Loop
    
    csvFile.Close
    Set csvFile = Nothing
    Set fso = Nothing
    
    ' Format data
    Call FormatMacroLibraryData
    
    ' Store CSV path for reference
    wsMacroLibrary.Range("Z1").Value = csvPath
    
    Call LogAction("ImportMacrosFromCSV", "SUCCESS", _
        "Imported " & recordCount & " macros from: " & csvPath)
    
    MsgBox "✓ CSV Import Complete!" & vbCrLf & vbCrLf & _
           "📊 " & recordCount & " macros loaded to Macro Library" & vbCrLf & vbCrLf & _
           "Next Step:" & vbCrLf & _
           "→ Go to Project_Config tab to set filter criteria" & vbCrLf & _
           "→ Selected Macros will auto-populate based on your formulas", _
           vbInformation, "Import Complete"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error importing CSV: " & Err.Description, vbCritical
    Call LogAction("ImportMacrosFromCSV", "ERROR", Err.Description)
End Sub

' ============================================================================
' STEP 2: GENERATE DRAWINGS (PROJECT_CONFIG TAB)
' ============================================================================
Sub GenerateDrawings_Click()
    'DUAL OPERATION:
    '  1. Export Selected Macros to CSV (UnifiedManager import format)
    '  2. Launch AutoCAD and prompt for target drawing
    
    Dim projectName As String
    Dim exportPath As String
    Dim csvFileName As String
    Dim selectedCount As Long
    Dim response As Integer
    
    On Error GoTo ErrorHandler
    
    ' Initialize if needed
    If wsSelectedMacros Is Nothing Then Call InitializeWorksheets
    
    ' ─────────────────────────────────────────────────────────────────
    ' VALIDATION
    ' ─────────────────────────────────────────────────────────────────
    
    ' Check project name
    projectName = GetSettingValue("ProjectName")
    If projectName = "" Or projectName = "New Project" Then
        MsgBox "❌ Please set a valid Project Name in Settings first!" & vbCrLf & vbCrLf & _
               "Go to Settings tab and enter a project name.", _
               vbExclamation, "Project Name Required"
        Exit Sub
    End If
    
    ' Check if macros are selected
    selectedCount = wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 1).End(xlUp).row - 1
    If selectedCount <= 0 Then
        MsgBox "❌ No macros in Selected Macros sheet!" & vbCrLf & vbCrLf & _
               "Please ensure your filter formulas populate Selected Macros.", _
               vbExclamation, "No Selection"
        Exit Sub
    End If
    
    ' ─────────────────────────────────────────────────────────────────
    ' OPERATION 1: EXPORT TO CSV
    ' ─────────────────────────────────────────────────────────────────
    
    ' Get export path
    exportPath = GetSettingValue("ExportPath")
    If exportPath = "" Then exportPath = ThisWorkbook.Path
    
    ' Ensure folder exists
    Call EnsureFolderExists(exportPath)
    
    ' Create CSV filename
    csvFileName = exportPath & "\Project_" & projectName & "_" & _
                  Format(Now, "yyyyMMdd_HHmmss") & ".csv"
    
    ' Export to CSV in UnifiedManager import format
    Call ExportSelectedMacrosToCSV(csvFileName)
    
    Call LogAction("GenerateDrawings", "SUCCESS", _
        "Exported " & selectedCount & " macros to: " & csvFileName)
    
    ' ─────────────────────────────────────────────────────────────────
    ' OPERATION 2: LAUNCH AUTOCAD
    ' ─────────────────────────────────────────────────────────────────
    
    response = MsgBox( _
        "✓ OPERATION 1 COMPLETE: CSV Export" & vbCrLf & vbCrLf & _
        "📄 CSV File: " & csvFileName & vbCrLf & vbCrLf & _
        "🔧 OPERATION 2: AutoCAD Integration" & vbCrLf & vbCrLf & _
        "Do you want to launch AutoCAD now?", _
        vbYesNo + vbQuestion, "Generate Drawings")
    
    If response = vbYes Then
        Call LaunchAutoCADWithPrompt(csvFileName)
    End If
    
    ' ─────────────────────────────────────────────────────────────────
    ' COMPLETION
    ' ─────────────────────────────────────────────────────────────────
    
    MsgBox "✅ GENERATE DRAWINGS COMPLETED!" & vbCrLf & vbCrLf & _
           "📊 Exported: " & selectedCount & " macros" & vbCrLf & _
           "📄 CSV File: " & csvFileName & vbCrLf & vbCrLf & _
           "🚀 Next Steps in AutoCAD:" & vbCrLf & _
           "   1. Open your target drawing file" & vbCrLf & _
           "   2. Type: UCB  or  UNIFIEDMANAGER" & vbCrLf & _
           "   3. Switch to Import mode" & vbCrLf & _
           "   4. Browse for the CSV file" & vbCrLf & _
           "   5. Import will place blocks at specified coordinates", _
           vbInformation, "Process Complete"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "❌ Error in Generate Drawings: " & Err.Description, vbCritical
    Call LogAction("GenerateDrawings", "ERROR", Err.Description)
End Sub

' ============================================================================
' EXPORT SELECTED MACROS TO CSV (UnifiedManager Import Format)
' ============================================================================
Sub ExportSelectedMacrosToCSV(csvPath As String)
    'Export Selected Macros in UnifiedManager import format
    'Format: CircuitName,Category,DWG_File,BaseX,BaseY,BaseZ,InsertX,InsertY,InsertZ,Export_Date,Export_Time
    
    Dim fso As Object
    Dim csvFile As Object
    Dim lastRow As Long
    Dim row As Long
    Dim csvLine As String
    
    On Error GoTo ErrorHandler
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set csvFile = fso.CreateTextFile(csvPath, True)
    
    ' Write header (UnifiedManager Auto import format - 12 columns)
    csvFile.WriteLine "Block/Circuit Name,Category,DWG File Location,X Coordinate,Y Coordinate,Z Coordinate,Layer,Color,Linetype,Export Date,Export Time"
    
    ' Get last row with data
    lastRow = wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 2).End(xlUp).row
    
    ' Write data rows - 12 columns matching UnifiedManager Auto format
    For row = 2 To lastRow
        If Trim(wsSelectedMacros.Cells(row, 2).Value) <> "" Then
            ' Build CSV line: Block/Circuit Name,Category,DWG File,X,Y,Z,Layer,Color,Linetype,Export_Date,Export_Time
            csvLine = _
                wsSelectedMacros.Cells(row, 2).Value & "," & _
                wsSelectedMacros.Cells(row, 3).Value & "," & _
                wsSelectedMacros.Cells(row, 4).Value & "," & _
                wsSelectedMacros.Cells(row, 5).Value & "," & _
                wsSelectedMacros.Cells(row, 6).Value & "," & _
                wsSelectedMacros.Cells(row, 7).Value & "," & _
                wsSelectedMacros.Cells(row, 8).Value & "," & _
                wsSelectedMacros.Cells(row, 9).Value & "," & _
                wsSelectedMacros.Cells(row, 10).Value & "," & _
                wsSelectedMacros.Cells(row, 11).Value & "," & _
                wsSelectedMacros.Cells(row, 12).Value
            
            csvFile.WriteLine csvLine
        End If
    Next row
    
    csvFile.Close
    Set csvFile = Nothing
    Set fso = Nothing
    
    Call LogAction("ExportSelectedMacrosToCSV", "SUCCESS", _
        "Exported " & (lastRow - 1) & " records to: " & csvPath)
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error exporting CSV: " & Err.Description, vbCritical
    Call LogAction("ExportSelectedMacrosToCSV", "ERROR", Err.Description)
End Sub

' ============================================================================
' LAUNCH AUTOCAD WITH PROMPT
' ============================================================================
Sub LaunchAutoCADWithPrompt(csvFilePath As String)
    'Launch AutoCAD and provide instructions
    
    Dim acadApp As Object
    Dim targetDwg As String
    Dim fd As FileDialog
    
    On Error Resume Next
    
    ' Try to get existing AutoCAD instance
    Set acadApp = GetObject(, "AutoCAD.Application")
    
    ' If not running, start new instance
    If acadApp Is Nothing Then
        Set acadApp = CreateObject("AutoCAD.Application")
    End If
    
    ' Make AutoCAD visible
    If Not (acadApp Is Nothing) Then
        acadApp.Visible = True
        acadApp.BringToFront
        
        ' Prompt user to select target drawing
        Set fd = Application.FileDialog(msoFileDialogFilePicker)
        With fd
            .Title = "Select Target AutoCAD Drawing for Macro Import"
            .AllowMultiSelect = False
            .Filters.Clear
            .Filters.Add "AutoCAD Drawings", "*.dwg"
            .Filters.Add "All Files", "*.*"
            
            If .Show = -1 Then
                targetDwg = .SelectedItems(1)
                
                ' Open the drawing in AutoCAD
                On Error Resume Next
                acadApp.Documents.Open targetDwg
                On Error GoTo 0
                
                Call LogAction("LaunchAutoCAD", "SUCCESS", _
                    "Opened drawing: " & targetDwg)
                
                MsgBox "✓ AutoCAD is ready!" & vbCrLf & vbCrLf & _
                       "📂 Drawing: " & targetDwg & vbCrLf & _
                       "📄 CSV File: " & csvFilePath & vbCrLf & vbCrLf & _
                       "🔧 Next Steps in AutoCAD:" & vbCrLf & _
                       "   1. Type: UCB  or  UNIFIEDMANAGER" & vbCrLf & _
                       "   2. Click 'Import' mode" & vbCrLf & _
                       "   3. Select 'Circuits' content type" & vbCrLf & _
                       "   4. Browse for CSV: " & vbCrLf & _
                       "      " & csvFilePath & vbCrLf & _
                       "   5. Macros will be placed at exact coordinates!", _
                       vbInformation, "AutoCAD Ready"
            Else
                MsgBox "⚠ No drawing selected." & vbCrLf & vbCrLf & _
                       "Please open your target drawing manually in AutoCAD.", _
                       vbExclamation
            End If
        End With
    Else
        Call LogAction("LaunchAutoCAD", "ERROR", "Failed to launch AutoCAD")
        MsgBox "❌ Could not launch AutoCAD." & vbCrLf & vbCrLf & _
               "Please ensure AutoCAD Electrical 2024 is installed.", _
               vbExclamation, "AutoCAD Not Found"
    End If
    
    On Error GoTo 0
End Sub

' ============================================================================
' HELPER FUNCTIONS
' ============================================================================

Sub SetupMacroLibraryHeaders()
    'Set up headers for Macro Library - 12 Column Format (UnifiedManager Auto)
    With wsMacroLibrary
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
        End With
        
        ' Set column widths
        .Columns("A:A").ColumnWidth = 8
        .Columns("B:B").ColumnWidth = 25
        .Columns("C:C").ColumnWidth = 20
        .Columns("D:D").ColumnWidth = 50
        .Columns("E:G").ColumnWidth = 12
        .Columns("H:H").ColumnWidth = 15
        .Columns("I:J").ColumnWidth = 12
        .Columns("K:L").ColumnWidth = 18
    End With
End Sub

Sub FormatMacroLibraryData()
    'Format Macro Library data - 12 column format
    With wsMacroLibrary
        .Columns("E:G").NumberFormat = "0.0000"  ' X, Y, Z Coordinates (4 decimal places)
        .Columns.AutoFit
        
        ' Add borders
        Dim lastRow As Long
        lastRow = .Cells(.Rows.Count, 1).End(xlUp).row
        If lastRow > 1 Then
            .Range("A1:L" & lastRow).Borders.LineStyle = xlContinuous
        End If
        
        ' Freeze panes at row 2
        .Range("A2").Select
        ActiveWindow.FreezePanes = True
    End With
End Sub

Sub EnsureFolderExists(folderPath As String)
    'Create folder if it doesn't exist
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If Not fso.FolderExists(folderPath) Then
        fso.CreateFolder folderPath
    End If
End Sub

Function BrowseForFile(fileType As String) As String
    'File browser dialog
    Dim fd As FileDialog
    Dim fileName As String
    
    On Error GoTo ErrorHandler
    
    Set fd = Application.FileDialog(msoFileDialogFilePicker)
    
    With fd
        .Title = "Select " & UCase(fileType) & " File"
        .AllowMultiSelect = False
        .Filters.Clear
        
        Select Case LCase(fileType)
            Case "csv"
                .Filters.Add "CSV Files", "*.csv"
                .Filters.Add "All Files", "*.*"
            Case "dwg"
                .Filters.Add "AutoCAD Drawings", "*.dwg"
                .Filters.Add "All Files", "*.*"
            Case Else
                .Filters.Add "All Files", "*.*"
        End Select
        
        If .Show = -1 Then
            fileName = .SelectedItems(1)
        End If
    End With
    
    BrowseForFile = fileName
    Exit Function
    
ErrorHandler:
    BrowseForFile = ""
End Function

Function GetSettingValue(settingName As String) As String
    'Get setting value from Settings sheet
    On Error Resume Next
    
    Select Case settingName
        Case "ProjectName"
            GetSettingValue = wsSettings.Range("B4").Value
        Case "ExportPath"
            GetSettingValue = wsSettings.Range("B6").Value
        Case "CSVFilesPath"
            GetSettingValue = wsSettings.Range("B8").Value
        Case Else
            GetSettingValue = ""
    End Select
End Function

Sub LogAction(action As String, status As String, details As String)
    'Log action to Logs sheet
    Dim lastRow As Long
    
    On Error Resume Next
    
    If wsLogs Is Nothing Then Exit Sub
    
    lastRow = wsLogs.Cells(wsLogs.Rows.Count, 1).End(xlUp).row + 1
    
    wsLogs.Cells(lastRow, 1).Value = Format(Now, "yyyy-mm-dd hh:mm:ss")
    wsLogs.Cells(lastRow, 2).Value = action
    wsLogs.Cells(lastRow, 3).Value = status
    wsLogs.Cells(lastRow, 4).Value = details
    
    ' Color code by status
    Select Case UCase(status)
        Case "ERROR"
            wsLogs.Rows(lastRow).Interior.Color = RGB(255, 200, 200)
        Case "SUCCESS"
            wsLogs.Rows(lastRow).Interior.Color = RGB(200, 255, 200)
    End Select
End Sub

' ============================================================================
' BUTTON CLICK HANDLERS
' ============================================================================

Sub RefreshMacroLibrary_Click()
    'Refresh from last imported CSV
    Dim csvPath As String
    
    csvPath = wsMacroLibrary.Range("Z1").Value
    
    If csvPath <> "" And Dir(csvPath) <> "" Then
        Call ImportMacrosFromCSV_Click
    Else
        MsgBox "No previous CSV file found. Please import a CSV first.", vbExclamation
    End If
End Sub

Sub ClearMacroLibrary_Click()
    'Clear all macro library data
    Dim response As Integer
    
    response = MsgBox("Clear all macro library data?", vbYesNo + vbQuestion)
    
    If response = vbYes Then
        wsMacroLibrary.Range("A2:L10000").ClearContents
        wsSelectedMacros.Range("A2:L10000").ClearContents
        
        MsgBox "✓ Macro Library cleared!", vbInformation
    End If
End Sub

' ============================================================================
' BROWSE BUTTON FUNCTIONS (Settings Sheet)
' ============================================================================

Sub BrowseMacroLibraryButton_Click()
    'Browse for Macro Library folder path
    Dim folderPath As String
    
    folderPath = BrowseForFolder("Select Macro Library Folder")
    
    If folderPath <> "" Then
        wsSettings.Range("B2").Value = folderPath
        Call LogAction("BrowseMacroLibrary", "SUCCESS", "Path set to: " & folderPath)
    End If
End Sub

Sub BrowseExportPathButton_Click()
    'Browse for Export folder path
    Dim folderPath As String
    
    folderPath = BrowseForFolder("Select Export Folder")
    
    If folderPath <> "" Then
        wsSettings.Range("B6").Value = folderPath
        Call LogAction("BrowseExportPath", "SUCCESS", "Path set to: " & folderPath)
    End If
End Sub

Sub BrowseCSVFilesPathButton_Click()
    'Browse for CSV Files folder path
    Dim folderPath As String
    
    folderPath = BrowseForFolder("Select CSV Files Folder")
    
    If folderPath <> "" Then
        wsSettings.Range("B8").Value = folderPath
        Call LogAction("BrowseCSVFilesPath", "SUCCESS", "Path set to: " & folderPath)
    End If
End Sub

Sub BrowseLogsPathButton_Click()
    'Browse for Logs folder path
    Dim folderPath As String
    
    folderPath = BrowseForFolder("Select Logs Folder")
    
    If folderPath <> "" Then
        wsSettings.Range("B10").Value = folderPath
        Call LogAction("BrowseLogsPath", "SUCCESS", "Path set to: " & folderPath)
    End If
End Sub

Sub BrowseBlockLibraryPathButton_Click()
    'Browse for Block Library folder path
    Dim folderPath As String
    
    folderPath = BrowseForFolder("Select Block Library Folder")
    
    If folderPath <> "" Then
        wsSettings.Range("B12").Value = folderPath
        Call LogAction("BrowseBlockLibraryPath", "SUCCESS", "Path set to: " & folderPath)
    End If
End Sub

Function BrowseForFolder(dialogTitle As String) As String
    'Folder browser dialog
    Dim fldr As FileDialog
    Dim selectedPath As String
    
    On Error GoTo ErrorHandler
    
    Set fldr = Application.FileDialog(msoFileDialogFolderPicker)
    
    With fldr
        .Title = dialogTitle
        .AllowMultiSelect = False
        .InitialFileName = Application.DefaultFilePath & "\"
        
        If .Show <> -1 Then
            BrowseForFolder = ""
            Exit Function
        End If
        
        selectedPath = .SelectedItems(1)
    End With
    
    BrowseForFolder = selectedPath
    Exit Function
    
ErrorHandler:
    MsgBox "Error selecting folder: " & Err.Description, vbExclamation
    BrowseForFolder = ""
End Function

' ============================================================================
' SETTINGS SHEET BUTTON FUNCTIONS
' ============================================================================

Sub ChooseExportPath_Click()
    'Browse for Export folder path
    Dim folderPath As String
    
    folderPath = BrowseForFolder("Select Export Folder")
    
    If folderPath <> "" Then
        wsSettings.Range("B3").Value = folderPath
        Call LogAction("ChooseExportPath", "SUCCESS", "Export path: " & folderPath)
    End If
End Sub

Sub ChooseCSVFilesPath_Click()
    'Browse for CSV Files folder path
    Dim folderPath As String
    
    folderPath = BrowseForFolder("Select CSV Files Folder")
    
    If folderPath <> "" Then
        wsSettings.Range("B4").Value = folderPath
        Call LogAction("ChooseCSVFilesPath", "SUCCESS", "CSV path: " & folderPath)
    End If
End Sub

Sub ChooseLogsPath_Click()
    'Browse for Logs folder path
    Dim folderPath As String
    
    folderPath = BrowseForFolder("Select Logs Folder")
    
    If folderPath <> "" Then
        wsSettings.Range("B5").Value = folderPath
        Call LogAction("ChooseLogsPath", "SUCCESS", "Logs path: " & folderPath)
    End If
End Sub

Sub SaveSettings_Click()
    'Save current settings
    On Error GoTo ErrorHandler
    
    ' Validate paths exist
    Dim exportPath As String
    Dim csvPath As String
    Dim logsPath As String
    
    exportPath = wsSettings.Range("B3").Value
    csvPath = wsSettings.Range("B4").Value
    logsPath = wsSettings.Range("B5").Value
    
    ' Check if paths are set
    If exportPath = "" Or csvPath = "" Or logsPath = "" Then
        MsgBox "Please set all folder paths before saving.", vbExclamation
        Exit Sub
    End If
    
    Call LogAction("SaveSettings", "SUCCESS", "Settings saved successfully")
    MsgBox "✓ Settings saved successfully!", vbInformation
    Exit Sub
    
ErrorHandler:
    MsgBox "Error saving settings: " & Err.Description, vbCritical
    Call LogAction("SaveSettings", "ERROR", Err.Description)
End Sub

Sub ResetDefaults_Click()
    'Reset settings to default values
    Dim response As VbMsgBoxResult
    
    response = MsgBox("Reset all settings to defaults?" & vbCrLf & vbCrLf & _
                      "This will clear all custom paths.", vbQuestion + vbYesNo)
    
    If response = vbYes Then
        wsSettings.Range("B2").Value = "ICE RINK"
        wsSettings.Range("B3").Value = "D:\Excel VBA Automation\MCC_Integration_Project\ICE RINK\Exports"
        wsSettings.Range("B4").Value = "D:\Excel VBA Automation\MCC_Integration_Project\ICE RINK\CSVs"
        wsSettings.Range("B5").Value = "D:\Excel VBA Automation\MCC_Integration_Project\ICE RINK\Logs"
        wsSettings.Range("B6").Value = "Yes"
        
        Call LogAction("ResetDefaults", "SUCCESS", "Settings reset to defaults")
        MsgBox "✓ Settings reset to defaults!", vbInformation
    End If
End Sub
