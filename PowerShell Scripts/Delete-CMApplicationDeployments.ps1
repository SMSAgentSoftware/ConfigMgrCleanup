#####################################################################
##                                                                 ##
## Script to delete deployments for ConfigMgr applications         ##
##                                                                 ##
## Provide a list of application names and assignment IDs          ##
## in a CSV format.                                                ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################


# CSV file with two columns, headers: SoftwareName, AssignmentID
$AppDeployments = Import-CSV  -Path 'C:\Temp\App Deployments to Delete.csv' 

# Load the ConfigMgr module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace('i386','ConfigurationManager.psd1')
$SiteCode = (Get-PSDrive -PSProvider CMSITE).Name
Set-Location ("$SiteCode" + ":")

# Process each app
foreach ($AppDeployment in $AppDeployments)
{
    Write-Host "Processing app '$($AppDeployment.SoftwareName)'" -ForegroundColor Yellow
    Write-Host "  AssignmentID = $($AppDeployment.AssignmentID)"

    # Get the deployment
    Try
    {
        $Deployment = Get-CMApplicationDeployment -Name $AppDeployment.SoftwareName -ErrorAction Stop | Where {$_.AssignmentID -eq $AppDeployment.AssignmentID} -ErrorAction Stop
        If ($Deployment)
        {
            Write-Host "  Found app deployment $($Deployment.AssignmentUniqueID) to collection '$($Deployment.CollectionName)'" -ForegroundColor Green
        }
        Else
        {
            Write-Host "  No deployment found!" -ForegroundColor Magenta
            Continue
        }
    } 
    Catch
    {
        Write-Host " An error occured: $_" -ForegroundColor Red
        Continue 
    }

    # Delete the deployment
    Try
    {
        Remove-CMApplicationDeployment -InputObject $Deployment -Force -ErrorAction Stop
        Write-Host "  Application deployment successfully deleted!" -ForegroundColor Green
    }
    Catch
    {
        Write-Host "  Failed to delete application deployment: $_" -ForegroundColor Red
        Continue
    }
}