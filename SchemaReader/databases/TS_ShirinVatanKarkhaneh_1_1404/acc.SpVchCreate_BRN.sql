USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 97/07/22
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
--exec [acc].[SpVchCreate_BRN] '1397/07/17',3,0
Create PROCEDURE [acc].[SpVchCreate_BRN]
	@strToDate			Char(10),
	@VoucherCreateMetod INT,
	@UserID				INT

WITH ENCRYPTION
AS

BEGIN 

Declare @BRN as varchar(20)
Declare @AcntCode as varchar(20)
DECLARE @DocDate CHAR(10)        
DECLARE @ProcessID   INT,     
		@ProcessNo  INT,
		@FiscalYear  INT,
		@SerialNo  INT
DECLARE @StrSourceCodeFieldValue nvarchar(500)

	Declare	curVch CURSOR For 
	SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,DocDate,BRN,AcntCode
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID in (90,100,50) AND BRN<>'' AND VchNo=0 AND
	      DocDate<=@strToDate 
	ORDER BY DocDate,BRN,ProcessID,AcntCode

	Open  curVch; 

	Fetch NEXT From curVch Into @ProcessID,@ProcessNo,@FiscalYear,@DocDate,@BRN,@AcntCode
	While (@@Fetch_Status = 0)
	BEGIN
		IF @AcntCode='' and @ProcessID=50
		BEGIN
			IF @AcntCode = ''
			BEGIN
				Close curVch;
				Deallocate curVch; 
				DECLARE @Msg nvarchar(max)=N'حساب سرمایه اول دوره در برگه های شعبه '+ @BRN + ' خالی است'
				Raiserror (@Msg,16,1)
				Return
			END	
		END
		--SET @StrSourceCodeFieldValue = LTRIM(RTRIM(STR(@ProcessID))) + '@' + LTRIM(RTRIM(STR(@FiscalYear)))+ '@' +@BRN+ '@'+@DocDate+ '@0'
		SET @StrSourceCodeFieldValue = LTRIM(RTRIM(STR(@ProcessID))) + '@' + LTRIM(RTRIM(STR(@FiscalYear)))+ '@' +@BRN+ '@'+@DocDate+ '@0'
		
		exec [acc].[SpVch_CreateDoc]
			0,				-- شماره سند
			0,			-- مرحله سند
			@DocDate,			-- تاریخ سند
			@DocDate,			-- تاریخ سند	
			@ProcessID,			-- 
			@ProcessNo,			--
			@FiscalYear,			--
			0,				--	
			'inv.tblStorageDocsHdr',		-- نام جدول هدر جدول اصلی
			'VchNo',		-- ''
			@VoucherCreateMetod,			-- سند تکی 1
			10,		-- اگر فقط سریال 1 در غیر اینصورت 2
			2,		-- نوع انتخابی سند توسط کاربر
			0,			    -- شماره سند قدیمی
			'BRN',				
			@BRN,		
			@UserID					 
		
		Fetch NEXT From curVch Into @ProcessID,@ProcessNo,@FiscalYear,@DocDate,@BRN,@AcntCode
	END

	Close curVch;
	Deallocate curVch; 
------------------------------------------خزانه داری-----------------------------------
	declare @NotRegisterVoucherForTrsIs_BRN as 	bit
	set @NotRegisterVoucherForTrsIs_BRN = 'False'

	SELECT @NotRegisterVoucherForTrsIs_BRN = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'NotRegisterVoucherForTrsIs_BRN'

	IF @NotRegisterVoucherForTrsIs_BRN = 'False'
	BEGIN
		declare  curPay cursor for   
		SELECT DISTINCT ProcessID,FiscalYear,DocDate,BRN
		FROM trs.tblPayHdr
		WHERE ProcessID in (1,2) AND BRN<>'' AND VchNo=0 AND
			  DocDate<=@strToDate 
		ORDER BY DocDate,BRN,ProcessID
		
		open curPay  
	  
		FETCH NEXT FROM curPay into @ProcessID,@FiscalYear,@DocDate,@BRN  
	  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
	  
			exec [acc].[SpVch_CreateDoc]   
				@intVchNo			= 0,  
				@intDocStep		    = 0,  
				@strVchDate			= @DocDate, 
				@strOldVchDate		= @DocDate,  
				@intSourceProcessID	= @ProcessID,  
				@intSourceProcessNo	= 1,  
				@intSourceFiscalYear= @FiscalYear,  
				@intSourceSerialNo	= 0,  
				@strHdrTblName		= 'trs.tblPayHdr',  
				@strVchNoFieldName	= 'VchNo',  
				@VoucherCreateMetod= @VoucherCreateMetod ,  
				@DocFormType        = 10 ,  
				@SelectedUserVchNoType = 2 , 
				@intOldVchNo = 0,			
				@StrSourceCodeFieldName = 'BRN',				
				@StrSourceCodeFieldValue = @BRN,		
				@UserID = @UserID					 
 	  
			FETCH NEXT FROM curPay into  @ProcessID,@FiscalYear,@DocDate,@BRN   
	  
		END   
	  
		close curPay  
		deallocate curPay 

		------------------------------------------وام دریافتنی-----------------------------------
		declare  curPay cursor for   
		SELECT DISTINCT ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,BRN
		FROM trs.tblLoanHdr
		WHERE ProcessID in (47,48) AND BRN<>'' AND VchNo=0 AND
			  DocDate<=@strToDate AND FirstPeriod='False'
		ORDER BY DocDate,BRN,ProcessID
		
		open curPay  
	  
		FETCH NEXT FROM curPay into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@DocDate,@BRN  
	  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
	  
			exec [acc].[SpVch_CreateDoc]   
				@intVchNo			= 0,  
				@intDocStep		    = 0,  
				@strVchDate			= @DocDate, 
				@strOldVchDate		= @DocDate,  
				@intSourceProcessID	= @ProcessID,  
				@intSourceProcessNo	= @ProcessNo,  
				@intSourceFiscalYear= @FiscalYear,  
				@intSourceSerialNo	= @SerialNo,  
				@strHdrTblName		= 'trs.tblLoanHdr',  
				@strVchNoFieldName	= 'VchNo',  
				@VoucherCreateMetod= @VoucherCreateMetod ,  
				@DocFormType        = 10 ,  
				@SelectedUserVchNoType = 1 , 
				@intOldVchNo = 0,			
				@StrSourceCodeFieldName = 'BRN',				
				@StrSourceCodeFieldValue = @BRN,		
				@UserID = @UserID					 
 	  
			FETCH NEXT FROM curPay into  @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@DocDate,@BRN   
	  
		END   
	  
		close curPay  
		deallocate curPay 
	END
END
GO
