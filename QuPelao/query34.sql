use SCP_CNDH
go
if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_split','if'))
drop function dbo.udf_split
go
create function dbo.udf_split(
@data varchar(max),
@sep varchar(1)='|'
)returns table as return(
select tt.n.value('.','varchar(max)') value
from(select cast(concat('<x>', replace(@data, @sep, '</x><x>'),'</x>') as xml) val)t
cross apply t.val.nodes('/x')tt(n)
)
go

if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_splice','if'))
drop function dbo.udf_splice
go
create function dbo.udf_splice(
    @data varchar(max),
    @sepCamp char(1) = '|',
    @sepRegs char(1) = '~'
)returns table as return(
    with tmp001_data(dato)as(
        select substring(@data, 0, isnull(nullif(charindex(@sepRegs, @data),0),len(@data)+1))
    )
    select concat('select*from(values(''',
    replace(replace(@data, @sepCamp, ''','''), @sepRegs, '''),('''),'''))t',
    stuff((select concat(',a', row_number()over(order by (select 1)))
    from tmp001_data t cross apply dbo.udf_split(t.dato, @sepCamp)
    for xml path, type).value('.', 'varchar(max)'), 1, 1, '('),')') dato
)
go
