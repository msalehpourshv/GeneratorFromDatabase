USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\jafari
-- Create date   : 1395/05/29
-- Viewed By	 : 
-- Last Modified : 1404/05/29
-- Last Modifier : Mostafavi
-- Description   : باسکول
-- =============================================
Create PROCEDURE [inv].[Rpt_BaskulSales]
	@ProcessID			Int = 56, -- Sale Order Process ID
	@DocDateFr			VarChar(10) = Null,
	@DocDateTo			VarChar(10) = Null,
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
	
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocRowNo	Varchar(100);
DECLARE @IsCancel	int;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--==============
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	If (@RepOptions   Is Null)	SET @RepOptions  = '11'
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	If (@ExtraParams Is Null)   SET @ExtraParams = '1,2,3,4';

	DECLARE @Step as VarChar(10)
	SET @Step		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); -- 1
	SET @IsCancel	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); -- 1
	--=============================================
	SET @StrWhere = ' H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' '	
	-- Where ----------------------------------------
			
	IF (@DocDateFr IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.DocDate >= ''' + @DocDateFr + ''''
	
	
	IF (@DocDateTo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.DocDate <= ''' + @DocDateTo + ''''
		SET @StrWhere = @StrWhere + ' AND H.Step in ( ' + @Step + ')'
	
	IF @IsCancel = 2
		SET @StrWhere = @StrWhere + ' AND H.IsCancel = 0'
	IF @IsCancel = 3
		SET @StrWhere = @StrWhere + ' AND H.IsCancel = 1'
	
	--============================
	SET @StrSelect = '
	SELECT SubString(DocDate,1,4) FiscalYear, 
		   H.*, 
		   (Select FirstName + '' '' + LastName
			From pub.tblDriversDtl 
			Where DriverID = H.DriverID 
			  AND LanguageID = '+ Ltrim(Rtrim(STR(@LangID))) +') DriverName,
		   (Select VehicleTypeName 
		    From sal.tblVehicleTypesDtl 
			Where VehicleTypeID = H.VehicleTypeID 
			  AND LanguageID = '+ Ltrim(Rtrim(STR(@LangID))) +') VehicleTypeName,
		   Case When Step=1 Then ''نوبت دهی'' Else Case When Step = 2 Then ''توزین اولیه'' Else Case When Step = 3 Then ''توزین کامل'' Else ''اتمام باسکول'' End End End State,
		   F.*,
		   ISNULL (V1.VisitPathName, '''') VisitPathName1, 
		   ISNULL (V2.VisitPathName, '''') VisitPathName2, 
		   ISNULL (V3.VisitPathName, '''') VisitPathName3, 
		   ISNULL (V4.VisitPathName, '''') VisitPathName4, 
		   ISNULL (CampaignName, '''') CampaignName,
		   ISNULL (T.TransporterName, '''') TransporterName,
		   [pub].[funGetLocationName] (F.LocationID, '+ Ltrim(Rtrim(STR(@LangID))) +') LocationName,
		   [sal].[funGetCustomerKindName] (F.CustomerKindID, '+ Ltrim(Rtrim(STR(@LangID))) +') CustomerKindName
	FROM inv.tblBaskulSalesHdr H
	OUTER APPLY acc.funGetCodeInfo(AcntCode) F
	LEFT JOIN acc.tblVisitPathDtl V1 ON V1.VisitPathID = F.VisitPathID1 AND V1.PartNumber=1
	LEFT JOIN acc.tblVisitPathDtl V2 ON V2.VisitPathID = F.VisitPathID2 AND V2.PartNumber=2
	LEFT JOIN acc.tblVisitPathDtl V3 ON V3.VisitPathID = F.VisitPathID3 AND V3.PartNumber=3
	LEFT JOIN acc.tblVisitPathDtl V4 ON V4.VisitPathID = F.VisitPathID4 AND V4.PartNumber=4
	LEFT JOIN acc.tblCampaignDtl Ca ON Ca.CampaignID  = F.CampaignID
	LEFT JOIN sal.tblTransportersDtl T ON T.TransporterID = F.TransporterID
	WHERE ' + @StrWhere + '
	ORDER BY H.SerialNo'

	--============================
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
