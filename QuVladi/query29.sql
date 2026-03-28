if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_mantenimiento_competencias_simple','p'))
drop procedure dbo.usp_mantenimiento_competencias_simple
go
create procedure dbo.usp_mantenimiento_competencias_simple
@data varchar(max)
as
begin
set nocount on
set language english
create table #tmp001_out(accion varchar(6), item int)

exec dbo.usp_mantenimiento_generico_simple
@data,
1,
'cross apply dbo.udf_competencia_pk_001()nn',
'n.Dic_Id,',
'isnull(n.Dic_Id, nn.Dic_Id) Dic_Id,'

if exists(select 1 from #tmp001_out where accion = 'INSERT')begin
    declare @Dic_Tipo varchar(2), @Dic_Cod varchar(10)

    select @Dic_Tipo = t.Dic_Tipo from dbo.m_Diccionarios t, #tmp001_out tt
    where t.Dic_Id = tt.item

    select @Dic_Cod = concat(@Dic_Tipo,
    max(cast(stuff(Dic_Cod,1,2,'') as int))over(partition by substring(Dic_Cod,1,2))+1)
    from dbo.m_Diccionarios where Dic_Tipo = @Dic_Tipo

    update t set t.Dic_Cod = @Dic_Cod
    from dbo.m_diccionarios t, #tmp001_out tt where t.Dic_Id = tt.item
end
select item from #tmp001_out

end
go

-- exec dbo.usp_mantenimiento_competencias_simple
-- '4|3.1|3.4|3.5|3.6|3.7|3.8||MARIA MAGDALENA|esto es nua prueba|CO|CA|1'

-- truncate table dbo.m_diccionarios
-- insert into dbo.m_diccionarios
-- select*from dbo.m_diccionarios_back


-- delete t from dbo.m_diccionarios t where t.Dic_Id > 30
select*from dbo.m_diccionarios
-- where Dic_Id_Padre = 13

-- select*from dbo.A00_menus
-- return



return


-- select*from dbo.m_diccionarios_back

exec dbo.usp_listar_tablas 'dbo.m_Diccionarios'

select*from dbo.mastertablas
select*from dbo.masterAudit
select*from dbo.m_Nivel_Posicion
select*from dbo.m_Escala_Likert
select top 100*from dbo.RH00_OrganigramaPuestos where not grado is null
