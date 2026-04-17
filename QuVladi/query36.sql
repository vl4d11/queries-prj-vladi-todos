

set rowcount 0


select*from dbo.RH50_TipoEvaluacion e
return


select*from dbo.rh50_DesigEvaluados_cab
select*from dbo.rh50_DesigEvaluados_det


select*from dbo.rh50_evDes



select Concat(p.pos_ApPat,' ',p.pos_ApMat,' ',p.pos_Nombres,' (',e.Descripcion,')')
from RH50_DesigEvaluados_CAB c
cross apply RH50_DesigEvaluados_Det d
cross apply RH30_Trabajadores t
cross apply RH10_Postulantes p
cross apply RH50_TipoEvaluacion e
where c.Id_EvaluadoCab = d.Id_EvaluadoCab
and c.Id_TipoEv = e.Id_TipoEv
and d.Trab_Sec = t.Trab_Sec
and t.pos_Id = p.Pos_Id
and c.Evaluador_Id = 1775686949090



-- select*from dbo.rh50_evDesTipos
-- select*from sys.key_constraints where type = 'UQ'
return
-- insert into dbo.rh50_DesigEvaluados_cab(
-- FormEDL_Id,
-- Proy_Id,
-- AreaOrg_Id,
-- PuestoOrg_Id,
-- Evaluador_Id,
-- Id_TipoEv)
-- select 1, 1655419457733, null, 43, 1775686949090, 1 union all
-- select 2, 1655419457733, null, 43, 1775686949090, 2 union all
-- select 3, 1655419457733, null, 43, 1775686949090, 1 union all
-- select 1, 1655419457733, null, 46, 1775686949090, 2


-- insert into dbo.rh50_DesigEvaluados_det(
-- Id_EvaluadoCab,
-- Proy_Id,
-- Area_Id,
-- Trab_Sec,
-- PuestoOrg_Id
-- )
-- select 2, 1655419457733, null, 1775686949090, 43 union all
-- select 3, 1655419457733, null, 1775686949090, 43 union all
-- select 4, 1655419457733, null, 1775686949090, 43 union all
-- select 5, 1655419457733, null, 1775686949090, 43


update t set PuestoOrg_Id = 43 from dbo.rh50_DesigEvaluados_cab t where PuestoOrg_Id is null
delete dbo.rh50_DesigEvaluados_det where Id_EvaluadoCab in (2,5)

select*from dbo.rh50_DesigEvaluados_cab
select*from dbo.rh50_DesigEvaluados_det

select proy_id, Proy_Nombre
from dbo.a10_proyectos
where proy_id = 1655419281410 and  Proy_Activo = 1

-- select*from mastertable('dbo.rh50_DesigEvaluados_cab')
-- select*from mastertable('dbo.rh50_DesigEvaluados_det')
return
-- select*from mastertable('dbo.rh50_DesigEvaluados_cab')
-- select*from mastertable('dbo.rh50_DesigEvaluados_det')
-- select*from mastertable('dbo.rh00_organigramaCab')
-- select*from mastertable('dbo.RH00_OrganigramaPuestos')
-- select*from mastertable('dbo.rh30_trabajadores')
-- return

-- select*from dbo.rh50_tipoEvaluacion


select proy_id, Proy_Nombre
from dbo.a10_proyectos
where proy_id = 1655419281410 and  Proy_Activo = 1

select t.OrgP_Id, tt.Proy_Id, t.Area_Id, t.OrgP_PuestoNombre, t.Pues_Id, t.grado
from dbo.RH00_OrganigramaPuestos t, dbo.rh00_organigramaCab tt
where t.Org_Id = tt.Org_Id and not grado is null

select tr.*
from dbo.rh30_trabajadores tr
,dbo.RH00_OrganigramaPuestos t
,dbo.rh00_organigramaCab tt
where t.Org_Id = tt.Org_Id and
tr.Trab_Proys = tt.Proy_Id and t.Pues_Id = tr.Pues_Org_Id
order by tr.pos_id


select*from dbo.RH10_Postulantes where pos_id in (1232, 52)

-- select*from dbo.rh30_trabajadores tr

select*from dbo.mastertable('dbo.rh30_trabajadores')
select*from dbo.rh30_trabajadores
return
select*from dbo.rh50_evDes
select*from dbo.rh50_evDesTipos
select*from dbo.m_diccionariosTipos

select*from dbo.mastertable('dbo.rh50_evDesForms')
-- select*from dbo.mastertable('dbo.rh50_evDesFormsDet')


set rowcount 200

-- update t set Dic_Id = 3
-- from dbo.rh50_evDesFormsDet t where FEDDet_ID = 1774085626386

-- update t set Dic_Id = 4
-- from dbo.rh50_evDesFormsDet t where FEDDet_ID = 1774085643790


-- select*from dbo.m_diccionarios where Dic_Disponible = 1 and Dic_Tipo = 'CO'

-- update t set
-- FEDDet_Activo = 0
-- from dbo.rh50_evDesFormsDet t where FEDDet_ID = 1720611625220

select*from mastertable('dbo.m_areas')
select*from mastertable('dbo.m_puestos')

select*from dbo.rh50_evDesForms
select*from dbo.rh50_evDesFormsDet


return





-- select Area_Id, Area_Descripcion
-- from dbo.m_areas where Area_Activo = 1

-- select Pues_Id, Pues_Nombre
-- from dbo.m_puestos where Pues_Activo = 1


select Pos_Id, Pos_ApPat, Pos_ApMat, Pos_Nombres, Pos_DocNumero
from dbo.RH10_Postulantes where pos_id = 52


select * -- Pos_Id, Trab_Proys, Pues_Org_Id, Trab_JefeDirecto
from dbo.rh30_trabajadores  --where pos_id = 52






return
select*from dbo.rh50_tipoEvaluacion
select*from dbo.rh50_desigEvaluados_cab
select*from dbo.rh50_desigEvaluados_det


-- select*from dbo.rh50_evDesForms
-- select*from dbo.rh50_evDesFormsDet
