-- Task Sequence deployments with no execution history in the last 180 days

Select 
	summ.SoftwareName as 'Task Sequence',
	summ.CollectionName as 'Targeted Collection',
	ts.MaxExecutionTime as 'Last Execution Time',
	DateDiff(day,ts.MaxExecutionTime,GetDate()) as 'Days Since Last Exection'
from vDeploymentSummary summ
Inner Join (
	Select Max(ExecutionTime) as 'MaxExecutionTime',AdvertisementID
	from v_TaskExecutionStatus tes
	where AdvertisementID in (
		select OfferID
		from vDeploymentSummary summ
		WHERE summ.FeatureType=7
		and (NumberSuccess > 0
		or NumberInProgress > 0
		or NumberUnknown > 0
		or NumberErrors > 0
		or NumberOther > 0)
	)
	Group By tes.AdvertisementID
) AS ts on ts.AdvertisementID = summ.OfferID
Where summ.FeatureType = 7
And ts.MaxExecutionTime is not null
and DateDiff(day,ts.MaxExecutionTime,GetDate()) > 180
Order By summ.SoftwareName, summ.CollectionName