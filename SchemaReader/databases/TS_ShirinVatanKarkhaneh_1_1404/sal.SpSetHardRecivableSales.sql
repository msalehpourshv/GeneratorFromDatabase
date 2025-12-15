USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sal].[SpSetHardRecivableSales] 
	 @CurrentDate	Char(10),
	 @LanguageID    TinyInt = 1
WITH ENCRYPTION
AS

BEGIN

--	SET @LanguageID = pub.funGetCurrentLanguageID();

SET NOCOUNT ON;

	BEGIN

		Update inv.tblStorageDocsHdr Set HardRecivable = 'True'
		Where ProcessID IN (90, 91) AND IsConfirmed = 'False' And 
		     (SettlementDate <> '' And SettlementDate < @CurrentDate)

	END

END
GO
