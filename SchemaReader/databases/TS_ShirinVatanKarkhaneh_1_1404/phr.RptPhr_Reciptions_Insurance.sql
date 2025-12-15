USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : REZA NP
-- Create date   : 1392/12/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_Reciptions_Insurance]
	
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@InsuranceID	varchar(20) = null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
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
	Select @StrWhere = 'WHERE 1=1'


	If (@InsuranceID is not null)
		SET @StrWhere = @StrWhere + ' AND (InsuranceID = ''' + @InsuranceID + ''')'

		IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DocDateTo + ''')'
	


	-- Select Clause -------------------------------------------
	SET @StrSelect = 'SELECT InsuranceID,InsuranceTypeID,COUNT(*)as cont,
		phr.FunGetInsuranceName(InsuranceID,1) AS insuranceName,
		phr.FunGetInsuranceTypeName(InsuranceTypeID,1)AS insuranceTypeName,
		SUM(IllPortionSum)as illPortion,SUM(InsurancePortionSum) AS insurPortion
	  FROM phr.tblReciptionHdr '
			
	  + @StrWhere + 
	' GROUP BY InsuranceID,InsuranceTypeID '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
