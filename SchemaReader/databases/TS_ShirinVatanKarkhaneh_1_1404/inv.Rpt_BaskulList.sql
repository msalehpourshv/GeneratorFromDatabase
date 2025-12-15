USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\jafari
-- Create date   : 1395/07/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : باسکول
-- =============================================
Create PROCEDURE [inv].[Rpt_BaskulList]
		@ProcessID			Int = 56, -- Sale Order Process ID
		@LocationID         varchar(20)='',
		@DriverID           varchar(20)='',
		@DocDateFr			VarChar(10) = Null,
		@DocDateTo			VarChar(10) = Null,
		@AcntCode1          varchar(20)='',
		@AcntCode2          varchar(20)='',
		@AcntCode3          varchar(20)='',
		@AcntCode4          varchar(20)='',
		@GoodsID            varchar(20)='',
		@ExtraParams		NVarChar(Max) = '',
		@RepInfo			NVarChar(100) = '1@1@1',
		@RepOptions			VarChar(20) = '111'  
	
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000)='';
DECLARE @StrWhere	NVarChar(4000)='';
DECLARE @EmptyDateFr	VarChar(10) = Null;
DECLARE @EmptyDateTo	VarChar(10) = Null;
DECLARE @FullDateFr		VarChar(10) = Null;
DECLARE @FullDateTo		VarChar(10) = Null;
DECLARE @SerialNoFr		Int = 0;
DECLARE @SerialNoTo		Int = 0;
DECLARE @FiscalYearFr	Int = 0;
DECLARE @FiscalYearTo	Int = 0;
		
DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocRowNo	Varchar(100);

DECLARE @VehicleNo	Varchar(100);
DECLARE @VehicleTypeID	Varchar(100);
declare @IsCancel	int;
DECLARE @Layer1				int
DECLARE @Layer2				int
DECLARE @Layer3				int
DECLARE @Layer4				int
DECLARE @CampaignID			int

DECLARE @StrAcntCode1	NVarChar(1024);
DECLARE @StrAcntCode2	NVarChar(1024);
DECLARE @StrAcntCode3	NVarChar(1024);
DECLARE @StrAcntCode4	NVarChar(1024);

DECLARE @AcntStart1		int;
DECLARE @AcntLen1		int;
DECLARE @AcntStart2		int;
DECLARE @AcntLen2		int;
DECLARE @AcntStart3		int;
DECLARE @AcntLen3		int;
DECLARE @AcntStart4		int;
DECLARE @AcntLen4		int;

DECLARE @PartNoAcntRemain		tinyint;
DECLARE @StartLayerAcntRemain	int;
DECLARE @LenLayerAcntRemain		int;

Begin --============== S T A R T  C O D E ===================================================
 
SET NOCOUNT ON;

SELECT @PartNoAcntRemain=acc.FunGetAcntInfoForRemain(1)
SELECT @StartLayerAcntRemain=acc.FunGetAcntInfoForRemain(2)
SELECT @LenLayerAcntRemain=acc.FunGetAcntInfoForRemain(3)

SELECT @AcntStart1=acc.funGetAcntLayerStartandLen(1,1)
SELECT @AcntLen1=acc.funGetAcntLayerStartandLen(1,2)

SELECT @AcntStart2=acc.funGetAcntLayerStartandLen(2,1)
SELECT @AcntLen2=acc.funGetAcntLayerStartandLen(2,2)

SELECT @AcntStart3=acc.funGetAcntLayerStartandLen(3,1)
SELECT @AcntLen3=acc.funGetAcntLayerStartandLen(3,2)

