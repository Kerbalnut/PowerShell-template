
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
	Alias: Get-EnvironmentVariable -GetModulePaths
	.NOTES
	Alias: Get-EnvironmentVariable -GetModulePaths
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
	Sets an environment variable, either PATH or the PowerShell Module paths.
	.DESCRIPTION
	When given either a PathVar string or ModulePaths string, this function will overwrite either the PATH or PSModulePath environment variable respectively.
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
	[CmdletBinding(DefaultParameterSetName = "PathVar")]
	Param(
		[Parameter(ParameterSetName = "PathVar")]
		[string]$PathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[Alias('GetPsModulePaths','GetPowershellModulePaths')]
		[string]$ModulePaths,
		
		[string]$BackupFile = ".\PATH_BACKUP.txt",
		
		[switch]$Remove,
		
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
	
	If ($PathPrefix -ne "" -And $null -ne $PathPrefix) {
		Test-Path -Path $PathPrefix -PathType Container
	}
	
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
		}
		1 {
			$FileExtension = ((Split-Path $BackupFile -Leaf).Split('.'))[1]
			# txt
			# zip
		}
		2 {
			$FileExtension = (Get-ChildItem $BackupFile).Extension
			# .txt
			# .zip
		}
		3 {
			$FileExtension = (Get-Item $BackupFile).Extension
			# .txt
			# .zip
		}
		Default {Throw "Please select a method for getting PowerShell path extension."}
	}
	Write-Verbose "`$FileExtension = `"$FileExtension`""
	
	# If given filename doesn't have an extension for some reason, assign one.
	If ($FileExtension -eq '' -Or $null -eq $FileExtension) {
		$FileExtension = ".txt"
		Write-Verbose "`$FileExtension = `"$FileExtension`" (none detected, defaulting to .txt)"
		$BackupFile = $BackupFile + $FileExtension
	}
	
	# If BackupFile still exists, try to rename it to BackupFile_old or something:
	If ((Test-Path -Path $BackupFile)) {
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
		
		# Check if this BackupFile_old file already exists:
		If ((Test-Path -Path $NewName)) {
			Write-Verbose "Removing old backup file before generating new one: `"$NewName`""
			Write-Warning "Removing old backup file before generating new one: `"$NewName`""
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
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	If ($PathVar) {
		$EnvVarName = "PATH"
	} ElseIf ($ModulePaths) {
		$EnvVarName = "PSModulePath"
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	Try {
		If ($PathVar) {
			$Env:PATH | Out-file -FilePath $BackupFile -Append
		} ElseIf ($ModulePaths) {
			$Env:PSModulePath | Out-file -FilePath $BackupFile -Append
		}
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
			} # End Switch $Result
		} # End If !($Force)
		
	} # End Try/Catch
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
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
	
	$OriginalPaths = ($OriginalPath -split ";").Count
	Write-Verbose "`$OriginalPath.Length = $($OriginalPath.Length) ; `$OriginalPaths(Count) = $OriginalPaths"
	
	$EnvVarPath = $EnvVarPath.Trim()
	$EnvVarPaths = ($EnvVarPath -split ";").Count
	Write-Verbose "`$EnvVarPath.Length = $($EnvVarPath.Length) ; `$EnvVarPaths(Count) = $EnvVarPaths"
	
	If ($EnvVarPath -notlike '*;*' -And !($Force)) {
		Write-Host "CAUTION: No ;" -ForegroundColor Red -BackgroundColor Black
		Write-Warning "No ; semicolon detected in new $EnvVarName variable value. This means you will be overwriting $EnvVarName with only one directory location. This is NOT recommened."
		Write-Error "No ; semicolon detected in new $EnvVarName variable value. This means you will be overwriting $EnvVarName with only one directory location. This is NOT recommened."
		Throw "No ; semicolon detected in new $EnvVarName variable value. This means you will be overwriting $EnvVarName with only one directory location. This is NOT recommened."
	}
	
	If ( ($EnvVarPath.Lenth) -lt ($OriginalPath.Length) -And !($Remove) -And !($Force) ) {
		Write-Warning "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future, use the -Remove parameter when removing data from $EnvVarName."
		Write-Error "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future,d use the -Remove parameter when removing data from $EnvVarName."
		Throw "New $EnvVarName is shorter than old $EnvVarName! Is this intentional? You will be removing data from the $EnvVarName variable. To avoid this warning in the future, use the -Remove parameter when removing data from $EnvVarName."
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	If ($PathVar) {
		[Environment]::SetEnvironmentVariable("PATH", $EnvVarPath, [EnvironmentVariableTarget]::Machine)
	} ElseIf ($ModulePaths) {
		[Environment]::SetEnvironmentVariable("PSModulePath", $EnvVarPath, [EnvironmentVariableTarget]::Machine)
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
	.EXAMPLE
	
	#>
	[Alias("Add-EnvVar")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = "PathVar")]
	Param(
		[Parameter(ParameterSetName = "PathVar", Position = 0)]
		[String]$AddToPathVar,
		
		[Parameter(ParameterSetName = "ModulePaths")]
		[String]$AddToModulePaths
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($AddToPathVar) {
		$PathVar = Get-EnvironmentVariable -GetPathVar @CommonParameters
		# Check if path to add already exists in env var
		ForEach ($Path in $PathVar) {
			If ($Path -eq $AddToPathVar) {
				Write-Warning "Path to add already exists in PATH environment var:`n`"$Path`""
				Return
			}
		}
		$PathVar += $AddToPathVar
		$PathVar = ($PathVar | Sort-Object) -join ';'
		Set-EnvironmentVariable -PathVar $PathVar @CommonParameters
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	If ($AddToModulePaths) {
		$EnvVar = Get-EnvironmentVariable -GetModulePaths @CommonParameters
		# Check if path to add already exists in env var
		ForEach ($Path in $EnvVar) {
			If ($Path -eq $AddToModulePaths) {
				Write-Warning "Path to add already exists in PATH environment var:`n`"$Path`""
				Return
			}
		}
		$EnvVar += $AddToModulePaths
		$EnvVar = ($EnvVar | Sort-Object) -join ';'
		Set-EnvironmentVariable -ModulePaths $EnvVar @CommonParameters
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of Add-EnvironmentVariable function.
Set-Alias -Name 'Add-EnvVar' -Value 'Add-EnvironmentVariable'
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
	#>
	[Alias("Remove-EnvVar")]
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
} # End of Remove-EnvironmentVariable function.
Set-Alias -Name 'Remove-EnvVar' -Value 'Remove-EnvironmentVariable'
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






