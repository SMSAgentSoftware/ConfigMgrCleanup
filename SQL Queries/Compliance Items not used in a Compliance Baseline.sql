-- Compliance Items not used in a Compliance Baseline

select DisplayName,Description,IsChild,IsSuperseded,CreatedBy,LastModifiedBy
from fn_ListDCMCIsLatest_List(1033)
where (
	((CIType_ID = 3 OR 
	(CIType_ID = 4 AND IsUserDefined = 1)) OR 
	CIType_ID = 5) 
	OR CIType_ID = 7
) 
and IsLatest = 1
and InUse = 0
order by DisplayName