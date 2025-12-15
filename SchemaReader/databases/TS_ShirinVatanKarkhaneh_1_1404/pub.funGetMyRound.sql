USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1401-01-20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : روند کردن اعداد که در ضرب اعشاری  نمایی نشان میدهد   مانند  0/00004*.01 
-- ==============================================
Create FUNCTION pub.funGetMyRound
(
@Dec1 VarChar(20) 
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

BEGIN
declare @s char(1) 
declare @i int 
declare @j int 
declare @f int 
declare @Dec2 VarChar(20) 

select @i =len(@Dec1)
set @j=1
set @f=0

while @j<=@i
begin

	select @s =substring (@Dec1,@j,1)

  if @s='.'
	set @f=1
  if @f=0
  begin
	select @Dec2 =substring (@Dec1,1,@j)
  end 
  if @f=1
  begin
	if @s='.'
		select @Dec2 =substring (@Dec1,1,@j-1)
	else
	if @s<>'0'
		select @Dec2 =substring (@Dec1,1,@j)

  end 

  set @j=@j+1

end

  RETURN   @Dec2

	  
END
GO
