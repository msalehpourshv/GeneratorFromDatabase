USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/09/03
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
create PROCEDURE [phr].[RptPhr_CompleteInsurance]
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@ExpDateFr		char(10) = null,
	@ExpDateTo		char(10) = null,
	@InsuranceID	varchar(20) = null,
	@InsuranceTypeID	varchar(20) = null,
	@RepOptions		VarChar(10) = '111011111',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);
Declare @StrWhere1	NVarChar(4000);
Declare @StrWhere2	NVarChar(4000);
Declare @StrWhere3	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	-- Where Clause -----------------------------------------
	Select @StrWhere = '(ReciptionTypeID = 1 AND Deleted=0 AND Payed=1 AND IsPreSale=0) '
	Select @StrWhere1 = ' AND 1 = 1  AND Deleted=0 AND Payed=1 AND IsPreSale=0 '
	Select @StrWhere2 = ' AND 1 = 1  AND Deleted=0 AND Payed=1 AND IsPreSale=0 '
	Select @StrWhere3 = ' AND 1 = 1  AND Deleted=0 AND Payed=1 AND IsPreSale=0 '

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DocDateTo + ''')'
		
	IF (@ExpDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (ExpDate >= ''' + @ExpDateFr + ''')'
	IF (@ExpDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (ExpDate <= ''' + @ExpDateTo + ''')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	If (@InsuranceID Is Not Null)
		SET @StrWhere1 = @StrWhere1 + ' AND (CompleteInsuranceID = ''' + @InsuranceID + ''')'

	If (@InsuranceTypeID Is Not Null)
		SET @StrWhere1 = @StrWhere1 + ' AND (CompleteInsuranceTypeID = ''' + @InsuranceTypeID + ''')'

	If (@InsuranceID Is Not Null)
		SET @StrWhere2 = @StrWhere2 + ' AND (CompleteInsuranceID2 = ''' + @InsuranceID + ''')'

	If (@InsuranceTypeID Is Not Null)
		SET @StrWhere2 = @StrWhere2 + ' AND (CompleteInsuranceTypeID2 = ''' + @InsuranceTypeID + ''')'

	If (@InsuranceID Is Not Null)
		SET @StrWhere3 = @StrWhere3 + ' AND (CompleteInsuranceID3 = ''' + @InsuranceID + ''')'

	If (@InsuranceTypeID Is Not Null)
		SET @StrWhere3 = @StrWhere3 + ' AND (CompleteInsuranceTypeID3 = ''' + @InsuranceTypeID + ''')'
				
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	Select SerialNo, DocDate, IllInsuranceNo, IllName + '' '' + IllLastName As PatientName,
		   CompleteInsuranceAmount, CompleteInsuranceDiff, CompleteInsuranceProfCost,
		   (CompleteInsuranceAmount + CompleteInsuranceDiff + CompleteInsuranceProfCost) As TotalAmount
	From phr.tblReciptionHdr
	WHERE  ' + @StrWhere + @StrWhere1 + '

	UNION
	
	Select SerialNo, DocDate, IllInsuranceNo, IllName + '' '' + IllLastName As PatientName,
		   CompleteInsuranceSum2, CompleteInsuranceDiff, CompleteInsuranceProfCost,
		   CompleteInsuranceSum2 As TotalAmount
	From phr.tblReciptionHdr
	WHERE  ' + @StrWhere + @StrWhere2 + '
	
	UNION
	
	Select SerialNo, DocDate, IllInsuranceNo, IllName + '' '' + IllLastName As PatientName,
		   CompleteInsuranceSum3, CompleteInsuranceDiff, CompleteInsuranceProfCost,
		   CompleteInsuranceSum3 As TotalAmount
	From phr.tblReciptionHdr
	WHERE  ' + @StrWhere + @StrWhere3 + '
	ORDER BY SerialNo
	'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
