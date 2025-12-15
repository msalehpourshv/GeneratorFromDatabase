USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 95/08/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================

Create PROCEDURE [sal].[SpRegMatchSaleRet]
	@ProcessID		TinyInt,
	@ProcessNo		TinyInt,
	@FiscalYear	SmallInt,
	@SerialNo		Int
	WITH ENCRYPTION
AS

BEGIN

declare @RowCount		Int
declare @BaseProcessID		Int
declare	@BaseProcessNo		Int
declare @BaseFiscalYear	Int
declare @BaseSerialNo		Int
declare @AcntCode Varchar(20)
declare @VisitorAcntCode Varchar(20)
declare @DocDate char(10)


---------------------------تست مرجع دار بودن----------------------------------
select @BaseProcessID=BaseProcessID ,@BaseProcessNo=BaseProcessNo,@BaseFiscalYear=BaseFiscalYear,@BaseSerialNo=BaseSerialNo,@AcntCode=AcntCode,@DocDate=DocDate
From inv.tblStorageDocsHdr
where  @ProcessID=ProcessID and @ProcessNo=ProcessNo and @FiscalYear=FiscalYear  and @SerialNo=SerialNo
 
-- Select  @BaseProcessID ,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@AcntCode
 if (@BaseSerialNo=0)
 return


select @VisitorAcntCode=VisitorAcntCode From  inv.tblStorageDocsHdr
where  ProcessID=@BaseProcessID and ProcessNo =@BaseProcessNo and FiscalYear=@BaseFiscalYear  and SerialNo=@BaseSerialNo
And @BaseSerialNo<>BaseSerialNo


-----------------------------تست کل برگشت از یک فاکتور بودن--------------------------------
select @RowCount=COUNT(*) From  inv.tblStorageDocsDtl
where  @ProcessID=ProcessID and @ProcessNo=ProcessNo and @FiscalYear=FiscalYear  and @SerialNo=SerialNo
And @BaseSerialNo<>BaseSerialNo

if (@RowCount>0)
 return
 
 
--select @VisitorAcntCode
----------------------------محاسبه مبلغ باقی مانده تطبیق نشده فروش برای ثبت تطبیق برگشتی ---------------------------------

declare @PriceSale int
declare @PriceRet1 int
declare @PriceRet2 int
declare @PriceRet3 int
declare @PriceMatch int

------------مبلغ فروش------------
SELECT    @PriceSale= isnull(SUM(Debit),0)
FROM         acc.tblVoucherDtl
WHERE     (SourceProcessID= @BaseProcessID) AND (SourceProcessNo= @BaseProcessNo) AND (SourceFiscalYear= @BaseFiscalYear) AND (SourceSerialNo = @BaseSerialNo) AND (AcntCode = @AcntCode)
And BaseID=1 

------------مبلغ برگشت از فروش -----------
SELECT    @PriceRet1=isnull( SUM(Credit),0)
FROM         acc.tblVoucherDtl
WHERE     (SourceProcessID= @ProcessID) AND (SourceProcessNo= @ProcessNo) AND (SourceFiscalYear= @FiscalYear) AND (SourceSerialNo = @SerialNo) AND (AcntCode = @AcntCode)
And BaseID=1

------------مبلغ مالیات برگشت از فروش -----------
SELECT    @PriceRet2= isnull(SUM(Credit),0)
FROM         acc.tblVoucherDtl
WHERE     (SourceProcessID= @ProcessID) AND (SourceProcessNo= @ProcessNo) AND (SourceFiscalYear= @FiscalYear) AND (SourceSerialNo = @SerialNo) AND (AcntCode = @AcntCode)
And BaseID=2
------------مبلغ عوارض برگشت از فروش -----------
SELECT    @PriceRet3= isnull(SUM(Credit),0)
FROM         acc.tblVoucherDtl
WHERE     (SourceProcessID= @ProcessID) AND (SourceProcessNo= @ProcessNo) AND (SourceFiscalYear= @FiscalYear) AND (SourceSerialNo = @SerialNo) AND (AcntCode = @AcntCode)
And BaseID=3

