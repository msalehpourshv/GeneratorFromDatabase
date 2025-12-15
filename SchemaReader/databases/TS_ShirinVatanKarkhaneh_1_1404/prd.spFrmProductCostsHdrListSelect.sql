USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 90/02/12 'Happy B D
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================

CREATE PROCEDURE [prd].[spFrmProductCostsHdrListSelect] 
	@FiscalYear		Int,
	@SerialNo		Int,
	@DocStep		tinyint,
	@DocDate		Char(10),
	@AcntCode		varchar(20)
	
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

	SELECT H.ProductID,H.ProductCount,H.AcntCode,GoodsInProductionAcntCode
	FROM inv.tblStorageDocsHdr H INNER JOIN 
		(
			SELECT ProcessID,ProcessNo,FiscalYear,SerialNo 
			FROM [prd].[FunGetProduct] (@AcntCode,@DocDate,@DocStep,1)
			WHERE SerialNo = @SerialNo AND FiscalYear = @FiscalYear
			EXCEPT
			SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
			FROM [prd].[FunGetBaseProduct](@AcntCode,@DocDate,1,2,1)
			WHERE BaseSerialNo = @SerialNo AND BaseFiscalYear = @FiscalYear
		) D
	ON 	H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
	    H.FiscalYear=D.FiscalYear AND  H.SerialNo=D.SerialNo
	 INNER JOIN    inv.tblStores S
	 ON H.StoreID=S.StoreID
END	    
GO
