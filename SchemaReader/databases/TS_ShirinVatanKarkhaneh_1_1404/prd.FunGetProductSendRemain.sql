USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--Select [prd].[FunGetProductSendRemain] (1, 790)
CREATE FUNCTION [prd].[FunGetProductSendRemain]
(
	@ProcessNo	Int = Null,
	@SerialNo	Int = Null
)
RETURNS Decimal(28,9)
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @StrResult AS Decimal(28,9)
	SET @StrResult = 0

	-- ==========
	SELECT @StrResult = MAX(A.ProductRemain)
	FROM
	(
		Select D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, H.ProductID, H.FormulaNo, 
			   D.SubUnitQuantity / H.ProductCount As EachPrdCount, D.SubUnitQuantity As SendCount, 
			   IsNull(SendRet.SubUnitQuantity,0) As RetCount, IsNull(ReceivePrd.SubUnitQuantity,0) * (D.SubUnitQuantity / H.ProductCount) As ReceiveCount,
			   D.SubUnitQuantity - IsNull(SendRet.SubUnitQuantity,0) - (IsNull(ReceivePrd.SubUnitQuantity,0) * (D.SubUnitQuantity / H.ProductCount)) As RemainCount,
			   (D.SubUnitQuantity - IsNull(SendRet.SubUnitQuantity,0) - (IsNull(ReceivePrd.SubUnitQuantity,0) * (D.SubUnitQuantity / H.ProductCount))) /
			   (D.SubUnitQuantity / H.ProductCount) As ProductRemain
			   
		From inv.tblStorageDocsDtl D
		Inner Join inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And 
											  H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
											  
		Left Join (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ProcessID,SUM(SubUnitQuantity) SubUnitQuantity
				   from inv.tblStorageDocsDtl 
				   WHERE BaseProcessNo = @ProcessNo And BaseSerialNo = @SerialNo AND ProcessID = 75
				   GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ProcessID) SendRet	ON SendRet.BaseProcessID = D.ProcessID And SendRet.BaseProcessNo = D.ProcessNo And 
												   SendRet.BaseFiscalYear = D.FiscalYear And SendRet.BaseSerialNo = D.SerialNo And
												   SendRet.BaseDocRowNo = D.DocRowNo AND SendRet.ProcessID = 75
												   
		Left Join (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,ProcessID,SUM(SubUnitQuantity) SubUnitQuantity
				   from inv.tblStorageDocsDtl 
				   WHERE BaseProcessNo = @ProcessNo And BaseSerialNo = @SerialNo
				   GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,ProcessID) ReceivePrd
		ON ReceivePrd.BaseProcessID = H.ProcessID And ReceivePrd.BaseProcessNo = H.ProcessNo And 
													  ReceivePrd.BaseFiscalYear = H.FiscalYear And ReceivePrd.BaseSerialNo = H.SerialNo And
													  ReceivePrd.ProcessID = 80
													  
		Where ProductID <> '' AND D.ProcessID = 70 And D.ProcessNo = @ProcessNo And D.SerialNo = @SerialNo
	) A	

	Return IsNull(@StrResult,0)

END
GO
