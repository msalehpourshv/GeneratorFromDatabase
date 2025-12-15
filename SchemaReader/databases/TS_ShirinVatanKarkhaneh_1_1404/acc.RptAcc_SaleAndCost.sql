USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
---- =========== TS-QC:UPDATED ====================
---- Author		 : TakroSystem\Hadi Sadeghi
---- Create date   : 1400/06/13
---- Viewed By	 : 
---- Last Modified : 
---- Last Modifier : 
---- Description   : 
---- =============================================
-- [acc].[RptAcc_SaleAndCost] '1400/01','1400/02',0,0,0,0,'000','1@1@1@0@1'
Create  PROCEDURE [acc].[RptAcc_SaleAndCost]
	@Date1				VarChar(10)=  '',
	@Date2				VarChar(10) = '',
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@RepOptions			VarChar(100) = '110', -- bit array options
	@RepInfo			NVarChar(100) = Null

WITH ENCRYPTION
AS
	DECLARE	@LangID				char(1);
	DECLARE	@SessionNo			int; 
	DECLARE	@ReportID			int; 
	DECLARE	@UserID				Int;
	DECLARE @UserIsAdmin		Bit;
	DECLARE @StrSelect			NVarChar(MAX);
	DECLARE @StrWhere			NVarChar(MAX);
	DECLARE @StrWhereP			NVarChar(MAX);
	DECLARE @StrWhereSale		NVarChar(MAX);
	DECLARE @StrWhereDiscount	NVarChar(MAX);
	DECLARE @LenAcntlayer1		tinyint=0
	DECLARE @LimitState1		SmallInt;
	DECLARE @LimitState2		SmallInt;
	DECLARE @LimitState3		SmallInt;
	DECLARE @LimitState4		SmallInt;

	Declare @Part1Start	TinyInt;
	Declare @Part1Len	TinyInt;

	Declare @Part2Start	TinyInt;
	Declare @Part2Len	TinyInt;

	Declare @Part3Start	TinyInt;
	Declare @Part3Len	TinyInt;

	Declare @Part4Start	TinyInt;
	Declare @Part4Len	TinyInt;
