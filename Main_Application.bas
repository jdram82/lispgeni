' ============================================================================
' MODULE: Main_Application
' PURPOSE: Application entry points and initialization
' VERSION: 1.0 - CORRECTED & TESTED
' ============================================================================

Option Explicit

' ============================================================================
' GLOBAL WORKSHEET REFERENCES
' ============================================================================

Public wsMacroLibrary As Worksheet
Public wsProjectConfig As Worksheet
Public wsAvailableMacros As Worksheet
Public wsSelectedMacros As Worksheet
Public wsDashboard As Worksheet
Public wsLogs As Worksheet
Public wsSettings As Worksheet

' ============================================================================
' INITIALIZE APPLICATION (Called on workbook open)
' ============================================================================

Sub InitializeApplication()
    'Called on workbook open - set up all worksheet references
    
    On Error GoTo ErrorHandler
    
    ' Set worksheet references
    Set wsMacroLibrary = ThisWorkbook.Sheets("Macro_Library")
    Set wsProjectConfig = ThisWorkbook.Sheets("Project_Config")
    Set wsAvailableMacros = ThisWorkbook.Sheets("Available_Macros")
    Set wsSelectedMacros = ThisWorkbook.Sheets("Selected_Macros")
    Set wsDashboard = ThisWorkbook.Sheets("Dashboard")
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    ' Load settings from Settings sheet
    Call LoadAppConfiguration
    
    ' Update dashboard
    Call UpdateDashboard
    
    MsgBox "Application initialized successfully!", vbInformation, "Macro Manager"
    Exit Sub
    
ErrorHandler:
    MsgBox "Error initializing application: " & Err.Description, vbCritical, "Initialization Error"
End Sub

' ============================================================================
' REFRESH MACRO LIBRARY
' ============================================================================

Sub RefreshMacroLibrary()
    'Reload Macro_Library.csv into worksheet
    
    Dim csvPath As String
    On Error GoTo ErrorHandler
    
    csvPath = GetSettingValue("MacroLibraryPath")
    
    If Dir(csvPath) <> "" Then
        Call ImportCSVToSheet(wsMacroLibrary, csvPath)
        Call UpdateAvailableMacros
        Call LogAction("RefreshMacroLibrary", "SUCCESS", "Imported from: " & csvPath)
        MsgBox "Macro Library refreshed successfully!", vbInformation
    Else
        MsgBox "Macro Library CSV not found: " & csvPath, vbCritical
        Call LogAction("RefreshMacroLibrary", "ERROR", "File not found: " & csvPath)
    End If
    
    Exit Sub
ErrorHandler:
    MsgBox "Error refreshing library: " & Err.Description, vbCritical
    Call LogAction("RefreshMacroLibrary", "ERROR", Err.Description)
End Sub

' ============================================================================
' UPDATE AVAILABLE MACROS
' ============================================================================

Sub UpdateAvailableMacros()
    'Populate Available_Macros sheet from Macro_Library
    
    Dim lastRow As Long
    Dim i As Long
    
    On Error GoTo ErrorHandler
    
    lastRow = wsMacroLibrary.Cells(wsMacroLibrary.Rows.Count, 1).End(xlUp).row
    
    ' Clear available macros sheet
    wsAvailableMacros.Cells.Clear
    
    ' Copy headers from Macro_Library
    wsMacroLibrary.Rows(1).Copy wsAvailableMacros.Rows(1)
    
    ' Add checkbox column header
    wsAvailableMacros.Range("A1").Value = "Select"
    
    ' Copy all data rows
    If lastRow > 1 Then
        wsMacroLibrary.Range(wsMacroLibrary.Cells(2, 1), wsMacroLibrary.Cells(lastRow, 8)).Copy _
            wsAvailableMacros.Range("B2")
    End If
    
    ' Format available macros sheet
    Call FormatAvailableMacrosSheet
    
    Call LogAction("UpdateAvailableMacros", "SUCCESS", "Updated with " & (lastRow - 1) & " macros")
    
    Exit Sub
ErrorHandler:
    MsgBox "Error updating available macros: " & Err.Description, vbCritical
    Call LogAction("UpdateAvailableMacros", "ERROR", Err.Description)
