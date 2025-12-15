USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/10
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create  PROCEDURE cmr.sp_api_TakroSystem_GetCmrDtl

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
				SELECT c.RowNo,c.DocRowNo,DocDate,c.GoodsID,GoodsQuantity,DescDtl,  u.UnitName,Isnull(su.SubUnitID,'''') AS SubUnitID,gd.GoodsName,cast(ProcessNo as int ) as ProcessNo,cast(ProcessID as int) as ProcessID,cast(SerialNo as int )SerialNo,cast(FiscalYear as int )as FiscalYear,c.StoreID as StoreId,
					Cast (ISNULL(su.UnitValue,1)AS float )AS UnitValue,
					Cast (Isnull(su.MainUnitValue,1) AS float) AS MainUnitValue,
					Isnull(U.UnitName,'''') AS SubUnitName
				FROM cmr.tblCMRDtl c
					LEFT JOIN inv.tblGoodsDtl gd ON c.GoodsID=gd.GoodsID
					LEFT JOIN inv.tblSubUnitsDtl su ON c.GoodsID=su.GoodsID and su.ShowInInvoice=1
					LEFT JOIN inv.tblUnitsDtl u ON c.SubUnitID =u.UnitID 
					LEFT JOIN inv.tblUnitsDtl U ON su.SubUnitID=U.UnitID


				WHERE c.ProcessID ='+@ProcessID+' AND c.ProcessNo='+@ProcessNo+' AND c.SerialNo= '+@SerialNo+' AND c.FiscalYear='+@FiscalYear

	PRINT @strQuery
	EXEC sp_executesql @strQuery
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
