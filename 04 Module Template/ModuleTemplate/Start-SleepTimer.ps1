
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
		Return $Result
	} # End End block
} # End Function Set-PowerState
#-----------------------------------------------------------------------------------------------------------------------

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
		
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
		[ValidateSet('Sleep','Suspend','Hibernate')]
		[Alias('PowerAction')]
		[String]$Action = 'Sleep',
		
		[Switch]$DisableWake,
		[Switch]$Force
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	$StartTime = Get-Date
	
	[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Minutes 1)
	#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Minutes 5)
	#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Hours 2 -Minutes 30)
	
	If ($Hours -Or $Minutes) {
		
		$TimeSpanParams = @{}
		If ($Hours) { $TimeSpanParams += @{Hours = $Hours} }
		If ($Minutes) { $TimeSpanParams += @{Minutes = $Minutes} }
		
		$TimerDuration = New-TimeSpan @TimeSpanParams @CommonParameters
		
	}
	
	If ($TimerDuration) {
		[DateTime]$EndTime = [DateTime]$StartTime + [TimeSpan]$TimerDuration
	} ElseIf ($DateTime) {
		[DateTime]$EndTime = Get-Date -Date $DateTime -Millisecond 0
		[TimeSpan]$TimerDuration = [DateTime]$EndTime - (Get-Date -Date $StartTime -Millisecond 0)
	}
	
	$SetPowerStateParams = @{
		DisableWake = $DisableWake
		Force = $Force
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	$Method = 0
	switch ($Method) {
		0 {
			Write-Verbose "PowerShell Start-Sleep wait method:"
			#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
			
			$RefreshRate = 1
			$RefreshRateFast = 200
			$RefreshRateSlow = 5
			$HeaderBreaks = 5
			$ProgressBarId = 0
			
			If ($Action -eq 'Sleep' -Or $Action -eq 'Suspend') {
				$ActionVerb = "Sleeping"
			} ElseIf ($Action -eq 'Hibernate') {
				$ActionVerb = "Hibernating"
			}
			
			Function Get-NewlineSpacer([int]$LineBreaks,[switch]$Testing) {
				<#
				.EXAMPLE
				Get-NewlineSpacer -LineBreaks 0 -Testing
				Get-NewlineSpacer -LineBreaks 1 -Testing
				Get-NewlineSpacer -LineBreaks 2 -Testing
				Get-NewlineSpacer -LineBreaks 5 -Testing
				.EXAMPLE
				$NewlineSpace = Get-NewlineSpacer -LineBreaks 5
				$HeaderLineBreaks = Get-NewlineSpacer -LineBreaks $HeaderBreaks
				#>`
				$NewlineSpace = ""
				If ($LineBreaks -gt 0) {
					for ($i = 0; $i -lt $LineBreaks; $i++) {
						$NewlineSpace += "`n"
					}
				}
				If ($Testing) {
					Write-Host "LineBreaks: `'$LineBreaks`' - Start"
					Write-Host "$($NewlineSpace)End"
				} Else {
					Return $NewlineSpace
				}
			} # End Function Get-NewlineSpacer
			$HeaderLineBreaks = Get-NewlineSpacer -LineBreaks $HeaderBreaks
			
			Function Get-ProgressBarTest {
				<#
				.LINK
				https://thinkpowershell.com/how-to-make-a-powershell-progress-bar/
				#>
				For ($i=0; $i -le 100; $i++) {
					Start-Sleep -Milliseconds 20
					Write-Progress -Activity "Counting to 100" -Status "Current Count: $i" -PercentComplete $i -CurrentOperation "Counting ..."
				}
			} # End Function Get-ProgressBarTest
			#Get-ProgressBarTest
			
			Function Get-TimerProgressBarTest($Seconds) {
				For ($i=0; $i -le $Seconds; $i++) {
					Write-Progress -Activity "Counting to $Seconds" -Status "Current Count: $i/$Seconds" -PercentComplete (($i/$Seconds)*100) -CurrentOperation "Counting ..."
					If ($i -ne $Seconds) {
						Start-Sleep -Seconds 1
					}
				}
				Write-Progress -Activity "Counting to $Seconds" "Current Count: $Seconds/$Seconds" -PercentComplete 100 -CurrentOperation "Complete!" #-Completed
				Start-Sleep -Seconds 2
			} # End Function Get-TimerProgressBarTest
			#Get-TimerProgressBarTest -Seconds 5
			
			Function Get-NestedProgressBarTest {
				<#
				.LINK
				https://thinkpowershell.com/how-to-make-a-powershell-progress-bar/
				#>
				For ($i=0; $i -le 10; $i++) {
					Start-Sleep -Milliseconds 1
					Write-Progress -Id 1 -Activity "First Write Progress" -Status "Current Count: $i" -PercentComplete $i -CurrentOperation "Counting ..."
					
					For ($j=0; $j -le 100; $j++) {
						Start-Sleep -Milliseconds 1
						Write-Progress -Id 2 -Activity "Second Write Progress" -Status "Current Count: $j" -PercentComplete $j -CurrentOperation "Counting ..."
					}
				}
			} # End Function Get-NestedProgressBarTest
			#Get-NestedProgressBarTest
			
			$SecondsToCount = $TimerDuration.TotalSeconds
			$TimeLeft = $TimerDuration
			$EndTimeShort = Get-Date -Date $EndTime -Format t
			$EndTimeLong = Get-Date -Date $EndTime -Format T
			$SecondsCounter = 0
			do {
				Clear-Host #cls
				
				#$TimeLeft = $TimeLeft - (New-TimeSpan -Seconds 1)
				#$TimeLeft = $TimeLeft - (New-TimeSpan -Seconds $RefreshRate)
				
				#$SecondsCounter = $SecondsCounter + 1
				$SecondsCounter = $SecondsCounter + $RefreshRate
				#$SecondsToCount = $SecondsToCount - 1
				#$SecondsToCount = $SecondsToCount - $RefreshRate
				#$SecondsLeft = ($SecondsToCount - $SecondsCounter)
				#$TimeLeft = New-TimeSpan -Seconds $SecondsToCount
				$TimeLeft = New-TimeSpan -Seconds ($SecondsToCount - $SecondsCounter)
				
				#https://devblogs.microsoft.com/scripting/use-powershell-and-conditional-formatting-to-format-time-spans/
				#$CountdownLabel = "{0:c}" -f $TimeLeft
				$CountdownLabel = "{0:g}" -f $TimeLeft
				#$CountdownLabel = "{0:G}" -f $TimeLeft
				
				Write-Progress -Id $ProgressBarId -Activity "$ActionVerb device at $EndTimeLong" -Status "$ActionVerb device in $CountdownLabel - ($SecondsCounter / $SecondsToCount)" -PercentComplete (($SecondsCounter / $SecondsToCount)*100) -CurrentOperation "Counting down $TimerDuration to $EndTimeShort before $ActionVerb..."
				
				<#
				Write-Progress
				     [-Activity] <String>
				     [[-Status] <String>]
				     [[-Id] <Int32>]
				     [-PercentComplete <Int32>]
				     [-SecondsRemaining <Int32>]
				     [-CurrentOperation <String>]
				     [-ParentId <Int32>]
				     [-Completed]
				     [-SourceId <Int32>]
				     [<CommonParameters>]
				#>
				
				#Start-Sleep -Seconds 1
				Start-Sleep -Seconds $RefreshRate
				
				#$i = $i - 1
				$i = $i + $RefreshRate
				
			} until ($i -ge ($SecondsToCount - 30) )
			
			PAUSE
			
			Set-PowerState -Action $Action @SetPowerStateParams @CommonParameters
			
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






