USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1398/02/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < انجام گروهی دستور کار>
-- ==============================================
CREATE PROCEDURE prd.SpChangeProductQuantity
	@GoodsID		NVarChar(20)= '32030701003000' ,
	@StoreID		NVarChar(20)= '0858' ,
	@FromDate		Char(10) = '1397/12/01',
	@ToDate			Char(10) = '1397/12/05',
	@TaskSerialNo	int=0
	
WITH ENCRYPTION
AS
BEGIN
	SELECT  ProductID,GoodsID,FormulaNo,ProductCount,pub.funGetGoodsName(ProductID,1) Name,
	SUM(ProducedCount)ProducedCount, SUM(GoodsQuantity) UsedGoodsQuantity,SUM(StandardQuantity) StandardQuantity
	FROM (  SELECT b.ProductID,a.GoodsID,b.FormulaNo,fh.ProductCount,a.GoodsQuantity,
				   ISNULL((
				   SELECT SUM(GoodsQuantity) 
				   FROM inv.tblStorageDocsDtl s
				   WHERE (
						  (s.ProcessID IN (80)AND a.ProcessID=s.BaseProcessID AND a.ProcessNo=s.BaseProcessNo and 
						   a.FiscalYear=s.BaseFiscalYear AND a.SerialNo=s.BaseSerialNo and b.ProductID=s.GoodsID AND @TaskSerialNo=0
						  ) OR 
						  (s.ProcessID IN (72,73) and s.BaseProcessID=610 and ( @TaskSerialNo =0 OR s.BaseSerialNo=@TaskSerialNo ) AND
						   a.BaseProcessID=s.BaseProcessID AND a.BaseProcessNo=s.BaseProcessNo and 
						   a.BaseFiscalYear=s.BaseFiscalYear AND a.BaseSerialNo=s.BaseSerialNo AND 
						   a.BaseDocRowNo=s.BaseDocRowNo and b.ProductID=s.GoodsID
						  ) 
						 )
				   ),0) ProducedCount,
				  fh.ProductCount  *  a.GoodsQuantity / fd.GoodsQuantity StandardQuantity
			FROM inv.tblStorageDocsDtl a
			INNER JOIN inv.tblStorageDocsHdr b
			ON a.ProcessID=b.ProcessID AND a.ProcessNo=b.ProcessNo AND 
			   a.FiscalYear=b.FiscalYear AND a.SerialNo=b.SerialNo
			INNER JOIN prd.tblFormulasHdr fh
			ON fh.ProductID=b.ProductID AND fh.SerialNo=b.FormulaNo
			INNER JOIN (SELECT fd1.GoodsID,fd1.ProductID,fd1.SerialNo,SUM(GoodsQuantity) GoodsQuantity  
						FROM prd.tblFormulasDtl fd1  
						WHERE fd1.GoodsID = @GoodsID 
						GROUP BY fd1.GoodsID,fd1.ProductID,fd1.SerialNo
						) fd
			ON fd.ProductID=b.ProductID AND fd.SerialNo=b.FormulaNo
			WHERE a.ProcessID IN (70,82,83) AND (@TaskSerialNo=0 OR (a.BaseProcessID=610 AND a.BaseSerialNo=@TaskSerialNo))
			AND a.GoodsID = @GoodsID AND a.StoreID=@StoreID AND
			a.DocDate BETWEEN @FromDate AND @ToDate
	) a
	GROUP BY ProductID,GoodsID,FormulaNo,ProductCount
END

GO
