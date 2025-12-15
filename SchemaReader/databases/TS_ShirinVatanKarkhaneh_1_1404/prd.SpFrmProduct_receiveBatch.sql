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
Create PROCEDURE prd.SpFrmProduct_receiveBatch
	@StrBatchNo		Varchar(20),
	@AcntCode		Varchar(20),
	@intProcessID	TinyInt,
	@intProcessNo	TinyInt,
	@intFiscalYear	SmallInt,
	@intSerialNo	Int,
	@LanguageID		TinyInt,
	@Prd_SendIsOneStep Bit,
	@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS

BEGIN
	Declare @BaseProcessID	Int

	SET @BaseProcessID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	set @BaseProcessID=isnull(@BaseProcessID,0)
	-----
	Declare @strMsgText				NVarChar(2044)
	Declare @BatchNo				VarChar(20)
	Declare @CountBatchNo			int
	declare @ProduceReceiveWithoutSend BIT
	SET @ProduceReceiveWithoutSend = 'False'
	SELECT @ProduceReceiveWithoutSend=isnull(SettingValue,1) FROM pub.tblSettings 
	WHERE SettingKey='ProduceReceiveWithoutSend' 

	SELECT TOP 1 @BatchNo=BatchNo 
	FROM inv.tblStorageDocsHdr
	WHERE BatchNo = @StrBatchNo
	
	IF @BatchNo='' and @ProduceReceiveWithoutSend = 'False'
		BEGIN
			--به اين شماره بچي وجود ندارد
			SET @strMsgText=TS.pub.funGetMessages(16003,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	IF @intProcessID  in (79,80) AND @Prd_SendIsOneStep='False'
		begin
			declare @SourceSerialNo int
			SET @SourceSerialNo = 0

			SELECT TOP 1 @SourceSerialNo=SerialNo 
			FROM inv.tblStorageDocsHdr
			WHERE BatchNo = @StrBatchNo and ProcessID=70 AND ProcessNo  = @intProcessNo AND DocStep<=1

			IF @SourceSerialNo >0
			BEGIN
				--حواله انبار تبديلي برگه  %d تاييد نشده است 
				SET @strMsgText=TS.pub.funGetMessages(16015,@LanguageID)
				Raiserror (@strMsgText,16,1,@SourceSerialNo)
				Return
			END
		END
if @intProcessID=79
	begin
		SELECT A.*,ProductCount1 - ISNULL(D.GoodsQuantity,0) ProductCount ,ISNULL(DfStoreID,'') StoreID
		FROM (
			SELECT  MAX(S.DocDate) DocDate,S.AcntCode,S.ProductCount ProductCount1,S.ProductID,BatchNo,WageRate,FormulaNo,
				pub.funGetGoodsName(ProductID,@LanguageID) AS GoodsName,
				pub.funGetGoodsUnitID(ProductID) AS UnitID,
				pub.funGetGoodsUnitName(ProductID,@LanguageID) AS UnitName
			FROM inv.tblStorageDocsHdr S
			WHERE Ltrim(BatchNo) <>'' AND BatchNo = @StrBatchNo AND ProcessID=70
			GROUP BY S.AcntCode,S.ProductCount,S.ProductID,BatchNo,WageRate,FormulaNo	
			) A
		LEFT JOIN (
			SELECT  BatchNo,GoodsID, sum(GoodsQuantity) GoodsQuantity  
			FROM inv.tblInvTempReceiptDtl D
			WHERE Ltrim(BatchNo) <>'' AND BatchNo = @StrBatchNo AND ProcessID=79
			Group by BatchNo,GoodsID
				) D
		ON (A.BatchNo=D.BatchNo AND A.ProductID=D.GoodsID ) 
		LEFT JOIN inv.tblGoods G ON A.ProductID=G.GoodsID 
		WHERE  (ProductCount1 - ISNULL(D.GoodsQuantity,0)>0 OR  (ProductCount1 =0 AND D.BatchNo IS NULL))	
				and  A.BatchNo+'@'+ProductID    not in (
					SELECT  BatchNo+'@'+GoodsID  					
					FROM inv.tblStorageDocsDtl D
					WHERE Ltrim(BatchNo) <>'' AND BatchNo = @StrBatchNo AND ProcessID=80
					Group by BatchNo,GoodsID
					having sum(GoodsQuantity) >0)
	end
else
	begin
		if @BaseProcessID=0
		begin
			SELECT A.*,ProductCount1 - ISNULL(D.GoodsQuantity,0) ProductCount ,ISNULL(DfStoreID,'') StoreID
			FROM (
				SELECT  MAX(S.DocDate) DocDate,S.AcntCode,S.ProductCount ProductCount1,S.ProductID,BatchNo,WageRate,FormulaNo,
					pub.funGetGoodsName(ProductID,@LanguageID) AS GoodsName,
					pub.funGetGoodsUnitID(ProductID) AS UnitID,
					pub.funGetGoodsUnitName(ProductID,@LanguageID) AS UnitName
				FROM inv.tblStorageDocsHdr S
				WHERE Ltrim(BatchNo) <>'' AND BatchNo = @StrBatchNo AND ProcessID=70
				GROUP BY S.AcntCode,S.ProductCount,S.ProductID,BatchNo,WageRate,FormulaNo	
				) A
			LEFT JOIN (
				SELECT  BatchNo,GoodsID, sum(GoodsQuantity) GoodsQuantity  
				FROM inv.tblStorageDocsDtl D
				WHERE Ltrim(BatchNo) <>'' AND BatchNo = @StrBatchNo AND ProcessID=80
				Group by BatchNo,GoodsID
					) D
			ON (A.BatchNo=D.BatchNo AND A.ProductID=D.GoodsID ) 
			LEFT JOIN inv.tblGoods G ON A.ProductID=G.GoodsID 
			WHERE  (ProductCount1 - ISNULL(D.GoodsQuantity,0)>0 OR  (ProductCount1 =0 AND D.BatchNo IS NULL))
				and  A.BatchNo+'@'+ProductID    not in (
					SELECT  BatchNo+'@'+GoodsID  
					FROM inv.tblInvTempReceiptDtl D
					WHERE Ltrim(BatchNo) <>'' AND BatchNo = @StrBatchNo AND ProcessID=79
					Group by BatchNo,GoodsID
					having sum(GoodsQuantity) >0)
		END
		if @BaseProcessID=79
		begin
			SELECT A.*,ProductCount1 - ISNULL(D.GoodsQuantity,0) ProductCount ,ISNULL(DfStoreID,'') StoreID
			FROM (
				SELECT  MAX(S.DocDate) DocDate,S.AcntCode,Sum(S.SubUnitQuantity) ProductCount1,S.GoodsID ProductID,BatchNo, 0 WageRate,FormulaNo,
					pub.funGetGoodsName(GoodsID,1) AS GoodsName,
					pub.funGetGoodsUnitID(GoodsID) AS UnitID,
					pub.funGetGoodsUnitName(GoodsID,1) AS UnitName
				FROM inv.tblInvTempReceiptDtl S
				WHERE Ltrim(BatchNo) <>'' AND BatchNo = @StrBatchNo AND ProcessID=79
				GROUP BY S.AcntCode,S.GoodsID,BatchNo,FormulaNo	
				) A
			LEFT JOIN (
				SELECT  BatchNo,GoodsID, sum(GoodsQuantity) GoodsQuantity  
				FROM inv.tblStorageDocsDtl D
				WHERE Ltrim(BatchNo) <>'' AND BatchNo = @StrBatchNo AND ProcessID=80
				Group by BatchNo,GoodsID
					) D
			ON (A.BatchNo=D.BatchNo AND A.ProductID=D.GoodsID ) 
			LEFT JOIN inv.tblGoods G ON A.ProductID=G.GoodsID 
			WHERE  (ProductCount1 - ISNULL(D.GoodsQuantity,0)>0 OR  (ProductCount1 =0 AND D.BatchNo IS NULL))
		
		END
	END
END
GO
