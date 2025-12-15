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
CREATE PROCEDURE [inv].[spFrmStoresRequestsLoadConfirmDoc] 
	 @ProcessID		tinyint,
	 @ProcessNo		tinyint,
	 @FiscalYear	smallint,
	 @SerialNo		int,
	 @DocDate		Char(10),
	 @AcntCode		Nvarchar(20),
	 @LanguageID	Tinyint
WITH ENCRYPTION
 AS

BEGIN

SET NOCOUNT ON;
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart	
---------------------------------------------
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(Cd1.AcntCode) IsCodeClosed, Cd1.ProcessID, Cd1.ProcessNo, Cd1.FiscalYear, Cd1.SerialNo, Cd1.RowNo, Cd1.DocRowNo, Cd1.DocStep, 
		Cd1.DocDate, Cd1.AcntCode, Cd1.AcntCode2, Cd1.GoodsID, Cd1.SubUnitID, Cd1.SubUnitQuantity, StoreID ,
		Drv.GoodsQuantity, Cd1.DescDtl, Cd1.BaseProcessID,
		Cd1.BaseProcessNo, Cd1.BaseFiscalYear, Cd1.BaseSerialNo, Cd1.BaseDocRowNo, pub.funGetGoodsName(Cd1.GoodsID,@LanguageID) AS GoodsName, 
		[inv].[funGetTechnicalSpecifications](Cd1.GoodsID) AS TechnicalSpecifications,
		inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName
FROM	inv.tblStoresRequestsDtl AS Cd1 
	INNER JOIN
	(
		Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo , Cnf.DocRowNo 
				,Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0)- ISNULL(CmrOrder.ConfirmQuantity,0) AS GoodsQuantity ,DocDate,AcntCode
		From 
			(
				Select ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo , GoodsQuantity ,DocDate,AcntCode
				From inv.tblStoresRequestsDtl 
				Where ProcessID = 230 AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate <= @DocDate
			) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
						, BaseDocRowNo , SUM(GoodsQuantity) GoodsQuantity
				From inv.tblStoresRequestsDtl 
				Where BaseProcessID = 230 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				From [cmr].[FunGetBaseStorageDocsGoodsUse](@AcntCode,@DocDate) 
			) CmrOrder
			ON Cnf.ProcessID = CmrOrder.BaseProcessID AND  Cnf.ProcessNo = CmrOrder.BaseProcessNo AND 
			   Cnf.FiscalYear = CmrOrder.BaseFiscalYear AND Cnf.SerialNo = CmrOrder.BaseSerialNo AND 
			   Cnf.DocRowNo = CmrOrder.BaseDocRowNo AND Cnf.DocDate<=@DocDate 

	 )	Drv
	ON	Cd1.ProcessID = Drv.ProcessID AND  Cd1.ProcessNo = Drv.ProcessNo AND  
		Cd1.FiscalYear = Drv.FiscalYear AND  Cd1.SerialNo = Drv.SerialNo AND  
		Cd1.DocRowNo = Drv.DocRowNo 
	INNER JOIN
	(SELECT GoodsID FROM inv.tblGoods WHERE CodeClosed = 'False' AND PartNumber = @UnitPart   ) G
	ON SUBSTRING(Cd1.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID		
WHERE Drv.GoodsQuantity > 0  AND
		Cd1.DocDate<=@DocDate AND
		Cd1.SerialNo=@SerialNo AND Cd1.ProcessID=@ProcessID AND 
		Cd1.ProcessNo=@ProcessNo AND Cd1.FiscalYear=@FiscalYear AND 
		(@AcntCode IS NULL OR Cd1.AcntCode = @AcntCode) AND	Cd1.DocDate<=@DocDate 
) A WHERE IsCodeClosed = 0

END
GO
