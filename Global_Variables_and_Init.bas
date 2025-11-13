' ============================================================================
' GLOBAL VARIABLE DECLARATIONS - ADD THIS AT THE TOP OF MODULE1
' ============================================================================

Option Explicit

' Global worksheet references - MUST be declared at module level
Public wsMacroLibrary As Worksheet
Public wsProjectConfig As Worksheet
Public wsAvailableMacros As Worksheet
Public wsSelectedMacros As Worksheet
Public wsDashboard As Worksheet
Public wsLogs As Worksheet
Public wsSettings As Worksheet

' ============================================================================
' WORKSHEET INITIALIZATION
' ============================================================================

Sub InitializeWorksheetReferences()
    'Set up global worksheet references for the VBA functions
    
    On Error GoTo ErrorHandler
    
    ' IMPORTANT: Update these sheet names to match your actual Excel sheet names
    Set wsMacroLibrary = ThisWorkbook.Sheets("Macro Library")        ' UPDATE THIS NAME
    Set wsAvailableMacros = ThisWorkbook.Sheets("Available Macros")  ' UPDATE THIS NAME  
    Set wsSelectedMacros = ThisWorkbook.Sheets("Selected Macros")    ' UPDATE THIS NAME
    Set wsSettings = ThisWorkbook.Sheets("Settings")                 ' UPDATE THIS NAME
    
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
           "Please check that your sheet names match exactly:" & vbCrLf & _
           "• Macro Library" & vbCrLf & _
           "• Available Macros" & vbCrLf & _
           "• Selected Macros" & vbCrLf & _
           "• Settings" & vbCrLf & vbCrLf & _
           "Update the sheet names in the code if different.", vbCritical, "Initialization Error"
End Sub