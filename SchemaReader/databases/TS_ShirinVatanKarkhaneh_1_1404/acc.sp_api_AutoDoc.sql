USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alianpour
-- Create date   : 1401/01/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[sp_api_AutoDoc]

@DocDate AS NVARCHAR(10),
@SerialNo AS NVARCHAR(50),
@ProcessNo AS int,
@FiscalYear AS int,
@ProcessId AS int,
@DocStep as int=0,
@TableName AS NVARCHAR(50)



WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @MAxSerialNo AS INT
DECLARE @DocDate2 AS NVARCHAR(20)

BEGIN TRY
IF(@SerialNo<>0)
BEGIN

	
	IF(@ProcessId=90 or @ProcessId=100 or @ProcessId=55)
	BEGIN

		SELECT @DocDate2=DocDate FROM inv.tblStorageDocsHdr WHERE ProcessID=@ProcessId and ProcessNo=@ProcessNo and SerialNo=@SerialNo and FiscalYear=@FiscalYear
	END

	IF(@ProcessId=180 or @ProcessId=185 )
	BEGIN

		SELECT @DocDate2=DocDate FROM sal.tblSaleOrderHdr WHERE ProcessID=@ProcessId and ProcessNo=@ProcessNo and SerialNo=@SerialNo and FiscalYear=@FiscalYear
	END

	if(select left(@DocDate2,1))='2'
	begin
		set @DocDate2=pub.funChangeDate_GergorianToPersian(@DocDate2)
	end

	IF(@ProcessId=1 or @ProcessId=2)
	BEGIN

		SELECT @DocDate2=DocDate FROM trs.tblPayHdr WHERE ProcessID=@ProcessId and ProcessNo=@ProcessNo and SerialNo=@SerialNo and FiscalYear=@FiscalYear
	END


	IF(@ProcessId=240)
	BEGIN

		SELECT @DocDate2=DocDate FROM inv.tblPreSaleHdr WHERE ProcessID=@ProcessId and ProcessNo=@ProcessNo and SerialNo=@SerialNo and FiscalYear=@FiscalYear
	END

	if(@DocDate2='' AND @DocDate<>'')
		SET @DocDate2=@DocDate

	EXEC  acc.SpVch_CreateDoc 0,@DocStep,@DocDate2,@DocDate2,@ProcessId,@ProcessNo,@FiscalYear,@SerialNo,@TableName,'VchNo',2,5,1,0


end

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
