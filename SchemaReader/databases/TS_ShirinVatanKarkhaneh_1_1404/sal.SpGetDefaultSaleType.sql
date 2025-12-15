USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sal].[SpGetDefaultSaleType] 
	@LanguageID	tinyint
WITH ENCRYPTION
AS 
Begin
	SELECT D.SaleTypeID,D.SaleTypeName 
	FROM  sal.tblSaleTypesDtl D
	INNER JOIN sal.tblSaleTypes H
	ON H.SaleTypeID=D.SaleTypeID AND LanguageID = @LanguageID AND IsDefault = 'True'
END	
GO
