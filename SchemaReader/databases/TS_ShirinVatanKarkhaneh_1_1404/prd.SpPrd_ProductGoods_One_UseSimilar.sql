USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[prd].[SpPrd_ProductGoods_One_UseSimilar] '101000801109100',4,60,'1394/04/14','','0000','1@1@1'
-- =========== TS-QC:UPDATED ===================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/01/19
-- Viewed By	 : 
-- Last Modified : 1394/08/25
-- Last Modifier : TakroSystem\H.Sadeghi
-- ---------------------------------------------
-- =============================================
Create PROCEDURE [prd].[SpPrd_ProductGoods_One_UseSimilar]
	@ProductID	VarChar(20),
    @ProductQty	float = 1,
	@SerialNo	int = 0,
	@DocDateTo	char(10) = null,
	@StoreID	varchar(20) = null,
	@RepOptions	VarChar(20) = '00', -- bit array
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @LangID		Char(1);
DECLARE @SessionNo  varChar(10);
DECLARE @ReportID   varChar(10);

DECLARE @FormulaYOnly bit; -- فقط کالاهائی که فرمول تولید دارند
DECLARE @FormulaNOnly bit; -- فقط کالاهائی که فرمول تولید ندارند

declare @TmpProductID	varchar(20);
declare @GoodsID		varchar(20);
declare @GoodsIDX		varchar(20);
declare @UnitID			varchar(20);
declare @DefaultStoreID	varchar(20) = ''
declare @ProducerAcntCode	varchar(20) = ''
declare @BatchNo		varchar(20) = ''

declare @Quantity	float;
declare @SubUnitQuantity	float;
declare @FmlParam1	float;
declare @Balance	float;
declare @FormulaNo	int;
DECLARE @ProdStepID	int;
DECLARE @StorIDHdr	int;
DECLARE @DocRowNo	int;
DECLARE @ContractNo	int;

DECLARE @StrSelect  nvarchar(4000);
DECLARE @DescDtl	nvarchar(500);
DECLARE @StrWhere	nvarchar(2000);
DECLARE @QuantityDecimalsToForms AS int
DECLARE @Prd_UseSimilarGoodsInProduce AS bit
DECLARE @NotGroupByGoodsIDInProduct AS bit
DECLARE @UnitPart TINYINT

