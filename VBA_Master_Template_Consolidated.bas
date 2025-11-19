' =============================================================================
' EXCEL VBA MASTER TEMPLATE - ALL MODULES CONSOLIDATED
' =============================================================================
' PROJECT: Excel-AutoCAD Block/Circuit Manager
' VERSION: 3.1 - Production Ready
' DATE: November 19, 2025
' =============================================================================
' INSTALLATION: Import this entire file OR import individual modules below
' =============================================================================

' =============================================================================
' MODULE 1: Global_Variables
' =============================================================================

Option Explicit

Public wsMacroLibrary As Worksheet
Public wsProjectConfig As Worksheet
Public wsSelectedMacros As Worksheet
Public wsDashboard As Worksheet
Public wsLogs As Worksheet
Public wsSettings As Worksheet

Sub InitializeWorksheetReferences()
    On Error GoTo ErrorHandler
    
    Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")
    Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    On Error Resume Next
    Set wsProjectConfig = ThisWorkbook.Sheets("Project_Config")
    Set wsDashboard = ThisWorkbook.Sheets("Dashboard")
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    On Error GoTo ErrorHandler
    
    MsgBox "✓ Worksheet references initialized successfully!" & vbCrLf & vbCrLf & _
           "✓ Macro Library: " & wsMacroLibrary.Name & vbCrLf & _
           "✓ Selected Macros: " & wsSelectedMacros.Name & vbCrLf & _
           "✓ Settings: " & wsSettings.Name, vbInformation, "Initialization Complete"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "ERROR initializing worksheet references: " & Err.Description & vbCrLf & vbCrLf & _
           "Check that your sheet names match exactly:" & vbCrLf & _
           "• Macro Library (with space)" & vbCrLf & _
           "• Selected Macros (with space)" & vbCrLf & _
           "• Settings", vbCritical, "Initialization Error"
End Sub

' =============================================================================
' MODULE 2: Add_Function (CSV Import/Export & AutoCAD Integration)
' =============================================================================

Sub ImportFromCSV_Click()
    Dim csvPath As String
    Dim macroCount As Long
    Dim defaultPath As String
    
    On Error GoTo ErrorHandler
    
    If wsMacroLibrary Is Nothing Then
        Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")
        Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")
        Set wsSettings = ThisWorkbook.Sheets("Settings")
    End If
    
    defaultPath = GetSettingValue("CSVFilesPath")
    If defaultPath <> "" Then
        On Error Resume Next
        If Dir(defaultPath, vbDirectory) <> "" Then
            ChDir defaultPath
        End If
        On Error GoTo ErrorHandler
    End If
    
    csvPath = BrowseForFile("csv")
    
    If csvPath <> "" Then
        wsMacroLibrary.Range("Z1").Value = csvPath
        Call SetupMacroLibraryHeaders
        Call ImportVerifiedCSVFormat(csvPath)
        
        macroCount = wsMacroLibrary.Cells(wsMacroLibrary.Rows.Count, 1).End(xlUp).row - 1
        Call LogAction("ImportFromCSV", "SUCCESS", "Imported " & macroCount & " macros from: " & csvPath)
        
        MsgBox "CSV imported successfully!" & vbCrLf & vbCrLf & _
               "📊 " & macroCount & " macros loaded to Macro Library", _
               vbInformation, "Import Complete"
    End If
    
    Exit Sub
ErrorHandler:
    MsgBox "Error importing CSV: " & Err.Description, vbCritical
    Call LogAction("ImportFromCSV", "ERROR", Err.Description)
End Sub

Sub ImportVerifiedCSVFormat(csvPath As String)
    Dim fso As Object
    Dim csvFile As Object
    Dim line As String
    Dim fields() As String
    Dim row As Long
    Dim serialNo As Long
    
    On Error GoTo ErrorHandler
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If Not fso.FileExists(csvPath) Then
        MsgBox "File not found: " & csvPath, vbCritical
        Exit Sub
    End If
    
    Set csvFile = fso.OpenTextFile(csvPath, 1)
    row = 2
    serialNo = 1
    
    If Not csvFile.AtEndOfStream Then
        line = csvFile.ReadLine
        If InStr(1, Trim(line), "Block Name", vbTextCompare) > 0 Or _
           InStr(1, Trim(line), "Sl.No", vbTextCompare) > 0 Then
        Else
            GoTo ProcessLine
        End If
    End If
    
    Do While Not csvFile.AtEndOfStream
        line = csvFile.ReadLine
        
