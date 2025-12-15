USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1400/03/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE FUNCTION acc.funAcntCodeClosed
(
	@AcntCode Varchar(20)
)
RETURNS bit
WITH ENCRYPTION
AS

BEGIN

DECLARE  @PartNumber int
DECLARE  @PartStart int
DECLARE  @PartEnd int
DECLARE @Rslt  bit


select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
select @PartStart=[acc].[FunGetAcntInfoForRemain](2)
select @PartEnd=[acc].[FunGetAcntInfoForRemain](3)

	SET  @Rslt = 0

	SELECT @Rslt = CodeClosed
	From acc.tblAcnt
	Where	AcntCode= substring( @AcntCode,@PartStart,@PartEnd ) AND 
			PartNumber=@PartNumber
	
	RETURN @Rslt
END
GO
