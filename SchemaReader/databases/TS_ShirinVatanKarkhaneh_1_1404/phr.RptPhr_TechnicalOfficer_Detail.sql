USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/09/01
-- Viewed By	 : 
-- Last Modified : 1393/09/01
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
create PROCEDURE [phr].[RptPhr_TechnicalOfficer_Detail]

	@InsuranceID			Varchar(20) = Null,
	@InsuranceTypeID		Varchar(20) = Null,
	@ReciptionTypeID		Tinyint = Null,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@PrescriptionDateFr		Char(10) = Null,
	@PrescriptionDateTo		Char(10) = Null,
	@DocTimeFr				Char(5) = Null,
	@DocTimeTo				Char(5) = Null,
	@DeliverUserID			Varchar(20) = Null,
	@CompInsuranceID		Varchar(20) = Null,
	@CompInsuranceTypeID	Varchar(20) = Null,
	@RepOptions				VarChar(10) = '111011111',  -- Bit Array Options
	@RepInfo				NVarChar(100) = '1@1@1'

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

	IF (@InsuranceID Is Not Null And @InsuranceID <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.InsuranceID = ''' + @InsuranceID + ''')'

	If (@InsuranceTypeID Is Not Null And @InsuranceTypeID <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.InsuranceTypeID = ''' + @InsuranceTypeID + ''')'

	IF (@CompInsuranceID Is Not Null And @CompInsuranceID <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.CompleteInsuranceID = ''' + @CompInsuranceID + ''')'

	If (@CompInsuranceTypeID Is Not Null And @CompInsuranceTypeID <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.CompleteInsuranceTypeID = ''' + @CompInsuranceTypeID + ''')'
				
	IF (@ReciptionTypeID Is Not Null And @ReciptionTypeID <> '')
		SET @StrWhere = @StrWhere + ' AND RH.ReciptionTypeID = ' + LTrim(Str(@ReciptionTypeID))	
				
	IF (@DocDateFr Is Not Null And @DocDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null And @DocDateTo <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.DocDate <= ''' + @DocDateTo + ''')'
			
	IF (@PrescriptionDateFr Is Not Null And @PrescriptionDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.PrescriptionDate >= ''' + @PrescriptionDateFr + ''')'
	
	IF (@PrescriptionDateTo Is Not Null And @PrescriptionDateTo <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.PrescriptionDate <= ''' + @PrescriptionDateTo + ''')'
					
	IF (@DocTimeFr Is Not Null And @DocTimeFr <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.DocTime >= ''' + @DocTimeFr + ''')'
	IF (@DocTimeTo Is Not Null And @DocTimeTo <> '')
		SET @StrWhere = @StrWhere + ' AND (RH.DocTime <= ''' + @DocTimeTo + ''')'
							
	IF @DeliverUserID > -1
		SET @StrWhere = @StrWhere + ' AND CD.DeliverUserID = ''' + @DeliverUserID + ''''	
		
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	Select Distinct RH.SessionNo ,CD.ReciptionSerialNo, RH.DocDate, RH.PrescriptionDate, RH.DocTime ,
			RH.IllName + '' '' + RH.IllLastName As PatientName ,CD.DeliveryToCustomer ,RH.FiscalYear, 
			ID.InsuranceName, ITD.InsuranceTypeName, RH.PayablePrice ,RH.InsurancePortionSum,
			isnull(phr.FunGetInsuranceName(CompleteInsuranceID,1),'''')comInsuranceName,
			isnull(phr.FunGetInsuranceTypeName(CompleteInsuranceTypeID,1),'''')comInsuranceTypeName
	From phr.tblReciptionHdr RH 
	Inner Join phr.tblCashBoxDtl CD ON RH.SerialNo = CD.ReciptionSerialNo 
	Left Join phr.tblInsuranceDtl ID On RH.InsuranceID = ID.InsuranceID 
	Left Join phr.tblInsuranceTypeDtl ITD On RH.InsuranceTypeID = ITD.InsuranceTypeID 
	Where ' + @StrWhere + '
	Order by CD.ReciptionSerialNo DESC '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
