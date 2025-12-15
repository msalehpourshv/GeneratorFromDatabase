USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/04/13
-- Viewed By	 : 
-- Last Modified : 1390/04/28
-- Last Modifier : TakroSystem\Zia
-- Description   : <List of Product Formulas with last Price>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_AmountForecast_All]
	@SelectedProds		int = 0,
	@WageNo				int = 0,
	@UserID				int = Null,         
	@ToDate				varchar(10) = null,
	@RepOptions			NVarChar(200) = '111',
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect			NVarChar(2000)
DECLARE @StrFrom			NVarChar(2000)
DECLARE @StrWhere			NVarChar(2000)
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی
DECLARE	@ProductID			varchar(20);
DECLARE	@SerialNo			int;
DECLARE	@ProductCount		float;
DECLARE	@SortByTotalAmount  BIT;
DECLARE @DBNameYear1		VARCHAR(500)
DECLARE @DBNameYear2		VARCHAR(500)
DECLARE @DBNameYear3		VARCHAR(500)
DECLARE @DBNameYear4		VARCHAR(500)
DECLARE @FiscalYear			int
BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedProds	Is Null)	SET @SelectedProds = 0;
	IF (@RepOptions		Is Null)	SET @RepOptions = '10';
	IF (@ToDate			Is Null)	SET @ToDate = '9999/99/9';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @SortByTotalAmount	= Substring(@RepOptions, 2, 1);

	---------------------------------------------------------------------------
	create table #tblProducts2
	(
		ProductID		varchar(20) collate arabic_cs_as not null,
		SerialNo		int not null,
		ProductCount	float not null
	);

	create table #tblGoods2
	(
		GoodsID			varchar(20) collate arabic_cs_as not null,
		GoodsName		nvarchar(200) not null,
		GoodsQuantity	float,
		Balance			float,
		UnitName		nvarchar(200) not null
	);

	create table #tblGoods2Ex
	(
		ProductID		varchar(20) collate arabic_cs_as not null,
		SerialNo		int not null,
		ProductCount	float not null,
		GoodsID			varchar(20) collate arabic_cs_as not null,
		GoodsName		nvarchar(500) not null,
		GoodsQuantity	float,
		Balance			float
	);

	-- WHERE SECTION --------------------------------
	SET @StrWhere = '(H.IsDefault = 1)'
	
	If (@SelectedProds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.ProductID') 

	set @StrSelect = 
		' insert into #tblProducts2(ProductID, SerialNo, ProductCount) ' +
		' select distinct H.ProductID, H.SerialNo, 1 ' +
		' from prd.tblFormulasDtl D 
			inner join prd.tblFormulasHdr H ON H.ProductID = D.ProductID AND H.SerialNo = D.SerialNo ' +
		' where ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-------------------------------------------------
	declare csr_Products2 cursor for
		select ProductID, SerialNo, ProductCount
		from #tblProducts2
	open csr_Products2;

	fetch NEXT from csr_Products2 into @ProductID, @SerialNo, @ProductCount
	
	while (@@fetch_status = 0)
	begin
		insert into #tblGoods2(GoodsID, GoodsName, GoodsQuantity, Balance,UnitName)
		exec [prd].[RptPrd_ProduceGoods_Leafs] @ProductID, 1, '10', '1@1@1'

		insert into #tblGoods2Ex(ProductID, SerialNo, ProductCount, GoodsID, GoodsName, GoodsQuantity, Balance)
		select @ProductID, @SerialNo, @ProductCount, G.GoodsID, G.GoodsName, sum(G.GoodsQuantity) as GoodsQuantity, G.Balance
		from #tblGoods2 G
		group by G.GoodsID, G.GoodsName, G.Balance

		delete from #tblGoods2

		fetch NEXT from csr_Products2 into @ProductID, @SerialNo, @ProductCount
	end

	close csr_Products2
	deallocate csr_Products2
	
	begin try
		create table ##tbl_RptPrd_AmountForecastAllXM001 (ProdID varchar(20) collate Arabic_CS_AS not null, SumAmount bigint not null)
	end try
	begin catch
	end catch
	----------------------------------------------------------------------------------------------
	select @DBNameYear1=DB_NAME()
	select @FiscalYear=SUBSTRING(@DBNameYear1,len(@DBNameYear1)-3,4)
	select @DBNameYear2=SUBSTRING(@DBNameYear1,1,len(@DBNameYear1)-4)+ltrim(str(@FiscalYear-1))
	select @DBNameYear3=SUBSTRING(@DBNameYear1,1,len(@DBNameYear1)-4)+ltrim(str(@FiscalYear-2))
	select @DBNameYear4=SUBSTRING(@DBNameYear1,1,len(@DBNameYear1)-4)+ltrim(str(@FiscalYear-3))
	IF (select count(*) from sys.databases where name=@DBNameYear2)=0
		set @DBNameYear2=@DBNameYear1
	IF (select count(*) from sys.databases where name=@DBNameYear3)=0
		set @DBNameYear3=@DBNameYear1
	IF (select count(*) from sys.databases where name=@DBNameYear4)=0
		set @DBNameYear4=@DBNameYear1		 

	-- SELECT SECTION -------------------------------
	if @SortByTotalAmount='False'
		set @StrSelect	='
		select *,Row_Number()over(Partition by ProductID order by A.ProductID ) RN 
		from (
				SELECT	D.ProductID, D.SerialNo, D.GoodsID, D.GoodsQuantity, D.ProductCount,
					[pub].[funGetGoodsName](D.ProductID, '+@LangID+') As ProductName, D.GoodsName, 
					[pub].[funGetGoodsUnitName] (D.GoodsID, '+@LangID+') As UnitName
					,isnull((
					case when inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					when '+@DBNameYear2+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear2+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''')
					when '+@DBNameYear3+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear3+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					when '+@DBNameYear4+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear4+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					else 0 end
					), 0)  LastPriceBuy
					,isnull((
					case when inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					when '+@DBNameYear2+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear2+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''')
					when '+@DBNameYear3+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear3+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					when '+@DBNameYear4+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear4+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					else 0 end
					), 0) LastPricePrim, M.SumAmount				
				FROM	#tblGoods2Ex D
					left join ##tbl_RptPrd_AmountForecastAllXM001 M on M.ProdID = D.ProductID 
			) A'
	ELSE	
		set @StrSelect	='	
		select *,Row_Number()over(Partition by ProductID order by A.ProductID,A.GoodsQuantity*(CASE WHEN LastPriceBuy>0 THEN LastPriceBuy ELSE LastPricePrim END)  desc ) RN 
		from (
				SELECT	D.ProductID, D.SerialNo, D.GoodsID, D.GoodsQuantity, D.ProductCount,
					[pub].[funGetGoodsName](D.ProductID, '+@LangID+') As ProductName, D.GoodsName, 
					[pub].[funGetGoodsUnitName] (D.GoodsID, '+@LangID+') As UnitName
					,isnull((
					case when inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					when '+@DBNameYear2+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear2+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''')
					when '+@DBNameYear3+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear3+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					when '+@DBNameYear4+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear4+'.inv.funGetLastPrice(55,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					else 0 end
					), 0)  LastPriceBuy,
					isnull((
					case when inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					when '+@DBNameYear2+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear2+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''')
					when '+@DBNameYear3+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear3+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					when '+@DBNameYear4+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') >0 then  '+@DBNameYear4+'.inv.funGetLastPrice(50,0,0,D.GoodsID,Null,'''+@ToDate+''') 
					else 0 end				
					), 0) LastPricePrim, M.SumAmount				
				FROM	#tblGoods2Ex D
				left join ##tbl_RptPrd_AmountForecastAllXM001 M on M.ProdID = D.ProductID 
			) A
			order by A.ProductID,A.GoodsQuantity*(CASE WHEN LastPriceBuy>0 THEN LastPriceBuy ELSE LastPricePrim END) desc'
	-------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
