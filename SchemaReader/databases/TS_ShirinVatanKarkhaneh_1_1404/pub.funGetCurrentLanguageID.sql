USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Javad Bayani
-- Create date: 2008/02/05
-- Description:	Get Current Language Of Current Connection
-- =============================================
CREATE FUNCTION [pub].[funGetCurrentLanguageID] ()
RETURNS Tinyint
WITH ENCRYPTION
AS
BEGIN
	-- Declare variables here
	DECLARE @LanguageID Tinyint
	DECLARE @HostName VarChar(100)
	DECLARE @Pos int

	SELECT @HostName = host_name 
	From sys.dm_exec_sessions 
	Where session_id = @@SPID

	Set @Pos = CharIndex('$$',@HostName,1)

	IF @Pos = 0 Return 1

	Set @Pos = CharIndex('$$',@HostName,@Pos + 2)

	SET @LanguageID = Convert(Tinyint,SubString(@HostName ,@Pos + 2,2))

	IF @LanguageID = 0 
		BEGIN
			SET @LanguageID = 1
		END

	-- Return the result of the function
	RETURN @LanguageID

END






GO
