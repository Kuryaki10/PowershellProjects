function Get-EmployeeFromCSV{
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

function Get-EmployeesFromAD{
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