BEGIN -- ============================ S T A R T =====================================================
	SELECT	@LenAcntlayer1 = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);
	SET @StrWhere = ''
	SET @StrWhereP = ''
	SET @StrWhereSale = ''
	SET @StrWhereDiscount = ''

	declare @SaleAcntCodeInSaleTypes VARCHAR(7)='False'
	SELECT @SaleAcntCodeInSaleTypes = SettingValue	 FROM pub.tblSettings WHERE SettingKey = 'SaleAcntCodeInSaleTypes' 

	-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	Create Table #tbl_result
	(
		AcntCode				varchar(20),
		AcntCode1				varchar(20),
		AcntCode2				varchar(20),
		AcntCode3				varchar(20),
		AcntCode4				varchar(20),
		AcntName1			    NVARCHAR(1000),
		AcntName2			    NVARCHAR(1000),
		AcntName3			    NVARCHAR(1000),
		AcntName4			    NVARCHAR(1000),
		Debit1					BIGINT,
		Credit1					BIGINT,
		Percent1				float,
		Debit2					BIGINT,
		Credit2					BIGINT,
		Percent2				float
	);


	If @UserIsAdmin = 1
	Begin
		SET	@LimitState1 = 1
		SET	@LimitState2 = 1
		SET	@LimitState3 = 1
		SET	@LimitState4 = 1
	End
	Else
	Begin
		SELECT	TOP 1 @LimitState1 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 1)

		SET @LimitState1 = IsNull(@LimitState1, -1);

		SELECT	TOP 1 @LimitState2 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 2)

		SET @LimitState2 = IsNull(@LimitState2, -1);

		SELECT	TOP 1 @LimitState3 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 3)

		SET @LimitState3 = IsNull(@LimitState3, -1);

		SELECT	TOP 1 @LimitState4 = AccessAllCode
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 4)

		SET @LimitState4 = IsNull(@LimitState4, -1);
	End

	If (@LimitState1 = -1)
		Set @StrWhereP = @StrWhereP + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ')) = '''' '
	Else If (@LimitState1 = 0)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '

	If (@LimitState2 = -1)
		Set @StrWhereP = @StrWhereP + '	AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ')) = '''' '
	Else If (@LimitState2 = 0) 
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '

	If (@LimitState3 = -1)
		Set @StrWhereP = @StrWhereP + '	AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ')) = '''' '
	Else If (@LimitState3 = 0) 
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '

	If (@LimitState4 = -1)
		Set @StrWhereP = @StrWhereP + '	AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ')) = '''' '
	Else If (@LimitState4 = 0) 
		Set @StrWhereP = @StrWhereP + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '
	If (@UserIsAdmin <> 1)
		Set @StrWhereP = @StrWhereP + '	AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '


	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	SET @StrWhereSale =
		' AND ((''' + @SaleAcntCodeInSaleTypes+ ''' =''False'' AND 
		((SELECT COUNT(*) FROM inv.tblStores a WHERE LEN(SaleAcntCode)>0 AND a.SaleAcntCode=LEFT(D.AcntCode,LEN(a.SaleAcntCode)))>0
		OR
		(SELECT COUNT(*) FROM inv.tblStores a WHERE LEN(SaleReturnAcntCode)>0 AND  a.SaleAcntCode=LEFT(D.AcntCode,LEN(a.SaleReturnAcntCode)))>0
		))
		OR 
		 (''' + @SaleAcntCodeInSaleTypes+ ''' =''True'' AND 
		((SELECT COUNT(*) FROM sal.tblSaleTypes a WHERE LEN(SaleAcntCode)>0 AND a.SaleAcntCode=LEFT(D.AcntCode,LEN(a.SaleAcntCode)))>0
		OR
		(SELECT COUNT(*) FROM sal.tblSaleTypes a WHERE LEN(SaleReturnAcntCode)>0 AND  a.SaleAcntCode=LEFT(D.AcntCode,LEN(a.SaleReturnAcntCode)))>0
		))) ' +  @StrWhere + @StrWhereP


	SET @StrWhereDiscount =
		' AND ((''' + @SaleAcntCodeInSaleTypes+ ''' =''False'' AND 
		((SELECT COUNT(*) FROM inv.tblStores a WHERE LEN(SaleDiscountAcntCode)>0 AND a.SaleDiscountAcntCode=LEFT(D.AcntCode,LEN(a.SaleAcntCode)))>0
		OR
		(SELECT COUNT(*) FROM inv.tblStores a WHERE LEN(AfterSaleDiscountAcntCode)>0 AND  a.AfterSaleDiscountAcntCode=LEFT(D.AcntCode,LEN(a.SaleReturnAcntCode)))>0
		))
		OR 
		 (''' + @SaleAcntCodeInSaleTypes+ ''' =''True'' AND 
		((SELECT COUNT(*) FROM sal.tblSaleTypes a WHERE LEN(SaleDiscountAcntCode)>0 AND a.SaleDiscountAcntCode=LEFT(D.AcntCode,LEN(a.SaleAcntCode)))>0
		OR
		(SELECT COUNT(*) FROM sal.tblSaleTypes a WHERE LEN(AfterSaleDiscountAcntCode)>0 AND  a.AfterSaleDiscountAcntCode=LEFT(D.AcntCode,LEN(a.SaleReturnAcntCode)))>0
		))) ' +  @StrWhere  + @StrWhereP

	SET @StrSelect = '
	declare @TotalSaleM1 float,@TotalSaleM2 float, @TotalSaleDiscM1 float,@TotalSaleDiscM2 float
	select @TotalSaleM1 =SUM(Credit-Debit)  
	from acc.tblVoucherDtl D
	where LEFT(DocDate,7)=''' + @Date1 + '''' +  @StrWhereSale + ' ;

	select @TotalSaleM2 =SUM(Credit-Debit)  
	from acc.tblVoucherDtl D
	where LEFT(DocDate,7)=''' + @Date2 + '''' +  @StrWhereSale + ' ;

	select @TotalSaleDiscM1 =SUM(Debit-Credit)  
	from acc.tblVoucherDtl D
	where LEFT(DocDate,7)=''' + @Date1 + '''' +  @StrWhereDiscount + ' ;

	select @TotalSaleDiscM2 =SUM(Debit-Credit)  
	from acc.tblVoucherDtl D
	where LEFT(DocDate,7)=''' + @Date2 + '''' +  @StrWhereDiscount + ' ;

	IF @TotalSaleM1=0
		SET @TotalSaleM1 = 0.0001
	IF @TotalSaleM2=0
		SET @TotalSaleM2 = 0.0001

	INSERT INTO #tbl_result
	SELECT ''0000000000'','''','''','''','''',N''(فروش-برگشت از فروش)'','''','''','''',ROUND(@TotalSaleM1,2),0,0,ROUND(@TotalSaleM2,2),0,0
	UNION
	SELECT ''0000000001'','''','''','''','''',N''(تخفیفات - برگشت تخفیفات)'','''','''','''',0,@TotalSaleDiscM1,ROUND(@TotalSaleDiscM1*100/@TotalSaleM1,2),0,@TotalSaleDiscM2,ROUND(@TotalSaleDiscM2*100/@TotalSaleM2,2)
	UNION
		SELECT CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END AcntCode,
		Substring(CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ') AcntCode1,
		Substring(CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ') AcntCode2,
		Substring(CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ') AcntCode3,
		Substring(CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ') AcntCode4,
	[acc].[funGetAcntName](Substring(CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '),1,1) AcntName1,
	[acc].[funGetAcntName](Substring(CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '),2,1) AcntName2,
	[acc].[funGetAcntName](Substring(CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '),3,1) AcntName3,
	[acc].[funGetAcntName](Substring(CASE WHEN a.AcntCode IS NULL THEN b.AcntCode ELSE a.AcntCode END, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '),4,1) AcntName4,
	0,ISNULL(Amount1,0),ISNULL(Percent1,0),
	0,ISNULL(Amount2,0),ISNULL(Percent2,0)
	FROM 
	(select AcntCode, SUM(Debit-Credit) Amount1,ROUND(SUM(Debit-Credit) * 100/@TotalSaleM1,2) Percent1 
	from acc.tblVoucherDtl D
	where LEFT(AcntCode,' + STR(@LenAcntlayer1) + ') IN
		(SELECT AcntCode FROM acc.tblAcnt WHERE AcntType in (61,62) AND PartNumber=1 and LEN(AcntCode)=' + STR(@LenAcntlayer1) + ' )
	AND LEFT(DocDate,7)=''' + @Date1 + '''' +  @StrWhere + @StrWhereP + '
	group by AcntCode ) a
	FULL OUTER JOIN 
	(select AcntCode, SUM(Debit-Credit) Amount2,ROUND(SUM(Debit-Credit) * 100/@TotalSaleM2,2) Percent2 
	from acc.tblVoucherDtl D
	where LEFT(AcntCode,' + STR(@LenAcntlayer1) + ') IN
		(SELECT AcntCode FROM acc.tblAcnt WHERE AcntType in (61,62) AND PartNumber=1 and LEN(AcntCode)=' + STR(@LenAcntlayer1) + ' )
	AND LEFT(DocDate,7)=''' + @Date2 + '''' +  @StrWhere + @StrWhereP +  '
	group by AcntCode 
	)b ON a.AcntCode=b.AcntCode

	'

	PRINT @StrSelect
	Exec sp_executesql @StrSelect;

	SELECT * from #tbl_result order by AcntCode


END
GO
