<#
.SYNOPSIS
Controller script for building ManageEnvVars (and ManageEnvVars_Admin) modules.
.DESCRIPTION
Requires -RunAsAdministrator because Get-ModuleCommandInfo function needs to load all files as modules to work, and this project contains modules that are Admin only.
.PARAMETER FileNames
List of module files to export for the module. These can be .ps1 files and they will still be exported as .psm1 files.
.PARAMETER BuildFuncsName
File name of the build functions .ps1 script to load, required for this controller script operation. Default is "BuildModule.ps1".
.PARAMETER ExceptionFileName
Optional .xml file name of exceptions file.
.PARAMETER Guid
To create a new GUID in PowerShell, type `[guid]::NewGuid()`.
.PARAMETER Description
Describes the contents of the module.
.LINK
https://www.leeholmes.com/cmdlets-vs-functions/
.NOTES
Cmdlets vs. Functions:
- It is currently much easier for ISVs and developers to package and deploy cmdlets than it is to package libraries of functions or scripts.
- It is currently easier to write and package help for cmdlets.
- Cmdlets are written in a compiled .NET language, while functions (and scripts) are written in the PowerShell language. On the plus side, this makes certain developer tasks (such as P/Invoke calls, working with generics) much easier in a cmdlet. On the minus side, this makes you pay the ‘compilation’ tax — making it slower to implement and evaluate new functionality.
- In V1,  Cmdlets provide the author a great deal of support for parameter validation, and tentative processing (-WhatIf, -Confirm.) This is an implementation artifact, though, and could go away in the future.
- [Various technical points] Functions support scoping, different naming guidelines, management through the function drive, etc. See your favourite scripting reference for these details.
#>
#Requires -RunAsAdministrator
[CmdletBinding()]
Param(
	[Parameter(Position = 0, 
	#Mandatory = $True, 
	ValueFromPipeline = $True, 
	ValueFromPipelineByPropertyName = $True)]
	[ValidateNotNullOrEmpty()]
	[Alias('ModuleNames','FilesToExport')]
	[String[]]$FileNames = $(@("ManageEnvVars.ps1","ManageEnvVars_Admin.ps1")),
	
	#[Parameter(Mandatory = $True)]
	[String]$BuildFuncsName = "BuildModule.ps1",
	
	[Parameter(Mandatory = $False)]
	[String]$ExceptionFileName = "Exceptions.xml",
	
	[String]$ModuleVersion = "0.1",
	
	[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True, 
	HelpMessage = "To create a new GUID in PowerShell, type `[guid]::NewGuid()`.")]
	[System.Guid]$Guid,
	
	[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True, 
	HelpMessage = "Describes the contents of the module.")]
	$Description = "Hello World",
	
	[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
	$ReleaseNotes,
	
	[String]$Author = "Kerbalnut",
	
	[String]$ProjectUri = "https://github.com/Kerbalnut/PowerShell-template",
	[String]$LicenseUri = "https://github.com/Kerbalnut/PowerShell-template/blob/master/LICENSE",
	[String]$IconUri,
	
	[System.Object[]]$RequiredModules,
	[System.String[]]$RequiredAssemblies,
	
	[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True, 
	HelpMessage = "Recommended PowerShell version, e.g. '5.1'")]
	[System.Version]$PowerShellVersion = 5.1,
	
	[ValidateSet('Desktop','Core')]
	[String[]]$CompatiblePSEditions = 'Desktop',
	
	[ValidateSet('None','MSIL','X86','IA64','Amd64','Arm')]
	#@('None','X86','IA64','Amd64')
	[System.Reflection.ProcessorArchitecture]$ProcessorArchitecture = 'X86'
	
)
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$CommonParameters = @{
	Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
	Debug = [System.Management.Automation.ActionPreference]$DebugPreference
}
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$ScriptName = $MyInvocation.MyCommand.Name
Write-Host "Starting build script: `"$ScriptName`""
$HomePath = $PSScriptRoot
#$HomePath = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\"
Write-Verbose "Selected files: $FileNames"

#-----------------------------------------------------------------------------------------------------------------------

# Import build functions from BuildModule.ps1
If ($BuildFuncsName -match '.+\..+') {$HasFileExtension = $True} Else {$HasFileExtension = $False}
# RegEx: .+\..+
#    .+  The . matches any character, plus + modifier matches between one and unlimited times (Greedy)
#    \.  Matches the period . character literally. (Backslash \ is the escape character)
#    .+  The . matches any character, plus + modifier matches between one and unlimited times (Greedy)

If ($HasFileExtension) {
	$Method = 0
	switch ($Method) {
		0 {
			# .NET function
			$FileExtension = [System.IO.Path]::GetExtension($Path)
			
			# Regex remove any . in $FileExtension
			$FileExtension = $FileExtension -replace '^\.',''
		}
		1 {
			# Split-Path
			$FileExtension = ((Split-Path -Path $Path -Leaf).Split('.'))[1]
		}
		2 {
			# Get-ChildItemS
			$FileExtension = (Get-ChildItem -Path $Path).Extension
			
			# Regex remove any . in $FileExtension
			$FileExtension = $FileExtension -replace '^\.',''
		}
		Default {Throw "Horrible error: Get file extension wrong `$Method: '$Method'"}
	} # End switch
} # End If ($HasFileExtension)
$BuildFunctions = Join-Path -Path $HomePath -ChildPath $BuildFuncsName
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
Write-Verbose "Loading $BuildFuncsName complete."

