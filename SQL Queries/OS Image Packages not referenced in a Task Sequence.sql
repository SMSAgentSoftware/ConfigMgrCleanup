-- OS Image Packages not referenced in a Task Sequence

Select Name, PackageID, PkgSourcePath 
from v_ImagePackage ip
where ip.PackageID not in (
	Select distinct ReferencePackageID 
	from dbo.v_TaskSequenceReferencesInfo
	where ReferencePackageType = 257
)
Order by Name