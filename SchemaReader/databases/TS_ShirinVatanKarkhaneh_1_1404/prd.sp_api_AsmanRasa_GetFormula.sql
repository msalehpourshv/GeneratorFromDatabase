USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        :Elaheh AlianPour
-- Create date   : 1401/06/16
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE  PROCEDURE prd.sp_api_AsmanRasa_GetFormula

@TechnicalNo As Nvarchar(50),
@StateIds As varchar(50)
WITH ENCRYPTION
 AS
BEGIN

DECLARE @StrErrorMessage As Nvarchar(1024)
DECLARE @ProductId As varchar(100)
DECLARE @GoodsClassificationID As Nvarchar(100)

BEGIN TRY

	set @ProductId=''
	SELECT @ProductId=ISNULL(GoodsID,''),@GoodsClassificationID =GoodsClassificationID FROM inv.tblGoods 
	WHERE TechnicalNo=@TechnicalNo-- and ExtraField4 like '%/'+ ltrim(rtrim(str(@StateIds)))+'/%' 
	
	IF(@ProductId='')
	BEGIN
		begin
			Set @StrErrorMessage = N'کد فنی  '+@TechnicalNo+'  تعریف نشده است'
			raiserror (@StrErrorMessage, 16, 1)
		end
	END

	set @ProductId=''
	SELECT @ProductId=ISNULL(GoodsID,''),@GoodsClassificationID =GoodsClassificationID FROM inv.tblGoods 
	WHERE TechnicalNo=@TechnicalNo and ExtraField4 like '%/'+ ltrim(rtrim(str(@StateIds)))+'/%' 


	
	SELECT   H.ProductCount AS HdrGoodsQuantity,H.ProductCount , H.FormulaName AS DescDtl, DocDate , D.GoodsID , D.GoodsQuantity , D.SerialNo AS FormulaNo ,G2.UnitID,
		CASE 
		WHEN @GoodsClassificationID='' THEN 0
		WHEN @GoodsClassificationID<>'' THEN (SELECT  COUNT(*) FROM prd.tblFormulasHdr B WHERE D.GoodsID=B.ProductID)
		END AS CountGoods
		  
	FROM prd.tblFormulasDtl D
		   
		JOIN prd.tblFormulasHdr H
		ON H.SerialNo=D.SerialNo AND H.ProductID=D.ProductID
	JOIN inv.tblGoods G2
	ON G2.GoodsID=D.GoodsID
	WHERE D.ProductID=@ProductId AND H.IsDefault=1			

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