--SELECT    *
--FROM         acc.tblVoucherDtl
--WHERE     (SourceProcessID= @ProcessID) AND (SourceProcessNo= @ProcessNo) AND (SourceFiscalYear= @FiscalYear) AND (SourceSerialNo = @SerialNo) AND (AcntCode = @AcntCode)

------------- مبلغ تطبیق شده ---------------


select @PriceMatch=SUM(Amount) from acc.tblAccState
where  (SourceProcessID1= @BaseProcessID) AND (SourceProcessNo1= @BaseProcessNo) AND (SourceFiscalYear1= @BaseFiscalYear) AND (SourceSerialNo1 = @BaseSerialNo) AND (AcntCode = @AcntCode)


--Select @PriceSale,@PriceMatch,@PriceRet1,@PriceSale-@PriceMatch,@PriceRet

--Select @PriceSale,@PriceMatch,@PriceRet1,@PriceSale-@PriceMatch,@PriceRet1

--If (@PriceSale-@PriceMatch<@PriceRet1)
-- return

--Select @PriceSale,@PriceMatch,@PriceRet1,@PriceRet2,@PriceRet3


--Select @PriceSale-@PriceMatch,@PriceRet1,@PriceRet2,@PriceRet3
--Select @PriceSale-@PriceMatch-@PriceRet1,@PriceRet2,@PriceRet3
--Select @PriceSale-@PriceMatch-@PriceRet1-@PriceRet2,@PriceRet3
--Select @PriceSale-@PriceMatch-@PriceRet1-@PriceRet2-@PriceRet3

--exec acc.SpAcc_AccState  '''',5,@ProcessID,	@ProcessNo,	@FiscalYear	,@SerialNo
 exec acc.SpAcc_AccState  @AcntCode,4,@ProcessID,	@ProcessNo,	@FiscalYear	,@SerialNo
 
 

 
 Delete  from acc.tblAccState 
 where SourceProcessID1=@BaseProcessID and  SourceProcessNo1=@BaseProcessNo and SourceFiscalYear1=@BaseFiscalYear and  SourceSerialNo1=@BaseSerialNo
 and SourceProcessID2=@ProcessID and  SourceProcessNo2=SourceProcessNo2 and  SourceFiscalYear2= SourceFiscalYear2 and SourceSerialNo2=SourceSerialNo2
and AcntCode=@AcntCode

 insert into acc.tblAccState (SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1, BaseID1
				, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2, BaseID2
				, DocDate, AcntCode, EventNo
				, Amount, RecDesc, VisitorAcntCode)  
                
   select @BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,1,
   @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,1,
   @DocDate,  @AcntCode,1,@PriceRet1,'تطبیق برگشت',@VisitorAcntCode
   
   
--If (@PriceSale-@PriceMatch-@PriceRet1<@PriceRet2)
-- return


 insert into acc.tblAccState (SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1, BaseID1
				, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2, BaseID2
				, DocDate, AcntCode, EventNo
				, Amount, RecDesc, VisitorAcntCode)  
                
   select @BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,1,
   @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,2,
   @DocDate,  @AcntCode,2,@PriceRet2,'تطبیق برگشت',@VisitorAcntCode
   
   
If (@PriceSale-@PriceMatch-@PriceRet1-@PriceRet2<@PriceRet3)
 return


 insert into acc.tblAccState (SourceProcessID1, SourceProcessNo1, SourceFiscalYear1, SourceSerialNo1, BaseID1
				, SourceProcessID2, SourceProcessNo2, SourceFiscalYear2,SourceSerialNo2, BaseID2
				, DocDate, AcntCode, EventNo
				, Amount, RecDesc, VisitorAcntCode)  
                
   select @BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,1,
   @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,3,
   @DocDate,  @AcntCode,3,@PriceRet3,'تطبیق برگشت',@VisitorAcntCode
   
-------------------------------------------------------------
-------------------------------------------------------------
-------------------------------------------------------------

end 
GO
