USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/06/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create FUNCTION [inv].[FunGetRemainBatchGoods]
(
@StoreID	Varchar(20),
@DocDate	Char(10),
@ProductID	Varchar(20),
@BatchNo	Varchar(20),
@Qty		Float,
@FormulaNo	Int,
@ProdStepID Int,
@LanguageID Tinyint
)
RETURNS TABLE 
WITH ENCRYPTION
AS
RETURN 
(

Select	@FormulaNo FormulaNo, C1.GoodsID, C1.GoodsQuantity - ISNULL(C2.GoodsQuantity,0) AS Quantity,
        (C1.GoodsQuantity - ISNULL(C2.GoodsQuantity,0)) *  C1.SubUnitQuantity /C1.GoodsQuantity AS SubUnitQuantity,
		UnitID,case when @StoreID='' then DefaultStoreID else @StoreID end DefaultStoreID, C1.ProductCount,DocRowNo,DescDtl
From
	(
		SELECT B.GoodsID,GoodsQuantity*@Qty/A.ProductCount as GoodsQuantity ,SubUnitQuantity*@Qty/A.ProductCount as SubUnitQuantity,B.UnitID,A.ProductCount,B.DefaultStoreID,DocRowNo,DescDtl
		FROM prd.tblFormulasHdr A, prd.tblFormulasDtl B
		WHERE	A.ProductID=B.ProductID AND A.SerialNo=B.SerialNo AND 
				A.ProductID=@ProductID AND 
				((@FormulaNo> 0 AND A.SerialNo = @FormulaNo) OR ( @FormulaNo = 0 AND A.IsDefault=1)) AND
				(B.ParamKind=0 OR (B.ParamKind=1 and A.FmlParam1>0)) AND
				(@ProdStepID = 0 OR B.ProduceStepID = @ProdStepID )

	) C1
LEFT JOIN 
(
	Select	S1.GoodsID ,S1.GoodsQuantity - ISNULL(S2.GoodsQuantity,0) AS GoodsQuantity
	From
		(
			select D.GoodsID,Sum(GoodsQuantity) GoodsQuantity  
			from inv.tblStorageDocsHdr H,inv.tblStorageDocsDtl D
			Where	H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
					H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo AND 
					H.BatchNo = @BatchNo AND H.ProcessID = 70
			Group By D.GoodsID,H.BatchNo 
		) S1
	LEFT JOIN 
		(
			select D.GoodsID,Sum(GoodsQuantity) GoodsQuantity 
			from inv.tblStorageDocsHdr H,inv.tblStorageDocsDtl D
			Where	H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND 
					H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo AND 
					H.BatchNo = @BatchNo AND H.ProcessID = 80
			Group By D.GoodsID,H.BatchNo 
		) S2
	ON	S1.GoodsID = S2.GoodsID 
) C2
	ON	C1.GoodsID = C2.GoodsID 
WHERE C1.GoodsQuantity - ISNULL(C2.GoodsQuantity,0)  > 0

)
GO
