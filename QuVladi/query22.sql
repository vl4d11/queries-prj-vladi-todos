if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_listar_metadata','p'))
drop procedure dbo.usp_listar_metadata
go
create procedure dbo.usp_listar_metadata
@dato varchar(max) output,
@tabla varchar(1000)
as
begin
set nocount on

select @dato = replace(replace(@dato, char(13),''), char(10), '')
select top 0
cast(null as varchar(5)) collate database_default campoU,
cast(null as varchar(50)) collate database_default tabla,
cast(null as varchar(50)) collate database_default campo,
cast(null as int) requerido,
cast(null as int) ancho,
cast(null as int) tipo_dato,
cast(null as int) tipo_ctl,
cast(null as varchar(100)) collate database_default datos into #tmp001_dataU_2312
select top 0
cast(null as varchar(3)) collate database_default auxU,
cast(null as varchar(50)) collate database_default tabla into #tmp001_tabla_7893
select top 0
cast(null as int) orden,
cast(null as int) item,
cast(null as int) column_id,
cast(null as varchar(50)) collate database_default tabla,
cast(null as varchar(50)) collate database_default campo,
cast(null as int) length,
cast(null as int) is_nullable,
cast(null as int) is_identity,
cast(null as int) default_object_id,
cast(null as int) is_primary_key,
cast(null as int) tipo_dato,
cast(null as int) audi into #tmp001_metadataU_11903

select @dato = replace(dato, 'select*', 'select null,*')
from dbo.udf_splice(@dato, default, default)
insert into #tmp001_dataU_2312 exec(@dato)
select @tabla = dato from dbo.udf_splice(@tabla, default, default)
insert into #tmp001_tabla_7893 exec(@tabla)

update t set t.tabla = tt.tabla from #tmp001_dataU_2312 t, #tmp001_tabla_7893 tt
where t.tabla = tt.auxU

select @tabla = stuff((select '|',tabla from #tmp001_tabla_7893
for xml path, type).value('.','varchar(max)'),1,1,'')
insert #tmp001_metadataU_11903 exec dbo.usp_listar_tablas @tabla

update tt set
tt.campoU = concat(t.item,'.', t.column_id),
tt.requerido = isnull(tt.requerido, iif(t.is_nullable=0,1,0)),
tt.ancho = isnull(tt.ancho, t.length),
tt.tipo_dato = isnull(tt.tipo_dato, t.tipo_dato),
tt.tipo_ctl = isnull(tt.tipo_ctl, ttt.ctl)
from #tmp001_metadataU_11903 t cross apply #tmp001_dataU_2312 tt
cross apply(select case isnull(tt.tipo_dato, t.tipo_dato)
when 0 then 1
when 1 then 1
when 2 then 1
when 3 then 2
when 4 then 3 end ctl)ttt
where t.tabla = tt.tabla and t.campo = tt.campo

;with tmp001_sep(t,r) as(
    select*from(values('*','|'))t(sepSubCamp,sepCamp)
)
select @dato = stuff((select r,
campoU, t, requerido, t, ancho, t, tipo_dato, t, tipo_ctl, t, datos
from #tmp001_dataU_2312
for xml path, type).value('.','varchar(max)'),1,1,'')
from tmp001_sep

end
go

-- select*from dbo.masterTablas
-- select*from dbo.masterAudit


declare @dato varchar(max) =
't|User_Id|||||234*45*12*45~
t|Pos_Id|||||234*45*12*45~
t|Patro_Id|||||234*45*12*45~
t|USER_Usuario||10|4||234*maria*12*45~
t|USER_Clave256|||||234*45*12*45~
t|USER_Token|||||234*45*roberto*45~
||||3|2|24*45*sonia morales*4~
t|User_Empresas|||||234*soto cueva*12*45~
t|User_UOs|||||234*45*12*45~
t|User_Proys|||||234*45*12*45~
t|User_ProyDefault|||||234*45*12*45'

exec dbo.usp_listar_metadata @dato output, 't|dbo.A00_Usuarios'
select top 0 cast(null as varchar(max)) collate database_default meta into #tmp001_meta
insert into #tmp001_meta select @dato

select meta from #tmp001_meta
