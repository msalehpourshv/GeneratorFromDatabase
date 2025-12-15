USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1397/02/21
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- اعتبار مشتری
-- ==============================================

Create PROCEDURE [acc].[SpAccountCredit]
	@ExtraParams		NVarChar(Max) 
	WITH ENCRYPTION
AS

BEGIN

	
DECLARE	@PartNumber			 Int;
DECLARE	@StartLayer			 Int;
DECLARE	@LenLayer			 Int;

DECLARE	@AccountRemain		 bigInt;
DECLARE	@MaxDebitRemain		 bigInt;
DECLARE	@ComplementMaxCredit bigInt;

DECLARE	@ProcessID Int;
DECLARE	@ProcessNo Int;
DECLARE	@FiscalYear Int;
DECLARE	@SerialNo Int;

            
DECLARE @AcntCode			 varchar(20)
DECLARE @DocDate 			 char(10)

SET @AcntCode			 = pub.funSplitString(@ExtraParams, '@', 1);
SET @DocDate			 = pub.funSplitString(@ExtraParams, '@', 2);
SET @ProcessID			 = pub.funSplitString(@ExtraParams, '@', 3);
SET @ProcessNo			 = pub.funSplitString(@ExtraParams, '@', 4);
SET @FiscalYear			 = pub.funSplitString(@ExtraParams, '@', 5);
SET @SerialNo			 = pub.funSplitString(@ExtraParams, '@', 6);


	select @PartNumber=acc.FunGetAcntInfoForRemain(1),@StartLayer=acc.FunGetAcntInfoForRemain(2),@LenLayer=acc.FunGetAcntInfoForRemain(3)

	SELECT	@AccountRemain= IsNull(Sum(Debit), 0) -IsNull(Sum(Credit), 0)   
	FROM	acc.tblVoucherDtl a   
	WHERE VchKind <> 0 
	AND SUBSTRING(a.AcntCode,@StartLayer,@LenLayer) =substring(@AcntCode,@StartLayer,@LenLayer)
	and  not  ( SourceProcessID=@ProcessID and  SourceProcessNo=@ProcessNo and  SourceFiscalYear=@FiscalYear and  SourceSerialNo=@SerialNo )
	
	select @MaxDebitRemain=IsNull(MaxDebitRemain,0) +IsNull(MaxReceivableRemain,0) 
	 from acc.tblAcnt   
	  where PartNumber=@PartNumber  
	   AND AcntCode=substring(@AcntCode,@StartLayer,@LenLayer)



	SELECT  @ComplementMaxCredit=isnull(sum(DebtorCreditRemain+VouchersCreditRemain),0)  
	FROM sal.tblComplementMaxCreditHdr a inner join sal.tblComplementMaxCreditDtl  b
	on a.SerialNo=b.SerialNo
	where CustomerAcntCode=@AcntCode
	and StartDate<=@DocDate
	and @DocDate<pub.funFarsiDateAddDays('Day',case when StartDate='' then DocDate else StartDate end ,CreditTime) 
	   
	
select isnull(@AccountRemain, 0) AccountRemain ,isnull(@MaxDebitRemain , 0) MaxDebitRemain,isnull(@ComplementMaxCredit, 0) ComplementMaxCredit


end
GO
