use SCP_AMINISTIA_MCO
go

-- go
-- CREATE Procedure [dbo].[uspMcoGrabarOrndenCsv]
declare
    @data varchar(max)
= '|2025|7||2025-07-20|01|41445779|SERVICIO DE CAPACITACIÓN|01|20516263033|4|2|OBSERVACIONES|R|fflores^\
||PAGO DE SERVICIO DE CAPACITACIÓN|01|222|44444|2025-07-21|05|si|18||23.00|2|8.28||54.28|007|8|4.34^000032|000FOR|06006|23.00|8.28||54.28|000001~000032|000FRD|06009|15.00|5.00||20.00|000004'

-- as
-- begin

set nocount on
set language english
-- set tran isolation level read uncommitted
-- begin try
-- begin tran

declare @id int, @usuario varchar(15),
@cabecera varchar(max), @detalle varchar(max), @item varchar(max)

create table #tmp001_listas(
   item int identity,
   datos varchar(max)
)
create table #tmp001_key(
   item int,
   accion varchar(6)
)

select cast(null as int) num_id, txt_anoproceso, cod_mes, txt_numeroorden, fec_orden, cod_filial,
cod_responsable, txt_motivo, cod_tipomoneda, cod_destino, cod_tipoasiento,
cod_idcuentabanco, txt_observacion, cod_estado
into #tmp001_param from dbo.mco_cabeceraorden where 1=2

select cast(null as int) num_iddetalle, num_id, txt_concepto, cod_comprobantedepago,
txt_serie, txt_nrodocumento, fec_documento, cod_tipogasto, cast(null as varchar(2)) flg_impuesto,
cast(null as varchar(10)) por_igv, cast(null as varchar(10)) num_tipocambio,
cast(null as varchar(10)) num_costounitario, num_cantidad,
cast(null as varchar(10)) num_igv, cast(null as varchar(10)) num_otroimpto,
cast(null as varchar(10)) num_monto, cast(null as varchar(10)) cod_detraccion,
cast(null as varchar(10)) num_tasadetraccion, cast(null as varchar(10)) num_montodetraccion
into #tmp002_param from dbo.mco_detalleorden where 1=2

