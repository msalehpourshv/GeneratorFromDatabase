USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Reza NOGREPASAND
-- Create Date   : 1392/04/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create   Function [cac].[funGetAcntRemain]
	(
		@AcntCode AS VARCHAR(20),
		@SerialNo AS INT,
		@FiscalYear AS INT,
		@Date		char(10)
	)
RETURNS FLOAT
WITH ENCRYPTION
AS
BEGIN
	DECLARE @MaxDate AS CHAR(10)
	DECLARE @Sum AS FLOAT

	SELECT @MaxDate = ISNULL(MAX(ToDate),'') FROM cac.tblPortionCosts
 
	SELECT @Sum=isnull(SUM(D.GoodsAmount+D.SalaryAmount+D.OverLoadAmount+D.OtherCostAmount),0)
	 FROM cac.tblPortionAcntDtl D
	INNER JOIN cac.tblPortionHdr H
	ON H.SerialNo = D.SerialNo AND H.FiscalYear = D.FiscalYear
	WHERE NOT(H.FiscalYear=@FiscalYear AND H.SerialNo=@SerialNo)
	AND  (@MaxDate = '' OR DocDate>@MaxDate) AND DocDate<=@Date  AND
	D.AcntCode=@AcntCode


	
RETURN @Sum 	
  
END


GO
