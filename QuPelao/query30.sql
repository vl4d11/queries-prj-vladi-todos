use SCP_CORRELATIVO
-- select text from sys.syscomments where id=object_id('dbo.uspMcoMonitorOrndenCsv','p')

-- CREATE Procedure [dbo].[uspMcoMonitorOrndenCsv]

declare @trama varchar(max) = '2025|08|42441293'
-- As
-- Begin

Declare @pos1 int
Declare @pos2 int
Declare @pos3 int

Declare @txt_anoproceso varchar(4)
Declare @cod_mes varchar(2);
Declare @cod_responsable varchar(10)

Set @pos1 = CharIndex('|',@trama,0)
Set @txt_anoproceso = SUBSTRING(@trama,1,@pos1-1)
Set @pos2 = CharIndex('|',@trama,@pos1+1)
Set @cod_mes = SUBSTRING(@trama,@pos1+1,@pos2-@pos1-1)
Set @pos3 = Len(@trama)+1
Set @cod_responsable = SUBSTRING(@trama,@pos2+1,@pos3-@pos2-1)

--  MONITOR DE ÓRDENES
Select 'Fecha|Número|Motivo|Responsble|Estado¬70|70|450|500|200¬String|String|String|String|String¬' +
IsNull((Select STUFF((Select '¬' + Convert(varchar,A.fec_orden,103) + '|' + A.txt_numeroorden + '|' +
A.txt_motivo + '|' + IsNull(B.txt_nombredestino,'') + '|' + IsNull(C.txt_accion,'')
From mco_cabeceraorden A Cross Apply mco_estado C
Left Join scp_destino B On B.cod_destino = A.cod_responsable
Where A.txt_anoproceso = @txt_anoproceso And A.cod_mes = @cod_mes And A.cod_responsable = @cod_responsable
And C.num_idestado = A.cod_estado
Order By A.fec_orden, Substring(A.txt_numeroorden,3,2)
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- OFICINAS (1)
IsNull((Select STUFF((Select '¬' + cod_filial + '|' + txt_descripcion
From scp_filial Order By txt_descripcion
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- TIPO MONEDA (2)
IsNull((Select STUFF((Select '¬' + cod_tipomoneda + '|' + txt_descripcion
From scp_tipomoneda Order By cod_tipomoneda
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- PROVEEDORES (3)
'Código|Nombre¬10%|22%¬' +
IsNull((Select STUFF((Select '¬' + cod_destino + '|' + Ltrim(txt_nombre)
+ ' ' + Ltrim(txt_apellidopaterno)
+ ' ' + Ltrim(txt_apellidomaterno)
From scp_destino Order By txt_nombre
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- TIPO ASIENTO (4)
IsNull((Select STUFF((Select '¬' + cod_asiento + '|' + txt_descripcion
From scp_tipoasiento FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- PROYECTO (5)
'Código|Proyecto¬10%|22%¬' +
IsNull((Select STUFF((Select '¬' + cod_proyecto + '|' + txt_descproyecto
From scp_proyecto Order By cod_proyecto
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- LUGAR DE GASTO (6)
IsNull((Select STUFF((Select '¬' + cod_contraparte + '|' + txt_desccontraparte
From scp_contraparte
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- COMPROBANTES DE PAGO (7)
IsNull((Select STUFF((Select '¬' + cod_tipocomprobantepago + '|' + txt_descripcion
From scp_comprobantepago
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- COMPRAS (8)
IsNull((Select STUFF((Select '¬' + cod_registrocompraventa + '|' + txt_descripcion
From scp_compraventa Where SUBSTRING(cod_registrocompraventa,1,0) = 'C'
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- AÑOS FISCALES (9)
IsNull((Select STUFF((Select '¬' + txt_anoproceso
From scp_controlperiodo A Order By txt_anoproceso Desc
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- TIPOS DE DOCUMENTOS (10)
IsNull((Select STUFF((Select '¬' + cod_tipodocumento + '|' + txt_descripcion From scp_tipodocumento
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- TIPO CUENTA (11)
IsNull((Select STUFF((Select '¬' + cod_tipocuenta + '|' + txt_tipocuenta From scp_TipoCuenta Where txt_anoproceso = @txt_anoproceso
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- BANCOS (12)
IsNull((Select STUFF((Select '¬' + cod_banco + '|' + txt_descripcion
From scp_banco Order By cod_banco
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- TIPO CUENTAS BANCARIAS (13)
IsNull((Select STUFF((Select '¬' + cod_tipoctabanco + '|' + txt_descripcion From scp_tipoctabanco Order By cod_tipoctabanco
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- TASAS DETRACCIÓN (14)
IsNull((Select STUFF((Select '¬' + cod_detraccion + '|' +
Convert(varchar, num_porcentaje) + ' - ' + txt_descripcion
From scp_detraccion Order By cod_detraccion
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- REGISTRO DE SOLICITANTES (15)
IsNull((Select STUFF((Select '¬' + cod_destino + '|' + txt_nombredestino
From scp_destino Order By txt_nombre
FOR XML PATH('')), 1, 1, '')),'')
