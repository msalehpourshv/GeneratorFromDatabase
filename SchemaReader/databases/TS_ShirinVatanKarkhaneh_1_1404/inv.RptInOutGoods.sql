USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create PROCEDURE inv.RptInOutGoods
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(193) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;
---------------Acnt Layer ----------------------------------------------------
Declare @StartLayer	TINYINT;
Declare @LayerLen	TINYINT;
Declare @PartNumber	TINYINT;
Declare @QuantityDecimals	TINYINT;
Declare @PriceDecimals		TINYINT;
Declare @ShowZeroDecimals	bit;
select @QuantityDecimals = SettingValue From pub.tblSettings Where SettingKey='QuantityDecimals'
select @PriceDecimals = SettingValue From pub.tblSettings Where SettingKey='PriceDecimals'
select @ShowZeroDecimals = SettingValue From pub.tblSettings Where SettingKey='ShowZeroDecimals'


SELECT @StartLayer = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'StartLayerIndex'	
select @LayerLen = SettingValue From pub.tblSettings Where SettingKey='LayerLen'
select @PartNumber = SettingValue From pub.tblSettings Where SettingKey='AcntPartNumberForRemainCalculation'
		
IF (@StartLayer Is Null)	SET @StartLayer = 1;
IF (@LayerLen Is Null)		SET @LayerLen = 1;
IF (@PartNumber Is Null)	SET @PartNumber = 1;

---------------Goods Layer ----------------------------------------------------

DECLARE @GroupBy	NVarChar(Max);
DECLARE @FilterLink	NVarChar(Max);
DECLARE @FilterLink2	NVarChar(Max);
DECLARE @FieldName	NVarChar(Max);

Declare @GoodsLayerStart	TINYINT;
Declare @GoodsLayer1	TINYINT;
Declare @GoodsLayer2	TINYINT;

Select @GoodsLayerStart=Layer1 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
Select @GoodsLayer1=Layer2 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
Select @GoodsLayer2=Layer3 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
	
SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


DECLARE	
	@FilterType			int,
	@ProcessNo			Varchar(20) ,
	@FiscalYearFr		Int ,
	@SerialNoFr			Int ,
	@FiscalYearTo		Int ,
	@SerialNoTo			Int ,
	@DocDateFr			Char(10) ,
	@DocDateTo			Char(10) ,
	@StoreID			Varchar(20),
	@GoodsID			Varchar(20),
	@SelectedAcnt1		Varchar(20),
	@SelectedAcnt2		Varchar(20),
	@SelectedAcnt3		Varchar(20),
	@SelectedAcnt4		Varchar(20),
	@DriverID			Varchar(20),
	@TrukNo				NVarchar(20),
	@BaseSendID			Varchar(20),
	@FarmerID			Varchar(20),
	@LocationID			Varchar(20),
	@BatchNo			Varchar(20),
	@TransporterID2		VarChar(20), 
	@Orders 			NVarChar(Max),
	@GroupByField		Varchar(200),
	@GroupByFieldTmp	Varchar(200),
	@GroupByFieldNameTmp	Varchar(200),
	@GroupByTmp			Varchar(200),
	@GroupByTmp2		Varchar(200),
	@GroupByFieldGoods	Varchar(200)
	

SET @FilterType			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @ProcessNo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @FiscalYearFr		    = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
SET @SerialNoFr			    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @FiscalYearTo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @SerialNoTo		    	= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
SET @DocDateFr			    = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @DocDateTo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
SET @StoreID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
SET @GoodsID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
SET @SelectedAcnt1		    = LTrim(pub.funSplitString(@ExtraParams, '@', 11));
SET @SelectedAcnt2		    = LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
SET @SelectedAcnt3		    = LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
SET @SelectedAcnt4		    = LTrim(pub.funSplitString(@ExtraParams, '@', 14));
SET @DriverID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 15));
SET @TrukNo					= LTrim(pub.funSplitString(@ExtraParams, '@', 16));
SET @BaseSendID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 17));
SET @FarmerID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 18));
SET @LocationID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 19));
SET @BatchNo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 20));
SET @Orders 				= LTrim(pub.funSplitString(@ExtraParams, '@', 21));
SET @GroupByField		    = LTrim(pub.funSplitString(@ExtraParams, '@', 22));
SET @TransporterID2		    = LTrim(pub.funSplitString(@ExtraParams, '@', 23));
SET @GroupByFieldGoods	    = LTrim(pub.funSplitString(@ExtraParams, '@', 24));


