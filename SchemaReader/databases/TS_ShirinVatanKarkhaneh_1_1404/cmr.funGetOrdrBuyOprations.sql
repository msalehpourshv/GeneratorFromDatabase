USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [cmr].[funGetOrdrBuyOprations]
(
	@GoodsID	 Varchar(20),
	@ProcessNo   Int = Null,
	@FiscalYear  Int = Null,
	@SerialNo	 Int = Null,
	@DocRowNo	 Int = Null,
	@DocStep	 Int
)
RETURNS Float
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

DECLARE @Result	Float;

	SELECT @Result =
		(Select Count( Distinct  S.SerialNo)
		From inv.tblStorageDocsDtl S
		Inner Join cmr.tblOrderDtl C ON S.BaseProcessID = C.ProcessID And S.BaseProcessNo = C.ProcessNo And 
									  S.BaseFiscalYear = C.FiscalYear And S.BaseSerialNo = C.SerialNo And 
									  S.BaseDocRowNo = C.DocRowNo
												 
		Where C.ProcessNo = @ProcessNo And C.FiscalYear = @FiscalYear And C.SerialNo = @SerialNo  And C.DocRowNo = @DocRowNo And S.GoodsID = @GoodsID And 
			  (S.DocStep = 0 OR S.DocStep >= @DocStep)) +
		--===
		(Select Count( Distinct  S.SerialNo)
		From cmr.tblOrderDtl C
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = C.ProcessID And T.BaseProcessNo = C.ProcessNo And 
												 T.BaseFiscalYear = C.FiscalYear And T.BaseSerialNo = C.SerialNo And T.BaseDocRowNo = C.DocRowNo
												 
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = T.ProcessID And S.BaseProcessNo = T.ProcessNo And 
											  S.BaseFiscalYear = T.FiscalYear And S.BaseSerialNo = T.SerialNo And S.BaseDocRowNo = T.DocRowNo
											  									 
		Where T.BaseProcessNo = @ProcessNo And T.BaseFiscalYear = @FiscalYear And T.BaseSerialNo = @SerialNo And T.BaseDocRowNo = @DocRowNo And T.GoodsID = @GoodsID And 
			  (S.DocStep = 0 OR S.DocStep >= @DocStep))
			  
		--===
	
		
	Return @Result
	
End   -- === E N D ===============================================
GO
