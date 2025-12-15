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
Create FUNCTION [cmr].[FunGetBaseStorageDocsGoods]
(
	@AcntCode Varchar(20),
	@DocDate  char(10),
	@DocStep1 Tinyint,
	@DocStep2 Tinyint,
	@SerialNo int = NULL,
	@FiscalYear SmallInt = NULL
)
RETURNS TABLE 
WITH ENCRYPTION
AS

RETURN 
(
Select	Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
		Cnf.ConfirmQuantity  ,GoodsID,SubUnitID
		, [inv].[funGetGoodsQuantityFromSubUnit](GoodsID,SubUnitID,ConfirmQuantity) MainConfirmQuantity
From
	(
		Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,
		Sum(SubUnitQuantity - bb.cc) ConfirmQuantity,GoodsID,SubUnitID
		From (SELECT *,case when (SELECT SettingValue FROM pub.tblSettings
		      WHERE SettingKey = 'invcalcBuyRetInBuyReq' ) = 'True' then  ISNULL((Select	Sum(SubUnitQuantity) 
			            From inv.tblStorageDocsDtl a 
		WHERE a.BaseProcessID = b.ProcessID AND a.BaseProcessNo = b.ProcessNo AND 
				  a.BaseFiscalYear = b.FiscalYear AND a.BaseSerialNo = b.SerialNo AND 
				  a.BaseDocRowNo = b.DocRowNo),0) ELSE 0 END cc 
				  from inv.tblStorageDocsDtl b
	    Where ProcessID = 55 AND BaseProcessID > 0 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
			 (DocStep = 0 OR DocStep = @DocStep1 OR DocStep  = @DocStep2) AND (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
		) bb
		Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
				 BaseDocRowNo,GoodsID,SubUnitID
 	UNION
		Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,SubUnitQuantity AS ConfirmQuantity
		,GoodsID,SubUnitID
		From inv.tblStorageDocsDtl
		Where ProcessID = 55 AND BaseProcessID = 0 AND
			 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
			 (DocStep = 0 OR DocStep = @DocStep1 OR DocStep  = @DocStep2) AND (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
	) Cnf

WHERE Cnf.ConfirmQuantity > 0
)
GO
