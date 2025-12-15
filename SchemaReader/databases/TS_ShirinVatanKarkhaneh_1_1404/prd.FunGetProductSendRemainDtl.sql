USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hamid
-- Create date   : 95/03/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--Select * From [prd].[FunGetProductSendRemainDtl] (1, 790, 1)
CREATE FUNCTION [prd].[FunGetProductSendRemainDtl]
(
	@ProcessNo	Int,
	@SerialNo	Int,
	@DocRowNo	Int
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
	Select D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, H.ProductID, H.FormulaNo, 
		   D.SubUnitQuantity / H.ProductCount As EachPrdCount, D.SubUnitQuantity As SendCount, 
		   SendRet.SubUnitQuantity As RetCount, ReceivePrd.SubUnitQuantity * (D.SubUnitQuantity / H.ProductCount) As ReceiveCount,
		   D.SubUnitQuantity - SendRet.SubUnitQuantity - (ReceivePrd.SubUnitQuantity * (D.SubUnitQuantity / H.ProductCount)) As RemainCount,
		   (D.SubUnitQuantity - SendRet.SubUnitQuantity - (ReceivePrd.SubUnitQuantity * (D.SubUnitQuantity / H.ProductCount))) /
		   (D.SubUnitQuantity / H.ProductCount) As ProductRemain
		   
	From inv.tblStorageDocsDtl D
	Inner Join inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And 
										  H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
	Left Join inv.tblStorageDocsDtl SendRet	ON SendRet.BaseProcessID = D.ProcessID And SendRet.BaseProcessNo = D.ProcessNo And 
											   SendRet.BaseFiscalYear = D.FiscalYear And SendRet.BaseSerialNo = D.SerialNo And
											   SendRet.BaseDocRowNo = D.DocRowNo		  
	Left Join inv.tblStorageDocsDtl ReceivePrd ON ReceivePrd.BaseProcessID = H.ProcessID And ReceivePrd.BaseProcessNo = H.ProcessNo And 
												  ReceivePrd.BaseFiscalYear = H.FiscalYear And ReceivePrd.BaseSerialNo = H.SerialNo And
												  ReceivePrd.ProcessID = 80
	Where D.ProcessID = 70 And D.ProcessNo = @ProcessNo And D.SerialNo = @SerialNo And D.DocRowNo = @DocRowNo
)
GO
