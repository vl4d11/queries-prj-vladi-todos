use SCC_SPP_BUENA  -- mi pelao
go

alter procedure dbo.usp_scc_RepPerfilProfesor
@cod_promocion varchar(2)
as
begin
set nocount on

;with tmp001_promocion as(
    select top 1 with ties cod_promocion, idProfesor
    from dbo.scc_dictadoseminario t
    where t.cod_promocion = @cod_promocion
    order by row_number()over(partition by cod_promocion, idProfesor order by cod_promocion, idProfesor)
)
,tmp001_matrizProfesor as(
    select datediff(year,
    case when fec_nacimiento != cast('' as date) then fec_nacimiento end, getdate()) edad,
    cod_sexo, cod_tiempoincorp, cod_condicion
    from dbo.scc_profesor t
    outer apply(select*from tmp001_promocion tt where tt.idProfesor = t.idProfesor)tt
    where @cod_promocion = '' or  not tt.idProfesor is null
)
,tmp001_sexo as(
    select '02' codOrden, 'Sexo' txtOrden,
    t.cod_sexo, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct cod_sexo, sum(1)over(partition by cod_sexo) cant, sum(1)over() total
    from tmp001_matrizProfesor)t
    outer apply(select*from dbo.gen_sexo tt where tt.cod_sexo = t.cod_sexo)tt
)
,tmp001_tiempoincorp as(
    select '03' codOrden, 'Tiempo Incorporado' txtOrden,
    t.cod_tiempoincorp, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct cod_tiempoincorp, sum(1)over(partition by cod_tiempoincorp) cant, sum(1)over() total
    from tmp001_matrizProfesor)t
    outer apply(select*from dbo.scc_tiempoincorp tt where tt.cod_tiempoincorp = t.cod_tiempoincorp)tt
)
,tmp001_condicion as(
    select '04' codOrden, 'Condicion' txtOrden,
    t.cod_condicion, isnull(tt.txt_descripcioncorta,'') descripcion, t.cant, t.total
    from(select distinct cod_condicion, sum(1)over(partition by cod_condicion) cant, sum(1)over() total
    from tmp001_matrizProfesor)t
    outer apply(select*from dbo.scc_condicion tt where tt.cod_condicion = t.cod_condicion)tt
)
,tmp001_edades as(
    select '01' codOrden, 'Edades' txtOrden,
    row_number()over(order by (select 1)) Codigo, isnull(rango, '') Descripcion,
    edades cantidad, total
    from(select distinct tt.rango,
    sum(1)over(partition by tt.rango) edades, sum(1)over() total
    from tmp001_matrizProfesor t cross apply(
    select case when edad < 31 then 'menor 31'
    when edad between 31 and 40 then 'entre 31-40'
    when edad between 41 and 50 then 'entre 41-50'
    when edad between 51 and 60 then 'entre 51-60'
    when edad between 61 and 70 then 'entre 61-70'
    when edad > 70 then 'mayor 70' end rango)tt)t
)
select*from tmp001_edades union all
select*from tmp001_sexo union all
select*from tmp001_tiempoincorp union all
select*from tmp001_condicion

end
go

exec dbo.usp_scc_RepPerfilProfesor '10'
