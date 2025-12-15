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
Create FUNCTION pub.funDec2Bin
(
	@Input int
)
RETURNS VarChar(100)
WITH ENCRYPTION
AS

BEGIN

declare @Output varchar (100)=''
 

while @Input>0
begin
	select @Output =@Output+CAST((@Input%2)as varchar)
	set @Input=@Input/2

end



	Return reverse(@Output);
END
GO
