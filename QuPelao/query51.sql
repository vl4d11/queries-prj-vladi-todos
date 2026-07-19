use SCC_DESCOSUR_FALLA2

declare
    @txt_anoproceso varchar(4) = '2026',
    @cod_trabajador varchar(10) = 'E0034',
    @num_docidentidad varchar(15) = '47422172'


declare @cod_trabajador2 varchar(10), @cod_afp varchar(5), @nombres varchar(100)

select @nombres = concat(txt_paterno, ' ', txt_materno, ' ', txt_nombre), @cod_afp = cod_afp, @cod_trabajador2 = cod_trabajador
from dbo.MPP_EMPLEADO where cod_trabajador = @cod_trabajador and num_docidentidad = @num_docidentidad

select @nombres, @cod_afp

select row_number()over(order by case t.cod_conceptompp when '0205' then '0250' else t.cod_conceptompp end) item,*
into #MPP_CONCEPTOMPP
from(select t.cod_conceptompp, t.txt_descripcion, t.tip_concepto, tt.descr
from dbo.MPP_CONCEPTOMPP t,(values
('I','REMUNERACIONES/ INGRESOS VARIABLES'),
('A','APORTES EMPLEADO'),
('T','IMPUESTOS Y RETENCIONES'),
('D','DESCUENTOS'))tt(tip_concepto,descr)
where t.tip_concepto = tt.tip_concepto and t.cod_conceptompp != '0205' union all
select t.cod_conceptompp, t.txt_descripcion, 'E', 'APORTES EMPLEADOR'
from dbo.MPP_CONCEPTOMPP t where t.cod_conceptompp = '0205')t



select*from #MPP_CONCEPTOMPP order by item

select*from dbo.MPP_FINDEMES
where cod_trabajador = @cod_trabajador2 and txt_anoproceso = @txt_anoproceso
order by txt_mesproceso


select replace(concat('Trabajador (Rubro/Concepto)|', months, '|TOTAL'),',','|') tit
from sys.syslanguages where alias = 'Spanish'




-- select*from mastertable('MPP_FINDEMES')
-- select*from mastertable('MPP_CONCEPTOMPP')
-- select*from mastertable('MPP_EMPLEADO')


-- set rowcount 50

-- select * from MPP_FINDEMES
-- select * from MPP_CONCEPTOMPP
-- select * from MPP_EMPLEADO
