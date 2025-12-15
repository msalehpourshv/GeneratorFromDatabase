USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

CREATE FUNCTION [prd].[FunGetGoodsQuantityFromBatchNo]
(
	@StrBatchNo Varchar(20),
	@StrGoodsID Varchar(20),
	@intProcessID	TinyInt,
	@intProcessNo	TinyInt,
	@intFiscalYear	SmallInt,
	@intSerialNo	Int
)
RETURNS float  
WITH ENCRYPTION
AS
BEGIN

	DECLARE @SumGoodsQuantity    float 
	DECLARE @SumGoodsQuantityRet float 

	SELECT @SumGoodsQuantity =ISNULL(SUM(GoodsQuantity),0) 
	FROM inv.tblStorageDocsDtl D,inv.tblStorageDocsHdr H
	WHERE H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
		  H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo AND 
		  H.BatchNo=@StrBatchNo AND
		  D.GoodsID = @StrGoodsID AND
		  H.ProcessID=70 AND
		  NOT(H.ProcessID=@intProcessID AND 
			  H.ProcessNo=@intProcessNo AND 
			  H.FiscalYear=@intFiscalYear AND 
			  H.SerialNo=@intSerialNo)

	SELECT @SumGoodsQuantityRet=ISNULL(SUM(GoodsQuantity),0) 
	FROM inv.tblStorageDocsDtl D,inv.tblStorageDocsHdr H
	WHERE H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
		  H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo AND 
		  H.BatchNo=@StrBatchNo AND
		  D.GoodsID = @StrGoodsID AND
		  H.ProcessID=75 AND
		  NOT(H.ProcessID=@intProcessID AND 
			  H.ProcessNo=@intProcessNo AND 
			  H.FiscalYear=@intFiscalYear AND 
			  H.SerialNo=@intSerialNo) 
	
	Return @SumGoodsQuantity - @SumGoodsQuantityRet 

END











GO
