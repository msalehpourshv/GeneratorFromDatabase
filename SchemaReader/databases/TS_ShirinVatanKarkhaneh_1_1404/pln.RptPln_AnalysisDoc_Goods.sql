USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1388/11/03
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
CREATE PROCEDURE [pln].[RptPln_AnalysisDoc_Goods]
	@ProcessID		int,
	@ProcessNo		int,
	@FiscalYearFr	int,
	@SerialNoFr		int,
	@FiscalYearTo	int,
	@SerialNoTo		int,
	@RepInfo		varchar(10) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID		Int;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
Begin

--==============	
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


	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);


	SELECT	D.*, [pub].[funGetGoodsName](D.GoodsID,1) GoodsName, UD.UnitName
	FROM	pln.tblProduceAnalysisGoods D 
				INNER JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(D.GoodsID,@str_Goods+1,@str_GoodsSum) AND G.PartNumber=@UnitPart
				INNER JOIN inv.tblUnitsDtl UD ON UD.UnitID = G.UnitID 
	WHERE 	D.ProcessID = @ProcessID AND D.ProcessNo = @ProcessNo AND
			D.FiscalYear >= @FiscalYearFr AND D.SerialNo >= @SerialNoFr AND
			D.FiscalYear <= @FiscalYearTo AND D.SerialNo <= @SerialNoTo
End
GO
