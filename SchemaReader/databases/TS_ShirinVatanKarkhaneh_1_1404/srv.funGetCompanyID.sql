USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create Date   : 1392/07/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE  Function [srv].[funGetCompanyID](
    	@SerialNo      	Int = NULL,
		@FiscalYear		Int = NULL,
    	@DocRowNo      	Int = NULL,
		@PerssonelID	VarChar(20))
		
RETURNS VarChar (20)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @CompanyID VarChar (20)
	
            Select Distinct  @CompanyID = SH.CompanyID 
			From srv.tblServiceRequestHdr SH
			Inner Join srv.tblServiceRequestDtl SD
			ON SD.ProcessID = SH.ProcessID And SD.ProcessNo = SH.ProcessNo And 
			   SD.FiscalYear = SH.FiscalYear And SD.SerialNo = SH.SerialNo
			Inner Join srv.tblServiceTaskAtm1 SA
			ON SA.RequestCode = SH.SerialNo And SA.RequestFiscalYear = SH.FiscalYear
			Inner Join srv.tblServiceTaskPersonnelDtl SP
			ON SP.SerialNo = SA.SerialNo And SP.FiscalYear = SA.FiscalYear 
			Where SA.SerialNo = @SerialNo And SA.FiscalYear = @FiscalYear And 
			      SA.DocRowNo = @DocRowNo And SP.PersonnelID = @PerssonelID
			      
	RETURN @CompanyID 	  
END


GO
