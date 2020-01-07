#####################################################################
##                                                                 ##
## Script to delete a list of compliance items from ConfigMgr      ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################

$ComplianceItemsToDelete = @(
    'ComplianceItem1'
    'ComplianceItem2'
)

# Load the ConfigMgr module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace('i386','ConfigurationManager.psd1')
$SiteCode = (Get-PSDrive -PSProvider CMSITE).Name
Set-Location ("$SiteCode" + ":")


#############################
## Delete compliance items ##
#############################

Foreach ($ComplianceItem in $ComplianceItemsToDelete)
{
    Write-Host "Processing compliance item '$ComplianceItem'" -ForegroundColor Yellow
    Try
    {
        $CI = Get-CMConfigurationItem -Name $ComplianceItem -Fast -ErrorAction Stop   
    }
    Catch
    {
        Write-host "  An error occured: $_" -ForegroundColor Red
        Continue
    }
    If ($CI)
    {
        Write-host "  Found compliance item with unique ID '$($CI.CI_UniqueID)'" -ForegroundColor Green

        # Delete compliance item
        Try
        {
            $CI | Remove-CMConfigurationItem -Force -ErrorAction Stop
            Write-Host "  Successfully deleted compliance item!" -ForegroundColor Green
        }
        Catch
        {
            Write-Host "  An error occured attempting to delete the compliance item: $_" -ForegroundColor Red
            Continue
        }
    }
    Else
    {
        Write-Host "  Compliance item not found!" -ForegroundColor Red
    }
}
