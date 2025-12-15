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
CREATE PROCEDURE [phr].[RptPhr_UserWork]

	@FiscalYear			Int = Null,
	@SerialNo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@ReciptionTypeID	Tinyint = Null,
	@IsInternetConfirm	Bit = Null,
	@UserID				Varchar(20) = Null,
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

DECLARE	@CashPay	Float;
DECLARE	@PosPay		Float;
DECLARE	@DepositPay	Float;


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

	-- Where Clause -----------------------------------------
	Select @StrWhere = '1 = 1'

	--IF (@FiscalYear Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND D.FiscalYear = ' + LTrim(Str(@FiscalYear))  
		
	--IF (@SerialNo Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND D.SerialNo = ' + LTrim(Str(@SerialNo))  

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RH.DocDate >= ''' + LTrim(RTrim(@DocDateFr)) + '''' 

	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RH.DocDate <= ''' + LTrim(RTrim(@DocDateTo)) + ''''

	IF (@ReciptionTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RH.ReciptionTypeID = ' + LTrim(Str(@ReciptionTypeID))		
		
	IF (@IsInternetConfirm Is Not Null)
		SET @StrWhere = @StrWhere + ' AND RH.IsInternetConfirm = ' + LTrim(Str(@IsInternetConfirm))		
		
	IF @UserID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND pub.GetUserName(RH.SessionNo) = ''' + LTrim(RTrim(@UserID)) + ''''
		
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	Select RH.SerialNo, RH.ReciptionTypeID, RH.DocDate, 
		   phr.FunGetInsuranceName(RH.InsuranceID,1) As InsuranceName,
		   phr.FunGetInsuranceTypeName(RH.InsuranceTypeID,1) As InsuranceTypeName, 
		   RH.PayablePrice,RH.SessionNo, pub.GetUserName(RH.SessionNo) As UserName, RH.*
	From phr.tblReciptionHdr RH
	Where ' + @StrWhere + '
	ORDER BY RH.SerialNo '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
