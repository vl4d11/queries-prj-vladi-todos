if exists(select 1 from sys.sysobjects where id = object_id('dbo.usp_loginConvocatoria','p'))
drop procedure dbo.usp_loginConvocatoria
go
create procedure dbo.usp_loginConvocatoria
@data varchar(max)
as
begin
set nocount on

select top 0
cast(null as varchar(100)) USER_Usuario,
cast(null as varchar(100)) clave into #tmp001_usuario
select top 0
cast(null as varchar(max)) dato into #tmp001_loginConvocatoriaData
select @data =
concat('select*from(values(''', replace(@data, '|', ''','''), '''))t(a,b)')
insert into #tmp001_usuario exec(@data)
exec dbo.usp_loginConvocatoriaData 0

;with tmp001_sep(t, r, l, g, i, s) as(
    select*from(values('|','~','^', '¬','¦','¯'))t(sepCamp,sepReg,sepList,sepGrupo,sepSubCamp,sepSubReg)
)
,tmp001_datos as(
    select USER_Usuario,
    case when not try_cast(USER_Usuario as int) is null then USER_Usuario end nro,
    len(USER_Usuario) long,
    convert(varchar(128), hashbytes('sha2_512', clave), 2) USER_Clave256
    from #tmp001_usuario
)
,tmp001_login as(
    select t.pos_id, esNumero =
    case when ltrim(rtrim(tt.USER_Usuario)) = ltrim(rtrim(tt.nro)) and tt.long = 8 then tt.USER_Usuario end
    from tmp001_datos tt outer apply
    (select*from dbo.A00_Usuarios t where t.USER_Usuario = tt.USER_Usuario and
    t.USER_Clave256 = tt.USER_Clave256)t
)
,tmp001_result as(
    select numero = coalesce(convert(varchar,tt.pos_id),
    case tt.esNumero when t.Pos_DocNumero then 'existe' else tt.esNumero end, 'error'),
    isnull(tt.pos_id, 0) post
    from tmp001_login tt outer apply(
    select*from dbo.RH10_Postulantes t where t.Pos_DocNumero = tt.esNumero)t
)
,help001_tipDoc(dato)as(
    select concat(l, 3,(select r, DocId_Id, t, DocId_Nombre
    from dbo.m_DocsIdentidad,(values(1),(4))t(tt) where DocId_Id = t.tt order by 1
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_uorg(dato)as(
    select concat(l, 9,(select r,
    UO_Id, t, concat(rtrim(UO_Nombre), ' (', rtrim(UO_Descripcion), ')')
    from dbo.A10_UOs where UO_Estado = 1 order by UO_Nombre
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_comunidad(dato)as(
    select concat(l, 0, t, 50,(select r,
    Comu_Id, t, Comu_Nombre, t, UM_Id
    from dbo.m_Comunidades order by UM_Id, Comu_Nombre
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_proyecto(dato)as(
    select concat(l, 0, t, 51,(select r, Proy_Id, t, Proy_Nombre, t, UO_Id
    from dbo.A10_Proyectos where Proy_Disponible = 1 order by UO_Id, Proy_Nombre
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_puesto(dato)as(
    select concat(l, 0, t, 52,(select r, t.Pues_Id, t, t.Pues_Nombre, t, tt.Proy_Id
    from(select distinct t.Proy_Id, tt.Pues_Id
    from dbo.RH00_OrganigramaCab t, dbo.RH00_OrganigramaPuestos tt
    where t.Org_Id = tt.Org_Id)tt, dbo.m_Puestos t
    where tt.Pues_Id = t.Pues_Id and t.Pues_Activo = 1
    order by tt.Proy_Id, t.Pues_Nombre
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_estadoCivil(dato)as(
    select concat(l, 20,(select r, EstCiv_Id, t, EstCiv_Nombre
    from dbo.m_EstadosCiviles order by EstCiv_Nombre
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_parentesco(dato)as(
    select concat(l, 23,(select r, Paren_Id, t, Paren_Nombre
    from dbo.m_Parentescos order by Paren_Nombre
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_gradoInstruccion(dato)as(
    select concat(l, 25,(select r, GradIns_Id, t, GradIns_Descripcion
    from dbo.m_GradosInstruccion where GradIns_Activo = 1
    order by GradIns_Descripcion
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_ctaBanco(dato)as(
    select concat(l, 28,(select r, PosCtaTipo_Id, t, PosCtaTipo_Nombre
    from dbo.m_CtaTipos order by PosCtaTipo_Nombre
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_afp(dato)as(
    select concat(l, 31,(select r, AFP_Id, t, AFP_Nombre
    from dbo.m_AFPs order by AFP_Nombre
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_epp(dato)as(
    select concat(l, 0, t, 200,(select r, EPP_Id, t, EPP_Nombre
    from dbo.m_EPPs where EPP_Disponible = 1 order by EPP_Id
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_files(dato)as(
    select concat(l, 0, t, 300,(select r, Doc_Id, t, Doc_Descripcion, t, Doc_Cod
    from dbo.m_DocsVarios where Doc_Disponible = 1 and Doc_Responsable = 'U'
    order by Doc_Descripcion
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_grupoSangre(dato)as(
    select concat(l, 0, t, 301, stuff((select t,
    gSan from dbo.udf_gSanguineo() order by item
    for xml path, type).value('.', 'varchar(max)'), 1, 1, r))
    from tmp001_sep
)
,help001_ubigeo(dato)as(
    select concat(l, 0, t, 201202203,(select r,
    UBIGEO_Codigo, t, stuff(UBIGEO_RENIEC,1,1,''), t, DPTO_NOM, t, PROV_NOM, t, DITRI_NOM
    from dbo.m_Ubigeos where UBIGEO_RENIEC != 'R000000' order by UBIGEO_RENIEC
    for xml path, type).value('.', 'varchar(max)'))
    from tmp001_sep
)
,help001_listaAyudas(g, dato)as(
    select g, concat(
        m.dato, t1.dato, t2.dato, t3.dato, t4.dato, t5.dato, t6.dato,
        t7.dato, t8.dato, t9.dato, t10.dato, t11.dato, t12.dato, t13.dato, t14.dato
    )
    from help001_tipDoc t1,
    help001_uorg t2,
    help001_comunidad t3,
    help001_proyecto t4,
    help001_puesto t5,
    help001_estadoCivil t6,
    help001_parentesco t7,
    help001_gradoInstruccion t8,
    help001_ctaBanco t9,
    help001_afp t10,
    help001_epp t11,
    help001_ubigeo t12,
    help001_files t13,
    help001_grupoSangre t14,
    #tmp001_loginConvocatoriaData m,
    tmp001_sep
)
,tmp001_epp(Pos_Id, dato)as(
    select tt.numero, stuff((select s, ttt.Pos_Id, i, ttt.PosEPP_Sec, i, ttt.EPP_Id, i, ttt.PosEPP_Talla
    from tmp001_result t
    outer apply(select*from dbo.RH10_PosEPPs ttt where ttt.pos_id = t.numero)ttt
    where t.post > 0 and t.numero = tt.numero
    for xml path, type).value('.', 'varchar(max)'),1,1,'')
    from tmp001_sep, tmp001_result tt where tt.post > 0
)
,tmp001_postulante(bloqueo, dato)as(
    select concat(jj.bloqueo, l), concat(
    t.Pos_DocTipoId, t, t.Pos_DocNumero, t, t.Pos_ApPat, t, t.Pos_ApMat, t, t.Pos_Nombres, t,
    t.Pos_Id, t, t.Pos_Sexo, t, t.Pos_Email, t, t.Pos_Cel1, t, t.EstCiv_Id, t,
    convert(varchar, nullif(t.Pos_DocEmision, cast('' as date)), 121), t,
    convert(varchar, nullif(t.Pos_NacFecha, cast('' as date)), 121), t,
    t.GradIns_Id, t, t.Pos_EMER_Nombre, t, t.Pos_EMER_Parentesco, t,
    t.Pos_EMER_Numero, t, t.Pos_ExperienciaAnios, t, t.Pos_ExperienciaPuesto, t,
    j.UO_Id, t, t.Proy_Id, t, t.Pues_Id, t,
    t.Pos_GrupoSanguineo, t, t.Pos_Talla, t, t.Pos_PretencionSalarial, t,
    tt.Pos_Id, t, tt.Dir_Sec, t, tt.Dir_DomViaNombre, t, tt.Dir_DomUbigeoId, t,
    t5.Pos_Id, t, t5.Pos_Cta_Sec, t, t5.Pos_CtaTipo, t, t5.Pos_Cta_Numero, t,
    t5.Pos_Cta_CCI, t, t.Pos_Comunidad_Id, t, t.Pos_AFP, t, ttt.dato)
    from dbo.RH10_Postulantes t cross apply tmp001_result p cross apply tmp001_sep
    outer apply(select top 1 *from dbo.RH10_PosDirecciones tt where tt.Pos_Id = t.Pos_Id order by CreaFecha desc)tt
    outer apply(select*from dbo.RH10_PosCuentas t5 where t5.Pos_Id = t.Pos_Id)t5
    outer apply(select*from tmp001_epp ttt where ttt.Pos_Id = t.Pos_Id)ttt
    outer apply(select*from dbo.A10_Proyectos j where j.Proy_Id = t.Proy_Id)j
    outer apply(select*from dbo.udf_enProceso()jj where jj.Proceso_Id = t.PosEst_Proceso)jj
    where t.Pos_Id = p.numero
)
select
case when try_cast(t.numero as int) is null then t.numero else concat(t.numero, g, tt.dato) end
from tmp001_result t outer apply help001_listaAyudas tt
where post = 0
union all
select concat(g, tt.bloqueo, tt.dato, ttt.dato)
from tmp001_result t outer apply tmp001_postulante tt outer apply help001_listaAyudas ttt
where post != 0

end
go

exec dbo.usp_loginConvocatoria '42925465|42925465'
return
-- return
set nocount off
declare @nroDni varchar(10) = '09957375'

select*from dbo.RH10_Postulantes where Pos_DocNumero = @nroDni

select t.*from dbo.RH10_PosDirecciones t, dbo.RH10_Postulantes tt
where t.pos_id = tt.pos_id and tt.Pos_DocNumero = @nroDni

select t.*from dbo.RH10_PosEPPs t, dbo.RH10_Postulantes tt
where t.pos_id = tt.pos_id and tt.Pos_DocNumero = @nroDni

select t.*from dbo.RH10_PosCuentas t, dbo.RH10_Postulantes tt
where t.pos_id = tt.pos_id and tt.Pos_DocNumero = @nroDni

select t.*from dbo.A00_Usuarios t, dbo.RH10_Postulantes tt
where t.pos_id = tt.pos_id and tt.Pos_DocNumero = @nroDni


-- delete t from dbo.RH10_PosCuentas t, dbo.RH10_Postulantes tt
-- where t.pos_id = tt.pos_id and tt.Pos_DocNumero = @nroDni

-- delete t from dbo.RH10_PosDirecciones t, dbo.RH10_Postulantes tt
-- where t.pos_id = tt.pos_id and tt.Pos_DocNumero = @nroDni

-- delete t from dbo.RH10_PosEPPs t, dbo.RH10_Postulantes tt
-- where t.pos_id = tt.pos_id and tt.Pos_DocNumero = @nroDni

-- delete t from dbo.A00_Usuarios t, dbo.RH10_Postulantes tt
-- where t.pos_id = tt.pos_id and tt.Pos_DocNumero = @nroDni

-- delete dbo.RH10_Postulantes where Pos_DocNumero = @nroDni


return
update t set PosEst_Proceso = 1 from dbo.RH10_Postulantes t where Pos_Id = 52
-- PosEst_Proceso = 4

select Pos_DocNumero, Pos_Nombres, PosEst_Proceso, Proy_Id, Pues_Id
from dbo.RH10_Postulantes where Pos_Id = 52

return
exec dbo.usp_loginConvocatoria
-- '42925465|42925465'
--  '43965777|43965777'
--  '43965|43965777'
--  '41183237|43965777'
--  'maria|43965777'
--  '02873029|fsdfsdf'
--  '43965777|43965777'
--  '47321624|47321624'

--  '08502931|08502931'
'Varrieta|4321'
-- '09957375|4321'
