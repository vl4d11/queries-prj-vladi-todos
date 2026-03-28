if exists(select 1 from sys.sysobjects where id = object_id('dbo.usp_loginVerAcopioMinero','p'))
drop procedure dbo.usp_loginVerAcopioMinero
go
create procedure dbo.usp_loginVerAcopioMinero
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
    select t.User_Id, t.pos_id, case t.User_VerAcopio when 1 then convert(varchar(max), 'A') end User_VerAcopio
    from tmp001_datos tt, dbo.A00_Usuarios t
    where tt.USER_Usuario = t.USER_Usuario and tt.USER_Clave256 = t.USER_Clave256
)
,tmp001_validado as(
    select t.*, tt.minero_idDato from tmp001_login t
    outer apply(select stuff((select t, tt.minero_id
        from dbo.AC00_Usuario_Mineros tt where tt.Usuario_Id = t.User_Id
        for xml path, type).value('.','varchar(max)'),1,1,'') minero_idDato
        from tmp001_sep
    )tt
)
,tmp001_loteXidNro(dato) as(
    select (select top 20 r, t.lote_id, t, t.lote_nro
    from tmp001_validado u cross apply udf_split(minero_idDato, default)tt
    cross apply dbo.AC10_Lotes t where t.minero_id = tt.value and u.User_VerAcopio is null
    order by t.Fecha_Ingreso desc
    for xml path, type).value('.','varchar(max)')
    from tmp001_sep
)
,tmp001_loteSalida as(
    select tt.User_Id, tt.pos_id, tt.User_VerAcopio, concat(tt.minero_idDato, t.dato) minero_idDato
    from tmp001_loteXidNro t, tmp001_validado tt
)
select coalesce((
    select concat(User_Id, '~', isnull(User_VerAcopio, minero_idDato)) dato
    from tmp001_loteSalida), 'N')

end try
begin catch
    select concat('error:', error_message())
end catch
end
go


exec dbo.usp_loginVerAcopioMinero
-- 'varrieta|4321'
'43902900|43902900'
-- '45239593|45239593'
-- '23232|rer'

-- select*from dbo.AC10_Lotes


return
set rowcount 10
select*from dbo.A00_Usuarios
select*from dbo.AC00_Usuario_Mineros
select*from dbo.AC10_Lotes
select*from dbo.AC10_Lotes_Docs
