USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/10
-- Viewed By	 : 
-- Last Modified : mr.moayed 1403/10/18
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_TakroSystem_GetGoods

@Filter as NVARCHAR(50),--='010114042',
@StoreID as NVARCHAR(20),--='10500001',
@DocDate as NVARCHAR(50),
@Skip as NVARCHAR(50),
@MaxResultCount as NVARCHAR(50),
@SaleTypeId as NVARCHAR(20),
@IsBarCode as bit,
@GoodsGroupID as NVARCHAR(20)='' 

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)
	DECLARE @strQuerySortGoodsGroupID as NVARCHAR(Max)=''

BEGIN TRY

	if @GoodsGroupID<>''
	begin

		set @strQuerySortGoodsGroupID= ' Order By GG.DocRowNo '
	End	
		else
	begin

		set @strQuerySortGoodsGroupID= ' ORDER BY g.GoodsID DESC '
	End

		set @strQuery='SELECT g.GoodsID,gd.GoodsName,g.GoodsPrice,g.UnitID,g.TechnicalNo,
						  inv.funGetUnitName(g.UnitID,1) as UnitName,Isnull(su.SubUnitID,'''') AS SubUnitID,
						  Cast (ISNULL(su.UnitValue,1)AS float )AS UnitValue,
						  Cast (Isnull(su.MainUnitValue,1) AS float) AS MainUnitValue,
						  inv.funGetUnitName(su.SubUnitID,1) AS SubUnitName,'

						  
	if @GoodsGroupID <> ''
		begin
			set @strQuery+=' cast(0 AS nvarchar(200)) AS GoodsRemain,
							cast(0 AS nvarchar(200)) AS Price'
		end
	else
		begin
   			set @strQuery+=' cast([inv].[funGetGoodsRemain](null,null,null,null,NULL,'''+@StoreID+''' ,g.GoodsID,'''','''+@DocDate+''' ,0) AS nvarchar(200)) AS GoodsRemain,
			cast([sal].[funGetGoodsAmountSaleType](g.GoodsID,'''+ @StoreID+''' , '''+@DocDate+''' ,'''+@SaleTypeId+''',1,0,0)AS nvarchar(200)) AS Price'
		end
		
	set @strQuery+=' From inv.tblGoods g '

	--در صورتی که کدینگ گروه کالا باشه جوین بخوره و گرنه باعث سنگین شدن کوئری نشه
	IF isnull(@GoodsGroupID,'') <>''
		--set @strQuery+= ' INNER JOIN inv.tblGoodsGroupsGoodsListDtl GG ON SUBSTRING(g.GoodsID,1,LEN(GG.GoodsID))=GG.GoodsID  '--قاتل سرعت اجرای کوئری!!!
		set @strQuery+=' INNER JOIN inv.tblGoodsGroupsGoodsListDtl GG on g.GoodsID=GG.GoodsID '

	set @strQuery+= 'LEFT JOIN inv.tblGoodsDtl gd ON g.GoodsID=gd.GoodsID AND gd.LanguageID = 1
				   LEFT JOIN inv.tblSubUnitsDtl su ON g.GoodsID=su.GoodsID and su.ShowInInvoice=1
				   WHERE CodeClosed=0 '
	
	--اگر 1 باشد یعنی فیلتر بر اساس بارکد است و نیازی به فیلتر گروه کالایی نیست
	if(@IsBarCode=0)
	begin
		set @strQuery=@strQuery+' And (SELECT TOP 1 COUNT(*) from inv.tblGoods b where LEFT(b.GoodsID,LEN(g.GoodsID))=g.GoodsID )=1'
	End


	if @Filter<>''
	begin
		set @strQuery=@strQuery+ ' And (gd.GoodsName like ''%'+@Filter+'%'' OR g.GoodsID LIKE '''+@Filter+'%'')'
	End

	if isnull(@GoodsGroupID,'')<>''
	begin
		set @strQuery = @strQuery + ' and GG.GoodsGroupID=''' + @GoodsGroupID + ''''
	end
	
	SET @strQuery= @strQuery + @strQuerySortGoodsGroupID + ' 
				   OFFSET ' + @Skip +' Rows 
				   FETCH NEXT ' + @MaxResultCount + ' Rows ONLY '
print @strQuery
EXEC sp_executesql @strQuery
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
