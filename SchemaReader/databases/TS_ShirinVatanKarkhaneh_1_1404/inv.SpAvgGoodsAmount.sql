USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
  -- =========== TS-QC:OK ========================
  -- Author        : 
  -- Create date   : 92/11/27
  -- Viewed By	 : 
  -- Last Modified : 
  -- Description   : 
  -- =============================================
 --[inv].[SpAvgGoodsAmount] '1392/09/30'
  CREATE PROCEDURE [inv].[SpAvgGoodsAmount]
      @ToDate	Char(10)
   	WITH ENCRYPTION
   AS
   
  BEGIN
  	
  	DECLARE @ProductID	VARCHAR(20);
  	DECLARE @ProductQty FLOAT;
  	DECLARE @Amount1	FLOAT;
  	DECLARE @Amount2	FLOAT;
  		
  	CREATE TABLE #tbl_Amounts
  	(
  		GoodsID	VARCHAR(20) COLLATE arabic_cs_as,
  		Amount	FLOAT
  	)
  
  	CREATE TABLE #tbl_Products
  	(
  		
  		ProductID	VARCHAR(20) COLLATE arabic_cs_as,
  		ProductQty	FLOAT,
  		Amount		FLOAT
  	)
  
  	INSERT INTO #tbl_Amounts(GoodsID, Amount)
  	SELECT D.GoodsID, AVG(D.GoodsAmount) 
  	FROM inv.tblStorageDocsDtl D
  	WHERE D.ProcessID IN (70, 82) AND D.DocDate <= @ToDate 
 		AND D.GoodsID NOT IN (SELECT DISTINCT GoodsID FROM inv.tblStorageDocsDtl WHERE ProcessID IN (72,73,80))
  	GROUP BY D.GoodsID
  
  	INSERT INTO #tbl_Products(ProductID, ProductQty, Amount)
  	SELECT GoodsID, SUM(GoodsQuantity), 0
  	FROM inv.tblStorageDocsDtl
  	WHERE ProcessID IN (72,73,80) AND DocDate <= @ToDate
  	GROUP BY GoodsID
  	
  	Declare	cur1 CURSOR For 
   	SELECT ProductID, ProductQty
   	FROM #tbl_Products
   	WHERE Amount = 0
  	
  	WHILE (SELECT COUNT(*) FROM #tbl_Products WHERE Amount=0) > 0
  	BEGIN
  
   		Open  cur1; 
  	 		
   		Fetch NEXT From cur1 into @ProductID, @ProductQty
  	 
   		While (@@Fetch_Status = 0)
   		BEGIN
  			 	
  			IF (SELECT count(*)
  				FROM
  				(
   					SELECT DISTINCT D.GoodsID
   					FROM inv.tblStorageDocsDtl D
   							INNER JOIN inv.tblStorageDocsHdr H 
   							ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND 
   							   H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo  
   					WHERE H.ProductID=@ProductID AND H.ProcessID IN (70,82) AND H.DocDate <= @ToDate
   					EXCEPT
   					SELECT GoodsID
  	 				FROM #tbl_Amounts
  				) T 
  				)  = 0
  				
  			BEGIN
  				
  					------------------------------------------------------------
  					SET @Amount1 = 0
  			 					
  					SELECT @Amount1 = ISNULL( SUM(a.Amount * d.GoodsQuantity), 0) / @ProductQty
 					FROM inv.tblStorageDocsDtl d
 					INNER JOIN inv.tblStorageDocsHdr h
 					ON h.ProcessID = d.ProcessID AND h.ProcessNo = d.ProcessNo AND h.FiscalYear = d.FiscalYear AND h.SerialNo = d.SerialNo
 					INNER JOIN #tbl_Amounts a
 					ON a.GoodsID = d.GoodsID 
 					WHERE h.ProductID = @ProductID and h.ProcessID IN (82,70) AND h.DocDate <= @ToDate 
  					 					
  					------------------------------------------------------------
  					SET @Amount2 = 0
  				
  					SELECT @Amount2 = ISNULL(SUM(PortionGoods+PortionOtherCost+PortionSalary+PortionOverLoad),0) / @ProductQty 
  					FROM  cac.tblPortionSum 
  					WHERE ProcessID = 70 and GoodsID=@ProductID 
  
  					----------------------------------------------------------
  					IF @Amount1 = 0 AND @Amount2 = 0
  						SET @Amount1 =0.000001
  									
  					INSERT INTO #tbl_Amounts(GoodsID, Amount)
  					VALUES(@ProductID, @Amount1+@Amount2)
  
  					UPDATE #tbl_Products
  					SET Amount = @Amount1+@Amount2
  					WHERE ProductID=@ProductID
  					
  				END	
  		 		
  	 			Fetch NEXT From cur1 into @ProductID, @ProductQty
  	 		
   		END;
  	 	
   		CLOSE cur1
  
  	END -- WHILE	
  
   	DEALLOCATE cur1
  
  	SELECT DISTINCT ProductID, Amount
  	FROM #tbl_Products
  
  END	
GO
