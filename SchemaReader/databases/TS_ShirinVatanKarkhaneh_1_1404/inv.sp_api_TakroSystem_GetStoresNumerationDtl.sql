USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/09/10
-- Viewed By	 : 
-- Last Modified :  
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_TakroSystem_GetStoresNumerationDtl

@SerialNo AS NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)
	
BEGIN TRY

	set @strQuery=' 
	SELECT 145 as ''ProcessID'',0 as ''ProcessNo'',
	   0 as ''FiscalYear'',d.SerialNo,d.RowNo,d.RowNo as ''DocRowNo'',
	   d.DocDate,d.GoodsID,gd.GoodsName,d.DescDtl,

	   g.UnitID,inv.funGetUnitName(g.UnitID,1) as ''UnitName'',d.GoodsQuantity,
	   Isnull(su.SubUnitID,'''') as ''UnitID2'',inv.funGetUnitName(su.SubUnitID,1) as ''UnitName2'',
	   Isnull(d.SubUnitID,'''') as ''SubUnitID'',inv.funGetUnitName(d.SubUnitID,1) as ''SubUnitName'',d.SubUnitQuantity,
	  	   	   
	   Cast(ISNULL(su.UnitValue,1) as float) as ''UnitValue'',Cast(Isnull(su.MainUnitValue,1) as float) as ''MainUnitValue'',
		
	   d.StoreID,pub.GetStoreName(d.StoreID,1) as ''StoreName'','''' as ''StoreID2'','''' as ''StoreName2''

	FROM [inv].[tblStoresNumerationDtl] d
	INNER JOIN inv.tblGoods g ON g.GoodsID=d.GoodsID 
	INNER JOIN inv.tblGoodsDtl gd ON d.GoodsID=gd.GoodsID
	LEFT JOIN inv.tblSubUnitsDtl su ON d.GoodsID=su.GoodsID and su.ShowInInvoice=1 

	WHERE d.SerialNo=' + @SerialNo 

	PRINT @strQuery
	EXEC sp_executesql @strQuery
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
