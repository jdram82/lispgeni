' ============================================================================
' MODULE: Global_Variables
' PURPOSE: Global variable declarations and initialization
' VERSION: 3.0 - FORMULA-BASED WORKFLOW (AVAILABLE MACROS REMOVED)
' ============================================================================

Option Explicit

' Global worksheet references - MUST be declared at module level
Public wsMacroLibrary As Worksheet
Public wsProjectConfig As Worksheet
Public wsSelectedMacros As Worksheet
Public wsDashboard As Worksheet
Public wsLogs As Worksheet
Public wsSettings As Worksheet

' ============================================================================
' WORKSHEET INITIALIZATION - CALL THIS FIRST!
' ============================================================================

Sub InitializeWorksheetReferences()
    'Set up global worksheet references for the VBA functions
    'IMPORTANT: Call this Sub before running any other macros!
    
    On Error GoTo ErrorHandler
    
    ' Set worksheet references - WITH SPACES TO MATCH YOUR ACTUAL SHEET NAMES
    Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")      ' WITH SPACE
    Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")   ' WITH SPACE
    Set wsSettings = ThisWorkbook.Sheets("Settings")
    
    ' Optional: Set up other sheets if they exist
    On Error Resume Next
    Set wsProjectConfig = ThisWorkbook.Sheets("Project_Config01")
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
           "• Settings" & vbCrLf & vbCrLf & _
           "If your names are different, update them in this module.", vbCritical, "Initialization Error"
End Sub

' ============================================================================
' TEST FUNCTIONS
' ============================================================================

Sub TestHeadersAndReferences()
    'Test that headers are set up correctly and all references work
    
    On Error GoTo ErrorHandler
    
    ' Initialize references first
    Call InitializeWorksheetReferences
    
    ' Check headers in each sheet
    Dim headerCheck As String
    headerCheck = "Header Verification:" & vbCrLf & vbCrLf
    
    ' Check Macro Library headers
    headerCheck = headerCheck & "Macro Library:" & vbCrLf
    headerCheck = headerCheck & "A1: " & wsMacroLibrary.Range("A1").Value & vbCrLf
    headerCheck = headerCheck & "B1: " & wsMacroLibrary.Range("B1").Value & vbCrLf
    headerCheck = headerCheck & "C1: " & wsMacroLibrary.Range("C1").Value & vbCrLf & vbCrLf
    
    ' Check Selected Macros headers
    headerCheck = headerCheck & "Selected Macros:" & vbCrLf
    headerCheck = headerCheck & "A1: " & wsSelectedMacros.Range("A1").Value & vbCrLf
    headerCheck = headerCheck & "B1: " & wsSelectedMacros.Range("B1").Value & vbCrLf
    headerCheck = headerCheck & "C1: " & wsSelectedMacros.Range("C1").Value
    
    MsgBox headerCheck, vbInformation, "Header Verification"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error in test: " & Err.Description, vbCritical
End Sub
