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

;with tmp001_sep(t,r,i,b) as(
    select*from(values('|','~','^',' '))t(sepCamp,sepReg,sepList,sepBlan)
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
,tmp001_nombres(dato) as(
    select
    concat(rtrim(t.Pos_ApPat), b, rtrim(t.Pos_ApMat), b, rtrim(t.Pos_Nombres))
    from dbo.RH10_Postulantes t, tmp001_login tt, tmp001_sep
    where t.pos_id = tt.pos_id
)
,tmp001_menus as(
    select*from(values('0700'),('0704'))t(Menu_Id)
)
,tmp001_menus_detalle as(
    select menu_id, Menu_Nombre, menu_router,
        case cta_menu when tot then 1 else 0 end cta_menu
    from(select
        ttt.menu_id, ltrim(ttt.Menu_Nombre) Menu_Nombre, ttt.menu_router,
        count(m.dato)over() cta_menu, count(1)over() tot
    from tmp001_login t
    cross apply dbo.A00_UsuariosRoles tt
    cross apply dbo.A00_menus ttt
    outer apply(select 1 dato from tmp001_menus m where m.Menu_Id = tt.Menu_Id)m
    where t.Pos_Id = tt.pos_id and
        substring(tt.Menu_Id, 1, 2) = '07' and tt.Rol_Activo = 1 and
        tt.menu_id = ttt.Menu_Id)t
)
,tmp001_cta_menu as(
    select distinct cta_menu from tmp001_menus_detalle
)
select coalesce((select concat(u.User_Id, t, c.cta_menu, t, n.dato, (
select r, t.menu_id, '00', t, ltrim(t.Menu_Nombre), t, t.menu_router
from tmp001_menus_detalle t order by t.menu_id
for xml path, type).value('.','varchar(max)'))
from tmp001_sep, tmp001_login u,
tmp001_nombres n, tmp001_cta_menu c), 'warning')

end try
begin catch
    select concat('error:', error_message()) dato
end catch
end
go

exec dbo.usp_login_eva_desempenno 'varrieta|4321'
exec dbo.usp_login_eva_desempenno 'varrieta|43211'

-- select*from dbo.A00_menus where substring(Menu_Id, 1, 2) = '07'
set rowcount 50

update t set Rol_Activo = 1
from dbo.A00_UsuariosRoles t where pos_id = 52 and
-- Menu_Id in ('0701')
Menu_Id in ('0701', '0702', '0703')


select*from dbo.A00_menus where Menu_Id between 700 and 800
select*from dbo.A00_UsuariosRoles where pos_id = 52 and Menu_Id between 700 and 800
