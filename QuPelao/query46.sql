use SCP_CEDIA_SUBSIDIO
go

declare @data varchar(max) = 'VFH183|2026|01'


set nocount on
set language english

select top 0
cast(null as varchar(10)) cod_trabajador,
cast(null as char(4)) collate database_default anio,
cast(null as char(2)) collate database_default mes into #tmp001_params
select*into #mpp_findemes from dbo.mpp_findemes where 1=2
create table #tmp001_conceptos(
    item  int,
    mes   char(2) collate database_default,
    valor numeric(7,2)
)
create table #tmp001_campos(
    item   int identity,
    campo  varchar(10) collate database_default,
    codigo varchar(10) collate database_default
)
select @data = dato from dbo.udf_splice2(@data, default, default)
insert into #tmp001_params exec(@data)

;with tmp001_params as(
    select cod_trabajador, substring(fecha,1,4) anio, substring(fecha,5,2) mes
    from(select *,
    convert(varchar, dateadd(mm, -1, convert(date, concat(anio,mes,'01'), 23)), 112) fecha
    from #tmp001_params)t
)
insert into #mpp_findemes
select t.*
from dbo.mpp_findemes t
cross apply tmp001_params p
where   t.cod_trabajador = p.cod_trabajador
    and t.txt_anoproceso = p.anio


;with tmp001_sep as(
    select*from(values('|'))t(t)
)
insert into #tmp001_conceptos
select
row_number()over(partition by txt_mesproceso order by (select 1)), txt_mesproceso, value
from(select concat(
num_0101,t,
num_0102,t,
num_0103,t,
num_0104,t,
num_0105,t,
num_0106,t,
num_0107,t,
num_0108,t,
num_0109,t,
num_0110,t,
num_0111,t,
num_0112,t,
num_0113,t,
num_0114,t,
num_0115,t,
num_0116,t,
num_0117,t,
num_0118,t,
num_0119,t,
num_0120,t,
num_0121,t,
num_0122,t,
num_0123,t,
num_0124,t,
num_0125,t,
num_0126,t,
num_0127,t,
num_0128,t,
num_0129,t,
num_0130,t,
num_0201,t,
num_0202,t,
num_0203,t,
num_0204,t,
num_0205,t,
num_0206,t,
num_0207,t,
num_0208,t,
num_0301,t,
num_0401,t,
num_0402,t,
num_0403,t,
num_0404,t,
num_0405,t,
num_0406,t,
num_0407,t,
num_0408,t,
num_0409,t,
num_0410,t,
num_0411,t,
num_0412,t,
num_0413,t,
num_0414,t,
num_0415,t,
num_0416,t,
num_0417,t,
num_0418,t,
num_0419,t,
num_0420) dato, txt_mesproceso
from #mpp_findemes, tmp001_sep
order by txt_mesproceso offset 0 rows
-- where txt_mesproceso = 3
)t cross apply dbo.udf_split(dato, default)

insert into #tmp001_campos
select name campo, stuff(name, 1,4,'') codigo
from sys.columns
where object_id = object_id('dbo.mpp_findemes')
    and name like 'num_%'
    and try_cast(stuff(name, 1,4,'') as int) is not null
order by column_id


select t.mes, t.valor, tt.campo, tt.codigo
into #tmp001_matriz
from #tmp001_conceptos t, #tmp001_campos tt
where t.valor != 0
    and t.item = tt.item
order by t.mes, tt.codigo


select*from #mpp_findemes order by txt_mesproceso

select t.*, tt.txt_descripcion, tt.flg_ordinario
from #tmp001_matriz t
cross apply dbo.mpp_conceptompp tt
where t.codigo = tt.cod_conceptompp
order by t.mes, t.codigo
