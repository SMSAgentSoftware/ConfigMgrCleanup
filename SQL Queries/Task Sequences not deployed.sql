-- Task Sequences not deployed

Select Name,Description
from dbo.v_TaskSequencePackage
where Name not in (
        SELECT DISTINCT SoftwareName
        FROM vDeploymentSummary
        WHERE FeatureType=7
)
Order by Name