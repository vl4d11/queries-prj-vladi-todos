use SCP_DOCUMENTO; select @@version
-- select*from sys.procedures order by 1
-- select text from sys.syscomments where id=object_id('dbo.uspMppTablasCalculoPlanillaListarCsv','p')

-- CREATE Procedure [dbo].[uspMppTablasCalculoPlanillaListarCsv]
Declare
	@Data varchar(max)
-- As

Declare @pos1 int
Declare @pos2 int
Declare @pos3 int
Declare @cod_mes varchar(2)
Declare @txt_periodo varchar(4)
Declare @cod_concepto varchar(4)
Declare @cod_mesretencion varchar(2)
Declare @cod_mesanterior varchar(2)

Set @pos1 = CharIndex('|',@Data,0)
Set @cod_mes = SUBSTRING(@Data,1,@pos1-1)
Set @pos2 = CharIndex('|',@Data,@pos1+1)
Set @txt_periodo = SUBSTRING(@Data,@pos1+1,@pos2-@pos1-1)
Set @pos3 = Len(@Data)+1
Set @cod_concepto = SUBSTRING(@Data,@pos2+1,@pos3-@pos2-1)

Set @cod_mesretencion = (Select Top 1 Right('00'+convert(varchar,num_mesesretencion),2) From mpp_mesquinta where cod_mes = @cod_mes)
set @cod_mesanterior = right('00'+convert(varchar,convert(int,@cod_mes)-1),2)