#-----------------------------------------------------------------------------------------------------------------------

Write-Verbose "Removing extensions from module file names:"

$NoFileExtensions = @()
ForEach ($File in $FileNames) {
	If ($File -match '.+\..+') {$HasFileExtension = $True} Else {$HasFileExtension = $False}
	# RegEx: .+\..+
	#    .+    The . matches any character, plus + modifier matches between one and unlimited times (Greedy)
	#    \.    Matches the period . character literally. (Backslash \ is the escape character)
	#    .+    The . matches any character, plus + modifier matches between one and unlimited times (Greedy)
	
	Write-Verbose "File $File has extension: $HasFileExtension"
	
	If ($HasFileExtension) {
		$Method = 0
		switch ($Method) {
			0 {
				# .NET function
				$NoFileExtension = [System.IO.Path]::GetFileNameWithoutExtension($File)
			}
			1 {
				# Regex remove file extension
				$NoFileExtension = $File -replace '\.\w+?$',''
				# RegEx: \.\w+?$
				#    \.    Matches the period . character literally. (Backslash \ is the escape character)
				#    \w+?  \w matches any word character, plus + modifier matches between one and unlimited times (Greedy), and question mark ? modifier changes this behavior to match as few characters as possible (Lazy).
				#    $     The $ matches the end of line/string.
			}
			Default {Throw "Horrible error: Remove file extension wrong `$Method: '$Method'"}
		} # End switch
	} Else {
		$NoFileExtension = $File
	} # End If ($HasFileExtension)
	
	$NoFileExtension = [PSCustomObject]@{
		File = $File
		NoFileExtension = $NoFileExtension
	}
	$NoFileExtensions += $NoFileExtension
	
} # End ForEach ($File in $FileNames)

#-----------------------------------------------------------------------------------------------------------------------

Write-Verbose "Getting list of all functions and aliases:"

#[String[]]$FileNames = $(@("ManageEnvVars.ps1","ManageEnvVars_Admin.ps1"))
#$HomePath = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\"

$CompleteModulesInfo = @()
ForEach ($file in $FileNames) {
	#$file = "ManageEnvVars.ps1"
	#$file = "ManageEnvVars_Admin.ps1"
	
	$FullPath = Join-Path -Path $HomePath -ChildPath $file
	#$ModuleInfo = Get-ModuleCommandInfo -Path $FullPath -NoSubFunctions -NoVerification @CommonParameters
	$ModuleInfo = Get-ModuleCommandInfo -Path $FullPath -NoSubFunctions -TempModuleSuffix "" -DontRemoveModule @CommonParameters
	$FunctionsList = Get-FunctionsInScript -ModuleCommandInfoObj $ModuleInfo @CommonParameters
	$AliasList = Get-AliasesInScript -ModuleCommandInfoObj $ModuleInfo @CommonParameters
	Write-Host "$($file):"
	If ($VerbosePreference -ne 'SilentlyContinue') {
		$ModuleInfo | Format-Table | Out-Host
	}
	$CompleteModulesInfo += $ModuleInfo
}
# Run same command again without -DontRemoveModule switch to remove modules.
ForEach ($file in $FileNames) {
	$null = Get-ModuleCommandInfo -Path $FullPath -NoSubFunctions -TempModuleSuffix "" @CommonParameters
}

#-----------------------------------------------------------------------------------------------------------------------

#$ExceptionFileName = "Exceptions.xml"

If ($ExceptionFileName) {
	Write-Verbose "Evaluating Exceptions:"
	$ExceptionFile = Join-Path -Path $HomePath -ChildPath $ExceptionFileName
}

If ($Exceptions) {Remove-Variable -Name Exceptions}

$FalseString = "[ ]"
$TrueString = "[X]"

