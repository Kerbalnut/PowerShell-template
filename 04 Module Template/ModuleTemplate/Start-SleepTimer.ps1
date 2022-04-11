
#-----------------------------------------------------------------------------------------------------------------------
Function Start-SleepTimer {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.PARAMETER TimerDuration
	Takes [TimeSpan] type input values. For example, like the output given by `New-TimeSpan` command.
	By default this function uses: (New-TimeSpan -Hours 2 -Minutes 30)
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	.LINK
	https://ephos.github.io/posts/2018-8-20-Timers
	#>
	[Alias("Set-SleepTimer")]
	#Requires -Version 3
	[CmdletBinding(DefaultParameterSetName = 'Timer')]
	Param(
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'DateTime')]
		[ValidateNotNullOrEmpty()]
		[Alias('SleepTime')]
		[DateTime]$DateTime,
		
		[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'Timer')]
		[ValidateNotNullOrEmpty()]
		[Alias('SleepTimer','Timer')]
		[TimeSpan]$TimerDuration = (New-TimeSpan -Hours 2 -Minutes 30),
		
		[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'HoursMins')]
		[Int32]$Hours,
		
		[Parameter(Mandatory = $False, Position = 1, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'HoursMins')]
		[Alias('Mins')]
		[Int32]$Minutes,
		
		[Switch]$Force
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	#-----------------------------------------------------------------------------------------------------------------------
	Function Set-PowerState {
		<#
		.EXAMPLE
		Set-PowerState -Action Sleep
		.EXAMPLE
		Set-PowerState -Action Hibernate -DisableWake -Force
		.LINK
		https://stackoverflow.com/questions/20713782/suspend-or-hibernate-from-powershell
		.LINK
		https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.application.setsuspendstate?redirectedfrom=MSDN&view=windowsdesktop-6.0#System_Windows_Forms_Application_SetSuspendState_System_Windows_Forms_PowerState_System_Boolean_System_Boolean_
		#>
		[CmdletBinding(DefaultParameterSetName = 'StringName')]
		Param(
			[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'StringName')]
			[ValidateSet('Sleep','Suspend','Hibernate')]
			[Alias('PowerAction')]
			[String]$Action = 'Sleep',
			
			[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'PowerState')]
			[System.Windows.Forms.PowerState]$PowerState = [System.Windows.Forms.PowerState]::Suspend,
			
			[Switch]$DisableWake,
			[Switch]$Force
		) # End Param
		Begin {
			$FunctionName = $MyInvocation.MyCommand
			
			Write-Verbose -Message "[$FunctionName]: Executing Begin block"
			
			If (!$DisableWake) { $DisableWake = $false }
			If (!$Force) { $Force = $false }
			
			Write-Verbose -Message ('Force is: {0}' -f $Force)
			Write-Verbose -Message ('DisableWake is: {0}' -f $DisableWake)
			
			If ($Action -eq 'Sleep' -Or $Action -eq 'Suspend') {
				[System.Windows.Forms.PowerState]$PowerState = [System.Windows.Forms.PowerState]::Suspend
			}
			If ($Action -eq 'Hibernate') {
				[System.Windows.Forms.PowerState]$PowerState = [System.Windows.Forms.PowerState]::Hibernate
			}
			
			Write-Verbose "PowerState: `'$PowerState`'"
		} # End Begin
		Process {
			Write-Verbose -Message "[$FunctionName]: Executing Process block"
			Try {
				$Result = [System.Windows.Forms.Application]::SetSuspendState($PowerState, $Force, $DisableWake)
			} Catch {
				Write-Error -Exception $_
			}
		} # End Process
		End {
			Write-Verbose -Message "[$FunctionName]: Executing End block"
		} # End End block
	} # End Function Set-PowerState
	#-----------------------------------------------------------------------------------------------------------------------
	
	If ($Hours -Or $Minutes) {
		
		$TimeSpanParams = @{}
		If ($Hours) { $TimeSpanParams += @{Hours = $Hours} }
		If ($Minutes) { $TimeSpanParams += @{Minutes = $Minutes} }
		
		$TimerDuration = New-TimeSpan @TimeSpanParams @CommonParameters
		
	}
	
	
	$Method = 0
	switch ($Method) {
		0 {
			Write-Verbose "PowerShell Start-Sleep wait method:"
			#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			
			$RefreshRate = 5
			$HeaderBreaks = 5
			
			Function Get-HeaderSpacer($HeaderBreaks,[switch]$Testing) {
				<#
				.EXAMPLE
				Get-HeaderSpacer -HeaderBreaks 0 -Testing
				Get-HeaderSpacer -HeaderBreaks 1 -Testing
				Get-HeaderSpacer -HeaderBreaks 2 -Testing
				Get-HeaderSpacer -HeaderBreaks 5 -Testing
				.EXAMPLE
				$HeaderLineBreaks = Get-HeaderSpacer -HeaderBreaks 5
				#>
				$HeaderLineBreaks = ""
				If ($HeaderBreaks -gt 0) {
					for ($i = 0; $i -lt $HeaderBreaks; $i++) {
						$HeaderLineBreaks += "`n"
					}
				}
				If ($Testing) {
					Write-Host "Headerbreaks: `'$HeaderBreaks`' - Start"
					Write-Host "$($HeaderLineBreaks)End"
				} Else {
					Return $HeaderLineBreaks
				}
			} # End Function Get-HeaderSpacer
			
			$HeaderLineBreaks = Get-HeaderSpacer -HeaderBreaks $HeaderBreaks
			
			
			
			do {
				
			} until ($a -eq 0)
			
			
			#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		}
		1 {
			Write-Verbose "Using [Stopwatch] object method:"
			#https://ephos.github.io/posts/2018-8-20-Timers
			
			#Create a Stopwatch
			$stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
			
			#You can use the $stopWatch variable to see it
			$stopWatch
			
			#Go ahead and check out the methods and properties it has
			$stopWatch | Get-Member
			
		}
		2 {
			Write-Verbose "Scheduled Task method:"
			
		}
		Default {
			Write-Error "Incorrectly definfed method: '$Method'"
			Throw "Incorrectly definfed method: '$Method'"
		}
	}
	
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	Return
} # End of Start-SleepTimer function.
Set-Alias -Name 'Set-SleepTimer' -Value 'Start-SleepTimer'
#-----------------------------------------------------------------------------------------------------------------------







#-----------------------------------------------------------------------------------------------------------------------
Function Stop-SleepTimer {
	<#
	.SYNOPSIS
	Single-line summary.
	.DESCRIPTION
	Multiple paragraphs describing in more detail what the function is, what it does, how it works, inputs it expects, and outputs it creates.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	#>
	[Alias("Reset-SleepTimer", "Disable-SleepTimer")]
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
} # End of Stop-SleepTimer function.
Set-Alias -Name 'Reset-SleepTimer' -Value 'Stop-SleepTimer'
Set-Alias -Name 'Disable-SleepTimer' -Value 'Stop-SleepTimer'
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
		[ValidateSet("default", "powershell.exe", "Code.exe", "VSCodium.exe")]
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