ProcessLine:
        If line <> "" Then
            fields = ParseCSVLine(line)
            
            If UBound(fields) >= 6 Then
                wsMacroLibrary.Cells(row, 1).Value = serialNo
                wsMacroLibrary.Cells(row, 2).Value = Trim(fields(0))
                wsMacroLibrary.Cells(row, 3).Value = Trim(fields(1))
                wsMacroLibrary.Cells(row, 4).Value = Trim(fields(2))
                wsMacroLibrary.Cells(row, 5).Value = Trim(fields(3))
                wsMacroLibrary.Cells(row, 6).Value = Trim(fields(4))
                wsMacroLibrary.Cells(row, 7).Value = Trim(fields(5))
                wsMacroLibrary.Cells(row, 8).Value = Trim(fields(6))
                
                row = row + 1
                serialNo = serialNo + 1
            End If
        End If
        line = ""
    Loop
    
    csvFile.Close
    Call FormatMacroLibraryData
    
    Exit Sub
ErrorHandler:
    MsgBox "Error importing CSV data: " & Err.Description, vbCritical
    Call LogAction("ImportVerifiedCSVFormat", "ERROR", Err.Description)
End Sub

Sub GenerateDrawings_Click()
    On Error GoTo ErrorHandler
    
    If wsMacroLibrary Is Nothing Then
        Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")
        Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")
        Set wsSettings = ThisWorkbook.Sheets("Settings")
    End If
    
    Dim projectName As String
    Dim csvPath As String
    Dim selectedCount As Long
    
    projectName = GetSettingValue("ProjectName")
    
    If projectName = "" Or projectName = "New Project" Then
        MsgBox "Please set a valid Project Name in Settings first!", vbExclamation
        Exit Sub
    End If
    
    selectedCount = wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 1).End(xlUp).row - 1
    
    If selectedCount <= 0 Then
        MsgBox "No macros selected!", vbExclamation
        Exit Sub
    End If
    
    csvPath = GetSettingValue("ExportPath") & "\Project_Macros_" & projectName & ".csv"
    Call EnsurePathExists(GetSettingValue("ExportPath"))
    Call ExportSelectedMacrosToProjectCSV(csvPath)
    
    Call LogAction("GenerateDrawings", "SUCCESS", "Dual operation completed")
    
    MsgBox "✅ GENERATE DRAWINGS COMPLETED!" & vbCrLf & vbCrLf & _
           "📊 " & selectedCount & " macros exported" & vbCrLf & _
           "📄 CSV File: " & csvPath, vbInformation
    
    Exit Sub
    
ErrorHandler:
    MsgBox "❌ Error in Generate Drawings: " & Err.Description, vbCritical
    Call LogAction("GenerateDrawings", "ERROR", Err.Description)
End Sub

Sub ExportSelectedMacrosToProjectCSV(csvPath As String)
    Dim fso As Object
    Dim csvFile As Object
    Dim lastRow As Long
    Dim row As Long
    Dim csvLine As String
    
    On Error GoTo ErrorHandler
    
    lastRow = wsSelectedMacros.Cells(wsSelectedMacros.Rows.Count, 1).End(xlUp).row
    
    If lastRow <= 1 Then
        Exit Sub
    End If
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set csvFile = fso.CreateTextFile(csvPath, True)
    
    csvFile.WriteLine "Block Name,X Coordinate,Y Coordinate,Z Coordinate,Layer,Color,Linetype"
    
    For row = 2 To lastRow
        If Trim(wsSelectedMacros.Cells(row, 2).Value) <> "" Then
            csvLine = wsSelectedMacros.Cells(row, 2).Value & "," & _
                      wsSelectedMacros.Cells(row, 3).Value & "," & _
                      wsSelectedMacros.Cells(row, 4).Value & "," & _
                      wsSelectedMacros.Cells(row, 5).Value & "," & _
                      wsSelectedMacros.Cells(row, 6).Value & "," & _
                      wsSelectedMacros.Cells(row, 7).Value & "," & _
                      wsSelectedMacros.Cells(row, 8).Value
            
            csvFile.WriteLine csvLine
        End If
    Next row
    
    csvFile.Close
    Call LogAction("ExportSelectedMacrosToProjectCSV", "SUCCESS", "Exported to: " & csvPath)
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error exporting CSV: " & Err.Description, vbCritical
End Sub

Sub RefreshMacroLibrary_Click()
    Dim csvPath As String
    
    If wsMacroLibrary Is Nothing Then Call InitializeWorksheetReferences
    
    csvPath = wsMacroLibrary.Range("Z1").Value
    
    If csvPath <> "" And Dir(csvPath) <> "" Then
        Call SetupMacroLibraryHeaders
        Call ImportVerifiedCSVFormat(csvPath)
        MsgBox "Macro Library refreshed!", vbInformation
    Else
        MsgBox "Please import a CSV file first!", vbExclamation
    End If
