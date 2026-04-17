if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_registrar_encuesta_datos_evdeslab','p'))
drop procedure dbo.usp_registrar_encuesta_datos_evdeslab
go
create procedure dbo.usp_registrar_encuesta_datos_evdeslab
@data varchar(max)
as
begin
begin try
set tran isolation level read uncommitted
set nocount on
begin tran

declare @auth int, @cta int, @tot int, @pk_cabecera bigint, @meta_detalle varchar(max)
select top 0
cast(null as int) item,
cast(null as int) auth,
cast(null as int) itera,
cast(null as varchar(max)) collate database_default dato into #tmp001_matrizDetalle
create table #tmp001_data_detalle(
    item int identity,
    itera int,
    dato varchar(max) collate database_default
)
create table #tmp001_out(
    inc int identity,
    accion varchar(6) collate database_default,
    item bigint
)

select @auth = substring(@data, 0, charindex('|', @data))

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
        then convert(varchar(500), '')
        else convert(varchar(500), value) end dato
    from(
    select row_number()over(order by (select 1)) item, value
    from #tmp001_data_detalle cross apply dbo.udf_split(dato, default)
    where item = @cta)t)t
    for xml path, type).value('.','varchar(max)'))

    exec dbo.usp_mantenimiento_generico_simple @data, 1

    select @cta+=1
end

select 1

-- select stuff((select '|', item from #tmp001_out
-- order by inc
-- for xml path, type).value('.','varchar(max)'), 1, 1, '')
commit;
end try
begin catch
    rollback;
    select concat('error:', error_message()) dato
end catch
end
go


-- exec dbo.usp_registrar_encuesta_datos_evdeslab
-- '4|8|8.1|8.2|8.3|8.4|8.5|8.6|8.7|8.8||1|1775686949090|1775686949090|43|32|3|||1|1775686949090|1775686949090|43|33|1|fdwwdq||1|1775686949090|1775686949090|43|31|3|'

-- delete dbo.rh50_evDes
select*from dbo.rh50_evDes



-- alter table dbo.rh50_evDes drop constraint UQ_rh50_evDes_Cols
-- ALTER TABLE dbo.rh50_evDes
-- ADD CONSTRAINT UQ_rh50_evDes_Cols
-- UNIQUE (FormEv_Id, Trab_Sec, PuesOrg_Id, Dic_Id);


-- ALTER TABLE dbo.rh50_DesigEvaluados_cab
-- ADD CONSTRAINT UQ_rh50_DesigEvaluados_cab_Cols
-- UNIQUE (FormEDL_Id, Proy_Id, PuestoOrg_Id, Id_TipoEv);


-- select object_name(parent_object_id),*
-- from sys.key_constraints where type = 'uq'
