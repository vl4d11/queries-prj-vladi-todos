-- if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_os_asignarActividades','p'))
-- drop procedure dbo.usp_os_asignarActividades
-- go
-- create procedure dbo.usp_os_asignarActividades
declare
@pos_id varchar(10)
= 52
-- as
-- begin
-- set nocount on
-- set language english
-- begin try
select top 0
cast(null as bigint) proy_id,
cast(null as char(1)) proy_miembro,
cast(null as int) pos_id into #tmp001_param

declare @data varchar(max)= (
select (select
';select ', Proy_Id, ',''R'',*from(values(',
replace(Proy_Responsables, '•', '),('), '))t(a)',
';select ', Proy_Id, ',''E'',*from(values(',
replace(Proy_EquipoTrabajo, '•', '),('), '))t(a)'
from dbo.A10_Proyectos
where concat(isnull(Proy_Responsables, ''), isnull(Proy_EquipoTrabajo, '')) != ''
for xml path, type).value('.','varchar(max)'))
insert into #tmp001_param exec(@data)

;with tmp001_sep(t,r,i,e) as(
    select*from(values('|','~','^',' '))tablaSep(sepCamp,sepReg,sepList,sepEsp)
)
,tmp001_cab(dato)as(
    select concat(
    'Proyecto|Actividad|Lugar|Responsable|Termino|Prioridad|Avance|Estado',r,
    '130|100|100|100|100|100|100|100')
    from tmp001_sep
)
,hlp001_prioridades(dato)as(
    select stuff((select r, Prioridad_Id, t, Prioridad_Nom
    from dbo.m_Prioridades where Prioridad_Disponible = 1
    for xml path, type).value('.','varchar(max)'),1,1,i)
    from tmp001_sep
)
,hlp001_estados(dato)as(
    select stuff((select r, Est_Id, t, Est_Nom
    from dbo.PR20_SeguimientoEstados where Est_Disponible = 1
    for xml path, type).value('.','varchar(max)'),1,1,i)
    from tmp001_sep
)
,hlp001_usuarioXproy(dato) as(
    select stuff((select r, t.pos_id, t, t.proy_miembro, t, t.proy_id, t,
    tu.Pos_ApPat, e, tu.Pos_ApMat, e, tu.Pos_Nombres
    from(select t.proy_id, t.proy_miembro, t.pos_id, t.dato
    from(select p.proy_id, p.proy_miembro, p.pos_id,
    max(isnull(t.dato,0))over(partition by p.proy_id) max, t.dato
    from #tmp001_param p
    outer apply(select 1 dato from(values(@pos_id,'R'))t(pos_id,proy_miembro)
    where t.pos_id = p.pos_id and t.proy_miembro = p.proy_miembro)t)t
    where t.max = 1 or (t.max = 0 and t.pos_id = @pos_id))t,
    dbo.RH10_Postulantes tu where t.pos_id = tu.pos_id
    order by t.proy_id, t.dato desc, tu.Pos_ApPat, tu.Pos_ApMat
    for xml path, type).value('.','varchar(max)'),1,1,i)
    from tmp001_sep
)
,tmp001_proyectos as(
    select t.Proy_Id, t.Proy_Nombre, tt.proy_miembro, u.UO_Nombre, tt.pos_id
    from dbo.A10_Proyectos t, dbo.A10_UOs u, #tmp001_param tt
    where t.Proy_Id = tt.Proy_Id and tt.pos_id = @pos_id and t.UO_Id = u.UO_Id
)
,hlp001_proyectos(dato) as(
    select stuff((select r, t.UO_Nombre, t, t.Proy_Id, t, t.Proy_Nombre, ' (', t.proy_miembro, ')'
    from tmp001_proyectos t
    order by t.proy_id
    for xml path, type).value('.','varchar(max)'),1,1,i)
    from tmp001_sep
)
select
-- select concat(cab.dato, (select r,
convert(varchar, t.FechaFin, 23), t,
t.Comentarios, t,
t.Seg_Id, t,
t.Proy_Id, t,
t.Actividad, t,
t.Lugar, t,
t.Responsable_Id, t,
convert(varchar, t.FechaTermino, 23), t,
t.Prioridad_Id, t,
t.Avance, t,
t.Estado_Id
from dbo.PR20_SeguimientoCAB t, tmp001_proyectos p
,tmp001_sep
where t.Proy_Id = p.Proy_Id and (p.proy_miembro = 'R' or p.pos_id = t.Responsable_Id)
-- for xml path, type).value('.','varchar(max)'),
-- t1.dato, t2.dato, t3.dato, t4.dato) data
-- from tmp001_sep, tmp001_cab cab,
-- hlp001_prioridades t1,
-- hlp001_estados t2,
-- hlp001_usuarioXproy t3,
-- hlp001_proyectos t4

-- end try
-- begin catch
--     select concat('error:', error_message()) data
-- end catch
-- end
-- go

-- exec dbo.usp_os_asignarActividades '52'


-- select*from mastertable('dbo.PR20_SeguimientoCAB')
