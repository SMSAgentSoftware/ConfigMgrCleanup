#####################################################################
##                                                                 ##
## Script to delete deployments for ConfigMgr packages             ##
##                                                                 ##
## Provide a list of packages names and deployment IDs             ##
## in a CSV format.                                                ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################


# CSV file with two columns, headers: SoftwareName, AssignmentID
$PkgDeployments = Import-CSV  -Path 'C:\Temp\Pkg Deployments to Delete.csv' 

# Load the ConfigMgr module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace('i386','ConfigurationManager.psd1')
$SiteCode = (Get-PSDrive -PSProvider CMSITE).Name
Set-Location ("$SiteCode" + ":")

# Process each app
foreach ($PkgDeployment in $PkgDeployments)
{
    Write-Host "Processing package '$($PkgDeployment.SoftwareName)'" -ForegroundColor Yellow
    Write-Host "  DeploymentID = $($PkgDeployment.DeploymentID)"

    # Get the deployment
    Try
    {
        $Deployment = Get-CMPackageDeployment -Name $PkgDeployment.SoftwareName -ErrorAction Stop | Where {$_.AdvertisementID -eq $PkgDeployment.DeploymentID} -ErrorAction Stop
        If ($Deployment)
        {
            Write-Host "  Found package deployment '$($Deployment.AdvertisementName)' to collection ID '$($Deployment.CollectionID)'" -ForegroundColor Green
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
        Remove-CMPackageDeployment -InputObject $Deployment -Force -ErrorAction Stop
        Write-Host "  Package deployment successfully deleted!" -ForegroundColor Green
    }
    Catch
    {
        Write-Host "  Failed to delete package deployment: $_" -ForegroundColor Red
        Continue
    }
}