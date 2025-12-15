USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : HamidReza Soltani
-- Create date   : 1389/08/22
-- Viewed By	 : 
-- Last Modified : 1390/12/03
-- Last Modifier : Zia
-- Description   : گزارش آخرین قیمت کالا
-- =================================================================
Create PROCEDURE inv.RptInv_GoodsLastPrice
	@ProcessID1		int = 55,
	@ProcessID2		int = 90,
	@SelectedGoods	int = 0,
	@SelectedStore	int = 0,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@SortFields		varchar(50) = null,
	@RepOptions		VarChar(10) = '10',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @StrWhere1      As Nvarchar(Max);
DECLARE @StrWhere2      As Nvarchar(Max);
DECLARE @StrWhereM      As Nvarchar(Max);
DECLARE @StrWhere       As Nvarchar(Max);
DECLARE @StrSelect      As Nvarchar(Max);
DECLARE @StrSelect5x     As Nvarchar(Max);
DECLARE @StrSelect1		As Nvarchar(Max);
DECLARE @StrSelect11		As Nvarchar(Max);
DECLARE @StrSelect12		As Nvarchar(Max);
DECLARE @StrSelect1X		As Nvarchar(Max);
DECLARE @StrSelect2			As Nvarchar(Max);
DECLARE @StrSelect3			As Nvarchar(Max);
DECLARE @StrSelect4			As Nvarchar(Max);
DECLARE @StrSelectM			As Nvarchar(Max);
DECLARE @StrSelect2X		As Nvarchar(Max);
DECLARE @StrSelect3X		As Nvarchar(Max);
DECLARE @StrSelect4X		As Nvarchar(Max);
DECLARE @StrSelectAcnt		As Nvarchar(Max);
DECLARE @StrSelectAcntName  As Nvarchar(Max);
DECLARE @PrevDBName			AS Nvarchar(200);
DECLARE @UseProcessID2   As bit;
DECLARE @OnlyWithPrice   As bit;
DECLARE @UseStoreFilter  As bit;
DECLARE @ShowAtomAmount	 As bit;
DECLARE @ShowDiscountDtl As bit;

