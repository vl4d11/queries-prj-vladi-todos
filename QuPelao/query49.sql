use SCC_CANDIDATOS
go

-- CREATE PROCEDURE [dbo].[usp_scc_RepInforme_BuscarInformePorCandidatoCaso]
Declare
    @idCandidato int
-- AS
select @idCandidato
    = 51
-- = 97

select
INF.id
,INF.idCandidato
,INF.num_caso
,INF.num_informe
,INF.flg_entrego
,INF.fec_fechaentrega
,INF.txt_titulotrabajo
,INF.idProfesor
,INF.txt_observacionsupervisor
,INF.[fec_fregistro]
,INF.[cod_uregistro]
,INF.[fec_factualiza]
,INF.[cod_uactualiza]
,INF.txt_nombreprofesor
,INF.txt_nombre
,INF.txt_appaterno
,INF.txt_apmaterno
,INF.txt_caso
,INF.txt_informe
,INF.cod_promocion
,INF.txt_promocion
from(SELECT row_number()over(partition by INF.id order by INF.num_caso) item,
       INF.id
	  ,INF.idCandidato
	  ,INF.num_caso
	  ,INF.num_informe
	  ,INF.flg_entrego
      ,INF.fec_fechaentrega
	  ,INF.txt_titulotrabajo
	  ,INF.idProfesor
      ,INF.txt_observacionsupervisor
	  ,INF.[fec_fregistro]
      ,INF.[cod_uregistro]
      ,INF.[fec_factualiza]
      ,INF.[cod_uactualiza]
	  ,Isnull((Select Top 1 PR2.txt_nombre + ' ' + PR2.txt_appaterno + ' ' +  PR2.txt_apmaterno From scc_profesor PR2  Where CA.idProfesor = PR2.idProfesor And CA.num_caso = INF.num_caso),' ') As txt_nombreprofesor
	  ,IsNull(CD.txt_nombre,'')  As txt_nombre
	  ,IsNull(CD.txt_appaterno,'')  As txt_appaterno
	  ,IsNull(CD.txt_apmaterno,'') As txt_apmaterno
	  ,IsNull(CR.txt_descripcioncorta,'') As txt_caso
	  ,IsNull(IR.txt_descripcioncorta,'') As txt_informe
      ,IsNull(CD.cod_promocion,'') As cod_promocion
	  ,IsNull(PM.txt_descripcioncorta,' ') As txt_promocion
From scc_informe INF
LEFT OUTER JOIN scc_candidato CD ON INF.idCandidato=CD.idCandidato
LEFT OUTER JOIN scc_casorelacion CR ON INF.num_caso=CR.num_caso
LEFT OUTER JOIN scc_informerelacion IR ON INF.num_informe=IR.num_informe
Left Outer Join  scc_promocion PM ON PM.cod_promocion = CD.cod_promocion
Left Outer Join  scc_caso CA ON  CA.idCandidato=INF.idCandidato
And CA.num_caso = INF.num_caso
Where INF.idCandidato=@idCandidato Or @idCandidato=0)INF where item = 1
Order By INF.txt_nombre,INF.txt_appaterno,INF.num_caso
