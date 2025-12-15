USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1395/08/19
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Inv Transfer Docs
-- ----------------------------------------------
-- ==============================================
-- EXEC [inv].[SPGetGoodsFields] '5010005501251028'
CREATE PROCEDURE [inv].[SPGetGoodsWith]
	@GoodsID VarChar(20)
	
WITH ENCRYPTION
AS

DECLARE @GoodsPrePartLen	Int
DECLARE @GoodsPartLen1 		Int
DECLARE @GoodsPartLen2 		Int
DECLARE @GoodsPartLen3 		Int
DECLARE @GoodsPartLen4 		Int
DECLARE @GoodsPartLen5 		Int

DECLARE @GoodsWidthPartNo Int
DECLARE @GoodsWidthPartNoLen Int
DECLARE @GoodsWidthField NVarchar(100)

DECLARE @GoodsWidth Int

BEGIN
	
	SET @GoodsWidthPartNo = 0

	-- ==========
	SELECT @GoodsWidthPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GoodsWidthPartNo'

	If @GoodsWidthPartNo = 0
	Begin
		Select 0
		Return 0
	End

	Select @GoodsWidthField = SettingValue
	From pub.tblSettings
	Where SettingKey = 'GoodsWidthField'
	
	-- ==========
	Select @GoodsPrePartLen = Sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9) + 1
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber < @GoodsWidthPartNo
	
	Select @GoodsWidthPartNoLen = Sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9)
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = @GoodsWidthPartNo
		
	-- ==========
	Select @GoodsPartLen1 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 1
	
	Select @GoodsPartLen2 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 2
	
	Select @GoodsPartLen3 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 3
	
	Select @GoodsPartLen4 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 4
	
	Select @GoodsPartLen5 = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From pub.tblCodeLayer
	Where TableName = 'inv.tblGoods' And PartNumber = 5
					
	-- ==========
	SELECT GoodsWidth
	FROM inv.tblGoods
	WHERE GoodsID = Substring(@GoodsID,@GoodsPrePartLen,@GoodsWidthPartNoLen) And 
		  PartNumber = @GoodsWidthPartNo
	
END
GO
