USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Javd Bayani
-- Create Date   : 1388/09/25	, 2009/12/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :	This Function Check each Layer of each Part and when  one of them  is Closed ,
--					Return the PartNumber and Layer
-- ==============================================
CREATE FUNCTION acc.funIsCodeClosed 
(
	@AcntCode Varchar(20)
)
RETURNS Tinyint
WITH ENCRYPTION
AS
BEGIN

	Declare @L1 Char(1) ,
			@L2 Char(1) ,
			@L3 Char(1) ,
			@L4 Char(1) ,
			@L5 Char(1) ,
			@L6 Char(1) ,
			@L7 Char(1) ,
			@L8 Char(1) ,
			@L9 Char(1) 
	Declare	@P1 Char(10) ,
			@P2 Char(10) ,
			@P3 Char(10) ,
			@P4 Char(10)

	Declare @Part Tinyint , @Result Tinyint 
	Declare @Layer Tinyint , @L Tinyint , @PrevL Tinyint, @Spc Tinyint
	Declare @Acnt Varchar(20)

	SET @P1 = ''
	SET @P2 = ''
	SET @P3 = ''
	SET @P4 = ''

	Select @L1 = Layer1,@L2 = Layer2,@L3 = Layer3,@L4 = Layer4,@L5 = Layer5,@L6 = Layer6,@L7 = Layer7,@L8 = Layer8,@L9 = Layer9
	From pub.tblCodeLayer
	Where TableName = 'acc.tblAcnt' AND PartNumber = 1

	SET @P1 =STUFF(@P1, 1, 1, @L1)
	SET @P1 =STUFF(@P1, 2, 1, @L2)
	SET @P1 =STUFF(@P1, 3, 1, @L3)
	SET @P1 =STUFF(@P1, 4, 1, @L4)
	SET @P1 =STUFF(@P1, 5, 1, @L5)
	SET @P1 =STUFF(@P1, 6, 1, @L6)
	SET @P1 =STUFF(@P1, 7, 1, @L7)
	SET @P1 =STUFF(@P1, 8, 1, @L8)
	SET @P1 =STUFF(@P1, 9, 1, @L9)

	Select @L1 = Layer1,@L2 = Layer2,@L3 = Layer3,@L4 = Layer4,@L5 = Layer5,@L6 = Layer6,@L7 = Layer7,@L8 = Layer8,@L9 = Layer9
	From pub.tblCodeLayer
	Where TableName = 'acc.tblAcnt' AND PartNumber = 2

	SET @P2 =STUFF(@P2, 1, 1, @L1)
	SET @P2 =STUFF(@P2, 2, 1, @L2)
	SET @P2 =STUFF(@P2, 3, 1, @L3)
	SET @P2 =STUFF(@P2, 4, 1, @L4)
	SET @P2 =STUFF(@P2, 5, 1, @L5)
	SET @P2 =STUFF(@P2, 6, 1, @L6)
	SET @P2 =STUFF(@P2, 7, 1, @L7)
	SET @P2 =STUFF(@P2, 8, 1, @L8)
	SET @P2 =STUFF(@P2, 9, 1, @L9)

	Select @L1 = Layer1,@L2 = Layer2,@L3 = Layer3,@L4 = Layer4,@L5 = Layer5,@L6 = Layer6,@L7 = Layer7,@L8 = Layer8,@L9 = Layer9
	From pub.tblCodeLayer
	Where TableName = 'acc.tblAcnt' AND PartNumber = 3

	SET @P3 =STUFF(@P3, 1, 1, @L1)
	SET @P3 =STUFF(@P3, 2, 1, @L2)
	SET @P3 =STUFF(@P3, 3, 1, @L3)
	SET @P3 =STUFF(@P3, 4, 1, @L4)
	SET @P3 =STUFF(@P3, 5, 1, @L5)
	SET @P3 =STUFF(@P3, 6, 1, @L6)
	SET @P3 =STUFF(@P3, 7, 1, @L7)
	SET @P3 =STUFF(@P3, 8, 1, @L8)
	SET @P3 =STUFF(@P3, 9, 1, @L9)

	Select @L1 = Layer1,@L2 = Layer2,@L3 = Layer3,@L4 = Layer4,@L5 = Layer5,@L6 = Layer6,@L7 = Layer7,@L8 = Layer8,@L9 = Layer9
	From pub.tblCodeLayer
	Where TableName = 'acc.tblAcnt' AND PartNumber = 4

	SET @P4 =STUFF(@P4, 1, 1, @L1)
	SET @P4 =STUFF(@P4, 2, 1, @L2)
	SET @P4 =STUFF(@P4, 3, 1, @L3)
	SET @P4 =STUFF(@P4, 4, 1, @L4)
	SET @P4 =STUFF(@P4, 5, 1, @L5)
	SET @P4 =STUFF(@P4, 6, 1, @L6)
	SET @P4 =STUFF(@P4, 7, 1, @L7)
	SET @P4 =STUFF(@P4, 8, 1, @L8)
	SET @P4 =STUFF(@P4, 9, 1, @L9)

	--	***************************************************************************************************************

	Set @Part = 10
	Set @Spc = 0
	Set @Result = 0
	While @Part <= 40
		Begin
			IF @Part = 10
				Set @L = 0
			IF @Part = 20
				Begin
					Set @PrevL = @L
					Set @L = 0
				End
			IF @Part = 30
				Begin
					Set @PrevL = @PrevL + @L + 1
					Set @L = 0
				End
			IF @Part = 40
				Begin
					Set @PrevL = @PrevL + @L
					Set @L = 0
				End

			Set @Layer = 1
			While @Layer <= 9
				Begin
					IF @Part = 10
						IF Cast(SubString(@P1,@Layer,1) AS Tinyint) > 0
							Begin
								Select @L = @L + Cast(SubString(@P1,@Layer,1) AS Tinyint)
								Select @Acnt = Ltrim(Rtrim(SubString(@AcntCode ,1 ,@L + @Spc)))
	--							Select @Part ,@Acnt ,CodeClosed , @Part + @Layer AS PartLayer From acc.tblAcnt Where AcntCode = @Acnt AND PartNumber = @Part/10 AND CodeClosed = 1
								IF (Select Count(*) From acc.tblAcnt Where AcntCode = @Acnt AND PartNumber = @Part/10 AND CodeClosed = 1) > 0
									Set @Result = @Part + @Layer
							End
					IF @Part = 20
						IF Cast(SubString(@P2,@Layer,1) AS Tinyint) > 0
							Begin
								Select @L = @L + Cast(SubString(@P2,@Layer,1) AS Tinyint)
								Select @Acnt = Ltrim(Rtrim(SubString(@AcntCode ,@PrevL + @Spc ,@L + @Spc)))
	--							Select @Part ,@Acnt ,CodeClosed , @Part + @Layer AS PartLayer From acc.tblAcnt Where AcntCode = @Acnt AND PartNumber = @Part/10 --AND CodeClosed = 1
								IF (Select Count(*) From acc.tblAcnt Where AcntCode = @Acnt AND PartNumber = @Part/10 AND CodeClosed = 1) > 0
									Set @Result = @Part + @Layer
							End
					IF @Part = 30
						IF Cast(SubString(@P3,@Layer,1) AS Tinyint) > 0
							Begin
								Select @L = @L + Cast(SubString(@P3,@Layer,1) AS Tinyint)
								Select @Acnt = Ltrim(Rtrim(SubString(@AcntCode ,@PrevL + @Spc ,@L )))
	--							Select @Part ,@Acnt ,CodeClosed , @Part + @Layer AS PartLayer From acc.tblAcnt Where AcntCode = @Acnt AND PartNumber = @Part/10 AND CodeClosed = 1
								IF (Select Count(*) From acc.tblAcnt Where AcntCode = @Acnt AND PartNumber = @Part/10 AND CodeClosed = 1) > 0
									Set @Result = @Part + @Layer
							End
					IF @Part = 40
						IF Cast(SubString(@P4,@Layer,1) AS Tinyint) > 0
							Begin
								Select @L = @L + Cast(SubString(@P4,@Layer,1) AS Tinyint)
								Select @Acnt = Ltrim(Rtrim(SubString(@AcntCode ,@PrevL + @Spc,@L )))
	--							Select @Part ,@Acnt ,CodeClosed , @Part + @Layer AS PartLayer From acc.tblAcnt Where AcntCode = @Acnt AND PartNumber = @Part/10 AND CodeClosed = 1
								IF (Select Count(*) From acc.tblAcnt Where AcntCode = @Acnt AND PartNumber = @Part/10 AND CodeClosed = 1) > 0
									Set @Result = @Part + @Layer
							End
					Set @Layer = @Layer + 1
				End
			Set @Part = @Part + 10
			Set @Spc = @Spc + 1
		End

	RETURN @Result

END

GO
