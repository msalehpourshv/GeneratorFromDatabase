USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1401/10/27
-- Viewed By	 : 
-- Last ModIFied : 
-- Description   : 
-- =============================================
Create PROCEDURE acc.sp_api_AppService_GetAccountTurnover

@AcntCode As NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage as NVARCHAR(100)
	DECLARE @PartNumber  as int
	DECLARE @LenToAcnt   as int
	DECLARE @LenFromAcnt as int
	DECLARE @Layer1Lan	 as int




BEGIN TRY

	
	select @Layer1Lan=Layer1 from pub.tblCodeLayer   where TableName='acc.tblAcnt' and PartNumber=1

	SET  @PartNumber=  [acc].[FunGetAcntInfoForRemain] (1)
	SET  @LenFromAcnt= [acc].[FunGetAcntInfoForRemain] (2)
	SET  @LenToAcnt=   [acc].[FunGetAcntInfoForRemain] (3)

	select substring (d.AcntCode,@LenFromAcnt,@LenToAcnt) as AcntCode,AcntName,
	LastName ,FirstName,FirstName + ' '+LastName as FullName,
	NationalIdentity,NationalIDNumber,EconomicalCode,ZipCode,
	Debit,Credit,RecDesc,RecDesc2,d.DocDate,d.SerialNo,d.RowNo,IsAutoDoc,SourceFiscalYear,
	pub.funGetProcessName (d.SourceProcessID,d.SourceProcessNo,1) as ProcessName,d.CurrencyTypeID,* 
	from acc.tblVoucherDtl d
		
	left join acc.tblAcnt  a on a.AcntCode=substring (d.AcntCode,@LenFromAcnt,@LenToAcnt) and a.PartNumber=@PartNumber 
	and d.AcntCode in (
	SELECT	Distinct a.AcntCode	
		FROM	acc.tblVoucherDtl a
		INNER join acc.tblAcnt b	ON PartNumber= 1 and SUBSTRING(a.AcntCode,1,2) = SUBSTRING(b.AcntCode,1,2) AND LEN(b.AcntCode)=2
	WHERE AcntType NOT IN (91,92) AND VchKind <> 0
	)

	left join acc.tblAcntDtl ad on ad.AcntCode=substring (d.AcntCode,@LenFromAcnt,@LenToAcnt) and ad.PartNumber=@PartNumber

	where VchKind<> 0  and substring (d.AcntCode,@LenFromAcnt,@LenToAcnt)=@AcntCode


END TRY
BEGIN CATCH
	SET @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
