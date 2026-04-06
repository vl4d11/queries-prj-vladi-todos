declare @data varchar(max)
= '4|4.1|4.2|4.3|4.4|4.5|4.6|4.7|4.8|4.9|4.10|4.11||maria|bonita|49|1|34|1|1|1|2026-04-22|4~5|5.1|5.2|5.3|5.4|5.5|||12|3|1|||11|7|1'
-- = '~5|5.1|5.2|5.3|5.4|5.5|||12|3|1|||11|7|1'
-- = '4|4.1|4.2|4.3|4.4|4.5|4.6|4.7|4.8|4.9|4.10|4.11||maria|bonita|49|1|34|1|1|1|2026-04-22|4~'


set nocount on
set language english

declare @auth int, @cta int, @tot int, @pk_cabecera bigint, @meta_detalle varchar(max)
select top 0
cast(null as int) item,
cast(null as int) auth,
cast(null as int) itera,
cast(null as varchar(max)) collate database_default dato into #tmp001_matrizDetalle
create table #tmp001_out(accion varchar(6) collate database_default, item bigint)
create table #tmp001_data_detalle(
    item int identity,
    itera int,
    dato varchar(max) collate database_default
)
create table #tmp001_cadenas(
    item int identity,
    dato varchar(max) collate database_default
)
insert into #tmp001_cadenas
select value from dbo.udf_split(@data, '~')


-- NOTA LLEGA CABECERA Y DETALLE
-- =============================
if exists(select 1 from #tmp001_cadenas where dato != '' having count(1) = 2)begin

    select @data = dato from #tmp001_cadenas where item = 1

    exec dbo.usp_mantenimiento_generico_simple
    @data,
    1,
    'cross apply dbo.udf_RH50_EvDesForms_pk_001()nn',
    'n.FormEvDes_Id,',
    'isnull(n.FormEvDes_Id, nn.FormEvDes_Id) FormEvDes_Id,'

    select @pk_cabecera = item from #tmp001_out


    select @auth = substring(dato, 0, charindex('|', dato)) from #tmp001_cadenas where item = 1
    select @data = concat(@auth, '|', dato) from #tmp001_cadenas where item = 2

    insert into #tmp001_matrizDetalle
    exec dbo.usp_armar_matriz_detalle @data

    insert into #tmp001_data_detalle
    select distinct tt.itera, stuff((select '|', t.dato
    from #tmp001_matrizDetalle t where t.itera = tt.itera order by t.item
    for xml path, type).value('.','varchar(max)'), 1, 1, '')
    from #tmp001_matrizDetalle tt order by tt.itera

    select @tot = count(1) +2, @cta = 2 from #tmp001_data_detalle where item != 1
    select @meta_detalle = concat(@auth, '|', dato) from #tmp001_data_detalle where item = 1

    while (@cta < @tot)begin

        select @data = null

        select @data = concat(@meta_detalle, (
        select '|', case item when 1 then  isnull(nullif(dato, 0),'')  else dato end
        from(select item, convert(varchar,
        case when item = 2 and value = '' then @pk_cabecera else value end) dato
        from(select row_number()over(order by (select 1)) item, value
        from #tmp001_data_detalle cross apply dbo.udf_split(dato, default)
        where item = @cta)t)t
        for xml path, type).value('.','varchar(max)'))

        exec dbo.usp_mantenimiento_generico_simple @data, 1
        select @cta+=1
    end
end


-- NOTA LLEGA SOLO CABECERA
-- =============================
if exists(select 1 from #tmp001_cadenas where dato = '' and item = 2 having count(1) = 1)begin



    select 'cab only'

end


-- NOTA LLEGA SOLO DETALLE
-- =============================
if exists(select 1 from #tmp001_cadenas where dato = '' and item = 1 having count(1) = 1)begin



    select 'det only'

end


select stuff((select '|', item from #tmp001_out
for xml path, type).value('.','varchar(max)'), 1, 1, '')





-- select*from dbo.mastertablas
-- select*from dbo.masterAudit

-- select*from mastertable('dbo.rh50_evDesForms')
-- select*from mastertable('dbo.rh50_evDesFormsDet')


-- select DATEFROMPARTS(YEAR(GETDATE()),1,1)
