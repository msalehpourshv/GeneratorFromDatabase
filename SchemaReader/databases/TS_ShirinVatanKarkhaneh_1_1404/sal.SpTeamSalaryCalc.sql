USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1400/09/03
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < محاسبه درصد بازاریاب >
-- ==============================================
Create PROCEDURE sal.SpTeamSalaryCalc
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrSelect		NVarChar(Max);
	DECLARE @StrWhereH		NVarChar(Max);
	DECLARE @StrWhereD		NVarChar(Max);
	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; 
	DECLARE	@ReportID		Int;
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;

	Declare @StartLayer		TINYINT;
	Declare @LayerLen		TINYINT;
	Declare @PartNumber		TINYINT;
	Declare @StartLayer1	TINYINT;
	Declare @LayerLen1		TINYINT;
	Declare @StartLayer2	TINYINT;
	Declare @LayerLen2		TINYINT;
	Declare @StartLayer3	TINYINT;
	Declare @LayerLen3		TINYINT;
	Declare @StartLayer4	TINYINT;
	Declare @LayerLen4		TINYINT;
		
	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5);
	
	declare @CallType			Int;
	declare @ShowNoZeroRows		Int;
	declare @MonthCode			varchar(2);
	declare @CustomerKindID		varchar(20);
	declare @GoodsID			varchar(20);
	declare @GoodsGroupID		varchar(20);
	declare @SaleTypeID			varchar(20);
	declare @AcntCode1			varchar(20);
	declare @AcntCode2			varchar(20);
	declare @AcntCode3			varchar(20);
	declare @AcntCode4			varchar(20);
	declare @VisitorPercent		varchar(20);
	declare @VisitorPercent2	varchar(20);	

	declare @FromAmount float;
	declare @ToAmount	float;
	declare @FromQty	float;
	declare @ToQty		float;
	SET @CallType		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @MonthCode		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 		
	SET @ShowNoZeroRows	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 		

	if @CallType=3
	begin

 		select REPLACE(VisitorAcntCode ,' ','-') VisitorAcntCode,[pub].[GetCodeName](VisitorAcntCode,1 ) VisitorName from (
			Select  distinct VisitorAcntCode  from inv.tblStorageDocsHdr 
				where VisitorAcntCode   <> '' and cast (SUBSTRING(DocDate,6,2) as int) =@MonthCode
			except
			select VisitorAcntCode
				from sal.tblTeamPolicies2TeamDtl a
				inner join sal.tblTeamVisitorDtl b on a.TeamID=b.TeamID and  a.MonthCode=b.MonthCode
				where 	a.MonthCode=@MonthCode	)a
		order by [pub].[GetCodeName](VisitorAcntCode,1 ) 
		return  
	end 
