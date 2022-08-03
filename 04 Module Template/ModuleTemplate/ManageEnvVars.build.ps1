<#
.SYNOPSIS
Controller script for building ManageEnvVars (and ManageEnvVars_Admin) modules.
.DESCRIPTION
Requires -RunAsAdministrator because Get-ModuleCommandInfo function needs to load all files as modules to work, and this project contains modules that are Admin only.
.PARAMETER FileNames
List of module files to export for the module. These can be .ps1 files and they will still be exported as .psm1 files.
.PARAMETER BuildFuncsName
File name of the build functions .ps1 script to load, required for this controller script operation. Default is "BuildModule.ps1".
.PARAMETER ExceptionFileName
Optional .xml file name of exceptions file.
.PARAMETER Guid
To create a new GUID in PowerShell, type `[guid]::NewGuid()`.
.PARAMETER Description
Describes the contents of the module.
.LINK
https://www.leeholmes.com/cmdlets-vs-functions/
.NOTES
Cmdlets vs. Functions:
- It is currently much easier for ISVs and developers to package and deploy cmdlets than it is to package libraries of functions or scripts.
- It is currently easier to write and package help for cmdlets.
- Cmdlets are written in a compiled .NET language, while functions (and scripts) are written in the PowerShell language. On the plus side, this makes certain developer tasks (such as P/Invoke calls, working with generics) much easier in a cmdlet. On the minus side, this makes you pay the ‘compilation’ tax — making it slower to implement and evaluate new functionality.
- In V1,  Cmdlets provide the author a great deal of support for parameter validation, and tentative processing (-WhatIf, -Confirm.) This is an implementation artifact, though, and could go away in the future.
- [Various technical points] Functions support scoping, different naming guidelines, management through the function drive, etc. See your favourite scripting reference for these details.
#>
#Requires -RunAsAdministrator
[CmdletBinding()]
Param(
	[Parameter(Position = 0, 
	#Mandatory = $True, 
	ValueFromPipeline = $True, 
	ValueFromPipelineByPropertyName = $True)]
	[ValidateNotNullOrEmpty()]
	[Alias('ModuleNames','FilesToExport')]
	[String[]]$FileNames = $(@("ManageEnvVars.ps1","ManageEnvVars_Admin.ps1")),
	
	#[Parameter(Mandatory = $True)]
	[String]$BuildFuncsName = "BuildModule.ps1",
	
	[Parameter(Mandatory = $False)]
	[String]$ExceptionFileName = "Exceptions.xml",
	
	[String]$ModuleVersion = "0.1",
	
	[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True, 
	HelpMessage = "To create a new GUID in PowerShell, type `[guid]::NewGuid()`.")]
	[System.Guid]$Guid,
	
	[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True, 
	HelpMessage = "Describes the contents of the module.")]
	$Description = "",
	
	[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
	$ReleaseNotes,
	
	[String]$Author = "Kerbalnut",
	
	[String]$ProjectUri = "https://github.com/Kerbalnut/PowerShell-template",
	[String]$LicenseUri = "https://github.com/Kerbalnut/PowerShell-template/blob/master/LICENSE",
	[String]$IconUri,
	
	[System.Object[]]$RequiredModules,
	[System.String[]]$RequiredAssemblies,
	[System.Version]$PowerShellVersion,
	
	[ValidateSet('Desktop','Core')]
	[String[]]$CompatiblePSEditions = 'Desktop',
	
	[ValidateSet('None','MSIL','X86','IA64','Amd64','Arm')]
	[String[]]$ProcessorArchitecture = @('None','X86','IA64','Amd64')
	
)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$CommonParameters = @{
	Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
	Debug = [System.Management.Automation.ActionPreference]$DebugPreference
}
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$ScriptName = $MyInvocation.MyCommand.Name
Write-Host "Starting build script: `"$ScriptName`""
$HomePath = $PSScriptRoot
#$HomePath = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\"
Write-Verbose "Selected files: $FileNames"

#-----------------------------------------------------------------------------------------------------------------------

# Import build functions from BuildModule.ps1
If ($BuildFuncsName -match '.+\..+') {$HasFileExtension = $True} Else {$HasFileExtension = $False}
# RegEx: .+\..+
#    .+  The . matches any character, plus + modifier matches between one and unlimited times (Greedy)
#    \.  Matches the period . character literally. (Backslash \ is the escape character)
#    .+  The . matches any character, plus + modifier matches between one and unlimited times (Greedy)

If ($HasFileExtension) {
	$Method = 0
	switch ($Method) {
		0 {
			# .NET function
			$FileExtension = [System.IO.Path]::GetExtension($Path)
			
			# Regex remove any . in $FileExtension
			$FileExtension = $FileExtension -replace '^\.',''
		}
		1 {
			# Split-Path
			$FileExtension = ((Split-Path -Path $Path -Leaf).Split('.'))[1]
		}
		2 {
			# Get-ChildItemS
			$FileExtension = (Get-ChildItem -Path $Path).Extension
			
			# Regex remove any . in $FileExtension
			$FileExtension = $FileExtension -replace '^\.',''
		}
		Default {Throw "Horrible error: Get file extension wrong `$Method: '$Method'"}
	} # End switch
} # End If ($HasFileExtension)
$BuildFunctions = Join-Path -Path $HomePath -ChildPath $BuildFuncsName
If ((Test-Path -Path $BuildFunctions)) {
	Write-Verbose "Loading $BuildFuncsName . . . `"$BuildFunctions`""
	Try {
		. $BuildFunctions
	} Catch {
		Write-Error "'$BuildFuncsName' failed to load."
		Throw "'$BuildFuncsName' failed to load."
	}
} Else {
	Write-Error "'$BuildFuncsName' script with additional (required) build functions could not be found: `"$BuildFunctions`""
	Throw "'$BuildFuncsName' script with additional (required) build functions could not be found: `"$BuildFunctions`""
}
Write-Verbose "Loading $BuildFuncsName complete."

#-----------------------------------------------------------------------------------------------------------------------

#$ExceptionFileName = "Exceptions.xml"
$ExceptionFile = Join-Path -Path $HomePath -ChildPath $ExceptionFileName
If ($Exceptions) {Remove-Variable -Name Exceptions}

If ((Test-Path -Path $ExceptionFile)) {
	
	# Ask user to load exceptions file
	$Title = "Load $ExceptionFileName?"
	$Info = "Load the Exceptions file, modify it, or skip it?"
	# Use Ampersand & in front of letter to designate that as the choice key. E.g. "&Yes" for Y, "Y&Ellow" for E.
	$Load = New-Object System.Management.Automation.Host.ChoiceDescription "&Load", "Load all exception in $ExceptionFileName file"
	$Modify = New-Object System.Management.Automation.Host.ChoiceDescription "&Edit", "Modify $ExceptionFileName file"
	$Skip = New-Object System.Management.Automation.Host.ChoiceDescription "&Skip", "Skip loading the exceptions file, include all functions with no exceptions."
	$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Load, $Modify, $Skip)
	[int]$DefaultChoice = 0
	$Result = $Host.UI.PromptForChoice($Title, $Info, $Options, $DefaultChoice)
	switch ($Result) {
		0 {
			Write-Verbose "Loading Exceptions file"
			$Exceptions = Get-Content -Path $ExceptionFile
		}
		1 {
			Write-Verbose "Modify $ExceptionFileName"
			$Exceptions = Get-Content -Path $ExceptionFile
			$EditExceptions = $True
		}
		2 {
			Write-Verbose "Skipping $ExceptionFileName"
		}
	} # End switch ($Result)
	
} Else { # End If ((Test-Path -Path $ExceptionFile))
	
	Write-Verbose "No Exceptions file found."
	
	[String[]]$FileNames = $(@("ManageEnvVars.ps1","ManageEnvVars_Admin.ps1"))
	$HomePath = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\"
	
	ForEach ($file in $FileNames) {
		#$file = "ManageEnvVars.ps1"
		#$file = "ManageEnvVars_Admin.ps1"
		
		$FullPath = Join-Path -Path $HomePath -ChildPath $file
		$ModuleInfo = Get-ModuleCommandInfo -Path $FullPath -NoVerification -NoSubFunctions @CommonParameters
		$FunctionsList = Get-FunctionsInScript -ModuleCommandInfoObj $ModuleInfo @CommonParameters
		$AliasList = Get-AliasesInScript -ModuleCommandInfoObj $ModuleInfo @CommonParameters
		Write-Host "$($file):"
		$ModuleInfo | Format-Table | Out-Host
	}
	
	# Ask user to create exceptions file
	$Title = "Create $ExceptionFileName?"
	$Info = "An exceptions file is defined in parameters, but was not found. Create it?"
	# Use Ampersand & in front of letter to designate that as the choice key. E.g. "&Yes" for Y, "Y&Ellow" for E.
	$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Create & build the file: `"$ExceptionFile`""
	$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip defining any exceptions and automatically load all functions and aliases in: $FileNames"
	$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
	[int]$DefaultChoice = 0
	$Result = $Host.UI.PromptForChoice($Title, $Info, $Options, $DefaultChoice)
	switch ($Result) {
		0 {
			Write-Verbose "Creating Exceptions file"
			$Exceptions = Get-Content -Path $ExceptionFile
		}
		1 {
			Write-Verbose "Skipping exceptions, $ExceptionFileName will not be created."
		}
	} # End switch ($Result)
	
} # End If/Else ((Test-Path -Path $ExceptionFile))

