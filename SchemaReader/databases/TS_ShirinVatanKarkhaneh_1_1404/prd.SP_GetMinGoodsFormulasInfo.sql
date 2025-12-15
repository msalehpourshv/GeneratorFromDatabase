USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1402/09/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create   PROCEDURE prd.SP_GetMinGoodsFormulasInfo  
@GoodsID Varchar(20),
@SerialNo Varchar(20)
WITH ENCRYPTION
AS
BEGIN

 ----  براِی مشاهده گردش تابع 
 ---- prd.funGetMinGoodsFormulasInfo @GoodsID,@SerialNo
 ---- استفاده میشود 

	select  @GoodsID GoodsID into #tblFormulas
	
	DECLARE @ProductID			VARCHAR(20);

	DECLARE csr CURSOR FOR 
		SELECT * FROM  #tblFormulas

	OPEN csr
	FETCH NEXT FROM csr INTO @ProductID

	WHILE @@Fetch_Status = 0
	BEGIN
	
		select 	 
			D.ProductID,prd.funGetGoodsFormulasInfo(1 ,D.ProductID,'','') Qty	,D.GoodsID	
			,prd.funGetGoodsFormulasInfo(2 ,D.ProductID,'','') Prod 
			,(prd.funGetMinGoodsFormulasInfo(D.GoodsID,0)*ProductCount/ GoodsQuantity )	MinGoodsFormulas	,ProductCount/GoodsQuantity 		
			,prd.funGetGoodsFormulasInfo(1 ,D.ProductID,'','') +
			prd.funGetGoodsFormulasInfo(2 ,D.ProductID,'','') +
			(prd.funGetMinGoodsFormulasInfo(D.GoodsID,0)*ProductCount/ GoodsQuantity )	SumGoodsFormula	
		from	prd.tblFormulasDtl D 
		INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID
		where  (D.ProductID =@ProductID)  AND (D.SerialNo = @SerialNo  or ( @SerialNo= 0 and H.IsDefault = 1)  )
		
	   insert into #tblFormulas
		select 	 D.GoodsID
		from	prd.tblFormulasDtl D 
		INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID
		where  (D.ProductID =@ProductID)  AND (D.SerialNo =@SerialNo  or ( @SerialNo =0 and H.IsDefault = 1)  )
   

		FETCH NEXT FROM csr INTO @ProductID
	END

	CLOSE csr
	DEALLOCATE csr	 
	  
END
GO
