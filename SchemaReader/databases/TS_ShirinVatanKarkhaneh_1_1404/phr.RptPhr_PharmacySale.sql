USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/01/07
-- Viewed By	 : 
-- Last Modified : 1393/01/20
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
create PROCEDURE [phr].[RptPhr_PharmacySale]-- 93,3662

	@FiscalYear			Int = Null,
	@SerialNo			Int = Null,
	@ReciptionTypeID	Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@DocTimeFr			Char(5) = Null,
	@DocTimeTo			Char(5) = Null,
	@UserID			    Varchar(20) = Null,
	@RepOptions			VarChar(10) = '1',  -- bit array options
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

DECLARE	@CashPay	Float;
DECLARE	@PosPay		Float;
DECLARE	@DepositPay	Float;
DECLARE	@IsPayReciption	char(1);


Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------

	IF (@FiscalYear Is Null)	SET @SerialNo = Null;
	IF (@SerialNo	Is Null)	SET @FiscalYear = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	Set @CashPay = 0;
	Set @PosPay = 0;
	Set @DepositPay = 0;
	set @IsPayReciption=pub.funSplitString(@RepOptions, '@', 1);
	
	-- Where Clause -----------------------------------------
	Select @StrWhere = '1 = 1'

	--IF (@FiscalYear Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND D.FiscalYear = ' + LTrim(Str(@FiscalYear))  
		
	--IF (@SerialNo Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND D.SerialNo = ' + LTrim(Str(@SerialNo))  

	IF (@ReciptionTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.ReciptionTypeID = ' + LTrim(Str(@ReciptionTypeID))

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.DocDate >= ''' + LTrim(RTrim(@DocDateFr)) + '''' 

	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.DocDate <= ''' + LTrim(RTrim(@DocDateTo)) + ''''
		
	IF (@DocTimeFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.DocTime >= ''' + LTrim(RTrim(@DocTimeFr)) + '''' 

	IF (@DocTimeTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.DocTime <= ''' + LTrim(RTrim(@DocTimeTo)) + ''''		

	IF @UserID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND A.UserID = ''' + LTrim(RTrim(@UserID)) + ''''
		
	if @IsPayReciption='1'
	 	SET @StrWhere = @StrWhere + ' AND (select COUNT(*) from  phr.tblCashBoxDtl
			where phr.tblCashBoxDtl.ReciptionSerialNo=H.SerialNo and
			phr.tblCashBoxDtl.ReciptionFiscalYear=H.FiscalYear)>0'
	 
	-- Select Clause -------------------------------------------
	
	
		SET @StrSelect = '
		Select H.FiscalYear,H.PrescriptionDate,H.CompleteInsuranceSum, H.SerialNo, H.DocDate, H.ReciptionTypeID, SUM(D.SalePrice*Qty) As Azad_Sum, 
			   SUM(D.InsurancePrice*Qty) As InsurancePrice_Sum, 
			   H.ProficiencyCost, H.IllPortionSum,
			   H.InsurancePortionSum, H.InformaticCost,
			    SUM(D.PriceDiff) As PriceDiff, H.PayablePrice,H.Discount
			    ,H.InsuranceProfCost,H.PlusCost,H.BoxingCost
		From phr.tblReciptionHdr H
		Inner Join phr.tblReciptionDtl D ON D.SerialNo = H.SerialNo	
		Where '+ @StrWhere + '
		Group By H.FiscalYear, H.SerialNo, H.DocDate, H.ProficiencyCost, H.IllPortionSum, 
				 H.InsurancePortionSum, H.InformaticCost, H.PayablePrice, H.ReciptionTypeID	
				 ,H.PrescriptionDate,H.CompleteInsuranceSum,H.Discount,H.InsuranceProfCost
				 ,H.PlusCost,H.BoxingCost
				 
				 
		ORDER BY H.SerialNo '
	


	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
