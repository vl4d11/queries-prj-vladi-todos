if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_insertDocPostula','p'))
drop procedure dbo.usp_insertDocPostula
go
create procedure dbo.usp_insertDocPostula
@data varchar(max)
as
begin
set nocount on
set language english

declare @codigo varchar(max)
create table #tmp001_param(
    item int identity,
    data varchar(100) collate database_default,
    doc_item int
)
select @data =
concat('select*from(values(''', replace(@data, '|','''),('''), '''))t(a)')
insert into #tmp001_param(data) exec(@data)

;with tmp001_param as(select item, doc_id2 =
    reverse(stuff(reverse(data),1,charindex('.',reverse(data)), ''))
    from #tmp001_param where item > 2
)
,tmp001_dato as(
    select m.Doc_Id, p.item
    from dbo.m_DocsVarios m, #tmp001_param t, tmp001_param p
    where m.Doc_Disponible = 1 and m.Doc_Responsable = 'U' and t.item = 2
    and concat(t.data,'-', m.Doc_Cod) = p.doc_id2
)
update t set t.doc_item = tt.Doc_Id
from #tmp001_param t, tmp001_dato tt
where t.item = tt.item

select @data = concat(stuff((
select case idx when 1 then ''',''' else ''',''1\' end, data from #tmp001_param,
(values(1),(2))t(idx) where item = idx
for xml path, type).value('.','varchar(max)'),1,2,''),'\')

