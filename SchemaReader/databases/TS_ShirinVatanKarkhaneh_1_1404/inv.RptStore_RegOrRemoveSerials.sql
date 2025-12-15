USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ==================
-- Author		 : jafari	
-- Create date   : 1402/01/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : لیست مغایرت سریالها ;
-- ============================================
 Create PROCEDURE inv.RptStore_RegOrRemoveSerials 
	@SerialNo		VarChar(20),
	@GoodsIDFr		VarChar(20) = Null,
	@GoodsIDTo		VarChar(20) = Null,
	@GoodsIDMask	VarChar(20) = Null, 
	@DocDateTo		VarChar(10) = Null, 
	@SortFields		NVarChar(100) = Null,
	@RepOptions		NVarChar(100) = '111110', 
	@RepInfo		NVarChar(100) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrSelect1	NVarChar(max);
DECLARE @StrWhereSD	NVarChar(2000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StoreID	NVarChar(20);
DECLARE @FiscalYear int;

DECLARE @ShowPrice	Bit; -- شامل ستون قیمت
DECLARE @ZeroAmount	Bit; -- شامل کالاهای با مبلغ صفر
DECLARE @AllGoods	Bit; -- شامل کالاهائی که در سند شمارش نیستند
DECLARE @Decrease	Bit; -- کاهش ها
DECLARE @Increase	Bit; -- افزایش ها
DECLARE @DontFilt	Bit; -- همه کالاها

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@Decimlas	Int;
DECLARE @strRound VARCHAR(50)

DECLARE @ShowPE		Bit; -- مجوزها دخیل نباشد
DECLARE	@CallType	Int;
DECLARE	@ProcessID	Int;

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	DECLARE @UnitPart TINYINT	
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	-- Init Variables --------------------------------
	IF (@RepOptions Is Null) SET @RepOptions = '11101';
	IF (@RepInfo Is Null)	 SET @RepInfo = '1@1@1';
	IF (@SortFields Is Null) SET @SortFields = 'GoodsID';
		
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @CallType	= pub.funSplitString(@RepInfo, '@', 6);
	SET @ProcessID	= pub.funSplitString(@RepInfo, '@', 7);
	
	set @Decimlas = 2
	select @Decimlas = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimalsToForms'

	SELECT	@StoreID = StoreID
	FROM	inv.tblStoresNumerationDtl
	WHERE	SerialNo = @SerialNo

	IF (@StoreID Is Null) SET @StoreID = ''

	SET @ShowPrice	= Substring(@RepOptions, 1, 1)
	SET @ZeroAmount	= Substring(@RepOptions, 2, 1)
	SET @AllGoods	= Substring(@RepOptions, 3, 1)
	SET @Decrease	= Substring(@RepOptions, 4, 1)
	SET @Increase	= Substring(@RepOptions, 5, 1)
	SET @DontFilt	= Substring(@RepOptions, 6, 1)
	SET @FiscalYear	= Substring(@RepOptions, 7, 4)
	SET @ShowPE		= Substring(@RepOptions, 11, 1)
	
 update inv.tblStorageDocsSerials
 set NumberPerContainer=0 , ContainerStoresID='',ProductionDate='',ExpireDate=''
 where ContainerID ='' and NumberPerContainer<>0
 
 update inv.tblStoresNumerationSerials
 set NumberPerContainer=0, ContainerStoresID='',ProductionDate='',ExpireDate=''
 where ContainerID ='' and NumberPerContainer<>0

--------------------------------------------------	
	SET @StrWhere = '(1=1)';

	IF (@StoreID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND b.StoreID = ''' + @StoreID + ''''
	IF (@GoodsIDFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND b.GoodsID >= ''' + @GoodsIDFr + ''''
	IF (@GoodsIDTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND b.GoodsID <= ''' + @GoodsIDTo + ''''
	IF (@GoodsIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND b.GoodsID LIKE ''' + RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'''
	--------------------------------------------------		 
 	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (b.DocDate <= ''' + @DocDateTo + ''')'

if @CallType=1
	SET @StrSelect = '	 
	select D.*,GH.UnitID,UnitName, pub.funGetGoodsName(D.GoodsID,' + @LangID + ') GoodsName ,EnterKind  NumberPerContainer  from ( 
select Distinct GoodsID, sum(a.EnterKind ) EnterKind, a.StoreID,a.PSerialNo ,a.ProductSerialID, ContainerID,ContainerStoresID,ProductionDate,ExpireDate
			From (
				Select  b.StoreID, GoodsID,a.ContainerID,a.ContainerStoresID,ProductionDate,a.ExpireDate
					,SUM(case when ContainerID<>'''' then NumberPerContainer *a.EnterKind else  1*a.EnterKind end )  EnterKind
					,case when ContainerID<>'''' then '''' else a.PSerialNo end PSerialNo
					,case when ContainerID<>'''' then '''' else a.ProductSerialID end ProductSerialID
				From inv.tblStorageDocsSerials a
					Inner Join inv.tblStorageDocsDtl b On a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
				where '+@StrWhere+'   and b.GoodsID In (select GoodsID   from inv.tblStoresNumerationDtl a	where SerialNo=  '+ str(@SerialNo)+' )
				group by b.StoreID ,GoodsID,a.ContainerID,case when ContainerID<>'''' then '''' else a.PSerialNo end 
					,case when ContainerID<>'''' then '''' else a.ProductSerialID end ,ContainerStoresID,ProductionDate,a.ExpireDate
			
				  ) a group by a.StoreID,a.PSerialNo ,GoodsID,a.ProductSerialID, ContainerID,ContainerStoresID,ProductionDate,ExpireDate
			having sum(a.EnterKind)>0
			) D
		 inner join inv.tblGoods	GH on GH.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		left  join inv.tblUnitsDtl U on U.UnitID = GH.UnitID AND U.LanguageID =  1 
	 '
if @CallType=2
	SET @StrSelect = '
	select D.*,GH.UnitID,UnitName, pub.funGetGoodsName(D.GoodsID,' + @LangID + ') GoodsName,EnterKind  NumberPerContainer from ( 
		select  Distinct GoodsID,  sum(a.EnterKind ) EnterKind, a.StoreID,a.PSerialNo ,a.ProductSerialID, ContainerID,ContainerStoresID,ProductionDate,ExpireDate
				From (
					select  a.StoreID,GoodsID, ContainerID,ContainerStoresID,ProductionDate,a.ExpireDate
					,SUM(Case when ContainerID<>'''' then  NumberPerContainer*a.EnterKind else a.EnterKind end) EnterKind  
					,Case when ContainerID<>'''' then  '''' else a.PSerialNo end PSerialNo 
					,Case when ContainerID<>'''' then  '''' else a.ProductSerialID end ProductSerialID 
					from inv.tblStoresNumerationSerials a				
						inner join inv.tblStoresNumerationDtl b
						on a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
					where 	'+@StrWhere+' and  a.SerialNo=  '+ str(@SerialNo)+'
					group by a.StoreID ,GoodsID,a.ContainerID,case when ContainerID<>'''' then '''' else a.PSerialNo end 
						,case when ContainerID<>'''' then '''' else a.ProductSerialID end,ContainerStoresID,ProductionDate,a.ExpireDate
					) a group by GoodsID, a.StoreID, ContainerID,a.PSerialNo ,a.ProductSerialID ,ContainerStoresID,ProductionDate,ExpireDate
				having sum(a.EnterKind)>0
		)D
		inner join inv.tblGoods	GH on GH.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		left  join inv.tblUnitsDtl U on U.UnitID = GH.UnitID AND U.LanguageID =  1 
		'
	-- Sort Clause ---------------------------------------------
	SET @StrSelect = @StrSelect + ' 
	ORDER BY D.GoodsID,D.PSerialNo ,D.ProductSerialID ; '

	-- Run -----------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	

END
GO
