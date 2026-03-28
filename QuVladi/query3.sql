
;with tmp001_data as(
    select item,
    monto_total_transferencia_sat monto_inicial2,

    0 variacion2,

    case tipo when 'PAGO' then monto_total_transferencia_sat - monto 
    when 'COSTAS' then monto_total_transferencia_sat
    when 'VARIACION_ANUAL' then monto_total_transferencia_sat
    else 0 end insoluto2,

    case tipo when 'COSTAS' then monto else 0 end costas_acum2,

    (case tipo when 'PAGO' then monto_total_transferencia_sat - monto 
    when 'VARIACION_ANUAL' then monto_total_transferencia_sat
    else 0 end) + (case tipo when 'COSTAS' then monto else 0 end) deuda2,

    anio
    from(select top 1 CAST(REPLACE(Total, ',', '') AS DECIMAL(12, 2)) monto_total_transferencia_sat
    FROM REPORT.ActaTransferencia where DocDeuda = @ACTA)t, 
    (select*from #tmp_pagos2 where item = 1)tt

    union all 

    select t.item + 1 item,
    case when tt.item > 1 and not tt.anio is null and tt.anio = t.anio then 
        t.insoluto2 
    when tt.item > 1 and not tt.anio is null and tt.anio != t.anio then
        t.insoluto2
    end monto_inicial2,

    case when tt.item > 1 and not tt.anio is null and tt.anio = t.anio then 
        t.variacion2
    when tt.item > 1 and not tt.anio is null and tt.anio != t.anio then
        ((select valor from config.uit where ano = tt.anio) -
         (select valor from config.uit where ano =  t.anio))* @PORCENTAJE_MULTA / 100
    end variacion2,

    case when tt.item > 1 and not tt.anio is null and tt.anio = t.anio then 
        case tt.tipo when 'COSTAS' then
            tt.monto_inicial + tt.variacion
        when 'PAGO' then
            case when t.costas_acum2 > 0 then
                case when tt.monto >= t.costas_acum2 then
                    iif((tt.monto - t.costas_acum2) >= t.insoluto2, 
                        (tt.monto - t.costas_acum2) - tt.monto_inicial + tt.variacion,
                        tt.monto_inicial - (tt.monto - t.costas_acum2) + tt.variacion
                    )
                else
                    tt.monto_inicial + tt.variacion
                end
            else
                tt.monto_inicial + tt.variacion - tt.monto
            end
        end
    when tt.item > 1 and not tt.anio is null and tt.anio != t.anio then 
        case tt.tipo when 'COSTAS' then
            tt.monto_inicial + tt.variacion
        when 'PAGO' then
            case when t.costas_acum2 > 0 then
                case when tt.monto >= t.costas_acum2 then
                    iif((tt.monto - t.costas_acum2) > t.insoluto2, 
                        (tt.monto - t.costas_acum2) - tt.monto_inicial + tt.variacion,
                        tt.monto_inicial - (tt.monto - t.costas_acum2) + tt.variacion
                    )
                else
                    tt.monto_inicial + tt.variacion
                end
            else
                tt.monto_inicial + tt.variacion - tt.monto
            end
        when 'VARIACION_ANUAL' then
            case when t.deuda2 > 0 then
                tt.monto_inicial + tt.variacion
            else
                0
            end
        end
    end insoluto2,

    case when tt.item > 1 and not tt.anio is null and tt.anio = t.anio then
        case tt.tipo when 'COSTAS' then
            tt.monto + t.costas_acum2 
        when 'PAGO' then
            case when t.costas_acum2 > 0 then
                case when tt.monto >= t.costas_acum2 then
                    0
                else
                    t.costas_acum2 - tt.monto
                end
            else
                t.costas_acum2
            end
        end
    when tt.item > 1 and not tt.anio is null and tt.anio != t.anio then 
        case tt.tipo when 'COSTAS' then
            tt.monto  + t.costas_acum2
        when 'PAGO' then
            case when t.costas_acum2 > 0 then
                case when tt.monto >= t.costas_acum2 then
                    0
                else
                    t.costas_acum2 - tt.monto
                end
            else
                t.costas_acum2
            end
        when 'VARIACION_ANUAL' then
            case when t.deuda2 > 0 then
                t.costas_acum2
            else
                0
            end
        end
    end costas_acum2,

    case when tt.item > 1 and not tt.anio is null and tt.anio = t.anio then
        case tt.tipo when 'COSTAS' then
            (tt.monto_inicial + tt.variacion) + (tt.monto + t.costas_acum2)
        when 'PAGO' then
            case when t.costas_acum2 > 0 then
                case when tt.monto >= t.costas_acum2 then
                    tt.insoluto + tt.costas_acum
                else
                    (tt.monto_inicial + tt.variacion) + (t.costas_acum2 - tt.monto)
                end
            else
                (tt.monto_inicial + tt.variacion - tt.monto) + t.costas_acum2
            end
        end
    when tt.item > 1 and not tt.anio is null and tt.anio != t.anio then 
        case tt.tipo when 'COSTAS' then
            (tt.monto_inicial + tt.variacion) + (tt.monto + t.costas_acum2)
        when 'PAGO' then
            case when t.costas_acum2 > 0 then
                case when tt.monto >= t.costas_acum2 then
                    tt.insoluto + tt.costas_acum
                else
                    (tt.monto_inicial + tt.variacion) + (t.costas_acum2 - tt.monto)
                end
            else
                (tt.monto_inicial + tt.variacion - tt.monto) + t.costas_acum2
            end
        when 'VARIACION_ANUAL' then
            case when t.deuda2 > 0 then
                tt.monto_inicial + tt.variacion + t.costas_acum2
            else
                0
            end
        end
    end deuda2

    from tmp001_data t, #tmp_pagos2 tt
    where t.item = tt.item
)
select*from tmp001_data

