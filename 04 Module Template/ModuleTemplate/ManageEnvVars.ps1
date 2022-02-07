
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
		Quiet =$Quiet
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
		Quiet =$Quiet
	}
	#Get-EnvironmentVariable -GetModulePaths @CommonParameters
	Get-EnvironmentVariable -GetModulePaths @FuncParams @CommonParameters
}
Set-Alias -Name 'Get-PoshModulePaths' -Value 'Get-PowershellModulePaths'
Set-Alias -Name 'Get-PsModulePaths' -Value 'Get-PowershellModulePaths'
Set-Alias -Name 'Get-ModulePaths' -Value 'Get-PowershellModulePaths'
#-----------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------------------------------------
Function Set-EnvironmentVariable {
	<#
	.SYNOPSIS
	Sets an environment variable, either PATH or the PowerShell Module paths. Required to be run as Administrator.
	.DESCRIPTION
	When given either a PathVar string or ModulePaths string, this function will overwrite either the PATH or PSModulePath environment variable respectively.
	.PARAMETER BackupFile
	This function will always attempt to backup the Environment Variable to a file location first before modifying it. 
	
	This can be either a full file path "C:\Users\Test\Desktop\Backup_file.txt" or filename "\Backup_file.txt". If using only a filename, the backup file will be created in the same working directory the Powershell function is executing from. 
	
	If a file already exists with same name, it will be renamed to file_old. If file_old already exists, it will be deleted.
	.PARAMETER Remove
	Surpresses warning prompts when removing Paths. Note, warnings will still be produced when there are only 2 paths left and you are trying to remove one. To surpress all warnings, see Force parameter.
	.PARAMETER Force
	Surpresses all warning prompts and safety checks.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	#>
	[Alias("Set-EnvVar")]
	#Requires -Version 3
	#Requires -RunAsAdministrator
	[CmdletBinding(DefaultParameterSetName = "PathVar")]
	Param(
		[Parameter(ParameterSetName = "PathVar")]
		[string]$PathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[Alias('GetPsModulePaths','GetPowershellModulePaths')]
		[string]$ModulePaths,
		
		[string]$BackupFile = ".\PATH_BACKUP.txt",
		
		[switch]$Remove,
		
		[Alias('q','Silent','s')]
		[switch]$Quiet,
		
		[switch]$Force
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Check if given BackupFile path is a filename, or full path.
	$PathPrefix = Split-Path -Path $BackupFile -Parent
	
	# Check if given $BackupFile string is a file
	$PartialPath = $False
	If ($PathPrefix -eq "." -Or $PathPrefix -eq "\" -Or $PathPrefix -eq "" -Or $null -eq $PathPrefix) {
		$PartialPath = $True
		Write-Verbose "Partial Path detected: $PartialPath"
	}
	
	If ($PartialPath) {
		# If BackupFile filename starts with a period . remove it: E.g. ".\Backup file name.log" to "\Backup file name.log"
		$BackupFile = $BackupFile -replace '^\.', ''
		# RegEx: ^\.
		#    ^   Asserts position at start of a line.
		#    \.  Matches the period . character literally. (Backslash \ is the escape character)
		
		# Get current execution path, in order to combine with given BackupFile filename to get a full file path.
		$ScriptPath = $MyInvocation.MyCommand.Path
		# If being run via F8 'Run Selection' method, then $MyInvocation.MyCommand.Definition will return entire script being executed, and will probably make Split-Path fail.
		#$ScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent # PoSh v2 compatible - thanks to https://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script
		$WorkingDirectory = Get-Location
		Write-Verbose "`$ScriptPath = $ScriptPath"
		#Write-Verbose "`$ScriptDir = $ScriptDir"
		Write-Verbose "`$WorkingDirectory = $WorkingDirectory"
		
		# Combine current execution path with given BackupFile filename to get a full file path:
		$BackupFile = Join-Path -Path $WorkingDirectory -ChildPath $BackupFile
	}
	
	# Get file extension:
	#https://www.tutorialspoint.com/how-to-get-the-file-extension-using-powershell
	$Method = 0
	switch ($Method) {
		0 {
			$FileExtension = [System.IO.Path]::GetExtension($BackupFile)
			# .txt
			# .zip
			Write-Verbose "Get file extension method $($Method): [System.IO.Path]::GetExtension(`$BackupFile)`n`t- `$FileExtension = `"$FileExtension`""
		}
		1 {
			$FileExtension = ((Split-Path $BackupFile -Leaf).Split('.'))[1]
			# txt
			# zip
			Write-Verbose "Get file extension method $($Method): ((Split-Path `$BackupFile -Leaf).Split('.'))[1]`n`t- `$FileExtension = `"$FileExtension`""
		}
		2 {
			$FileExtension = (Get-ChildItem $BackupFile).Extension
			# .txt
			# .zip
			Write-Verbose "Get file extension method $($Method): (Get-ChildItem `$BackupFile).Extension`n`t- `$FileExtension = `"$FileExtension`""
		}
		3 {
			$FileExtension = (Get-Item $BackupFile).Extension
			# .txt
			# .zip
			Write-Verbose "Get file extension method $($Method): (Get-Item `$BackupFile).Extension`n`t- `$FileExtension = `"$FileExtension`""
		}
		Default {Throw "Please select a method (`$Method = `'$Method`') for getting PowerShell path extension."}
	}
	Write-Verbose "`$FileExtension = `"$FileExtension`""
	
	# If given filename doesn't have an extension for some reason, assign one.
	If ($FileExtension -eq '' -Or $null -eq $FileExtension) {
		$FileExtension = ".txt"
		Write-Verbose "`$FileExtension = `"$FileExtension`" (none detected, defaulting to .txt)"
		$BackupFile = $BackupFile + $FileExtension
	}
	
	Write-Verbose "Before any file (backup) operations."
	# If BackupFile still exists, try to rename it to BackupFile_old or something:
	If ((Test-Path -Path $BackupFile)) {
		Write-Warning "`$BackupFile already exists: `"$BackupFile`""
		# Generate BackupFile_old filepath:
		If ($FileExtension -ne '' -And $null -ne $FileExtension) {
			# Remove file extension:
			$NoExtension = $BackupFile -replace '\.\w+$', ''
			# RegEx: \.\w+$
			#    \.  Matches the period . character literally. (Backslash \ is the escape character)
			#    \w+ Matches any word character (equivalent to [a-zA-Z0-9_]), and the plus + modifier matches between one and unlimited times (Greedy).
			#    $   Asserts position at the end of a line.
		}
		
		$NewName = $NoExtension + "_old" + $FileExtension
		
		Write-Verbose "Renaming existing file to: `"$NewName`""
		# Check if this BackupFile_old file already exists:
		If ((Test-Path -Path $NewName)) {
			Write-Warning "Old backup file already exists: `"$NewName`""
			Write-Warning "Removing old backup file before generating new one: `"$NewName`""
			Write-Debug "Removing old backup file before generating new one: `"$NewName`""
			Remove-Item -Path $NewName
			Start-Sleep -Milliseconds 150
		}
		Rename-Item -Path $BackupFile -NewName $NewName
		Start-Sleep -Milliseconds 150
	}
	#New-Item -Path $BackupFile -Value (Get-Date -Format "o")
	$NewItemResults = New-Item -Path $BackupFile
	Add-Content -Path $BackupFile -Value (Get-Date -Format "o")
	#Add-Content -Path $BackupFile -Value "`n"
	Add-Content -Path $BackupFile -Value (Get-Date)
	Add-Content -Path $BackupFile -Value "`n"
	
	Write-Verbose "Finished verifying `$BackupFile path: `"$BackupFile`""
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	If ($PathVar) {
		$EnvVarName = "PATH"
	} ElseIf ($ModulePaths) {
		$EnvVarName = "PSModulePath"
	}
	
	If ($PathVar) {
		$OriginalPath = Get-EnvironmentVariable -GetPathVar -Raw @CommonParameters
	} ElseIf ($ModulePaths) {
		$OriginalPath = Get-EnvironmentVariable -GetModulePaths -Raw @CommonParameters
	}
	
	If ($PathVar) {
		$EnvVarPath = $PathVar
	} ElseIf ($ModulePaths) {
		$EnvVarPath = $ModulePaths
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	Write-Verbose "Backing up current $EnvVarName environment variable to: `"$BackupFile`""
	Write-Debug "Backing up current $EnvVarName environment variable to: `"$BackupFile`""
	Try {
		<#If ($PathVar) {
			$Env:PATH | Out-file -FilePath $BackupFile -Append
		} ElseIf ($ModulePaths) {
			$Env:PSModulePath | Out-file -FilePath $BackupFile -Append
		}#>
		
		$OriginalPath | Out-file -FilePath $BackupFile -Append
	} Catch {
		Write-Warning "Backup of $EnvVarName var before change failed."
		If (!($Force)) {
			#Write-Error "Backup of $EnvVarName var before change failed."
			#Throw "Backup of $EnvVarName var before change failed."
			
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
		} # End If !($Force)
	} # End Try/Catch $BackupFile
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	$OriginalPaths = ($OriginalPath -split ";").Count
	Write-Verbose "`$OriginalPath.Length = $($OriginalPath.Length) ; `$OriginalPaths(Count) = $OriginalPaths"
	
	$EnvVarPath = $EnvVarPath.Trim()
	$EnvVarPaths = ($EnvVarPath -split ";").Count
	Write-Verbose "`$EnvVarPath.Length = $($EnvVarPath.Length) ; `$EnvVarPaths(Count) = $EnvVarPaths"
	
	If ($EnvVarPath -notlike '*;*') {
		Write-Host "CAUTION: No ;" -ForegroundColor Red -BackgroundColor Black
		Write-Warning "No ; semicolon detected in new $EnvVarName variable value. This means you will be overwriting $EnvVarName with only one directory location. This is NOT recommened.`n`tOriginal $($EnvVarName): $($OriginalPath.Length) length ; $OriginalPaths count`n`t`t- $OriginalPath`n`tNew $($EnvVarName): $($EnvVarPath.Length) length ; $EnvVarPaths count`n`t`t- $EnvVarPath"
		#Write-Warning "No ; semicolon detected in new $EnvVarName variable value. This means you will be overwriting $EnvVarName with only one directory location. This is NOT recommened."
		If (!($Force)) {
			Write-Error "No ; semicolon detected in new $EnvVarName variable value. This means you will be overwriting $EnvVarName with only one directory location. This is NOT recommened."
			Throw "No ; semicolon detected in new $EnvVarName variable value. This means you will be overwriting $EnvVarName with only one directory location. This is NOT recommened."
		}
	}
	
	If ( ($EnvVarPath.Length) -lt ($OriginalPath.Length) -And !($Remove) ) {
		Write-Warning "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future, use the -Remove parameter when removing data from $EnvVarName.`n`tOriginal $($EnvVarName): $($OriginalPath.Length) length ; $OriginalPaths count`n`t`t- $OriginalPath`n`tNew $($EnvVarName): $($EnvVarPath.Length) length ; $EnvVarPaths count`n`t`t- $EnvVarPath"
		#Write-Warning "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future, use the -Remove parameter when removing data from $EnvVarName."
		If (!($Force)) {
			Write-Error "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future,d use the -Remove parameter when removing data from $EnvVarName."
			Throw "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future, use the -Remove parameter when removing data from $EnvVarName."
		}
	}
	
	If ( ($EnvVarPath.Length) -lt ($OriginalPath.Length) -And !($Remove) ) {
		Write-Warning "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future, use the -Remove parameter when removing data from $EnvVarName.`n`tOriginal $($EnvVarName): $($OriginalPath.Length) length ; $OriginalPaths count`n`t`t- $OriginalPath`n`tNew $($EnvVarName): $($EnvVarPath.Length) length ; $EnvVarPaths count`n`t`t- $EnvVarPath"
		#Write-Warning "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future, use the -Remove parameter when removing data from $EnvVarName."
		If (!($Force)) {
			Write-Error "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future,d use the -Remove parameter when removing data from $EnvVarName."
			Throw "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future, use the -Remove parameter when removing data from $EnvVarName."
		}
	}
	
	If ( ($EnvVarPath.Length) -gt ($OriginalPath.Length) -And $Remove ) {
		Write-Warning "New $EnvVarName is longer than old $EnvVarName, and -Remove switch is enabled! Is this intentional? You will be ADDING data from the $EnvVarName variable.`n`tOriginal $($EnvVarName): $($OriginalPath.Length) length ; $OriginalPaths count`n`t`t- $OriginalPath`n`tNew $($EnvVarName): $($EnvVarPath.Length) length ; $EnvVarPaths count`n`t`t- $EnvVarPath"
		#Write-Warning "New $EnvVarName is longer than old $EnvVarName, and -Remove switch is enabled! Is this intentional? You will be ADDING data from the $EnvVarName variable.."
		If (!($Force)) {
			Write-Error "New $EnvVarName is longer than old $EnvVarName, and -Remove switch is enabled! Is this intentional? You will be ADDING data from the $EnvVarName variable."
			Throw "New $EnvVarName is longer than old $EnvVarName, and -Remove switch is enabled! Is this intentional? You will be ADDING data from the $EnvVarName variable."
		}
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	Write-Verbose "Setting Environment Var: $EnvVarName"
	Write-Debug "Setting Environment Var: $EnvVarName`n`tOriginal $($EnvVarName): $($OriginalPath.Length) characters ; $OriginalPaths items`n`t`t- $OriginalPath`n`tNew $($EnvVarName): $($EnvVarPath.Length) characters ; $EnvVarPaths items`n`t`t- $EnvVarPath"
	If ($PathVar) {
		[Environment]::SetEnvironmentVariable("PATH", $EnvVarPath, [EnvironmentVariableTarget]::Machine)
	} ElseIf ($ModulePaths) {
		[Environment]::SetEnvironmentVariable("PSModulePath", $EnvVarPath, [EnvironmentVariableTarget]::Machine)
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	#https://www.delftstack.com/howto/powershell/wait-for-each-command-to-finish-in-powershell/
	If ((Get-Command 'RefreshEnv.cmd') -Or (Get-Command 'RefreshEnv')) {
		Write-Verbose "Running RefreshEnv.cmd command to update env vars without restarting console."
		Start-Sleep -Milliseconds 150
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
			Write-Verbose "Finished updating env vars using RefreshEnv.cmd"
		} Catch {
			Write-Warning "Failed to update environment variables with the RefreshEnv.cmd command. Consider restarting this console to update env vars."
		} # End Try/Catch RefreshEnv
	} Else {
		Write-Warning "You must restart the console for updated environment variables to take effect in this session."
	} # End If/Else (Get-Command RefreshEnv)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	.PARAMETER Force
	Surpresses all warning prompts and safety checks. Function will still atttempt to create backup files, but will silently continue if that fails. Will automatically create duplicates.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	.EXAMPLE
	Add-EnvironmentVariable -AddToPath "C:\Foobar\Hello world.txt" -Verbose -Debug
	.EXAMPLE
	Add-EnvironmentVariable "C:\Foobar\Hello world.txt", "C:\Foobar\Hello world2.txt", "C:\Foobar\Hello world3.txt" -Verbose -Force
	#>
	[Alias("Add-EnvVar")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = "PathVar")]
	Param(
		[Parameter(ParameterSetName = "PathVar", Position = 0)]
		[Alias('AddPathVar','PathVar','PATH')]
		[String[]]$AddToPathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[Alias('AddToModulePath','AddToPSModulePath','AddModulePath','AddPSModulePath','AddPowershellModulePath','PSModulePaths','PSModulePath','ModulePaths','Module','PowerShell','PoSh')]
		[String[]]$AddToModulePaths,
		
		[string]$BackupFile = ".\PATH_BACKUP.txt",
		
		[Alias('q','Silent','s')]
		[switch]$Quiet,
		
		[switch]$Force
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$GetEnvVarParams = $CommonParameters
	$SetEnvVarParams = $CommonParameters
	If ($VerbosePreference -ne 'SilentlyContinue') {
		$GetEnvVarParams += @{Quiet = $True}
		$SetEnvVarParams += @{Quiet = $True}
	} ElseIf ($Quiet) {
		$GetEnvVarParams += @{Quiet = $Quiet}
		$SetEnvVarParams += @{Quiet = $Quiet}
	}
	If ($BackupFile) {
		$SetEnvVarParams += @{BackupFile = $BackupFile}
	}
	If ($Force) {
		$SetEnvVarParams += @{Force = $Force}
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($AddToPathVar) {
		$EnvVarName = "PATH"
	} ElseIf ($AddToModulePathss) {
		$EnvVarName = "PSModulePath"
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($AddToPathVar) {
		$PathVar = Get-EnvironmentVariable -GetPathVar @GetEnvVarParams
		Write-Verbose "$($AddToPathVar.Count) path(s) to add to $EnvVarName env var."
		$i = 0
		$NumPathsToAdd = 0
		ForEach ($PathToAdd in $AddToPathVar) {
			$i++
			# Check if path to add already exists in env var
			$AlreadyExists = $False
			$DuplicateString = ""
			ForEach ($Path in $PathVar) {
				If ($Path -eq $PathToAdd) {
					Write-Warning "#$($i) Path to add already exists in $EnvVarName environment var:`n`"$Path`""
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
							Write-Verbose "Finished updating env vars using RefreshEnv.cmd"
						} Catch {
							Write-Warning "Failed to update environment variables with the RefreshEnv.cmd command. Consider restarting this console to update env vars."
						} # End Try/Catch RefreshEnv
					} # End If (Get-Command RefreshEnv)
					#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.2#debugpreference
					If ($Force) {
						Write-Debug "Path to add already exists in $EnvVarName environment var: `"$Path`".`n Normally this function would not add this path when `$Debug switch is not used. Add duplicate path anyway?"
						Write-Verbose "-Force option enabled, automatically adding duplicate path: `"$Path`""
						$AlreadyExists = $False
						$DuplicateString = " (duplicate)"
					} ElseIf ($DebugPreference -ne 'SilentlyContinue') {
						# Ask user to continue adding duplicate path anyway if $Debug is enabled:
						$Title = "Add duplicate path to $EnvVarName var?"
						$Info = "Path to add already exists in $EnvVarName environment var:`n`"$Path`". Normally this function would not add this path when `$Debug switch is not used. Add duplicate path anyway?"
						Write-Host $Info
						# Use Ampersand & in front of letter to designate that as the choice key. E.g. "&Yes" for Y, "Y&Ellow" for E.
						$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Add `"$Path`" to $EnvVarName env var (Not Recommended)"
						$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Normal operation: Continue without adding this path."
						#$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Power", "&Shell", "&Quit")
						$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
						[int]$DefaultChoice = 1
						$Result = $Host.UI.PromptForChoice($Title, $Info, $Options, $DefaultChoice)
						switch ($Result) {
							0 {
								Write-Verbose "Option $Result chosen: Yes"
								$AlreadyExists = $False
								$DuplicateString = " (duplicate)"
							}
							1 {
								Write-Verbose "Option $Result chosen: No"
								$AlreadyExists = $True
							}
						} # End switch ($Result)
					} Else {
						$AlreadyExists = $True
					} # End If/Else ($Debug)
				} # End If ($Path -eq $AddToPathVar)
			} # End ForEach ($PathVar)
			# Finished checking if path already exists in $EnvVarName env var
			If (!($AlreadyExists)) {
				Write-Verbose "#$($i): Path to add: `"$PathToAdd`"$DuplicateString"
				$PathVar += $PathToAdd
				$NumPathsToAdd++
			} Else {
				Write-Verbose "#$($i): Already exists in $EnvVarName var: `"$PathToAdd`""
			}
		} # End ForEach ($AddToPathVar)
		
		If ($NumPathsToAdd -gt 0) {
			Write-Verbose "Adding $NumPathsToAdd path(s) to $EnvVarName var:"
			$SetEnvVar = $True
		} ElseIf ($Force) {
			Write-Verbose "(-Force parameter:) Adding $NumPathsToAdd path(s) to $EnvVarName var:"
			$SetEnvVar = $True
		} Else {
			Write-Warning "No paths were added to $EnvVarName environment var."
			$SetEnvVar = $False
		}
		If ($SetEnvVar) {
			$PathVar = ($PathVar | Sort-Object) -join ';'
			# Remove preceeding semicolon ; leftover by -join operation
			$PathVar = $PathVar -replace '^;', ''
			# RegEx: ^;
			#    ^   Asserts position at start of a line.
			#    ;   Matches the semicolon ; character literally.
			Set-EnvironmentVariable -PathVar $PathVar @SetEnvVarParams
		}
	} # End If ($AddToPathVar)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($AddToModulePaths) {
		$EnvVar = Get-EnvironmentVariable -GetModulePaths @GetEnvVarParams
		Write-Verbose "$($AddToModulePaths.Count) path(s) to add to $EnvVarName env var."
		$i = 0
		$NumPathsToAdd = 0
		ForEach ($PathToAdd in $AddToModulePaths) {
			$i++
			# Check if path to add already exists in env var
			$AlreadyExists = $False
			$DuplicateString = ""
			ForEach ($Path in $EnvVar) {
				If ($Path -eq $PathToAdd) {
					Write-Warning "#$($i) Path to add already exists in $EnvVarName environment var:`n`"$Path`""
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
							Write-Verbose "Finished updating env vars using RefreshEnv.cmd"
						} Catch {
							Write-Warning "Failed to update environment variables with the RefreshEnv.cmd command. Consider restarting this console to update env vars."
						} # End Try/Catch RefreshEnv
					} # End If (Get-Command RefreshEnv)
					#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.2#debugpreference
					If ($Force) {
						Write-Debug "Path to add already exists in $EnvVarName environment var: `"$Path`".`n Normally this function would not add this path when `$Debug switch is not used. Add duplicate path anyway?"
						Write-Verbose "-Force option enabled, automatically adding duplicate path: `"$Path`""
						$AlreadyExists = $False
						$DuplicateString = " (duplicate)"
					} ElseIf ($DebugPreference -ne 'SilentlyContinue') {
						# Ask user to continue adding duplicate path anyway if $Debug is enabled:
						$Title = "Add duplicate path to $EnvVarName var?"
						$Info = "Path to add already exists in $EnvVarName environment var:`n`"$Path`". Normally this function would not add this path when `$Debug switch is not used. Add duplicate path anyway?"
						Write-Host $Info
						# Use Ampersand & in front of letter to designate that as the choice key. E.g. "&Yes" for Y, "Y&Ellow" for E.
						$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Add `"$Path`" to $EnvVarName env var (Not Recommended)"
						$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Normal operation: Continue without adding this path."
						#$Options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Power", "&Shell", "&Quit")
						$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
						[int]$DefaultChoice = 1
						$Result = $Host.UI.PromptForChoice($Title, $Info, $Options, $DefaultChoice)
						switch ($Result) {
							0 {
								Write-Verbose "Option $Result chosen: Yes"
								$AlreadyExists = $False
								$DuplicateString = " (duplicate)"
							}
							1 {
								Write-Verbose "Option $Result chosen: No"
								$AlreadyExists = $True
							}
						} # End switch ($Result)
					} Else {
						$AlreadyExists = $True
					} # End If/Else ($Debug)
				} # End If ($Path -eq $AddToModulePaths)
			} # End ForEach ($EnvVar)
			
			# Finished checking if path already exists in $EnvVarName env var
			If (!($AlreadyExists)) {
				Write-Verbose "#$($i): Path to add: `"$PathToAdd`"$DuplicateString"
				$EnvVar += $PathToAdd
				$NumPathsToAdd++
			} Else {
				Write-Verbose "#$($i): Already exists in $EnvVarName var: `"$PathToAdd`""
			}
		} # End ForEach ($AddToModulePaths)
		
		If ($NumPathsToAdd -gt 0) {
			Write-Verbose "Adding $NumPathsToAdd path(s) to $EnvVarName var:"
			$SetEnvVar = $True
		} ElseIf ($Force) {
			Write-Verbose "(-Force parameter:) Adding $NumPathsToAdd path(s) to $EnvVarName var:"
			$SetEnvVar = $True
		} Else {
			Write-Warning "No paths were added to $EnvVarName environment var."
			$SetEnvVar = $False
		}
		If ($SetEnvVar) {
			$EnvVar = ($EnvVar | Sort-Object) -join ';'
			# Remove preceeding semicolon ; leftover by -join operation
			$EnvVar = $EnvVar -replace '^;', ''
			# RegEx: ^;
			#    ^   Asserts position at start of a line.
			#    ;   Matches the semicolon ; character literally.
			Set-EnvironmentVariable -ModulePaths $EnvVar @SetEnvVarParams
		}
	} # If ($AddToModulePaths)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	#https://www.delftstack.com/howto/powershell/wait-for-each-command-to-finish-in-powershell/
	Start-Sleep -Milliseconds 150
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
			Write-Verbose "Finished updating env vars using RefreshEnv.cmd"
		} Catch {
			Write-Warning "Failed to update environment variables with the RefreshEnv.cmd command. Consider restarting this console to update env vars."
		} # End Try/Catch RefreshEnv
	} Else {
		Write-Warning "You must restart the console for updated environment variables to take effect in this session."
	} # End If/Else (Get-Command RefreshEnv)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of Add-EnvironmentVariable function.
