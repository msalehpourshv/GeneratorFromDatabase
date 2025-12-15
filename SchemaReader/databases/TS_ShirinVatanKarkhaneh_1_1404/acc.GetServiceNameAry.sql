USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[GetServiceNameAry]
(
@StrCode VarChar(20)
) RETURNS @tblTempservice TABLE 
						(
							[ServiceName] [NVarChar](50) COLLATE Arabic_CS_AS NULL
						) 
WITH EXECUTE AS CALLER , ENCRYPTION
AS
BEGIN

DECLARE @str_Service1layerSum tinyint,
        @str_Service2layerSum tinyint,
        @str_Service3layerSum tinyint,
        @str_Service4layerSum tinyint,
        @intCurrentservice2 tinyint,
        @intCurrentservice3 tinyint,
        @intCurrentservice4 tinyint,
        @StrCodeName NVarChar(50),
        @str_Service1layerLen varchar(20),
        @str_Service2layerLen varchar(20),
        @str_Service3layerLen varchar(20),
        @str_Service4layerLen varchar(20),
        @intPart int ,
        @intLevel int 

select @str_Service1layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2) ,
       @str_Service1layerLen = str(0,2)+ 
                            str(Layer1,2)+ 
                            str(Layer1+Layer2,2)+
                            str(Layer1+Layer2+Layer3,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9,2) 
from pub.tblCodeLayer 
where TableName='acc.tblServiceCoding' AND PartNumber=1

select @str_Service2layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Service2layerLen = str(0,2)+ 
                            str(Layer1,2)+ 
                            str(Layer1+Layer2,2)+
                            str(Layer1+Layer2+Layer3,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9,2) 
from pub.tblCodeLayer 
where TableName= 'acc.tblServiceCoding' AND PartNumber=2

select @str_Service3layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Service3layerLen = str(0,2)+ 
                            str(Layer1,2)+ 
                            str(Layer1+Layer2,2)+
                            str(Layer1+Layer2+Layer3,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9,2) 
from pub.tblCodeLayer 
where TableName='acc.tblServiceCoding' AND PartNumber=3

select @str_Service4layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Service4layerLen = str(0,2)+ 
                            str(Layer1,2)+ 
                            str(Layer1+Layer2,2)+
                            str(Layer1+Layer2+Layer3,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9,2) 
from pub.tblCodeLayer 
where TableName='acc.tblServiceCoding' AND PartNumber=4


set @intPart  = 1

SET @intCurrentservice2 = @str_Service1layerSum + 2
SET @intCurrentservice3 = @str_Service1layerSum + @str_Service2layerSum + 3
SET @intCurrentservice4 = @str_Service1layerSum + @str_Service2layerSum + @str_Service3layerSum + 4

while @intPart<5
begin
set @intLevel=1
   while @intLevel<10
     begin
       if @intPart=1
         begin
           if  LEN(RTRIM(substring(@StrCode,1,convert(int,ltrim(substring(@str_Service1layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Service1layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Service1layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Service1layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=ServiceName 
                 FROM acc.tblServiceCodingDtl
                 WHERE ServiceID=substring(@StrCode,1,convert(int,ltrim(substring(@str_Service1layerLen,(@intLevel*2)+1,2)))) 
				   AND PartNumber=1
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=2
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentservice2,convert(int,ltrim(substring(@str_Service2layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Service2layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Service2layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Service2layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=ServiceName
                 FROM acc.tblServiceCodingDtl 
                 WHERE ServiceID=substring(@StrCode,@intCurrentservice2,convert(int,ltrim(substring(@str_Service2layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=2
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=3
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentservice3,convert(int,ltrim(substring(@str_Service3layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Service3layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Service3layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Service3layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=ServiceName 
                 FROM acc.tblServiceCodingDtl 
                 WHERE ServiceID=substring(@StrCode,@intCurrentservice3,convert(int,ltrim(substring(@str_Service3layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=3
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=4
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentservice4,convert(int,ltrim(substring(@str_Service4layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Service4layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Service4layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Service4layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=ServiceName 
                 FROM acc.tblServiceCodingDtl
                 WHERE ServiceID=substring(@StrCode,@intCurrentservice4,convert(int,ltrim(substring(@str_Service4layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=4
              end
           else
              begin
                 set @StrCodeName=''
              end
         end

        INSERT INTO @tblTempservice values ( @StrCodeName )
        set @intLevel=@intLevel+1
     end
   set @intPart=@intPart+1
end
RETURN  

END



















GO
