USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/05/07
-- Viewed By	 : 
-- Last Modified : 1392/02/15
-- Last Modified : TakroSystem\ZiA
-- Description	 : < ثبت سند افتتاحیه >	
-- =============================================
Create PROCEDURE [acc].[SpVch_CreateDoc_Opening]
	@PrevYear	Char(4), -- سال مالی چهار رقمی پیشین
	@DocDate	Char(10) = null,
	@DocDesc	NVarChar(500) = ''
WITH ENCRYPTION
AS

DECLARE @Idx      As Int	-- Counter
DECLARE @IntLen   As Int	-- LayerLen
DECLARE @IntStart As Int	-- Start Index of Len
DECLARE @IntTemp  As BigInt	-- Temp Int Variable
DECLARE @StrTempB As NVarChar(4000)		-- Temp String Variable
DECLARE @StrTempS As NVarChar(500)		-- Temp String Variable
DECLARE @StrDB_Old    As NVarChar(100)	-- Previous Year Database Name 
DECLARE @StrDB_New    As NVarChar(100)	-- Current Year Database Name 
DECLARE @StrLayerLens1 As VarChar(100)	-- Array to hold Acnt1 Layers Len (Previous Year)
DECLARE @StrLayerLens2 As VarChar(100)	-- Array to hold Acnt2 Layers Len (Previous Year)
DECLARE @StrLayerLens3 As VarChar(100)	-- Array to hold Acnt3 Layers Len (Previous Year)
DECLARE @StrLayerLens4 As VarChar(100)	-- Array to hold Acnt4 Layers Len (Previous Year)
DECLARE @StrLayerLens1New As VarChar(100) -- Array to hold Acnt1 Layers Len (Current Year)
DECLARE @StrLayerLens2New As VarChar(100) -- Array to hold Acnt2 Layers Len (Current Year)
DECLARE @StrLayerLens3New As VarChar(100) -- Array to hold Acnt3 Layers Len (Current Year)
DECLARE @StrLayerLens4New As VarChar(100) -- Array to hold Acnt4 Layers Len (Current Year)

DECLARE @SerialNo_Fin As Int
DECLARE @SerialNo_New As Int
DECLARE @SerialNo_Old As Int
DECLARE @ParamDefinition As NVarChar(100) -- Used for sp_executesql
DECLARE @SessionNo AS Int
DECLARE @RecID As bigint
DECLARE @ErrorMsg As nvarchar(2000)

