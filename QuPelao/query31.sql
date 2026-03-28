use SCP_CORRELATIVO

declare
@trama varchar(max)
 = '2025|08|15300384'

select top 0
cast(null as varchar(4)) anno,
cast(null as varchar(2)) mes,
cast(null as varchar(15)) codigo into #tmp001_param
select @trama = concat('select*from(values(''',
replace(@trama, '|', ''','''), '''))t(a1,a2,a3)')
insert into #tmp001_param exec(@trama)

;with tmp001_sep(t,r,i,a)as(
    select*from(values('|','¬','~',' '))t(sepCamp,sepReg,sepList,sepAux)
)
,tmp001_cab(dato) as(
select 'Fecha|Número|Motivo|Responsble|Estado¬\
70|70|450|500|200¬String|String|String|String|String'
)
,tmp001_oficina(dato) as(
    select concat(i,stuff((select r, cod_filial, t, txt_descripcion
    from dbo.scp_filial order by txt_descripcion
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_tipoMoneda(dato)as(
    select concat(i,stuff((select r, cod_tipomoneda, t, txt_descripcion
    from dbo.scp_tipomoneda order by cod_tipomoneda
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_proveedores(dato)as(
    select concat(i,'Código|Nombre', r, '10%|22%',(select r, cod_destino, t,
    ltrim(txt_nombre), a, ltrim(txt_apellidopaterno), a, ltrim(txt_apellidomaterno)
    from dbo.scp_destino order by txt_nombre
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,tmp001_tipoAsiento(dato)as(
    select concat(i,stuff((select r, cod_asiento, t, txt_descripcion
    from dbo.scp_tipoasiento
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_proyecto(dato)as(
    select concat(i,'Código|Proyecto', r, '10%|22%',(select r,
    cod_proyecto, t, txt_descproyecto
    from dbo.scp_proyecto order by cod_proyecto
    for xml path, type).value('.','varchar(max)'))
    from tmp001_sep
)
,tmp001_lugarGasto(dato)as(
    select concat(i,stuff((select r, cod_contraparte, t, txt_desccontraparte
    from dbo.scp_contraparte
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_comprobantePago(dato)as(
    select concat(i,stuff((select r, cod_tipocomprobantepago, t, txt_descripcion
    from dbo.scp_comprobantepago
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_compras(dato)as(
    select concat(i,stuff((select r, cod_registrocompraventa, t, rtrim(txt_descripcion)
    from dbo.scp_compraventa
    where substring(cod_registrocompraventa, 1,1) = 'C'
    for xml path, type).value('.','varchar(max)'),1,0,''))
    from tmp001_sep
)
,tmp001_annosFiscales(dato)as(
    select concat(i,stuff((select r, txt_anoproceso
    from dbo.scp_controlperiodo order by txt_anoproceso desc
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_tipoDocumentos(dato)as(
    select concat(i,stuff((select r, cod_tipodocumento, t, txt_descripcion
    from dbo.scp_tipodocumento
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_tipoCuenta(dato)as(
    select concat(i,stuff((select r, cod_tipocuenta, t, txt_tipocuenta
    from dbo.scp_TipoCuenta where txt_anoproceso = p.anno
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep, #tmp001_param p
)
,tmp001_banco(dato)as(
    select concat(i,stuff((select r, cod_banco, t, txt_descripcion
    from dbo.scp_banco order by cod_banco
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_tipoCtaBanco(dato)as(
    select concat(i,stuff((select r, cod_tipoctabanco, t, txt_descripcion
    from dbo.scp_tipoctabanco order by cod_tipoctabanco
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_tasaDetraccion(dato)as(
    select concat(i,stuff((select r, cod_detraccion, t,
    num_porcentaje, ' - ', txt_descripcion
    from dbo.scp_detraccion order by cod_detraccion
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_regSolicitantes(dato)as(
    select concat(i,stuff((select r, cod_destino, t, txt_nombredestino
    from dbo.scp_destino order by txt_nombre
    for xml path, type).value('.','varchar(max)'),1,1,''))
    from tmp001_sep
)
,tmp001_perfilUsuario as(
    select d.num_idperfil
    from dbo.msg_usuario u, dbo.scp_destino d, #tmp001_param p
    where u.cod_destino = d.cod_destino and u.cod_destino = p.codigo
)
,tmp001_perfilEstadoOrden as(
    select*from(values (0,0),
    (1,20),(1,21),(1,22),
    (2,22),(2,23),(2,24),
    (3,24),(3,25),(3,26))v(num_idperfil, num_idestado)
)
select concat(cab.dato,(select r,
Convert(varchar,A.fec_orden,103), t,  A.txt_numeroorden, t,
A.txt_motivo, t, B.txt_nombredestino, t, C.txt_accion
From dbo.mco_cabeceraorden A cross apply dbo.mco_estado C
cross apply #tmp001_param pp
cross apply tmp001_perfilUsuario per
outer apply(select*from dbo.scp_destino B where B.cod_destino = A.cod_responsable)B
outer apply(select*from tmp001_perfilEstadoOrden est
where est.num_idperfil = per.num_idperfil and per.num_idperfil != 0)est
outer apply(select*from dbo.mco_supervisado su
where su.cod_supervisor = pp.codigo and per.num_idperfil = 1)su
Where A.txt_anoproceso = pp.anno
and A.cod_mes = pp.mes and
case per.num_idperfil when 0 then A.cod_responsable else A.cod_estado end =
case per.num_idperfil when 0 then pp.codigo else est.num_idestado end
and (per.num_idperfil != 1 or A.cod_responsable = su.cod_responsable)
and A.cod_estado = C.num_idestado
Order By A.fec_orden, Substring(A.txt_numeroorden,3,2)
for xml path, type).value('.','varchar(max)'),
t1.dato, t2.dato, t3.dato, t4.dato, t5.dato, t6.dato, t7.dato, t8.dato,
t9.dato, t10.dato, t11.dato, t12.dato, t13.dato, t14.dato, t15.dato)
from tmp001_sep, tmp001_cab cab,
tmp001_oficina t1,
tmp001_tipoMoneda t2,
tmp001_proveedores t3,
tmp001_tipoAsiento t4,
tmp001_proyecto t5,
tmp001_lugarGasto t6,
tmp001_comprobantePago t7,
tmp001_compras t8,
tmp001_annosFiscales t9,
tmp001_tipoDocumentos t10,
tmp001_tipoCuenta t11,
tmp001_banco t12,
tmp001_tipoCtaBanco t13,
tmp001_tasaDetraccion t14,
tmp001_regSolicitantes t15
