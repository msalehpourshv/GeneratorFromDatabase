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
Create PROCEDURE [inv].[SpInsertTaskGoodsToStoreHdr]
	@ProcessID		SmallInt,
	@ProcessNo		TinyInt,
	@FiscalYear		SmallInt,
	@SerialNo		Int,
	@DocDate		char(10),
	@SessionNo		bigint
	WITH ENCRYPTION
AS

BEGIN

	DELETE FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@ProcessID AND
		  ProcessNo=@ProcessNo AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo

	DELETE FROM inv.tblStorageDocsDtl
	WHERE ProcessID=@ProcessID AND
		  ProcessNo=@ProcessNo AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo

	DELETE FROM inv.tblStorageDocsAtom
	WHERE ProcessID=@ProcessID AND
		  ProcessNo=@ProcessNo AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo

	INSERT INTO inv.tblStorageDocsHdr
	      (ProcessID, ProcessNo,FiscalYear,SerialNo,DocDate,RecID,SessionNo )
	SELECT @ProcessID, @ProcessNo,@FiscalYear,@SerialNo,@DocDate,0 RecID,@SessionNo
	
END
GO
