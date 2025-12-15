USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1386/04/03
-- Viewed By	 : 
-- Last Modified : 1393/09/10
-- Last Modifier : TakroSystem\Hamid
-- Description	 : 
-- ==============================================
Create PROCEDURE [inv].[RptStore_Described_ShowRecievedSent]
	@ProcessID			Int = 70,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYear			Int = Null,
	@SerialNo			Int = Null
	--@LangID				Char(1)	= 1

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect			NVarChar(Max);
DECLARE @StrWhere			NVarChar(Max);

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- ==========
	--IF @LangID is null Set @LangID = 1
	-- ================================
		SET @StrSelect = '
			Select D.GoodsID, pub.funGetGoodsName(D.GoodsID,1) GoodsName,
				   D.StoreID, [pub].[GetStoreName](D.StoreID,1) StoreName, 
				   D.GoodsQuantity, D.DocDate
			From inv.tblStorageDocsDtl D
			Where D.ProcessID = 80 
			And D.BaseProcessID = '+ LTRIM(RTrim(str(@ProcessID))) +'
			And D.BaseProcessNo = '+ LTRIM(RTrim(str(@ProcessNo))) +'
			And D.BaseFiscalYear = '+ LTRIM(RTrim(str(@FiscalYear))) +' 
			And D.BaseSerialNo = '+ LTRIM(RTrim(str(@SerialNo))) 
			 
	print @StrSelect
	Exec sp_executesql @StrSelect;

END
GO