select @data = concat('select*from(values(''', replace(@data, '^', '''),('''), '''))t(a)')
insert into #tmp001_listas exec(@data)

select @cabecera = datos from #tmp001_listas where item = 1
select @detalle = nullif(datos,'') from #tmp001_listas where item = 2
select @item = datos from #tmp001_listas where item = 3

select @usuario = reverse(substring(reverse(@cabecera),1, charindex('|', reverse(@cabecera))-1))
select @cabecera = reverse(stuff(reverse(@cabecera),1, charindex('|', reverse(@cabecera)), ''))

exec dbo.general_poblarTablaParam @cabecera
update tt set
tt.cod_mes = right(tt.cod_mes + 100, 2),
tt.txt_numeroorden = t.txt_numeroorden
from(select right(max(t.txt_numeroorden) + 10001, 4) txt_numeroorden
from dbo.mco_cabeceraorden t
where t.txt_anoproceso = year(getdate()))t, #tmp001_param tt

insert into #tmp001_key
select id, accion from(
merge into dbo.mco_cabeceraorden t
using #tmp001_param s
on (t.num_id = s.num_id)
when matched then update set
t.txt_anoproceso = s.txt_anoproceso,
t.cod_mes = s.cod_mes,
t.txt_numeroorden = s.txt_numeroorden,
t.fec_orden = s.fec_orden,
t.cod_filial = s.cod_filial,
t.cod_responsable = s.cod_responsable,
t.txt_motivo = s.txt_motivo,
t.cod_tipomoneda = s.cod_tipomoneda,
t.cod_destino = s.cod_destino,
t.cod_tipoasiento = s.cod_tipoasiento,
t.cod_idcuentabanco = s.cod_idcuentabanco,
t.txt_observacion = s.txt_observacion,
t.cod_estado = s.cod_estado,
t.fec_factualiza = getdate(),
t.cod_uactualiza = @usuario
when not matched then
insert(txt_anoproceso, cod_mes, txt_numeroorden, fec_orden, cod_filial, cod_responsable,
txt_motivo, cod_tipomoneda, cod_destino, cod_tipoasiento, cod_idcuentabanco, txt_observacion,
cod_estado, cod_uregistro, cod_uactualiza, fec_fregistro, fec_factualiza)
values(s.txt_anoproceso, s.cod_mes, s.txt_numeroorden, s.fec_orden, s.cod_filial, s.cod_responsable,
s.txt_motivo, s.cod_tipomoneda, s.cod_destino, s.cod_tipoasiento, s.cod_idcuentabanco, s.txt_observacion,
s.cod_estado, @usuario, @usuario, getdate(), getdate())
output $action, inserted.num_id)t(accion,id)

select @id = item from #tmp001_key

if exists(select*from(values(@detalle))t(dato) where not dato is null)
exec dbo.general_poblarTablaParam2 @detalle

update t set flg_impuesto = substring(flg_impuesto,1,1) from #tmp002_param t

insert into #tmp001_key
select id, accion from(
merge into dbo.mco_detalleorden t
using #tmp002_param s
on(t.num_iddetalle = s.num_iddetalle and t.num_id = s.num_id)
when matched then update set
t.txt_concepto = s.txt_concepto,
t.cod_comprobantedepago = s.cod_comprobantedepago,
t.txt_serie = s.txt_serie,
t.txt_nrodocumento = s.txt_nrodocumento,
t.fec_documento = s.fec_documento,
t.cod_tipogasto = s.cod_tipogasto,
t.flg_impuesto = s.flg_impuesto,
t.por_igv = nullif(s.por_igv, ''),
t.num_tipocambio = nullif(s.num_tipocambio,''),
t.num_costounitario = nullif(s.num_costounitario,''),
t.num_cantidad = s.num_cantidad,
t.num_igv = nullif(s.num_igv,''),
t.num_otroimpto = nullif(s.num_otroimpto,''),
t.num_monto = nullif(s.num_monto,''),
t.cod_detraccion = nullif(s.cod_detraccion,''),
t.num_tasadetraccion = nullif(s.num_tasadetraccion,''),
t.num_montodetraccion = nullif(s.num_montodetraccion,''),
t.txt_item = @item,
t.fec_factualiza = getdate(),
t.cod_uactualiza = @usuario
when not matched then
insert(num_id, txt_concepto, cod_comprobantedepago, txt_serie,
txt_nrodocumento, fec_documento, cod_tipogasto, flg_impuesto, por_igv, num_tipocambio,
num_costounitario, num_cantidad, num_igv, num_otroimpto, num_monto,
cod_detraccion, num_tasadetraccion, num_montodetraccion, txt_item,
cod_uregistro, cod_uactualiza)
values(@id, s.txt_concepto, s.cod_comprobantedepago, s.txt_serie,
s.txt_nrodocumento, s.fec_documento, s.cod_tipogasto, s.flg_impuesto, nullif(s.por_igv,''),
nullif(s.num_tipocambio,''),
nullif(s.num_costounitario,''), s.num_cantidad, nullif(s.num_igv,''),
nullif(s.num_otroimpto,''),  nullif(s.num_monto,''),
nullif(s.cod_detraccion,''), nullif(s.num_tasadetraccion,''),
nullif(s.num_montodetraccion,''), @item,
@usuario, @usuario)
output $action, inserted.num_id)t(accion,id)

select distinct item from #tmp001_key

Select p.txt_numeroorden + '~' +
	'Fecha|Número|Motivo|Responsble|Estado¬70|70|450|200|100¬String|String|String|String|String¬' +
	IsNull((Select STUFF((Select '¬' + Convert(varchar, A.fec_orden,103) + '|' + A.txt_numeroorden + '|' +
	A.txt_motivo + '|' + IsNull(B.txt_nombredestino,'') + '|' + 'Pendiente'
	From mco_cabeceraorden A
	Left Outer Join scp_destino B On B.cod_destino = A.cod_responsable
	Where A.txt_anoproceso = P.txt_anoproceso And A.cod_mes = P.cod_mes And A.cod_responsable = P.cod_responsable
	Order By A.fec_orden, A.cod_responsable
	FOR XML PATH('')), 1, 1, '')),'')
from #tmp001_param p

--    commit;
--    select 'OK'
-- end try
-- begin catch
--    rollback;
--    select 'ERROR:' + error_message()
-- end catch
-- end
