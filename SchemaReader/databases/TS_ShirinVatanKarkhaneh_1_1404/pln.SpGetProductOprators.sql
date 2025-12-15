USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 94/04/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--EXEC [pln].[SpGetProductOprators] '111901 029076', '101100010000520'
CREATE PROCEDURE [pln].[SpGetProductOprators]

	@ProducerAcntCode VarChar(20),
	@ProductID		  VarChar(20)

WITH ENCRYPTION
AS

DECLARE	@Count	Int;

BEGIN

	SELECT @Count = Count(*) FROM pln.tblProductOpratorsDtl
	WHERE ProductID = @ProductID	
	
	Print @Count

	IF (@Count = 0)
		BEGIN
			SELECT OD.PersonnelID, P.FirstName + ' ' + P.LastName As PersonnelName   
			FROM pln.tblProductOpratorsDtl OD
			INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = OD.PersonnelID
			WHERE OD.ProducerAcntCode = @ProducerAcntCode -- AND ProductID = @ProductID
		END
		ELSE
		BEGIN
			SELECT OD.PersonnelID, P.FirstName + ' ' + P.LastName As PersonnelName   
			FROM pln.tblProductOpratorsDtl OD
			INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = OD.PersonnelID
			WHERE OD.ProducerAcntCode = @ProducerAcntCode AND ProductID = @ProductID	
		END
END
GO
