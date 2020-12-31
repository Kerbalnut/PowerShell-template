# 2>NUL & @CLS & PUSHD "%~dp0" & "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy ByPass -Command "Invoke-Expression -Command ([IO.File]::ReadAllText('%~f0'))" & POPD & EXIT /B

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

Write-Host "Pretty colors" -BackgroundColor Red -ForegroundColor Black
Write-Host "Pretty colors" -BackgroundColor Green -ForegroundColor Blue
Write-Host "Pretty colors" -BackgroundColor DarkGreen -ForegroundColor Black
Write-Host "Pretty colors" -BackgroundColor Black -ForegroundColor Green
Write-Host "Pretty colors" -BackgroundColor Black -ForegroundColor DarkGreen
Write-Host "Pretty colors" -BackgroundColor Black -ForegroundColor Red

PAUSE

