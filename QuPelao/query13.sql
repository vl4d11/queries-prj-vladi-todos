use SCP_DOCUMENTO; select @@version

if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_dia_habil','p'))
drop procedure dbo.usp_dia_habil
go
create procedure dbo.usp_dia_habil
@par_periodo varchar(max)
as
begin
set nocount on
set language english

select top 0
cast(null as varchar(10)) periodo,
cast(null as int) dias into #tmp001_dato
select @par_periodo = 
concat('select concat(a,''-01''),b from(values(''', 
replace(@par_periodo, '|', ''','''), '''))t(a,b)')
insert into #tmp001_dato exec(@par_periodo)
update t set dias = day(getdate()) from #tmp001_dato t where dias = 0

select count(1) diaHabil
from(select fecha, datepart(dw, fecha) nroDia
from(select dateadd(dd, item, cast(periodo as date)) fecha
from(select row_number()over(order by (select 1)) -1 item
from sys.fn_helpcollations())t cross apply #tmp001_dato tt where t.item < tt.dias)t)t
outer apply(select*from(values(1),(7))tt(nroDia) where tt.nroDia = t.nroDia)tt
outer apply(select*from(select cast(concat(txt_anoproceso, '-', txt_mes, '-', txt_dia)as date) fecha 
from dbo.gen_feriado)ttt where ttt.fecha = t.fecha)ttt
where tt.nroDia is null and ttt.fecha is null
end
go


exec dbo.usp_dia_habil
-- '2020-04|25'
'2025-04|30'




