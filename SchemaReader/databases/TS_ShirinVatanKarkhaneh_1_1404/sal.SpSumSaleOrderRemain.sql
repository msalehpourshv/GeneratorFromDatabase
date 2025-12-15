USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[sal].[SpSumSaleOrderRemain] '030101','1390/03/09',90,1,1
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Sadeghi
-- Create date   : 1390/03/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE PROCEDURE  [sal].[SpSumSaleOrderRemain] 
	@AcntCode	Varchar(20),
	@DocDate	Char(10),
	@FiscalYear	Int,
	@ProcessNo	tinyint,
	@SerialNo	int,
	@Return		Bit,
	@DocStep	tinyint
	
WITH ENCRYPTION
AS
BEGIN

	DECLARE @LastPriceInSaleorderForSale AS BIT
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	DECLARE @SalRet_RetToSalOdr AS BIT
	
	SET @LastPriceInSaleorderForSale = 'False'
	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	BEGIN TRAN

	BEGIN TRY
			
		SELECT @LastPriceInSaleorderForSale=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'LastPriceInSaleorderForSale'
		
		SELECT @SalOrder_ConfirmDocStep=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'SalOrder_ConfirmDocStep'
		
		SELECT @SalRet_RetToSalOdr = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'SalRet_RetToSalOdr' 
		
		IF @DocStep = 0
			BEGIN
				IF @SalOrder_ConfirmDocStep = 'False' 
					SET @DocStep = 1
				ELSE
					SET @DocStep = 2
			END
			
		DECLARE @maxSerialNo_Ret INT
		
		SELECT @maxSerialNo_Ret = ISNULL(MAX(SerialNo),0)+1
		FROM sal.tblSaleOrderHdr
		WHERE ProcessID=185 AND FiscalYear = @FiscalYear AND ProcessNo=@ProcessNo
		
		IF (
		SELECT  COUNT (*)
			FROM	
				(
				Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.DocDate,DocDesc,
						CmrCnf.ConfirmQuantity  - ISNULL(CmrOrder.ConfirmQuantity,0)  AS ConfirmQuantity ,GoodsPrice,VisitorAcntCode,SaleTypeID 
				From
					(
						SELECT DISTINCT * 
						FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,0,0)
						WHERE ProcessNo = @ProcessNo AND (@SerialNo =0 OR SerialNo=@SerialNo)			
					) CmrCnf 
				LEFT JOIN 
					(
						SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity,SubUnitQuantity
						FROM  [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,NULL,NULL) 
						WHERE  (@SerialNo =0 OR BaseSerialNo=@SerialNo)
					) CmrOrder
					ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
					CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
					CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
				) CMRSaleOrderHdr
			INNER JOIN
			sal.tblSaleOrderDtl OD
			ON	OD.ProcessID = CMRSaleOrderHdr.ProcessID AND  OD.ProcessNo = CMRSaleOrderHdr.ProcessNo AND 
				OD.FiscalYear = CMRSaleOrderHdr.FiscalYear AND OD.SerialNo = CMRSaleOrderHdr.SerialNo AND 
				OD.DocRowNo = CMRSaleOrderHdr.DocRowNo
			INNER JOIN
			(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False' ) G
			ON OD.GoodsID = G.GoodsID 
			WHERE	OD.ProcessID=180 AND OD.ProcessNo=@ProcessNo AND 
				   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 	
		) >0
		BEGIN
			INSERT INTO sal.tblSaleOrderHdr
				   ([ProcessID],[ProcessNo],[FiscalYear],[SerialNo],[DocStep],[DocDate],[AcntCode],[BaseProcessID],[BaseProcessNo],[BaseFiscalYear],[BaseSerialNo],[BaseDocType]
				   ,[DocDesc],[AgreeNo],[OrderDate],[DeliveryDate],[SaleTypeID],[VisitorAcntCode],[RecID],[SessionNo],[OldSerialNo],[Returned],[MaxDebitRemain]
				   ,[MaxReceivableRemain],[AccountRemain],[UnReceipts],[DocDate2],[AutoOrder])
			VALUES(185 , @ProcessNo , @FiscalYear , @maxSerialNo_Ret  , 1 , @DocDate , @AcntCode , 0 , 0 , @FiscalYear , 0 , 180 , '' , '' , '' , '' , '' , '' , 0 , 0 , 0 , 0 ,0 ,0 ,0 , 0 , '', ~ @Return )--'True' )
			

			INSERT INTO [sal].[tblSaleOrderDtl]
			(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,DocStep,
				DocDate, AcntCode, GoodsID, SubUnitID, SubUnitQuantity,
				ConfirmQuantity, GoodsQuantity, GoodsPrice, DescDtl, BaseDocType,
				BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
				BaseDocRowNo, AgreeNo, OrderDate, DeliveryDate, VisitorAcntCode,
				IsReward, SubUnitPrice,AutoOrder, 
				DiscountPercentDtl, DiscountDtl)
			SELECT  185 ProcessID, @ProcessNo , @FiscalYear , @maxSerialNo_Ret , Row_Number() Over (ORDER BY AcntCode) RowNo, Row_Number() Over (ORDER BY AcntCode) DocRowNo,
					1 DocStep, @DocDate DocDate, @AcntCode AcntCode, OD.GoodsID, OD.SubUnitID, inv.funGetGoodsSubQuantity(OD.GoodsID,OD.SubUnitID,CMRSaleOrderHdr.ConfirmQuantity) SubUnitQuantity, CMRSaleOrderHdr.ConfirmQuantity,
					CMRSaleOrderHdr.ConfirmQuantity GoodsQuantity,CMRSaleOrderHdr.GoodsPrice, '' DescDtl,180 BaseDocType ,OD.ProcessID BaseProcessID ,OD.ProcessNo BaseProcessNo,OD.FiscalYear BaseFiscalYear,OD.SerialNo BaseSerialNo,
					OD.DocRowNo BaseDocRowNo, OD.AgreeNo, '' OrderDate, '' DeliveryDate,OD.VisitorAcntCode,[IsReward],[SubUnitPrice],~ @Return ,DiscountPercentDtl,DiscountDtl
				FROM	
					(
					Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,CmrCnf.DocDate,DocDesc,
							CmrCnf.ConfirmQuantity  - ISNULL(CmrOrder.ConfirmQuantity,0)  AS ConfirmQuantity ,GoodsPrice,VisitorAcntCode,SaleTypeID 
					From
						(
							SELECT DISTINCT * 
							FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr,0,0)
							WHERE ProcessNo = @ProcessNo AND (@SerialNo =0 OR SerialNo=@SerialNo)			
						) CmrCnf 
					LEFT JOIN 
						(
							SELECT DISTINCT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,ConfirmQuantity,SubUnitQuantity
							FROM  [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,NULL,NULL) 
							WHERE  (@SerialNo =0 OR BaseSerialNo=@SerialNo)
						) CmrOrder
						ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
						CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
						CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
					) CMRSaleOrderHdr
				INNER JOIN
				sal.tblSaleOrderDtl OD
				ON	OD.ProcessID = CMRSaleOrderHdr.ProcessID AND  OD.ProcessNo = CMRSaleOrderHdr.ProcessNo AND 
					OD.FiscalYear = CMRSaleOrderHdr.FiscalYear AND OD.SerialNo = CMRSaleOrderHdr.SerialNo AND 
					OD.DocRowNo = CMRSaleOrderHdr.DocRowNo
				INNER JOIN
				(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False' ) G
				ON OD.GoodsID = G.GoodsID 
				WHERE	OD.ProcessID=180 AND OD.ProcessNo=@ProcessNo AND 
					   (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<= @DocDate  AND CMRSaleOrderHdr.ConfirmQuantity>0 	
			

		IF @Return = 'False'
			BEGIN
				DECLARE @maxSerialNo INT
				DECLARE @SaleTypeID varchar(20)
				SET @SaleTypeID = ''
				
				SELECT @maxSerialNo = ISNULL(MAX(SerialNo),0)+1
				FROM sal.tblSaleOrderHdr
				WHERE ProcessID=180 AND FiscalYear = @FiscalYear AND ProcessNo=@ProcessNo

				SELECT @SaleTypeID = SaleTypeID
				FROM  sal.tblSaleTypes 
				WHERE IsDefault = 'True'

				INSERT INTO sal.tblSaleOrderHdr
					   ([ProcessID],[ProcessNo],[FiscalYear],[SerialNo],[DocStep],[DocDate],[AcntCode],[BaseProcessID],[BaseProcessNo],[BaseFiscalYear],[BaseSerialNo],[BaseDocType]
					   ,[DocDesc],[AgreeNo],[OrderDate],[DeliveryDate],[SaleTypeID],[VisitorAcntCode],[RecID],[SessionNo],[OldSerialNo],[Returned],[MaxDebitRemain]
					   ,[MaxReceivableRemain],[AccountRemain],[UnReceipts],[DocDate2],[AutoOrder])
				VALUES(180 , @ProcessNo , @FiscalYear , @maxSerialNo  , @DocStep , @DocDate , @AcntCode , 0 , 0 , 0 , 0 , 0 , '' , '' , '' , '' , @SaleTypeID , '' , 0 , 0 , 0 , 0 ,0 ,0 ,0 , 0 , @DocDate,'True' )


				INSERT INTO [sal].[tblSaleOrderDtl]
				(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,DocStep,
				DocDate, AcntCode, GoodsID, SubUnitID, SubUnitQuantity,
				ConfirmQuantity, GoodsQuantity, GoodsPrice, DescDtl, BaseDocType,
				BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
				BaseDocRowNo, AgreeNo, OrderDate, DeliveryDate, VisitorAcntCode,
				IsReward, SubUnitPrice,AutoOrder, 
				DiscountPercentDtl, DiscountDtl)
				SELECT  180 ProcessID, @ProcessNo , @FiscalYear , @maxSerialNo , Row_Number() Over (ORDER BY AcntCode) RowNo, Row_Number() Over (ORDER BY AcntCode) DocRowNo,
						1 DocStep, @DocDate DocDate, @AcntCode AcntCode, OD.GoodsID, G.UnitID SubUnitID, GoodsQuantity SubUnitQuantity, GoodsQuantity ConfirmQuantity,GoodsQuantity,
						[sal].[funGetGoodsAmountSaleType](OD.GoodsID,'',@DocDate,@SaleTypeID,1,OD.UserPriceID,0) GoodsPrice,
						 '' DescDtl,0 BaseDocType ,0 BaseProcessID ,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo, 
						 '' AgreeNo, '' OrderDate, '' DeliveryDate
						 ,OD.VisitorAcntCode,IsReward,0,'True',0,0
					FROM
					(
					SELECT AcntCode,GoodsID,VisitorAcntCode,IsReward,SUM(GoodsQuantity)GoodsQuantity,UserPriceID
					FROM sal.tblSaleOrderDtl
					WHERE ProcessID=185 AND ProcessNo=@ProcessNo AND SerialNo = @maxSerialNo_Ret
					Group BY AcntCode,GoodsID,VisitorAcntCode,IsReward,UserPriceID
					) AS OD
					INNER JOIN inv.tblGoods G ON G.GoodsID=OD.GoodsID
			END
			
			SELECT 1 successful
		END
		else
			SELECT 2 successful
	COMMIT TRAN
		
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN
		SELECT -1 successful
		
	END CATCH	
END
GO
