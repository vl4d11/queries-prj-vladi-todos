use SCP_DESCOSUR2; select @@version;


select*from dbo.mpp_empleado where convert(varchar(6),fec_ingreso,112) > '202501'