If ($ExceptionFileName) {
	If ((Test-Path -Path $ExceptionFile)) {
		Write-Host "`n$($ExceptionFileName):"
		$Display = Import-Clixml -Path $ExceptionFile
		$Display | Format-Table | Out-Host
		
		# Ask user to load exceptions file
		$Title = "Load $($ExceptionFileName)?"
		$Info = "Load the Exceptions file, modify it, or skip it?"
		# Use Ampersand & in front of letter to designate that as the choice key. E.g. "&Yes" for Y, "Y&Ellow" for E.
		$Load = New-Object System.Management.Automation.Host.ChoiceDescription "&Load", "Load all exception in $ExceptionFileName file"
		$Modify = New-Object System.Management.Automation.Host.ChoiceDescription "&Edit", "Modify $ExceptionFileName file"
		$Skip = New-Object System.Management.Automation.Host.ChoiceDescription "&Skip", "Skip loading the exceptions file, and include all functions in module(s) with no exceptions."
		$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Load, $Modify, $Skip)
		[int]$DefaultChoice = 0
		$Result = $Host.UI.PromptForChoice($Title, $Info, $Options, $DefaultChoice)
		switch ($Result) {
			0 {
				Write-Verbose "Loading Exceptions file: $ExceptionFileName (`"$ExceptionFile`")"
				$Exceptions = Import-Clixml -Path $ExceptionFile
			}
			1 {
				Write-Verbose "Modifying $ExceptionFileName"
				$Exceptions = Import-Clixml -Path $ExceptionFile
				
				# Build menu list:
				$ExceptionsSelection = @()
				$i = 0
				ForEach ($Item in $CompleteModulesInfo) {
					$i++
					$Status = $FalseString
					ForEach ($Exc in $Exceptions) {
						If ( $Exc.ExceptionName -eq $Item.Name -And $Exc.ExceptionType -eq $Item.CommandType -And $Exc.Module -eq $Item.Source ) {
							$Status = $TrueString
						}
					}
					$ExceptionsSelection += [PSCustomObject]@{
						ID = $i
						Sel = $Status
						ExceptionName = $Item.Name
						ExceptionType = $Item.CommandType
						Module = $Item.Source
					}
				}
				
				[int]$CancelSelID = ($i + 1)
				[int]$DeleteSelID = ($i + 2)
				[int]$FinishSelID = ($i + 3)
				
				# Execute selection menu:
				Do {
					$NoSelection = $True
					ForEach ($Item in $ExceptionsSelection) {
						If ($Item.Sel -eq $TrueString) {
							$NoSelection = $False
						}
					}
					
					$Display = $ExceptionsSelection
					$Display += [PSCustomObject]@{
						ID = [int]$CancelSelID
						Sel = ""
						ExceptionName = "<cancel edits & exit without saving>"
						ExceptionType = ""
						Module = ""
					}
					$Display += [PSCustomObject]@{
						ID = [int]$DeleteSelID
						Sel = ""
						ExceptionName = "<delete $ExceptionFileName & remove all exceptions>"
						ExceptionType = ""
						Module = ""
					}
					If (!($NoSelection)) {
						$Display += [PSCustomObject]@{
							ID = [int]$FinishSelID
							Sel = ""
							ExceptionName = "<finish/confirm>"
							ExceptionType = ""
							Module = ""
						}
						[int]$MaxID = [int]$FinishSelID
					} Else {
						[int]$MaxID = [int]$DeleteSelID
					} # End If/Else (!($NoSelection))
					
					Write-Host "`nExceptions selection: "
					
					$Display | Format-Table | Out-Host
					
					[int]$SelID = Read-Host "Selection ID"
					
					If (([int]$SelID -ge 1) -And ([int]$SelID -le [int]$MaxID)) {
						If (([int]$SelID -ge 1) -And ([int]$SelID -le ($ExceptionsSelection.Count))) {
							ForEach ($MenuItem in $ExceptionsSelection) {
								If ($MenuItem.ID -eq [int]$SelID) {
									# Toggle:
									If ($MenuItem.Sel -eq $TrueString) {
										$MenuItem.Sel = $FalseString
									} Else {
										$MenuItem.Sel = $TrueString
									}
								} # End If ($MenuItem.ID -eq [int]$SelID)
							} # End ForEach ($MenuItem in $ExceptionsSelection)
						} # End If (([int]$SelID -ge 1) -And ([int]$SelID -le ($ExceptionsSelection.Count)))
					} Else {
						Write-Host "SELECTION ERROR: 1-$([int]$MaxID)" -ForegroundColor Red -BackgroundColor Black
					} # End If/Else (([int]$SelID -ge 1) -And ([int]$SelID -le [int]$MaxID))
					
				} Until ( [int]$SelID -eq [int]$CancelSelID -Or [int]$SelID -eq [int]$DeleteSelID -Or (!($NoSelection) -And [int]$SelID -eq [int]$FinishSelID) )
				
				If ([int]$SelID -eq [int]$FinishSelID) {
					$Exceptions = @()
					ForEach ($SelectedItem in $ExceptionsSelection) {
						If ($SelectedItem.Sel -eq $TrueString) {
							$Exceptions += [PSCustomObject]@{
								ExceptionName = $SelectedItem.ExceptionName
								ExceptionType = $SelectedItem.ExceptionType
								Module = $SelectedItem.Module
							}
						}
					}
					Write-Verbose "Saving changes to Exceptions list: $ExceptionFileName"
					$Exceptions | Export-Clixml -Path $ExceptionFile
				} ElseIf ([int]$SelID -eq [int]$DeleteSelID) {
					Write-Verbose "Deleting Exceptions file: $ExceptionFileName"
					Remove-Item -Path $ExceptionFile
					Remove-Variable -Name "Exceptions"
				} ElseIf ([int]$SelID -eq [int]$CancelSelID) {
					Write-Verbose "Cancelled editing Exceptions file and all changes discarded."
				}
			}
			2 {
				Write-Verbose "Skipping $ExceptionFileName"
			}
		} # End switch ($Result)
		
	} Else { # End If ((Test-Path -Path $ExceptionFile))
		
		Write-Verbose "No Exceptions file found."
		
		# Ask user to create exceptions file
		$Title = "Create `"$ExceptionFileName`"?"
		$Info = "An exceptions file is defined in parameters, but the file was not found. Create it?"
		# Use Ampersand & in front of letter to designate that as the choice key. E.g. "&Yes" for Y, "Y&Ellow" for E.
		$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Create & build the file: `"$ExceptionFile`""
		$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip defining any exceptions and automatically load all functions and aliases in file(s): $FileNames"
		$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
		[int]$DefaultChoice = 0
		$Result = $Host.UI.PromptForChoice($Title, $Info, $Options, $DefaultChoice)
		switch ($Result) {
			0 {
				Write-Verbose "Creating Exceptions file"
				
				# Build menu list:
				$Exceptions = @()
				$ExceptionsSelection = @()
				$i = 0
				ForEach ($Item in $CompleteModulesInfo) {
					$i++
					$ExceptionsSelection += [PSCustomObject]@{
						ID = $i
						Sel = $FalseString
						ExceptionName = $Item.Name
						ExceptionType = $Item.CommandType
						Module = $Item.Source
					}
				}
				
				[int]$CancelSelID = ($i + 1)
				[int]$FinishSelID = ($i + 2)
				
				# Execute selection menu:
				Do {
					$NoSelection = $True
					ForEach ($Item in $ExceptionsSelection) {
						If ($Item.Sel -eq $TrueString) {
							$NoSelection = $False
						}
					}
					
					$Display = $ExceptionsSelection
					$Display += [PSCustomObject]@{
						ID = [int]$CancelSelID
						Sel = ""
						ExceptionName = "<cancel>"
						ExceptionType = ""
						Module = ""
					}
					If (!($NoSelection)) {
						$Display += [PSCustomObject]@{
							ID = [int]$FinishSelID
							Sel = ""
							ExceptionName = "<finish/confirm>"
							ExceptionType = ""
							Module = ""
						}
						[int]$MaxID = [int]$FinishSelID
					} Else {
						[int]$MaxID = [int]$CancelSelID
					} # End If/Else (!($NoSelection))
					
					Write-Host "`nExceptions selection: "
					#Write-Host "(marked items will be added to exceptions list)"
					
					$Display | Format-Table | Out-Host
					
					[int]$SelID = Read-Host "Selection ID"
					
					If (([int]$SelID -ge 1) -And ([int]$SelID -le [int]$MaxID)) {
						If (([int]$SelID -ge 1) -And ([int]$SelID -le ($ExceptionsSelection.Count))) {
							ForEach ($MenuItem in $ExceptionsSelection) {
								If ($MenuItem.ID -eq [int]$SelID) {
									# Toggle:
									If ($MenuItem.Sel -eq $TrueString) {
										$MenuItem.Sel = $FalseString
									} Else {
										$MenuItem.Sel = $TrueString
									}
								} # End If ($MenuItem.ID -eq [int]$SelID)
							} # End ForEach ($MenuItem in $ExceptionsSelection)
						} # End If (([int]$SelID -ge 1) -And ([int]$SelID -le ($ExceptionsSelection.Count)))
					} Else {
						Write-Host "SELECTION ERROR: 1-$([int]$MaxID)" -ForegroundColor Red -BackgroundColor Black
					} # End If/Else (([int]$SelID -ge 1) -And ([int]$SelID -le [int]$MaxID))
					
				} Until ( ($NoSelection -And [int]$SelID -eq [int]$CancelSelID) -Or (!($NoSelection) -And (([int]$SelID -eq [int]$CancelSelID) -Or ([int]$SelID -eq [int]$FinishSelID))) )
				
				If ([int]$SelID -eq [int]$FinishSelID) {
					$Exceptions = @()
					ForEach ($SelectedItem in $ExceptionsSelection) {
						If ($SelectedItem.Sel -eq $TrueString) {
							$Exceptions += [PSCustomObject]@{
								ExceptionName = $SelectedItem.ExceptionName
								ExceptionType = $SelectedItem.ExceptionType
								Module = $SelectedItem.Module
							}
						}
					}
					
					$Exceptions | Export-Clixml -Path $ExceptionFile
					
					Write-Verbose "Finished creating Exceptions file: $ExceptionFileName"
				} ElseIf ([int]$SelID -eq [int]$CancelSelID) {
					Write-Verbose "Cancelled Exceptions file creation: $ExceptionFileName"
				}
			}
			1 {
				Write-Verbose "Skipping exceptions, $ExceptionFileName will not be created."
			}
		} # End switch ($Result)
		
	} # End If/Else ((Test-Path -Path $ExceptionFile))
} # End If ($ExceptionFileName)

