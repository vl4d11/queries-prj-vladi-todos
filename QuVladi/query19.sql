if exists(select 1 from sys.sysobjects where id = object_id('dbo.udf_usuariosAcopioMinero09','if'))
drop function dbo.udf_usuariosAcopioMinero09
go
create function dbo.udf_usuariosAcopioMinero09(
@usu1 int,
@usu2 int
)returns table as return(
    select (select '|', Concat(left(p.Pos_Nombres,1),'. ',p.Pos_ApPat)
    from(values(1, @usu1),(2, @usu2))d(item, usu)
    outer apply(select*from dbo.A00_Usuarios u where u.User_Id = d.usu)u
    outer apply(select*from dbo.RH10_Postulantes p where p.Pos_Id = u.Pos_Id)p
    order by d.item
    for xml path, type).value('.','varchar(max)') usuarios
)
go


if exists(select 1 from sys.sysobjects where id = object_id('dbo.usp_actualizaUsuarioSubeAcopioMinero03','p'))
drop procedure dbo.usp_actualizaUsuarioSubeAcopioMinero03
go
create procedure dbo.usp_actualizaUsuarioSubeAcopioMinero03
@data varchar(max)
as
begin
begin try
set nocount on
select top 0
cast(null as int) codigo,
cast(null as int) userid into #tmp001_param;
select @data = dato from dbo.udf_splice(@data, default, default)
insert into #tmp001_param
exec(@data)

update t set
t.SubioArchivo = 1, t.Sube_Id = p.userid, t.Sube_Fecha = getdate()
from dbo.AC10_Lotes_Docs t, #tmp001_param p
where t.Id_Doc = p.codigo

select replace(t.usuarios, '|', '') usuarios from #tmp001_param p
cross apply dbo.udf_usuariosAcopioMinero09(p.userid, 0)t

end try
begin catch
    select concat('error:', error_message())
end catch
end
go






-- update t set
-- t.SubioArchivo = 0, t.Sube_Id = null, t.Sube_Fecha = null
-- from dbo.AC10_Lotes_Docs t where t.Id_Doc = 665


-- select*
-- from dbo.AC10_Lotes_Docs d where d.Lote_Id = 226
-- order by Crea_Fecha
