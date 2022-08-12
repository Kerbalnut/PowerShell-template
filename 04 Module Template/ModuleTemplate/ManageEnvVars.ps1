<#
.SYNOPSIS
.DESCRIPTION
.NOTES
New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psd1" -ModuleVersion "1.0" -Author "Kerbalnut"
#>

#-----------------------------------------------------------------------------------------------------------------------
Function Get-EnvironmentVariable {
	<#
	.SYNOPSIS
	Returns the system's Environment variables: the Windows PATH var, or PowerShell Module paths.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.PARAMETER Raw
	Produces raw output, non-filtered non-sorted.
	.EXAMPLE
	Get-EnvironmentVariable
	.EXAMPLE
	Get-EnvironmentVariable -GetPathVar
	.EXAMPLE
	Get-EnvironmentVariable -GetModulePaths
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	.LINK
	https://www.tutorialspoint.com/how-to-get-environment-variable-value-using-powershell
	.LINK
	https://github.com/Kerbalnut/PowerShell-template
	#>
	[Alias("Get-EnvironmentVar","Get-EnvVar")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = 'None')]
	Param(
		[Parameter(ParameterSetName = "PathVar")]
		[Alias('PathVar','Path')]
		[switch]$GetPathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[Alias('GetPsModulePaths','GetPowershellModulePaths','PsModulePaths','PowershellModulePaths','ModulePaths')]
		[switch]$GetModulePaths,
		
		[Alias('r')]
		[switch]$Raw,
		
		[Alias('q','Silent','s')]
		[switch]$Quiet
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	#https://www.delftstack.com/howto/powershell/wait-for-each-command-to-finish-in-powershell/
	If ((Get-Command 'RefreshEnv.cmd') -Or (Get-Command 'RefreshEnv')) {
		Write-Verbose "Running RefreshEnv.cmd command to update env vars without restarting console."
		Try {
			If (!($Quiet)) {
				$Method = 1
			} Else {
				$Method = 0
			}
			switch ($Method) {
				0 {
					Write-Verbose "Running RefreshEnv.cmd with method $Method"
					RefreshEnv.cmd | Out-Null
				}
				1 {
					Write-Verbose "Running RefreshEnv.cmd with method $Method"
					Start-Process RefreshEnv.cmd -NoNewWindow -Wait
				}
				2 {
					Write-Verbose "Running RefreshEnv.cmd with method $Method"
					$proc = Start-Process RefreshEnv.cmd -NoNewWindow -PassThru
					$proc.WaitForExit()
				}
				Default {Throw "Please select a method (`$Method = `'$Method`') for getting PowerShell module paths."}
			} # End swtich ($Method)
		} Catch {
			Write-Warning "Failed to update environment variables with the RefreshEnv.cmd command. Consider restarting this console to update env vars."
		} # End Try/Catch RefreshEnv
		Start-Sleep -Milliseconds 150
		Write-Verbose "Finished updating env vars using RefreshEnv.cmd"
	} Else {
		Write-Verbose "No RefreshEnv.cmd command found. Install the package manager Chocolatey.org to get this command. Otherwise, you will have to restart the powershell console for updates to environment variables to take effect."
		Write-Debug "No RefreshEnv.cmd command found. Install the package manager Chocolatey.org to get this command. Otherwise, you will have to restart the powershell console for updates to environment variables to take effect."
	} # End If/Else (Get-Command RefreshEnv)
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	If ($GetPathVar) {
		Write-Verbose "Getting PATH variable."
		$Method = 0
		switch ($Method) {
			0 {
				Write-Verbose 'The "PowerShell" Method:'
				Write-Verbose "Environment variables in PowerShell are stored as PS drive (Env:_)."
				If ($Raw) {
					$PathVar = $env:Path
				} Else {
					$PathVar = $env:Path -split ';' | Sort-Object
				}
			}
			1 {
				Write-Verbose "The .NET Method (Windows only, PoSh v5.1 and below):"
				Write-Verbose "[System.Environment]::GetEnvironmentVariables() is a .NET method"
				If ($Raw) {
					$PathVar = [System.Environment]::GetEnvironmentVariable('Path')
				} Else {
					$PathVar = [System.Environment]::GetEnvironmentVariable('Path') -split ';' | Sort-Object
				}
			}
			Default {Throw "Please select a method (`$Method = `'$Method`') for getting PowerShell module paths."}
		}
		Return $PathVar
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	If ($GetModulePaths) {
		Write-Verbose "Getting PowerShell Module paths."
		$Method = 0
		switch ($Method) {
			0 {
				Write-Verbose 'The "PowerShell" Method:'
				Write-Verbose "Environment variables in PowerShell are stored as PS drive (Env: )."
				If ($Raw) {
					$ModulePaths = $env:PSModulePath
				} Else {
					$ModulePaths = $env:PSModulePath -split ';' | Sort-Object
				}
			}
			1 {
				Write-Verbose "The .NET Method (Windows only, PoSh v5.1 and below):"
				Write-Verbose "[System.Environment]::GetEnvironmentVariables() is a .NET method"
				If ($Raw) {
					$ModulePaths = [System.Environment]::GetEnvironmentVariable('PSModulePath')
				} Else {
					$ModulePaths = [System.Environment]::GetEnvironmentVariable('PSModulePath') -split ';' | Sort-Object
				}
			}
			Default {Throw "Please select a method (`$Method = `'$Method`') for getting PowerShell module paths."}
		}
		Return $ModulePaths
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Get all environment variables.
	Write-Verbose "Getting Environment Variables."
	$Method = 0
	switch ($Method) {
		0 {
			Write-Verbose 'The "PowerShell" Method:'
			Write-Verbose "Environment variables in PowerShell are stored as PS drive (Env: )."
			If ($Raw) {
				$EnvVars = Get-ChildItem -Path Env:
			} Else {
				$EnvVars = Get-ChildItem -Path Env: | Sort-Object -Property "Name"
			}
		}
		1 {
			Write-Verbose "The .NET Method (Windows only, PoSh v5.1 and below):"
			Write-Verbose "[System.Environment]::GetEnvironmentVariables() is a .NET method"
			If ($Raw) {
				$EnvVars = [System.Environment]::GetEnvironmentVariables().GetEnumerator()
			} Else {
				$EnvVars = [System.Environment]::GetEnvironmentVariables().GetEnumerator() | Sort-Object -Property "Name"
			}
		}
		Default {Throw "Please select a method (`$Method = `'$Method`') for getting Environment Variables."}
	}
	Return $EnvVars
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
} # End of Get-EnvironmentVariable function.
Set-Alias -Name 'Get-EnvironmentVar' -Value 'Get-EnvironmentVariable'
Set-Alias -Name 'Get-EnvVar' -Value 'Get-EnvironmentVariable'
Function Get-PathVar {
	<#
	.SYNOPSIS
	Alias: Get-EnvironmentVariable -GetPathVar
	.DESCRIPTION
	Alias: Get-EnvironmentVariable -GetPathVar
	.NOTES
	Alias: Get-EnvironmentVariable -GetPathVar
	Get-Help Get-EnvironmentVariable
	.LINK
	Get-EnvironmentVariable
	.LINK
	https://github.com/Kerbalnut/PowerShell-template
	#>
	[Alias("Get-PathEnvVar")]
	[CmdletBinding()]
	Param(
		[Alias('r')]
		[switch]$Raw,
		
		[Alias('q','Silent','s')]
		[switch]$Quiet
	)
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	$FuncParams = @{
		Raw = $Raw
		Quiet = $Quiet
	}
	#Get-EnvironmentVariable -GetPathVar @CommonParameters
	Get-EnvironmentVariable -GetPathVar @FuncParams @CommonParameters
}
Set-Alias -Name 'Get-PathEnvVar' -Value 'Get-PathVar'
Function Get-PowershellModulePaths {
	<#
	.SYNOPSIS
	Alias: Get-EnvironmentVariable -GetModulePaths
	.DESCRIPTION
	Alias: Get-EnvironmentVariable -GetModulePaths
	.NOTES
	Alias: Get-EnvironmentVariable -GetModulePaths
	Get-Help Get-EnvironmentVariable
	.LINK
	Get-EnvironmentVariable
	.LINK
	https://github.com/Kerbalnut/PowerShell-template
	#>
	[Alias('Get-PoshModulePaths','Get-PsModulePaths','Get-ModulePaths')]
	[CmdletBinding()]
	Param(
		[Alias('r')]
		[switch]$Raw,
		
		[Alias('q','Silent','s')]
		[switch]$Quiet
	)
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	$FuncParams = @{
		Raw = $Raw
		Quiet = $Quiet
	}
	#Get-EnvironmentVariable -GetModulePaths @CommonParameters
	Get-EnvironmentVariable -GetModulePaths @FuncParams @CommonParameters
}
Set-Alias -Name 'Get-PoshModulePaths' -Value 'Get-PowershellModulePaths'
Set-Alias -Name 'Get-PsModulePaths' -Value 'Get-PowershellModulePaths'
Set-Alias -Name 'Get-ModulePaths' -Value 'Get-PowershellModulePaths'
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
	
	Function New-TaskTrackingInitiative is where this template is based from.
	
	.PARAMETER WhatIf
	.PARAMETER Confirm
	.EXAMPLE
	New-TaskTrackingInitiativeTEST -WhatIf -Confirm
	#>
	[Alias("New-ProjectInitTEST")]
	#Requires -Version 3
	#[CmdletBinding()]
	[CmdletBinding(DefaultParameterSetName = 'None')]
	Param(
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "Path")]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p')]
		[String]$Path,
		
		[switch]$WhatIf,
		#[switch]$WhatIfPreference,
		#[System.Management.Automation.ActionPreference]$WhatIfPreference,
		
		#[System.Management.Automation.ActionPreference]
		
		[switch]$Confirm
		#$ConfirmPreference
		
		#[switch]$ConfirmPreference
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	Write-Host "Whatif: $WhatIfPreference"
	Write-Host "Confirm: $ConfirmPreference"
	function Sub-Function1 
	{}
	fUNCTION Sub-Function2 {
		fUnCtIoN Sub-Function3 {}
		fUnCtIoN Sub-Function4 
		{}
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of New-TaskTrackingInitiativeTEST function.
Set-Alias -Name 'New-ProjectInitTEST' -Value 'New-TaskTrackingInitiativeTEST'
#-----------------------------------------------------------------------------------------------------------------------











