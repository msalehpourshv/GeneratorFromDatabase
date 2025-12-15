USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/05/08
-- Viewed By	 : 
-- Last Modified : 1393/06/06
-- Last Modifier : TakroSystem\ZIA
-- Description	 : <Bank Info>
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_BankStats]
	@ProcessNo		Int = 1,
	@SelectedBank	Int = 0,
	@DocDateTo		Char(10) = '1392/12/25',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @Today		Char(10);
Begin   

	SET NOCOUNT ON;
	
	--- Init -------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo  = '1@1@1';
	IF (@SelectedBank Is Null)	SET @SelectedBank = 0;
	IF (@DocDateTo IS Null)		SET @DocDateTo = '9999/99/99';

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @Today = pub.funFarsiDate(getdate());
	----------------------------------------------------
	--- Where Clause -----------------------------------
	SET @StrWhere = '(H.BankState = 3)'

	IF	(@SelectedBank > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedBank, 'D0.BankCode') 
	----------------------------------------------------
	--- Select Clause ----------------------------------
	SET @StrSelect = '
	SELECT	D0.*, H.AcntCode1,
			isnull((
				SELECT Sum(Debit - Credit)
				FROM   acc.tblVoucherDtl
				WHERE  (AcntCode = H.AcntCode1) AND (DocDate <= ''' + @DocDateTo + ''')
			),0) RemainAmount,
			isnull((
				SELECT	Sum(D.Amount)
				FROM	trs.tblPayDtl AS D 
						INNER JOIN
						(
							SELECT	VolumeFiscalYear, VolumeRowNo
							FROM	trs.tblPayDtl
							WHERE	(ProcessNo=' + ltrim(str(@ProcessNo)) + ') 
								and (PayTypeID IN (8,28)) 
								AND (ProcessID in (2,25)) 
								AND (ChequeDate<=''' + @DocDateTo + ''') 
								AND (ChequeDate< ''' + @Today + ''')
							EXCEPT  
							SELECT	VolumeFiscalYear, VolumeRowNo
							FROM	trs.tblPayDtl
							WHERE	(ProcessNo=' + ltrim(str(@ProcessNo)) + ') 
								and (PayTypeID IN (8, 28)) 
								AND (ProcessID IN (27,28))
						)	AS A
						ON A.VolumeFiscalYear = D.VolumeFiscalYear AND A.VolumeRowNo = D.VolumeRowNo 
				WHERE	PayTypeID IN(8, 28) AND 
						D.ProcessID in (2,25) AND 
						D.CreditCode = D0.BankCode
			),0) UnReceiptAmount1,
			isnull((
				SELECT	Sum(D.Amount)
				FROM	trs.tblPayDtl AS D 
						INNER JOIN
						(
							SELECT	VolumeFiscalYear, VolumeRowNo
							FROM	trs.tblPayDtl
							WHERE	(ProcessNo=' + ltrim(str(@ProcessNo)) + ') 
								and (PayTypeID IN (8,28)) 
								AND (ProcessID in (2,25)) 
								AND (ChequeDate<=''' + @DocDateTo + ''') 
								AND (ChequeDate>=''' + @Today + ''')
							EXCEPT  
							SELECT	VolumeFiscalYear, VolumeRowNo
							FROM	trs.tblPayDtl
							WHERE	(ProcessNo=' + ltrim(str(@ProcessNo)) + ') 
								and (PayTypeID IN (8, 28)) 
								AND (ProcessID IN (27,28))
						)	AS A
						ON A.VolumeFiscalYear = D.VolumeFiscalYear AND A.VolumeRowNo = D.VolumeRowNo 
				WHERE	PayTypeID IN(8, 28) AND 
						D.ProcessID in (2,25) AND 
						D.CreditCode = D0.BankCode
			),0) UnReceiptAmount2			
	FROM	trs.tblOurBanksDtl D0 
				INNER JOIN trs.tblOurBanks H ON H.BankCode = D0.BankCode
	WHERE	'  + @StrWhere + '
	ORDER BY D0.BankCode '
	----------------------------------------------------
	--- Exec -------------------------------------------
	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;
	----------------------------------------------------
End
GO