End Sub

Sub ClearMacroLibrary_Click()
    Dim response As Integer
    
    If wsMacroLibrary Is Nothing Then Call InitializeWorksheetReferences
    
    response = MsgBox("Clear all macro library data?", vbYesNo + vbQuestion)
    
    If response = vbYes Then
        wsMacroLibrary.Cells.Clear
        wsSelectedMacros.Cells.Clear
        Call SetupMacroLibraryHeaders
        Call SetupSelectedMacrosHeaders
        MsgBox "All macro library data cleared!", vbInformation
    End If
End Sub

Sub SetupMacroLibraryHeaders()
    With wsMacroLibrary
        .Range("A1").Value = "Sl.No"
        .Range("B1").Value = "Block Name"
        .Range("C1").Value = "X Coordinate"
        .Range("D1").Value = "Y Coordinate"
        .Range("E1").Value = "Z Coordinate"
        .Range("F1").Value = "Layer"
        .Range("G1").Value = "Color"
        .Range("H1").Value = "Linetype"
        
        With .Range("A1:H1")
            .Font.Bold = True
            .Interior.Color = RGB(150, 150, 150)
            .Font.Color = RGB(255, 255, 255)
        End With
    End With
End Sub

Sub SetupSelectedMacrosHeaders()
    With wsSelectedMacros
        .Range("A1").Value = "Sl.No"
        .Range("B1").Value = "Block Name"
        .Range("C1").Value = "X Coordinate"
        .Range("D1").Value = "Y Coordinate"
        .Range("E1").Value = "Z Coordinate"
        .Range("F1").Value = "Layer"
        .Range("G1").Value = "Color"
        .Range("H1").Value = "Linetype"
        
        With .Range("A1:H1")
            .Font.Bold = True
            .Interior.Color = RGB(100, 200, 100)
            .Font.Color = RGB(255, 255, 255)
        End With
    End With
End Sub

Sub FormatMacroLibraryData()
    On Error Resume Next
    With wsMacroLibrary
        .Columns("C:E").NumberFormat = "0.00"
        .Columns.AutoFit
        .Range("A2").Select
        ActiveWindow.FreezePanes = True
    End With
End Sub

Sub EnsurePathExists(folderPath As String)
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(folderPath) Then
        fso.CreateFolder folderPath
    End If
End Sub

' =============================================================================
' MODULE 3: File_Operations (CSV Parsing & File Browsing)
' =============================================================================

