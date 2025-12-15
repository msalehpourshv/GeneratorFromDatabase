USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [cmr].[spFrmOrderSave] 
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @DocDate		char(10),
 @LanguageID    TinyInt=1
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;
	Declare @strMsgText	 NVarChar(2044)
	Declare @Counter	 Int

	Declare @BaseFiscalYear	Smallint
	Declare @BaseSerialNo	Int
	Declare @BaseDocRowNo	Int
	Declare @AcntCode		Varchar(20)
	Declare @GoodsID		Varchar(20)
	Declare @UsedGoodsQuantity	Float
	Declare @GoodsQuantity	Float

	SET @AcntCode = NULL

	Declare	Cursor_PayDtl CURSOR For 
	SELECT	BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID,GoodsQuantity
	FROM cmr.tblOrderDtl
	WHERE ProcessID = @ProcessID AND
		  ProcessNo = @ProcessNo AND
		  FiscalYear= @FiscalYear AND
		  SerialNo  = @SerialNo 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@GoodsID,@GoodsQuantity

	While (@@Fetch_Status = 0)
		BEGIN
			---------------------------------------------------
			IF @ProcessID = 160 --BuyRequest
			BEGIN
				Select	@UsedGoodsQuantity = CmrCnf.ConfirmQuantity  - ISNULL(CmrOrder.ConfirmQuantity,0) - ISNULL(InvTempReceipt.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0) 
				From
					(
						SELECT DISTINCT * 
						FROM  [cmr].[FunGetCmrGoods](@AcntCode,@DocDate)
						WHERE	FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND
								DocRowNo = @BaseDocRowNo
					) CmrCnf 
				LEFT JOIN 
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
						FROM  [cmr].[FunGetOrderGoods](@AcntCode,'',@DocDate,1,2)
					) CmrOrder
					ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
					   CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
					   CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
				LEFT JOIN
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
						FROM  [cmr].[FunGetBaseInvTempReceiptGoods](@AcntCode,@DocDate,1,2,NULL,NULL) 
					) InvTempReceipt
					ON CmrCnf.ProcessID = InvTempReceipt.BaseProcessID AND  CmrCnf.ProcessNo = InvTempReceipt.BaseProcessNo AND 
					   CmrCnf.FiscalYear = InvTempReceipt.BaseFiscalYear AND CmrCnf.SerialNo = InvTempReceipt.BaseSerialNo AND 
   					   CmrCnf.DocRowNo = InvTempReceipt.BaseDocRowNo 
				LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
						From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,NULL,NULL) 
						
					) StorageDocs
					ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
					   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
					   CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo

				IF (@UsedGoodsQuantity ) < 0
					-- مقدار کالای %S بیش از مقدار سفارش خرید است
					SET @strMsgText=TS.pub.funGetMessages(14002,@LanguageID)
			END--IF @ProcessID = 150 --BuyRequest
			---------------------------------------------------
			IF @ProcessID = 165 --BuyRequest
			BEGIN
				Select	@UsedGoodsQuantity = Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0)
				From
					(
						Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
								DocRowNo , GoodsQuantity
						From cmr.tblOrderDtl 
						Where	ProcessID = 160 AND ProcessNo=@ProcessNo AND 
								(@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate <= @DocDate AND DocStep in (0,2) AND
								FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND DocRowNo = @BaseDocRowNo
					) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
							BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
					From cmr.tblOrderDtl 
					Where BaseProcessID = 160 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
							 BaseSerialNo , BaseDocRowNo
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo
				IF (@UsedGoodsQuantity ) < 0
					-- مقدار کالای %S بیش از مقدار سفارش خرید است
					SET @strMsgText=TS.pub.funGetMessages(14002,@LanguageID)

			END
			---------------------------------------------------
			IF @strMsgText<>''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					Raiserror (@strMsgText,16,1,@GoodsID)
					Return
				END

				
			Fetch NEXT From Cursor_PayDtl Into @BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@GoodsID,@GoodsQuantity
		END 

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 
--	SELECT @Counter=Count(*) 
--	FROM cmr.tblOrderDtl
--	WHERE (BaseProcessID=@ProcessID AND
--		   BaseProcessNo=@ProcessNo AND 
--		   BaseFiscalYear=@FiscalYear AND
--		   BaseSerialNo=@SerialNo) AND
--		not(ProcessID=@ProcessID AND
--			ProcessNo=@ProcessNo AND 
--			FiscalYear=@FiscalYear AND
--			SerialNo=@SerialNo)
--
--	IF @Counter>0
--	BEGIN
--		SET @strMsgText=TS.pub.funGetMessages(13003,@LanguageID)
--		Raiserror (@strMsgText,16,1)
--		Return
--	END
--END
--ELSE
--IF @ProcessID=155
--BEGIN
--
--END

END


























GO
