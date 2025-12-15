USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Creation date : 1400/08/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE inv.SpExportGoods2Mizan
	@ExtraParams varchar(200)
WITH ENCRYPTION
AS

BEGIN

DECLARE @LanguageID TinyInt;

SET NOCOUNT ON;

	DECLARE @StrSelect	NVarChar(Max);
	DECLARE @StrWhere	NVarChar(Max);
	
	SET @LanguageID = pub.funGetCurrentLanguageID();	
	 
	declare @dbName2		varchar(20)
	declare @tblName		varchar(20)
	declare @SaleTypeID		Varchar(20)
	declare @GoodsID		Varchar(20)
	declare @TechnicalNo	int

	set @tblName='dbo.MizanNetItem'
	 set @dbName2		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	 set @SaleTypeID	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 	 
	 set @GoodsID		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	

	select @TechnicalNo=TechnicalNo from inv.tblGoods where GoodsID=''''+@GoodsID+''''

	set @TechnicalNo	=isnull(@TechnicalNo,0)	
	 if @TechnicalNo>0
		begin
			SET @StrSelect = 
			'	delete from '+@dbName2+'.'+@tblName+'  
				where PluNo='''+ @TechnicalNo +''' '
			Print @StrSelect;
			Exec sp_executesql @StrSelect;		
		end
		else
		begin
			SET @StrSelect = 
			'	delete from '+@dbName2+'.'+@tblName+' '
			Print @StrSelect;
			Exec sp_executesql @StrSelect;		
		end
			--
	-- ============================================================= Select
	SET @StrSelect = '	
	insert into '+@dbName2+'.'+@tblName+'(PluNo,WeightUnit,BarFormat, BarFlags,BarItemCode)
	select TechnicalNo, Case  when WeightBarcode=''True'' then 0 else 1 end,Case  when WeightBarcode=''True'' then 5 else 8 end 
	,Case  when WeightBarcode=''True'' then 20 else substring(BarCode,1,2) end 
	,Case  when WeightBarcode=''True'' then BarCode else  substring(BarCode,3,len(BarCode)-2) end 
	
	 from inv.tblGoods					
	 '
	 set @StrWhere=' where BarCode <>'''' and TechnicalNo<>'''' and TechnicalNo  in (
	select TechnicalNo from inv.tblGoods	
	except 
	select PluNo from  '+@dbName2+'.'+@tblName+'
	) '
	 if @TechnicalNo>0
		set @StrWhere=@StrWhere+' and TechnicalNo='+ str(@TechnicalNo) +' '
	 if @GoodsID<>''
		set @StrWhere=@StrWhere+' and GoodsID='''+ @GoodsID +''' '
	SET @StrSelect = @StrSelect +@StrWhere
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
		
			SET @StrSelect = '	update '+@dbName2+'.'+@tblName+'
				set CommodityName =p.GoodsName
				from '+@dbName2+'.'+@tblName+' a
				inner join inv.tblGoods g on a.PluNo=g.TechnicalNo
				inner join inv.tblGoodsDtl p on p.GoodsID=g.GoodsID	'
		
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
		
	
	set @SaleTypeID	=isnull(@SaleTypeID,'')		

	IF @SaleTypeID<> ''
		BEGIN
			SET @StrSelect = '	
			update '+@dbName2+'.'+@tblName+'
				set UPrice=p.SalePrice
			from '+@dbName2+'.'+@tblName+' a
				inner join inv.tblGoods g on a.PluNo=g.TechnicalNo
				inner join sal.tblGoodsPricesDtl  p on p.GoodsID=g.GoodsID	 '
			set @StrWhere=' where 1=1  '
			if @GoodsID<>''
				set @StrWhere=@StrWhere+' and g.GoodsID='''+ @GoodsID +''' '
			if @SaleTypeID<>''
				set @StrWhere=@StrWhere+' and p.SaleTypeID='''+ @SaleTypeID +''' '
			if @TechnicalNo>0
				set @StrWhere=@StrWhere+' and g.TechnicalNo='+ str(@TechnicalNo) +' '
	SET @StrSelect = @StrSelect +@StrWhere
		
			Print @StrSelect;
			Exec sp_executesql @StrSelect;
		END		
END
GO
