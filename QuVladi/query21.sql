-- create table dbo.masterTablas(
--     item int identity,
--     tabla varchar(300) collate database_default
-- )
-- go
-- insert into dbo.masterTablas
-- select*from(values('dbo.A00_Usuarios'),
-- ('dbo.RH10_Postulantes')
-- )t(tabla)

-- go
-- create table dbo.masterAudit(
--     campo varchar(100) collate database_default
--     accion int,
-- )
-- go
-- insert into dbo.masterAudit
-- select*from(values('CreaId'),('CreaFecha'),('ModiId'),('ModiFecha')
-- )t(campo)
go
-- set rowcount 10
-- select*from dbo.RH10_Postulantes
-- select*from dbo.A00_Usuarios

-- select*from dbo.masterTable('dbo.RH10_Postulantes')


go
if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_listar_tablas','p'))
drop procedure dbo.usp_listar_tablas
go
create procedure dbo.usp_listar_tablas
@tablas varchar(500)
as
begin
set nocount on
select tt.item, tt.tabla, t.orden into #tmp541y_tablas
from(select row_number()over(order by (select 1)) orden, value
    from dbo.udf_split(@tablas, default)
)t,dbo.masterTablas tt where t.value = tt.tabla

select*into #tmp001_types from(values
(0,'char'),(0,'varchar'),
(1,'tinyint'),(1,'smallint'),(1,'int'),(1,'bigint'),
(2,'float'),(2,'decimal'),(2,'numeric'),
(3,'date'),(3,'datetime'),
(4,'bit')
)t(tipo_dato,nombre)

select orden, item, c.column_id, tabla, c.name,
case when not c.collation_name is null then c.max_length end length,
c.is_nullable, c.is_identity, c.default_object_id,
isnull(i.is_primary_key, 0) is_primary_key,
yy.tipo_dato, isnull(au.audi, 0) audi
from sys.tables t
cross apply #tmp541y_tablas
cross apply sys.columns c
cross apply sys.types ty
outer apply(select*from sys.index_columns ic
    where ic.object_id = t.object_id and ic.object_id = c.object_id and ic.index_column_id = c.column_id)ic
outer apply(select*from sys.indexes i
    where i.object_id = t.object_id and i.object_id = ic.object_id and i.index_id = ic.index_id)i
outer apply(select*from #tmp001_types yy
    where yy.nombre = ty.name)yy
outer apply(select accion audi from dbo.masterAudit au
    where au.campo = c.name)au
where t.name = parsename(tabla, 1)and t.schema_id = schema_id(parsename(tabla, 2))
and t.object_id = c.object_id
and c.system_type_id = ty.system_type_id and c.user_type_id = ty.user_type_id
order by orden, c.column_id

end
go

exec dbo.usp_listar_tablas 'dbo.RH10_Postulantes|dbo.A00_Usuarios'
