USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1402/05/11
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create FUNCTION acc.funGetAcntSaleTypeIDReverse
(
	@AcntCode AS VarChar(20),
	@AcntPart TinyInt
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS
BEGIN


dEclare  @len as int=len(@AcntCode)
dEclare  @SaleTypeID as varchar(20)

while @len>0 and isnull(@SaleTypeID, '')=''
begin

	SELECT  @SaleTypeID=SaleTypeID 
	FROM acc.tblAcnt 
	WHERE PartNumber = 4 AND 
		  AcntCode = left(@AcntCode, @len)
	set @len-=1
 end 
 --20468006

	RETURN isnull(@SaleTypeID,'')
END
GO
