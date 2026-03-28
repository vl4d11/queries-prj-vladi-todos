alter PROCEDURE SP_OBTENER_DETALLE_DEUDA_2
(
 @ACTA VARCHAR(50)='C1531939',
 @PLACA VARCHAR(50)='BCA564',
 @FALTA VARCHAR(50)='R05',
 @EXPEDIENTE VARCHAR(50)
)
AS
BEGIN
 
 IF OBJECT_ID('tempdb..#tmp_pagos') IS NOT NULL
			DROP TABLE #tmp_pagos
 IF OBJECT_ID('tempdb..#tmp_pagos2') IS NOT NULL
	 DROP TABLE #tmp_pagos2 
 

DECLARE @ACTA_PLACA_FALTA  VARCHAR(200)= ''
SET @ACTA_PLACA_FALTA=CONCAT(@ACTA,CONCAT(@PLACA,@FALTA))

DECLARE @ORIGEN			VARCHAR(100)=''
DECLARE @CARTERA		VARCHAR(100)=''

DECLARE @FECHA_INFRACCION DATE=NULL
DECLARE @FECHA_MEMO DATE=NULL
DECLARE @FECHA_RESOLUCION_INICIO DATE=NULL
DECLARE @PORCENTAJE_MULTA  DECIMAL(12,2)=NULL
DECLARE @Fecha_corte_SAT DATE= CAST('30/06/2020' AS DATE) 


IF EXISTS (
  SELECT 1 FROM REPORT.ActaTransferencia WHERE DocDeuda=@ACTA
)
 BEGIN
	SET @ORIGEN='SAT'

	IF EXISTS (SELECT 1 FROM [Base6] where [DOCUMENTO_DE_DEUDA]=@ACTA)
	BEGIN                            
		SET @CARTERA='SAT'
	END
	ELSE
		SET @CARTERA='DFS'
 END
 ELSE
BEGIN
     SET @ORIGEN='ATU'
	 SET @CARTERA='DFS'
END

IF ( @ORIGEN='SAT' AND @CARTERA='DFS') OR (@ORIGEN='ATU' AND @CARTERA='DFS')
BEGIN
   
   SELECT TOP 1 @FECHA_INFRACCION  = TRY_CAST(FECHA_INFRACCION AS DATE), 
          @FECHA_MEMO = TRY_CAST(FECHA_MEMO AS DATE), 
		  @FECHA_RESOLUCION_INICIO = TRY_CAST(FECHA_RESOLUCION_INICIO AS DATE),
		  @PORCENTAJE_MULTA		=  TRY_CAST(REPLACE(MULTA_EN_PORCENTAJE_UIT, '%', '') AS decimal(10,2))
	FROM  REPORT.BaseInicioArqueoDFS 
	WHERE conc=@ACTA_PLACA_FALTA
	ORDER BY TRY_CAST(FECHA_INFRACCION AS DATE)

END
IF @ORIGEN='SAT' AND @CARTERA='SAT'
BEGIN
    --- BUSCAR EN  BaseTransaccionalSAT
	  SELECT TOP 1 @FECHA_INFRACCION  = TRY_CAST(FECHA_DE_INFRACCION5 AS DATE), 
	           @PORCENTAJE_MULTA = CASE WHEN CHARINDEX('%', MONTO_DE_MULTA_EN_PORCENTAJE_UIT) > 0 THEN  TRY_CAST(REPLACE(MONTO_DE_MULTA_EN_PORCENTAJE_UIT, '%', '') AS decimal(10,2))
										ELSE TRY_CAST(MONTO_DE_MULTA_EN_PORCENTAJE_UIT AS decimal(10,2))*100 END
	  FROM REPORT.BaseTransaccionalSAT
	  WHERE CODUNICOX4V =@ACTA_PLACA_FALTA
	  ORDER BY TRY_CAST(FECHA_DE_INFRACCION5 AS DATE)
 
