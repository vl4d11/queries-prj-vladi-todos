use SCP_DOCUMENTO; select @@version


declare 
@par_data varchar(10) = 
'21/04/2025'

-- begin 
-- as

set language spanish
set nocount on

declare @fech_liquida date = @par_data, @ultimoDia int
set language english

select @ultimoDia = iif(month(@fech_liquida) = 2,
day(dateadd(dd, -1, dateadd(mm, 1, concat(left(@fech_liquida, 7),'-01')))), 30)

;with tmp001_fechas as(
    select @fech_liquida fecha, day(@fech_liquida) dia, datepart(dw, @fech_liquida) nro
    union all
    select dateadd(dd, 1, fecha), day(dateadd(dd, 1, fecha)), datepart(dw, dateadd(dd, 1, fecha))
    from tmp001_fechas
    where dia < @ultimoDia
)
,tmp001_finSem as(
    select*from(values(1),(7))t(nro)
)
,tmp001_feriados as(
    select cast(concat(txt_anoproceso,txt_mes,txt_dia)as date) fecha from gen_feriado
)
select count(1) dias
from(select fecha, dia from tmp001_fechas t 
outer apply(select*from tmp001_finSem tt where tt.nro = t.nro)tt
where tt.nro is null)t
outer apply(select*from tmp001_feriados ttt where ttt.fecha = t.fecha)ttt
where ttt.fecha is null
option(maxrecursion 0)

-- end
-- go





-- ;with tmp001_dia as(
--     select 1 item, @par_fech_ini fecha, day(@par_fech_ini) dia
--     union all
--     select item +1, dateadd(dd, 1, fecha), day(dateadd(dd, 1, fecha))
--     from tmp001_dia where item < @par_nroDias +1
-- )
-- select concat(count(1)/365, '|', (count(1)%365)/30, '|', (count(1)%365)%30) total
-- from tmp001_dia where dia != 31
-- option(maxrecursion 0)
