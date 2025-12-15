USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_AppService_GetUpdatedGoods

@DateFrom AS nvarchar(50),
@DateNow As nvarchar(50),
@GoodsID As nvarchar(50),
@SaleTypeId as nvarchar(50),
@StoreId as nvarchar(50),
@Skip AS  NVARCHAR(50),
@Layer AS nvarchar(50),
@MaxResultCount AS  NVARCHAR(50)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery  NVARCHAR(Max)
	DECLARE @SumLayer  NVARCHAR(Max)
	
BEGIN TRY

	set @SaleTypeId=@SaleTypeId

	SELECT @SumLayer=  Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer
	WHERE TableName ='inv.tblGoods' AND PartNumber=1

	declare @Layer1 int ,@Layer2 int ,@Layer3 int ,@Layer4 int  ,@Layer5 int ,@Layer6 int

	select @Layer1 =Layer1,
	@Layer2 = Layer1+ Layer2,
	@Layer3 = Layer1+ Layer2+Layer3,
	@Layer4 = Layer1+ Layer2+Layer3+Layer4,
	@Layer5 = Layer1+ Layer2+Layer3+Layer4+Layer5,
	@Layer6 = Layer1+ Layer2+Layer3+Layer4+Layer5+Layer6
	from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1

	declare @1Layer1 nvarchar(50) ,@2Layer2 nvarchar(50) ,@3Layer3 nvarchar(50) ,@4Layer4 nvarchar(50)  ,@5Layer5 nvarchar(50) ,@6Layer6 nvarchar(50)
	
	select  @1Layer1=ISNULL(@Layer1,''),
			@2Layer2=ISNULL(@Layer2,''),
			@3Layer3=ISNULL(@Layer3,''),
			@4Layer4=ISNULL(@Layer4,''),
			@5Layer5=ISNULL(@Layer5,''),
			@6Layer6=ISNULL(@Layer6 ,'')

	IF(@StoreId='' OR @StoreId IS NULL)
	BEGIN
		SET @strQuery='SELECT [inv].[funGetGoodsRemain](null,null,null,null,NULL, NULL ,G.GoodsID,'''','''+@DateNow+''',0)  AS Quantity , '
	END

	ELSE
	BEGIN

		SET @strQuery='SELECT [inv].[funGetGoodsRemain](null,null,null,null,NULL, '+@StoreId+' ,G.GoodsID,'''','''+@DateNow+''',0)  AS Quantity , '
	END

	

	set @strQuery=@strQuery+
				 '  G.GoodsID as GoodsId,G.GoodsID as GoodsID,GD.GoodsName,GD.GoodsName2,U.UnitName,G.BarCode,GD.Author,GD.Description,
				    [sal].[funGetGoodsAmountSaleType](G.GoodsID,'''' ,'''+@DateNow+''' ,'''+@SaleTypeId+''',1,0,0) Price,
				    CAST(LastUpdate AS VARCHAR(50)) as LastUpdate,
					SubString(G.GoodsID,1,'+@1Layer1+') Layer1,
					case 
						when SubString(G.GoodsID,'+@2Layer2+','+@2Layer2+')='''' then '''' 
						when SubString(G.GoodsID,'+@2Layer2+','+@2Layer2+')<>'''' then SubString(G.GoodsID,1,'+@2Layer2+') 
					end  Layer2,
					case 
						when SubString(G.GoodsID,'+@3Layer3+','+@3Layer3+')='''' then '''' 
						when SubString(G.GoodsID,'+@3Layer3+','+@3Layer3+')<>'''' then SubString(G.GoodsID,1,'+@3Layer3+') 
					end Layer3,
					case 
						when SubString(G.GoodsID,'+@4Layer4+','+@4Layer4+')='''' then '''' 
						when SubString(G.GoodsID,'+@4Layer4+','+@4Layer4+')<>'''' then SubString(G.GoodsID,1,'+@4Layer4+')
					end Layer4 ,
					case 
						when SubString(G.GoodsID,'+@5Layer5+','+@5Layer5+')='''' then '''' 
						when SubString(G.GoodsID,'+@5Layer5+','+@5Layer5+')<>'''' then SubString(G.GoodsID,1,'+@5Layer5+')
					end Layer5,
					case 
						when SubString(G.GoodsID,'+@6Layer6+','+@6Layer6+')='''' then '''' 
						when SubString(G.GoodsID,'+@6Layer6+','+@6Layer6+')<>'''' then SubString(G.GoodsID,1,'+@6Layer6+')
					end Layer6			
				  FROM inv.tblGoods G

				    INNER JOIN inv.tblGoodsDtl GD ON G.GoodsID=GD.GoodsID
		            INNER JOIN [inv].[tblUnitsDtl] U ON U.UnitID=G.UnitID

		          WHERE  G.CodeClosed=0 '
	
		IF(@DateFrom<>'')
		BEGIN
	    	SET @strQuery=@strQuery+' AND LastUpdate>= '''+@DateFrom+''''
		END

		IF(@GoodsID<>'')
		BEGIN
			SET @strQuery=@strQuery+' AND G.GoodsID= '''+@GoodsID+''''
		END

		
		IF(@Layer<>'' and @Layer<>0)
		BEGIN
			IF(@Layer='1')
				SET @strQuery=@strQuery+' AND lEN(G.GoodsID)= '+@1Layer1
			ELSE IF(@Layer='2')
				SET @strQuery=@strQuery+' AND lEN(G.GoodsID)= '+@2Layer2
			ELSE IF(@Layer='3')
				SET @strQuery=@strQuery+' AND lEN(G.GoodsID)= '+@3Layer3
			ELSE IF(@Layer='4')
				SET @strQuery=@strQuery+' AND lEN(G.GoodsID)= '+@4Layer4
			ELSE IF(@Layer='5')
				SET @strQuery=@strQuery+' AND lEN(G.GoodsID)= '+@5Layer5
			ELSE IF(@Layer='6')
				SET @strQuery=@strQuery+' AND lEN(G.GoodsID)= '+@6Layer6
			ELSE IF(@Layer='6')
				SET @strQuery=@strQuery+' AND lEN(G.GoodsID)= '+@6Layer6
			ELSE
				SET @strQuery=@strQuery+' AND lEN(G.GoodsID)> '+@6Layer6

		END
	
		SET @strQuery=@strQuery+' 
				   ORDER BY G.GoodsID 
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
