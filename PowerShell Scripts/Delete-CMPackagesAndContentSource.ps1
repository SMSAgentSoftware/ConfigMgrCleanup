#####################################################################
##                                                                 ##
## Script to delete a list of packages from ConfigMgr.             ##
## The script will also delete the content source directory        ##
## for each package.                                               ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
## Requires read access to the ConfigMgr database.                 ##
##                                                                 ##
## Provide a list of package names and PackageIDs in a CSV format. ##
##                                                                 ##
## Use the $Results variable after execution to view successful    ##
## or unsuccessful content source deletions.                       ##
##                                                                 ##
#####################################################################

#Requires -Version 5.0

# CSV file with two columns, headers: Name, PackageID
$PackagesToDelete = Import-CSV -Path C:\Temp\PackagesToDelete.csv

# Variables
$script:dataSource = 'MyConfigMgrSQLServer' 
$script:database = 'CM_ABC'
$PackageSource = "\\FileServer\PackageSource" # Package source share. This will be used to help identify content source locations that may be used by other content in ConfigMgr.


# Function to query ConfigMgr database
function Get-SQLData {
    param($Query)
    $connectionString = "Server=$dataSource;Database=$database;Integrated Security=SSPI;"
    $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandText = $Query
    $reader = $command.ExecuteReader()
    $table = New-Object -TypeName 'System.Data.DataTable'
    $table.Load($reader)
    
    # Close the connection
    $connection.Close()
    
    return $Table
}


###############################################################
## Get content locations for all packages / deployment types ##
###############################################################

$Query = "
Select Source from SMSPackages_All
where Source like '$PackageSource\%'
UNION
Select ContentSource
from v_Contentinfo
Where ContentSource like '$PackageSource%'
and DisplayName like '%DeploymentType%'
Order by Source
"

Try
{
    Write-host "Loading content source location list from ConfigMgr database"
    $CMContentSources = Get-SQLData -Query $Query 
    Write-host "Found $($CMContentSources.Count) content source locations in ConfigMgr"
}
Catch
{
    Write-Error -Exception $_ -Message "Failed to load content source locations from SCCM database." 
    Return
}


# Load the ConfigMgr module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace('i386','ConfigurationManager.psd1')
$SiteCode = (Get-PSDrive -PSProvider CMSITE).Name
Set-Location ("$SiteCode" + ":")


#####################
## Delete packages ##
#####################

$PackageSourceList = New-Object System.Collections.ArrayList
Foreach ($Package in $PackagesToDelete)
{
    Write-Host "Processing package '$($Package.Name)'" -ForegroundColor Yellow
    Write-Host "  Package ID: $($Package.PackageID)" -ForegroundColor Green
    Try
    {
        $Pkg = Get-CMPackage -Id $Package.PackageID -Fast -ErrorAction Stop   
    }
    Catch
    {
        Write-host "  An error occured: $_" -ForegroundColor Red
        Continue
    }
    If ($Pkg)
    {
        Write-host "  Found package" -ForegroundColor Green
        $ContentLocation = $Pkg.PkgSourcePath
        Write-Host "  Content source: '$ContentLocation'" -ForegroundColor Green

        # Delete Package
        Try
        {
            $Pkg | Remove-CMPackage -Force -ErrorAction Stop
            Write-Host "  Successfully deleted package!" -ForegroundColor Green
            [void]$PackageSourceList.Add($ContentLocation)
        }
        Catch
        {
            Write-Host "  An error occured attempting to delete the package: $_" -ForegroundColor Red
            Continue
        }
    }
    Else
    {
        Write-Host "  Package not found!" -ForegroundColor Red
    }
}


######################################
## Cleanup Package source locations ##
######################################

Write-host "=========================================================="
Write-Host "Running content source cleanup" -ForegroundColor Yellow

$SuccessfulDeletions = New-Object System.Collections.ArrayList
$UnsuccessfulDeletions = New-Object System.Collections.ArrayList
Foreach ($Location in ($PackageSourceList | Select -Unique))
{
    # Check if the location is referenced elsewhere by other content. If so, we won't delete that location
    $EscapedLocation= [regex]::Escape($Location).TrimEnd('\')
    If (($CMContentSources.Source | Where {$_ -match $EscapedLocation}).Count -gt 1)
    {
        Write-host "  Location '$Location' is referenced by other content in ConfigMgr...not deleting it" -ForegroundColor DarkYellow
        Continue
    } 

    Try
    {
        Write-host "Deleting $Location" -ForegroundColor Yellow
        # Need to use RMDIR as Remove-Item does not like 'illegal' characters
        $cmdstring = "/c RMDIR /S /Q ""$Location"""
        cmd.exe $cmdstring
        If ($?)
        {
            [void]$SuccessfulDeletions.Add("$Location")
        }
        Else
        {
            [void]$UnsuccessfulDeletions.Add([pscustomobject]@{
                Path = "$Location"
                Error = $Error[0].Exception.Message
            })
        }
    }
    Catch
    {
        [void]$UnsuccessfulDeletions.Add([pscustomobject]@{
            Path = "$Location"
            Error = $_.Exception.Message
        })
    }
}

# Return results
Class Deletions
{
    $SuccessfulDeletions
    $UnsuccessfulDeletions
    $SuccessfulDeletionsCount
    $UnsuccessfulDeletionsCount   
}

$Results = New-Object Deletions
$Results.SuccessfulDeletions = $SuccessfulDeletions
$Results.SuccessfulDeletionsCount = $SuccessfulDeletions.Count
$Results.UnsuccessfulDeletions = $UnsuccessfulDeletions
$Results.UnsuccessfulDeletionsCount = $UnsuccessfulDeletions.Count

Return $Results | fl
