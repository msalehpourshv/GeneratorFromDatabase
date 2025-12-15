USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid	
-- Create date   : 1393/05/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
--Select [inv].[FunGetCustomerLastProcessDate] (90, '2010101563', 0, 0, 0, 0, '', '')
CREATE FUNCTION [inv].[FunGetCustomerLastProcessDate]
(
	@ProcessID		SmallInt = 90,
	@AcntCode		VarChar(20),
	@FiscalFr		Int = Null,
	@SerialFr		Int = Null,
	@FiscalTo		Int = Null,
	@SerialTo		Int = Null,	
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS
BEGIN

DECLARE	@Result		VarChar(20);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE @PartStart	int;
DECLARE @PartLen	int;

DECLARE @Part1Start	int;
DECLARE @Part1Len	int;

DECLARE @Part2Start	int;
DECLARE @Part2Len	int;

DECLARE @Part3Start	int;
DECLARE @Part3Len	int;

DECLARE @Part4Start	int;
DECLARE @Part4Len	int;

DECLARE @VPathName1	nvarchar(50);
DECLARE @VPathName2	nvarchar(50);
DECLARE @VPathName3	nvarchar(50);
DECLARE @VPathName4	nvarchar(50);

DECLARE @PartNoLen	Int;
DECLARE @CustomerLayer AS tinyint;
DECLARE @AreaLayerLen AS tinyint;

DECLARE @PrePartsLen TinyInt;
DECLARE @StartLen	TinyInt;

	-- I N I T -----------------------------------------------------------------
		
	SET @LangID = pub.funGetCurrentLanguageID();
	
	If (@FiscalFr Is Null)	SET @SerialFr = Null;
	If (@FiscalTo Is Null)	SET @SerialTo = Null;
	If (@SerialFr Is Null)	SET @FiscalFr = Null;
	If (@SerialTo Is Null)	SET @FiscalTo = Null;
			
	-----------------------------------------------------------------------------------------------
	-------- set layers len -----------------------------------------------------------------------
	
	SET @VPathName1 = ''
	SET @VPathName2 = ''
	SET @VPathName3 = ''
	SET @VPathName4 = ''
	
	-- ================= AreaLayerLen
	SET @AreaLayerLen = 0
	
	SELECT @AreaLayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AreaLayerLen'
	
	-- ================= AcntPartNumberForRemainCalculation
	DECLARE @AcntPartNumberForRemainCalculation int
	SELECT @AcntPartNumberForRemainCalculation=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	-- ================= Select StartLen
	SET @StartLen = 1
	SET @PrePartsLen = 0
	
	Select @PrePartsLen = Sum(Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9) + @AcntPartNumberForRemainCalculation - 1
	From pub.tblCodeLayer
	Where TableName = 'acc.tblAcnt' And PartNumber < @AcntPartNumberForRemainCalculation
		
	-- =========================================
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	If (@AcntPartNumberForRemainCalculation = 1)
	Begin
		Set @PartStart = @Part1Start
		set @PartLen = @Part1Len
	End
	Else If (@AcntPartNumberForRemainCalculation = 2)
	Begin
		Set @PartStart = @Part2Start
		set @PartLen = @Part2Len
	End
	Else If (@AcntPartNumberForRemainCalculation = 3)
	Begin
		Set @PartStart = @Part3Start
		set @PartLen = @Part3Len
	End
	Else If (@AcntPartNumberForRemainCalculation = 4)
	Begin
		Set @PartStart = @Part4Start
		set @PartLen = @Part4Len
	End
	
	-- S E L E C T ------------------------------------------------------------
	SELECT Top 1 @Result = DocDate
	FROM inv.tblStorageDocsHdr H
	Where ProcessID = @ProcessID And SUBSTRING(AcntCode,@PartStart,@PartLen) = @AcntCode
	ORDER BY DocDate Desc

	---------------------------------------------------------------------------
	RETURN @Result

END
GO
