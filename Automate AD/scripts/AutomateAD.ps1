#Imports
$parentPath = Split-Path -Path $PSScriptRoot -Parent
. "$parentPath\variables\vars.ps1"
Import-Module $parentPath\modules\functions.psm1 -Global

#Compare
$usersData = Get-SyncData -Path $CSVfilePath -Delimiter $delimiter -Properties $properties -syncFieldMap $syncFieldMap -uniqueID $uniqueID -domain $domain



#Remove employees no longer in the company

#Add extra employees
