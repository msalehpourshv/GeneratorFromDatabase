USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_TakroSystem_GetSaleOrderHdrs]

@DateFrom As NVARCHAR(50),
@DateTo As NVARCHAR(50),
@ProcessNo As NVARCHAR(50),
--@AcntCode As NVARCHAR(50),
--@FromSerialNo As NVARCHAR(50),
@Skip As NVARCHAR(50),
@MaxResultCount As NVARCHAR(50),
@Filter As NVARCHAR(50),
@FiscalYear As NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @strSelect  NVARCHAR(MAX)
	DECLARE @StrErrorMessage NVARCHAR(MAX)

BEGIN TRY
		DECLARE @StrSelectPart  NVARCHAR(MAX)
	SELECT  @StrSelectPart=   ISNULL(SettingValue,2)FROM pub.tblSettings
		WHERE SettingKey LIKE 'AcntPartNumberForRemainCalculation'

	set @strSelect='SELECT SerialNo,ProcessID,ProcessNo,FiscalYear,DocDate,DocTime,OrderName,
						AcntCode,VisitorAcntCode,StoreID,SaleTypeID,DocStep,AutoOrder,Amount,Price,TransferSerialNo,
						SessionNo,DocDesc,ISNULL(acc.funPartAcntName(AcntCode,'+ @StrSelectPart +' ),'''')[AcntName],
						ISNULL(acc.funPartAcntName(VisitorAcntCode,'+ @StrSelectPart +' ),'''')[VisitorAcntName] 
					FROM sal.tblSaleOrderHdr 
					WHERE NOT EXISTS
						(SELECT
							 SerialNo,FiscalYear,ProcessNo,ProcessID
						 FROM inv.tblStorageDocsHdr
						 WHERE 
							 sal.tblSaleOrderHdr.SerialNo= inv.tblStorageDocsHdr.BaseSerialNo AND 
							 sal.tblSaleOrderHdr.ProcessID= inv.tblStorageDocsHdr.BaseProcessID AND 
						     sal.tblSaleOrderHdr.ProcessNo= inv.tblStorageDocsHdr.BaseProcessNo AND
						     sal.tblSaleOrderHdr.FiscalYear= inv.tblStorageDocsHdr.BaseFiscalYear And
							 ProcessID=180)and NoEditFromMobile=0'

	IF @DateFrom!=''
 
		SET @strSelect= @strSelect+ '  AND DocDate>= '''+@DateFrom+''''
 
	IF @DateTo!=''
	
		SET @strSelect= @strSelect+ '  AND DocDate<= '''+@DateTo+''''

	IF @FiscalYear!=''
	
		SET @strSelect= @strSelect+ '  AND FiscalYear= '''+@FiscalYear+''''

	IF @ProcessNo!='0' or @ProcessNo!=''
	
		SET @strSelect= @strSelect+ '  AND ProcessNo= '''+@ProcessNo+''''

	IF @Filter!=''
	
		SET @strSelect= @strSelect+ '  AND SerialNo like ''%'+@Filter+'%'' or ISNULL(acc.funPartAcntName(AcntCode,'+ @StrSelectPart +' ),'''') like N''%'+@Filter+'%'''
	
	SET @strSelect=@strSelect+' ORDER BY SerialNo DESC
							    OFFSET ' +@Skip +' Rows 
								FETCH NEXT ' +@MaxResultCount +' Rows ONLY '

	--IF @AcntCode!=''
	
	--	SET @strSelect= @strSelect+ '  AND AcntName= '''+@AcntCode+''''

	--IF @FromSerialNo!=''
 
	--	SET @strSelect= @strSelect+ '  AND SerialNo>= '''+@FromSerialNo+''''

	--IF @ToSerialNo!=''
 
	--	SET @strSelect= @strSelect+ '  AND SerialNo<= '''+@ToSerialNo+''''

	--IF @SerialNo!=''
 
	--	SET @strSelect= @strSelect+ '  AND SerialNo Like(% '''+@ToSerialNo+''''+'%)'

PRINT @strSelect
EXEC sp_executesql @strSelect
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
--exec sal.sp_api_TakroSystem_GetSaleOrderHdr @DateFrom=N'',@DateTo=N'',@Filter=N'64',@FiscalYear=N'1400'
GO