If ($Exceptions) {
	Write-Verbose "Processing Exceptions file . . ."
	
	$TempList = @()
	ForEach ($OrigList in $CompleteModulesInfo) {
		ForEach ($Excp in $Exceptions) {
			If ( $Excp.ExceptionName -eq $OrigList.Name -And $Excp.ExceptionType -eq $OrigList.CommandType -And $Excp.Module -eq $OrigList.Source ) {
				Write-Verbose "Exception detected, skipping $($Excp.ExceptionName)"
			} Else {
				$TempList += $OrigList
			}
		}
	}
	$CompleteModulesInfo = $TempList
	Remove-Variable -Name TempList
	
} Else {
	Write-Verbose "Including all functions and aliases from all modules."
	#-FunctionsToExport '*' -AliasesToExport '*'
	$FunctionsToExport = '*'
	$AliasesToExport = '*'
}

#-----------------------------------------------------------------------------------------------------------------------

<#
-ModuleList 
Lists all modules that are included in this module.

Enter each module name as a string or as a hash table with ModuleName and ModuleVersion keys. The hash table can also have an optional GUID key. You can combine strings and hash tables in the parameter value.

This key is designed to act as a module inventory. The modules that are listed in the value of this key arent automatically processed.

-FileList
List of all files packaged with this module. As with ModuleList, FileList is an inventory list, and isn't otherwise processed.
#>
$ModuleList = @()
$FileList = @()
ForEach ($Name in $NoFileExtensions) {
	$ModuleList += $Name.NoFileExtension
	$FileList += $Name.File
}

