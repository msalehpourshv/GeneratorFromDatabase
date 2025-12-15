USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funHasSubUser]
(
	@SupUserID AS INT,
	@SubUserID AS INT
)
RETURNS BIT
WITH ENCRYPTION            
AS
BEGIN
	DECLARE @Ret as bit;
	SET @Ret = 0
	
	SELECT @Ret = COUNT(*)
	FROM pub.tblTaskAssignRules 
	WHERE SupUserID = @SupUserID AND SubUserID = @SubUserID

	IF @Ret = 0
	BEGIN	
		SELECT @Ret = COUNT(*) 
		from pub.tblTaskAssignRules
		where  SupUserID = @SupUserID AND 
				SubUserID IN (
								SELECT  SupUserID
								FROM pub.tblTaskAssignRules 
								WHERE SubUserID = @SubUserID
							 )
			
		IF @Ret = 0
		BEGIN	
			SELECT @Ret = COUNT(*) 
			from pub.tblTaskAssignRules
			where  SupUserID = @SupUserID AND 
					SubUserID IN (  SELECT SupUserID
									from pub.tblTaskAssignRules
									where SubUserID IN (
														SELECT  SupUserID
														FROM pub.tblTaskAssignRules 
														WHERE SubUserID = @SubUserID
														)
								 )
			IF @Ret = 0
			BEGIN
				WITH UserRule(SupUserID, SubUserID) AS 
				(
					SELECT SupUserID, SubUserID
					FROM pub.tblTaskAssignRules 
					WHERE SupUserID =@SupUserID
					UNION ALL
					SELECT e.SupUserID, e.SubUserID
					FROM pub.tblTaskAssignRules AS e
					INNER JOIN UserRule AS d ON e.SupUserID = d.SubUserID
					WHERE d.SupUserID not in (e.SubUserID)
				)
				
				SELECT @Ret = COUNT(*) 
				FROM UserRule
				WHERE SubUserID = @SubUserID
			END	
											 
		END		
		
	END

	RETURN @Ret
	
END
GO
