use SCP_VASJA
go

set language spanish

declare
@fechaInicio date = '01/01/2024',
@fechaFinal date = '31/12/2024',
@pryInicio int = '0005060',
@pryFinal int = '0008018',
@gastoInicio int = '004000',
@gastoFinal int = '004000',
@porMov_Mon varchar(1) = 'M',
@detalle varchar(1) = 'N'
declare
@data varchar(max)

create table #tmp001_nivel(nivel tinyint identity, num tinyint)
select * into #tmp001_sep from(values('|','~','^','),('))t(t,r,i,tt)

select*into #tmp001_param from(values(
@fechaInicio, @fechaFinal, @pryInicio, @pryFinal, @gastoInicio, @gastoFinal, @porMov_Mon, @detalle))t(
fechaIni, fechaFin, pryInicio, pryFinal, gastoInicio, gastoFinal, porMov_Mon, detalle)

select @data = concat('select*from(values(', num_nivel1, tt, num_nivel2, tt,
    num_nivel3, tt, num_nivel4, tt, num_nivel5, tt, num_nivel6, tt,
    num_nivel7, tt, num_nivel8,'))t(a)where a>0')
from dbo.scp_configuracionplanes, (
    select year(fechaFin) afin from #tmp001_param)f, #tmp001_sep
where txt_anoproceso = f.afin and cod_plan = '05'
insert into #tmp001_nivel exec(@data)


select*from #tmp001_nivel
select*from #tmp001_param


-- select t.cod_contraparte, t.cod_proyecto, *
-- from dbo.scp_comprobantedetalle t, scp_plancontable tt, #tmp001_param p
-- where t.txt_anoproceso = tt.txt_anoproceso and t.cod_ctacontable = tt.cod_ctacontable
-- and tt.flg_gasto = 's' and t.fec_comprobante between p.fechaIni and p.fechaFin
-- and cast(t.cod_proyecto as int) between p.pryInicio and p.pryFinal
-- and cast(t.cod_contraparte as int) between p.gastoInicio and p.gastoFinal





-- return
-- set rowcount 20

-- select*from dbo.scp_Contraparte
-- select*from dbo.scp_categorialugargasto


-- return
select*from dbo.mastertable('dbo.scp_comprobantedetalle')
select*from dbo.mastertable('dbo.scp_plancontable')

select*from dbo.mastertable('dbo.scp_Contraparte')
select*from dbo.mastertable('dbo.scp_categorialugargasto')
