USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.sp_api_TakroSystem_ChekBaseDocRowNo
@FiscalYear      AS int,
@ProcessNo       AS int,
@SerialNo	     AS int,
@BaseFiscalYear  AS int,
@BaseSerialNo    AS int,
@BaseProcessNo   AS int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @StrQuery        NVARCHAR(MAX)
	DECLARE @DbName			 NVARCHAR(100)
	DECLARE @MainDBNAME		 NVARCHAR(100)
BEGIN TRY
	SELECT @MainDBNAME=db_name()
	SELECT @DbName=substring (@MainDBNAME,1 , len(@MainDBNAME)-4)+ ltrim(str(@BaseFiscalYear))

	IF(@BaseFiscalYear<>@FiscalYear)
	BEGIN
		SET @DbName=@DbName
	END

	ELSE
	BEGIN
		SET @DbName=@MainDBNAME
	END

	SET @StrQuery= '
	SELECT  BaseProcessID,BaseProcessNo,BaseSerialNo,BaseFiscalYear,BaseDocRowNo,GoodsID,IsReward
	FROM inv.tblStorageDocsDtl 
	WHERE ProcessID=100 AND SerialNo='+STR(@SerialNo)+' 
	AND ProcessNo='+STR(@ProcessNo)+' AND FiscalYear='+STR(@FiscalYear)+'
	EXCEPT
	SELECT  ProcessID,ProcessNo,SerialNo,FiscalYear,DocRowNo ,GoodsID,IsReward
	FROM  '+@DbName+'.inv.tblStorageDocsDtl 
	WHERE ProcessID=90 AND SerialNo='+STR(@BaseSerialNo)+' 
	AND ProcessNo='+STR(@BaseProcessNo)+' AND FiscalYear='+STR(@BaseFiscalYear)

	PRINT @StrQuery
    EXEC sp_executesql @StrQuery

END TRY

BEGIN CATCH
	
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
