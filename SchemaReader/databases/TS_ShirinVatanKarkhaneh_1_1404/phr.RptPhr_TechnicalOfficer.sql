USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/09/23
-- Viewed By	 : 
-- Last Modified : 1392/09/23
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_TechnicalOfficer]

	@DeliverDocDateFr	Char(10) = Null,
	@DeliverDocDateTo	Char(10) = Null,
	@DeliverUserID		Varchar(20) = Null,
	@RepOptions			VarChar(10) = '111011111',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'

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
	Select @StrWhere = 'CD.DeliveryToCustomer = 1'

	IF (@DeliverDocDateFr Is Not Null)
		
		SET @StrWhere = @StrWhere + ' AND (CD.DeliverDocDate >= ''' + @DeliverDocDateFr + ''')'
	
	IF @DeliverDocDateTo Is Not Null
	
		SET @StrWhere = @StrWhere + ' AND (CD.DeliverDocDate <= ''' + @DeliverDocDateTo + ''')'
			
	IF @DeliverUserID > -1
			
		SET @StrWhere = @StrWhere + ' AND CD.DeliverUserID = ''' + @DeliverUserID + ''''	
		
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	Select RH.ReciptionTypeID, IsNull(phr.FunGetInsuranceName(RH.InsuranceID,1),'''') As InsuranceName, COUNT(*) As Count
	From phr.tblReciptionHdr RH
		Inner Join (Select Distinct ReciptionFiscalYear, ReciptionSerialNo, DeliveryToCustomer,
                 DeliverDocDate ,DeliverUserID From phr.tblCashBoxDtl) CD
        ON RH.FiscalYear = CD.ReciptionFiscalYear And RH.SerialNo = CD.ReciptionSerialNo
	Where ' + @StrWhere + '
	Group By RH.InsuranceID, RH.ReciptionTypeID'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
