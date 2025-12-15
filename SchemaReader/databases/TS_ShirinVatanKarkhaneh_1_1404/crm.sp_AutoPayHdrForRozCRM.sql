USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1402/07/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE crm.sp_AutoPayHdrForRozCRM
	@ProcessNo			as int,
	@FiscalYear			as int,
	@DocDate			as nvarchar(10),
	@DescHdr			as nvarchar(2000),
	@TransferSerialNo	as nvarchar(20),
	@ExtraParams		NVarChar(Max)
WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage	Nvarchar(1024)
DECLARE @Enter				SmallInt
DECLARE @MaxSerialNo		int
 
BEGIN TRY	
	
	if @TransferSerialNo<> 0  and (select count(*) from trs.tblPayHdr where ProcessID=1 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and TransferSerialNo=@TransferSerialNo)=0
	begin
	
		SELECT @MaxSerialNo = isnull(MAX(SerialNo), 0)
		FROM  trs.tblPayHdr 
		WHERE ProcessID=1
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear
			
		SET @MaxSerialNo = @MaxSerialNo + 1

		INSERT INTO   trs.tblPayHdr (ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, DescHdr,TransferSerialNo)
		SELECT 1, @ProcessNo, @FiscalYear, @MaxSerialNo, @DocDate, @DescHdr	,@TransferSerialNo
	end

	SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocDate, DescHdr
	FROM   trs.tblPayHdr 
	where ProcessID=1 AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear and TransferSerialNo=@TransferSerialNo 

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
 
GO