#-----------------------------------------------------------------------------------------------------------------------

$FuncParams = @()
$FuncParams += [PSCustomObject]@{
	Module = $a
	ExceptionType = "Function"
	ExceptionName = "New-TaskTrackingInitiativeTEST"
}

$FuncParams += [PSCustomObject]@{
	Module = $a
	ExceptionType = "Alias"
	ExceptionName = "New-ProjectInitTEST"
}

#-----------------------------------------------------------------------------------------------------------------------

#[String[]]$FileNames = @("ManageEnvVars.ps1","ManageEnvVars_Admin.ps1")

ForEach ($file in $FileNames) {
	#$file = "ManageEnvVars.ps1"
	$FullPath = Join-Path -Path $HomePath -ChildPath $file
	#$FullPath = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	$ModuleInfo = Get-ModuleCommandInfo -Path $FullPath
	$FunctionsList = Get-FunctionsInScript -ModuleCommandInfoObj $ModuleInfo
	$AliasList = Get-AliasesInScript -ModuleCommandInfoObj $ModuleInfo
	$FileFunctionExceptions = @()
	$FileAliasExceptions = @()
	ForEach ($Exception in $Exceptions) {
		If ($Exception.Module -eq $file) {
			If ($Exception.ExceptionType -eq 'Function') {
				$FileFunctionExceptions += $Exception.ExceptionName
			} ElseIf ($Exception.ExceptionType -eq 'Alias') {
				$FileAliasExceptions += $Exception.ExceptionName
			} Else {
				Write-Warning "Wrong ExceptionType: $($Exception.ExceptionType)"
				Write-Error "Wrong ExceptionType: $($Exception.ExceptionType)"
			} # End If/ElseIf ($Exception.ExceptionType)
		} Else {
			Write-Verbose "Skipping $($Exception.Module) exception."
		} # End If ($Exception.Module -eq $file)
	} # End ForEach ($Exception in $Exceptions)
	
	Do {
		$i = 0
		$SelectionArray = @()
		ForEach ($Exception in $FileFunctionExceptions) {
			$i++
			$SelectionArray += [PSCustomObject]@{
				ID = $i
				Name = $Exception
				Exception = $Ex
			}
		} # End ForEach ($Exception in $FileFunctionExceptions)
		ForEach ($func in $FunctionsList) {
			$ExceptionStatus = $False
			ForEach ($Exception in $FileFunctionExceptions) {
				If ($Exception -eq $func) {
					$ExceptionStatus = $True
				}
			} # End ForEach ($Exception in $FileFunctionExceptions)
			$i++
			$SelectionArray += [PSCustomObject]@{
				ID = $i
				Name = $func
				Exception = $ExceptionStatus
			}
		} # End ForEach ($func in $FunctionsList)
		$i++
		$SelectionArray += [PSCustomObject]@{
			ID = $i
			Name = "<done/cancel>"
		}
		$SelectionArray | Format-Table
		$SelectedID = Read-Host -Prompt "Select ID"
		
	} Until ($SelectedID -ge 1 -And $SelectedID -le ($FunctionsList.Count + 1) )
	
}

