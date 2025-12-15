USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1404/06/12
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier : 
-- Description   :  تسهیم یک پروسه
-- =================================================================
Create FUNCTION inv.funGetOverLoadPrice
(
	@ProcessID	int = 55,
	@ProcessNo	int = 0,
	@EnterKind	int = 1,
	@GoodsID	Varchar(20),
	@StoreID	Varchar(20),
	@DateTo		Char(10)
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN

	declare @price  float;
	declare @Month int;
	set @DateTo=isnull(@DateTo,'9999/12/99')
	set @Month =Substring (@DateTo ,6,2)
	set	@price = 0.0;

	select TOP 1 @price =  
		case when @Month=1 then GoodsAmount1 
			 when @Month=2 then GoodsAmount2 
			 when @Month=3 then GoodsAmount3 
			 when @Month=4 then GoodsAmount4 
			 when @Month=5 then GoodsAmount5 
			 when @Month=6 then GoodsAmount6 
			 when @Month=7 then GoodsAmount7 
			 when @Month=8 then GoodsAmount8 
			 when @Month=9 then GoodsAmount9
			 when @Month=10 then GoodsAmount10 
			 when @Month=11 then GoodsAmount11 
			 when @Month=12 then GoodsAmount12  end 
	from inv.tblStorageDocsDtl
	where (GoodsID = @GoodsID) 
			and (DocDate <= @DateTo) 
			and (GoodsAmount > 0) 
			and ((@ProcessID = 0) or (@ProcessID <> 0 and ProcessID = @ProcessID))
			and ((@ProcessNo = 0) or (@ProcessNo <> 0 and ProcessNo = @ProcessNo))
			and ((@EnterKind = 0) or (@EnterKind <> 0 and EnterKind = @EnterKind))
			and ((@StoreID is null) or ((@StoreID is not null) and (StoreID = @StoreID)))
	order by DocDate desc, VolumeRowNo desc

	return @price
END
GO
