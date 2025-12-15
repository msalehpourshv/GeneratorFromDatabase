USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : jafari
-- Creation date : 1399/10/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : مانده بدهکاری یک حساب
-- =============================================
Create FUNCTION acc.funAcntDebitRemainFull
(
	@FullAcntCode VarChar(20),
	@DocDate      char(10)
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN



	DECLARE @Result AS float
	 
	DECLARE @Remain1	Bit;
	DECLARE @Remain2	Bit;
	DECLARE @Remain3	Bit;
	DECLARE @Remain4	Bit;
	DECLARE @CountPartRemain TINYINT
	DECLARE @Part1End		 TINYINT;
	DECLARE @Part1Start	Int;
	DECLARE @Part2Start	Int;
	DECLARE @Part3Start	Int;
	DECLARE @Part4Start	Int;
	DECLARE @Part1Len	Int;
	DECLARE @Part2Len	Int;
	DECLARE @Part3Len	Int;
	DECLARE @Part4Len	Int;
 

	SET		@Part1Start = 1;
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

	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  TableName = 'acc.tblAcnt' AND PartNumber = 1

	SELECT  @Remain1 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain1'
	SELECT  @Remain2 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain2'
	SELECT  @Remain3 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain3'
	SELECT  @Remain4 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain4'

	SET @CountPartRemain=0;
	
 

	SET @CountPartRemain=0;
	
 
	IF (@Remain1 = 1)
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain2 = 1) AND @CountPartRemain = 1
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain3 = 1) AND @CountPartRemain = 2
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain4 = 1) AND @CountPartRemain = 3
		SET @CountPartRemain = @CountPartRemain + 1

		IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CountPartRemain
			begin
				SET @CountPartRemain =250  
				SET @Remain1=0
				SET @Remain2=0
				SET @Remain3=0
				SET @Remain4=0
			end 
		else
			SET @CountPartRemain =0

		SELECT	@Result = IsNull(Sum(Debit-Credit), 0)
		FROM	acc.tblVoucherDtl M 
		INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = M.SerialNo
		INNER JOIN acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(M.AcntCode, 1, @Part1End)= SUBSTRING(b.AcntCode, 1, @Part1End )AND LEN(b.AcntCode) = @Part1End
		WHERE    b.AcntType NOT IN (91,92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 
		and ( @CountPartRemain=0 OR (@CountPartRemain=250 AND  M.AcntCode=@FullAcntCode))		
		AND ( @Remain1 =0 or (@Remain1 =1 AND Substring(M.AcntCode,@Part1Start,@Part1Len)=Substring(@FullAcntCode,@Part1Start,@Part1Len)))
		AND ( @Remain2 =0 or (@Remain2 =1 AND Substring(M.AcntCode,@Part2Start,@Part2Len)=Substring(@FullAcntCode,@Part2Start,@Part2Len)))
		AND ( @Remain3 =0 or (@Remain3 =1 AND Substring(M.AcntCode,@Part3Start,@Part3Len)=Substring(@FullAcntCode,@Part3Start,@Part3Len)))
		AND ( @Remain4 =0 or (@Remain4 =1 AND Substring(M.AcntCode,@Part4Start,@Part4Len)=Substring(@FullAcntCode,@Part4Start,@Part4Len)))
		AND	(@DocDate='' or M.DocDate <= @DocDate )

	RETURN @Result
END

GO
