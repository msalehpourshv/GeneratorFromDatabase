USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : Ahmadnejad, Hossein
-- Create date   : 86/12/19
-- Viewed By	 : 
-- Last Modified : 
-- Description: < دفتر حسابداری یک کد حسابداری >
-- =============================================
CREATE PROCEDURE [acc].[SpAccountingBook_OneCodeForSaleOrder]
	@AcntCode	VarChar(20) = Null,
	@IsSum		Bit,
	@StartTargetLayer tinyint,
	@LenTargetLayer tinyint,
	@ProcessID Smallint =NULL ,
	@ProcessNo Tinyint =NULL ,
	@FiscalYear INT =NULL ,
	@SerialNo INT =NULL,
	@Filter_Type BIT ='True' 

	WITH ENCRYPTION
AS

Declare @Part1End	TINYINT;
Declare @Part1Len	VARCHAR(2);

Declare @Part2Start	VARCHAR(2);
Declare @Part2Len	VARCHAR(2);

Declare @Part3Start	VARCHAR(2);
Declare @Part3Len	VARCHAR(2);

Declare @Part4Start	VARCHAR(2);
Declare @Part4Len	VARCHAR(2);

Declare @AcntCode1	VarChar(20);
Declare @AcntCode2	VarChar(20);
Declare @AcntCode3	VarChar(20);
Declare @AcntCode4	VarChar(20);

