-- select text from sys.syscomments where id=object_id('dbo.usp_listarMenus22', 'p')

if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_listarMenus22', 'p'))
drop procedure dbo.usp_listarMenus22
go
CREATE procedure dbo.usp_listarMenus22
@data varchar(max)
as
begin
set nocount on
begin try

select top 0
cast(null as varchar(100)) USER_Usuario,
cast(null as varchar(100)) clave into #tmp001_usuario
select @data =
concat('select*from(values(''', replace(@data, '|', ''','''), '''))t(a,b)')
insert into #tmp001_usuario exec(@data)

;with tmp001_sep(t,r,i)as(
    select*from(values('|','~','^'))t(sepCamp,sepReg,sepList)
)
,tmp001_datos as(
    select coalesce((select convert(varchar, t.Pos_id)
    from dbo.A00_Usuarios t, #tmp001_usuario tt
    where t.USER_Usuario = tt.USER_Usuario and
    t.USER_Clave256 = convert(varchar(128), hashbytes('sha2_512', tt.clave), 2)),
    'warning') Pos_id
)
select concat(ttt.Pos_id,(select r,
tt.menu_id, t, ltrim(tt.menu_nombre), t, ltrim(tt.menu_router)
from dbo.A00_UsuariosRoles t, dbo.A00_Menus tt
where t.menu_id = tt.menu_id and t.Pos_id = try_cast(ttt.Pos_id as int)
and t.rol_activo = 1
order by t.menu_id
for xml path, type).value('.','varchar(max)'))
from tmp001_sep, tmp001_datos ttt

end try
begin catch
    select concat('error:', error_message())
end catch
end
go

declare @data varchar(max)
='varrieta|4321'

exec dbo.usp_listarMenus22 @data
exec dbo.usp_listarMenus22 'paul|1356'
