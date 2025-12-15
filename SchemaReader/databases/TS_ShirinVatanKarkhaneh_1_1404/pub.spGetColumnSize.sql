USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 90/10/10
-- Description:
-- ==============================================
CREATE PROCEDURE [pub].[spGetColumnSize] 
(@FormID	INT,
 @UserID	INT)
WITH ENCRYPTION
As 

	SELECT * FROM pub.tblColumnSize
	WHERE FormID=@FormID AND
		  UserID=@UserID	



























GO
