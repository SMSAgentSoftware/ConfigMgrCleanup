-- Disabled Compliance Baselines

Select cip.DisplayName
from dbo.v_ConfigurationItems ci
left join v_LocalizedCIProperties cip on ci.CI_ID = cip.CI_ID 
where CIType_ID = 2
and IsLatest = 1
and cip.LocaleID = 1033
and ci.IsEnabled = 0
Order By cip.DisplayName