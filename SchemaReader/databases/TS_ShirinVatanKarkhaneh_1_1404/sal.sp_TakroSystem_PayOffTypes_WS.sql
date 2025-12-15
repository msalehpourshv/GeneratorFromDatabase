USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Moayed
-- Create date   : 1403-04-31
-- Viewed By	 : 
-- Last Modified : 
-- Description   : List of PayOffType according to tblPayOffTypesRng
-- =============================================
CREATE PROCEDURE [sal].[sp_TakroSystem_PayOffTypes_WS]

@UserID as NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)
BEGIN TRY

	set @strQuery=
	'
	select p.PayOffTypeID,d.PayOffTypeName
	from sal.tblPayOffTypes p
	inner join sal.tblPayOffTypesDtl d on d.PayOffTypeID=p.PayOffTypeID
	where (1=1)	
	'

	set @strQuery= @strQuery+ '
		AND
		(
					(Select COUNT(*) from sal.tblPayOffTypesRng
					where sal.tblPayOffTypesRng.UserID='+@UserID+' AND AllowCodeView=1  AND
					(LEFT(p.PayOffTypeID,LEN(sal.tblPayOffTypesRng.FromCode))>=LEFT(sal.tblPayOffTypesRng.FromCode,LEN(p.PayOffTypeID))
					AND LEFT(p.PayOffTypeID,LEN(sal.tblPayOffTypesRng.ToCode))<=LEFT(sal.tblPayOffTypesRng.ToCode,LEN(p.PayOffTypeID)))
			)>0 
			
			OR 
					(Select COUNT(*) from sal.tblPayOffTypesRng
					where sal.tblPayOffTypesRng.UserID='+@UserID+' AND AccessAllCode=1)>0
		)
			
		AND(
					(Select COUNT(*) from sal.tblPayOffTypesRng
					where sal.tblPayOffTypesRng.UserID='+@UserID+' AND AllowCodeView=0 AND 
					(LEFT(p.PayOffTypeID,LEN(sal.tblPayOffTypesRng.FromCode))>=LEFT(sal.tblPayOffTypesRng.FromCode,LEN(p.PayOffTypeID))
					AND LEFT(p.PayOffTypeID,LEN(sal.tblPayOffTypesRng.ToCode))<=LEFT(sal.tblPayOffTypesRng.ToCode,LEN(p.PayOffTypeID)))
					)=0 
			OR
					(Select COUNT(*) from sal.tblPayOffTypesRng
					where sal.tblPayOffTypesRng.UserID=-1 AND AllowCodeView=0 AND
					(LEFT(p.PayOffTypeID,LEN(sal.tblPayOffTypesRng.FromCode))>=LEFT(sal.tblPayOffTypesRng.FromCode,LEN(p.PayOffTypeID))
					AND LEFT(p.PayOffTypeID,LEN(sal.tblPayOffTypesRng.ToCode))<=LEFT(sal.tblPayOffTypesRng.ToCode,LEN(p.PayOffTypeID)))
					)=0 
			)
	'
	
	PRINT @strQuery

	EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
