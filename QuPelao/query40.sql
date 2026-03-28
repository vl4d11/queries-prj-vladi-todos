use SCP_VASJA
go
set language spanish

-- exec dbo.seguimiento_datos_ingreso '01/01/2025','31/12/2025','','','','','*','1'
-- select text from sys.syscomments where id = object_id('dbo.resumen_x_proyecto_pa_lst_ingreso', 'p')

-- CREATE procedure dbo.seguimiento_datos_ingreso
declare
    @par_fecha_ini		char(10),
	@par_fecha_fin		char(10),
	@par_letra			varchar(14),
	@par_contrapar_ini	varchar(6),
	@par_contrapar_fin	varchar(6),
	@par_cod_pry_ini	varchar(6),
	@par_cod_pry_fin	varchar(6),
	@par_verDetalle		tinyint
-- as
-- begin
-- set nocount on
Declare
		@tbl		dbo.tbl_contraparte_proyecto_ingreso,
		@tblSource	dbo.sourceContraparte_ingreso

-- insert into @tblSource
-- exec dbo.resumen_x_proyecto_pa_lst_ingreso @par_fecha_ini, @par_fecha_fin, @par_letra, @par_contrapar_ini, @par_contrapar_fin, @par_cod_pry_ini, @par_cod_pry_fin


-- insert into @tbl
-- select item, cod_ctaespecial, cod_contraparte, cod_proyecto, brk_codCpte, brk_codCpte_X_pry, total_codCpteS, total_codCpteD, total_codCpteE, total_codPryS, total_codPryD, total_codPryE, txt_DescContraparte, txt_descproyecto, txt_gasto, txt_fecha, txt_glosaItem
-- from @tblSource order by item asc

-- select t.* from @tblSource s
-- cross apply(select cuentas, soles, dolares, euros, cta, letra from dbo.target_contraparte_x_pry_tf_back(left(s.cod_ctaespecial, 1), @tbl, @tblSource, @par_verDetalle))t
-- where s.gp1 = 1
-- order by s.item asc


create function dbo.target_contraparte_x_pry_tf_back(
	@par_letra				char(1),
	@par_tblSource_filtro	dbo.tbl_contraparte_proyecto_ingreso readonly,
	@par_tblSource			dbo.sourceContraparte_ingreso readonly,
	@par_verDetalle tinyint
)returns @salida table(	item	int identity(1,1),
						cuentas varchar(1000),
						soles	numeric(10,2),
						dolares numeric(10,2),
						euros	numeric(10,2),
						cta		varchar(1),
						letra	 char(1))
as
begin
Declare @tmpT001Ejemplo table(	item	 int identity(1,1),
								cabecera varchar(1000),
								soles	 numeric(10,2),
								dolares	 numeric(10,2),
								euros	 numeric(10,2),
								cta		 varchar(14),
								letra	 char(1))
Declare @tmpT011Ejemplo table(	item	 int,
								cabecera varchar(1000),
								soles	 numeric(10,2),
								dolares	 numeric(10,2),
								euros	 numeric(10,2),
								cta		 varchar(14),
								letra	 char(1))

	insert into @tmpT001Ejemplo
	select	t.*
	from	@par_tblSource x
	cross apply(select * from dbo.descripcion_cta_cab_tf_back(cod_ctaespecial, total_gp1S, total_gp1D, total_gp1E, total_gp2S, total_gp2D, total_gp2E,
	total_gp3S, total_gp3D, total_gp3E, total_gp4S, total_gp4D, total_gp4E, total_gp5S, total_gp5D, total_gp5E, total_gp6S, total_gp6D, total_gp6E, total_gp7S, total_gp7D, total_gp7E, @par_tblSource_filtro, @par_verDetalle))t
	where	left(x.cod_ctaespecial,1) = @par_letra and x.gp7 = 1
	order by x.item asc


	insert into @tmpT011Ejemplo
	select item, cabecera, soles, dolares, euros, cta, letra from (
		select nro = row_number()over(partition by cta order by item, cta), *
		from @tmpT001Ejemplo)t
	where t.nro = 1 or t.cta = ''
	order by t.item asc

	update t set cta = '' from @tmpT011Ejemplo t
	update t set cta = '*'from @tmpT011Ejemplo t where item = 1

	insert into @salida
	select cabecera, soles, dolares, euros, cta, letra from @tmpT011Ejemplo order by item

