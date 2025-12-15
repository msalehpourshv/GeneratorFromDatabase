USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1400/10/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : ورود سفارش خرید  از crm  رز
-- =============================================
Create PROCEDURE crm.sp_AutoOrderHdrForRozCRM
@ProcessNo as int,
@DocDate as CHAR(10),
@SettlementDate as CHAR(10),
@AcntCode AS VARCHAR(20),
@DocDesc as NVARCHAR(500),
@TransferSerialNo as NVARCHAR(100)
WITH ENCRYPTION
 AS

BEGIN
	DECLARE @maxSerialNo INT
	Declare @StrErrorMessage As Nvarchar(1024)
	 
	--DECLARE @AcntCustomerCode as Varchar(20)='3'
	--DECLARE @PartXLen	Int;
	--Declare @CustomerPartNo AS Tinyint
	DECLARE @TransportationIncomeAcntCode as varchar(20)
	DECLARE @TransportationCostAcntCode as varchar(20)
	 
BEGIN TRY

if (select count(*) from cmr.tblOrderHdr where TransferSerialNo=@TransferSerialNo)=0
begin	
	
	declare @FiscalYear				int;
	set @FiscalYear=RIGHT (DB_NAME(),4) 
	declare @PartNumber				int;
	declare @PartStart				int;
	declare @PartLen				int;
	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
	select @PartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @PartLen=[acc].[FunGetAcntInfoForRemain](3)

	declare @AcntCode1 AS VARCHAR(20)
	declare @AcntCode2 AS VARCHAR(20)
	declare @AcntCode3 AS VARCHAR(20)
	declare @AcntCode4 AS VARCHAR(20)


	IF @DocDate=''	
		raiserror (N'  تاریخ صحیح نمی باشد', 16, 1)
	IF @AcntCode=''	
		raiserror (N'کد مشتری صحیح نمی باشد', 16, 1)
	if @PartNumber>=1
	begin
		SET @AcntCode1			    = LTrim(pub.funSplitString(@AcntCode, ' ', 1)); 
		IF (SELECT COUNT(*) from acc.tblAcnt where AcntCode=@AcntCode1 and PartNumber=1)=0
		BEGIN
			Set @StrErrorMessage = N' کد حسابداری '+ @AcntCode1+' نامعتبر است'
			raiserror (@StrErrorMessage, 16, 1)
		END			
	end 
	if @PartNumber>=2
	begin
		SET @AcntCode2			    = LTrim(pub.funSplitString(@AcntCode, ' ', 2)); 	
		IF (SELECT COUNT(*) from acc.tblAcnt where AcntCode=@AcntCode2 and PartNumber=2)=0
		BEGIN
			Set @StrErrorMessage = N' کد حسابداری '+ @AcntCode2+' نامعتبر است'
			raiserror (@StrErrorMessage, 16, 1)
		END	
		
	end 
	if @PartNumber>=3
	begin
		SET @AcntCode3			    = LTrim(pub.funSplitString(@AcntCode, ' ', 3));
		IF (SELECT COUNT(*) from acc.tblAcnt where AcntCode=@AcntCode3 and PartNumber=3)=0
		BEGIN
			Set @StrErrorMessage = N' کد حسابداری '+ @AcntCode3+' نامعتبر است'
			raiserror (@StrErrorMessage, 16, 1)
		END	
		 
	end 
	if @PartNumber>=4
	begin
		SET @AcntCode4			    = LTrim(pub.funSplitString(@AcntCode, ' ', 4)); 
		IF (SELECT COUNT(*) from acc.tblAcnt where AcntCode=@AcntCode4 and PartNumber=4)=0
		BEGIN
			Set @StrErrorMessage = N' کد حسابداری '+ @AcntCode4+' نامعتبر است'
			raiserror (@StrErrorMessage, 16, 1)
		END	
	  		
	end 
	 
	--IF @SaleTypeID=''	
	--	raiserror (N'کد نوع فروش صحیح نمی باشد', 16, 1)
	IF @TransferSerialNo=0	
		raiserror (N'کد سریال مبدا صحیح نمی باشد', 16, 1)
	
	--------------------------------------------------------------------------------------------------------------
	declare @db_0000 as varchar(300)= Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	declare @UserID as int=0
	declare @SessionNo as int=0

	Select @UserID=SettingValue from pub.tblSettings where SettingKey ='UserExternalCRM'

	IF isnull(@UserID,0)<=0
	BEGIN
		Set @StrErrorMessage = N'  کد کاربر تعریف شده در تنظیمات برای Crm  نا معتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	Select cast(0 as int ) SessionID, cast(0 as int ) SessionNo into #tblSession
	DECLARE @StrSelect				NVarChar(4000);
	SET @StrSelect = '
		insert into  #tblSession
		 exec '+@db_0000+'.[pub].[SetSessionNo] ''SessionNo''	,''برای کاربر'' 	,     ''  CRM ''	,   '' ROZ ''	,'+str(@UserID)+''

	print @StrSelect
	EXEC sp_executesql @StrSelect;
	if (Select count(*) from   #tblSession )<=0
	BEGIN
		Set @StrErrorMessage = N' مشکل در اختصاص ایجاد SessionNo برای کاربر '
		raiserror (@StrErrorMessage, 16, 1)
	END	
	Select @SessionNo=SessionNo from   #tblSession
	--------------------------------------------------------------------------------------------------------------

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM cmr.tblOrderHdr
	WHERE ProcessID=160
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1
		INSERT INTO cmr.tblOrderHdr
	(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	AcntCode,DocDesc,TransferSerialNo,SettlementDate,SessionNo)
	
	SELECT 160,@ProcessNo,@FiscalYear,@maxSerialNo, 2, @DocDate, @AcntCode,@DocDesc,@TransferSerialNo,@SettlementDate,@SessionNo
   
	SELECT @maxSerialNo SerialNo,@AcntCode AcntCode,0 IsExist
End
else
	SELECT   SerialNo, AcntCode,1 IsExist from cmr.tblOrderHdr where TransferSerialNo=@TransferSerialNo

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
