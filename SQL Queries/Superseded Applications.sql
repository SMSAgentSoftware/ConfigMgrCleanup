-- Superseded Applications

Select DisplayName
from dbo.Fn_Listlatestapplicationcis(1033)
Where IsSuperseded = 1
Order by DisplayName