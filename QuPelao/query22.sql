use SCP_SAIPE; select @@version

set rowcount 0

select*from mastertable('scp_comprobantecabecera')
select*from mastertable('scp_comprobantedetalle')


set rowcount 20

select*from dbo.scp_comprobantecabecera
select*from dbo.scp_comprobantedetalle






-- exec sys.sp_spaceused scp_comprobantecabecera
-- exec sys.sp_spaceused scp_comprobantedetalle

