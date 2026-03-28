use SCP_CNDH
declare @data varchar(max)
='2023|2023|02|2023-01-01|2023-12-31|060DIN|'

set nocount on
set language english

create table #tmp001_nivel(nivel tinyint identity, num tinyint)
select * into #tmp001_sep from(values('|','~','^','),('))t(t,r,ls,tt)
select top 0
cast(null as smallint) aini,
cast(null as smallint) afin,
cast(null as varchar(2)) tipoMoneda,
cast(null as date) fini,
cast(null as date) ffin,
cast(null as varchar(6)) cod_proy,
cast(null as varchar(6)) cod_fina into #tmp001_param

select @data = concat('select*from(values(''',
replace(@data,'|',''','''), '''))t(a1,a2,a3,a4,a5,a6,a7)')
insert into #tmp001_param exec(@data)

select @data = concat('select*from(values(', num_nivel1, tt, num_nivel2, tt,
    num_nivel3, tt, num_nivel4, tt, num_nivel5, tt, num_nivel6, tt,
    num_nivel7, tt, num_nivel8,'))t(a)where a>0')
from dbo.scp_configuracionplanes, #tmp001_param, #tmp001_sep
where txt_anoproceso = afin and cod_plan = '02'
insert into #tmp001_nivel exec(@data)

select* into #tmp001_numeracion from(select distinct
    hashbytes('md5', concat(t.txt_anoproceso, t.cod_proyecto)) cod_ap,
    hashbytes('md5', concat(t.txt_anoproceso, t.cod_proyecto,
    t.cod_financiera, t.cod_ctaproyecto)) cod_apfc, t.cod_financiera
from dbo.scp_presupuestoproyecto t cross apply #tmp001_param p
where t.txt_anoproceso between p.aini and p.afin
and t.cod_tipomoneda = p.tipoMoneda
and t.cod_proyecto = isnull(nullif(p.cod_proy,''), t.cod_proyecto)
and not nullif(nullif(substring(t.cod_ctaproyecto,1,1),'I'),'') is null
order by cod_apfc offset 0 rows)t order by cod_apfc

;with tmp001_sep(t,r,i)as(
    select*from(values('|','~','^'))t(sepCampo,sepReg,sepLst)
)
,tmp001_cab(dato) as(
    select concat(
    'COD PROYECTO|DESCRIPCION|PRESUPUESTO|EJECUCION|SALDO|NEGRITA', r,
    '50|250|50|50|50|50', r,
    'String|String|String|String|String|String')
    from tmp001_sep
)
,tmp001_niveles as(
    select*from #tmp001_nivel
)
,tmp001_param as(
    select*from #tmp001_param
)
,tmp001_presupuesto as(
    select distinct n.cod_apfc, txt_anoproceso, cod_proyecto,
        t.cod_financiera, sum(ppto)over(
        partition by txt_anoproceso, cod_proyecto, t.cod_financiera,
        cod_ctaproyecto) ppto
    from(
        select hashbytes('md5', concat(t.txt_anoproceso, t.cod_proyecto,
        t.cod_financiera, t.cod_ctaproyecto)) cod,
        t.txt_anoproceso, t.cod_proyecto, t.cod_financiera, t.cod_ctaproyecto,
        cast((t.num_ppto01 + t.num_ppto02 + t.num_ppto03 + t.num_ppto04 +
        t.num_ppto05 + t.num_ppto06 + t.num_ppto07 + t.num_ppto08 +
        t.num_ppto09 + t.num_ppto10 + t.num_ppto11 + t.num_ppto12)
        as numeric(10,2)) ppto
        from dbo.scp_presupuestoproyecto t cross apply tmp001_param p
            where t.txt_anoproceso between p.aini and p.afin
            and t.cod_tipomoneda = p.tipoMoneda
            and t.cod_proyecto = isnull(nullif(p.cod_proy,''), t.cod_proyecto)
            and not nullif(nullif(substring(t.cod_ctaproyecto,1,1),'I'),'') is null
    )t
    cross apply #tmp001_numeracion n
    where n.cod_apfc = t.cod
    order by txt_anoproceso, cod_proyecto, t.cod_financiera offset 0 rows
)
,tmp001_gastos as(
    select distinct n.cod_apfc, txt_anoproceso, cod_proyecto,
        tt.cod_financiera, sum(ejecucion)over(
        partition by txt_anoproceso, cod_proyecto, tt.cod_financiera,
        cod_ctaproyecto) eje
    from(
        select hashbytes('md5', concat(tt.txt_anoproceso, tt.cod_proyecto,
            tt.cod_financiera, tt.cod_ctaproyecto)) cod,
            tt.txt_anoproceso, tt.cod_proyecto, tt.cod_financiera,
            tt.cod_ctaproyecto, case p.tipoMoneda
            when '01' then tt.num_debesol - tt.num_habersol
            when '02' then tt.num_debedolar - tt.num_haberdolar
            when '03' then tt.num_debemo - tt.num_habermo end ejecucion
        from dbo.scp_comprobanteCabecera t
        cross apply dbo.scp_comprobanteDetalle tt
        cross apply dbo.scp_plancontable ttt
        cross apply tmp001_param p
        where t.txt_anoproceso = tt.txt_anoproceso
        and t.cod_filial = tt.cod_filial
        and t.cod_mes = tt.cod_mes and t.cod_origen = tt.cod_origen
        and t.cod_comprobante = tt.cod_comprobante
        and tt.txt_anoproceso = ttt.txt_anoproceso
        and tt.cod_ctacontable = ttt.cod_ctacontable
        and not nullif(tt.cod_ctaproyecto,'') is null
        and ttt.flg_gasto = 'S'
        and t.fec_comprobante between p.fini and p.ffin
        and tt.cod_proyecto = isnull(nullif(p.cod_proy, ''), tt.cod_proyecto)
    )tt
    cross apply #tmp001_numeracion n
    where n.cod_apfc = tt.cod
    order by txt_anoproceso, cod_proyecto, tt.cod_financiera offset 0 rows
)
,tmp001_planProj as(
    select distinct
        dense_rank()over(order by pp.txt_anoproceso, pp.cod_proyecto) prj,
        dense_rank()over(order by pp.txt_anoproceso, pp.cod_proyecto,
        n.cod_financiera) item,
        pp.txt_anoproceso, pp.cod_proyecto, n.cod_financiera,
        pp.cod_ctaproyecto, pp.txt_descctaproyecto,
        hashbytes('md5', concat(pp.txt_anoproceso, pp.cod_proyecto,
        n.cod_financiera, pp.cod_ctaproyecto)) cod_apfc, pp.flg_movimiento
    from dbo.scp_planproyecto pp, #tmp001_numeracion n
    where
    hashbytes('md5', concat(pp.txt_anoproceso, pp.cod_proyecto)) = n.cod_ap
    and not nullif(nullif(substring(pp.cod_ctaproyecto,1,1),'I'),'') is null
    order by pp.txt_anoproceso, pp.cod_proyecto, n.cod_financiera,
    pp.cod_ctaproyecto offset 0 rows
)
,tmp001_proyFina as(
    select distinct t.txt_anoproceso, t.cod_proyecto, t.cod_financiera,
        tt.txt_descproyecto, ttt.txt_descfinanciera
    from tmp001_planProj t, dbo.scp_proyecto tt, dbo.scp_financiera ttt
    where t.cod_proyecto = tt.cod_proyecto
    and t.cod_financiera = ttt.cod_financiera
)
,tmp001_proyFinaHead as(
    select distinct
        t.txt_anoproceso, t.cod_proyecto, t.cod_financiera,
        t.txt_descfinanciera
    from tmp001_proyFina t union all
    select distinct
        t.txt_anoproceso, t.cod_proyecto, null, t.txt_descproyecto
    from tmp001_proyFina t
)
select -- concat(c.dato, (select r,
    t.ctaproyecto, -- t,
    convert(varchar(100), t.descrp), -- t,
    t.ppto, -- t,
    t.eje, -- t,
    t.ppto - t.eje -- , t,
    -- case isnull(t.flg_movimiento, 'S') when 'N' then 'S' else 'N' end
from(
    select
        t.txt_anoproceso, t.cod_proyecto, t.cod_financiera, t.cod_ctaproyecto,
        case
        when t.cod_financiera is null and t.cod_ctaproyecto is null
        then concat('PROY: ',t.cod_proyecto)
        when t.cod_ctaproyecto is null
        then concat('FINA: ',t.cod_financiera)
        else t.cod_ctaproyecto end ctaproyecto,
        case
        when t.cod_financiera is null and t.cod_ctaproyecto is null and t.ppto is null
        then max(t.totPrjPro)over(partition by t.txt_anoproceso, t.cod_proyecto)
        when t.cod_ctaproyecto is null and t.ppto is null
        then max(t.totfinPro)over(partition by t.txt_anoproceso, t.cod_proyecto, t.cod_financiera)
        else t.ppto end ppto,
        case
        when t.cod_financiera is null and t.cod_ctaproyecto is null and t.eje is null
        then max(t.totPrjEje)over(partition by t.txt_anoproceso, t.cod_proyecto)
        when t.cod_ctaproyecto is null and t.eje is null
        then max(t.totfinEje)over(partition by t.txt_anoproceso, t.cod_proyecto, t.cod_financiera)
        else t.eje end eje, t.descrp, t.flg_movimiento
    from(
        select t.txt_anoproceso, t.cod_proyecto, t.cod_financiera,
        t.cod_ctaproyecto, t.ppto, t.eje, t.totfinPro, t.totfinEje,
        t.totPrjPro, t.totPrjEje, t.descrp, t.flg_movimiento
        from(
            select row_number()over(partition by concat(t.item, t.cod_ctaproyecto)
            order by t.item, t.cod_ctaproyecto, t.ppto desc, t.eje desc) cta, *
            from(
                select distinct
                    t.txt_anoproceso, t.cod_proyecto, t.cod_financiera, t.item,
                    t.cod_ctaproyecto, t.ppto, t.eje, t.totfinPro, t.totfinEje,
                    t.totPrjPro, t.totPrjEje, t.descrp, t.flg_movimiento
                from(
                    select n.nivel, n.num, t.len, t.item,
                    t.txt_anoproceso, t.cod_proyecto, t.cod_financiera, t.cod_ctaproyecto,
                    isnull(case
                    when n.num = t.len and t.ppto is null
                    then sum(t.ppto)over(partition by concat(t.item, substring(t.cod_ctaproyecto, 1, n.num)))
                    else t.ppto end, 0) ppto,
                    isnull(case
                    when n.num = t.len and t.eje is null
                    then sum(t.eje )over(partition by concat(t.item, substring(t.cod_ctaproyecto, 1, n.num)))
                    else t.eje end, 0) eje,
                    t.totfinPro, t.totfinEje, t.totPrjPro, t.totPrjEje,
                    t.descrp, t.flg_movimiento
                    from(
                        select t.txt_anoproceso, t.cod_proyecto, t.cod_financiera, t.item,
                            t.cod_ctaproyecto, uu.num len, tt.ppto, ttt.eje,
                            t.txt_descctaproyecto descrp,
                            sum(tt.ppto)over(partition by t.item) totfinPro,
                            sum(ttt.eje)over(partition by t.item) totfinEje,
                            sum(tt.ppto)over(partition by t.prj) totPrjPro,
                            sum(ttt.eje)over(partition by t.prj) totPrjEje,
                            t.flg_movimiento
                        from tmp001_planProj t cross apply tmp001_niveles uu
                        outer apply(select*from tmp001_presupuesto tt where tt.cod_apfc = t.cod_apfc)tt
                        outer apply(select*from tmp001_gastos ttt where ttt.cod_apfc = t.cod_apfc)ttt
                        where len(t.cod_ctaproyecto) = uu.num
                        order by t.txt_anoproceso, t.cod_proyecto, t.cod_financiera,
                        t.cod_ctaproyecto offset 0 rows
                    )t
                    cross apply tmp001_niveles n
                    order by n.nivel, t.txt_anoproceso, t.cod_proyecto, t.cod_financiera,
                    t.cod_ctaproyecto offset 0 rows
                )t
                order by t.txt_anoproceso, t.cod_proyecto, t.cod_financiera,
                t.cod_ctaproyecto offset 0 rows
            )t
            order by t.txt_anoproceso, t.cod_proyecto, t.cod_financiera,
            t.cod_ctaproyecto offset 0 rows
        )t
        where t.cta = 1 union all
        select tt.txt_anoproceso, tt.cod_proyecto, tt.cod_financiera,
        null, null, null, null, null, null, null, tt.txt_descfinanciera, null
        from tmp001_proyFinaHead tt
    )t
    order by t.txt_anoproceso, t.cod_proyecto, t.cod_financiera,
    t.cod_ctaproyecto offset 0 rows
)t
order by t.txt_anoproceso, t.cod_proyecto,
t.cod_financiera, t.cod_ctaproyecto
-- for xml path, type).value('.','varchar(max)'))
-- from tmp001_sep, tmp001_cab c
