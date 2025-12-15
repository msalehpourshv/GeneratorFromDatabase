USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1402/09/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create Function prd.funGetMinGoodsFormulasInfo
(  
@GoodsID Varchar(20),
@SerialNo Varchar(20)
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN
	
	declare @GoodsQuantity  float;
 
 ----  براِی مشاهده گردش از تابع 
 ---- prd.SP_GetMinGoodsFormulasInfo @GoodsID,@SerialNo
 ---- استفاده شود 


		select @GoodsQuantity=ISNULL(Min(
			
			ISNULL((prd.funGetMinGoodsFormulasInfo(D.GoodsID,@SerialNo)*ProductCount/ GoodsQuantity ),0)
		),0)
		from	prd.tblFormulasDtl D 
		INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID
		where  (D.ProductID =@GoodsID)  AND (D.SerialNo = @SerialNo  or ( @SerialNo = 0 and H.IsDefault = 1)  )
		and BaseGoods=1 

	set @GoodsQuantity=ISNULL(@GoodsQuantity,0)

	set @GoodsQuantity	+=	ISNULL(prd.funGetGoodsFormulasInfo(2 ,@GoodsID,'','') ,0)+ISNULL(	prd.funGetGoodsFormulasInfo(1 ,@GoodsID,'','') ,0)

	return isnull(@GoodsQuantity,0) 
	  
END
GO
