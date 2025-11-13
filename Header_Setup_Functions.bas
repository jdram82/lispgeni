' ============================================================================
' HEADER SETUP FUNCTIONS - FOR EASY BUTTON IMPLEMENTATION
' ============================================================================

Sub SetupAllHeaders_Click()
    'Master function to setup headers on all three tabs
    
    On Error GoTo ErrorHandler
    
    Call SetupMacroLibraryHeaders
    Call SetupAvailableMacrosHeaders  
    Call SetupSelectedMacrosHeaders
    
    MsgBox "Headers added to all three tabs!" & vbCrLf & vbCrLf & _
           "✓ Macro Library tab" & vbCrLf & _
           "✓ Available Macros tab" & vbCrLf & _
           "✓ Selected Macros tab" & vbCrLf & vbCrLf & _
           "Ready to import CSV data!", vbInformation, "Headers Setup Complete"
    
    Call LogAction("SetupAllHeaders", "SUCCESS", "All headers configured")
    Exit Sub
    
ErrorHandler:
    MsgBox "Error setting up headers: " & Err.Description, vbCritical
    Call LogAction("SetupAllHeaders", "ERROR", Err.Description)
End Sub

' Individual header setup functions (already in your code)

Sub SetupMacroLibraryHeaders_Click()
    'Button function for Macro Library tab
    Call SetupMacroLibraryHeaders
    MsgBox "Macro Library headers added!", vbInformation
End Sub

Sub SetupAvailableMacrosHeaders_Click()
    'Button function for Available Macros tab
    Call SetupAvailableMacrosHeaders
    MsgBox "Available Macros headers added!", vbInformation
End Sub

Sub SetupSelectedMacrosHeaders_Click()
    'Button function for Selected Macros tab
    Call SetupSelectedMacrosHeaders
    MsgBox "Selected Macros headers added!", vbInformation
End Sub