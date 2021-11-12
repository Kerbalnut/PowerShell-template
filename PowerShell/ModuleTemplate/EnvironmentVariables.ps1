
Function Get-PsModulePaths {
	<#
	.SYNOPSIS
	Gets the paths that PowerShell auto-loads modules from.
	.DESCRIPTION
	PowerShell automatically loads modules within the environment variable $env:PSModulePath during console startup. This list is normally semicolon ; separated, like the PATH environment variable. This function gets these paths and separates it into a nice list or array.
	.NOTES
	.LINK
	$env:PSModulePath
	.LINK
	Get-Module
	.LINK
	Add-PsModulePath
	Remove-PsModulePathsd
	#>
	[CmdletBinding()]
	Param(
		[Alias('Array','a','o')]
		[Switch]$ObjArrayOutput
	)
	
	#$PSModulePaths = ( $env:PSModulePath ) -split ';'
	$PSModulePaths = ( [Environment]::GetEnvironmentVariable("PSModulePath") ) -split ';'
	
	If ($ObjArrayOutput) {
		$TestArray = @()
		ForEach ($path in $PSModulePaths) {
			If ((Test-Path -Path $path)) {
				$Item = [PSCustomObject]@{
					Path = $path
					Exists = $True
				}
			} Else {
				$Item = [PSCustomObject]@{
					Path = $path
					Exists = $False
				}
			}
			$TestArray += $Item
		}
		$PSModulePaths = $TestArray
	}
	
	#$PSModulePaths.GetType()
	Return $PSModulePaths
} # End of Get-PsModulePaths function.

Function Add-PsModulePath {
	<#
	.SYNOPSIS
	.DESCRIPTION
	.NOTES
	#>
	[CmdletBinding()]
	Param()
	
	
} # End of Add-PsModulePath function.

Function Remove-PsModulePaths {
	<#
	.SYNOPSIS
	.DESCRIPTION
	.NOTES
	#>
	[CmdletBinding()]
	Param()
	
	
} # End of Remove-PsModulePaths function.