return
end



go
alter procedure dbo.resumen_x_proyecto_pa_lst_ingreso
	@par_fecha_ini		char(10),
	@par_fecha_fin		char(10),
	@par_ctaespecial	varchar(14),
	@par_contrapar_ini	varchar(6),
	@par_contrapar_fin	varchar(6),
	@par_cod_pry_ini	varchar(6),
	@par_cod_pry_fin	varchar(6)
as
begin
set nocount on
set language spanish
Declare
		@aux_flg_gasto	char(1) = 'S',
		@aux_fecha_ini	date = @par_fecha_ini,
		@aux_fecha_fin	date = @par_fecha_fin

select
	item= row_number()over(order by t.cod_cta1),
	gp1 = row_number()over(partition by t.cod_cta1 order by t.cod_cta1, cod_ctaespecial, cod_proyecto),
	gp2 = row_number()over(partition by t.cod_cta1, t.cod_cta2 order by t.cod_cta1, t.cod_cta2, cod_ctaespecial, cod_proyecto),
	gp3 = row_number()over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3 order by t.cod_cta1, t.cod_cta2, t.cod_cta3, cod_ctaespecial, cod_proyecto),
	gp4 = row_number()over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4 order by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, cod_ctaespecial, cod_proyecto),
	gp5 = row_number()over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5 order by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, cod_ctaespecial, cod_proyecto),
	gp6 = row_number()over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6 order by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, cod_ctaespecial, cod_proyecto),
	gp7 = row_number()over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7 order by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7, cod_ctaespecial, cod_proyecto),
	brk_codCpte = 1,
	brk_codCpte_X_pry = row_number()over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7, cod_proyecto  order by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7, cod_proyecto),
	cod_ctaespecial, '' cod_contraparte, cod_proyecto,
	total_gp1S = case when cod_cta1 !='' then sum(num_debesol	- num_habersol  )over(partition by t.cod_cta1)else 0 end,
	total_gp1D = case when cod_cta1 !='' then sum(num_debedolar - num_haberdolar)over(partition by t.cod_cta1)else 0 end,
	total_gp1E = case when cod_cta1 !='' then sum(num_debemo	- num_habermo	)over(partition by t.cod_cta1)else 0 end,
	total_gp2S = case when cod_cta2 !='' then sum(num_debesol	- num_habersol  )over(partition by t.cod_cta1, t.cod_cta2)else 0 end,
	total_gp2D = case when cod_cta2 !='' then sum(num_debedolar - num_haberdolar)over(partition by t.cod_cta1, t.cod_cta2)else 0 end,
	total_gp2E = case when cod_cta2 !='' then sum(num_debemo	- num_habermo	)over(partition by t.cod_cta1, t.cod_cta2)else 0 end,
	total_gp3S = case when cod_cta3 !='' then sum(num_debesol	- num_habersol  )over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3)else 0 end,
	total_gp3D = case when cod_cta3 !='' then sum(num_debedolar - num_haberdolar)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3)else 0 end,
	total_gp3E = case when cod_cta3 !='' then sum(num_debemo	- num_habermo	)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3)else 0 end,
	total_gp4S = case when cod_cta4 !='' then sum(num_debesol	- num_habersol  )over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4)else 0 end,
	total_gp4D = case when cod_cta4 !='' then sum(num_debedolar - num_haberdolar)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4)else 0 end,
	total_gp4E = case when cod_cta4 !='' then sum(num_debemo	- num_habermo	)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4)else 0 end,
	total_gp5S = case when cod_cta5 !='' then sum(num_debesol	- num_habersol  )over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5)else 0 end,
	total_gp5D = case when cod_cta5 !='' then sum(num_debedolar - num_haberdolar)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5)else 0 end,
	total_gp5E = case when cod_cta5 !='' then sum(num_debemo	- num_habermo	)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5)else 0 end,
	total_gp6S = case when cod_cta6 !='' then sum(num_debesol	- num_habersol  )over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6)else 0 end,
	total_gp6D = case when cod_cta6 !='' then sum(num_debedolar - num_haberdolar)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6)else 0 end,
	total_gp6E = case when cod_cta6 !='' then sum(num_debemo	- num_habermo	)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6)else 0 end,
	total_gp7S = case when cod_cta7 !='' then sum(num_debesol	- num_habersol  )over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7)else 0 end,
	total_gp7D = case when cod_cta7 !='' then sum(num_debedolar - num_haberdolar)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7)else 0 end,
	total_gp7E = case when cod_cta7 !='' then sum(num_debemo	- num_habermo	)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7)else 0 end,
	total_codCpteS = num_debesol	- num_habersol,
	total_codCpteD = num_debedolar	- num_haberdolar,
	total_codCpteE = num_debemo		- num_habermo,
	total_codPryS  = sum(num_debesol	- num_habersol  )over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7, cod_proyecto),
	total_codPryD  = sum(num_debedolar	- num_haberdolar)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7, cod_proyecto),
	total_codPryE  = sum(num_debemo		- num_habermo	)over(partition by t.cod_cta1, t.cod_cta2, t.cod_cta3, t.cod_cta4, t.cod_cta5, t.cod_cta6, t.cod_cta7, cod_proyecto),
	tt.txt_descproyecto, '' txt_DescContraparte,
	gasto = convert(varchar, fec_comprobante, 103) + space(5) + rtrim(ltrim(isnull(txt_nombredestino + ' - ', ''))) + rtrim(ltrim(txt_glosaitem)),
	fecha = cast(fec_comprobante as date), txt_glosaitem

