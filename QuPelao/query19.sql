use SCP_DOCUMENTO; select @@version

--NOTA: CALCULO DEL CTS

Declare
@fecha_ingreso varchar(10) = '2025-01-23'


declare @current_year date = @fecha_ingreso, @total_dias int

if year(@current_year) = year(getdate()) select 'año actual'

select cast(concat(year(@current_year)-1,'1102') as date),  cast(concat(year(@current_year),'1030') as date)

select @total_dias = datediff(dd, cast(concat(year(@current_year)-1,'1102') as date),  cast(concat(year(@current_year),'1030') as date))









select @total_dias









return
select 
cast(concat(year(getdate()),'0430') as date) ffin_1q,
cast(concat(year(getdate()),'0501') as date) fini_2q, 
cast(concat(year(getdate()),'1030') as date) ffin_2q

