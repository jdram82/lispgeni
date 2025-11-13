' ============================================================================
' MODULE: Settings_and_Logging
' PURPOSE: Application settings management and logging functionality
' VERSION: 1.0 - CORRECTED & TESTED
' ============================================================================

Option Explicit

' ============================================================================
' LOAD APPLICATION CONFIGURATION
' ============================================================================

Sub LoadAppConfiguration()
    'Load all configuration settings from Settings sheet
    
    On Error GoTo ErrorHandler
    
    ' Load saved settings from hidden column F
    Call LoadSettings
    
    ' Validate critical paths exist
    Call ValidateSettings
    
    Call LogAction("LoadAppConfiguration", "SUCCESS", "Configuration loaded")
    Exit Sub
    
ErrorHandler:
    Call LogAction("LoadAppConfiguration", "ERROR", "Error loading config: " & Err.Description)
End Sub

' ============================================================================
' GET SETTING VALUE
' ============================================================================

Function GetSettingValue(settingName As String) As String
    'Retrieve setting value by name from Settings sheet
    
    Dim wsSettings As Worksheet
    Dim settingValue As String
    
    On Error GoTo ErrorHandler
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    Select Case settingName
        Case "MacroLibraryPath"
            settingValue = wsSettings.Range("B2").Value
        Case "ProjectName"
            settingValue = wsSettings.Range("B4").Value
        Case "ExportPath"
            settingValue = wsSettings.Range("B6").Value
        Case "CSVFilesPath"
            settingValue = wsSettings.Range("B8").Value
        Case "LogsPath"
            settingValue = wsSettings.Range("B10").Value
        Case "BlockLibraryPath"
            settingValue = wsSettings.Range("B12").Value
        Case "AutoLaunchAutoCAD"
            settingValue = wsSettings.Range("B14").Value
        Case Else
            settingValue = ""
    End Select
    
    GetSettingValue = settingValue
    Exit Function
    
ErrorHandler:
    GetSettingValue = ""
End Function

' ============================================================================
' SET SETTING VALUE
' ============================================================================

Sub SetSettingValue(settingName As String, settingValue As String)
    'Set setting value by name in Settings sheet
    
    Dim wsSettings As Worksheet
    
    On Error GoTo ErrorHandler
    
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    Select Case settingName
        Case "MacroLibraryPath"
            wsSettings.Range("B2").Value = settingValue
        Case "ProjectName"
            wsSettings.Range("B4").Value = settingValue
        Case "ExportPath"
            wsSettings.Range("B6").Value = settingValue
        Case "CSVFilesPath"
            wsSettings.Range("B8").Value = settingValue
        Case "LogsPath"
            wsSettings.Range("B10").Value = settingValue
        Case "BlockLibraryPath"
            wsSettings.Range("B12").Value = settingValue
        Case "AutoLaunchAutoCAD"
            wsSettings.Range("B14").Value = settingValue
    End Select
    
    Call LogAction("SetSettingValue", "SUCCESS", settingName & " = " & settingValue)
    Exit Sub
    
ErrorHandler:
    Call LogAction("SetSettingValue", "ERROR", "Error setting " & settingName & ": " & Err.Description)
End Sub

' ============================================================================
' VALIDATE SETTINGS
' ============================================================================

Sub ValidateSettings()
    'Validate that critical settings are configured
    
    Dim errors As String
    Dim macroLibPath As String
    Dim exportPath As String
    
    On Error Resume Next
    
    macroLibPath = GetSettingValue("MacroLibraryPath")
    exportPath = GetSettingValue("ExportPath")
    
    ' Check critical paths
    If macroLibPath = "" Then
        errors = errors & "• Macro Library Path not set" & vbCrLf
    End If
    
    If exportPath = "" Then
        errors = errors & "• Export Path not set" & vbCrLf
    End If
    
    If errors <> "" Then
        Call LogAction("ValidateSettings", "WARNING", "Missing settings:" & vbCrLf & errors)
    Else
        Call LogAction("ValidateSettings", "SUCCESS", "All critical settings validated")
    End If
    
    On Error GoTo 0
End Sub

' ============================================================================
' LOG ACTION
' ============================================================================

Sub LogAction(action As String, status As String, details As String)
    'Log action to Logs sheet with timestamp
    
    Dim wsLogs As Worksheet
    Dim lastRow As Long
    Dim timestamp As String
    
    On Error Resume Next
    
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    lastRow = wsLogs.Cells(wsLogs.Rows.Count, 1).End(xlUp).row + 1
    timestamp = Format(Now(), "yyyy-mm-dd hh:mm:ss")
    
    ' Add log entry
    wsLogs.Cells(lastRow, 1).Value = timestamp
    wsLogs.Cells(lastRow, 2).Value = action
    wsLogs.Cells(lastRow, 3).Value = status
    wsLogs.Cells(lastRow, 4).Value = details
    
    ' Format based on status
    Select Case UCase(status)
        Case "ERROR"
            wsLogs.Rows(lastRow).Interior.Color = RGB(255, 200, 200)
        Case "WARNING"
            wsLogs.Rows(lastRow).Interior.Color = RGB(255, 255, 200)
        Case "SUCCESS"
            wsLogs.Rows(lastRow).Interior.Color = RGB(200, 255, 200)
        Case "INFO"
            wsLogs.Rows(lastRow).Interior.Color = RGB(240, 240, 240)
    End Select
    
    ' Auto-scroll to latest entry
    wsLogs.Cells(lastRow, 1).Select
    
    On Error GoTo 0
