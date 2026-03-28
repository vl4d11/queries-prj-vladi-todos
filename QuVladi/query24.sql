-- create table dbo.m_Nivel_Posicion(
--     id_nivel int identity primary key not null,
--     nombre_nivel varchar(100),
--     grados_nivel varchar(20),
--     CreaId int,
--     CreaFecha datetime default(getdate()),
--     ModiId int,
--     ModiFecha datetime default(getdate())
-- )
-- go
-- insert into dbo.m_Nivel_Posicion(nombre_nivel, grados_nivel, CreaId)
-- select*from(values
-- ('obreros y tecnicos','6,7,8,9,10',4),
-- ('profesionales y supervisores','11,12,13',4),
-- ('jefaturas','14,15,16,17',4),
-- ('alta direccion','18,19',4)
-- )t(a1,a2,a3)
-- go
-- create table dbo.m_Escala_Likert(
--     id_escala int identity primary key not null,
--     puntaje int,
--     descripcion varchar(20),
--     CreaId int,
--     CreaFecha datetime default(getdate()),
--     ModiId int,
--     ModiFecha datetime default(getdate())
-- )
-- go
-- insert into dbo.m_Escala_Likert(puntaje, descripcion, CreaId)
-- select*from(values
-- (1,'Muy Bajo',4),
-- (2,'Bajo',4),
-- (3,'Promedio',4),
-- (4,'Alto',4),
-- (5,'Muy Alto',4)
-- )t(a1,a2,a3)

-- select*from dbo.m_PuestosRoles
-- select*from dbo.m_PuestosTipos

-- alter table dbo.m_Diccionarios add grado int
-- alter table dbo.RH00_OrganigramaPuestos add grado int

select*from dbo.m_Nivel_Posicion
select*from dbo.m_Escala_Likert

-- exec sys.sp_spaceused 'dbo.RH00_OrganigramaPuestos'
-- exec sys.sp_spaceused 'dbo.m_Puestos'
-- exec sys.sp_spaceused 'dbo.RH30_Trabajadores'

select t.Proy_Nombre, ttt.*
from dbo.A10_Proyectos t, dbo.RH00_OrganigramaCab tt, dbo.RH00_OrganigramaPuestos ttt
where t.proy_id = tt.proy_id and tt.Org_Id = ttt.Org_Id and
-- t.proy_id in (1732701910583, 1655419281410)
t.proy_id = 1655419281410


-- return
-- set rowcount 20
-- select*from dbo.RH00_OrganigramaCab
-- select*from dbo.RH00_OrganigramaPuestos
-- select*from dbo.m_Puestos
