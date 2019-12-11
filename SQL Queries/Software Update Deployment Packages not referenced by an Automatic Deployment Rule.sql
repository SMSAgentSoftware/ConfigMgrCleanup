-- Software Update Deployment Packages not referenced by an Automatic Deployment Rule
-- Note: not being referenced by an ADR does not mean they are not used for individual Software Update deployments

select Name,PkgID,Source
from vSMS_SoftwareUpdatesPackage_List
where PkgID not in (
	Select distinct
		ContentTemplate.value('(/ContentActionXML/PackageID)[1]','nvarchar(MAX)') as 'DeploymentPackageID'
	from vSMS_AutoDeployments
	Where ContentTemplate.value('(/ContentActionXML/PackageID)[1]','nvarchar(MAX)') is not null
)