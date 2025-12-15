USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Creation Date : 1396/08/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- ==============================================
Create FUNCTION  [prd].[funMaxRetProduct]
(
	@ProcessID	Int = 70,
	@ProcessNo  Int = 1,
	@FiscalYear Int = 96,
	@SerialNo  	Int = 1300,
	@TypeCount 	Int = 0
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN -- ====================================================


	IF (SELECT TOP 1 COUNT(*) from inv.tblStorageDocsDtl where ProcessID=75)=0
		RETURN 0
	DECLARE @ProductID nvarchar(20)
	DECLARE @ProductCount Float
	DECLARE @Ret Float
	DECLARE @FormulaNoCount Float
	DECLARE @FormulaNo int

	Select @ProductID = ProductID, @ProductCount= ProductCount, @FormulaNo=FormulaNo 
	From inv.tblStorageDocsHdr 
	Where ProcessID = @ProcessID and ProcessNo = @ProcessNo  and FiscalYear = @FiscalYear and SerialNo = @SerialNo 
	
	Select @FormulaNoCount = ProductCount 
	From prd.tblFormulasHdr 
	Where ProductID = @ProductID and SerialNo = @FormulaNo

	-- =======================
	IF @TypeCount = 0
	BEGIN
	 	 SELECT @Ret = Sum(MaxCounts) 
		 FROM 
		 (
			Select MAX(MaxCounts) MaxCounts,SerialNo 
			From 
			(
				Select a.ProcessID, a.ProcessNo, a.FiscalYear, a.SerialNo, @ProductID ProductID, @ProductCount ProductCount,
					   @FormulaNoCount FormulaNoCount, @FormulaNo FormulaNo, a.GoodsID, a.GoodsQuantity,
					   a.GoodsQuantity * @FormulaNoCount / b.GoodsQuantity MaxCounts
				From inv.tblStorageDocsDtl  a
				Inner Join prd.tblFormulasDtl b ON b.ProductID = @ProductID and b.SerialNo = @FormulaNo and 
												   a.GoodsID = b.GoodsID
				Where ProcessID = 75 and BaseProcessID = @ProcessID and BaseProcessNo = @ProcessNo and
					  BaseFiscalYear = @FiscalYear and BaseSerialNo = @SerialNo
			) aa 
			Group By SerialNo
		 ) bb
	END
	
	-- =======================
	IF @TypeCount = 1
	BEGIN
		 SELECT @Ret = Sum(MaxCounts) 
		 FROM 
		 (
			 Select MAX(MaxCounts) MaxCounts, SerialNo 
			 From (
					Select a.ProcessID, a.ProcessNo, a.FiscalYear, a.SerialNo, @ProductID ProductID, @ProductCount ProductCount,
						   @FormulaNoCount FormulaNoCount, @FormulaNo FormulaNo, a.GoodsID, a.GoodsQuantity,  
						   a.GoodsQuantity * @ProductCount / b.GoodsQuantity MaxCounts
					From inv.tblStorageDocsDtl  a
					Inner Join inv.tblStorageDocsDtl b ON a.BaseProcessID = b.ProcessID and a.BaseProcessNo = b.ProcessNo and
														  a.BaseFiscalYear = b.FiscalYear and a.BaseSerialNo = b.SerialNo and 
														  a.GoodsID = b.GoodsID
					Where a.ProcessID = 75 and a.BaseProcessID = @ProcessID and a.BaseProcessNo = @ProcessNo and 
						  a.BaseFiscalYear = @FiscalYear and a.BaseSerialNo = @SerialNo
				   ) aa 
			Group by SerialNo
		 ) bb
	END

	IF @TypeCount = 2
	BEGIN
		Set @Ret = 0
	END

	RETURN IsNull(@Ret, 0)
	
END
GO
