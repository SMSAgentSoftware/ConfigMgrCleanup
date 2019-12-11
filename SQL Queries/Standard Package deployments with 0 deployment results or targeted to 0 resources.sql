-- Standard Package deployments with 0 deployment results or targeted to 0 resources

Select SoftwareName,CollectionName,DeploymentID
from fn_DeploymentSummary(1033)
Where FeatureType = 2
And ((NumberSuccess = 0
and NumberInProgress = 0
and NumberUnknown = 0
and NumberErrors = 0
and NumberOther = 0)
Or NumberTargeted is null)
Order By SoftwareName,CollectionName