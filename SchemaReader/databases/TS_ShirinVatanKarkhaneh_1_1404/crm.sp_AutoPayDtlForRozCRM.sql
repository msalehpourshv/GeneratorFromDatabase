USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1402/07/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE crm.sp_AutoPayDtlForRozCRM
	@ProcessNo		int,
	@FiscalYear		int,
	@SerialNo		Int,
	@RowNo			Int,
	@PayTypeID		nvarchar(20),
	@DebitCode		VARCHAR(20),
	@CreditCode		VARCHAR(60),
	@Amount			FLOAT,
	@ChequeNo		VARCHAR(60),
	@ChequeNoNew	VARCHAR(60),
	@ChequeDate		CHAR(10),
	@LocationID		VARCHAR(60),	
	@BankTypeID		VARCHAR(60),
	@AccountNo		VARCHAR(60),
	@NationalIDNumber CHAR(10),
	@RowDesc		NVARCHAR(500),
	@ExtraParams	NVarChar(Max)		

WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage	Nvarchar(1024)
DECLARE @Enter				SmallInt
DECLARE	@DocDate			CHAR(10)
Declare @BankCode			VARCHAR(20)
Declare @BranchCode			VARCHAR(20)
Declare @BranchName			NVARCHAR(100)
Declare @AccountOwnerName	VARCHAR(100)
DECLARE @VchNo				INT
DECLARE @VchDate			CHAR(10)
 
