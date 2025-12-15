USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 1403/03/30 r.moayed
-- Description   : 
-- ============================================= 
CREATE PROCEDURE inv.sp_api_AppService_GetBuysHdr
@Skip AS  nvarchar(50),
@VisitorID AS  nvarchar(50),
@MaxResultCount AS  nvarchar(50),
@Filter as nvarchar(max),
@AcntCustomerCode as nvarchar(200)


WITH ENCRYPTION
 AS
BEGIN

	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery  NVARCHAR(Max)
	
	
	DECLARE @PartNumber Int;
	DECLARE @PStart Int;
	DECLARE @PLen Int;
	DECLARE @PLenSubString Int;

BEGIN TRY


	if( @AcntCustomerCode<>'')
	begin
		select @PartNumber = [acc].[FunGetAcntInfoForRemain](1)

		select @PStart = acc.funGetAcntLayerStartandLen(@PartNumber,1)
		
		select @PLenSubString = Len(pub.funSplitString('' + @AcntCustomerCode + '',',',1))

		SET @AcntCustomerCode=' and SubString(H.AcntCode,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLenSubString)) + ') in (' + @AcntCustomerCode + ')'

	end

	SET @strQuery='
					SELECT SerialNo ,FiscalYear ,ProcessNo ,cast(ProcessID as tinyint) as ProcessID ,H.AcntCode ,AD.AcntName ,VisitorAcntCode ,AV.AcntName AS  VisitorAcntName ,VisitorAcntCode,Amount ,DocDate ,DocDesc ,Price ,Discount ,
					       TaxOverWorthCost ,TollOverWorthCost ,H.StoreID ,StoreName ,TransferSerialNo 
					FROM inv.tblStorageDocsHdr H
						LEFT JOIN inv.tblStoresDtl S ON S.StoreID=H.StoreID
						LEFT JOIN acc.tblAcntDtl AD ON H.AcntCode=AD.AcntCode
						LEFT JOIN acc.tblAcntDtl AV ON H.VisitorAcntCode=AD.AcntCode
					WHERE (H.ProcessID=55) ' + @AcntCustomerCode

	IF(@VisitorID<>'')
		SET @strQuery = @strQuery+ ' AND VisitorAcntCode='''+@VisitorID+''''

	IF(@Filter<>'')
		SET @strQuery = @strQuery + ' AND  (H.AcntCode LIKE ''%'+@Filter+'%'' OR AD.AcntName LIKE ''%'+@Filter+'%'' OR SerialNo LIKE ''%'+@Filter+'%'')'
	
	SET @strQuery = @strQuery + ' 
				ORDER BY  SerialNo 
				OFFSET ' + @Skip + ' Rows 
				FETCH NEXT ' +@MaxResultCount +' Rows ONLY '

PRINT @strQuery
EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
