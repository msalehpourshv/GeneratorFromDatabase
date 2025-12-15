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
Create PROCEDURE [inv].[spFrmStoresRequestsHdrListSelect] 
	@DocDate		Char(10),
	@ProcessID		Smallint,
	@AcntCode		varchar(20)
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed, Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo --, Cnf.DocRowNo 
		,DocDate
From 
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

	 )Cnf
WHERE	Cnf.GoodsQuantity > 0  AND 
		DocDate<=@DocDate 
) A WHERE IsCodeClosed = 0
		
END


GO
