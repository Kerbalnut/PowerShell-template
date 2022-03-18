
Clear-Host
Write-Host "Keep host alive with scroll lock"

$WShell = New-Object -ComObject "WScript.shell"

while ($True) {
	$WShell.sendkeys("{SCROLLLOCK}")
	Start-Sleep -Milliseconds 100
	$WShell.sendkeys("{SCROLLLOCK}")
	Start-Sleep -Seconds 240
}
