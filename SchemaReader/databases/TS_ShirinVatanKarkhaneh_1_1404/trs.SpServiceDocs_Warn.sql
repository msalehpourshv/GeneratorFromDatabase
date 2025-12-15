USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1393/11/04
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\
-- Description	 : <Service Documents Report>
-- ----------------------------------------------
-- گزارش سررسید خدمات
-- ==============================================
Create PROCEDURE [trs].[SpServiceDocs_Warn]
	@ProcessID			Int = 49,  -- < 1: Cheques In Cash > < 2: Cheques Not In Cash > < 3: Returned Cheques >
	@ProcessNo			Int = 1,
	@DueDate0	    	VarChar(10) = Null, --تاریخ سررسید تا
	@DueDate1	    	VarChar(10) = Null, --تاریخ سررسید تا
	@SortFields			NVarChar(100) = Null, -- لیست فیلدها برای مرتب سازی
	@RepOptions			NVarChar(100) = '1000111', -- آرایه بیتی
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
As
DECLARE @IncludeCash		Bit;  --  مربوط به صندوق 
DECLARE @IncludePerson		Bit;  --  مربوط به اشخاص 
DECLARE @IncludeBank		Bit;  -- مربوط به بانکها 
DECLARE @IncludeTransfer	Bit;  -- مربوط به انتقال 

DECLARE @IncludeConfirmed1	Bit;  
DECLARE @RecPrims		Bit;  
DECLARE @RecNoPrims		Bit;  

DECLARE @StrWhere			NVarChar(2000);
DECLARE @StrWhereI			NVarChar(2000);
DECLARE @StrSelect			NVarChar(2000);
DECLARE @StrResult			NVarChar(4000);
DECLARE @StrPID				NVarChar(2000);

DECLARE @ReceivePrim		TinyInt
DECLARE @Receive			TinyInt
DECLARE @ReceiveReceipt		TinyInt
DECLARE @ReceiveRet			TinyInt

DECLARE @PaidPerson			TinyInt
DECLARE @PaidPersonRetCash	TinyInt
DECLARE @PaidPersonRetOwner TinyInt

DECLARE @PaidBankPrim		TinyInt
DECLARE @PaidBank			TinyInt
DECLARE @PaidBankReceipt	TinyInt
DECLARE @PaidBankRetCash	TinyInt
DECLARE @PaidBankRetOwner	TinyInt

DECLARE @BaseDate		Char(10)
DECLARE @Transfer		Varchar(10)
DECLARE @StrPayTypeID	Varchar(10)
DECLARE @StrBaseDate	nVarchar(20)

DECLARE	@TrsCalcAvgByDocDate bit;
DECLARE	@StrDebitName	VarChar(500)
DECLARE @StrCreditName	VarChar(500)
DECLARE @LangID			Char(1)
DECLARE @SessionNo		VarChar(10)
DECLARE @ReportID		VarChar(10)
BEGIN   

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 0
	If (@SortFields Is Null)	SET @SortFields = 'FiscalYear, SerialNo'

	SET @IncludeCash	= Cast(Cast(SubString(@RepOptions, 1, 1) As Int) As Bit)
	SET @IncludePerson	= Cast(Cast(SubString(@RepOptions, 2, 1) As Int) As Bit)
	SET @IncludeBank	= Cast(Cast(SubString(@RepOptions, 3, 1) As Int) As Bit)
	SET @IncludeTransfer= Cast(Cast(SubString(@RepOptions, 4, 1) As Int) As Bit)
	
	SET @IncludeConfirmed1= Cast(Cast(SubString(@RepOptions, 6, 1) As Int) As Bit)
	SET @RecNoPrims	= Cast(Cast(SubString(@RepOptions, 7, 1) As Int) As Bit)
	SET @RecPrims	= Cast(Cast(SubString(@RepOptions, 8, 1) As Int) As Bit)
		
	select @TrsCalcAvgByDocDate = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'TrsCalcAvgByDocDate'

	

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	IF	@IncludeCash = 0 AND @IncludePerson = 0 AND	@IncludeBank = 0 
		SET @IncludeCash = 1

	SELECT @StrPID = ''
	SELECT @StrResult = ''
	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	

	-----------------------------------------------------------------
	set @StrResult=' where 1=1 '
	
	IF (@DueDate0 Is Not Null)
		SET @StrResult = @StrResult + ' AND D.DueDate >= ''' + @DueDate0 + ''''
	IF (@DueDate1 Is Not Null)
	SET @StrResult = @StrResult + ' AND D.DueDate <= ''' + @DueDate1 + ''''

	
	IF (@SortFields Is Not Null)
		SET @StrResult = @StrResult + ' ORDER BY ' + @SortFields
	
	SET @StrSelect = '
				SELECT     D.SerialNo, D.ServiceID, acc.funGetServiceName(D.ServiceID, 1) AS ServiceName, D.DueDate, H.AcntCode, pub.GetCodeName(H.AcntCode, 1) AS AcntName, D.RowNo,
                       D.DescDtl, D.ServiceQuantity, D.ServiceAmount, D.DocRowNo, D.DiscountPercentDtl, D.DiscountDtl, D.DueDate AS EXPR3, H.DocDate, H.DescHdr, 
                      H.ServiceDiscount, H.TaxOverWorthAcntCode, H.TaxOverWorthCost, H.VchNo, H.RecID, H.SessionNo, H.DiscountAcntCode, H.OldSerialNo, H.VchDate, H.ExpertCode, 
                      H.ProcessID, H.ProcessNo, H.FiscalYear, H.TollOverWorthAcntCode, H.TollOverWorthCost, H.CashAmount, H.ChequeAmount, H.DiscountPercent, H.VisitorAcntCode, 
                      H.VisitorPercent, H.TaskTax, H.TaskTaxAcntCode
FROM         acc.tblServicesDtl AS D INNER JOIN
                      acc.tblServicesHdr AS H ON D.SerialNo = H.SerialNo  '+ @StrResult

	/* -------------- Category <1> (Available Cheques) --------------------------- */
	

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
