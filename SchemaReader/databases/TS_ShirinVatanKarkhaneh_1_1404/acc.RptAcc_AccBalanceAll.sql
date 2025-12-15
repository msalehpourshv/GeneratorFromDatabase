USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1391/02/23
-- Viewed By	 : 
-- Last Modified : 1391/02/23
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- ==============================================
Create PROCEDURE [acc].[RptAcc_AccBalanceAll]
	@PartNo			TinyInt, -- شماره بخش
	@LevelNo		TinyInt, -- طول لایه - اگر بخش یک باشد یا بخش یک نباشد ولی کد بصورت کامل خواسته شود این پارامتر طول کامل کد والا طول کد در آن بخش را می پذیرد
	@AcntCode1		varchar(21) = null,
	@AcntCode2		varchar(21) = null,
	@AcntCode3		varchar(21) = null,
	@AcntCode4		varchar(21) = null,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@SerialNoFr		int = Null,
	@SerialNoTo		int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@DebitRemainFr	float = Null,
	@DebitRemainTo	float = Null,
	@CreditRemainFr	float = Null,
	@CreditRemainTo	float = Null,
	@DebitCycleFr	float = Null,
	@DebitCycleTo	float = Null,
	@CreditCycleFr	float = Null,
	@CreditCycleTo	float = Null,
	@SortFields		NVarChar(100) = Null,
	@RepOptions		varchar(21) = '0011101',
	@RepInfo		NVarChar(max) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @ZeroRemain		Bit;
DECLARE @ZeroCycles		Bit;
DECLARE @ShowPrimar		Bit;
DECLARE @ShowFinish		Bit;
DECLARE @ShowClosed		Bit;
DECLARE @ExtraCodes		Bit;
DECLARE @UserIsAdmin	Bit;
DECLARE @ShowVchKind0	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE	@UserID			Int;

DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhereT	NVarChar(max);
DECLARE @StrWhereV	NVarChar(max);
DECLARE @StrWhereP	NVarChar(max);
DECLARE @StrWhereA	NVarChar(max);
DECLARE @StrHaving	NVarChar(max);
DECLARE @StrPartAcntCode	VarChar(21);

DECLARE @iAcntStart	TinyInt;
DECLARE @iAcntLen	TinyInt;
DECLARE @iTempLen	TinyInt;
DECLARE @pPartLen	TinyInt;
DECLARE @pAcntStart	TinyInt;
DECLARE @pAcntLen	TinyInt;

DECLARE @Part1Start	TinyInt;
DECLARE @Part1Len	TinyInt;

DECLARE @Part2Start	TinyInt;
DECLARE @Part2Len	TinyInt;

DECLARE @Part3Start	TinyInt;
DECLARE @Part3Len	TinyInt;

DECLARE @Part4Start	TinyInt;
DECLARE @Part4Len	TinyInt;

DECLARE @PartNo2	TinyInt;
DECLARE @LevelNo2	TinyInt;
DECLARE @FltrAcntCode	varchar(max);
DECLARE @Desc			NVarChar(max);
DECLARE @ZeroStart		TinyInt;
DECLARE	@Auto				Bit; 
DECLARE	@Manu				Bit; 
DECLARE	@Sharing			Bit; 
DECLARE	@OldSerialNoFr		int ;
DECLARE @OldSerialNoTo		int ;
DECLARE @TaxType			int ;
DECLARE @ShowCurrency		bit ;
DECLARE @CurrencyTypeID		int ;
DECLARE	@SourceProcessNo	VARCHAR(30);

