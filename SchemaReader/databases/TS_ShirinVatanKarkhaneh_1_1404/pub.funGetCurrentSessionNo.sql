USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Javad Bayani
-- Create date: 2008/02/05
-- Description:	Get Current SessionNo Of Current Connection
-- =============================================
CREATE FUNCTION [pub].[funGetCurrentSessionNo] ()
RETURNS Int
WITH ENCRYPTION
AS
BEGIN
	-- Declare variables here
	DECLARE @SessionNo Int
	DECLARE @HostName VarChar(100)
	DECLARE @Pos int

	SELECT @HostName = host_name 
	From sys.dm_exec_sessions 
	Where session_id = @@SPID

	Set @Pos = CharIndex('$$',@HostName,1)

	IF @Pos = 0 Return 0

	SET @SessionNo = Convert(Int,SubString(@HostName ,1,CharIndex('$$',@HostName,1)- 1))

	-- Return the result of the function
	RETURN @SessionNo

END







GO
