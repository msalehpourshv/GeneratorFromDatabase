USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/10/25
-- Viewed By	 : 
-- Last Modified : 1389/11/13
-- Last Modifier : TakroSystem\Zia
-- Description	 : همه مشتریان و ویزیتورها
-- ===============================================
CREATE PROCEDURE [sal].[RptSale_CustomerVisitor] 
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@VisitorAcnt1	int = 0,
	@VisitorAcnt2	int = 0,
	@VisitorAcnt3	int = 0,
	@VisitorAcnt4	int = 0,
	@ExtraParams	nvarchar(100) = '2',
	@RepOptions		nvarchar(10) = '01',
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
as
declare @StrSelect	nvarchar(4000);
declare @StrFrom	nvarchar(4000);
declare @StrWhere	nvarchar(4000);

declare @LangID		char(1);
declare @SessionNo	int;
declare @ReportID	int;

declare @PartNo		char(1);

declare @PartStart	int;
declare @PartLen	int;

declare @Part1Start	int;
declare @Part1Len	int;

declare @Part2Start	int;
declare @Part2Len	int;

declare @Part3Start	int;
declare @Part3Len	int;

declare @Part4Start	int;
declare @Part4Len	int;
declare @AcntCode	varchar(50);
Begin
	-- ============================ S T A R T =====================================================

	-- Init ---------------------------------------------------------------------------------------
	SET NOCOUNT ON;

	IF (@RepOptions	Is Null)	SET @RepOptions = '01';
	IF (@RepOptions	= '')		SET @RepOptions = '01';

	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	IF (@VisitorAcnt1	Is Null)	SET @VisitorAcnt1 = 0;
	IF (@VisitorAcnt2	Is Null)	SET @VisitorAcnt2 = 0;
	IF (@VisitorAcnt3	Is Null)	SET @VisitorAcnt3 = 0;
	IF (@VisitorAcnt4	Is Null)	SET @VisitorAcnt4 = 0;

--	SET @IsExtended	= Substring(@RepOptions, 1, 1);
	SET @PartNo = pub.funSplitString(@ExtraParams, '@', 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-----------------------------------------------------------------------------------------------
	-------- set layers len -----------------------------------------------------------------------
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

	If (@PartNo = 1)
	Begin
		Set @PartStart = @Part1Start
		set @PartLen = @Part1Len
		set @AcntCode = 'A.AcntCode'
	End
	Else If (@PartNo = 2)
	Begin
		Set @PartStart = @Part2Start
		set @PartLen = @Part2Len
		set @AcntCode = 'space(' + ltrim(str(@Part1Len+1)) + ') + A.AcntCode'
	End
	Else If (@PartNo = 3)
	Begin
		Set @PartStart = @Part3Start
		set @PartLen = @Part3Len
		set @AcntCode = 'space(' + ltrim(str(@Part1Len+@Part2Len+1+1)) + ') + A.AcntCode'
	End
	Else If (@PartNo = 4)
	Begin
		Set @PartStart = @Part4Start
		set @PartLen = @Part4Len
		set @AcntCode = 'space(' + ltrim(str(@Part1Len+@Part2Len+@Part3Len+1+1+1)) + ') + A.AcntCode'
	End
	---------------------------------------------------------------------------------------------
	------- where clause ------------------------------------------------------------------------
	Set @StrWhere = '(A.PartNumber = ' + @PartNo + ')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, @AcntCode)
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, @AcntCode)
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, @AcntCode)
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, @AcntCode)

	IF (@VisitorAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt1, 'V.VisitorAcntCode')
	IF (@VisitorAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt2, 'V.VisitorAcntCode')
	IF (@VisitorAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt3, 'V.VisitorAcntCode')
	IF (@VisitorAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt4, 'V.VisitorAcntCode')
	----------------------------------------------------------------------------------------------
	------- select clause ------------------------------------------------------------------------
	Set @StrSelect = '
	select T.*, pub.GetCodeName(VisitorAcntCode, 1) VisitorAcntName
	from
	(
		select A.AcntCode, V.VisitorAcntCode, B.AcntName
		from acc.tblAcnt A
				inner join acc.tblAcntDtl B on B.AcntCode = A.AcntCode and B.PartNumber = A.PartNumber
				left join sal.tblVisitorsCustomersDtl V on substring(V.CustomerAcntCode, ' + LTrim(Str(@PartStart)) + ', ' + LTrim(Str(@PartLen)) + ') = A.AcntCode
		where ' + @StrWhere + '
	) T '

	print @StrSelect;
	exec sp_executesql @StrSelect;
	----------------------------------------------------------------------------------------------
End
GO
