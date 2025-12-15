USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 88/02/24
-- Viewed By	 : Hadi Sadeghi
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [prd].[SpGetProducersWageRate]
	@AcntCode				Varchar(20)
	WITH ENCRYPTION
AS

BEGIN

	SELECT WageRate FROM prd.tblProducers
	WHERE AcntCode=@AcntCode

END
GO
