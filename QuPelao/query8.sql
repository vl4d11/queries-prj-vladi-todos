use SCP_CEDIA;
set language spanish


Declare
	@num_mesgenerado varchar(2) = '12',
	@num_mesinicial varchar(2)='12',
	@num_mesfinal varchar(2)= '12',
	@fec_emision date = '25/12/2024',
	@cod_trabajador varchar(10) = '999999',
	@flg_moneda char(1) = '1',
	@num_tipocambio decimal(6,3) = 1,
	@cod_oficina varchar(2) = '01',
	@num_periodo varchar(4) = '2024'



Select A.cod_trabajador, A.txt_diaproceso, A.txt_mesproceso, 
A.txt_anoproceso, A.num_dias, A.num_horas, A.num_horasextras,
Isnull(Ltrim(B.txt_paterno),'') + ' ' + 
Isnull(Ltrim(B.txt_materno),'') + ' ' + 
Isnull(Ltrim(B.txt_nombre),'') As txt_nombre,
Isnull(Ltrim(K.txt_descripcion),'') As txt_tipotrabajador,
Isnull(Ltrim(C.txt_descripcion),'') As txt_cargo,
Isnull(Ltrim(I.txt_descripcion),'') As txt_tipodocumento,
Isnull(D.num_docidentidad,'') As num_docidentidad,
Isnull(D.num_cuspp,'') As num_cuspp,
Isnull(B.txt_autogenerado,'') As txt_autogenerado,
Isnull(E.txt_descripcion,'') As txt_afp,
Isnull(D.fec_ingreso,'') As fec_ingreso,
Case Isnull(Convert(Char(10),D.fec_cese,103),'')
When '01/01/1900' Then ' ' Else Convert(Char(10),D.fec_cese,103)
End fec_cese,
Isnull(Convert(Char(10),H.fec_programada,103),'') As fec_iniciovacacion,
Isnull(Convert(Char(10),H.fec_retorno,103),'') As fec_finvacacion,
Space(1) As fec_iniciolicencia,
Space(1) As fec_finlicencia,
Isnull(Convert(Char(10),J.fec_inicio,103),'') As fec_ilicencia,
Isnull(Convert(Char(10),J.fec_termino,103),'') As fec_flicencia,
Isnull(F.txt_descripcion,'') As txt_mespago,
'R.U.C. ' + Isnull(G.num_ruc,'') + ', ' + Isnull(G.txt_direccion,'') + ', ' + 
Isnull(G.txt_distrito,'') As txt_direccion,
1 as num_pago,
A.num_0101, A.num_0102, A.num_0103, A.num_0104, A.num_0105, A.num_0106, 
A.num_0107, A.num_0108, A.num_0109, A.num_0110, A.num_0111, A.num_0112, 
A.num_0113, A.num_0114, A.num_0115, A.num_0116, A.num_0117, A.num_0118,
A.num_0119, A.num_0120, A.num_0121, A.num_0122, A.num_0123, A.num_0124,
A.num_0125, A.num_0126, A.num_0127, A.num_0128, A.num_0129, A.num_0130,
A.num_0201, A.num_0202, A.num_0203, A.num_0204, A.num_0205, A.num_0206,
A.num_0207, A.num_0208,
A.num_0301, 
A.num_0401, A.num_0402, A.num_0403, A.num_0404, A.num_0405, A.num_0406, 
A.num_0407, A.num_0408, A.num_0409, A.num_0410, A.num_0411, A.num_0412, 
A.num_0413, A.num_0414, A.num_0415, A.num_0416, A.num_0417, A.num_0418, 
A.num_0419, A.num_0420, Isnull(B.cod_oficina,'') As cod_oficina,
Isnull(B.tip_comision,'') As tip_comision,
Isnull(D.num_comisionvar,0) As num_comisionvar,
Isnull(D.num_comisionmixta,0) As num_comisionmixta,
Isnull(D.num_seguroinv,0) As num_seguroinv,
Isnull(D.num_aporteobl,0) As num_aporteobl,
txt_paterno, fec_programada
into #tmp001_rpta
From mpp_findemes A
Left Outer Join mpp_empleado B On Ltrim(B.cod_trabajador) = Ltrim(A.cod_trabajador)
Left Outer Join mpp_cargo C On Ltrim(C.cod_cargo) = Ltrim(B.cod_cargo)
Left Outer Join mpp_historico D On D.txt_mesproceso = @num_mesgenerado
And D.txt_anoproceso = @num_periodo
And D.cod_trabajador = B.cod_trabajador
Left Outer Join mpp_afp E On E.cod_afp = D.cod_afp
Left Outer Join mpp_mesquinta F On F.cod_mes = @num_mesgenerado
Left Outer Join mpp_institucional G On G.num_periodo = @num_periodo
Left Outer Join mpp_vacacion H On H.num_periodo = @num_periodo
And H.cod_trabajador = A.cod_trabajador
And Substring(Convert(Char(10),H.fec_programada,103),4,2) = @num_mesgenerado
Left Outer Join mpp_permiso J On J.num_periodo = @num_periodo
And J.cod_trabajador = A.cod_trabajador
And J.cod_mes = @num_mesgenerado
Left Outer Join scp_tipodocumento I On I.cod_tipodocumento = B.cod_tipodocu
Left Outer Join mpp_tipodetrabajador K On K.tip_trabajador = B.tip_trabajador
Where (Substring(@cod_trabajador,4,3) = Substring(A.cod_trabajador,4,3) 
      Or (Substring(@cod_trabajador,4,3) <> Substring(A.cod_trabajador,4,3) 
      And Substring(@cod_trabajador,4,3)= '999'))
	  And A.txt_mesproceso = @num_mesgenerado And A.txt_anoproceso = @num_periodo	
