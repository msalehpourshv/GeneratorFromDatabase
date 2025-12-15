USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create Function [inv].[funGetFitPoint] 
(  
@StoreID	Varchar(20), 
@GoodsID Varchar(20)
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN
	declare @fitPoint  float;
	set	@fitPoint = 0.0;
	if (@StoreID is not null)
	begin 
     select TOP 1 @fitPoint = FitPoint
	  from inv.tblGoodsStatusDtl
    	where (GoodsID = @GoodsID) 	and (StoreID = @StoreID)
	end
	if (@StoreID is null)
	begin 
     select @fitPoint = SUM(FitPoint)
	  from inv.tblGoodsStatusDtl
    	where (GoodsID = @GoodsID) 
	end
	 return @fitPoint 
	
END








GO