$ModulesFolder = Join-Path -Path $HomePath -ChildPath "Modules"
If ((Test-Path -Path $ModulesFolder)) {
	Remove-Item -Path $ModulesFolder -Recurse
}
$null = New-Item -Path $ModulesFolder -ItemType Directory

ForEach ($Module in $NoFileExtensions) {
	Write-Verbose "Running New-ModuleManifest for $($Module.NoFileExtension):"
	
	# Build Functions & Aliases list:
	$FunctionsToExport = @()
	$AliasesToExport = @()
	ForEach ($ModInfo in $CompleteModulesInfo) {
		# Let's process one module at a time. In case $CompleteModulesInfo is mixed up somehow.
		If ($ModInfo.Source -eq $Module.NoFileExtension) {
			If ($ModInfo.CommandType -eq 'Function') {
				$FunctionsToExport += $ModInfo.Name
			}
			If ($ModInfo.CommandType -eq 'Alias') {
				$AliasesToExport += $ModInfo.Name
			}
		} # End If ($ModInfo.Source -eq $Module)
	} # End ForEach ($ModInfo in $CompleteModulesInfo)
	# End Build Functions & Aliases list
	
	Write-Verbose "Create module $($Module.NoFileExtension) structure and copy files:"
	
	$ModNameFolder = Join-Path -Path $ModulesFolder -ChildPath $Module.NoFileExtension
	$null = New-Item -Path $ModNameFolder -ItemType Directory
	
	$VersionFolder = Join-Path -Path $ModNameFolder -ChildPath $ModuleVersion
	$null = New-Item -Path $VersionFolder -ItemType Directory
	
	$NewModName = "$($Module.NoFileExtension).psm1"
	$NewModPath = Join-Path -Path $VersionFolder -ChildPath $NewModName
	Copy-Item -Path (Join-Path -Path $HomePath -ChildPath $Module.File) -Destination $NewModPath
	
	$NewModManName = "$($Module.NoFileExtension).psd1"
	$NewModManPath = Join-Path -Path $VersionFolder -ChildPath $NewModManName
	
	
	<#
	-Guid <System.Guid>
	To create a new GUID in PowerShell, type `[guid]::NewGuid()`.
	#>
	
	
	<#
	-Guid <System.Guid>
	To create a new GUID in PowerShell, type `[guid]::NewGuid()`.
	
	-ReleaseNotes
	
	-Description  Describes the contents of the module.
	
	-AliasesToExport
	-Description
	-ModuleList 
	Lists all modules that are included in this module.
	
	Enter each module name as a string or as a hash table with ModuleName and
	ModuleVersion keys. The hash table can also have an optional GUID key. You can
	combine strings and hash tables in the parameter value.
	
	This key is designed to act as a module inventory. The modules that are listed in
	the value of this key arent automatically processed.
	-CmdletsToExport
	-FunctionsToExport
	
	-Guid
	-ProjectUri
	-LicenseUri
	-IconUri
	
	-RequiredModules <System.Object[]>
	-RequiredAssemblies <System.String[]>
	
	-PowerShellVersion <System.Version>
	-PowerShellHostVersion <System.Version>
	-CompatiblePSEditions {Desktop | Core}
	-ProcessorArchitecture {None | MSIL | X86 | IA64 | Amd64 | Arm}
	#>
	
	# Root Module
	# Script module or binary module file associated with this manifest. Previous versions of PowerShell called this element the ModuleToProcess.
	# Possible types for the root module can be empty, which creates a Manifest module, the name of a script module (.psm1), or the name of a binary module (.exe or .dll). Placing the name of a module manifest (.psd1) or a script file (.ps1) in this element causes an error.
	# Example: RootModule = 'ScriptModule.psm1'
	
	
	# ModuleList
	# Type: Object[]
	# Specifies all the modules that are packaged with this module. These modules can be entered by name, using a comma-separated string, or as a hash table with ModuleName and GUID keys. The hash table can also have an optional ModuleVersion key. The ModuleList key is designed to act as a module inventory. These modules are not automatically processed.
	# Example: ModuleList = @("SampleModule", "MyModule", @{ModuleName="MyModule"; ModuleVersion="1.0.0.0"; GUID="50cdb55f-5ab7-489f-9e94-4ec21ff51e59"})
	
	# FileList
	# Type: String[]
	# List of all files packaged with this module. As with ModuleList, FileList is an inventory list, and isn't otherwise processed.
	# Example: FileList = @("File1", "File2", "File3")
	
	Write-Verbose "Creating $($Module.NoFileExtension) Module manifest (.psd1 file):"
	
	#New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\Modules\ManageEnvVars_Admin.psd1" -RootModule 'ManageEnvVars_Admin.psm1' -ModuleVersion "1.0" -Author "Kerbalnut" -FunctionsToExport '*' -AliasesToExport '*'
	
	#New-ModuleManifest -Path $NewModManPath -RootModule $NewModName -ModuleVersion $ModuleVersion -Author $Author -FunctionsToExport $FunctionsToExport -AliasesToExport $AliasesToExport -ModuleList $ModuleList -Description $Description -ReleaseNotes $ReleaseNotes -Guid $Guid -ProjectUri $ProjectUri -LicenseUri $LicenseUri -IconUri $IconUri -RequiredModules $RequiredModules -RequiredAssemblies $RequiredAssemblies -PowerShellVersion $PowerShellVersion -PowerShellHostVersion $PowerShellHostVersion -CompatiblePSEditions $CompatiblePSEditions -ProcessorArchitecture $ProcessorArchitecture
	
	$ParamsHashTable = @{
		Path = $NewModManPath
		RootModule = $NewModName
		ModuleVersion = $ModuleVersion
		Author = $Author
		FunctionsToExport = $FunctionsToExport
		AliasesToExport = $AliasesToExport
		ModuleList = $ModuleList
		FileList = $FileList
		Description = $Description
		RequiredModules = $RequiredModules
		RequiredAssemblies = $RequiredAssemblies
		PowerShellVersion = $PowerShellVersion
		PowerShellHostVersion = $PowerShellHostVersion
		CompatiblePSEditions = $CompatiblePSEditions
		ProcessorArchitecture = $ProcessorArchitecture
	}
	If ($ReleaseNotes) {
		$ParamsHashTable += @{
			ReleaseNotes = $ReleaseNotes
		}
	}
	If ($Guid) {
		$ParamsHashTable += @{
			Guid = $Guid
		}
	}
	If ($ProjectUri) {
		$ParamsHashTable += @{
			ProjectUri = $ProjectUri
		}
	}
	If ($LicenseUri) {
		$ParamsHashTable += @{
			LicenseUri = $LicenseUri
		}
	}
	If ($IconUri) {
		$ParamsHashTable += @{
			IconUri = $IconUri
		}
	}
	
	New-ModuleManifest @ParamsHashTable
	
	
	#https://docs.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest?view=powershell-7.2
	
	#https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/Test-ModuleManifest
	
	
	#Test-ModuleManifest myModuleName.psd1
	
	
} # End ForEach ($Module in $CompleteModulesInfo)