from dbo.scp_comprobantedetalle d
	cross apply(select flg_gasto from dbo.scp_plancontable where txt_anoproceso = d.txt_anoproceso and cod_ctacontable = d.cod_ctacontable and left(ltrim(d.cod_ctacontable), 2) in ('46','75'))f
	cross apply(select txt_descctaespecial, cod_cta1, cod_cta2, cod_cta3, cod_cta4, cod_cta5, cod_cta6, cod_cta7 from dbo.scp_planespecial where txt_anoproceso = d.txt_anoproceso and cod_ctaespecial = d.cod_ctaespecial)t
	cross apply(select txt_descproyecto from dbo.scp_proyecto where cod_proyecto = d.cod_proyecto)tt
	outer apply(select txt_nombredestino from dbo.scp_destino where cod_destino = d.cod_destino)ttt
--cross apply(select txt_DescContraparte from dbo.scp_Contraparte where cod_contraparte = d.cod_contraparte)ttt
where	d.cod_ctaespecial != '0'
	and d.cod_ctaespecial != ''
	and left(ltrim(d.cod_ctaespecial), 1) = 'I'
	and not d.cod_mes in ('00', '13')
	--and d.cod_contraparte != ''
	and d.fec_comprobante between @aux_fecha_ini and @aux_fecha_fin
	and (@par_ctaespecial = '*' or (left(d.cod_ctaespecial, len(@par_ctaespecial)) = @par_ctaespecial))
	--and (@par_contrapar_ini = '*' or (d.cod_contraparte between @par_contrapar_ini and case @par_contrapar_fin when '*' then @par_contrapar_ini else @par_contrapar_fin end))
	and (@par_cod_pry_ini = '*' or (d.cod_proyecto between @par_cod_pry_ini and case @par_cod_pry_fin when '*' then @par_cod_pry_ini else @par_cod_pry_fin end))
order by item asc
