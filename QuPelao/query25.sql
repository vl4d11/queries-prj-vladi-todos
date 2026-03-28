use SCP_DESCOSUR2; select @@version;

-- select text from sys.syscomments where id = object_id('dbo.uspMppEmpleadoMpqListarCsv','p')

CREATE PROCEDURE [dbo].[uspMppEmpleadoMpqListarCsv]
@Data varchar(max)
AS
Begin

Declare @pos1 int
Declare @pos2 int
Declare @txt_mesproceso varchar(2)
Declare @txt_anoproceso varchar(4)

Set @pos1 = CharIndex('|',@Data,0)
Set @txt_mesproceso = SUBSTRING(@Data,1,@pos1-1)
Set @pos2 = Len(@Data)+1
Set @txt_anoproceso = SUBSTRING(@Data,@pos1+1,@pos2-@pos1)

select concat(@txt_anoproceso,@txt_mesproceso) periodo into #tmp001_periodo

Select 'Codigo|Nombre|Cargo|Horas|Dias|Categoria|Pago|' +
'Afp|Escala|Ingreso|TipodPago|FechaNacimiento|Departamento|' +
 'Provincia|DiasOficiales|RegimenPension|TipoComision|Licencia|Liquida|FechaCese|CodigoCese|OtraRenta|' +
 'AfectoEps|VidaLey|EpsEmpleador|RentaMayor|Judicial|TasaJudicial|Correo¬' +
'40|150|80|80|80|80|80|80|80|80|80|80|80|80|40|20|80|80|80|80|80|80|80|80|80|80|80|80|80¬' +
'String|String|String|Int32|Int32|String|Int32|' +
'String|String|DateTime|String|DateTime|String|' +
'String|Int32|String|String|String|Int32|DateTime|String|Decimal|String|Decimal|Decimal|String|String|Decimal|String¬' +
IsNull((Select STUFF((Select '¬' + A.cod_trabajador + '|' +
Ltrim(A.txt_paterno) + ' ' + Ltrim(A.txt_materno) + ' ' + Ltrim(A.txt_nombre) + '|' +
--B.txt_descripcion + '|' +
Convert(varchar,A.fec_ingreso,103) + '|' +
Convert(varchar,A.num_horas) + '|' +
Convert(varchar,A.num_dias) + '|' +
C.txt_descripcion + '|' +
Convert(char(1),1) + '|' + 
A.cod_afp + '|' + 
A.cod_escala + '|' +
Convert(varchar, A.fec_ingreso, 103) + '|' +
Convert(char(1),tip_pago) + '|' +
Convert(varchar, A.fec_nacimiento, 103) + '|' +
A.cod_departamento + '|' +
A.cod_provincia + '|' +
Convert(varchar,A.num_dias) + '|' +
A.cod_regimenpension + '|' +
A.tip_comision + '|' +
A.est_licencia + '|' +
Convert(char(1),0) + '|' +
Convert(varchar, A.fec_cese, 103) + '|' +
A.cod_cese + '|' +
Isnull((Select Top 1 Convert(varchar,D.num_remuneracion) From mpp_rentaadicional D
        Where D.txt_anoproceso = @txt_anoproceso And
              D.txt_mesproceso = @txt_mesproceso And  
              D.cod_trabajador = A.cod_trabajador),0) + '|' + A.flg_afectoeps + '|' +
Isnull((Select Top 1 Convert(varchar,F.num_monto) From mpp_descuento F
        Where F.num_periodo = @txt_anoproceso And
              F.cod_trabajador = A.cod_trabajador And F.cod_conceptompp = '0207'),0) 
			  + '|' +
--Isnull((Select Top 1 Convert(varchar,E.num_vidaley) From mpp_otroaporte E
--        Where E.txt_anoproceso = @txt_anoproceso And
--              E.cod_trabajador = A.cod_trabajador),0) + '|' +
Isnull((Select Top 1 Convert(varchar,E.num_epsempleador) From mpp_otroaporte E
        Where E.txt_anoproceso = @txt_anoproceso And
              E.cod_trabajador = A.cod_trabajador),0) + '|' + A.flg_rentamayor + '|' + 
flg_desjudicial + '|' + Convert(varchar,num_tasajudicial) + '|' +
txt_correo
From mpp_empleado A,
     mpp_cargo B,
     mpp_tipodetrabajador C, #tmp001_periodo pp
Where ((Substring(Convert(Char(10),A.fec_cese,103),7,4) = '1900') Or
      (Substring(Convert(Char(10),A.fec_cese,103),7,4) = @txt_anoproceso) And
	  (Substring(Convert(Char(10),A.fec_cese,103),4,2) >= @txt_mesproceso))
And Ltrim(B.cod_cargo) = Ltrim(A.cod_cargo) 
And Ltrim(C.tip_trabajador) = Ltrim(A.tip_trabajador)
and convert(varchar(6), A.fec_ingreso,112) <= pp.periodo
Order By A.txt_paterno
FOR XML PATH('')), 1, 1, '')),'') + '~' +

(Select 'Codigo|Concepto|Monto|AfectoEps|Ordinario¬40|100|100|100|100¬String|String|Decimal|String|String¬' + 
IsNull((Select STUFF((Select '¬' + A.cod_trabajador + '|' +
B.cod_conceptompp + '|' + 
Convert(varchar,B.num_monto) + '|' + 
A.flg_afectoeps + '|' +
C.flg_ordinario
From mpp_empleado A,
     mpp_incremento B,
	 mpp_conceptompp C, #tmp001_periodo pp
Where A.est_retiro = 'A' And Ltrim(B.cod_trabajador) = Ltrim(A.cod_trabajador)
And C.cod_conceptompp = B.cod_conceptompp And C.flg_ordinario = 'S'
and convert(varchar(6), A.fec_ingreso,112) <= pp.periodo
FOR XML PATH('')), 1, 1, '')),''))

End
uspMppEmpleadoMpqListarCsv '01|2025'
                                                                                                                                                                       
