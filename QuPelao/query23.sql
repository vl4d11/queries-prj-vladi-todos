-- NOTA: SCRIPT DE INSERCION DE DATOS MASIVO
-- ===========================================================
use SCP_DESCOSUR; -- select @@version;

set nocount off
declare @data varchar(max),
@tabla varchar(100) = 'dbo.mpp_empleado2'

create table #tmp001_datos (
    item int identity,
    datos varchar(max)
)
select @data = concat(stuff((select ','''''','''''',',
case when substring(name, 1, 4) = 'fec_'
then concat('convert(varchar,', name, ',121)')
when type in('decimal', 'numeric')
then concat('isnull(', name, ', 0)')
else name end
from mastertable(@tabla)
for xml path, type)
.value('.', 'varchar(max)'), 1, 9, 'select concat('',('','''''''','),
','''''''','')'') from ', @tabla)


insert into #tmp001_datos
exec ('select ''insert into ' + @tabla + ' values'' union all ' + @data)
update t set datos = stuff(datos, 1, 1, '') from #tmp001_datos t where item = 2

select datos from #tmp001_datos order by item
return

-- hasta aqui se genera el script de insercion masivo
-- ===========================================================



-- drop table dbo.mpp_empleado2
-- select*into dbo.mpp_empleado2 from dbo.mpp_empleado where 1=2
-- alter table dbo.mpp_empleado2 add cargos varchar(300)
-- alter table dbo.mpp_empleado2 drop column cargos
-- return


-- tratamiento:
-- ============================
-- update t set
-- cod_uregistro = case when not fec_fregistro is null then 'Administrador' end,
-- cod_uactualiza = case when not fec_factualiza is null then 'Administrador' end
-- from dbo.mpp_empleado2 t

-- update t set t.cod_cargo = tt.cod_cargo
-- from dbo.mpp_empleado2 t
-- outer apply(select*from dbo.mpp_cargo tt where tt.txt_descripcion = t.cargos)tt
-- return




set rowcount 0
select*from dbo.mpp_empleado2 order by 1
return
select*from dbo.mpp_empleado order by 1





return
select*into dbo.mpp_profesionocupacion1 from dbo.mpp_profesionocupacion where 1=2

select*into dbo.mpp_motivodecese1 from dbo.mpp_motivodecese where 1=2

select*into dbo.mpp_cargo1 from dbo.mpp_cargo where 1=2

select*into dbo.mpp_incremento1 from dbo.mpp_incremento where 1=2

select*into dbo.mpp_empleado1 from dbo.mpp_empleado where 1=2

