if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_splitCadena', 'p'))
drop procedure dbo.usp_splitCadena
go
create procedure dbo.usp_splitCadena
@data varchar(max)
as
begin
set nocount on

select top 0
cast(null as int) clave2,
cast(null as int) column_id,
cast(null as varchar(100)) name into #tmp001_loginConvocatoriaData
exec dbo.usp_loginConvocatoriaData 1

create table #tmp001_datos(
    item int identity,
    dato varchar(max)
)
create table #tmp002_datos(
    item int,
    grupo int,
    tabla int,
    campo int,
    dato varchar(max)
)
select @data =
(select 'select*from(values(''', replace(@data, '|', '''),('''), '''))t(a);'
for xml path, type).value('.','varchar(max)')
insert into #tmp001_datos exec(@data)

select id corr, tabla into #tmp001_tablas from dbo.udf_lisTablas(default)

;with tmp001_split as(
    select item cta, count(1)over()/2 tot from #tmp001_datos
)
,tmp002_split as(
    select corr, grupo, item, case grupo when 0 then
    replace(replace(dato, '.','¿*5?'), '''', '(/)') else dato end dato
    from(select row_number()over(partition by grupo order by item) corr, *
    from(select case when t.item > tot then 1 else 0 end grupo, t.item, t.dato
    from #tmp001_datos t, tmp001_split
    where t.item = cta order by t.item offset 0 rows)t)t
    order by t.item offset 0 rows
)
select @data = replace(replace((
select 'select*from(values(''', replace(dato, '.', ''','''), '''))t(a,b,c,d,e);'
from(select tt.corr, concat(tt.corr, '.', t.dato,'.', tt.dato) dato
from tmp002_split t,
(select t.corr, t.item, t.dato from tmp002_split t where t.grupo = 0)tt
where t.grupo = 1 and t.corr = tt.corr
order by tt.corr offset 0 rows)t order by corr
for xml path, type).value('.','varchar(max)'), '¿*5?', '.'), '(/)', '''')
insert into #tmp002_datos exec(@data)

if exists(select 1 from #tmp002_datos where tabla = 4)
    with tmp001_maxi(sgt) as(
        select count(1) + 1 from #tmp002_datos
    )
    insert into #tmp002_datos
    select sgt, 1, 4, 1, '' from tmp001_maxi union all
    select sgt +1, 1, 4, 2, '' from tmp001_maxi


insert into #tmp001_splitCadena
select t.item, max(t.tblOne)over(Partition by tt.tabla) maxi, t.grupo,
t.tblOne, tt.tabla, ttt.name, t.dato
from(select dense_rank()over(order by tabla) corr,
row_number()over(partition by tabla, grupo order by item) tblOne,
item, grupo, tabla, campo, dato
from #tmp002_datos)t, #tmp001_tablas tt, #tmp001_loginConvocatoriaData ttt
where t.tabla = tt.corr and t.tabla = ttt.clave2 and t.campo = ttt.column_id
order by t.item

end
go


if exists(select 1 from sys.sysobjects where id = object_id('dbo.udf_lisTablas','if'))
drop function dbo.udf_lisTablas
go
create function dbo.udf_lisTablas(
    @item int = null
)returns table as return(
    select*from(
    select 1, 'dbo.RH10_Postulantes' union all
    select 2, 'dbo.RH10_PosDirecciones' union all
    select 3, 'dbo.RH10_PosEPPs' union all
    select 4, 'dbo.A00_Usuarios' union all
    select 5, 'dbo.RH10_PosCuentas')t(id, tabla) where id = isnull(@item, id)
)
go

select id, tabla from dbo.udf_lisTablas(default)


if exists(select 1 from sys.sysobjects where id = object_id('dbo.udf_getpk','if'))
drop function dbo.udf_getpk
go
create function dbo.udf_getpk(
    @tabla varchar(100)
)returns table as return(
    select ttt.name pk, ttt.is_identity itty, ttt.default_object_id def,
    req = case when patindex('%RH10_PosEPPs', @tabla) > 0 then 1 else 0 end
    from sys.columns ttt, sys.index_columns t, sys.indexes tt
    where ttt.object_id = t.object_id and ttt.column_id = t.column_id and
    t.object_id = tt.object_id and t.index_id = tt.index_id and
    tt.is_primary_key = 1 and ttt.object_id = object_id(@tabla)
)
go

select pk, itty, def, req from dbo.udf_getpk('dbo.RH10_PosDirecciones')


go
if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_enProceso'))
drop function dbo.udf_enProceso
go
create function dbo.udf_enProceso(
)returns table as return(
    select Proceso_Id, iif(Proceso_Id = 4, 1, 0) bloqueo, Proceso_Nombre
    from dbo.RH10_ProcesosRRHH
)
go


if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_gSanguineo','if'))
drop function dbo.udf_gSanguineo
go
create function dbo.udf_gSanguineo()
returns table as return(
select*from(values
(1, 'O+'),
(2, 'O-'),
(3, 'A+'),
(4, 'A-'),
(5, 'B+'),
(5, 'B-'),
(7, 'AB+'),
(8, 'AB-')
)t(item, gSan))
go

if exists(select 1 from sys.sysobjects where id=object_id('dbo.tr_Dev_Usuarios_GeneraClave','tr'))
drop trigger dbo.tr_Dev_Usuarios_GeneraClave
go
create trigger dbo.tr_Dev_Usuarios_GeneraClave
on dbo.A00_Usuarios
after insert
as
begin
set nocount on
    update t
    set t.USER_Clave256 =
    convert(varchar(128), hashbytes('sha2_512', t.USER_Usuario), 2)
    from dbo.A00_Usuarios t, inserted i
    where t.User_Id = i.User_Id
end
go

return
alter table dbo.RH10_Postulantes add constraint def_procesos default(1) for PosEst_Proceso
alter table dbo.RH10_Postulantes add constraint def_estado default(1) for PosEst_Id
alter table dbo.RH10_Postulantes add constraint def_nacional default('PERUANA') for Pos_NacPais

alter table dbo.RH10_PosCuentas add constraint def_sueldo default('SUELDO') for Pos_CtaBanco


-- default (datediff_big(millisecond,'19700101',dateadd(hour,(-5),getutcdate())))