Write-Verbose "End Running New-ModuleManifest"

#-----------------------------------------------------------------------------------------------------------------------



Pause



<#
-Guid <System.Guid>
To create a new GUID in PowerShell, type `[guid]::NewGuid()`.

-ReleaseNotes

-Description  Describes the contents of the module.

-AliasesToExport
-Description
-ModuleList 
Lists all modules that are included in this module.

Enter each module name as a string or as a hash table with ModuleName and
ModuleVersion keys. The hash table can also have an optional GUID key. You can
combine strings and hash tables in the parameter value.

This key is designed to act as a module inventory. The modules that are listed in
the value of this key arent automatically processed.
-CmdletsToExport
-FunctionsToExport

-Guid
-ProjectUri
-LicenseUri
-IconUri

-RequiredModules <System.Object[]>
-RequiredAssemblies <System.String[]>

-PowerShellVersion <System.Version>
-PowerShellHostVersion <System.Version>
-CompatiblePSEditions {Desktop | Core}
-ProcessorArchitecture {None | MSIL | X86 | IA64 | Amd64 | Arm}

#>


<#
New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psd1" -ModuleVersion $ModuleVersion -Author $Author


New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psd1" -ModuleVersion "1.0" -Author "Kerbalnut"

New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\Modules\ManageEnvVars\0.1\ManageEnvVars.psd1" -ModuleVersion "1.0" -Author "Kerbalnut" -FunctionsToExport '*' -AliasesToExport '*'



