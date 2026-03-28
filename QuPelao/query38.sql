use SCC_REMUNERACION  -- juanca
go

alter procedure dbo.usp_remuneracion_datos
@data varchar(max)
as
begin
set nocount on
declare @tot int, @cta int = 1,
@tempGlob varchar(200) = replace(convert(varchar(36), newid()), '-','_'),
@cabecera varchar(1000), @cabSplit varchar(1000)
select top 0
cast(null as varchar(4)) collate database_default anno,
cast(null as varchar(2)) collate database_default aux,
cast(null as varchar(2)) collate database_default mesIni,
cast(null as varchar(2)) collate database_default mesFin
into #tmp001_param

select @data = dato from dbo.udf_splice(@data, default, default)
insert into #tmp001_param
exec(@data +'cross apply dbo.udf_periodoIniFin(a2)tt')

select tt.item, t.cod_conceptompp into #tmp001_conceptos
from dbo.mpp_conceptompp t, (values(1),(2))tt(item)
where t.tip_concepto = 'I' and t.flg_ordinario = 'N'
order by tt.item, t.cod_conceptompp

select row_number()over(order by (select 1)) +1 item, cod_conceptompp
into #tmp001_relacion from #tmp001_conceptos where item = 1 order by cod_conceptompp

select @cabecera = concat('select \
row_number()over(order by cod_trabajador)item, cod_trabajador', (
select ',num_', cod_conceptompp from #tmp001_conceptos
where item = 1 order by 2
for xml path, type).value('.','varchar(max)'))

select @cabSplit = concat('select item, concat(cod_trabajador', (
select ',''|'', num_', cod_conceptompp
from #tmp001_conceptos
where item = 1 order by 2
for xml path, type).value('.','varchar(max)'),
')dato into ##tmp001_salida', @tempGlob,' from #tmp001_salida')

;with tmp001_preData(dato)as(
    select (select dato
    from(select distinct concat(
    case tt.item when 1 then concat( @cabecera,
    ' into #tmp001_salida from(select row_number()over(partition by cod_trabajador \
    order by txt_mesproceso)item,*\
    from(select distinct*from(select t.cod_trabajador, t.txt_mesproceso, ')
    else 'sum(' end, stuff((
    select case tt.item when 1 then ',ltrim(str(sum(' else '+' end, 't.num_',
    t.cod_conceptompp,
    case tt.item when 1 then concat(')over(partition by t.cod_trabajador)/6,10,2)) num_',
    t.cod_conceptompp) end
    from #tmp001_conceptos t
    where t.item = tt.item order by 1, 2
    for xml path, type).value('.','varchar(max)'),1,1,''),
    case tt.item when 1 then ',' else
    ')over(partition by t.cod_trabajador, t.txt_mesproceso) SubMonto' end) dato
    from #tmp001_conceptos tt)t
    for xml path, type).value('.','varchar(max)')
)
select @data = concat(dato,
' from dbo.mpp_findemes t, dbo.mpp_empleado ttt, #tmp001_param tt \
where t.cod_trabajador = ttt.cod_trabajador and ttt.est_retiro = ''A'' and \
t.txt_anoproceso = tt.anno and \
t.txt_mesproceso between tt.mesIni and tt.mesFin)t \
where SubMonto > 0)t)t where t.item = 3')
from tmp001_preData
exec(@data + @cabSplit)

select top 0
cast(null as int) item,
cast(null as varchar(max)) dato into #tmp001_salida

exec('insert into #tmp001_salida select*from ##tmp001_salida'+ @tempGlob)

select top 0
cast(null as int) item,
cast(null as varchar(100)) valor,
cast(null as varchar(10)) concepto into #tmp001_valores
select @tot = count(1)+1 from #tmp001_salida
select top 0
cast(null as varchar(100)) cod_trabajador,
cast(null as varchar(100)) concepto,
cast(null as numeric(10, 2)) importe into #tmp001_final

while @cta < @tot begin
    insert into #tmp001_valores
    select @cta, value, cod_conceptompp from(
    select row_number()over(order by (select 1)) item1, value
    from #tmp001_salida
    cross apply dbo.udf_split(dato, default)
    where item = @cta)t
    outer apply(select*from #tmp001_relacion tt where tt.item = t.item1)tt
    where value > '0.00'
    select @cta +=1
end
select @cta = 1

while @cta < @tot begin
    with tmp001_codTrabajador(codtrab)as(
        select valor from #tmp001_valores where item = @cta and concepto is null
    )
    insert into #tmp001_final
    select codtrab, concepto, valor
    from #tmp001_valores, tmp001_codTrabajador
    where item = @cta and not concepto is null
    select @cta +=1
end

;with tmp001_sep(t,r,i)as(
    select*from(values('|','¬','^'))t(sepCamp,sepReg,sepList)
)
,tmp001_cab(dato)as(
    select concat('cod_trabajador|cod_concepto|importe', r,
    '100|100|100', r, 'String|String|Decimal')
    from tmp001_sep
)
select concat(c.dato, (select r, cod_trabajador, t, concepto, t, importe
from #tmp001_final
for xml path, type).value('.','varchar(max)'))
from tmp001_sep, tmp001_cab c

end
go


exec dbo.usp_remuneracion_datos '2025|02'



-- go
-- create function dbo.udf_periodoIniFin(
--      @input varchar(2)
-- )
-- returns table as return(
-- select
-- isnull(case @input when '07' then '01' end, '07') ini,
-- isnull(case @input when '07' then '06' end, '12') fin
-- )
