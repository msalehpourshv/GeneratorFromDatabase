USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/01/07
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create Procedure [sal].[SpGetVisitorAcntCode]

	@AcntCode Varchar(20),
	@Date	  char(10)=''

WITH ENCRYPTION
AS
BEGIN
	IF (SELECT COUNT(0) FROM sal.tblVisitorsCustomersDtl NOLOCK ) = 0
	BEGIN
		SELECT top 0 '' VisitorAcntCode ,0 VisitorPercent 
		return
	END

-- Declare Variables ------------
	Declare @Layer11 Tinyint
	Declare @Layer12 Tinyint
	Declare @Layer13 Tinyint
	Declare @Layer14 Tinyint
	Declare @Layer15 Tinyint
	Declare @Layer16 Tinyint
	Declare @Layer17 Tinyint
	Declare @Layer18 Tinyint
	Declare @Layer19 Tinyint
	Declare @Part1Len Tinyint
	Set @Part1Len = 0

	Declare @Layer21 Tinyint
	Declare @Layer22 Tinyint
	Declare @Layer23 Tinyint
	Declare @Layer24 Tinyint
	Declare @Layer25 Tinyint
	Declare @Layer26 Tinyint
	Declare @Layer27 Tinyint
	Declare @Layer28 Tinyint
	Declare @Layer29 Tinyint
	Declare @Part2Len Tinyint
	Set @Part2Len = 0

	Declare @Layer31 Tinyint
	Declare @Layer32 Tinyint
	Declare @Layer33 Tinyint
	Declare @Layer34 Tinyint
	Declare @Layer35 Tinyint
	Declare @Layer36 Tinyint
	Declare @Layer37 Tinyint
	Declare @Layer38 Tinyint
	Declare @Layer39 Tinyint
	Declare @Part3Len Tinyint
	Set @Part3Len = 0

	Declare @Layer41 Tinyint
	Declare @Layer42 Tinyint
	Declare @Layer43 Tinyint
	Declare @Layer44 Tinyint
	Declare @Layer45 Tinyint
	Declare @Layer46 Tinyint
	Declare @Layer47 Tinyint
	Declare @Layer48 Tinyint
	Declare @Layer49 Tinyint
	Declare @Part4Len Tinyint
	Set @Part4Len = 0

	Declare @VisitorAcntCode Varchar(20)
	Declare @VisitorPercent  Float

	SET @VisitorAcntCode = Null

	Select	@Layer11 = Layer1, @Layer12 = Layer2, @Layer13 = Layer3, 
				@Layer14 = Layer4, @Layer15 = Layer5, @Layer16 = Layer6, 
				@Layer17 = Layer7, @Layer18 = Layer8, @Layer19 = Layer9,
				@Part1Len=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From		pub.tblCodeLayer 
	Where		PartNumber = 1 AND TableName = 'acc.tblAcnt'

	Select	@Layer21 = Layer1, @Layer22 = Layer2, @Layer23 = Layer3, 
				@Layer24 = Layer4, @Layer25 = Layer5, @Layer26 = Layer6, 
				@Layer27 = Layer7, @Layer28 = Layer8, @Layer29 = Layer9,
				@Part2Len=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From		pub.tblCodeLayer 
	Where		PartNumber = 2 AND TableName = 'acc.tblAcnt'

	Select @Layer31 = Layer1, @Layer32 = Layer2, @Layer33 = Layer3, 
          @Layer34 = Layer4, @Layer35 = Layer5, @Layer36 = Layer6, 
          @Layer37 = Layer7, @Layer38 = Layer8, @Layer39 = Layer9,
  		  @Part3Len=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From  pub.tblCodeLayer 
	Where PartNumber = 3 AND TableName = 'acc.tblAcnt'

	Select @Layer41 = Layer1, @Layer42 = Layer2, @Layer43 = Layer3, 
          @Layer44 = Layer4, @Layer45 = Layer5, @Layer46 = Layer6, 
          @Layer47 = Layer7, @Layer48 = Layer8, @Layer49 = Layer9,
  		  @Part4Len=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	From  pub.tblCodeLayer 
	Where PartNumber = 4 AND TableName = 'acc.tblAcnt'

