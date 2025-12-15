USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 90/07/21
-- Description:	
-- =============================================
Create PROCEDURE [inv].[spGetUserIOAccess]
(
	@StoreID  VarChar(50),
	@UserID int,
	@EnterKind INT,
	@OutputStatus tinyint
)
WITH ENCRYPTION            
AS
BEGIN
	DECLARE @Return AS BIT	
	SET @Return = 'True'

	
	IF @EnterKind = 0
		begin
			select @Return
			return 
		end 
		 
	IF (SELECT COUNT(*) FROM inv.tblUsersIOAccessDtl WHERE StoreID=@StoreID )>0
		SET @Return = 'False'

	IF (SELECT COUNT(*) 
	    FROM inv.tblUsersIOAccessDtl 
	    WHERE StoreID=@StoreID AND UserID=@UserID) >0
	BEGIN
		IF @EnterKind = 1
			BEGIN
				SELECT TOP 1 @Return=Input 
				FROM inv.tblUsersIOAccessDtl 
				WHERE StoreID=@StoreID AND UserID=@UserID
			END
			
		ELSE IF @EnterKind = -1
			BEGIN
				IF @OutputStatus = 1
					SELECT TOP 1 @Return = [Output] 
					FROM inv.tblUsersIOAccessDtl 
					WHERE StoreID=@StoreID AND UserID=@UserID
					
				ELSE IF @OutputStatus = 2
					SELECT TOP 1 @Return = [Output_Numeric] 
					FROM inv.tblUsersIOAccessDtl 
					WHERE StoreID=@StoreID AND UserID=@UserID
					
				ELSE IF @OutputStatus = 3
					SELECT TOP 1 @Return = [Output] & [Output_Numeric] 
					FROM inv.tblUsersIOAccessDtl 
					WHERE StoreID=@StoreID AND UserID=@UserID
					
			END	
	END
	
	SELECT @Return
	
END
GO
