USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari	
-- Create date   : 96/01/07
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[spPays2Settlement]
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

Declare @DocDate as char(10)
Declare @DebitCode as varchar(20)
Declare @CreditCode as varchar(20)
Declare @ReceiptOperatorID as varchar(20)
Declare @BankID as varchar(20)
Declare @CashID as varchar(20)
Declare @CashID2 as varchar(20)
Declare @PayTypeID as int
Declare @hProcessID as int=0
Declare @hProcessNo as int=0
Declare @hFiscalYear as int=0
Declare @hSerialNo as int=0
Declare @BaseProcessID as int=0
Declare @BaseProcessNo as int=0
Declare @BaseFiscalYear as int=0
Declare @BaseSerialNo as int=0
Declare @DocRowNo as int=0
Declare @Amount as Decimal(28,9)=0
Declare @ChequeNo as Decimal(28,9)=0

Declare @SerialNo as int=0
--Declare @FiscalYear as int=95
Declare @Counter as int=0

----------------------------------------------------------------------------------------------------------------------------
--delete 
--select * from sal.tblReceiptOperator
if  ((select COUNT(*) from sal.tblReceiptOperator)<=0 )
begin	--کد فروش کالا خالي است 
	--Raiserror ('حداقل یک عامل وصول تعریف کنید',16,1)
	--Return

	insert into sal.tblReceiptOperator(ReceiptOperatorID)				
	select '001'

	insert into sal.tblReceiptOperatorDtl( ReceiptOperatorID, LanguageID, ReceiptOperatorName)				
	select '001',1,'---'

end

----------------------------------------------------------------------------------------------------------------------------

select Top 1  @ReceiptOperatorID=ReceiptOperatorID from sal.tblReceiptOperator



DECLARE curPay CURSOR FOR 
		
select  Distinct  h.ProcessID, h.ProcessNo,  h.FiscalYear,  h.SerialNo,h.DocDate,d.CreditCode ,d.DebitCode,d.Amount,d.PayTypeID,
	 h.BaseProcessID, h.BaseProcessNo,  h.BaseFiscalYear,  h.BaseSerialNo,d.ChequeNo
from trs.tblPayHdr h
inner join trs.tblPayDtl d on h.ProcessID=d.ProcessID and h.ProcessNo=d.ProcessNo and   h.FiscalYear=d.FiscalYear and  h.SerialNo=d.SerialNo
where h.BaseProcessID=90 and h.BaseProcessNo=10
and d.PayTypeID in (1,6,35)
Order by h.DocDate

----------------------------------------------------------------------------------------------------------------------------
OPEN curPay
FETCH NEXT FROM curPay INTO @hProcessID, @hProcessNo,  @hFiscalYear,  @hSerialNo,@DocDate,@CreditCode ,@DebitCode,@Amount,@PayTypeID,@BaseProcessID, @BaseProcessNo,  @BaseFiscalYear,  @BaseSerialNo,@ChequeNo

