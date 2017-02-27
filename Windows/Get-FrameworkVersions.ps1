<#
.Synopsis

Returns the install .NET Framework versions.

.Description

The script looks through the registry using the notes from the below
MSDN links to determine which versions of .NET are installed.

- https://msdn.microsoft.com/en-us/library/bb822049(v=vs.110).aspx
- https://msdn.microsoft.com/en-us/library/hh925568(v=vs.110).aspx

.Notes
AUTHOR: David Mohundro
#>

$ndpDirectory = 'hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\'

if (Test-Path "$ndpDirectory\v2.0.50727") {
    $version = Get-ItemProperty "$ndpDirectory\v2.0.50727" -name Version | select Version
    $version
}

if (Test-Path "$ndpDirectory\v3.0") {
    $version = Get-ItemProperty "$ndpDirectory\v3.0" -name Version | select Version
    $version
}

if (Test-Path "$ndpDirectory\v3.5") {
    $version = Get-ItemProperty "$ndpDirectory\v3.5" -name Version | select Version
    $version
}

$v4Directory = "$ndpDirectory\v4\Full"
if (Test-Path $v4Directory) {
    $version = Get-ItemProperty $v4Directory -name Version | select -expand Version
    $version
}
