#####################################################################
##                                                                 ##
## Script to delete a list of compliance items from ConfigMgr      ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################

$ComplianceItemsToDelete = @(
'COM - Local Admin Account 2'
'HBM 044 Client - Software Center settings'
'HBM BOC Client - Software Center settings'
'HBM GRV Client - Software Center settings'
'HBM GSV Client - Software Center settings'
'HBM IND Client - Software Center settings'
'HBM LAW Client - Software Center settings'
'HBM LOS Client - Software Center settings'
'HBM SDG Client - Software Center settings'
'HBM SEA Client - Software Center settings'
'HBM SFR Client - Software Center setting'
'HBM TRY Client - Software Center settings'
'HBM UND Client - Software Center settings'
'HET - Bomgar Remote Wakeup'
'HET - GLB - SUP - Office 365 2016 - OfficeMgmtCOM'
'HET - GLB - SUP - Office 365 2016 - UpdateChannel'
'HET - HP SoftPaq 80320'
'HET - HP SoftPaq 80323'
'HET - O365 - Deferred Channel'
'HET - O365 - Update Readiness'
'HET - SEP - SEP Communication Settings (SEP14)'
'HET - Skype for Business 15.0.4771.1001 and above'
'HET - SUP - O365 2013 SCCM Managed'
'HMD Firewall'
'HMD Nightly Shutdown'
'HMD NYC Client - Software Center settings'
'HMI - Google Chrome Auto Upgrade'
'HMI - IE 11 Warn on ZoneCrossing'
'HMI Local admin password'
'HNP ALB Client - Software Center settings'
'HNP BPT Client - Software Center settings'
'HNP DBY Client - Software Center settings'
'HNP EDW Client - Software Center settings'
'HNP GWC Client - Software Center settings'
'HNP LAR Client - Software Center settings'
'HNP SFR Client - Software Center settings'
'HNP STF Client - Software Center settings'
'HSC CLT Client - Software Center settings'
'HSC Local admin password'
'HTS - SUP - O365 Target Version'
'HTV CLT Client - Software Center settings'
'HTV Local admin password'
'Restart Prompt via Windows Toast Notification'
'Restart Prompt via Windows Toast Notification BACKUP'
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