USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\ Reza Nogrepasand
-- Create date   : 1392/06/31
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE PROCEDURE  [sal].[SpSumSaleOrderRemainReturnDtl] 
	
	@AcntCode	Varchar(20),
	@DocDate	Char(10),
	@FiscalYear	Smallint,
	@ProcessNo	tinyint,
	@DocStep	Smallint,
	@SaleTypeID AS VARCHAR(20),
	@GoodsID AS VARCHAR(20),
	@UnitID AS VARCHAR(20),
	@SubUnitQuantity AS FLOAT,
	@GoodsPrice AS FLOAT,
	@BaseFiscalYear AS INT,
	@BaseSerialNo AS INT,
	@BaseDocRowNo AS INT,
	@SerialNo AS INT
		
WITH ENCRYPTION
AS
BEGIN

	DECLARE @LastPriceInSaleorderForSale AS BIT
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	DECLARE @SalRet_RetToSalOdr AS BIT
	
	SET @LastPriceInSaleorderForSale = 'False'
	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	
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
		
	
		DECLARE @maxRowNo INT
		DECLARE @maxDocRowNo INT
		
		
		
		DECLARE @strSelectDtl AS NVARCHAR(MAX)
		SET @strSelectDtl =''	
		--DECLARE @strSelectDtl AS NVARCHAR(MAX)=''	
						
	
	
			
		SELECT @maxRowNo = ISNULL(MAX(RowNo),0)
		FROM sal.tblSaleOrderDtl
		WHERE ProcessID=185 AND SerialNo=@SerialNo AND FiscalYear = @FiscalYear AND ProcessNo=@ProcessNo

		SELECT @maxDocRowNo = ISNULL(MAX(DocRowNo),0)
		FROM sal.tblSaleOrderDtl
		WHERE ProcessID=185 AND SerialNo=@SerialNo AND FiscalYear = @FiscalYear AND ProcessNo=@ProcessNo

			--SELECT @SaleTypeID = SaleTypeID
			--FROM  sal.tblSaleTypes 
			--WHERE IsDefault = 'True'

		set @strSelectDtl= 'INSERT INTO [sal].[tblSaleOrderDtl]
		(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocStep, DocDate,
		 AcntCode, GoodsID, SubUnitID, SubUnitQuantity, ConfirmQuantity, GoodsQuantity,
		 GoodsPrice, DescDtl, BaseDocType, BaseProcessID, BaseProcessNo, BaseFiscalYear,
		 BaseSerialNo, BaseDocRowNo, AgreeNo, OrderDate, DeliveryDate, VisitorAcntCode,
		 IsReward, SubUnitPrice, AutoOrder, TransferSerialNo)
				SELECT  185 ProcessID, ' + ltrim(rtrim(str(@ProcessNo))) + ' ProcessNo, ' + ltrim(rtrim(str(@FiscalYear))) + ' FiscalYear,'
				+ ltrim(rtrim(str(@SerialNo))) + ' SerialNo,'+ ltrim(rtrim(str(@maxRowNo+1))) +' RowNo,
				'+ ltrim(rtrim(str(@maxDocRowNo+1))) +' DocRowNo,1 DocStep,''' + @DocDate + ''' DocDate,'''+ @AcntCode +''' AcntCode,
				'''+ @GoodsID + ''' GoodsID,''' + @UnitID + ''' SubUnitID,'+ ltrim(rtrim(str(@SubUnitQuantity))) + 'SubUnitQuantity,
				'+ ltrim(rtrim(str(@SubUnitQuantity)))+' ConfirmQuantity,' +ltrim(rtrim(str(@SubUnitQuantity))) + ' GoodsQuantity,
				'+ltrim(rtrim(str(@GoodsPrice)))+' GoodsPrice, '''' DescDtl,180 BaseDocType ,180 BaseProcessID ,'+ltrim(rtrim(str(@ProcessNo)))+' BaseProcessNo,
				'+ltrim(rtrim(str(@BaseFiscalYear)))+' BaseFiscalYear,'+ltrim(rtrim(str(@BaseSerialNo)))+' BaseSerialNo,
				'+ ltrim(rtrim(str(@BaseDocRowNo))) +' BaseDocRowNo, '''' AgreeNo, '''' OrderDate, '''' DeliveryDate,
				'''' VisitorAcntCode,0 IsReward,0 SubUnitPrice, 1  AutoOrder ,0'
			
		
			PRINT @strSelectDtl;
			EXEC sp_executesql @strSelectDtl;
		
		
		
	
	END TRY
	
	BEGIN CATCH
		
		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)	
	END CATCH	

END
GO
