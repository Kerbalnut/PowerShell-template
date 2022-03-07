
#-----------------------------------------------------------------------------------------------------------------------
Function Get-ModuleCommandInfo {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	.EXAMPLE
	Get-ModuleCommandInfo -Path "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psm1"
	
	$Path = "C:\Users\Grant\Documents\GitHub\PowerShell-template\04 Module Template\ModuleTemplate\ManageEnvVars.psm1"
	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $True, Position = 0,
		           ValueFromPipeline = $True, 
		           ValueFromPipelineByPropertyName = $True,
		           HelpMessage = "Path to ...")]
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
	
	$NewPath = $NoExtension + "_GetFunctions.psm1"
	
	Copy-Item -Path $Path -Destination $NewPath
	
	Import-Module $NewPath
	
	$ModuleInfo = Get-Command -Module $FileNameNoExtension
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return $ModuleInfo
} # End of Get-ModuleCommandInfo function.
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






