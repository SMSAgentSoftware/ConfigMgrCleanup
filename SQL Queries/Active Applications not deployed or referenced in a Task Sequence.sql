-- Active Applications not deployed or referenced in a Task Sequence

Select 
	DisplayName,
	SoftwareVersion,
	IsEnabled,
	NumberOfDeploymentTypes,
	NumberOfDependedDTs,
	NumberOfDevicesWithApp,
	NumberOfUsersWithApp,
	DateCreated,
	DateLastModified,
	LastModifiedBy,
	CreatedBy
from dbo.Fn_Listlatestapplicationcis(1033)
Where IsDeployed = 0
and IsExpired = 0
and NumberOfDependentTS = 0
Order by DisplayName