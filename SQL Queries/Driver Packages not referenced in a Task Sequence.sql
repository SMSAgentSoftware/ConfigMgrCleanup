-- Driver Packages not referenced in a Task Sequence

Select Name, PackageID, PkgSourcePath 
from v_DriverPackage dp
where dp.PackageID not in (
	Select distinct ReferencePackageID 
	from dbo.v_TaskSequenceReferencesInfo
	where ReferencePackageType = 3
)
Order by Name