USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_TakroSystem_GetSaleOrderDtl]
@SerialNo as nvarchar(50),
@ProcessID as smallint,
@ProcessNo as tinyint,
@FiscalYear as nvarchar(50)


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
BEGIN TRY



	SELECT SerialNo,ProcessID,ProcessNo,FiscalYear,b.DocRowNo,b.RowNo,
		b.GoodsID,GoodsQuantity,b.GoodsPrice,b.SubUnitID,AcntCode,DescDtl,
		DocDate,VisitorAcntCode,b.SaleTypeID,StoreID,g.TechnicalNo as TechnicalNo,
		gd.GoodsName as GoodsName,g.UnitID,--,u.UnitName as SubUnitName,
		--Cast (Isnull(su.MainUnitValue,1) AS float) AS MainUnitValue,
		--Cast (ISNULL(su.UnitValue,1)AS float )AS UnitValue
		 u.UnitName,Isnull(su.SubUnitID,'') AS SubUnitID,
		 Cast (ISNULL(su.UnitValue,1)AS float )AS UnitValue,
		 Cast (Isnull(su.MainUnitValue,1) AS float) AS MainUnitValue,
		 Isnull(U.UnitName,'') AS SubUnitName

	FROM sal.tblSaleOrderDtl b

		LEFT JOIN inv.tblGoodsDtl gd on b.GoodsID=gd.GoodsID
		LEFT JOIN inv.tblGoods g on b.GoodsID=g.GoodsID
		LEFT JOIN inv.tblSubUnitsDtl su ON g.GoodsID=su.GoodsID and su.ShowInInvoice=1
		LEFT JOIN inv.tblUnitsDtl u ON g.UnitID =u.UnitID 
		LEFT JOIN inv.tblUnitsDtl U ON su.SubUnitID=U.UnitID

	WHERE ProcessID=180 AND SerialNo=@SerialNo AND
		  ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear AND 
		  u.LanguageID=1 AND  gd.LanguageID=1

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