End Sub

' ============================================================================
' CLEAR LOGS
' ============================================================================

Sub ClearLogs()
    'Clear all log entries
    
    Dim wsLogs As Worksheet
    Dim response As Integer
    
    On Error GoTo ErrorHandler
    
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    
    response = MsgBox("Clear all log entries? This cannot be undone!", vbYesNo + vbQuestion, "Clear Logs")
    
    If response = vbYes Then
        ' Keep headers, clear data
        wsLogs.Range("2:" & wsLogs.Rows.Count).Delete
        
        ' Add headers if missing
        wsLogs.Range("A1").Value = "Timestamp"
        wsLogs.Range("B1").Value = "Action"
        wsLogs.Range("C1").Value = "Status"
        wsLogs.Range("D1").Value = "Details"
        
        ' Format headers
        With wsLogs.Range("1:1")
            .Font.Bold = True
            .Interior.Color = RGB(200, 200, 200)
        End With
        
        Call LogAction("ClearLogs", "SUCCESS", "All logs cleared by user")
        MsgBox "All logs cleared successfully!", vbInformation
    End If
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error clearing logs: " & Err.Description, vbCritical
End Sub

' ============================================================================
' EXPORT LOGS TO FILE
' ============================================================================

Sub ExportLogsToFile()
    'Export logs to text file
    
    Dim wsLogs As Worksheet
    Dim lastRow As Long
    Dim logPath As String
    Dim fso As Object
    Dim logFile As Object
    Dim i As Long
    Dim logLine As String
    
    On Error GoTo ErrorHandler
    
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    lastRow = wsLogs.Cells(wsLogs.Rows.Count, 1).End(xlUp).row
    
    If lastRow < 2 Then
        MsgBox "No logs to export!", vbExclamation
        Exit Sub
    End If
    
    ' Create log file path
    logPath = GetSettingValue("LogsPath") & "\Macro_Manager_Logs_" & Format(Now(), "yyyyMMdd_HHmmss") & ".txt"
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set logFile = fso.CreateTextFile(logPath, True)
    
    ' Write header
    logFile.WriteLine "Macro Manager - Log Export"
    logFile.WriteLine "Generated: " & Format(Now(), "yyyy-mm-dd hh:mm:ss")
    logFile.WriteLine String(50, "=")
    logFile.WriteLine ""
    
    ' Write log entries
    For i = 2 To lastRow
        logLine = wsLogs.Cells(i, 1).Value & " | " & _
                  wsLogs.Cells(i, 2).Value & " | " & _
                  wsLogs.Cells(i, 3).Value & " | " & _
                  wsLogs.Cells(i, 4).Value
        logFile.WriteLine logLine
    Next i
    
    logFile.Close
    Set logFile = Nothing
    Set fso = Nothing
    
    Call LogAction("ExportLogsToFile", "SUCCESS", "Logs exported to: " & logPath)
    MsgBox "Logs exported successfully to:" & vbCrLf & logPath, vbInformation
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error exporting logs: " & Err.Description, vbCritical
    Call LogAction("ExportLogsToFile", "ERROR", Err.Description)
End Sub

' ============================================================================
' FILTER LOGS BY STATUS
' ============================================================================

Sub FilterLogsByStatus(status As String)
    'Filter logs sheet by status column
    
    Dim wsLogs As Worksheet
    
    On Error GoTo ErrorHandler
    
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    
    ' Clear existing filters
    wsLogs.AutoFilterMode = False
    
    ' Apply autofilter
    wsLogs.Range("A1").AutoFilter
    
    If status <> "ALL" Then
        ' Filter by specific status
        wsLogs.Range("A1").AutoFilter Field:=3, Criteria1:=status
    End If
    
    Call LogAction("FilterLogsByStatus", "SUCCESS", "Filtered by: " & status)
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error filtering logs: " & Err.Description, vbCritical
End Sub

' ============================================================================
' GET LOG STATISTICS
' ============================================================================

Function GetLogStatistics() As String
    'Return formatted string with log statistics
    
    Dim wsLogs As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Dim errorCount As Long
    Dim warningCount As Long
    Dim successCount As Long
    Dim infoCount As Long
    Dim status As String
    Dim stats As String
    
    On Error GoTo ErrorHandler
    
    Set wsLogs = ThisWorkbook.Sheets("Logs")
    lastRow = wsLogs.Cells(wsLogs.Rows.Count, 1).End(xlUp).row
    
    ' Count by status
    For i = 2 To lastRow
        status = UCase(wsLogs.Cells(i, 3).Value)
        Select Case status
            Case "ERROR": errorCount = errorCount + 1
            Case "WARNING": warningCount = warningCount + 1
            Case "SUCCESS": successCount = successCount + 1
            Case "INFO": infoCount = infoCount + 1
        End Select
    Next i
    
    ' Format statistics
    stats = "Log Statistics:" & vbCrLf & _
            "Total Entries: " & (lastRow - 1) & vbCrLf & _
            "Errors: " & errorCount & vbCrLf & _
            "Warnings: " & warningCount & vbCrLf & _
            "Success: " & successCount & vbCrLf & _
            "Info: " & infoCount
    
    GetLogStatistics = stats
    Exit Function
    
ErrorHandler:
    GetLogStatistics = "Error calculating statistics: " & Err.Description
End Function