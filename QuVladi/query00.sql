-- NOTA: PASAR LA DATA A LOCAL ...
-- ===============================
-- go
-- exec dbo.sp_addlinkedserver @server = 'PVN', @provider = 'MSOLEDBSQL', @srvproduct = '', @provstr = 'server=DBD3;User ID=usrbdvialdes01;database=BD_SIGVIAL'
-- go
-- exec dbo.sp_addlinkedsrvlogin @rmtsrvname = 'PVN', @locallogin = null, @useself = 'false', @rmtuser = 'usrbdvialdes01', @rmtpassword = 'xyz456*'
-- go
-- exec sp_droplinkedsrvlogin @rmtsrvname = 'PVN', @locallogin = null
-- exec sp_dropserver @server = 'PVN'
-- go


-- SigLevTIntereferenciaPACRI
-- select*from sys.tables order by 1



-- select*into dbo.SigLevTEstadoEjecucionEstudio from openquery(PVN, 'select*from dbo.SigLevTEstadoEjecucionEstudio where eEstado != 10')




-- select*from sys.tables order by create_date desc
-- select*from sys.sysservers

-- exec sp_configure





-- select name, ctabla from sys.tables
-- outer apply(select*from openquery(PVN, 'select distinct ctabla from dbo.MapIntMTablas order by 1')
-- where rtrim(ctabla) collate database_default = rtrim(concat('dbo.', name)))t
-- order by ctabla
