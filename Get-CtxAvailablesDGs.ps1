<#
.SYNOPSIS
    Connect to remote XenDesktop farm (CVAD) to obtain data about availability of Delivery groups.

.PARAMETER DdcServers
    List of one Delivery Controller per farm.

.PARAMETER Credential
    Credentials to connect to remote server and XenDesktop farm (Read-Only)

.RETURN
    Return data in json format (data can be imported in influxDB)
    
.AUTHOR
    Manuel Pérez

.PROJECTURI
    https://github.com/ManuPerezSan

.REQUIREMENTS

#>
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true, Position=0)][string[]]$DdcServers,
[Parameter(Mandatory=$true, Position=1)][pscredential]$Credential
)

$DeliveryGroups = @()
$Farms = @()

Foreach($ddc in $DdcServers){

    $s01 = New-PsSession -Computer $ddc -Credential $Credential

    $siteName = Invoke-command -Session $s01 -ScriptBlock{ (Get-BrokerSite).Name }
    
    if ($Farms.IndexOf($siteName) -lt 0) {
        
        $Farms += $siteName
        
        try{

            $returnedData = Invoke-command -Session $s01 -ScriptBlock{

                $array=@()

                Add-PSSnapin citrix.*
                $dg = (Get-BrokerDesktopGroup -AdminAddress localhost).Name

                foreach ($x in $dg){

                    $hash = @{}

                    $machines = Get-BrokerMachine -DesktopGroupName $x -MaxRecordCount 100000
                    $maintenance = $machines | ? InMaintenanceMode -eq $true
                    $availables = $machines | ? SummaryState -eq 'Available'
                    $inUse = $machines | Where-Object {$_.SummaryState -eq 'InUse' -OR $_.SummaryState -eq 'Disconnected' }
                    $unregistered = $machines | ? RegistrationState -eq 'Unregistered'
                    $off = $machines | ? PowerState -eq 'Off'
                    $percentageAvailable = [math]::Round($availables.count / $machines.count * 100,1)

                    $Object = New-Object PSObject
                    $Statistics = New-Object PSObject

                    $Statistics | add-member Noteproperty InUse $inUse.count
                    $Statistics | add-member Noteproperty Available $availables.count
                    $Statistics | add-member Noteproperty InMaintenance $maintenance.count
                    $Statistics | add-member Noteproperty Off $off.count
                    $Statistics | add-member Noteproperty Unregistered $unregistered.count
                    $Statistics | add-member Noteproperty PercentageAvailable $PercentageAvailable
                    $Statistics | add-member Noteproperty Total $machines.count

                    $Object | add-member Noteproperty DeliveryGroup $x
                    $Object | add-member Noteproperty Statistics $Statistics                

                    $array += $Object

                    $hash = $null

                }

                return $array

            } | Select -Property DeliveryGroup,Statistics

        }catch{
            Remove-PSSession $s01 -Confirm:$false
        }
        
        $DeliveryGroups += $returnedData
    }
    
    Remove-PSSession $s01 -Confirm:$false   

}

ConvertTo-Json $DeliveryGroups -Depth 2 #-Compress
