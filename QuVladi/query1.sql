use master
go

Declare
@mdfExists int, @ldfExists int,
@dataBaseName varchar(200)
= 'MONITOREO'
,@mdfFile varchar(500)
= 'c:\data\computacion\monolito.mdf'
,@ldfFile varchar(500) 
= 'c:\data\computacion\monolito_log.ldf'

-- Verificar existencia del archivo MDF
exec dbo.xp_fileexist @mdfFile, @mdfExists output;

-- -- Verificar existencia del archivo LDF
exec dbo.xp_fileexist @ldfFile, @ldfExists output;


-- Validar resultados
if @mdfExists = 1 and @ldfExists = 1 begin
select 'Los archivos MDF y LDF existen. Procediendo con el attach.';

exec('CREATE DATABASE '+ @dataBaseName +' \
ON \
(\
NAME = ''' + @dataBaseName + '_Data'', \
FILENAME = ''' + @mdfFile + '''\
) \
LOG ON \
(\
NAME = '''+ @dataBaseName + '_Log'', \
FILENAME = ''' + @ldfFile + '''\
) \
FOR ATTACH;')
end
else select 'los archivos no existen en este contexto'

