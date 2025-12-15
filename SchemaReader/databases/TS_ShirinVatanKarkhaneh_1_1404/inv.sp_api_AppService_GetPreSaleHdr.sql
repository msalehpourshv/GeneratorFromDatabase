USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 1403/03/29 r.moayed
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_AppService_GetPreSaleHdr
@Skip AS  nvarchar(50),
@VisitorID AS  nvarchar(50),
@MaxResultCount AS  nvarchar(50),
@Filter as nvarchar(max),
@StoreID AS  nvarchar(50),
@ProcessID AS  nvarchar(50),
@ProcessNo as nvarchar(50),
@NationalIdentity AS  nvarchar(50),
@MobileNumber AS  nvarchar(50),
@AcntCustomerCode as nvarchar(200)



WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery  NVARCHAR(Max)

	
BEGIN TRY


	DECLARE @PartNumber Int;
	DECLARE @PStart Int;
	DECLARE @PLen Int;
	DECLARE @PLenSubString Int;
		if( @AcntCustomerCode<>'')
		begin
			select @PartNumber = [acc].[FunGetAcntInfoForRemain](1)

			select @PStart = acc.funGetAcntLayerStartandLen(@PartNumber,1)
		
			select @PLenSubString = Len(pub.funSplitString('' + @AcntCustomerCode + '',',',1))

				SET @AcntCustomerCode=' and SubString(H.AcntCode,' + LTrim(Str(@PStart)) + ',' + LTrim(Str(@PLenSubString)) + ') in (' + @AcntCustomerCode + ')'

		end

	SET @strQuery='
					SELECT SerialNo ,FiscalYear,ProcessNo ,cast (ProcessID as tinyint) as ProcessID,H.AcntCode ,f.AcntName ,VisitorAcntCode ,f.AcntName AS  VisitorAcntName ,VisitorAcntCode,Amount ,DocDate ,DocDesc ,Price ,Discount ,
					       TaxOverWorthCost ,TollOverWorthCost ,H.StoreID ,StoreName ,TransferSerialNo ,f.NationalIDNumber
					FROM inv.tblPreSaleHdr H
						LEFT JOIN inv.tblStoresDtl S ON S.StoreID=H.StoreID
					outer apply [acc].[funGetCodeInfo](H.AcntCode) f 
					WHERE ProcessNo=' + @ProcessNo 
	IF(@VisitorID<>'')
		SET @strQuery=@strQuery+ ' AND VisitorAcntCode='''+@VisitorID+''''

	IF(@ProcessID<>'')
		SET @strQuery=@strQuery+ ' AND ProcessID='''+@ProcessID+''''


	IF(@StoreID<>'')
		SET @strQuery=@strQuery+ ' AND H.StoreID='''+@StoreID+''''

	IF(@Filter<>'')
		SET @strQuery=@strQuery + ' AND  (H.AcntCode LIKE N''%'+@Filter+'%'' OR f.AcntName LIKE N''%'+@Filter+'%'' OR SerialNo LIKE N''%'+@Filter+'%'')'
	
	IF(@NationalIdentity<>'')
		SET @strQuery=@strQuery+ ' AND and H.NationalID='''+@NationalIdentity+''''
	
	IF(@MobileNumber<>'')
		SET @strQuery=@strQuery+ 'AND (f.Mobile LIKE N''%'+@MobileNumber+'%'' OR f.Tel LIKE N''%'+@MobileNumber+'%''  OR f.SMSMobile LIKE N''%'+@MobileNumber+'%'' )'
	
	SET @strQuery=@strQuery+ @AcntCustomerCode + ' 
				   ORDER BY H.SerialNo
				   OFFSET ' +@Skip +' Rows 
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
