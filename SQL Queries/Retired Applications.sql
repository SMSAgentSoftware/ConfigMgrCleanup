-- Retired Applications

Select DisplayName
from dbo.Fn_Listlatestapplicationcis(1033)
Where IsExpired = 1
Order by DisplayName