BEGIN -- ======= S T A R T  C O D E ===================================

	SET NOCOUNT ON;

	CREATE TABLE #tblAcntCodes
	(
		AcntCode	VarChar(20) COLLATE Arabic_CS_AS,
		AcntLayer	TinyInt -- 0 = Complete Code (Not Valid), 1 = Seperated Code (Valid)
	);

	-- Init Variables ---------------------------
	SET @StrDB_New = db_name()
	SET @StrDB_Old = Substring(db_name(), 0, Len(@StrDB_New) - 3) + @PrevYear

	SET @SessionNo	= pub.funGetCurrentSessionNo();
	
	If @DocDesc Is Null Set @DocDesc = ''
	If @DocDate Is Null Set @DocDate = RIGHT(@StrDB_New, 4) + '/01/01'
	----------------------------------------------------
	-- Check Not To Exist Any Similar Doc -------
	SELECT	@IntTemp = Count(*)
	FROM	acc.tblVoucherHdr
	WHERE	SerialNo = 1

	If (@IntTemp > 0)
	Begin
		-- RaisError(N'سند شماره 1 استفاده شده است' ,10, 16)
		Return -1;
	End
	--------------------------------------------------	
	-- Check Current Year's Finished Doc Not be saved --
	SELECT	@IntTemp = Count(*)
	FROM	acc.tblVoucherDtl
	WHERE	VchKind = 3

	If (@IntTemp > 0)
	Begin
		-- RaisError('سند اختتامیه ایجاد شده است' ,10, 16)
		Return -2;
	End
	----------------------------------------------------
	-- Check Previous Year's Finished Doc be saved -----
	Set @ParamDefinition = N'@SerialOUT Int OUTPUT';
	Set @StrTempB = '
		SELECT top 1 @SerialOUT = SerialNo
		FROM [' + @StrDB_Old + '].[acc].[tblVoucherDtl]
		WHERE VchKind = 3' -- Finish Voucher

	Execute sp_executesql @StrTempB, @ParamDefinition, @SerialOUT = @SerialNo_Fin OUTPUT;

	If (@SerialNo_Fin Is Null)
	Begin
		-- RaisError('سند اختتامیه سال قبل هنوز ثبت نشده است' ,10, 16)
		Return -3;
	End
	---------------------------------------------------------
	-- Check another user don't connect to database ---------
	--Set @ParamDefinition = N'@CountOUT Int OUTPUT';
	--Set @StrTempB = '
		--SELECT @CountOUT = Count(*)
		--FROM [' + pub.funGetBranchDBName() + '].[usr].[tblActiveUsers]
		--WHERE ABS(DateDiff(mi, RefreshDateTime, GetDate())) < 6'

	--Execute sp_executesql @StrTempB, @ParamDefinition, @CountOUT = @IntTemp OUTPUT;

	--If (@IntTemp > 1)
	--Begin
		---- RaisError('کابر دیگری در سیستم مشغول است' ,10, 16)
		--Return -4;
	--End
	-----------------------------------------------
	-- Check Layers Len to be same ----------------
	Set @ParamDefinition = N'@StrLayerLensOUT NVarChar(50) OUTPUT';
	Set @StrTempS = '
		SELECT @StrLayerLensOUT = 
				 LTRim(Str(Layer1)) + '';'' + LTRim(Str(Layer2)) + '';'' + LTRim(Str(Layer3)) + '';'' + 
				 LTRim(Str(Layer4)) + '';'' + LTRim(Str(Layer5)) + '';'' + LTRim(Str(Layer6)) + '';'' + 
				 LTRim(Str(Layer7)) + '';'' + LTRim(Str(Layer8)) + '';'' + LTRim(Str(Layer9))
		FROM	 ' + @StrDB_Old + '.pub.tblCodeLayer '

	-- Acnt Part1 Len  ------------------------
	Set @StrTempB = @StrTempS + '
		WHERE	PartNumber = 1 AND TableName = ''acc.tblAcnt'' '
	Execute sp_executesql @StrTempB, @ParamDefinition, @StrLayerLensOUT = @StrLayerLens1 OUTPUT;

	SELECT @StrLayerLens1New = LTRim(Str(Layer1)) + ';' + LTRim(Str(Layer2)) + ';' + LTRim(Str(Layer3)) + ';' + LTRim(Str(Layer4)) + ';' + LTRim(Str(Layer5)) + ';' + LTRim(Str(Layer6)) + ';' + LTRim(Str(Layer7)) + ';' + LTRim(Str(Layer8)) + ';' + LTRim(Str(Layer9))
	FROM   pub.tblCodeLayer
	WHERE  PartNumber = 1 AND TableName = 'acc.tblAcnt'

	-- Acnt Part2 Len  ------------------------
	Set @StrTempB = @StrTempS + '
		WHERE	PartNumber = 2 AND TableName = ''acc.tblAcnt'' '
	Execute sp_executesql @StrTempB, @ParamDefinition, @StrLayerLensOUT = @StrLayerLens2 OUTPUT;

	SELECT @StrLayerLens2New = LTRim(Str(Layer1)) + ';' + LTRim(Str(Layer2)) + ';' + LTRim(Str(Layer3)) + ';' + LTRim(Str(Layer4)) + ';' + LTRim(Str(Layer5)) + ';' + LTRim(Str(Layer6)) + ';' + LTRim(Str(Layer7)) + ';' + LTRim(Str(Layer8)) + ';' + LTRim(Str(Layer9))
	FROM   pub.tblCodeLayer
	WHERE  PartNumber = 2 AND TableName = 'acc.tblAcnt'

	-- Acnt Part3 Len  ------------------------
	Set @StrTempB = @StrTempS + '
		WHERE PartNumber = 3 AND TableName = ''acc.tblAcnt'' '
	Execute sp_executesql @StrTempB, @ParamDefinition, @StrLayerLensOUT = @StrLayerLens3 OUTPUT;

	SELECT @StrLayerLens3New = LTRim(Str(Layer1)) + ';' + LTRim(Str(Layer2)) + ';' + LTRim(Str(Layer3)) + ';' + LTRim(Str(Layer4)) + ';' + LTRim(Str(Layer5)) + ';' + LTRim(Str(Layer6)) + ';' + LTRim(Str(Layer7)) + ';' + LTRim(Str(Layer8)) + ';' + LTRim(Str(Layer9))
	FROM   pub.tblCodeLayer
	WHERE  PartNumber = 3 AND TableName = 'acc.tblAcnt'

	-- Acnt Part4 Len  ------------------------
	Set @StrTempB = @StrTempS + '
		WHERE PartNumber = 4 AND TableName = ''acc.tblAcnt'' '
	Execute sp_executesql @StrTempB, @ParamDefinition, @StrLayerLensOUT = @StrLayerLens4 OUTPUT;

	SELECT @StrLayerLens4New = LTRim(Str(Layer1)) + ';' + LTRim(Str(Layer2)) + ';' + LTRim(Str(Layer3)) + ';' + LTRim(Str(Layer4)) + ';' + LTRim(Str(Layer5)) + ';' + LTRim(Str(Layer6)) + ';' + LTRim(Str(Layer7)) + ';' + LTRim(Str(Layer8)) + ';' + LTRim(Str(Layer9))
	FROM  pub.tblCodeLayer
	WHERE PartNumber = 4 AND TableName = 'acc.tblAcnt'

	---------------------------------------------
	-- new db AcntCode(s) is not set yet; Import them from previous year db
	If (@StrLayerLens1New Is Null) AND (@StrLayerLens2New Is Null) AND (@StrLayerLens3New Is Null) AND (@StrLayerLens4New Is Null)
	Begin
		Set @StrTempB = '
		INSERT INTO pub.tblCodeLayer
		SELECT *
		FROM [' + @StrDB_Old + '].[pub].[tblCodeLayer] AS H
		WHERE H.TableName = ''acc.tblAcnt'';

		INSERT INTO pub.tblCodeLayerDtl
		SELECT *
		FROM [' + @StrDB_Old + '].[pub].[tblCodeLayerDtl] AS D
		WHERE D.TableName = ''acc.tblAcnt''; '

		Exec sp_executesql @StrTempB;
	End
	Else If (@StrLayerLens1New <> @StrLayerLens1)
	Begin
		--RaisError ('AcntCode Part1 Layers Has Changed!', 10, 16)
		Return -5;
	End
	Else If (@StrLayerLens2New <> @StrLayerLens2)
	Begin
		--RaisError ('AcntCode Part2 Layers Has Changed!', 10, 16)
		Return -5;
	End
	Else If (@StrLayerLens3New <> @StrLayerLens3)
	Begin
		--RaisError ('AcntCode Part3 Layers Has Changed!', 10, 16)
		Return -5;
	End
	Else If (@StrLayerLens4New <> @StrLayerLens4)
	Begin
		--RaisError ('AcntCode Part4 Layers Has Changed!', 10, 16)
		Return -5;
	End
	-----------------------------------------------
	-- T R Y  B L O C K ---------------------------
	BEGIN TRANSACTION;
	
	BEGIN TRY
		-- Extract Complete AcntCodes From Previous Year's Finish Voucher
		Set @StrTempB = '
		INSERT	INTO #tblAcntCodes
		SELECT	DISTINCT AcntCode, 0 
		FROM	[' + @StrDB_Old + '].[acc].[tblVoucherDtl]
		WHERE	SerialNo = ' + Str(@SerialNo_Fin)

		Exec sp_executesql @StrTempB;

		-- =================== A C N T  1 ===============================================
		Set @IntStart = 1;
		Set @Idx = 1;
		Set @IntLen = 0;

		While (@Idx <= 9)
		Begin
			Set @IntTemp = Cast([pub].[funSplitString](@StrLayerLens1, ';', @Idx) As Int)
			If (@IntTemp = 0) Break;

			Set @IntLen = @IntLen + @IntTemp;
			Set @Idx = @Idx + 1

			-- Break Complete AcntCode to its Layers and Save them into same table with (AcntLayer = 1)
			INSERT INTO #tblAcntCodes
			SELECT DISTINCT Substring(AcntCode, @IntStart, @IntLen), 1
			FROM   #tblAcntCodes
			WHERE  (AcntLayer = 0) AND Substring(AcntCode, @IntStart, @IntLen) <> ''
		End

		-- Fill Separated AcntCodes Into Current Year Acnt Tables
		Set @StrTempB = '
			INSERT	INTO [acc].[tblAcnt](
					AcntCode, PartNumber, CodeClosed, AcntType, AcntState, AcntMsgForce, Acnt2Force, Acnt3Force, Acnt4Force, LocationID, Tel, Fax, OtherTels, ZipCode, EconomicalCode, MaxDebitRemain, MaxReceivableRemain, MaxDaysAfterExpiration, RecID, SessionNo, ' + +            'PersonnelNo, IDNo, InitialGrad, CompanyRegisterNo, Mobile, NationalIDNumber, MaxReturnCheque, MemberCode, MemberDate, Email, InternetAddress)
			SELECT	AcntCode, PartNumber, CodeClosed, AcntType, AcntState, AcntMsgForce, Acnt2Force, Acnt3Force, Acnt4Force, LocationID, Tel, Fax, OtherTels, ZipCode, EconomicalCode, MaxDebitRemain, MaxReceivableRemain, MaxDaysAfterExpiration, RecID, ''' + Str(@SessionNo) + ''', PersonnelNo, IDNo, InitialGrad, CompanyRegisterNo, Mobile, NationalIDNumber, MaxReturnCheque, MemberCode, MemberDate, Email, InternetAddress
			FROM	[' + @StrDB_Old + '].[acc].[tblAcnt] 
			WHERE	PartNumber = 1 AND 
					AcntCode IN 
					(
						SELECT AcntCode
						FROM   #tblAcntCodes TMP 
						WHERE  TMP.AcntLayer = 1
					) AND 
					AcntCode NOT IN 
					(
						SELECT AcntCode 
						FROM [acc].[tblAcnt] 
						WHERE PartNumber = 1
					);

			INSERT	INTO [acc].[tblAcntDtl](
					AcntCode, LanguageID, PartNumber, AcntName, AcntComment, FirstName, LastName, OrganzationName, Address1, Address2, GradDesc)
			SELECT	AcntCode, LanguageID, PartNumber, AcntName, AcntComment, FirstName, LastName, OrganzationName, Address1, Address2, GradDesc
			FROM	[' + @StrDB_Old + '].[acc].[tblAcntDtl]
			WHERE	PartNumber = 1 AND 
					AcntCode IN 
					(
						SELECT AcntCode
						FROM   #tblAcntCodes TMP
						WHERE  TMP.AcntLayer = 1
					) AND 
					AcntCode NOT IN 
					(
						SELECT AcntCode 
						FROM [acc].[tblAcntDtl] 
						WHERE PartNumber = 1
					);'

		Exec sp_executesql @StrTempB;

		-- =================== A C N T  2 ===============================================
		Set @IntStart = @IntStart + @IntLen + 1;
		Set @Idx = 1;
		Set @IntLen = 0;

		While (@Idx <= 9)
		Begin
			Set @IntTemp = Cast([pub].[funSplitString](@StrLayerLens2, ';', @Idx) AS Int)
			If (@IntTemp = 0) Break;

			Set @IntLen = @IntLen + @IntTemp;
			Set @Idx = @Idx + 1;

			INSERT INTO #tblAcntCodes
			SELECT DISTINCT Substring(AcntCode, @IntStart, @IntLen), 2
			FROM   #tblAcntCodes
			WHERE  (AcntLayer = 0) AND Substring(AcntCode, @IntStart, @IntLen) <> ''
		End

		Set @StrTempB = '
			INSERT	INTO [acc].[tblAcnt](
					AcntCode, PartNumber, CodeClosed, AcntType, AcntState, AcntMsgForce, Acnt2Force, Acnt3Force, Acnt4Force, LocationID, Tel, Fax, OtherTels, ZipCode, EconomicalCode, MaxDebitRemain, MaxReceivableRemain, MaxDaysAfterExpiration, RecID, SessionNo, ' + +            'PersonnelNo, IDNo, InitialGrad, CompanyRegisterNo, Mobile, NationalIDNumber, MaxReturnCheque, MemberCode, MemberDate, Email, InternetAddress)
			SELECT	AcntCode, PartNumber, CodeClosed, AcntType, AcntState, AcntMsgForce, Acnt2Force, Acnt3Force, Acnt4Force, LocationID, Tel, Fax, OtherTels, ZipCode, EconomicalCode, MaxDebitRemain, MaxReceivableRemain, MaxDaysAfterExpiration, RecID, ''' + Str(@SessionNo) + ''', PersonnelNo, IDNo, InitialGrad, CompanyRegisterNo, Mobile, NationalIDNumber, MaxReturnCheque, MemberCode, MemberDate, Email, InternetAddress
			FROM	[' + @StrDB_Old + '].[acc].[tblAcnt] 
			WHERE	PartNumber = 2 AND 
					AcntCode IN 
					(
						SELECT AcntCode
						FROM   #tblAcntCodes TMP 
						WHERE  TMP.AcntLayer = 2
					) AND 
					AcntCode NOT IN 
					(
						SELECT AcntCode 
						FROM [acc].[tblAcnt] 
						WHERE PartNumber = 2
					);

			INSERT	INTO [acc].[tblAcntDtl](
					AcntCode, LanguageID, PartNumber, AcntName, AcntComment, FirstName, LastName, OrganzationName, Address1, Address2, GradDesc)
			SELECT	AcntCode, LanguageID, PartNumber, AcntName, AcntComment, FirstName, LastName, OrganzationName, Address1, Address2, GradDesc
			FROM	[' + @StrDB_Old + '].[acc].[tblAcntDtl]
			WHERE	PartNumber = 2 AND 
					AcntCode IN 
					(
						SELECT AcntCode
						FROM   #tblAcntCodes TMP
						WHERE  TMP.AcntLayer = 2
					) AND 
					AcntCode NOT IN 
					(
						SELECT AcntCode 
						FROM [acc].[tblAcntDtl] 
						WHERE PartNumber = 2
					);'

		Exec sp_executesql @StrTempB;

		-- =================== A C N T  3 ===============================================
		Set @IntStart = @IntStart + @IntLen + 1;
		Set @Idx = 1;
		Set @IntLen = 0;

		While (@Idx <= 9)
		Begin
			Set @IntTemp = Cast([pub].[funSplitString](@StrLayerLens3, ';', @Idx) AS Int)
			If (@IntTemp = 0) Break;

			Set @IntLen = @IntLen + @IntTemp;
			Set @Idx = @Idx + 1;

			INSERT INTO #tblAcntCodes
			SELECT DISTINCT Substring(AcntCode, @IntStart, @IntLen), 3
			FROM   #tblAcntCodes
			WHERE  (AcntLayer = 0) AND Substring(AcntCode, @IntStart, @IntLen) <> ''
		End

		Set @StrTempB = '
			INSERT	INTO [acc].[tblAcnt](
					AcntCode, PartNumber, CodeClosed, AcntType, AcntState, AcntMsgForce, Acnt2Force, Acnt3Force, Acnt4Force, LocationID, Tel, Fax, OtherTels, ZipCode, EconomicalCode, MaxDebitRemain, MaxReceivableRemain, MaxDaysAfterExpiration, RecID, SessionNo, ' + +            'PersonnelNo, IDNo, InitialGrad, CompanyRegisterNo, Mobile, NationalIDNumber, MaxReturnCheque, MemberCode, MemberDate, Email, InternetAddress)
			SELECT	AcntCode, PartNumber, CodeClosed, AcntType, AcntState, AcntMsgForce, Acnt2Force, Acnt3Force, Acnt4Force, LocationID, Tel, Fax, OtherTels, ZipCode, EconomicalCode, MaxDebitRemain, MaxReceivableRemain, MaxDaysAfterExpiration, RecID, ''' + Str(@SessionNo) + ''', PersonnelNo, IDNo, InitialGrad, CompanyRegisterNo, Mobile, NationalIDNumber, MaxReturnCheque, MemberCode, MemberDate, Email, InternetAddress
			FROM	[' + @StrDB_Old + '].[acc].[tblAcnt] 
			WHERE	PartNumber = 3 AND
					AcntCode IN 
					(
						SELECT AcntCode
						FROM   #tblAcntCodes TMP 
						WHERE  TMP.AcntLayer = 3
					) AND 
					AcntCode NOT IN 
					(
						SELECT AcntCode 
						FROM [acc].[tblAcnt] 
						WHERE PartNumber = 3
					);

			INSERT	INTO [acc].[tblAcntDtl](
					AcntCode, LanguageID, PartNumber, AcntName, AcntComment, FirstName, LastName, OrganzationName, Address1, Address2, GradDesc)
			SELECT	AcntCode, LanguageID, PartNumber, AcntName, AcntComment, FirstName, LastName, OrganzationName, Address1, Address2, GradDesc
			FROM	[' + @StrDB_Old + '].[acc].[tblAcntDtl]
			WHERE	PartNumber = 3 AND
					AcntCode IN 
					(
						SELECT AcntCode
						FROM   #tblAcntCodes TMP
						WHERE  TMP.AcntLayer = 3
					) AND 
					AcntCode NOT IN 
					(
						SELECT AcntCode 
						FROM [acc].[tblAcntDtl] 
						WHERE PartNumber = 3
					);'

		Exec sp_executesql @StrTempB;

		-- =================== A C N T  4 ===============================================
		Set @IntStart = @IntStart + @IntLen + 1;
		Set @Idx = 1;
		Set @IntLen = 0;

		While (@Idx <= 9)
		Begin
			Set @IntTemp = Cast([pub].[funSplitString](@StrLayerLens4, ';', @Idx) AS Int)
			If (@IntTemp = 0) Break;

			Set @IntLen = @IntLen + @IntTemp;
			Set @Idx = @Idx + 1;

			INSERT INTO #tblAcntCodes
			SELECT DISTINCT Substring(AcntCode, @IntStart, @IntLen), 4
			FROM   #tblAcntCodes
			WHERE  (AcntLayer = 0) AND Substring(AcntCode, @IntStart, @IntLen) <> ''
		End

		Set @StrTempB = '
			INSERT	INTO [acc].[tblAcnt](
					AcntCode, PartNumber, CodeClosed, AcntType, AcntState, AcntMsgForce, Acnt2Force, Acnt3Force, Acnt4Force, LocationID, Tel, Fax, OtherTels, ZipCode, EconomicalCode, MaxDebitRemain, MaxReceivableRemain, MaxDaysAfterExpiration, RecID, SessionNo, ' + +            'PersonnelNo, IDNo, InitialGrad, CompanyRegisterNo, Mobile, NationalIDNumber, MaxReturnCheque, MemberCode, MemberDate, Email, InternetAddress)
			SELECT	AcntCode, PartNumber, CodeClosed, AcntType, AcntState, AcntMsgForce, Acnt2Force, Acnt3Force, Acnt4Force, LocationID, Tel, Fax, OtherTels, ZipCode, EconomicalCode, MaxDebitRemain, MaxReceivableRemain, MaxDaysAfterExpiration, RecID, ''' + Str(@SessionNo) + ''', PersonnelNo, IDNo, InitialGrad, CompanyRegisterNo, Mobile, NationalIDNumber, MaxReturnCheque, MemberCode, MemberDate, Email, InternetAddress
			FROM	[' + @StrDB_Old + '].[acc].[tblAcnt] 
			WHERE	PartNumber = 4 AND 
					AcntCode IN 
					(
						SELECT AcntCode
						FROM   #tblAcntCodes TMP 
						WHERE  TMP.AcntLayer = 4
					) AND 
					AcntCode NOT IN 
					(
						SELECT AcntCode 
						FROM [acc].[tblAcnt] 
						WHERE PartNumber = 4
					);

			INSERT	INTO [acc].[tblAcntDtl](
					AcntCode, LanguageID, PartNumber, AcntName, AcntComment, FirstName, LastName, OrganzationName, Address1, Address2, GradDesc)
			SELECT	AcntCode, LanguageID, PartNumber, AcntName, AcntComment, FirstName, LastName, OrganzationName, Address1, Address2, GradDesc
			FROM	[' + @StrDB_Old + '].[acc].[tblAcntDtl]
			WHERE	PartNumber = 4 AND 
					AcntCode IN 
					(
						SELECT AcntCode
						FROM   #tblAcntCodes TMP
						WHERE  TMP.AcntLayer = 4
					) AND 
					AcntCode NOT IN 
					(
						SELECT AcntCode 
						FROM [acc].[tblAcntDtl] 
						WHERE PartNumber = 4
					);'

		Exec sp_executesql @StrTempB;

		-- =======================================================================================================
		-- =======================================================================================================
		-- =======================================================================================================

		-- === Insert Header Section === --
		-------------------------------------------------
		CREATE TABLE #tmp(Id bigint)
	
		insert into	#tmp
		exec [hst].[funGetUniqueId]

		select @RecID = Id from #tmp
		
		set @SerialNo_New = 1;
		set @SerialNo_Old = 1;

