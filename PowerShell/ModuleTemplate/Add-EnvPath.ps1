
#-----------------------------------------------------------------------------------------------------------------------
Function Add-EnvPath { #------------------------------------------------------------------------------------------------
	<#
	.SYNOPSIS
	Adds a folder path to the environment variable PATH. So it becomes available for use on the command line.
	
	.DESCRIPTION
	
	
	.NOTES
	Problem Changing Environment Variable Values with PowerShell
	
	When you change the value of an environment variable using PowerShell commands, the changes only affect the current session. This   behavior mimics using the Set command of previous Windows operating systems.
	
	You can use PowerShell to make a persistent change, the technique involves making changes the registry values.
	
	Retrieving Path Info from the Registry
	
	The solution to the temporary nature of PowerShell’s changes to the environmental variable values is to script persistent registry modifications. This is the equivalent of making changes to the Advanced system settings in the Control Panel.
	
	.EXAMPLE
	$NewEnvPath = Add-EnvPath -Path "C:\Demo\path" -Verbose
	
	Saves the new PATH environment var into $NewEnvPath var.
	
	.LINK
	about_Comment_Based_Help
	about_Requires
	about_CommonParameters
	.LINK
	https://www.computerperformance.co.uk/powershell/env-path/
	#>
	#Requires -RunAsAdministrator
	[CmdletBinding()]
	Param (
		#Script parameters go here
		[Parameter(Mandatory=$True,Position=0,
		ValueFromPipeline=$True)]
		[string]$Path
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Get $env:PATH from registry for instant updates
	$RegistryPath = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
	$PathVar = (Get-ItemProperty -Path "$RegistryPath" -Name PATH).Path
	
	$PathArray = $PathVar.Split(";")
	
	# Check if path already exists
	ForEach ($RegPathLine in $PathArray) {
		If ($Path -eq $RegPathLine) {
			Write-Warning "`'$Path`' already exists in PATH."
			Return $PathVar
		}
	}
	
	Write-Verbose "Adding `'$Path`' to PATH:"
	$NewPath = $PathVar + ";" + $Path
	Set-ItemProperty -Path "$RegistryPath" -Name PATH -Value $NewPath
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return $NewPath
} # End Add-EnvPath function -------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

