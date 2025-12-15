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
CREATE PROCEDURE [pln].[RptPln_OneProdGoods]
	@ProcessID	int,
	@ProcessNo	int,
	@FiscalYear	int,
	@SerialNo	int,
	@DocRowNo	int,
	@RepOptions	VarChar(10) = '',  -- bit array options
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
declare	@BID	int
declare	@BNo	int
declare	@BFY	int
declare	@BSN	int
declare	@BRW	int
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- SELECT Clause ----------------------------------------
	select @BID = BaseProcessID, @BNo=BaseProcessNo, @BFY=BaseFiscalYear, @BSN=BaseSerialNo, @BRW=BaseDocRowNo
	from inv.tblStorageDocsDtl
	where ProcessID=@ProcessID and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo and DocRowNo=@DocRowNo
	
	select	D.GoodsID, D.GoodsQuantity, D.GoodsAmount, [pub].[funGetGoodsName](D.GoodsID,1)GoodsName, UD.UnitName,
			D.DocDate, D.VolumeRowNo, D.StoreID,
			ISNULL((SELECT Top 1 BatchNo from inv.tblStorageDocsSerials S 
			 WHERE S.ProcessID=D.ProcessID and S.ProcessNo=D.ProcessNo AND S.FiscalYear=D.FiscalYear and S.SerialNo=D.SerialNo and S.DocRowNo=D.DocRowNo),0) BatchNo
	from	inv.tblStorageDocsDtl D
				inner join inv.tblGoods    GH on GH.GoodsID= SUBSTRING(D.GoodsID,@str_Goods+1,@str_GoodsSum) AND GH.PartNumber=@UnitPart
				inner join inv.tblUnitsDtl UD on UD.UnitID=GH.UnitID
	where D.BaseProcessID=@BID and D.BaseProcessNo=@BNo and D.BaseFiscalYear=@BFY and D.BaseSerialNo=@BSN and D.BaseDocRowNo=@BRW and D.ProcessID in (82,83)
	order by D.DocRowNo 
	
End
GO
