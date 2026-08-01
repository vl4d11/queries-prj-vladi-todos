use SCP_AMINISTIA_PERFIL

-- select*from msg_usuario
-- select*from sys.procedures where name = 'uspMcoMonitorOrndenCsv' order by 1
-- select text from sys.syscomments where id=object_id('dbo.uspMcoMonitorOrndenCsv', 'p')

-- 09598011    mconstantini (SUPERVISORA)
exec dbo.uspMcoMonitorOrndenCsv '2026|07|09598011'
-- 76548887    jgarcia (RESPONSABLE DE PRESUPUESTO)  NO SALE LA DATA
exec dbo.uspMcoMonitorOrndenCsv '2026|07|76548887'
-- 73539081    gcastro (RESPONSABLE DE CONTABILIDAD)
exec dbo.uspMcoMonitorOrndenCsv '2026|07|73539081'
