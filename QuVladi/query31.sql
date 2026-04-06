if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_mantenimiento_cabecera_detalle_bucle','p'))
drop procedure dbo.usp_mantenimiento_cabecera_detalle_bucle
go
create procedure dbo.usp_mantenimiento_cabecera_detalle_bucle
@data varchar(max) = null
as
begin
begin try
set nocount on
set language english

if nullif(@data,'') is null return

declare @auth int, @cta int, @tot int, @pk_cabecera bigint, @meta_detalle varchar(max)
select top 0
cast(null as int) item,
cast(null as int) auth,
cast(null as int) itera,
cast(null as varchar(max)) collate database_default dato into #tmp001_matrizDetalle
create table #tmp001_out(
    inc int identity,
    accion varchar(6) collate database_default,
    item bigint
)
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
    from #tmp001_matrizDetalle t
    where t.itera = tt.itera
    order by t.item
    for xml path, type).value('.','varchar(max)'), 1, 1, '')
    from #tmp001_matrizDetalle tt order by tt.itera

    select @tot = count(1) +2, @cta = 2 from #tmp001_data_detalle
    where item != 1
    select @meta_detalle = concat(@auth, '|', dato) from #tmp001_data_detalle
    where item = 1

    while (@cta < @tot)begin

        select @data = null
        select @data = concat(@meta_detalle, (
        select '|', dato
        from(select item,
        case when item = 2 and value = ''
            then convert(varchar(500), @pk_cabecera)
            else convert(varchar(500), value) end dato
        from(
        select row_number()over(order by (select 1)) item, value
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

    select @data = dato from #tmp001_cadenas where item = 1
    exec dbo.usp_mantenimiento_generico_simple @data, 1
end


-- NOTA LLEGA SOLO DETALLE
-- =============================
if exists(select 1 from #tmp001_cadenas where dato = '' and item = 1 having count(1) = 1)begin

    select @data = dato from #tmp001_cadenas where item = 2
    select @auth = substring(dato, 0, charindex('|', dato)) from #tmp001_cadenas where item = 2

    insert into #tmp001_matrizDetalle
    exec dbo.usp_armar_matriz_detalle @data

    insert into #tmp001_data_detalle
    select distinct tt.itera, stuff((select '|', t.dato
    from #tmp001_matrizDetalle t
    where t.itera = tt.itera
    order by t.item
    for xml path, type).value('.','varchar(max)'), 1, 1, '')
    from #tmp001_matrizDetalle tt order by tt.itera

    select @tot = count(1) +2, @cta = 2 from #tmp001_data_detalle
    where item != 1
    select @meta_detalle = concat(@auth, '|', dato) from #tmp001_data_detalle
    where item = 1

    while (@cta < @tot)begin

        select @data = null
        select @data = concat(@meta_detalle, (select '|', dato
        from(
        select row_number()over(order by (select 1)) item, value dato
        from #tmp001_data_detalle cross apply dbo.udf_split(dato, default)
        where item = @cta)t
        for xml path, type).value('.','varchar(max)'))

        exec dbo.usp_mantenimiento_generico_simple @data, 1

        select @cta+=1
    end

end

select stuff((select '|', item from #tmp001_out
order by inc
for xml path, type).value('.','varchar(max)'), 1, 1, '')

end try
begin catch
    select concat('error:', error_message()) dato
end catch
end
go



declare @data2 varchar(max)
= '4|4.1|4.9|2|0~5|5.1|5.2|5.3|5.4|5.5|1775393518966|2|5|0.26|1'
-- = '4|4.1|4.2|4.3|4.4|4.5|4.6|4.7|4.8|4.9|4.10|4.11||maria|bonita|7.36|1|0.83|1|1|1|2026-04-21|5~5|5.1|5.2|5.3|5.4|5.5|||18|0.03|1|||15|0.65|0'
-- = '4|4.1|4.2|4.3|4.4|4.5|4.6|4.7|4.8|4.9|4.10|4.11||maria|bonita|49|1|34|1|1|1|2026-04-22|4~5|5.1|5.2|5.3|5.4|5.5|||12|3|1|||11|7|1'
-- = '~5|5.1|5.2|5.3|5.4|5.5|||12|3|1|||11|7|1'
-- = '4|4.1|4.2|4.3|4.4|4.5|4.6|4.7|4.8|4.9|4.10|4.11||maria|bonita|49|1|34|1|1|1|2026-04-22|4~'

exec dbo.usp_mantenimiento_cabecera_detalle_bucle
-- @data2


-- delete dbo.rh50_evDesForms  where FormEvDes_Id > 1
-- delete dbo.rh50_evDesFormsDet  where FormEvDes_Id > 1



-- insert into dbo.rh50_evDesFormsDet(
-- FormEvDes_Id,Dic_Id,FEDDet_Peso,FEDDet_Activo,Crea_UserId,Crea_Fecha
-- )
-- select 1, 3, 0.76,1,4, getdate()
-- insert into dbo.rh50_evDesFormsDet(
-- FormEvDes_Id,Dic_Id,FEDDet_Peso,FEDDet_Activo,Crea_UserId,Crea_Fecha
-- )
-- select 1, 11, 0.92 ,1,4, getdate()

-- delete dbo.rh50_evDesFormsDet where FEDDet_ID in (1775306266443, 1775306266486)

select*from dbo.rh50_evDesForms
select*from dbo.rh50_evDesFormsDet


-- truncate table dbo.m_diccionarios
-- insert into dbo.m_diccionarios
-- select*from dbo.m_diccionarios_back

-- select*from dbo.m_diccionarios


-- select*from dbo.m_diccionarios where Dic_Tipo = 'CO'

-- select*from dbo.mastertablas
-- select*from dbo.masterAudit

-- select*from mastertable('dbo.rh50_evDesForms')
-- select*from mastertable('dbo.rh50_evDesFormsDet')
