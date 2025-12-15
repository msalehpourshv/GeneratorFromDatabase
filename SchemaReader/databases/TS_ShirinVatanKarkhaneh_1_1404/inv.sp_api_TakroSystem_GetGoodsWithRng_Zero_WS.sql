USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Moayed
-- Create date   : 1402-12-13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : لیست کالاها با توجه به حیطه کاربر در برنامه اینداستری
-- =============================================
CREATE PROCEDURE [inv].[sp_api_TakroSystem_GetGoodsWithRng_Zero_WS]

@Filter as NVARCHAR(50),
@Skip as NVARCHAR(50),
@MaxResultCount as NVARCHAR(50),
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
	
	SELECT G.GoodsID,ISNULL(GD.GoodsName,'''') AS GoodsName
	FROM inv.tblGoods G
	
	LEFT JOIN inv.tblUnitsDtl U
	ON G.UnitID=U.UnitID

	JOIN inv.tblGoodsDtl GD
	ON G.GoodsID=GD.GoodsID
	where (1=1)	
	'

	if(@IsAdmin='False')
	begin
	set @strQuery= @strQuery+ '
		and
		(
					(Select COUNT(*) from inv.tblGoodsRng
					where inv.tblGoodsRng.UserID='+@UserID+' AND AllowCodeView=1  AND
					(LEFT(G.GoodsID,LEN(inv.tblGoodsRng.FromCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(G.GoodsID))
					AND LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(G.GoodsID)))
			)>0 
			
			OR 
					(Select COUNT(*) from inv.tblGoodsRng
					where inv.tblGoodsRng.UserID='+@UserID+' AND AccessAllCode=1)>0
		)
			
		AND(
					(Select COUNT(*) from inv.tblGoodsRng
					where inv.tblGoodsRng.UserID='+@UserID+' AND AllowCodeView=0 AND 
					(LEFT(G.GoodsID,LEN(inv.tblGoodsRng.FromCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(G.GoodsID))
					AND LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(G.GoodsID)))
					)=0 
				OR
					(Select COUNT(*) from inv.tblGoodsRng
					where inv.tblGoodsRng.UserID=-1 AND AllowCodeView=0 AND
					(LEFT(G.GoodsID,LEN(inv.tblGoodsRng.FromCode))>=LEFT(inv.tblGoodsRng.FromCode,LEN(G.GoodsID))
					AND LEFT(G.GoodsID,LEN(inv.tblGoodsRng.ToCode))<=LEFT(inv.tblGoodsRng.ToCode,LEN(G.GoodsID)))
					)=0 
			)
	'
	End



	if @Filter<>''
	begin
		set @strQuery=@strQuery+ 'and GD.GoodsName like N''%'+@Filter+'%'' OR G.GoodsID LIKE N''%'+@Filter+'%'''
	End

	SET @strQuery=@strQuery+' 
		ORDER BY G.GoodsID DESC
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
