USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
create FUNCTION [cnt].[funGetPureWeight]
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
	DECLARE @PureWeight float

	Set @PureWeight = 0

	SELECT @PureWeight= d.PureWeight
		FROM cnt.tblSyncSaleBuyDtl d
		WHERE d.SerialNo=@SerialNo 
			AND d.ProcessID=@ProcessID	
			AND d.ProcessNo=@ProcessNo 
			AND d.FiscalYear=@FiscalYear
			AND d.Quality = @Quality
			
		
			if @PureWeight is  null
			begin
				set @PureWeight=0
			end
	
	return @PureWeight
	
END
GO
