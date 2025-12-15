USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[funMerg_AcntCode]
(
	@S	VARCHAR(30), 
	@Acnt2	VARCHAR(30), 
	@Acnt3	VARCHAR(30), 
	@Acnt4	VARCHAR(30)
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	IF @Acnt2 IS NULL
		SET @Acnt2 = ''

	IF @Acnt3 IS NULL
		SET @Acnt3 = ''

	IF @Acnt4 IS NULL
		SET @Acnt4 = ''

	IF LTRIM(@S) = ''
		RETURN ''
	DECLARE @T	VARCHAR(30) 
	DECLARE @Layer1Len INT
	DECLARE @Layer2Len INT
	DECLARE @Layer3Len INT
	DECLARE @Layer4Len INT
	
	SEt @Layer1Len = 0
	SEt @Layer2Len = 0
	SEt @Layer3Len = 0
	SEt @Layer4Len = 0
	
	SELECT @Layer1Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9 	from pub.tblCodeLayer WHERE TableName='acc.tblAcnt' AND PartNumber=1
	SELECT @Layer2Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9 	from pub.tblCodeLayer WHERE TableName='acc.tblAcnt' AND PartNumber=2
	SELECT @Layer3Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9 	from pub.tblCodeLayer WHERE TableName='acc.tblAcnt' AND PartNumber=3
	SELECT @Layer4Len = Layer1+ Layer2+ Layer3+ Layer4+ Layer5+ Layer6+ Layer7+ Layer8+ Layer9 	from pub.tblCodeLayer WHERE TableName='acc.tblAcnt' AND PartNumber=4

	SEt @T = SUBSTRING(@S,1,@Layer1Len)
	
	IF 	@Layer2Len > 0 
	BEGIN
		
		IF @Acnt2 =''
			IF LEN(@S)>=@Layer1Len + 2
				SET @T = @T + ' ' + SUBSTRING(@S,@Layer1Len + 2,@Layer2Len)
			ELSE
				SET @T = @T + ' ' + pub.funPadLeft('',' ',@Layer2Len)
		ELSE
			SET @T = @T + ' ' + @Acnt2
		
		IF 	@Layer3Len > 0 
		BEGIN
			IF @Acnt3 =''
				IF LEN(@S)>=@Layer1Len + @Layer2Len + 3
					SET @T = @T + ' ' + SUBSTRING(@S,@Layer1Len +@Layer2Len + 3,@Layer3Len)
				ELSE
					SET @T = @T + ' ' + pub.funPadLeft('',' ',@Layer3Len)
			ELSE
				SET @T = @T + ' ' + @Acnt3

			IF 	@Layer4Len > 0 
			BEGIN
				IF @Acnt4 =''
					IF LEN(@S)>=@Layer1Len + @Layer2Len + @Layer3Len + 4
						SET @T = @T + ' ' + SUBSTRING(@S,@Layer1Len +@Layer2Len+@Layer3Len  + 4,@Layer4Len)
					ELSE
						SET @T = @T + ' ' + pub.funPadLeft('',' ',@Layer4Len)
				ELSE
					SET @T = @T + ' ' + @Acnt4
			END				
		END
	END
			
	RETURN RTRIM(@T)
END
GO
