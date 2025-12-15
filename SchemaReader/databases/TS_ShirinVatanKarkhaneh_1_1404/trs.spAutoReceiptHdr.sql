USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/02/222
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--[trs].[spAutoReceiptHdr] 1,1399,'1399/12/30','0001','21312'
CREATE PROCEDURE [trs].[spAutoReceiptHdr]
@ProcessNo		as tinyint,
@FiscalYear		as Smallint,
@DocDate		as CHAR(10),
@CustomerCode	as varchar(20),
@DescHdr		as NVARCHAR(600)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @CustomerPartNo AS Tinyint
Declare @maxSerialNo	AS int
Declare @PartXLen		 AS Tinyint
DECLARE @AcntStartCode as Varchar(10)='22 '
DECLARE @AcntCustomerCode as Varchar(10)='50'

BEGIN TRY

	SET @CustomerPartNo = 1
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	SELECT	@PartXLen = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = @CustomerPartNo)

	SELECT @CustomerCode = @AcntCustomerCode + pub.funPadLeft(@CustomerCode,'0',@PartXLen-LEN(@AcntCustomerCode))
		
	IF (SELECT COUNT(*) from acc.tblAcnt where PartNumber=@CustomerPartNo and AcntCode=@CustomerCode)=0
	BEGIN
		Set @StrErrorMessage = N' کد حسابداری نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END

SET @CustomerCode =  @AcntStartCode + ' ' +  @CustomerCode

	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM trs.tblPayHdr 
	WHERE ProcessID=1
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear
			 
	SET @maxSerialNo = @maxSerialNo +1
	
	INSERT INTO trs.tblPayHdr
		(ProcessID,ProcessNo,FiscalYear,SerialNo,CreditCode,DocDate,VchDate,DescHdr)
	values
		(1,@ProcessNo,@FiscalYear,@maxSerialNo,@CustomerCode,@DocDate,@DocDate,@DescHdr)	
		
	SELECT 	@maxSerialNo SerialNo,@CustomerCode CustomerCode
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
