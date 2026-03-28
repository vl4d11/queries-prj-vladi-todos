use SCP_EQUIDAD1; select @@version

-- select*from sys.procedures order by 1
-- select text from sys.syscomments where id=object_id('dbo.usp_scp_DocumentoDuplicado','p')


-- CREATE PROCEDURE [dbo].[usp_scp_DocumentoDuplicado]
Declare @txt_anoproceso varchar(4)=
'2024'
-- '2025'       
Declare @MesIniMesFin   varchar(4)=
-- mes inicial y mes final
'0112'
-- '0101'

-- AS
Declare @MesIni Varchar(2)
Declare @MesFin Varchar(2)

Set @MesIni = Substring(@MesIniMesFin,1,2)
Set @MesFin = Substring(@MesIniMesFin,3,2)

Select b.cod_tipocomprobantepago,b.txt_seriecomprobantepago,b.txt_comprobantepago,
       b.cod_destino,
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
	   b.cod_ctaactividad
	   ,IsNull(d.txt_nombredestino,' ') As nombre
From scp_comprobanteCabecera a
INNER JOIN scp_comprobanteDetalle b ON a.txt_anoproceso  =b.txt_anoproceso 
And  a.cod_filial+a.cod_mes+a.cod_origen+a.cod_comprobante=b.cod_filial+b.cod_mes+b.cod_origen+b.cod_comprobante 
LEFT OUTER JOIN scp_planContable c ON c.txt_anoproceso=@txt_anoproceso  
And c.cod_ctaContable =b.cod_ctacontable
LEFT OUTER JOIN scp_destino d ON d.cod_destino=b.cod_destino  
Where a.txt_anoproceso = @txt_anoproceso And c.flg_gasto='S' And 
(a.cod_mes >= @MesIni And a.cod_mes <= @MesFin) And 
LTrim(Rtrim(b.cod_tipocomprobantepago))<>'' And LTrim(Rtrim(b.txt_seriecomprobantepago))<>'' And LTrim(Rtrim(b.txt_comprobantepago))<>''

AND		(b.cod_tipocomprobantepago + b.txt_seriecomprobantepago + b.txt_comprobantepago + b.cod_destino + cast(b.num_debesol as varchar) + cast(b.num_habersol as varchar) ) in 
		(
			Select	
					b.cod_tipocomprobantepago + 
					b.txt_seriecomprobantepago + 
					b.txt_comprobantepago + 
					b.cod_destino +
					cast(b.num_debesol as varchar) + 
					cast(b.num_habersol as varchar) 
			From scp_comprobanteCabecera a
			INNER JOIN scp_comprobanteDetalle b ON a.txt_anoproceso  =b.txt_anoproceso 
			And  a.cod_filial+a.cod_mes+a.cod_origen+a.cod_comprobante=b.cod_filial+b.cod_mes+b.cod_origen+b.cod_comprobante 
			LEFT OUTER JOIN scp_planContable c ON c.txt_anoproceso=@txt_anoproceso  
			And c.cod_ctaContable =b.cod_ctacontable
			Where a.txt_anoproceso = @txt_anoproceso And c.flg_gasto='S' And 
			(a.cod_mes >= @MesIni And a.cod_mes <= @MesFin) And 
			LTrim(Rtrim(b.cod_tipocomprobantepago))<>'' And LTrim(Rtrim(b.txt_seriecomprobantepago))<>'' And LTrim(Rtrim(b.txt_comprobantepago))<>''
			group by b.cod_tipocomprobantepago,
						b.txt_seriecomprobantepago,
						b.txt_comprobantepago,
						b.cod_destino,
						b.num_debesol,
						b.num_habersol
			having  count(*) > 1 
		)

Order By b.cod_tipocomprobantepago,b.txt_seriecomprobantepago,b.txt_comprobantepago,b.cod_destino

 --   Exec usp_scp_DocumentoDuplicado '2025','0101'

 --   Exec usp_scp_DocumentoDuplicado '2024','0112'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
