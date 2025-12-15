USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [acc].[GetAcntCodeNameAry]
(
@StrCode VarChar(20)
) RETURNS @tblTempAcnt TABLE 
						(
							[AcntName] [NVarChar](200) COLLATE Arabic_CS_AS NULL
						) 
WITH EXECUTE AS CALLER , ENCRYPTION
AS
BEGIN

DECLARE @str_Acnt1layerSum tinyint,
        @str_Acnt2layerSum tinyint,
        @str_Acnt3layerSum tinyint,
        @str_Acnt4layerSum tinyint,
        @intCurrentAcnt2 tinyint,
        @intCurrentAcnt3 tinyint,
        @intCurrentAcnt4 tinyint,
        @StrCodeName NVarChar(200),
        @str_Acnt1layerLen varchar(20),
        @str_Acnt2layerLen varchar(20),
        @str_Acnt3layerLen varchar(20),
        @str_Acnt4layerLen varchar(20),
        @intPart int ,
        @intLevel int 

select @str_Acnt1layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2) ,
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
from pub.tblCodeLayer 
where TableName='acc.tblAcnt' AND PartNumber=1

select @str_Acnt2layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Acnt2layerLen = str(0,2)+ 
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
where TableName= 'acc.tblAcnt' AND PartNumber=2

select @str_Acnt3layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Acnt3layerLen = str(0,2)+ 
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
where TableName='acc.tblAcnt' AND PartNumber=3

select @str_Acnt4layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Acnt4layerLen = str(0,2)+ 
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
where TableName='acc.tblAcnt' AND PartNumber=4


set @intPart  = 1

SET @intCurrentAcnt2 = @str_Acnt1layerSum + 2
SET @intCurrentAcnt3 = @str_Acnt1layerSum + @str_Acnt2layerSum + 3
SET @intCurrentAcnt4 = @str_Acnt1layerSum + @str_Acnt2layerSum + @str_Acnt3layerSum + 4

while @intPart<5
begin
set @intLevel=1
   while @intLevel<10
     begin
       if @intPart=1
         begin
           if  LEN(RTRIM(substring(@StrCode,1,convert(int,ltrim(substring(@str_Acnt1layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Acnt1layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Acnt1layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Acnt1layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=AcntName 
                 FROM acc.tblAcntDtl 
                 WHERE AcntCode=substring(@StrCode,1,convert(int,ltrim(substring(@str_Acnt1layerLen,(@intLevel*2)+1,2)))) 
				   AND PartNumber=1
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=2
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentAcnt2,convert(int,ltrim(substring(@str_Acnt2layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Acnt2layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Acnt2layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Acnt2layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=AcntName 
                 FROM acc.tblAcntDtl 
                 WHERE AcntCode=substring(@StrCode,@intCurrentAcnt2,convert(int,ltrim(substring(@str_Acnt2layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=2
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=3
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentAcnt3,convert(int,ltrim(substring(@str_Acnt3layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Acnt3layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Acnt3layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Acnt3layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=AcntName 
                 FROM acc.tblAcntDtl 
                 WHERE AcntCode=substring(@StrCode,@intCurrentAcnt3,convert(int,ltrim(substring(@str_Acnt3layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=3
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=4
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentAcnt4,convert(int,ltrim(substring(@str_Acnt4layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Acnt4layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Acnt4layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Acnt4layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=AcntName 
                 FROM acc.tblAcntDtl 
                 WHERE AcntCode=substring(@StrCode,@intCurrentAcnt4,convert(int,ltrim(substring(@str_Acnt4layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=4
              end
           else
              begin
                 set @StrCodeName=''
              end
         end

        INSERT INTO @tblTempAcnt values ( @StrCodeName )
        set @intLevel=@intLevel+1
     end
   set @intPart=@intPart+1
end
RETURN  

END
GO
