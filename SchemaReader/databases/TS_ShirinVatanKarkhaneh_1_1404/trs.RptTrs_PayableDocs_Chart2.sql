USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/04/18
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Description	 : <Payable Documents Chart>
-- ----------------------------------------------
-- نمودار اسناد پرداختنی
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_PayableDocs_Chart2]
	@ProcessNo			int = 1,
	@CurrentYear		Char(4), -- سال مالی جاری چهار رقمی
	@CurrentMonth		Char(2),    /* شماره ماه */
	@IncludeUnReceipt	Bit = 1, -- شامل وصول نشده ها
	@IncludeReceipt		Bit = 0, -- شامل وصول شده ها
	@IncludeReturned	Bit = 0, -- شامل برگشتی ها
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2			Int = 0,
	@DebitCode3			Int = 0,
	@DebitCode4			Int = 0,
	@CreditCode1		Int = 0, -- بستانکار
	@CreditCode2		Int = 0,
	@CreditCode3		Int = 0,
	@CreditCode4		Int = 0,
	@RepInfo			NVarChar(100) = Null
WITH ENCRYPTION
As
DECLARE @StrSelect		NVarChar(max);
DECLARE @StrSelectSub	NVarChar(max);
DECLARE @StrSelectPrm 	NVarChar(max);

DECLARE @LangID			Char(1)
DECLARE @SessionNo		VarChar(10)
DECLARE @ReportID		VarChar(10)
Begin   

	SET NOCOUNT ON;

	-- init Variables --
	If (@RepInfo	Is Null)		SET @RepInfo    = '1@1@1'

	IF (@DebitCode1 Is Null)		SET @DebitCode1 = 0
	IF (@DebitCode2 Is Null)		SET @DebitCode2 = 0
	IF (@DebitCode3 Is Null)		SET @DebitCode3 = 0
	IF (@DebitCode4 Is Null)		SET @DebitCode4 = 0

	IF (@CreditCode1 Is Null)		SET @CreditCode1 = 0
	IF (@CreditCode2 Is Null)		SET @CreditCode2 = 0
	IF (@CreditCode3 Is Null)		SET @CreditCode3 = 0
	IF (@CreditCode4 Is Null)		SET @CreditCode4 = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @StrSelectSub	= ''

	-- Set Primary Query to Create Days --
	Set @StrSelectPrm = '
	Declare @idx2 Int
	Create Table #tblDays(Days Char(10) Collate Arabic_CS_AS)
	
	-- Fill Table Variale With Year Days --
	Set @idx2 = 1

	While (@idx2 <= 31)
	Begin
		INSERT INTO #tblDays	
		VALUES (Case When Len(LTrim(Str(@idx2))) < 2 Then ''0'' Else '''' End + LTrim(Str(@idx2))) 
		Set @idx2 = @idx2 + 1
	End
	'
	
	-- ==== Create Sub String Query Section ==============================
	-- UnReceipt Docs Included 
	If @IncludeUnReceipt = 1 
		Set @StrSelectSub = '	
			SELECT	VolumeFiscalYear, VolumeRowNo
			FROM	trs.tblPayDtl
			WHERE	ProcessID IN (2,25) and ProcessNo = ' + LTRIM(STR(@ProcessNo)) + '
			EXCEPT  
			SELECT	VolumeFiscalYear, VolumeRowNo
			FROM	trs.tblPayDtl
			WHERE	ProcessID IN (27,28) and ProcessNo = ' + LTRIM(STR(@ProcessNo)) + '
			EXCEPT  
			SELECT	VolumeFiscalYear, VolumeRowNo
			FROM	trs.tblPayDtl
			WHERE	ProcessID IN (2,25) and ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ' AND (PayTypeID = 7)'

	-- Receipt Docs Included 
	If @IncludeReceipt = 1 
	Begin
		If @StrSelectSub <> ''
			Set @StrSelectSub = @StrSelectSub + '
			UNION ALL '
		Set @StrSelectSub = @StrSelectSub + ' 
			SELECT	VolumeFiscalYear, VolumeRowNo
			FROM	trs.tblPayDtl
			WHERE	ProcessID = 27 and ProcessNo = ' + LTRIM(STR(@ProcessNo)) + '
			UNION ALL
			SELECT	VolumeFiscalYear, VolumeRowNo
			FROM	trs.tblPayDtl
			WHERE	ProcessID = 2 and ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ' AND PayTypeID = 7 '
	End

	-- Returned Docs Included 
	If @IncludeReturned = 1 
	Begin
		If @StrSelectSub <> ''
			Set @StrSelectSub = @StrSelectSub + '
			UNION ALL '
		Set @StrSelectSub = @StrSelectSub + '	
			SELECT	VolumeFiscalYear, VolumeRowNo
			FROM	trs.tblPayDtl
			WHERE	(ProcessID = 28) and (ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ')'
	End 

	-- All Cheques Included ; No Need any Condition
	If @IncludeUnReceipt = 1 AND @IncludeReceipt = 1 AND @IncludeReturned = 1 
		Set @StrSelectSub = ''

	-- === End Query Sub String Section ==================================
	-- === Main String Query Section =====================================
	Set @StrSelect = '
   SELECT T.ChequeDate, Sum(T.Amount) Amount
   FROM
   (
		SELECT	Substring(D.ChequeDate, 9, 2) ChequeDate, D.Amount 
		FROM	trs.tblPayDtl AS D '

	-- Condition Query must be joint
	If @StrSelectSub <> ''
		Set @StrSelect = @StrSelect + '
		INNER JOIN
		( ' + @StrSelectSub + '
		) AS A ON A.VolumeFiscalYear = D.VolumeFiscalYear AND A.VolumeRowNo = D.VolumeRowNo '

	Set @StrSelect = @StrSelect + '
		WHERE (Left(D.ChequeDate, 4) = ' + @CurrentYear + ') 
			AND (Substring(D.ChequeDate, 6, 2) = ''' + @CurrentMonth + ''') 
			AND (D.ProcessID IN (2,25)) 
			AND (D.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ')
			AND (D.PayTypeID IN (7,8,28))'

	If	(@DebitCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') 
	If	(@DebitCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.DebitCode') 
	If	(@DebitCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') 
	If	(@DebitCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') 

	If	(@CreditCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode') 
	If	(@CreditCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode') 
	If	(@CreditCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode') 
	If	(@CreditCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode') 
		---------------------------------------------------------------------------------------------------
	Declare @DonotFilterAcc2Trs AS bit
	SET @DonotFilterAcc2Trs = 0
	SELECT @DonotFilterAcc2Trs = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DonotFilterAcc2Trs'
		
if @DonotFilterAcc2Trs=0 	
begin

	
	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;

	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblOurBanks
	END TRY
	BEGIN CATCH
	END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblOurBanks
	(
		CreditCode 			Varchar(20)collate arabic_cs_as null
	)
	if (@UserIsAdmin = 0)
	begin
	 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrSelect =  @StrSelect + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
	 end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end
------------------------------------------------------------------------------------------------------


	-- Union with All Days --
	Set @StrSelect = @StrSelect + '
		UNION all
		SELECT Days, 0
		FROM #tblDays'

	-- Group By Clause --
	Set @StrSelect = @StrSelect + '
	) T GROUP BY T.ChequeDate'

	Set @StrSelect = @StrSelectPrm + @StrSelect

	-- === End Main String Query Section ==================================
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
