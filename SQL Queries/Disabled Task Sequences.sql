-- Disabled Task Sequences

select Name,Description,ObjectPath 
from vSMS_TaskSequencePackageEx 
Where TsEnabled = 0