use SCC_SPP_BUENA
go

ALTER procedure dbo.usp_scc_RepPerfilCandidato
@cod_promocion varchar(2)
as
begin
set nocount on

;with tmp001_matrizCandidatos as(
    select
    datediff(year,
    case when fec_nacimiento != cast('' as date) then fec_nacimiento end, getdate()) edad,
    cod_sexo,
    cod_profesion,
    cod_gradoacademico,
    cod_ocupacion,
    cod_formacionpsicote,
    txt_periodoingreso,
    txt_periodoculminaseminario,
    txt_periodoegreso
    from dbo.scc_candidato
    where @cod_promocion = '' or cod_promocion = @cod_promocion
)
,tmp001_edades as(
    select '01' CodOrden, 'Edades' TxtOrden,
    row_number()over(order by (select 1)) Codigo, isnull(rango, '') Descripcion,
    edades Cantidad, Total
    from(select distinct tt.rango,
    sum(1)over(partition by tt.rango) edades, sum(1)over() total
    from tmp001_matrizCandidatos t cross apply(
    select case when edad < 31 then 'menor 31'
    when edad between 31 and 40 then 'entre 31-40'
    when edad between 41 and 50 then 'entre 41-50'
    when edad between 51 and 60 then 'entre 51-60'
    when edad between 61 and 70 then 'entre 61-70'
    when edad > 70 then 'mayor 70' end rango)tt)t
)
,tmp001_sexo as(
    select '02' codOrden, 'Sexo' txtOrden,
    t.cod_sexo, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_sexo, sum(1)over(partition by cod_sexo) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
)
,tmp001_profesion as(
    select '03' codOrden, 'Profesion' txtOrden,
    t.cod_profesion, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_profesion, sum(1)over(partition by cod_profesion) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.scc_profesion tt where tt.cod_profesion = t.cod_profesion)tt
)
,tmp001_gradoacademico as(
    select '04' codOrden, 'Grado Académico' txtOrden,
    t.cod_gradoacademico, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_gradoacademico, sum(1)over(partition by cod_gradoacademico) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.scc_gradoacademico tt where tt.cod_gradoacademico = t.cod_gradoacademico)tt
)
,tmp001_ocupacion as(
    select '05' codOrden, 'Ocupacion' txtOrden,
    t.cod_ocupacion, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_ocupacion, sum(1)over(partition by cod_ocupacion) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.scc_ocupacion tt where tt.cod_ocupacion = t.cod_ocupacion)tt
)
,tmp001_formacion as(
    select '06' codOrden, 'Formacion' txtOrden,
    t.cod_formacionpsicote, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_formacionpsicote, sum(1)over(partition by cod_formacionpsicote) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.scc_formacion tt where tt.cod_formacion = t.cod_formacionpsicote)tt
)
,tmp001_periodoingreso as(
    select '07' codOrden, 'Periodo Ingreso' txtOrden,
    t.txt_periodoingreso,
    concat(tt.txt_descripcioncorta,' ',
    case when not tt.txt_descripcioncorta is null then t.txt_periodoingreso end) descripcion,
    t.cant, t.total
    from(select distinct
    txt_periodoingreso, cod_sexo, sum(1)over(partition by txt_periodoingreso, cod_sexo) cant,
    sum(1)over(partition by txt_periodoingreso) total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
    order by t.txt_periodoingreso offset 0 rows
)
,tmp001_periodoculminaseminario as(
    select '08' codOrden, 'Periodo Culmina Seminario' txtOrden,
    t.txt_periodoculminaseminario,
    concat(tt.txt_descripcioncorta,' ',
    case when not tt.txt_descripcioncorta is null then t.txt_periodoculminaseminario end) descripcion,
    t.cant, t.total
    from(select distinct
    txt_periodoculminaseminario, cod_sexo, sum(1)over(partition by txt_periodoculminaseminario, cod_sexo) cant,
    sum(1)over(partition by txt_periodoculminaseminario) total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
    order by t.txt_periodoculminaseminario offset 0 rows
)
,tmp001_periodoegreso as(
    select '09' codOrden, 'Periodo Egreso' txtOrden,
    t.txt_periodoegreso,
    concat(tt.txt_descripcioncorta,' ',
    case when not tt.txt_descripcioncorta is null then t.txt_periodoegreso end) descripcion,
    t.cant, t.total
    from(select distinct
    txt_periodoegreso, cod_sexo, sum(1)over(partition by txt_periodoegreso, cod_sexo) cant,
    sum(1)over(partition by txt_periodoegreso) total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
    order by t.txt_periodoegreso offset 0 rows
)
select*from(
select*from tmp001_edades union all
select*from tmp001_sexo union all
select*from tmp001_profesion union all
select*from tmp001_gradoacademico union all
select*from tmp001_ocupacion union all
select*from tmp001_formacion union all
select*from tmp001_periodoingreso union all
select*from tmp001_periodoculminaseminario union all
select*from tmp001_periodoegreso)t
-- where codigo != 0

END
go
  exec dbo.usp_scc_RepPerfilCandidato '10'

 exec dbo.usp_scc_RepPerfilCandidato ''
