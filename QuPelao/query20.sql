use SCP_DOCUMENTO; select @@version

-- NOTA:
-- PARA VLADI 
-- ES EL CONSUMO DEL API REST
-- ============================
-- select*into dbo.gen_feriado2 from dbo.gen_feriado
-- alter table dbo.gen_feriado2 add id int identity primary key not null 
-- insert into dbo.gen_feriado2
-- select*from dbo.gen_feriado


select id, txt_mes, *from dbo.gen_feriado2


go
alter procedure dbo.usp_salida1
@data varchar(max)
as
begin
set nocount on

select top 0
cast(null as int) tipo,
cast(null as varchar(30)) docum into #tmp001_param

select @data = concat('select*from(values(''', replace(@data, '|', ''','''), '''))t(a,b)')
insert into #tmp001_param exec(@data)

select (
select txt_anoproceso anno, txt_mes mes, txt_dia dia, txt_descripcion descrip
from dbo.gen_feriado2, #tmp001_param pp
where id = pp.tipo and txt_mes = pp.docum
for json path) salida

end
go


-- go
-- alter procedure dbo.usp_salida2
-- as
-- begin
-- set nocount on

-- select txt_anoproceso anno, txt_mes mes, txt_dia dia, txt_descripcion descrip
-- from dbo.gen_feriado

-- end
-- go

-- exec dbo.usp_salida1 'maria'
-- exec dbo.usp_salida2

