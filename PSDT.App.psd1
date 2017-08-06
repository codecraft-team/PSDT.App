@{
    RootModule = '.\PSDT.App.psm1'
    ModuleVersion = '1.0.0.0'
    GUID = '23256234-e648-4d9e-b2f8-799114ef9322'
    Author = 'Tauri-Code'
    CompanyName = 'Tauri-Code'
    Copyright = '(c) 2017 Tauri-Code. All rights reserved.'
    Description = 'A collection of PowerShell developer tool related basic cmdlets.'
    FunctionsToExport = @("Get-Directory","Get-File","Find-ChildItem","Clear-ChildItemCache","New-PSDTGuid")
    AliasesToExport = @("f","d","fci","newguid")
}
