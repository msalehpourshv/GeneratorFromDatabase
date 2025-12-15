USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 06-13-2007
-- Viewed By	 : 
-- Last Modified : 1392/09/16
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Voucher_Summary>
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_Voucher_Summary_Common2]
	@SelectLen		int = 20, 
	@ReportType		int = 2, -- not used
		-- 1 = Continous Sort By DocRowNo (Not Used In this type)
		-- 2 = Discrete  Sort By AcntCode 
		-- 3 = Discrete  Sort By DocRowNo (Not Used In this type)
	@SerialNoFr		int = 1,
	@SerialNoTo		int = 10,
	@SerialOldFr	int = Null,
	@SerialOldTo	int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@PortionLayer	tinyint = 1, -- not used
	@RepOptions		varchar(20) = '0000011000100',
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarChar(200) = ''
WITH ENCRYPTION
AS

DECLARE @Source nvarchar(50)
DECLARE @Layer1 Tinyint
DECLARE @Layer2 Tinyint
DECLARE @Layer3 Tinyint
DECLARE @Layer4 Tinyint
DECLARE @Layer5 Tinyint
DECLARE @Layer6 Tinyint
DECLARE @Layer7 Tinyint
DECLARE @Layer8 Tinyint
DECLARE @Layer9 Tinyint
DECLARE @LayerS Tinyint
DECLARE @LayerLen Tinyint
DECLARE @PrevPart Tinyint
DECLARE @FullParts Bit
DECLARE	@UseCurrency	Bit; -- 1 = از واحد ارزی استفاده شود
DECLARE @SourceProcessID varchar(100)
DECLARE	@SourceProcessNo	VARCHAR(30);

DECLARE @UserName		NVarChar(4000)
DECLARE @UserFullName	NVarChar(4000)

CREATE TABLE #tblAll
(
	AcntCode	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit		float Not Null,
	Credit		float Not Null,
	DC_State	TinyInt, -- 0 = Debit, 1 = Credit
	IsMainCode	Bit Not Null
);

CREATE TABLE #tblResult
(
	AcntCode	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit		float Not Null,
	Credit		float Not Null,
	DC_State	TinyInt, -- 0 = Debit, 1 = Credit
	IsMainCode	Bit Not Null,
	ParentCode	VarChar(20) COLLATE Arabic_CS_AS Null
);

DECLARE	@StrQuery		NVarChar(2000);
DECLARE	@StrWhere		NVarChar(1000);
DECLARE	@LayerNumber	TinyInt;

DECLARE @ShowDocDesc1	Bit -- شامل شرح اول سند باشد یا نه؟
DECLARE @ShowDocDesc2	Bit -- شامل شرح دوم سند باشد یا نه؟
DECLARE @ShowRecDesc1	Bit -- شامل شرح ردیف اول باشد یا نه؟
DECLARE @ShowRecDesc2	Bit -- شامل شرح ردیف دوم باشد یا نه؟
DECLARE @ShowPortion	Bit -- شامل ستون جزء باشد یا نه؟
DECLARE @AutoY	Bit
DECLARE @AutoN	Bit 
DECLARE @SortByOldSrl Bit
DECLARE	@LockOnly	bit;

