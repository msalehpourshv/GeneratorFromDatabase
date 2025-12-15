USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 97/05/27
-- Description:	
-- =============================================
CREATE PROCEDURE [prd].[spControlDecomposition] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int
 WITH ENCRYPTION
 AS

BEGIN
SET NOCOUNT ON;

	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	select F.ProductID,F.GoodsID GoodsID_F,D.GoodsID GoodsID_D ,ISNULL(ISNULL(F.GoodsQuantity,0)*H.ProductCount /FH.ProductCount,@QuantityDecimalsToForms) PQuantity,ISNULL(D.GoodsQuantity,@QuantityDecimalsToForms) GoodsQuantity
	from prd.tblFormulasDtl F
	inner join prd.tblFormulasHdr FH on F.ProductID=FH.ProductID and F.SerialNo=FH.SerialNo
	inner join (SELECT * from inv.tblStorageDocsHdr 
	            where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo
	           )H
	on F.ProductID=H.ProductID and F.SerialNo=H.FormulaNo
	FULL join  (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID,SUM(GoodsQuantity) GoodsQuantity
				from  inv.tblStorageDocsDtl 
				where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo
				group by ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID
				)D
	On H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo and F.GoodsID=D.GoodsID
	where ROUND(ISNULL(ISNULL(F.GoodsQuantity,0)*H.ProductCount /FH.ProductCount,0),@QuantityDecimalsToForms)<>ROUND(ISNULL(D.GoodsQuantity,0),@QuantityDecimalsToForms)

 END
GO
