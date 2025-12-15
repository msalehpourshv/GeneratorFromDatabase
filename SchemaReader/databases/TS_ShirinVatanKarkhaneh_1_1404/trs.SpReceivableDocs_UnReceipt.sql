USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/12/19
-- Viewed By	 : 
-- Last Modified : 1392/05/15
-- Last Modifier : TakroSystem\ZiA
-- ----------------------------------------------
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [trs].[SpReceivableDocs_UnReceipt]
	@AcntCode	VarChar(20),
	@ProcessNo	Int = 0,
	@DateFrom	Char(10) = '2000/10/01'
WITH ENCRYPTION
As
DECLARE @StrSQL		AS NVarChar(1000)
DECLARE @StrPNO		AS NVarChar(1000)
DECLARE @StrParams	AS NVarChar(500);
DECLARE @StrSelect	AS NVarChar(4000)
DECLARE @StrTmpl	AS NVarChar(4000)
DECLARE @StrDB		AS NVarChar(100)
DECLARE @StrPrevDB	AS NVarChar(100)
DECLARE @TempTable	AS NVarChar(100)
Begin 
	SET NOCOUNT ON;

	SET @TempTable = '##tbl_SpReceivableDocs_UnReceipt' + CAST(@@SPID as varchar(20))

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
	
	-- اسناد دریافتنی موجود در صندوق و موجود در بانک
	SET @StrSelect = '
	SELECT	PD.FiscalYear, PD.SerialNo, PD.VolumeFiscalYear, PD.VolumeRowNo, PD.Amount,
			PD.ChequeDate, PD.ChequeNo, PD.AccountNo, BT.BankTypeName, LD.LocationName,
			PD.DebitCode, pub.GetBankName(PD.DebitCode, 1) AS DebitName,
			CASE WHEN (ProcessID IN (20, 21)) 
				THEN 2
				ELSE 1
			END AS Row
	INTO ' + @TempTable + '
	FROM	trs.tblPayDtl AS PD
			LEFT  JOIN pub.tblLocationsDtl AS LD ON LD.LocationID = PD.LocationID AND LD.LanguageID = 1
			LEFT  JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = PD.BankTypeID AND BT.LanguageID = 1
			INNER JOIN 
			(
				SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo,
						(
							SELECT Top 1 CreditCode
							FROM	trs.tblPayDtl
							WHERE	ProcessID IN (1,10) AND 
									PayTypeID IN (6,26) AND 
									VolumeFiscalYear = PD2.VolumeFiscalYear AND
									VolumeRowNo = PD2.VolumeRowNo
							ORDER By EventNo ASC
						) AS CreditCode
				FROM	trs.tblPayDtl AS PD2
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.' + Ltrim(@StrPNO) + '
				GROUP BY VolumeFiscalYear, VolumeRowNo
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
					 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) AND
			ProcessID IN (1, 10, 17, 20, 21, 23, 40) AND
			PD.' + Ltrim(@StrPNO) + ' AND
			VOL.CreditCode = ''' + @AcntCode + ''''

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	-- اسناد دریافتنی واگذار شده به اشخاص
	SET @StrTmpl = '
	INSERT INTO ' + @TempTable + '
	SELECT	PD.FiscalYear, PD.SerialNo, PD.VolumeFiscalYear, PD.VolumeRowNo, PD.Amount,
			PD.ChequeDate, PD.ChequeNo, PD.AccountNo, BT.BankTypeName, LD.LocationName,
			PD.DebitCode, pub.GetCodeName(PD.DebitCode, 1) AS DebitName, 3 AS Row
	FROM	[@DBNAME].[trs].[tblPayDtl] AS PD
			LEFT  JOIN [@DBNAME].[pub].[tblLocationsDtl] AS LD ON LD.LocationID = PD.LocationID AND LD.LanguageID = 1
			LEFT  JOIN [@DBNAME].[trs].[tblBankTypesDtl] AS BT ON BT.BankTypeID = PD.BankTypeID AND BT.LanguageID = 1
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
	WHERE	PD.PayTypeID IN (6, 26) AND
			ProcessID = 2 AND
			PD.' + Ltrim(@StrPNO) + ' AND
			VOL.CreditCode = ''' + @AcntCode + ''' AND 
			PD.ChequeDate > ''' + @DateFrom + ''''

	SET @StrSelect = Replace(@StrTmpl, '@DBNAME', db_name())
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	-- Cheques paid to people in last years is not transfered to new year 
	-- so we shoud check the last years.
	
	------- 1 Year Before ----------------------------------
	SET @StrDB = db_name()

	EXEC [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

	If (@StrPrevDB = '') 
		GOTO RUN

	SET @StrSelect = Replace(@StrTmpl, '@DBNAME', @StrPrevDB)
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	------- 2 Years Before ----------------------------------
	SET @StrDB = @StrPrevDB

	Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT 

	If (@StrPrevDB = '') 
		GOTO RUN

	SET @StrSelect = Replace(@StrTmpl, '@DBNAME', @StrPrevDB)
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
 	--------------------------------------------------------

RUN:
	SET @StrSelect = '
	SELECT *
	FROM ' + @TempTable + '
	ORDER BY ChequeDate DESC'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
