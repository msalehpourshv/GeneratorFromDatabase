USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/07/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
create PROCEDURE [phr].[RptPhr_Insurance_Tamin]
	@InsuranceID	Varchar(20) = Null,
	@Month			Char(2) = Null,
	@Year			Char(10) = Null,
	@CompanyName    NVarchar(200) = Null, 
	@ComputerCode   Varchar(20) = Null, 
	@DocumentCode   Varchar(20) = Null, 
	@CityName		NVarchar(100) = Null, 
	@Phone			Varchar(20) = Null, 
	@Address		NVarchar(500) = Null, 
	@AccountNo		Varchar(20) = Null,
	@PageCount		Int = Null,	 
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@DateFilterType		TINYINT = 1,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere1	NVarChar(4000);

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
	Select @StrWhere1 = ' (SELECT COUNT(*) from phr.tblReciptionDtl
	where  phr.tblReciptionDtl.SerialNo=RH.SerialNo and 
	phr.tblReciptionDtl.InsurancePercent>0 AND 
	phr.tblReciptionDtl.InsurancePortion>0)>0 and
	  InsuranceTypeID <> '''' AND (RH.ReciptionTypeID = 1) AND 
	(RH.Payed = 1)  AND (RH.Deleted = 0) AND  (RH.InsurancePortionSum > 0) AND
	RH.ConfirmType IN (0,1,2,5) '

	IF (@InsuranceID Is Not Null)
		SET @StrWhere1 = @StrWhere1 + ' AND (InsuranceID = ''' + @InsuranceID + ''')'

	--IF @Month Is Not Null
	--	SET @StrWhere1 = @StrWhere1 + ' AND (SubString(DocDate,6,2) = ''' + @Month + ''')'
		
	IF @DateFilterType = 1
		
		Begin
		
			IF (@DocDateFr Is Not Null)
			
			SET @StrWhere1 = @StrWhere1 + ' AND (RH.DocDate >= ''' + @DocDateFr + ''')' 
		
		IF @DocDateTo Is Not Null
		
			SET @StrWhere1 = @StrWhere1 + ' AND (RH.DocDate <= ''' + @DocDateTo + ''')'
		
		End
	
	IF @DateFilterType in (2,3)
		
		Begin
		
			IF (@DocDateFr Is Not Null)
			
			SET @StrWhere1 = @StrWhere1 + ' AND (RH.PrescriptionDate >= ''' + @DocDateFr + ''')'
		
		IF @DocDateTo Is Not Null
			
			SET @StrWhere1 = @StrWhere1 + ' AND (RH.PrescriptionDate <= ''' + @DocDateTo + ''')'
		
		End
		
			
	If (@Month is not null)
		SET @StrWhere1 = @StrWhere1 + ' AND (RH.Month = ''' + @Month + ''')'
	
	-- Select Clause -------------------------------------------

	SET @StrSelect = '
	Select phr.FunGetInsuranceTypeName(A.InsuranceTypeID,1) As InsuranceTypeName ,CI.InsuranceFileName ,
       SUM(Amount) As ORGPortion ,
       SUM(IllPortionSum) As PatientPortion,
       SUM(InsurSum) As TotalAmount ,
       COUNT(*) As RCount
   	From(
		Select RH.InsuranceID ,RH.InsuranceTypeID ,IllPortionSum ,
			  (RH.InsurancePortionSum ) As Amount,InsurancePriceSum As InsurSum
		From phr.tblReciptionHdr RH
		Where ' + @StrWhere1 + '
		) A
	Left Join phr.tblContractInsuranceHdr CI On A.InsuranceID = CI.InsuranceID And 
												A.InsuranceTypeID  = CI.InsuranceTypeID
	Group By A.InsuranceID ,A.InsuranceTypeID ,CI.InsuranceFileName '
	
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
