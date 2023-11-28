#Imports
$parentPath = Split-Path -Path $PSScriptRoot -Parent
. "$parentPath\variables\vars.ps1"
Import-Module $parentPath\modules\functions.psm1 -Global

#Import employees from csv
Get-EmployeeFromCSV -Path $CSVfilePath -Delimiter $delimiter -Properties $properties

#Import AD Employees
Get-EmployeesFromAD -syncFieldMap $syncFieldMap -uniqueID $uniqueID -domain $domain

#Compare

#Remove employees no longer in the company

#Add extra employees
