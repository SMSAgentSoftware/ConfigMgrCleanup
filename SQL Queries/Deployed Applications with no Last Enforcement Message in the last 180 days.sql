-- Deployed Applications with no Last Enforcement Message in the last 180 days

Select apps.DisplayName,apps.CI_ID,ci.LastEnforcementMessageTime
from dbo.Fn_Listlatestapplicationcis(1033) apps
left join (
	Select CI_ID,Max(LastEnforcementMessageTime) as 'LastEnforcementMessageTime'
	from v_CICurrentComplianceStatus
	Group by CI_ID
) as ci on apps.CI_ID = ci.CI_ID
Where apps.IsDeployed = 1
and DateDiff(day,ci.LastEnforcementMessageTime,GetDate()) > 180
Order By apps.DisplayName