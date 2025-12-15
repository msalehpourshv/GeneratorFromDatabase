USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/02/22
-- Viewed By	 : 
-- Last Modified : 1401-01-14
-- Description   : Alian
-- =============================================
create PROCEDURE [trs].[sp_api_saymandigital_AutoAtm]
@ProcessID		as Int,
@ProcessNo		as Tinyint,
@FiscalYear		as Int,
@SerialNo		as Int,
@RowNo			as Int,
@CustomerCode	as VARCHAR(20),
@Type	as VARCHAR(20),
@Amount			as VARCHAR(20),
@Desc		as NVARCHAR(500)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @BankCode		As VARCHAR(20)
Declare @BankTypeID		As VARCHAR(20)
Declare @LocationID		As VARCHAR(20)
Declare @BranchCode		As VARCHAR(20)
Declare @BranchName		As NVARCHAR(100)
Declare @AccountOwnerName	As VARCHAR(100)
Declare @PayTypeId as tinyint=3
Declare @CustomerPartNo AS Tinyint
Declare @PartXLen		 AS Tinyint
DECLARE @AcntStartCode as Varchar(10)='11301'
DECLARE @AcntCustomerCode as Varchar(10)='3'

BEGIN TRY
if(@SerialNo>0)
begin
	
	If @BankCode='3100005'
	Begin
		set @PayTypeId=1
	End

	If SUBSTRING(@BankCode,1,2)='21'
	BEGIN
		set @ProcessNo=2
		set @AcntStartCode='11302'
	END

	--AcntCode//////////////////////////////////////////////////////////////////////////////////////////


	IF(@Type='C')
	BEGIN
		set @AcntStartCode='11303'
	END

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

	--//////////////////////////////////////////////////////////////////////////////////////////////
	SELECT @BranchName=BranchName,@AccountOwnerName=AccountOwnerName
	FROM trs.tblOurBanksDtl
	where BankCode=@BankCode

	INSERT INTO trs.tblPayAtm
		(ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,AtomRowNo,AtomAcntCode,DocAtomRowNo,AtomAmount,AtomDesc,VolumeFiscalYearAtm,VolumeRowNoAtm)
	values
		(@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,1,@RowNo,@CustomerCode,@RowNo,@Amount,@Desc,0,0)	

END	
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
