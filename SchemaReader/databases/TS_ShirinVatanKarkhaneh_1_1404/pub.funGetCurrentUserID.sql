USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Javad Bayani
-- Create date: 2008/02/05
-- Description:	Get Current UserID Of Current Connection
-- =============================================
CREATE FUNCTION [pub].[funGetCurrentUserID] ()
RETURNS Int
WITH ENCRYPTION
AS
BEGIN
	-- Declare variables here
	DECLARE @UserID Int
	DECLARE @HostName VarChar(100)
	DECLARE @Pos int

	SELECT @HostName = host_name 
	From sys.dm_exec_sessions 
	Where session_id = @@SPID

	Set @Pos = CharIndex('$$',@HostName,1)

	IF @Pos = 0 Return 0

	SET @UserID = Convert(Int,SubString(@HostName ,@Pos + 2,CharIndex('$$',@HostName,@Pos + 2)-(@Pos + 2)))

	-- Return the result of the function
	RETURN @UserID

END






GO