if @GroupByField <>'' and @GroupByFieldGoods <>''
BEGIN
	SET @GroupByFieldNameTmp = @GroupByField + ',' + @GroupByFieldGoods 
	SET @GroupByFieldTmp = @GroupByField + ' GroupByField ,' + @GroupByFieldGoods + ' GroupByField2'
	SET @GroupByTmp = 'and D.'+ @GroupByField +'=#tblSale.GroupByField AND D.'+ @GroupByFieldGoods +'=#tblSale.GroupByField2'
	SET @GroupByTmp2 = 'and D.GroupByField=#tblSale.GroupByField and D.GroupByField2=#tblSale.GroupByField2 '
END
ELSE if @GroupByField <>''
BEGIN
	SET @GroupByFieldNameTmp = @GroupByField 
	SET @GroupByFieldTmp = @GroupByField + ' GroupByField ,'''' GroupByField2 '
	SET @GroupByTmp = 'and D.'+ @GroupByField +'=#tblSale.GroupByField '
	SET @GroupByTmp2 = 'and D.GroupByField=#tblSale.GroupByField'
END
ELSE if @GroupByFieldGoods <>''
BEGIN
	SET @GroupByFieldNameTmp = @GroupByFieldGoods 
	SET @GroupByFieldTmp = @GroupByFieldGoods + ' GroupByField ,'''' GroupByField2 '
	SET @GroupByTmp = 'AND D.'+ @GroupByFieldGoods +'=#tblSale.GroupByField'
	SET @GroupByTmp2 = 'and D.GroupByField=#tblSale.GroupByField '
END
ELSE
BEGIN
	SET @GroupByFieldNameTmp = ''
	SET @GroupByFieldTmp = ''
	SET @GroupByTmp = ''
	SET @GroupByTmp2 = ''
