USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : H.Sadeghi
-- Creation date : 1396/01/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
--[prd].[SpCreateFormulaFromPreSale] 240,1,95,11,1
CREATE PROCEDURE [prd].[SpCreateFormulaFromPreSale]
	@ProcessID	Int,
	@ProcessNo	Int,
	@FiscalYear	Int,
	@SerialNo	Int,
	@LanguageID	TinyInt
WITH ENCRYPTION
AS 

Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	DECLARE @GoodsID varchar(20)
	DECLARE @GoodsID2 varchar(20)
	DECLARE @StoreID varchar(20)
	DECLARE @MaxSeriaNo int
	DECLARE @MaxProduceStepNo int

	DECLARE curBenefits CURSOR FOR 
		select DISTINCT D.GoodsID,D.GoodsID2,H.StoreID
		from inv.tblPreSaleDtl D 
		inner join inv.tblPreSaleHdr H 
		ON H.ProcessID=D.ProcessID 
		AND H.ProcessID=D.ProcessID 
		AND H.ProcessNo=D.ProcessNo 
		AND H.FiscalYear=D.FiscalYear 
		AND H.SerialNo=D.SerialNo 
		where H.ProcessID = @ProcessID 
		AND   H.ProcessNo = @ProcessNo 
		AND   H.FiscalYear= @FiscalYear 
		AND   H.SerialNo  = @SerialNo 
		
	
	OPEN curBenefits;
	
	FETCH NEXT FROM curBenefits INTO @GoodsID, @GoodsID2,@StoreID
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @MaxSeriaNo = 0
		SET @MaxProduceStepNo = 0
		
		SELECT TOP 1 @MaxSeriaNo = a.SerialNo FROM prd.tblFormulasDtl a 
	    INNER JOIN prd.tblFormulasHdr b ON a.ProductID=b.ProductID and a.SerialNo=b.SerialNo 
	    WHERE a.ProductID=@GoodsID and a.GoodsID=@GoodsID2 AND b.IsDefault='True'
		    
		if @MaxSeriaNo=0
		BEGIN
			SELECT @MaxSeriaNo=ISNULL(MAX(SerialNo),0)+1 from prd.tblFormulasHdr where ProductID=@GoodsID
			
			INSERT INTO prd.tblFormulasHdr
			(ProductID, SerialNo,ProductCount, FormulaName, IsDefault, AcceptFormula )
			SELECT  @GoodsID,@MaxSeriaNo,1,[pub].[funGetGoodsName](@GoodsID,@LanguageID),'True','True'
			
			Insert into prd.tblFormulasDtl
			(ProductID, SerialNo, RowNo, GoodsID, GoodsQuantity, DocRowNo, UnitID)
			SELECT @GoodsID,@MaxSeriaNo,1,@GoodsID2,1,1,[pub].[funGetGoodsUnitID](@GoodsID2)
		END
		
		IF (SELECT COUNT(*) from pln.tblProduceStepHdr WHERE ProductID= @GoodsID AND FormulaNo = @MaxSeriaNo )=0
		BEGIN
		
			SELECT @MaxProduceStepNo=ISNULL(MAX(SerialNo),0)+1 from pln.tblProduceStepHdr where ProductID=@GoodsID and FormulaNo=@MaxSeriaNo
			
			INSERT INTO pln.tblProduceStepHdr
			(ProductID, SerialNo, ProduceMethodName, IsDefaultMethod, FormulaNo)
			SELECT @GoodsID,@MaxProduceStepNo,N'روش اتوماتیک','True',@MaxSeriaNo
		
			INSERT INTO pln.tblProduceStepDtl
			(ProductID, SerialNo, RowNo, DocRowNo,  ProduceStepID, ProduceStepName, AcceptStoreID, FailedStoreID, LossStoreID, UsageStoreID)
			SELECT @GoodsID,@MaxProduceStepNo,1,1,1,N'اتوماتیک : مرحله 1',@StoreID,@StoreID,@StoreID,@StoreID
		
		END
		
		FETCH NEXT FROM curBenefits INTO @GoodsID, @GoodsID2,@StoreID
	END

	CLOSE curBenefits;
	DEALLOCATE curBenefits;


End
GO
