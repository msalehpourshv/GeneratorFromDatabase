USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [prs].[FunIsTaxPersonel]
(
	@PersonnelID VARCHAR(20),
	@DocDate	CHAR(10)
	
)
	RETURNS INT
	
WITH ENCRYPTION
AS

Begin -- ====================================================

	DECLARE @IsTaxPersonel AS INT
	
	SET @IsTaxPersonel=0

	
	if	(SELECT COUNT(*) FROM (SELECT TOP 1 *  FROM prs.tblDecreeHdr
				WHERE PersonnelID=@PersonnelID
				AND ExecutionDate<=@DocDate
		ORDER BY SerialNo DESC ) n)=0 
	BEGIN
		
		RETURN @IsTaxPersonel
			
	END
	
	
		
IF (SELECT TOP 1 TaxType FROM prs.tblDecreeHdr
		WHERE PersonnelID=@PersonnelID
		AND ExecutionDate<=@DocDate	
		ORDER BY SerialNo DESC)=2 OR 
   (SELECT top 1 TaxType FROM prs.tblDecreeHdr
		WHERE PersonnelID=@PersonnelID
		AND ExecutionDate<=@DocDate
		ORDER BY SerialNo DESC)=3
		
	BEGIN
			set @IsTaxPersonel=1
			
	END

	
RETURN @IsTaxPersonel
END -- ======================================================
GO
