USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : 
-- =============================================

Create  PROCEDURE sal.SPSaleOrderParamAtom
	 	WITH ENCRYPTION
AS
BEGIN


select * from (
select *
,ISNULL( Case When ParamState=1 then (Select GoodsName From inv.tblGoodsDtl where GoodsID = ParamValue  )
When ParamState=2 then (Select CustomGoodsParamName From inv.tblCustomGoodsParamDtl where CustomGoodsParamID = ParamValue  )
When ParamState=3 then TextParam
When ParamState=4 then CAST( NumericParam as Varchar(10))
else ''
end , '') ParamValueName
 from sal.tblSaleOrderParamAtom
) a
where  ParamValueName<>''
 
 
 
END
GO
