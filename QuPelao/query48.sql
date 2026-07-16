use SCC_CANDIDATOS
go

PELAO

-- select*from sys.procedures order by 1
-- select text from sys.syscomments
-- where id=object_id('usp_scc_RepInforme_BuscarInformePorCandidatoCaso','p')


select idCaso,*from dbo.scc_informe where idCandidato = 51

-- return
select cod_motivocambio,*from dbo.scc_caso where idCandidato = 51
