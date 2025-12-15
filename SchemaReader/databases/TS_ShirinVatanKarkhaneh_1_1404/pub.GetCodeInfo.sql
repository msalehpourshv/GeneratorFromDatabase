USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetCodeInfo]
(
	@StrCode VarChar(20), 
	@StrFieldList Char(3), 
	----------------------------
	-- 100 = Name  (bit 1)    --
	-- 010 = Desc  (bit 2)    --
	-- 001 = Addr  (bit 3)    --
	----------------------------
	@StrDelimiter Char(1) 
)
	RETURNS  NVarChar(50) 
WITH ENCRYPTION
AS

BEGIN

Declare @str_Acnt1layerSum TinyInt
Declare @str_Acnt2layerSum TinyInt
Declare @str_Acnt3layerSum TinyInt
Declare @str_Acnt4layerSum TinyInt
Declare @intCurrent TinyInt
Declare @StrCodeInfo NVarChar(50)

Declare @MergeName Bit 
Declare @MergeDesc Bit 

Set @MergeName = Cast(Substring(@StrFieldList, 1, 1) AS TinyInt)
Set @MergeDesc = Cast(Substring(@StrFieldList, 2, 1) AS TinyInt)

Select @str_Acnt1layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2) 
From pub.tblCodeLayer 
Where PartNumber = 1 AND TableName='acc.tblAcnt'

Select @str_Acnt2layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2)
From pub.tblCodeLayer 
Where PartNumber = 2 AND TableName= 'acc.tblAcnt'

Select @str_Acnt3layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2)
From pub.tblCodeLayer 
Where PartNumber = 3 AND TableName='acc.tblAcnt'

Select @str_Acnt4layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2)
From pub.tblCodeLayer 
Where PartNumber = 4 AND TableName='acc.tblAcnt'

if len(@StrCode) <= @str_Acnt1layerSum
begin
   Select @StrCodeInfo = 
			 Case When (@MergeName = 1) Then (AcntName + @StrDelimiter) Else '' End + 
			 Case When (@MergeDesc = 1) Then (AcntComment + @StrDelimiter) Else '' End
   From   acc.tblAcntDtl 
   Where  AcntCode = @StrCode
end

else if len(@StrCode) <= @str_Acnt1layerSum + @str_Acnt2layerSum + 1
begin

   SET @intCurrent = @str_Acnt1layerSum + 2

   Select @StrCodeInfo = 
			 Case When (@MergeName = 1) Then (AcntName + @StrDelimiter) Else '' End + 
			 Case When (@MergeDesc = 1) Then (AcntComment + @StrDelimiter) Else '' End
   From   acc.tblAcntDtl 
   Where  AcntCode = substring(@StrCode, @intCurrent, @str_Acnt2layerSum)
end 

else if len(@StrCode) <= @str_Acnt1layerSum + @str_Acnt2layerSum + @str_Acnt3layerSum + 2
begin

   SET @intCurrent = @str_Acnt1layerSum + @str_Acnt2layerSum + 3

   Select @StrCodeInfo = 
			 Case When (@MergeName = 1) Then (AcntName + @StrDelimiter) Else '' End + 
			 Case When (@MergeDesc = 1) Then (AcntComment + @StrDelimiter) Else '' End
   From   acc.tblAcntDtl 
   Where  AcntCode = substring(@StrCode, @intCurrent, @str_Acnt3layerSum)
end

else if len(@StrCode) <= @str_Acnt1layerSum + @str_Acnt2layerSum + @str_Acnt3layerSum + @str_Acnt4layerSum + 3
begin

   SET @intCurrent = @str_Acnt1layerSum + @str_Acnt2layerSum + @str_Acnt3layerSum + 4

   Select @StrCodeInfo = 
			 Case When (@MergeName = 1) Then (AcntName + @StrDelimiter) Else '' End + 
			 Case When (@MergeDesc = 1) Then (AcntComment + @StrDelimiter) Else '' End
   From   acc.tblAcntDtl 
   Where  AcntCode = substring(@StrCode, @intCurrent, @str_Acnt4layerSum)
end

Return @StrCodeInfo

END









GO
