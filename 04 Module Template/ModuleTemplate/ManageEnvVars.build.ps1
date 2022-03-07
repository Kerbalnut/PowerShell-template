<#
.SYNOPSIS
Build controller script for ManageEnvVars (and ManageEnvVars_Admin) modules.
.DESCRIPTION
.NOTES
#>
#Requires -RunAsAdministrator
[CmdletBinding()]
Param(
	[String]$BuildFuncsName = "BuildModule.ps1",
	
	$ExceptionFileName = "Exceptions.xml"
	
)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$CommonParameters = @{
	Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
	Debug = [System.Management.Automation.ActionPreference]$DebugPreference
}
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$ScriptName = $MyInvocation.MyCommand.Name
Write-Host "Starting build script: `"$ScriptName`""

$BuildFunctions = Join-Path -Path $PSScriptRoot -ChildPath $BuildFuncsName
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

$ExceptionFileName = "Exceptions.xml"
$ExceptionFile = Join-Path -Path $PSScriptRoot -ChildPath $ExceptionFileName



Write-Verbose "Building variables hash table:"
$Method = 0
switch ($Method) {
	0 {
		$FuncParams = @{
			TempFileSuffix = $TempFileSuffix
		}
	}
	1 {
		$FuncParams = @{}
		
		If ($TempFileSuffix) {
			$FuncParams += @{Test2 = $TempFileSuffix}
		}
	}
	Default {Throw "Horrible error: Building vars hashtable, wrong `$Method selected: '$Method'"}
} # End switch




Pause


