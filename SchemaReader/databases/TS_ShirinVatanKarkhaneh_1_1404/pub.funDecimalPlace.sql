USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1402/10/10
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 :  برای حل مشکل  سامانه برای جلوگیری از گرد کردن اعشار
-- ==============================================
Create FUNCTION pub.funDecimalPlace
(
	@Price 	decimal(28,10),
	@DecPlace int 	
)
returns  Varchar(20) --Decimal(28,8)
WITH ENCRYPTION
AS
Begin

declare @p1 varchar(20)  
declare @p2 varchar(20)  
	   
    set @p1 =  @Price-cast(@Price as bigint )	 
    set @p2 =  cast(@Price as bigint )

	if @p1='0'
		set @p1='0.0'
	if @p1='1'
		begin
		set @p1='1.0'
		 set @p2 =  cast(@Price as bigint )+1
		end 
	
	if len(@p1)>@DecPlace +2
		set @p1=substring (@p1,1,@DecPlace+2) 

   while len(@p1)<@DecPlace+2
	   set @p1+='0'

	if @DecPlace=0
		return @p2
   return  @p2+Substring(@p1,2, len(@p1)-1)
  
  End
GO
