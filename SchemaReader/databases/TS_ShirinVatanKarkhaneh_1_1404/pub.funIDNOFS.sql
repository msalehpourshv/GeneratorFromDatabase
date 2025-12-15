USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--create function IDNOFS()
--str([ProcessID],(3))+str([ProcessNo],(2)))+str([FiscalYear],(2)))+str([SerialNo],len([SerialNo])))

CREATE FUNCTION [pub].[funIDNOFS]
(	@ProcessID int,
	@ProcessNo int,
	@FiscalYear int,
	@SerialNo int
	)
RETURNS NVarChar(100)
WITH ENCRYPTION
AS
BEGIN

	DECLARE @strMessages AS NVarChar(100)
	set @strMessages = ltrim(str(@ProcessID))+'@'+ltrim(str(@ProcessNo))+'@'+	ltrim(str(@FiscalYear))	  +'@'+ 	ltrim(str(@SerialNo))

	RETURN @strMessages
END
GO