End Sub

' ============================================================================
' EXPORT FILTERED MACROS TO CSV
' ============================================================================

Sub ExportFilteredMacrosToCSV()
    'Export selected macros to Project_Macros_[ProjectName].csv
    
    Dim csvPath As String
    Dim projectName As String
    Dim selectedData As Variant
    
    On Error GoTo ErrorHandler
    
    projectName = GetSettingValue("ProjectName")
    
    If projectName = "" Then
        MsgBox "Please set Project Name in Settings sheet first.", vbExclamation
        Exit Sub
    End If
    
    csvPath = GetSettingValue("ExportPath") & "\Project_Macros_" & projectName & ".csv"
    
    ' Create backup
    If Dir(csvPath) <> "" Then
        FileCopy csvPath, csvPath & ".bak_" & Format(Now(), "yyyyMMdd_HHmmss")
        Call LogAction("ExportFilteredMacros", "INFO", "Backup created")
    End If
    
    ' Get selected macros data
    selectedData = GetSelectedMacrosData()
    
    ' Export to CSV
    Call ExportToCSV(selectedData, csvPath)
    
    MsgBox "Filtered macros exported successfully to:" & vbCrLf & csvPath, vbInformation
    Call LogAction("ExportFilteredMacros", "SUCCESS", "Exported to: " & csvPath)
    
    Exit Sub
ErrorHandler:
    MsgBox "Error exporting filtered macros: " & Err.Description, vbCritical
    Call LogAction("ExportFilteredMacros", "ERROR", Err.Description)
End Sub

' ============================================================================
' GET SELECTED MACROS DATA
' ============================================================================

Function GetSelectedMacrosData() As Variant
    'Return array of selected macros from wsSelectedMacros
    
    Dim lastRow As Long
    Dim lastCol As Long
    Dim dataRange As Range
    
    On Error GoTo ErrorHandler
    
    lastRow = wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 1).End(xlUp).row
    lastCol = wsSelectedMacros.Cells(1, wsSelectedMacros.Columns.Count).End(xlToLeft).Column
    
    If lastRow < 1 Then
        MsgBox "No selected macros to export!", vbExclamation
        Exit Function
    End If
    
    Set dataRange = wsSelectedMacros.Range(wsSelectedMacros.Cells(1, 1), wsSelectedMacros.Cells(lastRow, lastCol))
    GetSelectedMacrosData = dataRange.Value
    
    Exit Function
ErrorHandler:
    MsgBox "Error getting selected macros: " & Err.Description, vbCritical
End Function

' ============================================================================
' IMPORT FROM CSV
' ============================================================================

Sub ImportFromCSV()
    'Import macros from CSV file browser
    
    Dim csvPath As String
    
    On Error GoTo ErrorHandler
    
    csvPath = BrowseForFile("csv")
    
    If csvPath <> "" Then
        Call ImportCSVToSheet(wsMacroLibrary, csvPath)
        Call UpdateAvailableMacros
        Call LogAction("ImportFromCSV", "SUCCESS", "Imported: " & csvPath)
        MsgBox "CSV imported successfully!", vbInformation
    Else
        MsgBox "No file selected.", vbExclamation
    End If
    
    Exit Sub
ErrorHandler:
    MsgBox "Error importing CSV: " & Err.Description, vbCritical
End Sub

' ============================================================================
' SEND TO AUTOCAD
' ============================================================================

