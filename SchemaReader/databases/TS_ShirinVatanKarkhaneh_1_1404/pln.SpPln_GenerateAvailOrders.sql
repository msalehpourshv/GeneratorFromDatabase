USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ===================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/05/12
-- Viewed By	 : 
-- Last Modified : 1394/02/17
-- Last Modifier : TakroSystem\Zia
-- درج کالاهای تولید شدنی برای یک سفارش تولید
-- =============================================
--exec [pln].[SpPln_GenerateAvailOrders] @ProcSet=N'600@2@95@3',@RepOptions=N'',@RepInfo=N'1@1381@1'
Create PROCEDURE [pln].[SpPln_GenerateAvailOrders]
	@ProcSet		VarChar(20),
	@RepOptions		VarChar(20) = '', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare	@ProductID			VarChar(20);
declare	@BatchNo			VarChar(20);
declare @ProductQty			Real;
declare @ProcessID			int; 
declare @ProcessNo			int;
declare @FiscalYear			int;
declare @SerialNo			int;
declare @DocRowNo			int;
declare @DocRowNo2			int;
declare @FormulaNo			int;
declare @StepNo				int;
declare @ProductWidht		float; 
declare @ProductHeight		float;
declare @ProductQuantity2	float;
declare @LangID				Char(1);
declare @SessionNo			varChar(10);
declare @ReportID			varChar(10);
declare @StrSelect			nvarchar(4000);
declare @StrWhere			nvarchar(2000);
declare @StrWhere2			nvarchar(2000);
declare @StepDefault		int;
declare @FormulaDefault		int;
Declare @strMsgText			NVarChar(2044)

