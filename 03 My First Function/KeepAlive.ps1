
$WShell = New-Object -ComObject "WScript.shell"

$i = 0
$StartTime = Get-Date
while ($True) {
	$i++
	Clear-Host
	Write-Host "Keep host alive with scroll lock: (Round $i) Start time: $StartTime"
	$WShell.sendkeys("{SCROLLLOCK}")
	Start-Sleep -Milliseconds 100
	$WShell.sendkeys("{SCROLLLOCK}")
	Start-Sleep -Seconds 240
}