-- _DatosEmpleado
Select 'cod_trabajador|num_serie|tip_trabajador|txt_paterno|txt_materno|txt_nombre|txt_direccion|cod_via|cod_zona|cod_nacionalidad|cod_tipodocu|num_docidentidad|ind_genero|fec_nacimiento|cod_cargo|cod_niveleducativo|cod_profesion|num_telefono|cod_escala|fec_ingreso|num_dias|num_horas|tip_pago|fec_cese|fec_reingreso|cod_regimenpension|cod_afp|num_cuspp|fec_afiliacionspp|tip_comision|txt_autogenerado|flg_afectoeps|cod_bancoahorro|num_cuentaahorro|cod_bancocts|num_cuentacts|tip_monedacts|flg_vacacion|est_licencia|est_retiro|txt_motivoretiro|txt_motivoreingreso|cod_oficina|cod_referencia|txt_observacion|cod_establecimiento|cod_departamento|cod_provincia|cod_distrito|cod_cese|cod_suspension|fec_fregistro|cod_uregistro|fec_factualiza|cod_uactualiza¬100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100¬String|String|String|String|String|String|String|String|String|String|String|String|String|DateTime|String|String|String|String|String|DateTime|Decimal|Decimal|Decimal|DateTime|DateTime|String|String|String|DateTime|String|String|String|String|String|String|String|String|String|String|String|String|String|String|String|String|String|String|String|String|String|String|DateTime|String|DateTime|String¬' + 
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + num_serie + '|' + tip_trabajador + '|' + txt_paterno + '|' + txt_materno + '|' + txt_nombre + '|' + txt_direccion + '|' + cod_via + '|' + cod_zona + '|' + cod_nacionalidad + '|' + cod_tipodocu + '|' + num_docidentidad + '|' + ind_genero + '|' + Convert(varchar, fec_nacimiento, 103) + '|' + cod_cargo + '|' + cod_niveleducativo + '|' + cod_profesion + '|' + num_telefono + '|' + cod_escala + '|' + Convert(varchar, fec_ingreso, 103) + '|' + Convert(varchar, num_dias) + '|' + Convert(varchar, num_horas) + '|' + Convert(varchar, tip_pago) + '|' + Convert(varchar, fec_cese, 103) + '|' + Convert(varchar, fec_reingreso, 103) + '|' + cod_regimenpension + '|' + cod_afp + '|' + num_cuspp + '|' + Convert(varchar, fec_afiliacionspp, 103) + '|' + tip_comision + '|' + txt_autogenerado + '|' + flg_afectoeps + '|' + cod_bancoahorro + '|' + num_cuentaahorro + '|' + cod_bancocts + '|' + num_cuentacts + '|' + tip_monedacts + '|' + flg_vacacion + '|' + est_licencia + '|' + est_retiro + '|' + txt_motivoretiro + '|' + txt_motivoreingreso + '|' + cod_oficina + '|' + cod_referencia + '|' + txt_observacion + '|' + cod_establecimiento + '|' + cod_departamento + '|' + cod_provincia + '|' + cod_distrito + '|' + cod_cese + '|' + cod_suspension + '|' + Convert(varchar, fec_fregistro, 103) + '|' + cod_uregistro + '|' + Convert(varchar, fec_factualiza, 103) + '|' + cod_uactualiza From mpp_empleado FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _IngresosEmpleado
'cod_trabajador|cod_conceptompp|txt_descripcion|flg_ordinario|flg_afectocts|flg_spp|flg_snp|flg_quinta|' +
'flg_quintaneta|flg_essalud|flg_otrarenta|tip_moneda|num_monto|num_tcambio¬' +
'100|100|100|100|100|100|100|100|100|100|100|100|100|100¬' +
'String|String|String|String|String|
String|String|String|String|String|String|String|Decimal|Decimal¬' + 
IsNull((Select STUFF((Select '¬' + A.cod_trabajador + '|' + A.cod_conceptompp + '|' + 
IsNull(B.txt_descripcion,'') + '|' + 
IsNull(B.flg_ordinario,'') + '|' + 
IsNull(B.flg_afectocts,'') + '|' + 
IsNull(B.flg_spp,'') + '|' + 
IsNull(B.flg_snp,'') + '|' + 
IsNull(B.flg_quinta,'') + '|' +
IsNull(B.flg_quintaneta,'') + '|' + 
IsNull(B.flg_essalud,'') + '|' + 
IsNull(B.flg_otrarenta,'') + '|' + 
A.tip_moneda + '|' +
Convert(varchar, A.num_monto) + '|' + Convert(varchar, A.num_tcambio)
From mpp_incremento A
Left Outer Join mpp_conceptompp B On B.cod_conceptompp = A.cod_conceptompp
Order By A.cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _Parametros AFP
'cod_afp|txt_descripcion|num_comisionvar|num_comisionmixta|num_seguroinv|num_aporteobl|num_topeprima|cod_cuencont¬' +
'100|100|100|100|100|100|100|100¬' +
'String|String|Decimal|Decimal|Decimal|Decimal|Decimal|String¬' + 
IsNull((Select STUFF((Select '¬' + cod_afp + '|' + txt_descripcion + '|' + Convert(varchar, num_comisionvar) + '|' + 
Convert(varchar, num_comisionmixta) + '|' + Convert(varchar, num_seguroinv) + '|' + Convert(varchar, num_aporteobl) + '|' + 
Convert(varchar, num_topeprima) + '|' + cod_cuencont  
From mpp_afp FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
---- _MonitorConceptos
--'cod_conceptompp|txt_descripcion|tip_concepto|flg_permanente|flg_ordinario|flg_spp|flg_snp|flg_quinta|flg_essalud|' +
--'flg_modelogeneral|cod_conceptopdt|flg_afectocts|flg_quintaneta|flg_otrarenta¬' +
--'100|100|100|100|100|100|100|100|100|100|100|100|100|100¬' +
--'String|String|String|String|String|String|String|String|String|String|String|String|String|String¬' +
--IsNull((Select STUFF((Select '¬' + cod_conceptompp + '|' + txt_descripcion + '|' + 
--Case tip_concepto
--When 'I' Then 'Ingreso'
--When 'T' Then 'Tributo'
--When 'D' Then 'Descuento'
--When 'A' Then 'Aporte'
--Else 'Unknown'
--End + '|' +
--flg_permanente + '|' +
--Case flg_ordinario When 'S' Then 'Sí' Else 'No' End + '|' +
--Case flg_spp When 'S' Then 'Sí' Else 'No' End + '|' +
--Case flg_snp When 'S' Then 'Sí' Else 'No' End + '|' +
--Case flg_quinta When 'S' Then 'Sí' Else 'No' End + '|' +
--Case flg_essalud When 'S' Then 'Sí' Else 'No' End + '|' +
--Case flg_modelogeneral When 'S' Then 'Sí' Else 'No' End + '|' +
--cod_conceptopdt + '|' +
--flg_afectocts + '|' +
--flg_quintaneta + '|' +
--flg_otrarenta
--From mpp_conceptompp FOR XML PATH('')), 1, 1, '')),'')
--+ '~' +
---- _ParametrosCalculoQuinta
--'cod_mes|txt_descripcion|num_divmeses|num_mesesretencion|txt_formula¬100|100|100|100|100¬String|String|Decimal|Decimal|String¬' + 
--IsNull((Select STUFF((Select '¬' + cod_mes + '|' + txt_descripcion + '|' + 
--Convert(varchar,num_divmeses) + '|' + Convert(varchar,num_mesesretencion) + '|' + txt_formula 
--From mpp_mesquinta FOR XML PATH('')), 1, 1, '')),'')
--+ '~' +
-- _RegistroVacacion
'cod_trabajador|fec_programada|fec_retorno|num_dias|num_diasutiles|num_remunera¬' + 
'100|100|100|100|100|100¬' +
'String|DateTime|DateTime|Int32|Int32|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,fec_programada,103) + '|' + 
Convert(varchar,fec_retorno,103) + '|' + Convert(varchar,num_dias) + '| ' +
Convert(varchar,num_diasutiles) + '|' + Convert(varchar,num_remunera)
From mpp_vacacion Where num_periodo = @txt_periodo 
And Substring(Convert(varchar(10),fec_programada,112),5,2) = @cod_mes
And est_vacacion = 'A'
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroHE
'cod_trabajador|num_horas|num_hotal¬' + 
'100|100|100¬' +
'String|Decimal|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,Sum(num_horas)) + '|' + 
Convert(varchar,Sum(num_montop1 + num_montop2))
From mpp_horaextra Where txt_anoproceso = @txt_periodo And txt_mesproceso = @cod_mes
Group By cod_trabajador Order By cod_trabajador
FOR XML PATH('')), 1,
 1, '')),'')
+ '~' +
-- _RegistroTardanza
'cod_trabajador|num_monto¬' + 
'100|100¬' +
'String|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,Sum(num_monto))
From mpp_Tardanza Where txt_anoproceso = @txt_periodo And txt_mesproceso = @cod_mes
Group By cod_trabajador Order By cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroPrestamo
'cod_trabajador|fec_prestamo|tip_moneda|num_totalprestamo|num_cuotas|num_saldo|num_mes01|num_mes02|num_mes03|num_mes04' +
'|num_mes05|num_mes06|num_mes07|num_mes08|num_mes09|num_mes10|num_mes11|num_mes12¬' +
'100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100|100¬' +
'String|String|DateTime|String|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|' +
'Decimal|Decimal|Decimal|Decimal¬' + 
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar, fec_prestamo, 103) + '|' + 
tip_moneda + '|' + Convert(varchar, num_totalprestamo) + '|' + Convert(varchar, num_cuotas) + '|' + 
Convert(varchar, num_saldo) + '|' + Convert(varchar, num_mes01) + '|' + Convert(varchar, num_mes02) + '|' + 
Convert(varchar, num_mes03) + '|' + Convert(varchar, num_mes04) + '|' + Convert(varchar, num_mes05) + '|' + 
Convert(varchar, num_mes06) + '|' + Convert(varchar, num_mes07) + '|' + Convert(varchar, num_mes08) + '|' + 
Convert(varchar, num_mes09) + '|' + Convert(varchar, num_mes10) + '|' + Convert(varchar, num_mes11) + '|' + 
Convert(varchar, num_mes12)
From mpp_prestamo Where num_periodo = @txt_periodo And est_pago = 'A'
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroOtroDescuento
'cod_trabajador|cod_conceptompp|txt_descripcion|num_monto|num_mesinicio|est_pago|flg_quincena|flg_findemes¬' + 
'100|100|100|100|100|100|100|100¬' +
'String|String|String|Decimal|Decimal|String|String|String¬' +
IsNull((Select STUFF((Select '¬' + A.cod_trabajador + '|' + A.cod_conceptompp + '|' + B.txt_descripcion + '|' +
Convert(varchar,Sum(Case When A.tip_moneda = 'N' Then (A.num_monto*1) Else Round((A.num_monto * A.num_tcambio),2)End)) + '|' +
A.num_mesinicio + '|' + A.est_pago + '|' + B.flg_quincena + '|' + B.flg_findemes
From mpp_descuento A, mpp_conceptompp B
Where (A.num_mesinicio = @cod_mes Or A.num_mesinicio = '00')
And B.cod_conceptompp = A.cod_conceptompp 
And A.num_periodo = @txt_periodo
And A.est_pago = 'A' 
Group By A.cod_trabajador, A.cod_conceptompp, B.txt_descripcion, 
A.num_mesinicio, A.est_pago, B.flg_quincena, B.flg_findemes
Order By A.cod_trabajador, A.cod_conceptompp
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroSubsidio
'cod_trabajador|num_monto|num_diassubsidio|num_diautil|cod_conceptompp|txt_descripcion|flg_ordinario|flg_afectocts|flg_spp|flg_quinta|flg_quintaneta|flg_essalud¬' +
'100|100|100|100|100|100|100|100|100|100|100|100¬' +
'String|Decimal|Int32|Int32|String|String|String|String|String|String|String|String¬' +
IsNull((Select STUFF((Select '¬' + A.cod_trabajador + '|' + Convert(varchar,Sum(A.num_montosub)) + '|' +
Convert(varchar,Sum (A.num_diassub)) + '|' + Convert(varchar,A.num_diautil) + '|' +
C.cod_conceptompp + '|' + C.txt_descripcion + '|' + C.flg_ordinario + '|' + C.flg_afectocts + '|' +
C.flg_spp + '|' + C.flg_snp + '|' + C.flg_quinta + '|' + C.flg_quintaneta + '|' + C.flg_essalud 
From mpp_diasdelicencia A
Left Outer Join mpp_licencia B On B.num_periodo = A.num_periodo
And B.cod_trabajador = A.cod_trabajador
And B.fec_inicio = A.fec_inicio
And B.fec_termino = A.fec_termino
Left Outer Join mpp_conceptompp C On C.cod_conceptompp = B.cod_concepto
Where A.num_periodo = @txt_periodo
--And Ltrim(A.cod_trabajador) = Ltrim(@codigo)
And A.num_mes = @cod_mes
Group By A.num_periodo, A.cod_trabajador, A.num_diautil,
C.cod_conceptompp, C.txt_descripcion, C.flg_ordinario, C.flg_afectocts, C.flg_spp, C.flg_snp, 
C.flg_quinta, C.flg_quintaneta, C.flg_essalud
Order By A.cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +

-- _RegistroLicencia
'cod_trabajador|num_totdias|num_valordia|num_totalpermiso|tip_permiso¬' +
'100|100|100|100|100¬' +
'String|Decimal|Decimal|Decimal|String¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,num_totdias) + '|' +
Convert(varchar,num_valordia) + '|' + Convert(varchar,num_totalpermiso) + '|' + tip_permiso
From mpp_permiso 
Where num_periodo = @txt_periodo
And cod_mes = @cod_mes
Order By cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroFalta
'cod_trabajador|num_monto¬100|100¬String|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,Sum(A.num_monto))
From  mpp_falta A
Where A.num_periodo = @txt_periodo
And A.num_mes = @cod_mes
And A.est_pago = 'A'
Group By A.cod_trabajador
Order By A.cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroGratificacionPagada
'cod_trabajador|num_monto¬100|100¬String|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,num_0108)
From mpp_quincena
Where txt_anoproceso = @txt_periodo
And txt_mesproceso = @cod_mes
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroQuincenaPagada
'cod_trabajador|num_neto¬100|100¬String|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,num_neto)
From mpp_quincena
Where txt_anoproceso = @txt_periodo
And txt_mesproceso = @cod_mes
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroOtraRenta
'cod_trabajador|num_brutoanterior|num_quintaanterior¬100|100|100¬String|Decimal|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,num_brutoanterior) + '|' +
Convert(varchar,num_quintaanterior)
From mpp_otrarenta
Where txt_anoproceso = @txt_periodo
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroQuintaAnterior
'cod_trabajador|num_0301¬100|100¬String|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + Convert(varchar,Sum(num_0301))
From mpp_findemes Where txt_anoproceso = @txt_periodo And txt_mesproceso <= @cod_mesretencion
Group By cod_trabajador Order By cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _RegistroPlanillaIndividual
'cod_trabajador¬100¬String¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador 
From mpp_findemes
Where txt_anoproceso = @txt_periodo
And txt_mesproceso = @cod_mes
And est_individual = '1'
Order By cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _Sueldos Anteriores (Gratificación)
'cod_trabajador|txt_diaproceso|txt_mesproceso|txt_anoproceso|' + 
'num_0101|num_0102|num_0103|num_0104|num_0105|num_0106|num_0107|num_0108|num_0109|num_0110|' +
'num_0111|num_0112|num_0113|num_0114|num_0115|num_0116|num_0117|num_0118|num_0119|num_0120|' +
'num_0121|num_0122|num_0123|num_0124|num_0125|num_0126|num_0127|num_0128|num_0129|num_0130¬' +
'100|100|100|100|' +
'100|100|100|100|100|100|100|100|100|100|' +
'100|100|100|100|100|100|100|100|100|100|' +
'100|100|100|100|100|100|100|100|100|100¬' +
'String|String|String|String|' +
'Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|' + 
'Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|' + 
'Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal¬' +
IsNull((Select STUFF((Select '¬' + cod_trabajador + '|' + txt_diaproceso + '|' + txt_mesproceso + '|' + txt_anoproceso + '|' +
Convert(varchar,num_0101) + '|' + Convert(varchar,num_0102) + '|' + Convert(varchar,num_0103) + '|' +
Convert(varchar,num_0104) + '|' + Convert(varchar,num_0105) + '|' + Convert(varchar,num_0106) + '|' +
Convert(varchar,num_0107) + '|' + Convert(varchar,num_0108) + '|' + Convert(varchar,num_0109) + '|' +
Convert(varchar,num_0110) + '|' + Convert(varchar,num_0111) + '|' + Convert(varchar,num_0112) + '|' +
Convert(varchar,num_0113) + '|' + Convert(varchar,num_0114) + '|' + Convert(varchar,num_0115) + '|' +
Convert(varchar,num_0116) 
+ '|' + Convert(varchar,num_0117) + '|' + Convert(varchar,num_0118) + '|' +
Convert(varchar,num_0119) + '|' + Convert(varchar,num_0120) + '|' + Convert(varchar,num_0121) + '|' +
Convert(varchar,num_0122) + '|' + Convert(varchar,num_0123) + '|' + Convert(varchar,num_0124) + '|' + 
Convert(varchar,num_0125) + '|' + Convert(varchar,num_0126) + '|' + Convert(varchar,num_0127) + '|' + 
Convert(varchar,num_0128) + '|' + Convert(varchar,num_0129) + '|' + Convert(varchar,num_0130)
From mpp_findemes
Where txt_mesproceso = @cod_mesanterior And txt_anoproceso = @txt_periodo
Order By cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
+ '~' +
-- _Brutos Anteriores
'cod_trabajador|' + 
'num_0101|num_0102|num_0103|num_0104|num_0105|num_0106|num_0107|num_0108|num_0109|num_0110|' +
'num_0111|num_0112|num_0113|num_0114|num_0115|num_0116|num_0117|num_0118|num_0119|num_0120|' +
'num_0121|num_0122|num_0123|num_0124|num_0125|num_0126|num_0127|num_0128|num_0129|num_0130¬' +
'100|' +
'100|100|100|100|100|100|100|100|100|100|' +
'100|100|100|100|100|100|100|100|100|100|' +
'100|100|100|100|100|100|100|100|100|100¬' +
'String|' +
'Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|' + 
'Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|' + 
'Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal|Decimal¬' +
IsNull((Select STUFF((Select '¬' + A.cod_trabajador + '|' + 
Convert(varchar,Sum(A.num_0101)) + '|' + Convert(varchar,Sum(A.num_0102)) + '|' + Convert(varchar,Sum(A.num_0103)) + '|' +
Convert(varchar,Sum(A.num_0104)) + '|' + Convert(varchar,Sum(A.num_0105)) + '|' + Convert(varchar,Sum(A.num_0106)) + '|' +
Convert(varchar,Sum(A.num_0107)) + '|' + 
Convert(varchar,Sum(A.num_0108+Isnull(B.num_0108,0))) + '|' + 
Convert(varchar,Sum(A.num_0109)) + '|' +
Convert(varchar,Sum(A.num_0110)) + '|' + Convert(varchar,Sum(A.num_0111)) + '|' + Convert(varchar,Sum(A.num_0112)) + '|' +
Convert(varchar,Sum(A.num_0113)) + '|' + 
Convert(varchar,Sum(A.num_0114+Isnull(B.num_0114,0))) + '|' + 
Convert(varchar,Sum(A.num_0115)) + '|' +
Convert(varchar,Sum(A.num_0116)) + '|' + Convert(varchar,Sum(A.num_0117)) + '|' + Convert(varchar,Sum(A.num_0118)) + '|' +
Convert(varchar,Sum(A.num_0119)) + '|' + Convert(varchar,Sum(A.num_0120)) + '|' + Convert(varchar,Sum(A.num_0121)) + '|' +
Convert(varchar,Sum(A.num_0122)) + '|' + Convert(varchar,Sum(A.num_0123)) + '|' + Convert(varchar,Sum(A.num_0124)) + '|' + 
Convert(varchar,Sum(A.num_0125)) + '|' + Convert(varchar,Sum(A.num_0126)) + '|' + Convert(varchar,Sum(A.num_0127)) + '|' + 
Convert(varchar,Sum(A.num_0128)) + '|' + Convert(varchar,Sum(A.num_0129)) + '|' + Convert(varchar,Sum(A.num_0130))
From mpp_findemes A
Left Outer Join mpp_quincena B On Ltrim(B.cod_trabajador) = Ltrim(A.cod_trabajador)
and B.txt_mesproceso = A.txt_mesproceso
and B.txt_anoproceso = A.txt_anoproceso
Where A.txt_mesproceso < @cod_mes And A.txt_anoproceso = @txt_periodo
Group By A.cod_trabajador
Order By A.cod_trabajador
FOR XML PATH('')), 1, 1, '')),'')
