USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

create FUNCTION [cnt].[funBuyPrice]
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
	DECLARE @BuyPrice float

	Set @BuyPrice = 0

	SELECT @BuyPrice= d.BuyPrice
		FROM cnt.tblSyncSaleBuyDtl d
		WHERE d.SerialNo=@SerialNo 
			AND d.ProcessID=@ProcessID	
			AND d.ProcessNo=@ProcessNo 
			AND d.FiscalYear=@FiscalYear
			AND d.Quality = @Quality
			
		
			if @BuyPrice is  null
			begin
				set @BuyPrice=0
			end
	
	return @BuyPrice
	
END
GO
