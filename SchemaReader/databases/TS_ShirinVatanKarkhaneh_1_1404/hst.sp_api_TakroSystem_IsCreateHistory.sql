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
Create PROCEDURE hst.sp_api_TakroSystem_IsCreateHistory
@SerialNo 	 as int ,
@ProcessID as int,
@FiscalYear as int,
@ProcessNo as int,
@Xml as nvarchar(250),
@DateNow as nvarchar(250),
@TimeNow as nvarchar(250),
@Status as int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @DBStatus as int
	DECLARE @DBDate NVARCHAR(MAX)
	DECLARE @DBTime NVARCHAR(MAX)

BEGIN TRY
	
	SELECT TOP 1 @DBDate=HistoryDate,@DBTime=HistoryTime ,@DBStatus= substring ( CAST(Code as Nvarchar(max)),18,1)
	FROM hst.tblHistoryRecords
	WHERE SerialNo=@SerialNo AND ProcessID=@ProcessID AND ProcessNo=@ProcessNo AND FiscalYear=@FiscalYear
	and Code like'<DocumentElement>%'
	ORDER BY HistoryDate,HistoryTime DESC

	IF (@DBDate=@DateNow)
	BEGIN
		IF(CAST(SUBSTRING(@DBTime,1,2)as int) <> CAST(SUBSTRING(@TimeNow,1,2)as int))
		BEGIN
			SELECT 1 AS IsCreate
		END

		--ELSE if(CAST(SUBSTRING(@DBTime,1,2)as int) = CAST(SUBSTRING(@TimeNow,1,2)as int) AND  CAST(SUBSTRING(@TimeNow,4,5)as int) >= (CAST(SUBSTRING(@DBTime,4,5)as int)+15) )
		--BEGIN
		--	IF(@DBStatus<>@Status)
		--	BEGIN
		--		SELECT 1 AS IsCreate
		--	END
		--	ELSE
		--		SELECT 0 AS IsCreate
		--END
		
		ELSE IF (CAST(SUBSTRING(@DBTime,1,2)as int) = CAST(SUBSTRING(@TimeNow,1,2)as int) AND  CAST(SUBSTRING(@TimeNow,4,5)as int) < (CAST(SUBSTRING(@DBTime,4,5)as int)+20) AND @DBStatus=@Status )
		BEGIN
			SELECT 0 AS IsCreate
		END

		ELSE
			SELECT 1 AS IsCreate
	END

	ELSE
		SELECT 1 AS IsCreate


END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
