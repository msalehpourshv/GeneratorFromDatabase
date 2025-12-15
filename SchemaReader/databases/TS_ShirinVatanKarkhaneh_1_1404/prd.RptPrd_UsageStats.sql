USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED =====================
-- Author		 : TakroSystem\ZIA
-- Create date   : 1389/10/12
-- Viewed By	 : 
-- Last Modified : 1389/11/24
-- Last Modifier : TakroSystem\ZIA
-- Description	 : 
-- ================================================
Create PROCEDURE [prd].[RptPrd_UsageStats]
	@SelectedProds	int = 0,
	@SelectedGoods	int = 0,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@DocCodeFr		int = Null,
	@DocCodeTo		int = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SortFields		nvarchar(50) = Null,
	@RepOptions		varchar(20) = '111',	-- bit array
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS 
Declare @StrSelect	NVarChar(4000);
Declare @StrWhereS	NVarChar(4000);
Declare @StrWhereF	NVarChar(4000);
Declare @StrWhereG	NVarChar(4000);
Declare @StrWhereA	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

--DECLARE	@FirstLayer Bit;
DECLARE	@FinishedOnly Bit;
DECLARE	@Dec Bit;
DECLARE	@Inc Bit;

DECLARE @UnitPart	TINYINT

BEGIN -- ============================ S T A R T   C O D E =========================================

	Set NoCount On;

	--================================== UnitPart
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
	--==================================
	
	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedProds	Is Null)	set @SelectedProds = 0;
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0;
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0;
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0;
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @FinishedOnly = Substring(@RepOptions, 1, 1);
	set @Inc = Substring(@RepOptions, 2, 1);
	set @Dec = Substring(@RepOptions, 3, 1);
	---------------------------------------------------------------------------

	-- Where Clause -----------------------------------------------------------
	Set @StrWhereS = '(1=1)';
	Set @StrWhereF = '(1=1)';
	Set @StrWhereG = '(1=1)';
	Set @StrWhereA = '(1=1)';

	if (@Inc = 0)
		set @StrWhereA = @StrWhereA + ' AND (FormulaQuantity > GoodsQuantity)'
	if (@Dec = 0)
		set @StrWhereA = @StrWhereA + ' AND (FormulaQuantity < GoodsQuantity)'

	if (@SelectedProds > 0)
	begin
		set @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'SH.ProductID') 
		set @StrWhereF = @StrWhereF + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'FH.ProductID') 
	end;

	if (@SelectedGoods > 0)
		set @StrWhereG = @StrWhereG + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'T.GoodsID') 

	if (@SelectedAcnt1 > 0)
		set @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'SH.AcntCode') 
	if (@SelectedAcnt2 > 0)
		set @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'SH.AcntCode') 
	if (@SelectedAcnt3 > 0)
		set @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'SH.AcntCode') 
	if (@SelectedAcnt4 > 0)
		set @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'SH.AcntCode') 

	If (@DocDateFr Is Not Null)
		Set @StrWhereS = @StrWhereS + ' AND (SH.DocDate >= ''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		Set @StrWhereS = @StrWhereS + ' AND (SH.DocDate <= ''' + @DocDateTo + ''')'
	
	If (@DocCodeFr Is Not Null)
		Set @StrWhereS = @StrWhereS + ' AND (SH.SerialNo >= ' + LTrim(Str(@DocCodeFr)) + ')'
	If (@DocCodeTo Is Not Null)
		Set @StrWhereS = @StrWhereS + ' AND (SH.SerialNo <= ' + LTrim(Str(@DocCodeTo)) + ')'	

	If (@FinishedOnly = 1)
		Set @StrWhereS = @StrWhereS + ' AND ((SH.ProcessID=70 AND (SH.ProductCount <= (select sum(GoodsQuantity) from inv.tblStorageDocsDtl M where M.BaseProcessID = SH.ProcessID and M.BaseProcessNo = SH.ProcessNo and M.BaseFiscalYear = SH.FiscalYear and M.BaseSerialNo = SH.SerialNo))) OR 
											 (SH.ProcessID in (82,83) AND  (SH.ProductCount <= (select sum(GoodsQuantity) from inv.tblStorageDocsDtl M where M.ProcessID IN(72,73) AND  M.BaseProcessID = SH.BaseProcessID and M.BaseProcessNo = SH.BaseProcessNo and M.BaseFiscalYear = SH.BaseFiscalYear and M.BaseSerialNo = SH.BaseSerialNo)) )	)'	
	--------------------------------------------------------------------
	-- From Clause -----------------------------------------------------

	--------------------------------------------------------------------
	-- select ----------------------------------------------------------
	
	 --------------------------------------------------
    -- 2) POPULATE #tbl_Products
    --------------------------------------------------
    CREATE TABLE #tbl_Products
    (
        ProductID   NVARCHAR(20) COLLATE Arabic_CS_AS NOT NULL,
        ProductCount FLOAT         NOT NULL,
        ProcessID    INT           NOT NULL,
        ProcessNo    INT           NOT NULL,
        FiscalYear   INT           NOT NULL,
        SerialNo     INT           NOT NULL
    );
	Declare @sql nVarchar(Max) = ''

    SET @sql = N'
    INSERT INTO #tbl_Products(ProductID,ProductCount,ProcessID,ProcessNo,FiscalYear,SerialNo)
    SELECT
      CAST(ISNULL(SH.ProductID,'''') AS NVARCHAR(20)) AS ProductID,
	  SUM(SH.ProductCount) AS ProductCount,
      SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo
    FROM inv.tblStorageDocsHdr SH
    WHERE SH.ProcessID IN (70,82,83)
      AND ' + @StrWhereS + N'
    GROUP BY
      SH.ProductID, SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo;';

    PRINT @sql;            -- debug
    EXEC sp_executesql @sql;

    --------------------------------------------------
    -- 3) RECURSIVE CTE TO TRACE DOWN BOM
    --------------------------------------------------
    SET @sql = N'
    ;WITH UsageCTE AS
    (
      -- ANCHOR: direct consumption from storage
      SELECT
        0 AS Depth,
		CAST('''' AS NVARCHAR(20)) AS ParentGoodsID,
		CAST(SH.ProductID AS NVARCHAR(20)) AS RootProductID,
		CAST(SD.GoodsID AS NVARCHAR(20)) AS GoodsID,
		GD.GoodsName AS GoodsName,
		U.UnitName AS UnitName,
		CAST(GD.GoodsName AS NVARCHAR(MAX)) AS LayerPath,
		CAST(SD.GoodsQuantity AS FLOAT) AS GoodsQty,
		CAST(P.ProductCount * FD.GoodsQuantity / FH.ProductCount AS FLOAT) AS FormulaQty
      FROM #tbl_Products P
      INNER JOIN inv.tblStorageDocsHdr SH ON P.ProductID = SH.ProductID
										 AND P.ProcessID = SH.ProcessID
										 AND P.ProcessNo = SH.ProcessNo
										 AND P.FiscalYear= SH.FiscalYear
										 AND P.SerialNo   = SH.SerialNo
      INNER JOIN inv.tblStorageDocsDtl SD ON SD.ProcessID = SH.ProcessID
										 AND SD.ProcessNo = SH.ProcessNo
										 AND SD.FiscalYear= SH.FiscalYear
										 AND SD.SerialNo   = SH.SerialNo
	  INNER JOIN prd.tblFormulasHdr FH ON FH.ProductID = P.ProductID
									  AND FH.IsDefault = 1
      INNER JOIN prd.tblFormulasDtl FD ON FD.ProductID = FH.ProductID
									  AND FD.SerialNo  = FH.SerialNo
      INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(SD.GoodsID,' + CAST(@str_Goods AS NVARCHAR) + N'+1,' + CAST(@str_GoodsSum AS NVARCHAR) + N')
								   AND GD.PartNumber = ' + CAST(@UnitPart AS NVARCHAR) + N'
      INNER JOIN inv.tblGoods G ON G.GoodsID   = GD.GoodsID
							   AND G.PartNumber= GD.PartNumber
      INNER JOIN inv.tblUnitsDtl U ON U.UnitID = G.UnitID

      UNION ALL

      -- RECURSIVE: dive into sub‐formulas
      SELECT
        C.Depth + 1  AS Depth,
		CAST(C.GoodsID AS NVARCHAR(20)) AS ParentGoodsID,
		CAST(C.GoodsID AS NVARCHAR(20)) AS RootProductID,
        CAST(FD.GoodsID AS NVARCHAR(20)) AS GoodsID,
        GD2.GoodsName AS GoodsName,
        U2.UnitName AS UnitName,
        CAST(C.LayerPath + '' >> '' + GD2.GoodsName  AS NVARCHAR(MAX)) AS LayerPath,
        CAST(FD.GoodsQuantity AS FLOAT) AS GoodsQty,
        CAST(C.FormulaQty * FD.GoodsQuantity / FH.ProductCount AS FLOAT) AS FormulaQty
      FROM UsageCTE C
      INNER JOIN prd.tblFormulasHdr FH ON FH.ProductID = C.GoodsID
									  AND FH.IsDefault = 1
      INNER JOIN prd.tblFormulasDtl FD ON FD.ProductID = FH.ProductID
									  AND FD.SerialNo  = FH.SerialNo
      INNER JOIN inv.tblGoodsDtl GD2 ON GD2.GoodsID = SUBSTRING(FD.GoodsID,'+ CAST(@str_Goods AS NVARCHAR) + N'+1,'+ CAST(@str_GoodsSum AS NVARCHAR) + N')
									AND GD2.PartNumber = ' + CAST(@UnitPart AS NVARCHAR) + N'
      INNER JOIN inv.tblGoods G2 ON G2.GoodsID   = GD2.GoodsID
								AND G2.PartNumber= GD2.PartNumber
      INNER JOIN inv.tblUnitsDtl U2 ON U2.UnitID = G2.UnitID
    )

    SELECT
	  RootProductID,
      ParentGoodsID AS ParentID,
      GoodsID + REPLICATE('' << '', Depth) AS GoodsID,
      REPLICATE('' >> '', Depth) + GoodsName AS GoodsName,
      UnitName,
      SUM(GoodsQty) GoodsQuantity,
      SUM(FormulaQty) FormulaQuantity
    FROM UsageCTE
    WHERE ' + @StrWhereG + N'
      AND ' + @StrWhereA + N'
    GROUP BY RootProductID, ParentGoodsID, GoodsID, GoodsName, UnitName, Depth, LayerPath
    ORDER BY LayerPath
    OPTION(MAXRECURSION 0);';

    PRINT @sql;            -- debug
    EXEC sp_executesql @sql;

    DROP TABLE #tbl_Products;
	--------------------------------------------------------
End
GO
