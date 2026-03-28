use SCP_EQUIDAD1; select @@version

Declare @txt_anoproceso varchar(4)=
'2024'
-- '2025'       
Declare @MesIniMesFin   varchar(4)=
'0112'
-- '0101'
use 

select top 0
cast(null as varchar(4)) txt_anoproceso,
cast(null as varchar(2)) mesini,
cast(null as varchar(2)) mesfin into #tmp001_params

insert into #tmp001_params
select @txt_anoproceso, stuff(@MesIniMesFin, 3,4,''), stuff(@MesIniMesFin, 1,2,'')

Select 
    concat(b.cod_tipocomprobantepago, b.txt_seriecomprobantepago, b.txt_comprobantepago, b.cod_destino, b.num_debesol, b.num_habersol) cod,
    b.cod_tipocomprobantepago, b.txt_seriecomprobantepago, b.txt_comprobantepago, b.cod_destino,
    a.txt_anoproceso,
    a.cod_filial,
    a.cod_mes,
    a.cod_origen,
    a.cod_comprobante,
    a.fec_comprobante,
    b.num_debesol,
    b.num_habersol,
    b.num_debedolar,
    b.num_haberdolar,
    b.cod_proyecto,
    b.cod_financiera,
    b.cod_ctaproyecto,
    b.cod_ctacontable,
    b.txt_glosaitem,
    b.cod_ctaarea, 
    b.cod_ctaactividad,
    IsNull(d.txt_nombredestino,' ') As nombre into #tmp001_datos
from scp_comprobanteCabecera a cross apply scp_comprobanteDetalle b cross apply #tmp001_params pp
outer apply(select*from scp_planContable c where c.txt_anoproceso = pp.txt_anoproceso and c.cod_ctaContable = b.cod_ctaContable)c
outer apply(select*from scp_destino d where d.cod_destino = b.cod_destino)d
where 
hashbytes('sha2_256', concat(a.txt_anoproceso, a.cod_filial, a.cod_mes, a.cod_origen, a.cod_comprobante)) = 
hashbytes('sha2_256', concat(b.txt_anoproceso, b.cod_filial, b.cod_mes, b.cod_origen, b.cod_comprobante)) and
(a.txt_anoproceso = pp.txt_anoproceso and a.cod_mes between pp.mesini and pp.mesfin) and c.flg_gasto='S' and
rtrim(ltrim(b.cod_tipocomprobantepago)) != '' and rtrim(ltrim(b.txt_seriecomprobantepago)) != '' and rtrim(ltrim(b.txt_comprobantepago)) != ''

select
    b.cod_tipocomprobantepago, 
    b.txt_seriecomprobantepago, 
    b.txt_comprobantepago, 
    b.cod_destino,
    b.txt_anoproceso,
    b.cod_filial,
    b.cod_mes,
    b.cod_origen,
    b.cod_comprobante,
    b.fec_comprobante,
    b.num_debesol,
    b.num_habersol,
    b.num_debedolar,
    b.num_haberdolar,
    b.cod_proyecto,
    b.cod_financiera,
    b.cod_ctaproyecto,
    b.cod_ctacontable,
    b.txt_glosaitem,
    b.cod_ctaarea, 
    b.cod_ctaactividad,
    b.nombre
from(select count(1)over(partition by cod order by cod) item,*from #tmp001_datos)b where b.item > 1
order by b.cod_tipocomprobantepago, b.txt_seriecomprobantepago, b.txt_comprobantepago, b.cod_destino

-- (1353 rows affected)
