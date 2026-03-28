use SIEC
go

SELECT p.*
    FROM [SIEC].[REPORT].[ConsolidadoPagos] p
     WHERE    EXISTS (
        SELECT 1
        FROM [REPORT].MatrizTransaccional m
        WHERE  (
		        m.EXPEDIENTE4 = p.EXPEDIENTE_COACTIVO
               AND m.ACTA_4 = p.ACTA
               AND m.PLACA_4 = p.PLACA
               AND (m.FALTA_4 = p.FALTA OR m.FALTA_SIN_EQUIVALENCIA = p.FALTA) )
			   or  (  m.CODIGO_LIQUIDACION = (p.ACTA + p.PLACA + p.FALTA) )
			   or  (   (m.ACTA_4 +m.PLACA_4)=(p.ACTA + p.PLACA) )
			   or  (   (m.ACTA_4 +m.FALTA_4)=(p.ACTA + p.FALTA) )
			   or  (   (m.EXPEDIENTE4 +m.ACTA_4)=(p.EXPEDIENTE_COACTIVO + p.ACTA) )
			   or  (   (m.EXPEDIENTE4 +m.PLACA_4)=(p.EXPEDIENTE_COACTIVO + p.PLACA) )
			   or  ( RIGHT(REPLICATE('0', 9) + m.ACTA_4, 9)+ m.PLACA_4+m.FALTA_4= RIGHT(REPLICATE('0', 9) + p.ACTA, 9)+p.PLACA+ p.FALTA )
			   --or  (   (m.ACTA_4 +m.PLACA_4)=(p.INFORME + p.PLACA) )
      );



	  	SELECT m.*
    FROM [REPORT].MatrizTransaccional m
     WHERE  EXISTS (
        SELECT 1
        FROM [SIEC].[REPORT].[ConsolidadoPagos] p
        WHERE  (
		        m.EXPEDIENTE4 = p.EXPEDIENTE_COACTIVO
               AND m.ACTA_4 = p.ACTA
               AND m.PLACA_4 = p.PLACA
               AND (m.FALTA_4 = p.FALTA OR m.FALTA_SIN_EQUIVALENCIA = p.FALTA) )
			   or  (  m.CODIGO_LIQUIDACION = (p.ACTA + p.PLACA + p.FALTA) )
			    or  (   (m.ACTA_4 +m.PLACA_4)=(p.ACTA + p.PLACA) )
			   or  (   (m.ACTA_4 +m.FALTA_4)=(p.ACTA + p.FALTA) )
			   or  (   (m.EXPEDIENTE4 +m.ACTA_4)=(p.EXPEDIENTE_COACTIVO + p.ACTA) )
			   or  (   (m.EXPEDIENTE4 +m.PLACA_4)=(p.EXPEDIENTE_COACTIVO + p.PLACA) )
			   or  ( RIGHT(REPLICATE('0', 9) + m.ACTA_4, 9)+ m.PLACA_4+m.FALTA_4= RIGHT(REPLICATE('0', 9) + p.ACTA, 9)+p.PLACA+ p.FALTA )
			   --or  (   (m.ACTA_4 +m.PLACA_4)=(p.INFORME + p.PLACA) )
      );


	  	--SELECT COUNT(1)  -- 46 275
    --FROM [SIEC].[REPORT].[ConsolidadoPagos] p

	IF OBJECT_ID('tempdb..#tempPagos') IS NOT NULL
		DROP TABLE #tempPagos


    SELECT EXPEDIENTE_COACTIVO, ACTA,PLACA,FALTA,
	SUM( CAST(REPLACE(MONTO_DE_PAGO, ',', '') AS DECIMAL(18,2))) AS MONTO_DE_PAGO ,
	COUNT(*) CantidadPagos,
	 (trim(ACTA) +TRIM( PLACA) +TRIM( FALTA) ) as ACTA_PLACA_FALTA
	 INTO #tempPagos
	FROM [SIEC].[REPORT].[ConsolidadoPagos]
   group by EXPEDIENTE_COACTIVO,ACTA,PLACA,FALTA

   ----select SUM(CantidadPagos) from #tempPagos  -->46275 ---> 46260

   select * from #tempPagos


	IF OBJECT_ID('tempdb..#tempPagos2') IS NOT NULL
		DROP TABLE #tempPagos2


    SELECT  1--- into #tempPagos2
        FROM [REPORT].MatrizTransaccional m inner join #tempPagos p
        on  (
		      (
		       m.EXPEDIENTE4 = p.EXPEDIENTE_COACTIVO AND m.ACTA_4 = p.ACTA AND m.PLACA_4 = p.PLACA AND (m.FALTA_4 = p.FALTA OR m.FALTA_SIN_EQUIVALENCIA = p.FALTA)
			  )
			  or  (  m.CODIGO_LIQUIDACION = (p.ACTA_PLACA_FALTA) )

			   ---or  (   (m.ACTA_4 +m.PLACA_4)=(p.ACTA + p.PLACA) )
			   --or  (   (m.ACTA_4 +m.FALTA_4)=(p.ACTA + p.FALTA)  )
			   --or  (   (m.EXPEDIENTE4 +m.ACTA_4)=(p.EXPEDIENTE_COACTIVO + p.ACTA) )
			   --or  (   (m.EXPEDIENTE4 +m.PLACA_4)=(p.EXPEDIENTE_COACTIVO + p.PLACA) )
			   --or  ( RIGHT(REPLICATE('0', 9) + m.ACTA_4, 9)+ m.PLACA_4+m.FALTA_4= RIGHT(REPLICATE('0', 9) + p.ACTA, 9)+p.PLACA+ p.FALTA)

		   )

		   select * from #tempPagos p

		  --UPDATE m
		  --select COUNT(p.cantidadPagos)

		  UPDATE m
		  SET   m.PROCESAMIENTO_PAGOS=cast(p.MONTO_DE_PAGO as decimal(18,3))
          from  [REPORT].MatrizTransaccional m inner join #tempPagos p
		  on (
		     m.EXPEDIENTE4 = p.EXPEDIENTE_COACTIVO AND m.ACTA_4 = p.ACTA AND m.PLACA_4 = p.PLACA
		     AND (m.FALTA_4 = p.FALTA OR m.FALTA_SIN_EQUIVALENCIA = p.FALTA)
			 )
		   --m--> 34 348  --->p--> 34  348

	      UPDATE m
		  SET   m.PROCESAMIENTO_PAGOS=cast(p.MONTO_DE_PAGO as decimal(18,3))
          from  [REPORT].MatrizTransaccional m inner join #tempPagos p
		  on (
		          m.CODIGO_LIQUIDACION = (p.ACTA_PLACA_FALTA)
			 )
		  where  m.PROCESAMIENTO_PAGOS is null
         --1287


		  UPDATE m
		  SET   m.PROCESAMIENTO_PAGOS=cast(p.MONTO_DE_PAGO as decimal(18,3))
          from  [REPORT].MatrizTransaccional m inner join #tempPagos p
		  on (
		         (m.ACTA_4 +m.PLACA_4)=(p.ACTA + p.PLACA)
			 )
		  where  m.PROCESAMIENTO_PAGOS is null
		  --(91 rows affected)


		  UPDATE m
		  SET   m.PROCESAMIENTO_PAGOS=cast(p.MONTO_DE_PAGO as decimal(18,3))
          from  [REPORT].MatrizTransaccional m inner join #tempPagos p
		  on (
		          (m.ACTA_4 +m.FALTA_4)=(p.ACTA + p.FALTA)
			 )
		  where  m.PROCESAMIENTO_PAGOS is null
		  -- 54


		  UPDATE m
		  SET   m.PROCESAMIENTO_PAGOS=cast(p.MONTO_DE_PAGO as decimal(18,3))
          from  [REPORT].MatrizTransaccional m inner join #tempPagos p
		  on (
		         (m.EXPEDIENTE4 +m.ACTA_4)=(p.EXPEDIENTE_COACTIVO + p.ACTA)
			 )
		  where  m.PROCESAMIENTO_PAGOS is null
		  --(5 rows affected)


		  UPDATE m
		  SET   m.PROCESAMIENTO_PAGOS=cast(p.MONTO_DE_PAGO as decimal(18,3))
          from  [REPORT].MatrizTransaccional m inner join #tempPagos p
		  on (
		         (m.EXPEDIENTE4 +m.PLACA_4)=(p.EXPEDIENTE_COACTIVO + p.PLACA)
			 )
		  where  m.PROCESAMIENTO_PAGOS is null
		  ---104 rows affected


		 UPDATE m
		  SET   m.PROCESAMIENTO_PAGOS=cast(p.MONTO_DE_PAGO as decimal(18,3))
          from  [REPORT].MatrizTransaccional m inner join #tempPagos p
		  on (
		        ( RIGHT(REPLICATE('0', 9) + m.ACTA_4, 9)+ m.PLACA_4+m.FALTA_4= RIGHT(REPLICATE('0', 9) + p.ACTA, 9)+p.PLACA+ p.FALTA)
			 )
		  --where  m.PROCESAMIENTO_PAGOS is null
		 --(581 rows affected)

		  --select   RIGHT(REPLICATE('0', 9) + m.ACTA_4, 9)+ m.PLACA_4+m.FALTA_4 ,
		  --          RIGHT(REPLICATE('0', 9) + p.ACTA, 9) +p.PLACA+ p.FALTA
		  ----SET   m.PROCESAMIENTO_PAGOS=cast(p.MONTO_DE_PAGO as decimal(18,3))
    --      from  [REPORT].MatrizTransaccional m inner join #tempPagos p
		  --on (
		  --      ( RIGHT(REPLICATE('0', 9) + m.ACTA_4, 9)+ m.PLACA_4+m.FALTA_4= RIGHT(REPLICATE('0', 9) + p.ACTA, 9)+p.PLACA+ p.FALTA)
			 --)

			 select COUNT(*) from  [REPORT].MatrizTransaccional  --422 540
			 --36 470
			 select PROCESAMIENTO_PAGOS from  [REPORT].MatrizTransaccional where PROCESAMIENTO_PAGOS is not null
			 	 select PROCESAMIENTO_PAGOS from  [REPORT].MatrizTransaccional where PROCESAMIENTO_PAGOS is   null