Begin --=============== S T A R T  C O D E ==============================================
	SET NOCOUNT ON;

	IF (@RepOptions Is Null)		SET @RepOptions = '10';
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
	if (@SortFields	   is null)	set @SortFields	= 'GoodsID';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @PrevDBName	= pub.funSplitString(@RepInfo, '@', 6);

	SET @UseProcessID2 		= Substring(@RepOptions, 1, 1)
	SET @OnlyWithPrice 		= Substring(@RepOptions, 2, 1)
	SET @UseStoreFilter		= Substring(@RepOptions, 3, 1)
	SET @ShowAtomAmount		= Substring(@RepOptions, 4, 1)
	SET @ShowDiscountDtl	= Substring(@RepOptions, 5, 1)

	-- common where --
	SET @StrWhere1 = '(D.GoodsPrice > 0)';

	If (@SelectedStore > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID')

	If (@SelectedAcnt1 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

	set @StrWhere2 = @StrWhere1 

	SET @StrWhere1 =  @StrWhere1 + ' AND D.ProcessID = ' + LTrim(STR(@ProcessID1));

	if (@ProcessID2 = 55)
		SET @StrWhere2 =  @StrWhere2 + ' AND D.ProcessID IN (50, ' + LTrim(STR(@ProcessID2)) + ')';
	Else
		SET @StrWhere2 =  @StrWhere2 + ' AND D.ProcessID = ' + LTrim(STR(@ProcessID2));

	-- outer where --
	SET @StrWhere = '(1=1)';

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'G.GoodsID')

	SET @StrSelect1 = '
		IsNull((
			SELECT Top 1 D.GoodsPrice
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC
           ), 0)'
   
	SET @StrSelectAcnt = '
		IsNull((
			SELECT Top 1 D.AcntCode
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC),'''')'

	SET @StrSelectAcntName = '
		IsNull((
			SELECT Top 1 pub.GetCodeName(D.AcntCode,'+@LangID+')
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC),'''')'
		

	SET @StrSelect11 = '
		IsNull((
			SELECT Top 1 D.SubUnitID
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC
           ), 0)'

	SET @StrSelect12 = '
		IsNull((
			SELECT Top 1 GG.UnitID
			FROM inv.tblStorageDocsDtl D
			INNER JOIN inv.tblGoods GG ON GG.GoodsID = D.GoodsID
			WHERE (D.GoodsID = G.GoodsID) 
			  AND (D.GoodsID = GG.GoodsID) 
			  AND ' + @StrWhere1 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC
           ), 0)'
   
	SET @StrSelect1X = '
        IsNull((
			SELECT Top 1 D.DocDate
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC
           ), 0)'

	SET @StrSelect2 = '
		IsNull((
			SELECT Top 1 D.GoodsPrice
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere2 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC
           ), 0)'
           
	SET @StrSelect3 = '
		IsNull((
				SELECT Top 1 D.GoodsQuantity
				FROM inv.tblStorageDocsDtl D
				WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
				ORDER by D.DocDate DESC, VolumeRowNo DESC
			   ), 0)'

	SET @StrSelect2X = '
		IsNull((
			SELECT Top 1 D.DocDate
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere2 + '
			ORDER by D.DocDate DESC, VolumeRowNo DESC
           ), 0)'
	
	SET @StrSelect3X = '
		IsNull((
			SELECT Top 1 D.AtomAmount
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			AND D.DocDate in ( IsNull((
								SELECT Top 1 D.DocDate
								FROM inv.tblStorageDocsDtl D
								WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
								ORDER by D.DocDate DESC, VolumeRowNo DESC
							   ), 0) )
			ORDER BY D.DocDate DESC, VolumeRowNo DESC
           ), 0)'
	
	SET @StrSelect4X = '
		IsNull((
			SELECT Top 1 D.DiscountDtl
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			AND D.DocDate in ( IsNull((
								SELECT Top 1 D.DocDate
								FROM inv.tblStorageDocsDtl D
								WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
								ORDER by D.DocDate DESC, VolumeRowNo DESC
							   ), 0) )
			ORDER BY D.DocDate DESC, VolumeRowNo DESC
           ), 0)'
 
	IF @PrevDBName <>''
	BEGIN
		SET @StrSelect1 ='CASE WHEN ' + @StrSelect1 + ' >0 THEN ' + @StrSelect1 + ' ELSE 
			IsNull((
				select Top 1 D.GoodsPrice
				from ' + @PrevDBName + '.inv.tblStorageDocsDtl D
				where (D.GoodsID=G.GoodsID) and ' + @StrWhere1 + '
				order by D.DocDate desc, VolumeRowNo desc
			   ), 0) END'

		SET @StrSelectAcnt = 'CASE WHEN '+ @StrSelectAcnt +' <> '''' THEN '+ @StrSelectAcnt+' ELSE
		IsNull((
			SELECT Top 1 D.AcntCode
			FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC)
			,'''') END'

		SET @StrSelectAcntName = 'CASE WHEN '+ @StrSelectAcntName +' <> '''' THEN '+ @StrSelectAcntName+' ELSE
		IsNull((
			SELECT Top 1 pub.GetCodeName(D.AcntCode,'+@LangID+')
			FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
			WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
			ORDER BY D.DocDate DESC, VolumeRowNo DESC),'''') END '

		SET @StrSelect11 ='CASE WHEN ' + @StrSelect11 + ' >0 THEN ' + @StrSelect11 + ' ELSE 
			IsNull((
				SELECT Top 1 D.SubUnitID
				FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
				WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
				ORDER BY D.DocDate DESC, VolumeRowNo DESC
			   ), 0) END'

		SET @StrSelect12 ='CASE WHEN ' + @StrSelect12 + ' >0 THEN ' + @StrSelect12 + ' ELSE 
			IsNull((
				SELECT Top 1 D.UnitID
				FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
				WHERE (D.GoodsID = G.GoodsID) 
				  AND ' + @StrWhere1 + '
				ORDER BY D.DocDate DESC, VolumeRowNo DESC
			   ), 0) END'

		SET @StrSelect1X = 'CASE WHEN ' + @StrSelect1X + ' <>''          '' THEN ' + @StrSelect1X + ' ELSE 
			IsNull((
				SELECT Top 1 D.DocDate
				FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
				WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
				ORDER BY D.DocDate DESC, VolumeRowNo DESC
			   ), 0) END'

		SET @StrSelect2 = 'CASE WHEN ' + @StrSelect2 + ' >0 THEN ' + @StrSelect2 + ' ELSE 
			IsNull((
				SELECT Top 1 D.GoodsPrice
				FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
				WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere2 + '
				ORDER BY D.DocDate DESC, VolumeRowNo DESC
			   ), 0) END'
           
		SET @StrSelect3 = 'CASE WHEN ' + @StrSelect3 + ' >0 THEN ' + @StrSelect3 + ' ELSE 
			IsNull((
					SELECT Top 1 D.GoodsQuantity
					FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
					WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
					ORDER BY D.DocDate DESC, VolumeRowNo DESC
				   ), 0) END'

		SET @StrSelect2X = 'CASE WHEN ' + @StrSelect2X + ' <>'''' THEN ' + @StrSelect2X + ' ELSE 
			IsNull((
				SELECT Top 1 D.DocDate
				FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
				WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere2 + '
				ORDER BY D.DocDate DESC, VolumeRowNo DESC
			   ), 0) END'
	
		SET @StrSelect3X = 'CASE WHEN ' + @StrSelect3X + ' >0 THEN ' + @StrSelect3X + ' ELSE 
			IsNull((
				SELECT Top 1 D.AtomAmount
				FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
				WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
				AND D.DocDate in ( CASE WHEN ' + @StrSelect2X + ' <>'''' THEN ' + @StrSelect2X + ' ELSE 
					IsNull((
							SELECT Top 1 D.DocDate
							FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
							WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere + '
							order BY D.DocDate DESC, VolumeRowNo DESC
								 ), 0) END )
				ORDER BY D.DocDate DESC, VolumeRowNo DESC
			   ), 0) END'

		SET @StrSelect4X = 'CASE WHEN ' + @StrSelect4X + ' >0 THEN ' + @StrSelect4X + ' ELSE 
			IsNull((
				SELECT Top 1 D.AtomAmount
				FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
				WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere1 + '
				AND D.DocDate in ( CASE WHEN ' + @StrSelect2X + ' <>'''' THEN ' + @StrSelect2X + ' ELSE 
					IsNull((
							SELECT Top 1 D.DocDate
							FROM ' + @PrevDBName + '.inv.tblStorageDocsDtl D
							WHERE (D.GoodsID=G.GoodsID) AND ' + @StrWhere + '
							ORDER BY D.DocDate DESC, VolumeRowNo DESC
								 ), 0) END )
				ORDER BY D.DocDate DESC, VolumeRowNo DESC
			   ), 0) END'


	END
	if (@UseProcessID2 = 0)
		SET @StrSelect2 = '0'

	-- balance --
	set @StrWhereM = '(GoodsID = G.GoodsID)'
	
	If (@SelectedStore > 0)
		SET @StrWhereM = @StrWhereM + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'StoreID')

	SET @StrSelect = '
		SELECT DISTINCT G.GoodsID,
						' + @StrSelect1 + ' As GoodsPrice1,
						' + @StrSelect11 + ' As SubUnitID,
						' + @StrSelect12 + ' As UnitID,
						' + @StrSelect1X + ' As DocDate1,
						' + @StrSelect2 + ' As GoodsPrice2,
						' + @StrSelect3 + ' As Quantity,
						' + @StrSelect2X + ' As DocDate2, 
						' + @StrSelectAcnt + ' As AcntCode, 
						'+ @StrSelectAcntName +' As AcntName,'
	SET @StrSelect5x = '
				CASE WHEN ' + LTrim(RTrim(Str(@ShowAtomAmount))) + ' = 1 THEN ' + @StrSelect3X + ' 
					 ELSE 0 
					 END As AtomAmount,
				CASE WHEN ' + LTrim(RTrim(Str(@ShowDiscountDtl))) + ' = 1 THEN ' + @StrSelect4X + ' 
					 ELSE 0 
					 END As DiscountDtl,
				ISNULL((SELECT SUM(GoodsQuantity * EnterKind) 
						FROM inv.tblStorageDocsDtl
						WHERE ' + @StrWhereM + '),0) as Balance, 
				0 WeightGoods
		FROM inv.tblStorageDocsDtl G 
		WHERE ' + @StrWhere

	if (@OnlyWithPrice = 1)
	begin
		set @StrWhere = '(GoodsPrice1 > 0)'

		if (@UseProcessID2 = 1)
			set @StrWhere = @StrWhere + ' OR (GoodsPrice2 > 0)'

	end;
		SET @StrSelect = '
		SELECT G.*,
			   [pub].[funGetGoodsName] (G.GoodsID,'+ @LangID +') AS GoodsName, 
			   ISNULL(UnitName,''-'') AS SubUnitName,
			   [inv].[funGetUnitName] (G.UnitID,'+ @LangID +') AS UnitName,
			   '+LTrim(RTrim(str(@ShowDiscountDtl)))+' AS ShowDiscountDtl,
			   [inv].[funGetTechnicalNo] (G.GoodsID) AS TechnicalNo
		FROM (' + @StrSelect + @StrSelect5x + ') G
		LEFT JOIN inv.tblUnitsDtl u ON G.SubUnitID = u.UnitID 
								   AND LanguageID = '+ @LangID +'
		WHERE ' + @StrWhere
	
	
	set @StrSelect = @StrSelect + ' ORDER BY ' + @SortFields;

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