BEGIN ---------------------------------------------------------------------

	SET NOCOUNT ON;

	set @LockOnly = 0;
	select @LockOnly = SettingValue
	from pub.tblSettings
	where SettingKey='Acc_ReportLockedOnly'
	
	SET @SourceProcessID = pub.funSplitString(@ExtraParams, '#', 1);
	SET @UserFullName	 = pub.funSplitString(@ExtraParams, '#', 2);
	SET @UserName		 = pub.funSplitString(@ExtraParams, '#', 3);
	
	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '0000011000100';

	set @ShowDocDesc1	= Substring(@RepOptions, 1, 1)
	set @ShowDocDesc2	= Substring(@RepOptions, 2, 1)
	set @ShowRecDesc1	= Substring(@RepOptions, 3, 1)
	set @ShowRecDesc2	= Substring(@RepOptions, 4, 1)
	set @ShowPortion	= Substring(@RepOptions, 5, 1)
	set @AutoY			= Substring(@RepOptions, 6, 1)
	set @AutoN			= Substring(@RepOptions, 7, 1)
	set @SortByOldSrl	= Substring(@RepOptions, 8, 1)
	-- ~ 9 is used
	set @FullParts		= Substring(@RepOptions, 10, 1)
	set @UseCurrency	= Substring(@RepOptions, 11, 1)

	if LEN(@RepOptions) > 11
		SET @SourceProcessNo= Substring(@RepOptions, 12, 1)
	else
		SET @SourceProcessNo= '0'
	---------------------------------------------------------

	if (@UseCurrency = 1) 
		set @Source = 'acc.vwVoucherDtl2'
	else
		set @Source = 'acc.tblVoucherDtl'

	SET @LayerLen = 0;
	SET @PrevPart = 0;

	--========= < W H E R E > =======================================================
	
	SET @StrWhere = '(D.VchKind <> 0)';

	if (@SourceProcessID <> '')
		SET @StrWhere = @StrWhere  + ' AND (D.SourceProcessID in (' + LTrim(@SourceProcessID) + '))'

	If (@SourceProcessNo <> '0')
	begin
		Declare @DistributionSourceProcessNo AS varchar(2)
		SET @DistributionSourceProcessNo = '0'
	
		SELECT @DistributionSourceProcessNo = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DistributionSourceProcessNo'

		IF @DistributionSourceProcessNo<>'0' AND @DistributionSourceProcessNo=@SourceProcessNo
			SET @SourceProcessNo = @SourceProcessNo + ',10' 
		If (@AutoN = 1) 
			SET @StrWhere = @StrWhere  + ' AND ((D.IsAutoDoc = 0) OR D.SourceProcessNo IN (' + @SourceProcessNo + '))'
		Else
			SET @StrWhere = @StrWhere  + ' AND (D.SourceProcessNo IN (' + @SourceProcessNo + '))'
	end

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')' 

	If (@SerialOldFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OldSerialNo >= ' + LTrim(Str(@SerialOldFr)) + ')'
	If (@SerialOldTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OldSerialNo <= ' + LTrim(Str(@SerialOldTo)) + ')'

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'

	If (@AutoY <> 1)
		SET @StrWhere = @StrWhere + ' AND (D.IsAutoDoc <> 1)'
	If (@AutoN <> 1)
		SET @StrWhere = @StrWhere + ' AND (D.IsAutoDoc <> 0)'

	if (@LockOnly = 1)
		SET @StrWhere = @StrWhere + ' AND (H.DocRegisterState > 1)'

	--============ < S E L E C T > ==================================================

	SET @StrQuery	= '
		INSERT  INTO #tblAll
		SELECT	Left(D.AcntCode, ' + LTrim(Str(@SelectLen)) + ') AcntCode, Sum(D.Debit) Debit, Sum(D.Credit) Credit,
				CASE WHEN (D.Debit <> 0) Then 0 Else 1 End AS DC_State, cast(1 as bit)
		FROM	' + @Source + ' D
					INNER JOIN acc.tblVoucherHdr H ON D.SerialNo = H.SerialNo 
		WHERE	' + @StrWhere + ' 
		GROUP BY Left(D.AcntCode, ' + LTrim(Str(@SelectLen)) + '), CASE WHEN (D.Debit <> 0) Then 0 Else 1 End '
		
	print @StrQuery;
	Exec sp_executesql @StrQuery;
	--*** ------------------------------------------------------------ ***
	--*** ------------------- First Section -------------------------- ***
	--*** ------------------------------------------------------------ ***

	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
			@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
			@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 1 AND TableName = 'acc.tblAcnt'

	SET	@LayerLen = @Layer1
	SET	@LayerNumber = 1
	SET	@LayerS = @Layer1+@Layer2+@Layer3+@Layer4+@Layer5+@Layer6+@Layer7+@Layer8+@Layer9

	If	(@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Null
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	SET @LayerLen = @LayerLen + @Layer2

	If  (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If  (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT	INTO #tblResult
		SELECT	A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A
		WHERE	Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	SET @LayerLen = @LayerLen + @Layer4

	If  (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT	INTO #tblResult
		SELECT	A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A
		WHERE	Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If  (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT	INTO #tblResult
		SELECT	A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A
		WHERE	Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If  (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT	INTO #tblResult
		SELECT	A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A
		WHERE	Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If  (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If  (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult
		SELECT A.*, null
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @LayerS)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	end
	
	SET @PrevPart = @LayerLen;
	
	--*** ------------------------------------------------------------- ***
	--*** --------------------- Second Section ------------------------ ***
	--*** ------------------------------------------------------------- ***
	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
			@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
			@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 2 AND TableName = 'acc.tblAcnt'

	SET	@LayerNumber = 2
	SET	@LayerLen = @LayerLen + 1    --/ Space /--
	SET	@LayerLen = @LayerLen + @Layer1
	SET	@LayerS = @Layer1+@Layer2+@Layer3+@Layer4+@Layer5+@Layer6+@Layer7+@Layer8+@Layer9

	If (@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @LayerS)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	end
	
	SET @PrevPart = @LayerLen;	
	
   --*** ------------------------------------------------------------- ***
	--*** --------------- Third Section ------------------------------- ***
   --*** ------------------------------------------------------------- ***
	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
			@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
			@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 3 AND TableName = 'acc.tblAcnt'

	SET	@LayerNumber = 3
	SET	@LayerLen = @LayerLen + 1  --/ Space /--
	SET	@LayerLen = @LayerLen + @Layer1
	SET	@LayerS = @Layer1+@Layer2+@Layer3+@Layer4+@Layer5+@Layer6+@Layer7+@Layer8+@Layer9

	If (@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If  (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If  (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If  (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If  (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If  (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If  (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If  (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If  (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @LayerS)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	end
	
	SET @PrevPart = @LayerLen;	
	
	--*** ------------------------------------------------------------- ***
	--*** --------------- Forth Section ------------------------------- ***
	--*** ------------------------------------------------------------- ***
	SELECT	@Layer1 = Layer1, @Layer2 = Layer2, @Layer3 = Layer3, 
			@Layer4 = Layer4, @Layer5 = Layer5, @Layer6 = Layer6, 
			@Layer7 = Layer7, @Layer8 = Layer8, @Layer9 = Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 4 AND TableName = 'acc.tblAcnt'

	SET	@LayerNumber = 4
	SET	@LayerLen = @LayerLen + 1  --/ Space /--
	SET	@LayerLen = @LayerLen + @Layer1
	SET	@LayerS = @Layer1+@Layer2+@Layer3+@Layer4+@Layer5+@Layer6+@Layer7+@Layer8+@Layer9
	
	If	(@FullParts <> 1) and @Layer1 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2
	
	If  (@FullParts <> 1) and @Layer2 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If  (@FullParts <> 1) and @Layer3 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If  (@FullParts <> 1) and @Layer4 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If  (@FullParts <> 1) and @Layer5 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If  (@FullParts <> 1) and @Layer6 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7
	
	If  (@FullParts <> 1) and @Layer7 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If  (@FullParts <> 1) and @Layer8 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If  (@FullParts <> 1) and @Layer9 > 0 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, DC_State, 0, Left(AcntCode, @LayerLen - @LayerS)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	end
	
	SET @PrevPart = @LayerLen;	

	----------------------------------------------------------------------------/
	SELECT	R.*, pub.GetCodeName(AcntCode, 1) AS AcntName,
			@UserFullName UserFullName, @UserName PrintUserName, 
			pub.funFarsiDate(GETDATE()) PrintDate
	FROM	#tblResult R
	Order By DC_State, AcntCode, IsMainCode DESC

END
GO
