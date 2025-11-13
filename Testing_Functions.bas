' ============================================================================
' GLOBAL VARIABLE DECLARATIONS - MUST BE AT THE TOP
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
' WORKSHEET INITIALIZATION FUNCTION
' ============================================================================

Sub InitializeWorksheetReferences()
    'Set up global worksheet references for the VBA functions
    
    On Error GoTo ErrorHandler
    
    ' IMPORTANT: Updated with your actual Excel sheet names
    Set wsMacroLibrary = ThisWorkbook.Sheets("Macro_Library")        ' Your actual sheet name
    Set wsAvailableMacros = ThisWorkbook.Sheets("Available_Macros")  ' Your actual sheet name
    Set wsSelectedMacros = ThisWorkbook.Sheets("Selected_Macros")    ' Your actual sheet name
    Set wsSettings = ThisWorkbook.Sheets("Settings")                 ' Update if different
    
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
           "• Macro_Library" & vbCrLf & _
           "• Available_Macros" & vbCrLf & _
           "• Selected_Macros" & vbCrLf & _
           "• Settings" & vbCrLf & vbCrLf & _
           "Update the sheet names in the code if different.", vbCritical, "Initialization Error"
End Sub

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

' ============================================================================
' TESTING SEQUENCE - RUN THESE IN ORDER
' ============================================================================

Sub Test1_InitializeSystem()
    'Test 1: Initialize worksheet references
    Call InitializeWorksheetReferences
End Sub

Sub Test2_VerifyHeaders()
    'Test 2: Verify headers are correctly set
    Call TestHeadersAndReferences
End Sub

Sub Test3_TestCSVImport()
    'Test 3: Test CSV import functionality (will prompt for file)
    
    ' Make sure worksheet references are set
    If wsMacroLibrary Is Nothing Then
        Call InitializeWorksheetReferences
    End If
    
    MsgBox "This will test the CSV import function." & vbCrLf & vbCrLf & _
           "Make sure you have a test CSV file ready with format:" & vbCrLf & _
           "MacroID,MacroName,Category,X,Y,Path,Timestamp" & vbCrLf & vbCrLf & _
           "Example:" & vbCrLf & _
           "M001,TestMacro,Power,10.5,20.3,C:\test.dwg,2025-10-31", _
           vbInformation, "CSV Import Test"
    
    ' Test the import function
    Call ImportFromCSV_Click
End Sub

Sub Test4_TestDataFlow()
    'Test 4: Test the complete data flow from Library to Available to Selected
    
    If wsMacroLibrary Is Nothing Then
        Call InitializeWorksheetReferences
    End If
    
    ' Check if we have data in Macro Library
    Dim dataRows As Long
    dataRows = wsMacroLibrary.Cells(wsMacroLibrary.Rows.Count, 1).End(xlUp).Row - 1
    
    If dataRows <= 0 Then
        MsgBox "No data in Macro Library! Please run Test3_TestCSVImport first.", vbExclamation
        Exit Sub
    End If
    
    MsgBox "Found " & dataRows & " rows in Macro Library." & vbCrLf & vbCrLf & _
           "Testing data flow to Available Macros...", vbInformation
    
    ' Update Available Macros from Library
    Call UpdateAvailableMacrosFromLibrary
    
    ' Check Available Macros
    dataRows = wsAvailableMacros.Cells(wsAvailableMacros.Rows.Count, 1).End(xlUp).Row - 1
    MsgBox "Available Macros now has " & dataRows & " rows." & vbCrLf & vbCrLf & _
           "✓ Data flow test complete!", vbInformation
End Sub

Sub Test5_CreateSampleData()
    'Test 5: Create sample data for testing (if you don't have a CSV file)
    
    If wsMacroLibrary Is Nothing Then
        Call InitializeWorksheetReferences
    End If
    
    ' Clear existing data (keep headers)
    wsMacroLibrary.Range("A2:H1000").Clear
    
    ' Add sample data
    With wsMacroLibrary
        .Cells(2, 1).Value = 1
        .Cells(2, 2).Value = "M001"
        .Cells(2, 3).Value = "PowerPanel_01"
        .Cells(2, 4).Value = "Power"
        .Cells(2, 5).Value = 100.5
        .Cells(2, 6).Value = 200.3
        .Cells(2, 7).Value = "C:\MacroExports\PowerPanel_01.dwg"
        .Cells(2, 8).Value = Format(Now(), "yyyy-mm-dd hh:mm:ss")
        
        .Cells(3, 1).Value = 2
        .Cells(3, 2).Value = "M002"
        .Cells(3, 3).Value = "ControlRelay_02"
        .Cells(3, 4).Value = "Control"
        .Cells(3, 5).Value = 150.7
        .Cells(3, 6).Value = 250.4
        .Cells(3, 7).Value = "C:\MacroExports\ControlRelay_02.dwg"
        .Cells(3, 8).Value = Format(Now(), "yyyy-mm-dd hh:mm:ss")
        
        .Cells(4, 1).Value = 3
        .Cells(4, 2).Value = "M003"
        .Cells(4, 3).Value = "ProtectionDevice_03"
        .Cells(4, 4).Value = "Protection"
        .Cells(4, 5).Value = 75.2
        .Cells(4, 6).Value = 180.6
        .Cells(4, 7).Value = "C:\MacroExports\ProtectionDevice_03.dwg"
        .Cells(4, 8).Value = Format(Now(), "yyyy-mm-dd hh:mm:ss")
    End With
    
    ' Format the data
    Call FormatMacroLibraryData
    
    MsgBox "Sample data created in Macro Library!" & vbCrLf & vbCrLf & _
           "✓ 3 sample macros added" & vbCrLf & _
           "✓ Data formatted" & vbCrLf & vbCrLf & _
           "You can now test the Transfer functions.", vbInformation, "Sample Data Created"
End Sub