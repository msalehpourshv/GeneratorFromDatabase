USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 86/12/19
-- Viewed By	 : 
-- Last Modified : 90/05/03
-- Last ModifieR : zIA
-- Description	 : 
-- ----------------------------------------------
-- 
-- ==============================================
Create PROCEDURE [trs].[SpReceivableDocs_UnReceipt_Sum]
	@AcntCode	AS VarChar(20),
	@ProcessNo	AS TinyInt = 1,
	@DateFrom	AS Char(10),
	@CountOrPrice as int=1
WITH ENCRYPTION
As
DECLARE @StrSQL		AS NVarChar(1000)
DECLARE @StrParams	AS NVarChar(500);
DECLARE @StrSelect	AS NVarChar(MAX)
DECLARE @StrSelect1	AS NVarChar(MAX)
DECLARE @StrSelect2	AS NVarChar(MAX)
DECLARE @StrTmpl	AS NVarChar(4000)
DECLARE @StrPrevDB		AS NVarChar(100)
DECLARE @StrDB			AS NVarChar(100)
Begin 

	Set NOCOUNT ON;
	SET @StrSelect1=''
	SET @StrSelect2=''
	-- اسناد دریافتنی موجود در صندوق و موجود در بانک
	SET @StrSelect = '
	DECLARE @iSumVal AS		BigInt
	DECLARE @iCountVal AS	Int
	SET		@iSumVal = 0.0

	SELECT	@iSumVal = IsNull(Sum(PD.Amount), 0)
			,@iCountVal = IsNull(Count(PD.Amount), 0)
	FROM	[trs].tblPayDtl AS PD  with (nolock)
			INNER JOIN 
			(
				SELECT A.*,Credit FROM 
				(SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
				FROM	[trs].tblPayDtl AS PD2  with (nolock)
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo in (1,2)
				GROUP BY VolumeFiscalYear, VolumeRowNo) A
				,
				(SELECT VolumeFiscalYear, VolumeRowNo,CreditCode  Credit
				 FROM	trs.tblPayDtl  with (nolock)
				 WHERE	ProcessID IN (1,10) AND 
						PayTypeID IN (6,26) AND 
						CreditCode = ''' + @AcntCode + '''
				) B
				WHERE A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo 
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
					 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) AND 
			PD.ProcessID IN (1, 10, 17, 20, 21, 23, 40) AND 
			PD.ProcessNo in (1,2) AND
			VOL.Credit = ''' + @AcntCode + ''''

	-- اسناد دریافتنی واگذار شده به اشخاص
	SET @StrTmpl = '
	SELECT	@iSumVal = @iSumVal + ISNull(Sum(PD.Amount), 0)
			,@iCountVal =@iCountVal+ IsNull(Count(PD.Amount), 0)
	FROM	[@DBNAME].[trs].[tblPayDtl] AS PD  with (nolock)
			INNER JOIN 
			(
				SELECT A.*,Credit FROM 
				(SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
				FROM	[@DBNAME].[trs].[tblPayDtl] AS PD2  with (nolock)
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo in (1,2)
				GROUP BY VolumeFiscalYear, VolumeRowNo) A
				,
				(SELECT VolumeFiscalYear, VolumeRowNo,CreditCode  Credit
				 FROM	[@DBNAME].trs.tblPayDtl  with (nolock)
				 WHERE	ProcessID IN (1,10) AND 
						PayTypeID IN (6,26) AND 
						CreditCode = ''' + @AcntCode + '''
				) B
				WHERE A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo 
			) VOL ON 
				PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
				PD.VolumeRowNo = VOL.VolumeRowNo AND 
				PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) AND
			PD.ProcessID = 2 AND
			PD.ProcessNo in (1,2) AND
			PD.ChequeDate > ''' + @DateFrom + ''' AND
			VOL.Credit = ''' + @AcntCode + ''''

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

	IF @CountOrPrice=1
	SET @StrSelect = @StrSelect + @StrSelect1 + @StrSelect2 + '	SELECT @iSumVal  sum;' 
	
	ELSE
	SET @StrSelect = @StrSelect + @StrSelect1 + @StrSelect2 + '	SELECT @iCountVal sum;' 
	

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
