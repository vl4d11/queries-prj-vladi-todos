use SCP_CEDIA_SUBSIDIO
go
declare @data varchar(max) = '2026|01|VFH183'

set language english

declare @param varchar(max) = @data
select top 0
cast(null as varchar(4)) collate database_default txt_anoproceso,
cast(null as varchar(4)) collate database_default txt_mesproceso,
cast(null as varchar(6)) collate database_default cod_trabajador into #tmp001_param
select top 0
cast(null as varchar(max)) collate database_default datos into #tmp001_remu
exec dbo.usp_remuneracion_ordinaria @data output, null
insert into #tmp001_remu select @data

select @param = dato from dbo.udf_splice(@param, default, default)
insert into #tmp001_param exec(@param)

select *, dateadd(mm, -11, periodo_fin) periodo_ini into #tmp002_param
from(select*, dateadd(mm, -1, cast(concat(txt_anoproceso, txt_mesproceso, '01') as date)) periodo_fin
from #tmp001_param)t

select*from #tmp001_remu
select*from #tmp002_param



select * from dbo.mpp_findemes t, #tmp002_param tt
where t.cod_trabajador = tt.cod_trabajador
-- and
-- t.txt_mesproceso = tt.txt_mesproceso and t.txt_anoproceso = tt.txt_anoproceso

select*from dbo.mpp_vacacion t, #tmp002_param tt
where t.cod_trabajador = tt.cod_trabajador

select*from dbo.mpp_conceptompp
