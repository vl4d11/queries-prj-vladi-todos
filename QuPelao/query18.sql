use SCP_DOCUMENTO; select @@version

-- NOTA: CALCULO DE TIEMPO DE TRABAJO (DIA, MES, AÑO)
-- ===========================================================
declare 
@fecha_ini varchar(10) = 
'01/03/2017',
-- '12/03/2017',

@fecha_fin varchar(10) = 
'30/01/2025'
-- '26/04/2025'



set language spanish
set nocount on

declare @par_fech_ini date = @fecha_ini, @par_fech_fin date = @fecha_fin
declare @par_nroDias  int = datediff(dd, @par_fech_ini, @par_fech_fin)


;with tmp001_timeLine(f_ini, f_fin) as(
    select cast(concat(year(@par_fech_ini),'0101') as date),
    dateadd(dd, -1, dateadd(yy, 1, cast(concat(year(@par_fech_fin),'0101') as date)))
)
,tmp001_matriz as(
    select f_ini, f_fin, 
    case when f_ini between @par_fech_ini and @par_fech_fin  then 1 end content
    from tmp001_timeLine
    union all 
    select dateadd(dd, 1, f_ini), f_fin,
    case when dateadd(dd, 1, f_ini) between @par_fech_ini and @par_fech_fin  then 1 end 
    from tmp001_matriz
    where f_ini < f_fin
)
select concat(anno + mes/12, '|', mes%12 + dias/30, '|', dias%30)
from(select distinct count(diasAnno)over() anno, count(diasMes)over() mes,
count(case when diasAnno is null and diasMes is null then 1 end)over() dias
from(select distinct *
from(select diasAnno, diasMes, f_ini =
case when diasAnno is null and diasMes is null then f_ini 
when diasAnno = 1 then cast(concat(convert(varchar(4), f_ini),'0101') as date)
when diasMes  = 2 then cast(concat(convert(varchar(7), f_ini),'-01') as date) end
from(select f_ini, content,
case when  diasAnno = diasAnnoCta and diasMes = diasMesCta  then 1 end diasAnno,
case when  diasAnno != diasAnnoCta and diasMes = diasMesCta then 2 end diasMes
from(select f_ini, diasAnno, diasMes, content,
count(1)over(partition by year(f_ini), content) diasAnnoCta,
count(1)over(partition by convert(varchar(7), f_ini), content) diasMesCta
from(select f_ini, content,
count(1)over(partition by year(f_ini)) diasAnno,
count(1)over(partition by convert(varchar(7), f_ini)) diasMes
from tmp001_matriz)t)t)t
where content = 1)t order by f_ini offset 0 rows)t)t
option(maxrecursion 0)




-- ;with tmp001_dia as(
--     select 1 item, @par_fech_ini fecha, day(@par_fech_ini) dia
--     union all
--     select item +1, dateadd(dd, 1, fecha), day(dateadd(dd, 1, fecha))
--     from tmp001_dia where item < @par_nroDias +1
-- )
-- select *
-- from tmp001_dia where dia != 31
-- option(maxrecursion 0)

