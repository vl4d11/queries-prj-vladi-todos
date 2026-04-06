if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_mantenimiento_generico_simple','p'))
drop procedure dbo.usp_mantenimiento_generico_simple
go
create procedure dbo.usp_mantenimiento_generico_simple
    @data varchar(max),
    @autoSalida int = 0,
    @logica varchar(1000) = '',
    @remplaza varchar(100) = '',
    @por varchar(100) = ''
as
begin
begin try
set nocount on
set language english

declare @tablas varchar(max), @campos varchar(500)
declare @salida varchar(50) =
case @autoSalida when 0 then 'select item from #tmp001_out' else '' end,
@tablaOut varchar(200) = case @autoSalida when 0 then
'create table #tmp001_out(accion varchar(6), item bigint);' else '' end

select top 0
cast(null as int) orden,
cast(null as int) item,
cast(null as int) column_id,
cast(null as varchar(200)) collate database_default tabla,
cast(null as varchar(200)) collate database_default name,
cast(null as int) length,
cast(null as int) is_nullable,
cast(null as int) is_identity,
cast(null as int) default_object_id,
cast(null as int) is_primary_key,
cast(null as int) tipo_dato,
cast(null as int) audi into #tmp001_tablas
create table #tmp001_preData(
    item int identity,
    data varchar(500)
)
insert into #tmp001_preData
select value from dbo.udf_split(@data, default)

select data, item, case when item > mim then 1 else 0 end grupo
into #tmp001_data
from(select data, row_number()over(order by item) item, max(item/2)over() mim
from #tmp001_preData where item > 1 order by item offset 0 rows)t
order by item

select @tablas = stuff((select distinct ',', tt.tabla
from #tmp001_data t, dbo.mastertablas tt
where t.grupo = 0 and parsename(t.data,2) = tt.item
for xml path, type).value('.','varchar(max)'),1,1,'')

insert into #tmp001_tablas exec dbo.usp_listar_tablas @tablas

select row_number()over(order by orden_inical) cta,*
into #tmp001_master
from(select*from(
select tt.*, t.item orden_inical
from #tmp001_data t, #tmp001_tablas tt
where t.grupo = 0 and t.data = concat(tt.item, '.', tt.column_id)
order by t.item offset 0 rows)t
union all
select*, row_number()over(order by tipo_dato)+300
from #tmp001_tablas where audi != 0)t

select @campos = stuff((select ',n.', name from #tmp001_master order by cta
for xml path,type).value('.','varchar(max)'),1,1,'')

select @campos = replace(@campos, @remplaza, @por)

;with tmp001_master as(
    select*from #tmp001_master
)
,tmp001_datos_frontend(dato) as(
    select concat(stuff((select '|', data
        from #tmp001_data where grupo = 1 order by item
        for xml path,type).value('.','varchar(max)'),1,1,''), t.dato)
    from(select dato = concat('|', data, '|', data, '|',
    convert(varchar, getdate(), 121), '|', convert(varchar, getdate(), 121))
    from #tmp001_preData where item = 1)t
)
,tmp001_datos_frontend_result(dato) as(
    select concat('insert into #tmp001_mergeData11 ', t.dato)
    from tmp001_datos_frontend cross apply dbo.udf_splice(dato, default, default)t
)
,tmp001_tabla_poblar(dato) as(
    select concat(@tablaOut, stuff((select ',',
    case is_primary_key when 1 then concat('cast(null as bigint) ', name) else name end
    from tmp001_master order by cta
    for xml path,type).value('.','varchar(max)'),1,1,'select '),
    ' into #tmp001_mergeData11 from ', @tablas, ' where 1=2;')
)
,tmp001_pks(dato) as(
    select name from tmp001_master where is_primary_key = 1
)
,tmp001_merge(dato) as(
    select concat(';merge into ',
    @tablas, ' t using(select ', @campos,' from #tmp001_mergeData11 n ',
    @logica,')s on(')
)
,tmp001_on(dato) as(
    select concat(stuff((select ' and t.', name, '=s.', name
    from tmp001_master where is_primary_key = 1
    for xml path,type).value('.','varchar(max)'),1,5,''),
    ') when matched then update set ')
)
,tmp001_matched(dato) as(
    select concat(stuff((select ',t.', name, '=s.', name
    from tmp001_master
    where is_identity = 0 and is_primary_key != 1 and audi != 1
    order by cta
    for xml path,type).value('.','varchar(max)'),1,1,''),
    ' when not matched then insert(')
)
,tmp001_not_matched(dato) as(
    select concat(stuff((select case t.m when 1 then ',' else
    case tt.cta when 1 then ')values(s.' else  ',s.' end end pre, tt.name
    from(select row_number()over(order by cta) cta, name
    from tmp001_master
    where is_identity = 0 and default_object_id = 0 and audi != 2
    order by cta offset 0 rows)tt, (values(1),(2))t(m)
    order by t.m, tt.cta
    for xml path,type).value('.','varchar(max)'),1,1,''),
    ' ) output $action, inserted.', k.dato, ' into #tmp001_out;')
    from tmp001_pks k
)
select @tablas = concat(t1.dato, t2.dato, t3.dato, t4.dato, t5.dato, t6.dato)
from tmp001_tabla_poblar t1,
tmp001_datos_frontend_result t2,
tmp001_merge t3,
tmp001_on t4,
tmp001_matched t5,
tmp001_not_matched t6

exec(@tablas + @salida)

end try
begin catch
    select concat('error:', error_message()) dato
end catch
end
go
