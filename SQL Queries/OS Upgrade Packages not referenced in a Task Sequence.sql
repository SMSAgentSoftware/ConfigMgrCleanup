-- OS Upgrade Packages not referenced in a Task Sequence

Select Name, PkgID, Source 
from vSMS_OSInstallPackage osip
where osip.PkgID not in (
	Select distinct ReferencePackageID 
	from dbo.v_TaskSequenceReferencesInfo
	where ReferencePackageType = 259
)
Order by Name