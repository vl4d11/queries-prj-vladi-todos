use SCP_EQUIDAD0;select @@version

Declare 
@fecha_ini date = '2025-01-10', @fecha_fin date = '2025-03-29'


;with tmp001_data as(
    select top 20 row_number()over(order by (select 1)) item, *
    from scp_comprobanteCabecera
)
,tmp001_fechas as(
    select null item2, null as item1,
    1 item, @fecha_ini fecha, cast(34.65 as numeric(8,2)) monto, 
    cast(null as varchar) salida
    union all
    select cast(tt.item as int), cast(t.item as int),    
    t.item + 1,  dateadd(dd, 1, fecha), 
    
    iif(t.item > 1, cast(monto +1 as numeric(8,2)), monto),
    case t.item when 66 then convert(varchar,'maria bonita') end
    
    from tmp001_fechas t, tmp001_data tt
    where t.item = tt.item 
)
select*from tmp001_fechas where not item2 is null
option(maxrecursion 0)
