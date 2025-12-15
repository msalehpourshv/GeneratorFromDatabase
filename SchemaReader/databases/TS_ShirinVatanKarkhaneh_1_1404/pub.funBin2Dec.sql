USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1399/03/13
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ===============================================
Create FUNCTION pub.funBin2Dec
(
	@Input VarChar(100)
)
RETURNS int
WITH ENCRYPTION
AS

BEGIN

declare @cnt int=1
declare @len int=len(@Input)

declare @Output bigint=cast ( substring(@Input ,@len,1) as bigint)

while (@cnt<@len)
begin
	select @Output =@Output+POWER (cast ( substring(@Input ,@len-@cnt,1)*2 as bigint),@cnt)
	set @cnt=@cnt+1
end



	Return @Output;
END
GO