WHILE LEN(@AcntCode) > 0
BEGIN

	IF @Part4Len > 0 AND LEN(@AcntCode)>@Part1Len + 1 + @Part2Len + 1 + @Part3Len + 1
	BEGIN
		IF @Layer49 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45+@Layer46+@Layer47+@Layer48+@Layer49
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45+@Layer46+@Layer47+@Layer48)
				END
			END
		ELSE IF @Layer48 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45+@Layer46+@Layer47+@Layer48
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45+@Layer46+@Layer47)
				END
			END
		ELSE IF @Layer47 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45+@Layer46+@Layer47
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45+@Layer46)
				END
			END
		ELSE IF @Layer46 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45+@Layer46
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45)
				END
			END
		ELSE IF @Layer45 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44+@Layer45
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44)
				END
			END
		ELSE IF @Layer44 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43+@Layer44
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43)
				END
			END
		ELSE IF @Layer43 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42+@Layer43
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42)
				END
			END
		ELSE IF @Layer42 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 + @Layer41+@Layer42
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 3 + @Layer41)
				END
			END
		ELSE IF @Layer41 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + @Part3Len + 3 +  @Layer41
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + @Part3Len + 2)
				END
			END
	END
	ELSE IF @Part3Len > 0 AND LEN(@AcntCode)>@Part1Len + 1 + @Part2Len + 1 
	BEGIN
		IF @Layer39 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35+@Layer36+@Layer37+@Layer38+@Layer39
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35+@Layer36+@Layer37+@Layer38)
				END
			END
		ELSE IF @Layer38 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35+@Layer36+@Layer37+@Layer38
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35+@Layer36+@Layer37)
				END
			END
		ELSE IF @Layer37 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35+@Layer36+@Layer37
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35+@Layer36)
				END
			END
		ELSE IF @Layer36 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35+@Layer36
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35)
				END
			END
		ELSE IF @Layer35 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34+@Layer35
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34)
				END
			END
		ELSE IF @Layer34 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33+@Layer34
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33)
				END
			END
		ELSE IF @Layer33 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 + @Layer31+@Layer32+@Layer33
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 2 + @Layer31+@Layer32)
				END
			END
		ELSE IF @Layer32 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 + @Layer31+@Layer32
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 2 + @Layer31)
				END
			END
		ELSE IF @Layer31 >0 AND LEN(@AcntCode) = @Part1Len + @Part2Len + 2 +  @Layer31
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + @Part2Len + 1)
				END
			END		
	END
	ELSE IF @Part2Len > 0 AND LEN(@AcntCode)>@Part1Len + 1 
	BEGIN
		IF @Layer29 >0 AND LEN(@AcntCode) = @Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25+@Layer26+@Layer27+@Layer28+@Layer29
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25+@Layer26+@Layer27+@Layer28)
				END
			END
		ELSE IF @Layer28 >0 AND LEN(@AcntCode) = @Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25+@Layer26+@Layer27+@Layer28
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25+@Layer26+@Layer27)
				END
			END
		ELSE IF @Layer27 >0 AND LEN(@AcntCode) = @Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25+@Layer26+@Layer27
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25+@Layer26)
				END
			END
		ELSE IF @Layer26 >0 AND LEN(@AcntCode) = @Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25+@Layer26
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25)
				END
			END
		ELSE IF @Layer25 >0 AND LEN(@AcntCode) = @Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24+@Layer25
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24)
				END
			END
		ELSE IF @Layer24 >0 AND LEN(@AcntCode) = @Part1Len + 1 + @Layer21+@Layer22+@Layer23+@Layer24
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + 1 + @Layer21+@Layer22+@Layer23)
				END
			END
		ELSE IF @Layer23 >0 AND LEN(@AcntCode) = @Part1Len + 1 + @Layer21+@Layer22+@Layer23
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + 1 + @Layer21+@Layer22)
				END
			END
		ELSE IF @Layer22 >0 AND LEN(@AcntCode) = @Part1Len + 1 + @Layer21+@Layer22
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len + 1 + @Layer21)
				END
			END
		ELSE IF @Layer21 >0 AND LEN(@AcntCode) = @Part1Len + 1 +  @Layer21
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Part1Len )
				END
			END		
	END
	ELSE IF @Part1Len > 0 AND LEN(@AcntCode)>0
	BEGIN
		IF @Layer19 >0 AND LEN(@AcntCode) = @Layer11+@Layer12+@Layer13+@Layer14+@Layer15+@Layer16+@Layer17+@Layer18+@Layer19
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1, @Layer11+@Layer12+@Layer13+@Layer14+@Layer15+@Layer16+@Layer17+@Layer18)
				END
			END
		ELSE IF @Layer18 >0 AND LEN(@AcntCode) = @Layer11+@Layer12+@Layer13+@Layer14+@Layer15+@Layer16+@Layer17+@Layer18
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1, @Layer11+@Layer12+@Layer13+@Layer14+@Layer15+@Layer16+@Layer17)
				END
			END
		ELSE IF @Layer17 >0 AND LEN(@AcntCode) = @Layer11+@Layer12+@Layer13+@Layer14+@Layer15+@Layer16+@Layer17
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1, @Layer11+@Layer12+@Layer13+@Layer14+@Layer15+@Layer16)
				END
			END
		ELSE IF @Layer16 >0 AND LEN(@AcntCode) = @Layer11+@Layer12+@Layer13+@Layer14+@Layer15+@Layer16
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1, @Layer11+@Layer12+@Layer13+@Layer14+@Layer15)
				END
			END
		ELSE IF @Layer15 >0 AND LEN(@AcntCode) = @Layer11+@Layer12+@Layer13+@Layer14+@Layer15
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1, @Layer11+@Layer12+@Layer13+@Layer14)
				END
			END
		ELSE IF @Layer14 >0 AND LEN(@AcntCode) = @Layer11+@Layer12+@Layer13+@Layer14
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Layer11+@Layer12+@Layer13)
				END
			END
		ELSE IF @Layer13 >0 AND LEN(@AcntCode) = @Layer11+@Layer12+@Layer13
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1, @Layer11+@Layer12)
				END
			END
		ELSE IF @Layer12 >0 AND LEN(@AcntCode) = @Layer11+@Layer12
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode = substring(@AcntCode,1,@Layer11)
				END
			END
		ELSE IF @Layer11 >0 AND LEN(@AcntCode) = @Layer11
			BEGIN 
				SELECT @VisitorAcntCode=VD.VisitorAcntCode ,@VisitorPercent=VisitorPursant
				FROM sal.tblVisitorsCustomersDtl VD
				INNER JOIN sal.tblVisitorsCustomersHdr VH
				ON VD.VisitorAcntCode=VH.VisitorAcntCode
				WHERE (@Date='' OR (FromDate<=@Date AND ToDate >=@Date)) AND CustomerAcntCode = @AcntCode
				IF @VisitorAcntCode IS Not null
				BEGIN
					SELECT @VisitorAcntCode AS VisitorAcntCode,@VisitorPercent AS VisitorPercent
					BREAK 
				END
				ELSE
				BEGIN
					SELECT @AcntCode =''
					BREAK
				END
			END		
		ELSE 
			SELECT '' VisitorAcntCode ,0 VisitorPercent 
			BREAK
	END
END

END
GO
