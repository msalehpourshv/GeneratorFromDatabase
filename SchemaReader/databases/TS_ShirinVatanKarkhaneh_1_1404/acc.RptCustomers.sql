USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 2008-08-14
-- Viewed By	 : 
-- Last Modified : 1393/06/22
-- Last Modifier : Takrosystem\Hamid
-- Description	 : مشخصات مشتریان
-- ===============================================
Create PROCEDURE [acc].[RptCustomers]
	@AcntPartNo		TinyInt, -- شماره بخش
	@FullAcntCodes	Bit = 1, -- فقط کدهای کامل
	@AcntCode1		Int = 0,
	@AcntCode2		Int = 0,
	@AcntCode3		Int = 0,
	@AcntCode4		Int = 0,
	@CustomerKind	VarChar(20) = Null, 
	@CustomerClass	VarChar(20) = Null,
	@UserID			Int = Null, 
	@RepOptions		NVarChar(10) = '1110000',
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(400) = ''
WITH ENCRYPTION
AS
DECLARE	@EmptyNames			Bit; -- شامل نامهای خالی باشد یا نه؟
DECLARE	@ZeroRemain			Bit; -- شامل کدهای با مانده صفر باشد یا نه؟
DECLARE	@ZeroCycle			Bit; -- شامل کدهای با گردش صفر باشد یا نه؟
DECLARE	@ShowDesc			Bit; -- شامل ستون شرح باشد یا نه؟
DECLARE	@ShowAddr			Bit; -- شامل ستون آدرس کد باشد یا نه؟
DECLARE	@UserIsAdmin		Bit; -- کاربر اعلام شده مدیر است یا نه؟
DECLARE	@SortByName			Bit; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
DECLARE	@ShowVisitors		Bit;
DECLARE	@ShowCodes			int;
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;
DECLARE @StrSelect			NVarChar(4000);
DECLARE @StrVisitor			NVarChar(4000);
DECLARE @StrWhere			NVarChar(4000);
DECLARE @StrHaving			NVarChar(4000);

