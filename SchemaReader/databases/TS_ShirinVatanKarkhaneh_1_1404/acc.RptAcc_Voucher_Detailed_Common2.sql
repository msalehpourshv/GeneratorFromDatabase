USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 06-13-2007
-- Viewed By	 : 
-- Last Modified : 1392/09/16
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Voucher> -- چاپ رویه اسناد حسابداری
-- ===============================================
CREATE PROCEDURE [acc].[RptAcc_Voucher_Detailed_Common2]
	@SelectLen		int = 20,
	@ReportType		int = 2,
		-- 1 = Continous Sort By DocRowNo
		-- 2 = Discrete  Sort By AcntCode
		-- 3 = Discrete  Sort By DocRowNo
	@SerialNoFr		int = 1,
	@SerialNoTo		int = 10,
	@SerialOldFr	int = Null,
	@SerialOldTo	int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@PortionLayer	tinyint = 1,
	@RepOptions		varchar(20) = '00000110001000',
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarChar(500) = ''
WITH ENCRYPTION
AS

DECLARE @Layer1Len TinyInt
DECLARE @Layer2Len TinyInt
DECLARE @Layer3Len TinyInt
DECLARE @Layer4Len TinyInt

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
DECLARE @Source nvarchar(50)
DECLARE @SourceProcessID varchar(100)
DECLARE	@SourceProcessNo VARCHAR(30);

DECLARE @ShowDocDesc1	Bit -- شامل شرح اول سند باشد یا نه؟
DECLARE @ShowDocDesc2	Bit -- شامل شرح دوم سند باشد یا نه؟
DECLARE @ShowRecDesc1	Bit -- شامل شرح ردیف اول باشد یا نه؟
DECLARE @ShowRecDesc2	Bit -- شامل شرح ردیف دوم باشد یا نه؟
DECLARE @ShowPortion	Bit -- شامل ستون جزء باشد یا نه؟
DECLARE @AutoY			Bit
DECLARE @AutoN			Bit 
DECLARE @SortByOldSrl	Bit
DECLARE @FullParts		Bit
DECLARE	@UseCurrency	Bit; -- 1 = از واحد ارزی استفاده شود

DECLARE @UserName		NVarChar(4000)
DECLARE @UserFullName	NVarChar(4000)

Create Table #tblAll
(
	AcntCode		VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit			float Not Null,
	Credit			float Not Null,
	DC_State		TinyInt, -- 0 = Debit, 1 = Credit
	RecDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RecDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	IsMainCode		Bit Not Null
);

Create Table #tblResult
(
	AcntCode		VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit			float Not Null,
	Credit			float Not Null,
	DC_State		TinyInt, -- 0 = Debit, 1 = Credit
	RowDesc1		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	RowDesc2		NVarChar(4000) COLLATE Arabic_CS_AS Null,
	IsMainCode		Bit Not Null,
	ParentCode		VarChar(20) COLLATE Arabic_CS_AS Null
);

