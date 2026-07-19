use SCC_DESCOSUR_FALLA2
go

declare @data varchar(max) = '2026|E0034|47422172'


set nocount on
set language english

declare @cod_trabajador2 varchar(10), @cod_afp varchar(5), @nombres varchar(100)
select top 0
cast(null as char(4)) collate database_default anio,
cast(null as varchar(10)) collate database_default cod_trabajador,
cast(null as varchar(15)) collate database_default num_docidentidad into #tmp001_params
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
select @data = dato from dbo.udf_splice(@data, default, default)
insert into #tmp001_params exec(@data)

insert into #mpp_findemes
select t.*
from dbo.mpp_findemes t cross apply #tmp001_params p
where   t.cod_trabajador = p.cod_trabajador
    and t.txt_anoproceso = p.anio

select @nombres = concat(t.txt_paterno, ' ', t.txt_materno, ' ', t.txt_nombre), @cod_afp = t.cod_afp, @cod_trabajador2 = t.cod_trabajador
from dbo.mpp_empleado t, #tmp001_params pp
where t.cod_trabajador = pp.cod_trabajador and t.num_docidentidad = pp.num_docidentidad

select row_number()over(order by case t.cod_conceptompp when '0205' then '0250' else t.cod_conceptompp end) item,*
into #MPP_CONCEPTOMPP
from(select t.cod_conceptompp, t.txt_descripcion, t.tip_concepto, tt.descr, tt.grupo
from dbo.MPP_CONCEPTOMPP t,(values
('I','REMUNERACIONES/ INGRESOS VARIABLES',1),
('A','APORTES EMPLEADO',2),
('T','IMPUESTOS Y RETENCIONES',4),
('D','DESCUENTOS',5))tt(tip_concepto,descr,grupo)
where t.tip_concepto = tt.tip_concepto and t.cod_conceptompp != '0205' union all
select t.cod_conceptompp, t.txt_descripcion, 'E', 'APORTES EMPLEADOR', 3
from dbo.MPP_CONCEPTOMPP t where t.cod_conceptompp = '0205')t

;with tmp001_sep as(
    select*from(values('|'))t(t)
)
insert into #tmp001_conceptos
select row_number()over(partition by txt_mesproceso order by (select 1)), txt_mesproceso, value
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
)t cross apply dbo.udf_split(dato, default)

insert into #tmp001_campos
select name campo, stuff(name, 1,4,'') codigo
from sys.columns
where object_id = object_id('dbo.mpp_findemes')
    and name like 'num_%'
    and try_cast(stuff(name, 1,4,'') as int) is not null
order by column_id

select t.mes, t.valor, tt.campo, tt.codigo into #tmp001_matriz
from #tmp001_conceptos t, #tmp001_campos tt
where t.valor != 0
    and t.item = tt.item
order by t.mes, tt.codigo




select*into #tmp001_meses
from(values('01'),('02'),('03'),('04'),('05'),('06'),('07'),('08'),('09'),('10'),('11'),('12'))m(meses)

select t.mes, t.valor, t.codigo, tt.txt_descripcion, tt.tip_concepto, tt.descr, tt.grupo
into #tmp002_matriz
from #tmp001_matriz t cross apply #mpp_conceptompp tt
where t.codigo = tt.cod_conceptompp

select distinct t.grupo, t.codigo, tt.meses into #tmp001_mesesGrupo from #tmp002_matriz t, #tmp001_meses tt

select t.grupo, t.codigo, t.meses, tt.valor, tt.txt_descripcion, tt.tip_concepto, tt.descr
into #tmp003_matriz
from #tmp001_mesesGrupo t outer apply(
select*from #tmp002_matriz tt where tt.grupo = t.grupo and tt.codigo = t.codigo and tt.mes = t.meses)tt


select grupo, codigo, meses, valor,
    case it1 when 1 then descr end tit_grupo, case it2 when 1 then txt_descripcion end tit_codigo,
    sum(valor)over(partition by codigo) tot_codigo
from(select grupo, codigo, meses, valor, txt_descripcion, descr,
    row_number()over(partition by grupo order by item) it1,
    row_number()over(partition by codigo order by item) it2
from(select t.grupo, t.codigo, t.meses,
    isnull(t.valor, 0) valor,
    isnull(t.txt_descripcion, tt.txt_descripcion) txt_descripcion,
    isnull(t.descr, tt.descr) descr,
    row_number()over(order by t.grupo, t.codigo, t.meses) item
from #tmp003_matriz t
cross apply(select distinct grupo, codigo, descr, txt_descripcion from #tmp002_matriz)tt
where t.grupo = tt.grupo and t.codigo = tt.codigo)t)t
order by t.grupo, t.codigo, t.meses


select t.grupo, t.meses, isnull(tt.tot_grupo_mes, 0) tot_grupo_mes,
sum(tt.tot_grupo_mes)over(partition by t.grupo) tot_grupo
from(select distinct grupo, meses from #tmp001_mesesGrupo)t outer apply(
    select distinct grupo, mes,
    sum(valor)over(partition by grupo, mes) tot_grupo_mes
from #tmp002_matriz tt where tt.grupo = t.grupo and tt.mes = t.meses)tt
order by t.grupo, t.meses


select t.meses, isnull(tt.tot_mes, 0) tot_mes, sum(tt.tot_mes)over() total
from(select distinct meses from #tmp001_mesesGrupo)t outer apply(
    select distinct mes,
    sum(valor)over(partition by mes) tot_mes
from #tmp002_matriz tt where tt.mes = t.meses)tt
order by t.meses







select replace(concat(@nombres,'^Trabajador (Rubro/Concepto)|', months, '|TOTAL'),',','|') tit
from sys.syslanguages where alias = 'Spanish'


-- select*from #mpp_findemes order by txt_mesproceso
