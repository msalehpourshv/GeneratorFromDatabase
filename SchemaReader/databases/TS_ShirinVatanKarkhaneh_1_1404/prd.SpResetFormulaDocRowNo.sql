USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [prd].[SpResetFormulaDocRowNo]
	@ProductID	VarChar(20),
	@GoodsID	VarChar(20),
	@SerialNo	int	,
	@DocRowNo	int ,
	@Extras		NVarchar(2000) = null,
	@PartNo		tinyint = 1
WITH ENCRYPTION
AS
BEGIN
	DECLARE @strSelect NVARCHAR (4000)

	IF @Extras is null or @Extras = ''
	BEGIN
		DELETE FROM prd.tblFormulasAtm
		WHERE  ProductID = @ProductID AND
			   SerialNo = @SerialNo AND DocRowNo=@DocRowNo

		DELETE FROM prd.tblFormulasDtl 
		WHERE  ProductID = @ProductID AND
			   SerialNo = @SerialNo AND DocRowNo=@DocRowNo
	END
	ELSE
	BEGIN
		SET @strSelect = '
		DELETE FROM prd.tblFormulasAtm 
		Where ProductID in ( SELECT ProductID FROM prd.tblFormulasAtm A
		LEFT JOIN inv.tblGoods G on G.GoodsID = A.ProductID  and G.PartNumber = '+ LTrim(RTrim(str(@PartNo))) +'
		WHERE  A.ProductID = ''' + LTrim(RTrim(@ProductID)) + ''' AND
			   A.SerialNo = ' +  LTrim(RTrim(str(@SerialNo))) + ' AND A.DocRowNo = ' +  LTrim(RTrim(str(@DocRowNo))) + ' ' + @Extras + ')
		AND SerialNo in ( SELECT SerialNo FROM prd.tblFormulasAtm A
		LEFT JOIN inv.tblGoods G on G.GoodsID = A.ProductID  and G.PartNumber = '+ LTrim(RTrim(str(@PartNo))) +'
		WHERE  A.ProductID = ''' + LTrim(RTrim(@ProductID)) + ''' AND
			   A.SerialNo = ' +  LTrim(RTrim(str(@SerialNo))) + ' AND A.DocRowNo = ' +  LTrim(RTrim(str(@DocRowNo))) + ' ' + @Extras + ')
		AND DocRowNo in ( SELECT DocRowNo FROM prd.tblFormulasAtm A
		LEFT JOIN inv.tblGoods G on G.GoodsID = A.ProductID  and G.PartNumber = '+ LTrim(RTrim(str(@PartNo))) +'
		WHERE  A.ProductID = ''' + LTrim(RTrim(@ProductID)) + ''' AND
			   A.SerialNo = ' +  LTrim(RTrim(str(@SerialNo))) + ' AND A.DocRowNo = ' +  LTrim(RTrim(str(@DocRowNo))) + ' ' + @Extras + ')

		DELETE FROM prd.tblFormulasDtl 
		Where ProductID in ( SELECT ProductID FROM prd.tblFormulasDtl A
		LEFT JOIN inv.tblGoods G on G.GoodsID = A.ProductID  and G.PartNumber = '+ LTrim(RTrim(str(@PartNo))) +'
		WHERE  A.ProductID = ''' + LTrim(RTrim(@ProductID)) + ''' AND
			   A.SerialNo = ' +  LTrim(RTrim(str(@SerialNo))) + ' AND A.DocRowNo = ' +  LTrim(RTrim(str(@DocRowNo))) + ' ' + @Extras + ')
		AND  SerialNo in ( SELECT SerialNo FROM prd.tblFormulasDtl A
		LEFT JOIN inv.tblGoods G on G.GoodsID = A.ProductID  and G.PartNumber = '+ LTrim(RTrim(str(@PartNo))) +'
		WHERE  A.ProductID = ''' + LTrim(RTrim(@ProductID)) + ''' AND
			   A.SerialNo = ' +  LTrim(RTrim(str(@SerialNo))) + ' AND A.DocRowNo = ' +  LTrim(RTrim(str(@DocRowNo))) + ' ' + @Extras + ')
		AND  DocRowNo in ( SELECT DocRowNo FROM prd.tblFormulasDtl A
		LEFT JOIN inv.tblGoods G on G.GoodsID = A.ProductID  and G.PartNumber = '+ LTrim(RTrim(str(@PartNo))) +'
		WHERE  A.ProductID = ''' + LTrim(RTrim(@ProductID)) + ''' AND
			   A.SerialNo = ' +  LTrim(RTrim(str(@SerialNo))) + ' AND A.DocRowNo = ' +  LTrim(RTrim(str(@DocRowNo))) + ' ' + @Extras + ')'
	
		Print @strSelect;
		Exec sp_executesql @strSelect;
	END
		

		BEGIN TRY
			DROP TABLE #tblFormulas
		END TRY
		BEGIN CATCH
		END CATCH
		
		
	select * into  #tblFormulas FROM prd.tblFormulasDtl 
	WHERE	ProductID = @ProductID AND
			SerialNo = @SerialNo 
		
	UPDATE prd.tblFormulasDtl
	SET DocRowNo = ROW_N
	FROM prd.tblFormulasDtl, 
		(
			SELECT	RowNo, ROW_NUMBER() OVER(ORDER BY DocRowNo) As ROW_N
			FROM	prd.tblFormulasDtl
			WHERE	ProductID = @ProductID AND SerialNo = @SerialNo
		) T 
	WHERE	prd.tblFormulasDtl.ProductID = @ProductID AND
			prd.tblFormulasDtl.SerialNo = @SerialNo AND 
			prd.tblFormulasDtl.RowNo = T.RowNo
			
	update  prd.tblFormulasAtm
	Set DocRowNo=c.DocRowNo
	From prd.tblFormulasAtm a 
	inner join 	#tblFormulas b on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
	inner join 	 prd.tblFormulasDtl c on c.ProductID=b.ProductID and c.SerialNo=b.SerialNo and c.GoodsID=b.GoodsID
	
	
	
			
END
GO
