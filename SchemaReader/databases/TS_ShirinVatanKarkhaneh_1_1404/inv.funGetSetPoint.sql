USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create Function [inv].[funGetSetPoint] 
(  
@StoreID	Varchar(20), 
@GoodsID Varchar(20)
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN

DECLARE @CMRGoodsStatusFilterStoreKind			bit;
	declare @setPoint  float;

SELECT @CMRGoodsStatusFilterStoreKind = SettingValue FROM pub.tblSettings WHERE SettingKey = 'CMRGoodsStatusFilterStoreKind'	
if @CMRGoodsStatusFilterStoreKind=0
begin

	set	@setPoint = 0.0;
	if (@StoreID is not null)
	begin 
     select TOP 1 @setPoint =SetPoint
	  from inv.tblGoodsStatusDtl
    	where (GoodsID = @GoodsID) 	and (StoreID = @StoreID)
	end
	if (@StoreID is null)
	begin 
     select @setPoint = SUM(SetPoint)
	  from inv.tblGoodsStatusDtl
    	where (GoodsID = @GoodsID) 
	end

end
else
begin

	set	@setPoint = 0.0;
	if (@StoreID is not null)
	begin 
     select TOP 1 @setPoint =SetPoint
	  from inv.tblGoodsStatusDtl a
	  inner join (SELECT StoreID from inv.tblStores WHERE InventoryType=0 and InventoryOwnership=0 ) b
	                     ON a.StoreID=b.StoreID
    	where (GoodsID = @GoodsID) 	and (a.StoreID = @StoreID)
	end
	if (@StoreID is null)
	begin 
     select @setPoint = SUM(SetPoint)
	  from inv.tblGoodsStatusDtl a
	    inner join (SELECT StoreID from inv.tblStores WHERE InventoryType=0 and InventoryOwnership=0 ) b
	                     ON a.StoreID=b.StoreID
    	where (GoodsID = @GoodsID) 
	end

end
	
	 return @setPoint 

END
GO
