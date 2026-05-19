if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_listar_formato_evaluacionDesem','p'))
drop procedure dbo.usp_listar_formato_evaluacionDesem
go
create procedure dbo.usp_listar_formato_evaluacionDesem
@data varchar(100) = 0
as
begin
begin try
set nocount on
set language english
select top 0
cast(null as varchar(max)) collate database_default meta into #tmp001_meta

declare @dato varchar(max) = '\
t|FormEvDes_Id||||0|1*1.1**~
t|FormEvDes_Nombre|1|||1|2*1.5*Ingrese Nombre de Evaluación:*12**~
t|FormEvDes_Descripcion|1||3|1|3*1.6*Ingrese Descripcion de Evaluación:*12**~
t|FormEvDes_PComp|1|3|1||4*1.7*Peso Competencia(%):*4**~
t|FormEvDes_EscalaComp||||4|5*1.2*Escala Competencia:*4**~
t|FormEvDes_PObjetivo||3|1||6*1.8*Peso Objetivos(%):*4**~
t|FormEvDes_EscalaObj||||4|7*1.3*Escala Objetivos:*4**~
t|FormEvDes_Activo|||||8*1.9*Disponible:*8*1*~
t|FormEvDes_EsCompleto|||||9*1.4*Porcentaje Completo:*8*1*~
t|FormEvDes_Inicio|1||||10*1.10*Fecha de Inicio:*6**~
t|FormEvDes_Duracion|1|2|||11*1.11*Duración( semana ):*6*1*~
t|isGrupo|||||20*1.12*Titulo por Grupos*6*1*~
t|isComentario|||||19*1.13*Con Observacion*8*1*~
t|mensajeCab||||5|17*1.14*Mensaje Bienvenida e Instrucciones*90**~
t|mensajePie|||||18*1.15*Mensaje Agradecimiento*22**~
tt|FEDDet_ID||||0|12*4.1**~
tt|FormEvDes_Id||||0|13*4.2**~
tt|Dic_Id|1|||4|14*4.3*Seleccione Competencia:*8****1~
tt|FEDDet_Peso|1|3|1||15*4.4*Peso Competencia(%):*6***~
tt|FEDDet_Activo|||||16*4.5*Disponible:*8*1**'

exec dbo.usp_listar_metadata
@dato output, 't|dbo.rh50_evDesForms~tt|dbo.rh50_evDesFormsDet'
insert into #tmp001_meta select @dato

