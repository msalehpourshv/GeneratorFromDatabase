USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/01/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description	 : اختلاف اسناد انبار با حسابداری
-- ==============================================
Create PROCEDURE [trs].[RptTrs_BalanceAccDiff]
	@ProcessNo		int = 1,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedBank	Int = 0,
	@MaxDiffValue	float = 0, 
	@ValueRanges	NVarChar(1500) = Null, -- فیلتر مقادیر
	@SortFields		NVarChar(100) = Null,
	@RepOptions		NVarChar(20) = '1111', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhereT	NVarChar(max);
DECLARE @StrWhereA	NVarChar(max);
DECLARE @StrWhereB	NVarChar(max);
DECLARE @StrGroup	NVarChar(max);
DECLARE @StrYear	Char(4);

DECLARE @AllRows	Bit; 
DECLARE @Rec1		Bit; 
DECLARE @Rec2		Bit; 
DECLARE @Pay		Bit; 
DECLARE @HasTRS2	Bit; 
DECLARE	@ProcessNo2	int; 

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ----------------------------------------------------------
	IF (@SelectedBank Is Null)	SET @SelectedBank = 0;
	IF (@RepOptions	 Is Null)	SET @RepOptions = '1111';

	SET @Rec1	= Substring(@RepOptions, 1, 1)
	SET @Rec2	= Substring(@RepOptions, 2, 1)
	SET @Pay	= Substring(@RepOptions, 3, 1)
	set @AllRows= Substring(@RepOptions, 4, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @StrYear = LTrim(RIGHT(db_name(), 4))

	SELECT @HasTRS2 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'HasTRS2'	
	set @HasTRS2=isnull(@HasTRS2,0)
	if @ProcessNo=1 
		if @HasTRS2='true'
			set @ProcessNo2=2
			else
			set @ProcessNo2=-1
	if @ProcessNo=2 
		set @ProcessNo2=1
 
	----------------------------------------------------------------------------
	-- Where Clause ------------------------------------------------------------
	SET @StrWhereT = '(1=1)';
	SET @StrWhereA = '(1=1)';
	SET @StrWhereB = '(1=1)';

	If (@DocDateFr Is Not Null)
		SET @StrWhereT = @StrWhereT + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhereT = @StrWhereT + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@DocDateFr Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhereA = @StrWhereA + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@SelectedBank > 0)
		SET @StrWhereB = @StrWhereB + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedBank, 'B.BankCode') 
	----------------------------------------------------------------------------------
	
	create table #tbl_Trs_BalanceAccDiff_Result
	(
		BankCode	varchar(20) collate arabic_cs_as,
		AcntCode1	varchar(20) collate arabic_cs_as,
		AcntCode2	varchar(20) collate arabic_cs_as,
		BalanceTrs	float,
		BalanceAcc	float,
		OtherAcc	float,
		Class		int
	);
	
	set @StrSelect = '
	insert into #tbl_Trs_BalanceAccDiff_Result
	select B.BankCode, B.AcntCode2, B.AcntCode5, 0, 0,0, 1
	from trs.tblOurBanks B
	where (B.BankState=1) and (B.BankCode<>'''') and ' + @StrWhereB

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	set @StrSelect = '
	insert into #tbl_Trs_BalanceAccDiff_Result
	select B.BankCode, B.AcntCode3, '''', 0, 0,0, 2
	from trs.tblOurBanks B
	where (B.BankState=3) and (B.BankCode<>'''') and ' + @StrWhereB
	
	print @StrSelect;
	exec sp_executesql @StrSelect;

	set @StrSelect = '
	insert into #tbl_Trs_BalanceAccDiff_Result
	select B.BankCode, B.AcntCode2, B.AcntCode5, 0, 0,0, 3
	from trs.tblOurBanks B
	where (B.BankState=3) and (B.BankCode<>'''') and ' + @StrWhereB

	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	--drop table tbl_Trs_BalanceAccDiff_Result
	--select *  into tbl_Trs_BalanceAccDiff_Result from #tbl_Trs_BalanceAccDiff_Result
	
	-- receivable docs in cash
	if (@Rec1 = 1)
	begin
		set @StrSelect = '
		update #tbl_Trs_BalanceAccDiff_Result
		set BalanceTrs = 
			isnull((
				SELECT	Sum(D.Amount)
				FROM	trs.tblPayDtl D
							INNER JOIN 
							(
								SELECT	D.VolumeFiscalYear, D.VolumeRowNo, Max(D.EventNo) AS EventNo
								FROM	trs.tblPayDtl AS D
								WHERE	(D.ProcessNo=' + str(@ProcessNo) + ') and (D.PayTypeID IN (6,26)) and ' + @StrWhereT + '
								GROUP BY D.VolumeFiscalYear, D.VolumeRowNo
							 ) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
				WHERE	(D.PayTypeID IN (6,26)) 
					AND (D.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ') 
					AND (D.ProcessID IN (1,10,17,23,40)) 
					and (D.DebitCode = #tbl_Trs_BalanceAccDiff_Result.BankCode) and ' + @StrWhereT + '
			),0)
		where (Class=1)'
		
		print @StrSelect;
		exec sp_executesql @StrSelect;
	end;

	-- receivable docs in bank
	if (@Rec2 = 1)
	begin
		set @StrSelect = '
		update #tbl_Trs_BalanceAccDiff_Result
		set BalanceTrs = 
			isnull((
				SELECT	SUM(D.Amount)
				FROM	trs.tblPayDtl D
							INNER JOIN 
							(
								SELECT D.VolumeFiscalYear, D.VolumeRowNo, Max(D.EventNo) EventNo 
								FROM   trs.tblPayDtl D
								WHERE  (D.ProcessNo=' + str(@ProcessNo) + ') and (D.PayTypeID in (6,26)) and ' + @StrWhereT + '
								GROUP BY D.VolumeFiscalYear, D.VolumeRowNo
							) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
				WHERE	(D.ProcessNo=' + LTRIM(STR(@ProcessNo)) + ') 
					and (D.PayTypeID in (6,26)) 
					and (D.ProcessID in (20,21)) 
					and (D.DebitCode = #tbl_Trs_BalanceAccDiff_Result.BankCode) and ' + @StrWhereT + '
			),0)
		where (Class=2)'
		
		print @StrSelect;
		exec sp_executesql @StrSelect;
	end;

	-- payable docs 
	if (@Pay = 1)
	begin
		set @StrSelect = '
		update #tbl_Trs_BalanceAccDiff_Result
		set BalanceTrs = 
			isnull((
				SELECT	Sum(D.Amount)
				FROM	trs.tblPayDtl D
							INNER JOIN 
							(
								SELECT D.VolumeFiscalYear, D.VolumeRowNo, Max(D.EventNo) EventNo 
								FROM   trs.tblPayDtl D
								WHERE  (D.ProcessNo=' + str(@ProcessNo) + ') and (D.PayTypeID in (8,28)) and ' + @StrWhereT + '
								GROUP BY D.VolumeFiscalYear, D.VolumeRowNo
							) VOL ON D.VolumeFiscalYear = VOL.VolumeFiscalYear AND D.VolumeRowNo = VOL.VolumeRowNo AND D.EventNo = VOL.EventNo
				WHERE	(D.PayTypeID in (8,28)) 
					and (D.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ') 
					and (D.ProcessID in (2,25)) 
					and (D.CreditCode = #tbl_Trs_BalanceAccDiff_Result.BankCode) and ' + @StrWhereT + '
			),0)
		where (Class=3)'
		
		print @StrSelect;
		exec sp_executesql @StrSelect;
	end;
		
	-- ===============================================================================--
		
	set @StrSelect = '
	update #tbl_Trs_BalanceAccDiff_Result
	set BalanceAcc = 
		isnull((
			select Sum(D.Debit - D.Credit)
			from acc.tblVoucherDtl D
			where D.SourceProcessNo=' + LTRIM(STR(@ProcessNo)) + ' and (D.VchKind not in (0,3)) and ((D.AcntCode=#tbl_Trs_BalanceAccDiff_Result.AcntCode1) or (D.AcntCode=#tbl_Trs_BalanceAccDiff_Result.AcntCode2)) and ' + @StrWhereA + '
		),0)
		, OtherAcc = 
		isnull((
			select Sum(D.Debit - D.Credit)
			from acc.tblVoucherDtl D
			where D.SourceProcessNo not in (' + STR(@ProcessNo) + ',' + STR(@ProcessNo2) + ') and (D.VchKind not in (0,3)) and ((D.AcntCode=#tbl_Trs_BalanceAccDiff_Result.AcntCode1) or (D.AcntCode=#tbl_Trs_BalanceAccDiff_Result.AcntCode2)) and ' + @StrWhereA + '
		),0)
	where (Class<>3)
	update #tbl_Trs_BalanceAccDiff_Result
	set BalanceAcc = 
		0-isnull((
			select Sum(D.Debit - D.Credit)
			from acc.tblVoucherDtl D
			where D.SourceProcessNo=' + LTRIM(STR(@ProcessNo)) + ' and (D.VchKind not in (0,3)) and ((D.AcntCode=#tbl_Trs_BalanceAccDiff_Result.AcntCode1) or (D.AcntCode=#tbl_Trs_BalanceAccDiff_Result.AcntCode2)) and ' + @StrWhereA + '
		),0)
		,OtherAcc = 
		0-isnull((
			select Sum(D.Debit - D.Credit)
			from acc.tblVoucherDtl D
			where D.SourceProcessNo not in (' + STR(@ProcessNo) + ',' + STR(@ProcessNo2) + ') and (D.VchKind not in (0,3)) and ((D.AcntCode=#tbl_Trs_BalanceAccDiff_Result.AcntCode1) or (D.AcntCode=#tbl_Trs_BalanceAccDiff_Result.AcntCode2)) and ' + @StrWhereA + '
		),0)
	where (Class=3)'

	print @StrSelect;
	exec sp_executesql @StrSelect;

	------------------------------------------------------------
	
	if (@AllRows = 1)
		select R.*, B.BankName
		from #tbl_Trs_BalanceAccDiff_Result R
			left join trs.tblOurBanksDtl B on B.BankCode = R.BankCode
	else
		select R.*, B.BankName
		from #tbl_Trs_BalanceAccDiff_Result R
			left join trs.tblOurBanksDtl B on B.BankCode = R.BankCode
		where Round(Abs(R.BalanceAcc - R.BalanceTrs), 0) > @MaxDiffValue
End
GO
