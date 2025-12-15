USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/19
-- Viewed By	 : 
-- Last Modified : 1393/05/22
-- Last Modifier : TakroSystem\Hamid
-- Description	 : <PettyCash Account>
-- ----------------------------------------------
-- یک شماره برگ مربوط به تنخواه
-- ==============================================
CREATE PROCEDURE [acc].[RptAcc_DebitCreditDeclaration]
	@ProcessID		Int 			= 1128,
	@ProcessNo		Int 			= 1,
	@FiscalYearFr	Int				= 96,
	@SerialNoFr		int 			= 1,
	@FiscalYearTo	Int				= 96,
	@SerialNoTo		int 			= 10,
	@DocDateFr		char(10) 		= Null,
	@DocDateTo		char(10) 		= Null,
	@RegDocFr		char(10) 		= Null,
	@RegDocTo		char(10) 		= Null,
	@RepOptions		varchar(20)		= '0000011000100',
	@RepInfo		nvarchar(100) 	= '1@1@1',
	@ExtraParams	nvarChar(200) 	= ''
WITH ENCRYPTION
As
DECLARE @LanguageID Int
DECLARE @UserName		NVarChar(4000)
DECLARE @UserFullName	NVarChar(4000)
BEGIN   -----------------  B E G I N   T O   C O D E  --------------------------

	SET @LanguageID = pub.funGetCurrentLanguageID();

	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNoFr;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYearFr;

	SET @UserFullName	 = pub.funSplitString(@ExtraParams, '#', 1);
	SET @UserName		 = pub.funSplitString(@ExtraParams, '#', 2);
	
	-- ======================================================
	SELECT	D.*, H.DocDate HDocDate, H.RegisterDate, H.VchNo, H.RecDesc, H.DocDesc2,
			H.CurrencyTypeID, H.CurrencyRate, H.SgnSN1, H.SgnSN2, H.SgnSN3, H.SgnSN4, H.SgnSN5,
			pub.GetUserName(H.SessionNo) AS UserName,
			pub.GetCodeName(D.AcntCode, 1) AS AcntName1,
			[acc].[funPartAcntName](D.AcntCode, 1) + ' ' + [acc].[funPartAcntName](D.AcntCode, 2) + ' ' + [acc].[funPartAcntName](D.AcntCode, 2) CostAcntName,
			acc.funGetAcntFullName(D.AcntCode) AS CostAcntFullName,
			pub.GetCodeName(pub.funSplitString(D.AcntCode, '', 1), 1) AcntName2,
			@UserFullName UserFullName, @UserName PrintUserName, 
			pub.funFarsiDate(GETDATE()) PrintDate,
			CASE WHEN Debit > 0 and CurrencyAmount>0 THEN ABS(CurrencyAmount) ELSE CASE WHEN Credit> 0 and CurrencyAmount<0 THEN ABS(CurrencyAmount) ELSE 0 END END AS _Debit ,
			CASE WHEN Credit> 0 and CurrencyAmount>0 THEN ABS(CurrencyAmount) ELSE CASE WHEN Debit > 0 and CurrencyAmount<0 THEN ABS(CurrencyAmount) ELSE 0 END END AS _Credit,
			IsNull(CTD.CurrencyTypeName,'') As CurrencyTypeName
	FROM	acc.tblDebitCreditDeclarationDtl D
	INNER JOIN acc.tblDebitCreditDeclarationHdr H 
	ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND 
	   D.FiscalYear = H.FiscalYear AND	D.SerialNo = H.SerialNo
	LEFT JOIN pub.tblCurrencyTypesDtl CTD ON CTD.CurrencyTypeID = D.CurrencyTypeID
	WHERE	 H.ProcessID  = @ProcessID  AND H.ProcessNo = @ProcessNo AND
			(@FiscalYearFr Is Null OR H.FiscalYear >= @FiscalYearFr) AND (@SerialNoFr Is Null OR H.SerialNo >= @SerialNoFr) AND
			(@FiscalYearTo Is Null OR H.FiscalYear <= @FiscalYearTo) AND (@SerialNoTo Is Null OR H.SerialNo <= @SerialNoTo) AND
			(@DocDateFr Is Null OR H.DocDate >= @DocDateFr) AND (@DocDateTo Is Null OR H.DocDate <= @DocDateTo) AND
			(@RegDocFr Is Null OR H.RegisterDate >= @RegDocFr) AND (@RegDocTo Is Null OR H.RegisterDate <= @RegDocTo)
	ORDER BY 	FiscalYear,	SerialNo,DocRowNo
END
GO
