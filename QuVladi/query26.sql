if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_listar_competencias','p'))
drop procedure dbo.usp_listar_competencias
go
create procedure dbo.usp_listar_competencias
@data varchar(100) = 0
as
begin
begin try
set nocount on
select top 0 cast(null as varchar(max)) collate database_default meta into #tmp001_meta

declare @dato varchar(max) =
't|Dic_Id||||0|1*1**~
t|Dic_Id_Padre|1|||4|2*1*Seleccione Competencia:*12*1***1~
t|Dic_Nombre|1||3|1|3*1*Ingrese Nombre Competencia:*18*1**1~
t|Dic_Descripcion|1|||5|4*1*Ingrese Descripcion:*80***~
t|Dic_Tipo||||4|5*1*Seleccione Tipo:*8**0*~
t|Dic_ComGrupoId||||4|6*1*Seleccione Grupo:*8***~
t|grado||||4|8*1*Seleccione Grado:*8***~
t|Dic_Disponible|||||7*1*Disponible*8*1**'

exec dbo.usp_listar_metadata @dato output, 't|dbo.m_Diccionarios'
insert into #tmp001_meta select @dato

;with tmp001_sep(t,r,i,x1,x2, pvt)as(
    select*, cast(@data as int) from(
    values('|','~','^','    ( ',' )'))t(Sepcamp,SepReg,SepList,aux1,aux2)
)
,hlp001_competencias(dato) as(
    select concat(i, 2, (select r, Dic_Id, t, re.nombre
    from dbo.m_Diccionarios
    cross apply(select replace(replace(Dic_Nombre, char(13),''), char(10), ''))re(nombre)
    where Dic_Disponible = 1 and Dic_Tipo = 'CO'
    order by re.nombre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,hlp001_competencia_grupo(dato)as(
    select concat(i, 6, (select r, ComG_Id, t, ComG_Nombre
    from dbo.m_Diccionarios_ComGrupos
    outer apply(select*from(values('EA'))t(item) where t.item = ComG_Id)t
    where ComG_Disponible = 1
    order by t.item desc, ComG_Nombre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,hlp001_competencia_tipo(dato)as(
    select concat(i, 5, (select r, DicT_Id, t, DicT_Nombre
    from dbo.m_DiccionariosTipos
    outer apply(select*from(values('CM'))t(item) where t.item = DicT_Id)t
    where DicT_Disponible = 1
    order by t.item desc, DicT_Nombre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,hlp001_grados(dato)as(
    select concat(i, 8, (select r, id_nivel, t, nombre_nivel, x1, grados_nivel, x2
    from dbo.m_Nivel_Posicion
    order by nombre_nivel
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,hlp001_cards(dato)as(
    select concat(i, 22, (select r, item, t, title, t, ancho from(
    values(1, 'NUEVO Comportamiento:', 80),
    (2, '', 50),
    (3, 'Lista de Comportamientos:', 80))t(item, title, ancho)
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,cap001_competencias(cab)as(
    select concat(r,
    '1|4|7|6|3|0|0', r,
    '1|2|3|4|Nombre Competencia|Nombre Grupo|Disp.', r,
    '0|0|0|0|600|300|100')
    from tmp001_sep
)
,lst001_competencias(dato)as(
    select concat(i, 40, c.cab, (select top 100 r,
    t.Dic_Id, t, rd.nombre, t, t.Dic_Disponible, t, t.Dic_ComGrupoId, t,
    re.nombre, t, tt.ComG_Nombre, t,
    case t.Dic_Disponible when 1 then 'SI' else 'NO' end
    from dbo.m_Diccionarios t
    cross apply dbo.m_Diccionarios_ComGrupos tt
    cross apply(select replace(replace(t.Dic_Nombre, char(13),''), char(10), ''))re(nombre)
    cross apply(select replace(replace(t.Dic_Descripcion, char(13),''), char(10), ''))rd(nombre)
    where t.Dic_ComGrupoId = tt.ComG_Id and t.Dic_Tipo = 'CO'
    order by t.Dic_Id desc, re.nombre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep, cap001_competencias c
)
,cap001_comportamientos(cab)as(
    select concat(r,
    '1|2|7|6|8|4|0|0|0', r,
    '1|2|3|4|5|Descripcion Comportamiento|Nombre Grado|Nombre Grupo|Disp.', r,
    '0|0|0|0|10|800|400|300|100')
    from tmp001_sep
)
,lst001_comportamientos(dato)as(
    select concat(i, 41, c.cab, (select top 1000 r,
    t.Dic_Id, t, t.Dic_Id_Padre, t, t.Dic_Disponible, t, t.Dic_ComGrupoId, t, t.grado, t,
    rd.nombre, t, upper(concat(ttt.nombre_nivel, x1, ttt.grados_nivel, x2)), t, tt.ComG_Nombre, t,
    case t.Dic_Disponible when 1 then 'SI' else 'NO' end
    from dbo.m_Diccionarios t
    cross apply dbo.m_Diccionarios_ComGrupos tt
    cross apply dbo.m_Nivel_Posicion ttt
    cross apply(select replace(replace(t.Dic_Descripcion, char(13),''), char(10), ''))rd(nombre)
    where t.Dic_ComGrupoId = tt.ComG_Id and t.grado = ttt.id_nivel and
    t.Dic_Tipo = 'CM'
    order by t.Dic_Id desc, t.Dic_Id_Padre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep, cap001_comportamientos c
)
select concat(meta, (select r,
t.Dic_Id, t,
t.Dic_Id_Padre, t,
t.Dic_Nombre, t,
t.Dic_Descripcion, t,
t.Dic_Tipo, t,
t.Dic_ComGrupoId, t,
t.grado, t,
t.Dic_Disponible
from dbo.m_Diccionarios t
where t.Dic_Disponible = 1 and t.Dic_Id = pvt
for xml path, type).value('.','varchar(max)'),
t1.dato, t2.dato, t3.dato, t4.dato, t5.dato, t6.dato, t7.dato
)
from tmp001_sep cross apply #tmp001_meta
outer apply(select*from hlp001_competencias where pvt = 0)t1
outer apply(select*from hlp001_competencia_grupo where pvt = 0)t2
outer apply(select*from hlp001_competencia_tipo where pvt = 0)t3
outer apply(select*from hlp001_grados where pvt = 0)t4
outer apply(select*from hlp001_cards where pvt = 0)t5
outer apply(select*from lst001_competencias where pvt = 0)t6
outer apply(select*from lst001_comportamientos where pvt = 0)t7

end try
begin catch
    select concat('error:', error_message()) dato
end catch
end
go

exec dbo.usp_listar_competencias
-- exec dbo.usp_listar_competencias 13
-- exec dbo.usp_listar_competencias 4

-- exec dbo.usp_listar_tablas 'dbo.m_Diccionarios'
