USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Creation Date : 1399/07/07
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE FUNCTION acc.funAccountRemainFromSaleSetting
(
	@AcntCode Varchar(20),
	@DocDate Char(10)
)
RETURNS Float
WITH ENCRYPTION
AS

BEGIN

DECLARE @Part1End			TinyInt;

	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)
	
	DECLARE @Result AS Varchar(20)
	Declare @Part1Start	TinyInt;
	Declare @Part1Len	TinyInt;

	Declare @Part2Start	TinyInt;
	Declare @Part2Len	TinyInt;

	Declare @Part3Start	TinyInt;
	Declare @Part3Len	TinyInt;

	Declare @Part4Start	TinyInt;
	Declare @Part4Len	TinyInt;

		-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
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


	DECLARE @Remain  FLOAT

	SET  @Remain = 0
	
	DECLARE @Remain1	Bit;
	DECLARE @Remain2	Bit;
	DECLARE @Remain3	Bit;
	DECLARE @Remain4	Bit;
	SELECT @Remain1= SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SalIvcRemain1'
	SELECT @Remain2= SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SalIvcRemain2'
	SELECT @Remain3= SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SalIvcRemain3'
	SELECT @Remain4= SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'SalIvcRemain4'

	 SELECT	 @Remain=IsNull(Sum( Credit-Debit ),0) 
				 FROM	acc.tblVoucherDtl M 
				 INNER JOIN acc.tblVoucherHdr VH 
					ON VH.SerialNo = M.SerialNo
				 INNER join acc.tblAcnt b 
					ON b.PartNumber = 1 
					AND SUBSTRING(M.AcntCode, 1, @Part1End) = SUBSTRING(b.AcntCode, 1,@Part1End)
					AND LEN(b.AcntCode) = @Part1End
				 WHERE  b.AcntType NOT IN (91, 92) 
					AND M.VchKind <> 0 
					AND VH.DocRegisterState > 0 
					AND M.DocDate <= @DocDate
				and (@Remain1 = 0 or (@Remain1 = 1  AND Substring(M.AcntCode,@Part1Start,@Part1Len)=Substring(@AcntCode,@Part1Start,@Part1Len) ))
				and (@Remain2 = 0 or (@Remain2 = 1  AND Substring(M.AcntCode,@Part2Start,@Part2Len)=Substring(@AcntCode,@Part2Start,@Part2Len) ))
				and (@Remain3 = 0 or (@Remain3 = 1  AND Substring(M.AcntCode,@Part3Start,@Part3Len)=Substring(@AcntCode,@Part3Start,@Part3Len) ))
				and (@Remain4 = 0 or (@Remain4 = 1  AND Substring(M.AcntCode,@Part4Start,@Part4Len)=Substring(@AcntCode,@Part4Start,@Part4Len) ))

	RETURN @Remain
END
GO
