USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE Procedure [cac].[SpAccouningPortion]
	@Date CHAR(10)
	WITH ENCRYPTION
AS
BEGIN
	DECLARE @MAXDate CHAR(10)
	SELECT @MAXDate=ISNULL(MAX(ToDate),'') FROM cac.tblPortionCosts WHERE ToDate<@Date
	
	SELECT AcntCode,SUM(GoodsAmount+SalaryAmount+OverLoadAmount+OtherCostAmount) Amount 
	FROM cac.tblPortionAcntDtl PAD
	inner join cac.tblPortionHdr PH
	on PAD.SerialNo=PH.SerialNo AND PAD.FiscalYear=PH.FiscalYear
	WHERE (@MAXDate = '' OR DocDate>@MAXDate) and DocDate<=@Date
	group by AcntCode

END


GO
