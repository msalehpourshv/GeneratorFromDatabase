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
create PROCEDURE [trs].[RptTrs_PayableDocs_Stats]
	@ProcessNo		int = 1,
	@ChqDateFr		char(10),
	@ChqDateTo		char(10),
	@DebitCode1		Int = 0, -- بدهکار
	@DebitCode2		Int = 0,
	@DebitCode3		Int = 0,
	@DebitCode4		Int = 0,
	@CreditCode1	Int = 0, -- بستانکار
	@CreditCode2	Int = 0,
	@CreditCode3	Int = 0,
	@CreditCode4	Int = 0,
	@RepOptions		VarChar(10) = '1110',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE @ShowUnR	Bit; -- شامل وصول نشده ها
DECLARE @ShowRec	Bit; -- شامل وصول شده ها
DECLARE @ShowRet	Bit; -- شامل برگشتی ها

DECLARE @LangID		Char(1)
DECLARE @SessionNo	VarChar(10)
DECLARE @ReportID	VarChar(10)

DECLARE @DailyChq	bit;
Declare @StrTID		NVarChar(20)
Declare @StrPID		NVarChar(20)
Begin   

	SET NOCOUNT ON;

	-- init Variables --
	if (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	if (@RepOptions Is Null)	SET @RepOptions = '0';

	IF (@DebitCode1 Is Null)	SET @DebitCode1 = 0;
	IF (@DebitCode2 Is Null)	SET @DebitCode2 = 0;
	IF (@DebitCode3 Is Null)	SET @DebitCode3 = 0;
	IF (@DebitCode4 Is Null)	SET @DebitCode4 = 0;

	IF (@CreditCode1 Is Null)	SET @CreditCode1 = 0;
	IF (@CreditCode2 Is Null)	SET @CreditCode2 = 0;
	IF (@CreditCode3 Is Null)	SET @CreditCode3 = 0;
	IF (@CreditCode4 Is Null)	SET @CreditCode4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ShowUnR	= Substring(@RepOptions, 1, 1);
	SET @ShowRec	= Substring(@RepOptions, 2, 1);
	SET @ShowRet	= Substring(@RepOptions, 3, 1);
	SET @DailyChq	= Substring(@RepOptions, 4, 1);

	if (@DailyChq = 1)
		set @StrTID = '7,8,28'
	else
		set @StrTID = '8,28'

	set @StrPID = '0'
	
	If (@ShowUnR = 1)
		set @StrPID	= @StrPID + ',2,25'
	If (@ShowRec = 1) 
		set @StrPID	= @StrPID + ',27'
	If (@ShowRet = 1)
		set @StrPID	= @StrPID + ',28'

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

	set @StrWhere = '(D.ProcessNo=1)
	    AND (D.PayTypeID in (' + @StrTID + '))
	    AND (D.ProcessID in (2, 25))
	    AND (D.ProcessNo = ' + LTRIM(STR(@ProcessNo)) + ')
		AND (LAST.ProcessID in (' + @StrPID + '))'


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
			SET @StrWhere =  @StrWhere + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
	 end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null

end

------------------------------------------------------------------------------------------------------


	SET @StrSelect = '
	SELECT	D.*
	FROM	trs.tblPayDtl D 
			INNER JOIN trs.vwLastEvent_Payment [LAST] ON [LAST].VolumeFiscalYear=D.VolumeFiscalYear and [LAST].VolumeRowNo=D.VolumeRowNo and [LAST].EventNo=D.EventNo
	WHERE ' + @StrWhere + '
	ORDER BY D.DocDate' 

	CREATE TABLE #tbl_PDC_Mon
	(
		ChequeDate Char(10) Collate Arabic_CS_AS
	)
	
	Declare @idxMFr Int
	Declare @idxMTo Int
	Declare @idxYFr Int
	Declare @idxYTo Int
	Declare @idxYCurr Int
	Declare @idxMCurr Int
	
	Set @idxYFr = LEFT(@ChqDateFr, 4);
	Set @idxYTo = LEFT(@ChqDateTo, 4);
	
	set @idxYCurr = @idxYFr;
	
	while (@idxYCurr <= @idxYTo)
	begin
		if (@idxYCurr = @idxYFr)
			set @idxMFr = SUBSTRING(@ChqDateFr, 6, 2);
		else
			set @idxMFr = 1;

		if (@idxYCurr = @idxYTo)
			set @idxMTo = SUBSTRING(@ChqDateTo, 6, 2);
		else
			set @idxMTo = 12;
		
		set @idxMCurr = @idxMFr;

		while (@idxMCurr <= @idxMTo)
		begin
			insert into #tbl_PDC_Mon
			values (ltrim(str(@idxYCurr)) + '/' + case when (@idxMCurr < 10) then '0' else '' end + Ltrim(Str(@idxMCurr)))
			
			Set @idxMCurr = @idxMCurr + 1
		end

		Set @idxYCurr = @idxYCurr + 1
	end;
	
	--insert into #tbl_PDC_Mon values('0000/00')
	insert into #tbl_PDC_Mon values('9999/99')

	-- ==== Create Sub String Query Section ==============================
	Set @StrSelect = '
	SELECT T.ChequeDate, Sum(T.Amount) Amount
	FROM
	(
		SELECT	CASE 
					WHEN D.ChequeDate < ''' + @ChqDateFr + ''' Then ''0000/00'' 
					WHEN D.ChequeDate > ''' + @ChqDateTo + ''' Then ''9999/99'' 
					ELSE Left(D.ChequeDate, 7) 
				END ChequeDate, D.Amount
		FROM	trs.tblPayDtl D
					LEFT JOIN trs.vwLastEvent_Payment [LAST] ON [LAST].VolumeFiscalYear=D.VolumeFiscalYear and [LAST].VolumeRowNo=D.VolumeRowNo
		WHERE	' + @StrWhere + '
		UNION	all
		SELECT	ChequeDate, 0
		FROM	#tbl_PDC_Mon
	) T 
	GROUP BY T.ChequeDate '

	-- === End Main String Query Section ==================================
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
