USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [acc].[FunGetAcntInfoForRemain]
(
	@TypeRet TinyInt

)
RETURNS int
WITH ENCRYPTION
AS
BEGIN

	DECLARE @Result AS int

	Declare @CustomerPartNo AS Tinyint
	SET @CustomerPartNo = 0
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	if (@TypeRet=1) 
		set @Result=@CustomerPartNo
	ELSE if (@TypeRet=2) 
		select @Result  = acc.funGetAcntLayerStartandLen(@CustomerPartNo,1)
	ELSE if (@TypeRet=3) 
		select @Result  = acc.funGetAcntLayerStartandLen(@CustomerPartNo,2)
 
	if @Result=0
		SET @Result=1
	RETURN isnull(@Result,'1')

END
GO
