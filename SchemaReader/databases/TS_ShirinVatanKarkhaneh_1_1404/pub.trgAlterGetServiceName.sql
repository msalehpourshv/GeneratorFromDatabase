USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Sadeghi	
-- Create Date: 91/03/03
-- Description: 
-- =============================================
CREATE TRIGGER [pub].[trgAlterGetServiceName] 
   ON  [pub].[tblCodeLayer] 
 
   WITH ENCRYPTION
   AFTER INSERT, UPDATE 
AS 
BEGIN 
 
	SET NOCOUNT ON; 
   
	IF	(SELECT COUNT(*) FROM inserted WHERE TableName = 'acc.tblServiceCoding') = 0 and 
		(SELECT COUNT(*) FROM deleted WHERE TableName = 'acc.tblServiceCoding' ) = 0 
       Return
   
	Declare @StrSQL AS NVarChar(4000)
   
	Declare @Layer1 AS TinyInt 
	Declare @Layer2 AS TinyInt 
	Declare @Layer3 AS TinyInt 
	Declare @Layer4 AS TinyInt 
   
	Select  @Layer1 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 +  Layer9 
   From    pub.tblCodeLayer 
	Where	PartNumber = 1 AND TableName = 'acc.tblServiceCoding'
   
 	IF @Layer1 Is Null 
		Set @Layer1 = 0 
   
	Select	@Layer2 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 +  Layer9 
    From    pub.tblCodeLayer 
	Where	PartNumber = 2 AND TableName = 'acc.tblServiceCoding' 
   
	IF @Layer2 Is Not Null 
		Set @Layer2 = @Layer2 + @Layer1 + 1 
    Else
		Set @Layer2 = @Layer1 + 1 
   
	Select	@Layer3 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 +  Layer9 
    From    pub.tblCodeLayer 
	Where	PartNumber = 3 AND TableName = 'acc.tblServiceCoding'
   
	IF @Layer3 Is Not Null 
		Set @Layer3 = @Layer3 + @Layer2 + 1 
    Else 
		Set @Layer3 = @Layer2 + 1 
   
	Select	@Layer4 = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 +  Layer9 
    From pub.tblCodeLayer 
	Where	PartNumber = 4 AND TableName = 'acc.tblServiceCoding'
   
	IF @Layer4 Is Not Null 
		Set @Layer4 = @Layer4 + @Layer3 + 1 
    Else 
		Set @Layer4 = @Layer3 + 1 
   
	Set @StrSQL = N' 
		ALTER FUNCTION [acc].[funGetServiceName](@StrCode VarChar(20), @LanguageID AS TinyInt) 
		RETURNS  NVarChar(50) 
		--WITH ENCRYPTION
		AS 
           BEGIN 
              
				Declare @ReturnValue AS NVarChar(50) 
				Declare @intLen	AS Int 
				
				Set @intLen = Len(@StrCode) 
				SET @ReturnValue = ''''
			
				IF @intLen <= ' + LTrim(Str(@Layer1)) + ' 
				  BEGIN 
					Select @ReturnValue = ServiceName 
					From acc.tblServiceCodingDtl 
					Where PartNumber = 1 AND ServiceID = Substring(@StrCode, 1, ' + 
						LTrim(Str(@Layer1)) + ') AND LanguageID = @LanguageID 
				  END
				  
				ELSE IF @intLen <= ' + LTrim(Str(@Layer2)) + ' 
				  BEGIN 
					Select @ReturnValue = ServiceName 
					From acc.tblServiceCodingDtl
					Where PartNumber = 2 AND ServiceID = Substring(@StrCode, ' + LTrim(Str(@Layer1 + 2)) + ', ' + 
						LTrim(Str(@Layer2 - @Layer1 - 1)) + ') AND LanguageID = @LanguageID 
				  END 
				  
				ELSE IF @intLen <= ' + LTrim(Str(@Layer3)) + ' 
				  BEGIN 
					Select	@ReturnValue = ServiceName 
					From acc.tblServiceCodingDtl
					Where PartNumber = 3 AND ServiceID = Substring(@StrCode, ' + LTrim(Str(@Layer2 + 2)) + ', ' + 
						LTrim(Str(@Layer3 - @Layer2 - 1)) + ') AND LanguageID = @LanguageID 
				  END
				   
				ELSE -- Part 4
				  BEGIN 
					Select	@ReturnValue = ServiceName 
					From acc.tblServiceCodingDtl 
					Where	PartNumber = 4 AND ServiceID = Substring(@StrCode, ' + LTrim(Str(@Layer3 + 2)) + ', ' + 
						LTrim(Str(@Layer4 - @Layer3 - 1)) + ') AND LanguageID = @LanguageID 
				End 

   			Return @ReturnValue; 
           End '
           
	Exec sp_executesql @StrSQL;
   
End
GO
