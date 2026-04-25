use SCP_CEDIA_SUBSIDIO
go

alter procedure dbo.usp_total_dias
@data varchar(max)
as
begin
set nocount on

select top 0
    cast(null as varchar(10)) cod_trabajador,
    cast(null as char(4)) anio,
    cast(null as char(2)) mes into #tmp001_params

select @data = dato from dbo.udf_splice2(@data, default, default)
insert into #tmp001_params exec(@data)
update t set
anio = substring(convert(varchar,
    dateadd(mm, -1, convert(date, concat(anio,mes,'01'), 23)), 112),1, 4),
mes = substring(convert(varchar,
    dateadd(mm, -1, convert(date, concat(anio,mes,'01'), 23)), 112),5, 2)
from #tmp001_params t


;with tmp001_inicio as(
    select*, convert(date, concat(anio,mes,'01'), 112) fecha
    from #tmp001_params
)
,tmp001_secuencia as(
    select item from(select row_number()over(order by (select 1))-1 item
    from sys.fn_helpcollations())t where item < 12
)
,tmp001_periodo as(
    select cod_trabajador, substring(fecha, 1,4) anio, substring(fecha, 6, 2) mes, fecha
    from(select cod_trabajador, anio, mes, convert(varchar, dateadd(mm, -item, fecha), 23) fecha
    from tmp001_inicio, tmp001_secuencia)t
)
insert into #tmp001_totalDias
select distinct totalDias
from(select
    t.cod_trabajador, t.txt_mesproceso, t.txt_anoproceso,
    t.num_dias + isnull(tt.num_dias, 0) diasXmes,
    sum(t.num_dias + isnull(tt.num_dias, 0))over() totalDias
from dbo.mpp_findemes t
cross apply tmp001_periodo p
outer apply(
    select tt.num_dias
    from dbo.mpp_vacacion tt
    where tt.cod_trabajador = t.cod_trabajador
        and tt.num_periodo = t.txt_anoproceso
        and substring(convert(varchar, tt.fec_programada, 23), 6, 2) = t.txt_mesproceso
)tt
where t.cod_trabajador = p.cod_trabajador
    and t.txt_anoproceso = p.anio
    and t.txt_mesproceso = p.mes
order by p.fecha desc offset 0 rows
)t

end
go


-- NOTA:  ASI SE PRUEBA
-- ======================
select top 0
cast(null as int) total into #tmp001_totalDias
exec dbo.usp_total_dias 'VFH183|2026|01'
select total from #tmp001_totalDias
