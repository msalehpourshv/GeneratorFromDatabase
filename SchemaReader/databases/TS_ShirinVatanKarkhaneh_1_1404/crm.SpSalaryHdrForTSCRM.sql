USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use TS_DarbMotaghed_1_1402
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1399/03/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < گردش فیش حقوقی برای CRM  >
-- ==============================================
CREATE PROCEDURE crm.SpSalaryHdrForTSCRM
		@MonthCode		Int	, 
		@AcntCode		Varchar(20)
WITH ENCRYPTION
AS
BEGIN

	IF @AcntCode='' or  @AcntCode is null
			BEGIN								
				Raiserror ('کد حسابداری خالی است',16,1)
				Return
			END

	DECLARE @MyRepOptions VarChar(50)
	DECLARE @RepInfo VarChar(50)
	DECLARE @PersonnelID  Varchar(20)
	declare @From as int 
	declare @Len as int 
	set @From =[acc].[FunGetAcntInfoForRemain](2)
	set @Len =[acc].[FunGetAcntInfoForRemain](3)

	select @PersonnelID= D.PersonnelID 
	from prs.tblDecreeHdr D 
	inner join  prs.tblSalaryCalculation S
	on D.PersonnelID=S.PersonnelID and D.SerialNo=S.DecreeSerialNo
	and MonthCode=@MonthCode
	and substring(AcntSalary,@From,@Len) =@AcntCode

	IF @PersonnelID='' or  @PersonnelID is null
		BEGIN								
			Raiserror ('کد پرسنلی برای کد حسابداری ورودی پیدا نشد',16,1)
			Return
		END

	SET @MyRepOptions = '01110000001'
	SET @RepInfo = '1@201@200032@0@1@@'+@PersonnelID
	
	declare @ShowBill bit = 0
	select @ShowBill = CanSeeSalaryReceipt from prs.tblFunctionsHdr where MonthCode=@MonthCode

	if (@ShowBill=1)
	begin
		EXEC [prs].[RptPrs_SalaryBillsHdr] @MonthCode, NULL,  NULL, NULL, NULL,  NULL,  '', '', @MyRepOptions, @RepInfo	  	
	end
	else
	begin
		-- return 0 records
		EXEC [prs].[RptPrs_SalaryBillsHdr] 0, NULL,  NULL, NULL, NULL,  NULL,  '', '', @MyRepOptions, @RepInfo	  	
	end
	
END
GO
