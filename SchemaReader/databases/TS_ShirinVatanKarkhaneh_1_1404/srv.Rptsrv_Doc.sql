USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/jafari
-- Create date   : 1398/10/16
-- Viewed By	 : 
-- Last Modified : 1398/10/16
-- Last Modifier : TakroSystem/jafari
-- Description   : برگ درخواست 
-- =============================================
Create PROCEDURE srv.Rptsrv_Doc
	@ProcessID		Int = 150, -- CMR Process ID
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 95,
	@SerialNo		Int = 1,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null

WITH ENCRYPTION
AS 
Declare @LanguageID TinyInt;
declare @CustomerPartNo TinyInt
Declare @DefaultStoreID			VarChar(20);
DECLARE @db_0000				NVarchar(50)

DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

Begin --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();
	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))

	-- Where ----------------------------------------
	IF (@FiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear >' + LTrim(Str(@FiscalYear)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '		
	
	Set NoCount On;

	--=======================
	CREATE TABLE #tbl_Session1
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo)
	FROM cmr.tblCMRHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_Session2
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo2)
	FROM cmr.tblCMRHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_Session3
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session3(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo3)
	FROM cmr.tblCMRHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
			
	--=======================
	CREATE TABLE #tbl_Signatures
	(
		UserID   Int,
		UserSign Image
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@db_0000)) + '.usr.tblUsers U '
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo  Is Null) SET @ProcessNo  = 1;
	If (@LanguageID Is Null) SET @LanguageID = 1;
	If (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	If (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;

	SET @DefaultStoreID = Null
	SELECT @DefaultStoreID = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'CMRDefaultStoreID'
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	-- S E L E C T ------------------------------------------------------------
	SELECT	D.*, DocDate	,PersonnelID,	CompanyID	,ContactDate	,ContactTime,	RecID	,SessionNo	,PhonerName,
		    S1.UserSign As UserSignature1,
		    S2.UserSign As UserSignature2,
		    S3.UserSign As UserSignature3
		    ,prs.funGetPersonnelName(PersonnelID,1) PersonnelName 
			,[acc].[funGetAcntName](CompanyID,@CustomerPartNo,1) CompanyName
			,[acc].[funGetServiceName] (ServiceID,1)  ServiceName
			, (select top 1 ServiceKindName from srv.tblServiceKindDtl where ServiceKindID=D.ServiceKindID) ServiceKindName
			, Case when Priority =1 then 'خیلی کم' when Priority =3 then 'کم' when Priority =5 then 'عادی' when Priority =7 then 'زیاد' when Priority =9 then 'خیلی زیاد' when Priority =10 then 'فوری' else ''	end	PriorityName
			, Case when PriorityNo =1 then 'خیلی کم' when PriorityNo =3 then 'کم' when PriorityNo =5 then 'عادی' when PriorityNo =7 then 'زیاد' when PriorityNo =9 then 'خیلی زیاد' when PriorityNo =10 then 'فوری' else '' end	PriorityNoName
			, Case when Importance =1 then 'خیلی کم' when Importance =3 then 'کم' when Importance =5 then 'عادی' when Importance =7 then 'زیاد' when Importance =9 then 'خیلی زیاد' when Importance =10 then 'فوری' else '' end	ImportanceName
			, Case when ReqImportance =1 then 'خیلی کم' when ReqImportance =3 then 'کم' when ReqImportance =5 then 'عادی' when ReqImportance =7 then 'زیاد' when ReqImportance =9 then 'خیلی زیاد' when ReqImportance =10 then 'فوری' else '' end	ReqImportanceName
			
	FROM    srv.tblServiceRequestDtl AS D 
	INNER JOIN srv.tblServiceRequestHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	LEFT  JOIN #tbl_Signatures S1 on S1.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session1 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S2 on S2.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session2 Where SerialNo = H.SerialNo),-1)
	LEFT  JOIN #tbl_Signatures S3 on S3.UserID = ISNULL((SELECT top 1 UserID FROM #tbl_Session3 Where SerialNo = H.SerialNo),-1)
	WHERE   H.ProcessID  = @ProcessID  AND H.ProcessNo = @ProcessNo AND
			H.FiscalYear >= @FiscalYear AND H.SerialNo >= @SerialNo AND
			H.FiscalYear <= @FiscalYearTo AND H.SerialNo <= @SerialNoTo
END




GO
