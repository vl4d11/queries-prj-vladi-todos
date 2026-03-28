use SCP_CNDH;

if exists(select 1 from sys.sysobjects where id=object_id('dbo.usp_spaceU','p'))
drop procedure dbo.usp_spaceU
go
create procedure dbo.usp_spaceU
as
begin
set nocount on

select top 0
cast(null as varchar(100)) name,
cast(null as int) rows,
cast(null as varchar(20)) reserved,
cast(null as varchar(20)) data,
cast(null as varchar(20)) index_size,
cast(null as varchar(20)) unused into ##tmp001_usados

declare @data varchar(max) = (
select(select ';exec sys.sp_spaceused ''dbo.', name, '''' from sys.tables
for xml path, type).value('.','varchar(max)'))
insert into ##tmp001_usados exec(@data)

end
go


-- exec dbo.usp_spaceU
-- select*from ##tmp001_usados where rows != 0 order by rows
