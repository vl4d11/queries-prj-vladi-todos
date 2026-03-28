use SCP_AMINISTIA_MCO
go


create procedure dbo.general_poblarTablaParam
@data varchar(max)
as
begin
set nocount on
set language spanish

declare @col varchar(max)
create table #tmp001_data(
    item int identity,
    dato varchar(max)
)
select * into #tmp002_data from #tmp001_data where 1=2
select @col =
concat('select*from(values(''', replace(@data, '¬', '''),('''), '''))t(a)')
insert into #tmp001_data exec(@col)
select @col = dato from #tmp001_data where item = 1
select @col =
concat('select*from(values(''', replace(@col, '|', '''),('''), '''))t(a)')
insert into #tmp002_data exec(@col)
select @col = stuff((select ',a',item from #tmp002_data
for xml path, type).value('.','varchar(max)'),1,1,'')
select @data = concat('select*from(values(''',
replace(replace(@data, '|', ''','''), '¬', '''),('''), '''))t(', @col, ')')
insert into #tmp001_param exec(@data)

end
go

---------------

create procedure dbo.general_poblarTablaParam2
@data varchar(max)
as
begin
set nocount on
set language spanish

declare @col varchar(max)
create table #tmp001_data(
    item int identity,
    dato varchar(max)
)
select * into #tmp002_data from #tmp001_data where 1=2
select @col =
concat('select*from(values(''', replace(@data, '¬', '''),('''), '''))t(a)')
insert into #tmp001_data exec(@col)
select @col = dato from #tmp001_data where item = 1
select @col =
concat('select*from(values(''', replace(@col, '|', '''),('''), '''))t(a)')
insert into #tmp002_data exec(@col)
select @col = stuff((select ',a',item from #tmp002_data
for xml path, type).value('.','varchar(max)'),1,1,'')
select @data = concat('select*from(values(''',
replace(replace(@data, '|', ''','''), '¬', '''),('''), '''))t(', @col, ')')
insert into #tmp002_param exec(@data)

end
go
