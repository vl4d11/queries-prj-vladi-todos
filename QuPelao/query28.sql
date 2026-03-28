use SCP_AMINISTIA_MCO_01

declare @data varchar(max)
= '000032|000FOR|01304|1250.0|225.00||1475|000004~000032|000FOR|01304|1250.0|225.00||1475|000003'


-- if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_retornoDato', 'p'))
-- drop procedure dbo.usp_retornoDato
-- go
-- create procedure dbo.usp_retornoDato
-- @data varchar(max) output
-- as
-- begin
set nocount on

declare @item int = 1, @tot int, @cadena varchar(max)
create table #tmp001_dato(
    item int identity,
    dato varchar(max)
)
select top 0
cast(null as varchar(10)) cod_proyecto,
cast(null as varchar(10)) dato2,
cast(null as varchar(10)) cod_ctaproyecto,
cast(null as varchar(10)) dato4,
cast(null as varchar(10)) dato5,
cast(null as varchar(10)) dato6,
cast(null as varchar(10)) dato7,
cast(null as varchar(10)) dato8 into #tmp002_dato

select @data =
concat('select*from(values(''', replace(@data,'~','''),('''), '''))t(a)')
insert into #tmp001_dato exec(@data)
select @tot = count(1) + 1 from #tmp001_dato

select @data = ''
while @item < @tot begin
delete #tmp002_dato
select @cadena =
concat('select*from(values(''', replace(dato,'|',''','''), '''))t(a1,a2,a3,a4,a5,a6,a7,a8)')
from #tmp001_dato where item = @item
insert into #tmp002_dato exec(@cadena)

select*from #tmp002_dato

select @data +=
concat('~', t.cod_proyecto, t, tt.txt_descproyecto, t, t.dato2, t,
t.cod_ctaproyecto, t, ttt.txt_descctaproyecto, t,
t.dato4, t, t.dato5, t, t.dato6, t, t.dato7, t, t.dato8)
from #tmp002_dato t, dbo.scp_proyecto tt, dbo.scp_planproyecto ttt,
(values('|'))temp(t)
where t.cod_proyecto = tt.cod_proyecto
and ttt.txt_anoproceso = year(getdate()) and t.cod_proyecto = ttt.cod_proyecto
and t.cod_ctaproyecto = ttt.cod_ctaproyecto

select @item += 1
end

-- end
-- go

select @data


-- declare @data varchar(max)
-- = '000032|000FOR|01304|1250.0|225.00||1475|000004~000032|000FOR|01304|1250.0|225.00||1475|000003'

-- exec dbo.usp_retornoDato @data output

-- select @data
