USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 92/08/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE Procedure [acc].[SpGetServiceDtlDiscount]
@CustomerAcntCode Varchar(20),
@ServiceCode Varchar(30),
@DocDate Varchar(10)

WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @DiscountPercent Float
	DECLARE @Discount Float

	SELECT @DiscountPercent=DiscountPercent,@Discount=DiscountAmount
	FROM trs.tblCustomerServiceDiscountDtl d INNER join trs.tblCustomerServiceDiscountHdr h
	ON d.SerialNo=h.SerialNo
	WHERE AcntCode=@CustomerAcntCode AND ServiceID=@ServiceCode AND FromDate <=@DocDate AND @DocDate <= h.ToDate
	ORDER BY h.SerialNo	DESC 

	IF @Discount IS NULL AND @DiscountPercent IS NULL
		SELECT @DiscountPercent=DiscountPercent,@Discount=DiscountAmount
		FROM trs.tblCustomerServiceDiscountDtl d INNER join trs.tblCustomerServiceDiscountHdr h
		ON d.SerialNo=h.SerialNo
		WHERE AcntCode=@CustomerAcntCode AND FromDate <=@DocDate AND @DocDate <= h.ToDate
		ORDER BY h.SerialNo	DESC 

	IF @Discount IS NULL AND @DiscountPercent IS NULL
		SELECT @DiscountPercent=DiscountPercent,@Discount=DiscountAmount
		FROM trs.tblCustomerServiceDiscountDtl d INNER join trs.tblCustomerServiceDiscountHdr h
		ON d.SerialNo=h.SerialNo
		WHERE ServiceID=@ServiceCode AND FromDate <=@DocDate AND @DocDate <= h.ToDate
		ORDER BY h.SerialNo	DESC 
		
	SELECT ISNULL(@DiscountPercent,0) DiscountPercent,ISNULL(@Discount,0) AS Discount
	
END













GO
