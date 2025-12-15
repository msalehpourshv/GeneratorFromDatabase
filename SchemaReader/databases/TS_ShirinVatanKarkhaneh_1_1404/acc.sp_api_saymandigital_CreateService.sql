USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/04/09
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[sp_api_saymandigital_CreateService]
@Desc2 As Nvarchar(Max),
@TransferSerialNo As Nvarchar(100),
@Tax As Float,
@Toll As Float,
@Price As Float,
@Amount As Float,
@Desc As Nvarchar(Max),
@DocDate As Nvarchar(10),
@AcntCode As Nvarchar(100)

WITH ENCRYPTION
 AS
BEGIN

	DECLARE @maxSerialNo INT
	DECLARE @PartXLen	Int;
	Declare @StrErrorMessage As Nvarchar(1024)
	DECLARE @AcntCustomerCode as Varchar(20)='3'
	Declare @CustomerPartNo AS Tinyint
	Declare @FiscalYear AS nvarchar(50)

BEGIN TRY

	IF(SELECT COUNT(*) FROM acc.tblServicesHdr WHERE TransferSerialNo=@TransferSerialNo)=0
	BEGIN
	

		IF (@AcntCode='')
		BEGIN
			Set @StrErrorMessage = N' کد مشتری را  در سفارش  '+@TransferSerialNo+' پر کنید'
			raiserror (@StrErrorMessage, 16, 1)
		END
	
 		SET @CustomerPartNo = 1
	
		SELECT @CustomerPartNo = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

		SELECT	@PartXLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @CustomerPartNo)
	

		IF (SELECT COUNT(*) from acc.tblAcnt where PartNumber=@CustomerPartNo and AcntCode=@AcntCode)=0
		BEGIN
			Set @StrErrorMessage = N'  کد حسابداری  '+@AcntCode+'درشماره سفارش '+@TransferSerialNo+'  نامعتبر است'
			raiserror (@StrErrorMessage, 16, 1)
		END

		SET @FiscalYear= SUBSTRING(@DocDate,1,4)

		SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
		FROM acc.tblServicesHdr
		WHERE ProcessID=49
		AND ProcessNo=1
		AND FiscalYear=@FiscalYear

		IF(@maxSerialNo=0)
			SET @maxSerialNo=1;
		
		SET @maxSerialNo=@maxSerialNo+1
		print @AcntCode
		
		insert into acc.tblServicesHdr
			 (SerialNo, DocDate, AcntCode, DescHdr, TaxOverWorthCost,ProcessID,
			  ProcessNo, FiscalYear, TollOverWorthCost,Amount, Price, VchNo,RecID, SessionNo,
			  OldSerialNo, VchDate, ExpertCode,CashAmount,ChequeAmount, DiscountPercent, VisitorAcntCode,VisitorPercent,
			  TaskTax, TaskTaxAcntCode, DocStep,BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseStep, TotalLineDiscount,TransferSerialNo)
		
		values(@maxSerialNo,@DocDate,'21103 '+@AcntCode,' عنوان: '+@Desc+' . توضیحات: '+@Desc2 ,@Tax,49,
				1,@FiscalYear,@Toll,@Amount,@Price,0,0,0,
				0,@DocDate,'',0,0,0,'',0,
				0,'',1,0,0,0,0,0,0,@TransferSerialNo)

		insert into acc.tblServicesDtl
			 (SerialNo, RowNo,  DescDtl,ProcessID, ProcessNo, FiscalYear,  DocStep, TaxOverWorthCostDtl, TollOverWorthCostDtl,
			  ServiceQuantity, ServiceAmount,SessionNo, DocRowNo,DiscountPercentDtl, DiscountDtl, DueDate,ServiceID)

		values
			(@maxSerialNo,1,@Desc2,49,1,@FiscalYear,1,@Tax,@Toll,
			 1,@Amount,1,1,0,0,'','10001')

		EXEC  acc.SpVch_CreateDoc 0,0,@DocDate,@DocDate,49,1,@FiscalYear,@maxSerialNo,'acc.tblServicesHdr','VchNo',2,5,1,0

	END

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ' خدمات:  ' +ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
