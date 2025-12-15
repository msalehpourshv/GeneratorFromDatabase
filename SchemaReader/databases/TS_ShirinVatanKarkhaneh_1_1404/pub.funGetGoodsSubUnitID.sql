USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create FUNCTION [pub].[funGetGoodsSubUnitID]
(
@GoodsID	VarChar(20)=NULL --'501000101100000014'--
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

declare @SubUnitID	VarChar(20)


		Select top 1 @SubUnitID=SubUnitID 		
		from  inv.tblSubUnitsDtl 
		Where      (GoodsID =@GoodsID OR (GoodsID='' and SubUnitID<>UnitID)) and ShowInInvoice=1
		order by GoodsID desc
		
	return isnull(@SubUnitID,'')
	
	
	
End   -- === E N D ===============================================



GO
