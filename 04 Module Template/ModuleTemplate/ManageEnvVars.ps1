
#-----------------------------------------------------------------------------------------------------------------------
Function Get-EnvironmentVariable {
	<#
	.SYNOPSIS
	Returns the system's Environment variables, the Windows PATH var, or PowerShell Module paths.
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
	#>
	[Alias("Get-EnvironmentVar","Get-EnvVar","Get-PathVar","Get-PathEnvVar")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = 'None')]
	Param(
		[Parameter(ParameterSetName = "PathVar")]
		[switch]$GetPathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[Alias('GetPsModulePaths','GetPowershellModulePaths')]
		[switch]$GetModulePaths,
		
		[Alias('r')]
		[switch]$Raw
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	If ($GetPathVar) {
		Write-Verbose "Getting PATH variable."
		$Method = 0
		switch ($Method) {
			0 {
				Write-Verbose 'The "PowerShell" Method:'
				Write-Verbose "Environment variables in PowerShell are stored as PS drive (Env: )."
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
			Default {Throw "Please select a method for getting PowerShell module paths."}
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
			Default {Throw "Please select a method for getting PowerShell module paths."}
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
		Default {Throw "Please select a method for getting Environment Variables."}
	}
	Return $EnvVars
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
} # End of Get-EnvironmentVariable function.
Set-Alias -Name 'Get-EnvironmentVar' -Value 'Get-EnvironmentVariable'
Set-Alias -Name 'Get-EnvVar' -Value 'Get-EnvironmentVariable'
Set-Alias -Name 'Get-PathVar' -Value 'Get-EnvironmentVariable'
Set-Alias -Name 'Get-PathEnvVar' -Value 'Get-EnvironmentVariable'
Function Get-PowershellModulePaths {
	<#
	.SYNOPSIS
	Alias: Get-EnvironmentVariable -GetModulePaths
	.DESCRIPTION
	Get-EnvironmentVariable -GetModulePaths
	.NOTES
	Get-Help Get-EnvironmentVariable
	.LINK
	Get-EnvironmentVariable
	#>
	[CmdletBinding()]
	Param(
		[Alias('r')]
		[Switch]$Raw
	)
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	$FuncParams = @{
		Raw = $Raw
	}
	#Get-EnvironmentVariable -GetModulePaths @CommonParameters
	Get-EnvironmentVariable -GetModulePaths @FuncParams @CommonParameters
}
Set-Alias -Name 'Get-PoshModulePaths' -Value 'Get-PowershellModulePaths'
Set-Alias -Name 'Get-PsModulePaths' -Value 'Get-PowershellModulePaths'
#-----------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------------------------------
Function Set-EnvironmentVariable {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.PARAMETER Remove
	Surpresses warning prompts when removing Paths. Note, warnings will still be produced when there are only 2 paths left and you are trying to remove one. To surpress all warnings, see Force parameter.
	.PARAMETER Force
	Surpresses all warning prompts and safety checks.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	0
	Maybe some original author credits as well.
	#>
	[Alias("Set-EnvVar")]
	#Requires -Version 3
	[CmdletBinding()]
	Param(
		[Parameter(ParameterSetName = "PathVar")]
		[switch]$PathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[Alias('GetPsModulePaths','GetPowershellModulePaths')]
		[switch]$ModulePaths,
		
		[string]$BackupFile = ".\PATH_BACKUP.txt",
		
		[switch]$Remove,
		
		[switch]$Force
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -2
	
	Try {
		#$Env:PATH >> $BackupFile
		
		$Env:PATH >> $BackupFile
		
	} Catch {
		Write-Warning "Backup of PATH var before change failed."
		
		If (!($Force)) {
			Write-Error "Backup of PATH var before change failed."
			Throw "Backup of PATH var before change failed."
			
			# Ask user to continue if failure to backup
			$Title = "Welcome"
			$Info = "Just to Demo Promt for Choice"
			$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Power", "&Shell", "&Quit")
			[int]$defaultchoice = 2
			$opt = $host.UI.PromptForChoice($Title , $Info , $Options,$defaultchoice)
			switch ($opt) {
				0 { Write-Host "Power" -ForegroundColor Green}
				1 { Write-Host "Shell" -ForegroundColor Green}
				2 {Write-Host "Good Bye!!!" -ForegroundColor Green}
			}
		}
		
	}
	
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -2
	
	If ($PathVar) {
		
		$OriginalPath = Get-EnvironmentVariable -GetPathVar -Raw
		$OriginalPaths = ($OriginalPath -split ";").Count
		Write-Verbose "`$OriginalPath.Length = $($OriginalPath.Length) ; `$OriginalPaths(Count) = $OriginalPaths"
		
		$PathVar = $PathVar.Trim()
		$PathVars = ($PathVar -split ";").Count
		Write-Verbose "`$PathVar.Length = $($PathVar.Length) ; `$PathVars(Count) = $PathVars"
		
		If ($PathVar -notlike '*;*' -And !($Force)) {
			Write-Host "CAUTION: No ;" -ForegroundColor Red -BackgroundColor Black
			Write-Warning "No ; semicolon detected in new PATH variable value. This means you will be overwriting PATH with only one directory location. This is NOT recommened."
			Write-Error "No ; semicolon detected in new PATH variable value. This means you will be overwriting PATH with only one directory location. This is NOT recommened."
			Throw "No ; semicolon detected in new PATH variable value. This means you will be overwriting PATH with only one directory location. This is NOT recommened."
		}
		
		If ( ($PathVar.Lenth) -lt ($OriginalPath.Length) -And !($Remove) -And !($Force) ) {
			Write-Warning "New PATH is shorter than old PATH! Is this intentional? You will be removing data from the PATH variable. To avoid this warning in the future, use the -Remove parameter when removing data from PATH."
			Write-Error "New PATH is shorter than old PATH! Is this intentional? You will be removing data from the PATH variable. To avoid this warning in the future, use the -Remove parameter when removing data from PATH."
			Throw "New PATH is shorter than old PATH! Is this intentional? You will be removing data from the PATH variable. To avoid this warning in the future, use the -Remove parameter when removing data from PATH."
		}
		
		$PathVar
		
		
		
		[Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";C:\Program Files\Scripts", [EnvironmentVariableTarget]::Machine)
		
		
	}
	
	
	
	Return
} # End of Set-EnvironmentVariable function.
Set-Alias -Name 'Set-EnvVar' -Value 'Set-EnvironmentVariable'
#-----------------------------------------------------------------------------------------------------------------------




#-----------------------------------------------------------------------------------------------------------------------
Function Add-EnvironmentVariable {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	#>
	[Alias("Add-EnvVar")]
	#Requires -Version 3
	[CmdletBinding()]
	Param(
		[Parameter(ParameterSetName = "PathVar")]
		[String]$AddToPathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[String]$AddToModulePaths
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($AddToPathVar) {
		$PathVar = Get-EnvironmentVariable -GetPathVar
		$PathVar += $AddToPathVar
		$PathVar = $PathVar | Sort-Object
		
		
	}
	
	
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of Add-EnvironmentVariable function.
Set-Alias -Name 'Add-EnvVar' -Value 'Add-EnvironmentVariable'
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
	
	
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of New-TaskTrackingInitiativeTEST function.
Set-Alias -Name 'New-ProjectInitTEST' -Value 'New-TaskTrackingInitiativeTEST'
#-----------------------------------------------------------------------------------------------------------------------






