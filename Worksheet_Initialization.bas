' ============================================================================
' WORKSHEET INITIALIZATION - ADD TO A NEW MODULE
' ============================================================================

Sub InitializeWorksheetReferences()
    'Set up global worksheet references for the VBA functions
    
    On Error GoTo ErrorHandler
    
    ' Set worksheet references (update these names to match your actual sheet names)
    Set wsMacroLibrary = ThisWorkbook.Sheets("Macro_Library")      ' or your actual name
    Set wsAvailableMacros = ThisWorkbook.Sheets("Available_Macros") ' or your actual name
    Set wsSelectedMacros = ThisWorkbook.Sheets("Selected_Macros")   ' or your actual name
    Set wsSettings = ThisWorkbook.Sheets("Settings")               ' or your actual name
    
    ' Optional: Set up other sheets if they exist
    ' Set wsProjectConfig = ThisWorkbook.Sheets("Project_Config")
    ' Set wsDashboard = ThisWorkbook.Sheets("Dashboard")
    ' Set wsLogs = ThisWorkbook.Sheets("Logs")
    
    MsgBox "Worksheet references initialized successfully!" & vbCrLf & vbCrLf & _
           "✓ Macro Library: " & wsMacroLibrary.Name & vbCrLf & _
           "✓ Available Macros: " & wsAvailableMacros.Name & vbCrLf & _
           "✓ Selected Macros: " & wsSelectedMacros.Name & vbCrLf & _
           "✓ Settings: " & wsSettings.Name, vbInformation, "Initialization Complete"
    
    Exit Sub
    
ErrorHandler:
    MsgBox "Error initializing worksheet references: " & Err.Description & vbCrLf & vbCrLf & _
           "Please check that your sheet names match:" & vbCrLf & _
           "• Macro_Library" & vbCrLf & _
           "• Available_Macros" & vbCrLf & _
           "• Selected_Macros" & vbCrLf & _
           "• Settings", vbCritical, "Initialization Error"
End Sub

' Quick test function to verify everything is working
Sub TestHeadersAndReferences()
    'Test that headers are set up correctly and references work
    
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
    
    ' Check Available Macros headers
    headerCheck = headerCheck & "Available Macros:" & vbCrLf
    headerCheck = headerCheck & "A1: " & wsAvailableMacros.Range("A1").Value & vbCrLf
    headerCheck = headerCheck & "B1: " & wsAvailableMacros.Range("B1").Value & vbCrLf
    headerCheck = headerCheck & "C1: " & wsAvailableMacros.Range("C1").Value & vbCrLf & vbCrLf
    
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