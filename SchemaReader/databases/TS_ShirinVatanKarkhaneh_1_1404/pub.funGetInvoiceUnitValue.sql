USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [pub].[funGetInvoiceUnitValue]
(
	@GoodsID	Varchar(20),
	@UnitID		VARCHAR(20)
)
RETURNS VARCHAR(50)
WITH ENCRYPTION
AS

Begin -- === S T A R T ===========================================

	--IF (SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID = @GoodsID AND UnitID = @UnitID)=0
	--	RETURN '1$$1'
		
	Declare @Result AS VARCHAR(50)
	
	SELECT top 1 @Result = UnitValue
	FROM   (SELECT  GoodsID,convert(varchar(50),MainUnitValue)  + '$$' + convert(varchar(50),UnitValue) UnitValue
			FROM inv.tblSubUnitsDtl 
			WHERE ( GoodsID=@GoodsID OR GoodsID='') AND ShowInInvoice='True'
			
			) A
			order by GoodsID desc
 
	 IF @Result is null and (SELECT  count(*)FROM inv.tblSubUnitsDtl WHERE GoodsID=@GoodsID ) > 0
		set @Result = '-1$$0'
	
	Return ISNULL(@Result,'0$$0')
	--select @Result = @Result +  '$$'+ isnull(UnitID,'') from inv.tblGoods where GoodsID=@GoodsID
	
	--set @Result = @Result +  '$$'+ @UnitID
	--Return ISNULL(@Result,'0$$0$$$$')
End   -- === E N D ===============================================
GO