select @SerialNo_Old=COUNT(*) from acc.tblVoucherHdr where OldSerialNo=1
if @SerialNo_Old=0
set @SerialNo_Old = 1;
else
select @SerialNo_Old = max(OldSerialNo)+1 from acc.tblVoucherHdr


		INSERT INTO	acc.tblVoucherHdr(SerialNo, DocDate, DocRegisterState, DocDesc, DocDesc2, VchKind, RecID, SessionNo, OldSerialNo, CurrencyTypeID, CurrencyRate, RowNo)
		VALUES (@SerialNo_New, @DocDate, 1, @DocDesc, '', 2, @RecID, @SessionNo, @SerialNo_Old, '', 0, 0)

		-- === Insert Details Section === --
		SET @StrTempB = '							   
		insert into [' + @StrDB_New + '].[acc].[tblVoucherDtl](
				SerialNo, RowNo, DocRowNo, DocDate, AcntCode, CurrencyTypeID, CurrencyAmount, 
				Debit, Credit, SessionNo, RecDesc, RecDesc2, IsAutoDoc, VchKind, IsShowDetail,
				SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocType,
				SourceCodeFieldValue, Emphasize, Emphasize2, Emphasize3,VisitorAcntCode)
		select	' + str(@SerialNo_New) + ', PREV.RowNo, PREV.DocRowNo, ''' + @DocDate + ''', PREV.AcntCode, 
				PREV.CurrencyTypeID, PREV.CurrencyAmount, PREV.Credit Debit, PREV.Debit Credit, 
				' + str(@SessionNo) + ', '''+ @DocDesc + ''', '''' RecDesc2, 1 IsAutoDoc, 2 VchKind,
				0 IsShowDetail,	0, SourceProcessNo, 0, 0, 0, 0, 0, 0, 0,VisitorAcntCode
		from	[' + @StrDB_Old + '].[acc].[tblVoucherDtl] PREV
		where	(PREV.SerialNo = ' + LTRim(Str(@SerialNo_Fin)) + ')'

		Exec sp_executesql @StrTempB;

		COMMIT TRANSACTION;

		--exec acc.SpAcc_AccStateTrans2NewYear
		exec acc.UpdateAlltblVoucher2AccState

		PRINT 'Successfull!';
		RETURN @SerialNo_New;
	END TRY

	BEGIN CATCH
		SELECT @ErrorMsg = ERROR_MESSAGE();

		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION;

		IF (XACT_STATE()) = 1
		BEGIN
--		  PRINT N'The transaction is committable. ' + 'but Rolling Back it.'
		  ROLLBACK TRANSACTION;   
		END;

		RAISERROR (@ErrorMsg, 16, 1)
		
		RETURN -10;
	END CATCH
END
GO