DECLARE @LimitState			SmallInt;
DECLARE @StrDesc			NVarChar(500);
DECLARE @StrAddr			NVarChar(500);
DECLARE @StrCycle			NVarChar(500);
DECLARE @StrRemain			NVarChar(500);
DECLARE @iPartStart			TinyInt;
DECLARE @iPartLen			TinyInt;
DECLARE @iPart1Start		TinyInt;
DECLARE @iPart1Len			TinyInt;
DECLARE @iPart2Start		TinyInt;
DECLARE @iPart2Len			TinyInt;
DECLARE @iPart3Start		TinyInt;
DECLARE @iPart3Len			TinyInt;
Declare @iPart4Start		TinyInt;
Declare @iPart4Len			TinyInt;
Declare @SaleTypeID			VarChar(20) ;
Declare @CompleteDateFrom	Char(10) ;
Declare @CompleteDateTo		Char(10) ;
Declare @InsertDateFrom		Char(10) ;
Declare @InsertDateTo		Char(10) ;
DECLARE @StrAcntWhere	NVarChar(4000);
DECLARE @CampaignID				int;
DECLARE @VisitPathID1			int;
DECLARE @VisitPathID2			int;
DECLARE @VisitPathID3			int;
DECLARE @VisitPathID4			int;
DECLARE @SalesRoomClass			int;
BEGIN 
	--============================ S T A R T ===========================================
	
	-- init ------------------------------------------------
	SET NOCOUNT ON;

	If (@RepInfo Is Null)	SET @RepInfo = '1@1@1'
	If (@RepOptions Is Null) SET @RepOptions = '1110000'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	

	SET @EmptyNames		= Substring(@RepOptions, 1, 1);
	SET @ZeroRemain		= Substring(@RepOptions, 2, 1);
	SET @ZeroCycle		= Substring(@RepOptions, 3, 1);
	SET @ShowDesc		= Substring(@RepOptions, 4, 1);
	SET @ShowAddr		= Substring(@RepOptions, 5, 1);
	SET @UserIsAdmin	= Substring(@RepOptions, 6, 1);
	SET @SortByName		= Substring(@RepOptions, 7, 1);
	
	if len(@RepOptions) > 7 
		set @ShowVisitors = Substring(@RepOptions, 8, 1)
	else
		set @ShowVisitors = 0;

	set @ShowCodes = Substring(@RepOptions, 9, 1)
		
	SET @SaleTypeID		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @CompleteDateFrom		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @CompleteDateTo		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @CampaignID				= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @VisitPathID1			= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @VisitPathID2			= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @VisitPathID3			= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	SET @VisitPathID4			= LTrim(pub.funSplitString(@ExtraParams, '@', 8));
	SET @SalesRoomClass			= LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @InsertDateFrom		= pub.funSplitString(@ExtraParams, '@', 10);
	SET @InsertDateTo		= pub.funSplitString(@ExtraParams, '@', 11);


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

	SET @StrWhere = '';
	
	If @UserIsAdmin = 1
		SET	@LimitState = 1
	Else
	Begin
		SELECT	TOP 1 @LimitState = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = @AcntPartNo)

		SET @LimitState = IsNull(@LimitState, -1);
	End
	 


	--=== WHERE =========================================================================

	SET @StrWhere = ' (H.PartNumber = ' + LTrim(Str(@AcntPartNo)) + ')'

	--If (@FullAcntCodes = 1)
	--	SET @StrWhere = @StrWhere + ' AND Len(H.AcntCode) = ' + LTrim(Str(@iPartLen))

	If (@FullAcntCodes = 1)
	SET @StrWhere = @StrWhere + ' AND  (SELECT COUNT(*) from acc.tblAcnt C where C.PartNumber = ' + LTrim(Str(@AcntPartNo)) + ' AND C.AcntCode LIKE (H.AcntCode+' + '''%''' + '))=1   '

	If (@ShowCodes = 2)
		SET @StrWhere = @StrWhere + ' AND H.CodeClosed  = 0 ' 
	If (@ShowCodes = 3)
		SET @StrWhere = @StrWhere + ' AND H.CodeClosed  = 1 ' 

	if (@CustomerKind is not null) And (@CustomerKind <> '')
		Set @StrWhere = @StrWhere + ' AND (H.CustomerKindID = ''' + @CustomerKind + ''')'
	
	if (@SaleTypeID is not null and @SaleTypeID<>'0')
		Set @StrWhere = @StrWhere + ' AND (H.SaleTypeID = ''' + @SaleTypeID + ''')'
	if (@CompleteDateFrom is not null and @CompleteDateFrom<>'0')
		Set @StrWhere = @StrWhere + ' AND (H.CompleteDate >= ''' + @CompleteDateFrom + ''')'
	if (@CompleteDateTo is not null and @CompleteDateTo<>'0')
		Set @StrWhere = @StrWhere + ' AND (H.CompleteDate <= ''' + @CompleteDateTo + ''')'

	if (@InsertDateFrom is not null and @InsertDateFrom<>'0')
		Set @StrWhere = @StrWhere + ' AND (H.InsertDate >= ''' + @InsertDateFrom + ''')'
	if (@InsertDateTo is not null and @InsertDateTo<>'0')
		Set @StrWhere = @StrWhere + ' AND (H.InsertDate <= ''' + @InsertDateTo + ''')'
	
	IF (@AcntCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode1, 'H.AcntCode')
	IF (@AcntCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode2, 'H.AcntCode')
	IF (@AcntCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode3, 'H.AcntCode')
	IF (@AcntCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode4, 'H.AcntCode')

	If (@EmptyNames = 0)
		SET @StrWhere = @StrWhere + ' AND 
			((D.FirstName <> '''') OR (D.LastName <> '''') OR (D.OrganzationName <> '''')) '
	-----------------------------------------------------
	If (@LimitState = -1)
	Begin
		SET @StrWhere = @StrWhere + ' AND 
		(H.AcntCode = '''') '
	End
	Else If (@LimitState = 0)
		SET @StrWhere = @StrWhere + ' AND 
		acc.funPermitted(' + LTRim(Str(@UserID)) + ', H.AcntCode, ' + LTrim(Str(@AcntPartNo)) + ') = 1 '
	
	--=== SELECT ================================================================
	if (@ShowVisitors=1)
		set @StrVisitor = 'isnull((select top 1 VisitorAcntCode from inv.tblStorageDocsDtl SD where Substring(SD.AcntCode, ' + LTrim(Str(@iPartStart)) + ', ' + LTrim(Str(@iPartLen)) + ') = H.AcntCode order by DocDate Desc, SerialNo Desc),'''')'
	else
		set @StrVisitor = ''''''
		
	SET @StrRemain = '[acc].[funGetAcntRemain] (H.AcntCode, ' + LTrim(Str(@iPartStart)) + ', ' + LTrim(Str(@iPartLen)) + ' )'

	If (@ZeroCycle = 1)
		SET @StrCycle = '1 '
	Else
		SET @StrCycle = 
					'(
						SELECT Count(*) 
						FROM [acc].[tblVoucherDtl] 
						WHERE Substring (AcntCode, ' + LTrim(Str(@iPartStart)) + ', ' + LTrim(Str(@iPartLen)) + ') = H.AcntCode 
					  )'