SELECT @AcntStart4=acc.funGetAcntLayerStartandLen(4,1)
SELECT @AcntLen4=acc.funGetAcntLayerStartandLen(4,2)

	--==============
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	If (@RepOptions   Is Null)	SET @RepOptions  = '11'
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
		
	IF (@ExtraParams Is Null)   SET @ExtraParams = '';

	SET @VehicleNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @VehicleTypeID	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @EmptyDateFr	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @EmptyDateTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @FullDateFr		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @FullDateTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
	SET @IsCancel		= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @CampaignID		= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	SET @SerialNoFr		= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
	SET @FiscalYearFr	= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
	SET @SerialNoTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 	
	SET @FiscalYearTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 	
	
	--=============================================
	SET @StrWhere = ' H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' '	
	-- Where ----------------------------------------
			
	IF (@DocDateFr IS NOT null and  @DocDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND H.DocDate >=''' + @DocDateFr + ''''
	
	IF (@DocDateTo IS NOT null and @DocDateTo <>'')
		SET @StrWhere = @StrWhere + ' AND H.DocDate <=''' + @DocDateTo + ''''
	 	
	IF (@EmptyDateFr IS NOT null and  @EmptyDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND (D.EmptyVehicleDate >=''' + @EmptyDateFr + ''' OR (H.EmptyVehicleDate >=''' + @EmptyDateFr + ''' AND H.EmptyVehicleDate <>'''')) '
	
	IF (@EmptyDateTo IS NOT null and @EmptyDateTo <>'')
		SET @StrWhere = @StrWhere + ' AND (D.EmptyVehicleDate <=''' + @EmptyDateTo + ''' OR (H.EmptyVehicleDate <=''' + @EmptyDateTo + ''' AND H.EmptyVehicleDate <>''''))'
	 	
	IF (@FullDateFr IS NOT null and  @FullDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND (D.FullVehicleDate >=''' + @FullDateFr + ''' OR (H.FullVehicleDate >=''' + @FullDateFr + ''' AND H.FullVehicleDate <>''''))'
	
	IF (@FullDateTo IS NOT null and @FullDateTo <>'')
		SET @StrWhere = @StrWhere + ' AND (D.FullVehicleDate <=''' + @FullDateTo + ''' OR (H.FullVehicleDate <=''' + @FullDateTo + ''' AND H.FullVehicleDate <>''''))'
	 	
	IF (@LocationID is not null and @LocationID <>'')
	SET @StrWhere = @StrWhere + ' AND H.LocationID = '+ STR(@LocationID)  +' '
		
	IF(@DriverID is not null and @DriverID <>'')
	   SET @StrWhere = @StrWhere + ' AND H.DriverID= '+ STR(@DriverID ) +' '
	
	IF(@VehicleNo is not null and @VehicleNo <>'')
	   SET @StrWhere = @StrWhere + ' AND H.VehicleNo like ''%'+ @VehicleNo  +'%'''
	   
	IF(@VehicleTypeID is not null and @VehicleTypeID <>'')
	   SET @StrWhere = @StrWhere + ' AND H.VehicleTypeID= '''+ @VehicleTypeID  +''''
				
	IF (@GoodsID <> '')
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID , 'D.GoodsID') 

	IF (@CampaignID > 0)
		BEGIN
			SET @StrWhere = @StrWhere + ' AND SUBSTRING (H.AcntCode,'+str(@StartLayerAcntRemain)+','+str(@LenLayerAcntRemain)+') IN (SELECT AcntCode FROM acc.tblAcnt A WHERE PartNumber = ' + LTRIM(STR(@PartNoAcntRemain)) + ' AND '+ pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'A.CampaignID') +' ) '
		END 
	
	IF (@SerialNoFr Is Not Null) And (@SerialNoFr <> 0)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(RTrim(Str(@FiscalYearFr))) + ' OR (D.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYearFr))) + ' AND D.SerialNo >= ' + LTrim(RTrim(Str(@SerialNoFr))) + '))' 
	IF (@SerialNoTo Is Not Null) And (@SerialNoTo <> 0)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(RTrim(Str(@FiscalYearTo))) + ' OR (D.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYearTo))) + ' AND D.SerialNo <= ' + LTrim(RTrim(Str(@SerialNoTo))) + '))' 
			
	IF (@AcntCode1 <> '')
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode1, 'H.AcntCode')
	IF (@AcntCode2 <> '')
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode2, 'H.AcntCode')
	IF (@AcntCode3 <> '')
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode3, 'H.AcntCode')
	IF (@AcntCode4 <> '')
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode4, 'H.AcntCode')
	
	IF @IsCancel=2
		SET @StrWhere = @StrWhere + ' AND H.IsCancel  =0'
	IF @IsCancel=3
		SET @StrWhere = @StrWhere + ' AND H.IsCancel  =1'

	--============================
		SET @StrAcntCode1 = 'SUBSTRING (H.AcntCode, 1, ' + LTrim(Str(@AcntLen1)) +')'
		SET @StrAcntCode2 = 'SUBSTRING (H.AcntCode, ' + LTrim(Str(@AcntStart2)) + ', ' + LTrim(Str(@AcntLen2)) +')'	
		SET @StrAcntCode3 = 'SUBSTRING (H.AcntCode, ' + LTrim(Str(@AcntStart3)) + ', ' + LTrim(Str(@AcntLen3)) +')'
		SET @StrAcntCode4 = 'SUBSTRING (H.AcntCode, ' + LTrim(Str(@AcntStart4)) + ', ' + LTrim(Str(@AcntLen4)) +')'	
	--============================
	SET @StrSelect = '
	SELECT acc.funGetAcntName(' + @StrAcntCode1 + ',1,1) AcntName1,
		   acc.funGetAcntName(' + @StrAcntCode2 + ',2,1) AcntName2,
		   acc.funGetAcntName(' + @StrAcntCode3 + ',3,1) AcntName3,
		   acc.funGetAcntName(' + @StrAcntCode4 + ',4,1) AcntName4, 
		   H.ProcessID, 
		   H.SerialNo, 
		   H.DocDate, 
		   H.AcntCode, 
		   H.OwnerDocNo,
		   CASE WHEN D.GoodsID IS NULL THEN  H.GoodsID ELSE D.GoodsID END GoodsID, 
		   H.GoodsDocNo, 
		   H.GoodsSpecifications, 
		   H.LocationID,
		   H.VehicleNo, 
		   H.VehicleTypeID, 
		   H.DriverID, 
		   H.RoadBillNo,
		   H.RoadBillDate,
		   D.FullVehicleDate,
		   D.FullVehicleTime,
		   D.FullVehicleBoxes,
		   D.FullVehicleWeight,
		   D.EmptyVehicleDate,
		   D.EmptyVehicleTime,
		   D.EmptyVehicleBoxes,
		   D.EmptyVehicleWeight,
		   D.BoxGoodsID,
		   D.BoxFee,
		   D.BoxWeight,
		   D.SubsidencePercent,
		   D.SubsidenceWeight,
		   D.BrixDegree,
		   D.Fee,
		   H.DocDesc,
		   D.DocDesc DescDtl, 
		   H.RecID, 
		   H.SessionNo, 
		   H.VchNo, 
		   H.StoreID, 
		   H.TransportationCost, 
		   H.SerialTime, 
		   H.Step,
		   H.SourceProcessID,
		   H.SourceSerialNo, 
		   H.ProcessNo, 
		   H.FiscalYear,
		   (SELECT SettingValue	FROM pub.tblSettings WHERE SettingKey = ''CompanyCompanyName'') CompanyName,
		   D.SubUnitQuantity,
		   CASE WHEN G.GoodsName IS NULL THEN G1.GoodsName ELSE G.GoodsName END GoodsName, 
		   (SELECT FirstName + '' '' + LastName FROM pub.tblDriversDtl WHERE DriverID = H.DriverID AND LanguageID = '+ Ltrim(Rtrim(STR(@LangID))) +') DriverName,
		   (SELECT LocationName FROM pub.tblLocationsDtl WHERE LocationID = H.LocationID AND LanguageID = '+ Ltrim(Rtrim(STR(@LangID))) +') LocationName,
		   (SELECT VehicleTypeName FROM sal.tblVehicleTypesDtl WHERE VehicleTypeID = H.VehicleTypeID AND LanguageID = '+ Ltrim(Rtrim(STR(@LangID))) +') VehicleTypeName,
		   (SELECT AcntName FROM acc.tblAcntDtl WHERE AcntCode = SUBSTRING(H.AcntCode,[acc].[FunGetAcntInfoForRemain] (2),[acc].[FunGetAcntInfoForRemain] (3)) AND LanguageID = '+ Ltrim(Rtrim(STR(@LangID))) +') Acntname,
		   CASE WHEN Step=1 THEN ''نوبت دهی'' ELSE CASE WHEN Step = 2 THEN ''توزین اولیه'' ELSE CASE WHEN Step = 3 THEN ''توزین کامل'' ELSE ''اتمام باسکول'' END END END StateName,
		   H.IsCancel,
		   WeightBarcode,
		   ActiveGoodsWeight,
		   PureWeight,
		   WeightGoods,
		   GoodsLength,
		   GoodsWidth,
		   GoodsHeight,
		   GoodsWeight,
		   D.SubUnitID,
		   D.DocRowNo, 
		   U.UnitName, 
		   H.BaseSerialNo, 
		   SD.BaseSerialNo MojavezBaseSerialNo
	FROM inv.tblBaskulSalesHdr H
	LEFT JOIN inv.tblBaskulSalesDtl D ON H.SerialNo = D.SerialNo 
									 AND H.ProcessID = D.ProcessID 
	LEFT JOIN inv.tblStorageDocsDtl SD ON D.BaseProcessID = SD.ProcessID 
									  AND D.BaseProcessNo = SD.ProcessNo 
									  AND D.BaseFiscalYear = SD.FiscalYear 
									  AND D.BaseSerialNo = SD.SerialNo 
									  AND D.BaseDocRowNo = SD.DocRowNo
	LEFT JOIN inv.tblGoods GI ON D.GoodsID = GI.GoodsID 
	LEFT JOIN inv.tblGoodsDtl G ON D.GoodsID = G.GoodsID 
							   AND G.LanguageID = ' +Ltrim(Rtrim(str( @LangID ))) + ' 
	LEFT JOIN inv.tblGoodsDtl G1 ON H.GoodsID = G1.GoodsID 
								AND G.LanguageID = ' +Ltrim(Rtrim(str( @LangID ))) + ' 
	LEFT JOIN inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID 
							   AND G.LanguageID =' +Ltrim(Rtrim(str( @LangID ))) + ' '

 SET @StrSelect= @StrSelect + '
				 WHERE ' + @StrWhere + '
				 Order By H.DocDate,H.SerialNo'

 	--============================
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
