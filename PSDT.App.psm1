$host.ui.RawUI.WindowTitle = "PSDT | PowerShell Developer Tools";

if (Test-Path Function:\TabExpansion) {
	Rename-Item Function:\TabExpansion PreGetVSSolutionTabExpansion
}

Function global:TabExpansion($line, $lastWord) {
    $filter = ($line -split " " | Select-Object -Skip 1) -join ".*";
   
  switch -regex ($line) {
		"^(Get-VSSolution|gvss) .*" {
      Get-VSSolution $filter | Select-Object -ExpandProperty FullName
    }
		"^(Get-File|f) .*" {
      Get-File $filter | Select-Object -ExpandProperty FullName
    }
		"^(Get-Directory|d) .*" {
      Get-Directory $filter | Select-Object -ExpandProperty FullName
    }
		default {
			if (Test-Path Function:\PreGetVSSolutionTabExpansion) {
				PreGetVSSolutionTabExpansion $line $lastWord
			}
		}
	}
}

$global:PSDTChildItemCache = @{};
$global:PSDTChildItemCacheFiltered = @{};

<#
.Synopsis
    Clears the global cache used by the Find-ChildItem cmdlet.
    The cmdlet's default alias is: ccic

.DESCRIPTION
    The cmdlet is removing every item from the Find-ChildItem cmdlet's internal cache.
    The next execution of Find-ChildItem will rebuild the cache based on the current state of the provider. 
    
    This command helps you track constantly changing provider content. It is intended to replace the "restart PowerShell session" action.

    The following global variables are affected:
        $global:PSDTChildItemCache
        $global:PSDTChildItemCacheFiltered
#>
Function Clear-ChildItemCache {
    [CmdletBinding()]
    Param (

    )
    
    Write-Verbose "Clearing $($global:PSDTChildItemCache.Count) items from child items cache...";
    Write-Verbose "Clearing $($global:PSDTChildItemCacheFiltered.Count) items from filtered child items cache...";

    $global:PSDTChildItemCache = @{};
    $global:PSDTChildItemCacheFiltered = @{};   
}

Function Find-ChildItem {
  Param (
    [string]$Filter = "*.*",
    [switch]$File,
    [switch]$Directory
  )

  $fullNameFilter = $args -join ".*";
  $fullNameFilter = ".*{0}.*" -f $fullNameFilter;
  $itemCache = $global:PSDTChildItemCache;
  $itemCacheFilterd = $global:PSDTChildItemCacheFiltered;

  $key = "$((Get-Location).Path)-File:$File-Directory:$Directory-Filter:$Filter";
  $keyOfFilteredItems = "$key-$fullNameFilter";
  
  If(-not $itemCache.ContainsKey($key)) { 
      $searchProgressActivity = "Find child items...";
      
      Write-Progress -Activity $searchProgressActivity -Status $fullNameFilter;
      $childItems = (Get-ChildItem .\ -Recurse -Filter $Filter -File:$File -Directory:$Directory);
      Write-Progress -Activity $searchProgressActivity -Completed;
      
      $itemCache.Add($key, $childItems); 
  }

  If($args.Length -gt 0 -and [System.IO.Path]::IsPathRooted($args[$args.Length - 1])) {
      return Get-Item $args[$args.Length - 1];
  }
  
  If(-not $itemCacheFilterd.ContainsKey($keyOfFilteredItems)) {
      $filteredItems = $itemCache[$key] | Where-Object { ($_.FullName -match $fullNameFilter) };
      $itemCacheFilterd.Add($keyOfFilteredItems, $filteredItems);
  }

  return $itemCacheFilterd[$keyOfFilteredItems];
}

Set-Alias fci Find-ChildItem;

<#
.Synopsis
    Gets all files under the current path, which match the filter parameters.
    The cmdlet's default alias is: f
.DESCRIPTION
    The cmdlet is using an internal cache, which is stored in the script scope.
.EXAMPLE
    The example gets all files on the drive R, where the FullName matches the pattern *common*full*.sln*.
   
    PS R:\Get-File common full .sln
   
        Directory: R:\Source\cool-project\master\common\Sources\Builds\FullBuild

    Mode                LastWriteTime         Length Name                                                                                           
    ----                -------------         ------ ----                                                                                           
    -a----         1/9/2017   8:03 AM          21870 FullBuild.sln                                                                                  

.EXAMPLE
    The example shows all matching files using tab completion.

    Type the command below and press the TAB.
        
        PS R:\Get-File common full .sln

    Pressing the tab will replace the last word with the first matching file.
        
        PS R:\Get-File common full R:\Source\cool-project\master\common\Sources\Builds\FullBuild.sln

.EXAMPLE
    The example shows all matching files in a completion list.

    After typing the following line:
        
        PS R:\Get-File common f .sln

    Pressing the CTRL+SPACE will replace the last word with the first matching file's full name, and will list each other matches.
        
        PS R:\Get-File common R:\Source\cool-project\master\common\Sources\Builds\FullBuild.sln
        R:\Source\cool-project\master\common\Sources\Builds\FeedbackBuild.sln
        R:\Source\cool-project\master\common\Sources\Builds\FeatureBuild.sln

#>
Function Get-File {
  return Find-ChildItem -Filter "*.*" -File @args;
}

Set-Alias f Get-File;

<#
.Synopsis
    Gets all directories under the current path, which match the filter parameters.
    The cmdlet's default alias is: d
.DESCRIPTION
    The cmdlet is using an internal cache, which is stored in the script scope.
.EXAMPLE
    The example gets all directories on the drive R, where the FullName matches the pattern *common*full*.sln*.
   
    PS R:\Get-Directory common full
   
        Directory: R:\Source\cool-project\master\common\Sources\Builds

    Mode                LastWriteTime         Length Name                                                                                           
    ----                -------------         ------ ----                                                                                           
    d-----         1/9/2017   8:03 AM          21870 FullBuild                                                                                  

.EXAMPLE
    The example shows all matching directories using tab completion.

    Type the command below and press the TAB.
        
        PS R:\Get-Directory common full

    Pressing the tab will replace the last word with the first matching directory.
        
        PS R:\Get-Directory common full R:\Source\cool-project\master\common\Sources\Builds\FullBuild

.EXAMPLE
    The example shows all matching directories in a completion list.

    After typing the following line:
        
        PS R:\Get-Directory common f

    Pressing the CTRL+SPACE will replace the last word with the first matching directory's full name, and will list each other matches.
        
        PS R:\Get-Directory common R:\Source\cool-project\master\common\Sources\Builds\FullBuild
        R:\Source\cool-project\master\common\Sources\Features
        R:\Source\cool-project\master\common\Sources\Features\Feature1
        R:\Source\cool-project\master\common\Sources\Features\Feature1\Project1
        R:\Source\cool-project\master\common\Sources\Features\Feature2

#>
Function Get-Directory {
  return Find-ChildItem -Filter "*.*" -Directory @args;
}

Set-Alias d Get-Directory;

<#
.SYNOPSIS
    The cmdlets generates a new guid and writs it to the output and the clipboard.
    It is intended to shorten guid generation.

    The cmdlet has the newguid default alias.
#>
Function New-Guid {
    $guid = [System.Guid]::NewGuid().ToString();
    $guid | clip;
    return $guid;
}

Set-Alias newguid New-Guid;