## This PowerShell script can help to identify orphaned content in your ConfigMgr Package Source share.
## It works by scanning the Package Source share (up to the depth you specify), extracting content source locations from the ConfigMgr database, and comparing the two
## The resulting CSV will need manually reviewing and cleaning as top-level directories will also be referenced by lower-level directories
## The script will take time to run depending on the number of directories in your package source and the number of content source locations in ConfigMgr

# Variables
$script:dataSource = 'MYSQLSERVER' 
$script:database = 'CM_ABC'
$PackageSource = "\\sccm-sofs\PackageSource"
$SearchDepth = 8

# Get Package source directories recursively
Try
{
    Write-host "Scanning PackageSource directory tree..."
    $ContentSourceDirectories = Get-Childitem -Path $PackageSource -Recurse -Directory -Depth $SearchDepth -ErrorAction Stop
    Write-host "Found $($ContentSourceDirectories.Count) directories in the package source"
}
Catch
{
    Write-Error -Exception $_ -Message "Failed to get package source directories" 
    Break
}

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

# Get content locations for all packages / deployment types
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
    $Results = Get-SQLData -Query $Query 
    Write-host "Found $($Results.Count) content source locations in ConfigMgr"
}
Catch
{
    Write-Error -Exception $_ -Message "Failed to load content source locations from SCCM database." 
    Break
}

# Identify locations that are valid and in use by comparing the content source list from ConfigMgr with the directory list in the package source
Write-host "Building a list of valid directories from the package source"
$AllValidDirectories = New-Object System.Collections.ArrayList
foreach ($Item in $Results.Source)
{
    # Some content references wim files directly
    If ($Item -like "*.wim")
    {
        $Wim = $item.Split('\')[-1]
        $Item = $Item.Replace($wim,'')
    }
    # Regex escape to work with the match operator
    $EscapedItem = [regex]::Escape($Item).TrimEnd('\')
    [array]$ValidDirectories = $ContentSourceDirectories.FullName -match $EscapedItem
    If ($ValidDirectories)
    {
        Foreach ($ValidDirectory in $ValidDirectories)
        {
            [void]$AllValidDirectories.Add($ValidDirectory)
        }
    }
}
Write-host "Found $($AllValidDirectories.Count) valid directories in the package source list"

# Extract the list of directories in the package source that are not referenced in ConfigMgr
Write-host "Building a list of unreferenced directories in the package source"
$UnreferencedDirectories = New-Object System.Collections.ArrayList
foreach ($ContentSourceDirectory in $ContentSourceDirectories.FullName)
{
    If (($AllValidDirectories -like "$ContentSourceDirectory*").Count -eq 0)
    {
        [void]$UnreferencedDirectories.Add($ContentSourceDirectory)
    }
}
Write-Host "Found $($UnreferencedDirectories.Count) directories not identified with any package content in SCCM"
$UnreferencedDirectories | Out-File C:\temp\UnreferencedDirectories.csv -Force