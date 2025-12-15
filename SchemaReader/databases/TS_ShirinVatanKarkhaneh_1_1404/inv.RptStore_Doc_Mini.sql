USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/06/30
-- Viewed By	 : 
-- Last Modified : 1392/06/30
-- Last Modifier : TakroSystem\Zia
-- Description	 : �ѐ �����
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Doc_Mini]
	@ProcessID	Int,
	@ProcessNo	Int,
	@FiscalYear	Int,
	@SerialNo	Int,
	@RepOptions	varchar(20) = '1000'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @UseCurrency	bit;
Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- Init ------------------------------------------
	IF (@ProcessNo Is Null)	SET @ProcessNo = 1;
	IF (@RepOptions Is Null)SET @RepOptions = '1000';
	
	SET @UseCurrency = Substring(@RepOptions, 1, 1);
	--------------------------------------------------

	-- SELECT Clause ----------------------------------------
	if (@UseCurrency=1)
		set @StrFrom = 'inv.vwStorageDtl_Currency'
	else
		set @StrFrom = 'inv.tblStorageDocsDtl'
	
	set @StrSelect = '
		SELECT	D.GoodsID, D.GoodsQuantity, D.GoodsAmount, D.GoodsPrice, GD.GoodsName
		FROM	' + @StrFrom + ' D 
					LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = D.GoodsID 
		WHERE 	D.ProcessID = ' + str(@ProcessID) + '
			AND D.ProcessNo = ' + str(@ProcessNo) + '
			AND	D.FiscalYear = ' + str(@FiscalYear) + '
			AND D.SerialNo = ' + str(@SerialNo) + '
		ORDER BY DocRowNo'
	------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
