USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1387/06/27
-- Viewed By	 : 
-- Last Modified : 1389/02/20
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : گزارش درختی حسابها
-- =============================================
CREATE PROCEDURE [acc].[RptAccounts_ListTree]
	@AcntCodeFr		VarChar(20) = Null,
	@AcntCodeTo		VarChar(20) = Null,
	@PartNumber		int = 1,
	@PartsCount		int = 1,
	@LayerCount		int = 9,
	@LanguageID		int = 1
WITH ENCRYPTION
AS
----------------------------------
DECLARE @Layer1		int
DECLARE @Layer2		int
DECLARE @Layer3		int
DECLARE @Layer4		int
DECLARE @Layer5		int
DECLARE @Layer6		int
DECLARE @Layer7		int
DECLARE @Layer8		int
DECLARE @Layer9		int
DECLARE @CurLen		int
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
----------------------------------
CREATE TABLE #tblAcntCodes
(
	AcntCode VarChar(20)
);
----------------------------------
CREATE TABLE #tblAcntCodesFull
(
	AcntCode   VarChar(20) Null,
	ParentCode VarChar(20) Null
)
----------------------------------
BEGIN
	
	SET NOCOUNT ON;
	-- Init -------------------------------------------
	SET @CurLen = 0

	SET @StrWhere = '(PartNumber = ' + LTRim(Str(@PartNumber)) + ')'

	If (@AcntCodeFr Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (SubString(LTrim(RTrim(AcntCode)), 1, ' + LTrim(Str(Len(@AcntCodeFr))) + ') >= ''' + @AcntCodeFr + ''')'

	If (@AcntCodeTo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (SubString(LTrim(RTrim(AcntCode)), 1, ' + LTrim(Str(Len(@AcntCodeTo))) + ') <= ''' + @AcntCodeTo + ''')'

	SET @StrSelect = '
	INSERT INTO	#tblAcntCodes
	SELECT LTrim(RTrim(AcntCode)) AS AcntCode
	FROM   acc.tblAcnt
	WHERE  ' + @StrWhere

	Exec sp_executesql @StrSelect

	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, @Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, @Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer
	WHERE	(PartNumber = @PartNumber) AND (TableName = 'acc.tblAcnt')

	SET @CurLen = @Layer1

	If (@Layer1 > 0) AND (@LayerCount >= 1)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), Null
		FROM   #tblAcntCodes
	End

	SET @CurLen = @CurLen + @Layer2

	If (@Layer2 > 0) AND (@LayerCount >= 2)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), LEFT(AcntCode, @CurLen - @Layer2)
		FROM   #tblAcntCodes
	End

	SET @CurLen = @CurLen + @Layer3

	If (@Layer3 > 0) AND (@LayerCount >= 3)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), LEFT(AcntCode, @CurLen - @Layer3)
		FROM   #tblAcntCodes
	End

	SET @CurLen = @CurLen + @Layer4

	If (@Layer4 > 0) AND (@LayerCount >= 4)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), LEFT(AcntCode, @CurLen - @Layer4)
		FROM   #tblAcntCodes
	End

	SET @CurLen = @CurLen + @Layer5

	If (@Layer5 > 0) AND (@LayerCount >= 5)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), LEFT(AcntCode, @CurLen - @Layer5)
		FROM   #tblAcntCodes
	End

	SET @CurLen = @CurLen + @Layer6

	If (@Layer6 > 0) AND (@LayerCount >= 6)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), LEFT(AcntCode, @CurLen - @Layer6)
		FROM   #tblAcntCodes
	End

	SET @CurLen = @CurLen + @Layer7

	If (@Layer7 > 0) AND (@LayerCount >= 7)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), LEFT(AcntCode, @CurLen - @Layer7)
		FROM   #tblAcntCodes
	End

	SET @CurLen = @CurLen + @Layer8

	If (@Layer8 > 0) AND (@LayerCount >= 8)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), LEFT(AcntCode, @CurLen - @Layer8)
		FROM   #tblAcntCodes
	End

	SET @CurLen = @CurLen + @Layer9

	If (@Layer9 > 0) AND (@LayerCount >= 9)
	Begin
		INSERT INTO #tblAcntCodesFull(AcntCode, ParentCode)
		SELECT LEFT(AcntCode, @CurLen), LEFT(AcntCode, @CurLen - @Layer9)
		FROM   #tblAcntCodes
	End

	----------------------------------------------------------------------------/

	SELECT DISTINCT F.*, [acc].[funGetAcntName](AcntCode, @PartNumber, @LanguageID) AS AcntName
	FROM	#tblAcntCodesFull F
	ORDER BY AcntCode, ParentCode
    
END
GO
