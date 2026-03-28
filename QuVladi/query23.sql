if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_login_eva_desempenno','p'))
drop procedure dbo.usp_login_eva_desempenno
go
create procedure dbo.usp_login_eva_desempenno
@data varchar(max)
as
begin
begin try
set nocount on

select top 0
cast(null as varchar(100)) USER_Usuario,
cast(null as varchar(100)) clave into #tmp001_usuario
select @data = dato from dbo.udf_splice(@data, default, default)
insert into #tmp001_usuario exec(@data)

;with tmp001_sep(t,r,i) as(
    select*from(values('|','~','^'))t(sepCamp,sepReg,sepList)
)
,tmp001_datos as(
    select USER_Usuario,
    convert(varchar(128), hashbytes('sha2_512', clave), 2) USER_Clave256
    from #tmp001_usuario
)
,tmp001_login as(
    select t.User_Id, t.pos_id
    from tmp001_datos tt, dbo.A00_Usuarios t
    where tt.USER_Usuario = t.USER_Usuario and tt.USER_Clave256 = t.USER_Clave256
)
select coalesce((select concat(u.User_Id, (select r,
    ttt.menu_id, '00', t, ltrim(ttt.Menu_Nombre), t, ttt.menu_router
from tmp001_login t, dbo.A00_UsuariosRoles tt, dbo.A00_menus ttt
where t.Pos_Id = tt.pos_id and
    substring(tt.Menu_Id, 1, 2) = '07' and tt.Rol_Activo = 1 and
    ttt.menu_id = tt.Menu_Id
order by ttt.menu_id
for xml path, type).value('.','varchar(max)'))
from tmp001_sep, tmp001_login u), 'warning')

end try
begin catch
    select concat('error:', error_message()) dato
end catch
end
go

exec dbo.usp_login_eva_desempenno 'varrieta|4321'
exec dbo.usp_login_eva_desempenno 'varrieta|43211'

-- select*from dbo.A00_menus where substring(Menu_Id, 1, 2) = '07'
