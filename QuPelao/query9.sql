use SCP_AMINISTIA;select @@version

declare @data varchar(max), @tabla varchar(100)=
-- 'mco_cabeceraorden'
'mco_detalleorden'

select concat(stuff((select ',',name
from mastertable(@tabla) order by column_id
for xml path, type).
value('.','varchar(500)'),1,1,'insert into '+@tabla+'('),')values')


select @data = concat(stuff((select ','''''','''''',', ltrim(rtrim(name))
from mastertable(@tabla) order by column_id
for xml path, type).
value('.','varchar(1000)'),1,9,'select '',('''''','),','''''')'' from '+@tabla)
exec(@data)

