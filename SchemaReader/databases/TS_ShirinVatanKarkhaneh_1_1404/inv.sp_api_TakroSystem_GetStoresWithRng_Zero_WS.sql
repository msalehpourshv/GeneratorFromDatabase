USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1401/08/16
-- Viewed By	 : 
-- Last Modified : mr.moayed 1404/04/18
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_TakroSystem_GetStoresWithRng_Zero_WS]

@Skip As NVARCHAR(50),
@MaxResultCount As NVARCHAR(50),
@Filter as NVARCHAR(50),
@UserID as NVARCHAR(50),
@IsAdmin as bit

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)
BEGIN TRY

	set @strQuery=
	'
	SELECT
		A.StoreID,sd.StoreName
	FROM inv.tblStores A
	
	JOIN inv.tblStoresDtl sd
	ON A.StoreID=sd.StoreID 
	
	where (1=1 and 
		(SELECT Count(*) from inv.tblStores b where SUBSTRING(b.StoreID,1,LEN(sd.StoreID))=sd.StoreID) =1 and A.StoreID<>''''
	) 
	
	'
	
	if @IsAdmin='False'
	begin
		set @strQuery=@strQuery+ 
		' AND
			(
				(Select COUNT(*) from inv.tblStoresRng
				where inv.tblStoresRng.UserID='+@UserID+' AND AllowCodeView=1  AND
				(LEFT(A.StoreID,LEN(inv.tblStoresRng.FromCode))>=LEFT(inv.tblStoresRng.FromCode,LEN(A.StoreID))
				AND LEFT(A.StoreID,LEN(inv.tblStoresRng.ToCode))<=LEFT(inv.tblStoresRng.ToCode,LEN(A.StoreID)))
		)>0 
			
		OR 
				(Select COUNT(*) from inv.tblStoresRng
				where inv.tblStoresRng.UserID='+@UserID+' AND AccessAllCode=1)>0
	)
			
		AND(
				(Select COUNT(*) from inv.tblStoresRng
				where inv.tblStoresRng.UserID='+@UserID+' AND AllowCodeView=0 AND 
				(LEFT(A.StoreID,LEN(inv.tblStoresRng.FromCode))>=LEFT(inv.tblStoresRng.FromCode,LEN(A.StoreID))
				AND LEFT(A.StoreID,LEN(inv.tblStoresRng.ToCode))<=LEFT(inv.tblStoresRng.ToCode,LEN(A.StoreID)))
				)=0 
				OR
				(Select COUNT(*) from inv.tblStoresRng
				where inv.tblStoresRng.UserID=-1 AND AllowCodeView=0 AND
				(LEFT(A.StoreID,LEN(inv.tblStoresRng.FromCode))>=LEFT(inv.tblStoresRng.FromCode,LEN(A.StoreID))
				AND LEFT(A.StoreID,LEN(inv.tblStoresRng.ToCode))<=LEFT(inv.tblStoresRng.ToCode,LEN(A.StoreID)))
				)=0 
		)
		'
	End

	if @Filter<>''
	begin
		set @strQuery=@strQuery+ ' AND( sd.StoreName LIKE ''%'+@Filter+'%'' OR A.StoreID LIKE ''%'+@Filter+'%'')'
	End

	
	SET @strQuery=@strQuery+' 
		 ORDER BY sd.StoreName DESC
		 OFFSET ' +@Skip +' Rows 
		 FETCH NEXT ' +@MaxResultCount +' Rows ONLY '

	PRINT @strQuery
	EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
