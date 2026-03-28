use SCC_SPP_BUENA  -- mi pelao
go

declare @cod_promocion varchar(10)
-- = '10'
= ''

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
    select '01' codOrden, 'Edades' txtOrden,
    convert(varchar(100), min(edad)) codigo,
    convert(varchar(100), max(edad)) descripcion,
    sum(edad)/ count(1) cantidad,
    sum(1)over() total
    from tmp001_matrizCandidatos
)
,tmp001_sexo as(
    select '02' codOrden, 'sexo' txtOrden,
    t.cod_sexo, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_sexo, sum(1)over(partition by cod_sexo) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
)
,tmp001_profesion as(
    select '03' codOrden, 'profesion' txtOrden,
    t.cod_profesion, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_profesion, sum(1)over(partition by cod_profesion) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.scc_profesion tt where tt.cod_profesion = t.cod_profesion)tt
)
,tmp001_gradoacademico as(
    select '04' codOrden, 'gradoacademico' txtOrden,
    t.cod_gradoacademico, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_gradoacademico, sum(1)over(partition by cod_gradoacademico) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.scc_gradoacademico tt where tt.cod_gradoacademico = t.cod_gradoacademico)tt
)
,tmp001_ocupacion as(
    select '05' codOrden, 'ocupacion' txtOrden,
    t.cod_ocupacion, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_ocupacion, sum(1)over(partition by cod_ocupacion) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.scc_ocupacion tt where tt.cod_ocupacion = t.cod_ocupacion)tt
)
,tmp001_formacion as(
    select '06' codOrden, 'formacion' txtOrden,
    t.cod_formacionpsicote, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    cod_formacionpsicote, sum(1)over(partition by cod_formacionpsicote) cant, sum(1)over() total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.scc_formacion tt where tt.cod_formacion = t.cod_formacionpsicote)tt
)
,tmp001_periodoingreso as(
    select '07' codOrden, 'periodoingreso' txtOrden,
    t.txt_periodoingreso, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    txt_periodoingreso, cod_sexo, sum(1)over(partition by txt_periodoingreso, cod_sexo) cant,
    sum(1)over(partition by txt_periodoingreso) total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
    order by t.txt_periodoingreso offset 0 rows
)
,tmp001_periodoculminaseminario as(
    select '08' codOrden, 'periodoculminaseminario' txtOrden,
    t.txt_periodoculminaseminario, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    txt_periodoculminaseminario, cod_sexo, sum(1)over(partition by txt_periodoculminaseminario, cod_sexo) cant,
    sum(1)over(partition by txt_periodoculminaseminario) total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
    order by t.txt_periodoculminaseminario offset 0 rows
)
,tmp001_periodoegreso as(
    select '09' codOrden, 'periodoegreso' txtOrden,
    t.txt_periodoegreso, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct
    txt_periodoegreso, cod_sexo, sum(1)over(partition by txt_periodoegreso, cod_sexo) cant,
    sum(1)over(partition by txt_periodoegreso) total
    from tmp001_matrizCandidatos)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
    order by t.txt_periodoegreso offset 0 rows
)
select*from tmp001_edades union all
select*from tmp001_sexo union all
select*from tmp001_profesion union all
select*from tmp001_gradoacademico union all
select*from tmp001_ocupacion union all
select*from tmp001_formacion union all
select*from tmp001_periodoingreso union all
select*from tmp001_periodoculminaseminario union all
select*from tmp001_periodoegreso
