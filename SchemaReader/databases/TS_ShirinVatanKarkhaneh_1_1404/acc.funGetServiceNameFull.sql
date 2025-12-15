USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[funGetServiceNameFull] 
(
	@ServiceID	VARChar(20) ,
	@LanguageID	TinyInt
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	
	RETURN [acc].[funGetServiceName] (@ServiceID,@LanguageID)

	-- Declare the return variable here
	DECLARE @ServiceName NVarChar(1000)
	DECLARE @ServiceName2 NVarChar(1000)
	DECLARE @ServiceName3 NVarChar(1000)
	DECLARE @ServiceName4 NVarChar(1000)

	Set @ServiceName = N'-'

	IF (SELECT LEN([pub].[funSplitString](@ServiceID,' ',1)))>0
		SELECT @ServiceName = ServiceName
		From  acc.tblServiceCodingDtl
		Where PartNumber =1 AND LanguageID = @LanguageID AND ServiceID = [pub].[funSplitString](@ServiceID,' ',1)
	 


	IF (SELECT LEN([pub].[funSplitString](@ServiceID,' ',2)))>0
	BEGIN
		SELECT @ServiceName2 =  ServiceName
		From  acc.tblServiceCodingDtl
		Where PartNumber =2 AND LanguageID = @LanguageID AND ServiceID = [pub].[funSplitString](@ServiceID,' ',2)
		
		set @ServiceName=@ServiceName+ ' - '  + @ServiceName2
	END
	
	IF (SELECT LEN([pub].[funSplitString](@ServiceID,' ',3)))>0
	
	BEGIN
		SELECT @ServiceName3 = ServiceName
		From  acc.tblServiceCodingDtl
		Where PartNumber =3 AND LanguageID = @LanguageID AND ServiceID = [pub].[funSplitString](@ServiceID,' ',3) 

	set @ServiceName=@ServiceName+ ' - '  + @ServiceName2 + ' - ' + @ServiceName3
	
	END
	
	IF (SELECT LEN([pub].[funSplitString](@ServiceID,' ',4)))>0
	BEGIN
		SELECT @ServiceName4 =  ServiceName
		From  acc.tblServiceCodingDtl
		Where PartNumber =4 AND LanguageID = @LanguageID AND ServiceID = [pub].[funSplitString](@ServiceID,' ',4) 
	set @ServiceName=@ServiceName+ ' - '  + @ServiceName2 + ' - ' + @ServiceName3 + ' - ' +@ServiceName4
	END
	
	-- Return the result of the function
	RETURN @ServiceName 

END
GO
