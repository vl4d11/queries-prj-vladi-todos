use SCP_CORRELATIVO
set rowcount 20

-- select cod_usuario, cod_destino from dbo.msg_usuario

-- select cod_destino, num_idperfil from dbo.scp_destino
-- select distinct num_idperfil from dbo.scp_destino order by 1

-- select*from dbo.mco_perfil
-- select*from dbo.mco_estado

-- exec sp_rename 'dbo.mco_supervisado.cod_destino', 'cod_responsable', 'COLUMN';





-- return
-- select*from mastertable('dbo.msg_usuario')
-- select*from mastertable('dbo.scp_destino')
-- select*from mastertable('dbo.mco_perfil')
-- select*from mastertable('dbo.mco_estado')
-- select*from mastertable('dbo.mco_supervisado')




-- return

-- update t set t.num_idperfil = 0 from dbo.scp_destino t
-- where t.cod_destino = '42441293'

return
set rowcount 20

select cod_destino, cod_usuario from dbo.msg_usuario -- NO SE SI VA
select cod_destino, num_idperfil from dbo.scp_destino
select num_idperfil, txt_descripcion from dbo.mco_perfil
select num_idperfil, num_idestado, txt_accion from dbo.mco_estado

--NOTA: RELACION DE USUARIOS CON SUS SUPERVISORES
-- select cod_destino, cod_responsable from dbo.mco_supervisado
