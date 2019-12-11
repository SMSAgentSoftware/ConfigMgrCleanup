-- Enabled Compliance Baselines not deployed
-- Change your LocaleID if needed

Select cip.DisplayName,ci.IsEnabled
from dbo.v_ConfigurationItems ci
left join v_LocalizedCIProperties cip on ci.CI_ID = cip.CI_ID 
where CIType_ID = 2
and IsLatest = 1
and IsDeployed = 0
and ci.IsEnabled = 1
and cip.LocaleID = 1033
Order By cip.DisplayName