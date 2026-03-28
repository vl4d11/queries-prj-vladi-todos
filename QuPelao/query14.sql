use SCP_DOCUMENTO; select @@version

if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_get_diaHabil','if'))
drop function dbo.udf_get_diaHabil
go
create function dbo.udf_get_diaHabil(
    @cod_trabajador varchar(10)
)returns table as return(
    with tmp001_dias(dias) as(
        select stuff((select ',', replace(replace(t.days, ',Saturday,Sunday', ''), ',Sábado,Domingo', '')
        from sys.syslanguages t,(values('english'),('spanish'))tt(alias)
        where t.alias = tt.alias
        for xml path, type).value('.','varchar(max)'),1,1,'')
    )
    select count(1) diaHabil
    from(select t.fecha, patindex(concat('%', datename(dw, t.fecha),'%'), tt.dias) pos
    from(select cast(dateadd(dd, item, tt.fec_inicio) as date) fecha
    from(select row_number()over(order by (select 1)) -1 item
    from sys.fn_helpcollations())t cross apply mpp_permiso tt 
    where t.item < datediff(dd, tt.fec_inicio, tt.fec_termino) +1 and tt.cod_trabajador = @cod_trabajador)t
    cross apply tmp001_dias tt
    outer apply(select*from(select cast(concat(txt_anoproceso, '-', txt_mes, '-', txt_dia)as date) fecha 
    from dbo.gen_feriado)ttt where ttt.fecha = t.fecha)ttt
    where ttt.fecha is null)t where pos > 0
)
go


select*from dbo.udf_get_diaHabil('MRC040')

