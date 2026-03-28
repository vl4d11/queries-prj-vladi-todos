use SCP_CNDH
go
declare @data varchar(max)
='30/01/2023|31/12/2023|02|2023'

set language spanish
select top 0
cast(null as date) FechaInicial,
cast(null as date) FechaFinal,
cast(null as varchar(2)) collate database_default Moneda,
cast(null as varchar(4)) collate database_default PeriodoPpto
into #tmp001_param

select @data = dato from dbo.udf_splice(@data, default, default)
insert into #tmp001_param exec(@data)

;with tmp001_sep(t,r,i)as(
    select*from(values('|','~','^'))t(sepCampo,sepReg,sepLst)
)
,tmp001_cab(dato) as(
    select concat(
    'COD PROYECTO|DESCRIPCION|GASTO|PRESUPUESTO|SALDO|PORCENTAJE', r,
    '50|250|50|50|50|50', r,
    'String|String|String|String|String|String')
    from tmp001_sep
)
,tmp001_presupuesto as(
    select top 1 with ties
    t.cod_proyecto,
    sum(m.monto)over(partition by t.cod_proyecto) presupuesto
    from dbo.scp_presupuestoproyecto t
    cross apply #tmp001_param pp
    cross apply(
        select
        t.num_ppto00+t.num_ppto01+t.num_ppto02+t.num_ppto03+
        t.num_ppto04+t.num_ppto05+t.num_ppto06+t.num_ppto07+
        t.num_ppto08+t.num_ppto09+t.num_ppto10+t.num_ppto11+
        t.num_ppto12 monto
    )m
    where t.txt_anoproceso = pp.PeriodoPpto and
    t.cod_tipomoneda = pp.Moneda
    order by
    row_number()over(partition by t.cod_proyecto order by t.cod_proyecto)
)
,tmp001_gastoPres as(
    select top 1 with ties
    tt.cod_proyecto,
    isnull(j.txt_descproyecto, '') txt_descproyecto,
    sum(m.monto)over(partition by tt.cod_proyecto) gasto,
    ttt.presupuesto
    from dbo.scp_comprobanteCabecera t
    cross apply dbo.scp_comprobanteDetalle tt
    cross apply #tmp001_param pp
    cross apply(
        select case pp.Moneda
        when '01' then tt.num_debesol-tt.num_habersol
        when '02' then tt.num_debedolar-tt.num_haberdolar
        else tt.num_debemo-tt.num_habermo end monto
    )m
    outer apply(
        select*from dbo.scp_plancontable p
        where p.txt_anoproceso = tt.txt_anoproceso and
        p.cod_ctacontable = tt.cod_ctacontable)p
    outer apply(
        select*from dbo.scp_proyecto j
        where j.cod_proyecto = tt.cod_proyecto)j
    outer apply(
        select*from tmp001_presupuesto ttt
        where ttt.cod_proyecto = tt.cod_proyecto
    )ttt
    where
        t.txt_anoproceso = tt.txt_anoproceso
        and t.cod_filial = tt.cod_filial
        and t.cod_mes = tt.cod_mes
        and t.cod_origen = tt.cod_origen
        and t.cod_comprobante = tt.cod_comprobante
        and t.fec_comprobante between pp.FechaInicial and pp.FechaFinal
        and ltrim(tt.cod_proyecto) != ''
        and p.flg_gasto = 'S'
    order by
    row_number()over(partition by tt.cod_proyecto order by tt.cod_proyecto)
)
select concat(c.dato, (select r,
cod_proyecto, t, txt_descproyecto, t, gasto, t,
ltrim(str(Presupuesto, 15, 2)), t,
ltrim(str(gasto - Presupuesto, 15, 2)), t,
ltrim(str((gasto/Presupuesto) * 100, 15, 2))
from tmp001_gastoPres
order by cod_proyecto
for xml path, type).value('.','varchar(max)'))
from tmp001_sep, tmp001_cab c
