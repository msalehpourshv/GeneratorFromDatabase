USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 99/08/12
-- Description:	Control Receipt 
-- =============================================
-- [inv].[spFrmStorageDocsLoadConfirmDoc] 90,1,93,252,'1393/07/28','101001','1',1
CREATE PROCEDURE [inv].[spControlStorageDocs]
	   @ProcessID		Smallint,
	   @ProcessNo		tinyint,
	   @FiscalYear		smallint,
	   @SerialNo		int
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

	
    SELECT 1 Resault,S.* into #T
    FROM inv.tblStorageDocsDtl S 
    INNER JOIN inv.tblGoods G 
    ON S.GoodsID=G.GoodsID AND 
        S.SubUnitID=G.UnitID AND 
        ROUND(GoodsQuantity,5)<>ROUND(SubUnitQuantity,5)
    where ProcessID = @ProcessID and 
          ProcessNo= @ProcessNo  and 
          FiscalYear= @FiscalYear  and 
          SerialNo= @SerialNo

	IF (select COUNT(*) from #T)>0
		select * from #T
	else
	BEGIN
		SELECT 2 Resault,StoreID into #S
		FROM inv.tblStorageDocsDtl S 
		where ProcessID = @ProcessID and 
			  ProcessNo= @ProcessNo  and 
			  FiscalYear= @FiscalYear  and 
			  SerialNo= @SerialNo          
		GROUP BY StoreID
		except
		select 2,StoreID
		from inv.tblStores
	    
		IF (select COUNT(*) from #S)>0
			SELECT * from #S
		ELSE
			select 0 Resault
	END	
    
    
END
GO
