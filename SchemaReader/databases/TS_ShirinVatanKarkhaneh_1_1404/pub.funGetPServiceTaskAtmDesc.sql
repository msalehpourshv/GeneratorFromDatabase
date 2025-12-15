USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--select  pub.funGetPerformDesc(95,1,1)

Create FUNCTION [pub].[funGetPServiceTaskAtmDesc]
(
	@FiscalYear int,
	@SerialNo int,
	@DocRowNo int 
)
RETURNS NVarChar(max)
WITH ENCRYPTION
AS
BEGIN

	DECLARE @strMessages AS 	NVarChar(MAx);
	Declare @PerformDesc  AS 	NVarChar(MAx);
	
	Set @strMessages=' '
	
	DECLARE csr CURSOR FOR 
		Select PerformDesc from  srv.tblServiceTaskAtm2  a1 where a1.FiscalYear=@FiscalYear  and a1.SerialNo=@SerialNo and a1.DocRowNo=@DocRowNo 
	OPEN csr
	FETCH NEXT FROM csr INTO @PerformDesc

	WHILE @@Fetch_Status = 0
	BEGIN

		SET @strMessages = @strMessages + '  ' + @PerformDesc
		--Exec sp_executesql @StrTemp; 

		FETCH NEXT FROM csr INTO @PerformDesc
	END

	CLOSE csr
	DEALLOCATE csr

	
	
	
	RETURN @strMessages
END
GO
