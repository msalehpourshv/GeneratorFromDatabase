USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/01/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.sp_api_AsmanRasa_GetGoodsInfo
@OrderID        AS NVARCHAR(100),
@GoodsID		AS NVARCHAR(100)
WITH ENCRYPTION
 AS
BEGIN
	Declare @SCount	  as int
	Declare @RCount	  as int
	Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY

	   SELECT @GoodsID= GoodsID FROM inv.tblGoods
	   WHERE TechnicalNo=@GoodsID

		SELECT
		TOP 1 @RCount=count(*) 
		FROM inv.tblStorageDocsHdr h
		join inv.tblStorageDocsDtl d on  
		d.SerialNo=   h.SerialNo   and 
		d.ProcessID=  h.ProcessID  and
		d.ProcessNo=  h.ProcessNo  and
		d.FiscalYear= h.FiscalYear WHERE
		GoodsID=@GoodsID and 
		pub.funSplitString (TransferSerialNo,'_' ,1)=@OrderID and h.ProcessID=80


		SELECT 
		CASE 
		WHEN HasBatchNo=0  THEN 1 
		WHEN HasBatchNo<>0 THEN  1
		END AS SCount,
		CASE 
		WHEN HasBatchNo=0  THEN 1 
		WHEN HasBatchNo<>0 THEN  @RCount  
		END AS RCount,
		HasBatchNo,IsService,ExtraField3,ExtraField4, ExtraField5
		FROM inv.tblGoods WHERE GoodsID=@GoodsID
END TRY								 
BEGIN CATCH							 
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)
END CATCH

END	
GO
