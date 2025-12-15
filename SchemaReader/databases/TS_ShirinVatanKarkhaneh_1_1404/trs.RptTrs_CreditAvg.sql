USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1387/11/16
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : میانگین بدهکاری یک حساب
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_CreditAvg]
	@AcntCode	VarChar(20),
	@BaseDate	VarChar(10)
WITH ENCRYPTION
As
DECLARE	@ResultDays AS Int
BEGIN
	
	SET NOCOUNT ON;

	SELECT @ResultDays = Ceiling( Sum(T.DateDuration * T.Credit) / Sum(T.Credit) )
	FROM
	(
		SELECT	D.Credit, pub.funFarsiDateDiff('Day', D.DocDate, @BaseDate) AS DateDuration
		FROM	acc.tblVoucherDtl AS D
		WHERE	(D.Credit <> 0) AND (AcntCode = @AcntCode)
	) AS T

	IF (@ResultDays Is Null)
		SET @ResultDays = 0
		
	SELECT @ResultDays 

END
GO
