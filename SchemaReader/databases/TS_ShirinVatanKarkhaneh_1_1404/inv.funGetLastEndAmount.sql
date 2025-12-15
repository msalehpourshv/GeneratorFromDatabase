USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi
-- Create date   : 1394/06/01
-- Viewed By	 : 
-- Last Modified : 1394/06/01
-- Last Modifier : 
-- Description   : آخرین قیمت یک پروسه
-- =================================================================
CREATE FUNCTION [inv].[funGetLastEndAmount]
(
	@GoodsID	Varchar(20),
	@StoreID	Varchar(20),
	@DateTo		Char(10)
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN

	declare @price  float;
	set	@price = 0.0;

	select TOP 1 @price = AmntRemain0/QtyRemain
	from inv.tblStorageDocsDtl
	where (GoodsID = @GoodsID) 
			and (DocDate <= @DateTo) 
			and (GoodsAmount > 0) 
			and (QtyRemain > 0) 
			and ((@StoreID is null) or ((@StoreID is not null) and (StoreID = @StoreID)))
			and FiscalYear=RIGHT(DB_NAME(),4)
	order by DocDate desc, VolumeRowNo desc

	return @price
END
GO
