USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION [cmr].[FunGetOrderGoods]
(
	@AcntCode Varchar(20),
	@StoreID  Varchar(20),
	@DocDate  char(10),
	@DocStep1 Tinyint,
	@DocStep2 Tinyint
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(
select *, [inv].[funGetGoodsQuantityFromSubUnit](GoodsID,SubUnitID,ConfirmQuantity) MainConfirmQuantity from (
Select	Cnf.ProcessID, Cnf.ProcessNo, Cnf.FiscalYear, Cnf.SerialNo, Cnf.DocRowNo, Cnf.BaseProcessID, Cnf.BaseProcessNo, 
		Cnf.BaseFiscalYear, Cnf.BaseSerialNo, Cnf.BaseDocRowNo,
		Case When (SELECT SettingValue FROM pub.tblSettings WHERE SettingKey = 'BuyOrderOneStep') = 'False' Then 
			Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0)
		Else Cnf.GoodsQuantity - ISNULL(Rtn.ConfirmQuantity,0) End AS ConfirmQuantity 
		,GoodsID,SubUnitID, DocDate,AcntCode, AcntName, DescDtl DocDesc
From
	(
	
		Select	ProcessID , ProcessNo , FiscalYear , SerialNo, DocRowNo ,BaseProcessID , BaseProcessNo,
				BaseFiscalYear , BaseSerialNo , BaseDocRowNo,DocDate, ConfirmQuantity, GoodsQuantity
				,GoodsID,SubUnitID
				,AcntCode, pub.GetCodeName(AcntCode, 1) AS AcntName, DescDtl
		FROM 	cmr.tblOrderDtl
		Where ProcessID = 160 AND (@StoreID = '' OR StoreID='' OR StoreID = @StoreID) AND
			  (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
			  (DocStep = @DocStep1 OR DocStep = @DocStep2)
			
	) Cnf
LEFT JOIN 
(	Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
			Sum(ConfirmQuantity) ConfirmQuantity, Sum(GoodsQuantity) GoodsQuantity
	From cmr.tblOrderDtl 
	Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
			BaseDocRowNo
) Rtn
ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo 
AND Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo 
AND Cnf.DocRowNo = Rtn.BaseDocRowNo
WHERE Case When (SELECT SettingValue FROM pub.tblSettings 
				 WHERE SettingKey = 'BuyOrderOneStep') = 'False' Then Cnf.ConfirmQuantity 
	  Else Cnf.GoodsQuantity End - ISNULL(Rtn.ConfirmQuantity,0) > 0
) retTbl	  
	  
)
GO
