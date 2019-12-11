-- Software Update Groups not deployed

Select Title, DateLastModified from dbo.v_AuthListInfo
Where IsDeployed = 0