#####################################################################
##                                                                 ##
## Script to delete a list of task sequences from ConfigMgr.       ##
##                                                                 ##
## Must be run where the ConfigurationManager module is installed. ##
##                                                                 ##
#####################################################################

$TaskSequencesToDelete = @(
    'TaskSequence1'
    'TaskSequence2'
)

# Load the ConfigMgr module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace('i386','ConfigurationManager.psd1')
$SiteCode = (Get-PSDrive -PSProvider CMSITE).Name
Set-Location ("$SiteCode" + ":")


###########################
## Delete task sequences ##
###########################

Foreach ($TaskSequence in $TaskSequencesToDelete)
{
    Write-Host "Processing task sequence '$TaskSequence'" -ForegroundColor Yellow
    Try
    {
        $TS = Get-CMTaskSequence -Name $TaskSequence -ErrorAction Stop   
    }
    Catch
    {
        Write-host "  An error occured: $_" -ForegroundColor Red
        Continue
    }
    If ($TS)
    {
        Write-host "  Found task sequence with Package ID '$($TS.PackageID)'" -ForegroundColor Green

        # Delete task sequence
        Try
        {
            $TS | Remove-CMTaskSequence -Force -ErrorAction Stop
            Write-Host "  Successfully deleted task sequence!" -ForegroundColor Green
        }
        Catch
        {
            Write-Host "  An error occured attempting to delete the task sequence: $_" -ForegroundColor Red
            Continue
        }
    }
    Else
    {
        Write-Host "  Task sequence not found!" -ForegroundColor Red
    }
}