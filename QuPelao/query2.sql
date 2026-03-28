use SCP_AMINISTIA;select @@version

if exists(select 1 from sys.sysobjects where id= object_id('dbo.UDF_sep', 'if'))
drop function dbo.UDF_sep
go
create function dbo.UDF_sep(
    @flag tinyint
)returns table as return(
select sepCamp t, sepReg r from(values
(0,'|','^'),
(1,'|','¬')

)t(flag, sepCamp, sepReg) where flag = @flag
)
go



if exists(select 1 from sys.sysobjects where id = object_id('dbo.usp_genera_data', 'p'))
drop procedure dbo.usp_genera_data
go

create procedure dbo.usp_genera_data
@sep tinyint,
@tablaU varchar(200),
@data varchar(max)
as
begin
set nocount on
set language english

declare @dataCab varchar(max)
;with tmp001_pos as(
    select charindex(r, @data) pos
    from dbo.UDF_sep(@sep)
)
select @dataCab = substring(@data, 0, iif(pos = 0, len(@data) +1, pos)) from tmp001_pos

create table #tmp001_cab(
    letra char(1),
    item int identity
)
declare @cab varchar(max) = ( 
select concat('select ''a'' from(values(''', replace(@dataCab, t, '''),('''), '''))t(a)')
from dbo.UDF_sep(@sep))
insert into #tmp001_cab(letra) exec(@cab)

select @cab = concat(' select*from(values(''', 
replace(replace(@data, t, ''','''), r, '''),('''), '''))t(',
stuff((select ',', letra, item from #tmp001_cab
for xml path, type).value('.','varchar(max)'),1,1,''), ')')
from dbo.UDF_sep(@sep)

declare @random varchar(max)=
(select concat(abs(checksum(newid())),abs(checksum(newid())), abs(checksum(newid()))))

declare @tabla varchar(max)= (
select concat(stuff((select ',', letra, item, ' varchar(2000)' from #tmp001_cab
for xml path, type).value('.','varchar(max)'),1,1, 
concat('create table ##tmp001_info_', @random, '(')), ')'))

select @data = concat(@tabla, ';insert into ##tmp001_info_', @random, @cab)
exec(@data)
exec('insert into '+ @tablaU +' select*from ##tmp001_info_'+ @random)

end
go



