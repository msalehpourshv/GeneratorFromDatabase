USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hadi Sadeghi
-- Creation date : 1393/06/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
CREATE FUNCTION [inv].[funGetSerialState]
(
	@StoreID			VarChar(20),
	@DocDate			Char(10),
	@ProductSerialID	int
)
RETURNS SMALLINT
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS SMALLINT

	SELECT  
	@Result = (SELECT COUNT(*) SCount  FROM inv.tblStorageDocsDtl d INNER JOIN inv.tblStorageDocsSerials s
	on d.ProcessID=s.ProcessID AND d.ProcessNo=s.ProcessNo AND
	d.FiscalYear=s.FiscalYear AND d.SerialNo=s.SerialNo AND d.DocRowNo=s.DocRowNo
	where d.StoreID = @StoreID and d.EnterKind = 1 AND DocDate <= @DocDate AND ProductSerialID = @ProductSerialID)
	- 
	(SELECT COUNT(*) SCount  FROM inv.tblStorageDocsDtl d INNER JOIN inv.tblStorageDocsSerials s
	on d.ProcessID=s.ProcessID AND d.ProcessNo=s.ProcessNo AND
	d.FiscalYear=s.FiscalYear AND d.SerialNo=s.SerialNo AND d.DocRowNo=s.DocRowNo
	where d.StoreID = @StoreID and d.EnterKind =-1 AND DocDate <= @DocDate AND ProductSerialID = @ProductSerialID) % 2 

	RETURN @Result
END
GO
