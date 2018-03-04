# PSDT.App

[![Build status](https://ci.appveyor.com/api/projects/status/ey9k361d8x3038qo/branch/master?svg=true&passingText=Build%20Passing&failingText=Build%20Failing&pendingText=Build%20Pending)](https://ci.appveyor.com/project/codecraftteam/PSDT-App)

A collection of PowerShell scripts and modules, which increase .NET developers every day productivity.

Thinking in applications, when using PowerShell helps us to separate work into multiple PowerShell windows. The PSDT.App module is responsible to display the context of the currently used PSDT module to the user. The module can be used standalone, however it is intended to deliver lower level functions to other PSDT modules.

## Installation

The module can be installed through PowerShell Gallery or by downloading the sources.

```powershell
PS :\> Install-Package PSDT.App
```

## Features

- The PowerShell window title displays PSDT | PowerShell Developer Tools as soon as you import the module,
- Searching for
  - directories,
  - files,
  - any child item,
    by using multiple path segment filters.
- Tab completion for the above mentioned search cmdlets.

For more information check the cmdlets provided by the module, for example:

```powershell
Get-Command -Module PSDT.App

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Find-ChildItem                                     1.0.0.0    PSDT.App
Function        Get-Directory                                      1.0.0.0    PSDT.App
Function        Get-File                                           1.0.0.0    PSDT.App
Function        TabExpansion                                       1.0.0.0    PSDT.App
```

For more information on the cmdlets check the help, for example:

```powershell
Get-Help Find-ChildItem
```