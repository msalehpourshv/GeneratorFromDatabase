USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/10/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[spFrmSaleOrderSave] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @DocDate		Char(10),
 @AcntCode		Varchar(20),
 @LanguageID	Tinyint
WITH ENCRYPTION
 AS

BEGIN

SET NOCOUNT ON;

	Declare @strMsgText		NVarChar(2044)
	Declare @GoodsID		Varchar(20)
	Declare @TempFiscalYear	Smallint
	Declare @TempProcessNo	tinyint
	Declare @TempSerialNo	Int
	Declare @TempDocRowNo	INT
	Declare @BaseProcessID	int
	Declare @BaseProcessNo	tinyint
	Declare @BaseFiscalYear	Smallint
	Declare @BaseSerialNo	Int
	Declare @BaseDocRowNo	Int
	Declare @UsedGoodsQuantity	Float
	Declare @GoodsQuantity	Float
	DECLARE @SalRet_RetToSalOdr AS BIT
	DECLARE @PreventSaleorderWhenNotRemain AS BIT
	DECLARE @CanSaleOrderBeLessThanSale AS BIT

	SET @SalRet_RetToSalOdr = 'False'
	SET @PreventSaleorderWhenNotRemain = 'False'
	SET @CanSaleOrderBeLessThanSale = 'False'
	
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 

	SELECT @PreventSaleorderWhenNotRemain = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PreventSaleorderWhenNotRemain' 
	
	SELECT @CanSaleOrderBeLessThanSale = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'CanSaleOrderBeLessThanSale' 	

		Declare	Cursor_SaleOrderDtl CURSOR For 
		SELECT	FiscalYear,SerialNo,DocRowNo,GoodsQuantity,GoodsID,
				BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo
		FROM sal.tblSaleOrderDtl
		WHERE ProcessID = @ProcessID AND
			  ProcessNo = @ProcessNo AND
			  FiscalYear= @FiscalYear AND
			  SerialNo  = @SerialNo 

		Open  Cursor_SaleOrderDtl; 

		Fetch NEXT From Cursor_SaleOrderDtl 
		Into @TempFiscalYear,@TempSerialNo,@TempDocRowNo,@GoodsQuantity,@GoodsID,
			 @BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo

		While (@@Fetch_Status = 0)
			BEGIN
				
				IF @ProcessID = 180 
				BEGIN
					
					SELECT @GoodsQuantity= @GoodsQuantity - isnull( SUM(GoodsQuantity)  ,0)
					FROM sal.tblSaleOrderDtl
					WHERE BaseProcessID = @ProcessID AND
						  BaseProcessNo = @ProcessNo AND
						  BaseFiscalYear= @FiscalYear AND
						  BaseSerialNo  = @SerialNo AND
						  BaseDocRowNo =  @TempDocRowNo AND 
						  GoodsID = @GoodsID
			
					Select	@GoodsQuantity= @GoodsQuantity -isnull( SUM(GoodsQuantity)  ,0)
					From inv.tblStorageDocsDtl
					WHERE BaseProcessID = @ProcessID AND
						  BaseProcessNo = @ProcessNo AND
						  BaseFiscalYear= @FiscalYear AND
						  BaseSerialNo  = @SerialNo AND
						  BaseDocRowNo =  @TempDocRowNo AND 
						  GoodsID = @GoodsID
						  					

				IF @SalRet_RetToSalOdr = 'True'
					BEGIN
						SELECT @GoodsQuantity= @GoodsQuantity +isnull( SUM (A.GoodsQuantity),0)
						FROM inv.tblStorageDocsDtl A INNER JOIN
						(Select	*
						From inv.tblStorageDocsDtl
						WHERE BaseProcessID = @ProcessID AND
							  BaseProcessNo = @ProcessNo AND
							  BaseFiscalYear= @FiscalYear AND
							  BaseSerialNo  = @SerialNo AND
							  BaseDocRowNo =  @TempDocRowNo AND 
							  GoodsID = @GoodsID) B
						ON B.ProcessID = A.BaseProcessID AND B.ProcessNo = A.BaseProcessNo AND 
						   B.FiscalYear = A.BaseFiscalYear AND B.SerialNo = A.BaseSerialNo AND 
						   B.DocRowNo = A.BaseDocRowNo AND A.GoodsID = @GoodsID
						   AND A.ProcessID=100
						
					END

					IF round(@GoodsQuantity,5) < 0 AND @CanSaleOrderBeLessThanSale='False'
						-- مقدار کالای %S بیش از مقدار سفارش فروش است
						SET @strMsgText=TS.pub.funGetMessages(18001,@LanguageID)


				END
				ELSE
				IF @ProcessID = 185
				BEGIN
					SELECT @GoodsQuantity= isnull(SUM(GoodsQuantity)  ,0)
					FROM sal.tblSaleOrderDtl
					WHERE BaseProcessID = @BaseProcessID AND
						  BaseProcessNo = @BaseProcessNo AND
						  BaseFiscalYear= @BaseFiscalYear AND
						  BaseSerialNo  = @BaseSerialNo AND
						  BaseDocRowNo =  @BaseDocRowNo AND 
						  GoodsID = @GoodsID  

					SELECT @GoodsQuantity= GoodsQuantity -  @GoodsQuantity
					FROM sal.tblSaleOrderDtl
					WHERE ProcessID = @BaseProcessID AND
						  ProcessNo = @BaseProcessNo AND
						  FiscalYear= @BaseFiscalYear AND
						  SerialNo  = @BaseSerialNo AND
						  DocRowNo =  @BaseDocRowNo AND 
						  GoodsID = @GoodsID
						  			
					Select	@GoodsQuantity= @GoodsQuantity - isnull(SUM(GoodsQuantity)  ,0)
					From inv.tblStorageDocsDtl
					WHERE BaseProcessID = @BaseProcessID AND
						  BaseProcessNo = @BaseProcessNo AND
						  BaseFiscalYear= @BaseFiscalYear AND
						  BaseSerialNo  = @BaseSerialNo AND
						  BaseDocRowNo =  @BaseDocRowNo AND 
						  GoodsID = @GoodsID
						  					

				IF @SalRet_RetToSalOdr = 'True'
					BEGIN
						SELECT @GoodsQuantity= @GoodsQuantity + isnull(SUM (A.GoodsQuantity),0)
						FROM inv.tblStorageDocsDtl A INNER JOIN
						(Select	*
						From inv.tblStorageDocsDtl
						WHERE BaseProcessID = @BaseProcessID AND
							  BaseProcessNo = @BaseProcessNo AND
							  BaseFiscalYear= @BaseFiscalYear AND
							  BaseSerialNo  = @BaseSerialNo AND
							  BaseDocRowNo =  @BaseDocRowNo AND 
							  GoodsID = @GoodsID) B
						ON B.ProcessID = A.BaseProcessID AND B.ProcessNo = A.BaseProcessNo AND 
						   B.FiscalYear = A.BaseFiscalYear AND B.SerialNo = A.BaseSerialNo AND 
						   B.DocRowNo = A.BaseDocRowNo AND A.GoodsID = @GoodsID
						   AND A.ProcessID=100
						
					END
					
					IF round(@GoodsQuantity,5) < 0 AND @CanSaleOrderBeLessThanSale='False'
						-- مقدار کالای %S بیش از مقدار سفارش فروش است
						SET @strMsgText=TS.pub.funGetMessages(18001,@LanguageID)

				END	
				
				IF @strMsgText <>''
				BEGIN
					Close Cursor_SaleOrderDtl;
					Deallocate Cursor_SaleOrderDtl; 
					Raiserror (@strMsgText,16,1,@GoodsID)
					Return
				END

				IF @PreventSaleorderWhenNotRemain = 'True' AND (SELECT ROUND([inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,NULL,@GoodsID,'',@DocDate,0),5) - ROUND([sal].[funGetSaleOrderGoodsRemain](@GoodsID,@DocDate,@FiscalYear,0),5) ) <0
				BEGIN
					SET @strMsgText=N'مانده سفارش کالای ' + @GoodsID +  '  در تاریخ '+@DocDate +'منفی می شود'
					Close Cursor_SaleOrderDtl;
					Deallocate Cursor_SaleOrderDtl; 
					Raiserror (@strMsgText,16,1,@GoodsID)
					Return
				END

				Fetch NEXT From Cursor_SaleOrderDtl 
				Into @TempFiscalYear,@TempSerialNo,@TempDocRowNo,@GoodsQuantity,@GoodsID,
					 @BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo
			END 
		Close Cursor_SaleOrderDtl;
		Deallocate Cursor_SaleOrderDtl; 

		UPDATE sal.tblSaleOrderDtl 
		SET BaseDocRowNo = A.DocRowNo 
		FROM sal.tblSaleOrderDtl B INNER JOIN 
		 (SELECT * from sal.tblSaleOrderDtl) A 
		ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo  AND 
		 A.FiscalYear=B.BaseFiscalYear  AND A.SerialNo=B.BaseSerialNo  AND 
		 A.GoodsID=B.GoodsID AND A.DocRowNo<>B.BaseDocRowNo 
		 AND A.GoodsID NOT IN (SELECT GoodsID 
			 FROM sal.tblSaleOrderDtl AA 
			 WHERE AA.ProcessID = 180 AND AA.ProcessID=A.ProcessID AND 
			 AA.ProcessNo=A.ProcessNo AND AA.FiscalYear=A.FiscalYear AND AA.SerialNo=A.SerialNo 
			 GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID 
			 HAVING COUNT(GoodsID)>1)
			  
			  
		UPDATE inv.tblStorageDocsDtl 
		SET BaseDocRowNo = A.DocRowNo 
		FROM inv.tblStorageDocsDtl B INNER JOIN 
		 sal.tblSaleOrderDtl A 
		ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo  AND 
		 A.FiscalYear=B.BaseFiscalYear  AND A.SerialNo=B.BaseSerialNo  AND 
		 A.GoodsID=B.GoodsID AND A.DocRowNo<>B.BaseDocRowNo 
		 AND A.GoodsID NOT IN (SELECT GoodsID 
			 FROM sal.tblSaleOrderDtl AA 
			 WHERE AA.ProcessID = 180 AND AA.ProcessID=A.ProcessID AND 
			 AA.ProcessNo=A.ProcessNo AND AA.FiscalYear=A.FiscalYear AND AA.SerialNo=A.SerialNo 
			 GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID 
			 HAVING COUNT(GoodsID)>1)

END
GO
