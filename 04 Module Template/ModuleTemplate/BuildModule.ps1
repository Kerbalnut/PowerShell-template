<#
.SYNOPSIS
A module with functions for building modules.
#>

#-----------------------------------------------------------------------------------------------------------------------
Function Get-FunctionName {
	<#
	.LINK
	https://stackoverflow.com/questions/3689543/is-there-a-way-to-retrieve-a-powershell-function-name-from-within-a-function
	#>
	'This function is called {0}.' -f $MyInvocation.MyCommand
} # End Function Get-FunctionName
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
Function Get-ModuleCommandInfo {
	<#
	.SYNOPSIS
	Returns all function names and aliases from a given PowerShell script file.
	.DESCRIPTION
	Relies on Get-Command results, but for any type of PowerShell file. Uses Import-Module to load the file into memory, so the file must be valid PowerShell code. (It compiles/Can be loaded without any terminating errors.) Use the -NoVerification switch to turn this behavior off and exclusivly use a regex discovery method.
	.PARAMETER TempModuleSuffix
	This function creates a temporary .psm1 module file to load from with a custom suffix name, in order to avoid any conflicts with the originally named module if it's already imported.
	Use this parameter to adjust the suffix string.
	By default, this value is usually set as either "_GetFunctions" or "_GetAliases".
	For example, the file "HelloWorld.ps1" would become the temporary filename "HelloWorld_GetFunctions.psm1" for operation.
	
	If -NoVerification switch is used this parameter becomes unnecessary.
	.PARAMETER DontRemoveModule
	Will leave temporarily-loaded modules imported after execution. Useful when used with a blank string for the -TempModuleSuffix "" parameter, for testing modules that have a #Requires dependency on another module that needs to be loaded and stay loaded. 
	
	To clean-up these imported modules after this function's data is collected, run the same command again but without this -DontRemoveModule switch enabled.
	
	Not compatible with -NoVerification switch.
	.PARAMETER NoVerification
	Turns off validation of PowerShell code before returning results. This method will rely exclusively on regex filters for function name discovery. For example, modules with #Requires -RunAsAdministrator can still be processed even from a non-Admin instance.
	
	Currently, using this switch does not enable Alias name discovery. (See Notes for more info.)
	
	If this switch is used, one of either the -IncludeSubFunctions or -NoSubFunctions switches are required as well.
	
	Not compatible with -DontRemoveModule or -RawOutput switches.
	.PARAMETER IncludeSubFunctions
	Includes discovery of sub-functions nested inside other functions.
	
	This is normally disabled, because nested functions are not accessible to anything else besides it's parent function. This is only useful for discovering function names that might be useful in other scenarios besides it's parent context.
	
	If this switch is used, either the -NoVerification switch is also required, or a value for -TempModuleSuffix must be provided, for example: 
	-TempModuleSuffix "_GetFunctions"
	-TempModuleSuffix "_GetAliases"
	-TempModuleSuffix ""
	.PARAMETER NoSubFunctions
	Excludes sub-functions nested inside other functions.
	
	This is normally the default option, because nested functions are not accessible to anything else besides it's parent function.
	.PARAMETER RawOutput
	Prevents simplifying of output object type. Normally Get-Command output creates a [System.Management.Automation.FunctionInfo] array with [System.Management.Automation.AliasInfo] and [System.Management.Automation.FunctionInfo] objects. This switch will also prevent sub-functions nested inside other functions from being discovered.
	
	Not compatible with -NoVerification switch.
	.NOTES
	TODO: Currently the NoVerification parameter (regex discovery method) will not look for Aliases. This could change in the future, if the regex filters can be worked out.
	.EXAMPLE
	Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -Verbose
	Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars_Admin.ps1" -Verbose
	
	$Path = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	$Path = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars_Admin.ps1"
	
	Get-ModuleCommandInfo -Path $Path -Verbose
	.EXAMPLE
	Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -Verbose
	Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -IncludeSubFunctions -TempModuleSuffix "" -Verbose
	Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -NoVerification -NoSubFunctions -Verbose
	Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -NoVerification -IncludeSubFunctions -Verbose
	Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -RawOutput -Verbose
	
	Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars_Admin.ps1" -NoVerification -NoSubFunctions -Verbose
	#>
	[CmdletBinding(DefaultParameterSetName = "NoSubFuncs")]
	Param(
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...")]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p','ScriptPath','ModulePath')]
		[String]$Path,
		
		[Parameter(ParameterSetName = "IncludeSubFuncs")]
		[Parameter(ParameterSetName = "NoSubFuncs")]
		[String]$TempModuleSuffix = "_GetFunctions",
		
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs_NoVerification")]
		[Parameter(Mandatory = $True, ParameterSetName = "NoSubFuncs_NoVerification")]
		[Switch]$NoVerification,
		
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs_NoVerification")]
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs")]
		[Alias('IncludeNestedFunctions')]
		[Switch]$IncludeSubFunctions,
		
		[Parameter(Mandatory = $True, ParameterSetName = "NoSubFuncs_NoVerification")]
		[Parameter(ParameterSetName = "NoSubFuncs")]
		[Alias('NoNestedFunctions')]
		[Switch]$NoSubFunctions,
		
		[Parameter(ParameterSetName = "IncludeSubFuncs")]
		[Parameter(ParameterSetName = "NoSubFuncs")]
		[Switch]$DontRemoveModule,
		
		[Parameter(ParameterSetName = "NoSubFuncs")]
		[Switch]$RawOutput
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
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Set default behavior:
	If ($IncludeSubFunctions -And $NoSubFunctions) {
		$IncludeSubFunctions = $False
		$NoSubFunctions = $True
	} ElseIf (!($IncludeSubFunctions) -And !($NoSubFunctions)) {
		$IncludeSubFunctions = $False
		$NoSubFunctions = $True
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Get info via module import:
	
	$NewPath = $NoExtension + $TempModuleSuffix + ".psm1"
	$TempModuleName = $FileNameNoExtension + $TempModuleSuffix
	
	If (!($NoVerification)) {
		
		Write-Verbose "Getting functions & aliases via Import-Module: ($TempModuleName)"
		
		If ((Test-Path -Path $NewPath)) {
			Write-Warning "Temp module path already exists. Deleting: $TempModuleName.psm1"
			Remove-Item -Path $NewPath -Force @CommonParameters
		}
		
		Copy-Item -Path $Path -Destination $NewPath @CommonParameters
		Start-Sleep -Milliseconds 60
		
		ForEach ($Module in ((Get-Module).Name)) {
			If ($Module -eq $TempModuleName) {
				Try {
					Remove-Module -Name $TempModuleName @CommonParameters
				} Catch {
					Write-Warning "Module ($TempModuleName) removal failure."
				}
			} # End If ($Module -eq $TempModuleName)
		} # End ForEach ($Module in ((Get-Module).Name))
		Start-Sleep -Milliseconds 60
		
		Import-Module $NewPath @CommonParameters
		Start-Sleep -Milliseconds 60
		
		$ModuleInfo = Get-Command -Module $TempModuleName @CommonParameters
		Start-Sleep -Milliseconds 60
		
		If (!($DontRemoveModule)) {
			ForEach ($Module in ((Get-Module).Name)) {
				If ($Module -eq $TempModuleName) {
					Try {
						Remove-Module -Name $TempModuleName @CommonParameters
					} Catch {
						Write-Warning "No modules ($TempModuleName) were removed."
					}
				} # End If ($Module -eq $TempModuleName)
			} # End ForEach ($Module in ((Get-Module).Name))
		} # End If (!($DontRemoveModule))
		
		If ((Test-Path -Path $NewPath)) {
			Remove-Item -Path $NewPath -Force @CommonParameters
		} Else {
			Write-Warning "Temp module path does not exist: `"$NewPath`""
		}
	} # End If (!($NoVerification))
	
	If ($RawOutput) {
		Return $ModuleInfo
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Get sub-functions via regex:
	
	If (!($RawOutput)) {
		
		Write-Verbose "Getting functions & sub-functions via regex:"
		
		#Get-ModuleCommandInfo -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -Verbose
		
		#$Path = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
		
		$FileText = (Get-Content -Path $Path | Out-String).Trim()
		
		$NoMultiLineComments = $FileText -replace '(?si)<#.*?#>',''
		# Regex: (?si)<#.*?#>
		#  (?i)      s modifier: single line. Dot matches newline characters. i modifier: Case insensitive match.
		#  <#        matches the characters "<#" literally
		#  .*?       . matches any character, * modifier matches between zero and unlimited times (by default, greedy), ? modifier forces lazy matches (as few times as possible)
		#  #>        matches the characters "#>" literally
		
		$TempFile = "$env:TEMP\DELETE_ME_Get-ModuleCommandInfo_NoMultiLineComments.ps1"
		
		If ((Test-Path -Path $TempFile)) {Remove-Item -Path $TempFile -Force}
		Start-Sleep -Milliseconds 100 # Wait for disk operations to complete
		
		$CmdletResults = New-Item -Path $TempFile -ItemType File -Value $NoMultiLineComments
		Start-Sleep -Milliseconds 100 # Wait for disk operations to complete
		Write-Verbose $CmdletResults
		#If ($VerbosePreference -ne "SilentlyContinue") {Write-Host $CmdletResults}
		
		Set-Content -Path $TempFile -Value $NoMultiLineComments
		Start-Sleep -Milliseconds 100 # Wait for disk operations to complete
		
		$FileText = Get-Content -Path $TempFile
		Start-Sleep -Milliseconds 100 # Wait for disk operations to complete
		
		If ((Test-Path -Path $TempFile)) {Remove-Item -Path $TempFile -Force}
		
		$NoSingleLineComments = $FileText -replace '\s*#.*',''
		
		$FullFunctionsList = $NoSingleLineComments | Select-String -Pattern '(?i)^\s*function\s+\w+'
		# Regex: (?i)^\s*function\s+\w+
		#  (?i)      i modifier: Case insensitive match (ignores case of [a-zA-Z])
		#  ^         ^ asserts position at start of the string
		#  \s*       \s matches any whitespace character, * modifier matches between zero and unlimited times
		#  function  matches the text "function" literally
		#  \s+       \s matches any whitespace character, + modifier matches between one and unlimited times
		#  \w+       \w matches any word character, + modifier matches between one and unlimited times
		
		$FullFunctionsList = $FullFunctionsList -replace '{',''
		$FullFunctionsList = $FullFunctionsList -replace '}',''
		
		If ($NoVerification) {
			$TopLvlFunctions = $FullFunctionsList -replace '(?i)^function\s+',''
			$TopLvlFunctions = $TopLvlFunctions -replace '\s+',''
		}
		
		$FullFunctionsList = $FullFunctionsList -replace '(?i)\s*function\s+',''
		$FullFunctionsList = $FullFunctionsList -replace '\s+',''
		
	} # End If (!($NoSubFunctions) -And !($RawOutput))
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Convert module info data into a generic array that's easier to manipulate:
	
	$SimpleInfo = @()
	If (!($NoVerification)) {
		ForEach ($Item in $ModuleInfo) {
			$SimpleInfo += [PSCustomObject]@{
				CommandType = $Item.CommandType
				Name = $Item.Name
				Version = $Item.Version
				Source = $Item.Source
			}
		} # End ForEach ($Item in $ModuleInfo)
	} Else {
		ForEach ($RegexFunction in $FullFunctionsList) {
			$CT = "Sub-function"
			ForEach ($TopLvlFunc in $TopLvlFunctions) {
				#Write-Verbose "Comparing `"$RegexFunction`" to `"$TopLvlFunc`""
				If ($TopLvlFunc -eq $RegexFunction) {
					$CT = "Function"
				}
			}
			
			$NewItem = [PSCustomObject]@{
				CommandType = $CT
				Name = $RegexFunction
				Version = $null
				Source = $TempModuleName
			}
			
			If ($NoSubFunctions) {
				If ($CT -eq "Function") {
					$SimpleInfo += $NewItem
				}
			} Else {
				$SimpleInfo += $NewItem
			}
		} # End ForEach ($RegexFunction in $FullFunctionsList)
	} # End If/Else ($NoVerification)
	
	If ($NoSubFunctions -Or $NoVerification) {
		Return $SimpleInfo
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Merge the 2 lists:
	
	If ($IncludeSubFunctions) {
		ForEach ($RegexFunction in $FullFunctionsList) {
			[Boolean]$AlreadyCaptured = $False
			ForEach ($ImportedFunction in $SimpleInfo) {
				If ($RegexFunction -eq ($ImportedFunction).Name) {
					[Boolean]$AlreadyCaptured = $True
				}
			}
			If (!($AlreadyCaptured)) {
				$NewItem = [PSCustomObject]@{
					CommandType = "Sub-function"
					Name = $RegexFunction
					Version = $null
					Source = $TempModuleName
				}
				#$NewItem = @("Sub-function", $RegexFunction, $null, $TempModuleName)
				$SimpleInfo += $NewItem
			}
		} # End ForEach ($RegexFunction in $FullFunctionsList)
	} # End If ($IncludeSubFunctions)
	
	Return $SimpleInfo
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
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
	.PARAMETER TempModuleSuffix
	This function is an alias for Get-ModuleCommandInfo. See Get-ModuleCommandInfo -TempModuleSuffix parameter help text for info.
	.EXAMPLE
	Get-FunctionsInScript -Path $Path
	Get-FunctionsInScript -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -TempModuleSuffix "_FindFuncs" -Verbose
	
	$Path = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	.EXAMPLE
	Get-FunctionsInScript -ModuleCommandInfoObj $ModuleInfo -Verbose
	
	$ModuleInfo = Get-ModuleCommandInfo -Path $Path -Verbose
	$Path = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	$Path = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars_Admin.ps1"
	#>
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = "NoSubFuncs")]
	Param(
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "IncludeSubFuncs")]
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "NoSubFuncs")]
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "IncludeSubFuncs_NoVerification")]
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "NoSubFuncs_NoVerification")]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p','ScriptPath','ModulePath')]
		[String]$Path,
		
		[Parameter(Mandatory = $False, Position = 1, 
		           ValueFromPipelineByPropertyName = $True, 
		           ParameterSetName = "IncludeSubFuncs")]
		[Parameter(Mandatory = $False, Position = 1, 
		           ValueFromPipelineByPropertyName = $True, 
				   ParameterSetName = "NoSubFuncs")]
		[String]$TempModuleSuffix = "_GetFunctions",
		
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs_NoVerification")]
		[Parameter(Mandatory = $True, ParameterSetName = "NoSubFuncs_NoVerification")]
		[Switch]$NoVerification,
		
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs_NoVerification")]
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs")]
		[Alias('IncludeNestedFunctions')]
		[Switch]$IncludeSubFunctions,
		
		[Parameter(Mandatory = $True, ParameterSetName = "NoSubFuncs_NoVerification")]
		[Parameter(ParameterSetName = "NoSubFuncs")]
		[Alias('NoNestedFunctions')]
		[Switch]$NoSubFunctions,
		
		[Parameter(ParameterSetName = "IncludeSubFuncs")]
		[Parameter(ParameterSetName = "NoSubFuncs")]
		[Switch]$DontRemoveModule,
		
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
	$FuncParams = @{}
	If (!($NoVerification)) {
		If ($TempModuleSuffix) {$FuncParams += @{TempModuleSuffix = $TempModuleSuffix}}
	}
	If ($NoVerification) {$FuncParams += @{NoVerification = $NoVerification}}
	If ($IncludeSubFunctions) {$FuncParams += @{IncludeSubFunctions = $IncludeSubFunctions}}
	If ($NoSubFunctions) {$FuncParams += @{NoSubFunctions = $NoSubFunctions}}
	If ($DontRemoveModule) {$FuncParams += @{DontRemoveModule = $DontRemoveModule}}
	
	Write-Verbose "Getting module info:"
	If ($Path) {
		$ModuleCommands = Get-ModuleCommandInfo -Path $Path @FuncParams @CommonParameters
	} ElseIf ($ModuleCommandInfoObj) {
		$ModuleCommands = $ModuleCommandInfoObj
	} Else {
		Throw "Horrible error in parameter choice: Could not make distinction between Path or ModuleCommandInfoObj param set."
	}
	
	Write-Verbose "Getting function names from module info:"
	$Functions = $ModuleCommands | Where-Object -Property 'CommandType' -like "*unction"
	$FunctionNames = $Functions.Name
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return $FunctionNames
} # End of Get-FunctionsInScript function.
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
Function Get-AliasesInScript {
	<#
	.SYNOPSIS
	Returns a list of Alias names in a PowerShell script.
	.DESCRIPTION
	This is an alias function for Get-ModuleCommandInfo, with output filtered to show alias names. Use -ModuleCommandInfoObj parameter for filtering Get-ModuleCommandInfo output directly.
	.NOTES
	.PARAMETER TempModuleSuffix
	This function is an alias for Get-ModuleCommandInfo. See Get-ModuleCommandInfo -TempModuleSuffix parameter help text for info.
	.EXAMPLE
	Get-AliasesInScript -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1" -TempModuleSuffix "_FindFuncs" -Verbose
	
	$Path = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	.EXAMPLE
	Get-AliasesInScript -ModuleCommandInfoObj $ModuleInfo -Verbose
	
	$ModuleInfo = Get-ModuleCommandInfo -Path $Path -Verbose
	$Path = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	#>
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = "NoSubFuncs")]
	Param(
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "IncludeSubFuncs")]
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "NoSubFuncs")]
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "IncludeSubFuncs_NoVerification")]
		[Parameter(Mandatory = $True, Position = 0, 
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True, 
		           HelpMessage = "Path to ...", 
		           ParameterSetName = "NoSubFuncs_NoVerification")]
		[ValidateNotNullOrEmpty()]
		[Alias('ProjectPath','p','ScriptPath','ModulePath')]
		[String]$Path,
		
		[Parameter(Mandatory = $False, Position = 1, 
		           ValueFromPipelineByPropertyName = $True, 
		           ParameterSetName = "IncludeSubFuncs")]
		[Parameter(Mandatory = $False, Position = 1, 
		           ValueFromPipelineByPropertyName = $True, 
				   ParameterSetName = "NoSubFuncs")]
		[String]$TempModuleSuffix = "_GetAliases",
		
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs_NoVerification")]
		[Parameter(Mandatory = $True, ParameterSetName = "NoSubFuncs_NoVerification")]
		[Switch]$NoVerification,
		
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs_NoVerification")]
		[Parameter(Mandatory = $True, ParameterSetName = "IncludeSubFuncs")]
		[Alias('IncludeNestedFunctions')]
		[Switch]$IncludeSubFunctions,
		
		[Parameter(Mandatory = $True, ParameterSetName = "NoSubFuncs_NoVerification")]
		[Parameter(ParameterSetName = "NoSubFuncs")]
		[Alias('NoNestedFunctions')]
		[Switch]$NoSubFunctions,
		
		[Parameter(ParameterSetName = "IncludeSubFuncs")]
		[Parameter(ParameterSetName = "NoSubFuncs")]
		[Switch]$DontRemoveModule,
		
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
	$FuncParams = @{}
	If (!($NoVerification)) {
		If ($TempModuleSuffix) {$FuncParams += @{TempModuleSuffix = $TempModuleSuffix}}
	}
	If ($NoVerification) {$FuncParams += @{NoVerification = $NoVerification}}
	If ($IncludeSubFunctions) {$FuncParams += @{IncludeSubFunctions = $IncludeSubFunctions}}
	If ($NoSubFunctions) {$FuncParams += @{NoSubFunctions = $NoSubFunctions}}
	If ($DontRemoveModule) {$FuncParams += @{DontRemoveModule = $DontRemoveModule}}
	
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
#-----------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------
Function New-Shortcut {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	#>
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
	
	#https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-.net-and-com-objects--new-object-?view=powershell-7.2
	
	# Creating a Desktop Shortcut with WScript.Shell
	
	# One task that can be performed quickly with a COM object is creating a shortcut. Suppose you want to create a shortcut on your desktop that links to the home folder for Windows PowerShell. You first need to create a reference to WScript.Shell, which we will store in a variable named $WshShell:
	
	$WshShell = New-Object -ComObject WScript.Shell
	
	$lnk = $WshShell.CreateShortcut("$Home\Desktop\PSHome.lnk")
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of New-Shortcut function.
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






