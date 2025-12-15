USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [pub].[funGetCustomerKindID](@StrAcntCode VarChar(20))

RETURNS  VarChar(20) 

WITH ENCRYPTION
AS 

BEGIN 
              
		Declare @Layer1 AS TinyInt 
		Declare @Layer2 AS TinyInt 
		Declare @Layer3 AS TinyInt 
		Declare @Layer4 AS TinyInt 
		Declare @StrAcntCode1 AS VarChar(20) 
   
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
   
              
				Declare @ReturnValue AS VarChar(20) 
				Declare @intLen	AS Int 
				Declare @NamePartNo AS Tinyint
				
				Set @intLen = Len(@StrAcntCode) 
				Set @NamePartNo = 0
                Set @ReturnValue = ''
				---------------------------------
				SELECT @NamePartNo = SettingValue
				FROM pub.tblSettings
				WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
			
				IF @NamePartNo > 0
					BEGIN
						IF @NamePartNo = 1
						  BEGIN 
								Select	 TOP 1 @ReturnValue = CustomerKindID
								From acc.tblAcnt 
								Where	PartNumber = 1 AND AcntCode = Substring(@StrAcntCode, 1, @Layer1) 
						  End
						ELSE IF @NamePartNo = 2 
						  BEGIN 
								Select	@ReturnValue = CustomerKindID 
								From acc.tblAcnt 
								Where	PartNumber = 2 AND AcntCode = Substring(@StrAcntCode,   @Layer1 + 2 ,@Layer2 - @Layer1 - 1) 
						  END 
						ELSE IF @NamePartNo = 3 
						  BEGIN 
								Select	@ReturnValue = CustomerKindID 
								From acc.tblAcnt 
								Where	PartNumber = 3 AND AcntCode = Substring(@StrAcntCode,   @Layer2 + 2  , @Layer3 - @Layer2 - 1) 
						  END 
						ELSE -- Part 4
						  BEGIN 
								Select	@ReturnValue = CustomerKindID 
								From acc.tblAcnt 
								Where	PartNumber = 4 AND AcntCode = Substring(@StrAcntCode,   @Layer3 + 2 ,@Layer4 - @Layer3 - 1) 
						End 					
					END

				
				IF @ReturnValue = ''
					BEGIN
						IF @intLen <=   @Layer1   
						  BEGIN 
								Select	@ReturnValue = CustomerKindID 
							  From acc.tblAcnt 
								Where	PartNumber = 1 AND AcntCode = @StrAcntCode 
						  End
						ELSE IF @intLen <=   @Layer2   
						  BEGIN 
								Select	@ReturnValue = CustomerKindID 
							  From acc.tblAcnt 
								Where	PartNumber = 2 AND AcntCode = Substring(@StrAcntCode,   @Layer1 + 2,@Layer2 - @Layer1 - 1) 
						  END 
						ELSE IF @intLen <=   @Layer3   
						  BEGIN 
								Select	@ReturnValue = CustomerKindID 
							  From acc.tblAcnt 
								Where	PartNumber = 3 AND AcntCode = Substring(@StrAcntCode,   @Layer2 + 2,@Layer3 - @Layer2 - 1) 
						  END 
						ELSE -- Part 4
						  BEGIN 
								Select	@ReturnValue = CustomerKindID 
							  From acc.tblAcnt 
								Where	PartNumber = 4 AND AcntCode = Substring(@StrAcntCode,   @Layer3 + 2,@Layer4 - @Layer3 - 1) 
						End 
					END
               
   			Return @ReturnValue; 

End
GO
