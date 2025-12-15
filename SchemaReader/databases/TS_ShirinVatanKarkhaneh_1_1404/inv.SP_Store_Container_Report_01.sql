USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE inv.SP_Store_Container_Report_01
	@ProcessID  Int           = 120,
	@ProcessNo  Int           = 2,
	@FiscalYear Int           = 1404,
	@SerialNo   Int           = 0,
	@DocDate_Fr Char(10)      = '1404/04/01',
	@DocDate_To Char(10)      = '1404/04/30',
	@StoreID_01 VarChar(20)   = '0852',
	@StoreID_02 VarChar(20)   = '0301',
	@OP_Type    Int           = 2       -- 1 => Detailed | 2 => GroupedDECLARE @StrSelect	NVarChar(Max);

WITH ENCRYPTION
AS

DECLARE @StrSelect   NVarChar(Max) = ''
DECLARE @StrWhere    NVarChar(Max) = ''
DECLARE @StrFields   NVarChar(Max) = ''
DECLARE @StrGroup_By NVarChar(Max) = ''

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- =====================================================================================
	-- ===================================================================================== Init
	-- =====================================================================================
	IF @OP_Type = 1
	Begin
	   SET @StrFields = '
		   D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.StoreID, D.StoreID2, D.GoodsID, GD.GoodsName, D.SubUnitQuantity, UD.UnitName, 
		   S.ContainerID, S.ContainerID2, S.NumberPerContainer, S.SubUnitNumberPerContainer, S.ProductionDate, S.ExpireDate, S.ContainerStoresID, S.ContainerStoresID2'

	   SET @StrGroup_By = ''
	End
	ELSE
	Begin
	   SET @StrFields = '
		   D.ProcessID, D.ProcessNo, D.FiscalYear, D.StoreID, D.StoreID2, COUNT(S.ContainerID) Container_Count '

	   SET @StrGroup_By = '
	Group By D.ProcessID, D.ProcessNo, D.FiscalYear, D.StoreID, D.StoreID2'

	End

	-- ===================================================================================== Select
	SET @StrSelect = '
	Select ' + @StrFields + '
	From       inv.tblStorageDocsHdr     H
	Inner Join inv.tblStorageDocsDtl     D  ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
	Inner Join inv.tblStorageDocsSerials S  ON S.ProcessID = D.ProcessID And S.ProcessNo = D.ProcessNo And S.FiscalYear = D.FiscalYear And S.SerialNo = D.SerialNo And S.DocRowNo = D.DocRowNo
	Inner Join inv.tblGoodsDtl           GD ON GD.GoodsID = D.GoodsID 
	Inner Join inv.tblUnitsDtl           UD ON UD.UnitID = D.SubUnitID
	Where 1 = 1 ' +
	  Case When @ProcessID <> 0 Then ' 
	  And H.ProcessID  = ' + LTrim(RTrim(Str(@ProcessID))) Else '' End +
	  Case When @ProcessNo <> 0 Then '
	  And H.ProcessNo  = ' + LTrim(RTrim(Str(@ProcessNo)))  Else '' End +
	  Case When @FiscalYear <> 0 Then ' 
	  And H.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYear))) Else '' End +
	  Case When @SerialNo <> 0 Then ' 
	  And H.SerialNo   = ' + LTrim(RTrim(Str(@SerialNo)))   Else '' End +
	  Case When @StoreID_01 <> '' Then ' 
	  And D.StoreID    = ''' + LTrim(RTrim(@StoreID_01)) + '''' Else '' End +
	  Case When @StoreID_02 <> '' Then ' 
	  And D.StoreID2   = ''' + LTrim(RTrim(@StoreID_02)) + '''' Else '' End + 
	  Case When @DocDate_Fr <> '' Then ' 
	  And D.DocDate   >= ''' + LTrim(RTrim(@DocDate_Fr)) + '''' Else '' End + 
	  Case When @DocDate_To <> '' Then ' 
	  And D.DocDate   <= ''' + LTrim(RTrim(@DocDate_To)) + '''' Else '' End + 
	  @StrGroup_By

	-- ===================================================================================== EXEC
	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;

END

GO
