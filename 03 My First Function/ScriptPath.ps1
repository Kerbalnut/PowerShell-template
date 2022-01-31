
$VerbosePreference = "Continue"

$CurrDir = pwd
$CurrDir = Get-Location

Write-Host "Current dir: `"$CurrDir`""

# Script name (including extension)
$ScriptName = $MyInvocation.MyCommand.Name
Write-Verbose "Script name: `"$ScriptName`""
Write-Verbose `r`n # New line (carriage return and newline (CRLF), `r`n)

# Script dir (home directory of script)
Write-Verbose "Script home directory:"
#https://stackoverflow.com/questions/801967/how-can-i-find-the-source-path-of-an-executing-script/6985381#6985381
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Write-Verbose "$ScriptDir"
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Definition # PoSh v2 compatible - thanks to https://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script
Write-Verbose "$ScriptDir"
$ScriptDir = $PSScriptRoot # PoSh v3 compatible - This is an automatic variable set to the current file's/module's directory
Write-Verbose "$ScriptDir"
Write-Verbose `r`n # New line (carriage return and newline (CRLF), `r`n)

# Script path (full file path & name & extension of currently running script)
$ScriptPath = $MyInvocation.MyCommand.Path
Write-Verbose "Script full path:"
Write-Verbose "$ScriptPath"
Write-Verbose `r`n # New line (carriage return and newline (CRLF), `r`n)

# Check if script is being Run as Administrator or not
$SessionIsAdminElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
Write-Verbose "Session is running as Admin: $SessionIsAdminElevated"
Write-Verbose `r`n # New line (carriage return and newline (CRLF), `r`n)


#-----------------------------------------------------------------------------------------------------------------------
Function New-TaskTrackingInitiativeTEST {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	#>
	[Alias("New-ProjectInitTEST")]
	#Requires -Version 3
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $True, Position = 0,
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True,
		           HelpMessage = "Path to ...")]
		[ValidateNotNullOrEmpty()]
		[String]$Path
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of New-TaskTrackingInitiativeTEST function.
Set-Alias -Name 'New-ProjectInitTEST' -Value 'New-TaskTrackingInitiativeTEST'
#-----------------------------------------------------------------------------------------------------------------------








#-----------------------------------------------------------------------------------------------------------------------
Function New-TaskTrackingInitiativeTEST {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	#>
	[Alias("New-ProjectInitTEST")]
	#Requires -Version 3
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $True, Position = 0,
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True,
		           HelpMessage = "Path to ...")]
		[ValidateNotNullOrEmpty()]
		[String]$Path
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of New-TaskTrackingInitiativeTEST function.
Set-Alias -Name 'New-ProjectInitTEST' -Value 'New-TaskTrackingInitiativeTEST'
#-----------------------------------------------------------------------------------------------------------------------






