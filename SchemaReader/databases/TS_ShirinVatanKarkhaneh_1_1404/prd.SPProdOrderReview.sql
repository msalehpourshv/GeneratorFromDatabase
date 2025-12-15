USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1402/09/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE prd.SPProdOrderReview 
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE @StrSelect		NVarChar(max)
DECLARE @StrWhere		NVarChar(2000)
DECLARE @StrGoods		NVarChar(2000)
DECLARE @StrStore		NVarChar(2000)

DECLARE @FiscalYearFR	int
DECLARE @SerialNoFR		int
DECLARE @FiscalYearTO	int
DECLARE @SerialNoTO		int
DECLARE @UnitPart		int
DECLARE @LangID			int
DECLARE @str_Goods		int
DECLARE @str_GoodsSum	int
DECLARE @SerialNoFormul	int

DECLARE @FromDate		varchar(10)
DECLARE @ToDate			varchar(10)

	SELECT @LangID = pub.funGetCurrentLanguageID();

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
if @CallType=2
begin

	Declare @GoodsID as varchar(20)
	Declare @GoodsID2 as varchar(20)
	Declare @ProductCount float
	Declare @GoodsQuantity float

	SET @GoodsID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	set @GoodsID2 =''
	set @ProductCount=0
	set @GoodsQuantity=0	
	
	BEGIN TRY
			DROP TABLE #tblFlows
	END TRY
	BEGIN CATCH
	END CATCH

	select GoodsID,GoodsPrice  GoodsQuantity,GoodsPrice  SendQuantity , GoodsPrice Qtybase,GoodsPrice ProductQty,GoodsPrice GoodsQty
		into #tblFlows
	from inv.tblStorageDocsDtl
	where 1=0
	
	
	while @GoodsID<>@GoodsID2
	begin
		insert into #tblFlows
		select @GoodsID GoodsID,GoodsQuantity,SendQuantity,case When GoodsQuantity+SendQuantity<ProdQuantity then ProdQuantity-SendQuantity-GoodsQuantity else  0 end ProdQuantity		
			,@ProductCount,@GoodsQuantity
		from (select 
				 prd.funGetGoodsFormulasInfo(1,@GoodsID,'','') As GoodsQuantity
				, prd.funGetGoodsFormulasInfo(2,@GoodsID,'','') As SendQuantity
				,prd.funGetMinGoodsFormulasInfo(@GoodsID, 0) As ProdQuantity
			)aa

		set @GoodsID2=@GoodsID
	
		select top 1 @GoodsID=isnull(GoodsID,''),@ProductCount=ProductCount,@GoodsQuantity=GoodsQuantity from (
		select ISNULL(Min(			
					ISNULL((prd.funGetMinGoodsFormulasInfo(D.GoodsID,1)*ProductCount/ GoodsQuantity ),0)
						),0) Qty ,GoodsID,ProductCount,GoodsQuantity
				from	prd.tblFormulasDtl D 
				INNER JOIN prd.tblFormulasHdr H ON D.SerialNo = H.SerialNo AND D.ProductID = H.ProductID
				where  (D.ProductID =@GoodsID)  and H.IsDefault = 1 and BaseGoods=1 
				Group by GoodsID,ProductCount,GoodsQuantity) a 
				order by Qty
	end 

	select  S.GoodsID	,G.GoodsName, 	S.GoodsQuantity	,S.SendQuantity	,S.Qtybase,	S.ProductQty,	S.GoodsQty
	from  #tblFlows S
	left JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(S.GoodsID,@str_Goods+1,@str_GoodsSum) AND G.PartNumber= @UnitPart 

end 
if @CallType=1
begin
	
	SET @StrGoods		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @StrStore		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @FiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @SerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @FiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @SerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
	SET @FromDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @ToDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	SET @SerialNoFormul	= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 

	set @StrWhere='1=1 	'

	if @StrGoods<>''
		set @StrWhere =@StrWhere+ @StrGoods

	if @StrStore<>''
		set @StrWhere =@StrWhere+ @StrStore

	if @FiscalYearFR>0
		set @StrWhere =@StrWhere+ ' AND S.FiscalYear>=' +str(@FiscalYearFR)
	if @SerialNoFR>0
		set @StrWhere = @StrWhere+' AND S.SerialNo  >=' +str(@SerialNoFR)
	if @FiscalYearTO>0
		set @StrWhere =@StrWhere+ ' AND S.FiscalYear<=' +str(@FiscalYearTO)
	if @SerialNoTO>0
		set @StrWhere = @StrWhere+' AND S.SerialNo	<=' +str(@SerialNoTO)
	if @FromDate<>''	
		set @StrWhere = @StrWhere+' AND S.DocDate	>=''' +@FromDate +''''
	if @ToDate<>''	
		set @StrWhere = @StrWhere+' AND S.DocDate	<=''' + @ToDate +''''	

	set @StrSelect = ' 
		Select GoodsID	,GoodsName	,cast (OrderQuantity as float )OrderQuantity	,cast (GoodsQuantity as float )GoodsQuantity	,cast (ProdQuantity as float )ProdQuantity	
			,case When OrderQuantity>(GoodsQuantity+ProdQuantity) then  OrderQuantity-(GoodsQuantity+ProdQuantity)  else  0 end Remain 
		from (
				Select GoodsID,GoodsName,OrderQuantity,GoodsQuantity,case When GoodsQuantity<ProdQuantity then ProdQuantity-GoodsQuantity else  0 end ProdQuantity		
				 From (
						SELECT Top 1000  S.GoodsID, GD.GoodsName, Sum(S.GoodsQuantity) OrderQuantity
							, prd.funGetGoodsFormulasInfo(1,S.GoodsID,'''','''') As GoodsQuantity
							,prd.funGetMinGoodsFormulasInfo(S.GoodsID,'+str(@SerialNoFormul)+') As ProdQuantity
						FROM sal.tblSaleOrderDtl S 
						INNER JOIN	(
									SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderDtl 
									WHERE ProcessID=180  
									EXCEPT
									SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
									WHERE BaseProcessID=180 AND ProcessID=90  
									) A ON A.ProcessID=S.ProcessID AND A.ProcessNo=S.ProcessNo AND A.FiscalYear=S.FiscalYear AND A.SerialNo=S.SerialNo						
						INNER JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(S.GoodsID,' +str(@str_Goods+1)+','+ str(@str_GoodsSum)+') AND G.PartNumber= ' +str(@UnitPart) +' 
						INNER JOIN inv.tblGoodsDtl GD ON G.GoodsID = GD.GoodsID AND GD.PartNumber= ' + str(@UnitPart) +' AND GD.LanguageID =' +str(@LangID) +'   
				where  ' + @StrWhere +'
				Group by S.GoodsID, G.BarCode, GD.GoodsName
					)A
			)A
		order by GoodsID,  GoodsName '

		print @StrSelect
		Exec sp_executesql @StrSelect;
 end 
end 
GO