if @CallType=1
begin

	SET @StrWhereH = ''
	SET @StrWhereD = ''  
		
	DECLARE @GroupBy		NVarChar(Max);
	DECLARE @FilterLink		NVarChar(Max);
	DECLARE @FilterLink2	NVarChar(Max);
	DECLARE @FieldName		NVarChar(Max);
	Declare @LinkType		TINYINT;
	Declare @LinkTable1		TINYINT;
	Declare @LinkTable2		TINYINT;
	Declare @LinkTable3		TINYINT;
	DECLARE @JoinHdrDtl		NVarChar(Max);
	DECLARE @JoinHdrAcnt	NVarChar(Max);
	Declare @GoodsName		VARCHAR(200)		

	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
	select @StartLayer=[acc].[FunGetAcntInfoForRemain](2)
	select @LayerLen=[acc].[FunGetAcntInfoForRemain](3)

	select @StartLayer1=[acc].[funGetAcntLayerStartandLen](1,1)
	select @LayerLen1=[acc].[funGetAcntLayerStartandLen](1,2)
	select @StartLayer2=[acc].[funGetAcntLayerStartandLen](2,1)
	select @LayerLen2=[acc].[funGetAcntLayerStartandLen](2,2)	
	select @StartLayer3=[acc].[funGetAcntLayerStartandLen](3,1)
	select @LayerLen3=[acc].[funGetAcntLayerStartandLen](3,2)
	select @StartLayer4=[acc].[funGetAcntLayerStartandLen](4,1)
	select @LayerLen4=[acc].[funGetAcntLayerStartandLen](4,2)

	delete from   sal.tblTeamSaleResualt   where MonthCode=@MonthCode
	
	insert into  sal.tblTeamSaleResualt  
	(MonthCode, WorkDayInMonth, TeamID, VisitorAcntCodeHdr, VisitorAcntCode, WorkDay,TargetType, SerialNo, DocRowNo, Amount, Qty, Amount2, Qty2, VisitorPrice, VisitorPrice2)
		select  a.MonthCode	,a.WorkDayInMonth	,b.TeamID	--,b.BaseSerialNo
			,d.VisitorAcntCode  VisitorAcntCodeHdr
			,e.VisitorAcntCode  ,e.WorkDay
			, TargetType ,c.SerialNo,c.DocRowNo
			,cast( 0 as float) Amount , cast( 0 as float) Qty
			,cast( 0 as float) Amount2, cast( 0 as float) Qty2
			, cast( 0 as float) VisitorPrice , cast( 0 as float)  VisitorPrice2
		from sal.tblTeamPolicies2TeamHdr a
			inner join sal.tblTeamPolicies2TeamDtl b on a.MonthCode=b.MonthCode
			inner join sal.tblTeamPoliciesDtl c on b.BaseSerialNo=c.SerialNo
			inner join sal.tblTeamPoliciesHdr cc on cc.SerialNo=c.SerialNo and cc.ProcessID=c.ProcessID
			inner join sal.tblTeam d on b.TeamID=d.TeamID
			inner join sal.tblTeamVisitorDtl e on e.TeamID=d.TeamID and e.MonthCode=a.MonthCode
		where a.MonthCode=@MonthCode
				
		declare @SerialNo int 
		declare @DocRowNo int 
		
	DECLARE csr CURSOR FOR 
		SELECT Distinct SerialNo, DocRowNo
		FROM sal.tblTeamSaleResualt   
		where MonthCode=@MonthCode
				
	OPEN csr
	FETCH NEXT FROM csr INTO @SerialNo, @DocRowNo

	WHILE @@Fetch_Status = 0
	BEGIN

		select 
			@CustomerKindID=CustomerKindID
			,@GoodsID=GoodsID 
			,@GoodsGroupID=GoodsGroupID 
			,@SaleTypeID	=SaleTypeID	 
			,@AcntCode1=AcntCode1 
			,@AcntCode1=AcntCode1 
			,@AcntCode2=AcntCode2 
			,@AcntCode3=AcntCode3 
			,@AcntCode4=AcntCode4 
			,@FromAmount=FromAmount 
			,@ToAmount=ToAmount 
			,@FromQty=FromQty 
			,@ToQty=ToQty 
			,@VisitorPercent=VisitorPercent 
			,@VisitorPercent2=VisitorPercent2 	
		from sal.tblTeamPoliciesDtl 
		where SerialNo=@SerialNo and DocRowNo=@DocRowNo
	
		SET @StrWhereH =' AND H.ProcessID in (90,100) AND substring(H.DocDate,6,2)='''+ @MonthCode +''''	
		SET @StrWhereD =' AND D.ProcessID in (90,100) AND substring(D.DocDate,6,2)='''+ @MonthCode +''''	

		SET @StrWhereH =@StrWhereH+' AND H.VisitorAcntCode in (select VisitorAcntCode from sal.tblTeamSaleResualt where SerialNo='+str(@SerialNo)+' and DocRowNo='+str(@DocRowNo)+' and MonthCode='+str(@MonthCode)+')'	

		IF (@CustomerKindID  <> '')	
			SET @StrWhereH = @StrWhereH + ' AND  substring(H.AcntCode,'+str(@StartLayer)+','+str(@LayerLen)+') in ( select AcntCode From  acc.tblAcnt where CustomerKindID=''' + @CustomerKindID + ''')'		

		IF (@GoodsID  <> '')	
			SET @StrWhereD = @StrWhereD + ' AND  substring(D.GoodsID,1,len('+@GoodsID+'))= '''+@GoodsID+''' '	
	
		IF (@GoodsGroupID  <> '')	
			SET @StrWhereD = @StrWhereD + ' AND  D.GoodsID in (Select GoodsID	From   inv.tblGoodsGroupsGoodsListDtl	where GoodsGroupID=''' +@GoodsGroupID +''')'	

		IF (@SaleTypeID   <> '')	
		begin
			SET @StrWhereH = @StrWhereH + ' AND H.SaleTypeID= '''+@SaleTypeID+''' '	
			SET @StrWhereD = @StrWhereD + ' AND D.SaleTypeID= '''+@SaleTypeID+''' '	
		end
		IF (@AcntCode1   <> '')	
		begin
			SET @StrWhereH = @StrWhereH + ' AND substring(H.AcntCode,'+str(@StartLayer1)+','+str(len(@AcntCode1))+') = '''+@AcntCode1+''' '	
			SET @StrWhereD = @StrWhereD + ' AND substring(D.AcntCode,'+str(@StartLayer1)+','+str(len(@AcntCode1))+') = '''+@AcntCode1+''' '	
		end
		IF (@AcntCode2   <> '')	
		begin
			SET @StrWhereH = @StrWhereH + ' AND substring(H.AcntCode,'+str(@StartLayer2)+','+str(len(@AcntCode2))+') = '''+@AcntCode2+''' '	
			SET @StrWhereD = @StrWhereD + ' AND substring(D.AcntCode,'+str(@StartLayer2)+','+str(len(@AcntCode2))+') = '''+@AcntCode2+''' '	
		end
		IF (@AcntCode3   <> '')	
		begin
			SET @StrWhereH = @StrWhereH + ' AND substring(H.AcntCode,'+str(@StartLayer3)+','+str(len(@AcntCode3))+') = '''+@AcntCode3+''' '	
			SET @StrWhereD = @StrWhereD + ' AND substring(D.AcntCode,'+str(@StartLayer3)+','+str(len(@AcntCode3))+') = '''+@AcntCode3+''' '	
		end

		IF (@AcntCode4   <> '')	
		begin
			SET @StrWhereH = @StrWhereH + ' AND substring(H.AcntCode,'+str(@StartLayer4)+','+str(len(@AcntCode4))+') = '''+@AcntCode4+''' '	
			SET @StrWhereD = @StrWhereD + ' AND substring(D.AcntCode,'+str(@StartLayer4)+','+str(len(@AcntCode4))+') = '''+@AcntCode4+''' '	
		end
		Begin
			BEGIN TRY
				DROP TABLE  #tblStorageDocsHdr
				DROP TABLE #tblStorageDocsDtl
			END TRY
			BEGIN CATCH
			END CATCH
		End
	
		select *
		into #tblStorageDocsHdr
		from inv.tblStorageDocsHdr
		where 1=0

		select *
			,cast( 0 as float ) as DiscountHdrs
			,cast( 0 as float ) as PriceDtl
			,cast( 0 as float ) as SumPriceDtl
			,cast( 0 as float ) as PriceAfterDiscounts
		into #tblStorageDocsDtl
		from inv.tblStorageDocsDtl
		where 1=0

		set @StrSelect = 
			' Insert into #tblStorageDocsHdr 
			 Select   * from inv.tblStorageDocsHdr H 
			 where H.ProcessID in(90,100)  '+ @StrWhereH +' ' 

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;

		set @StrSelect = 
			' Insert into #tblStorageDocsDtl 
			 Select D.* 
				,Discount+Discount2+Discount3+AfterSaleDiscount DiscountHdrs
				,ISNULL(GoodsPrice*GoodsQuantity -DiscountDtl, 0)PriceDtl
				,0  SumPriceDtl 
				,0  PriceAfterDiscounts
			 from inv.tblStorageDocsDtl D 
				inner join #tblStorageDocsHdr H 
					On H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
			 where D.ProcessID in(90,100) '+ @StrWhereD +' '+ @StrWhereH +' ' 

		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
	
	Update #tblStorageDocsDtl 
		set SumPriceDtl =b.SumPriceDtl
	from #tblStorageDocsDtl a
		inner join (select sum(ISNULL(GoodsPrice*GoodsQuantity-DiscountDtl, 0) ) SumPriceDtl, ProcessID,ProcessNo, FiscalYear,SerialNo from  #tblStorageDocsDtl Group by ProcessID,ProcessNo, FiscalYear,SerialNo)b
		on a.ProcessID=b.ProcessID	and a.ProcessNo=b.ProcessNo	and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
	
	Update #tblStorageDocsDtl 
		set PriceAfterDiscounts=PriceDtl-DiscountHdrs*PriceDtl/ SumPriceDtl

	
	 if @GoodsID<>'' or @GoodsGroupID<>'' or @FromQty<>0 or @ToQty<>0	
		begin
			update  sal.tblTeamSaleResualt 
				set Amount =b.Amount,Qty=b.Qty
			from  sal.tblTeamSaleResualt a
				inner join(select sum(PriceAfterDiscounts*EnterKind*-1) Amount, sum(GoodsQuantity*EnterKind*-1) Qty , VisitorAcntCode from  #tblStorageDocsDtl Group by VisitorAcntCode) b
				on a.VisitorAcntCode=b.VisitorAcntCode
			where a.MonthCode=@MonthCode and a.SerialNo=@SerialNo and a.DocRowNo=@DocRowNo
		end
	else
		begin
			update  sal.tblTeamSaleResualt 
				set Amount =b.Amount,Qty=0
			from  sal.tblTeamSaleResualt a
				inner join (select sum(Amount-AfterSaleDiscount) Amount, VisitorAcntCode from  #tblStorageDocsHdr Group by VisitorAcntCode) b 
				on a.VisitorAcntCode=b.VisitorAcntCode
			where a.MonthCode=@MonthCode and a.SerialNo=@SerialNo and a.DocRowNo=@DocRowNo
		end
	
		update sal.tblTeamSaleResualt 
			set Amount2=AvgAmount
			,Qty2= AvgQty
		from sal.tblTeamSaleResualt a 
			inner join (Select *
					,case when TargetType=1 then Amount else case when WorkDay> WorkDayInMonth then Amount/WorkDayInMonth else Amount/WorkDay  end end AvgAmount
					,case when TargetType=1 then Qty else case when WorkDay> WorkDayInMonth then Qty/WorkDayInMonth else Qty/WorkDay  end end AvgQty
					from sal.tblTeamSaleResualt ) b
			on  a.MonthCode=b.MonthCode
				and a.TeamID=b.TeamID
				and  a.VisitorAcntCode=b.VisitorAcntCode
				and  a.SerialNo=b.SerialNo
				and  a.DocRowNo=b.DocRowNo
			where a.MonthCode=@MonthCode and a.SerialNo=@SerialNo and a.DocRowNo=@DocRowNo

	FETCH NEXT FROM csr INTO  @SerialNo, @DocRowNo
	END

	CLOSE csr
	DEALLOCATE csr

	update sal.tblTeamSaleResualt
		set  VisitorPrice=Amount*VisitorPercent/100 ,   VisitorPrice2=Amount*VisitorPercent2/100
	from sal.tblTeamSaleResualt a 
		inner join sal.tblTeamPoliciesDtl b
		on a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
	where a.MonthCode=@MonthCode
	and (FromQty=0 or 	(FromQty<>0 and Qty2>=FromQty))
	and (ToQty=0 or 	(ToQty<>0 and Qty2<=ToQty))
	and (FromAmount=0 or 	(FromAmount<>0 and Amount2>=FromAmount))
	and (ToAmount=0 or 	(ToAmount<>0 and Amount2<=ToAmount))

end 

	select 	 MonthCode,WorkDayInMonth	,TeamName	,VisitorAcntCodeHdr,[pub].[GetCodeName](VisitorAcntCodeHdr,1)	VisitorAcntCodeHdrName,a.VisitorAcntCode,[pub].[GetCodeName](a.VisitorAcntCode,1)VisitorName
		,WorkDay,Case when TargetType=0 then 'روزانه' else 'ماهانه' end	TargetType,a.SerialNo,a.DocRowNo	
		,Amount	,Qty	,Amount2	,Qty2	,cast (VisitorPrice	as int )VisitorPrice,cast (VisitorPrice2	as int )VisitorPrice2	,DescDtl,VisitorCostAcntCode
	from  sal.tblTeamSaleResualt a
		inner join sal.tblTeamPoliciesDtl b 	on a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo	
		inner join  sal.tblTeamDtl t on t.TeamID=a.TeamID
		inner join  sal.tblTeam th on th.TeamID=a.TeamID
	where a.MonthCode=@MonthCode
	and (@ShowNoZeroRows =0 or (@ShowNoZeroRows =1 and VisitorPrice>0 ) )
	order by a.VisitorAcntCode,a.SerialNo,a.DocRowNo
END
GO
