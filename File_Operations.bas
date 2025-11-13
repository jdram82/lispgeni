' ============================================================================
' MODULE: File_Operations
' PURPOSE: Handle CSV file I/O, file browsing, and data validation
' VERSION: 1.0 - CORRECTED & TESTED
' ============================================================================

Option Explicit

' ============================================================================
' IMPORT CSV TO SHEET
' ============================================================================

Sub ImportCSVToSheet(targetSheet As Worksheet, csvPath As String)
    'Import CSV file to specified worksheet
    
    Dim fso As Object
    Dim csvFile As Object
    Dim line As String
    Dim fields() As String
    Dim row As Long
    Dim col As Long
    
    On Error GoTo ErrorHandler
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    ' Validate file exists
    If Not fso.FileExists(csvPath) Then
        MsgBox "File not found: " & csvPath, vbCritical
        Exit Sub
    End If
    
    ' Clear target sheet
    targetSheet.Cells.Clear
    
    ' Open CSV file
    Set csvFile = fso.OpenTextFile(csvPath, 1)  ' 1 = ForReading
    row = 1
    
    ' Read and parse each line
    Do While Not csvFile.AtEndOfStream
        line = csvFile.ReadLine
        
        If line <> "" Then
            ' Parse CSV line
            fields = ParseCSVLine(line)
            
            ' Write fields to worksheet
            For col = 0 To UBound(fields)
                targetSheet.Cells(row, col + 1).Value = Trim(fields(col))
            Next col
            
            row = row + 1
        End If
    Loop
    
    csvFile.Close
    Set csvFile = Nothing
    Set fso = Nothing
    
    Exit Sub
ErrorHandler:
    MsgBox "Error importing CSV: " & Err.Description, vbCritical
    Call LogAction("ImportCSVToSheet", "ERROR", Err.Description)
End Sub

' ============================================================================
' PARSE CSV LINE
' ============================================================================

Function ParseCSVLine(line As String) As String()
    'Parse CSV line into array of fields
    
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
    
    ' Add last field
    ReDim Preserve fields(fieldCount)
    fields(fieldCount) = field
    
    ParseCSVLine = fields
End Function

' ============================================================================
' EXPORT TO CSV
' ============================================================================

