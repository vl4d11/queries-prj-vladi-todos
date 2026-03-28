-- create function dbo.udf_competencia_pk_001()returns table as return
-- -- (select max(Dic_Id)+1 Dic_Id from dbo.m_Diccionarios)
-- go
-- create function dbo.udf_competencia_Dic_Cod_dato_001(
-- @Dic_Tipo varchar(3)
-- )returns table as return(
--     select distinct Dic_Cod = concat(@Dic_Tipo,
--     max(cast(stuff(Dic_Cod,1,2,'') as int))over(partition by substring(Dic_Cod,1,2))+1)
--     from dbo.m_Diccionarios where Dic_Tipo = @Dic_Tipo
-- )
-- go

select Dic_id from dbo.udf_competencia_pk_001()
select Dic_Cod from dbo.udf_competencia_Dic_Cod_dato_001('CO')
select Dic_Cod from dbo.udf_competencia_Dic_Cod_dato_001('CM')


exec dbo.usp_listar_tablas 'dbo.m_Diccionarios'

-- select*from dbo.m_Diccionarios
return
select*from mastertable('dbo.m_Diccionarios')

exec dbo.usp_listar_tablas 'dbo.m_Diccionarios'

select*from dbo.m_Nivel_Posicion
select*from dbo.m_Diccionarios



-- insert into dbo.m_Diccionarios
-- select 18+item, a1, concat('CM',item),
-- a2,a3,a4,a5,a6,a7,a8,a9,a10,a11
-- from(select row_number()over(order by (select 1))+1  item, *
-- from(
-- select 13, 'AGILIDAD MENTAL', '¿Aprende rápidamente nuevos procedimientos o tareas técnicas?', 'CM', 'EA', 1, 4, getdate(), null, null,1
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Resuelve problemas operativos sin depender completamente de su supervisor?', 'CM', 'EA', 1, 4, getdate(), null, null,1
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Analiza situaciones y propone soluciones efectivas?', 'CM', 'EA', 1, 4, getdate(), null, null,2
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Toma decisiones adecuadas con la información que tiene a su alcance?', 'CM', 'EA', 1, 4, getdate(), null, null,2
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Identifica causas raíz de los problemas antes de actuar?', 'CM', 'EA', 1, 4, getdate(), null, null,2
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Resuelve problemas complejos que impactan en su área?', 'CM', 'EA', 1, 4, getdate(), null, null,3
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Evalúa distintas alternativas antes de tomar decisiones críticas?', 'CM', 'EA', 1, 4, getdate(), null, null,3
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Anticipa problemas y define acciones preventivas?', 'CM', 'EA', 1, 4, getdate(), null, null,3
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Toma decisiones estratégicas en contextos de alta incertidumbre?', 'CM', 'EA', 1, 4, getdate(), null, null,4
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Integra variables operativas, financieras y humanas en sus decisiones?', 'CM', 'EA', 1, 4, getdate(), null, null,4
-- union all
-- select 13, 'AGILIDAD MENTAL', '¿Define soluciones que impactan a múltiples áreas o a la organización?', 'CM', 'EA', 1, 4, getdate(), null, null,4
-- )t(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11))t
