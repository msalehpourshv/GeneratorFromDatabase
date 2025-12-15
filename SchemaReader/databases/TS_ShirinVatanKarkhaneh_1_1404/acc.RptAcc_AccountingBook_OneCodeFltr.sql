USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : Takrosystem\Zia
-- Create date   : 1386/12/19
-- Viewed By	 : 
-- Last Modified : 1393/06/06
-- Description	 : < دفتر حسابداری یک کد حسابداری >
-- =============================================
Create PROCEDURE [acc].[RptAcc_AccountingBook_OneCodeFltr]
	@FullAcntCode	VarChar(21),
	@SerialNoFr		int = 0,
	@SerialNoTo		int = 999999999,
	@DocDateFr		char(10) = '0000/00/00',
	@DocDateTo		char(10) = '9999/99/99',
	@SelectedAcnt1		int = 0,
	@SelectedAcnt2		int = 0,
	@SelectedAcnt3		int = 0,
	@SelectedAcnt4		int = 0,
	@RepOptions		varchar(21) = '0011101',
	@RepInfo		NVarChar(1000) = '1=1@1@1'
WITH ENCRYPTION
AS
BEGIN

IF @SerialNoTo = 999999
	set @SerialNoTo = 999999999
IF (@RepInfo Is Null)		SET @RepInfo = '1=1@1@1@1@1@1@1@1@1';
IF (@RepOptions Is Null)	SET @RepOptions = '0011101';

Declare @FltrAcntCode	varchar(2000);
Declare	@LevelNo		int = 0;
Declare @StrWhereA	NVarChar(max);
Declare @StrWhereT	NVarChar(max);
Declare @Desc	NVarChar(max);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE	@UserID			Int;
DECLARE	@DebitFrom		Int;
DECLARE	@DebitTo		Int;
DECLARE	@CreditFrom		Int;
DECLARE	@CreditTo		Int;

Declare @Part1Start	TinyInt;
Declare @Part1Len	TinyInt;
Declare @Part2Start	TinyInt;
Declare @Part2Len	TinyInt;
Declare @Part3Start	TinyInt;
Declare @Part3Len	TinyInt;
Declare @Part4Start	TinyInt;
Declare @Part4Len	TinyInt;

Declare @StrWhereP	NVarChar(max);

Declare @ShowPrimar		Bit;
Declare @ShowFinish		Bit;
Declare @ShowClosed		Bit;
Declare @ExtraCodes		Bit;
Declare @UserIsAdmin	Bit;
Declare @ShowVchKind0	Bit;
DECLARE	@Auto				Bit; 
DECLARE	@Manu				Bit; 
DECLARE	@Sharing			Bit; 
DECLARE	@OldSerialNoFr		int ;
DECLARE	@OldSerialNoTo		int;
DECLARE	@TaxType			int;
DECLARE @CurrencyTypeID		int ;
DECLARE @SortFields			NVarChar(100);
Declare @ShowFullName		Bit;

	SET @ShowPrimar = Substring(@RepOptions, 3, 1)
	SET @ShowFinish	= Substring(@RepOptions, 4, 1)
	SET @ShowClosed	= Substring(@RepOptions, 5, 1)
	SET @ExtraCodes	= Substring(@RepOptions, 6, 1)
	SET @UserIsAdmin= Substring(@RepOptions, 7, 1)
	SET @ShowVchKind0= Substring(@RepOptions, 8, 1)
	SET @Auto		= Substring(@RepOptions, 9, 1)
	SET @Manu		= Substring(@RepOptions, 10, 1)
	SET @Sharing	= Substring(@RepOptions, 11, 1)

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);	
	SET @FltrAcntCode	= pub.funSplitString(@RepInfo, '@', 6);
   	SET @Desc			= pub.funSplitString(@RepInfo, '@', 7);
   	SET @SortFields		= pub.funSplitString(@RepInfo, '@', 8);
   	SET @DebitFrom		= pub.funSplitString(@RepInfo, '@', 9);
   	SET @DebitTo		= pub.funSplitString(@RepInfo, '@', 10);
   	SET @CreditFrom		= pub.funSplitString(@RepInfo, '@', 11);
   	SET @CreditTo		= pub.funSplitString(@RepInfo, '@', 12);
   	SET @OldSerialNoFr	= pub.funSplitString(@RepInfo, '@', 13);
   	SET @OldSerialNoTo	= pub.funSplitString(@RepInfo, '@', 14);
   	SET @TaxType		= pub.funSplitString(@RepInfo, '@', 15);
	SET @CurrencyTypeID	= pub.funSplitString(@RepInfo, '@', 16);
	SET @ShowFullName	= pub.funSplitString(@RepInfo, '@', 17);

	set @Desc = REPLACE(@Desc,NCHAR(1610),NCHAR(1740))
	set @Desc = REPLACE(@Desc,NCHAR(1603),NCHAR(1705))

   	if @OldSerialNoTo=0
		set @OldSerialNoTo=99999999
	
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


	SELECT @LevelNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	--select @PartNo1,@PartNo2
	SET NOCOUNT ON;
