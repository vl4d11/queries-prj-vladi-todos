use SCP_AMINISTIA02
go

declare @data varchar(max) =
'2026|AVD024|02|01|02|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|02|01|02|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|03|01|03|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|03|01|03|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|04|01|04|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|04|01|04|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|05|01|05|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|05|01|05|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|06|01|06|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|06|01|06|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|07|01|07|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|07|01|07|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|08|01|08|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|08|01|08|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|09|01|09|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|09|01|09|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|10|01|10|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|10|01|10|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|11|01|11|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|11|01|11|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|12|01|12|000005|0000UE| | |01105|000000|50.00|0.00|Juan Carlos¬\
2026|AVD024|12|01|12|000008|000FOR|01215| |01203|000000|50.00|0.00|Juan Carlos'

set nocount on
begin try

select num_periodo,cod_trabajador,num_mes,tip_partida,cod_area,
cod_proyecto,cod_financiera,
cast(null as varchar(14)) cod_ctaproyecto,cod_ctaactividad,
cod_ctaespecial,cod_contraparte,num_porcentaje,num_monto,
cast(null as varchar(100)) cod_uregistro
into #mpp_proyectosxempleado
from dbo.mpp_proyectosxempleado where 1=2

select @data = dato from dbo.udf_splice(@data, default, '¬')
-- insert into #mpp_proyectosxempleado

select @data = replace(@data, 'select*', 'select a1,a2,a3 ')
exec(@data)
-- update t set cod_ctaproyecto = case when cod_ctaproyecto is null then '' else cod_ctaproyecto end
-- from #mpp_proyectosxempleado t
return

insert into dbo.mpp_proyectosxempleado(
num_periodo,cod_trabajador,num_mes,tip_partida,cod_area,
cod_proyecto,cod_financiera,cod_ctaproyecto,cod_ctaactividad,
cod_ctaespecial,cod_contraparte,num_porcentaje,num_monto,
cod_uregistro, fec_fregistro, fec_factualiza, cod_uactualiza
)
select*, dateadd(hh, -5, getutcdate()),
dateadd(hh, -5, getutcdate()), cod_uregistro
from #mpp_proyectosxempleado

select 'ok'
end try
begin catch
    select concat('error:', error_message())
end catch
