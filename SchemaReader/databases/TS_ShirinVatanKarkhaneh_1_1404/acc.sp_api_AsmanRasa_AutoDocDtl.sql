USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alianpour
-- Create date   : 1400/11/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE  PROCEDURE [acc].[sp_api_AsmanRasa_AutoDocDtl]

@DocDate AS NVARCHAR(10),
@SerialNo AS NVARCHAR(50),
@AcntCode AS NVARCHAR(50),
@RecDesc AS NVARCHAR(200),
@Price AS Float, 
@SourceCodeFieldValue AS NVARCHAR(50),
@IsDepit AS INt
WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @Debit AS Nvarchar(50)=0
DECLARE @Credit AS Nvarchar(50)=0
DECLARE @RowNo  AS  Int

BEGIN TRY




if(select count(*) from acc.tblVoucherDtl where SourceCodeFieldValue=@SourceCodeFieldValue)=0
begin
if(@Price<0)
	set @Price=Abs(@Price)

if(SUBSTRING(@DocDate,1,4)>='1402')
begin
	IF(@IsDepit=1)
		BEGIN
		SET @Debit=@Price
		SET @Credit=0
		END
	ELSE
		BEGIN
		SET @Credit=@Price
		SET @Debit=0
		END

	SELECT @RowNo =ISNULL(MAX(RowNo),0) FROM acc.tblVoucherDtl
	WHERE SerialNo=@SerialNo

	SET @RowNo=@RowNo+1;

	INSERT INTO acc.tblVoucherDtl
		(SerialNo, RowNo,SourceProcessID,SourceProcessNo,SourceSerialNo,SourceFiscalYear,
		 DocDate,AcntCode,Debit,Credit,RecDesc,DocRowNo,SourceCodeFieldValue,RecDesc2,VchKind,IsAutoDoc)
	
	VALUES (@SerialNo,@RowNo,0,0,0,0 ,
			@DocDate,@AcntCode,@Debit,@Credit,@RecDesc,@RowNo,@SourceCodeFieldValue,'Api',1,1)
end
end
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