Sub SendToAutoCAD()
    'Notify AutoCAD to import filtered macros
    
    Dim csvPath As String
    Dim projectName As String
    Dim fso As Object
    Dim triggerFile As String
    Dim fsoFile As Object
    
    On Error GoTo ErrorHandler
    
    projectName = GetSettingValue("ProjectName")
    csvPath = GetSettingValue("ExportPath") & "\Project_Macros_" & projectName & ".csv"
    
    If Dir(csvPath) = "" Then
        MsgBox "Please export filtered macros first!", vbExclamation
        Call LogAction("SendToAutoCAD", "ERROR", "CSV file not found: " & csvPath)
        Exit Sub
    End If
    
    ' Create trigger file
    Set fso = CreateObject("Scripting.FileSystemObject")
    triggerFile = GetSettingValue("ExportPath") & "\IMPORT_TRIGGER.txt"
    
    Set fsoFile = fso.CreateTextFile(triggerFile, True)
    fsoFile.WriteLine csvPath
    fsoFile.Close
    
    ' Optional: Launch AutoCAD
    If GetSettingValue("AutoLaunchAutoCAD") = "Yes" Then
        Call LaunchAutoCAD
    End If
    
    Call LogAction("SendToAutoCAD", "SUCCESS", "Trigger file created: " & triggerFile)
    MsgBox "AutoCAD has been notified to import macros.", vbInformation
    
    Exit Sub
ErrorHandler:
    MsgBox "Error sending to AutoCAD: " & Err.Description, vbCritical
    Call LogAction("SendToAutoCAD", "ERROR", Err.Description)
End Sub

' ============================================================================
' LAUNCH AUTOCAD
' ============================================================================

Sub LaunchAutoCAD()
    'Launch AutoCAD application if not running
    
    Dim acadApp As Object
    
    On Error Resume Next
    Set acadApp = GetObject(, "AutoCAD.Application")
    
    If acadApp Is Nothing Then
        Set acadApp = CreateObject("AutoCAD.Application")
    End If
    
    If Not (acadApp Is Nothing) Then
        acadApp.Visible = True
        acadApp.BringToFront
    End If
    
    On Error GoTo 0
End Sub

' ============================================================================
' FORMAT AVAILABLE MACROS SHEET
' ============================================================================

Sub FormatAvailableMacrosSheet()
    'Format Available_Macros sheet
    
    Dim ws As Worksheet
    Set ws = wsAvailableMacros
    
    On Error Resume Next
    
    ' Format header row
    With ws.Range("1:1")
        .Font.Bold = True
        .Interior.Color = RGB(100, 150, 200)
        .Font.Color = RGB(255, 255, 255)
    End With
    
    ' Auto-fit columns
    ws.Columns.AutoFit
    
    ' Add autofilter
    ws.Range("1:1").AutoFilter
    
    On Error GoTo 0
End Sub

' ============================================================================
' FORMAT SELECTED MACROS SHEET
' ============================================================================

Sub FormatSelectedMacrosSheet()
    'Format Selected_Macros sheet
    
    Dim ws As Worksheet
    Set ws = wsSelectedMacros
    
    On Error Resume Next
    
    ' Format header row
    With ws.Range("1:1")
        .Font.Bold = True
        .Interior.Color = RGB(100, 200, 100)
        .Font.Color = RGB(255, 255, 255)
    End With
    
    ' Auto-fit columns
    ws.Columns.AutoFit
    
    ' Freeze header row
    ws.Range("2:2").Select
    ActiveWindow.FreezePanes = True
    
    On Error GoTo 0
End Sub

' ============================================================================
' UPDATE DASHBOARD
' ============================================================================

Sub UpdateDashboard()
    'Update Dashboard sheet with current statistics
    
    Dim ws As Worksheet
    Dim totalMacros As Long
    Dim selectedMacros As Long
    
    On Error Resume Next
    
    Set ws = wsDashboard
    
    totalMacros = wsMacroLibrary.Cells(wsMacroLibrary.Rows.Count, 1).End(xlUp).row - 1
    selectedMacros = wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 1).End(xlUp).row - 1
    
    ws.Range("B2").Value = totalMacros
    ws.Range("B3").Value = selectedMacros
    ws.Range("B4").Value = Format(Now(), "yyyy-mm-dd hh:mm:ss")
    
    On Error GoTo 0
End Sub

' ============================================================================
' REFRESH ALL SHEETS
' ============================================================================

Sub RefreshAllSheets()
    'Refresh all data sheets
    
    Application.ScreenUpdating = False
    
    On Error GoTo ErrorHandler
    
    Call RefreshMacroLibrary
    Call UpdateAvailableMacros
    Call FormatAvailableMacrosSheet
    Call FormatSelectedMacrosSheet
    Call UpdateDashboard
    
    Application.ScreenUpdating = True
    MsgBox "All sheets refreshed successfully!", vbInformation
    
    Exit Sub
