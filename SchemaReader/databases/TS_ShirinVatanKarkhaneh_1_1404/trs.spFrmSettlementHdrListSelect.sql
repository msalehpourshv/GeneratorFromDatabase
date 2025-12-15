USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Seyed Mahdi Mostafavi
-- Create date   : 1403/06/13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================			   
Create PROCEDURE [trs].[spFrmSettlementHdrListSelect]
	@ProcessID		Smallint,
	@DocDate		Char(10),
	@FilterInfo		NVarChar(100) = '@@0@0@@0@1'

WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

DECLARE @LanguageID				AS TinyInt
DECLARE @FromDate				Char(10);
DECLARE @ToDate	    			Char(10);
DECLARE @SaleFromDate			Char(10);
DECLARE @SaleToDate	    		Char(10);
DECLARE @FromSerialNo			Int;
DECLARE @ToSerialNo				Int;
DECLARE @UserID					NVarChar(4000);
DECLARE @UserIsAdmin			BIT;
DECLARE @Confirmed				tinyint;
DECLARE @IsOfficialConfirmed	tinyint;
Declare @CollectorID			VarChar(20);
Declare @StrSelect				NVarChar(max);


--================================
	Set @FromDate		=''
	Set @ToDate	    	=''
	Set @FromSerialNo	=0
	Set @ToSerialNo		=0
	
	-- Init -------------------------------------------------
	IF (@FilterInfo Is Null)	SET @FilterInfo ='@@@0@0@0@1@0@0@0'
	
	SET @CollectorID			= pub.funSplitString(@FilterInfo, '@', 1);
	SET @FromDate				= pub.funSplitString(@FilterInfo, '@', 2);
	SET @ToDate					= pub.funSplitString(@FilterInfo, '@', 3);
	SET @SaleFromDate			= pub.funSplitString(@FilterInfo, '@', 4);
	SET @SaleToDate				= pub.funSplitString(@FilterInfo, '@', 5);
	SET @FromSerialNo			= pub.funSplitString(@FilterInfo, '@', 6);
	SET @ToSerialNo				= pub.funSplitString(@FilterInfo, '@', 7);
	SET @UserID					= pub.funSplitString(@FilterInfo, '@', 8);
	SET @UserIsAdmin			= pub.funSplitString(@FilterInfo, '@', 9);
	SET @Confirmed				= pub.funSplitString(@FilterInfo, '@', 10);
	SET @IsOfficialConfirmed	= pub.funSplitString(@FilterInfo, '@', 11);
	
	If @CollectorID		is null Set @CollectorID = ''
	If @FromDate		is null Set @FromDate = ''
	If @ToDate			is null Set @ToDate = ''
	If @SaleFromDate	is null Set @SaleFromDate = ''
	If @SaleToDate		is null Set @SaleToDate = ''
	If @FromSerialNo	is null Set @FromSerialNo = ''
	If @ToSerialNo		is null Set @ToSerialNo = ''
	
	SET @LanguageID = pub.funGetCurrentLanguageID()

	--=====================================
	--=====================================
	
Set @StrSelect = '
	SELECT Distinct SH.*
	FROM trs.tblSettlementHdr SH
	Left Join trs.tblSettlementDtl SD On SH.ProcessID = SD.ProcessID AND SH.ProcessNo = SD.ProcessNo AND SH.FiscalYear = SD.FiscalYear AND SH.SerialNo = SD.SerialNo
	Left Join inv.tblStorageDocsDtl SDD On SD.BaseSaleProcessID = SDD.ProcessID AND SD.BaseSaleProcessNo = SDD.ProcessNo AND SD.BaseSaleFiscalYear = SDD.FiscalYear AND SD.BaseSaleSerialNo = SDD.SerialNo
	WHERE SH.ProcessID= '+LTrim(RTrim(str(@ProcessID)))+' AND
		('''+@CollectorID+''' = '''' OR ('''+@CollectorID+''' <> '''' AND CollectorID = '''+@CollectorID+''' )) AND
		('''+LTrim(RTrim(@FromDate))+''' ='''' OR ('''+LTrim(RTrim(@FromDate))+''' <> '''' AND SH.DocDate >= '''+LTrim(RTrim(@FromDate))+''' )) AND
		('''+LTrim(RTrim(@ToDate))+''' ='''' OR ('''+LTrim(RTrim(@ToDate))+''' <> '''' AND SH.DocDate <= '''+LTrim(RTrim(@ToDate))+''')) AND
		('''+LTrim(RTrim(@SaleFromDate))+''' ='''' OR ('''+LTrim(RTrim(@SaleFromDate))+''' <> '''' AND SDD.DocDate >= '''+LTrim(RTrim(@SaleFromDate))+''' )) AND
		('''+LTrim(RTrim(@SaleToDate))+''' ='''' OR ('''+LTrim(RTrim(@SaleToDate))+''' <> '''' AND SDD.DocDate <= '''+LTrim(RTrim(@SaleToDate))+''' )) AND
		('+LTrim(RTrim(str(@FromSerialNo)))+' =0 OR ('+LTrim(RTrim(str(@FromSerialNo)))+' <> 0 AND SH.SerialNo >= '+LTrim(RTrim(str(@FromSerialNo)))+' )) AND
		('+LTrim(RTrim(str(@ToSerialNo)))+' =0 OR ('+LTrim(RTrim(str(@ToSerialNo)))+' <> 0 AND SH.SerialNo  <= '+LTrim(RTrim(str(@ToSerialNo)))+' )) AND
		(Confirmed = '+LTrim(RTrim(str(@Confirmed)))+') AND
		(ConfirmIsOfficial = '+LTrim(RTrim(str(@IsOfficialConfirmed)))+')'
	
	print @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
