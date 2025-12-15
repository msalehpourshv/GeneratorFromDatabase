USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [cmr].[funLastDescError]
(
	@DocDate varchar(20),
	@AcntCode varchar(20),	
	@GoodsID varchar(20)	
)
RETURNS NVarChar(max)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @strMessages AS NVarChar(max)

    SET @strMessages = N''

	SELECT TOP 1 @strMessages = N'' + CASE WHEN   (Recognition =4 or Recognition =2)    
	                                 THEN  N' برگه '+ ltrim(rtrim(str(SerialNo ))) + N' : ' +DescDtl 
								     ELSE  N' ' END  
	FROM inv.tblInvTempReceiptDtl
	WHERE AcntCode=AcntCode and 
	DocDate<=@DocDate
	and GoodsID=@GoodsID
	ORDER BY DocDate DESC
		
	RETURN @strMessages
END


GO
