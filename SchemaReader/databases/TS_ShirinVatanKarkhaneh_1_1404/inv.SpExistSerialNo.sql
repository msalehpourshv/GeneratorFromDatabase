USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi Sadeghi
-- Creation date : 1392/08/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [inv].[SpExistSerialNo]
	@GoodsID	    VarChar(20),
	@BatchNo		VARCHAR(20),
	@ProductSerial	INT ,
	@PSerial		VARCHAR(20) ,
	@ExpireDate		VarChar(10), 
	@ProcessID		Int,
	@ProcessNo		Int,
	@FiscalYear		Int,
	@SerialNo		Int,
	@DocRowNo		Int	
WITH ENCRYPTION
AS 
Begin 

IF @ProductSerial = 0
BEGIN
	select top 1 @ProductSerial = ProductSerialID
	from pln.tblProductSerials
	where ProductID = @GoodsID and SerialNo=@PSerial
END

declare @Count int 
SET @Count = 0
SELECT @Count = SUM(EnterKind*Quantity) 
FROM ( 
	SELECT a.ProductSerialID,a.[ExpireDate],a.BatchNo,d.EnterKind,COUNT(*) Quantity 
	FROM inv.tblStorageDocsSerials a 
	Right join inv.tblStorageDocsDtl d 
	ON a.ProcessID=d.ProcessID and a.ProcessNo=d.ProcessNo and 
	   a.FiscalYear=d.FiscalYear and a.SerialNo=d.SerialNo and 
	   a.DocRowNo=d.DocRowNo 
	WHERE GoodsID = @GoodsID and a.BatchNo=@BatchNo and a.ExpireDate=@ExpireDate and a.ProductSerialID=@ProductSerial
		 AND NOT (a.ProcessID=@ProcessID and a.ProcessNo=@ProcessNo and a.FiscalYear=@FiscalYear and a.SerialNo=@SerialNo and a.DocRowNo=@DocRowNo)
	GROUP BY a.ProductSerialID,a.[ExpireDate],a.BatchNo,d.EnterKind) b 
group by ProductSerialID,[ExpireDate],BatchNo 

SELECT (@Count % 2) AS SerialCount

end
GO
