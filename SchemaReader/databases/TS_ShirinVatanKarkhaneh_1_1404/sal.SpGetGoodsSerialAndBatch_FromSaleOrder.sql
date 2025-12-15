USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--===================================
--Aoutor : Hamid
--Date   : 1393/11/18
--===================================
CREATE PROCEDURE [sal].[SpGetGoodsSerialAndBatch_FromSaleOrder]
(
	@DocDate	Char(10) = Null,
	@StoreID	VarChar(20) = Null,
	@GoodsID	VarChar(20) = Null,
	@ExpireDate	VarChar(10) = Null,
	@Count		Int = Null
)
WITH ENCRYPTION
AS
BEGIN

	-- Declare the return variable here
	Select Top 1 * From 
	(
		Select D.GoodsID, S.BatchNo, S.ExpireDate, S.ProductSerialID, Sum(D.GoodsQuantity * D.EnterKind) GoodsRemain, COUNT(*) As RCount
		From inv.tblStorageDocsDtl D
		Inner Join inv.tblStorageDocsSerials S ON S.ProcessID = D.ProcessID And S.ProcessNo = D.ProcessNo And S.FiscalYear = D.FiscalYear And
												  S.SerialNo = D.SerialNo								      
										      
		Where D.DocDate <= @DocDate And (@StoreID = '' OR D.StoreID = @StoreID) And D.GoodsID = @GoodsID And S.ExpireDate = @ExpireDate 
		and  S.BatchNo<>''
		Group By D.GoodsID, S.BatchNo, S.ExpireDate, S.ProductSerialID
	) A
	Where A.GoodsRemain > @Count
	Order By A.ExpireDate

END
GO
