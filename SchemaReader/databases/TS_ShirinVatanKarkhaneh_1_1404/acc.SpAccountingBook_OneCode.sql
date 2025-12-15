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
CREATE PROCEDURE [acc].[SpAccountingBook_OneCode]
	@AcntCode	VarChar(20) = Null,
	@DocDate	Char(10),
	@IsSum		Bit

WITH ENCRYPTION
AS

Declare @Part1Start	TinyInt;
Declare @Part1End	TinyInt;
Declare @Part1Len	TinyInt;

Declare @Part2Start	TinyInt;
Declare @Part2End	TinyInt;
Declare @Part2Len	TinyInt;

Declare @Part3Start	TinyInt;
Declare @Part3End	TinyInt;
Declare @Part3Len	TinyInt;

Declare @Part4Start	TinyInt;
Declare @Part4End	TinyInt;
Declare @Part4Len	TinyInt;

Declare @AcntCode1	VarChar(20);
Declare @AcntCode2	VarChar(20);
Declare @AcntCode3	VarChar(20);
Declare @AcntCode4	VarChar(20);

Declare @StrSelect	NVarChar(3000);
Declare @StrWhere	NVarChar(3000);
BEGIN

	SET NOCOUNT ON;

	------SET	@Part1Start = 1;
	------SELECT	@Part1End = @Part1Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1
	------FROM	pub.tblCodeLayer 
	------WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)
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

	Set @StrWhere = @StrWhere + '
		AND AcntCode = ''' + @AcntCode + ''''

	IF @DocDate <> '' And @DocDate Is Not Null
		Set @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DocDate + ''')'
	/* ====== Prepare SELECT Section ============= */
	If (@IsSum = 1)

		Set @StrSelect = '
		SELECT	IsNull(Sum(Debit), 0) Debit, IsNull(Sum(Credit), 0) Credit
		FROM	acc.tblVoucherDtl
		WHERE ' + LTrim(RTrim(@StrWhere))
	Else
		Set @StrSelect = '
		SELECT	DocDate, Debit, Credit, pub.funReverseForCrystal(RecDesc) RecDesc,
				(Case When Credit = 0 
					Then 1 
					Else 2 
				End) AS [Order],SerialNo
		FROM	acc.tblVoucherDtl
		WHERE ' + LTrim(RTrim(@StrWhere)) + '
		ORDER BY DocDate, SerialNo, DocRowNo '

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