END

	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNoFr;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYearFr;
	
		BEGIN TRY
			DROP TABLE #tblAcntCode
			DROP TABLE #tblStoreID
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	CREATE TABLE #tblStoreID
	(
	StoreID 			Varchar(20)collate arabic_cs_as null
	)
	
	 Insert into  #tblAcntCode (AcntCode) SELECT  Distinct AcntCode	FROM         inv.tblStorageDocsHdr
	 Insert into  #tblStoreID (StoreID) SELECT  Distinct StoreID	FROM         inv.tblStorageDocsHdr
	 Insert into  #tblStoreID (StoreID) SELECT  Distinct StoreID	FROM         inv.tblStorageDocsDtl

	if @UserIsAdmin=0
	begin
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '#tblStoreID', 'StoreID', 'inv.tblStores', @UserID;
	END

	SET @StrWhere =  '  and   D.AcntCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) '
	SET @StrWhere =  @StrWhere + '  and   D.StoreID in (SELECT   StoreID	FROM  #tblStoreID    ) '
	
	-- Where ----------------------------------------
	IF (@SerialNoFr <>0)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >=' + LTrim(Str(@SerialNoFr)) + ') '
	IF (@SerialNoTo  <>0)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'		
	IF (@FiscalYearFr  <>0)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear >=' + LTrim(Str(@FiscalYearFr)) + ')'
	IF (@FiscalYearFr  <>0)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear <=' + LTrim(Str(@FiscalYearFr)) + ')'
	If (@DocDateFr Is Not Null and  LTRIM(rtrim(@DocDateFr ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null  and  LTRIM(rtrim(@DocDateTo ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
	IF (@StoreID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'D.StoreID')
	IF (@GoodsID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'D.GoodsID')
	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)	
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	If (@DriverID Is Not Null  and  LTRIM(rtrim(@DriverID ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.DriverID = ''' + @DriverID + ''')'
	If (@TransporterID2 Is Not Null  and  LTRIM(rtrim(@TransporterID2 ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.TransporterID2 = ''' + @TransporterID2 + ''')'
	If (@TrukNo Is Not Null  and  LTRIM(rtrim(@TrukNo ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.TrukNo like N''%' + @TrukNo + '%'')'
	If (@BaseSendID Is Not Null  and  LTRIM(rtrim(@BaseSendID ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.BaseSendID = ''' + @BaseSendID + ''')'
	If (@FarmerID Is Not Null  and  LTRIM(rtrim(@FarmerID ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.FarmerID = ''' + @FarmerID + ''')'
	If (@LocationID Is Not Null  and  LTRIM(rtrim(@LocationID ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.LocationID = ''' + @LocationID + ''')'
	If (@BatchNo Is Not Null  and  LTRIM(rtrim(@BatchNo ))<>'')
		SET @StrWhere = @StrWhere + ' AND (D.BatchNo = ''' + @BatchNo + ''' or D.BatchNo2 = ''' + @BatchNo + ''' )'

	

	CREATE TABLE #tblSale
	(
	GroupID 			Varchar(20)collate arabic_cs_as null,
	GroupName 			Varchar(200)collate arabic_cs_as null,
	GroupByField 			Varchar(200)collate arabic_cs_as null,	
	GroupByFieldName 			Varchar(200)collate arabic_cs_as null,	
	GroupByField2 			Varchar(200)collate arabic_cs_as null,	
	GroupByFieldName2 			Varchar(200)collate arabic_cs_as null,	
	A1      float ,
	A2      float,
	A3      float,
	A4      float,
	A5      float,
	A6      float,
	B1      float,
	B2      float,
	B3      float,
	B4      float,
	B5      float,
	B6      float
	)



------------------ایجاد جدول temp-------------------------
		select 
		a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.DocDate,a.AcntCode
		,a.BaseSendID,a.TransporterID2 ,a.FarmerID,a.TrukNo,a.DriverID
		,a.BaseSerialNo,a.LocationID
		, b.VirtualQuantity,b.LoadWeight
		,b.EmptyWeight,b.NetWeight,b.Var3,b.Var4,  b.DescDtl
		,b.StoreID,b.ReciverID
		,b.GoodsID,b.BatchNo,b.BatchNo2, b.GoodsQuantity

		into    #tblTemp 

		 from inv.tblStorageDocsHdr a inner join inv.tblStorageDocsDtl b
		on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo 
		where  1=0

------------------پرکردن جدول temp-------------------------


		SET @StrSelect = ' Insert into   #tblTemp 
		Select * from (select 
		a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.DocDate,a.AcntCode
		,a.BaseSendID,a.TransporterID2 ,a.FarmerID,a.TrukNo,a.DriverID
		,a.BaseSerialNo,a.LocationID
		, b.VirtualQuantity,b.LoadWeight
		,b.EmptyWeight,b.NetWeight,b.Var3, b.Var4, b.DescDtl
		,b.StoreID,b.ReciverID
		,b.GoodsID,b.BatchNo,b.BatchNo2, b.GoodsQuantity
		 from inv.tblStorageDocsHdr a inner join inv.tblStorageDocsDtl b
		on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo 
		where a.ProcessID in (192,193,260,265)) D   Where   1=1 '+ @StrWhere 
	
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
---------------------------Filter GoodsID-----------------------------------------------------------------------

if @FilterType=1
	begin
		if @GroupByFieldTmp <>'' 
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName,GroupByField,GroupByField2) 
				SELECT  Distinct  D.GoodsID ,pub.funGetGoodsName (D.GoodsID,'+@LangID +') ,'+ @GroupByFieldTmp +' 
				FROM        #tblTemp D Where   1=1 '    
			set @FilterLink=' D.GoodsID=#tblSale.GroupID ' + @GroupByTmp 
			set @FilterLink2=' D.GoodsID=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='   #tblSale.GroupID , '+ @GroupByFieldNameTmp +''--'D.GoodsID'  --
			set @FieldName=' #tblSale.GroupID GoodsID , '+ @GroupByFieldTmp 
		end
		else
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName) 
				SELECT  Distinct  D.GoodsID ,pub.funGetGoodsName (D.GoodsID,'+@LangID +') 
				FROM        #tblTemp D Where   1=1 '
			set @FilterLink=' D.GoodsID=#tblSale.GroupID'
			set @FilterLink2=' D.GoodsID=#tblSale.GroupID'
			set @GroupBy=' #tblSale.GroupID '--'D.GoodsID'  --
			set @FieldName='  #tblSale.GroupID GoodsID '
		end 		
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
	end
	---------------------------Filter GoodsID 2-----------------------------------------------------------------------
	if @FilterType=2
		begin
			if @GroupByField <>''
			begin
				SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName,GroupByField) 
					SELECT  Distinct substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1)) + ')
					, pub.funGetGoodsName(substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1)) + '),'+@LangID +'),'+ @GroupByField +' GroupByField
					FROM        #tblTemp D Where   1=1 '
				set @FilterLink='   substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ')=#tblSale.GroupID and D.'+ @GroupByField +'=#tblSale.GroupByField'
				set @FilterLink2=' D.GoodsID=#tblSale.GroupID and D.GroupByField=#tblSale.GroupByField'
				set @GroupBy='   substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ') , '+ @GroupByField +''
				set @FieldName=' substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ') GoodsID , '+ @GroupByField +' GroupByField'
			end
			else
			begin
				SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName) 
					SELECT  Distinct substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1)) + ')
					, pub.funGetGoodsName(substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+ @GoodsLayer1)) + '),'+@LangID +')
					FROM        #tblTemp D Where   1=1 '   			
				set @FilterLink='   substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ')=#tblSale.GroupID'
				set @FilterLink2=' D.GoodsID=#tblSale.GroupID'
				set @GroupBy='   substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ') '
				set @FieldName=' substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1)) + ') GoodsID '
			end	
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
	end
	---------------------------Filter GoodsID 3-----------------------------------------------------------------------
	if @FilterType=3
		begin
			if @GroupByField <>''
			begin			
				SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName,GroupByField) 
					SELECT  Distinct substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + '),pub.funGetGoodsName (substring( D.GoodsID,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1 +@GoodsLayer2)) + '),'+@LangID +')
					,'+ @GroupByField +' GroupByField
					FROM        #tblTemp D Where    1=1  '     
				set @FilterLink='   substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')=#tblSale.GroupID and D.'+ @GroupByField +'=#tblSale.GroupByField'
				set @FilterLink2=' D.GoodsID=#tblSale.GroupID and D.GroupByField=#tblSale.GroupByField'
				set @GroupBy='    substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')   , '+ @GroupByField +''
				set @FieldName='  substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')   GoodsID  , '+ @GroupByField +' GroupByField'
			end
			else
			begin
				SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName) 
					SELECT  Distinct substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + '),pub.funGetGoodsName (substring( D.GoodsID,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1 +@GoodsLayer2)) + '),'+@LangID +')
					FROM        #tblTemp D Where    1=1  '    
				set @FilterLink='   substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')=#tblSale.GroupID'
				set @FilterLink2=' D.GoodsID=#tblSale.GroupID'
				set @GroupBy='   substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')  '
				set @FieldName=' substring( D.GoodsID ,1,' + ltrim(str(@GoodsLayerStart+@GoodsLayer1+@GoodsLayer2)) + ')  GoodsID '
			end
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
		
	end	
	---------------------------Filter BatchNo 4 -----------------------------------------------------------------------
	if @FilterType=4
	begin
		if @GroupByFieldTmp <>''
		begin			
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupByField,GroupByField2) 
				SELECT  Distinct  D.BatchNo,'+ @GroupByFieldTmp +'
				FROM        #tblTemp D Where    1=1  '                     
			set @FilterLink=' D.BatchNo=#tblSale.GroupID  ' + @GroupByTmp 
			set @FilterLink2=' D.BatchNo=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='   #tblSale.GroupID  , '+ @GroupByFieldNameTmp +''--'D.GoodsID'  --
			set @FieldName=' #tblSale.GroupID BatchNo   , '+ @GroupByFieldTmp 
		end
		else
		begin	
			SET @StrSelect = ' Insert into  #tblSale (GroupID) 
				SELECT  Distinct  D.BatchNo
				FROM        #tblTemp D Where    1=1  '                      
			set @FilterLink=' D.BatchNo=#tblSale.GroupID'
			set @FilterLink2=' D.BatchNo=#tblSale.GroupID'
			set @GroupBy='   #tblSale.GroupID'--'D.GoodsID'  --
			set @FieldName=' #tblSale.GroupID BatchNo '
		end	
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;				
		update #tblSale		set GroupName= isnull(BatchName,'') 
		from #tblSale	a inner join inv.tblBatchDtl b
		on a.GroupID=b.BatchNo and b.LanguageID=@LangID		

	end		
	---------------------------Filter AcntCode-----------------------------------------------------------------------
if @FilterType=5
	begin
		if @GroupByField <>''
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupByField) 
				SELECT  Distinct  substring(D.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ') ,'+ @GroupByField +' GroupByField
				FROM        #tblTemp D  Where    1=1  '	
			set @FilterLink='  substring(D.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ')=#tblSale.GroupID and D.'+ @GroupByField +'=#tblSale.GroupByField'
			set @FilterLink2=' D.AcntCode=#tblSale.GroupID								 and D.GroupByField=#tblSale.GroupByField'
			set @GroupBy='  substring(D.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ') , '+ @GroupByField +' '
			set @FieldName=' substring(D.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ')  AcntCode , '+ @GroupByField +' GroupByField'
		end
		else
		begin	
			SET @StrSelect = ' Insert into  #tblSale (GroupID) 
				SELECT  Distinct  substring(D.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ') 
				FROM        #tblTemp D  Where    1=1  '
			set @FilterLink='  substring(D.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ')=#tblSale.GroupID'
			set @FilterLink2=' D.AcntCode=#tblSale.GroupID'
			set @GroupBy='  substring(D.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ')  '
			set @FieldName='  substring(D.AcntCode,' + ltrim(str(@StartLayer)) + ',' + ltrim(str(@LayerLen)) + ')   AcntCode '
		end	
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;			
		update #tblSale Set GroupName=acc.funGetAcntName(GroupID,  @PartNumber , @LangID )		
	end

---------------------------Filter DriverID-----------------------------------------------------------------------
if @FilterType=6
	begin
		if @GroupByFieldTmp <>''
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupByField,GroupByField2)
			 SELECT  Distinct  D.DriverID ,'+ @GroupByFieldTmp +' 
				FROM        #tblTemp D  Where    1=1  '				     
			set @FilterLink='  D.DriverID=#tblSale.GroupID ' + @GroupByTmp 
			set @FilterLink2=' D.DriverID=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='   D.DriverID , '+ @GroupByFieldNameTmp +' '
			set @FieldName=' D.DriverID  DriverID , '+ @GroupByFieldTmp 
		end
		else
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID) SELECT  Distinct  D.DriverID 
				FROM        #tblTemp D  Where    1=1  '				     
			set @FilterLink='  D.DriverID=#tblSale.GroupID'
			set @FilterLink2=' D.DriverID=#tblSale.GroupID'
			set @GroupBy='   D.DriverID '
			set @FieldName=' D.DriverID  DriverID '
		end
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		update #tblSale		set GroupName= isnull(FirstName+' '+ LastName,'') 
		from #tblSale	a inner join  pub.tblDriversDtl b
		on a.GroupID=b.DriverID
	end
	
---------------------------Filter Months-----------------------------------------------------------------------
if @FilterType=7
	begin
		if @GroupByFieldTmp <>''
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupByField,GroupByField2)
			 SELECT  Distinct  Substring(D.DocDate,6,2),'+ @GroupByFieldTmp +' 
				FROM        #tblTemp D  Where    1=1  '					
			set @FilterLink='  Substring(D.DocDate,6,2)=#tblSale.GroupID ' + @GroupByTmp 
			set @FilterLink2=' D.Months=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='	 Substring(D.DocDate,6,2) , '+ @GroupByFieldNameTmp +' '
			set @FieldName=' Substring(D.DocDate,6,2) Months  , '+ @GroupByFieldTmp 
		end
		else
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID) SELECT  Distinct  Substring(D.DocDate,6,2)
				FROM        #tblTemp D  Where    1=1  '						
			set @FilterLink='  Substring(D.DocDate,6,2)=#tblSale.GroupID'
			set @FilterLink2=' D.Months=#tblSale.GroupID'
			set @GroupBy=' Substring(D.DocDate,6,2)  '
			set @FieldName=' Substring(D.DocDate,6,2)  Months '
		end	
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;	
		update #tblSale		set GroupName='فروردین'  where GroupID='01'
		update #tblSale		set GroupName='اردیبهشت'  where GroupID='02'
		update #tblSale		set GroupName='خرداد'  where GroupID='03'
		update #tblSale		set GroupName='تیر'  where GroupID='04'
		update #tblSale		set GroupName='مرداد'  where GroupID='05'
		update #tblSale		set GroupName='شهریور'  where GroupID='06'
		update #tblSale		set GroupName='مهر'  where GroupID='07'
		update #tblSale		set GroupName='آبان'  where GroupID='08'
		update #tblSale		set GroupName='آذر'  where GroupID='09'
		update #tblSale		set GroupName='دی'  where GroupID='10'
		update #tblSale		set GroupName='بهمن'  where GroupID='11'
		update #tblSale		set GroupName='اسفند'  where GroupID='12'
	end
---------------------------Filter DocDate-----------------------------------------------------------------------
if @FilterType=8
	begin
		if @GroupByFieldTmp <>''
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName,GroupByField,GroupByField2)
			 SELECT  Distinct  D.DocDate,D.DocDate,'+ @GroupByFieldTmp +' 
				FROM        #tblTemp D  Where    1=1  '	
			set @FilterLink='  D.DocDate=#tblSale.GroupID ' + @GroupByTmp 
			set @FilterLink2=' D.DocDate=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='	 D.DocDate , '+ @GroupByFieldNameTmp +' '
			set @FieldName=' D.DocDate DocDate   , '+ @GroupByFieldTmp 
		end
		else
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName) SELECT  Distinct  D.DocDate,D.DocDate
				FROM        #tblTemp D  Where    1=1  '		
			set @FilterLink='  D.DocDate=#tblSale.GroupID'
			set @FilterLink2=' D.DocDate=#tblSale.GroupID'
			set @GroupBy='   D.DocDate '
			set @FieldName=' D.DocDate DocDate '
		end
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
	end
---------------------------Filter BaseSerialNo-----------------------------------------------------------------------
if @FilterType=9
	begin
		if @GroupByFieldTmp <>''
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName,GroupByField,GroupByField2)
				SELECT  Distinct  D.BaseSerialNo,pub.GetCodeName(D.AcntCode,  '+ str(@LangID)+' ),'+ @GroupByFieldTmp +' 
				FROM        #tblTemp D  Where    1=1  '		
			set @FilterLink='  D.BaseSerialNo=#tblSale.GroupID ' + @GroupByTmp 
			set @FilterLink2=' D.BaseSerialNo=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='	 D.BaseSerialNo  , '+ @GroupByFieldNameTmp +' '
			set @FieldName=' D.BaseSerialNo  BaseSerialNo  , '+ @GroupByFieldTmp 
		end
		else
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupName) 
				SELECT  Distinct  D.BaseSerialNo,pub.GetCodeName(D.AcntCode,  '+ str(@LangID)+' )
				FROM        #tblTemp D  Where    1=1  '	
			set @FilterLink='  D.BaseSerialNo=#tblSale.GroupID'
			set @FilterLink2=' D.BaseSerialNo=#tblSale.GroupID'
			set @GroupBy='   D.BaseSerialNo '
			set @FieldName=' D.BaseSerialNo BaseSerialNo '
		end
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
	end	
---------------------------Filter FarmerID-----------------------------------------------------------------------
if @FilterType=10
	begin
		if @GroupByFieldTmp <>''
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupByField,GroupByField2)
			 SELECT  Distinct  D.FarmerID ,'+ @GroupByFieldTmp +' 
				FROM        #tblTemp D  Where    1=1  '					     
			set @FilterLink='  D.FarmerID=#tblSale.GroupID ' + @GroupByTmp 
			set @FilterLink2=' D.FarmerID=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='   D.FarmerID   , '+ @GroupByFieldNameTmp +' '
			set @FieldName=' D.FarmerID  FarmerID  , '+ @GroupByFieldTmp 
		end
		else
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID) SELECT  Distinct  D.FarmerID 
				FROM        #tblTemp D  Where    1=1  '					     
			set @FilterLink='  D.FarmerID=#tblSale.GroupID'
			set @FilterLink2=' D.FarmerID=#tblSale.GroupID'
			set @GroupBy='   D.FarmerID '
			set @FieldName=' D.FarmerID FarmerID '
    	end
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		update #tblSale		set GroupName= isnull(FarmerName,'') 
		from #tblSale	a inner join  inv.tblFarmersDtl b
		on a.GroupID=b.FarmerID and b.LanguageID=@LangID
	end
---------------------------Filter BaseSendID-----------------------------------------------------------------------
if @FilterType=11
	begin
		if @GroupByFieldTmp <>''
		begin			
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupByField,GroupByField2)
				SELECT  Distinct  D.BaseSendID  ,'+ @GroupByFieldTmp +' 
				FROM        #tblTemp D  Where    1=1  '					     
			set @FilterLink='  D.BaseSendID=#tblSale.GroupID '+ @GroupByTmp 
			set @FilterLink2=' D.BaseSendID=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='   D.BaseSendID  , '+ @GroupByFieldNameTmp +' '
			set @FieldName=' D.BaseSendID BaseSendID  , '+ @GroupByFieldTmp 
		end
		else
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID) SELECT  Distinct  D.BaseSendID 
				FROM        #tblTemp D  Where    1=1  '					     
			set @FilterLink='  D.BaseSendID=#tblSale.GroupID'
			set @FilterLink2=' D.BaseSendID=#tblSale.GroupID'
			set @GroupBy='   D.BaseSendID '
			set @FieldName=' D.BaseSendID  BaseSendID '
		end
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
		
		update #tblSale		set GroupName= isnull(BaseSendName,'') 
		from #tblSale	a inner join  sal.tblBaseSendDtl b
		on a.GroupID=b.BaseSendID and b.LanguageID=@LangID
	end
	---------------------------Filter LocationID-----------------------------------------------------------------------
if @FilterType=12
	begin
	if @GroupByFieldTmp <>''
		begin			
			SET @StrSelect = ' Insert into  #tblSale (GroupID,GroupByField,GroupByField2)
				SELECT  Distinct  D.LocationID ,'+ @GroupByFieldTmp +' 
				FROM        #tblTemp D  Where    1=1  '					     
			set @FilterLink='  D.LocationID=#tblSale.GroupID ' + @GroupByTmp 
			set @FilterLink2=' D.LocationID=#tblSale.GroupID ' + @GroupByTmp2
			set @GroupBy='   D.LocationID  , '+ @GroupByFieldNameTmp +' '
			set @FieldName=' D.LocationID LocationID  , '+ @GroupByFieldTmp 
		end
		else
		begin
			SET @StrSelect = ' Insert into  #tblSale (GroupID) 
				SELECT  Distinct  D.LocationID 
				FROM        #tblTemp D  Where    1=1  '					     
			set @FilterLink='  D.LocationID=#tblSale.GroupID'
			set @FilterLink2=' D.LocationID=#tblSale.GroupID'
			set @GroupBy='   D.LocationID '
			set @FieldName=' D.LocationID LocationID '
		end		
		print   @StrSelect;             
		EXEC sp_executesql @StrSelect;
		
		
		update #tblSale		set GroupName= isnull(LocationName,'') 
		from #tblSale	a inner join  pub.tblLocationsDtl b
		on a.GroupID=b.LocationID and b.LanguageID=@LangID
	end
		
 -------------Sets --------------------------------------------------------------------------------------
 SET @StrSelect =''
-- Select @LinkType,@LinkTable2,@LinkTable3

----------- Set   A1=LoadWeight ------------------------------------------------------------------	

SET @StrSelect = ' 	update #tblSale  Set A1= D.LoadWeight from(
				select 	Sum( LoadWeight ) LoadWeight ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (192 )
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

SET @StrSelect = ' 	update #tblSale  Set B1= D.LoadWeight from(
				select 	Sum( LoadWeight ) LoadWeight , '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (193 ) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;



SET @StrSelect = ' 	update #tblSale  Set A1=isnull( A1,0)+D.LoadWeight from(
				select 	Sum( GoodsQuantity ) LoadWeight ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in ( 265)
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

SET @StrSelect = ' 	update #tblSale  Set B1= isnull( B1,0)+D.LoadWeight from(
				select 	Sum( GoodsQuantity ) LoadWeight ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in ( 260) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

----------- Set   A2=EmptyWeight ------------------------------------------------------------------	

SET @StrSelect = ' 	update #tblSale  Set A2= D.EmptyWeight from(
				select 	Sum( EmptyWeight ) EmptyWeight ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (192 , 265) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

SET @StrSelect = ' 	update #tblSale  Set B2= D.EmptyWeight from(
				select 	Sum( EmptyWeight ) EmptyWeight , '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (193 , 260) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
----------- Set   A3=NetWeight ------------------------------------------------------------------	

SET @StrSelect = ' 	update #tblSale  Set A3= D.NetWeight from(
				select 	Sum( NetWeight ) NetWeight ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (192 ) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

SET @StrSelect = ' 	update #tblSale  Set B3= D.NetWeight from(
				select 	Sum(NetWeight) NetWeight , '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (193 ) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;


SET @StrSelect = ' 	update #tblSale  Set A3=  isnull( A3,0)+D.NetWeight from(
				select 	Sum( GoodsQuantity ) NetWeight ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in ( 265) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

SET @StrSelect = ' 	update #tblSale  Set B3=  isnull( B3,0)+D.NetWeight from(
				select 	Sum( GoodsQuantity ) NetWeight ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in ( 260) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;



----------- Set   A4=VirtualQuantity ------------------------------------------------------------------	

SET @StrSelect = ' 	update #tblSale  Set A4= D.VirtualQuantity from(
				select 	Sum( VirtualQuantity ) VirtualQuantity ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (192 , 265) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

SET @StrSelect = ' 	update #tblSale  Set B4= D.VirtualQuantity from(
				select 	Sum( VirtualQuantity ) VirtualQuantity ,  '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (193 , 260) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
----------- Set   A5=Var4   ------------------------------------------------------------------	

SET @StrSelect = ' 	update #tblSale  Set A5= D.Var4 from(
				select 	Sum( Var4 ) Var4 , '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (192 , 265) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

SET @StrSelect = ' 	update #tblSale  Set B5= D.Var4 from(
				select 	Sum( Var4 ) Var4 , '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (193 , 260) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
----------- Set   A6=Var3   ------------------------------------------------------------------	

SET @StrSelect = ' 	update #tblSale  Set A6= D.Var3 from(
				select 	Sum( Var3 ) Var3 , '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (192 , 265) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;

SET @StrSelect = ' 	update #tblSale  Set B6= D.Var3 from(
				select 	Sum( Var3 ) Var3 , '+ @FieldName +' From #tblSale 
				Inner join #tblTemp D on '+ @FilterLink

	SET @StrSelect =  @StrSelect  +' Where  D.ProcessID in (193 , 260) 
	 Group by '+ @GroupBy +' )D where '+@FilterLink2
	
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
----------------------------------------------------------------------------

update #tblSale Set GroupID='' where  GroupID is null
update #tblSale Set GroupName='' where  GroupName is null

update #tblSale Set A1='' where  A1 is null
update #tblSale Set A2='' where  A2 is null
update #tblSale Set A3='' where  A3 is null
update #tblSale Set A4='' where  A4 is null
update #tblSale Set A5='' where  A5 is null
update #tblSale Set A6='' where  A6 is null


update #tblSale Set B1='' where  B1 is null
update #tblSale Set B2='' where  B2 is null
update #tblSale Set B3='' where  B3 is null
update #tblSale Set B4='' where  B4 is null
update #tblSale Set B5='' where  B5 is null
update #tblSale Set B6='' where  B6 is null

if @GroupByField <>'' and @GroupByFieldGoods <>''
	update #tblSale Set GroupByFieldName=acc.funGetAcntName(substring(GroupByField, @StartLayer, @LayerLen) ,  @PartNumber , @LangID ),
						GroupByFieldName2=pub.funGetGoodsName(GroupByField2 , @LangID )				
ELSE IF @GroupByFieldGoods <>''
	update #tblSale Set GroupByFieldName=pub.funGetGoodsName(GroupByField , @LangID )
ELSE
	update #tblSale Set GroupByFieldName=acc.funGetAcntName(substring(GroupByField, @StartLayer, @LayerLen) ,  @PartNumber , @LangID )

SET @StrSelect = ' Select * , '+ str(@QuantityDecimals)	+' QuantityDecimals , ' + str(@PriceDecimals)+' PriceDecimals , cast( ' + str(@ShowZeroDecimals)	+' as bit ) ShowZeroDecimals  ' + ' from  #tblSale ' + @Orders
PRINT @StrSelect;
EXEC sp_executesql @StrSelect;
GO
