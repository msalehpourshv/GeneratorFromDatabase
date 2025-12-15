USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [prd].[funGoodsCountFormula] (
	@ProductID Varchar(20),
	@GoodsID Varchar(20),
	@FormulaSNo int
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN
declare @Ret as Float
set @Ret = 0

SELECT @Ret = SUM(GoodsQuantity)/ProductCount
FROM prd.tblFormulasDtl a
inner join  prd.tblFormulasHdr b 
on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
where a.ProductID= (SELECT TOP 1 b1.ProductID  FROM prd.tblFormulasDtl a1
					inner join  prd.tblFormulasHdr b1 
					on a1.ProductID=b1.ProductID and a1.SerialNo=b1.SerialNo
					where a1.ProductID= SUBSTRING(@ProductID,1,LEN(a1.ProductID ))  
					and a1.SerialNo = @FormulaSNo AND a1.GoodsID = @GoodsID 
					order by LEN(b1.ProductID) desc ) 
and a.SerialNo = @FormulaSNo AND GoodsID = @GoodsID 
group by ProductCount

IF @Ret = 0
		SELECT @Ret =  sum(d.GoodsQuantity/b.ProductCount)
		from  prd.tblFormulasDtl a
		inner join  prd.tblFormulasHdr b
		on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
		inner join prd.tblFormulasAtm d
		on d.ProductID=b.ProductID and d.SerialNo=b.SerialNo 
		AND d.GoodsID = @GoodsID  and a.DocRowNo=d.DocRowNo
		where a.ProductID=@ProductID and a.SerialNo = @FormulaSNo AND d.GoodsID = @GoodsID 
		
return @Ret
END
GO
