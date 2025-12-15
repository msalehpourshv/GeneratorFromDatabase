USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Javad Bayani
-- Create date   : 2007/03/27
-- Viewed By	 : 
-- Last Modified : 1386/08/09
-- Description: نمودار درختی مانده حسابها
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_RemainBalanceTree]

	@AcntOptions	TinyInt = 0,
    -----------------------------------------------------------------------------
    -- 0 = Allow Zero Remain     & Not  Contain Without Cycle Codes            --
    -- 1 = Allow Zero Remain     & Must Contain Without Cycle Codes            --
    -- 2 = Not Allow Zero Remain & Not  Contain Without Cycle Codes            --
    -- 3 = Not Allow Zero Remain & Must Contain Without Cycle Codes (Not Used) --
    -----------------------------------------------------------------------------
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@DocDateTo		char(10) = null,
	@PartsCount		TinyInt = 1, -- Reseved 
	@LayerCount		TinyInt = 9,
	@RepOptions		VarChar(10) = '10000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS
	DECLARE @LangID		Char(1);
	DECLARE @SessionNo	VarChar(10);
	DECLARE @ReportID	VarChar(10);

	DECLARE @StrSelect	NVarChar(max);
	DECLARE @StrWhere	NVarChar(max);
	DECLARE @StrWhereA	NVarChar(max);
	DECLARE @StrHaving	NVarChar(max);

-- Declare Variables ------------
	Declare @Layer11 Tinyint
	Declare @Layer12 Tinyint
	Declare @Layer13 Tinyint
	Declare @Layer14 Tinyint
	Declare @Layer15 Tinyint
	Declare @Layer16 Tinyint
	Declare @Layer17 Tinyint
	Declare @Layer18 Tinyint
	Declare @Layer19 Tinyint
	Declare @Layer1Len Tinyint
	Set @Layer1Len = 0

	Declare @Layer21 Tinyint
	Declare @Layer22 Tinyint
	Declare @Layer23 Tinyint
	Declare @Layer24 Tinyint
	Declare @Layer25 Tinyint
	Declare @Layer26 Tinyint
	Declare @Layer27 Tinyint
	Declare @Layer28 Tinyint
	Declare @Layer29 Tinyint
	Declare @Layer2Len Tinyint
	Set @Layer2Len = 0

	Declare @Layer31 Tinyint
	Declare @Layer32 Tinyint
	Declare @Layer33 Tinyint
	Declare @Layer34 Tinyint
	Declare @Layer35 Tinyint
	Declare @Layer36 Tinyint
	Declare @Layer37 Tinyint
	Declare @Layer38 Tinyint
	Declare @Layer39 Tinyint
	Declare @Layer3Len Tinyint
	Set @Layer3Len = 0

	Declare @Layer41 Tinyint
	Declare @Layer42 Tinyint
	Declare @Layer43 Tinyint
	Declare @Layer44 Tinyint
	Declare @Layer45 Tinyint
	Declare @Layer46 Tinyint
	Declare @Layer47 Tinyint
	Declare @Layer48 Tinyint
	Declare @Layer49 Tinyint
	Declare @Layer4Len Tinyint
	Set @Layer4Len = 0
