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
CREATE PROCEDURE  [sal].[SpSumSaleOrderRemainReturnHdr] 
	
	@AcntCode	Varchar(20),
	@DocDate	Char(10),
	@FiscalYear	Smallint,
	@ProcessNo	tinyint,
	@DocStep	Smallint,
	@SaleTypeID AS VARCHAR(20),
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
		
		DECLARE @maxSerialNo INT
		
		
		
		DECLARE @strSelectHdr AS NVARCHAR(MAX) 
		SET @strSelectHdr =''	
		--DECLARE @strSelectDtl AS NVARCHAR(MAX)=''	
						
	
	
			
		SELECT @maxSerialNo = ISNULL(MAX(SerialNo),0)+1
		FROM sal.tblSaleOrderHdr
		WHERE ProcessID=185 AND FiscalYear = @FiscalYear AND ProcessNo=@ProcessNo

		
		set @strSelectHdr= '
			INSERT INTO sal.tblSaleOrderHdr
				   ([ProcessID],[ProcessNo],[FiscalYear],[SerialNo],[DocStep],[DocDate],[AcntCode],[BaseProcessID],[BaseProcessNo],[BaseFiscalYear],[BaseSerialNo],[BaseDocType]
				   ,[DocDesc],[AgreeNo],[OrderDate],[DeliveryDate],[SaleTypeID],[VisitorAcntCode],[RecID],[SessionNo],[OldSerialNo],[Returned],[MaxDebitRemain]
				   ,[MaxReceivableRemain],[AccountRemain],[UnReceipts],[DocDate2],[AutoOrder])
			VALUES(185 , ' + ltrim(str(@ProcessNo)) +' ,' +LTRIM(str(@FiscalYear)) +' , ' + ltrim(str(@SerialNo)) +' ,
			' + ltrim(str(@DocStep)) + ' ,''' +@DocDate +''' ,''' + @AcntCode + ''',180 
			, '+ltrim(str(@ProcessNo)) +' , '+LTRIM(str(@FiscalYear))+' , 0 , 0 , '''' , '''' , '''' , '''' , '''+ @SaleTypeID +''',
			 '''' , 0 , 0 , 0 , 0 ,0 ,0 ,0 , 0 , '''+ @DocDate +''',1 )'
			 
		
			PRINT @strSelectHdr;
			EXEC sp_executesql @strSelectHdr;
		
	
			
	END TRY
	
	BEGIN CATCH
	
		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)	
	END CATCH	

END
GO
