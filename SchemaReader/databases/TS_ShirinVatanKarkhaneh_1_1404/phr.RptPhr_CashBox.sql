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
CREATE PROCEDURE [phr].[RptPhr_CashBox]

	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@PayTypeID		Int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@UserID			Varchar(20) = Null,
	@RepOptions		VarChar(10) = '111011111',  -- bit array options
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

	IF (@PayTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND A.PayTypeID = ' + LTrim(Str(@PayTypeID))

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + LTrim(RTrim(@DocDateFr)) + '''' 

	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + LTrim(RTrim(@DocDateTo)) + ''''

	IF @UserID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND A.UserID = ''' + LTrim(RTrim(@UserID)) + ''''
		
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT D.*, A.PayTypeID, 
				(select  IllName + '' - '' + IllLastName from phr.tblReciptionHdr where SerialNo=D.ReciptionSerialNo ) As PatientName, 
				A.DiscountAmount,
		   A.BankReceiptNo, A.PayedAmount As AtomPayedAmount,
		   Case When A.PayTypeID = 1 Then A.PayedAmount End As CashPay, 
		   Case When A.PayTypeID = 2 Then A.PayedAmount End As PosPay, 
		   Case When A.PayTypeID = 3 Then A.PayedAmount End As DepositPay
	FROM phr.tblCashBoxDtl D
		INNER JOIN phr.tblCashBoxAtm A ON D.SerialNo = A.SerialNo And D.DocRowNo = A.DocRowNo And
										  D.DocDate = A.DocDate And D.UserID = A.UserID	
		LEFT JOIN phr.tblPatientDtl PD ON D.PatientID = PD.PatientID
	WHERE ' + @StrWhere + '
	ORDER BY D.SerialNo '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
