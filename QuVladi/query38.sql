-- update t set FormEDL_Id = 3
-- update t set FormEDL_Id = 1
-- from dbo.rh50_DesigEvaluados_cab t


go
alter procedure dbo.usp_datosEncuesta
@data varchar(max)
as
begin
set nocount on

-- ;with tmp001_sep(t,r)as(
--     select*from(values('|','~'))t(SepCamp,SepReg)
-- )
-- select stuff((select top 50 r,
-- Proy_Id, t, Proy_Nombre, t, Proy_Descripcion, t, Proy_ArchivoLogo
-- from dbo.a10_proyectos
-- for xml path, type).value('.','varchar(max)'),1,1,'') data
-- from tmp001_sep

select top 10
Proy_Id, Proy_Nombre, Proy_Descripcion, Proy_ArchivoLogo
from dbo.a10_proyectos

select count(1) totalReg from dbo.a10_proyectos

end
go

exec dbo.usp_datosEncuesta 34
