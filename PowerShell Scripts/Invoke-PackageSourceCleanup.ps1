## This PowerShell script can be used to recursively delete directories for orphaned content in your ConfigMgr package source
## Use the CSV file generated by the "Identify-OrphanedContentInConfigMgrPackageSource" script
## DO NOT run this script without a CAREFUL REVIEW of the locations in the CSV file. You have been warned!

$LocationsToDelete = Get-Content C:\temp\UnreferencedDirectories.csv -ReadCount 0

$SuccessfulDeletions = New-Object System.Collections.ArrayList
$UnsuccessfulDeletions = New-Object System.Collections.ArrayList
Foreach ($Location in $LocationsToDelete)
{
    Try
    {
        Write-host "Deleting $Location" -ForegroundColor Yellow
        If ($Location -match ',')
        {
            # Need to use RMDIR where the path has 'illegal' characters
            Start-Process -FilePath cmd.exe -ArgumentList ('/c', 'RMDIR', '/S', '/Q', "$Location") -NoNewWindow -Wait -ErrorAction Stop
        }
        Else
        {
            Remove-Item -Path "$Location" -Recurse -Force -ErrorAction Stop
        }
        [void]$SuccessfulDeletions.Add("$Location")
    }
    Catch
    {
        [void]$UnsuccessfulDeletions.Add([pscustomobject]@{
            Path = "$Location"
            Error = $_.Exception.Message
        })
    }
}

Write-Host "Successful Deletions: $($SuccessfulDeletions.Count)"
Write-Host "Unsuccessful Deletions: $($UnsuccessfulDeletions.Count)"