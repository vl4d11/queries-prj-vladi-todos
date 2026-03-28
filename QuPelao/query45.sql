use SCP_CEDIA_SUBSIDIO
go
if exists(select 1 from sys.sysobjects where id = object_id('dbo.usp_remuneracion_ordinaria', 'p'))
drop procedure dbo.usp_remuneracion_ordinaria
go
create procedure dbo.usp_remuneracion_ordinaria
@data varchar(max) output,
@cab int = 1
as
begin
set nocount on

select top 0
cast(null as varchar(4)) collate database_default txt_anoproceso,
cast(null as varchar(4)) collate database_default txt_mesproceso,
cast(null as varchar(6)) collate database_default cod_trabajador into #tmp001_param
select top 0
cast(null as varchar(6)) collate database_default cod_trabajador,
cast(null as numeric(10,2)) remuneracion into #tmp001_remuneracion
select @data = dato from dbo.udf_splice(@data, default, default)
insert into #tmp001_param exec(@data)

select @data = concat(stuff((select '+num_', cod_conceptompp
from dbo.mpp_conceptompp where flg_ordinario = 'S'
for xml path, type).value('.','varchar(max)'),1,1,'select t.cod_trabajador,'),
' remuneracion from dbo.mpp_findemes t, #tmp001_param tt \
where t.txt_mesproceso = tt.txt_mesproceso and t.txt_anoproceso = tt.txt_anoproceso \
and t.cod_trabajador = isnull(tt.cod_trabajador, t.cod_trabajador)')
insert into #tmp001_remuneracion exec(@data)

;with tmp001_sep(t,r)as(
    select*from(values('|','~'))t(sepCamp,sepReg)
)
,tmp001_cab(cab) as(
    select concat('cod_trabajador|num_remafecta', r, '100|100', r, 'String|Decimal', r)
    from tmp001_sep where @cab = 1
)
select @data = concat(c.cab, stuff((select r, cod_trabajador, t, remuneracion
from #tmp001_remuneracion
for xml path, type).value('.','varchar(max)'),1,1,''))
from tmp001_sep outer apply tmp001_cab c

end
go

select top 0
cast(null as varchar(max)) collate database_default datos into #tmp001_remu
declare @data varchar(max) = '2025|04|'
exec dbo.usp_remuneracion_ordinaria @data output, null
insert into #tmp001_remu select @data

select datos from #tmp001_remu
