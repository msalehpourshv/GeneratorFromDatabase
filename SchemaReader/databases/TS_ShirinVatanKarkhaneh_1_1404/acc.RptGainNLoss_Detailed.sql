USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/05/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <Gain And Loss Report>     
-- =============================================
Create PROCEDURE [acc].[RptGainNLoss_Detailed]
	@DateFr			Char(10) = Null,
	@DateTo			Char(10) = Null,
	@ShowFinishDocs	Bit = 1, -- اختتامیه
	@ShowClosedDocs	Bit = 1, -- بستن حساب
	@ShowDaily		Bit = 0,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect		NVarChar(2000);
DECLARE @StrWhere		NVarChar(1000);
DECLARE @StrDay			NVarChar(200);
DECLARE @StrDay2		NVarChar(200);
DECLARE @StrMon			NVarChar(200);
DECLARE @StrAcntCode	VarChar(1000);
DECLARE @StrLayerLen	VarChar(2);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
BEGIN ------------------------------------------------------------------------

	SET NOCOUNT ON;

	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	 SET @RepInfo = '1@1@1';
	IF (@ShowFinishDocs Is Null) SET @ShowFinishDocs = 1;
	IF (@ShowClosedDocs Is Null) SET @ShowClosedDocs = 1;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = '(D.VchKind <> 0) AND (A.AcntType in (41,51,61,62,81))'

	IF (@DateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DateFr + ''')'

	IF (@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'

	IF (@ShowFinishDocs = 0)
		SET @StrWhere = @StrWhere + ' AND (D.VchKind <> 3)'

	IF (@ShowClosedDocs = 0)
		SET @StrWhere = @StrWhere + ' AND (D.VchKind <> 4)'
	----------------------------------------------------------------------------
	-- Select Clause -----------------------------------------------------------
	SELECT	@StrLayerLen = Cast(Layer1 AS VarChar(2))
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SET @StrAcntCode = 'LEFT(D.AcntCode, ' + @StrLayerLen + ')'

	If (@ShowDaily = 1) 
	BEGIN
		SET @StrDay	= 'Cast(Substring(D.DocDate, 6, 5) As Char(5))'
		SET @StrDay2= 'Days'
	END
	ELSE
	BEGIN
		SET @StrDay	= '''00/00'''
		SET @StrDay2= '''00/00'''
	END

	SET @StrMon = 'Cast(Substring(D.DocDate, 6, 2) As Char(2))'

	SET @StrSelect = '
	Declare @idx1 Int
	Declare @idx2 Int
	Create Table #tblDays (Days Char(10) COLLATE Arabic_CS_AS)
	-- Fill Table Variale With Year Days --
	Set @idx1 = 1

	While @idx1 <= 12
	Begin
		Set @idx2 = 1

		While @idx2 <= 31
		Begin
			Insert Into #tblDays	
			Values (Case When Len(LTrim(Str(@idx1))) < 2 Then ''0'' Else '''' End + Ltrim(Str(@idx1)) + ''/'' + 
					  Case When Len(LTrim(Str(@idx2))) < 2 Then ''0'' Else '''' End + LTrim(Str(@idx2)))	
			Set @idx2 = @idx2 + 1
		End

		Set @idx1 = @idx1 + 1
	End; '

	SET @StrSelect = @StrSelect + ' 
	SELECT	[Day], [Month],
			SUM(CASE WHEN (AcntType in( 41,81)) THEN (Credit - Debit) ELSE 0 END) AS Incoming,
			SUM(CASE WHEN (AcntType In(51, 61, 62)) THEN (Debit - Credit) ELSE 0 END) AS Outgoing
	FROM
	(
		SELECT	' + @StrDay + ' AS Day,
				' + @StrMon + ' AS Month, D.Debit, D.Credit, A.AcntType
		FROM	acc.tblVoucherDtl D INNER JOIN acc.tblAcnt A ON
					(' + @StrAcntCode + ' = A.AcntCode) AND (A.PartNumber = 1)
		WHERE	' + @StrWhere + '
		UNION All
		SELECT  ' + @StrDay2 + ', LEFT(Days, 2), 0, 0, 41
		FROM #tblDays
	) T
	GROUP BY T.Day, T.Month
	ORDER BY T.Day, T.Month '
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC  sp_executesql @StrSelect;
END
GO
