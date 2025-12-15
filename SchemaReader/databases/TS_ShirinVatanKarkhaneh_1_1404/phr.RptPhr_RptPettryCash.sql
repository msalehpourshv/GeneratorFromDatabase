USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/09/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_RptPettryCash]

	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@AcntCode		Varchar(20) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	-- Where Clause -----------------------------------------
	Select @StrWhere = '1 = 1'
	
	IF @AcntCode Is Not Null
	Begin
		IF (Select COUNT(*) FROM trs.tblOurBanks WHERE AcntCode1 = @AcntCode) > 0
		Begin
			SET @StrWhere = @StrWhere + ' AND H.OurBankCode IN (SELECT IsNull(BankCode,'''') FROM trs.tblOurBanks 
										  WHERE AcntCode1 = ''' + @AcntCode + ''')'
		End		
		Else
		Begin
			Return
		End
	End			

	IF (@DocDateFr Is Not Null)
		
		SET @StrWhere = @StrWhere + ' AND D.SpendDate >= ''' + @DocDateFr + ''''
		
	IF @DocDateTo Is Not Null
			
		SET @StrWhere = @StrWhere + ' AND D.SpendDate <= ''' + @DocDateTo + ''''
		
	-- Select Clause -------------------------------------------

	SET @StrSelect = '
	SELECT D.* 
	FROM trs.tblPettyCashDtl D
		 INNER JOIN trs.tblPettyCashHdr H
		 ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND 
			H.SerialNo = D.SerialNo
	Where ' + @StrWhere
	
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
