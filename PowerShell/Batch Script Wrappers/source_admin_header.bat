# 2>NUL & @ECHO OFF & @CLS & PUSHD "%~dp0" & ECHO Requesting administrative privileges... waiting 2 seconds & PING -n 3 127.0.0.1 >NUL & SET "_batchFile=%~f0" & SET "_Args=%*" & IF NOT [%_Args%]==[] SET "_Args=%_Args:"=""%" & IF ["%_Args%"] EQU [""] (SET "_CMD_RUN=%_batchFile%") ELSE (SET "_CMD_RUN=""%_batchFile%"" %_Args%") & ECHO Set UAC = CreateObject^("Shell.Application"^) >"%Temp%\~ElevateMe.vbs" & ECHO UAC.ShellExecute "CMD", "/C ""%_CMD_RUN%""", "", "RUNAS", 1 >>"%Temp%\~ElevateMe.vbs" & FSUTIL dirty query %SystemDrive% >NUL && "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression -Command ([IO.File]::ReadAllText('%~f0'))" || cscript "%Temp%\~ElevateMe.vbs"

# & POPD & EXIT /B 

#Requires -RunAsAdministrator



# ECHO Requesting administrative privileges... waiting 2 seconds & PING -n 3 127.0.0.1 >NUL & SET "_batchFile=%~f0" & SET "_Args=%*" & IF NOT [%_Args%]==[] SET "_Args=%_Args:"=""%" & IF ["%_Args%"] EQU [""] (SET "_CMD_RUN=%_batchFile%") ELSE (SET "_CMD_RUN=""%_batchFile%"" %_Args%") & ECHO Set UAC = CreateObject^("Shell.Application"^) >"%Temp%\~ElevateMe.vbs" & ECHO UAC.ShellExecute "CMD", "/C ""%_CMD_RUN%""", "", "RUNAS", 1 >>"%Temp%\~ElevateMe.vbs"










<#
:: First check if we are running As Admin/Elevated
FSUTIL dirty query %SystemDrive% >NUL
IF %ERRORLEVEL% EQU 0 GOTO START

::https://ss64.com/nt/syntax-redirection.html
:: commandA && commandB || commandC
:: If commandA succeeds run commandB, if it fails commandC


# 2>NUL & @ECHO OFF & @CLS & FSUTIL dirty query %SystemDrive% >NUL 

&& PUSHD "%~dp0" & "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression -Command ([IO.File]::ReadAllText('%~f0'))" & POPD & EXIT /B

|| ECHO Requesting administrative privileges... ^(waiting 2 seconds^) & PING -n 3 127.0.0.1 >NUL & SET "_batchFile=%~f0" & SET "_Args=%*" & IF NOT [%_Args%]==[] SET "_Args=%_Args:"=""%" & IF ["%_Args%"] EQU [""] (SET "_CMD_RUN=%_batchFile%") ELSE (SET "_CMD_RUN=""%_batchFile%"" %_Args%") & ECHO Set UAC = CreateObject^("Shell.Application"^) >"%Temp%\~ElevateMe.vbs" & ECHO UAC.ShellExecute "CMD", "/C ""%_CMD_RUN%""", "", "RUNAS", 1 >>"%Temp%\~ElevateMe.vbs" & cscript "%Temp%\~ElevateMe.vbs" & EXIT /B

#>


<#
https://www.reddit.com/r/PowerShell/comments/gaa2ip/never_write_a_batch_wrapper_again
An explanation:

@
Stops a command from echoing to the console host.

# 2>NUL & @CLS
This allows us to comment out the batch wrapper part from the powershell script and eats the cmd.exe error since # is not a command or control character.

PUSHD "%~dp0"
Ensure our working directory is the same as the script's root so we can use $PWD accurately in the script (since $PSScriptRoot will be unavailable).

"%SystemRoot%\[...]\powershell.exe"
Ensure we're executing the right interpreter. If this is compromised, there's no hope for the system anyways.

-nol -nop -ep bypass
-NoLogo -NoProfile -ExecutionPolicy Bypass

"[IO.File]::ReadAllText('%~f0')|iex"
-Command "Invoke-Expression -Command ([System.IO.File]::ReadAllText('%~f0'))"
%~f0 will evaluate to the script's fully-qualified name. This piece is what actually executes our script with Invoke-Expression. powershell.exe will not execute files without a .ps1 extension so this piece is necessary without creating an intermediate temp file.

POPD
Resets the working directory.

EXIT /B
Allows %ERRORLEVEL% to be reflected properly.
#>

'Hello, World!' | Write-Output

Write-Host "`nThis code block was forcefully taken from:`n`nhttps://www.reddit.com/r/PowerShell/comments/gaa2ip/never_write_a_batch_wrapper_again`n`nThere were no injuries.`n" -BackgroundColor Black -ForegroundColor Red

$PSVersionTable.PSVersion

# Check if script is being Run as Administrator or not
$SessionIsAdminElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If ($SessionIsAdminElevated) {
	Write-Host "Session is running as Admin: $SessionIsAdminElevated" -BackgroundColor Black -ForegroundColor Green
} Else {
	Write-Host "Session is running as Admin: $SessionIsAdminElevated" -BackgroundColor Red -ForegroundColor White
}

Write-Host "Pretty colors" -BackgroundColor Red -ForegroundColor Black
Write-Host "Pretty colors" -BackgroundColor Green -ForegroundColor Blue
Write-Host "Pretty colors" -BackgroundColor DarkGreen -ForegroundColor Black
Write-Host "Pretty colors" -BackgroundColor Black -ForegroundColor Green
Write-Host "Pretty colors" -BackgroundColor Black -ForegroundColor DarkGreen
Write-Host "Pretty colors" -BackgroundColor Black -ForegroundColor Red

PAUSE

