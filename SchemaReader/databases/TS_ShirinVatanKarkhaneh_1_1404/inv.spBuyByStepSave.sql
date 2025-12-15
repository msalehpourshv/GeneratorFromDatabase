USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1386/11/30
-- Viewed By	 : 
-- Last Modified : 1387/12/18
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[spBuyByStepSave] 
 @ProcessID		Tinyint,
 @ProcessNo		Tinyint,
 @FiscalYear	Smallint,
 @SerialNo		Int,
 @AcntCode		Varchar(20),
 @DocDate		char(10),
 @BaseProcessID	Tinyint,
 @BaseProcessNo	Tinyint,
 @LanguageID	TinyInt
 WITH ENCRYPTION
AS

BEGIN
SET NOCOUNT ON;

	Declare @strMsgText		NVarChar(2044)
	Declare @DocStep		Tinyint
	Declare @BaseFiscalYear	Smallint
	Declare @BaseSerialNo	Int
	Declare @BaseDocRowNo	Int
	Declare @GoodsID		Varchar(20)
	Declare @UsedGoodsQuantity	Float
	Declare @GoodsQuantity	Float

	SET @strMsgText = ''
	SET @UsedGoodsQuantity = 0

	Declare	Cursor_PayDtl CURSOR For 
	SELECT	DocStep,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID,GoodsQuantity
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID = @ProcessID AND
		  ProcessNo = @ProcessNo AND
		  FiscalYear= @FiscalYear AND
		  SerialNo  = @SerialNo 

	Open  Cursor_PayDtl; 

	Fetch NEXT From Cursor_PayDtl Into @DocStep,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@GoodsID,@GoodsQuantity

	While (@@Fetch_Status = 0)
		BEGIN
			---------------------------------------------------
			IF @BaseProcessID = 150 --BuyRequest
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
					-- مقدار کالای %S بیش از مقدار درخواست خرید است
					SET @strMsgText=TS.pub.funGetMessages(14001,@LanguageID)

			END --ELSE IF @BaseSerialNo = 150
			---------------------------------------------------
			ELSE IF @BaseProcessID = 160 --BuyOrder
			BEGIN

				Select	@UsedGoodsQuantity = CmrCnf.ConfirmQuantity - ISNULL(CmrOrder.ConfirmQuantity,0) - ISNULL(InvTempReceipt.ConfirmQuantity,0) From
				(
					Select	ProcessID , ProcessNo , FiscalYear , SerialNo,DocRowNo,DocDate,ConfirmQuantity
					FROM  [cmr].[FunGetOrderGoods](@AcntCode,'',@DocDate,1,2) 
					WHERE	FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND
							DocRowNo = @BaseDocRowNo

				) CmrCnf 
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
				) CmrOrder
				ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
				   CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
				   CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo AND CmrCnf.DocDate<=@DocDate 

			---------------------------------------------------
				IF @UsedGoodsQuantity < 0
					-- مقدار کالای %S بیش از مقدار سفارش است
					SET @strMsgText=TS.pub.funGetMessages(14002,@LanguageID)

			END --ELSE IF @BaseSerialNo = 160
			---------------------------------------------------
			ELSE IF @BaseProcessID = 170
			BEGIN
				Select	@UsedGoodsQuantity = CmrCnf.ConfirmQuantity - ISNULL(CmrOrder.ConfirmQuantity,0) 
				From
				(
					Select	ProcessID , ProcessNo , FiscalYear , SerialNo,DocRowNo,DocDate,ConfirmQuantity
					FROM  [cmr].[FunGetInvTempReceiptGoods](@AcntCode,@DocDate,1,2) 
					WHERE	FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND
							DocRowNo = @BaseDocRowNo

				) CmrCnf 
			LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
					From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,NULL,NULL) 
				) CmrOrder
				ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
				   CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
				   CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo AND CmrCnf.DocDate<=@DocDate 


			---------------------------------------------------
				IF @UsedGoodsQuantity  < 0
					-- مقدار کالای %S بیش از مقدار رسید موقت است
					SET @strMsgText=TS.pub.funGetMessages(14003,@LanguageID)

			END --ELSE IF @BaseSerialNo = 170
			ELSE IF @BaseProcessID = 55
			BEGIN

				Select	@UsedGoodsQuantity = Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0)
				From
					(
						Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
								DocRowNo , GoodsQuantity
						From inv.tblStorageDocsDtl 
						Where	ProcessID = 55 AND ProcessNo=@ProcessNo AND 
								(@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate <= @DocDate AND DocStep in (0,2) AND
								FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND DocRowNo = @BaseDocRowNo
					) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
							BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where BaseProcessID = 55 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
							 BaseSerialNo , BaseDocRowNo
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo

			---------------------------------------------------
				IF @UsedGoodsQuantity < 0
					-- مقدار کالای %S بیش از مقدار خرید است
					SET @strMsgText=TS.pub.funGetMessages(14004,@LanguageID)

			END --ELSE IF @BaseSerialNo = 55
			ELSE IF @BaseProcessID = 110
			BEGIN
				Select	@UsedGoodsQuantity = Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) 
				From
					(
						Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
								DocRowNo , GoodsQuantity
						From inv.tblStorageDocsDtl 
						Where	ProcessID = 110   AND ProcessNo = @ProcessNo AND 
								(@AcntCode IS NULL OR AcntCode   = @AcntCode) AND 
								DocDate <= @DocDate AND DocStep = 3 AND
								FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND DocRowNo = @BaseDocRowNo
					) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
							BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where BaseProcessID = 110 AND ProcessNo=@ProcessNo AND 
						 (@AcntCode IS NULL OR AcntCode   = @AcntCode)  
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
							 BaseSerialNo , BaseDocRowNo
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo

			---------------------------------------------------
				IF @UsedGoodsQuantity < 0
					-- مقدار کالای %S بیش از مقدار مصرف داخلی است
					SET @strMsgText=TS.pub.funGetMessages(14005,@LanguageID)

			END
			---------------------------------------------------
			IF @strMsgText<>''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl;
					Raiserror (@strMsgText,16,1,@GoodsID)
					Return
				END

				
			Fetch NEXT From Cursor_PayDtl Into @DocStep,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@GoodsID,@GoodsQuantity
		END 

	Close Cursor_PayDtl;
	Deallocate Cursor_PayDtl; 
END
GO
