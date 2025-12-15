USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE inv.RPT_Goods_Container_Report_In_Store
       @ProcessID        Int         = 0,
       @ProcessNo        Int         = 0,
       @FiscalYear       Int         = 0,
       @SerialNo         Int         = 0,
       @StoreID          VarChar(20) = '',  -- 0103
       @GoodsID          VarChar(20) = '',  -- 42040202021024
       @DocDate_Fr       Char(10)    = '',  -- مثل '1404/05/01'
       @DocDate_To       Char(10)    = '',
       @ContainerID      Char(10)    = '',
	   @Cardex_Report    Bit         = 0

WITH ENCRYPTION
AS

DECLARE @StrSelect_1 NVarChar(Max) = ''
DECLARE @StrSelect_2 NVarChar(Max) = ''
DECLARE @StrWhere_1  NVarChar(Max) = '1 = 1'
DECLARE @StrWhere_2  NVarChar(Max) = '1 = 1'
DECLARE @StrWhere_3  NVarChar(Max) = ''
DECLARE @StrFields   NVarChar(Max) = ''
DECLARE @StrGroup_By NVarChar(Max) = ''

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- =====================================================================================
	-- ===================================================================================== WHERE
	-- =====================================================================================
	IF @ProcessID <> 0 And @ProcessID Is Not Null
		SET @StrWhere_1 = @StrWhere_1 + '  
          And S.ProcessID   = ' + LTrim(RTrim(Str(@ProcessID)))

	IF @ProcessNo <> 0 And @ProcessNo Is Not Null
		SET @StrWhere_1 = @StrWhere_1 + '  
          And S.ProcessID   = ' + LTrim(RTrim(Str(@ProcessNo)))

	IF @FiscalYear <> 0 And @FiscalYear Is Not Null
		SET @StrWhere_1 = @StrWhere_1 + '  
          And S.FiscalYear  = ' + LTrim(RTrim(Str(@FiscalYear)))

	IF @SerialNo <> 0 And @SerialNo Is Not Null
		SET @StrWhere_1 = @StrWhere_1 + '  
          And S.SerialNo    = ' + LTrim(RTrim(Str(@SerialNo)))

	IF @StoreID <> '' And @StoreID Is Not Null
		SET @StrWhere_1 = @StrWhere_1 + '  
          And D.StoreID     = ''' + LTrim(RTrim(@StoreID)) + ''''

	IF @GoodsID <> '' And @GoodsID Is Not Null
		SET @StrWhere_1 = @StrWhere_1 + '  
          And D.GoodsID     = ''' + LTrim(RTrim(@GoodsID)) + ''''

	IF @DocDate_Fr <> '' And @DocDate_Fr Is Not Null
	Begin
		SET @StrWhere_2 = @StrWhere_2 + '  
          And B.DocDate >= ''' + LTrim(RTrim(@DocDate_Fr)) + ''''

		SET @StrWhere_3 = @StrWhere_3 + '  
          And DocDate < ''' + LTrim(RTrim(@DocDate_Fr)) + ''''
	End

	IF @DocDate_To <> '' And @DocDate_To Is Not Null
		SET @StrWhere_2 = @StrWhere_2 + '  
          And B.DocDate <= ''' + LTrim(RTrim(@DocDate_To)) + ''''

	IF @ContainerID <> '' And @ContainerID Is Not Null
		SET @StrWhere_1 = @StrWhere_1 + '  
          And S.ContainerID = ''' + LTrim(RTrim(@ContainerID)) + ''''

	-- ===================================================================================== Select
	SET @StrSelect_1 = '
        IF OBJECT_ID(''#Tbl_Goods_Remain'') IS NOT NULL DROP TABLE #Tbl_Goods_Remain;

        -- ===============================================
		Select StoreID, GoodsID, Cast(inv.funGetGoodsRemain(NULL, NULL, NULL, NULL, NULL, StoreID, GoodsID, NULL, ''1410/12/29'', 0) As Decimal(10, 4)) As Last_Remain
		INTO #Tbl_Goods_Remain
		From 
		(
		  Select Distinct StoreID, GoodsID 
		  From inv.tblStorageDocsDtl 
		  Where SubString(GoodsID, 1, 1) IN(''4'') And Len(GoodsID) = 14 --And GoodsID = ''42040202021024''
		) A

		-- ================================================================================================
        IF OBJECT_ID(''#Base'') IS NOT NULL DROP TABLE #Base;

        -- ===============================================
        SELECT 
            P.ProcessName + CASE WHEN S.ProcessNo = 1 THEN '''' ELSE N'' - '' + LTRIM(RTRIM(STR(S.ProcessNo))) END AS ProcessName, S.FiscalYear, S.SerialNo, S.DocRowNo, D.DocDate, D.VolumeRowNo,
            D.StoreID, D.StoreID2, D.GoodsID, GD.GoodsName, D.SubUnitQuantity, S.ContainerID, S.ContainerID2, S.NumberPerContainer AS Qty_Container, S.ProductionDate, S.ExpireDate,
            S.ContainerStoresID, S.ContainerStoresID2, CASE WHEN S.EnterKind = -1 THEN N''خروج'' ELSE N''ورود'' END AS OP_Type, Qty = S.NumberPerContainer * S.EnterKind
        INTO #Base
        FROM inv.tblStorageDocsSerials   AS S
        JOIN inv.tblStorageDocsDtl       AS D  ON D.ProcessID  = S.ProcessID AND D.ProcessNo = S.ProcessNo AND D.FiscalYear = S.FiscalYear AND D.SerialNo = S.SerialNo AND D.DocRowNo = S.DocRowNo
        JOIN inv.tblGoodsDtl             AS GD ON GD.GoodsID = D.GoodsID
        JOIN pub.tblProcess              AS P  ON P.ProcessID = S.ProcessID AND P.ProcessNo = D.ProcessNo
        WHERE ' + @StrWhere_1 + '

		-- ================================================================================================
		CREATE CLUSTERED INDEX IX_Base_PartFull
		ON #Base(GoodsID, StoreID, ContainerStoresID, ContainerID, ProductionDate, ExpireDate, DocDate, VolumeRowNo, FiscalYear, SerialNo, DocRowNo);

		CREATE NONCLUSTERED INDEX IX_Base_PartStore
		ON #Base(GoodsID, StoreID, DocDate, VolumeRowNo, FiscalYear, SerialNo, DocRowNo)
		INCLUDE (Qty);

		-- ================================================================================================ @DocDate_Fr افتتاحیه‌ها قبل از
		IF OBJECT_ID(''#OpenFull'') IS NOT NULL DROP TABLE #OpenFull;
		IF OBJECT_ID(''#OpenStore'') IS NOT NULL DROP TABLE #OpenStore;

        -- ===============================================
		SELECT 
			GoodsID, StoreID, ContainerStoresID, ContainerID, ProductionDate, ExpireDate,
			Opening_Full = SUM(Qty)
		INTO #OpenFull
		FROM #Base
		WHERE ' + 
		Case When @DocDate_Fr <> '' Then'
        DocDate < ''' + LTrim(RTrim(@DocDate_Fr)) + '''' Else ' 1 = 0' End + '

		GROUP BY GoodsID, StoreID, ContainerStoresID, ContainerID, ProductionDate, ExpireDate;

		SELECT 
			GoodsID, StoreID,
			Opening_Store = SUM(Qty)
		INTO #OpenStore
		FROM #Base
		WHERE ' + 
		Case When @DocDate_Fr <> '' Then'
        DocDate < ''' + LTrim(RTrim(@DocDate_Fr)) + '''' Else ' 1 = 0' End + '
		GROUP BY GoodsID, StoreID;'

	SET @StrSelect_2 = '
		-- ================================================================================================
		-- ================================================================================================ Result
		-- ================================================================================================
        IF OBJECT_ID(''#Tbl_Store_Remain_Result'') IS NOT NULL DROP TABLE #Tbl_Store_Remain_Result;

        -- ===============================================
		SELECT B.ProcessName, B.DocDate, B.VolumeRowNo, B.StoreID, B.StoreID2, B.GoodsID, B.GoodsName, B.SubUnitQuantity, B.ContainerID, B.ContainerID2, B.ProductionDate,
               B.ExpireDate, B.ContainerStoresID, B.ContainerStoresID2, B.Qty_Container Qty, B.OP_Type,--, B.FiscalYear, B.SerialNo

			Pallet_Remain = COALESCE(OFL.Opening_Full, 0) + SUM(B.Qty) OVER (PARTITION BY B.GoodsID, B.StoreID, B.ContainerStoresID, B.ContainerID, B.ProductionDate, B.ExpireDate
			                  ORDER BY B.DocDate, B.VolumeRowNo, B.FiscalYear, B.SerialNo, B.DocRowNo
			                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			                  ),
			Store_Remain = COALESCE(OS.Opening_Store, 0) + SUM(B.Qty) 
			                  OVER (PARTITION BY B.GoodsID, B.StoreID ORDER BY B.DocDate, B.VolumeRowNo, B.FiscalYear, B.SerialNo, B.DocRowNo
			                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			                  ), 
			R1.Last_Remain Last_Store_Remain, (Select Sum(Last_Remain) From #Tbl_Goods_Remain Where GoodsId = B.GoodsID) Full_Store_Remain

		INTO #Tbl_Store_Remain_Result
		FROM #Base AS B
		LEFT JOIN #OpenFull  AS OFL ON OFL.GoodsID = B.GoodsID AND OFL.StoreID = B.StoreID AND OFL.ContainerStoresID = B.ContainerStoresID AND OFL.ContainerID = B.ContainerID AND 
								OFL.ProductionDate  = B.ProductionDate AND OFL.ExpireDate = B.ExpireDate
		LEFT JOIN #OpenStore AS OS     ON OS.GoodsID = B.GoodsID AND OS.StoreID = B.StoreID
		Inner Join #Tbl_Goods_Remain R1 ON R1.GoodsID = B.GoodsID AND R1.StoreID = B.StoreID
		WHERE ' + @StrWhere_2 + '
		ORDER BY B.GoodsID, B.DocDate, B.VolumeRowNo;
		
		-- ===================================================================================== Last Result' + 
		Case When @Cardex_Report = 1 Then '
        Select * From #Tbl_Store_Remain_Result
		ORDER BY GoodsID, DocDate, VolumeRowNo;'
		Else '
        SELECT P.GoodsID, P.GoodsName, P.StoreID, P.ContainerStoresID, P.ContainerID, P.ProductionDate, P.ExpireDate, P.Net_Qty
        FROM (
              SELECT GoodsID, GoodsName, StoreID, ContainerStoresID, ContainerID, ProductionDate, ExpireDate, Net_Qty = SUM(CASE WHEN OP_Type = N''ورود'' THEN Qty ELSE -Qty END)
              FROM #Tbl_Store_Remain_Result
              GROUP BY GoodsID, GoodsName, StoreID, ContainerStoresID, ContainerID, ProductionDate, ExpireDate
              HAVING SUM(CASE WHEN OP_Type = N''ورود'' THEN Qty ELSE -Qty END) <> 0
             ) AS P
        INNER JOIN (
                    SELECT GoodsID, StoreID, StoreTotal = SUM(CASE WHEN OP_Type = N''ورود'' THEN Qty ELSE -Qty END)
                    FROM #Tbl_Store_Remain_Result
                    GROUP BY GoodsID, StoreID
                   ) AS S ON S.GoodsID = P.GoodsID AND S.StoreID = P.StoreID
				   
        WHERE S.StoreTotal <> 0
        ORDER BY P.GoodsID, P.StoreID, P.ContainerStoresID, P.ContainerID, P.ProductionDate, P.ExpireDate;
		'
		End

	-- ===================================================================================== EXEC
	PRINT @StrSelect_1
	PRINT @StrSelect_2
	SET   @StrSelect_1 = @StrSelect_1 + @StrSelect_2;
	EXEC  sp_executesql @StrSelect_1;

END

GO
