if exists(select 1 from sys.sysobjects where id = object_id('dbo.usp_listarLoteAcopioMinero','p'))
drop procedure dbo.usp_listarLoteAcopioMinero
go
create procedure dbo.usp_listarLoteAcopioMinero
@data varchar(max)
as
begin
begin try
set nocount on
set language english

create table #tmp001_param (
    id int identity,
    codigo varchar(20) collate database_default
)
insert into #tmp001_param
select value from dbo.udf_split(@data, default)

;with tmp001_sep(t,r,i)as(
    select*from(values('|','~','^'))t(sepCamp,sepReg,sepList)
)
,tmp001_cab(dato)as(
    select concat(
    'Documento|id|gen|val|sub|Proceso|Fecha Registro|Usuario Registro|Usuario Sube|Fecha Sube', r,
    '10|10|10|10|10|400|150|200|200|150')
    from tmp001_sep
)
,tmp001_cta(tipo)as(
    select count(1) from #tmp001_param
)
,tmp001_lote(Lote_Nro, tipo) as(
    select t.codigo, tt.tipo from #tmp001_param t, tmp001_cta tt
    where t.id = 1
)
,tmp001_minero(Minero_Id)as(
    select codigo from #tmp001_param where id > 1
)
,tmp001_lotes as(
    select t.Lote_Id, t.Lote_Nro, t.Facturador_Id, t.Minero_Id
    from dbo.AC10_Lotes t cross apply tmp001_lote tt
    outer apply(select*from tmp001_minero ttt
        where case ttt.Minero_Id when 'A'
        then t.Minero_id else ttt.Minero_id end = t.Minero_Id
    )ttt
    where case tt.tipo when 1 then t.lote_id else
        try_cast(stuff(t.Lote_Nro,1,3,'') as int) end = cast(tt.Lote_Nro as int)
        and (tt.tipo = 1 or not ttt.Minero_Id is null)
)
,tmp001_texto_cabecera(dato) as(
    select concat(t.Lote_Nro, t, tt.Estado_Lote, t, f.Razon_Social, t, m.Nom_Minero, r)
    from(select top 1
        tt.Lote_Id, tt.Tipo_Doc_Id, t.Lote_Nro, t.Facturador_Id, t.Minero_Id
        from tmp001_lotes t, dbo.AC10_Lotes_Docs tt
        where t.Lote_Id = tt.Lote_Id order by tt.crea_fecha desc
        )t,
    dbo.AC00_TiposDocs tt, dbo.AC00_Facturadores f, dbo.AC00_Mineros m, tmp001_sep
    where t.Tipo_Doc_Id = tt.DocTipo_Id and t.Facturador_Id = f.facturador_Id
    and t.Minero_Id = m.Minero_Id
)
select concat(cc.dato, c.dato, (
    select r, documento, t, id, t, gen, t, val, t, sub, t, proceso, t,
    convert(varchar, fecha, 23), usuario, t, convert(varchar, subeFecha, 23)
from(
    select concat(l.Lote_Nro,'-',td.Cod_Archivo),
    d.Id_Doc, isnull(d.Generado, 0), d.EsValido, d.SubioArchivo,
    concat(td.Proceso,' ',td.nombre), d.Crea_Fecha, p.usuarios, d.Sube_Fecha
    from dbo.AC10_Lotes_Docs d
    cross apply tmp001_lotes l
    cross apply dbo.AC00_TiposDocs td
    cross apply dbo.udf_usuariosAcopioMinero09(d.Crea_Id, d.Sube_Id) p
    where d.Lote_Id = l.Lote_Id
    and d.Tipo_Doc_Id = td.DocTipo_Id
)t(documento, id, gen, val, sub, proceso, fecha, usuario, subeFecha) order by fecha
for xml path, type).value('.', 'varchar(max)'))
from tmp001_sep, tmp001_cab c, tmp001_texto_cabecera cc

end try
begin catch
    select concat('error:', error_message())
end catch
end
go



-- return
declare @data1 varchar(max)
-- = '314|A'
-- = '296|A'
-- = '296|7|12|14|18|19|28|29|33|38'
-- = '296|7|12|14|18|19|28|29|33|38|31'
= 262

exec dbo.usp_listarLoteAcopioMinero @data1


select*from mastertable('dbo.AC10_Lotes_Docs')

set rowcount 10
select Id_Doc, Generado, EsValido, Sube_Id, Sube_Fecha
from dbo.AC10_Lotes_Docs
