' ============================================================================
' WORKBOOK EVENT - AUTO SETUP HEADERS ON OPEN
' ============================================================================

' Add this to ThisWorkbook module

Private Sub Workbook_Open()
    'Automatically initialize and setup headers when workbook opens
    
    On Error Resume Next
    
    ' Initialize worksheet references first
    Call InitializeWorksheets
    
    ' Check if headers already exist in Macro Library
    If wsMacroLibrary.Range("A1").Value = "" Then
        Call SetupMacroLibraryHeaders
    End If
    
    ' Check if headers exist in Selected Macros
    If wsSelectedMacros.Range("A1").Value = "" Then
        Call SetupSelectedMacrosHeaders
    End If
    
    On Error GoTo 0
End Sub