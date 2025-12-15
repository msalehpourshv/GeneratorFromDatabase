USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [prd].[SpFrmProduct_RetGetGoods]
	@StrGoodsID		Varchar(20),
	@StrBatchNo		Varchar(20),
	@intProcessID	TinyInt,
	@intProcessNo	TinyInt,
	@intFiscalYear	SmallInt,
	@intSerialNo	Int,
	@LanguageID		TinyInt

WITH ENCRYPTION
AS

BEGIN

	
	-----
	Declare @strMsgText			NVarChar(2044)
	Declare @GoodsIDCount		INT
	Declare @BatchNo			VarChar(20)
	Declare @CountBatchNo		int
	Declare @SumGoodsQuantity	float
	Declare @SumGoodsQuantityRet	float

	--------------------------------------------------------------------------------------------------------------
	SELECT @GoodsIDCount=ISNULL(Count(H.BatchNo),0)
	FROM inv.tblStorageDocsDtl D,inv.tblStorageDocsHdr H
	WHERE H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
		  H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo AND 
		  H.BatchNo = @StrBatchNo AND H.ProcessID = 70 AND 
		  D.GoodsID = @StrGoodsID AND
	   	  NOT(H.ProcessID=@intProcessID AND 
			  H.ProcessNo=@intProcessNo AND 
			  H.FiscalYear=@intFiscalYear AND 
			  H.SerialNo=@intSerialNo)

	IF @GoodsIDCount = 0
		BEGIN
			--�?� ���� �� ���� �?� ȍ �� ��� ����� ���
			SET @strMsgText=TS.pub.funGetMessages(16005,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END


	--------------------------------------------------------------------------------------------------------------
	SELECT @SumGoodsQuantity=ISNULL(SUM(GoodsQuantity),0)
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

	SELECT @SumGoodsQuantityRet= ISNULL(SUM(GoodsQuantity),0)
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
    

	IF (@SumGoodsQuantity - @SumGoodsQuantityRet) <= 0
		BEGIN
			--����? �?� ���� �ѐ�� ���� ��� ���
			SET @strMsgText=TS.pub.funGetMessages(16006,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END


	SELECT  @SumGoodsQuantity - @SumGoodsQuantityRet as  GoodsQuantity
	
END
GO
