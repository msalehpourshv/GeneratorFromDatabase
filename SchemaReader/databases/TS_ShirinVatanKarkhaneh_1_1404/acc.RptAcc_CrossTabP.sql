USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H Sadeghi
-- Create date   :1400/10/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
Create PROCEDURE [acc].[RptAcc_CrossTabP]
	@SerialNoFr			int = 1,
	@SerialNoTo			int = 10,
	@SerialOldFr		int = Null,
	@SerialOldTo		int = Null,
	@DocDateFr			char(10) = Null,
	@DocDateTo			char(10) = Null,
	@AutoN				tinyint=0,
	@SortByOldSrl		Bit=0,
	@SourceProcessNo	tinyint = 0,
	@AcntCode1			Int = 0,
	@AcntCode2			Int = 0,
	@AcntCode3			Int = 0,
	@AcntCode4			Int = 0,
	@RepOptions			varchar(20) = '0000011000100',
	@RepInfo			nvarchar(100) = '1@1@1',
	@ExtraParams		nvarChar(200) = ''
WITH ENCRYPTION
AS
-- DECLARE Variables ------------
DECLARE @Part1 tinyint
DECLARE @Part2 tinyint
DECLARE @Part3 tinyint
DECLARE @Part4 tinyint

DECLARE @SourceProcessID varchar(100)
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;

DECLARE @UserName		NVarChar(4000)
DECLARE @UserFullName	NVarChar(4000)

DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;

SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);

CREATE TABLE #tblAcntCode
		(
		AcntCode 			Varchar(20)collate arabic_cs_as null
		)	

DECLARE	@StrQuery		NVarChar(2000);
DECLARE	@StrWhere		NVarChar(1000);
DECLARE	@LayerNumber	TinyInt;

