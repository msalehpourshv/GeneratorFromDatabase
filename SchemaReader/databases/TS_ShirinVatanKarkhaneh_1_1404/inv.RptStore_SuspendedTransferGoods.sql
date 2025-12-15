USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Hamid
-- Create date   : 1394/06/22
-- Viewed By	 : 
-- Last Modified : 1394/06/22
-- Last Modifier : TakroSystem/Hamid
-- Description   : برگ سفارش خرید کالا
-- =============================================
Create PROCEDURE [inv].[RptStore_SuspendedTransferGoods]
	@GoodsID	 Varchar(20) = Null,
	@StoreID	 Varchar(20) = Null,
	--@StoreID2	 Varchar(20) = Null,
	@FromDate	 Varchar(20) = Null,
	@ToDate		 Varchar(20) = Null
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(Max);
DECLARE @LanguageID TinyInt;
DECLARE @HasSerial  Bit;
DECLARE @UnitPart TINYINT

Begin --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	Set @StrSelect = ''
	Set @StrWhere = '1 = 1'
	Set @StrWhere2 = ''

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	If (@LanguageID Is Null)	SET @LanguageID = 1

	-- W H E R E --------------------------------------------------------------
	IF @StoreID <> '' And @StoreID IS Not Null
		Set @StrWhere = @StrWhere + ' And A.StoreID = ''' + LTrim(RTrim(@StoreID)) + ''''
			
	--IF @StoreID2 <> '' And @StoreID2 IS Not Null
	--	Set @StrWhere = @StrWhere + ' And StoreID2 = ''' + LTrim(RTrim(@StoreID2)) + ''''
		
	IF @GoodsID <> '' And @GoodsID IS Not Null
		Set @StrWhere = @StrWhere + ' And A.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''''		
	
	IF (@FromDate Is Not Null And @FromDate <> '')
		Set @StrWhere2 = @StrWhere2 + ' And A.DocDate >= ''' + LTrim(RTrim(@FromDate)) + ''''
		
	IF (@ToDate Is Not Null And @ToDate <> '')
		Set @StrWhere2 = @StrWhere2 + ' And A.DocDate <= ''' + LTrim(RTrim(@ToDate)) + ''''		
	
	-- S E L E C T ------------------------------------------------------------

	Set @StrSelect = '
	SELECT A.FiscalYear, A.SerialNo, A.StoreID, A.StoreID2, A.GoodsID, G.GoodsName, A.GoodsQuantity 
	From 
		  (Select ProcessNo, FiscalYear, SerialNo, GoodsID, GoodsQuantity, StoreID, StoreID2 
		   From inv.tblStorageDocsDtl 
		   Where ProcessID = 120 
		   Except
		   Select ProcessNo, FiscalYear, SerialNo, GoodsID, GoodsQuantity, StoreID2, StoreID 
		   From inv.tblStorageDocsDtl 
		   Where ProcessID = 125) A
	 Inner Join inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(A.GoodsID,' + LTRIM(STR(@str_Goods+1)) + ',' + LTRIM(STR(@str_GoodsSum)) + ')  	AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + '
	 WHERE ' + @StrWhere + '
	 GROUP BY A.FiscalYear, A.SerialNo, A.StoreID, A.StoreID2, A.GoodsID, G.GoodsName, A.GoodsQuantity '
	
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