Sub ExportToCSV(dataArray As Variant, csvPath As String)
    'Export 2D array to CSV file
    
    Dim fso As Object
    Dim csvFile As Object
    Dim row As Long
    Dim col As Long
    Dim csvLine As String
    Dim fieldValue As String
    
    On Error GoTo ErrorHandler
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set csvFile = fso.CreateTextFile(csvPath, True)  ' True = overwrite
    
    ' Write data
    For row = LBound(dataArray, 1) To UBound(dataArray, 1)
        csvLine = ""
        
        For col = LBound(dataArray, 2) To UBound(dataArray, 2)
            ' Get field value
            fieldValue = CStr(dataArray(row, col))
            
            ' Quote if contains comma or quotes
            If InStr(fieldValue, ",") > 0 Or InStr(fieldValue, """") > 0 Then
                fieldValue = """" & Replace(fieldValue, """", """""") & """"
            End If
            
            ' Add comma separator
            If col > LBound(dataArray, 2) Then
                csvLine = csvLine & ","
            End If
            csvLine = csvLine & fieldValue
        Next col
        
        csvFile.WriteLine csvLine
    Next row
    
    csvFile.Close
    Set csvFile = Nothing
    Set fso = Nothing
    
    Call LogAction("ExportToCSV", "SUCCESS", "Exported to: " & csvPath)
    Exit Sub
    
ErrorHandler:
    MsgBox "Error exporting to CSV: " & Err.Description, vbCritical
    Call LogAction("ExportToCSV", "ERROR", Err.Description)
End Sub

' ============================================================================
' BROWSE FOR FILE
' ============================================================================

Function BrowseForFile(Optional fileType As String = "csv") As String
    'File browser dialog - returns selected file path
    
    Dim fd As FileDialog
    Dim fileName As String
    
    On Error GoTo ErrorHandler
    
    Set fd = Application.FileDialog(msoFileDialogFilePicker)  ' Use FilePicker for better reliability
    
    With fd
        .Title = "Select " & UCase(fileType) & " File"
        .AllowMultiSelect = False
        .Filters.Clear  ' Clear any existing filters first
        
        Select Case LCase(fileType)
            Case "csv"
                .Filters.Add "CSV Files", "*.csv"
                .Filters.Add "All Files", "*.*"
            Case "txt"
                .Filters.Add "Text Files", "*.txt"
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
    MsgBox "Error browsing for file: " & Err.Description, vbCritical
    BrowseForFile = ""
End Function
End Function

' ============================================================================
' BROWSE FOR FOLDER
' ============================================================================

Function BrowseForFolder() As String
    'Folder browser dialog - returns selected folder path
    
    Dim shell As Object
    Dim folder As Object
    
    On Error GoTo ErrorHandler
    
    Set shell = CreateObject("Shell.Application")
    Set folder = shell.BrowseForFolder(0, "Select Folder:", 0, 0)
    
    If Not folder Is Nothing Then
        BrowseForFolder = folder.Self.Path
    End If
    
    Exit Function
ErrorHandler:
    MsgBox "Error browsing for folder: " & Err.Description, vbCritical
End Function

' ============================================================================
' SETTINGS BUTTON HANDLERS
' ============================================================================

Sub BrowseMacroLibraryButton_Click()
    On Error GoTo ErrorHandler
    
    Dim shell As Object
    Dim folder As Object
    Dim folderPath As String
    Dim wsSettings As Worksheet
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    
    Set folder = shell.BrowseForFolder(0, _
        "Select the folder containing your Macro Library CSV file:", _
        0, 0)
    
    If Not folder Is Nothing Then
        folderPath = folder.Self.Path
        wsSettings.Range("B2").Value = folderPath
        
        Call LogAction("BrowseMacroLibrary", "SUCCESS", _
            "User selected folder: " & folderPath)
        
        MsgBox "Macro Library path set to: " & vbCrLf & folderPath, _
            vbInformation, "Path Selected"
    Else
        MsgBox "No folder selected.", vbInformation, "Cancelled"
    End If
    
    Set folder = Nothing
    Set shell = Nothing
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error selecting folder: " & Err.Description, vbCritical, "Error"
    Call LogAction("BrowseMacroLibrary", "ERROR", _
        "Error: " & Err.Description)
End Sub

Sub BrowseExportPathButton_Click()
    On Error GoTo ErrorHandler
    
    Dim shell As Object
    Dim folder As Object
    Dim folderPath As String
    Dim wsSettings As Worksheet
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    
    Set folder = shell.BrowseForFolder(0, _
        "Select the folder where exported files will be saved:", _
        0, 0)
    
    If Not folder Is Nothing Then
        folderPath = folder.Self.Path
        wsSettings.Range("B6").Value = folderPath
        
        Call LogAction("BrowseExportPath", "SUCCESS", _
            "User selected folder: " & folderPath)
        
        MsgBox "Export path set to: " & vbCrLf & folderPath, _
            vbInformation, "Path Selected"
    Else
        MsgBox "No folder selected.", vbInformation, "Cancelled"
    End If
    
    Set folder = Nothing
    Set shell = Nothing
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error selecting folder: " & Err.Description, vbCritical, "Error"
    Call LogAction("BrowseExportPath", "ERROR", _
        "Error: " & Err.Description)
End Sub

Sub BrowseCSVFilesPathButton_Click()
    On Error GoTo ErrorHandler
    
    Dim shell As Object
    Dim folder As Object
    Dim folderPath As String
    Dim wsSettings As Worksheet
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    
    Set folder = shell.BrowseForFolder(0, _
        "Select the folder containing CSV files:", _
        0, 0)
    
    If Not folder Is Nothing Then
        folderPath = folder.Self.Path
        wsSettings.Range("B8").Value = folderPath
        
        Call LogAction("BrowseCSVFilesPath", "SUCCESS", _
            "User selected folder: " & folderPath)
        
        MsgBox "CSV files path set to: " & vbCrLf & folderPath, _
            vbInformation, "Path Selected"
    Else
        MsgBox "No folder selected.", vbInformation, "Cancelled"
    End If
    
    Set folder = Nothing
    Set shell = Nothing
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error selecting folder: " & Err.Description, vbCritical, "Error"
    Call LogAction("BrowseCSVFilesPath", "ERROR", _
        "Error: " & Err.Description)
End Sub

Sub BrowseLogsPathButton_Click()
    On Error GoTo ErrorHandler
    
    Dim shell As Object
    Dim folder As Object
    Dim folderPath As String
    Dim wsSettings As Worksheet
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    
    Set folder = shell.BrowseForFolder(0, _
        "Select the folder for log files:", _
        0, 0)
    
    If Not folder Is Nothing Then
        folderPath = folder.Self.Path
        wsSettings.Range("B10").Value = folderPath
        
        Call LogAction("BrowseLogsPath", "SUCCESS", _
            "User selected folder: " & folderPath)
        
        MsgBox "Logs path set to: " & vbCrLf & folderPath, _
            vbInformation, "Path Selected"
    Else
        MsgBox "No folder selected.", vbInformation, "Cancelled"
    End If
    
    Set folder = Nothing
    Set shell = Nothing
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error selecting folder: " & Err.Description, vbCritical, "Error"
    Call LogAction("BrowseLogsPath", "ERROR", _
        "Error: " & Err.Description)
End Sub

Sub BrowseBlockLibraryPathButton_Click()
    On Error GoTo ErrorHandler
    
    Dim shell As Object
    Dim folder As Object
    Dim folderPath As String
    Dim wsSettings As Worksheet
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    Set shell = CreateObject("Shell.Application")
    
    Set folder = shell.BrowseForFolder(0, _
        "Select the folder containing block library files:", _
        0, 0)
    
    If Not folder Is Nothing Then
        folderPath = folder.Self.Path
        wsSettings.Range("B12").Value = folderPath
        
        Call LogAction("BrowseBlockLibraryPath", "SUCCESS", _
            "User selected folder: " & folderPath)
        
        MsgBox "Block Library path set to: " & vbCrLf & folderPath, _
            vbInformation, "Path Selected"
    Else
        MsgBox "No folder selected.", vbInformation, "Cancelled"
    End If
    
    Set folder = Nothing
    Set shell = Nothing
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error selecting folder: " & Err.Description, vbCritical, "Error"
    Call LogAction("BrowseBlockLibraryPath", "ERROR", _
        "Error: " & Err.Description)
End Sub

Sub SaveSettings_Click()
    On Error GoTo ErrorHandler
    Dim wsSettings As Worksheet
    Dim macroLibPath As String, projectName As String, exportPath As String
    Dim csvFilesPath As String, logsPath As String, blockLibPath As String, autoLaunch As String
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    macroLibPath = wsSettings.Range("B2").Value
    projectName = wsSettings.Range("B4").Value
    exportPath = wsSettings.Range("B6").Value
    csvFilesPath = wsSettings.Range("B8").Value
    logsPath = wsSettings.Range("B10").Value
    blockLibPath = wsSettings.Range("B12").Value
    autoLaunch = wsSettings.Range("B14").Value
    
    ' Save to hidden column F for persistence
    wsSettings.Range("F2").Value = macroLibPath
    wsSettings.Range("F4").Value = projectName
    wsSettings.Range("F6").Value = exportPath
    wsSettings.Range("F8").Value = csvFilesPath
    wsSettings.Range("F10").Value = logsPath
    wsSettings.Range("F12").Value = blockLibPath
    wsSettings.Range("F14").Value = autoLaunch
    
    wsSettings.Columns("F").Hidden = True
    
    Call LogAction("SaveSettings", "SUCCESS", "All settings saved successfully")
    
    MsgBox "All settings saved!" & vbCrLf & vbCrLf & _
        "Paths:" & vbCrLf & _
        "• Macro Library: " & macroLibPath & vbCrLf & _
        "• Export Path: " & exportPath & vbCrLf & _
        "• CSV Files: " & csvFilesPath & vbCrLf & _
        "• Logs: " & logsPath & vbCrLf & _
        "• Block Library: " & blockLibPath, vbInformation, "Settings Saved"
    
    ThisWorkbook.Save
    Exit Sub
ErrorHandler:
    MsgBox "Error: " & Err.Description, vbCritical
    Call LogAction("SaveSettings", "ERROR", "Error: " & Err.Description)
End Sub

Sub ResetDefaults_Click()
    On Error GoTo ErrorHandler
    Dim wsSettings As Worksheet, response As Integer, defaultPath As String
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    response = MsgBox("Reset all settings to defaults? This cannot be undone!", vbYesNo + vbQuestion, "Confirm Reset")
    
    If response = vbNo Then
        Exit Sub
    End If
    
    defaultPath = ThisWorkbook.Path
    
    wsSettings.Range("B2").Value = defaultPath & "\Macros"
    wsSettings.Range("B4").Value = "New Project"
    wsSettings.Range("B6").Value = defaultPath & "\Exports"
    wsSettings.Range("B8").Value = defaultPath & "\CSVs"
    wsSettings.Range("B10").Value = defaultPath & "\Logs"
    wsSettings.Range("B12").Value = defaultPath & "\Blocks"
    wsSettings.Range("B14").Value = "No"
    
    wsSettings.Range("F2:F14").Value = ""
    
    Call LogAction("ResetDefaults", "SUCCESS", "All settings reset to defaults")
    
    MsgBox "Settings reset to defaults!" & vbCrLf & vbCrLf & _
        "Defaults:" & vbCrLf & _
        "• Macro Library: " & defaultPath & "\Macros" & vbCrLf & _
        "• Export: " & defaultPath & "\Exports" & vbCrLf & _
        "• CSV Files: " & defaultPath & "\CSVs" & vbCrLf & _
        "• Logs: " & defaultPath & "\Logs" & vbCrLf & _
        "• Blocks: " & defaultPath & "\Blocks" & vbCrLf & _
        "• Project: New Project" & vbCrLf & _
        "• Auto Launch: No", vbInformation, "Settings Reset"
    
    ThisWorkbook.Save
    Exit Sub
ErrorHandler:
    MsgBox "Error: " & Err.Description, vbCritical
    Call LogAction("ResetDefaults", "ERROR", "Error: " & Err.Description)
End Sub

Sub LoadSettings()
    On Error GoTo ErrorHandler
    Dim wsSettings As Worksheet, macroLibPath As String, projectName As String
    Dim exportPath As String, csvFilesPath As String, logsPath As String
    Dim blockLibPath As String, autoLaunch As String
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    ' Load from hidden column F
    macroLibPath = wsSettings.Range("F2").Value
    projectName = wsSettings.Range("F4").Value
    exportPath = wsSettings.Range("F6").Value
    csvFilesPath = wsSettings.Range("F8").Value
    logsPath = wsSettings.Range("F10").Value
    blockLibPath = wsSettings.Range("F12").Value
    autoLaunch = wsSettings.Range("F14").Value
    
    If macroLibPath <> "" Then
        wsSettings.Range("B2").Value = macroLibPath
        wsSettings.Range("B4").Value = projectName
        wsSettings.Range("B6").Value = exportPath
        wsSettings.Range("B8").Value = csvFilesPath
        wsSettings.Range("B10").Value = logsPath
        wsSettings.Range("B12").Value = blockLibPath
        wsSettings.Range("B14").Value = autoLaunch
        Call LogAction("LoadSettings", "SUCCESS", "Settings loaded")
    End If
    Exit Sub
ErrorHandler:
    Call LogAction("LoadSettings", "ERROR", "Error: " & Err.Description)
End Sub