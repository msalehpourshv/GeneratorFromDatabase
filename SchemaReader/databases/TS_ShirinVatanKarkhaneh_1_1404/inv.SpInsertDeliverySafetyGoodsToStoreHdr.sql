USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   :
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[SpInsertDeliverySafetyGoodsToStoreHdr]
	@FiscalYear		SmallInt,
	@SerialNo		Int,
	@DocDate		char(10),
	@StoreID		varchar(30),
	@SessionNo		bigint
	WITH ENCRYPTION
AS

BEGIN

	DELETE FROM inv.tblStorageDocsHdr
	WHERE ProcessID=110 AND
		  ProcessNo=9 AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo

	DELETE FROM inv.tblStorageDocsDtl
	WHERE ProcessID=110 AND
		  ProcessNo=9 AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo

	DELETE FROM inv.tblStorageDocsAtom
	WHERE ProcessID=110 AND
		  ProcessNo=9 AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo

	INSERT INTO inv.tblStorageDocsHdr
	      (ProcessID, ProcessNo,FiscalYear,SerialNo,DocDate,DocDate2,DocDate3,RecID,SessionNo,StoreID,DocStep )
	SELECT 110, 9,@FiscalYear,@SerialNo,@DocDate,@DocDate,@DocDate,0 RecID,@SessionNo,@StoreID,2
	
END
GO
