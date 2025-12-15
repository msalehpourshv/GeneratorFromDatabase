USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : mr.moayed
-- Create date   : 1403/05/30
-- Viewed By	 : 
-- Last Modified : 1403/11/07
-- Description   : 
-- =============================================
Create PROCEDURE inv.sp_api_AppService_GetGoodsGroups

@UserID as NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery  NVARCHAR(Max)
	
BEGIN TRY

	SET @strQuery=
	'SELECT H.GoodsGroupID,GoodsGroupName FROM inv.tblGoodsGroups AS H 
	INNER JOIN (SELECT * FROM inv.tblGoodsGroupsDtl WHERE LanguageID=1) AS D  ON H.GoodsGroupID=D.GoodsGroupID 
	WHERE 
			(
				(Select COUNT(*) from [inv].[tblGoodsGroupsRng]
				where [inv].[tblGoodsGroupsRng].UserID='+@UserID+' AND AllowCodeView=1  AND
				(LEFT(H.GoodsGroupID,LEN([inv].[tblGoodsGroupsRng].FromCode))>=LEFT([inv].[tblGoodsGroupsRng].FromCode,LEN(H.GoodsGroupID))
				AND LEFT(H.GoodsGroupID,LEN([inv].[tblGoodsGroupsRng].ToCode))<=LEFT([inv].[tblGoodsGroupsRng].ToCode,LEN(H.GoodsGroupID)))
		)>0 

		OR 
				(Select COUNT(*) from [inv].[tblGoodsGroupsRng]
				where [inv].[tblGoodsGroupsRng].UserID='+@UserID+' AND AccessAllCode=1)>0
	)
			
		AND(
				(Select COUNT(*) from [inv].[tblGoodsGroupsRng]
				where [inv].[tblGoodsGroupsRng].UserID='+@UserID+' AND AllowCodeView=0 AND 
				(LEFT(H.GoodsGroupID,LEN([inv].[tblGoodsGroupsRng].FromCode))>=LEFT([inv].[tblGoodsGroupsRng].FromCode,LEN(H.GoodsGroupID))
				AND LEFT(H.GoodsGroupID,LEN([inv].[tblGoodsGroupsRng].ToCode))<=LEFT([inv].[tblGoodsGroupsRng].ToCode,LEN(H.GoodsGroupID)))
				)=0 
				OR
				(Select COUNT(*) from [inv].[tblGoodsGroupsRng]
				where [inv].[tblGoodsGroupsRng].UserID=-1 AND AllowCodeView=0 AND
				(LEFT(H.GoodsGroupID,LEN([inv].[tblGoodsGroupsRng].FromCode))>=LEFT([inv].[tblGoodsGroupsRng].FromCode,LEN(H.GoodsGroupID))
				AND LEFT(H.GoodsGroupID,LEN([inv].[tblGoodsGroupsRng].ToCode))<=LEFT([inv].[tblGoodsGroupsRng].ToCode,LEN(H.GoodsGroupID)))
				)=0 
		) AND H.GoodsGroupID <> '''' AND CodeClosed =''False''
	ORDER BY H.GoodsGroupID'

PRINT @strQuery
EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)
END CATCH

END	
GO