BEGIN
	SET NOCOUNT ON;

	create table #tbl_Avail_Tmp
	(
		GoodsID				varchar(20) collate arabic_cs_as,
		Quantity			float,
		FormulaNo			int,
		StepNo				int,
		PrdStep				int,
		ProductWidth		float,
		ProductHeight		float,
		ProductQuantity2	float,
		BaseDocRowNo		int	,
		LevelStr			nvarchar(500) ,
		BatchNo				varchar(20) 
	);
	
	-- Init ---------------------------------------------------------------------
	IF (@RepInfo Is Null)	 SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null) SET @RepOptions = '1';

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @StepDefault	= pub.funSplitString(@RepInfo, '@', 4);
	SET @FormulaDefault	= pub.funSplitString(@RepInfo, '@', 5);

	SET @ProcessID		= pub.funSplitString(@ProcSet, '@', 1);
	SET @ProcessNo		= pub.funSplitString(@ProcSet, '@', 2);
	SET @FiscalYear		= pub.funSplitString(@ProcSet, '@', 3);
	SET @SerialNo		= pub.funSplitString(@ProcSet, '@', 4);
	SET @DocRowNo2		= pub.funSplitString(@ProcSet, '@', 5);

	if @DocRowNo2 is null
		set @DocRowNo2=0
	
	-----------------------------------------------------------------------------
	-- Process ------------------------------------------------------------------
	DECLARE @UnitPart	TINYINT
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
	
	SELECT	 * into #tblFormulasHdr 
	FROM	prd.tblFormulasHdr 
	where 1=0		

	declare crs_Prods cursor for 
		select ProductID, ProductCount, FormulaNo, StepNo, ProductWidth, ProductHeight, ProductQuantity2,DocRowNo,BatchNo
		from pln.tblProduceOrderDtl
		where (ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo)
		and (@DocRowNo2=0 or DocRowNo=@DocRowNo2)

	open crs_Prods;
	fetch next from crs_Prods into @ProductID, @ProductQty, @FormulaNo, @StepNo, @ProductWidht, @ProductHeight, @ProductQuantity2,@DocRowNo,@BatchNo;
	
	while (@@fetch_status = 0)
	begin
			
		if (@FormulaNo = 0)
			continue
			
		set @StrWhere = '(H.SerialNo = ' + Str(@FormulaNo) + ')'
		set @StrWhere2 = ''

		--SELECT	H.*
		--	FROM	prd.tblFormulasHdr H 
		--	where H.ProductID='41060103010004'
		--SELECT	H.*
		--	FROM	prd.tblFormulasDtl D
		--	INNER JOIN prd.tblFormulasHdr H ON (D.SerialNo = H.SerialNo) AND (D.ProductID = H.ProductID) 
		--	where H.ProductID='41060103010004'
		
		delete  FROM	#tblFormulasHdr 
		
		if @FormulaDefault =1
		begin
			insert into #tblFormulasHdr 
			SELECT	 * FROM	prd.tblFormulasHdr where SerialNo=@FormulaNo

			insert into #tblFormulasHdr 
			SELECT	 a.* FROM	prd.tblFormulasHdr a
			inner join 
			(SELECT	ProductID  FROM	prd.tblFormulasHdr where IsDefault=1
			except 	
			SELECT	ProductID  FROM	#tblFormulasHdr  )b 
			on a.ProductID=b.ProductID  
			where a.IsDefault=1
		end 

		if @FormulaDefault =2
			--set @StrWhere2 = '  and (H.SerialNo = ' + Str(@FormulaNo) + ') '
			insert into #tblFormulasHdr 
			SELECT	 * FROM	prd.tblFormulasHdr where SerialNo=@FormulaNo
		if @FormulaDefault =3
		--	set @StrWhere2 = '  and (H.IsDefault=1) '
			insert into #tblFormulasHdr 
			SELECT	 * FROM	prd.tblFormulasHdr where IsDefault=1
		if @FormulaDefault =4
		--	set @StrWhere2 = '  and (H.SerialNo = ' + Str(@FormulaNo) + ')   '
			insert into #tblFormulasHdr 
			SELECT	 * FROM	prd.tblFormulasHdr where SerialNo=@FormulaNo
		
		--select * from #tblFormulasHdr 
		
		
		set @StrSelect = '
		WITH tblTemp(ProductID, GoodsID, Quantity, FormulaNo,LevelStr) AS
		(
			SELECT	H.ProductID, D.GoodsID, (' + str(@ProductQty,20,5) + ' / H.ProductCount) * D.GoodsQuantity As Quantity, H.SerialNo
			,CAST(CAST('+str(@DocRowNo)+' as varchar(500))+''-''+CAST(DocRowNo as varchar(500))+''-''  as  nvarchar(500))  as LevelStr
			FROM	prd.tblFormulasDtl D
						INNER JOIN prd.tblFormulasHdr H ON (D.SerialNo = H.SerialNo) AND (D.ProductID = H.ProductID) 
			WHERE  (H.ProductID = ''' + @ProductID + ''') AND ' + @StrWhere + '
			UNION All
			SELECT	H.ProductID, D.GoodsID, (tblTemp.Quantity / H.ProductCount) * D.GoodsQuantity As Quantity, H.SerialNo
			,CAST(tblTemp.LevelStr + CAST(CAST(DocRowNo as varchar(500))+''-'' as nvarchar(500)) as  nvarchar(500)  ) as LevelStr
			FROM	prd.tblFormulasDtl D
				INNER JOIN #tblFormulasHdr H ON (D.SerialNo = H.SerialNo) AND (D.ProductID = H.ProductID) 
				INNER JOIN 	tblTemp on (H.ProductID = tblTemp.GoodsID) 
		)
		insert  into #tbl_Avail_Tmp (GoodsID, Quantity, FormulaNo, StepNo, PrdStep, ProductWidth, ProductHeight, ProductQuantity2,LevelStr)
		select	tblTemp.GoodsID, sum(tblTemp.Quantity) Quantity, tblTemp.FormulaNo, ' + str(@StepNo) + ',2,0,0,0
		,LevelStr
		from	tblTemp 
			LEFT join inv.tblGoods G on SUBSTRING(tblTemp.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') = G.GoodsID AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + ' AND G.CodeClosed = 0
		where tblTemp.GoodsID in (select ProductID from prd.tblFormulasHdr F where F.OutSourcing = 0 
		) 
		group by tblTemp.GoodsID, tblTemp.FormulaNo,tblTemp.LevelStr
		union all
		select ''' + @ProductID + ''', ' + str(@ProductQty,20,5) +',' + STR(@FormulaNo)+',' + STR(@StepNo)+',1,' + Str(@ProductWidht,LEN(Str(@ProductWidht)),3) + ',' + Str(@ProductHeight,LEN(Str(@ProductHeight)),3) + ',' + Str(@ProductQuantity2,LEN(Str(@ProductQuantity2)),3)+ ',cast(0 as  nvarchar(500))'

		print @StrSelect;
		exec sp_executesql @StrSelect;
		 
	--select * from #tbl_Avail_Tmp
		update #tbl_Avail_Tmp
		set BaseDocRowNo=@DocRowNo
		,BatchNo=@BatchNo
		where isnull(BaseDocRowNo,0)=0
	
		fetch next from crs_Prods into @ProductID, @ProductQty, @FormulaNo, @StepNo, @ProductWidht, @ProductHeight, @ProductQuantity2,@DocRowNo,@BatchNo;
	end;

	close crs_Prods;
	deallocate crs_Prods; 
		
	BEGIN TRY
		DROP TABLE #tblFormulasHdr
	END TRY
	BEGIN CATCH
	END CATCH

	-----------------------------------------------------------------------------
	if (select  count(*) 	from pln.tblProduceOrderHdr where  ProductOnly='True' and (ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo) )>0
	delete from  #tbl_Avail_Tmp
	where LevelStr<>'0' 

	declare crs_Prods cursor for 
	select GoodsID,  FormulaNo, StepNo from  #tbl_Avail_Tmp
	
	open crs_Prods;
	fetch next from crs_Prods into @ProductID,  @FormulaNo, @StepNo
	
	while (@@fetch_status = 0)
	begin

		if @StepDefault =1
		begin
		  --ProductID	SerialNo	ProduceMethodName	RecID	SessionNo	IsDefaultMethod	FormulaNo
		  if (select isnull(count(*),0) from   pln.tblProduceStepHdr  where ProductID =@ProductID and SerialNo=@StepNo)<=0
			  if (select isnull(count(*),0) from   pln.tblProduceStepHdr  where ProductID =@ProductID and IsDefaultMethod=1)<=0
			  begin
				SET @strMsgText='روش پیش فرض برای کالای ' + @ProductID + '   تعریف نشده است '
				Raiserror (@strMsgText,16,1)
				Return 
			  end 
			  else
			  begin		 
					update #tbl_Avail_Tmp
					set StepNo= SerialNo , FormulaNo=s.FormulaNo
					from #tbl_Avail_Tmp a
					inner join   pln.tblProduceStepHdr  s on a.GoodsID=s.ProductID and s.IsDefaultMethod=1
					where a.GoodsID =@ProductID and a.StepNo=@StepNo
			  end 
		end
	if @StepDefault =2
		begin
		  
		  if (select isnull(count(*),0) from   pln.tblProduceStepHdr  where ProductID =@ProductID and SerialNo=@StepNo)<=0
		   begin
				SET @strMsgText='روش تولید تعریف شده برای کالای ' + @ProductID + '   تعریف نشده است '
				Raiserror (@strMsgText,16,1)
				Return
			  end 
		end
	if @StepDefault =3
		 if (select isnull(count(*),0) from   pln.tblProduceStepHdr  where ProductID =@ProductID and IsDefaultMethod=1)<=0
			  begin
				SET @strMsgText='روش پیش فرض برای کالای ' + @ProductID + '   تعریف نشده است '
				Raiserror (@strMsgText,16,1)
				Return
			  end 
			  else
			  begin			  
					update #tbl_Avail_Tmp
					set StepNo= SerialNo , FormulaNo=s.FormulaNo
					from #tbl_Avail_Tmp a
					inner join   pln.tblProduceStepHdr  s on a.GoodsID=s.ProductID and s.IsDefaultMethod=1					
			  end 
		
		if @FormulaDefault =1
		begin
			 if (select isnull(count(*),0) from  prd.tblFormulasHdr  where ProductID =@ProductID and SerialNo=@FormulaNo)<=0
			  if (select isnull(count(*),0) from   prd.tblFormulasHdr  where ProductID =@ProductID and IsDefault=1)<=0
			  begin
				SET @strMsgText='فرمول پیش فرض برای کالای ' + @ProductID + '   تعریف نشده است '
				Raiserror (@strMsgText,16,1)
				Return
			
			  end 
			  else
			  begin
					update #tbl_Avail_Tmp
					set FormulaNo= SerialNo 
					from #tbl_Avail_Tmp a
					inner join    prd.tblFormulasHdr  s on a.GoodsID=s.ProductID and s.IsDefault=1
					where a.GoodsID=@ProductID and a.FormulaNo=@FormulaNo
					update #tbl_Avail_Tmp
					set FormulaNo=s.FormulaNo
					from #tbl_Avail_Tmp a
					inner join   pln.tblProduceStepHdr  s on a.GoodsID=s.ProductID and   a.StepNo= s.SerialNo  
					where a.GoodsID=@ProductID and a.FormulaNo=@FormulaNo
			  end 
	
		end
	if @FormulaDefault =2
		begin
		-- select * from  prd.tblFormulasHdr  where ProductID =@ProductID and SerialNo=@FormulaNo
		 if (select isnull(count(*),0) from  prd.tblFormulasHdr  where ProductID =@ProductID and SerialNo=@FormulaNo)<=0
			  begin
				SET @strMsgText='فرمول تولید تعریف شده برای کالای ' + @ProductID + '   تعریف نشده است '
				Raiserror (@strMsgText,16,1)
				Return
			  end 
		end
	
	if @FormulaDefault =3
		if (select isnull(count(*),0) from   prd.tblFormulasHdr  where ProductID =@ProductID and IsDefault=1)<=0
			  begin
				SET @strMsgText='فرمول پیش فرض برای کالای ' + @ProductID + '   تعریف نشده است '
				Raiserror (@strMsgText,16,1)
				Return
			
			  end 
			  else
			  begin
					update #tbl_Avail_Tmp
					set FormulaNo= SerialNo
					from #tbl_Avail_Tmp a
					inner join    prd.tblFormulasHdr  s on a.GoodsID=s.ProductID and s.IsDefault=1
					update #tbl_Avail_Tmp
					set FormulaNo=s.FormulaNo
					from #tbl_Avail_Tmp a
					inner join   pln.tblProduceStepHdr  s on a.GoodsID=s.ProductID and   a.StepNo= s.SerialNo  
			  end 
		
		fetch next from crs_Prods into @ProductID, @FormulaNo, @StepNo
	end;

	close crs_Prods;
	deallocate crs_Prods; 
	
	
--select * from  #tbl_Avail_Tmp
	--return
	-- Select -------------------------------------------------------------------
	delete 
	from pln.tblAvailProduceOrders
	where (ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo)
		and (@DocRowNo2=0 or BaseDocRowNo=@DocRowNo2)

	select @DocRowNo2=case when isnull( max (RowNo ),0)>isnull( max (DocRowNo ),0) then isnull( max (RowNo ),0) else isnull( max (DocRowNo ),0) end  from   pln.tblAvailProduceOrders
	where (ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo)
	
	insert into pln.tblAvailProduceOrders(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, GoodsID, GoodsQuantity, FormulaNo, StepNo, ProductWidth, ProductHeight, ProductQuantity2,StepDefault,FormulaDefault,BaseDocRowNo,LevelStr,BatchNo	)
	select  @ProcessID, @ProcessNo, @FiscalYear, @SerialNo, T.RowNo+@DocRowNo2, T.RowNo+@DocRowNo2, T.GoodsID, GoodsQuantity, FormulaNo,StepNo, ProductWidth, ProductHeight, ProductQuantity2,@StepDefault,@FormulaDefault,BaseDocRowNo,LevelStr,BatchNo
	from 
	(
		select Row_Number() over (order by GoodsID) as RowNo, *
		from
		(
			select GoodsID, Quantity GoodsQuantity, FormulaNo,StepNo, ProductWidth, ProductHeight, ProductQuantity2,BaseDocRowNo,LevelStr,BatchNo
			from #tbl_Avail_Tmp 
			where PrdStep = 1
			union all
			select GoodsID, Sum(Quantity) GoodsQuantity, FormulaNo,StepNo, ProductWidth, ProductHeight, ProductQuantity2,BaseDocRowNo,LevelStr,BatchNo
			from #tbl_Avail_Tmp 
			where PrdStep > 1
			group by GoodsID, FormulaNo,StepNo, ProductWidth, ProductHeight, ProductQuantity2,BaseDocRowNo,LevelStr,BatchNo
		) X
	) T 
	order by T.GoodsID
	-----------------------------------------------------------------------------
 	if (select  count(*) 	from pln.tblProduceOrderHdr where  ProductOnly='True' and (ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo) )>0
		delete from pln.tblAvailProduceOrders 
		where LevelStr<>'0' AND (ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo)

	declare crs_Prods cursor for 
	
	select GoodsID,FormulaNo
	from pln.tblAvailProduceOrders
	where (ProcessID = @ProcessID) and (ProcessNo = @ProcessNo) and (FiscalYear = @FiscalYear) and (SerialNo = @SerialNo)

	open crs_Prods;
	fetch next from crs_Prods into @ProductID,  @FormulaNo	
	while (@@fetch_status = 0)
	begin
		if ( select Count(*) from  prd.tblFormulasHdr  where ProductID=@ProductID  and SerialNo=@FormulaNo)<=0
			update  pln.tblAvailProduceOrders
			set FormulaNo= (select top 1  SerialNo from  prd.tblFormulasHdr  where ProductID=@ProductID   and IsDefault=1)
			where GoodsID=@ProductID  and FormulaNo=@FormulaNo

		fetch next from crs_Prods into @ProductID, @FormulaNo
	end;

	close crs_Prods;
	deallocate crs_Prods; 
 
END
GO
