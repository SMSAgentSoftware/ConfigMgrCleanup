#####################################################################
##                                                                 ##
## Script to delete a list of Compliance Baselines from ConfigMgr. ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################

$ComplianceBaselinesToDelete = @(
    'Baseline1'
    'Baseline2'
)

# Load the ConfigMgr module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace('i386','ConfigurationManager.psd1')
$SiteCode = (Get-PSDrive -PSProvider CMSITE).Name
Set-Location ("$SiteCode" + ":")


######################
## Delete baselines ##
######################

Foreach ($ComplianceBaseline in $ComplianceBaselinesToDelete)
{
    Write-Host "Processing compliance baseline '$ComplianceBaseline'" -ForegroundColor Yellow
    Try
    {
        $CB = Get-CMBaseline -Name $ComplianceBaseline -ErrorAction Stop   
    }
    Catch
    {
        Write-host "  An error occured: $_" -ForegroundColor Red
        Continue
    }
    If ($CB)
    {
        Write-host "  Found baseline with unique ID '$($CB.CI_UniqueID)'" -ForegroundColor Green

        # Delete baseline
        Try
        {
            $CB | Remove-CMBaseline -Force -ErrorAction Stop
            Write-Host "  Successfully deleted compliance baseline!" -ForegroundColor Green
        }
        Catch
        {
            Write-Host "  An error occured attempting to delete the compliance baseline: $_" -ForegroundColor Red
            Continue
        }
    }
    Else
    {
        Write-Host "  Compliance Baseline not found!" -ForegroundColor Red
    }
}