Write-Verbose "Building variables hash table:"
$Method = 0
switch ($Method) {
	0 {
		$FuncParams = @{TempFileSuffix = $TempFileSuffix}
	}
	1 {
		$FuncParams = @{}
		If ($TempFileSuffix) {$FuncParams += @{TempFileSuffix = $TempFileSuffix}}
	}
	Default {Throw "Horrible error: Building vars hashtable, wrong `$Method selected: '$Method'"}
} # End switch


$FuncParams = @{
	TempFileSuffix = $TempFileSuffix
}

Write-Host "End of $ScriptName script."
# If running in the console, wait for input before closing.
if ($Host.Name -eq "ConsoleHost")
{
    Write-Host "Press any key to continue..."
    $Host.UI.RawUI.FlushInputBuffer()   # Make sure buffered input doesn't "press a key" and skip the ReadKey().
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}


Pause






# Ask user to continue if failure to backup
$Title = "Backup failed. Continue anyway?"
$Info = "Backing-up the $EnvVarName environment variable before changing it failed. Continue changing it anyway?"
# Use Ampersand & in front of letter to designate that as the choice key. E.g. "&Yes" for Y, "Y&Ellow" for E.
$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Proceed with setting $EnvVarName Env Var without backup. (Not Recommended)"
$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Halt operation. Inspect backup file location: `"$BackupFile`""
#$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Power", "&Shell", "&Quit")
$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
[int]$DefaultChoice = 1
$Result = $Host.UI.PromptForChoice($Title, $Info, $Options, $DefaultChoice)
switch ($Result) {
	0 {
		Write-Error "Backup of $EnvVarName var before change failed."
		Write-Verbose "User verified proceeding without backup."
	}
	1 {
		Write-Verbose "Halting operation."
		Write-Verbose "Please inspect backup file location for permissions: `n`"$BackupFile`""
		Split-Path -Path $BackupFile -Parent
	}
} # End switch ($Result)








Pause

<#

-Guid <System.Guid>
To create a new GUID in PowerShell, type `[guid]::NewGuid()`.

-ReleaseNotes

-Description  Describes the contents of the module.

-AliasesToExport
-Description
-ModuleList 
Lists all modules that are included in this module.

Enter each module name as a string or as a hash table with ModuleName and
ModuleVersion keys. The hash table can also have an optional GUID key. You can
combine strings and hash tables in the parameter value.

This key is designed to act as a module inventory. The modules that are listed in
the value of this key arent automatically processed.
-CmdletsToExport
-FunctionsToExport

-Guid
-ProjectUri
-LicenseUri
-IconUri

-RequiredModules <System.Object[]>
-RequiredAssemblies <System.String[]>

-PowerShellVersion <System.Version>
-PowerShellHostVersion <System.Version>
-CompatiblePSEditions {Desktop | Core}
-ProcessorArchitecture {None | MSIL | X86 | IA64 | Amd64 | Arm}

#>

New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psd1" -ModuleVersion $ModuleVersion -Author $Author


New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psd1" -ModuleVersion "1.0" -Author "Kerbalnut"

New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\Modules\ManageEnvVars\0.1\ManageEnvVars.psd1" -ModuleVersion "1.0" -Author "Kerbalnut" -FunctionsToExport '*' -AliasesToExport '*'



