DECLARE @mdfFile NVARCHAR(260) = N'/data/computacion/monolito.mdf';
DECLARE @ldfFile NVARCHAR(260) = N'/data/computacion/monolito_log.ldf';
DECLARE @mdfExists INT;
DECLARE @ldfExists INT;

-- Verificar existencia del archivo MDF
EXEC xp_fileexist @mdfFile, @mdfExists OUTPUT;

-- Verificar existencia del archivo LDF
EXEC xp_fileexist @ldfFile, @ldfExists OUTPUT;

-- Validar resultados
IF @mdfExists = 1 AND @ldfExists = 1
BEGIN
    PRINT '✅ Los archivos MDF y LDF existen. Procediendo con el attach.';

    -- Opcionalmente aquí puedes poner el CREATE DATABASE FOR ATTACH
    EXEC('
        CREATE DATABASE MONOLITO_DB
        ON (FILENAME = ''' + @mdfFile + ''')
        LOG ON (FILENAME = ''' + @ldfFile + ''')
        FOR ATTACH;
    ');
END
ELSE
BEGIN
    IF @mdfExists = 0
        PRINT '❌ El archivo MDF no existe: ' + @mdfFile;

    IF @ldfExists = 0
        PRINT '❌ El archivo LDF no existe: ' + @ldfFile;

    PRINT '⚠️ No se realizó el attach por falta de archivos.';
END;
