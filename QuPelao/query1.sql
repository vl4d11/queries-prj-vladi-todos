select @@version; select db_name()
-- use SCP_AMINISTIA;
-- select*from sys.tables order by 1
--
-- ALTER DATABASE SCC_SPP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- GO
-- drop database SCC_SPP
-- go

select dbid, name, filename from sys.sysdatabases order by name
select convert(decimal(10, 2), (size * 8.0)/ 1024) size_MB,*
from sys.master_files



-- -- NOTA: RESTORE X SQL2019 -- EN EL CONTAINER
-- -- =======================
-- restore database SCC_DESCOSUR_FALLA2 from
-- disk='/var/opt/mssql/DBDESCOSUR.bak' with replace,
-- move 'SCP_DESCOSUR' to '/var/opt/mssql/SCP_DESCOSUR_falla2.mdf',
-- move 'SCP_DESCOSUR_log' to '/var/opt/mssql/SCP_DESCOSUR_falla2_log.ldf'
-- go


-- :: NOTA: PARA EL CONTAINER SQL-2019
-- declare @ruta varchar(500) =
-- '/var/opt/mssql/DBDESCOSUR.bak'

-- restore verifyonly from disk=@ruta -- with checksum
-- restore filelistonly from disk=@ruta
-- restore headeronly from disk=@ruta




-- NOTA: RESTORE X SQL2022 -- EN EL HOST LOCAL
-- =======================
-- restore database SCP_AMINISTIA from
-- disk='/backups/sql-server/SCP_AMINISTIA.bak' with replace,
-- move 'SCP_AMINISTIA' to '/backups/sql-server/SCP_AMINISTIA_2022.mdf',
-- move 'SCP_AMINISTIA_log' to '/backups/sql-server/SCP_AMINISTIA_2022_log.ldf'


-- -- :: NOTA: PARA EL CONTAINER SQL-2019
-- restore filelistonly from
-- disk='/var/opt/mssql/DBSCP_CEDIA.bak'
-- restore headeronly from
-- disk='/var/opt/mssql/DBSCP_CEDIA.bak'




-- -- :: NOTA: PARA DB LOCAL SQL-2022
-- restore filelistonly from
-- disk='/backups/sql-server/SCP_AMINISTIA.bak'
-- restore headeronly from
-- disk='/backups/sql-server/SCP_AMINISTIA.bak'



-- create database SCP_AMINISTIA
-- on(
--     filename = '/backups/sql-server/SCP_AMINISTIA_2019.mdf'
-- )
-- log on (
--     filename = '/backups/sql-server/SCP_AMINISTIA_2019_log.ldf'
-- )
-- for attach;



-- ============================== NO FUNCIONA XQ CAMBIA LA VERSION INTERNA

-- NOTA DETACH DATA BASE (FOR BOTH)
-- =====================
-- alter database SCP_AMINISTIA set single_user with rollback immediate
-- exec sp_detach_db 'SCP_AMINISTIA'


-- NOTA: ATTACH DATA BASE (EN LOCAL)
-- ======================
-- exec sp_attach_db 'SCP_AMINISTIA',
-- '/backups/sql-server/SCP_AMINISTIA_2019.mdf',
-- '/backups/sql-server/SCP_AMINISTIA_2019_log.ldf'


-- NOTA: ATTACH DATA BASE (EN REMOTO)
-- ======================
-- exec sp_attach_db 'SCP_AMINISTIA',
-- '/var/opt/mssql/SCP_AMINISTIA_2019.mdf',
-- '/var/opt/mssql/SCP_AMINISTIA_2019_log.ldf'
