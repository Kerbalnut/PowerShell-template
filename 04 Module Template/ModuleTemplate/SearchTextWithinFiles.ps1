
# Pluralsight training:
# Windows PowerShel and Regular Expressions
# by Jeff Hicks
# 2021-12-20

cd C:\Users\Grant\Documents\Hg\device-config

dir * -Recurse | Select-String "chmod"


# Powershell uses for regex objects:

[System.Text.RegularExpressions]

[regex]$regex = "[^a-zA-Z]+-\d{1,3}$"
[regex]$rx = "[^a-zA-Z]+-\d{1,3}$"

# If you piped into | Get-Member on that object:
[System.Text.RegularExpressions.Regex]

# Try out .IsMatch() function:

$rx = $regex

$rx.IsMatch("foo-12")
$rx.Ismatch("BAR-1234")

# Building Advanced Regular Expression Commands with the Regex Object

$names = "foo-12","fail","srv-02","ok-123","p!s-98","SRV-9999"
$names | Where-Object {$_ -match $rx}
$names | Where-Object {$_ -notmatch $rx}

# Using .split() method/function leaved empty/null values in results?:

help about_split

$t.Split.OverloadDefinitions











