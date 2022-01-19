
Return

$PSVersionTable.PSVersion

# Start PowerShell Job using PowerShell Version 5.1
Start-Job -ScriptBlock { $PSVersionTable.PSVersion } -PSVersion 5.1

# Start PowerShell Job using PowerShell Version 7.0
Start-Job -ScriptBlock { $PSVersionTable.PSVersion }

# Background Jobs 
# Only availabe within the current PowerShell session
# Use the Start-Job cmdlet
Start-Job

# Scheduled Jobs 
# Independent of the current PowerShell session

# Remote Job
# Use -AsJob parameter of the Invoke-Command cmdlet
Invoke-Command -AsJob

# PSWorkflow Job
# Started by using the -AsJob parameter of a Workflow

# CIM Job / WMI Job
# Started by using the -AsJob parameter of a CDXML or WMI Module

# PSEvent Job
# Use Register-ObjectEvent and adding an action parameter

Get-Command "*job*"
Start-Job
Get-Job
Wait-Job
Remove-Job
Receive-Job

Get-Job | Remove-Job




Start-Job -Name -ScriptBlock -Credential -Authentication -InitializationScript -WorkingDirectory -RunAs32 -PSVersion -InputObject -ArgumentList

# Start a Background Job
Start-Job -ScriptBlock { Get-Process -Name pwsh }

# Run Existing PowerShell Script within a Job
Start-Job -FilePath "C:\Scripts\Script.ps1"

# Use and Argument List with Job
Start-Job -ScriptBlock { Get-Process -Name $args } `
	-ArgumentList powershell, pwsh, notepad

# Set the Working Directory fo Job
Start-Job -WorkingDirectory "C:\Scripts" -FilePath "Script.ps1"


# Create Background Job using "Start-Job"
Start-Job -ScriptBlock { Get-Process -Name notepad }

# Create Background Job using "&" ampersand Operator
#Get-Process -Name notepad &

# Create Background Job using "Invoke-Command" and "-AsJob" parameter
$job = Invoke-Command `
	-ComputerName ( Get-Content -Path "C:\Servers.txt") `
	-ScriptBlock { Get-Service -Name WinRM } `
	-JobName WinRM -ThrottleLimit 16 -AsJob

$JobParams = @{
	ComputerName = ( Get-Content -Path "C:\Servers.txt")
	ScriptBlock = { Get-Service -Name "WinRM" }
	JobName = "WinRM"
	ThrottleLimit = 16
	AsJob = $true
}
$job = Invoke-Command @JobParams


# Remove Job by Name
$job = Get-Job -Name BatchJob
$job | Remove-Job

# Remove Job by Instance ID
$job = Start-Job -ScriptBlock {Get-Process PowerShell}
$job | Format-List -Property *
Remove-Job -InstanceId cf02b942-9807-4407-87f3-d23e72055872

# Delete Job using "Invoke-Command"
$session = New-PSSession -ComputerName "Server"
Invoke-Command -Session $session -ScriptBlock {Start-Job `
	-ScriptBlock {Get-Process} -Name "Job"}
Invoke-Command -Session $session `
	-ScriptBlock {Remove-Job -Name "Job"}
Get-PSSession
Disconnect-PSSession -Session $session
Get-PSSession



# Waiting for background jobs to complete:

# Suppresses the command prompt until one or all PowerShell background jobs complete

# Wait for all jobs
Get-Job | Wait-Job

# Wait by ID
Wait-Job -Id 1,2,5 -Any

# Waiting for "Invoke-Command" jobs
$job = Invoke-Command -Session $session -ScriptBlock {Get-Process} -AsJob
$job | Wait-Job


# Get Child Job Details
Get-Job -IncludeChildJob

# Get Non-Started Jobs
Get-Job -State NotStarted

# Retrieve Specific Job Results
$job = Start-Job -ScriptBlock {Get-Process}
Receive-Job -Job $job

# Retrieve Specific Job Results from Multiple Comptuers
$session = New-PSSession -ComputerName DC01, SQL02, WEB03
$job = Invoke-Command -Session $session `
	-ScriptBlock {Start-Job -ScriptBlock {$env:COMPUTERNAME}}
Get-Job