New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\Modules\ManageEnvVars.psd1" -RootModule 'ManageEnvVars.psm1' -ModuleVersion "1.0" -Author "Kerbalnut" -FunctionsToExport '*' -AliasesToExport '*'

New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\Modules\ManageEnvVars_Admin.psd1" -RootModule 'ManageEnvVars_Admin.psm1' -ModuleVersion "1.0" -Author "Kerbalnut" -FunctionsToExport '*' -AliasesToExport '*'
#>


# Root Module
# Script module or binary module file associated with this manifest. Previous versions of PowerShell called this element the ModuleToProcess.
# Possible types for the root module can be empty, which creates a Manifest module, the name of a script module (.psm1), or the name of a binary module (.exe or .dll). Placing the name of a module manifest (.psd1) or a script file (.ps1) in this element causes an error.
# Example: RootModule = 'ScriptModule.psm1'


# ModuleList
# Type: Object[]
# Specifies all the modules that are packaged with this module. These modules can be entered by name, using a comma-separated string, or as a hash table with ModuleName and GUID keys. The hash table can also have an optional ModuleVersion key. The ModuleList key is designed to act as a module inventory. These modules are not automatically processed.
# Example: ModuleList = @("SampleModule", "MyModule", @{ModuleName="MyModule"; ModuleVersion="1.0.0.0"; GUID="50cdb55f-5ab7-489f-9e94-4ec21ff51e59"})

# FileList
# Type: String[]
# List of all files packaged with this module. As with ModuleList, FileList is an inventory list, and isn't otherwise processed.
# Example: FileList = @("File1", "File2", "File3")



#-----------------------------------------------------------------------------------------------------------------------

$FuncParams = @()
$FuncParams += [PSCustomObject]@{
	Module = $a
	ExceptionType = "Function"
	ExceptionName = "New-TaskTrackingInitiativeTEST"
}

$FuncParams += [PSCustomObject]@{
	Module = $a
	ExceptionType = "Alias"
	ExceptionName = "New-ProjectInitTEST"
}

#-----------------------------------------------------------------------------------------------------------------------

#[String[]]$FileNames = @("ManageEnvVars.ps1","ManageEnvVars_Admin.ps1")

