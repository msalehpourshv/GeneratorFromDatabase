USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1401/08/16
-- Viewed By	 : 
-- Last Modified : 1403/05/18 mr.moayed
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_TakroSystem_GetProductsQuantityWithStore]

@StoreId As NVARCHAR(50),
@DateNow As NVARCHAR(50),
@Skip As NVARCHAR(50),
@MaxResultCount As NVARCHAR(50),
@Filter as NVARCHAR(50),
@UserID as NVARCHAR(50),
@IsSubUnitID as bit = 'False'


WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)

BEGIN TRY

	if(@DateNow='')
	begin
		set @DateNow = [pub].[funChangeDate_GergorianToPersian](getDate())
	end
		
	if(@IsSubUnitID = 'False')
		begin
			set @strQuery='
				SELECT *,(select case when(GoodsRemain- ISNULL(SetPoint,0))>0 Then ''True'' else ''False'' End) as ''Status'' from (
					SELECT
						[inv].[funGetGoodsRemain](null,null,null,null,NULL,'''+@StoreId+''' ,G.GoodsID,null,'''+@DateNow+''' ,0)  AS GoodsRemain,
						ISNULL(U.UnitName,'''') AS UnitName,G.GoodsID,S.SetPoint,
						ISNULL(GD.GoodsName,'''') AS GoodsName
					FROM inv.tblGoods G
			
					LEFT JOIN inv.tblUnitsDtl U	ON G.UnitID=U.UnitID
					LEFT JOIN inv.tblGoodsDtl GD ON G.GoodsID=GD.GoodsID
					LEFT JOIN [inv].[tblGoodsStatusDtl] S ON S.GoodsID=GD.GoodsID AND S.StoreID='+@StoreId+'

					where
					(
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
					)
				'
		end
	else
		begin
			set @strQuery='
					SELECT *,(select case when(GoodsRemain- ISNULL(SetPoint,0))>0 Then ''True'' else ''False'' End) as ''Status'' from (
						SELECT
							[inv].[funGetSubUnitFromGoodsQuantity]( s.GoodsID ,s.SubUnitID ,[inv].[funGetGoodsRemain](null,null,null,null,NULL,'''+@StoreId+''' ,G.GoodsID,null,'''+@DateNow+''' ,0))  AS GoodsRemain,
							ISNULL(U.UnitName,inv.funGetUnitName(G.UnitID,1)) AS UnitName,G.GoodsID,S.SetPoint,
							ISNULL(GD.GoodsName,'''') AS GoodsName
						FROM inv.tblGoods G
						LEFT JOIN [inv].[tblSubUnitsDtl] s ON s.GoodsID = G.GoodsID and ShowInInvoice=''True''
						LEFT JOIN inv.tblUnitsDtl U	ON s.SubUnitID=U.UnitID
						LEFT JOIN inv.tblGoodsDtl GD	ON G.GoodsID=GD.GoodsID
						LEFT JOIN [inv].[tblGoodsStatusDtl] S ON S.GoodsID=GD.GoodsID AND S.StoreID='+@StoreId+'

						where
						(
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
						)
				'
		end
	

	if @Filter<>''
	begin
		set @strQuery=@strQuery+ 'and GD.GoodsName like N''%'+@Filter+'%'' OR G.GoodsID LIKE N''%'+@Filter+'%'''
	End

	SET @strQuery=@strQuery+' 
		) a where GoodsRemain>0.0001
		ORDER BY GoodsID DESC
		OFFSET ' +@Skip +' Rows 
		FETCH NEXT ' +@MaxResultCount +' Rows ONLY '

	--PRINT @strQuery
	EXEC sp_executesql @strQuery
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
