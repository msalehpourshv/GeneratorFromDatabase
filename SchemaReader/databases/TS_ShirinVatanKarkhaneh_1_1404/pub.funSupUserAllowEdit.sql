USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funSupUserAllowEdit]
(
	@SupUserID AS INT,
	@SubUserID AS INT
)
RETURNS BIT
WITH ENCRYPTION            
AS
BEGIN
	DECLARE @Ret AS BIT;
	SET @Ret = 'False';
	
	SELECT @Ret = AllowEdit
	FROM pub.tblTaskAssignRules 
	WHERE SupUserID = @SupUserID AND SubUserID = @SubUserID

	IF @Ret = 0
	BEGIN	
		SELECT @Ret = AllowEdit
		from pub.tblTaskAssignRules
		where  SupUserID = @SupUserID AND 
				SubUserID IN (
								SELECT  SupUserID
								FROM pub.tblTaskAssignRules 
								WHERE SubUserID = @SubUserID
							 )
			
		IF @Ret = 0
		BEGIN	
			SELECT @Ret = AllowEdit
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
				WITH UserRule(SupUserID, SubUserID, AllowEdit) AS 
				(
					SELECT SupUserID, SubUserID,AllowEdit
					FROM pub.tblTaskAssignRules 
					WHERE SupUserID =@SupUserID
					UNION ALL
					SELECT e.SupUserID, e.SubUserID, e.AllowEdit
					FROM pub.tblTaskAssignRules AS e
						INNER JOIN UserRule AS d
						ON e.SupUserID = d.SubUserID
				)
				SELECT Top 1 @Ret = AllowEdit 
				FROM UserRule
				WHERE SubUserID = @SubUserID
			END	
											 
		END		
		
	END

	RETURN @Ret

END
GO
