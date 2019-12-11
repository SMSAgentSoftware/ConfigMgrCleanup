-- Boot images not referenced by a Task Sequence

Select Name, PackageID, PkgSourcePath 
from v_BootImagePackage bip
where bip.PackageID not in (
	Select distinct ReferencePackageID 
	from dbo.v_TaskSequenceReferencesInfo
	where ReferencePackageType = 258
)
Order by Name