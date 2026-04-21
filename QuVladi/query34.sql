if exists(select 1 from sys.sysobjects
where id=object_id('dbo.usp_listar_encuestas_comportamientos','p'))
drop procedure dbo.usp_listar_encuestas_comportamientos
go
create procedure dbo.usp_listar_encuestas_comportamientos
@data varchar(100),
@pivot int = null
as
begin
begin try
set nocount on
set tran isolation level read uncommitted
set language english

select top 0
cast(null as int) pos_id into #tmp001_param
select top 0
cast(null as varchar(max)) collate database_default meta into #tmp001_meta
insert into #tmp001_param select @data

;with tmp001_trabajador as(
    select top 1 with ties
        t.Trab_Proys, t.Trab_Sec, t.Pues_Org_Id, tt.Proy_Nombre
    from #tmp001_param pp, dbo.rh30_trabajadores t, dbo.a10_proyectos tt
    where t.pos_id = pp.pos_id
    and t.Trab_Proys = tt.proy_id and tt.Proy_Activo = 1
    order by row_number()over(partition by t.pos_id order by t.Crea_Fecha desc)
)
,tmp001_trabajador_organigrama as(
    select tr.*, tt.grado
    from tmp001_trabajador tr,
    dbo.rh00_organigramaCab t, dbo.RH00_OrganigramaPuestos tt
    where t.Org_Id = tt.Org_Id
    and tr.Trab_Proys = t.Proy_Id and tr.Pues_Org_Id = tt.Pues_Id
)
select top 1 t.*,
    f.FormEvDes_EscalaComp escala, f.FormEvDes_Nombre nombreForm
into #tmp001_recopilando_preguntas
from(select t.*, tt.Id_EvaluadoCab, tt.FormEDL_Id, tt.Evaluador_Id,
    case t.Trab_Sec when tt.Evaluador_Id then 1 else 0 end evaluador
    from tmp001_trabajador_organigrama t
    cross apply dbo.rh50_DesigEvaluados_cab tt
    cross apply(
        select FormEvDes_Id, rtrim(FormEvDes_Nombre) nombreForm
        from dbo.rh50_evDesForms
        where FormEvDes_Activo = 1 and cast(getdate() as date)
            between FormEvDes_Inicio
            and dateadd(week, FormEvDes_Duracion, FormEvDes_Inicio)
    )ttt
    where t.Trab_Proys = tt.Proy_Id and t.Pues_Org_Id = tt.PuestoOrg_Id
    and tt.FormEDL_Id = ttt.FormEvDes_Id
)t
cross apply dbo.rh50_evDesForms f
where t.FormEDL_Id = f.FormEvDes_Id and f.FormEvDes_Activo = 1
and exists(select 1 from dbo.rh50_DesigEvaluados_det tt
    where t.Id_EvaluadoCab = tt.Id_EvaluadoCab
        and t.Trab_Proys = tt.Proy_Id
        and t.Trab_Sec = tt.Trab_Sec
        and t.Pues_Org_Id = tt.PuestoOrg_Id)


