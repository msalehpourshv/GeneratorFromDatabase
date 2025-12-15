USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid
-- Create date   : 1395/04/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Hamid
-- Description   : قرارداد حق الحفاظ
-- =============================================
Create PROCEDURE [inv].[Rpt_GoodsExit]
	@ProcessID		Int = 193, -- Sale Order Process ID
	@ProcessNo		Int = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@RepInfo		NVarChar(200) = '1@1@1',
	@RepOptions		NVarChar(10)  = '',
	@ExtraParams	Nvarchar(500) = ''

WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @db_0000		NVarchar(50)
SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

DECLARE @DocRowNo	Varchar(100);

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	If (@RepOptions   Is Null)	SET @RepOptions  = '11'
	IF (@ProcessNo	  Is Null)	SET @ProcessNo   = 1;

	IF (@FiscalYearFr  Is Null)	SET @SerialNoFr	  = Null;
	IF (@FiscalYearTo  Is Null)	SET @SerialNoTo	  = Null;
	IF (@SerialNoFr	   Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	   Is Null)	SET @FiscalYearTo = Null;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @DocRowNo = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 

	--=============================================
	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	
	-- Where ----------------------------------------
	IF (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear >' + LTrim(Str(@FiscalYearFr)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '		
		
	--=======================
	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID   Int,
		UserSign Image
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@db_0000)) + '.usr.tblUsers U '
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;		
	
	--=======================
	CREATE TABLE #tbl_Session1
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_Session2
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo2)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
	--=======================
	CREATE TABLE #tbl_SgnSN1
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN1)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
	
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_SgnSN2
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN2)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	

	--=======================
	CREATE TABLE #tbl_SgnSN3
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN3(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN3)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
			
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;		
		
	--=======================
	CREATE TABLE #tbl_SgnSN4
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN4(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN4)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
	--=======================
	CREATE TABLE #tbl_SgnSN5
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN5(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN5)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;					
	--=============================================
	
	---------------------------------------------------------------------------
		--SET @StrWhere = '(D.AutoOrder = 0) and D.ProcessID = ' + Str(@ProcessID) + ' AND D.ProcessNo = ' + Str(@ProcessNo)
	SET @StrWhere = 'SH.ProcessID = ' + Str(@ProcessID) + ' AND SH.ProcessNo = ' + Str(@ProcessNo)

	If (@FiscalYearFr	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SH.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(SH.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SH.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SH.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(SH.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SH.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	IF @DocRowNo Is Not Null And @DocRowNo <> '-1' And @DocRowNo <> ''
		SET @StrWhere = @StrWhere + ' AND (SD.DocRowNo In (' + LTrim(RTrim(@DocRowNo)) + ')) '

	--============================
	SET @StrSelect = '
	SELECT SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo, SH.DocDate, SD.StoreID, IsNull(S.StoreName,'''') StoreName,
		   SH.ReceiptType, SH.EnterTime, SH.ExitTime, SH.AgreeNo, D2.FirstName + '' '' + LastName As DriverName, D.VehicleNo, D.DriverTel DriverMobile, 
		   D.DrivingLicenseNo, SH.Count As CartonCount, SH.LocationID, SH.BaseSendID, BS.BaseSendName, SH.Weight As WaybillWeight, 
		   pub.funGetLocationName(SH.LocationID,' + LTrim(RTrim(@LangID)) + ') AS LocationName, SH.TransportationType, SH.CarNo, 
		   SH.TrukNo, SH.TransporterID2 WaybillNo, SH.CCNo As BillNo, SD.VirtualQuantity, SD.LoadWeight, SD.EmptyWeight, [pub].[GetUserName](SH.SessionNo) AS UserName, 
		   SD.AcntCode, pub.GetCodeName(SD.AcntCode, 1) AS AcntName, SH.Address, SD.GoodsID, GD.GoodsName, SD.SendNo, SD.SubUnitID, UD.UnitName, 
		   SD.SubUnitQuantity, SD.NetWeight, SD.NetWeight /  ( case when SD.VirtualQuantity=0 then SD.SubUnitQuantity else  SD.VirtualQuantity end   ) As AverageWeight, SH.TransportationCost, SH.DocDesc,
		   SD.GoodsPrice, F.CompanyRegisterNo, F.NationalIDNumber, F.EconomicalCode, F.NationalIdentity, F.Address1, 
		   F.Address2, F.Tel, F.Fax, F.Mobile,
		   Case When SH.SgnSN1=0 Then '''' Else pub.GetUserName(SH.SgnSN1) End Signer1Name,
		   Case When SH.SgnSN2=0 Then '''' Else pub.GetUserName(SH.SgnSN2) End Signer2Name,
		   Case When SH.SgnSN3=0 Then '''' Else pub.GetUserName(SH.SgnSN3) end Signer3Name,
		   Case When SH.SgnSN4=0 Then '''' Else pub.GetUserName(SH.SgnSN4) End Signer4Name,
		   Case When SH.SgnSN5=0 Then '''' Else pub.GetUserName(SH.SgnSN5) End Signer5Name,
		   S1.UserSign As UserSignature1,
		   S2.UserSign As UserSignature2,
		   S3.UserSign As Signature1,
		   S4.UserSign As Signature2,
		   S5.UserSign As Signature3,
		   S6.UserSign As Signature4,
		   S7.UserSign As Signature5	
		 ,SD.*
		  , B.BatchName, R.ReciverName, R.ReciverAddress

	FROM inv.tblStorageDocsHdr SH
	INNER JOIN inv.tblStorageDocsDtl SD ON SH.ProcessID = SD.ProcessID And SH.ProcessNo = SD.ProcessNo And
										 SH.FiscalYear = SD.FiscalYear And SH.SerialNo = SD.SerialNo
	left join    inv.tblGoodsReciverDtl R on SD.ReciverID=R.ReciverID	and R.LanguageID=' + LTrim(RTrim(@LangID)) + '
	left join    inv.tblBatchDtl	B on B.BatchNo=	SD.BatchNo	and B.LanguageID=' + LTrim(RTrim(@LangID)) + '									 
	INNER JOIN inv.tblGoods G ON G.GoodsID = SD.GoodsID									 
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SD.GoodsID
	INNER JOIN inv.tblUnitsDtl UD ON UD.UnitID = SD.SubUnitID
	LEFT JOIN sal.tblBaseSendDtl BS ON BS.BaseSendID = SH.BaseSendID
	LEFT JOIN pub.tblDrivers D ON D.DriverID = SH.DriverID
	LEFT JOIN pub.tblDriversDtl D2 ON D2.DriverID = SH.DriverID
	LEFT  JOIN inv.tblStoresDtl S ON S.StoreID = SD.StoreID

	LEFT  JOIN #tbl_Invoice_Signatures S1 on S1.UserID = (SELECT UserID FROM #tbl_Session1 Where SerialNo = SH.SerialNo)
	LEFT  JOIN #tbl_Invoice_Signatures S2 on S2.UserID = (SELECT UserID FROM #tbl_Session2 Where SerialNo = SH.SerialNo)
	LEFT  JOIN #tbl_Invoice_Signatures S3 on S3.UserID = (SELECT UserID FROM #tbl_SgnSN1 Where SerialNo = SH.SerialNo)
	LEFT  JOIN #tbl_Invoice_Signatures S4 on S4.UserID = (SELECT UserID FROM #tbl_SgnSN2 Where SerialNo = SH.SerialNo)
	LEFT  JOIN #tbl_Invoice_Signatures S5 on S5.UserID = (SELECT UserID FROM #tbl_SgnSN3 Where SerialNo = SH.SerialNo)
	LEFT  JOIN #tbl_Invoice_Signatures S6 on S6.UserID = (SELECT UserID FROM #tbl_SgnSN4 Where SerialNo = SH.SerialNo)
	LEFT  JOIN #tbl_Invoice_Signatures S7 on S7.UserID = (SELECT UserID FROM #tbl_SgnSN5 Where SerialNo = SH.SerialNo)	

	OUTER APPLY acc.funGetCodeInfo(SD.AcntCode) AS F 
	WHERE ' + @StrWhere + '
	ORDER BY SH.FiscalYear, SH.SerialNo'

	--============================
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
