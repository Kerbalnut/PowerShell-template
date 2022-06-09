
#-----------------------------------------------------------------------------------------------------------------------
Function Set-PowerState {
	<#
	.PARAMETER DisableWake
	From the original StackOverflow answer:
	Note: In my testing, the -DisableWake option did not make any distinguishable difference that I am aware of. I was still capable of using the keyboard and mouse to wake the computer, even when this parameter was set to $True.
	
	About disableWakeEvent... This parameter can prevent SetWaitableTimer() to awake the computer. SetWaitableTimer() used by Task Scheduler (at least). See details here: msdn.microsoft.com/en-us/library/windows/desktop/aa373235.aspx – CoolCmd
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
		
		#[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'PowerState')]
		#[System.Windows.Forms.PowerState]$PowerState = [System.Windows.Forms.PowerState]::Suspend,
		
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
		
		Add-Type -AssemblyName System.Windows.Forms
		
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
Function Format-ShortTimeString {
	<#
	.EXAMPLE
	Format-ShortTimeString -Seconds 59
	Format-ShortTimeString -Seconds 60
	Format-ShortTimeString -Seconds 61
	Format-ShortTimeString -Seconds 299
	Format-ShortTimeString -Seconds 61 -Round
	Format-ShortTimeString -Seconds 299 -Round
	Format-ShortTimeString -Seconds 3600
	Format-ShortTimeString -Seconds 5400
	Format-ShortTimeString -Seconds 7200
	Format-ShortTimeString -Seconds 86399
	Format-ShortTimeString -Seconds 86400
	Format-ShortTimeString -Seconds 86401
	Format-ShortTimeString -Seconds 88200
	Format-ShortTimeString -Seconds 90000
	Format-ShortTimeString -Seconds 91800
	Format-ShortTimeString -Seconds 93600
	
	Format-ShortTimeString -Seconds 86329
	Format-ShortTimeString -Seconds 86330
	Format-ShortTimeString -Seconds 86331
	Format-ShortTimeString -Seconds 86399
	Format-ShortTimeString -Seconds 86400
	Format-ShortTimeString -Seconds 86429
	Format-ShortTimeString -Seconds 86430
	Format-ShortTimeString -Seconds 86431
	
	Format-ShortTimeString -Seconds 86329 -Round
	Format-ShortTimeString -Seconds 86330 -Round
	Format-ShortTimeString -Seconds 86331 -Round
	Format-ShortTimeString -Seconds 86399 -Round
	Format-ShortTimeString -Seconds 86400 -Round
	Format-ShortTimeString -Seconds 86429 -Round
	Format-ShortTimeString -Seconds 86430 -Round
	Format-ShortTimeString -Seconds 86431 -Round
	
	Format-ShortTimeString -Seconds 93529
	Format-ShortTimeString -Seconds 93530
	Format-ShortTimeString -Seconds 93531
	Format-ShortTimeString -Seconds 93599
	Format-ShortTimeString -Seconds 93600
	Format-ShortTimeString -Seconds 93629
	Format-ShortTimeString -Seconds 93630
	Format-ShortTimeString -Seconds 93631
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
		[Alias('Second','s')]
		[int]$Seconds,
		
		[Switch]$Round
	)
	
	$TS = New-TimeSpan -Seconds $Seconds
	
	If ($TS.TotalSeconds -le 60) {
		$Result = "$([math]::Round($TS.TotalSeconds,1))" + "s"
	} Else {
		If ($TS.TotalMinutes -lt 60) {
			If ($TS.Seconds -eq 0 -Or $Round) {
				$Result = "$([math]::Round($TS.TotalMinutes,1))" + "m"
			} Else {
				$Result = "$($TS.Minutes)m $($TS.Seconds)s"
			}
		} Else {
			If ($TS.TotalHours -lt 24) {
				If ($([math]::Round($TS.TotalMinutes,0)) -eq 1440) {
					$Result = "24h"
				} Else {
					If ($TS.Minutes -eq 0) {
						$Result = "$($TS.Hours)h"
					} Else {
						$Result = "$($TS.Hours)h $($TS.Minutes)m"
					}
				}
			} ElseIf ($([math]::Round($TS.TotalMinutes,0)) -eq 1440) {
				$Result = "24h"
			} Else {
				If ($TS.Minutes -eq 0) {
					If ($TS.Hours -eq 0) {
						$Result = "$($TS.Days)d"
					} Else {
						$Result = "$($TS.Hours)h $($TS.Minutes)m"
						$Result = "$($TS.Days)d $($TS.Hours)h"
					}
				} Else {
					If ($TS.Hours -eq 0) {
						$Result = "$($TS.Days)d $($TS.Minutes)m"
					} Else {
						$Result = "$($TS.Days)d $($TS.Hours)h $($TS.Minutes)m"
					} # End If ($TS.Hours -eq 0)
				} # End If ($TS.Minutes -eq 0)
			} # End If ($TS.TotalHours -lt 24)
		} # End If ($TS.TotalMinutes -lt 60)
	} # End If ($TS.TotalSeconds -le 60)
	
	Return $Result
} # End 
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
	.PARAMETER TicsBeforeCounterResync
	For methods that rely on wait operations from PowerShell loops, this value will determine how many seconds into the time count loop before this function corrects itself based on end time calculated at the beginning of execution.
	.NOTES
	Some extra info about this function, like it's origins, what module (if any) it's apart of, and where it's from.
	
	Maybe some original author credits as well.
	.EXAMPLE
	Start-SleepTimer -Hours 2 -Minutes 30 -Action 'sleep'
	Starts a sleep countdown timer for 2 hours and 30 minutes from now. 
	
	Start-SleepTimer -Hours 2 -Minutes 30 -Action 'sleep' -TicsBeforeCounterResync 59
	Start-SleepTimer -Hours 2 -Minutes 30 -Action 'sleep' -TicsBeforeCounterResync 9
	.EXAMPLE
	Start-SleepTimer -TimerDuration (New-TimeSpan -Seconds 10) -TicsBeforeCounterResync 9 -Verbose
	Sets a sleep timer for 10 seconds from now. The default action is to sleep/suspend the system, so the -Action parameter is not required.
	
	Start-SleepTimer -TimerDuration (New-TimeSpan -Seconds 60) -TicsBeforeCounterResync 9 -Verbose
	.EXAMPLE
	Start-SleepTimer -DateTime (Get-Date -Hour (12 + 8) -Minute 0 -Second 0) -Verbose -Action 'Hibernate'
	Sets a hibernate timer for 8 PM.
	.LINK
	https://ephos.github.io/posts/2018-8-20-Timers
	#>
	[Alias("Set-SleepTimer")]
	#Requires -Version 3
	#[CmdletBinding(DefaultParameterSetName = 'Timer')]
	[CmdletBinding(DefaultParameterSetName = 'HoursMins')]
	Param(
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'DateTime')]
		[ValidateNotNullOrEmpty()]
		[Alias('SleepTime')]
		[DateTime]$DateTime,
		
		[Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'Timer')]
		[ValidateNotNullOrEmpty()]
		[Alias('SleepTimer','Timer')]
		[TimeSpan]$TimerDuration = (New-TimeSpan -Hours 2 -Minutes 0),
		#[TimeSpan]$TimerDuration = (New-TimeSpan -Minutes 3),
		#[TimeSpan]$TimerDuration = (New-TimeSpan -Seconds 10),
		
		[Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'HoursMins')]
		[Int32]$Hours,
		
		[Parameter(Mandatory = $True, Position = 1, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'HoursMins')]
		[Alias('Mins')]
		[Int32]$Minutes,
		
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)]
		[ValidateSet('Sleep','Suspend','Hibernate')]
		[Alias('PowerAction')]
		[String]$Action = 'Sleep',
		
		[Switch]$DisableWake,
		[Switch]$Force,
		
		[int]$TicsBeforeCounterResync = 299
		#[int]$TicsBeforeCounterResync = 9
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	$StartTime = Get-Date
	
	#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Minutes 1)
	#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Minutes 5)
	#[DateTime]$DateTime = (Get-Date) + [TimeSpan](New-TimeSpan -Hours 2 -Minutes 30)
	
	If ($DateTime) {
		Write-Verbose "ParameterSet selected: 'DateTime'"
		[DateTime]$EndTime = Get-Date -Date $DateTime -Millisecond 0
		[TimeSpan]$TimerDuration = [DateTime]$EndTime - (Get-Date -Date $StartTime -Millisecond 0)
	} ElseIf ($Hours -Or $Minutes) {
		Write-Verbose "ParameterSet selected: 'HoursMins'"
		
		$TimeSpanParams = @{}
		If ($Hours) { $TimeSpanParams += @{Hours = $Hours} }
		If ($Minutes) { $TimeSpanParams += @{Minutes = $Minutes} }
		
		$TimerDuration = New-TimeSpan @TimeSpanParams @CommonParameters
		[DateTime]$EndTime = [DateTime]$StartTime + [TimeSpan]$TimerDuration
	} ElseIf ($TimerDuration) {
		Write-Verbose "ParameterSet selected: 'Timer'"
		[DateTime]$EndTime = [DateTime]$StartTime + [TimeSpan]$TimerDuration
	}
	Write-Verbose "`$EndTime = $EndTime"
	Write-Verbose "`$TimerDuration = $TimerDuration"
	
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
			
			$RefreshRate = 1 # in seconds
			$RefreshRateFast = 200
			$RefreshRateSlow = 5
			#$TicsBeforeCounterResync = 9
			#$TicsBeforeCounterResync = 59
			#$TicsBeforeCounterResync = 299
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
				#>
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
			#$HeaderLineBreaks = Get-NewlineSpacer -LineBreaks $HeaderBreaks
			
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
					$PercentageComplete = ($i/$Seconds).ToString("P")
					$PercentageComplete2 = "$( [math]::Round(( ($i/$Seconds)*100 ),2) ) %"
					Write-Progress -Activity "Counting to $Seconds" -Status "Current Count: $i/$Seconds - $PercentageComplete - $PercentageComplete2" -PercentComplete (($i/$Seconds)*100) -CurrentOperation "Counting ..."
					If ($i -ne $Seconds) {
						Start-Sleep -Seconds 1
					}
				}
				Write-Progress -Activity "Counting to $Seconds" "Current Count: $Seconds/$Seconds" -PercentComplete 100 -CurrentOperation "Complete!" #-Completed
				Start-Sleep -Seconds 2
			} # End Function Get-TimerProgressBarTest
			#Get-TimerProgressBarTest -Seconds 777
			
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
			$OrigSecondsToCount = $TimerDuration.TotalSeconds
			$TimeLeft = $TimerDuration
			$OrigTimerDuration = $TimerDuration
			$TimerDurationWhole = $TimerDuration
			$EndTimeShort = Get-Date -Date $EndTime -Format t
			$EndTimeLong = Get-Date -Date $EndTime -Format T
			$StartTimeShort = Get-Date -Date $StartTime -Format t
			$StartTimeLong = Get-Date -Date $StartTime -Format T
			$SecondsCounter = 0
			$i = 0
			
			$CounterMethod = 0
			switch ($CounterMethod) {
				0 {
					Write-Verbose "Write-Progress method:"
					$ActivityName = "$ActionVerb device at $EndTimeLong - (Ctrl + C to Cancel)"
					$j = 0 # Clock re-sync counter, used with $TicsBeforeCounterResync
					$k = 0 # Re-sync operation counter
					$FloatTimeTotal = 0
					$ResyncTimeLabel = Format-ShortTimeString -Seconds $TicsBeforeCounterResync -Round
					do {
						#Clear-Host #cls
						
						#$i = $i + $RefreshRate
						$SecondsCounter = $SecondsCounter + $RefreshRate
						$TimeLeft = New-TimeSpan -Seconds ($SecondsToCount - $SecondsCounter)
						$TimeElapsed = New-TimeSpan -Seconds ($SecondsCounter)
						
						#https://devblogs.microsoft.com/scripting/use-powershell-and-conditional-formatting-to-format-time-spans/
						#$CountdownLabel = "{0:c}" -f $TimeLeft
						$CountdownLabel = "{0:g}" -f $TimeLeft
						#$CountdownLabel = "{0:G}" -f $TimeLeft
						
						$CountUpLabel = "{0:g}" -f $TimeElapsed
						
						$PercentageComplete = ($SecondsCounter / $SecondsToCount).ToString("P")
						
						If ($j -lt $TicsBeforeCounterResync) {
							$j++
							$Status = "Counting at $StartTimeShort for $OrigTimerDuration every $RefreshRate second(s) from $TimerDurationWhole down to $EndTimeShort before $ActionVerb..."
							If ($SecondsToCount -ne $OrigSecondsToCount) {
								$Diff = $SecondsToCount - $OrigSecondsToCount
								If ($Diff -ge 0) {$Diff = "+$Diff"}
								$SecondsToCountLabel = "$SecondsToCount (orig $OrigSecondsToCount $Diff)"
							} Else {
								$SecondsToCountLabel = $SecondsToCount
								#$SecondsToCountLabel = ""
							}
						} Else {
							$j = 0
							$k++
							
							#[TimeSpan]$NewTimerDurationWhole = [DateTime]$EndTime - (Get-Date -Millisecond 0)
							[TimeSpan]$NewTimerDuration = [DateTime]$EndTime - (Get-Date)
							$NewSecondsToCount = $NewTimerDuration.TotalSeconds
							[TimeSpan]$NewTimerDurationWhole = New-TimeSpan -Seconds ([math]::Round($NewSecondsToCount,0))
							$TimeLeft = $NewTimerDuration
							
							$FloatSeconds = [math]::Round(( $NewSecondsToCount - ($SecondsToCount - $SecondsCounter) ),1)
							$SecondsCounterRemaining = $SecondsToCount - $SecondsCounter
							
							If ($NewSecondsToCount -lt $SecondsCounterRemaining) {
								$Status = "Re-syncing timer with $EndTimeShort deadline... (done $k times) - Shortening float counter by $([math]::Round(( $SecondsCounterRemaining - $NewSecondsToCount ),1))"
							} ElseIf ($NewSecondsToCount -gt $SecondsCounterRemaining) {
								$Status = "Re-syncing timer with $EndTimeShort deadline... (done $k times) - Lengthening float counter by $([math]::Round(( $NewSecondsToCount - $SecondsCounterRemaining ),1))"
							} ElseIf ($NewSecondsToCount -eq $SecondsCounterRemaining) {
								$Status = "Re-syncing timer with $EndTimeShort deadline... (done $k times) - No adjustment needed!"
							}
							
							$FloatTimeTotal = [math]::Round(( $FloatTimeTotal + $FloatSeconds ),1)
							[TimeSpan]$TimerDuration = [TimeSpan]$NewTimerDuration
							[TimeSpan]$TimerDurationWhole = [TimeSpan]$NewTimerDurationWhole
							
							$FloatTimeWhole = [math]::Round($FloatSeconds,0)
							
							If ($FloatTimeWhole -ge 1 -Or $FloatTimeWhole -le -1) {
								#$SecondsCounterRemaining
								#$SecondsToCount = $SecondsToCount + $FloatTimeWhole
								$SecondsToCount = ( [math]::Round($NewSecondsToCount,0) + $SecondsCounter )
							}
							
						} # End If/Else ($j -lt $TicsBeforeCounterResync)
						
						If ($k -gt 0) {
							$CurrentOp = "$ActionVerb device in $CountdownLabel - $CountUpLabel - $PercentageComplete - Count: $SecondsCounter/$SecondsToCountLabel - Re-sync: $j/$TicsBeforeCounterResync, done $k time(s) every $ResyncTimeLabel, drift: $FloatSeconds cumulative: $FloatTimeTotal"
						} Else {
							$CurrentOp = "$ActionVerb device in $CountdownLabel - $CountUpLabel - $PercentageComplete - Count: $SecondsCounter/$SecondsToCountLabel - Re-sync: $j/$TicsBeforeCounterResync"
						}
						
						Write-Progress -Id $ProgressBarId -Activity $ActivityName -PercentComplete (($SecondsCounter / $SecondsToCount)*100) -Status $Status -CurrentOperation $CurrentOp
						
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
						
						Start-Sleep -Seconds $RefreshRate
						
						#} until ($SecondsCounter -ge ($SecondsToCount - 30) )
					} until ($SecondsCounter -ge $SecondsToCount)
					
					Write-Progress -Id $ProgressBarId -Activity $ActivityName -Completed
					
					Write-Verbose "Progress bar counter completed."
					
				}
				Default {}
			} # End switch ($CounterMetod)
			
			Write-Verbose "$ActionVerb computer . . ."
			
			#PAUSE
			
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






