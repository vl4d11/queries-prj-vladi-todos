select top 0
cast(null as varchar(100)) dato into #tmp001_param
-- select*from #tmp001_param
-- insert #tmp001_param(values
declare @datos varchar(500)

select @datos =
't.FechaFin,\
t.Comentarios,\
t.Seg_Id,\
t.Proy_Id,\
t.Actividad,\
t.Lugar,\
t.Responsable_Id,\
t.FechaTermino,\
t.Prioridad_Id,\
t.Avance'

select @datos
