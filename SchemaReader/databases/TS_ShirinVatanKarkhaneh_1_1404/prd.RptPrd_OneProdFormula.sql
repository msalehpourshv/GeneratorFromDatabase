USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_OneProdFormula]
	@ProductID		varchar(20),
	@SerialNo		int,
	@ProductQty		float,
	@DocDate		char(10),
	@VolumeRowNo	int,
	@RepOptions		VarChar(10) = '',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 

DECLARE	@LangID	Char(1);

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	SET @LangID = 1

	-- SELECT Clause ----------------------------------------
	select D.GoodsID, D.GoodsQuantity*@ProductQty/H.ProductCount GoodsQuantity, 
			[pub].[funGetGoodsName](D.GoodsID, @LangID) As GoodsName, [pub].[funGetGoodsUnitName] (D.GoodsID, @LangID) As UnitName, 
			H.SerialNo, O.Wage1, O.Wage2, O.Wage3, O.Wage4, O.Wage5, O.Wage6, O.Wage7, O.Wage8, O.Wage9, O.Wage10, 
			isnull((
				select top 1 S.GoodsAmount
				from inv.tblStorageDocsDtl S
				where S.GoodsID=D.GoodsID 
					and S.GoodsAmount > 0
					and ((S.DocDate<@DocDate) or (S.DocDate=@DocDate and S.VolumeRowNo<@VolumeRowNo))
				order by S.DocDate desc, S.VolumeRowNo desc
			),0) GoodsAmount
	from prd.tblFormulasDtl D
		inner join prd.tblFormulasHdr H on H.ProductID=D.ProductID and H.SerialNo=D.SerialNo
		left  join prd.tblFormulasOverLoadHdr O on O.ProductID=H.ProductID and O.SerialNo=H.SerialNo
	where H.SerialNo=@SerialNo and H.ProductID=@ProductID And (O.OverLoadProduct=1 or (O.OverLoadProduct=0 and O.OverLoadDecomposition=0))
	order by D.GoodsID
	
End
GO
