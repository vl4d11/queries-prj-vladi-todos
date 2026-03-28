use SIEC
go
-- exec sys.sp_spaceused 'report.ConsolidadoCostas'
-- exec sys.sp_spaceused 'report.ConsolidadoPagos'
-- exec sys.sp_spaceused 'report.MatrizTransaccional'

-- select schema_name(schema_id) esquema,*from sys.tables order by 1, 2
set rowcount 40


select
N_EXPEDIENTE_COACTIVO, ACTA_DE_CONTROL, PLACA, CODIGO_INFRACCION, COSTO_POR_ACTO_PROCESAL_A
from report.ConsolidadoCostas where estado = 'ACTIVO'

select
MONTO_DE_PAGO, EXPEDIENTE_COACTIVO, ACTA, PLACA, FALTA
from report.ConsolidadoPagos

select
EXPEDIENTE4, ACTA_4, PLACA_4, FALTA_4
from report.MatrizTransaccional