END

	   IF OBJECT_ID('tempdb..#tmp_pagos') IS NOT NULL
			DROP TABLE #tmp_pago
		 

		SELECT * INTO #tmp_pagos FROM (
		SELECT  cast(FECHA as date) FECHA,
		        YEAR(FECHA) ANIO, 						  
			    cast('PAGO' as VARCHAR(100)) AS TIPO,
			   	 CAST(REPLACE(MONTO_DE_PAGO, ',', '') AS DECIMAL(12, 3))   MONTO,
				 cast(0 as decimal(10,2)) MONTO_INICIAL,
				 cast(0 as decimal(10,2)) VARIACION, 
				 cast(0 as decimal(10,2)) INSOLUTO,
				 cast(0 as decimal(10,2)) COSTAS_ACUM,
				 cast(0 as decimal(10,2)) DEUDA
		FROM [REPORT].ConsolidadoPagos WHERE CONCAT(concat(ACTA,PLACA),FALTA) = @ACTA_PLACA_FALTA --'C1682122'--'C1531939'--		 	  
		UNION ALL
		SELECT  cast(FECHA_DE_EMISION as date) FECHA ,
		        YEAR(FECHA_DE_EMISION) ANIO ,
				  cast('COSTAS' as VARCHAR(100))  AS TIPO,					 
				  CAST(REPLACE(REPLACE(SUMATORIA_A_B_C_D_SISTEMA, ',', ''),'S/','') AS DECIMAL(12, 3))  MONTO,
				  cast(0 as decimal(10,2)) MONTO_INICIAL,
				  cast(0 as decimal(10,2)) VARIACION, 
				  cast(0 as decimal(10,2)) INSOLUTO,
				  cast(0 as decimal(10,2)) COSTAS_ACUM,
				  cast(0 as decimal(10,2)) DEUDA
		FROM [REPORT].[ConsolidadoCostas] WHERE CONCAT(CONCAT(ACTA_DE_CONTROL,PLACA),CODIGO_INFRACCION)=@ACTA_PLACA_FALTA--'C1682122' --'C1531939'--
		) P
		 ORDER BY P.FECHA

		 --select * from #tmp_pagos

		 
       IF OBJECT_ID('tempdb..#tmp_pagos2') IS NOT NULL
			DROP TABLE #tmp_pagos2

 		SELECT 
		 ROW_NUMBER() OVER (ORDER BY A.ANIO, B.FECHA ) AS item,
		A.ANIO,ISNULL(B.FECHA,CONCAT(A.ANIO,'-01-01') ) FECHA,isnull(B.TIPO,'VARIACION_ANUAL') TIPO, isnull(B.MONTO,0) MONTO,B.MONTO_INICIAL,B.VARIACION , B.INSOLUTO,B.COSTAS_ACUM,B.DEUDA
		INTO #tmp_pagos2
		FROM (SELECT ANO AS ANIO FROM CONFIG.UIT WHERE ANO>='2020') A LEFT JOIN 
		#tmp_pagos B ON A.ANIO=B.ANIO ORDER BY A.ANIO,B.FECHA
 
   ---- select * from #tmp_pagos2


            DECLARE @item int,
		        @anio INT, 
		        @fecha date,
				@tipo varchar(50),				
				@monto DECIMAL(12,2),
				@monto_inicio DECIMAL(12,2),
				@variacion DECIMAL(12,2),
				@insoluto DECIMAL(12,2),
				@costas DECIMAL(12,2),
				@deuda  DECIMAL(12,2),

			   @item_anterior int ,
			   @anio_anterior  INT = NULL ,
               @fecha_anterior date = NULL,
		       @tipo_anterior  varchar(50),
		       @monto_anterior DECIMAL(12,2),
			   @monto_inicio_anterior DECIMAL(12,2),
			   @variacion_anterior DECIMAL(12,2),
		       @insoluto_anterior DECIMAL(12,2),
		       @costas_anterior DECIMAL(12,2),
		       @deuda_anterior DECIMAL(12,2),
			   @UIT_ACTUAL DECIMAL(12,2),
			   @UIT_ANTERIOR DECIMAL(12,2); 
 

	DECLARE cursor_pagos_sat CURSOR FOR
	select * from #tmp_pagos2 Order By  FECHA,TIPO

	OPEN cursor_pagos_sat;
	FETCH NEXT FROM cursor_pagos_sat 
    INTO @item,@anio,@fecha,@tipo,@monto,@monto_inicio,@variacion,@insoluto,@costas,@deuda;
	WHILE @@FETCH_STATUS = 0
	BEGIN

     IF @anio_anterior IS NOT NULL
	 BEGIN
	         if @anio=@anio_anterior
			 begin
					-- cuando los años son iguales- no hay variacion
						UPDATE #tmp_pagos2 set MONTO_INICIAL  = @insoluto_anterior,  
											VARIACION	  = @variacion_anterior 
											where item =@item 
						--UPDATE #tmp_pagos2 set VARIACION	  = @variacion_anterior where item =@item

				          ---- QUE PASA CON EL INSOLUTO Y LA DEUDA
						  IF @tipo ='COSTAS'
						  BEGIN
							  UPDATE #tmp_pagos2 
							  set COSTAS_ACUM = MONTO + @costas_anterior,
							      INSOLUTO = MONTO_INICIAL + VARIACION,
							       DEUDA=(MONTO_INICIAL + VARIACION)+ (MONTO + @costas_anterior)--INSOLUTO + COSTAS_ACUM
							  where item=@item
							  --UPDATE #tmp_pagos2 set INSOLUTO = MONTO_INICIAL + VARIACION where item =@item
							  --UPDATE #tmp_pagos2 set DEUDA= INSOLUTO + COSTAS_ACUM where item=@item						  
						  END

				          IF @tipo ='PAGO'
						  BEGIN
						     IF @costas_anterior>0
							 BEGIN
							    IF @monto >= @costas_anterior
								BEGIN
								    --UPDATE #tmp_pagos2 SET COSTAS_ACUM = 0 where item=@item                                   
								    DECLARE @diferenciaPagoYCostas decimal(12,2)= (@monto-@costas_anterior )
								   -- UPDATE #tmp_pagos2 SET COSTAS_ACUM=0 WHERE item=@item

									--if(@diferenciaPagoYCostas>= @insoluto_anterior)
									--    UPDATE #tmp_pagos2 SET INSOLUTO =@diferenciaPagoYCostas-MONTO_INICIAL + VARIACION where item=@item 
									--else 
									--   UPDATE #tmp_pagos2 SET INSOLUTO =MONTO_INICIAL- @diferenciaPagoYCostas + VARIACION where item=@item   								
								  
								  UPDATE #tmp_pagos2 SET INSOLUTO= case when (@diferenciaPagoYCostas>= @insoluto_anterior) then (@diferenciaPagoYCostas-MONTO_INICIAL + VARIACION )
																		else (MONTO_INICIAL- @diferenciaPagoYCostas + VARIACION) end
								   where item=@item 
								    

								    UPDATE #tmp_pagos2 SET COSTAS_ACUM=0 ,
									                  DEUDA= INSOLUTO +COSTAS_ACUM									
									WHERE item=@item
								    -- UPDATE #tmp_pagos2 set DEUDA= INSOLUTO +COSTAS_ACUM where item=@item	
								END
								ELSE
								BEGIN
								      UPDATE #tmp_pagos2 SET 
									  COSTAS_ACUM = @costas_anterior-@monto ,
									  INSOLUTO= MONTO_INICIAL + VARIACION,
									  DEUDA = (MONTO_INICIAL + VARIACION) +( @costas_anterior-@monto)--INSOLUTO+COSTAS_ACUM 
									  where item=@item

									  --UPDATE #tmp_pagos2 set INSOLUTO= MONTO_INICIAL + VARIACION where item=@item
									  --UPDATE #tmp_pagos2 set DEUDA = INSOLUTO +COSTAS_ACUM  where item = @item									  
								END 
							 END
							 ELSE
							 BEGIN
							       UPDATE #tmp_pagos2 SET 
								   COSTAS_ACUM =  @costas_anterior ,
								   INSOLUTO    =  MONTO_INICIAL + VARIACION -@monto,
								   DEUDA =  ( MONTO_INICIAL + VARIACION -@monto)+@costas_anterior--INSOLUTO+COSTAS_ACUM								   
								   where item =@item

								   --update #tmp_pagos2 set INSOLUTO    =  MONTO_INICIAL + VARIACION -@monto where item=@item
								   --update #tmp_pagos2 SET DEUDA = INSOLUTO +COSTAS_ACUM WHERE ITEM = @item
							 END

						  END


						  -- EN EL MISMO AÑO NO EXISTE VARIACION @TIPO='VARIACION_ANUAL'
						select @insoluto=INSOLUTO,
						      @costas= COSTAS_ACUM, 
							  @deuda=DEUDA
							  from #tmp_pagos2 where item=@item

						--set @costas=(select COSTAS_ACUM from #tmp_pagos2 where item=@item)
						--set @deuda=(select DEUDA from #tmp_pagos2 where item=@item)

			 end
			 else
			 begin
			    --- años diferentes
			            UPDATE #tmp_pagos2 set MONTO_INICIAL= @insoluto_anterior where item =@item
					    ----cambio de año variacion----
					   	SELECT @UIT_ACTUAL   = VALOR FROM CONFIG.UIT WHERE ANO=@anio
						SELECT @UIT_ANTERIOR = VALOR FROM CONFIG.UIT WHERE ANO=@anio_anterior
						UPDATE #tmp_pagos2 set VARIACION=(@UIT_ACTUAL - @UIT_ANTERIOR) * @PORCENTAJE_MULTA / 100 where item=@item
						
						IF @TIPO ='COSTAS' 
						BEGIN
						   UPDATE #tmp_pagos2 set 
						   COSTAS_ACUM = MONTO + @costas_anterior, 
						   INSOLUTO = MONTO_INICIAL+ VARIACION,
						    DEUDA = (MONTO_INICIAL+ VARIACION)+(MONTO + @costas_anterior)--INSOLUTO + COSTAS_ACUM
						   where item=@item
						   --UPDATE #tmp_pagos2 set INSOLUTO = MONTO_INICIAL+ VARIACION where item=@item
						   --Update #tmp_pagos2 set DEUDA = INSOLUTO + COSTAS_ACUM where item = @item
						END

						IF @tipo='PAGO'
						BEGIN
							IF @costas_anterior> 0
							BEGIN
								IF @monto>= @costas_anterior
								BEGIN
									-- UPDATE #tmp_pagos2 SET COSTAS_ACUM=0 where item =@item
									 declare @diferenciaPagoYCostas2 decimal(12,2)= (@monto- @costas_anterior)
									 
									 --if(@diferenciaPagoYCostas2 >@insoluto_anterior)
									 --   UPDATE #tmp_pagos2 SET INSOLUTO= @diferenciaPagoYCostas2-MONTO_INICIAL + VARIACION where item=@item
									 --else
									 --   UPDATE #tmp_pagos2 SET INSOLUTO= MONTO_INICIAL-@diferenciaPagoYCostas2 + VARIACION where  item=@item
									 
									   --update #tmp_pagos2 set DEUDA= INSOLUTO +COSTAS_ACUM where item=@item

									   ------------------
									   UPDATE #tmp_pagos2 SET INSOLUTO= case when (@diferenciaPagoYCostas2 >@insoluto_anterior) then (@diferenciaPagoYCostas2-MONTO_INICIAL + VARIACION)
																		else (MONTO_INICIAL-@diferenciaPagoYCostas2 + VARIACION) end
								       where item=@item 
								    

								    UPDATE #tmp_pagos2 SET COSTAS_ACUM=0 ,
									                  DEUDA= INSOLUTO +COSTAS_ACUM	


								END
								ELSE
								BEGIN
								     UPDATE #tmp_pagos2 SET
									 COSTAS_ACUM = @costas_anterior - @monto,
									 INSOLUTO =MONTO_INICIAL+VARIACION,
									 DEUDA = (MONTO_INICIAL+VARIACION)+ (@costas_anterior - @monto)--INSOLUTO+COSTAS_ACUM
									 where item=@item
									 --update #tmp_pagos2 SET INSOLUTO =MONTO_INICIAL+VARIACION where item =@item
									 --update #tmp_pagos2 set DEUDA = INSOLUTO+COSTAS_ACUM where item= @item
								END

							END
							ELSE
							BEGIN
							    update #tmp_pagos2 set COSTAS_ACUM= @costas_anterior,
								INSOLUTO = MONTO_INICIAL+VARIACION-@monto,
								DEUDA= (MONTO_INICIAL+VARIACION-@monto)+ @costas_anterior--INSOLUTO+ COSTAS_ACUM
								where item= @item
								--update #tmp_pagos2 set INSOLUTO = MONTO_INICIAL+VARIACION-@monto where item= @item
								--update #tmp_pagos2 set DEUDA= INSOLUTO+ COSTAS_ACUM where item=@item
							END
						END
						
						if @tipo= 'VARIACION_ANUAL'
						BEGIN
						  IF @deuda_anterior>0
						  BEGIN
									  UPDATE #tmp_pagos2 SET INSOLUTO= MONTO_INICIAL+VARIACION ,
															 COSTAS_ACUM= @costas_anterior,
															 DEUDA= MONTO_INICIAL+VARIACION + @costas_anterior ---INSOLUTO + COSTAS_ACUM
									  WHERE item=@item
						  --update #tmp_pagos2 set COSTAS_ACUM= @costas_anterior where item=@item
						  --update #tmp_pagos2 set DEUDA= INSOLUTO + COSTAS_ACUM where item =@item
						  END
						  ELSE
						  BEGIN 
								--UPDATE #tmp_pagos2 SET INSOLUTO=0 WHERE item=@item
								--UPDATE #tmp_pagos2 SET COSTAS_ACUM=0 WHERE item=@item
								--UPDATE #tmp_pagos2 SET VARIACION=0 WHERE item=@item
								--UPDATE #tmp_pagos2 SET DEUDA=0 WHERE item=@item

								UPDATE #tmp_pagos2 SET INSOLUTO=0,COSTAS_ACUM=0, VARIACION=0, DEUDA=0
								WHERE item=@item
						  END
						END


						--set @insoluto=(select INSOLUTO from #tmp_pagos2 where item=@item) 
						--set @costas=(select COSTAS_ACUM from #tmp_pagos2 where item=@item)
						--set @deuda=(select DEUDA from #tmp_pagos2 where item=@item)

							select @insoluto=INSOLUTO,
						      @costas= COSTAS_ACUM, 
							  @deuda=DEUDA
							  from #tmp_pagos2 where item=@item
			  
			 end
	 END
	 ELSE
	 BEGIN
		----- Primer RegisTro
		    IF  @item=1
				  BEGIN
			 		 declare @Montototal_transferencia_SAT DECIMAL(12, 2)
					 SET @Montototal_transferencia_SAT =(SELECT CAST(REPLACE(Total, ',', '') AS DECIMAL(12, 2)) FROM REPORT.ActaTransferencia where DocDeuda=@ACTA)--@ACTA
					  
					   UPDATE #tmp_pagos2 set MONTO_INICIAL=@Montototal_transferencia_SAT,
										      VARIACION= 0,
											  INSOLUTO=case when TIPO='PAGO' then @Montototal_transferencia_SAT -MONTO --MONTO_INICIAL - MONTO 
										 			        when TIPO='COSTAS' OR TIPO ='VARIACION_ANUAL' then @Montototal_transferencia_SAT --MONTO_INICIAL+ VARIACION
										 			   end,
													   COSTAS_ACUM=case when TIPO='COSTAS' THEN MONTO ELSE 0 END,
											 DEUDA= isnull(case when TIPO='PAGO' then @Montototal_transferencia_SAT -MONTO --MONTO_INICIAL - MONTO 
										 			        when TIPO='COSTAS' OR TIPO ='VARIACION_ANUAL' then @Montototal_transferencia_SAT --MONTO_INICIAL+ VARIACION
										 			   end,0)+isnull(case when TIPO='COSTAS' THEN MONTO ELSE 0 END,0) --isnull(INSOLUTO,0) + isnull(COSTAS_ACUM,0) 
						 where item=1

					 -- UPDATE #tmp_pagos2 set MONTO_INICIAL=@Montototal_transferencia_SAT where item=1
				  --    UPDATE #tmp_pagos2 set VARIACION= 0 where item=1				 
					 -- UPDATE #tmp_pagos2 set INSOLUTO=case when TIPO='PAGO' then MONTO_INICIAL - MONTO 
						--				 			        when TIPO='COSTAS' OR TIPO ='VARIACION_ANUAL' then MONTO_INICIAL+ VARIACION
						--				 			   end	where item=1
 
					 --UPDATE #tmp_pagos2 set COSTAS_ACUM=case when TIPO='COSTAS' THEN MONTO ELSE 0 END where item=1
					 -- UPDATE #tmp_pagos2 set DEUDA= isnull(INSOLUTO,0) + isnull(COSTAS_ACUM,0) where item=1
					
					 select @insoluto = INSOLUTO,@costas= COSTAS_ACUM, @deuda=DEUDA , @variacion=VARIACION 
					 from #tmp_pagos2
					 where item=@item

	       --            set @insoluto=(select INSOLUTO from #tmp_pagos2 where item=1)
					   --set @costas=(select COSTAS_ACUM from #tmp_pagos2 where item=1)
					   --set @deuda=(select DEUDA from #tmp_pagos2 where item=1)
					   --set @variacion=(select VARIACION from #tmp_pagos2 where item=@item)
				 END
		 
				
	 END

	 	 SET @item_anterior = @item;
		 SET @anio_anterior = @anio;
		 SET @variacion_anterior= @variacion;
		 set @insoluto_anterior=@insoluto;
		 SET @costas_anterior= @costas;
		 SET @deuda_anterior = @deuda
    
	FETCH NEXT FROM cursor_pagos_sat INTO @item, @anio, @fecha,@tipo,@monto,@monto_inicio,@variacion,@insoluto,@costas,@deuda;
	END
	CLOSE cursor_pagos_sat;
	DEALLOCATE cursor_pagos_sat;

	 --select  * from #tmp_pagos2  order by  FECHA,TIPO ;
 
	update  REPORT.BaseTransaccionalSAT 
	set INSOLUTO_SISTEMA = ( select top 1 INSOLUTO from #tmp_pagos2  order by item desc),
	COSTAS_SISTEMA = ( select top 1 COSTAS_ACUM from #tmp_pagos2  order by item desc),
	DEUDA_SISTEMA = ( select top 1 DEUDA from #tmp_pagos2  order by item desc)
	where ACTA_4 = @ACTA and PLACA_4=@PLACA and FALTA_4=@FALTA  
	
	--update  REPORT.BaseTransaccionalSAT set COSTAS_SISTEMA = ( select top 1 COSTAS_ACUM from #tmp_pagos2  order by item desc)
	--where ACTA_4 = @ACTA and PLACA_4=@PLACA and FALTA_4=@FALTA  

	--update  REPORT.BaseTransaccionalSAT set DEUDA_SISTEMA = ( select top 1 DEUDA from #tmp_pagos2  order by item desc)
	--where ACTA_4 = @ACTA and PLACA_4=@PLACA and FALTA_4=@FALTA  

END
  

  --declare @data varchar(max)=( SELECT (
		--	  select 'EXEC SP_OBTENER_DETALLE_DEUDA ''',ACTA_4,''',''', PLACA_4,''',''',FALTA_4,''',''',EXPEDIENTE5,''';'
		--	  from (
		--	  select TOP 10000 ROW_NUMBER() over (partition by CODUNICOX4V,expediente5 order by CODUNICOX4V) item, CODUNICOX4V, ACTA_4,PLACA_4,FALTA_4,EXPEDIENTE5 
		--	  from  REPORT.BaseTransaccionalSAT) t 
		--	  where item=1  
		--	  FOR XML PATH, TYPE).value('.','VARCHAR(MAX)')
  --)
  --exec (@data)
  

  --EXEC SP_OBTENER_DETALLE_DEUDA '1811568','UI2297','M06','777400108437';
  