select @codigo = concat(
'insert into  dbo.RH10_PosDocsAfiliacion(Con_Id,Doc_Id,Pos_Id,Doc_Archivo,\
CreaFecha,Doc_Check,CreaId)select*from(',
stuff((select
''' union all select ', tt.item, ',', doc_item, ',',  @data, data, ''',''',
convert(varchar,getdate(),23), ''',''', 1, ''',''', 99
from(select doc_item, data, row_number()over(order by (select 1)) ide
from #tmp001_param where item > 2)t cross apply dbo.udf_PosEPPs(t.ide)tt
for xml path, type).value('.','varchar(max)'),1,11,''),
''')t(Con_Id,Doc_Id,Pos_Id,Doc_Archivo,CreaFecha,Doc_Check,CreaId)\
where not exists(select 1 from dbo.RH10_PosDocsAfiliacion tt \
where tt.Pos_Id = t.Pos_Id and tt.Doc_Id = t.Doc_Id)')
exec(@codigo)

end
go


declare @data varchar(max) =
'52|09957375|09957375-RR-HH-005.jpeg|09957375-RR-HH-016.docx|09957375-RR-HH-018.sql'
-- exec dbo.usp_insertDocPostula @data

-- delete t from dbo.RH10_PosDocsAfiliacion t WHERE POS_ID = 52

select*from dbo.RH10_PosDocsAfiliacion tt WHERE POS_ID = 52

return
-- UPDATE tt set
--tt.Doc_Archivo = '1\45763714\45763714-RR-HH-011.pdf'

select*from mastertable('dbo.RH10_PosDocsAfiliacion')


return
select*from dev.RH10_PosCuentas where pos_id = 52
select*from dbo.RH10_Postulantes where pos_id = 52
select*from dev.RH10_Postulantes where pos_id = 52












-- if exists(select 1 from sys.objects where object_id=object_id('dbo.udf_corrEpp', 'if'))
-- drop function dbo.udf_corrEpp
-- go
-- create function dbo.udf_corrEpp(
-- @item int
-- )returns table as return(
-- select datediff_big(millisecond,'19700101',dateadd(hour,(-5),getutcdate())) + @item [22_22]
-- )
-- go


-- select *
-- from(select top 10 row_number()over(order by(select 1)) item
-- from sys.fn_helpcollations())t cross apply dbo.udf_corrEpp(item)


-- select *, isnull(nullif(PosEPP_Sec, 0), tt.[22_22]) PosEPP_Sec
-- from(select row_number()over(order by (select 1)) [11_11],
-- Pos_Id, PosEPP_Sec, EPP_Id, PosEPP_Talla
-- from dbo.prueba99)t cross apply dbo.udf_corrEpp([11_11])tt




-- select*from sys.schemas
--  (datediff_big(millisecond,'19700101',dateadd(hour,(-5),getutcdate())))

-- -- NOTA: DDL - RH10_Postulantes
-- -- ============================
-- alter table dev.RH10_Postulantes
-- add constraint pk_dev_RH10_Postulantes primary key (Pos_Id);

-- -- NOTA: DDL - RH10_PosDirecciones
-- -- ============================
-- alter table dev.RH10_PosDirecciones
-- add constraint pk_dev_RH10_PosDirecciones primary key (Pos_Id, Dir_Sec);

-- alter table dev.RH10_PosDirecciones
-- add constraint def_dev_RH10_PosDirecciones default ((datediff_big(millisecond,'19700101',dateadd(hour,(-5),getutcdate()))))
-- for Dir_Sec;

-- -- NOTA: DDL - RH10_PosEPPs
-- -- ============================
-- alter table dev.RH10_PosEPPs
-- add constraint pk_dev_RH10_PosEPPs primary key (Pos_Id, PosEPP_Sec);

-- alter table dev.RH10_PosEPPs
-- add constraint def_dev_RH10_PosEPPs default ((datediff_big(millisecond,'19700101',dateadd(hour,(-5),getutcdate()))))
-- for PosEPP_Sec;

-- -- NOTA: DDL - A00_Usuarios
-- -- ============================
-- alter table dev.A00_Usuarios
-- add constraint pk_dev_A00_Usuarios primary key (User_Id);

-- alter table dev.A00_Usuarios
-- add constraint def_dev_A00_Usuarios default (dbo.udf_dev_pkusuario())
-- for User_Id;



-- set identity_insert dev.RH10_Postulantes on
-- disable trigger tr_Dev_Usuarios_GeneraClave on dev.A00_Usuarios;


-- enable trigger tr_Dev_Usuarios_GeneraClave on dev.A00_Usuarios;
-- set identity_insert dev.RH10_Postulantes off



-- truncate table dev.RH10_Postulantes
-- truncate table dev.RH10_PosDirecciones
-- truncate table dev.RH10_PosEPPs
-- truncate table dev.A00_Usuarios

-- select*from mastertable('dev.RH10_Postulantes')
-- select*from mastertable('dbo.RH10_Postulantes')

-- select*from mastertable('dev.RH10_PosDirecciones')
-- select*from mastertable('dbo.RH10_PosDirecciones')

-- select*from mastertable('dev.RH10_PosEPPs')
-- select*from mastertable('dbo.RH10_PosEPPs')



-- select*from mastertable('dev.RH10_PosCuentas')
-- select*from mastertable('dbo.RH10_PosCuentas')

-- select*from mastertable('dev.A00_Usuarios')

return

-- select text from sys.syscomments where id=object_id('dbo.udf_dev_pkusuario','fn')


-- select definition from sys.default_constraints
-- where parent_object_id = object_id('dbo.RH10_PosEPPs', 'U')
-- return

select*from sys.default_constraints;

return
-- CreaId,CreaFecha,ModiId,ModiFecha


-- select definition from sys.default_constraints where parent_object_id = object_id('dev.A00_Usuarios')
-- select text from sys.syscomments where id=object_id('udf_dev_pkusuario')


-- select isnull(max(User_Id), 0) +1 codUsu from dev.A00_Usuarios
-- select*from dev.A00_Usuarios where User_Id = 0


-- select*from sys.triggers where parent_id=object_id('dev.A00_Usuarios')
-- select text from sys.syscomments where id=object_id('dev.tr_Dev_Usuarios_GeneraClave', 'tr')


-- select*into dev.RH10_Postulantes from dbo.RH10_Postulantes
-- select*into dev.RH10_PosDirecciones from dbo.RH10_PosDirecciones
-- select*into dev.RH10_PosEPPs from dbo.RH10_PosEPPs
-- select*into dev.A00_Usuarios from dbo.A00_Usuarios


-- drop table dev.RH10_Postulantes
-- drop table dev.RH10_PosDirecciones
-- drop table dev.RH10_PosEPPs
-- drop table dev.A00_Usuarios


-- select definition from sys.default_constraints
-- where parent_object_id = object_id('dbo.RH10_PosDirecciones','U')
return


-- select*from dbo.udf_getpk('dbo.RH10_Postulantes')
-- select*from dbo.udf_getpk('dbo.RH10_PosDirecciones')
-- select*from dbo.udf_getpk('dbo.RH10_PosEPPs')
-- select*from dbo.udf_getpk('dbo.A00_Usuarios')

select*from dbo.udf_lisTablas(default) -- cross apply dbo.udf_getpk(tabla)
return






-- alter table dbo.RH10_Postulantes add constraint def_001_dbo_RH10_Postulantes
-- default (getdate()) for CreaFecha;
-- alter table dbo.RH10_Postulantes add constraint def_002_dbo_RH10_Postulantes
-- default (getdate()) for ModiFecha;
-- alter table dbo.RH10_Postulantes add constraint def_003_dbo_RH10_Postulantes
-- default (99) for CreaId;
-- alter table dbo.RH10_Postulantes add constraint def_004_dbo_RH10_Postulantes
-- default (99) for ModiId;


-- alter table dbo.RH10_PosDirecciones add constraint def_001_dbo_RH10_PosDirecciones
-- default (getdate()) for CreaFecha;
-- alter table dbo.RH10_PosDirecciones add constraint def_002_dbo_RH10_PosDirecciones
-- default (getdate()) for ModiFecha;
-- alter table dbo.RH10_PosDirecciones add constraint def_003_dbo_RH10_PosDirecciones
-- default (99) for CreaId;
-- alter table dbo.RH10_PosDirecciones add constraint def_004_dbo_RH10_PosDirecciones
-- default (99) for ModiId;


-- alter table dbo.RH10_PosEPPs add constraint def_001_dbo_RH10_PosEPPs
-- default (getdate()) for CreaFecha;
-- alter table dbo.RH10_PosEPPs add constraint def_002_dbo_RH10_PosEPPs
-- default (getdate()) for ModiFecha;
-- alter table dbo.RH10_PosEPPs add constraint def_003_dbo_RH10_PosEPPs
-- default (99) for CreaId;
-- alter table dbo.RH10_PosEPPs add constraint def_004_dbo_RH10_PosEPPs
-- default (99) for ModiId;


-- alter table dbo.A00_Usuarios add constraint def_001_dbo_A00_Usuarios
-- default (getdate()) for CreaFecha;
-- alter table dbo.A00_Usuarios add constraint def_002_dbo_A00_Usuarios
-- default (getdate()) for ModiFecha;
-- alter table dbo.A00_Usuarios add constraint def_003_dbo_A00_Usuarios
-- default (99) for CreaId;
-- alter table dbo.A00_Usuarios add constraint def_004_dbo_A00_Usuarios
-- default (99) for ModiId;
