-- Standard Packages not deployed or referenced in a Task Sequence

Select Name,PackageID,PkgSourcePath
from dbo.v_Package
where PackageID not in (
	Select distinct PackageID
	from fn_DeploymentSummary(1033)
	where ObjectTypeID = '201'
	and ProgramName != '*'
)
and PackageID not in (
	Select distinct ReferencePackageID 
	from dbo.v_TaskSequenceReferencesInfo
	where ReferencePackageType = 0
)
and PackageType = 0
Order By Name