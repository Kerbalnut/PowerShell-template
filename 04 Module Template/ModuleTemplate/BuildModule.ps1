<#
.SYNOPSIS
A module with functions for building modules.
#>

#-----------------------------------------------------------------------------------------------------------------------
Function Get-ModuleCommandInfo {
	<#
	.SYNOPSIS
	Returns all commands and aliases in a PowerShell script.
	.DESCRIPTION
	Returns Get-Command results, but for any PowerShell file. Uses Import-Module to load the file into memory, so the file must be valid PowerShell code.
	.NOTES
	.PARAMETER TempFileSuffix
	This function creates a temporary .psm1 module file to load from, with a custom suffix to avoid conflicts with the original file.
	Use this parameter to adjust the suffix string.
	By default, this value is usually set as either "_GetFunctions" or "_GetAliases".
	For example, the file "HelloWorld.ps1" would use the temporary filename "HelloWorld_GetFunctions.psm1" for operation.
	.EXAMPLE
	Get-ModuleCommandInfo -Path "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -Verbose
	
	$Path = "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...")]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p','ScriptPath','ModulePath')]
		[String]$Path,
		
		[String]$TempFileSuffix = "_GetFunctions"
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Convert file to a .psm1 module, import it, and use powershell's built-in tools to find function names.
	
	# Get file extension:
	$Method = 0
	switch ($Method) {
		0 {
			$FileExtension = [System.IO.Path]::GetExtension($Path)
			
			# Regex remove any . in $FileExtension
			$FileExtension = $FileExtension -replace '^\.',''
		}
		1 {
			$FileExtension = ((Split-Path -Path $Path -Leaf).Split('.'))[1]
		}
		2 {
			$FileExtension = (Get-ChildItem -Path $Path).Extension
			
			# Regex remove any . in $FileExtension
			$FileExtension = $FileExtension -replace '^\.',''
		}
		Default {Throw "Horrible error: Get file extension wrong `$Method: '$Method'"}
	} # End switch
	
	# Get file name:
	$Method = 0
	switch ($Method) {
		0 {
			$FileName = [System.IO.Path]::GetFileName($Path)
		}
		1 {
			$FileName = Split-Path -Path $Path -Leaf
		}
		2 {
			$FileName = (Get-ChildItem -Path $Path).Name
		}
		Default {Throw "Horrible error: Get file name wrong `$Method: '$Method'"}
	} # End switch
	
	# Get file name (no extension):
	$Method = 0
	switch ($Method) {
		0 {
			$FileNameNoExtension = [System.IO.Path]::GetFileNameWithoutExtension($Path)
		}
		1 {
			$FileNameNoExtension = ((Split-Path -Path $Path -Leaf).Split('.'))[0]
		}
		2 {
			$FileNameNoExtension = (Get-ChildItem -Path $Path).BaseName
		}
		Default {Throw "Horrible error: Get file name wrong `$Method: '$Method'"}
	} # End switch
	
	# If the given filepath has an extension, get file path without extension:
	If ($FileExtension -ne '' -And $null -ne $FileExtension) {
		# Get file path without extension:
		$Method = 0
		switch ($Method) {
			0 {
				$NoExtension = $Path -replace '\.\w+$', ''
				# RegEx: \.\w+$
				#    \.  Matches the period . character literally. (Backslash \ is the escape character)
				#    \w+ Matches any word character (equivalent to [a-zA-Z0-9_]), and the plus + modifier matches between one and unlimited times (Greedy).
				#    $   Asserts position at the end of a line.
			}
			1 {
				$VarType = (($Path).GetType()).Name
				Write-Verbose "Path `$VarType = `"$VarType`""
				If ($VarType -eq 'String') {
					$NoExtension = $Path.Substring(0, $Path.LastIndexOf('.'))
				} ElseIf ($VarType -eq 'FileInfo') {
					[String]$Path = $Path
					$NoExtension = $Path.Substring(0, $Path.LastIndexOf('.'))
				}
			}
			2 {
				$VarType = (($Path).GetType()).Name
				Write-Verbose "Path `$VarType = `"$VarType`""
				If ($VarType -eq 'String') {
					$NoExtension = Join-Path -Path ([System.IO.FileInfo]$Path).DirectoryName -ChildPath ([System.IO.FileInfo]$Path).BaseName
				} ElseIf ($VarType -eq 'FileInfo') {
					$NoExtension = Join-Path -Path $Path.DirectoryName -ChildPath $Path.BaseName
				}
			}
		} # End switch
	} # End If ($FileExtension -ne '')
	
	$NewPath = $NoExtension + $TempFileSuffix + ".psm1"
	
	Copy-Item -Path $Path -Destination $NewPath @CommonParameters
	Start-Sleep -Milliseconds 60
	
	Import-Module $NewPath @CommonParameters
	Start-Sleep -Milliseconds 60
	
	$ModuleInfo = Get-Command -Module ("$FileNameNoExtension" + "$TempFileSuffix") @CommonParameters
	Start-Sleep -Milliseconds 60
	
	Remove-Module -Name ("$FileNameNoExtension" + "$TempFileSuffix")
	
	Remove-Item -Path $NewPath
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return $ModuleInfo
} # End of Get-ModuleCommandInfo function.
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
Function Get-FunctionsInScript {
	<#
	.SYNOPSIS
	Returns a list of Function names in a PowerShell script.
	.DESCRIPTION
	This is an alias function for Get-ModuleCommandInfo, with output filtered to show function names. Use -ModuleCommandInfoObj parameter for filtering Get-ModuleCommandInfo output directly.
	.NOTES
	.PARAMETER TempFileSuffix
	This function is an alias for Get-ModuleCommandInfo. See Get-ModuleCommandInfo -TempFileSuffix parameter help text for info.
	.EXAMPLE
	Get-FunctionsInScript -Path $Path
	Get-FunctionsInScript -Path "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -TempFileSuffix "_FindFuncs" -Verbose
	
	$Path = "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	.EXAMPLE
	Get-FunctionsInScript -ModuleCommandInfoObj $ModuleInfo -Verbose
	
	$ModuleInfo = Get-ModuleCommandInfo -Path $Path -Verbose
	$Path = "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	$Path = "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars_Admin.ps1"
	#>
	[Alias("New-ProjectInitTEST")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = 'Path')]
	Param(
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "Path")]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p','ScriptPath','ModulePath')]
		[String]$Path,
		
		[Parameter(Mandatory = $False, Position = 1, 
		           ValueFromPipelineByPropertyName = $True, 
		           ParameterSetName = "Path")]
		[String]$TempFileSuffix = "_GetFunctions",
		
		[Parameter(Mandatory = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           ParameterSetName = "ModuleCommandInfo")]
		[ValidateNotNullOrEmpty()]
		[Alias('ModuleCmdletInfoObj')]
		$ModuleCommandInfoObj
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	
	Write-Verbose "Getting module info:"
	If ($Path) {
		$ModuleCommands = Get-ModuleCommandInfo -Path $Path @FuncParams @CommonParameters
	} ElseIf ($ModuleCommandInfoObj) {
		$ModuleCommands = $ModuleCommandInfoObj
	} Else {
		Throw "Horrible error in parameter choice: Could not make distinction between Path or ModuleCommandInfoObj param set."
	}
	
	Write-Verbose "Getting function names from module info:"
	$Functions = $ModuleCommands | Where-Object -Property 'CommandType' -eq "Function"
	$FunctionNames = $Functions.Name
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return $FunctionNames
} # End of Get-FunctionsInScript function.
Set-Alias -Name 'New-ProjectInitTEST' -Value 'Get-FunctionsInScript'
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
Function Get-AliasesInScript {
	<#
	.SYNOPSIS
	Returns a list of Alias names in a PowerShell script.
	.DESCRIPTION
	This is an alias function for Get-ModuleCommandInfo, with output filtered to show alias names. Use -ModuleCommandInfoObj parameter for filtering Get-ModuleCommandInfo output directly.
	.NOTES
	.PARAMETER TempFileSuffix
	This function is an alias for Get-ModuleCommandInfo. See Get-ModuleCommandInfo -TempFileSuffix parameter help text for info.
	.EXAMPLE
	Get-AliasesInScript -Path "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -TempFileSuffix "_FindFuncs" -Verbose
	
	$Path = "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	.EXAMPLE
	Get-AliasesInScript -ModuleCommandInfoObj $ModuleInfo -Verbose
	
	$ModuleInfo = Get-ModuleCommandInfo -Path $Path -Verbose
	$Path = "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	#>
	[Alias("New-ProjectInitTEST")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = 'Path')]
	Param(
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           ParameterSetName = "Path")]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p','ScriptPath','ModulePath')]
		[String]$Path,
		
		[Parameter(Mandatory = $False, Position = 1, 
		           ValueFromPipelineByPropertyName = $True, 
		           ParameterSetName = "Path")]
		[String]$TempFileSuffix = "_GetAliases",
		
		[Parameter(Mandatory = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           ParameterSetName = "ModuleCommandInfo")]
		[ValidateNotNullOrEmpty()]
		[Alias('ModuleCmdletInfoObj')]
		$ModuleCommandInfoObj
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	
	Write-Verbose "Getting module info:"
	If ($Path) {
		$ModuleCommands = Get-ModuleCommandInfo -Path $Path @FuncParams @CommonParameters
	} ElseIf ($ModuleCommandInfoObj) {
		$ModuleCommands = $ModuleCommandInfoObj
	} Else {
		Throw "Horrible error in parameter choice: Could not make distinction between Path or ModuleCommandInfoObj param set."
	}
	
	Write-Verbose "Getting function names from module info:"
	$Functions = $ModuleCommands | Where-Object -Property 'CommandType' -eq "Alias"
	$FunctionAliases = $Functions.Name
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return $FunctionAliases
} # End of Get-AliasesInScript function.
Set-Alias -Name 'New-ProjectInitTEST' -Value 'Get-AliasesInScript'
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






