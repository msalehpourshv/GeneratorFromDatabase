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
-- Description   : نقدی بودن مشتری در کشتارگاه
-- =============================================
create FUNCTION [pub].[funGetAcntSaleCash]
(
	@AcntCode	varchar(20),
	@PartNumber	tinyint,
	@ProcessID	int,
	@ProcessNo	int,
	@FiscalYear	int,
	@SerialNo	int,
	@BaseStep   tinyint
)
RETURNS BIT
WITH ENCRYPTION
AS

Begin -- === S T A R T ===========================================

	Declare @Result AS BIT
	SET @Result='False'
	SELECT @Result = SaleCash 
	FROM acc.tblAcnt 
	WHERE AcntCode =@AcntCode and PartNumber=@PartNumber
	
	IF @Result='True'
		IF (SELECT(ISNULL((SELECT TOP 1 Amount 
						FROM acc.tblServicesHdr 
						WHERE BaseStep = @BaseStep AND 
							  BaseProcessID=@ProcessID AND
							  BaseProcessNo=@ProcessNo AND
							  BaseFiscalYear=@FiscalYear AND 
							  BaseSerialNo=@SerialNo),0)) - 
                (ISNULL((select SUM(Amount) 
						from trs.tblPayDtl PD INNER JOIN trs.tblPayHdr PH 
						ON PD.ProcessID=PH.ProcessID AND PD.ProcessNo=PH.ProcessNo
						AND PD.FiscalYear=PH.FiscalYear AND PD.SerialNo=PH.SerialNo
						WHERE PH.BaseProcessID=@ProcessID AND PH.BaseProcessNo=@ProcessNo
						AND PH.BaseFiscalYear=@FiscalYear AND PH.BaseSerialNo=@SerialNo 
						AND BaseStep=@BaseStep),0)))>0
			SET @Result='True'
		ELSE	
			SET @Result='False'
 
	Return @Result
End   -- === E N D ===============================================

GO