ErrorHandler:
    Application.ScreenUpdating = True
    MsgBox "Error refreshing sheets: " & Err.Description, vbCritical
End Sub

' ============================================================================
' GENERATE DRAWINGS - Main function called from Project_Config tab
' ============================================================================

Sub GenerateDrawings_Click()
    'Main function that handles the Generate Drawings button click
    'This function performs two main tasks:
    '1. Export selected macros to CSV file
    '2. Import CSV to AutoCAD and prompt for CAD file selection
    
    On Error GoTo ErrorHandler
    
    Dim projectName As String
    Dim csvPath As String
    Dim response As Integer
    
    ' Get project name from settings
    projectName = GetSettingValue("ProjectName")
    
    If projectName = "" Or projectName = "New Project" Then
        MsgBox "Please set a valid Project Name in Settings first!", vbExclamation
        Exit Sub
    End If
    
    ' Check if there are selected macros
    If wsSelectedMacros.Cells(2, 1).Value = "" Then
        MsgBox "No macros selected! Please select macros first.", vbExclamation
        Exit Sub
    End If
    
    ' Step 1: Export selected macros to CSV
    Call LogAction("GenerateDrawings", "INFO", "Starting Generate Drawings process")
    
    ' Export to project-specific CSV
    Call ExportFilteredMacrosToCSV
    
    ' Step 2: Import to AutoCAD
    csvPath = GetSettingValue("ExportPath") & "\Project_Macros_" & projectName & ".csv"
    
    If Dir(csvPath) <> "" Then
        ' Create AutoCAD import trigger
        Call SendToAutoCAD
        
        ' Prompt user to select CAD file
        response = MsgBox("Selected macros have been exported to CSV." & vbCrLf & vbCrLf & _
                         "Would you like to open a specific CAD file for drawing generation?", _
                         vbYesNo + vbQuestion, "Open CAD File")
        
        If response = vbYes Then
            Call PromptForCADFile
        End If
        
        Call LogAction("GenerateDrawings", "SUCCESS", "Process completed successfully")
        MsgBox "Generate Drawings process completed!" & vbCrLf & vbCrLf & _
               "✓ Selected macros exported to CSV" & vbCrLf & _
               "✓ AutoCAD notified for import" & vbCrLf & _
               "✓ Ready for drawing generation", vbInformation, "Process Complete"
    Else
        Call LogAction("GenerateDrawings", "ERROR", "CSV export failed")
        MsgBox "Error: CSV export failed. Cannot proceed with AutoCAD import.", vbCritical
    End If
    
    Exit Sub
    
ErrorHandler:
    Call LogAction("GenerateDrawings", "ERROR", "Error: " & Err.Description)
    MsgBox "Error in Generate Drawings process: " & Err.Description, vbCritical
End Sub

' ============================================================================
' PROMPT FOR CAD FILE
' ============================================================================

Sub PromptForCADFile()
    'Prompt user to select a CAD file and open it
    
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
        .Filters.Add "All Files", "*.*"
        
        If .Show = -1 Then
            cadFilePath = .SelectedItems(1)
            
            ' Create shell object to open the file
            Set shell = CreateObject("WScript.Shell")
            
            ' Open the CAD file with default application
            shell.Run """" & cadFilePath & """", 1, False
            
            Call LogAction("PromptForCADFile", "SUCCESS", "Opened CAD file: " & cadFilePath)
            
            MsgBox "CAD file opened: " & vbCrLf & cadFilePath & vbCrLf & vbCrLf & _
                   "You can now import the macros using the AutoCAD macro manager.", _
                   vbInformation, "CAD File Opened"
        Else
            Call LogAction("PromptForCADFile", "INFO", "User cancelled CAD file selection")
        End If
    End With
    
    Exit Sub
    
ErrorHandler:
    Call LogAction("PromptForCADFile", "ERROR", "Error: " & Err.Description)
    MsgBox "Error opening CAD file: " & Err.Description, vbExclamation
End Sub