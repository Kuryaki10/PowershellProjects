function Get-UsersFromCSV{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)][string]$Path,
        [Parameter(Mandatory=$false)][Object[]]$Properties,
        [Parameter(Mandatory)][string]$delimiter
    )

    Begin{}
    Process{
        try {
            $csvEmployees = Import-Csv -Path $Path -Delimiter $delimiter | Select-Object -Property $Properties
        }
        catch {
            Write-Error -Message $_.Exception.Message
            $csvEmployees = $null
        }
    }
    End{
        return $csvEmployees
    }
}

function Get-UsersFromAD{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][Hashtable]$syncFieldMap,
        [Parameter(Mandatory)][string]$uniqueID,
        [Parameter(Mandatory,ValueFromPipeline)][string]$domain
    )

    Begin{}
    Process{
        try {
            $adEmployees = Get-ADUser -Filter {$uniqueID -like '*'} -Server $domain -Properties @($syncFieldMap.Values)
        }
        catch {
            Write-Error -Message $_.Exception.Message
            $adEmployees = $null
        }
    }
    End{
        return $adEmployees
    }
}

function Compare-Users{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)][string]$Path,
        [Parameter(Mandatory=$false)][Object[]]$Properties,
        [Parameter(Mandatory)][string]$delimiter,
        [Parameter(Mandatory)][Hashtable]$syncFieldMap,
        [Parameter(Mandatory)][string]$uniqueID,
        [Parameter(Mandatory,ValueFromPipeline)][string]$domain
    )

    Begin{}
    Process{
        #Import employees from csv
        Get-UsersFromCSV -Path $CSVfilePath -Delimiter $delimiter -Properties $properties

        #Import AD Employees
        Get-UsersFromAD -syncFieldMap $syncFieldMap -uniqueID $uniqueID -domain $domain

        #Compare
        $compareData = Compare-Object -ReferenceObject $employeesFromAD -DifferenceObject $employeesFromCSV -IncludeEqual -Property $uniqueID.
    }
    End{
        return $compareData
    }

}

function Get-SyncData{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)][string]$Path,
        [Parameter(Mandatory=$false)][Object[]]$Properties,
        [Parameter(Mandatory)][string]$delimiter,
        [Parameter(Mandatory)][Hashtable]$syncFieldMap,
        [Parameter(Mandatory)][string]$uniqueID,
        [Parameter(Mandatory,ValueFromPipeline)][string]$domain
    )

    Begin{}
    Process{
        #Compare
        $compareData = Compare-Users -Path $CSVfilePath -Delimiter $delimiter -Properties $properties -syncFieldMap $syncFieldMap -uniqueID $uniqueID -domain $domain
        $newUsersUniqueID = $compareData | Where-Object {$_.sideindicator -eq '=>'}
        $syncedUsersUniqueID = $compareData | Where-Object {$_.sideindicator -eq '<=='}
        $removeUsersUniqueID = $compareData | Where-Object {$_.sideindicator -eq '<='}

        $newUsers = Get-UsersFromCSV -Path $CSVfilePath -Delimiter $delimiter -Properties $properties | Where-Object {$_.$uniqueID -in $newUsersUniqueID.$uniqueID}
        $syncedUsers = Get-UsersFromCSV -Path $CSVfilePath -Delimiter $delimiter -Properties $properties | Where-Object {$_.$uniqueID -in $syncedUsersUniqueID.$uniqueID}
        $removeUsers = Get-UsersFromAD -Path $CSVfilePath -Delimiter $delimiter -Properties $properties | Where-Object {$_.$uniqueID -in $removeUsersUniqueID.$uniqueID}
    }
    End{
        return @{
            New = $newUsers
            Synced = $syncedUsers
            Removed = $removeUsers
        }
    }

}