DECLARE	@StrQuery	NVarChar(max);
DECLARE	@StrWhere	NVarChar(max);
DECLARE	@LayerNumber	TinyInt;
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
	IF (@RepOptions Is Null)	SET @RepOptions = '000001101000';

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
	
	If (@ReportType = 1) -- Common Report (No discrete)
		SET @StrWhere = '(D.VchKind > -1)';
	Else
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

	/* =================== Common State ============== */
	If (@ReportType = 1)   -- حالت عادی بدون تفکیک --
	Begin
		SET @StrQuery = '
		SELECT	LTrim(RTrim(D.AcntCode)) AS AcntCode, D.Debit, D.Credit, 
				CASE WHEN (D.Debit <> 0) THEN 0 ELSE 1 END AS DC_State, ' +
				CASE WHEN(@ShowRecDesc1 = 1) THEN 'D.RecDesc ' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc1, ' + 
				CASE WHEN(@ShowRecDesc2 = 1) THEN 'D.RecDesc2' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc2, 
				1 IsMainCode, '''' ParentCode, pub.GetCodeName(LTrim(RTrim(D.AcntCode)), 1) AcntName,
				acc.funPartAcntName(D.AcntCode, 1) AcntName1,
				acc.funPartAcntName(D.AcntCode, 2) AcntName2,
				acc.funPartAcntName(D.AcntCode, 3) AcntName3
 		FROM	' + @Source + ' D 
		INNER JOIN acc.tblVoucherHdr H on H.SerialNo = D.SerialNo
		WHERE ' + @StrWhere + '
		ORDER BY D.AcntCode '
	
		print	@StrQuery;
		EXEC	sp_executesql @StrQuery;
		RETURN
	End
	/* ================================================ */	

	SET @StrQuery = '
	INSERT	INTO #tblAll 
	SELECT	Left(D.AcntCode, ' + LTrim(Str(@SelectLen)) + ') AcntCode, D.Debit, D.Credit,
			CASE WHEN (D.Debit <> 0) THEN 0 ELSE 1 END AS DC_State, ' +
			CASE WHEN(@ShowRecDesc1 = 1) THEN 'D.RecDesc ' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc1, ' + 
			CASE WHEN(@ShowRecDesc2 = 1) THEN 'D.RecDesc2' ELSE 'Cast('''' As NVarChar(4000))' END + ' AS RowDesc2, 1 IsMainCode
	FROM	' + @Source + ' D 
	INNER JOIN acc.tblVoucherHdr H on H.SerialNo = D.SerialNo
	WHERE ' + @StrWhere

	print	@StrQuery;
	EXEC	sp_executesql @StrQuery;

	SET @LayerLen = 0;
	SET @PrevPart = 0;
	
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

	If	(@FullParts <> 1) and (@Layer1 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Null
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0, 
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	SET @LayerLen = @LayerLen + @Layer2

	If  (@FullParts <> 1) and (@Layer2 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If  (@FullParts <> 1) and (@Layer3 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If  (@FullParts <> 1) and (@Layer4 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If  (@FullParts <> 1) and (@Layer5 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If  (@FullParts <> 1) and (@Layer6 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If  (@FullParts <> 1) and (@Layer7 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If  (@FullParts <> 1) and (@Layer8 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9
	
	If (@FullParts <> 1) and (@Layer9 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer9)
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
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @LayerS)
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

	If (@FullParts <> 1) and (@Layer1 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts <> 1) and (@Layer2 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts <> 1) and (@Layer3 > 0) 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts <> 1) and (@Layer4 > 0) 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts <> 1) and (@Layer5 > 0) 
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts <> 1) and (@Layer6 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts <> 1) and (@Layer7 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and (@Layer8 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and (@Layer9 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @LayerS)
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

	If (@FullParts <> 1) and (@Layer1 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2

	If (@FullParts <> 1) and (@Layer2 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3

	If (@FullParts <> 1) and (@Layer3 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4

	If (@FullParts <> 1) and (@Layer4 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5

	If (@FullParts <> 1) and (@Layer5 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts <> 1) and (@Layer6 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7

	If (@FullParts <> 1) and (@Layer7 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and (@Layer8 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and (@Layer9 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @LayerS)
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
	
	If (@FullParts <> 1) and (@Layer1 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer1 - 1)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer2
	
	If (@FullParts <> 1) and (@Layer2 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer2)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer2)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer3
	
	If (@FullParts <> 1) and (@Layer3 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer3)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer3)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer4
	
	If (@FullParts <> 1) and (@Layer4 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer4)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer4)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer5
	
	If (@FullParts <> 1) and (@Layer5 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer5)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer5)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer6

	If (@FullParts <> 1) and (@Layer6 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer6)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer6)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer7
	
	If (@FullParts <> 1) and (@Layer7 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer7)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer7)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer8

	If (@FullParts <> 1) and (@Layer8 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer8)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer8)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End

	SET @LayerLen = @LayerLen + @Layer9

	If (@FullParts <> 1) and (@Layer9 > 0)
	Begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @Layer9)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) = @LayerLen AND IsMainCode = 1

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @Layer9)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	End
	
	if (@FullParts = 1) and (@LayerS > 0)
	begin
		INSERT INTO #tblResult
		SELECT A.*, Left(AcntCode, @LayerLen - @LayerS)
		FROM   #tblAll A
		WHERE  Len(A.AcntCode) <= @LayerLen AND IsMainCode = 1 and Len(A.AcntCode) > @PrevPart

		INSERT	INTO #tblResult
		SELECT	DISTINCT Left(AcntCode, @LayerLen), 0, 0,  
				DC_State, '', '', 0, Left(AcntCode, @LayerLen - @LayerS)
		FROM	#tblAll A 
		WHERE	Len(AcntCode) > @LayerLen AND IsMainCode = 1
	end
	
	SET @PrevPart = @LayerLen;	

	-- ===========================================================
	SELECT	R.*, pub.GetCodeName(R.AcntCode, 1) AS AcntName,
			acc.funPartAcntName(R.AcntCode, 1) AcntName1,
			acc.funPartAcntName(R.AcntCode, 2) AcntName2,
			acc.funPartAcntName(R.AcntCode, 3) AcntName3,
			@UserFullName UserFullName, @UserName PrintUserName, 
			pub.funFarsiDate(GETDATE()) PrintDate
	FROM	#tblResult R
	ORDER BY DC_State, AcntCode, IsMainCode DESC
	-- ===========================================================

END
GO
