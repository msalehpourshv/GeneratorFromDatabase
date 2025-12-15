USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/01/31
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[funGoodsRemain]
(
	-- Add the parameters for the function here
	@ProcessID			Smallint,
	@ProcessNo			TinyInt,
	@FiscalYear			smallint=NULL,
	@SerialNo			int=NULL,
	@VolumeRowNo    	FLOAT=NULL,	
	@BaseProcessID		Smallint,
	@BaseProcessNo		TinyInt,
	@BaseFiscalYear		Smallint,
	@BaseSerialNo		Int,
	@BaseDocRowNo		Int,
	@DocDate			Char(10),
	@AcntCode			VarChar(20)
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN
	-- Declare the return variable here
	
	IF @FiscalYear IS NULL OR @FiscalYear = 0
		SET @FiscalYear =  RIGHT(db_name(),4)
			
	DECLARE @Result			Float
	SET @Result =0

	IF @AcntCode = ''
		SET @AcntCode = NULL

	IF @ProcessID=55 -- خرید
		BEGIN
	-------------------------------------------------------------------------------------------------------------------
			IF @BaseProcessID = 150 -- درخواست خرید
				Select	@Result = (CmrCnf.ConfirmQuantity - ISNULL(CmrOrder.ConfirmQuantity,0) - ISNULL(InvTempReceipt.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0))
				From
					(
						SELECT DISTINCT * 
						FROM  [cmr].[FunGetCmrGoods](@AcntCode,@DocDate)
						where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
					) CmrCnf 
				LEFT JOIN 
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
						FROM  [cmr].[FunGetBaseOrderGoods](@AcntCode,@DocDate,1,2,null,null) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) CmrOrder
					ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
					CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
					CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
				LEFT JOIN
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
						FROM  [cmr].[FunGetBaseInvTempReceiptGoods](@AcntCode,@DocDate,1,2,null,null) 
						WHERE ConfirmQuantity > 0	AND BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo	
					) InvTempReceipt
					ON CmrCnf.ProcessID = InvTempReceipt.BaseProcessID AND  CmrCnf.ProcessNo = InvTempReceipt.BaseProcessNo AND 
					CmrCnf.FiscalYear = InvTempReceipt.BaseFiscalYear AND CmrCnf.SerialNo = InvTempReceipt.BaseSerialNo AND 
					CmrCnf.DocRowNo = InvTempReceipt.BaseDocRowNo 
				LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
						From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,null,null) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) StorageDocs
					ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
					CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
					CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo
				WHERE CmrCnf.DocDate<=@DocDate 
	-------------------------------------------------------------------------------------------------------------------
			ELSE IF @BaseProcessID = 160 -- سفارش خرید
				Select	@Result = (CmrCnf.ConfirmQuantity - ISNULL(InvTempReceipt.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0))
				From
					(
						Select	ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,DocDate,ConfirmQuantity 
						FROM  [cmr].[FunGetOrderGoods](@AcntCode,'',@DocDate,1,2) 
						where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
					) CmrCnf 
				LEFT JOIN
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
						FROM  [cmr].[FunGetBaseInvTempReceiptGoods](@AcntCode,@DocDate,1,2,null,null) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) InvTempReceipt
					ON CmrCnf.ProcessID = InvTempReceipt.BaseProcessID AND  CmrCnf.ProcessNo = InvTempReceipt.BaseProcessNo AND 
					CmrCnf.FiscalYear = InvTempReceipt.BaseFiscalYear AND CmrCnf.SerialNo = InvTempReceipt.BaseSerialNo AND 
					CmrCnf.DocRowNo = InvTempReceipt.BaseDocRowNo 
				LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
						From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,null,null) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) StorageDocs
					ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
					CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
					CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo
				WHERE CmrCnf.DocDate<=@DocDate 

	-------------------------------------------------------------------------------------------------------------------
			ELSE IF @BaseProcessID = 170 -- رسید موقت
				Select	@Result = (CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0))
				From
					(
						Select	ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,DocDate,ConfirmQuantity 
						FROM  [cmr].[FunGetInvTempReceiptGoods](@AcntCode,@DocDate,1,2) 
						where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
					) CmrCnf 
				LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
						From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,null,null) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) StorageDocs
					ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
					CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
					CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo
				WHERE CmrCnf.DocDate<=@DocDate  

		END
	-------------------------------------------------------------------------------------------------------------------
	ELSE IF @ProcessID=60 AND @BaseProcessID >0 --برگشت از خرید
		SELECT @Result = Cn.GoodsQuantity
		FROM inv.tblStorageDocsDtl OD 
			INNER JOIN
			(
				Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity
				From
					(
						SELECT	ProcessID , ProcessNo , FiscalYear ,SerialNo , 
								DocRowNo , GoodsQuantity
						From inv.tblStorageDocsDtl
						where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
						  and DocStep=2
					) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
							Sum(GoodsQuantity) GoodsQuantity
					From inv.tblStorageDocsDtl 
					where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo	
			) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
					Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo 
			WHERE	(@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate 
	-------------------------------------------------------------------------------------------------------------------
	ELSE IF @ProcessID=110 -- مصرف داخلی
		Select	@Result = CmrCnf.ConfirmQuantity - ISNULL(CmrOrder.ConfirmQuantity,0)
		From
			(
				Select	ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,DocDate,GoodsQuantity as ConfirmQuantity 
				FROM  inv.tblStoresRequestsDtl
				where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
			) CmrCnf 
		LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,null,null) 
				where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
			) CmrOrder
			ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
			CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
			CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
		WHERE CmrCnf.DocDate<=@DocDate 
	-------------------------------------------------------------------------------------------------------------------
	ELSE IF @ProcessID=115 and @BaseProcessID > 0 -- برگشت مصرف داخلی

		SELECT @Result = Cn.GoodsQuantity
		FROM inv.tblStorageDocsDtl OD 
			INNER JOIN
			(
				Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,DocRowNo , Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity
				From
					(
						Select	ProcessID , ProcessNo , FiscalYear ,SerialNo , 
								DocRowNo , GoodsQuantity
						From inv.tblStorageDocsDtl
						where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
						 AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocStep=3 AND DocDate <= @DocDate
					) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
							Sum(GoodsQuantity) GoodsQuantity
					From inv.tblStorageDocsDtl 
					where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					  AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo	
			) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
					Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND  Cn.DocRowNo = OD.DocRowNo
		WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate --AND StoreID=@StoreID

	ELSE IF @ProcessID=170 -- رسید موقت
		BEGIN
	-------------------------------------------------------------------------------------------------------------------
			IF @BaseProcessID = 150 -- درخواست کالا
				Select	@Result = (CmrCnf.ConfirmQuantity-ISNULL(CmrOrder.ConfirmQuantity,0)-ISNULL(InvTempReceipt.ConfirmQuantity,0)-ISNULL(StorageDocs.ConfirmQuantity,0))
				From
					(
						SELECT DISTINCT * 
						FROM  [cmr].[FunGetCmrGoods](@AcntCode,@DocDate) 
						where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
					) CmrCnf 
				LEFT JOIN 
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
						FROM  [cmr].[FunGetBaseOrderGoods](@AcntCode,@DocDate,1,2,NULL,NULL) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) CmrOrder
					ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
					   CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
					   CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
				LEFT JOIN
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
						FROM  [cmr].[FunGetBaseInvTempReceiptGoods](@AcntCode,@DocDate,1,2,null,null) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) InvTempReceipt
					ON CmrCnf.ProcessID = InvTempReceipt.BaseProcessID AND  CmrCnf.ProcessNo = InvTempReceipt.BaseProcessNo AND 
					   CmrCnf.FiscalYear = InvTempReceipt.BaseFiscalYear AND CmrCnf.SerialNo = InvTempReceipt.BaseSerialNo AND 
					   CmrCnf.DocRowNo = InvTempReceipt.BaseDocRowNo 
				LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
						From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,null,null) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) StorageDocs
					ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
					   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
					   CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo 
				WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND  CmrCnf.DocDate<=@DocDate

			ELSE IF @BaseProcessID = 160 -- سفارش کالا
				Select	@Result = (CmrCnf.ConfirmQuantity-ISNULL(InvTempReceipt.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0))
				From
					(
						Select	ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,DocDate,ConfirmQuantity 
						FROM  [cmr].[FunGetOrderGoods](@AcntCode,'',@DocDate,1,2) 
						where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
					) CmrCnf 
				LEFT JOIN
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity
						FROM  [cmr].[FunGetBaseInvTempReceiptGoods](@AcntCode,@DocDate,1,2,null,null) 
					) InvTempReceipt
					ON CmrCnf.ProcessID = InvTempReceipt.BaseProcessID AND  CmrCnf.ProcessNo = InvTempReceipt.BaseProcessNo AND 
					   CmrCnf.FiscalYear = InvTempReceipt.BaseFiscalYear AND CmrCnf.SerialNo = InvTempReceipt.BaseSerialNo AND 
					   CmrCnf.DocRowNo = InvTempReceipt.BaseDocRowNo 
				LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
						From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,null,null) 
						where BaseProcessID =@BaseProcessID AND BaseProcessNo=@BaseProcessNo AND BaseFiscalYear=@BaseFiscalYear and BaseSerialNo=@BaseSerialNo and BaseDocRowNo=@BaseDocRowNo
					) StorageDocs
					ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
					   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
					   CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo 
				WHERE CmrCnf.DocDate<=@DocDate 

		END
	ELSE IF @ProcessID=175 --برگشت از رسید موقت
		SELECT 	@Result =  Cn.ConfirmQuantity
		FROM inv.tblInvTempReceiptDtl OD 
			INNER JOIN
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [cmr].[FunGetInvTempReceiptGoods](@AcntCode,@DocDate,2,2)
				where ProcessID =@BaseProcessID AND ProcessNo=@BaseProcessNo AND FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo and DocRowNo=@BaseDocRowNo
			) Cn ON Cn.BaseProcessID = OD.BaseProcessID AND Cn.BaseProcessNo = OD.BaseProcessNo AND 
					Cn.BaseFiscalYear = OD.BaseFiscalYear AND Cn.BaseSerialNo = OD.BaseSerialNo AND Cn.BaseDocRowNo = OD.BaseDocRowNo
		WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate 

	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	IF @QuantityDecimalsToForms>0
		SET		@QuantityDecimalsToForms = @QuantityDecimalsToForms - 1
		
	-- ===================================
	IF @Result > 0 and @ProcessID IS NOT NULL AND @ProcessID>0 AND @SerialNo IS NOT NULL AND @SerialNo>0  AND @FiscalYear IS NOT NULL AND @FiscalYear>0 AND @VolumeRowNo IS NOT NULL AND @VolumeRowNo>0
		SELECT @Result = Round(@Result * b.UnitValue/b.MainUnitValue, @QuantityDecimalsToForms)
		FROM   inv.tblStorageDocsDtl a
		INNER JOIN inv.tblSubUnitsDtl b
		ON a.GoodsID=b.GoodsID and a.SubUnitID=b.SubUnitID
		WHERE  (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate AND FiscalYear=@FiscalYear AND ProcessID = @ProcessID AND 
				ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and SerialNo=@SerialNo AND VolumeRowNo=@VolumeRowNo
		 
	RETURN @Result
	
END
GO