BEGIN
	SET NoCount On;

	-- Init --------------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1100'

	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-----------------------------------------------------------

	---------------------------------
	-- Create Temporary Tables ------
	Create Table #tbl_RBT_Result
	(
		ParentCode	Char(20) COLLATE Arabic_CS_AS Null,
		AcntCode	Char(20) COLLATE Arabic_CS_AS Not Null,
		PartNo		Tinyint,
		LayerCode	Char(20) COLLATE Arabic_CS_AS Not Null,
		Remain		float Not Null,
		SumDebit	float Not Null,
		SumCredit	float Not Null
	)
	Create Table #tbl_RBT_Remain
	(
		AcntCode	Char(20) COLLATE Arabic_CS_AS Not Null,
		Remain		float Not Null,
		SumDebit	float Not Null,
		SumCredit	float Not Null		
	)

	----------------------------------

	set @StrHaving = ''
	set @StrWhere = '(D.VchKind <> 0)'	
	set @StrWhereA = '(A.PartNumber = 1)'

	If	(@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode') 
	If	(@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode') 
	If	(@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode') 
	If	(@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode') 
	
	If	(@SelectedAcnt1 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'A.AcntCode') 
	If	(@SelectedAcnt2 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'A.AcntCode') 
	If	(@SelectedAcnt3 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'A.AcntCode') 
	If	(@SelectedAcnt4 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'A.AcntCode') 

	SET @StrWhereA = @StrWhereA + ' AND AcntCode NOT IN (SELECT LayerCode FROM #tbl_RBT_Result Where PartNo = 1)'

	If (@DocDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
		
	if (@AcntOptions <> 2)
	set @StrHaving = @StrHaving + '
	Having (Sum(Debit - Credit) <> 0)'
		
	set @StrSelect = '
	insert	into #tbl_RBT_Remain (AcntCode, Remain, SumDebit, SumCredit)
	select	LTrim(RTrim(AcntCode)), isnull(Sum(Debit - Credit),0), isnull(Sum(Debit),0), isnull(Sum(Credit),0)
	from	acc.tblVoucherDtl D
	where	' + @StrWhere + '
	group	By LTrim(RTrim(AcntCode)) ' + @StrHaving
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	--*** ---------------------------------------------------------------- ***
	--*** ------------------- محاسبه مانده قسمت اول  ---------------------- ***
	--*** ---------------------------------------------------------------- ***
	Select	@Layer11 = Layer1, @Layer12 = Layer2, @Layer13 = Layer3, 
				@Layer14 = Layer4, @Layer15 = Layer5, @Layer16 = Layer6, 
				@Layer17 = Layer7, @Layer18 = Layer8, @Layer19 = Layer9
	From		pub.tblCodeLayer 
	Where		PartNumber = 1 AND TableName = 'acc.tblAcnt'

	Set @Layer1Len = @Layer11

	If (@Layer11 > 0) AND (@LayerCount >= 1)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Null, Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group  By Left(AcntCode, @Layer1Len)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order  By Left(AcntCode, @Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer11)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len));
		
			exec sp_executesql @StrSelect;
		End
	End

	Set @Layer1Len = @Layer1Len + @Layer12

	If (@Layer12 > 0) AND (@LayerCount >= 2)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer1Len - @Layer12), Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain),
			   Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer1Len - @Layer12), Left(AcntCode, @Layer1Len)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0)  --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /--
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer12)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len))
		
			exec sp_executesql @StrSelect;
		End
	End

	Set @Layer1Len = @Layer1Len + @Layer13

	If (@Layer13 > 0) AND (@LayerCount >= 3)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer1Len - @Layer13), Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain),
			   Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group By Left(AcntCode,@Layer1Len - @Layer13), Left(AcntCode, @Layer1Len)
		Having   (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode,@Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /--
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer13)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len))
		
			exec sp_executesql @StrSelect;
		End
	End

	Set @Layer1Len = @Layer1Len + @Layer14

	If (@Layer14 > 0) AND (@LayerCount >= 4)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer1Len - @Layer14), Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain),
			   Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer1Len - @Layer14), Left(AcntCode, @Layer1Len)
		Having   (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /--
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer14)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len))
		
			exec sp_executesql @StrSelect;
		End
	End

	Set @Layer1Len = @Layer1Len + @Layer15

	If (@Layer15 > 0) AND (@LayerCount >= 5)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer1Len - @Layer15), Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain),
			   Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer1Len - @Layer15), Left(AcntCode, @Layer1Len)
		Having   (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /--
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer15)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len))
		
			exec sp_executesql @StrSelect;
		End
	End

	Set @Layer1Len = @Layer1Len + @Layer16

	If (@Layer16 > 0) AND (@LayerCount >= 6)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer1Len - @Layer16), Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain),
			   Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer1Len - @Layer16), Left(AcntCode, @Layer1Len)
		Having   (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /--
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer16)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len))
		
			exec sp_executesql @StrSelect;
		End
	End

	Set @Layer1Len = @Layer1Len + @Layer17

	If (@Layer17 > 0) AND (@LayerCount >= 7)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer1Len - @Layer17), Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain),
			   Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer1Len - @Layer17), Left(AcntCode, @Layer1Len)
		Having   (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /--
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer17)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len))
		
			exec sp_executesql @StrSelect;
		End
	End

	Set @Layer1Len = @Layer1Len + @Layer18

	If (@Layer18 > 0) AND (@LayerCount >= 8)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer1Len - @Layer18), Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain),
			   Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer1Len - @Layer18), Left(AcntCode, @Layer1Len)
		Having   (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /--
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer18)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len))
		
			exec sp_executesql @StrSelect;
		End
	End

	Set @Layer1Len = @Layer1Len + @Layer19

	If (@Layer19 > 0) AND (@LayerCount >= 9)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer1Len - @Layer19), Left(AcntCode, @Layer1Len), 1, Left(AcntCode, @Layer1Len) AS LayerCode, Sum(Remain),
			   Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer1Len - @Layer19), Left(AcntCode, @Layer1Len)
		Having   (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer1Len)

		--/ Adding Codes That Have not Any Cycle (If Needed) /--
		If (@AcntOptions = 1)
		Begin
			set @StrSelect = '
			Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
			SELECT Left(A.AcntCode, ' + ltrim(str(@Layer1Len-@Layer19)) + '), A.AcntCode, 1, Left(A.AcntCode, ' + ltrim(str(@Layer1Len)) + ') LayerCode, 0, 0, 0
			FROM   acc.tblAcnt A
			WHERE ' + @StrWhereA + ' and Len(A.AcntCode) = ' + ltrim(str(@Layer1Len))
		
			exec sp_executesql @StrSelect;
		End
	End
	--*** ------------------------------------------------------------- ***
	--*** --------------------- محاسبه مانده قسمت دوم  ----------------- ***
   --*** ------------------------------------------------------------- ***
	Select	@Layer21 = Layer1, @Layer22 = Layer2, @Layer23 = Layer3, 
				@Layer24 = Layer4, @Layer25 = Layer5, @Layer26 = Layer6, 
				@Layer27 = Layer7, @Layer28 = Layer8, @Layer29 = Layer9
	From		pub.tblCodeLayer 
	Where		PartNumber = 2 AND TableName = 'acc.tblAcnt'

	Set @Layer2Len = @Layer1Len + 1    --/ Space /--
	Set @Layer2Len = @Layer2Len + @Layer21

	If (@Layer21 > 0) AND (@LayerCount >= 10)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer2Len - @Layer21 - 1), Left(AcntCode, @Layer2Len), 2, 
             SubString(AcntCode,@Layer1Len + 2, @Layer21) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain As R
		Where (	Select	Count(*) -- ?????????????
					From		#tbl_RBT_Remain As A
					Where		Left(A.AcntCode, @Layer2Len - @Layer21 - 1) = Left(R.AcntCode, @Layer2Len - @Layer21 - 1) AND
								LTrim(RTrim(SubString(A.AcntCode, @Layer1Len + 2, 20))) <> ''
			   ) > 0
		Group By Left(AcntCode, @Layer2Len - @Layer21 - 1), Left(AcntCode, @Layer2Len), 
               SubString(AcntCode,@Layer1Len + 2, @Layer21)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0)    --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End

	Set @Layer2Len = @Layer2Len + @Layer22

	If (@Layer22 > 0) AND (@LayerCount >= 11)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer2Len - @Layer22), Left(AcntCode, @Layer2Len), 2, 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From	 #tbl_RBT_Remain
		-- Where		LTrim(RTrim(SubString(AcntCode, @Layer1Len + 2 + @Layer22, @Layer22))) <> ''  ???????
		Group  By Left(AcntCode, @Layer2Len - @Layer22), Left(AcntCode, @Layer2Len), 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2)
		Having  (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End

	Set @Layer2Len = @Layer2Len + @Layer23

	If (@Layer23 > 0) AND (@LayerCount >= 12)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer2Len - @Layer23), Left(AcntCode, @Layer2Len), 2, 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From	 #tbl_RBT_Remain
		Group  By Left(AcntCode, @Layer2Len - @Layer23), Left(AcntCode, @Layer2Len), 
				 SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2)
		Having  (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End

	Set @Layer2Len = @Layer2Len + @Layer24

	If (@Layer24 > 0) AND (@LayerCount >= 13)
	Begin
		Insert	Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select	Left(AcntCode, @Layer2Len - @Layer24), Left(AcntCode, @Layer2Len), 2,
               SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From		#tbl_RBT_Remain
		Group By Left(AcntCode, @Layer2Len - @Layer24), Left(AcntCode, @Layer2Len), 
               SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2)
		Having  (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End

	Set @Layer2Len = @Layer2Len + @Layer25

	If (@Layer25 > 0) AND (@LayerCount >= 14)
	Begin
		Insert	Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select	Left(AcntCode, @Layer2Len - @Layer25), Left(AcntCode, @Layer2Len), 2, 
               SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From		#tbl_RBT_Remain
		Group By Left(AcntCode, @Layer2Len - @Layer25), Left(AcntCode, @Layer2Len), 
               SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2)
		Having  (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End

	Set @Layer2Len = @Layer2Len + @Layer26

	If (@Layer26 > 0) AND (@LayerCount >= 15)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer2Len - @Layer26), Left(AcntCode, @Layer2Len), 2, 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From	 #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer2Len - @Layer26), Left(AcntCode, @Layer2Len), 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End
   
	Set @Layer2Len = @Layer2Len + @Layer27
	
	If (@Layer27 > 0) AND (@LayerCount >= 16)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer2Len - @Layer27), Left(AcntCode, @Layer2Len), 2, 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From	 #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer2Len - @Layer27), Left(AcntCode, @Layer2Len), 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End

	Set @Layer2Len = @Layer2Len + @Layer28
	
	If (@Layer28 > 0) AND (@LayerCount >= 17)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer2Len - @Layer28), Left(AcntCode, @Layer2Len), 2, 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From	 #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer2Len - @Layer28), Left(AcntCode, @Layer2Len), 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End

	Set @Layer2Len = @Layer2Len + @Layer29
	If (@Layer29 > 0) AND (@LayerCount >= 18)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer2Len - @Layer29), Left(AcntCode, @Layer2Len), 2, 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From	 #tbl_RBT_Remain
		Group By Left(AcntCode, @Layer2Len - @Layer29), Left(AcntCode, @Layer2Len), 
             SubString(AcntCode, @Layer1Len + 2, @Layer2Len - @Layer1Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer2Len)

	End

	--*** ------------------------------------------------------------- ***
	--*** --------------- محاسبه مانده قسمت سوم  ----------------------- ***
   --*** ------------------------------------------------------------- ***
	Select @Layer31 = Layer1, @Layer32 = Layer2, @Layer33 = Layer3, 
          @Layer34 = Layer4, @Layer35 = Layer5, @Layer36 = Layer6, 
          @Layer37 = Layer7, @Layer38 = Layer8, @Layer39 = Layer9
	From  pub.tblCodeLayer 
	Where PartNumber = 3 AND TableName = 'acc.tblAcnt'

	Set @Layer3Len = @Layer2Len + 1  --/ Space /--
	Set @Layer3Len = @Layer3Len + @Layer31

	If (@Layer31 > 0) AND (@LayerCount >= 19)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer3Len - @Layer31), Left(AcntCode, @Layer3Len), 3, 
				 SubString(AcntCode, @Layer2Len + 2, @Layer31) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain As m
        Where (	Select Count(*)
               From #tbl_RBT_Remain As w
               Where Left(m.AcntCode, @Layer3Len - @Layer31 - 1) = Left(w.AcntCode, @Layer3Len - @Layer31 - 1) And
                     LTrim(RTrim(SubString(w.AcntCode, @Layer2Len + 1 + 1, 20))) <> ''
			   ) > 0 
		Group By Left(AcntCode, @Layer3Len - @Layer31), Left(AcntCode, @Layer3Len), 
			    SubString(AcntCode, @Layer2Len + 2, @Layer31)
		Having  (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode,@Layer3Len)

	End

	Set @Layer3Len = @Layer3Len + @Layer32
	
	If (@Layer32 > 0) AND (@LayerCount >= 20)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode,@Layer3Len - @Layer32), Left(AcntCode, @Layer3Len), 3, 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer3Len - @Layer32), Left(AcntCode, @Layer3Len), 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer3Len)

	End

	Set @Layer3Len = @Layer3Len + @Layer33
	
	If (@Layer33 > 0) AND (@LayerCount >= 21)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode,@Layer3Len - @Layer33), Left(AcntCode, @Layer3Len), 3, 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer3Len - @Layer33), Left(AcntCode, @Layer3Len), 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer3Len)

	End

	Set @Layer3Len = @Layer3Len + @Layer34
	
	If (@Layer34 > 0) AND (@LayerCount >= 22)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode,@Layer3Len - @Layer34), Left(AcntCode, @Layer3Len), 3, 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer3Len - @Layer34), Left(AcntCode, @Layer3Len), 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer3Len)

	End

	Set @Layer3Len = @Layer3Len + @Layer35
	
	If (@Layer35 > 0) AND (@LayerCount >= 23)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode,@Layer3Len - @Layer35), Left(AcntCode, @Layer3Len), 3, 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer3Len - @Layer35), Left(AcntCode, @Layer3Len), 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer3Len)

	End

	Set @Layer3Len = @Layer3Len + @Layer36
	
	If (@Layer36 > 0) AND (@LayerCount >= 24)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer3Len - @Layer36), Left(AcntCode, @Layer3Len), 3, 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer3Len - @Layer36), Left(AcntCode, @Layer3Len), 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer3Len)

	End

	Set @Layer3Len = @Layer3Len + @Layer37
	
	If (@Layer37 > 0) AND (@LayerCount >= 25)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer3Len - @Layer37), Left(AcntCode, @Layer3Len), 3, 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer3Len - @Layer37), Left(AcntCode, @Layer3Len), 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer3Len)

	End

	Set @Layer3Len = @Layer3Len + @Layer38
	
	If (@Layer38 > 0) AND (@LayerCount >= 26)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer3Len - @Layer38), Left(AcntCode, @Layer3Len), 3,
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer3Len - @Layer38), Left(AcntCode, @Layer3Len), 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer3Len)

	End

	Set @Layer3Len = @Layer3Len + @Layer39
	
	If (@Layer39 > 0) AND (@LayerCount >= 27)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer3Len - @Layer39), Left(AcntCode, @Layer3Len), 3,
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer3Len - @Layer39), Left(AcntCode, @Layer3Len), 
				 SubString(AcntCode, @Layer2Len + 2, @Layer3Len - @Layer2Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer3Len)

	End

	--*** ------------------------------------------------------------- ***
	--*** --------------- محاسبه مانده قسمت چهارم  ----------------------- ***
   --*** ------------------------------------------------------------- ***
	Select @Layer41 = Layer1, @Layer42 = Layer2, @Layer43 = Layer3, 
          @Layer44 = Layer4, @Layer45 = Layer5, @Layer46 = Layer6, 
          @Layer47 = Layer7, @Layer48 = Layer8, @Layer49 = Layer9
	From  pub.tblCodeLayer 
	Where PartNumber = 4 AND TableName = 'acc.tblAcnt'

	Set @Layer4Len = @Layer3Len + 1  --/ Space /--
	Set @Layer4Len = @Layer4Len + @Layer41

	If (@Layer41 > 0) AND (@LayerCount >= 28)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer41), Left(AcntCode, @Layer4Len), 4, 
				 SubString(AcntCode, @Layer3Len + 2, @Layer41) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From   #tbl_RBT_Remain As m
		Where (	Select Count(*)
               From #tbl_RBT_Remain As w
               Where Left(m.AcntCode, @Layer4Len - @Layer41 - 1) = Left(w.AcntCode, @Layer4Len - @Layer41 - 1) And
                     LTrim(RTrim(SubString(w.AcntCode, @Layer3Len + 2, 20))) <> ''
			   ) > 0 
		Group By Left(AcntCode, @Layer4Len - @Layer41), Left(AcntCode, @Layer4Len), 
            SubString(AcntCode, @Layer3Len + 2, @Layer41)
		Having  (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End

	Set @Layer4Len = @Layer4Len + @Layer42
	
	If (@Layer42 > 0) AND (@LayerCount >= 29)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer42), Left(AcntCode, @Layer4Len), 4, 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer4Len - @Layer42), Left(AcntCode, @Layer4Len), 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End

	Set @Layer4Len = @Layer4Len + @Layer43
	
	If (@Layer43 > 0) AND (@LayerCount >= 30)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer43), Left(AcntCode, @Layer4Len), 4,
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer4Len - @Layer43), Left(AcntCode, @Layer4Len), 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End

	Set @Layer4Len = @Layer4Len + @Layer44
	
	If (@Layer44 > 0) AND (@LayerCount >= 31)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer44), Left(AcntCode, @Layer4Len), 4,
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer4Len - @Layer44), Left(AcntCode, @Layer4Len), 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End

	Set @Layer4Len = @Layer4Len + @Layer45
	
	If (@Layer45 > 0) AND (@LayerCount >= 32)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer45), Left(AcntCode, @Layer4Len), 4,
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer4Len - @Layer45), Left(AcntCode, @Layer4Len), 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End

	Set @Layer4Len = @Layer4Len + @Layer46
	
	If (@Layer46 > 0) AND (@LayerCount >= 33)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer46), Left(AcntCode, @Layer4Len), 4, 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer4Len - @Layer46), Left(AcntCode, @Layer4Len), 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End

	Set @Layer4Len = @Layer4Len + @Layer47
	
	If (@Layer47 > 0) AND (@LayerCount >= 34)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer47), Left(AcntCode, @Layer4Len), 4, 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer4Len - @Layer47), Left(AcntCode, @Layer4Len), 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End

	Set @Layer4Len = @Layer4Len + @Layer48
	
	If (@Layer48 > 0) AND (@LayerCount >= 35)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer48), Left(AcntCode, @Layer4Len), 4,
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer4Len - @Layer48), Left(AcntCode, @Layer4Len), 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End

	Set @Layer4Len = @Layer4Len + @Layer49
	
	If (@Layer49 > 0) AND (@LayerCount >= 36)
	Begin
		Insert Into #tbl_RBT_Result(ParentCode, AcntCode, PartNo, LayerCode, Remain, SumDebit, SumCredit)
		Select Left(AcntCode, @Layer4Len - @Layer49), Left(AcntCode, @Layer4Len), 4,
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2) AS LayerCode, Sum(Remain), Sum(SumDebit), Sum(SumCredit)
		From #tbl_RBT_Remain
      Group By Left(AcntCode, @Layer4Len - @Layer49), Left(AcntCode, @Layer4Len), 
				 SubString(AcntCode, @Layer3Len + 2, @Layer4Len - @Layer3Len - 2)
		Having (@AcntOptions <> 2) OR (Sum(Remain) <> 0) --/ Check Not to Pass Zero Remain if Necessary /--
		Order By Left(AcntCode, @Layer4Len)

	End
----------------------------------------------------------------------------/
	Select	*, pub.GetCodeName(AcntCode, 1) AS AcntName
	From	#tbl_RBT_Result
	Order By AcntCode, ParentCode
    
END
GO
