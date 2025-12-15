USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ahmadnejad
-- Create Date: 1386/06/04	(03-11-2007)
-- Description: CREATE GetCodeName Function
-- =============================================
CREATE TRIGGER [pub].[trgAlterGetCodeName] 
   ON  [pub].[tblCodeLayer] 
 
   WITH ENCRYPTION
   AFTER INSERT, UPDATE 
AS 
BEGIN 
 
	SET NOCOUNT ON; 
   
	IF	(SELECT COUNT(*) FROM inserted WHERE TableName = 'acc.tblAcnt') = 0 and 
		(SELECT COUNT(*) FROM deleted WHERE TableName = 'acc.tblAcnt' ) = 0 
       Return
   
	Declare @StrSQL AS NVarChar(4000)
   
	Declare @Layer1 AS TinyInt 
	Declare @Layer2 AS TinyInt 
	Declare @Layer3 AS TinyInt 
	Declare @Layer4 AS TinyInt 
   
	Select  @Layer1 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 +  Layer9 
   From    pub.tblCodeLayer 
	Where	PartNumber = 1 AND TableName = 'acc.tblAcnt'
   
 	IF @Layer1 Is Null 
		Set @Layer1 = 0 
   
	Select	@Layer2 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 +  Layer9 
    From    pub.tblCodeLayer 
	Where	PartNumber = 2 AND TableName = 'acc.tblAcnt' 
   
	IF @Layer2 Is Not Null 
		Set @Layer2 = @Layer2 + @Layer1 + 1 
    Else
		Set @Layer2 = @Layer1 + 1 
   
	Select	@Layer3 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 +  Layer9 
    From    pub.tblCodeLayer 
	Where	PartNumber = 3 AND TableName = 'acc.tblAcnt'
   
	IF @Layer3 Is Not Null 
		Set @Layer3 = @Layer3 + @Layer2 + 1 
    Else 
		Set @Layer3 = @Layer2 + 1 
   
	Select	@Layer4 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 +  Layer9 
    From pub.tblCodeLayer 
	Where	PartNumber = 4 AND TableName = 'acc.tblAcnt'
   
	IF @Layer4 Is Not Null 
		Set @Layer4 = @Layer4 + @Layer3 + 1 
    Else 
		Set @Layer4 = @Layer3 + 1 
   
	Set @StrSQL = N' 
		ALTER FUNCTION [pub].[GetCodeName](@StrCode VarChar(20), @LanguageID AS TinyInt) 
		RETURNS  NVarChar(200) 
		WITH ENCRYPTION
		AS 
           BEGIN 
			--	SET @LanguageID = pub.funGetCurrentLanguageID() 
				IF @LanguageID = 0
					SET @LanguageID = 1

				Declare @ReturnValue AS NVarChar(200) 
				Declare @intLen	AS Int 
				Declare @AcntNameFromPart1 AS BIT
				Declare @AcntNameFromPart2 AS BIT
				Declare @AcntNameFromPart3 AS BIT
				Declare @AcntNameFromPart4 AS BIT	
				
				Set @intLen = Len(@StrCode) 
				SET @ReturnValue = ''''
							
				SELECT @AcntNameFromPart1 = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = ''AcntNameFromPart1''

				SELECT @AcntNameFromPart2 = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = ''AcntNameFromPart2''
				
				SELECT @AcntNameFromPart3 = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = ''AcntNameFromPart3''
				
				SELECT @AcntNameFromPart4 = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = ''AcntNameFromPart4''
				

				IF @AcntNameFromPart1 = ''True'' AND LEN(@StrCode) >= ' + LTrim(Str(@Layer1))  + '
				  BEGIN 
						Select	@ReturnValue = AcntName 
						From acc.tblAcntDtl 
						Where	PartNumber = 1 AND AcntCode = Substring(@StrCode, 1, ' + 
								LTrim(Str(@Layer1)) + ') AND LanguageID = @LanguageID 
				  End
				  
				IF @AcntNameFromPart2 = ''True''  AND LEN(@StrCode)>=' + LTrim(Str(@Layer2))  + '
				  BEGIN 
					  if @ReturnValue <>''''
							SET @ReturnValue = @ReturnValue + ''->''
							
						Select	@ReturnValue = @ReturnValue + AcntName 
						From acc.tblAcntDtl 
						Where	PartNumber = 2 AND AcntCode = Substring(@StrCode, ' + LTrim(Str(@Layer1 + 2)) + ', ' + 
								LTrim(Str(@Layer2 - @Layer1 - 1)) + ') AND LanguageID = @LanguageID 
				  END 
				  
				IF @AcntNameFromPart3 = ''True'' AND LEN(@StrCode)>=' + LTrim(Str(@Layer3))  + '
				  BEGIN 
				  		if @ReturnValue <>''''
							SET @ReturnValue = @ReturnValue + ''->''
							
						Select	@ReturnValue = @ReturnValue + AcntName 
						From acc.tblAcntDtl 
						Where	PartNumber = 3 AND AcntCode = Substring(@StrCode, ' + LTrim(Str(@Layer2 + 2)) + ', ' + 
								LTrim(Str(@Layer3 - @Layer2 - 1)) + ') AND LanguageID = @LanguageID 
				  END 
				  
				IF @AcntNameFromPart4 = ''True'' AND LEN(@StrCode)>=' + LTrim(Str(@Layer4))  + ' -- Part 4
				  BEGIN 
				  		if @ReturnValue <>''''
							SET @ReturnValue = @ReturnValue + ''->''
						Select	@ReturnValue = @ReturnValue  + AcntName 
						From acc.tblAcntDtl 
						Where	PartNumber = 4 AND AcntCode = Substring(@StrCode, ' + LTrim(Str(@Layer3 + 2)) + ', ' + 
								LTrim(Str(@Layer4 - @Layer3 - 1)) + ') AND LanguageID = @LanguageID 
				End 	
					
				IF @ReturnValue IS NULL OR @ReturnValue = '''' 
					BEGIN
						IF @intLen <= ' + LTrim(Str(@Layer1)) + ' 
						  BEGIN 
							Select @ReturnValue = AcntName 
							From acc.tblAcntDtl 
							Where PartNumber = 1 AND AcntCode = Substring(@StrCode, 1, ' + 
								LTrim(Str(@Layer1)) + ') AND LanguageID = @LanguageID 
						  END
						  
						ELSE IF @intLen <= ' + LTrim(Str(@Layer2)) + ' 
						  BEGIN 
							Select @ReturnValue = AcntName 
							From acc.tblAcntDtl 
							Where PartNumber = 2 AND AcntCode = Substring(@StrCode, ' + LTrim(Str(@Layer1 + 2)) + ', ' + 
								LTrim(Str(@Layer2 - @Layer1 - 1)) + ') AND LanguageID = @LanguageID 
						  END 
						  
						ELSE IF @intLen <= ' + LTrim(Str(@Layer3)) + ' 
						  BEGIN 
							Select	@ReturnValue = AcntName 
							From acc.tblAcntDtl 
							Where PartNumber = 3 AND AcntCode = Substring(@StrCode, ' + LTrim(Str(@Layer2 + 2)) + ', ' + 
								LTrim(Str(@Layer3 - @Layer2 - 1)) + ') AND LanguageID = @LanguageID 
						  END
						   
						ELSE -- Part 4
						  BEGIN 
							Select	@ReturnValue = AcntName 
							From acc.tblAcntDtl 
							Where	PartNumber = 4 AND AcntCode = Substring(@StrCode, ' + LTrim(Str(@Layer3 + 2)) + ', ' + 
								LTrim(Str(@Layer4 - @Layer3 - 1)) + ') AND LanguageID = @LanguageID 
						End 
					END
               
   			Return @ReturnValue; 
           End '
           
	Exec sp_executesql @StrSQL;
   
End
GO
