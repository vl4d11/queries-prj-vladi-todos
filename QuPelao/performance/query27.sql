select actual_state_desc, desired_state_desc, readonly_reason
from sys.database_query_store_options;

-- ALTER DATABASE TuBaseDatos
-- SET QUERY_STORE = ON;

-- ALTER DATABASE TuBaseDatos
-- SET QUERY_STORE = ON
-- (
--     MAX_STORAGE_SIZE_MB = 100,                -- Límite de espacio
--     CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 7), -- Mantener 7 días de historial
--     INTERVAL_LENGTH_MINUTES = 15,            -- Cada cuánto se agregan estadísticas
--     DATA_FLUSH_INTERVAL_SECONDS = 900,       -- Intervalo de escritura en disco
--     QUERY_CAPTURE_MODE = AUTO                -- Captura automática (solo consultas relevantes)
-- );



SELECT TOP 10
    qsqt.query_sql_text,
    rs.avg_duration,
    rs.avg_cpu_time,
    rs.avg_logical_io_reads,
    rs.count_executions,
    rs.last_execution_time
FROM sys.query_store_runtime_stats rs
JOIN sys.query_store_plan p ON rs.plan_id = p.plan_id
JOIN sys.query_store_query q ON p.query_id = q.query_id
JOIN sys.query_store_query_text qsqt ON q.query_text_id = qsqt.query_text_id
ORDER BY rs.avg_cpu_time DESC;

-- PARA VER EL ESTADO Y CAPACIDAD DE LAS ESTADISTICAS
SELECT
    db_name(database_id) AS database_name,
    storage_size_mb,
    max_storage_size_mb,
    [state_desc]
FROM sys.query_store_database_runtime_stats;


-- Monitorear tamaño con vistas DMV
SELECT TOP 10
    qs.total_worker_time / qs.execution_count AS AvgCPU,
    qs.total_worker_time AS TotalCPU,
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_logical_writes,
    qs.creation_time,
    qs.last_execution_time,
    SUBSTRING(qt.text, (qs.statement_start_offset / 2) + 1,
              ((CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(qt.text)
                    ELSE qs.statement_end_offset
               END - qs.statement_start_offset) / 2) + 1) AS query_text,
    qt.text AS full_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY qs.total_worker_time DESC; -- CPU más alto

-- ejecucion de consulta online, current
select*from sys.dm_exec_requests
select*from sys.dm_tran_locks


-- qs.total_worker_time → CPU total consumido
-- qs.total_logical_reads → Lecturas en memoria
-- qs.total_logical_writes → Escrituras en memoria
-- qs.execution_count → Frecuencia
-- qs.creation_time → Desde cuándo está la consulta registrada
-- qs.last_execution_time → Última ejecución

-- RECONSTRUCCION DE INDICES

SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(), NULL, NULL, 'DETAILED') AS ips
JOIN sys.indexes AS i
    ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 100
ORDER BY avg_fragmentation_in_percent DESC;


ALTER INDEX [NombreIndice] ON [NombreTabla]
REBUILD WITH (
    FILLFACTOR = 90,
    SORT_IN_TEMPDB = ON
);