BEGIN ---------------------------------------------------------------------
	SET NOCOUNT ON;


	SET @SourceProcessID = pub.funSplitString(@ExtraParams, '#', 1);
	SET @UserFullName	 = pub.funSplitString(@ExtraParams, '#', 2);
	SET @UserName		 = pub.funSplitString(@ExtraParams, '#', 3);	

	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '00000110100';

	if LEN(@RepOptions) > 11
		SET @SourceProcessNo= Substring(@RepOptions, 12, 1)
	else
		SET @SourceProcessNo= '0'
	---------------------------------------------------------

	--========= < W H E R E > =======================================================
		
	SET @StrWhere = '(D.VchKind <> 0)';

	if (@SourceProcessID <> '')
		SET @StrWhere = @StrWhere  + ' AND (D.SourceProcessID in (' + LTrim(@SourceProcessID) + '))'

	If (@SourceProcessNo <>'0')
	begin
		Declare @DistributionSourceProcessNo AS varchar(2)
		SET @DistributionSourceProcessNo = '0'
	
		SELECT @DistributionSourceProcessNo = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DistributionSourceProcessNo'

		IF @DistributionSourceProcessNo<>'0' AND @DistributionSourceProcessNo=@SourceProcessNo
			SET @SourceProcessNo = @SourceProcessNo + ',10' 

		If (@AutoN = 2) 
			SET @StrWhere = @StrWhere  + ' AND (D.IsAutoDoc = 1) '
		Else IF (@AutoN =3) 
			SET @StrWhere = @StrWhere  + ' AND (D.IsAutoDoc = 0) '
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

	IF (@AcntCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode1, 'D.AcntCode')
	IF (@AcntCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode2, 'D.AcntCode')
	IF (@AcntCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode3, 'D.AcntCode')
	IF (@AcntCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @AcntCode4, 'D.AcntCode')

	SELECT	@Part1 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 1 AND TableName = 'acc.tblAcnt'

	SELECT	@Part2 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 2 AND TableName = 'acc.tblAcnt'

	SELECT	@Part3 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 3 AND TableName = 'acc.tblAcnt'

	SELECT	@Part4 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 4 AND TableName = 'acc.tblAcnt'

	DECLARE @Acnt1 as varchar(100) ='LEFT(D.AcntCode,'+ STR(@Part1) +') '
	DECLARE @Acnt2 as varchar(100)
	DECLARE @Acnt3 as varchar(100)
	DECLARE @Acnt4 as varchar(100)

	IF @Part2>0
		SET @Acnt2 ='SUBSTRING(D.AcntCode,' + str(@Part1 +2) + ','+ str(@Part2) +') '
	ELSE
		SET @Acnt2 =''''' '

	IF @Part2>0
		SET @Acnt3 ='SUBSTRING(D.AcntCode,' + str(@Part1+@Part2 +3) + ','+ str(@Part3) +') '
	ELSE
		SET @Acnt3 =''''' '

	IF @Part2>0
		SET @Acnt4 ='SUBSTRING(D.AcntCode,' + str(@Part1+@Part2+@Part3 +4) + ','+ str(@Part4) +') '
	ELSE
		SET @Acnt4 =''''' '
	--============ < S E L E C T > ==================================================

CREATE TABLE #tblAll
(
	SerialNo	Int	Null,
	DocDate		Char(10),
	AcntCode	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	AcntCode1	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	AcntCode2	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	AcntCode3	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	AcntCode4	VarChar(20) COLLATE Arabic_CS_AS Not Null,
	Debit		float Not Null,
	Credit		float Not Null,
	Amount		float Not Null,
	DocDesc	NVarChar(max) COLLATE Arabic_CS_AS Null,
	DocDesc2	NVarChar(max) COLLATE Arabic_CS_AS Null,
	RecDesc	NVarChar(max) COLLATE Arabic_CS_AS Null,
	RecDesc2	NVarChar(max) COLLATE Arabic_CS_AS Null,
	DC_State	TinyInt, -- 0 = Debit, 1 = Credit
	OldSerialNo	Int	Null
);

	SET @StrQuery = '
		INSERT INTO	#tblAll
		SELECT	D.SerialNo, D.DocDate,D.AcntCode,' +  @Acnt1 + ' AcntCode1,' +  @Acnt2 + ' AcntCode2,' +  @Acnt3 + ' AcntCode3,' +  @Acnt4 + ' AcntCode1,
				Debit,Credit,(Debit-Credit) Amount,H.DocDesc,H.DocDesc2,RecDesc,RecDesc2,
				CASE WHEN (Debit <> 0) Then 0 Else 1 End AS DC_State, H.OldSerialNo
		FROM	acc.tblVoucherDtl  D 
		INNER JOIN acc.tblVoucherHdr H ON D.SerialNo = H.SerialNo 
		WHERE	' + @StrWhere 
	
	print @StrQuery;
	Exec sp_executesql @StrQuery;
		
if @UserIsAdmin=0
	begin
		
		Insert into  #tblAcntCode (AcntCode)	SELECT Distinct AcntCode	FROM  #tblAll
				
		exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
	
		--حذف ردیف های سند که کاربر دسترسی ندارد

		delete  from #tblAll where AcntCode not in ( select AcntCode from #tblAcntCode )

	end

	if @SortByOldSrl = 0
		SELECT	R.*, pub.GetCodeName(AcntCode, 1) AS AcntName, 
				[acc].[funGetAcntName](AcntCode1 , 1,1) AcntName1,[acc].[funGetAcntName](AcntCode2, 2,1) AcntName2,
				[acc].[funGetAcntName](AcntCode3, 3,1) AcntName3,[acc].[funGetAcntName](AcntCode4,4,1) AcntName4,
				@UserFullName UserFullName, @UserName PrintUserName, 
				pub.funFarsiDate(GETDATE()) PrintDate
		FROM	#tblAll R
		Order By R.SerialNo,R.DC_State, R.AcntCode
	else
		SELECT	R.*, pub.GetCodeName(AcntCode, 1) AS AcntName, 
				[acc].[funGetAcntName](AcntCode1 , 1,1) AcntName1,[acc].[funGetAcntName](AcntCode2, 2,1) AcntName2,
				[acc].[funGetAcntName](AcntCode3, 3,1) AcntName3,[acc].[funGetAcntName](AcntCode4,4,1) AcntName4,
				@UserFullName UserFullName, @UserName PrintUserName, 
				pub.funFarsiDate(GETDATE()) PrintDate,Tax_Type
		FROM	#tblAll R
        LEFT JOIN acc.tblVoucherHdr H on H.SerialNo=R.SerialNo 
		Order By R.OldSerialNo,R.DC_State, R.AcntCode
	
END
GO
