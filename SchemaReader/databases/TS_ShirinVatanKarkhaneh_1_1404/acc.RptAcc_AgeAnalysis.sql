USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/03/29
-- Viewed By	 : 
-- Last Modified : 1390/08/21
-- Last Modifier : TakroSystem\Zia
-- Description	 : تجزیه سنی
-- ===============================================
Create PROCEDURE [acc].[RptAcc_AgeAnalysis] 
	@PartNo			int = 1, -- شماره بخش
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@VisitorAcnt1	int = 0,
	@VisitorAcnt2	int = 0,
	@VisitorAcnt3	int = 0,
	@VisitorAcnt4	int = 0,
	@SerialNoFr		int = Null,
	@SerialNoTo		int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedAcnt	varchar(20) = Null,
	@ExtraParams	nvarchar(100) = '0@0@0@AcntCode',
	@RepOptions		nvarchar(10) = '01',
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
as
declare @StrSelect	nvarchar(4000);
declare @StrFrom	nvarchar(2000);
declare @StrWhere	nvarchar(4000);
declare @StrWhereV	nvarchar(4000);
declare @StrWhere2	nvarchar(4000);

declare @PartStart	int;
declare @MinLen		int;
declare @PartLen	int;

declare @Part1Start	int;
declare @Part1Len	int;

declare @Part2Start	int;
declare @Part2Len	int;

declare @Part3Start	int;
declare @Part3Len	int;

declare @Part4Start	int;
declare @Part4Len	int;

DECLARE @LimitState1	SmallInt;
DECLARE @LimitState2	SmallInt;
DECLARE @LimitState3	SmallInt;
DECLARE @LimitState4	SmallInt;

declare @AcntCode varchar(1000);
declare @SortBy nvarchar(20);
declare @MontCode char(200);

declare @LangID		char(1);
declare @SessionNo	int;
declare @ReportID	int;
declare @UserID		int;
declare @IsExtended bit;

declare @Acnt		varchar(1000);
declare @Month		char(2);
declare @RemainFr	bigint;
declare @RemainTo	bigint;
declare @Debit		bigint;
declare @Credit		bigint;
declare @UserIsAdmin bit;

declare @MonthCode as char(2);
declare @DebitRemainFr as bigint;
declare @DebitRemainTo as bigint;
declare @DebitSum as bigint;
declare @CreditSum as bigint;
declare @Month00 as bigint;
declare @Month01 as bigint;
declare @Month02 as bigint;
declare @Month03 as bigint;
declare @Month04 as bigint;
declare @Month05 as bigint;
declare @Month06 as bigint;
declare @Month07 as bigint;
declare @Month08 as bigint;
declare @Month09 as bigint;
declare @Month10 as bigint;
declare @Month11 as bigint;
declare @Month12 as bigint;

declare @PrevMonthCode as char(2);
declare @PrevDebitRemainFr as bigint;
declare @PrevDebitRemainTo as bigint;
declare @PrevDebitSum as bigint;
declare @PrevCreditSum as bigint;
declare @PrevMonth00 as bigint;
declare @PrevMonth01 as bigint;
declare @PrevMonth02 as bigint;
declare @PrevMonth03 as bigint;
declare @PrevMonth04 as bigint;
declare @PrevMonth05 as bigint;
declare @PrevMonth06 as bigint;
declare @PrevMonth07 as bigint;
declare @PrevMonth08 as bigint;
declare @PrevMonth09 as bigint;
declare @PrevMonth10 as bigint;
declare @PrevMonth11 as bigint;
declare @PrevMonth12 as bigint;

