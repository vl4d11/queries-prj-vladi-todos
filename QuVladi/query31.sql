set rowcount 20

update t set
FormEvDes_Inicio = '2026-03-25',
FormEvDes_Duracion = 4
from dbo.rh50_evDesForms t

select*from dbo.rh50_evDesForms


return

select proy_id, Proy_Nombre
from dbo.a10_proyectos where Proy_Activo = 1


select * from dbo.rh00_organigramaCab tt

-- select t.OrgP_Id, tt.Proy_Id, t.Area_Id, t.OrgP_PuestoNombre, t.Pues_Id, t.grado
select *
from dbo.RH00_OrganigramaPuestos t

-- where t.Org_Id = tt.Org_Id and not grado is null



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
