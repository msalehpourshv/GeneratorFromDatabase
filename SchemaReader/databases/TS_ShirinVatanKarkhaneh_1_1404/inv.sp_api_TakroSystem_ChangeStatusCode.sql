USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
cREATE PROCEDURE inv.sp_api_TakroSystem_ChangeStatusCode
@ProcessId			as int,
@ProcessNo			as int,
@SerialNo			as int,
@FiscalYear			as int,
@ReferenceNumber	as nvarchar(50),
@TaxID				as nvarchar(50),
@Status				as int,
@TPEdited			as int,
@TaxSerialNo		as nvarchar(50),
@DocTime			as nvarchar(50),
@BaseTaxID			as nvarchar(50),
@IsCanceled		    as int,
@NationalNumber     as nvarchar(20)	,
@EconomicalCode	    as nvarchar(20)	,
@ZipCode		    as nvarchar(20),
@Comment			as Nvarchar(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @SendTaxToll AS INT
BEGIN TRY
	
	UPDATE inv.tblStorageDocsHdr 
	SET SendTaxTollState=@Status,TaxSerialNo=@TaxSerialNo,TPComment=@Comment
	WHERE SerialNo=@SerialNo AND ProcessID=@ProcessId AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear 
	-----------------------------------------------------------------------------------------------------------
	IF(@Status=2 )
	BEGIN
		UPDATE inv.tblStorageDocsHdr 
		SET TaxID2=@TaxID+'$'+@BaseTaxID+'$'+CASE WHEN @DocTime='' THEN DocTime ELSE @DocTime END+'$',
		ReferenceID=CASE WHEN @ReferenceNumber='' THEN ReferenceID ELSE @ReferenceNumber END
		WHERE SerialNo=@SerialNo AND ProcessID=@ProcessId AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear
	END
	---------------------------------------------------------------------------------------------------------------
	ELSE IF(@Status=3)
	BEGIN
		UPDATE inv.tblStorageDocsHdr 
		SET SendTaxToll=0,
		TaxID=case when @Comment='' then  pub.funSplitString(TaxID2,'$',1)
		when @Comment<>'' then @TaxID end,
		BaseTaxID=case when @Comment='' then pub.funSplitString(TaxID2,'$',2)
		when @Comment<>'' then @BaseTaxID end,
		DocTime=pub.funSplitString(TaxID2,'$',3),
		ReferenceID=CASE WHEN @ReferenceNumber='' THEN ReferenceID ELSE @ReferenceNumber END,TaxID2='',
		TPCanceled=@IsCanceled,
		TPPriceBeforDiscount=CASE WHEN TPPriceBeforDiscount=0 THEN Price ELSE TPPriceBeforDiscount END,
		TPPriceAfterDiscount=CASE WHEN TPPriceAfterDiscount=0 THEN (Amount-TaxOverWorthCost) ELSE TPPriceAfterDiscount END ,
		ZipCode=@ZipCode,NationalIDNumber=@NationalNumber,EconomicalCode=@EconomicalCode
		WHERE SerialNo=@SerialNo AND ProcessID=@ProcessId AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear
	END
	-------------------------------3----------------------------------------------------------------------------------
	--ELSE IF(@Status=4 OR @Status=5)
	--BEGIN
	--	UPDATE inv.tblStorageDocsHdr 
	--	SET TaxID2=''
	--	WHERE SerialNo=@SerialNo AND ProcessID=@ProcessId AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear
	--END
	-------------------------------------------------------------------------------------------------------------------

END TRY

BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
