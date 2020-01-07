#####################################################################
##                                                                 ##
## Script to delete deployments for ConfigMgr compliance baselines ##
##                                                                 ##
## Provide a list of baseline names and assignment IDs             ##
## in a CSV format.                                                ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################


# CSV file with two columns, headers: Baseline, AssignmentID
$CBDeployments = Import-CSV  -Path 'C:\Temp\Compliance Baseline Deployments to Delete.csv' 

# Load the ConfigMgr module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace('i386','ConfigurationManager.psd1')
$SiteCode = (Get-PSDrive -PSProvider CMSITE).Name
Set-Location ("$SiteCode" + ":")

# Process each app
foreach ($CBDeployment in $CBDeployments)
{
    Write-Host "Processing compliance baseline '$($CBDeployment.Baseline)'" -ForegroundColor Yellow
    Write-Host "  AssignmentID = $($CBDeployment.AssignmentID)"

    # Get the deployment
    Try
    {
        $Deployment = Get-CMBaselineDeployment -Name $CBDeployment.Baseline -ErrorAction Stop | where {$_.AssignmentID -eq $CBDeployment.AssignmentID} -ErrorAction Stop
        If ($Deployment)
        {
            Write-Host "  Found baseline deployment '$($Deployment.AssignmentName)' to collection ID '$($Deployment.TargetCollectionID)'" -ForegroundColor Green
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
        Remove-CMBaselineDeployment -InputObject $Deployment -Force -ErrorAction Stop
        Write-Host "  Baseline deployment successfully deleted!" -ForegroundColor Green
    }
    Catch
    {
        Write-Host "  Failed to delete baseline deployment: $_" -ForegroundColor Red
        Continue
    }
}