BEGIN -- ============================ S T A R T =====================================================

	SET NOCOUNT ON;
	
	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	If (@SortFields is null)	SET @SortFields = 'AcntCode';
	IF (@RepOptions Is Null)	SET @RepOptions = '0011101';

	IF (@SelectedAcnt1 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID			 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			 = pub.funSplitString(@RepInfo, '@', 4);
	SET @FltrAcntCode	 = pub.funSplitString(@RepInfo, '@', 6);
	SET @Desc			 = pub.funSplitString(@RepInfo, '@', 7);
	SET @ZeroStart		 = pub.funSplitString(@RepInfo, '@', 8);
	SET @OldSerialNoFr	 = pub.funSplitString(@RepInfo, '@', 9);
	SET @OldSerialNoTo	 = pub.funSplitString(@RepInfo, '@', 10);
	SET @TaxType		 = pub.funSplitString(@RepInfo, '@', 11);
	SET @ShowCurrency	 = pub.funSplitString(@RepInfo, '@', 12);
	SET @CurrencyTypeID	 = pub.funSplitString(@RepInfo, '@', 13);
	SET @SourceProcessNo = pub.funSplitString(@RepInfo, '@', 14);

--select @PartNo2,@LevelNo2,@FltrAcntCode
	SET @ZeroRemain	= Substring(@RepOptions, 1, 1)
	SET @ZeroCycles	= Substring(@RepOptions, 2, 1)
	SET @ShowPrimar = Substring(@RepOptions, 3, 1)
	SET @ShowFinish	= Substring(@RepOptions, 4, 1)
	SET @ShowClosed	= Substring(@RepOptions, 5, 1)
	SET @ExtraCodes	= Substring(@RepOptions, 6, 1)
	SET @UserIsAdmin= Substring(@RepOptions, 7, 1)
	SET @ShowVchKind0= Substring(@RepOptions, 8, 1)
	SET @Auto		= Substring(@RepOptions, 9, 1)
	SET @Manu		= Substring(@RepOptions, 10, 1)
	SET @Sharing	= Substring(@RepOptions, 11, 1)
	 
	-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
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
	---- CALC LEN ----
	IF (@PartNo=1)
	BEGIN
		SET @iTempLen = 0
		SET @pAcntStart = @Part1Start
	END
		
	ELSE IF (@PartNo=2)
	BEGIN
		SET @iTempLen = @Part1Start + @Part1Len
		SET @pAcntStart = @Part2Start
	END

	ELSE IF (@PartNo=3)
	BEGIN
		SET @iTempLen = @Part2Start + @Part2Len
		SET @pAcntStart = @Part3Start
	END

	ELSE IF (@PartNo=4)
	BEGIN
		SET @iTempLen = @Part3Start + @Part3Len
		SET @pAcntStart = @Part4Start
	END

	SET @pAcntLen = pub.funLayerSum('acc.tblAcnt', @PartNo, @LevelNo)
	SET @iAcntLen = @iTempLen + @pAcntLen
	SET @iAcntStart = 1
	
	PRINT @pAcntStart
	PRINT @pAcntLen

	--------  LAYERS LEN END  ---------------------------------------------------
	-------- CASE WHEN CLAUSE ---------------------------------------------------
	DECLARE @StrDebit	NVarChar(1000);
	DECLARE @StrCredit	NVarChar(1000);
	
	IF (@DocDateFr Is Null) AND (@SerialNoFr Is Null)
	BEGIN                            --(Date = null & Serial = null)
		SET @StrDebit  = 'CASE WHEN (VchKind=2) THEN Debit  Else 0 End '
		SET @StrCredit = 'CASE WHEN (VchKind=2) THEN Credit Else 0 End '
	END
	ELSE IF (@DocDateFr Is Not Null) AND (@SerialNoFr Is Null)
	BEGIN                            --(Date <> null & Serial = null)
		SET @StrDebit   = 'CASE WHEN DocDate < ''' + @DocDateFr + ''' OR (VchKind = 2 AND DocDate=''' + @DocDateFr + ''') THEN Debit  Else 0 End '
		SET @StrCredit  = 'CASE WHEN DocDate < ''' + @DocDateFr + ''' OR (VchKind = 2 AND DocDate=''' + @DocDateFr + ''')  THEN Credit Else 0 End '
	END
	ELSE IF (@DocDateFr Is Null) AND (@SerialNoFr Is Not Null)
	BEGIN                            --(Date = null & Serial <> null) 
		SET @StrDebit   = 'CASE WHEN SerialNo < ' + LTrim(Str(@SerialNoFr)) + '  OR (VchKind = 2 AND SerialNo = ' + LTrim(Str(@SerialNoFr)) + ') THEN Debit  Else 0 End '
		SET @StrCredit  = 'CASE WHEN SerialNo < ' + LTrim(Str(@SerialNoFr)) + '  OR (VchKind = 2 AND SerialNo = ' + LTrim(Str(@SerialNoFr)) + ') THEN Credit Else 0 End '
	END
	ELSE -- (DateFrom <> Null  &  SerialNoFrom <> null)
	BEGIN
		SET @StrDebit   = 'CASE WHEN (DocDate < ''' + @DocDateFr + ''' OR (VchKind = 2 AND DocDate=''' + @DocDateFr + ''')) AND (SerialNo < ' + LTrim(Str(@SerialNoFr)) + '  OR (VchKind = 2 AND SerialNo = ' + LTrim(Str(@SerialNoFr)) + ')) THEN Debit  Else 0 End'
		SET @StrCredit  = 'CASE WHEN (DocDate < ''' + @DocDateFr + ''' OR (VchKind = 2 AND DocDate=''' + @DocDateFr + ''')) AND (SerialNo < ' + LTrim(Str(@SerialNoFr)) + '  OR (VchKind = 2 AND SerialNo = ' + LTrim(Str(@SerialNoFr)) + ')) THEN Credit Else 0 End '
	END
	
	------ CASE WHEN END -----------------------------------------------------

	------ WHERE CLAUSE ------------------------------------------------------
	SET @StrWhereA = '(1=1)';
	SET @StrWhereP = '';
	
	SET @StrWhereV = ' 1=1 AND Len(AcntCode) >= ' + LTrim(Str(@iTempLen))

	IF (@ShowPrimar = 0)
		SET @StrWhereV = @StrWhereV + ' AND (VchKind<>2)'
	IF (isnull(@CurrencyTypeID ,0)<>0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CurrencyTypeID, 'CurrencyTypeID')
	IF (@ShowFinish = 0)
		Set @StrWhereV = @StrWhereV + ' AND (VchKind<>3)'
	IF (@ShowClosed = 0)
		Set @StrWhereV = @StrWhereV + ' AND (VchKind<>4)'
	IF (@ShowVchKind0 = 0)
		Set @StrWhereV = @StrWhereV + ' AND (VchKind<>0)'
	IF (@Auto = 0) 
		SET @StrWhereV = @StrWhereV + ' AND (IsAutoDoc <> 1)' 
	IF (@Manu = 0) 
		SET @StrWhereV = @StrWhereV + ' AND (IsAutoDoc <> 0)' 
	IF @Sharing=0
		SET @StrWhereV = @StrWhereV + ' AND (SourceDocType <> 6)' 
	IF (@ExtraCodes <> 1)
	BEGIN
		DECLARE @P1L1	int;
		SELECT @P1L1 = [pub].[funLayerSum]('acc.tblAcnt', 1, 1)

		SET @StrWhereV = @StrWhereV  + ' AND Substring(AcntCode, 1, ' + LTrim(Str(@P1L1)) + ') not in (SELECT AcntCode 
																									   FROM acc.tblAcnt 
																									   WHERE (PartNumber=1) 
																									     AND (AcntType in (91,92)))'
	END
 
  -- Date To --
	IF (@DocDateTo Is Not Null)
		SET @StrWhereV = @StrWhereV + ' AND (DocDate <= ''' + @DocDateTo + ''')'
  
	IF (@SerialNoFr Is Not Null)
		SET @StrWhereV = @StrWhereV + ' AND (SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	IF (@SerialNoTo Is Not Null)
		SET @StrWhereV = @StrWhereV + ' AND (SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'

	IF (@OldSerialNoFr Is Not Null  and @OldSerialNoFr <>0)
		SET @StrWhereV = @StrWhereV + ' AND (OldSerialNo >= ' + LTrim(Str(@OldSerialNoFr)) + ')'
	IF (@OldSerialNoTo Is Not Null  and @OldSerialNoTo <>0)
		SET @StrWhereV = @StrWhereV + ' AND (OldSerialNo <= ' + LTrim(Str(@OldSerialNoTo)) + ')'

	IF (@SelectedAcnt1 > 0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhereV = @StrWhereV + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	IF (@AcntCode1 is not null)
		Set @StrWhereA = @StrWhereA + ' AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(Len(@AcntCode1))) + ') = ''' + LTrim(@AcntCode1) + ''' '
	IF (@AcntCode2 is not null)
		Set @StrWhereA = @StrWhereA + ' AND Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(Len(@AcntCode2))) + ') = ''' + LTrim(@AcntCode2) + ''' '
	IF (@AcntCode3 is not null)
		Set @StrWhereA = @StrWhereA + ' AND Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(Len(@AcntCode3))) + ') = ''' + LTrim(@AcntCode3) + ''' '
	IF (@AcntCode4 is not null)
		Set @StrWhereA = @StrWhereA + ' AND Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(Len(@AcntCode4))) + ') = ''' + LTrim(@AcntCode4) + ''' '
				
	If (@SourceProcessNo <> '0')
	begin
		Declare @DistributionSourceProcessNo AS varchar(2)
		SET @DistributionSourceProcessNo = '0'
	
		SELECT @DistributionSourceProcessNo = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DistributionSourceProcessNo'

		IF @DistributionSourceProcessNo<>'0' AND @DistributionSourceProcessNo=@SourceProcessNo
			SET @SourceProcessNo = @SourceProcessNo + ',10' 
		--If (@Manu = 1) 
		--	SET @StrWhere = @StrWhere  + ' AND ((IsAutoDoc = 0) OR SourceProcessNo = ' + LTrim(STR(@SourceProcessNo)) + ')'
		--Else
			SET @StrWhereV = @StrWhereV  + ' AND (SourceProcessNo IN (' + @SourceProcessNo + '))'
	end

	BEGIN TRY
		DROP TABLE #tblAcntCode
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(21)collate arabic_cs_as null
	)

	INSERT INTO #tblAcntCode (AcntCode)
	SELECT Distinct AcntCode		
	FROM acc.tblVoucherDtl 

	SET @StrWhereP = ''
	IF @UserIsAdmin=0
	BEGIN
		EXEC pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		SET @StrWhereP =  ' AND D.AcntCode in (SELECT AcntCode 
											   FROM  #tblAcntCode ) '
	END

	--Set @StrWhere = @StrWhere + ' and ' + @StrWhereA + @StrWhereP

	----- WHERE CLAUSE END ------------------------------------------------------

	----- HAVING CLAUSE ---------------------------------------------------------
	SET @StrHaving = '(1=1)'

	IF (@DebitRemainFr Is Not Null)
		SET @StrHaving = @StrHaving + ' AND Sum(Debit)-Sum(Credit) >= ' + LTrim(Str(@DebitRemainFr,16))

	IF (@DebitRemainTo Is Not Null)
		SET	@StrHaving = @StrHaving + ' AND Sum(Debit)-Sum(Credit) <= ' + LTrim(Str(@DebitRemainTo,16))

	IF (@CreditRemainFr Is Not Null)
		SET @StrHaving = @StrHaving + ' AND	Sum(Credit)-Sum(Debit) >= ' + LTrim(Str(@CreditRemainFr,16))

	IF (@CreditRemainTo Is Not Null)
		SET @StrHaving = @StrHaving + ' AND Sum(Credit)-Sum(Debit) <= ' + LTrim(Str(@CreditRemainTo,16))
	
	IF (@DebitCycleFr Is Not Null)
		SET @StrHaving = @StrHaving + ' AND Sum(Debit) >= ' + LTrim(Str(@DebitCycleFr,16))

	IF (@DebitCycleTo Is Not Null)
		SET @StrHaving = @StrHaving + ' AND Sum(Debit) <= ' + LTrim(Str(@DebitCycleTo,16))

	IF (@CreditCycleFr Is Not Null)
		SET @StrHaving = @StrHaving + ' AND Sum(Credit) >= ' + LTrim(Str(@CreditCycleFr,16))

	-- Credit Cycle To
	IF (@CreditCycleTo Is Not Null)
		SET @StrHaving = @StrHaving + ' AND Sum(Credit) <= ' + LTrim(Str(@CreditCycleTo,16))	

------------------------------------------------------------------------------------------
--select @StrWhere 
	IF (@FltrAcntCode is not null)
		SET @StrWhereV = @StrWhereV + @FltrAcntCode
	IF (@Desc is not null and @Desc  <>'')
		SET @StrWhereV = @StrWhereV + ' AND (RecDesc like N''%'+ @Desc +'%'' OR RecDesc2 LIKE N''%'+ @Desc +'%'' ) '

	SET @StrWhereT='1=1'
	IF (@TaxType <>-1)
		SET @StrWhereT = @StrWhereT + ' AND (Tax_Type='+ str(@TaxType) +' ) '		
	
------------------------------------------------------------------------------------------
	--===== SELECT CLAUSE =======================================================
 

		BEGIN TRY
			DROP TABLE #AC
			DROP TABLE #AC2

		END TRY
		BEGIN CATCH
		END CATCH

		SELECT TOP 0 AcntCode,
				   ISNULL(SUM(Debit) ,0.0) AS DebitStart, 
				   ISNULL(SUM(Credit) ,0.0) AS CreditStart,
				   ISNULL(SUM(Debit) ,0.0) - ISNULL(SUM(Debit),0.0) DebitBase,
				   ISNULL(SUM(Credit) ,0.0) - ISNULL(SUM(Credit ),0.0) CreditBase,
				   ISNULL(SUM(Debit) ,0.0) SumDebit, 
				   ISNULL(SUM(Credit) ,0) SumCredit,
				   ISNULL(CASE WHEN SUM(Debit) > SUM(Credit) THEN SUM(Debit) - SUM(Credit) ELSE 0 END,0)RemainDebit,
				   ISNULL(CASE WHEN SUM(Debit) < SUM(Credit) THEN SUM(Credit) - SUM(Debit) ELSE 0 END,0)RemainCredit,
				   CurrencyTypeID,
				   RecDesc CurrencyTypeName
		INTO #AC
		FROM acc.tblVoucherDtl 
		GROUP BY AcntCode,CurrencyTypeID,RecDesc
	
	IF @ShowCurrency='True'
		SET @StrSelect = '
			INSERT INTO  #AC
			SELECT CAST(Substring(AcntCode, ' + LTrim(Str(@pAcntStart)) + ', ' + LTrim(Str(@pAcntLen)) + ') AS VarChar(21)) AS AcntCode,
				   ISNULL(SUM('+ @StrDebit + ') ,0) AS DebitStart, 
				   ISNULL(SUM(' + @StrCredit + ') ,0) AS CreditStart,
				   ISNULL(SUM(Debit) ,0) - ISNULL(SUM('+ @StrDebit + ') ,0) DebitBase,
				   ISNULL(SUM(Credit) ,0) - ISNULL(SUM(' + @StrCredit + ') ,0) CreditBase,
				   ISNULL(SUM(Debit) ,0) SumDebit, 
				   ISNULL(SUM(Credit) ,0) SumCredit,
				   ISNULL(CASE WHEN SUM(Debit) > Sum(Credit) THEN SUM(Debit) - SUM(Credit) ELSE 0 END,0)RemainDebit,
				   ISNULL(CASE WHEN SUM(Debit) < Sum(Credit) THEN SUM(Credit) - SUM(Debit) ELSE 0 END,0)RemainCredit,
				   CurrencyTypeID, 
				   pub.funGetCurrencyTypesName(CurrencyTypeID,1) CurrencyTypeName
			 FROM (SELECT SerialNo,
						  RowNo,
						  SourceProcessID,
						  SourceProcessNo,
						  SourceFiscalYear,
						  SourceSerialNo,
						  DocDate,
						  AcntCode,
						  RecDesc,
						  RecDesc2,
						  IsAutoDoc,
						  SessionNo,
						  VchKind,
						  DocRowNo,
						  SourceDocType,
						  IsShowDetail,
						  CurrencyAmount,
						  Emphasize,
						  CurrencyTypeID,
						  SourceCodeFieldValue,
						  Emphasize2,
						  Emphasize3,
						  SourceSerialNo1,
						  SourceRowNo,
						  ID,
						  BaseID,
						  VisitorAcntCode, 
						  CASE WHEN Debit = 0 THEN 0 ELSE CurrencyAmount END Debit, 
						  CASE WHEN Credit = 0 THEN 0 ELSE CurrencyAmount END Credit 
				   FROM acc.tblVoucherDtl
				   WHERE CurrencyAmount>0) D
			INNER JOIN (SELECT SerialNo NewSerialNo,
							   OldSerialNo 
						FROM acc.tblVoucherHdr 
						WHERE '+@StrWhereT+') H on D.SerialNo = H.NewSerialNo
			WHERE ' + @StrWhereV + @StrWhereP + '
			GROUP BY Substring(AcntCode, ' + LTrim(Str(@pAcntStart)) + ', ' + LTrim(Str(@pAcntLen)) + ') , CurrencyTypeID
			HAVING    ' + @StrHaving
	ELSE
	BEGIN
		SELECT D.*,H.OldSerialNo,Tax_Type into #t
		FROM acc.tblVoucherDtl D
		INNER JOIN acc.tblVoucherHdr H  on D.SerialNo=H.SerialNo

		SET @StrSelect = '
			INSERT INTO  #AC
			SELECT Cast(Substring(AcntCode, ' + LTrim(Str(@pAcntStart)) + ', ' + LTrim(Str(@pAcntLen)) + ') AS VarChar(21)) AS AcntCode,
				   ISNULL(SUM('+ @StrDebit + ') ,0) AS DebitStart, 
				   ISNULL(SUM(' + @StrCredit + ') ,0) AS CreditStart,
				   ISNULL(SUM(Debit) ,0) - ISNULL(SUM('+ @StrDebit + ') ,0) DebitBase,
				   ISNULL(SUM(Credit) ,0) - ISNULL(SUM(' + @StrCredit + ') ,0) CreditBase,
				   ISNULL(SUM(Debit) ,0) SumDebit, 
				   ISNULL(SUM(Credit) ,0) SumCredit,
				   ISNULL(CASE WHEN SUM(Debit) > SUM(Credit) THEN SUM(Debit) - SUM(Credit) ELSE 0 END, 0)RemainDebit,
				   ISNULL(CASE WHEN SUM(Debit) < SUM(Credit) THEN SUM(Credit) - SUM(Debit) ELSE 0 END, 0)RemainCredit,
				   '''' CurrencyTypeID,
				   '''' CurrencyTypeName
			FROM #t D
			WHERE ' + @StrWhereV + @StrWhereP + ' AND ' + @StrWhereT+' 
			GROUP BY Substring(AcntCode, ' + LTrim(Str(@pAcntStart)) + ', ' + LTrim(Str(@pAcntLen)) + ') 
			HAVING    ' + @StrHaving

	END
	PRINT @StrSelect;	
	EXEC sp_executesql @StrSelect;
	
	SELECT a.AcntCode,AcntName INTO  #AC2 
	FROM acc.tblAcnt a 
	INNER JOIN acc.tblAcntDtl b ON a.AcntCode = b.AcntCode 
							   AND a.PartNumber = b.PartNumber
							   AND b.LanguageID = 1
	WHERE a.PartNumber = @PartNo 
	  AND len(a.AcntCode) = LTrim(Str(@pAcntLen)) 

	--select @StrWhere
	--select @StrWhereA
	--select @StrWhereP
	DECLARE @strLF Nvarchar(100)
	SET @strLF = ' INNER '
	If (@ZeroCycles = 1)
		SET @strLF = ' LEFT '

	IF @ZeroStart=1
	BEGIN
		SELECT AC.AcntCode, 
			   AC.AcntName, 
			   T.DebitStart, 
			   T.CreditStart, 
			   T.DebitBase, 
			   T.CreditBase, 
			   T.SumDebit, 
			   T.SumCredit, 
			   T.RemainDebit, 
			   T.RemainCredit, 
			   T.CurrencyTypeID, 
			   T.CurrencyTypeName
		INTO #AC2AC
		FROM 
		#AC2 AC
		LEFT JOIN #AC T	
		ON AC.AcntCode = T.AcntCode 
		LEFT JOIN acc.tblAcntDtl A ON A.AcntCode = T.AcntCode 
								  AND A.PartNumber = @PartNo 
		WHERE 1=0
	

		SET @StrSelect = ' 
		INSERT INTO #AC2AC
		SELECT AC.AcntCode,
			   AC.AcntName,
			   0 DebitStart,
			   0 CreditStart,
			   ISNULL(T.DebitBase, 0) DebitBase,
			   ISNULL(T.CreditBase, 0) CreditBase,
			   0 SumDebit,
			   0 SumCredit,
			   ISNULL(T.RemainDebit, 0) RemainDebit,
			   ISNULL(T.RemainCredit, 0) RemainCredit,
			   ISNULL(CurrencyTypeID, '''') CurrencyTypeID,
			   ISNULL(CurrencyTypeName, '''') CurrencyTypeName
		FROM #AC2 AC 
		' + @strLF + 'JOIN #AC T ON AC.AcntCode = T.AcntCode 		
		WHERE ' + @StrWhereA + ' 
		  AND AC.AcntName IS NOT NULL '

		IF (@ZeroRemain = 0) 
			SET @StrSelect = @StrSelect + ' AND (SumDebit <> SumCredit) '
		IF (@ZeroCycles = 0)							  
	 		SET @StrSelect = @StrSelect + ' AND (SumDebit <> 0 OR SumCredit <> 0) '	
		SET @StrSelect = @StrSelect + ' ORDER BY ' + @SortFields

		PRINT @StrSelect;	
		EXEC sp_executesql @StrSelect;


		 UPDATE #AC2AC 
		 SET RemainDebit = CASE WHEN DebitBase > CreditBase THEN DebitBase - CreditBase ELSE 0 END, 
			 RemainCredit = CASE WHEN DebitBase < CreditBase THEN CreditBase - DebitBase ELSE 0 END
		 
		 SET @StrSelect =  'SELECT * FROM #AC2AC'

		 PRINT @StrSelect;	
		 EXEC sp_executesql @StrSelect;
		
	END
	ELSE
	BEGIN
	 
		SET @StrSelect = '
		SELECT AC.AcntCode,
			   AC.AcntName,
			   ISNULL(T.DebitStart, 0) DebitStart,
			   ISNULL(T.CreditStart, 0) CreditStart,
			   ISNULL(T.DebitBase, 0) DebitBase,
			   ISNULL(T.CreditBase, 0) CreditBase,
			   ISNULL(T.SumDebit, 0) SumDebit,
			   ISNULL(T.SumCredit, 0) SumCredit,
			   ISNULL(T.RemainDebit, 0) RemainDebit,
			   ISNULL(T.RemainCredit, 0) RemainCredit,
			   ISNULL(CurrencyTypeID, '''') CurrencyTypeID,
			   ISNULL(CurrencyTypeName, '''') CurrencyTypeName
		FROM #AC2  AC 
		' + @strLF + 'JOIN #AC T ON AC.AcntCode = T.AcntCode 
		WHERE  ' + @StrWhereA 	+' AND AC.AcntName IS NOT NULL '	
		IF (@ZeroRemain = 0) 
			SET @StrSelect = @StrSelect + ' AND (SumDebit <> SumCredit) '
		IF (@ZeroCycles = 0)
			SET @StrSelect = @StrSelect + ' AND (SumDebit <> 0 OR SumCredit <> 0) '	
		SET @StrSelect = @StrSelect + ' ORDER BY ' + @SortFields

		PRINT @StrSelect;	
		EXEC sp_executesql @StrSelect;

	END 
END
GO