BEGIN
	SET NOCOUNT ON;

	-- Init ---------------------------------------------------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '109';
	IF (@DocDateTo Is Null)		SET @DocDateTo = '9999/99/99';

	set @NotGroupByGoodsIDInProduct='False'	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @ProducerAcntCode = pub.funSplitString(@RepInfo, '@', 4);
	SET @ContractNo	= pub.funSplitString(@RepInfo, '@', 5);
	SET @FmlParam1	= pub.funSplitString(@RepInfo, '@', 6);
	SET @BatchNo	= pub.funSplitString(@RepInfo, '@', 7);

	SET @FormulaYOnly = Substring(@RepOptions, 1, 1);
	SET @FormulaNOnly = Substring(@RepOptions, 2, 1);
	SET @ProdStepID	  = Substring(@RepOptions, 3, 2);
	SET @StorIDHdr	  = Substring(@RepOptions, 5, 1);

	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	SELECT @NotGroupByGoodsIDInProduct=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'NotGroupByGoodsIDInProduct'	
	SELECT @QuantityDecimalsToForms=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'QuantityDecimalsToForms'	
	SELECT @Prd_UseSimilarGoodsInProduce=SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'Prd_UseSimilarGoodsInProduce'	
	SET @Prd_UseSimilarGoodsInProduce =isnull( @Prd_UseSimilarGoodsInProduce,'False')

	IF @ProducerAcntCode <> '' AND (@ContractNo<>'' OR @ContractNo<>'0')
	BEGIN	    
		IF (select COUNT(*) from prd.tblProducersWageDtl 
		    where SerialNo=@ContractNo AND ProducerAcntCode=@ProducerAcntCode AND GoodsID=@ProductID AND IsService='True')>0
		BEGIN
			SELECT cast(@ProductID as varchar(20)) ProductID, cast(@ProductID as varchar(20)) GoodsID, 
			       @ProductQty Quantity, @ProductQty SubUnitQuantity,
				   @StoreID  DefaultStoreID, @ProductQty ProductCount,1 DocRowNo, 
				   [pub].[funGetGoodsName](@ProductID, @LangID) As GoodsName,
				   [pub].[funGetGoodsUnitID](@ProductID) UnitID, [inv].[funGetUnitName]([pub].[funGetGoodsUnitID](@ProductID),@LangID) UnitName,
					ISNULL((
						select ROUND(SUM(GoodsQuantity*EnterKind), @QuantityDecimalsToForms)
						from inv.tblStorageDocsDtl D
						where D.GoodsID = @ProductID
						  and DocDate <= @DocDateTo 
						  and D.StoreID = @StoreID
					),0) Balance,
					ISNULL((
						select ROUND(SUM(GoodsQuantity*EnterKind), @QuantityDecimalsToForms)
						from inv.tblStorageDocsDtl D
						where D.GoodsID = @ProductID
						  and DocDate <= @DocDateTo 
						  and D.StoreID = @StoreID
					),0) SubBalance
			RETURN
		END
	END
 
	DECLARE @intGoods int 

	select @intGoods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber=1
		
	-- 3 is used
	-----------------------------------------------------------------------------
	create table #tbl_Prd_ProductGoods_One_UseSimilar_Result
	(
		FormulaNo		int not null,
		GoodsID			varchar(20) collate arabic_cs_as not null,
		Quantity		Decimal(38,10) not null,
		SubUnitQuantity Decimal(38,10) not null,
		UnitID			varchar(20) collate arabic_cs_as not null,
		DefaultStoreID 	varchar(20) collate arabic_cs_as not null,
		ProductCount	float not null,
		DocRowNo		int not null,
		DescDtl			Nvarchar(4000)
	)
	
	create table #tbl_Prd_ProductGoods_Similar
	(
		DocRowNo		int not null,
		ProductCount	float not null,
		GoodsID			varchar(20) collate arabic_cs_as not null,
		UnitID			varchar(20) collate arabic_cs_as not null,
		DefaultStoreID 	varchar(20) collate arabic_cs_as not null,
		Quantity		float not null,
		Value1			float not null,
		Value2			float not null
	)

	SELECT TOP 1 @TmpProductID = ProductID FROM prd.tblFormulasHdr  FH
	WHERE	FH.ProductID = SUBSTRING(@ProductID,1,LEN(FH.ProductID)) AND 
	       ((@SerialNo> 0 AND FH.SerialNo = @SerialNo) OR ( @SerialNo = 0 AND IsDefault=1))
	order by LEN(ProductID) DESC
	
	if (@SerialNo <> 0) 
		set @StrWhere = '(H.SerialNo=' + Str(@SerialNo) + ')'
	else
		set @StrWhere = '(H.IsDefault=1)' 

	if (@FormulaYOnly = 1)
		set @StrWhere = @StrWhere + ' AND (D.GoodsID in (select ProductID from prd.tblFormulasHdr))' 
	if (@FormulaNOnly = 1)
		set @StrWhere = @StrWhere + ' AND (D.GoodsID not in (select ProductID from prd.tblFormulasHdr))' 
	if (@ProdStepID <> 0) 
		set @StrWhere = @StrWhere + ' AND (D.ProduceStepID = ' + Str(@ProdStepID) + ')'

	set @StrWhere = @StrWhere + ' AND (D.ParamKind=0 OR (D.ParamKind=1 and H.FmlParam1>0))'
	

	-----------------------------------------------------------------------------	
	set @StoreID=isnull(@StoreID,'')
	-- Select -------------------------------------------------------------------
	IF @BatchNo<>'' AND @FmlParam1=0
	BEGIN
			DECLARE @BatchStoreID varchar(20)
			SET @BatchStoreID = @StoreID
			IF @StorIDHdr <> 1
				SET @BatchStoreID=''

			set @StrSelect = '
			insert into #tbl_Prd_ProductGoods_One_UseSimilar_Result(FormulaNo, GoodsID, Quantity,SubUnitQuantity,UnitID, DefaultStoreID, ProductCount,DocRowNo,DescDtl)
			SELECT FormulaNo, GoodsID, Quantity,SubUnitQuantity,UnitID, DefaultStoreID, ProductCount,DocRowNo,DescDtl 
            FROM inv.FunGetRemainBatchGoods('''+ @BatchStoreID +''','''+ @DocDateTo +''',''' + @TmpProductID + ''',''' + @BatchNo + ''',' + LTrim(CONVERT(Nvarchar(40),@ProductQty,128)) + ',' + Str(@SerialNo) + ',' + Str(@ProdStepID) + ',1)'
			
	END
	ELSE if @NotGroupByGoodsIDInProduct = 'False' 
	BEGIN
		set @StrSelect = '
			insert into #tbl_Prd_ProductGoods_One_UseSimilar_Result(FormulaNo, GoodsID, Quantity,SubUnitQuantity,UnitID, DefaultStoreID, ProductCount,DocRowNo,DescDtl)
			select	H.SerialNo, D.GoodsID, 
			round(sum((case when D.ParamKind=0 THEN ' + LTrim(CONVERT(Nvarchar(40),@ProductQty,128)) + ' ELSE ' + LTrim(CONVERT(Nvarchar(40),@FmlParam1,128)) + ' END  / case when D.ParamKind=0 THEN H.ProductCount ELSE H.FmlParam1 END) * D.GoodsQuantity),'+ str(@QuantityDecimalsToForms)+') as Quantity,
			round(sum((case when D.ParamKind=0 THEN ' + LTrim(CONVERT(Nvarchar(40),@ProductQty,128)) + ' ELSE ' + LTrim(CONVERT(Nvarchar(40),@FmlParam1,128)) + ' END / case when D.ParamKind=0 THEN H.ProductCount ELSE H.FmlParam1 END) * D.SubUnitQuantity),'+ str(@QuantityDecimalsToForms)+') as SubUnitQuantity,UnitID,
			'
			IF @StorIDHdr = 1
				set @StrSelect += '''' + @StoreID + ''', H.ProductCount'
			else
				set @StrSelect += '		 D.DefaultStoreID, H.ProductCount'
			 set @StrSelect += ',0,''''
			FROM	prd.tblFormulasDtl D
			INNER JOIN prd.tblFormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID
			where  (H.ProductID = ''' + @TmpProductID + ''') and ' + @StrWhere + '
			group by H.SerialNo, D.GoodsID,UnitID, D.DefaultStoreID, ProductCount,DescDtl'


			update 	#tbl_Prd_ProductGoods_One_UseSimilar_Result 
			set DocRowNo=ISNULL(D.DocRowNo,0)
				from #tbl_Prd_ProductGoods_One_UseSimilar_Result M
					left join prd.tblFormulasHdr H on H.ProductID=@TmpProductID  and (H.SerialNo=@SerialNo or (@SerialNo=0 and  IsDefault=1 ))
				left join prd.tblFormulasDtl D on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID and D.GoodsID=M.GoodsID

	END
	ELSE
	BEGIn
		set @StrSelect = '
			insert into #tbl_Prd_ProductGoods_One_UseSimilar_Result(FormulaNo, GoodsID, Quantity,SubUnitQuantity,UnitID, DefaultStoreID, ProductCount,DocRowNo,DescDtl)
			select	H.SerialNo, D.GoodsID, 
			round((case when D.ParamKind=0 THEN ' + LTrim(CONVERT(Nvarchar(40),@ProductQty,128)) + ' ELSE ' + LTrim(CONVERT(Nvarchar(40),@FmlParam1,128)) + ' END  / case when D.ParamKind=0 THEN H.ProductCount ELSE H.FmlParam1 END) * D.GoodsQuantity, '+ str(@QuantityDecimalsToForms)+') as Quantity,
			round((case when D.ParamKind=0 THEN ' + LTrim(CONVERT(Nvarchar(40),@ProductQty,128)) + ' ELSE ' + LTrim(CONVERT(Nvarchar(40),@FmlParam1,128)) + ' END / case when D.ParamKind=0 THEN H.ProductCount ELSE H.FmlParam1 END) * D.SubUnitQuantity, '+ str(@QuantityDecimalsToForms)+') as SubUnitQuantity,UnitID,
			'
			IF @StorIDHdr = 1
				set @StrSelect += '''' + @StoreID + ''', H.ProductCount'
			else
				set @StrSelect += '		 D.DefaultStoreID, H.ProductCount'
			 set @StrSelect += ',D.DocRowNo,isnull(D.DescDtl,'''') DescDtl
			FROM	prd.tblFormulasDtl D
			INNER JOIN prd.tblFormulasHdr H on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID
			where  (H.ProductID = ''' + @TmpProductID + ''') and ' + @StrWhere + '
			'
	END
	-----------------------------------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	update 	#tbl_Prd_ProductGoods_One_UseSimilar_Result 
	set DefaultStoreID=@StoreID
	where DefaultStoreID is null or DefaultStoreID=''
	---------- بررسی مواد اولیه براساس موجودی آن------------------------------------------------------------
	DECLARE crsr_Goods CURSOR FOR
		select	T.FormulaNo, T.GoodsID, T.Quantity,T.SubUnitQuantity,T.UnitID,T.DefaultStoreID,T.DocRowNo,T.DescDtl
		from	#tbl_Prd_ProductGoods_One_UseSimilar_Result T
		order by T.FormulaNo, T.GoodsID

	OPEN crsr_Goods
	FETCH NEXT FROM crsr_Goods INTO @FormulaNo, @GoodsID, @Quantity,@SubUnitQuantity,@UnitID,@DefaultStoreID,@DocRowNo,@DescDtl

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF @StorIDHdr = 1
			SET @DefaultStoreID = @StoreID
		
		set @Balance=0 
		select @Balance = isnull(round( [inv].[funGetSubUnitFromGoodsQuantity](GoodsID,@UnitID,Sum(D.GoodsQuantity*EnterKind)),@QuantityDecimalsToForms ),0)
		from inv.tblStorageDocsDtl D
		where (GoodsID = @GoodsID) and (DocDate <= @DocDateTo) and (@DefaultStoreID ='' or (@DefaultStoreID <>'' and D.StoreID=@DefaultStoreID))	
		group by GoodsID

	 -----------کمبود موجودی و استفاده از مشابه--------------------------------------------------------------------------
		if (@Balance < @SubUnitQuantity) and @Prd_UseSimilarGoodsInProduce ='True'
		begin
	 
			set @GoodsIDX = null;
			delete from #tbl_Prd_ProductGoods_Similar;
		
			declare @ComplateType bit
			select @ComplateType=ComplateType from prd.tblFormulasHdr 
			where (ProductID=@TmpProductID) and (SerialNo = @FormulaNo) 

			insert into #tbl_Prd_ProductGoods_Similar(DocRowNo,		ProductCount,	GoodsID		,UnitID,	DefaultStoreID, Quantity, Value1,Value2)
			select	FD.DocRowNo,ProductCount, FA.GoodsID,FA.SubUnitID,FD.DefaultStoreID  
				,isnull(round([inv].[funGetSubUnitFromGoodsQuantity](FA.GoodsID,FA.SubUnitID,SUM(D.GoodsQuantity*D.EnterKind)),@QuantityDecimalsToForms ),0)			
				,FD.SubUnitQuantity,FA.SubUnitQuantity			
			from inv.tblStorageDocsDtl D
					inner join prd.tblFormulasAtm FA on FA.GoodsID=D.GoodsID 
					inner join prd.tblFormulasHdr FH on FH.ProductID=FA.ProductID and FH.SerialNo=FA.SerialNo
					inner join prd.tblFormulasDtl FD on FD.ProductID=FA.ProductID and FD.SerialNo=FA.SerialNo and FD.DocRowNo=FA.DocRowNo
			where (FA.ProductID=@TmpProductID) 
					and (FA.SerialNo = @FormulaNo) 
					and (FD.GoodsID = @GoodsID) 
					and (D.DocDate <= @DocDateTo)
					and (@DefaultStoreID ='' or (@DefaultStoreID <>'' and D.StoreID=@DefaultStoreID))
					and (@ComplateType=0 or (@ComplateType=1 and FA.GoodsID <> @GoodsID  ))
			group by FD.DocRowNo,FH.ProductCount, FA.GoodsID, FA.GoodsQuantity, FA.DocAtomRowNo,FD.DefaultStoreID ,FA.SubUnitID,FA.SubUnitQuantity,FD.SubUnitQuantity
			having  @ComplateType=0  or round(SUM(D.GoodsQuantity*D.EnterKind),@QuantityDecimalsToForms ) >= round((@ProductQty / FH.ProductCount) * FA.GoodsQuantity,@QuantityDecimalsToForms )
			order by FA.DocAtomRowNo
		
			delete from #tbl_Prd_ProductGoods_Similar 
				where Quantity<=0 
------------------------------------------------------------------------
		BEGIN TRY
			DROP TABLE #tbl_Prd_ProductGoods_SimilarSum
		END TRY
		BEGIN CATCH
		END CATCH
			select *  into #tbl_Prd_ProductGoods_SimilarSum  from #tbl_Prd_ProductGoods_Similar 
			where 1=0

			insert into #tbl_Prd_ProductGoods_SimilarSum			
			select  min(DocRowNo),ProductCount,GoodsID,UnitID, DefaultStoreID ,sum(Quantity)    ,sum(Value1)    ,sum(Value2)    from #tbl_Prd_ProductGoods_Similar 
			group by ProductCount,GoodsID,UnitID, DefaultStoreID  

			delete from #tbl_Prd_ProductGoods_Similar
			insert into #tbl_Prd_ProductGoods_Similar 			
			select *  from  #tbl_Prd_ProductGoods_SimilarSum  
------------------------------------------------------------------------
			Declare @TmpQty float
			Declare @TmpSubQty float
			Declare @Value1 float
			Declare @Value2 float

			------استفاده از کالا ی مشابه---------------------------------------
		if (select COUNT(*) from #tbl_Prd_ProductGoods_Similar) > 0
		begin		
			update #tbl_Prd_ProductGoods_Similar
			set DefaultStoreID=(select Top 1 DefaultStoreID from #tbl_Prd_ProductGoods_One_UseSimilar_Result where GoodsID = @GoodsID)
			-------تمامی مواد از یک کالای مشابه برداشه شود ----------------------------------------------------------------
			if @ComplateType=1
			begin
				set @TmpQty=@SubUnitQuantity
				if (Select Count(*) from #tbl_Prd_ProductGoods_Similar where  @TmpQty/Value1<=Quantity/Value2)>0
				begin
						delete from #tbl_Prd_ProductGoods_One_UseSimilar_Result where GoodsID = @GoodsID
	
						insert into #tbl_Prd_ProductGoods_One_UseSimilar_Result(FormulaNo	,GoodsID,	Quantity	,SubUnitQuantity,	UnitID	,DefaultStoreID	,ProductCount	,DocRowNo,	DescDtl)
						select top 1 @FormulaNo,GoodsID,@TmpQty/Value1*Value2,@TmpQty/Value1*Value2,UnitID,DefaultStoreID,ProductCount,DocRowNo,'' from #tbl_Prd_ProductGoods_Similar  where  @TmpQty/Value1<=Quantity/Value2
						select @TmpQty= 0		
				end 
			end		
			-------تمامی مواد از کالای مشابه تکمیل شود ----------------------------------------------------------------
			if @ComplateType=0
			begin		
				
				set @TmpQty=@SubUnitQuantity

				if @Balance>0
				begin
					set @TmpQty=@TmpQty-@Balance
					Update  #tbl_Prd_ProductGoods_One_UseSimilar_Result	
						set SubUnitQuantity=@Balance
					where GoodsID =@GoodsID
				end	 
				else
				begin
					Update  #tbl_Prd_ProductGoods_One_UseSimilar_Result	
						set SubUnitQuantity=0
						where GoodsID =@GoodsID
				end	 
							
				DECLARE crsr_Goods_Qty CURSOR FOR
				select GoodsID,Value1	,Value2 from #tbl_Prd_ProductGoods_Similar

				OPEN crsr_Goods_Qty
				FETCH NEXT FROM crsr_Goods_Qty INTO  @GoodsIDX,@Value1,@Value2

				WHILE (@@FETCH_STATUS = 0 and 0<@TmpQty  )
				BEGIN
				
				--select @TmpQty,* from #tbl_Prd_ProductGoods_One_UseSimilar_Result 
				-- select @TmpQty,* from #tbl_Prd_ProductGoods_Similar 

					if (Select Count(*) from #tbl_Prd_ProductGoods_Similar where GoodsID=@GoodsIDX and @TmpQty/Value1>Quantity/Value2)>0
					begin
							insert into #tbl_Prd_ProductGoods_One_UseSimilar_Result(FormulaNo	,GoodsID,	Quantity	,SubUnitQuantity,	UnitID	,DefaultStoreID	,ProductCount	,DocRowNo,	DescDtl)
							select @FormulaNo,GoodsID,Quantity,Quantity,UnitID,DefaultStoreID,ProductCount,DocRowNo,'' from #tbl_Prd_ProductGoods_Similar  where  GoodsID =@GoodsIDX
							select @TmpQty= (@TmpQty/Value1-Quantity/Value2 )*Value1 from #tbl_Prd_ProductGoods_Similar  where  GoodsID =@GoodsIDX
							delete from #tbl_Prd_ProductGoods_Similar  where  GoodsID =@GoodsIDX
					end 
					else 
					begin
							insert into #tbl_Prd_ProductGoods_One_UseSimilar_Result(FormulaNo	,GoodsID,	Quantity	,SubUnitQuantity,	UnitID	,DefaultStoreID	,ProductCount	,DocRowNo,	DescDtl)
							select @FormulaNo,GoodsID,@TmpQty/Value1*Value2,@TmpQty/Value1*Value2,UnitID,DefaultStoreID,ProductCount,DocRowNo,'' from #tbl_Prd_ProductGoods_Similar  where  GoodsID =@GoodsIDX
							select @TmpQty= 0							
							delete from  #tbl_Prd_ProductGoods_One_UseSimilar_Result	where GoodsID =@GoodsID and @Balance<=0							
					end 

					FETCH NEXT FROM crsr_Goods_Qty INTO   @GoodsIDX,@Value1,@Value2
		
				END

				CLOSE crsr_Goods_Qty
				DEALLOCATE crsr_Goods_Qty
	
		 		if @TmpQty>0
					update #tbl_Prd_ProductGoods_One_UseSimilar_Result set SubUnitQuantity=SubUnitQuantity+@TmpQty where GoodsID=@GoodsID  
		 
			end	
	end	
		else
			delete from #tbl_Prd_ProductGoods_Similar	
				
	end	
	FETCH NEXT FROM crsr_Goods INTO @FormulaNo, @GoodsID, @Quantity,@SubUnitQuantity,@UnitID,@DefaultStoreID	,@DocRowNo	,@DescDtl
	END

	CLOSE crsr_Goods
	DEALLOCATE crsr_Goods
	--select * from #tbl_Prd_ProductGoods_One_UseSimilar_Result

	--return 
	update #tbl_Prd_ProductGoods_One_UseSimilar_Result
		set DescDtl=isnull(DescDtl,'')
		,Quantity=	[inv].[funGetGoodsQuantityFromSubUnit](GoodsID,UnitID,SubUnitQuantity)
		 
	update 	#tbl_Prd_ProductGoods_One_UseSimilar_Result 
	set DocRowNo=ISNULL(D.DocRowNo,0)
		from #tbl_Prd_ProductGoods_One_UseSimilar_Result M
			left join prd.tblFormulasHdr H on H.ProductID=@TmpProductID  and (H.SerialNo=@SerialNo or (@SerialNo=0 and  IsDefault=1 ))
		left join prd.tblFormulasDtl D on D.SerialNo = H.SerialNo and D.ProductID = H.ProductID and D.GoodsID=M.GoodsID
		where M.DocRowNo=0

	select * from (
			select M.ProductID	,M.GoodsID	, round( M.Quantity,@QuantityDecimalsToForms) Quantity, round( M.SubUnitQuantity,@QuantityDecimalsToForms) SubUnitQuantity	 ,M.UnitID	,M.DefaultStoreID	,M.ProductCount	,M.DocRowNo	,M.DescDtl,M.ExtraField1,M.ExtraField2,M.ExtraField3,M.ExtraField4,M.ExtraField5	
				, [pub].[funGetGoodsName](M.GoodsID, @LangID) As GoodsName,isnull( UD.UnitID,'') UnitID2, isnull(UD.UnitName,'') UnitName
				,ISNULL((
						select ROUND(SUM(GoodsQuantity*EnterKind), @QuantityDecimalsToForms)
						from inv.tblStorageDocsDtl D
						where D.GoodsID = M.GoodsID
							and (DocDate <= @DocDateTo) 
							and ((@StorIDHdr = 1 and @StoreID ='') or ( (M.DefaultStoreID <>''  AND D.StoreID = M.DefaultStoreID) OR (M.DefaultStoreID ='' AND (D.StoreID =@StoreID OR @StoreID=''))))
					),0) Balance
				,[inv].[funGetSubGoodsRemain](NULL,NULL,NULL,NULL,NULL,CASE WHEN M.DefaultStoreID <>'' THEN  M.DefaultStoreID ELSE @StoreID END,M.GoodsID,UD.UnitID,@DocDateTo,'',0) SubBalance
	from
	(
		select cast(@ProductID as varchar(20)) ProductID, T.GoodsID, SUM(T.Quantity) Quantity, SUM(T.SubUnitQuantity) SubUnitQuantity,T.UnitID,T.DefaultStoreID, T.ProductCount,T.DocRowNo,T.DescDtl,G.ExtraField1,G.ExtraField2,G.ExtraField3,G.ExtraField4,G.ExtraField5
		from #tbl_Prd_ProductGoods_One_UseSimilar_Result T	
		Left join inv.tblGoods G on G.GoodsID=SUBSTRING(T.GoodsID,@str_Goods+1, @str_GoodsSum)
		group by T.GoodsID,T.UnitID, T.DefaultStoreID, T.ProductCount,T.DocRowNo,T.DescDtl,G.ExtraField1,G.ExtraField2,G.ExtraField3,G.ExtraField4,G.ExtraField5
	) M
		left join inv.tblUnitsDtl UD on UD.UnitID  = M.UnitID
	where M.Quantity > 0
	) M 
	order by ISnull(M.DocRowNo,0),GoodsName,M.ProductID, M.GoodsID 	

END
GO
