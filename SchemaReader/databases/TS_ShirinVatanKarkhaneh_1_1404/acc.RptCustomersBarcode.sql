USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/06/28
-- Viewed By	 : 
-- Last Modified : 1389/06/28
-- Last Modifier : Takrosystem\Zia
-- Description	 : مشخصات مشتریان
-- ===============================================
CREATE PROCEDURE [acc].[RptCustomersBarcode]
	@AcntPartNo		Int = 1, -- شماره بخش
	@AcntCode1		Int = 0,
	@AcntCode2		Int = 0,
	@AcntCode3		Int = 0,
	@AcntCode4		Int = 0,
	@CustomerKind	VarChar(20) = Null, 
	@RepOptions		NVarChar(10) = '11',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@EmptyNames		Bit; -- شامل نامهای خالی باشد یا نه؟
DECLARE	@SortByName		Bit; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrHaving		NVarChar(1000);

DECLARE @iPartStart		TinyInt;
DECLARE @iPartLen		TinyInt;

DECLARE @iPart1Start	TinyInt;
DECLARE @iPart1Len		TinyInt;
DECLARE @iPart2Start	TinyInt;
DECLARE @iPart2Len		TinyInt;
DECLARE @iPart3Start	TinyInt;
DECLARE @iPart3Len		TinyInt;
Declare @iPart4Start	TinyInt;
Declare @iPart4Len		TinyInt;

BEGIN 
	--============================ S T A R T ===========================================

	-- init ------------------------------------------------
	SET NOCOUNT ON;

	If (@RepInfo Is Null)	SET @RepInfo = '1@1@1'
	If (@RepOptions Is Null) SET @RepOptions = '11'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @EmptyNames		= Substring(@RepOptions, 1, 1);
	SET @SortByName		= Substring(@RepOptions, 2, 1);
	--------------------------------------------------------

	-------- LAYERS LEN CLAUSE -----------------------------
	SELECT	@iPart1Start = 1;
	SELECT	@iPart1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@iPart2Start = @iPart1Start + @iPart1Len + 1;
	SELECT	@iPart2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@iPart3Start = @iPart2Start + @iPart2Len + 1;
	SELECT	@iPart3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@iPart4Start = @iPart3Start + @iPart3Len + 1;
	SELECT	@iPart4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	---- CALC LEN ----
	If @AcntPartNo = 1
		Set @iPartStart = @iPart1Start
	Else If @AcntPartNo = 2
		Set @iPartStart = @iPart2Start
	Else If @AcntPartNo = 3
		Set @iPartStart = @iPart3Start
	Else If @AcntPartNo = 4
		Set @iPartStart = @iPart4Start

	SELECT	@iPartLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @AcntPartNo)

	-------------------------------------------------------------------------------------
	-- where ----------------------------------------------------------------------------
	SET @StrWhere = ' (H.PartNumber = ' + LTrim(Str(@AcntPartNo)) + ') AND Len(H.AcntCode) = ' + LTrim(Str(@iPartLen))

	if (@CustomerKind is not null)
		Set @StrWhere = @StrWhere + ' AND (pub.funGetCustomerKindID(H.AcntCode) = ''' + @CustomerKind + ''')'

	IF (@AcntCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode1, 'H.AcntCode')
	IF (@AcntCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode2, 'H.AcntCode')
	IF (@AcntCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode3, 'H.AcntCode')
	IF (@AcntCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode4, 'H.AcntCode')

	If (@EmptyNames = 0)
		SET @StrWhere = @StrWhere + ' AND ((D.FirstName <> '''') OR (D.LastName <> '''') OR (D.OrganzationName <> '''')) '
	-------------------------------------------------------------------------------------
	-- select ---------------------------------------------------------------------------
	SET @StrSelect = '
		SELECT	H.*, D.AcntName, D.AcntComment, D.FirstName, D.LastName, D.OrganzationName, 
				D.Address1, D.Address2, D.GradDesc, L.AreaCode, LD.LocationName
		FROM	acc.tblAcnt H 
					INNER JOIN acc.tblAcntDtl D ON (H.AcntCode = D.AcntCode) AND (H.PartNumber = D.PartNumber)
					LEFT  JOIN pub.tblLocations L ON (H.LocationID = L.LocationID)
					LEFT  JOIN pub.tblLocationsDtl LD ON (L.LocationID = LD.LocationID) AND (LD.LanguageID = ' + @LangID + ')
		WHERE  ' + @StrWhere 

	If (@SortByName = 1)
		SET @StrSelect = @StrSelect + '
		ORDER By AcntName '
	Else
		SET @StrSelect = @StrSelect + '
		ORDER By AcntCode '
	-------------------------------------------------------------------------------------
	-- run ------------------------------------------------------------------------------
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	-------------------------------------------------------------------------------------
END
GO
