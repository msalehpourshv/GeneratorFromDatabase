USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [inv].[SpSetPrintCount]
	@ProcessID int=90
	,@ProcessNo  int=1
	,@FiscalYear  int=93
	,@SerialNo  int=5

WITH ENCRYPTION
AS
BEGIN
	DECLARE @PrintCount varchar(10)
	
	SET @PrintCount = '0'
	
	select @PrintCount =C6
	FROM inv.tblStorageDocsHdr 
	where ProcessID=@ProcessID and 	
		  ProcessNo  =@ProcessNo and 	
		  FiscalYear =@FiscalYear and 	
		  SerialNo  =@SerialNo  

	IF 	@PrintCount = ''  OR @PrintCount = '0'  
		SET @PrintCount = 1
	ELSE
		SET @PrintCount = @PrintCount + 1

	UPDATE 	inv.tblStorageDocsHdr
	SET C6 = @PrintCount
	where ProcessID=@ProcessID and 	
		  ProcessNo  =@ProcessNo and 	
		  FiscalYear =@FiscalYear and 	
		  SerialNo  =@SerialNo  
		  
	SELECT  @PrintCount
	
END
GO
