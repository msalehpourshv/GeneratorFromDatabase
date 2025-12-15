USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 
		CREATE FUNCTION [pub].[GetCodeName](@StrCode VarChar(20), @LanguageID AS TinyInt) 
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
				SET @ReturnValue = ''
							
				SELECT @AcntNameFromPart1 = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = 'AcntNameFromPart1'

				SELECT @AcntNameFromPart2 = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = 'AcntNameFromPart2'
				
				SELECT @AcntNameFromPart3 = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = 'AcntNameFromPart3'
				
				SELECT @AcntNameFromPart4 = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = 'AcntNameFromPart4'
				

				IF @AcntNameFromPart1 = 'True' AND LEN(@StrCode) >= 5
				  BEGIN 
						Select	@ReturnValue = AcntName 
						From acc.tblAcntDtl 
						Where	PartNumber = 1 AND AcntCode = Substring(@StrCode, 1, 5) AND LanguageID = @LanguageID 
				  End
				  
				IF @AcntNameFromPart2 = 'True'  AND LEN(@StrCode)>=13
				  BEGIN 
					  if @ReturnValue <>''
							SET @ReturnValue = @ReturnValue + '->'
							
						Select	@ReturnValue = @ReturnValue + AcntName 
						From acc.tblAcntDtl 
						Where	PartNumber = 2 AND AcntCode = Substring(@StrCode, 7, 7) AND LanguageID = @LanguageID 
				  END 
				  
				IF @AcntNameFromPart3 = 'True' AND LEN(@StrCode)>=17
				  BEGIN 
				  		if @ReturnValue <>''
							SET @ReturnValue = @ReturnValue + '->'
							
						Select	@ReturnValue = @ReturnValue + AcntName 
						From acc.tblAcntDtl 
						Where	PartNumber = 3 AND AcntCode = Substring(@StrCode, 15, 3) AND LanguageID = @LanguageID 
				  END 
				  
				IF @AcntNameFromPart4 = 'True' AND LEN(@StrCode)>=20 -- Part 4
				  BEGIN 
				  		if @ReturnValue <>''
							SET @ReturnValue = @ReturnValue + '->'
						Select	@ReturnValue = @ReturnValue  + AcntName 
						From acc.tblAcntDtl 
						Where	PartNumber = 4 AND AcntCode = Substring(@StrCode, 19, 2) AND LanguageID = @LanguageID 
				End 	
					
				IF @ReturnValue IS NULL OR @ReturnValue = '' 
					BEGIN
						IF @intLen <= 5 
						  BEGIN 
							Select @ReturnValue = AcntName 
							From acc.tblAcntDtl 
							Where PartNumber = 1 AND AcntCode = Substring(@StrCode, 1, 5) AND LanguageID = @LanguageID 
						  END
						  
						ELSE IF @intLen <= 13 
						  BEGIN 
							Select @ReturnValue = AcntName 
							From acc.tblAcntDtl 
							Where PartNumber = 2 AND AcntCode = Substring(@StrCode, 7, 7) AND LanguageID = @LanguageID 
						  END 
						  
						ELSE IF @intLen <= 17 
						  BEGIN 
							Select	@ReturnValue = AcntName 
							From acc.tblAcntDtl 
							Where PartNumber = 3 AND AcntCode = Substring(@StrCode, 15, 3) AND LanguageID = @LanguageID 
						  END
						   
						ELSE -- Part 4
						  BEGIN 
							Select	@ReturnValue = AcntName 
							From acc.tblAcntDtl 
							Where	PartNumber = 4 AND AcntCode = Substring(@StrCode, 19, 2) AND LanguageID = @LanguageID 
						End 
					END
               
   			Return @ReturnValue; 
           End 
GO
