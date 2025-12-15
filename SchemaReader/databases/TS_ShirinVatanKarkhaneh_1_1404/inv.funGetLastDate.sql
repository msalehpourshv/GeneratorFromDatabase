USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1389/02/14
-- Viewed By	 : 
-- Last Modified : 1390/11/12
-- Last Modifier : 
-- Description   : آخرین قیمت یک پروسه
-- =================================================================
CREATE FUNCTION [inv].[funGetLastDate]
(
	@ProcessID	int = 55,
	@ProcessNo	int = 0,
	@EnterKind	int = 1,
	@GoodsID	Varchar(20),
	@StoreID	Varchar(20),
	@DateTo		Char(10)
)
RETURNS char(10)
WITH ENCRYPTION
AS
BEGIN

	declare @date  char(10);
	set	@date = '';

	select TOP 1 @date = DocDate
	from inv.tblStorageDocsDtl
	where (GoodsID = @GoodsID) 
			and (DocDate <= @DateTo) 
			and (GoodsPrice > 0) 
			and ((@ProcessID = 0) or (@ProcessID <> 0 and ProcessID = @ProcessID))
			and ((@ProcessNo = 0) or (@ProcessNo <> 0 and ProcessNo = @ProcessNo))
			and ((@EnterKind = 0) or (@EnterKind <> 0 and EnterKind = @EnterKind))
			and ((@StoreID is null) or ((@StoreID is not null) and (StoreID = @StoreID)))
	order by DocDate desc, VolumeRowNo desc

	return @date
END
GO
