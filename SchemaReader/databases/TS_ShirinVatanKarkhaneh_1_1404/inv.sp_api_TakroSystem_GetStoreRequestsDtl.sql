USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/10
-- Viewed By	 : 
-- Last Modified : mr.moayed 1403/05/31
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_TakroSystem_GetStoreRequestsDtl

@ProcessNo AS  NVARCHAR(50),
@ProcessID AS  NVARCHAR(50),
@SerialNo AS NVARCHAR(50), 
@FiscalYear AS  NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)
	
BEGIN TRY

	set @strQuery=' 
	SELECT cast(req.ProcessID as int) as ProcessID, cast(req.ProcessNo as int) as ProcessNo,
	   cast(req.FiscalYear as int) as FiscalYear,req.SerialNo,req.RowNo,req.DocRowNo,
	   req.DocDate,req.GoodsID,gd.GoodsName,req.DescDtl,

	   g.UnitID,inv.funGetUnitName(g.UnitID,1) as ''UnitName'',req.GoodsQuantity,
	   Isnull(su.SubUnitID,'''') as ''UnitID2'',inv.funGetUnitName(su.SubUnitID,1) as ''UnitName2'',
	   Isnull(req.SubUnitID,'''') as ''SubUnitID'',inv.funGetUnitName(req.SubUnitID,1) as ''SubUnitName'',req.SubUnitQuantity,
	  	   	   
	   Cast(ISNULL(su.UnitValue,1) as float) as ''UnitValue'',Cast(Isnull(su.MainUnitValue,1) as float) as ''MainUnitValue'',
		
	   req.StoreID,pub.GetStoreName(req.StoreID,1) as ''StoreName'',req.StoreID2,pub.GetStoreName(req.StoreID2,1) as ''StoreName2''

	FROM inv.tblStoresRequestsDtl req
	INNER JOIN inv.tblGoods g ON g.GoodsID=req.GoodsID 
	INNER JOIN inv.tblGoodsDtl gd ON req.GoodsID=gd.GoodsID
	LEFT JOIN inv.tblSubUnitsDtl su ON req.GoodsID=su.GoodsID and su.ShowInInvoice=1 

	WHERE req.ProcessID =' + @ProcessID + ' AND req.ProcessNo=' + @ProcessNo + ' AND req.SerialNo=' + @SerialNo + ' AND req.FiscalYear=' + @FiscalYear

	PRINT @strQuery
	EXEC sp_executesql @strQuery
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
