-- Compliance Baseline deployments with 0 deployment results or targeted to 0 resources

Select SoftwareName,CollectionName,AssignmentID
from fn_DeploymentSummary(1033)
Where FeatureType = 6
And ((NumberSuccess = 0
and NumberInProgress = 0
and NumberUnknown = 0
and NumberErrors = 0
and NumberOther = 0)
Or NumberTargeted is null)
Order By SoftwareName,CollectionName