--=========================


	set @StrAcntWhere=' '

	If  @CampaignID > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'CampaignID') 

	If  @VisitPathID1 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'VisitPathID1') 
		
	If  @VisitPathID2 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'VisitPathID2') 
		
	If  @VisitPathID3 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'VisitPathID3') 
		
	If  @VisitPathID4 > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'VisitPathID4') 
		
	If @SalesRoomClass > 0 
		SET @StrAcntWhere = @StrAcntWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SalesRoomClass, 'SalesRoomClass') 
		
	If  @StrAcntWhere <> ''
		SET @StrAcntWhere = '
		INNER JOIN (Select AcntCode AcntC From acc.tblAcnt Where PartNumber = ' + LTrim(RTrim(Str(@AcntPartNo))) + ' 
		'+  @StrAcntWhere +'
		) a 
		ON H.AcntCode = a.AcntC '
			
	--=========================
	
	SET @StrSelect = '
		SELECT *, pub.GetCodeName(VisitorAcntCode, 1) VisitorAcntName
		FROM
		(
			SELECT	H.*, D.AcntName, D.AcntComment, D.FirstName, D.LastName, D.OrganzationName, D.DistributionPoint, 
					D.Address1, D.Address2, D.GradDesc, C.CustomerKindName,	' + @StrRemain + ' AS DebitRemain,
					' + @StrCycle + ' AS Cycle, L.AreaCode, LD.LocationName, ' + @StrVisitor + ' as VisitorAcntCode,
					VP1.VisitPathName as VisitPathName1,
					VP2.VisitPathName as VisitPathName2,
					VP3.VisitPathName as VisitPathName3,
					VP4.VisitPathName as VisitPathName4					
			FROM acc.tblAcnt H ' + 
			@StrAcntWhere + '
			INNER JOIN acc.tblAcntDtl D ON (H.AcntCode = D.AcntCode) AND (H.PartNumber = D.PartNumber)
			LEFT  JOIN pub.tblLocations L ON H.LocationID = L.LocationID
			LEFT  JOIN pub.tblLocationsDtl LD ON L.LocationID = LD.LocationID AND LD.LanguageID = ' + @LangID + '
			LEFT  JOIN sal.tblCustomerKindsDtl C ON C.CustomerKindID = H.CustomerKindID
			LEFT  JOIN acc.tblVisitPathDtl VP1 on VP1.VisitPathID = H.VisitPathID1 and VP1.PartNumber = 1
			LEFT  JOIN acc.tblVisitPathDtl VP2 on VP2.VisitPathID = H.VisitPathID2 and VP2.PartNumber = 2
			LEFT  JOIN acc.tblVisitPathDtl VP3 on VP3.VisitPathID = H.VisitPathID3 and VP3.PartNumber = 3
			LEFT  JOIN acc.tblVisitPathDtl VP4 on VP4.VisitPathID = H.VisitPathID4 and VP4.PartNumber = 4			
			WHERE  ' + @StrWhere + '
		) M '

	DECLARE @Whr AS NVarChar(1000);
	SET @Whr = ''
	
	If (@ZeroRemain = 0) 
	Begin
		If (@Whr <> '')
		  SET @Whr = @Whr + ' AND '

		SET @Whr = @Whr + '(M.DebitRemain <> 0)'
	End
	
	If (@ZeroCycle = 0) 
	Begin
		If (@Whr <> '')
		  SET @Whr = @Whr + ' AND '

		SET @Whr = @Whr + '(M.Cycle <> 0)'
	End

	If (@Whr <> '')
		SET @StrSelect = @StrSelect + '
		WHERE ' + @Whr

	If (@SortByName = 1)
		SET @StrSelect = @StrSelect + '
		ORDER By AcntName '
	Else
		SET @StrSelect = @StrSelect + '
		ORDER By AcntCode '

	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
END
GO
