USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [cmr].[funGetCmrBuyOprations]
(
	@GoodsID	 Varchar(20),
	@ProcessNo   Int = Null,
	@FiscalYear  Int = Null,
	@SerialNo	 Int = Null,
	@DocStep	 Int
)
RETURNS Float
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

DECLARE @Result	Float;

	SELECT @Result =
		(Select Count(*) 
		From inv.tblStorageDocsDtl S
		Inner Join cmr.tblCMRDtl C ON S.BaseProcessID = C.ProcessID And S.BaseProcessNo = C.ProcessNo And 
									  S.BaseFiscalYear = C.FiscalYear And S.BaseSerialNo = C.SerialNo And 
									  S.BaseDocRowNo = C.DocRowNo
												 
		Where C.ProcessNo = @ProcessNo And C.FiscalYear = @FiscalYear And C.SerialNo = @SerialNo And S.GoodsID = @GoodsID And 
			  (S.DocStep = 0 OR S.DocStep >= @DocStep)) +
		--===
		(Select Count(*) 
		From cmr.tblCMRDtl C
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = C.ProcessID And T.BaseProcessNo = C.ProcessNo And 
												 T.BaseFiscalYear = C.FiscalYear And T.BaseSerialNo = C.SerialNo And T.BaseDocRowNo = C.DocRowNo
												 
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = T.ProcessID And S.BaseProcessNo = T.ProcessNo And 
											  S.BaseFiscalYear = T.FiscalYear And S.BaseSerialNo = T.SerialNo And S.BaseDocRowNo = T.DocRowNo
											  									 
		Where T.BaseProcessNo = @ProcessNo And T.BaseFiscalYear = @FiscalYear And T.BaseSerialNo = @SerialNo And T.GoodsID = @GoodsID And 
			  (S.DocStep = 0 OR S.DocStep >= @DocStep)) +
		--===
		(Select Count(*) 
		From cmr.tblOrderDtl O
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = O.ProcessID And T.BaseProcessNo = O.ProcessNo And 
												 T.BaseFiscalYear = O.FiscalYear And T.BaseSerialNo = O.SerialNo And T.BaseDocRowNo = O.DocRowNo
												 
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = T.ProcessID And S.BaseProcessNo = T.ProcessNo And 
											  S.BaseFiscalYear = T.FiscalYear And S.BaseSerialNo = T.SerialNo And S.BaseDocRowNo = T.DocRowNo								 								 
											  
		Where O.BaseProcessNo = @ProcessNo And O.BaseFiscalYear = @FiscalYear And O.BaseSerialNo = @SerialNo And O.GoodsID = @GoodsID And 
			  (S.DocStep = 0 OR S.DocStep >= @DocStep)) +
		--===
		(Select Count(*) 
		From cmr.tblCMRDtl C
		Inner Join cmr.tblOrderDtl O ON O.BaseProcessID = C.ProcessID And O.BaseProcessNo = C.ProcessNo And 
										O.BaseFiscalYear = C.FiscalYear And O.BaseSerialNo = C.SerialNo And O.BaseDocRowNo = C.DocRowNo
										
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = O.ProcessID And S.BaseProcessNo = O.ProcessNo And 
											  S.BaseFiscalYear = O.FiscalYear And S.BaseSerialNo = O.SerialNo And S.BaseDocRowNo = O.DocRowNo
											  
		Where C.ProcessNo = @ProcessNo And C.FiscalYear = @FiscalYear And C.SerialNo = @SerialNo And S.GoodsID = @GoodsID And 
			  (S.DocStep = 0 OR S.DocStep >= @DocStep))
 
	Return @Result
	
End   -- === E N D ===============================================
GO
