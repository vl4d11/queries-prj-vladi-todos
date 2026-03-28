alter procedure dbo.prueba_likert
@data varchar(100) = 0
as
begin
begin try
set nocount on
set language english

;with tmp001_sep(t,r,i,s,c)as(
    select*from(
    values('|','~','^',' ',',  '))t(Sepcamp,SepReg,SepList,SepAux,Sepcoma)
)
,tmp001_liker as(
    select Escala_Cabecera, Escala_Valores
    from dbo.m_escalas where Escala_Id = 1
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
,cap001_comportamientos(cab)as(
    select concat(r,
    '1|Descripcion Comportamiento', r,
    '0|800')
    from tmp001_sep
)
,tmp001_personal(dato)as(
    select concat(i, 17, (select r,
        Pos_Id, t, rtrim(Pos_ApPat), s, rtrim(Pos_ApMat), c, rtrim(Pos_Nombres)
    from dbo.RH10_Postulantes
    order by Pos_ApPat offset 0 rows fetch next 100 rows only
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,lst001_comportamientos(dato)as(
    select concat(i, 41, c.cab, (select top 1000 r,
    t.Dic_Id, t, rd.nombre
    from dbo.m_Diccionarios t
    cross apply(select replace(replace(t.Dic_Descripcion, char(13),''), char(10), ''))rd(nombre)
    where t.Dic_Tipo = 'CM'
    order by t.Dic_Id desc, t.Dic_Id_Padre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep, cap001_comportamientos c
)
select concat('datos..', t1.dato, t2.dato, t3.dato)
from tmp001_sep
outer apply(select*from tmp004_liker)t1
outer apply(select*from lst001_comportamientos)t2
outer apply(select*from tmp001_personal)t3

end try
begin catch
    select concat('error:', error_message()) dato
end catch
end
go

exec dbo.prueba_likert

-- select*from dbo.m_Diccionarios