;with tmp001_sep(t,r,i,pvt)as(
    select*, cast(@data as int) from(
    values('|','~','^'))t(Sepcamp,SepReg,SepList)
)
,hlp001_escalas(dato) as(
    select concat(i, 5.7, (select r, Escala_Id, t, Escala_Nombre
    from dbo.m_escalas
    order by Escala_Nombre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,hlp001_competencias(dato) as(
    select concat(i, 14, (select r, Dic_Id, t, re.nombre
    from dbo.m_Diccionarios
    cross apply(select replace(replace(Dic_Nombre, char(13),''), char(10), ''))re(nombre)
    where Dic_Disponible = 1 and Dic_Tipo = 'CO'
    order by re.nombre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,hlp001_cards(dato)as(
    select concat(i, 22, (select r, item, t, title, t, ancho from(
    values(1, 'NUEVO Formato de Evaluación :', 80),
    (3, '', 50),
    (2, 'Detalle Formato de Evaluación Desempeño :', 80),
    (4, 'Detalle Formato de Evaluación Desempeño :', 80))t(item, title, ancho)
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,cap001_formato_cab(cab)as(
    select concat(r,
    '1|5|7|9|2|3|4|6|8|10|11|20|19|17|18', r,
    '1|2|3|4|Nombre Formato Evaluación|Descripcion Formato Evaluación|',
    'Peso Competencia|Peso Objetivo|Activo|Fecha Inicio|Duracion|',
    'Grupo|Observa|Msg. Intro|Msg. Agradecimiento', r,
    '0|0|0|0|300|600|200|200|100|150|100|100|100|300|300')
    from tmp001_sep
)
,lst001_formatos_Cab(dato)as(
    select concat(i, 41, c.cab, (select top 80 r,
        t.FormEvDes_Id, t,
        t.FormEvDes_EscalaComp, t,
        t.FormEvDes_EscalaObj, t,
        t.FormEvDes_EsCompleto, t,
        t.FormEvDes_Nombre, t,
        t.FormEvDes_Descripcion, t,
        ltrim(str(t.FormEvDes_PComp*100,3,0)), t,
        ltrim(str(t.FormEvDes_PObjetivo*100,3,0)), t,
        t.FormEvDes_Activo, t,
        t.FormEvDes_Inicio, t,
        t.FormEvDes_Duracion, t,
        t.isGrupo, t,
        t.isComentario, t,
        t.mensajeCab, t,
        t.mensajePie
    from dbo.rh50_evDesForms t
    order by t.FormEvDes_Id desc
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep, cap001_formato_cab c
)
,cap001_formato_det(cab)as(
    select concat(r,
    '0|12|13|14|15|16|0|0|0', r,
    '1|2|3|4|5|6|Nombre Competencia|Peso Competencia|Disp.', r,
    '0|0|0|0|0|0|400|200|100')
    from tmp001_sep
)
,lst001_formatos_Det(dato)as(
    select concat(i, 42, c.cab, (select top 500 r,
        lower(convert(varchar(32), hashbytes('md5',
        concat(
            tt.FEDDet_ID, t,
            tt.FormEvDes_Id, t,
            tt.Dic_Id, t,
            tt.FEDDet_Peso, t,
            tt.FEDDet_Activo
        )), 2)), t,
        tt.FEDDet_ID, t,
        tt.FormEvDes_Id, t,
        tt.Dic_Id, t,
        tt.FEDDet_Peso, t,
        tt.FEDDet_Activo
    from dbo.rh50_evDesFormsDet tt
    order by tt.FEDDet_ID desc
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep, cap001_formato_det c
)
select concat(m.meta, (select r,
    t.FormEvDes_Id, t,
    t.FormEvDes_Nombre, t,
    t.FormEvDes_Descripcion, t,
    str(t.FormEvDes_PComp, 4,2), t,
    t.FormEvDes_EscalaComp, t,
    str(t.FormEvDes_PObjetivo, 4,2), t,
    t.FormEvDes_EscalaObj, t,
    t.FormEvDes_Activo, t,
    t.FormEvDes_EsCompleto, t,
    t.FormEvDes_Inicio, t,
    t.FormEvDes_Duracion, t,
    t.isGrupo, t,
    t.isComentario, t,
    t.mensajeCab, t,
    t.mensajePie
from dbo.rh50_evDesForms t
where t.FormEvDes_Activo = 1 and t.FormEvDes_Id = pvt
order by t.FormEvDes_Id desc
for xml path, type).value('.','varchar(max)'),
t1.dato, t2.dato, t3.dato, t4.dato, t5.dato
)
from tmp001_sep cross apply #tmp001_meta m
outer apply(select*from hlp001_escalas where pvt = 0)t1
outer apply(select*from hlp001_competencias where pvt = 0)t2
outer apply(select*from hlp001_cards where pvt = 0)t3
outer apply(select*from lst001_formatos_Cab where pvt = 0)t4
outer apply(select*from lst001_formatos_Det where pvt = 0)t5

end try
begin catch
    select concat('error:', error_message()) dato
end catch
end
go

exec usp_listar_formato_evaluacionDesem

exec dbo.usp_listar_tablas 'dbo.rh50_evDesForms|dbo.rh50_evDesFormsDet'


-- go
-- create function dbo.udf_RH50_EvDesForms_pk_001()returns table as return
-- (select isnull(max(FormEvDes_Id),0)+1 FormEvDes_Id from dbo.RH50_EvDesForms)
-- go
