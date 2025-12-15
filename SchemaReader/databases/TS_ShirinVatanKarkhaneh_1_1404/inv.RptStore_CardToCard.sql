USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Mostafavi
-- Creation Date : 1403/08/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE [inv].[RptStore_CardToCard]
	@ProcessID			Int = 260,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@DocDescMask		NVarChar(100) = Null, -- بخشی از شرح
	@SelectedGoods		Int = 0, 
	@SelectedGoods2		Int = 0, 
	@SelectedStore		Int = 0, 
	@SelectedStore2		Int = 0, 
	@RepOptions			VarChar(50) = '', -- bit array options
	@RepInfo			NVarChar(100) = Null,
	@SortFields			NVarChar(100) = Null,
	@ExtraParams		NVarChar(2000) = Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect				NVarChar(Max);
DECLARE @StrWhere				NVarChar(Max);

--print sysdatetime()

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int;
DECLARE	@ReportID			Int;
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		bit;
DECLARE @SH					NVarChar(50);
DECLARE @SD					NVarChar(50);
DECLARE @BatchNoGoodsFr		NVarChar(20);
DECLARE @BatchNoGoodsTo		NVarChar(20);
DECLARE @PrdSerialFr		NVarChar(20);
DECLARE @PrdSerialTo		NVarChar(20);
DECLARE @DocDescMaskAlt		NVarChar(100);
Declare @QtyStr nvarchar(2000)
DECLARE @DbName_0000 varchar(500)=Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--========================
	DECLARE @UnitPart TINYINT
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
	
	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)		SET @RepOptions = '110001111111110000';
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;

	IF (@DocDateFr	Is Null)		SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)		SET @DocDateTo = '@@@';
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedGoods2 Is Null)	SET @SelectedGoods2 = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0;
	
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;


	
	SET @LangID			 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	 = pub.funSplitString(@RepInfo, '@', 5);

	SET @PrdSerialFr	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @PrdSerialTo	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @BatchNoGoodsFr	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @BatchNoGoodsTo	 		= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	set @DocDescMaskAlt			= LTRIM(pub.funSplitString(@ExtraParams, '@', 6));
	
		---------------------------------------------------------
	--Print @bolSaleAndRet
	-- Where Clause -----------------------------------------
	SET @StrSelect = ''
	Set @StrWhere = ''

	IF (@BatchNoGoodsFr <> '')
		Set @StrWhere = @StrWhere + ' AND (D.BatchNo >= ''' + Ltrim(@BatchNoGoodsFr) + ''')'

	IF (@BatchNoGoodsTo <> '')
		Set @StrWhere = @StrWhere + ' AND (D.BatchNo <= ''' + Ltrim(@BatchNoGoodsTo) + ''')'

	IF @ProcessNo Is Not Null and @ProcessNo>0
		Set @StrWhere = @StrWhere + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
		
	IF (@SerialNoFr Is Not Null) And (@SerialNoFr <> 0)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	IF (@SerialNoTo Is Not Null) And (@SerialNoTo <> 0)
		Set @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@') AND (@DocDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@') AND (@DocDateTo <> '')
		SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')

	IF @DocDescMask Is Not Null And @DocDescMask <> ''
		Set @StrWhere= @StrWhere+ ' and  ((H.DocDesc LIKE N''%' + @DocDescMask + '%'' OR D.DescDtl LIKE N''%' + @DocDescMask + '%''  
		OR isnull((SELECT top 1  DocDesc  FROM inv.tblStorageDocsHdr BH where  BH.ProcessID = D.BaseProcessID AND BH.ProcessNo = D.BaseProcessNo AND 
		BH.FiscalYear = D.BaseFiscalYear AND BH.SerialNo = D.BaseSerialNo ),'''') LIKE N''%' + @DocDescMask + '%''  )'

	IF @DocDescMaskAlt Is Not Null And @DocDescMaskAlt <> ''
		Set @StrWhere= @StrWhere+ ' or  (H.DocDesc LIKE N''%' + @DocDescMaskAlt + '%'' OR D.DescDtl LIKE N''%' + @DocDescMaskAlt + '%''  
		OR isnull((SELECT top 1  DocDesc  FROM inv.tblStorageDocsHdr BH where  BH.ProcessID = D.BaseProcessID AND BH.ProcessNo = D.BaseProcessNo AND 
		BH.FiscalYear = D.BaseFiscalYear AND BH.SerialNo = D.BaseSerialNo ),'''') LIKE N''%' + @DocDescMaskAlt + '%''  ))'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	IF (@SelectedGoods2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods2, 'D.GoodsID2') 
	
	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID')

	IF (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'D.StoreID2')
	
	begin try
		drop table #tmpUserName
		drop table #SessionNo
	end try
	begin catch
	end catch
	
	Create Table #SessionNo
	(
	SessionNo					Int 
	)
	set @QtyStr =
	'INSERT INTO #SessionNo 
		select distinct SessionNo from	inv.tblStorageDocsHdr
		union
		select distinct SessionNo2 from inv.tblStorageDocsHdr
		union
		select distinct SessionNo3 from inv.tblStorageDocsHdr
		union
		select distinct SessionNo4 from inv.tblStorageDocsHdr
		union
		select distinct SessionNo5 from inv.tblStorageDocsHdr
	'
	
	Exec sp_executesql @QtyStr;
	
	Create Table #tmpUserName
	(
	SessionNo					Int, 
	UserName					nvarchar(500) 
	)
	print sysdatetime()				 
		set @QtyStr = 
		   'insert into #tmpUserName
		    select SessionNo, UserName  
			from ' + @DbName_0000 + '.usr.tblSessions SI
			inner join (
				SELECT SN.SessionNo,SessionID
				FROM ' + @DbName_0000 + '.usr.tblSessionNumbers SN 
				INNER JOIN  #SessionNo SD
				ON SD.SessionNo=SN.SessionNo
			)SN
			ON SN.SessionID=SI.SessionID
			inner join  (SELECT UserID,' + @DbName_0000 + '.[pub].[funUserFullName](UserID) UserName FROM ' + @DbName_0000 + '.usr.tblUsers) U
			on SI.UserID=U.UserID	'				 
	PRINT @QtyStr
	Exec sp_executesql @QtyStr;
	

	SET @StrSelect = '
			SELECT 
				P.ProcessName,
				D.ProcessID,
				D.FiscalYear,
				D.SerialNo,
				D.StoreID,
				D.StoreID2,
				[pub].[GetStoreName](D.StoreID,' + LTrim(RTrim(@LangID)) + ') StoreIDDtlName, 
				[pub].[GetStoreName](D.StoreID2,' + LTrim(RTrim(@LangID)) + ') StoreIDDtl2Name, 
				D.BaseSerialNo,
				D.GoodsID,
				D.GoodsID2,
				[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, 
				[pub].[funGetGoodsName](D.GoodsID2,' + LTrim(RTrim(@LangID)) + ') Goods2Name,
				D.BatchNo,
				D.BatchNo2,
				[inv].[funGetBatchName](D.BatchNo,' + LTrim(RTrim(@LangID)) + ') BatchName,
				[inv].[funGetBatchName](D.BatchNo2,' + LTrim(RTrim(@LangID)) + ') Batch2Name,
				D.SubUnitID,
				[inv].[funGetUnitName](D.SubUnitID,' + LTrim(RTrim(@LangID)) + ') SubUnitName,
				D.VirtualQuantity,
				D.SubUnitQuantity,
				D.GoodsQuantity,
				D.DocDate DocDateDtl,
				D.DescDtl, 
				G.TechnicalNo,
				GG.TechnicalNo TechnicalNo2,
				IsNull(G.GoodsWeight,0) Weight,
				H.DocDate DocDateHdr, 
				H.StoreID StoreIDHdr, 
				H.StoreID2 StoreID2Hdr, 
				H.DocDesc,
				[pub].[GetStoreName](H.StoreID,' + LTrim(RTrim(@LangID)) + ') StoreIDHdrName, 
				[pub].[GetStoreName](H.StoreID2,' + LTrim(RTrim(@LangID)) + ') StoreIDHdr2Name,
				[inv].[funGetGoodsRemain](D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.VolumeRowNo,D.StoreID,D.GoodsID,D.BatchNo,D.DocDate,D.UserPriceID) - ROUND(cast([inv].[funGetGoodsRemainVirtualQuantity](D.GoodsID,D.StoreID,D.DocDate) as float),0) Remain,
				[inv].[funGetGoodsRemain](D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.VolumeRowNo,D.StoreID2,D.GoodsID2,D.BatchNo2,D.DocDate,D.UserPriceID2) - ROUND(cast([inv].[funGetGoodsRemainVirtualQuantity](D.GoodsID2,D.StoreID2,D.DocDate) as float),0) Remain2,
				U1.UserName, 
				U1.UserName UserName1, 
				U2.UserName UserName2, 
				U3.UserName UserName3, 
				U4.UserName UserName4, 
				U5.UserName UserName5
			FROM inv.tblStorageDocsHdr H
			LEFT JOIN inv.tblStorageDocsDtl D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
			LEFT JOIN pub.tblProcess P ON P.ProcessID = H.ProcessID and P.ProcessNo = H.ProcessNo
			LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN inv.tblGoods GG ON GG.GoodsID = SUBSTRING(D.GoodsID2,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GG.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN #tmpUserName U1 ON U1.SessionNo = H.SessionNo
			LEFT JOIN #tmpUserName U2 ON U2.SessionNo = H.SessionNo
			LEFT JOIN #tmpUserName U3 ON U3.SessionNo = H.SessionNo
			LEFT JOIN #tmpUserName U4 ON U4.SessionNo = H.SessionNo
			LEFT JOIN #tmpUserName U5 ON U5.SessionNo = H.SessionNo
			WHERE H.ProcessID = '+ ltrim(rtrim(STR(@ProcessID))) +' --260 
			'+ @StrWhere+'
			GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.VolumeRowNo, D.StoreID, D.GoodsID, D.BatchNo, D.DocDate, D.UserPriceID, D.UserPriceID2 , D.StoreID2, D.GoodsID2, D.BatchNo2,
				P.ProcessName, D.StoreID, D.StoreID2, D.BaseSerialNo, D.GoodsID, D.GoodsID2, D.BatchNo, D.BatchNo2, D.SubUnitID, D.VirtualQuantity, D.VisitorAcntCode, D.VisitorPercent, GG.TechnicalNo,
				D.AcntCode, D.OrderAcntCode, D.ReciverAcntCode, D.SubUnitQuantity, D.GoodsQuantity, D.DocDate, D.DescDtl, G.TechnicalNo, G.GoodsWeight, H.DocDate, H.StoreID,
				H.StoreID2, H.DocDesc, U1.UserName, U2.UserName, U3.UserName, U4.UserName, U5.UserName'
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