Set-Alias -Name 'Add-EnvVar' -Value 'Add-EnvironmentVariable'
Function Add-PowershellModulePath {
	<#
	.SYNOPSIS
	Alias: Add-EnvironmentVariable -AddToModulePaths "<path_to_add>"
	.DESCRIPTION
	Alias: Add-EnvironmentVariable -AddToModulePaths "<path_to_add>"
	.NOTES
	Alias: Add-EnvironmentVariable -AddToModulePaths "<path_to_add>"
	Get-Help Add-EnvironmentVariable
	.LINK
	Add-EnvironmentVariable
	#>
	[CmdletBinding()]
	Param(
		[Parameter(ParameterSetName = "ModulePaths", Position = 0)]
		[Alias('AddToModulePath','AddToPSModulePath','AddModulePath','AddPSModulePath','AddPowershellModulePath','PSModulePaths','PSModulePath','ModulePaths','Module','PowerShell','PoSh')]
		[String[]]$AddToModulePaths,
		[string]$BackupFile = ".\PATH_BACKUP.txt",
		[Alias('q','Silent','s')]
		[switch]$Quiet,
		[switch]$Force
	)
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	$FuncParams = @{
		BackupFile = $BackupFile
		Quiet = $Quiet
		Force = $Force
	}
	#Add-EnvironmentVariable -AddToModulePaths $AddToModulePaths @CommonParameters
	Add-EnvironmentVariable -AddToModulePaths $AddToModulePaths @CommonParameters @FuncParams
}
Set-Alias -Name 'Add-PoshModulePath' -Value 'Add-PowershellModulePath'
Set-Alias -Name 'Add-PsModulePath' -Value 'Add-PowershellModulePath'
#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
Function Remove-EnvironmentVariable {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	.EXAMPLE
	Remove-EnvironmentVariable -RemoveFromPathVar "C:\Foobar\Hello world.txt" -Verbose -Debug
	.EXAMPLE
	Remove-EnvironmentVariable "C:\Foobar\Hello world.txt", "C:\Foobar\Hello world2.txt", "C:\Foobar\Hello world3.txt" -Verbose -Force
	#>
	[Alias("Remove-EnvVar")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = "PathVar")]
	Param(
		[Parameter(ParameterSetName = "PathVar", Position = 0)]
		[Alias('RemovePathVar','RemovePath','PathVar','PATH')]
		[String[]]$RemoveFromPathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[Alias('RemoveFromPSModulePath','RemovePSModulePath','RemovePSModulePaths','RemoveModulePath','PSModulePaths','PSModulePath','ModulePaths','Module','PowerShell','PoSh')]
		[String[]]$RemoveFromModulePaths,
		
		[string]$BackupFile = ".\PATH_BACKUP.txt",
		
		[Alias('q','Silent','s')]
		[switch]$Quiet,
		
		[switch]$Force
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$GetEnvVarParams = $CommonParameters
	$SetEnvVarParams = $CommonParameters
	If ($VerbosePreference -ne 'SilentlyContinue') {
		$GetEnvVarParams += @{Quiet = $True}
		$SetEnvVarParams += @{Quiet = $True}
	} ElseIf ($Quiet) {
		$GetEnvVarParams += @{Quiet = $Quiet}
		$SetEnvVarParams += @{Quiet = $Quiet}
	}
	If ($BackupFile) {
		$SetEnvVarParams += @{BackupFile = $BackupFile}
	}
	If ($Force) {
		$SetEnvVarParams += @{Force = $Force}
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($RemoveFromPathVar) {
		$EnvVarName = "PATH"
	} ElseIf ($RemoveFromModulePaths) {
		$EnvVarName = "PSModulePath"
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($RemoveFromPathVar) {
		$PathVar = Get-EnvironmentVariable -GetPathVar @GetEnvVarParams
		$CountPathsToRemove = $RemoveFromPathVar.Count
		Write-Verbose "$($RemoveFromPathVar.Count) path(s) to remove from $EnvVarName env var."
		$NumPathsToRemove = 0
		$NewEnvVar = @()
		$j = 0
		ForEach ($PathToRemove in $RemoveFromPathVar) {
			$j++
			# Check if there are duplicate paths to remove:
			$i = 0
			$PathRemoved = $False
			ForEach ($Path in $PathVar) {
				If ($Path -eq $PathToRemove) {
					$i++
					$PathRemoved = $True
					If ($i -gt 1) {
						Write-Warning "$i duplicate paths removed from $EnvVarName env var:`n`"$Path`""
					} Else {
						Write-Verbose "Removing `$Path from list: `"$Path`""
						$NumPathsToRemove++
					}
				} Else {
					Write-Verbose "$($j): path not to be removed: `"$Path`""
					$NewEnvVar += $Path
				}
			} # End ForEach ($Path in $PathVar)
			If ($i -eq $CountPathsToRemove -And !($PathRemoved)) {
				Write-Warning "Path #$($j): $i/$($CountPathsToRemove): Path not found in $EnvVarName var: `"$PathToRemove`""
			}
		} # End ForEach ($PathToRemove in $RemoveFromPathVar)
		
		$PathVar = $NewEnvVar
		If ($NumPathsToRemove -gt 0) {
			Write-Verbose "Removing $NumPathsToRemove path(s) from $EnvVarName var:"
			$SetEnvVar = $True
		} ElseIf ($Force) {
			Write-Verbose "(-Force parameter:) Removing $NumPathsToRemove path(s) from $EnvVarName var:"
			$SetEnvVar = $True
		} Else {
			Write-Warning "No paths were removed from $EnvVarName environment var."
			$SetEnvVar = $False
		}
		If ($SetEnvVar) {
			$PathVar = ($PathVar | Sort-Object) -join ';'
			# Remove preceeding semicolon ; leftover by -join operation
			$PathVar = $PathVar -replace '^;', ''
			# RegEx: ^;
			#    ^   Asserts position at start of a line.
			#    ;   Matches the semicolon ; character literally.
			Set-EnvironmentVariable -Remove -PathVar $PathVar @SetEnvVarParams
		}
	} # End If ($RemoveFromPathVar)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($RemoveFromModulePaths) {
		$EnvVar = Get-EnvironmentVariable -GetModulePaths @GetEnvVarParams
		Write-Verbose "$($RemoveFromModulePaths.Count) path(s) to remove from $EnvVarName env var."
		$NumPathsToRemove = 0
		$NewEnvVar = @()
		ForEach ($PathToRemove in $RemoveFromModulePaths) {
			# Check if there are duplicate paths to remove:
			$i = 0
			ForEach ($Path in $EnvVar) {
				If ($Path -eq $PathToRemove) {
					$i++
					If ($i -gt 1) {
						Write-Warning "$i duplicate paths removed from $EnvVarName env var:`n`"$Path`""
					}
				} Else {
					$NewEnvVar += $Path
				}
			} # End ForEach ($Path in $EnvVar)
		} # End ForEach ($PathToRemove in $RemoveFromModulePaths)
		
		$EnvVar = $NewEnvVar
		
		If ($NumPathsToRemove -gt 0) {
			Write-Verbose "Removing $NumPathsToRemove path(s) from $EnvVarName var:"
			$SetEnvVar = $True
		} ElseIf ($Force) {
			Write-Verbose "(-Force parameter:) Removing $NumPathsToRemove path(s) from $EnvVarName var:"
			$SetEnvVar = $True
		} Else {
			Write-Warning "No paths were removed from $EnvVarName environment var."
			$SetEnvVar = $False
		}
		If ($SetEnvVar) {
			$EnvVar = ($EnvVar | Sort-Object) -join ';'
			# Remove preceeding semicolon ; leftover by -join operation
			$EnvVar = $EnvVar -replace '^;', ''
			# RegEx: ^;
			#    ^   Asserts position at start of a line.
			#    ;   Matches the semicolon ; character literally.
			Set-EnvironmentVariable -Remove -ModulePaths $EnvVar @SetEnvVarParams
		}
	} # End If ($RemoveFromModulePaths)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	#https://www.delftstack.com/howto/powershell/wait-for-each-command-to-finish-in-powershell/
	Start-Sleep -Milliseconds 150
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
			Write-Verbose "Finished updating env vars using RefreshEnv.cmd"
		} Catch {
			Write-Warning "Failed to update environment variables with the RefreshEnv.cmd command. Consider restarting this console to update env vars."
		} # End Try/Catch RefreshEnv
	} Else {
		Write-Warning "You must restart the console for updated environment variables to take effect in this session."
	} # End If/Else (Get-Command RefreshEnv)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of Remove-EnvironmentVariable function.
Set-Alias -Name 'Remove-EnvVar' -Value 'Remove-EnvironmentVariable'
Function Remove-PowershellModulePath {
	<#
	.SYNOPSIS
	Alias: Remove-EnvironmentVariable -RemoveFromModulePaths "<path_to_Remove>"
	.DESCRIPTION
	Alias: Remove-EnvironmentVariable -RemoveFromModulePaths "<path_to_Remove>"
	.NOTES
	Alias: Remove-EnvironmentVariable -RemoveFromModulePaths "<path_to_Remove>"
	Get-Help Remove-EnvironmentVariable
	.LINK
	Remove-EnvironmentVariable
	#>
	[CmdletBinding()]
	Param(
		[Parameter(ParameterSetName = "ModulePaths", Position = 0)]
		[Alias('RemoveFromModulePath','RemoveFromPSModulePath','RemovePSModulePath','PSModulePaths','PSModulePath','RemoveModulePath','ModulePaths','Module','PowerShell','PoSh')]
		[String]$RemoveFromModulePaths
	)
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	Remove-EnvironmentVariable -RemoveFromModulePaths $RemoveFromModulePaths @CommonParameters
}
Set-Alias -Name 'Remove-PoshModulePath' -Value 'Remove-PowershellModulePath'
Set-Alias -Name 'Remove-PsModulePath' -Value 'Remove-PowershellModulePath'
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






