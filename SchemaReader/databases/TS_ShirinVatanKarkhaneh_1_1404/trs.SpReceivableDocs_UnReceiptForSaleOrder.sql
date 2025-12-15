USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 86/12/19
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- 
-- ==============================================
CREATE PROCEDURE [trs].[SpReceivableDocs_UnReceiptForSaleOrder]
	@AcntCode	AS VarChar(20),
	@ProcessNo	AS TinyInt=1,
	@DateFrom	AS Char(10)= '2000/10/01',
	@StartTargetLayer tinyint,
	@LenTargetLayer tinyint
WITH ENCRYPTION
As
DECLARE @StrSQL		AS NVarChar(1000)
DECLARE @StrParams	AS NVarChar(500);
DECLARE @StrSelect	AS NVarChar(4000)
DECLARE @StrTmpl	AS NVarChar(4000)
DECLARE @StrDB		AS NVarChar(100)
DECLARE @StrPrevDB	AS NVarChar(100)
DECLARE @TempTable	AS NVarChar(100)
Begin 
	SET NOCOUNT ON;

	SET @TempTable = '##tbl_SpReceivableDocs_UnReceiptForSaleOrder' + CAST(@@SPID as varchar(20))

	BEGIN TRY
		SET @StrSelect = N'DROP TABLE ' + @TempTable
		EXEC sp_executesql @StrSelect
	END TRY
	BEGIN CATCH
	END CATCH
	
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
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo = ' + LTrim(Str(@ProcessNo)) + '
				GROUP BY VolumeFiscalYear, VolumeRowNo
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
					 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) AND
			ProcessID IN (1, 10, 17, 20, 21, 23, 40) AND
			PD.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' AND
			SUBSTRING(VOL.CreditCode,' + LTrim(Str(@StartTargetLayer)) + ',' + LTrim(Str(@LenTargetLayer)) + ')=''' + SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer) + ''''

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
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo = ' + LTrim(Str(@ProcessNo)) + '
				GROUP BY VolumeFiscalYear, VolumeRowNo
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
					 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) AND
			ProcessID = 2 AND
			PD.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' AND
			SUBSTRING(VOL.CreditCode,' + LTrim(Str(@StartTargetLayer)) + ',' + LTrim(Str(@LenTargetLayer)) + ')=''' + SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer) + ''' AND 
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
	ORDER BY ChequeDate '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
