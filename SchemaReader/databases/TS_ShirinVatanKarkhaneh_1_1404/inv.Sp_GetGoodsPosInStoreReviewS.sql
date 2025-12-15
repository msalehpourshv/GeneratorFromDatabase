USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Seyyed Mahdi Mostafavi
-- Create date   : 1404/04/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[Sp_GetGoodsPosInStoreReviewS]
@AcntPart    TINYINT,
@AcntStart   TINYINT,
@AcntLen	 TINYINT,
@GoodsPart   TINYINT,
@GoodsStart  TINYINT,
@GoodsLen	 TINYINT,
@LanguageID	 TINYINT,
@UserIsAdmin BIT,
@UserID		 INT,
@StrStoreFilter				VARCHAR(Max), 
@strGoodsFilter				VARCHAR(Max), 
@strContainerIDFilter		VARCHAR(Max), 
@strContainerStoreIDFilter	VARCHAR(Max), 
@SelectedStore			VARCHAR(Max), 
@SelectedStore2			VARCHAR(Max), 
@SelectedGoods			VARCHAR(Max), 
@SelectedContainerID	VARCHAR(Max), 
@SelectedContainerID2	VARCHAR(Max), 
@SelectedContainerSID	VARCHAR(Max), 
@SelectedContainerSID2	VARCHAR(Max), 
@FromDate			VARCHAR(10),
@ToDate				VARCHAR(10),
@FromExpireDate		VARCHAR(10),
@ToExpireDate		VARCHAR(10),
@FromProductionDate VARCHAR(10),
@ToProductionDate	VARCHAR(10),
@AcntCode			VARCHAR(20),
@UserPriceID		BIGINT,
@SerialNo			BIGINT

WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrFrom	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(Max);
DECLARE @StrConds	NVarChar(Max);