ForEach ($file in $FileNames) {
	#$file = "ManageEnvVars.ps1"
	$FullPath = Join-Path -Path $HomePath -ChildPath $file
	#$FullPath = "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.ps1"
	$ModuleInfo = Get-ModuleCommandInfo -Path $FullPath
	$FunctionsList = Get-FunctionsInScript -ModuleCommandInfoObj $ModuleInfo
	$AliasList = Get-AliasesInScript -ModuleCommandInfoObj $ModuleInfo
	$FileFunctionExceptions = @()
	$FileAliasExceptions = @()
	ForEach ($Exception in $Exceptions) {
		If ($Exception.Module -eq $file) {
			If ($Exception.ExceptionType -eq 'Function') {
				$FileFunctionExceptions += $Exception.ExceptionName
			} ElseIf ($Exception.ExceptionType -eq 'Alias') {
				$FileAliasExceptions += $Exception.ExceptionName
			} Else {
				Write-Warning "Wrong ExceptionType: $($Exception.ExceptionType)"
				Write-Error "Wrong ExceptionType: $($Exception.ExceptionType)"
			} # End If/ElseIf ($Exception.ExceptionType)
		} Else {
			Write-Verbose "Skipping $($Exception.Module) exception."
		} # End If ($Exception.Module -eq $file)
	} # End ForEach ($Exception in $Exceptions)
	
	Do {
		$i = 0
		$SelectionArray = @()
		ForEach ($Exception in $FileFunctionExceptions) {
			$i++
			$SelectionArray += [PSCustomObject]@{
				ID = $i
				Name = $Exception
				Exception = $Ex
			}
		} # End ForEach ($Exception in $FileFunctionExceptions)
		ForEach ($func in $FunctionsList) {
			$ExceptionStatus = $False
			ForEach ($Exception in $FileFunctionExceptions) {
				If ($Exception -eq $func) {
					$ExceptionStatus = $True
				}
			} # End ForEach ($Exception in $FileFunctionExceptions)
			$i++
			$SelectionArray += [PSCustomObject]@{
				ID = $i
				Name = $func
				Exception = $ExceptionStatus
			}
		} # End ForEach ($func in $FunctionsList)
		$i++
		$SelectionArray += [PSCustomObject]@{
			ID = $i
			Name = "<done/cancel>"
		}
		$SelectionArray | Format-Table
		$SelectedID = Read-Host -Prompt "Select ID"
		
	} Until ($SelectedID -ge 1 -And $SelectedID -le ($FunctionsList.Count + 1) )
	
}

Write-Verbose "Building variables hash table:"
$Method = 0
switch ($Method) {
	0 {
		$FuncParams = @{TempFileSuffix = $TempFileSuffix}
	}
	1 {
		$FuncParams = @{}
		If ($TempFileSuffix) {$FuncParams += @{TempFileSuffix = $TempFileSuffix}}
	}
	Default {Throw "Horrible error: Building vars hashtable, wrong `$Method selected: '$Method'"}
} # End switch


$FuncParams = @{
	TempFileSuffix = $TempFileSuffix
}

Write-Host "End of $ScriptName script."
# If running in the console, wait for input before closing.
if ($Host.Name -eq "ConsoleHost")
{
    Write-Host "Press any key to continue..."
    $Host.UI.RawUI.FlushInputBuffer()   # Make sure buffered input doesn't "press a key" and skip the ReadKey().
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}


Pause






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








Pause




<#
-Guid <System.Guid>
To create a new GUID in PowerShell, type `[guid]::NewGuid()`.

-ReleaseNotes

-Description  Describes the contents of the module.

-AliasesToExport
-Description
-ModuleList 
Lists all modules that are included in this module.

Enter each module name as a string or as a hash table with ModuleName and
ModuleVersion keys. The hash table can also have an optional GUID key. You can
combine strings and hash tables in the parameter value.

This key is designed to act as a module inventory. The modules that are listed in
the value of this key arent automatically processed.
-CmdletsToExport
-FunctionsToExport

-Guid
-ProjectUri
-LicenseUri
-IconUri

-RequiredModules <System.Object[]>
-RequiredAssemblies <System.String[]>

-PowerShellVersion <System.Version>
-PowerShellHostVersion <System.Version>
-CompatiblePSEditions {Desktop | Core}
-ProcessorArchitecture {None | MSIL | X86 | IA64 | Amd64 | Arm}

#>

New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psd1" -ModuleVersion $ModuleVersion -Author $Author


New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psd1" -ModuleVersion "1.0" -Author "Kerbalnut"

New-ModuleManifest -Path "$Home\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\Modules\ManageEnvVars\0.1\ManageEnvVars.psd1" -ModuleVersion "1.0" -Author "Kerbalnut" -FunctionsToExport '*' -AliasesToExport '*'



