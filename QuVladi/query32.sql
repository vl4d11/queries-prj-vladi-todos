if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_armar_matriz_detalle','p'))
drop procedure dbo.usp_armar_matriz_detalle
go
create procedure dbo.usp_armar_matriz_detalle
@data varchar(max)
as
begin
set nocount on
set language english

create table #tmp001_datos(
    item int identity,
    dato varchar(max)
)
insert into #tmp001_datos
select value from dbo.udf_split(@data, default)

;with tmp001_auth as(
    select cast(dato as int) auth from #tmp001_datos where item = 1
)
,tmp001_totreg as(
    select count(1) totreg from #tmp001_datos where item > 2
)
,tmp001_size as(
    select cast(dato as int) size, totreg, auth
    from #tmp001_datos, tmp001_totreg, tmp001_auth
    where item = 2
)
,tmp001_iteracion as(
    select itera, auth
    from(select row_number()over(order by (select 1))*size itera, totreg, auth
    from sys.fn_helpcollations() cross apply tmp001_size
    where substring(name,1,1) = 'a')t where itera < totreg +1
)
,tmp001_cta_reg as(
    select cta
    from(select row_number()over(order by (select 1)) cta, size
    from sys.fn_helpcollations() cross apply tmp001_size
    where substring(name,1,1) = 'a')t where cta < size +1
)
,tmp001_matriz as(
    select row_number()over(order by itera, cta)+2 item, itera, auth
    from tmp001_cta_reg, tmp001_iteracion order by itera, cta offset 0 rows
)
select t.item, tt.auth, tt.itera, t.dato
from #tmp001_datos t, tmp001_matriz tt where t.item > 2 and t.item = tt.item
order by t.item

end
go

select top 0
cast(null as int) item,
cast(null as int) auth,
cast(null as int) itera,
cast(null as varchar(max)) collate database_default dato into #tmp001_matrizDetalle

insert into #tmp001_matrizDetalle
exec dbo.usp_armar_matriz_detalle '4|5|5.1|5.2|5.3|5.4|5.5|||12|3|1|||11|7|1'

select*from #tmp001_matrizDetalle