Declare @StrSelect	NVarChar(3000);
Declare @StrWhere	NVarChar(3000);
BEGIN

	SET NOCOUNT ON;

	
	SELECT	@Part1End =  Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)
	
	------SET		@Part1Len = @Part1End + 1 - @Part1Start;

	------SET	@Part2Start = @Part1End + 2;
	------SELECT	@Part2End = @Part2Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	------FROM	pub.tblCodeLayer 
	------WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)
	------SET		@Part2Len = @Part2End + 1 - @Part2Start;

	------SET	@Part3Start = @Part2End + 2;
	------SELECT	@Part3End = @Part3Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	------FROM	pub.tblCodeLayer 
	------WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)
	------SET		@Part3Len = @Part3End + 1 - @Part3Start;

	------SET	@Part4Start = @Part3End + 2;
	------SELECT	@Part4End = @Part4Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	------FROM	pub.tblCodeLayer 
	------WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	------SET		@Part4Len = @Part4End + 1 - @Part4Start;

	------If (Len(@AcntCode) >= @Part1End)
		------Set @AcntCode1 = Substring(@AcntCode, @Part1Start, @Part1Len)
	------Else
		------Set @AcntCode1 = ''

	------If (Len(@AcntCode) >= @Part2End)
		------Set @AcntCode2 = Substring(@AcntCode, @Part2Start, @Part2Len)
	------Else
		------Set @AcntCode2 = ''

	------If (Len(@AcntCode) >= @Part3End)
		------Set @AcntCode3 = Substring(@AcntCode, @Part3Start, @Part3Len)
	------Else
		------Set @AcntCode3 = ''

	------If (Len(@AcntCode) >= @Part4End)
		------Set @AcntCode4 = Substring(@AcntCode, @Part4Start, @Part4Len)
	------Else
		------Set @AcntCode4 = ''

	-- Voucher Kind <> 'Note'
	Set @StrWhere = ' VchKind <> 0 '

	------If (@AcntCode1 <> '')
		------Set @StrWhere = @StrWhere + '
			------AND Substring(AcntCode, ' + LTrim(Str(@Part1Start)) + ', ' + LTrim(Str(@Part1Len)) + ') = ''' + @AcntCode1 + ''''

	------If (@AcntCode2 <> '')
		------Set @StrWhere = @StrWhere + '
			------AND Substring(AcntCode, ' + LTrim(Str(@Part2Start)) + ', ' + LTrim(Str(@Part2Len)) + ') = ''' + @AcntCode2 + ''''

	------If (@AcntCode3 <> '')
		------Set @StrWhere = @StrWhere + '
			------AND Substring(AcntCode, ' + LTrim(Str(@Part3Start)) + ', ' + LTrim(Str(@Part3Len)) + ') = ''' + @AcntCode3 + ''''

	------If (@AcntCode4 <> '')
		------Set @StrWhere = @StrWhere + '
			------AND Substring(AcntCode, ' + LTrim(Str(@Part4Start)) + ', ' + LTrim(Str(@Part4Len)) + ') = ''' + @AcntCode4 + ''''

			
	--IF (SELECT SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain1') = 'True'
	--	Set @StrWhere = @StrWhere + '
	--		AND a.AcntCode = ''' + @AcntCode + ''''
	--ELSE
	--	Set @StrWhere = @StrWhere + '
	--		AND SUBSTRING(a.AcntCode,' + LTrim(Str(@StartTargetLayer)) + ',' + LTrim(Str(@LenTargetLayer)) + ') = ''' + SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer) + ''''




	IF (SELECT SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'SalIvcRemain1')='True'
	BEGIN
		SELECT	@Part1Len =  Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)
		
		SET @StrWhere =  @StrWhere + ' AND SUBSTRING(a.AcntCode,1,' + @Part1Len + ') = SUBSTRING(''' + @AcntCode + ''',1,' + @Part1Len + ')' 
	END

	IF (SELECT SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'SalIvcRemain2')='True'
	BEGIN
		SELECT	@Part2Start =  SUM(Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 )+2
		FROM	pub.tblCodeLayer 
		WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber < 2)
	
		SELECT	@Part2Len =  Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 2)
			
				
		SET @StrWhere = @StrWhere + ' AND SUBSTRING(a.AcntCode,' + @Part2Start + ',' + @Part2Len + ') = SUBSTRING(''' + @AcntCode + ''',' + @Part2Start + ',' + @Part2Len + ')'
	END

	IF (SELECT SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'SalIvcRemain3')='True'
	BEGIN
		SELECT	@Part3Start =  SUM(Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 )+3
		FROM	pub.tblCodeLayer 
		WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber < 3)

		SELECT	@Part3Len =  Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 3)
			
		SET @StrWhere = @StrWhere + ' AND SUBSTRING(a.AcntCode,' + @Part3Start + ',' + @Part3Len + ')=SUBSTRING(''' + @AcntCode + ''',' + @Part3Start + ',' + @Part3Len + ')'
	END	
	
	IF (SELECT SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'SalIvcRemain4')='True'
	BEGIN
		SELECT	@Part4Start =  SUM(Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 )+4
		FROM	pub.tblCodeLayer 
		WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber < 4)
		
		SELECT	@Part4Len =  Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
		FROM	pub.tblCodeLayer 
		WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 4)

				
		SET @StrWhere = @StrWhere + ' AND SUBSTRING(a.AcntCode,' + @Part4Start + ',' + @Part4Len + ')=SUBSTRING(''' + @AcntCode + ''',' + @Part4Start + ',' + @Part4Len + ')'
		
	END	



	/* ====== Prepare SELECT Section ============= */
	If (@IsSum = 1)
		IF @Filter_Type = 'False'
			Set @StrSelect = '
			SELECT	IsNull(Sum(Debit), 0) Debit, IsNull(Sum(Credit), 0) Credit
			FROM	acc.tblVoucherDtl a
			WHERE ' + LTrim(RTrim(@StrWhere))
		ELSE
			Set @StrSelect = '
			SELECT	IsNull(Sum(Debit), 0) Debit, IsNull(Sum(Credit), 0) Credit
			FROM	acc.tblVoucherDtl a
			INNER join acc.tblAcnt b
			ON PartNumber= 1 and SUBSTRING(a.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode)=' + LTrim(RTrim(STR(@Part1End))) + '
			WHERE AcntType NOT IN (91,92) AND ' + LTrim(RTrim(@StrWhere))
	Else
	IF @Filter_Type = 'False'
			
		Set @StrSelect = '
		SELECT	DocDate, Debit, Credit, RecDesc,RowNo AS [Order]
		FROM	acc.tblVoucherDtl a
		WHERE ' + LTrim(RTrim(@StrWhere)) + '
		ORDER BY DocDate,SerialNo, [Order] '
		ELSE
			
			
		Set @StrSelect = '
		SELECT	DocDate, Debit, Credit, RecDesc,RowNo AS [Order]
		FROM	acc.tblVoucherDtl a
			INNER join acc.tblAcnt b
			ON PartNumber= 1 and SUBSTRING(a.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') = SUBSTRING(b.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') AND LEN(b.AcntCode)=' + LTrim(RTrim(STR(@Part1End))) + '
			WHERE AcntType NOT IN (91,92) AND ' + LTrim(RTrim(@StrWhere)) + '
		ORDER BY DocDate,SerialNo, [Order] '
			Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
