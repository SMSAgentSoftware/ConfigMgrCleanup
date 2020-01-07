#####################################################################
##                                                                 ##
## Script to delete deployments for ConfigMgr task sequences       ##
##                                                                 ##
## Provide a list of task sequence names and deployment IDs        ##
## in a CSV format.                                                ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################


# CSV file with two columns, headers: TaskSequence, DeploymentID
$TSDeployments = Import-CSV  -Path 'C:\Temp\Task Sequence Deployments to Delete.csv' 

# Load the ConfigMgr module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace('i386','ConfigurationManager.psd1')
$SiteCode = (Get-PSDrive -PSProvider CMSITE).Name
Set-Location ("$SiteCode" + ":")

# Process each app
foreach ($TSDeployment in $TSDeployments)
{
    Write-Host "Processing task sequence '$($TSDeployment.TaskSequence)'" -ForegroundColor Yellow
    Write-Host "  DeploymentID = $($TSDeployment.DeploymentID)"

    # Get the deployment
    Try
    {
        $Deployment = Get-CMTaskSequenceDeployment -DeploymentID $TSDeployment.DeploymentID -ErrorAction Stop
        If ($Deployment)
        {
            Write-Host "  Found task sequence deployment '$($Deployment.AdvertisementName)' to collection ID '$($Deployment.CollectionID)'" -ForegroundColor Green
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
        Remove-CMTaskSequenceDeployment -InputObject $Deployment -Force -ErrorAction Stop
        Write-Host "  Task sequence deployment successfully deleted!" -ForegroundColor Green
    }
    Catch
    {
        Write-Host "  Failed to delete task sequence deployment: $_" -ForegroundColor Red
        Continue
    }
}