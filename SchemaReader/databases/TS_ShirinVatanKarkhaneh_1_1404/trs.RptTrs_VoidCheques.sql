USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/02/11
-- Viewed By	 : 
-- Last Modified : 1386/08/28
-- Description	 : <Unused Cheques list>
-- ----------------------------------------------
-- لیست برگ چکهای استفاده نشده دسته چکهای یک بانک
-- ==============================================
Create PROCEDURE [trs].[RptTrs_VoidCheques]
	@SelectedBank	int = 0,
	@RepOptions		nVarChar(10) = '0000000000',  -- bit array options
	@SortFields		NVarChar(100) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
Declare @StrSelect		NVarChar(4000);
Declare @StrFrom		NVarChar(4000);
Declare @StrWhere		NVarChar(4000);

DECLARE	@LangID					Char(1);
DECLARE	@SessionNo				Int; 
DECLARE	@ReportID				Int; 
DECLARE	@ChequeIsDigital		Int; 
Begin --============== S T A R T  C O D E ===================================================
	SET NOCOUNT ON;

	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '110011111'
	IF (@SortFields	Is Null)	SET @SortFields = 'V.BankCode, V.ChequeNo'
	
	--SET @ShowQuantity	= Substring(@RepOptions, 1, 1)

	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	SET @ChequeIsDigital	= pub.funSplitString(@RepInfo, '@', 6);

	-- Where Clause -----------------------------------------------------------
	Set @StrWhere = '(1=1)'

	IF (@SelectedBank > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedBank, 'V.BankCode') 
	IF (@ChequeIsDigital = 1)
		SET @StrWhere = @StrWhere + ' AND V.ChequeIsDigital = 1'
	IF (@ChequeIsDigital = 0)
		SET @StrWhere = @StrWhere + ' '
	
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	select V.*, BD.BankName, BD.BranchName, BH.BankAccountNo
	from trs.tblBankVoidChequesDtl V
			inner join trs.tblOurBanks BH on BH.BankCode = V.BankCode
			inner join trs.tblOurBanksDtl BD on BD.BankCode = V.BankCode
	where ' + @StrWhere
	------------------------------------------------------------
	-- Sort Clause ---------------------------------------------
	If (@SortFields Is Not Null)
	SET @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
