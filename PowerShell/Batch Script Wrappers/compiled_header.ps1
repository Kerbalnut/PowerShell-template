# 2>NUL & @CLS & PUSHD "%~dp0" & "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -nol -nop -ep ByPass "[IO.File]::ReadAllText('%~f0')|iex" & POPD & EXIT /B

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

