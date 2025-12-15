USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari	
-- Create date   : 1403/02/13
-- Viewed By	 : 
-- Last Modified : 
-- Last ModifieR : 
-- Description	 : 
-- ==============================================
Create PROCEDURE trs.SpReceivableDocs_UnReceipt_SumFull
	@AcntCode	AS VarChar(20)	
WITH ENCRYPTION
As
DECLARE @StrSQL		NVarChar(1000)
DECLARE @StrParams	NVarChar(500);
DECLARE @StrSelect	NVarChar(MAX)
DECLARE @StrSelect1	NVarChar(MAX)
DECLARE @StrSelect2	NVarChar(MAX)
DECLARE @StrWhare	NVarChar(MAX)
DECLARE @StrTmpl	NVarChar(4000)
DECLARE @StrPrevDB	NVarChar(100)
DECLARE @StrDB		NVarChar(100)
DECLARE @Remain1	Bit;
DECLARE @Remain2	Bit;
DECLARE @Remain3	Bit;
DECLARE @Remain4	Bit;
DECLARE @CntPrtRmin INT
DECLARE @Part1End	INT;
DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;
DECLARE @DocDate	AS Char(10)
Begin 

 
	Set NOCOUNT ON;
	SET @StrSelect1=''
	SET @StrSelect2=''
	SET @StrWhare=''
		
	Set @DocDate=RIGHT(db_name(),4)+'/01/01'

	SET		@Part1Start = 1;
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

	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  TableName = 'acc.tblAcnt' AND PartNumber = 1

	SELECT  @Remain1 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain1'
	SELECT  @Remain2 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain2'
	SELECT  @Remain3 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain3'
	SELECT  @Remain4 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain4'
	
	SET @CntPrtRmin=0;
 
	IF (@Remain1 = 1)
		SET @CntPrtRmin = @CntPrtRmin + 1
	IF (@Remain2 = 1) AND @CntPrtRmin = 1
		SET @CntPrtRmin = @CntPrtRmin + 1
	IF (@Remain3 = 1) AND @CntPrtRmin = 2
		SET @CntPrtRmin = @CntPrtRmin + 1
	IF (@Remain4 = 1) AND @CntPrtRmin = 3
		SET @CntPrtRmin = @CntPrtRmin + 1

		IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CntPrtRmin
			begin
				SET @CntPrtRmin =250  
				SET @Remain1=0
				SET @Remain2=0
				SET @Remain3=0
				SET @Remain4=0
			end 
		else
			SET @CntPrtRmin =0

		set @StrWhare ='   ( '+ str(@CntPrtRmin) +' =0 OR ('+ str(@CntPrtRmin) +'=250 AND  VOL.CreditCode='''+ @AcntCode +'''))		
		AND ( '+ str(@Remain1) +' =0 or ('+ str(@Remain1) +' =1 AND Substring(VOL.CreditCode,'+ str(@Part1Start) +','+ str(@Part1Len) +')=Substring('''+ @AcntCode +''','+ str(@Part1Start) +','+ str(@Part1Len) +')))
		AND ( '+ str(@Remain2) +' =0 or ('+ str(@Remain2) +' =1 AND Substring(VOL.CreditCode,'+ str(@Part2Start) +','+ str(@Part2Len) +')=Substring('''+ @AcntCode +''','+ str(@Part2Start) +','+ str(@Part2Len) +')))
		AND ( '+ str(@Remain3) +' =0 or ('+ str(@Remain3) +' =1 AND Substring(VOL.CreditCode,'+ str(@Part3Start) +','+ str(@Part3Len) +')=Substring('''+ @AcntCode +''','+ str(@Part3Start) +','+ str(@Part3Len) +')))
		AND ( '+ str(@Remain4) +' =0 or ('+ str(@Remain4) +' =1 AND Substring(VOL.CreditCode,'+ str(@Part4Start) +','+ str(@Part4Len) +')=Substring('''+ @AcntCode +''','+ str(@Part4Start) +','+ str(@Part4Len) +')))
		'

	-- اسناد دریافتنی موجود در صندوق و موجود در بانک
	SET @StrSelect = '
	DECLARE @iSumVal AS	BigInt
	SET		@iSumVal = 0.0

	SELECT	@iSumVal = IsNull(Sum(PD.Amount), 0)
	FROM	[trs].tblPayDtl AS PD  with (nolock)
			INNER JOIN 
			(
				SELECT A.*,B.CreditCode FROM 
				(SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
				FROM	[trs].tblPayDtl AS PD2  with (nolock)
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo in (1,2)
				GROUP BY VolumeFiscalYear, VolumeRowNo) A
				,
				(SELECT VolumeFiscalYear, VolumeRowNo,CreditCode 
				 FROM	trs.tblPayDtl VOL with (nolock) 
				 WHERE	ProcessID IN (1,10) 
					AND PayTypeID IN (6,26) 
					AND ' + @StrWhare + '
				) B
				WHERE A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo 
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear 
					AND PD.VolumeRowNo = VOL.VolumeRowNo 
					AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) 
		AND PD.ProcessID IN (1, 10, 17, 20, 21, 23, 40) 
		AND PD.ProcessNo in (1,2) 
		AND ' + @StrWhare + ''

	-- اسناد دریافتنی واگذار شده به اشخاص
	SET @StrTmpl = '
	SELECT	@iSumVal = @iSumVal + ISNull(Sum(PD.Amount), 0)
	FROM	[@DBNAME].[trs].[tblPayDtl] AS PD  with (nolock)
			INNER JOIN 
			(
				SELECT A.*,B.CreditCode FROM 
				(SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
				FROM	[@DBNAME].[trs].[tblPayDtl] AS PD2  with (nolock)
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo in (1,2)
				GROUP BY VolumeFiscalYear, VolumeRowNo) A
				,
				(SELECT VolumeFiscalYear, VolumeRowNo,CreditCode   
				 FROM	[@DBNAME].trs.tblPayDtl VOL with (nolock) 
				 WHERE	ProcessID IN (1,10) 
					AND PayTypeID IN (6,26) 
					AND ' + @StrWhare + '
				) B
				WHERE A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo 
			) VOL 
				ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear 
					AND PD.VolumeRowNo = VOL.VolumeRowNo 
					AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) 
		AND PD.ProcessID = 2 
		AND PD.ProcessNo in (1,2) 
		AND PD.ChequeDate >= '''+ @DocDate +''' 
		AND  ' + @StrWhare + ''

	SET @StrSelect = @StrSelect + '
	' + Replace(@StrTmpl, '@DBNAME', db_name())
	------- 1 Year Before ----------------------------------
	SET @StrDB = db_name()

	Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

	If (@StrPrevDB = '')
		GOTO RUN

	SET @StrSelect1 = '	' + Replace(@StrTmpl, '@DBNAME', @StrPrevDB)

	------- 2 Years Before ----------------------------------
	SET @StrDB = @StrPrevDB

	Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

	If (@StrPrevDB = '') 
		GOTO RUN

	SET @StrSelect2 = '	' + Replace(@StrTmpl, '@DBNAME', @StrPrevDB)
	------------------------------------------------------
RUN:

	SET @StrSelect = @StrSelect + @StrSelect1 + @StrSelect2 + '
	SELECT @iSumVal sum;' 

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
