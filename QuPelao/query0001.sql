-- Tomado, digamos, a las 10:15 AM
BACKUP LOG SISPAP_Dev
TO DISK = 'C:\SQLBackups\SISPAP_Dev_LOG_20250624_1015.bak'
WITH INIT, COMPRESSION, DESCRIPTION = 'Log Backup 10:15 AM';
GO

-- Tomado, digamos, a las 10:30 AM
BACKUP LOG SISPAP_Dev
TO DISK = 'C:\SQLBackups\SISPAP_Dev_LOG_20250624_1030.bak'
WITH INIT, COMPRESSION, DESCRIPTION = 'Log Backup 10:30 AM';
GO


============================================

-- 1. Restaurar el backup COMPLETO más reciente
RESTORE DATABASE SISPAP_Dev
FROM DISK = 'C:\SQLBackups\SISPAP_Dev_FULL_20250624_0800.bak'
WITH NORECOVERY,
MOVE 'SISPAP_Dev' TO 'D:\SQLData\SISPAP_Dev.mdf', -- Ajusta rutas
MOVE 'SISPAP_Dev_log' TO 'D:\SQLData\SISPAP_Dev_log.ldf';
GO

-- 2. Restaurar el backup DIFERENCIAL más reciente (si lo tienes)
RESTORE DATABASE SISPAP_Dev
FROM DISK = 'C:\SQLBackups\SISPAP_Dev_DIFF_20250624_1200.bak'
WITH NORECOVERY;
GO

-- 3. Restaurar los backups de LOG en orden cronológico
RESTORE LOG SISPAP_Dev
FROM DISK = 'C:\SQLBackups\SISPAP_Dev_LOG_20250624_1215.bak'
WITH NORECOVERY;
GO

RESTORE LOG SISPAP_Dev
FROM DISK = 'C:\SQLBackups\SISPAP_Dev_LOG_20250624_1230.bak'
WITH NORECOVERY;
GO

-- ... (más backups de LOG si los hay) ...

-- 4. Restaurar el ÚLTIMO backup de LOG y poner la DB en línea (o restaurar a un punto en el tiempo)
RESTORE LOG SISPAP_Dev
FROM DISK = 'C:\SQLBackups\SISPAP_Dev_LOG_20250624_1245.bak'
WITH RECOVERY; -- Pone la DB en línea al final
GO

-- O para restaurar a un punto en el tiempo específico:
-- RESTORE LOG SISPAP_Dev
-- FROM DISK = 'C:\SQLBackups\SISPAP_Dev_LOG_20250624_1245.bak'
-- WITH STOPAT = '2025-06-24 12:40:00.000', RECOVERY;
-- GO