if not exists(select 1 from #tmp001_recopilando_preguntas)begin
    if @pivot is not null begin
        insert into #tmp001_pivote select '0'
        return
    end
    select '0'
    return
end
if @pivot is not null begin
    insert into #tmp001_pivote select '1'
    return
end

-- update t set escala = 0 from #tmp001_recopilando_preguntas t


select
    t.FormEDL_Id,
    t.Evaluador_Id,
    tt.Trab_Sec,
    t.Pues_Org_Id,
    pd.nombre,
    ttt.Etiqueta,
    py.Proy_Nombre,
    isnull(ex.dioExamen, 0) dioExamen
into #tmp001_tipoEval_cab
from(
    select t.FormEDL_Id, t.Evaluador_Id, t.Pues_Org_Id, tt.Id_EvaluadoCab,
        t.evaluador, t.Trab_Sec evaluado
    from #tmp001_recopilando_preguntas t
    cross apply dbo.rh50_DesigEvaluados_cab tt
    where t.escala = 1
    and t.FormEDL_Id = tt.FormEDL_Id
    and t.Trab_Proys = tt.Proy_Id
    and t.Pues_Org_Id = tt.PuestoOrg_Id
    and t.Evaluador_Id = tt.Evaluador_Id
)t
cross apply dbo.rh50_DesigEvaluados_det tt
cross apply dbo.rh50_tipoEvaluacion ttt
cross apply dbo.RH30_Trabajadores tr
cross apply dbo.RH10_Postulantes p
cross apply (
    select concat(
        rtrim(p.pos_ApPat), ' ',
        rtrim(p.pos_ApMat), ' ',
        rtrim(p.pos_Nombres)) nombre)pd
outer apply(
    select*from dbo.a10_proyectos py where py.proy_id = tt.Proy_Id
)py
outer apply (
    select top 1 1 dioExamen
    from dbo.rh50_evDes e
    where e.FormEv_Id = t.FormEDL_Id
    and e.Trab_Sec = tt.Trab_Sec
    and e.PuesOrg_Id = t.Pues_Org_Id
)ex
where t.Id_EvaluadoCab = tt.Id_EvaluadoCab
    and tt.Id_TipoEv = ttt.Id_TipoEv
    and tt.Proy_Id = tr.Trab_Proys
    and tt.Trab_Sec = tr.Trab_Sec
    and tr.pos_id = p.pos_id
    and (t.evaluador = 1 or t.evaluado = tt.Trab_Sec)
order by tt.Id_TipoEv


;with tmp001_sep(t,r,i,a,c1,c2)as(
    select*from(
    values('|','~','^','*',' (', ')'))t(Sepcamp,SepReg,SepList,SepAux,Sep1,Sep2)
)
select concat(i, 9,(select r,
    t.FormEDL_Id, a,
    t.Evaluador_Id, a,
    t.Trab_Sec, a,
    t.Pues_Org_Id, t,
    t.nombre, c1,
    t.Etiqueta, c2, t,
    t.Proy_Nombre, t,
    t.dioExamen
from #tmp001_tipoEval_cab t
order by t.nombre
for xml path, type).value('.','varchar(max)')) dato into #tmp001_tipoEval
from tmp001_sep


;with tmp001_sep(t,r,i)as(
    select*from(
    values('|','~','^'))t(Sepcamp,SepReg,SepList)
)
,tmp001_rindio_encuesta as(
    select tt.Trab_Sec, tt.Dic_id, tt.Respuesta
    from #tmp001_tipoEval_cab t
    cross apply dbo.rh50_evDes tt
    where t.FormEDL_Id = tt.FormEv_Id
        and t.Evaluador_Id = tt.Evaluador_Id
        and t.Trab_Sec = tt.Trab_Sec
        and t.Pues_Org_Id = tt.PuesOrg_Id
    order by tt.Trab_Sec offset 0 rows
)
select (select i, Trab_Sec, dato
from(
    select distinct tt.Trab_Sec, (select r, t.Dic_id, t, t.Respuesta
    from tmp001_rindio_encuesta t
    where t.Trab_Sec = tt.Trab_Sec
    for xml path, type).value('.','varchar(max)') dato
    from tmp001_rindio_encuesta tt
)t
for xml path, type).value('.','varchar(max)') dato
into #tmp001_rindieron_evaluacion
from tmp001_sep


declare @dato varchar(max) = '\
t|EvDes_Id||||0|1*1.1**~
t|FormEv_Id||||0|2*1.2**~
t|Evaluador_Id||||0|3*1.3**~
t|Trab_Sec||||0|4*1.4**~
t|PuesOrg_Id||||0|5*1.5**~
t|Dic_Id||||0|6*1.6**~
t|Respuesta||||0|7*1.7**~
t|Comentarios||||0|8*1.8**~
|||||4|9*3.1*Seleccione Tipo Evaluacion*4***1'

exec dbo.usp_listar_metadata @dato output, 't|dbo.rh50_evDes'
insert into #tmp001_meta select @dato

;with tmp001_sep(t,r,i,s,c)as(
    select*from(
    values('|','~','^',' ',',  '))t(Sepcamp,SepReg,SepList,SepAux,Sepcoma)
)
,tmp001_liker as(
    select t.Escala_Cabecera, t.Escala_Valores
    from dbo.m_escalas t, #tmp001_recopilando_preguntas tt
    where t.Escala_Id = tt.escala
)
,tmp002_liker as(
    select t.value, row_number()over(order by (select 1)) item
    from tmp001_liker cross apply dbo.udf_split(Escala_Cabecera, default)t
)
,tmp003_liker as(
    select t.value, row_number()over(order by (select 1)) item
    from tmp001_liker cross apply dbo.udf_split(Escala_Valores, default)t
)
,tmp004_liker(dato) as(
    select concat(i, 35, (select r, t.value, t, tt.value
    from tmp002_liker t, tmp003_liker tt
    where t.item = tt.item order by t.item
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,hlp001_cards(dato)as(
    select concat(i, 22, (select r, item, t, title, t, ancho from(
    values(3, concat(upper(tt.nombreForm), ' :'), 80)
    )t(item, title, ancho)
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep, #tmp001_recopilando_preguntas tt
)
,cap001_comportamientos(cab)as(
    select concat(r,
    '1|Descripcion Comportamiento', r,
    '0|800')
    from tmp001_sep
)
,tmp001_matriz_pesos as(
    select id_nivel grado, value peso
    from dbo.m_Nivel_Posicion cross apply dbo.udf_split(grados_nivel, ',')
)
,tmp001_matriz_cabecera as(
    select distinct tt.Dic_Id, t.grado peso, ttt.Dic_Tipo
    from #tmp001_recopilando_preguntas t,
        dbo.rh50_evDesFormsDet tt, dbo.m_diccionarios ttt
    where t.FormEDL_Id = tt.FormEvDes_Id and tt.FEDDet_Activo = 1
    and tt.Dic_id = ttt.Dic_id and ttt.Dic_Disponible = 1
)
,lst001_comportamientos(dato)as(
    select concat(i, 41, c.cab, (select r,
    tt.Dic_Id, t, rd.nombre
    from tmp001_matriz_cabecera t
    cross apply dbo.m_diccionarios tt
    cross apply tmp001_matriz_pesos ttt
    cross apply(
        select replace(replace(rtrim(tt.Dic_Descripcion),
        char(13),''), char(10), ''))rd(nombre)
    where t.Dic_Id = tt.Dic_Id_Padre and tt.Dic_Disponible = 1
    and tt.grado = ttt.grado and t.peso = ttt.peso
    order by tt.Dic_Id_Padre, rd.nombre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep, cap001_comportamientos c
)
select concat(m.meta, (select r,
    null, t,
    t.FormEDL_Id, t,
    t.Evaluador_Id, t,
    t.Trab_Sec, t,
    t.Pues_Org_Id, t,
    t.Proy_Nombre, t,
    t.evaluador
from #tmp001_recopilando_preguntas t
for xml path, type).value('.','varchar(max)'),
t.dato, t1.dato, t2.dato, t3.dato, t4.dato
)
from tmp001_sep cross apply #tmp001_meta m
cross apply hlp001_cards t
cross apply tmp004_liker t1
cross apply #tmp001_tipoEval t2
cross apply lst001_comportamientos t3
outer apply #tmp001_rindieron_evaluacion t4


end try
begin catch
    select concat('error:', error_message()) dato
end catch
end
go


exec dbo.usp_listar_encuestas_comportamientos '52'


-- select top 0 cast(null as char(1)) pivote into #tmp001_pivote
-- exec dbo.usp_listar_encuestas_comportamientos '52', 22
-- select*from #tmp001_pivote


-- select*from dbo.mastertable('dbo.rh50_evDes')

-- NO TOCAR
-- select*from dbo.m_diccionariosTipos



-- update t set FormEvDes_Activo = 0
-- from dbo.rh50_evDesForms  t where FormEvDes_Id = 2
-- select*from dbo.rh50_evDesForms
