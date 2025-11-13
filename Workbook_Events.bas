' ============================================================================
' WORKBOOK EVENT - AUTO SETUP HEADERS ON OPEN
' ============================================================================

' Add this to ThisWorkbook module

Private Sub Workbook_Open()
    'Automatically setup headers when workbook opens
    
    On Error Resume Next
    
    ' Check if headers already exist
    If wsMacroLibrary.Range("A1").Value = "" Then
        Call SetupMacroLibraryHeaders
    End If
    
    If wsAvailableMacros.Range("A1").Value = "" Then
        Call SetupAvailableMacrosHeaders
    End If
    
    If wsSelectedMacros.Range("A1").Value = "" Then
        Call SetupSelectedMacrosHeaders
    End If
    
    On Error GoTo 0
End Sub