BEGIN

	IF @LanguageID is null SET @LanguageID = 1
	IF @AcntCode is null or @AcntCode = ''  SET @AcntCode = ''''''
	IF @FromDate is null or @FromDate = ''  SET @FromDate = ''''''
	IF @ToDate is null or @ToDate = ''		SET @ToDate = ''''''
	IF @FromExpireDate is null or @FromExpireDate = ''  SET @FromExpireDate = ''''''
	IF @ToExpireDate is null or @ToExpireDate = ''		SET @ToExpireDate = ''''''
	IF @FromProductionDate is null or @FromProductionDate = ''  SET @FromProductionDate = ''''''
	IF @ToProductionDate is null or @ToProductionDate = ''		SET @ToProductionDate = ''''''

	SET @StrWhere = 'WHERE (1=1) '
	SET @StrWhere2 = 'WHERE (1=1) '

	IF (@SelectedStore <> '')
		SET @StrWhere = @StrWhere + @SelectedStore
	IF (@SelectedStore2 <> '')
		SET @StrWhere2 = @StrWhere2 + @SelectedStore2

	IF (@SelectedGoods <> '') 
		SET @StrWhere = @StrWhere + @SelectedGoods

	IF @StrStoreFilter <> ''
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ('''+ LTRIM(RTRIM(@StrStoreFilter)) +''' = '''' OR D.StoreID = '''+ LTRIM(RTRIM(@StrStoreFilter)) +''') '
		SET @StrWhere2 = @StrWhere2 + ' AND ('''+ LTRIM(RTRIM(@StrStoreFilter)) +''' = '''' OR StoreID = '''+ LTRIM(RTRIM(@StrStoreFilter)) +''') '
	END

	IF @strGoodsFilter <> ''
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ('''+ LTRIM(RTRIM(@strGoodsFilter)) +''' = '''' OR D.GoodsID = '''+ LTRIM(RTRIM(@strGoodsFilter)) +''') '
	END

	IF @strContainerIDFilter <> ''
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ('''+ LTRIM(RTRIM(@strContainerIDFilter)) +''' = '''' OR SS.ContainerID = '''+ LTRIM(RTRIM(@strContainerIDFilter)) +''') '
		SET @StrWhere2 = @StrWhere2 + ' AND ('''+ LTRIM(RTRIM(@strContainerIDFilter)) +''' = '''' OR ContainerID = '''+ LTRIM(RTRIM(@strContainerIDFilter)) +''') '
	END

	IF @strContainerStoreIDFilter <> ''
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ('''+ LTRIM(RTRIM(@strContainerStoreIDFilter)) +''' = '''' OR SS.ContainerStoresID = '''+ LTRIM(RTRIM(@strContainerStoreIDFilter)) +''') '
		SET @StrWhere2 = @StrWhere2 + ' AND ('''+ LTRIM(RTRIM(@strContainerStoreIDFilter)) +''' = '''' OR ContainerStoresID = '''+ LTRIM(RTRIM(@strContainerStoreIDFilter)) +''') '
	END

	IF (@SelectedContainerID <> '') 
		SET @StrWhere = @StrWhere + @SelectedContainerID
	IF (@SelectedContainerID2 <> '') 
		SET @StrWhere2 = @StrWhere2 + @SelectedContainerID2
	IF (@SelectedContainerSID <> '') 
		SET @StrWhere = @StrWhere + @SelectedContainerSID
	IF (@SelectedContainerSID2 <> '') 
		SET @StrWhere2 = @StrWhere2 + @SelectedContainerSID2
		
	IF @AcntCode <> '' AND @AcntCode <> '''''' 
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(@AcntCode)) + ' = '''' OR D.AcntCode = ' + LTRIM(RTRIM(@AcntCode)) + ')'

	IF @UserPriceID <> 0 
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(STR(@UserPriceID))) + ' = 0 OR D.UserPriceID = ' + LTRIM(RTRIM(STR(@UserPriceID))) + ')'
	
	IF @SerialNo <> 0 
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(STR(@SerialNo))) + ' = 0 OR D.SerialNo = ' + LTRIM(RTRIM(STR(@SerialNo))) + ')'

	IF @FromDate <> '' AND @FromDate <> '''''' 
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(@FromDate)) + ' = '''' OR D.DocDate >= ''' + LTRIM(RTRIM(@FromDate)) + ''')'

	IF @ToDate <> '' AND @ToDate <> '''''' 
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(@ToDate)) + ' = '''' OR D.DocDate <= ''' + LTRIM(RTRIM(@ToDate)) + ''')'

	IF @FromExpireDate <> '' AND @FromExpireDate <> '''''' 
	BEGIN
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(@FromExpireDate)) + ' = '''' OR SS.ExpireDate >= ''' + LTRIM(RTRIM(@FromExpireDate)) + ''')'
		Set @StrWhere2 = @StrWhere2 + ' AND (' + LTRIM(RTRIM(@FromExpireDate)) + ' = '''' OR ExpireDate >= ''' + LTRIM(RTRIM(@FromExpireDate)) + ''')'
	END

	IF @ToExpireDate <> '' AND @ToExpireDate <> '''''' 
	BEGIN
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(@ToExpireDate)) + ' = '''' OR SS.ExpireDate <= ''' + LTRIM(RTRIM(@ToExpireDate)) + ''')'
		Set @StrWhere2 = @StrWhere2 + ' AND (' + LTRIM(RTRIM(@ToExpireDate)) + ' = '''' OR ExpireDate <= ''' + LTRIM(RTRIM(@ToExpireDate)) + ''')'
	END

	IF @FromProductionDate <> '' AND @FromProductionDate <> '''''' 
	BEGIN
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(@FromProductionDate)) + ' = '''' OR SS.ProductionDate >= ''' + LTRIM(RTRIM(@FromProductionDate)) + ''')'
		Set @StrWhere2 = @StrWhere2 + ' AND (' + LTRIM(RTRIM(@FromProductionDate)) + ' = '''' OR ProductionDate >= ''' + LTRIM(RTRIM(@FromProductionDate)) + ''')'
	END

	IF @ToProductionDate <> '' AND @ToProductionDate <> '''''' 
	BEGIN
		Set @StrWhere = @StrWhere + ' AND (' + LTRIM(RTRIM(@ToProductionDate)) + ' = '''' OR SS.ProductionDate <= ''' + LTRIM(RTRIM(@ToProductionDate)) + ''')'
		Set @StrWhere2 = @StrWhere2 + ' AND (' + LTRIM(RTRIM(@ToProductionDate)) + ' = '''' OR ProductionDate <= ''' + LTRIM(RTRIM(@ToProductionDate)) + ''')'
	END

	SET @StrSelect = '
	SELECT 
		H.ProcessID,
		ISNULL(pub.funGetProcessName(H.ProcessID,H.ProcessNo, ' + LTRIM(RTRIM(STR(@LanguageID))) + '),'''')ProcessName,
		H.ProcessNo,
		H.FiscalYear,
		H.SerialNo,
		H.DocDate,
		D.StoreID,
		D.GoodsID,
		D.SubUnitID,
		Cast(CASE WHEN H.ProcessID= 188 THEN 1 WHEN H.ProcessID= 189 THEN -1  ELSE D.EnterKind END AS SmallInt) EnterKind,
		SS.ContainerID,
		inv.funGetContainerName(SS.ContainerID, ' + LTRIM(RTRIM(STR(@LanguageID))) + ') ContainerName,
		SS.NumberPerContainer,
		CAST(D.GoodsQuantity as float )GoodsQuantity,
		CAST(D.SubUnitQuantity  as float )SubUnitQuantity,
		D.GoodsAmount,
		ISNULL(S.StoreName,'''')StoreName,
		ISNULL(G.GoodsName,'''') GoodsName,
		GG.TechnicalNo,
		ISNULL(U.UnitName,'''')UnitName, 
		SS.ContainerStoresID, 
		inv.funGetContainerStoresName(SS.ContainerStoresID,' + LTRIM(RTRIM(STR(@LanguageID))) + ') ContainerStoresName, 
		SS.ContainerStoresID2, 
		inv.funGetContainerStoresName(SS.ContainerStoresID2,' + LTRIM(RTRIM(STR(@LanguageID))) + ') ContainerStoresName2, 
		SS.ExpireDate, 
		SS.ProductionDate, 
		GG.ExpirationPeriod
	FROM '
	
	SET @StrFrom =  'inv.tblStorageDocsHdr H 
	INNER JOIN inv.tblStorageDocsDtl D ON H.ProcessID = D.ProcessID 
									  AND H.ProcessNo = D.ProcessNo 
									  AND H.FiscalYear = D.FiscalYear 
									  AND H.SerialNo = D.SerialNo 
	INNER JOIN inv.tblStorageDocsSerials SS ON SS.ProcessID = D.ProcessID 
										   AND SS.ProcessNo = D.ProcessNo 
										   AND SS.FiscalYear = D.FiscalYear 
										   AND SS.SerialNo = D.SerialNo 
										   AND SS.DocRowNo = D.DocRowNo
	LEFT JOIN pub.tblProcess P ON H.ProcessID = P.ProcessID 
							  AND H.ProcessNo = P.ProcessNo 
	LEFT JOIN acc.tblAcntDtl A ON SUBSTRING(D.AcntCode,' + LTRIM(RTRIM(STR(@AcntStart))) + ',' + LTRIM(RTRIM(STR(@AcntLen))) + ') = A.AcntCode 
							  AND A.LanguageID = ' + LTRIM(RTRIM(STR(@LanguageID))) + ' 
							  AND A.PartNumber = ' + LTRIM(RTRIM(STR(@AcntPart))) + ' 
	LEFT JOIN inv.tblStoresDtl S ON D.StoreID = S.StoreID 
								AND S.LanguageID = ' + LTRIM(RTRIM(STR(@LanguageID))) + '
	LEFT JOIN inv.tblGoodsDtl G	ON SUBSTRING(D.GoodsID,' + LTRIM(RTRIM(STR(@GoodsStart))) + ',' + LTRIM(RTRIM(STR(@GoodsLen))) + ') = G.GoodsID 
							   AND G.LanguageID = ' + LTRIM(RTRIM(STR(@LanguageID))) + ' 
							   AND G.PartNumber = ' + LTRIM(RTRIM(STR(@GoodsPart))) + ' 
	LEFT JOIN inv.tblGoods GG ON SUBSTRING(D.GoodsID,' + LTRIM(RTRIM(STR(@GoodsStart))) + ',' + LTRIM(RTRIM(STR(@GoodsLen))) + ') = GG.GoodsID 
							 AND GG.PartNumber = ' + LTRIM(RTRIM(STR(@GoodsPart))) + '
	LEFT JOIN inv.tblUnitsDtl U	ON D.SubUnitID = U.UnitID 
							   AND U.LanguageID = ' + LTRIM(RTRIM(STR(@LanguageID))) + '
	LEFT JOIN inv.tblBatch B ON D.BatchNo = B.BatchNo 
	LEFT JOIN inv.tblBatchDtl BD ON D.BatchNo = BD.BatchNo 
								AND BD.LanguageID = ' + LTRIM(RTRIM(STR(@LanguageID)))
	
	SET @StrWhere = @StrWhere + ' AND (D.EnterKind <> 0 or H.ProcessID in(188,189)) 
								  AND (' + CASE WHEN LTRIM(RTRIM(STR(@UserIsAdmin))) = 1 THEN '''TRUE''' ELSE '''FALSE''' END + ' = ''TRUE'' 
								       OR ((SELECT IsNull(COUNT(*), 0) 
											FROM inv.tblGoodsRng 
											WHERE (UserID = ' + LTRIM(RTRIM(STR(@UserID))) + ') 
											  AND (PartNumber = ' + LTRIM(RTRIM(STR(@GoodsPart))) + ') 
											  AND (AccessAllCode = 1 OR ((AllowCodeView = 1) 
											  AND (LEFT(ISNULL(D.GoodsID,''''), LEN(ToCode)) >= FromCode) 
											  AND (LEFT(ISNULL(D.GoodsID,''''), LEN(ToCode)) <= ToCode))))>0 
											  AND (SELECT IsNull(COUNT(*), 0)
											FROM inv.tblStoresRng
											WHERE (UserID = ' + LTRIM(RTRIM(STR(@UserID))) + ') 
											  AND (AccessAllCode=1 OR ((AllowCodeView = 1) 
											  AND (LEFT(ISNULL(D.StoreID,''''), LEN(ToCode)) >= FromCode) 
											  AND (LEFT(ISNULL(D.StoreID,''''), LEN(ToCode)) <= ToCode))))>0))'
	SET @StrConds = '
	GROUP BY H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,H.DocDate,D.StoreID,D.GoodsID,D.SubUnitID,D.EnterKind,
			 SS.ContainerID,SS.NumberPerContainer,D.GoodsQuantity,D.SubUnitQuantity,D.GoodsAmount,S.StoreName,
			 G.GoodsName,GG.TechnicalNo,U.UnitName,SS.ContainerStoresID, SS.ContainerStoresID2,SS.ExpireDate,
			 SS.ProductionDate,GG.ExpirationPeriod
	ORDER BY DocDate,ExpireDate'

	PRINT @StrSelect
	PRINT @StrFrom
	PRINT @StrWhere
	PRINT @StrConds

	SET @StrSelect = @StrSelect + @StrFrom + @StrWhere + @StrConds
	Exec sp_executesql @StrSelect;
END
GO
