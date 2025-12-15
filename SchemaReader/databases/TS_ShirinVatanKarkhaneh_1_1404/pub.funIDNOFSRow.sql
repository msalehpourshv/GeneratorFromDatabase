USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [pub].[funIDNOFSRow]
(	@ProcessID int,
	@ProcessNo int,
	@FiscalYear int,
	@SerialNo int,
	@DocRowNo int
	)
RETURNS NVarChar(100)
WITH ENCRYPTION
AS
BEGIN

	DECLARE @strMessages AS NVarChar(100)
    set @strMessages = ltrim(str(@ProcessID))+'@'+ltrim(str(@ProcessNo))+'@'+	ltrim(str(@FiscalYear))	  +'@'+ 	ltrim(str(@SerialNo))	+'@'+	ltrim(str(@DocRowNo))

	RETURN @strMessages
END
GO
