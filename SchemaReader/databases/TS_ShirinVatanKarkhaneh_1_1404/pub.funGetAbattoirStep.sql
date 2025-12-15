USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hadi Sadeghi
-- Create date   : 1399/05/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : مرحله جاری کشتارگاه
-- =============================================
Create FUNCTION [pub].[funGetAbattoirStep]
(	@ProcessID	int,
	@ProcessNo	int,
	@FiscalYear	int,
	@SerialNo	int
)
RETURNS tinyint	
WITH ENCRYPTION
AS

Begin
	Declare @Result AS tinyint
	SET @Result = 0
	
	SELECT @Result=DocStep 
	FROM inv.tblAbattoirHdr
	where ProcessID=@ProcessID
	AND ProcessNo=@ProcessNo
	AND FiscalYear=@FiscalYear
	AND SerialNo=@SerialNo

	RETURN @Result
END
GO