BEGIN TRY	
	

	if @PayTypeID <>1 and @PayTypeID <>6  and @PayTypeID <>35  and @PayTypeID <>38
  		begin
			Set @StrErrorMessage = N'نوع پرداخت نادرست است  وباید یکی از گزینه های زیر باشد  1- واریز نقدی  6-چک 38- واریز اینتزنتی 35- کارت خوان'
			raiserror (@StrErrorMessage, 16, 1)
		end	
	
	if @PayTypeID =6  and (isnull(@ChequeNo,'')='' or isnull(@ChequeDate,'')=''  or isnull(@BankTypeID,'')=''  or isnull(@LocationID,'')='' or isnull(@AccountNo,'')='' )
  		begin
			if isnull(@ChequeNo,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع اسناد دریافتنی شماره چک اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end
			if isnull(@ChequeDate,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع اسناد دریافتنی تاریخ چک اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end
			if isnull(@LocationID,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع اسناد دریافتنی شهر اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end
			if isnull(@BankTypeID,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع اسناد دریافتنی بانک  اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end
			if isnull(@AccountNo,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع اسناد دریافتنی شماره حساب اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end
		end
		if @PayTypeID =35
  		begin
			if isnull(@ChequeNo,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع واریز کارت خوان شماره پیگیری اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end 
			if isnull(@ChequeDate,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع واریز کارت خوان تاریخ اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end 
		end
		if @PayTypeID =38  
  		begin
			if isnull(@ChequeNo,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع واریز اینترنتی شماره پیگیری اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end 
			if isnull(@ChequeDate,'')=''
			begin 
				Set @StrErrorMessage = N'در نوع واریز اینترنتی تاریخ اجباری است'
				raiserror (@StrErrorMessage, 16, 1)
			end 
		end
	if(@SerialNo<=0)
		begin
			Set @StrErrorMessage = N'لطفا شماره برگه را مقداردهی کنید'
			raiserror (@StrErrorMessage, 16, 1)
		end 

	IF @DebitCode=''
		BEGIN
			Set @StrErrorMessage = N'لطفا کد حساب مقصد را مقداردهی کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END	
	IF @CreditCode=''
		BEGIN
			Set @StrErrorMessage = N'لطفا کد حساب مبدا را مقداردهی کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END	
	
	IF (SELECT COUNT(*) FROM trs.tblOurBanks	where BankCode=@DebitCode)<=0
	BEGIN
		Set @StrErrorMessage = N'حساب بانکی در سیستم خزانه داری بانکی معرفی نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
		
	SELECT @DocDate = DocDate,@VchNo=VchNo, @VchDate=case when isnull(VchDate,'')='' then DocDate else VchDate end  FROM trs.tblPayHdr
	WHERE SerialNo=@SerialNo AND ProcessID=1 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear


	if @PayTypeID =38 
	begin
		SELECT @BankCode=BankCode,@BankTypeID=BankTypeID,@LocationID=LocationID,@BranchCode=BranchCode
		FROM trs.tblOurBanks
		where BankCode=@DebitCode
	
		SELECT @BranchName=BranchName,@AccountOwnerName=AccountOwnerName
		FROM trs.tblOurBanksDtl
			where BankCode=@DebitCode
	end 
	if @PayTypeID =6 
	begin
		IF (SELECT COUNT(*) FROM trs.tblOurBanks	where BankCode=@DebitCode)<=0
			BEGIN
				Set @StrErrorMessage = N'حساب بانکی در سیستم خزانه داری بانکی معرفی نشده است'
				raiserror (@StrErrorMessage, 16, 1)
			END	
	end

	set @BranchCode=isnull(@BranchCode,'')
	set @BranchName=isnull(@BranchName,'')
	set @AccountOwnerName=isnull(@AccountOwnerName,'')
	if (select count(*) from trs.tblPayDtl where ProcessID=1 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and SerialNo=@SerialNo and RowNo=@RowNo)=0
	begin	
		
		INSERT INTO   trs.tblPayDtl(ProcessID,ProcessNo,FiscalYear,SerialNo, RowNo,DocDate,PayTypeID, DebitCode, CreditCode, Amount, 
									ChequeNo, ChequeNoNew, ChequeDate,RowDesc,LocationID,BankTypeID,BranchCode,BranchName,AccOwnerName,AccountNo,NationalIDNumber)
					SELECT 1, @ProcessNo,@FiscalYear,@SerialNo, @RowNo,@DocDate,@PayTypeID, @DebitCode, @CreditCode, @Amount, 
					@ChequeNo, @ChequeNoNew, @ChequeDate,@RowDesc,@LocationID,@BankTypeID,@BranchCode,@BranchName,@AccountOwnerName	,@AccountNo,@NationalIDNumber
	end

	if @PayTypeID =6 
	begin-------- شماره دفتر چک
		DECLARE @MaxVolumeRowNo int
		
		SELECT @MaxVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
		FROM trs.tblPayDtl 
		WHERE PayTypeID IN (6,26) AND
			  VolumeFiscalYear = @FiscalYear
		
		 if @MaxVolumeRowNo=0
			SELECT   @MaxVolumeRowNo= SettingValue FROM         pub.tblSettings WHERE     (SettingKey = N'StartVolumeRowNo')
		
		update trs.tblPayDtl
		set VolumeFiscalYear=FiscalYear , VolumeRowNo=@MaxVolumeRowNo
		where ProcessID=1 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and SerialNo=@SerialNo and RowNo=@RowNo

	end
	
	if @VchNo <> 0 and @SerialNo <> 0
		delete from acc.tblVoucherDtl 
		where SourceProcessID = 2  and 
			  SourceProcessNo = @ProcessNo  and 
			  SourceFiscalYear= @FiscalYear and 
			  SourceSerialNo  = @SerialNo
			
		select top 1 VchNo into #tblVchNo  from trs.tblPayHdr
		
		insert into #tblVchNo	-------- صدور سند
		exec [acc].[SpVch_CreateDoc]   
			@intVchNo			= @VchNo,  
			@intDocStep		    = 0,  
			@strVchDate			= @VchDate, 
			@strOldVchDate		= @VchDate,  
			@intSourceProcessID	= 1,  
			@intSourceProcessNo	= @ProcessNo,  
			@intSourceFiscalYear= @FiscalYear,  
			@intSourceSerialNo	= @SerialNo,  
			@strHdrTblName		= 'trs.tblPayHdr',  
			@strVchNoFieldName	= 'VchNo',  
			@VoucherCreateMetod	= 2 ,  
			@DocFormType        = 2 ,  
			@SelectedUserVchNoType = 1 ,
			@intOldVchNo = @VchNo 
		
	update trs.tblPayHdr
	set VchDate=@VchDate	
	WHERE SerialNo=@SerialNo AND ProcessID=1 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear
	
	SELECT ProcessNo,FiscalYear,SerialNo, RowNo,DocDate,PayTypeID, DebitCode, CreditCode, Amount, ChequeNo, ChequeNoNew, ChequeDate,RowDesc
			,LocationID,BankTypeID,BranchCode,BranchName,AccOwnerName,AccountNo,NationalIDNumber
	FROM   trs.tblPayDtl
	where ProcessID=1 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and SerialNo=@SerialNo and RowNo=@RowNo

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
