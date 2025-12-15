USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/12/19
-- Viewed By	 : 
-- Last Modified : 1392/05/15
-- Last Modifier : TakroSystem\Zia
-- ----------------------------------------------
-- Description	 : Returns a persons Returned cheques list
-- ==============================================
CREATE PROCEDURE [trs].[SpReceivableDocs_Returned]
	@AcntCode AS VarChar(20),
	@ProcessNo AS Int = 0

WITH ENCRYPTION
As

DECLARE @StrSQL		AS NVarChar(1000)
DECLARE @StrPNO		AS NVarChar(1000)
DECLARE @StrParams	AS NVarChar(500)
DECLARE @StrSelect	AS NVarChar(max)
DECLARE @StrTmpl	AS NVarChar(max)
DECLARE @StrDB		AS NVarChar(100)
DECLARE @StrPrevDB	AS NVarChar(100)
DECLARE @TempTable	AS NVarChar(100)

BEGIN 

	SET @TempTable = '##tbl_SpReceivableDocs_Returned'

	BEGIN TRY
		SET @StrSelect = N'DROP TABLE ' + @TempTable
		EXEC sp_executesql @StrSelect
	END TRY
	BEGIN CATCH
	END CATCH
	
	if (@ProcessNo > 0)
		set @StrPNO = 'ProcessNo = ' + LTrim(Str(@ProcessNo))
	else
		set @StrPNO = 'ProcessNo > -1'

	SET @StrTmpl = N'
	@FIRST_INSERT
	SELECT	PD.FiscalYear, PD.SerialNo, PD.VolumeFiscalYear, PD.VolumeRowNo, PD.Amount,
			PD.ChequeDate, PD.ChequeNo, PD.AccountNo, BT.BankTypeName, LD.LocationName,
			PD.DebitCode, 
			CASE WHEN (ProcessID = 2) 
				THEN [@DBNAME].pub.GetCodeName(PD.DebitCode, 1) 
				ELSE [@DBNAME].pub.GetBankName(PD.DebitCode, 1)
			END AS DebitName,
			CASE 
				WHEN (ProcessID = 2) THEN 3
				WHEN (ProcessID IN (20, 21)) THEN 2
				ELSE 1
			END AS Row
	@SECOND_INSERT
	FROM	trs.tblPayDtl AS PD
			LEFT JOIN [@DBNAME].[pub].[tblLocationsDtl] AS LD ON LD.LocationID = PD.LocationID AND LD.LanguageID = 1
			LEFT JOIN [@DBNAME].[trs].[tblBankTypesDtl] AS BT ON BT.BankTypeID = PD.BankTypeID AND BT.LanguageID = 1
			INNER JOIN 
			(
				SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo,
						(
							SELECT Top 1 CreditCode
							FROM	[@DBNAME].trs.tblPayDtl
							WHERE	ProcessID IN (1,10) AND 
									PayTypeID IN (6,26) AND 
									VolumeFiscalYear = PD2.VolumeFiscalYear AND 
									VolumeRowNo = PD2.VolumeRowNo
							ORDER By EventNo ASC
						) AS CreditCode
				FROM	[@DBNAME].[trs].[tblPayDtl] AS PD2
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.' + Ltrim(@StrPNO) + ' 
				GROUP BY VolumeFiscalYear, VolumeRowNo
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
					 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) 
			AND PD.ProcessID IN (13, 18, 24) 
			AND PD.' + Ltrim(@StrPNO) + ' 
			AND	VOL.CreditCode = ''' + @AcntCode + ''''

	SET @StrSelect = @StrTmpl
	SET @StrSelect = Replace(@StrSelect, '@DBNAME', db_name())
	SET @StrSelect = Replace(@StrSelect, '@FIRST_INSERT', '')
	SET @StrSelect = Replace(@StrSelect, '@SECOND_INSERT', 'INTO ' + @TempTable)

	-- Recursive to all years before current year --
	SET @StrDB = db_name()
	SET @StrPrevDB = @StrDB

	While (1 = 1)
	Begin
		--PRINT @StrSelect;
		PRINT '---------';
		EXEC sp_executesql @StrSelect;
		
		SET @StrDB = @StrPrevDB

		EXEC [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

		If (@StrPrevDB = '') 
			BREAK

		SET @StrSelect = @StrTmpl
		SET @StrSelect = Replace(@StrSelect, '@DBNAME', @StrPrevDB)
		SET @StrSelect = Replace(@StrSelect, '@FIRST_INSERT' , 'INSERT INTO ' + @TempTable)
		SET @StrSelect = Replace(@StrSelect, '@SECOND_INSERT', '')
	End

	SET @StrSelect = '
	SELECT distinct * 
	FROM ' + @TempTable + '
	ORDER BY ChequeDate'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
