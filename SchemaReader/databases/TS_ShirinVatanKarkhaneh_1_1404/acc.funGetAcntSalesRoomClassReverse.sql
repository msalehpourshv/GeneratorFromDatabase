USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1402/06/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create FUNCTION acc.funGetAcntSalesRoomClassReverse
(
	@AcntCode AS VarChar(20),
	@AcntPart TinyInt
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS
BEGIN

if @AcntPart=0
	set @AcntCode=substring (@AcntCode,[acc].[FunGetAcntInfoForRemain](2) ,[acc].[FunGetAcntInfoForRemain](3))

dEclare  @len as int=len(@AcntCode)
dEclare  @SalesRoomClass as varchar(20)

while @len>0 and isnull(@SalesRoomClass, '')=''
begin

	SELECT  @SalesRoomClass=SalesRoomClass 
	FROM acc.tblAcnt 
	WHERE PartNumber = 4 AND 
		  AcntCode = left(@AcntCode, @len)
	set @len-=1
 end 
 --20468006

	RETURN isnull(@SalesRoomClass,'')
END
GO