WHILE @@Fetch_Status = 0
BEGIN
	set @SerialNo=0

	if @PayTypeID=1
		Select @SerialNo=isnull(SerialNo ,0) from trs.tblSettlementHdr where DocDate=@DocDate and (CashID=@DebitCode or CashID='' ) and  FiscalYear =@hFiscalYear 

	if @PayTypeID=6
		Select @SerialNo=isnull(SerialNo ,0) from trs.tblSettlementHdr where DocDate=@DocDate and (CashID2=@DebitCode or CashID2 ='' ) and  FiscalYear =@hFiscalYear 

	if @PayTypeID=35
		Select @SerialNo = ISNULL(SerialNo ,0) from trs.tblSettlementHdr where DocDate=@DocDate and (BankID=@DebitCode or  BankID='') and  FiscalYear =@hFiscalYear 
			
	if 	@SerialNo=0
	begin
		select @SerialNo = ISNULL(max(SerialNo) ,0)+1 from trs.tblSettlementHdr where ProcessID=209 and  ProcessNo=1 and  FiscalYear =@hFiscalYear 

		if @PayTypeID=1
			Insert into  trs.tblSettlementHdr(ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, CollectorID, CashID)
			select 209,1,@hFiscalYear,@SerialNo,@DocDate,@ReceiptOperatorID,@DebitCode

		if @PayTypeID=6
			Insert into  trs.tblSettlementHdr(ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, CollectorID,CashID2)
			select 209,1,@hFiscalYear,@SerialNo,@DocDate,@ReceiptOperatorID,@DebitCode

		if @PayTypeID=35
			Insert into  trs.tblSettlementHdr(ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, CollectorID, BankID )
			select 209,1,@hFiscalYear,@SerialNo,@DocDate,@ReceiptOperatorID,@DebitCode				
	end

	else -- if 	@SerialNo<>0
	begin
	if @PayTypeID=1
		update  trs.tblSettlementHdr
		Set CashID=@DebitCode
		where DocDate=@DocDate and (CashID=@DebitCode or  CashID='')and  FiscalYear =@hFiscalYear 

	if @PayTypeID=6
		update  trs.tblSettlementHdr
		Set CashID2 =@DebitCode
		where DocDate=@DocDate and (CashID2=@DebitCode or  CashID2='')and  FiscalYear =@hFiscalYear 

	if @PayTypeID=35
		update  trs.tblSettlementHdr
		Set BankID=@DebitCode
		where DocDate=@DocDate and (BankID=@DebitCode or  BankID='')and  FiscalYear =@hFiscalYear 
			
	end
			
	Update trs.tblPayHdr
	Set SettlementSerialNo=@SerialNo
	where ProcessID=@hProcessID and ProcessNo=@hProcessNo and FiscalYear=@hFiscalYear and SerialNo=@hSerialNo
			
	----------------------------------------------------------------------------------------------------------------------------			
	Set @DocRowNo =0

	Select @DocRowNo=DocRowNo From  trs.tblSettlementDtl
	Where BaseSaleProcessID=@BaseProcessID and BaseSaleProcessNo=@BaseProcessNo and BaseSaleFiscalYear=@BaseFiscalYear and BaseSaleSerialNo=@BaseSerialNo
		and SerialNo=@SerialNo and FiscalYear=@hFiscalYear

	if @DocRowNo=0
	begin
		if @PayTypeID=1
			insert into trs.tblSettlementDtl (ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, 
				BaseSaleProcessID, BaseSaleProcessNo, BaseSaleFiscalYear, BaseSaleSerialNo, CustomerAcntCode, CashPrice, 
				BasePayProcessID, BasePayProcessNo, BasePayFiscalYear, BasePaySerialNo)
			select 209,1,@hFiscalYear,@SerialNo,(select isnull(MAX(RowNo),0)+1 From trs.tblSettlementDtl where SerialNo=@SerialNo and FiscalYear=@hFiscalYear )
				,( select isnull(MAX(DocRowNo),0)+1 From trs.tblSettlementDtl where SerialNo=@SerialNo and FiscalYear=@hFiscalYear )
				,@BaseProcessID, @BaseProcessNo,  @BaseFiscalYear,  @BaseSerialNo
				,@CreditCode ,@Amount, @hProcessID, @hProcessNo,  @hFiscalYear,  @hSerialNo

		if @PayTypeID=6
			insert into trs.tblSettlementDtl (ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, 
				BaseSaleProcessID, BaseSaleProcessNo, BaseSaleFiscalYear, BaseSaleSerialNo, CustomerAcntCode, ChequePrice, 
				BasePayProcessID, BasePayProcessNo, BasePayFiscalYear, BasePaySerialNo)
			select 209,1,@hFiscalYear,@SerialNo,(select isnull(MAX(RowNo),0)+1 From trs.tblSettlementDtl where SerialNo=@SerialNo and FiscalYear=@hFiscalYear )
				,( select isnull(MAX(DocRowNo),0)+1 From trs.tblSettlementDtl where SerialNo=@SerialNo and FiscalYear=@hFiscalYear )
				,@BaseProcessID, @BaseProcessNo,  @BaseFiscalYear,  @BaseSerialNo
				,@CreditCode ,@Amount, @hProcessID, @hProcessNo,  @hFiscalYear,  @hSerialNo

		if @PayTypeID=35			
			insert into trs.tblSettlementDtl (ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, 
				BaseSaleProcessID, BaseSaleProcessNo, BaseSaleFiscalYear, BaseSaleSerialNo
				, CustomerAcntCode, DraftPrice, BasePayProcessID, BasePayProcessNo, BasePayFiscalYear, BasePaySerialNo,ChequeNo)

			select 209,1,@hFiscalYear,@SerialNo,(select isnull(MAX(RowNo),0)+1 From trs.tblSettlementDtl where SerialNo=@SerialNo and FiscalYear=@hFiscalYear )
				,( select isnull(MAX(DocRowNo),0)+1 From trs.tblSettlementDtl where SerialNo=@SerialNo and FiscalYear=@hFiscalYear )
				,@BaseProcessID, @BaseProcessNo,  @BaseFiscalYear,  @BaseSerialNo
				,@CreditCode ,@Amount, @hProcessID, @hProcessNo,  @hFiscalYear,  @hSerialNo,@ChequeNo
												
		end

	else --if @DocRowNo<>0
	begin
		if @PayTypeID=1
			Update  trs.tblSettlementDtl 
			Set CashPrice= @Amount --DraftPrice
			Where BaseSaleProcessID=@BaseProcessID and BaseSaleProcessNo=@BaseProcessNo and BaseSaleFiscalYear=@BaseFiscalYear and BaseSaleSerialNo=@BaseSerialNo
				and SerialNo=@SerialNo and FiscalYear=@hFiscalYear

		if @PayTypeID=6
			Update  trs.tblSettlementDtl 
			Set ChequePrice= @Amount 
			Where BaseSaleProcessID=@BaseProcessID and BaseSaleProcessNo=@BaseProcessNo and BaseSaleFiscalYear=@BaseFiscalYear and BaseSaleSerialNo=@BaseSerialNo
				and SerialNo=@SerialNo and FiscalYear=@hFiscalYear

		if @PayTypeID=35
			Update  trs.tblSettlementDtl 
			Set DraftPrice= @Amount ,ChequeNo=@ChequeNo
			Where BaseSaleProcessID=@BaseProcessID and BaseSaleProcessNo=@BaseProcessNo and BaseSaleFiscalYear=@BaseFiscalYear and BaseSaleSerialNo=@BaseSerialNo
				and SerialNo=@SerialNo and FiscalYear=@hFiscalYear
	end

	Set @Counter=@Counter+1

	FETCH NEXT FROM curPay INTO @hProcessID, @hProcessNo,  @hFiscalYear,  @hSerialNo,@DocDate,@CreditCode ,@DebitCode,@Amount,@PayTypeID,@BaseProcessID, @BaseProcessNo,  @BaseFiscalYear,  @BaseSerialNo,@ChequeNo

END

CLOSE curPay
DEALLOCATE curPay
	
end
GO
