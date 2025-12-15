USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

create FUNCTION [cnt].[funSalePrice]
(
	@SerialNo as int,
    @ProcessID as int,
	@ProcessNo as int,
	@FiscalYear as int,
	@Quality  as int
)
RETURNS float
WITH ENCRYPTION
AS

BEGIN
	
	-- Declare the return variable here
	DECLARE @SalePrice float

	Set @SalePrice = 0

	SELECT @SalePrice= d.SalePrice
		FROM cnt.tblSyncSaleBuyDtl d
		WHERE d.SerialNo=@SerialNo 
			AND d.ProcessID=@ProcessID	
			AND d.ProcessNo=@ProcessNo 
			AND d.FiscalYear=@FiscalYear
			AND d.Quality = @Quality
			
		
			if @SalePrice is  null
			begin
				set @SalePrice=0
			end
	
	return @SalePrice
	
END
GO
