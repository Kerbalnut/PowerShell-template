
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
	#>
	[Alias("Set-SleepTimer")]
	#Requires -Version 3
	#[CmdletBinding()]
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
		[Int32]$Minutes
		
	)
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	$CommonParameters = @{
		Verbose = [System.Management.Automation.ActionPreference]$VerbosePreference
		Debug = [System.Management.Automation.ActionPreference]$DebugPreference
	}
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	If ($Hours -Or $Minutes) {
		
		$TimeSpanParams = @{}
		If ($Hours) { $TimeSpanParams += @{Hours = $Hours} }
		If ($Minutes) { $TimeSpanParams += @{Minutes = $Minutes} }
		
		$TimerDuration = New-TimeSpan @TimeSpanParams @CommonParameters
		
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






