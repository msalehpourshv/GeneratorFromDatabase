USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO


-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1393/11/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   :
-- =================================================================
 Create FUNCTION [pub].[funGetCustRemain]
	(@AcntCode	varchar(20)	
		)
	RETURNS float
WITH ENCRYPTION
AS
BEGIN
	if @AcntCode=''
		return 0

	DECLARE @RemainTo float	

	DECLARE	@LayerLen	int;
	DECLARE	@StartLayerIndex	int;
	DECLARE	@AcntPartNumber	int;

	SELECT @LayerLen = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'LayerLen'
	
		SELECT @StartLayerIndex = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'StartLayerIndex'
	
		SELECT @AcntPartNumber = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
		set @RemainTo = 
		(
			select IsNull(Sum(Debit-Credit), 0)
			from acc.tblVoucherDtl D
			where substring (AcntCode,@StartLayerIndex,@LayerLen )=@AcntCode
			  and (D.VchKind <> 3) and (D.VchKind <> 4) -- finish docs
		)
	return @RemainTo
END
GO
