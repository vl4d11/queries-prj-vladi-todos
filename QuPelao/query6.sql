-- NOTA: ESSTO ES PARA EL CONEJO -- RESTORES MASIVOS X SCRIPT EN BASH
-- ======================================================================
select @@version

declare @par_nombre varchar(max) = 
'20250315-bkp-igesop'


declare @ruta varchar(max) = '/var/opt/mssql/vladi/'

create table #tmp001_logs(
LogicalName varchar(100),
PhysicalName varchar(100),
Type varchar(100),
FileGroupName varchar(100),
Size bigint,
MaxSize bigint,
FileId bigint,
CreateLSN bigint,
DropLSN bigint,
UniqueId varchar(1000),
ReadOnlyLSN bigint,
ReadWriteLSN bigint,
BackupSizeInBytes bigint,
SourceBlockSize bigint,
FileGroupId bigint,
LogGroupGUID varchar(100),
DifferentialBaseLSN bigint,
DifferentialBaseGUID varchar(1000),
IsReadOnly bigint,
IsPresent bigint,
TDEThumbprbigint varchar(100),
SnapshotUrl varchar(100),
item int identity
);
insert into #tmp001_logs
exec('restore filelistonly from disk='''+ @ruta + @par_nombre +'''')


select @ruta = concat('restore database igesop from disk=''', @ruta, @par_nombre, ''' with replace',
(select ', move ''', LogicalName, ''' to ''', @ruta, 'dataPrueba.', 
case item when 1 then 'mdf' else 'ldf' end, '''' 
from #tmp001_logs order by item
for xml path, type).value('.','varchar(max)'))

select(@ruta)


-- select*from sys.databases
-- use msdbPrueba;
-- select*from sys.tables