Order By B.txt_paterno offset 0 rows 


;with tmp002_rpta as(
	select*from(select cod_trabajador,
	row_number()over(order by cod_trabajador) item, 
	rank()over(order by cod_trabajador) rango, fec_programada, fec_iniciovacacion, fec_finvacacion
	from #tmp001_rpta)t where item != rango
)
,tmp003_rpta as(
	select ttt.item, t.cod_trabajador, t.fec_programada,
	case ttt.item when 1 then t.fec_iniciovacacion end inicio, 
	case ttt.item when 2 then t.fec_finvacacion end fin
	from #tmp001_rpta t, tmp002_rpta tt, (values(1),(2))ttt(item)
	where t.cod_trabajador = tt.cod_trabajador
	order by t.cod_trabajador, ttt.item, t.fec_programada offset 0 rows
)
,tmp004_rpta as(
	select distinct tt.cod_trabajador, tt.item,
	stuff((select ' | ', isnull(t.inicio, t.fin)
	from tmp003_rpta t where t.cod_trabajador = tt.cod_trabajador and t.item = tt.item
	order by t.cod_trabajador, t.item, t.fec_programada
	for xml path, type).value('.','varchar(30)'),1,3,'') fechas
	from tmp003_rpta tt order by tt.cod_trabajador, tt.item offset 0 rows
)
select t.cod_trabajador, t.fechas fec_iniciovacacion, tt.fec_finvacacion
into #tmp001_fecini_fecfin
from tmp004_rpta t,
(
    select cod_trabajador, fechas fec_finvacacion
    from tmp004_rpta where item = 2
)tt
where t.item = 1 and t.cod_trabajador = tt.cod_trabajador


Select A.cod_trabajador, A.txt_diaproceso, A.txt_mesproceso, 
A.txt_anoproceso, A.num_dias, A.num_horas, A.num_horasextras,
txt_nombre,
txt_tipotrabajador,
txt_cargo,
txt_tipodocumento,
num_docidentidad,
num_cuspp,
txt_autogenerado,
txt_afp,
fec_ingreso,
fec_cese,
isnull(tt.fec_iniciovacacion, A.fec_iniciovacacion) fec_iniciovacacion,
isnull(tt.fec_finvacacion, A.fec_finvacacion) fec_finvacacion,
fec_iniciolicencia,
fec_finlicencia,
fec_ilicencia,
fec_flicencia,
char(10) fec_ilicencia,
char(10) fec_flicencia,
txt_mespago,
txt_direccion,
num_pago,
A.num_0101, A.num_0102, A.num_0103, A.num_0104, A.num_0105, A.num_0106, 
A.num_0107, A.num_0108, A.num_0109, A.num_0110, A.num_0111, A.num_0112, 
A.num_0113, A.num_0114, A.num_0115, A.num_0116, A.num_0117, A.num_0118,
A.num_0119, A.num_0120, A.num_0121, A.num_0122, A.num_0123, A.num_0124,
A.num_0125, A.num_0126, A.num_0127, A.num_0128, A.num_0129, A.num_0130,
A.num_0201, A.num_0202, A.num_0203, A.num_0204, A.num_0205, A.num_0206,
A.num_0207, A.num_0208,
A.num_0301, 
A.num_0401, A.num_0402, A.num_0403, A.num_0404, A.num_0405, A.num_0406, 
A.num_0407, A.num_0408, A.num_0409, A.num_0410, A.num_0411, A.num_0412, 
A.num_0413, A.num_0414, A.num_0415, A.num_0416, A.num_0417, A.num_0418, 
A.num_0419, A.num_0420, cod_oficina,
tip_comision,
num_comisionvar,
num_comisionmixta,
num_seguroinv,
num_aporteobl
from(select t.*, row_number()over(partition by cod_trabajador order by cod_trabajador) item
from #tmp001_rpta t)A
outer apply(select*from #tmp001_fecini_fecfin tt where tt.cod_trabajador = A.cod_trabajador)tt 
where item = 1
order by txt_paterno


