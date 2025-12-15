USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetGoodsNameAry]
(
@StrCode VarChar(20)
) RETURNS @tblTempGoods TABLE 
						(
							[GoodsName] [NVarChar](50) COLLATE Arabic_CS_AS NULL
						) 
WITH EXECUTE AS CALLER , ENCRYPTION
AS
BEGIN

DECLARE @str_Goods1layerSum tinyint,
        @str_Goods2layerSum tinyint,
        @str_Goods3layerSum tinyint,
        @str_Goods4layerSum tinyint,
        @str_Goods5layerSum tinyint,
        @intCurrentGoods2 tinyint,
        @intCurrentGoods3 tinyint,
        @intCurrentGoods4 tinyint,
        @intCurrentGoods5 tinyint,
        @StrCodeName NVarChar(50),
        @str_Goods1layerLen varchar(20),
        @str_Goods2layerLen varchar(20),
        @str_Goods3layerLen varchar(20),
        @str_Goods4layerLen varchar(20),
        @str_Goods5layerLen varchar(20),
        @intPart int ,
        @intLevel int 

select @str_Goods1layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2) ,
       @str_Goods1layerLen = str(0,2)+ 
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
where TableName='inv.tblGoods' AND PartNumber=1

select @str_Goods2layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Goods2layerLen = str(0,2)+ 
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
where TableName= 'inv.tblGoods' AND PartNumber=2

select @str_Goods3layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Goods3layerLen = str(0,2)+ 
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
where TableName='inv.tblGoods' AND PartNumber=3

select @str_Goods4layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Goods4layerLen = str(0,2)+ 
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
where TableName='inv.tblGoods' AND PartNumber=4


select @str_Goods5layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Goods5layerLen = str(0,2)+ 
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
where TableName='inv.tblGoods' AND PartNumber=5

set @intPart  = 1

SET @intCurrentGoods2 = @str_Goods1layerSum + 1
SET @intCurrentGoods3 = @str_Goods1layerSum + @str_Goods2layerSum + 1
SET @intCurrentGoods4 = @str_Goods1layerSum + @str_Goods2layerSum + @str_Goods3layerSum + 1
SET @intCurrentGoods5 = @str_Goods1layerSum + @str_Goods2layerSum + @str_Goods3layerSum + @str_Goods4layerSum + 1

while @intPart<6
begin
set @intLevel=1
   while @intLevel<10
     begin
       if @intPart=1
         begin
           if  LEN(RTRIM(substring(@StrCode,1,convert(int,ltrim(substring(@str_Goods1layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Goods1layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Goods1layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Goods1layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=GoodsName 
                 FROM inv.tblGoodsDtl
                 WHERE GoodsID=substring(@StrCode,1,convert(int,ltrim(substring(@str_Goods1layerLen,(@intLevel*2)+1,2)))) 
				   AND PartNumber=1
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=2
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentGoods2,convert(int,ltrim(substring(@str_Goods2layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Goods2layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Goods2layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Goods2layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=GoodsName
                 FROM inv.tblGoodsDtl 
                 WHERE GoodsID=substring(@StrCode,@intCurrentGoods2,convert(int,ltrim(substring(@str_Goods2layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=2
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=3
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentGoods3,convert(int,ltrim(substring(@str_Goods3layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Goods3layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Goods3layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Goods3layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=GoodsName 
                 FROM inv.tblGoodsDtl 
                 WHERE GoodsID=substring(@StrCode,@intCurrentGoods3,convert(int,ltrim(substring(@str_Goods3layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=3
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=4
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentGoods4,convert(int,ltrim(substring(@str_Goods4layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Goods4layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Goods4layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Goods4layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=GoodsName 
                 FROM inv.tblGoodsDtl
                 WHERE GoodsID=substring(@StrCode,@intCurrentGoods4,convert(int,ltrim(substring(@str_Goods4layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=4
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=5
         begin
           if LEN(RTRIM(substring(@StrCode,@intCurrentGoods5,convert(int,ltrim(substring(@str_Goods5layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Goods5layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Goods5layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Goods5layerLen,((@intLevel-1)*2)+1,2)))
              begin
                 SELECT @StrCodeName=GoodsName 
                 FROM inv.tblGoodsDtl
                 WHERE GoodsID=substring(@StrCode,@intCurrentGoods5,convert(int,ltrim(substring(@str_Goods5layerLen,(@intLevel*2)+1,2))))
				   AND PartNumber=5
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
        INSERT INTO @tblTempGoods values ( @StrCodeName )
        set @intLevel=@intLevel+1
     end
   set @intPart=@intPart+1
end
RETURN  

END



















GO
