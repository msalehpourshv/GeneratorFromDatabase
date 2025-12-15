USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetCodeDesc]
(
	@strCode [varchar](20)
)
RETURNS  NVarChar(50) 
WITH ENCRYPTION
AS

BEGIN

DECLARE @str_Acnt1layerSum tinyint,
        @str_Acnt2layerSum tinyint,
        @str_Acnt3layerSum tinyint,
        @str_Acnt4layerSum tinyint,
        @intCurrent tinyint,
        @strCodeDesc NVarChar(50)

select @str_Acnt1layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2) 
from pub.tblCodeLayer 
where PartNumber = 1 AND TableName='acc.tblAcnt'

select @str_Acnt2layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2)
from pub.tblCodeLayer 
where PartNumber = 2 AND TableName= 'acc.tblAcnt'

select @str_Acnt3layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2)
from pub.tblCodeLayer 
where PartNumber = 3 AND TableName='acc.tblAcnt'

select @str_Acnt4layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2)
from pub.tblCodeLayer 
where PartNumber = 4 AND TableName='acc.tblAcnt'

if len(@strCode) <= @str_Acnt1layerSum
begin
   select @strCodeDesc = AcntComment 
   from   acc.tblAcntDtl 
   where  AcntCode = @strCode
end

else if len(@strCode) <= @str_Acnt1layerSum + @str_Acnt2layerSum + 1
begin

   SET @intCurrent = @str_Acnt1layerSum + 2

   select @strCodeDesc = AcntComment 
   from   acc.tblAcntDtl 
   where  AcntCode = substring(@strCode, @intCurrent, @str_Acnt2layerSum)
end 

else if len(@strCode) <= @str_Acnt1layerSum + @str_Acnt2layerSum + @str_Acnt3layerSum + 2
begin

   SET @intCurrent = @str_Acnt1layerSum + @str_Acnt2layerSum + 3

   select @strCodeDesc = AcntComment 
   from   acc.tblAcntDtl 
   where  AcntCode = substring(@strCode, @intCurrent, @str_Acnt3layerSum)
end

else if len(@strCode) <= @str_Acnt1layerSum + @str_Acnt2layerSum + @str_Acnt3layerSum + @str_Acnt4layerSum + 3
begin

   SET @intCurrent = @str_Acnt1layerSum + @str_Acnt2layerSum + @str_Acnt3layerSum + 4

   select @strCodeDesc = AcntComment 
   from   acc.tblAcntDtl 
   where  AcntCode = substring(@strCode, @intCurrent, @str_Acnt4layerSum)
end

return @strCodeDesc

END






GO
