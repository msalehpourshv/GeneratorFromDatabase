USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--Select [sal].[GetTransporterNameAry] ('12')
CREATE FUNCTION [sal].[GetTransporterNameAry]
	(
		@StrCode VarChar(30)
	) RETURNS NVARCHAR(500)
	
	WITH EXECUTE AS CALLER , ENCRYPTION
	AS
	BEGIN

	DECLARE @str_Acnt1layerSum tinyint,
			@StrCodeName NVarChar(500),
			@str_Acnt1layerLen varchar(20),
			@intLevel int, 
			@S VARCHAR(3)
	        
	SET @StrCodeName = ''
	Select @str_Acnt1layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2) ,
		   @str_Acnt1layerLen = str(0,2)+ 
								str(Layer1,2)+ 
								str(Layer1+Layer2,2)+
								str(Layer1+Layer2+Layer3,2)+ 
								str(Layer1+Layer2+Layer3+Layer4,2)+
								str(Layer1+Layer2+Layer3+Layer4+Layer5,2)+ 
								str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6,2)+ 
								str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7,2)+
								str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8,2)+ 
								str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9,2) 
	From pub.tblCodeLayer 
	Where TableName = 'sal.tblTransporters' AND PartNumber=1
							   -- PRINT @str_Acnt1layerLen

	set @intLevel=1
	   while @intLevel<10
		 begin
			 if LEN(RTRIM(substring(@StrCode,1,convert(int,ltrim(substring(@str_Acnt1layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Acnt1layerLen,((@intLevel-1)*2)+1,2) AND 
				convert(int,ltrim(substring(@str_Acnt1layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Acnt1layerLen,((@intLevel-1)*2)+1,2)))
				  BEGIN
	             
				  SET @S = ''
	              
				  IF @intLevel>1
					SET  @S =  ' > '
					
					 SELECT @StrCodeName = @StrCodeName +  @S + TransporterName 
					 FROM sal.tblTransportersDtl
					 WHERE TransporterID = substring(@StrCode,1,convert(int,ltrim(substring(@str_Acnt1layerLen,(@intLevel*2)+1,2)))) 
				  END
			 SET @intLevel= @intLevel + 1
		end

	RETURN @StrCodeName

END
GO
