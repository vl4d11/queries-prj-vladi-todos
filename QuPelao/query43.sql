use SCP_CEDIA_SUBSIDIO
go
set rowcount 0
select*from dbo.mpp_permiso where cod_trabajador = 'SPC158'
select*from dbo.mpp_licencia where cod_trabajador = 'VFH183'

-- select text from sys.syscomments where id = object_id('dbo.usp_mpp_DiasDeLicencia_SelFecha','p')
declare
    @num_periodo varchar(4) ='2026',
	@cod_trabajador varchar(10) = 'VFH183',
	@num_mesgenerado varchar(2) = '01'
-- AS
Select A.cod_trabajador,
Convert(Char(10),A.fec_inicio,103) As fec_inicio,
Convert(Char(10),A.fec_termino,103) As fec_termino
From mpp_licencia A
Where A.num_periodo = @num_periodo And A.cod_trabajador = @cod_trabajador
And @num_mesgenerado >= Substring(Convert(Char(10),A.fec_inicio,103),4,2)
And @num_mesgenerado <= Substring(Convert(Char(10),A.fec_termino,103),4,2)
Order By A.cod_trabajador

-- usp_mpp_DiasDeLicencia_SelFecha "2013","AGM003","05"
