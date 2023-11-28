$syncFieldMap = @{
    EmployeeID = "EmployeeID"
    FirstName = "GivenName"
    LastName = "SurName"
    Department = "Department"
    Location = "physicalDeliverOfficeName"
}
@{Name='GivenName';Expression={$_.FirstName}}
$properties = foreach($property in $syncFieldMap.GetEnumerator()){
    @{Name=$property.Value;Expression=[scriptblock]::Create("`$_.$($property.Key)")}
}

$CSVfilePath ="$(Split-Path -Path $PSScriptRoot -Parent)\files\employees.csv"
$delimiter = ','
$uniqueID = 'Name'
$domain = 'juniper'