use SCP_AMINISTIA;select @@version

-- truncate table mco_cabeceraorden
-- truncate table mco_detalleorden


declare @data varchar(max)
= '2|2025|3|05252|2025-03-27|01|41445779|SERVICIO DE CAPACITACIÓN|01|20516263033|4|2|OBSERVACIONES|A|ADMIN'
+ '^'
+ '2|2|1|PAGO 01-01|01|001|25252525|2025-02-04|02|S|18.00|0.00|23.00|1|5.00|2.00|30.00|8.00|1.50|000032_0000DI_06009_10.00_1.80_0.90_0.70_13.40_01_C1~000033_0000DII_06070_12.00_2.80_1.10_1.00_16.90_01_C2'
+ '^'
+ '3|2|0|PAGO DE SERVICIO 04-02|01|001|25252525|2025-02-04|02|S|18.00|0.00|23.00|1|5.00|2.00|35.00|8.00|1.50|000032_0000DI_06009_10.00_1.80_0.90_0.70_13.40_01_C1~000033_0000DII_06070_12.00_2.80_1.10_1.00_16.90_01_C2'



set nocount on
set language english

select cast(null as int) num_id, txt_anoproceso, cod_mes, txt_numeroorden, fec_orden, cod_filial, 
cod_responsable, txt_motivo, cod_tipomoneda, cod_destino, cod_tipoasiento, 
cod_idcuentabanco,txt_observacion, cod_estado,
cast(null as varchar(15)) txt_usuario
into #mco_cabeceraorden from dbo.mco_cabeceraorden where 1=2

select cast(null as int) num_iddetalle, num_id, num_nroitem, txt_concepto, cod_comprobantedepago, 
txt_serie, txt_nrodocumento, fec_documento, cod_tipogasto, flg_impuesto, por_igv,
num_tipocambio, num_costounitario, num_cantidad, num_igv, num_otroimpto,
num_monto, num_tasadetraccion, num_montodetraccion, txt_item
into #mco_detalleorden from dbo.mco_detalleorden where 1=2