declare @DebitRemain as bigint;
declare @RemFr as bigint;
declare @RemTo as bigint;
DECLARE @CampaignID	int;

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

	SET @IsExtended	= Substring(@RepOptions, 1, 1);
	SET @UserIsAdmin= Substring(@RepOptions, 2, 1);

	SET @UserID = pub.funSplitString(@ExtraParams, '@', 1);
	SET @RemFr = pub.funSplitString(@ExtraParams, '@', 2);
	SET @RemTo = pub.funSplitString(@ExtraParams, '@', 3);
	SET @SortBy = pub.funSplitString(@ExtraParams, '@', 4);
	SET @CampaignID	= pub.funSplitString(@ExtraParams, '@', 5);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	if (@SortBy = '') set @SortBy = 'AcntCode';
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
		Set @MinLen	= 0
		set @PartLen = @Part1Len
	End
	Else If (@PartNo = 2)
	Begin
		Set @PartStart = @Part2Start
		Set @MinLen	= @Part1Start + @Part1Len - 1
		set @PartLen = @Part2Len
	End
	Else If (@PartNo = 3)
	Begin
		Set @PartStart = @Part3Start
		Set @MinLen	= @Part2Start + @Part2Len - 1
		set @PartLen = @Part3Len
	End
	Else If (@PartNo = 4)
	Begin
		Set @PartStart = @Part4Start
		Set @MinLen	= @Part3Start + @Part3Len - 1
		set @PartLen = @Part4Len
	End

	If (@UserIsAdmin = 1)
	Begin
		SET	@LimitState1 = 1;
		SET	@LimitState2 = 1;
		SET	@LimitState3 = 1;
		SET	@LimitState4 = 1;
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
	---------------------------------------------------------------------------------------------
	------- where clause ------------------------------------------------------------------------
	Set @StrWhere = '(D.VchKind in (1,2))'
	set @StrWhereV = '(1=1)'

	if (@SelectedAcnt is not null)
		Set @StrWhere = @StrWhere + ' AND (Substring(D.AcntCode, ' + LTrim(Str(@PartStart)) + ', ' + LTrim(Str(@PartLen)) + ') = ''' + LTrim(@SelectedAcnt) + ''')'

	If (@PartNo <> 1)
		Set @StrWhere = @StrWhere + ' AND (Len(D.AcntCode) >= ' + LTrim(Str(@MinLen)) + ')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	IF (@VisitorAcnt1 > 0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt1, 'V.VisitorAcntCode')
	IF (@VisitorAcnt2 > 0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt2, 'V.VisitorAcntCode')
	IF (@VisitorAcnt3 > 0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt3, 'V.VisitorAcntCode')
	IF (@VisitorAcnt4 > 0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorAcnt4, 'V.VisitorAcntCode')

	IF (@DocDateTo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')' 

	-- permission --
	If (@LimitState1 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ')) = '''' '
	Else If (@LimitState1 = 0)
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '

	If (@LimitState2 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ')) = '''' '
	Else If (@LimitState2 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '

	If (@LimitState3 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ')) = '''' '
	Else If (@LimitState3 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '

 	If (@LimitState4 = -1)
		SET @StrWhere = @StrWhere + ' AND LTrim(Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ')) = '''' '
	Else If (@LimitState4 = 0) 
		SET @StrWhere = @StrWhere + ' AND acc.funPermitted(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '

	If (@UserIsAdmin <> 1)
	begin
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + '), 1)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + '), 2)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + '), 3)= 1 '
		Set @StrWhere = @StrWhere + '
			AND acc.funPermitted2(' + LTRim(Str(@UserID)) + ', Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + '), 4)= 1 '
	end;

	Set @StrWhere2 = @StrWhere + ' and (D.VchKind = 2) '
	----------------------------------------------------------------------------------------------
	------- select clause ------------------------------------------------------------------------
	create table #tbl_Prim
	(
		AcntCode	varchar(20) collate arabic_cs_as,
		MonthCode	char(2),
		Debit		bigint,
		Credit		bigint
	);

	set @StrFrom = ' (SELECT * FROM acc.tblVoucherDtl WHERE VchKind in (1,2) and SUBSTRING(AcntCode,1,' + LTrim(Str(@Part1Len)) + ') not in (select AcntCode from acc.tblAcnt where (PartNumber=1) and (AcntType in (91,92))) ) D'

	IF (@VisitorAcnt1 > 0) or (@VisitorAcnt2 > 0) or (@VisitorAcnt3 > 0) or (@VisitorAcnt4 > 0)
		set @StrFrom = @StrFrom + ' inner join 
		(
			select distinct CustomerAcntCode
			from sal.tblVisitorsCustomersDtl V
			where ' + @StrWhereV + '
		) V	on V.CustomerAcntCode = D.AcntCode '

	set @AcntCode = 'cast (Substring(D.AcntCode,' + LTrim(Str(@PartStart)) + ',' + LTrim(Str(@PartLen)) + ') as varchar(20))'
	set @MontCode = 'case when (D.VchKind = 2) then ''00'' else Substring(D.DocDate, 6, 2) end'

	Set @StrSelect = '
		insert into #tbl_Prim
		select ' + @AcntCode + ' AcntCode, ' + RTrim(@MontCode) + ' MonthCode, Debit, Credit
		from ' + @StrFrom + '
		where ' + @StrWhere + '
		union all
		select distinct ' + @AcntCode + ' AcntCode, ''01'' MonthCode, 0, 0
		from ' + @StrFrom + '
		where ' + @StrWhere2

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-------------------------------------
	SELECT	T.*, (DebitRemainFr + DebitSum - CreditSum) DebitRemainTo, 
		cast(0 as bigint) as Mon00, -- prev year remain
		cast(0 as bigint) as Mon01, cast(0 as bigint) as Mon02, 
		cast(0 as bigint) as Mon03, cast(0 as bigint) as Mon04, 
		cast(0 as bigint) as Mon05, cast(0 as bigint) as Mon06, 
		cast(0 as bigint) as Mon07, cast(0 as bigint) as Mon08, 
		cast(0 as bigint) as Mon09, cast(0 as bigint) as Mon10, 
		cast(0 as bigint) as Mon11, cast(0 as bigint) as Mon12
	into #tblResult
	FROM
	(
		SELECT	D.AcntCode, MonthCode,
				IsNull((
					select Sum(Debit - Credit) 
					from #tbl_Prim M 
					where (AcntCode = D.AcntCode) and (MonthCode < D.MonthCode)
				), 0) DebitRemainFr,
				IsNull(Sum(D.Debit), 0) DebitSum, IsNull(Sum(D.Credit), 0) CreditSum
		FROM	#tbl_Prim D
		GROUP BY AcntCode, MonthCode
	) T
	ORDER BY AcntCode, MonthCode 

	-- transfer remain of prev year into month 1
	update #tblResult
	set #tblResult.DebitRemainFr = (N.DebitSum - N.CreditSum)
	from (select * from #tblResult where MonthCode = '00') N
	where #tblResult.AcntCode = N.AcntCode and #tblResult.MonthCode = '01' 

	-- delete remain of prev year records
	delete from #tblResult
	where (MonthCode = '00')

	-- create last result record for every AcntCode
	insert into #tblResult
	select 	distinct AcntCode, '00',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	from #tblResult

	----------------------------------------------------------------------------------------------
	declare crs_AcntCode cursor for
		select distinct AcntCode 
		from #tblResult

	open crs_AcntCode 
	fetch next from crs_AcntCode into @AcntCode
	
	while (@@fetch_status = 0)
	begin
		-- clear creditors from list
		select top 1 @DebitRemain = DebitRemainTo
		from #tblResult
		where (AcntCode = @AcntCode) and (MonthCode <> '00')
		order by MonthCode desc

		if (@DebitRemain <= 0)
		begin
			delete from #tblResult
			where (AcntCode = @AcntCode)
			goto _NEXT
		end

		-- init previous row info
		select @PrevMonthCode='00',@PrevDebitRemainFr=0,@PrevDebitRemainTo=0,@PrevDebitSum=0,@PrevCreditSum=0,@PrevMonth00=0, @PrevMonth01=0, @PrevMonth02=0, @PrevMonth03=0, @PrevMonth04=0,@PrevMonth05=0,@PrevMonth06=0,@PrevMonth07=0,@PrevMonth08=0,@PrevMonth09=0,@PrevMonth10=0,@PrevMonth11=0,@PrevMonth12=0

		declare crs_AcntRecords cursor dynamic for
			select *
			from #tblResult
			where (AcntCode = @AcntCode) and (MonthCode <> '00')
			order by MonthCode

		open crs_AcntRecords
		fetch next from crs_AcntRecords into @AcntCode, @MonthCode, @DebitRemainFr, @DebitSum, @CreditSum, @DebitRemainTo, @Month00,  @Month01, @Month02, @Month03, @Month04, @Month05, @Month06, @Month07, @Month08, @Month09, @Month10, @Month11, @Month12

		while (@@fetch_status = 0)
		begin
			-- previous debit for first month
			if (@MonthCode = '01')
				set @PrevMonth00 = @DebitRemainFr

			if (@DebitRemainFr < 0) and (@MonthCode > '01')
				set @CreditSum = @CreditSum - @DebitRemainFr
						 
			-- remain of previous year --
			if (@CreditSum > @PrevMonth00)
			begin
				set @Month00 = 0
				set @CreditSum = @CreditSum - @PrevMonth00
			end
			else
			begin
				set @Month00 = @PrevMonth00 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 1 --
			if (@CreditSum > @PrevMonth01)
			begin
				set @Month01 = 0
				set @CreditSum = @CreditSum - @PrevMonth01
			end
			else
			begin
				set @Month01 = @PrevMonth01 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 2 --
			if (@CreditSum > @PrevMonth02)
			begin
				set @Month02 = 0
				set @CreditSum = @CreditSum - @PrevMonth02
			end
			else
			begin
				set @Month02 = @PrevMonth02 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 3 --
			if (@CreditSum > @PrevMonth03)
			begin
				set @Month03 = 0
				set @CreditSum = @CreditSum - @PrevMonth03
			end
			else
			begin
				set @Month03 = @PrevMonth03 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 4 --
			if (@CreditSum > @PrevMonth04)
			begin
				set @Month04 = 0
				set @CreditSum = @CreditSum - @PrevMonth04
			end
			else
			begin
				set @Month04 = @PrevMonth04 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 5 --
			if (@CreditSum > @PrevMonth05)
			begin
				set @Month05 = 0
				set @CreditSum = @CreditSum - @PrevMonth05
			end
			else
			begin
				set @Month05 = @PrevMonth05 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 6 --
			if (@CreditSum > @PrevMonth06)
			begin
				set @Month06 = 0
				set @CreditSum = @CreditSum - @PrevMonth06
			end
			else
			begin
				set @Month06 = @PrevMonth06 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 7 --
			if (@CreditSum > @PrevMonth07)
			begin
				set @Month07 = 0
				set @CreditSum = @CreditSum - @PrevMonth07
			end
			else
			begin
				set @Month07 = @PrevMonth07 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 8 --
			if (@CreditSum > @PrevMonth08)
			begin
				set @Month08 = 0
				set @CreditSum = @CreditSum - @PrevMonth08
			end
			else
			begin
				set @Month08 = @PrevMonth08 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 9 --
			if (@CreditSum > @PrevMonth09)
			begin
				set @Month09 = 0
				set @CreditSum = @CreditSum - @PrevMonth09
			end
			else
			begin
				set @Month09 = @PrevMonth09 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 10 --
			if (@CreditSum > @PrevMonth10)
			begin
				set @Month10 = 0
				set @CreditSum = @CreditSum - @PrevMonth10
			end
			else
			begin
				set @Month10 = @PrevMonth10 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 11 --
			if (@CreditSum > @PrevMonth11)
			begin
				set @Month11 = 0
				set @CreditSum = @CreditSum - @PrevMonth11
			end
			else
			begin
				set @Month11 = @PrevMonth11 - @CreditSum
				set @CreditSum = 0
			end

			-- remain of month 12 --
			if (@CreditSum > @PrevMonth12)
			begin
				set @Month12 = 0
				set @CreditSum = @CreditSum - @PrevMonth12
			end
			else
			begin
				set @Month12 = @PrevMonth12 - @CreditSum
				set @CreditSum = 0
			end
			-- remain of current month --
			if (@CreditSum > @DebitSum)
			begin
				if @MonthCode = '01' set @Month01 = 0;
				if @MonthCode = '02' set @Month02 = 0;
				if @MonthCode = '03' set @Month03 = 0;
				if @MonthCode = '04' set @Month04 = 0;
				if @MonthCode = '05' set @Month05 = 0;
				if @MonthCode = '06' set @Month06 = 0;
				if @MonthCode = '07' set @Month07 = 0;
				if @MonthCode = '08' set @Month08 = 0;
				if @MonthCode = '09' set @Month09 = 0;
				if @MonthCode = '10' set @Month10 = 0;
				if @MonthCode = '11' set @Month11 = 0;
				if @MonthCode = '12' set @Month12 = 0;
				set @CreditSum = @CreditSum - @DebitSum;
			end
			else
			begin
				if @MonthCode = '01' set @Month01 = @DebitSum - @CreditSum;
				if @MonthCode = '02' set @Month02 = @DebitSum - @CreditSum;
				if @MonthCode = '03' set @Month03 = @DebitSum - @CreditSum;
				if @MonthCode = '04' set @Month04 = @DebitSum - @CreditSum;
				if @MonthCode = '05' set @Month05 = @DebitSum - @CreditSum;
				if @MonthCode = '06' set @Month06 = @DebitSum - @CreditSum;
				if @MonthCode = '07' set @Month07 = @DebitSum - @CreditSum;
				if @MonthCode = '08' set @Month08 = @DebitSum - @CreditSum;
				if @MonthCode = '09' set @Month09 = @DebitSum - @CreditSum;
				if @MonthCode = '10' set @Month10 = @DebitSum - @CreditSum;
				if @MonthCode = '11' set @Month11 = @DebitSum - @CreditSum;
				if @MonthCode = '12' set @Month12 = @DebitSum - @CreditSum;
				set @CreditSum = 0;
			end

			-- update result values
			update #tblResult
			set Mon00 = @Month00, Mon01 = @Month01, Mon02 = @Month02, Mon03 = @Month03, Mon04 = @Month04, Mon05 = @Month05, Mon06 = @Month06, Mon07 = @Month07, Mon08 = @Month08, Mon09 = @Month09, Mon10= @Month10, Mon11 = @Month11, Mon12 = @Month12
			where AcntCode = @AcntCode and MonthCode = @MonthCode

			-- last state of an AcntCode
			if (@Month00<>0)or(@Month01<>0)or(@Month02<>0)or(@Month03<>0)or(@Month04<>0)or(@Month05<>0)or(@Month06<>0)or(@Month07<>0)or(@Month08<>0)or(@Month09<>0)or(@Month10<>0)or(@Month11<>0)or(@Month12<>0) 
				update #tblResult
				set Mon00 = @Month00, Mon01 = @Month01, Mon02 = @Month02, Mon03 = @Month03, Mon04 = @Month04, Mon05 = @Month05, Mon06 = @Month06, Mon07 = @Month07, Mon08 = @Month08, Mon09 = @Month09, Mon10= @Month10, Mon11 = @Month11, Mon12 = @Month12
				where AcntCode = @AcntCode and MonthCode = '00'

			-- copy current row info to previous row info
			select @PrevDebitRemainFr = @DebitRemainFr, @PrevDebitRemainTo = @DebitRemainTo, @PrevMonthCode	= @MonthCode, @PrevDebitSum	= @DebitSum, @PrevCreditSum	= @CreditSum, @PrevMonth00 = @Month00, @PrevMonth01 = @Month01, @PrevMonth02 = @Month02, @PrevMonth03 = @Month03, @PrevMonth04 = @Month04, @PrevMonth05 = @Month05, @PrevMonth06 = @Month06, @PrevMonth07 = @Month07, @PrevMonth08 = @Month08, @PrevMonth09 = @Month09, @PrevMonth10 = @Month10, @PrevMonth11 = @Month11, @PrevMonth12 = @Month12

			fetch next  from crs_AcntRecords into @AcntCode, @MonthCode, @DebitRemainFr, @DebitSum, @CreditSum, @DebitRemainTo, @Month00,  @Month01, @Month02, @Month03, @Month04, @Month05, @Month06, @Month07, @Month08, @Month09, @Month10, @Month11, @Month12
		end

		close crs_AcntRecords;
		deallocate crs_AcntRecords;

	_NEXT:
		fetch next from crs_AcntCode into @AcntCode
	end

	close	crs_AcntCode;
	deallocate crs_AcntCode;

	------- run ----------------------------------------------------------------------------------
	declare @whr nvarchar(2000);
	set @whr = '(MonthCode = ''00'')';

	if (@RemFr <> '') and (@RemFr <> '0') 
		set @whr = @whr + ' and (Mon00+Mon01+Mon02+Mon03+Mon04+Mon05+Mon06+Mon07+Mon08+Mon09+Mon10+Mon11+Mon12 >= ' + ltrim(str(@RemFr,20)) + ')';

	if (@RemTo <> '') and (@RemTo <> '0') 
		set @whr = @whr + ' and (Mon00+Mon01+Mon02+Mon03+Mon04+Mon05+Mon06+Mon07+Mon08+Mon09+Mon10+Mon11+Mon12 <= ' + ltrim(str(@RemTo,20)) + ')';

	SET @StrFrom =  ''

	If  @CampaignID > 0 
		SET @StrFrom =  ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CampaignID, 'AC.CampaignID') 

	set @StrSelect = '
	select R.*, A.AcntName, pub.funGetTypeText(10, cast(R.MonthCode as int), 1) as MonthName,
		F.Tel,F.OtherTels,F.EconomicalCode,F.AcntComment,F.Address1,F.Address2,F.InitialGrad,
		F.CustomerFirstName,F.CustomerLastName,F.ZipCode,F.CompanyRegisterNo,F.NationalIDNumber,
		F.LocationID,F.Mobile,F.OrganzationName,F.MaxDebitRemain,F.MaxReceivableRemain,F.DistributionPoint,
		F.AsnafID,F.Sequence,F.Fax,F.Email,F.MemberDate ,AC.CampaignID
	from #tblResult R
			inner join acc.tblAcnt  AC on AC.AcntCode = R.AcntCode and AC.PartNumber = ' + ltrim(str(@PartNo)) + '
			inner join acc.tblAcntDtl A on A.AcntCode = R.AcntCode and A.PartNumber = ' + ltrim(str(@PartNo)) + '
			OUTER APPLY acc.funGetCodeInfo_RemainCalculation(R.AcntCode,' + LTRIM(STR(@PartNo)) + ') AS F 
	where ' + @whr +@StrFrom+ '
	order by ' + @SortBy

	print @StrSelect;
	exec sp_executesql @StrSelect;
	----------------------------------------------------------------------------------------------
End
GO
