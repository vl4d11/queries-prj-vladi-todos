use SCP_DESCOSUR3

-- truncate table dbo.MPP_FINDEMES


select*from dbo.MPP_FINDEMES
order by txt_anoproceso, txt_mesproceso, txt_diaproceso




-- set nocount on
-- declare @data varchar(max),
-- @tabla varchar(100) = 'dbo.MPP_FINDEMES'

-- create table #tmp001_datos (
--     item int identity,
--     datos varchar(max)
-- )
-- select @data = concat(stuff((select ','''''','''''',',
-- case when type in('date', 'datetime')
-- then concat('convert(varchar,', name, ',121)')
-- when type in('decimal', 'numeric')
-- then concat('isnull(', name, ', 0)')
-- else name end
-- from mastertable(@tabla)
-- for xml path, type)
-- .value('.', 'varchar(max)'), 1, 9, 'select concat('',('','''''''','),
-- ','''''''','')'') from ', @tabla)


-- insert into #tmp001_datos
-- exec ('select ''insert into ' + @tabla + ' values'' union all ' + @data)
-- update t set datos = stuff(datos, 1, 1, '') from #tmp001_datos t where item = 2

-- select datos from #tmp001_datos order by item
