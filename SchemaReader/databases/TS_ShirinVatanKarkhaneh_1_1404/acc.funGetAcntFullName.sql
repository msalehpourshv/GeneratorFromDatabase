USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: TakroSystem\ Ahmadnejad
-- Create date	: 1387-04-30 
-- Description	: Full Acnt Name
-- =============================================
Create FUNCTION [acc].[funGetAcntFullName]
(
	@AcntFullCode AS VarChar(20)
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS
BEGIN

	DECLARE @Name		AS NVarChar(500)
	DECLARE @FullName	AS NVarChar(500) 

	SET @FullName = ''

	DECLARE csr_names CURSOR FOR
		SELECT *
		FROM acc.GetAcntCodeNameAry(@AcntFullCode)
	
	OPEN	csr_names

	FETCH NEXT FROM csr_names INTO @Name

	WHILE (@@Fetch_Status = 0)
	BEGIN

		If ISNULL(@Name, '') <> ''
		BEGIN
			If @FullName <> '' 
				SET @FullName = @FullName + ' > '

			SET @FullName = @FullName + ISNULL(@Name, '')
		END

		FETCH NEXT FROM csr_names INTO @Name
	END

	CLOSE		csr_names
	DEALLOCATE	csr_names

	RETURN	@FullName
END


GO