Function ParseCSVLine(line As String) As String()
    Dim fields() As String
    Dim fieldCount As Integer
    Dim field As String
    Dim inQuotes As Boolean
    Dim i As Long
    Dim char As String
    
    ReDim fields(0)
    fieldCount = 0
    field = ""
    inQuotes = False
    
    For i = 1 To Len(line)
        char = Mid(line, i, 1)
        
        If char = """" Then
            inQuotes = Not inQuotes
        ElseIf char = "," And Not inQuotes Then
            ReDim Preserve fields(fieldCount)
            fields(fieldCount) = field
            field = ""
            fieldCount = fieldCount + 1
        Else
            field = field & char
        End If
    Next i
    
    ReDim Preserve fields(fieldCount)
    fields(fieldCount) = field
    
    ParseCSVLine = fields
End Function

Function BrowseForFile(Optional fileType As String = "csv") As String
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

' =============================================================================
' MODULE 4-6: Settings, Browse Buttons, and Logging (CONSOLIDATED)
' =============================================================================

Function GetSettingValue(settingName As String) As String
    Dim wsSettings As Worksheet
    
    On Error Resume Next
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    Select Case settingName
        Case "MacroLibraryPath": GetSettingValue = wsSettings.Range("B2").Value
        Case "ProjectName": GetSettingValue = wsSettings.Range("B4").Value
        Case "ExportPath": GetSettingValue = wsSettings.Range("B6").Value
        Case "CSVFilesPath": GetSettingValue = wsSettings.Range("B8").Value
        Case "LogsPath": GetSettingValue = wsSettings.Range("B10").Value
        Case "BlockLibraryPath": GetSettingValue = wsSettings.Range("B12").Value
        Case "AutoLaunchAutoCAD": GetSettingValue = wsSettings.Range("B14").Value
        Case Else: GetSettingValue = ""
    End Select
End Function

Sub LogAction(action As String, status As String, details As String)
    Dim wsLogs As Worksheet
    Dim lastRow As Long
    
    On Error Resume Next
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    lastRow = wsLogs.Cells(wsLogs.Rows.Count, 1).End(xlUp).row + 1
    
    wsLogs.Cells(lastRow, 1).Value = Format(Now(), "yyyy-mm-dd hh:mm:ss")
    wsLogs.Cells(lastRow, 2).Value = action
    wsLogs.Cells(lastRow, 3).Value = status
    wsLogs.Cells(lastRow, 4).Value = details
    
    Select Case UCase(status)
        Case "ERROR": wsLogs.Rows(lastRow).Interior.Color = RGB(255, 200, 200)
        Case "SUCCESS": wsLogs.Rows(lastRow).Interior.Color = RGB(200, 255, 200)
    End Select
End Sub

Sub BrowseMacroLibraryButton_Click()
    Dim shell As Object, folder As Object, wsSettings As Worksheet
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    Set folder = shell.BrowseForFolder(0, "Select Macro Library Folder:", 0, 0)
    If Not folder Is Nothing Then
        wsSettings.Range("B2").Value = folder.Self.Path
        Call LogAction("BrowseMacroLibrary", "SUCCESS", "Path: " & folder.Self.Path)
    End If
End Sub

Sub BrowseExportPathButton_Click()
    Dim shell As Object, folder As Object, wsSettings As Worksheet
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    Set folder = shell.BrowseForFolder(0, "Select Export Path:", 0, 0)
    If Not folder Is Nothing Then
        wsSettings.Range("B6").Value = folder.Self.Path
    End If
End Sub

Sub BrowseCSVFilesPathButton_Click()
    Dim shell As Object, folder As Object, wsSettings As Worksheet
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    Set folder = shell.BrowseForFolder(0, "Select CSV Files Path:", 0, 0)
    If Not folder Is Nothing Then
        wsSettings.Range("B8").Value = folder.Self.Path
    End If
End Sub

Sub BrowseLogsPathButton_Click()
    Dim shell As Object, folder As Object, wsSettings As Worksheet
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    Set folder = shell.BrowseForFolder(0, "Select Logs Path:", 0, 0)
    If Not folder Is Nothing Then
        wsSettings.Range("B10").Value = folder.Self.Path
    End If
End Sub

Sub BrowseBlockLibraryPathButton_Click()
    Dim shell As Object, folder As Object, wsSettings As Worksheet
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    Set folder = shell.BrowseForFolder(0, "Select Block Library Path:", 0, 0)
    If Not folder Is Nothing Then
        wsSettings.Range("B12").Value = folder.Self.Path
    End If
End Sub

Sub SaveSettings_Click()
    Dim wsSettings As Worksheet
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    wsSettings.Range("F2").Value = wsSettings.Range("B2").Value
    wsSettings.Range("F4").Value = wsSettings.Range("B4").Value
    wsSettings.Range("F6").Value = wsSettings.Range("B6").Value
    wsSettings.Range("F8").Value = wsSettings.Range("B8").Value
    wsSettings.Range("F10").Value = wsSettings.Range("B10").Value
    wsSettings.Range("F12").Value = wsSettings.Range("B12").Value
    wsSettings.Columns("F").Hidden = True
    MsgBox "All settings saved!", vbInformation
    ThisWorkbook.Save
End Sub

' =============================================================================
' MODULE 7: Testing_Functions
' =============================================================================

Sub Test5_CreateSampleData()
    If wsMacroLibrary Is Nothing Then Call InitializeWorksheetReferences
    
    wsMacroLibrary.Range("A2:H1000").Clear
    
    With wsMacroLibrary
        .Cells(2, 1).Value = 1
        .Cells(2, 2).Value = "PowerPanel_01"
        .Cells(2, 3).Value = 100.5
        .Cells(2, 4).Value = 200.3
        .Cells(2, 5).Value = 0
        .Cells(2, 6).Value = "POWER"
        .Cells(2, 7).Value = "256"
        .Cells(2, 8).Value = "ByLayer"
        
        .Cells(3, 1).Value = 2
        .Cells(3, 2).Value = "ControlRelay_02"
        .Cells(3, 3).Value = 150.7
        .Cells(3, 4).Value = 250.4
        .Cells(3, 5).Value = 0
        .Cells(3, 6).Value = "CONTROL"
        .Cells(3, 7).Value = "256"
        .Cells(3, 8).Value = "ByLayer"
    End With
    
    Call FormatMacroLibraryData
    MsgBox "Sample data created!", vbInformation
End Sub

' =============================================================================
' END OF CONSOLIDATED MASTER TEMPLATE
' =============================================================================
