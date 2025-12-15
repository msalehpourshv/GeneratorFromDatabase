USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 86/12/19
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Returns sum of a persons Returned cheques.
-- ----------------------------------------------
-- 
-- ==============================================
CREATE PROCEDURE [trs].[SpReceivableDocs_Returned_SumForSaleOrder]
	@AcntCode AS VarChar(20),
	@ProcessNo AS TinyInt = 1,
	@StartTargetLayer tinyint,
	@LenTargetLayer tinyint
WITH ENCRYPTION
As
DECLARE @StrSQL		AS NVarChar(1000)
DECLARE @StrParams	AS NVarChar(500)
DECLARE @StrSelect	AS NVarChar(4000)
DECLARE @StrTmpl	AS NVarChar(4000)
DECLARE @StrDB		AS NVarChar(100)
DECLARE @StrPrevDB	AS NVarChar(100)
Begin 

	SET @StrSelect = N'
	DECLARE @iSumVal AS	BigInt
	SET		@iSumVal = 0
	'

	SET @StrTmpl = N'
	SELECT	@iSumVal = @iSumVal + IsNull(Sum(PD.Amount), 0)
	FROM	[@DBNAME].[trs].tblPayDtl AS PD
			INNER JOIN 
			(
				SELECT A.*,CreditCode FROM 
				(
				SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
				FROM	[@DBNAME].[trs].tblPayDtl AS PD2
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo = ' + LTrim(Str(@ProcessNo)) + '
				GROUP BY VolumeFiscalYear, VolumeRowNo
				)A , 
				(SELECT Top 1 VolumeFiscalYear, VolumeRowNo,CreditCode
					 FROM	[@DBNAME].trs.tblPayDtl
					 WHERE	ProcessID IN (1,10) AND 
							PayTypeID IN (6,26) AND 
							SUBSTRING(CreditCode,' + LTrim(Str(@StartTargetLayer)) + ',' + LTrim(Str(@LenTargetLayer)) + ') = ''' + SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer) + '''
					  ORDER By EventNo ASC
				) B
				WHERE A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo 
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
					 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) AND
			ProcessID IN (13, 18, 24) AND
			PD.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' AND
			SUBSTRING(VOL.CreditCode,' + LTrim(Str(@StartTargetLayer)) + ',' + LTrim(Str(@LenTargetLayer)) + ') = ''' + SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer) + ''''

	SET @StrSelect = @StrSelect + Replace(@StrTmpl, '@DBNAME', db_name())

	-- Recursive to all years before current year --
	SET @StrDB = db_name()
	SET @StrPrevDB = @StrDB

	While (1 = 1)
	Begin
		
		SET @StrDB = @StrPrevDB

		Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

		If (@StrPrevDB = '') 
			BREAK

		SET @StrSelect = @StrSelect + '
		' + Replace(@StrTmpl, '@DBNAME', @StrPrevDB)

	End
	
	SET @StrSelect = @StrSelect + '
	SELECT @iSumVal;'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