set @StrWhereA ='  '
If (@SelectedAcnt1 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'V.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'V.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'V.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'V.AcntCode')

	if (@Desc is not null and @Desc  <>'')
			Set @StrWhereA = @StrWhereA + ' and   (RecDesc like N''%'+ @Desc +'%''  or RecDesc2 like N''%'+ @Desc +'%'') '
----------------------------------------------------------------------------------------------------------------------

	SET @StrWhereP = '';		
	BEGIN TRY
		DROP TABLE #tblAcntCode
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(21)collate arabic_cs_as null
	)
	Insert into  #tblAcntCode (AcntCode)				SELECT Distinct AcntCode		FROM acc.tblVoucherDtl 

	if @UserIsAdmin=0
	begin
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		SET @StrWhereP =  ' and AcntCode in (SELECT AcntCode FROM  #tblAcntCode ) '
	END
	----------------------------------------------------------------------------------------------------------------------
	If (@ShowPrimar = 0)
		Set @StrWhereA = @StrWhereA + ' AND (VchKind<>2)'

	If (isnull(@CurrencyTypeID ,0)<>0)
			SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CurrencyTypeID, 'CurrencyTypeID')
	
	If (@ShowFinish = 0)
		Set @StrWhereA = @StrWhereA + ' AND (VchKind<>3)'

	If (@ShowClosed = 0)
		Set @StrWhereA = @StrWhereA + ' AND (VchKind<>4)'
	
	If (@ShowVchKind0 = 0)
		Set @StrWhereA = @StrWhereA + ' AND (VchKind<>0)'
	
	If (@Auto = 0) 
		SET @StrWhereA = @StrWhereA + ' AND (IsAutoDoc <> 1)' 
	If (@Manu = 0) 
		SET @StrWhereA = @StrWhereA + ' AND (IsAutoDoc <> 0)' 
	if @Sharing=0
		SET @StrWhereA = @StrWhereA + ' AND (SourceDocType <> 6)' 
				
	Declare @StrVchKind2	NVarChar(max);
	if @SerialNoFr<>0 and @DocDateFr ='0000/00/00'	
			set @StrVchKind2	='and ( SerialNo < '+ str(@SerialNoFr) +'  )'	
	if @SerialNoFr=0 and @DocDateFr <>'0000/00/00'	
			set @StrVchKind2	='and ( DocDate < '''+ @DocDateFr +'''   )'	
	if @SerialNoFr<>0 and @DocDateFr <>'0000/00/00'	
			set @StrVchKind2	='and ( SerialNo < '+ str(@SerialNoFr) +' or DocDate < '''+ @DocDateFr +''' )'	

	If (@DebitFrom >0)
		Set @StrWhereA = @StrWhereA + ' AND Debit>='+str(@DebitFrom)+''
	If (@DebitTo >0)
		Set @StrWhereA = @StrWhereA + ' AND Debit<='+str(@DebitTo)+''
	If (@CreditFrom >0)
		Set @StrWhereA = @StrWhereA + ' AND Credit>='+str(@CreditFrom)+''
	If (@CreditTo >0)
		Set @StrWhereA = @StrWhereA + ' AND Credit<='+str(@CreditTo)+''	
		
	if (@ExtraCodes <> 1)
	begin
		declare @P1L1	int;
		select	@P1L1 = [pub].[funLayerSum]('acc.tblAcnt', 1, 1)
		Set @StrWhereA = @StrWhereA  + ' AND Substring(AcntCode, 1, ' + LTrim(Str(@P1L1)) + ') not in (select AcntCode from acc.tblAcnt where (PartNumber=1) and (AcntType in (91,92)))'
	end

	Declare @StrAcntName NVarChar(max) = ''
	Declare @StrAcntNameU NVarChar(max) = ''
	Declare @StrAcnt1Start NVarChar(3)
	Declare @StrAcnt1Len NVarChar(3) 
	Declare @StrAcnt2Start NVarChar(3) 
	Declare @StrAcnt2Len NVarChar(3) 
	Declare @StrAcnt3Start NVarChar(3) 
	Declare @StrAcnt3Len NVarChar(3) 
	Declare @StrAcnt4Start NVarChar(3) 
	Declare @StrAcnt4Len NVarChar(3) 
	if (@ShowFullName = 1)
	begin
		select @StrAcnt1Start = acc.funGetAcntLayerStartandLen(1,1)
		select @StrAcnt1Len = acc.funGetAcntLayerStartandLen(1,2)
		select @StrAcnt2Start = acc.funGetAcntLayerStartandLen(2,1)
		select @StrAcnt2Len = acc.funGetAcntLayerStartandLen(2,2)
		select @StrAcnt3Start = acc.funGetAcntLayerStartandLen(3,1)
		select @StrAcnt3Len = acc.funGetAcntLayerStartandLen(3,2)
		select @StrAcnt4Start = acc.funGetAcntLayerStartandLen(4,1)
		select @StrAcnt4Len = acc.funGetAcntLayerStartandLen(4,2)

		Set @StrAcntName = @StrAcntName + '
		 ,isnull(acc.funPartAcntFullName(SubString(AcntCode,'+@StrAcnt1Start+','+@StrAcnt1Len+'),1),'''') 
		+ isnull(acc.funPartAcntFullName(SubString(AcntCode,'+@StrAcnt2Start+','+@StrAcnt2Len+'),2),'''') 
		+ isnull(acc.funPartAcntFullName(SubString(AcntCode,'+@StrAcnt3Start+','+@StrAcnt3Len+'),3),'''') 
		+ isnull(acc.funPartAcntFullName(SubString(AcntCode,'+@StrAcnt4Start+','+@StrAcnt4Len+'),4),'''')
		AcntFullName'		
		Set @StrAcntNameU = @StrAcntNameU + ','''''
	end
	else
	begin
		Set @StrAcntName = @StrAcntName + ''
		Set @StrAcntNameU = @StrAcntNameU + ''
	end

set @StrWhereT='1=1'
	If (@TaxType <>-1)
		Set @StrWhereT = @StrWhereT + ' and   (Tax_Type='+ str(@TaxType) +' ) '

Declare @StrSelect	NVarChar(max);
	Set @StrSelect = 'select * from (	
		SELECT	
		REPLACE(AcntCode,'' '','' '') AcntCode,
		[acc].[funPartAcntNameRecurcive](AcntCode,'+ str(@LevelNo) +') AcntName'
		+ @StrAcntName + ',
		DocDate, 
		SerialNo ,
		(select OldSerialNo from acc.tblVoucherHdr H where H.SerialNo=V.SerialNo) as OldSerialNo , 
		DocRowNo RowNo, 
		Debit, 
		Credit	, 
		'''' Types, 
		cast( 0  as float )Remain,
		ISNULL(case when Debit =0 then 0 else CurrencyAmount end,0) DebitCurrency , 
		ISNULL(case when Credit =0 then 0 else CurrencyAmount end,0) CreditCurrency 	, 
		'''' TypesCurrency, 
		cast( 0  as float )RemainCurrency, 
		pub.funReverseForCrystal(RecDesc) RecDesc, 
		pub.funReverseForCrystal(RecDesc2) RecDesc2	,
		(select DocDesc2 from acc.tblVoucherHdr H where H.SerialNo=V.SerialNo) as DocDesc2,
		VchKind, 
		DB_NAME() DB_NAME, 
		CurrencyTypeID, 
		pub.funGetCurrencyTypesName(CurrencyTypeID,1)  CurrencyTypeName,
		DocRowNo,
		V.VisitorAcntCode,
		[acc].[funPartAcntNameRecurcive](V.VisitorAcntCode,'+ str(@LevelNo) +') VisitorAcntName
		FROM	acc.tblVoucherDtl V
		inner join ( Select SerialNo NewSerialNo,OldSerialNo from  acc.tblVoucherHdr  where '+@StrWhereT+' ) H  on V.SerialNo=H.NewSerialNo
		WHERE 1=1 
			and (SerialNo >= '+ str(@SerialNoFr) +') 
			and (SerialNo <= '+ str(@SerialNoTo) +')
			and (OldSerialNo >= '+ str(@OldSerialNoFr) +') 
			and (OldSerialNo <= '+ str(@OldSerialNoTo) +')
			and (DocDate >= '''+ @DocDateFr +''') 
			and (DocDate <= '''+ @DocDateTo +''')
			'+ @FltrAcntCode +@StrWhereA+@StrWhereP+ CASE WHEN @DocDateFr='0000/00/00' THEN '' ELSE '
		union  all
		SELECT	
		'''' AcntCode
		,'''' AcntName' 
		+ @StrAcntNameU + '
		,'''' DocDate
		,0 SerialNo
		, 0 OldSerialNo
		,0 RowNo
		, isnull(Sum(Debit) ,0) Debit
		, isnull(Sum(Credit	),0) Credit
		, '''' Types
		, cast( 0  as float ) Remain
		, isnull(Sum(case when Debit =0 then 0 else CurrencyAmount end) ,0) DebitCurrency
		, isnull(Sum(case when Credit =0 then 0 else CurrencyAmount end),0) CreditCurrency
		, '''' TypesCurrency
		, cast( 0  as float )RemainCurrency	
		, ''نقل مانده کد '' RecDesc
		,''نقل مانده کد '' RecDesc2
		,'''' DocDesc2
		,1 VchKind
		, DB_NAME() DB_NAME
		,'''' CurrencyTypeID
		,'''' CurrencyTypeName
		,0 DocRowNo
		,'''' VisitorAcntCode
		,'''' VisitorAcntName
		FROM	acc.tblVoucherDtl V
		WHERE 1=1
		'+@StrVchKind2+ @FltrAcntCode +@StrWhereA+@StrWhereP+' 
		having 	isnull(Sum(Debit) ,0) >0 OR  isnull(Sum(Credit	),0)>0 ' END + '					
		) a ORDER BY '+ @SortFields
	
	print @StrSelect;	
	exec sp_executesql @StrSelect;
	
END
GO
