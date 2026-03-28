if exists(select 1 from sys.sysobjects where id= object_id('dbo.usp_loginConvocatoriaData','p'))
drop procedure dbo.usp_loginConvocatoriaData
go
create procedure dbo.usp_loginConvocatoriaData
@data int
as
begin
set nocount on

declare @campos varchar(max)='\
Pos_DocTipoId|1|3~Pos_DocNumero|1|4~Pos_ApPat|1|6~Pos_ApMat|1|7~Pos_Nombres|1|8~Pos_Id|1|1~\
Pos_Sexo|1|17~Pos_Email|1|21~Pos_Cel1|1|19~EstCiv_Id|1|20~Pos_DocEmision|1|5~Pos_NacFecha|1|18~GradIns_Id|1|25~\
Pos_EMER_Nombre|1|22~Pos_EMER_Parentesco|1|23~Pos_EMER_Numero|1|24~Pos_ExperienciaAnios|1|26~\
Pos_ExperienciaPuesto|1|27~Pos_aux1|1|9~Proy_id|1|11~Pues_id|1|12~\
Pos_GrupoSanguineo|1|109~Pos_Talla|1|110~Pos_PretencionSalarial|1|111~\
Pos_Id|2|40~Dir_Sec|2|14~Dir_DomViaNombre|2|13~Dir_DomUbigeoId|2|16~\
Pos_Id|5|112~Pos_Cta_Sec|5|113~Pos_CtaTipo|5|114~Pos_Cta_Numero|5|115~Pos_Cta_CCI|5|116~\
Pos_Comunidad_Id|1|10~Pos_AFP|1|31~\
Pos_Id|3|~PosEPP_Sec|3|~EPP_Id|3|~PosEPP_Talla|3|~\
USER_Usuario|4|~User_Id|4|~Pos_Id|4|'

create table #tmp001_campos(
    item int identity,
    name varchar(100) collate database_default,
    dataTabla int,
    dataItem int
)
select top 0
cast(null as int) tabla,
cast(null as int) column_id,
cast(null as varchar(100)) name,
cast(null as int) dataItem,
cast(null as int) len,
cast(null as int) item into #tmp001_tablas

select @campos = concat('select*from(values(''',
replace(replace(@campos, '~', '''),('''), '|', ''','''),  '''))t(a,b,c)')
insert into #tmp001_campos exec(@campos)

insert into #tmp001_tablas select tabla, column_id, name, dataItem, len, item
from(
select case when t.column_id is null then 0 else 1 end tabla,
isnull(t.column_id, 0) column_id, t.name, tt.dataItem,
case t.system_type_id when 167 then t.max_length end len, tt.item
from #tmp001_campos tt outer apply(select*from sys.columns t
where t.name = tt.name and t.object_id = object_id('dbo.RH10_Postulantes', 'U'))t
where tt.dataTabla = 1
union all
select 2, t.column_id, t.name, tt.dataItem, case t.system_type_id when 167 then t.max_length end, tt.item
from sys.columns t, #tmp001_campos tt
where t.name = tt.name and tt.dataTabla = 2 and t.object_id = object_id('dbo.RH10_PosDirecciones', 'U')
union all
select 3, t.column_id, t.name, tt.dataItem, case t.system_type_id when 167 then t.max_length end, tt.item
from sys.columns t, #tmp001_campos tt
where t.name = tt.name and tt.dataTabla = 3 and t.object_id = object_id('dbo.RH10_PosEPPs', 'U')
union all
select 4, t.column_id, t.name, tt.dataItem, case t.system_type_id when 167 then t.max_length end, tt.item
from sys.columns t, #tmp001_campos tt
where t.name = tt.name and tt.dataTabla = 4 and t.object_id = object_id('dbo.A00_Usuarios', 'U')
union all
select 5, t.column_id, t.name, tt.dataItem, case t.system_type_id when 167 then t.max_length end, tt.item
from sys.columns t, #tmp001_campos tt
where t.name = tt.name and tt.dataTabla = 5 and t.object_id = object_id('dbo.RH10_PosCuentas', 'U')
)t
order by item

if @data = 0
with tmp001_sep(t, r, p, i) as(
    select*from(values('¦', '|', '.', '~'))t(sepCamp,sepReg,sepPunto,sepRegIni)
)
insert into #tmp001_loginConvocatoriaData
select stuff((select r, tabla, p, column_id, t, dataItem, t, len
from #tmp001_tablas order by item
for xml path, type).value('.','varchar(max)'),1,1,i)
from tmp001_sep

else if @data = 1
insert into #tmp001_loginConvocatoriaData
select tabla, column_id, name
from #tmp001_tablas
order by item

end
go

-- select top 0
-- cast(null as varchar(max)) dato into #tmp001_loginConvocatoriaData
-- exec dbo.usp_loginConvocatoriaData 0

select top 0
cast(null as int) tabla,
cast(null as int) column_id,
cast(null as varchar(100)) name into #tmp001_loginConvocatoriaData
exec dbo.usp_loginConvocatoriaData 1

select*from #tmp001_loginConvocatoriaData

-- select top 5*from dbo.RH10_PosCuentas
-- select*from mastertable('dbo.RH10_PosCuentas')