create table #tmp001_key(
    item int,
    accion varchar(6)
)
create table #tmp001_listas( 
    item int identity,
    dato varchar(max)
)
select @data = concat('select*from(values(''', replace(@data, '^', '''),('''), '''))t(a)')
insert into #tmp001_listas exec(@data)

select @data = dato from #tmp001_listas where item = 1
exec dbo.usp_genera_data 0, '#mco_cabeceraorden', @data

select @data = stuff((select '^', dato from #tmp001_listas where item > 1 order by item
for xml path, type).value('.','varchar(max)'), 1,1,'')
exec dbo.usp_genera_data 0, '#mco_detalleorden', @data


-- NOTA: MERGE CABECERA
-- ====================
insert into #tmp001_key
select id, accion from(
merge into dbo.mco_cabeceraorden t
using #mco_cabeceraorden s
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
t.fec_factualiza = dateadd(hh, -5, getutcdate()),
t.cod_uactualiza = s.txt_usuario
when not matched then 
insert(txt_anoproceso, cod_mes, txt_numeroorden, fec_orden, cod_filial, cod_responsable, txt_motivo, cod_tipomoneda, cod_destino, cod_tipoasiento, 
cod_idcuentabanco, txt_observacion, cod_estado, cod_uregistro, cod_uactualiza)
values(s.txt_anoproceso, s.cod_mes, s.txt_numeroorden, s.fec_orden, s.cod_filial, s.cod_responsable, s.txt_motivo, s.cod_tipomoneda, s.cod_destino, s.cod_tipoasiento, 
s.cod_idcuentabanco, s.txt_observacion, s.cod_estado, s.txt_usuario, s.txt_usuario)
output $action, inserted.num_id)t(accion,id);

select item num_id, txt_usuario into #tmp001_aux from #mco_cabeceraorden, #tmp001_key

-- NOTA: MERGE DETALLE
-- ====================
insert into #tmp001_key
select id, accion from(
merge into dbo.mco_detalleorden t
using(
select isnull(tt.num_iddetalle, t.num_iddetalle) num_iddetalle, a.num_id, t.num_nroitem, t.txt_concepto, 
t.cod_comprobantedepago, t.txt_serie, t.txt_nrodocumento, t.fec_documento, 
t.cod_tipogasto, t.flg_impuesto, t.por_igv, t.num_tipocambio, t.num_costounitario, t.num_cantidad, t.num_igv,
t.num_otroimpto, t.num_monto, t.num_tasadetraccion, t.num_montodetraccion, t.txt_item, a.txt_usuario
from(select row_number()over(partition by (case when num_iddetalle != 0 then 1 end) order by num_iddetalle) idem,*
from #mco_detalleorden)t 
cross apply dbo.udf_general_generaMasivoDetalleIdentity(case t.num_iddetalle when 0 then t.idem end) tt
cross apply #tmp001_aux a
)s
on(t.num_iddetalle = s.num_iddetalle and t.num_id = s.num_id)
when matched and s.num_nroitem = 0 then delete
when matched then update set
t.num_nroitem = s.num_nroitem,          
t.txt_concepto = s.txt_concepto,         
t.cod_comprobantedepago = s.cod_comprobantedepago,
t.txt_serie = s.txt_serie,            
t.txt_nrodocumento = s.txt_nrodocumento,     
t.fec_documento = s.fec_documento,        
t.cod_tipogasto = s.cod_tipogasto,        
t.flg_impuesto = s.flg_impuesto, 
t.por_igv = s.por_igv,        
t.num_tipocambio = s.num_tipocambio,       
t.num_costounitario = s.num_costounitario,    
t.num_cantidad = s.num_cantidad,  
t.num_igv = s.num_igv,
t.num_otroimpto = s.num_otroimpto,
t.num_monto = s.num_monto,
t.num_tasadetraccion = s.num_tasadetraccion,
t.num_montodetraccion = s.num_montodetraccion,
t.txt_item = s.txt_item,
t.fec_factualiza = dateadd(hh, -5, getutcdate()),       
t.cod_uactualiza = s.txt_usuario
when not matched then
insert(num_iddetalle, num_id, num_nroitem, txt_concepto, cod_comprobantedepago, txt_serie, txt_nrodocumento, fec_documento, 
cod_tipogasto, flg_impuesto, por_igv, num_tipocambio, num_costounitario, num_cantidad, num_igv, num_otroimpto,
num_monto, num_tasadetraccion, num_montodetraccion, txt_item, cod_uregistro, cod_uactualiza)
values(s.num_iddetalle, s.num_id, s.num_nroitem, s.txt_concepto, s.cod_comprobantedepago, s.txt_serie, s.txt_nrodocumento, 
s.fec_documento, s.cod_tipogasto, s.flg_impuesto, s.por_igv, s.num_tipocambio, s.num_costounitario,
s.num_cantidad, s.num_igv, s.num_otroimpto, s.num_monto, s.num_tasadetraccion, s.num_montodetraccion, s.txt_item, s.txt_usuario, s.txt_usuario)
output $action, inserted.num_id)t(accion,id);




if exists(select 1 from #tmp001_key where accion ='INSERT')
    update t set num_nroitem = num_nroitem2
    from(select row_number()over(order by t.num_iddetalle) num_nroitem2, t.*
    from dbo.mco_detalleorden t, (select distinct item from #tmp001_key) tt 
    where t.num_id = tt.item)t
else if exists(select 1 from #tmp001_key where accion ='DELETE')
    update t set num_nroitem = num_nroitem2
    from(select row_number()over(order by t.num_iddetalle) num_nroitem2, t.*
    from dbo.mco_detalleorden t, #mco_detalleorden tt 
    where t.num_id = tt.num_id)t




select*from mco_cabeceraorden
select*from mco_detalleorden




-- truncate table mco_cabeceraorden
-- truncate table mco_detalleorden
-- return
