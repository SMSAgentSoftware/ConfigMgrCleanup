#####################################################################
##                                                                 ##
## Script to delete a list of Compliance Baselines from ConfigMgr. ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################

$ComplianceBaselinesToDelete = @(
'HET - HP SoftPaq 80320'
'HET - HP SoftPaq 80323'
'HET - Office 365 Update Readiness Compliance Baseline'
'HMI - Google Chrome Auto Upgrade'
'HMI - IE 11 Warn on ZoneCrossing'
'HMI Baseline'
'HNP Baseline'
'HSC Baseline'
'HTV Baseline - do not deploy'
'Restart Prompt via Windows Toast Notification'
'HBM 044 Baseline'
'HBM BOC Baseline'
'HBM GRV Baseline'
'HBM GSV Baseline'
'HBM IND Baseline'
'HBM LAW Baseline'
'HBM LOS Baseline'
'HBM SDG Baseline'
'HBM SEA Baseline'
'HBM SFR Baseline'
'HBM TRY Baseline'
'HBM UND Baseline'
'HET - Skype for Business 15.0.4771.1001 and above'
'HMD NYC Baseline'
'HNP ALB Baseline'
'HNP BPT Baseline'
'HNP DBY Baseline'
'HNP EDW Baseline'
'HNP GWC Baseline'
'HNP LAR Baseline'
'HNP SFR Baseline'
'HNP STF Baseline'
'HSC CLT Baseline'
'HTV CLT Baseline'
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