USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/02/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : آخرین قیمت یک یا چند پروسه
-- =================================================================
CREATE FUNCTION [inv].[funGetLastAmount]
(
	@ProcessID	int,
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

	if (@StoreID is null)
		select TOP 1 @price = GoodsAmount
		from inv.tblStorageDocsDtl
		where (GoodsID = @GoodsID) AND (DocDate <= @DateTo) AND (ProcessID = @ProcessID)
		order by DocDate desc, VolumeRowNo desc
	else
		select TOP 1 @price = GoodsAmount
		from inv.tblStorageDocsDtl
		where (GoodsID = @GoodsID) and (StoreID = @StoreID) and (DocDate <= @DateTo) AND (ProcessID = @ProcessID)
		order by DocDate desc, VolumeRowNo desc

	return @price
END
GO
