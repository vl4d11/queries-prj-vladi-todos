use SCP_SAIPE; select @@version

declare
@txt_anoproceso varchar(4) = '2024',
@cod_mes varchar(2) = '04'


select
convert(varchar(64), hashbytes('sha2_256', concat(t.txt_anoproceso, t.cod_filial, t.cod_mes, t.cod_origen, t.cod_comprobante)), 2) item,
t.cod_ctacontable into #tmp001_params
from dbo.scp_comprobantedetalle t
where isnull(t.cod_ctacontable, '') != '' and 
t.txt_anoproceso = @txt_anoproceso and t.cod_mes = @cod_mes


select item into #tmp002_params
from(select distinct tt.item, (select '|', t.cod_ctacontable from #tmp001_params t
where t.item = tt.item
order by t.cod_ctacontable
for xml path, type).value('.','varchar(max)') dato
from #tmp001_params tt)t
where patindex('%469201%759301%', dato) > 0


update t set  t.flg_im = 5
from dbo.scp_comprobantedetalle t, #tmp002_params where 
convert(varchar(64), hashbytes('sha2_256', concat(t.txt_anoproceso, t.cod_filial, t.cod_mes, t.cod_origen, t.cod_comprobante)), 2) = item

update t set  t.flg_im = 5
from dbo.scp_comprobantecabecera t, #tmp002_params where 
convert(varchar(64), hashbytes('sha2_256', concat(t.txt_anoproceso, t.cod_filial, t.cod_mes, t.cod_origen, t.cod_comprobante)), 2) = item



select 
t.txt_anoproceso, t.cod_filial, t.cod_mes, t.cod_origen, t.cod_comprobante, t.num_nroitem, t.cod_ctacontable, t.cod_proyecto, t.txt_glosaitem, t.flg_im
from dbo.scp_comprobantedetalle t, #tmp002_params where 
convert(varchar(64), hashbytes('sha2_256', concat(t.txt_anoproceso, t.cod_filial, t.cod_mes, t.cod_origen, t.cod_comprobante)), 2) = item



