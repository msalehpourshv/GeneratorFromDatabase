USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/01/07
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE Procedure [sal].[SpGetDtlDiscount]
	@GoodsID Varchar(20),
	@DocDate Varchar(10),
	@AcntCode Varchar(30)

WITH ENCRYPTION
AS
BEGIN
	DECLARE @DiscountPercent Float
	DECLARE @Discount Float

	SELECT @DiscountPercent=DiscountPercent,@Discount=Discount 
	FROM sal.tblGroupsDiscountDtl D,sal.tblGroupsDiscountHdr H
	WHERE H.SerialNo=D.SerialNo AND H.AcntCode=D.AcntCode AND H.GroupType=2 AND 
		  D.GoodsGroupID = @GoodsID AND @AcntCode LIKE REplace(H.AcntCode,' ' ,'_') + '%' AND 
		  ( H.StartContractDate='' OR ( H.StartContractDate <> '' AND H.StartContractDate <= @DocDate)) AND 
		  ( H.EndContractDate='' OR ( H.EndContractDate <> '' AND H.EndContractDate >= @DocDate)) 

	IF @Discount is null and @DiscountPercent IS NULL
		SELECT @DiscountPercent=DiscountPercent,@Discount=Discount
		FROM sal.tblGroupsDiscountDtl D,sal.tblGroupsDiscountHdr H
		WHERE H.SerialNo=D.SerialNo AND H.AcntCode=D.AcntCode AND H.GroupType=1  AND 
			  @AcntCode LIKE REplace(H.AcntCode,' ' ,'_') + '%' AND 
              (H.StartContractDate='' OR (H.StartContractDate <> '' AND H.StartContractDate <= @DocDate)) AND 
			  (H.EndContractDate='' OR (H.EndContractDate <> '' AND H.EndContractDate >= @DocDate))  AND 
			  D.GoodsGroupID IN (SELECT GoodsGroupID 
							   FROM inv.tblGoodsGroupsGoodsListDtl 
							   WHERE GoodsID=@GoodsID)

	SELECT ISNULL(@DiscountPercent,0) DiscountPercent,ISNULL(@Discount,0) AS Discount
	
END
GO
