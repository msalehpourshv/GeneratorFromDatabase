USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ========= TS-QC: ==========================
-- Author        : Hadi Sadeghi
-- Description   : 
-- Create date   : 1388/10/21
-- Last Modified : 
-- Viewed By	 :
-- =============================================

CREATE PROCEDURE [prd].[spControlIsFinalStep]
(@ProduceStepID Varchar(20))
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @intCount INT
	DECLARE @RetValue tinyInt
	
	SET @RetValue = 1

	SELECT @intCount = COUNT(IsFinalStep)
	FROM pln.tblProduceOrderSteps
	WHERE IsFinalStep  = 1
	
	IF @intCount > 1
		UPDATE pln.tblProduceOrderSteps
		SET IsFinalStep = 0
		WHERE ProduceStepID <> @ProduceStepID	
	ELSE IF @intCount = 0
		UPDATE pln.tblProduceOrderSteps
		SET IsFinalStep = 1
		WHERE ProduceStepID = @ProduceStepID	
	ELSE 
		SET @RetValue = 0
	
	SELECT 	@RetValue AS Value
END
GO
