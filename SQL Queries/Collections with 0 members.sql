-- Collections with 0 members

Select 	
	CollectionName,
	CollectionComment,
	LastChangeTime,
	LastRefreshRequest,
	LastRefreshTime,
	LastIncrementalRefreshTime,
	LastMemberChangeTime,
	LimitToCollectionName,
	CollectionVariablesCount,
	RefreshType,
	IncludeExcludeCollectionsCount,
	ObjectPath
from dbo.v_Collections
Where MemberCount = 0
Order By CollectionName