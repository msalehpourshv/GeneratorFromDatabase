USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ==================
-- Author		 : TakroSyatem\Ahmadnejad
-- Create date   : 1388/06/12
-- Viewed By	 : 
-- Last Modified : 1393/01/19
-- Last Modifier : TakroSyatem\Hamid
-- Description   : برگ انبار گردانی 
-- ============================================
Create PROCEDURE [inv].[RptStore_Numeration_Doc]
	@SerialNoFr		Int,
	@SerialNoTo		Int = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrWhere		NVarChar(Max);

-- ======
DECLARE @goods_id						Varchar(20);
DECLARE @batch_no						NVarchar(20);
DECLARE @serial_no						int;
DECLARE @docrowno						int;
DECLARE @goods_quantity					DECIMAL(28,9);

-- ======
DECLARE @unit_name						nvarchar(200);
DECLARE @unit_id						varchar(20);
DECLARE @unit_value						float;
DECLARE @unit_value_Temp				float;
DECLARE @Mainunit_value					float;
DECLARE @Cnt							INT;

-- ======
DECLARE @unit_nameGoods1				nvarchar(200);
DECLARE @unit_idGoods1					varchar(20);
DECLARE @unit_valueGoods1				float;
DECLARE @Mainunit_valueGoods1			float;

DECLARE @unit_nameGoods2				nvarchar(200);
DECLARE @unit_idGoods2					varchar(20);
DECLARE @unit_valueGoods2				float;
DECLARE @Mainunit_valueGoods2			float;

DECLARE @strGoodsQuantity				NVarChar(200);
DECLARE @strSubUnitQuantity				NVarChar(200);
DECLARE @strDocRowNo					NVarChar(200);
DECLARE @strRowNo						NVarChar(200);
DECLARE @strBatchNo						NVarChar(200);
DECLARE @strDescDtl						NVarChar(200);
DECLARE @StrUserPrice					NVarChar(1000);
DECLARE @StrUserPriceID					NVarChar(1000);
DECLARE @StrUserPriceGrp				NVarChar(1000);
DECLARE @GroupBy						NVarChar(Max);

BEGIN --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	SELECT @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	FROM pub.tblCodeLayer 
	WHERE TableName='inv.tblGoods' AND PartNumber<@UnitPart

	SELECT @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	FROM pub.tblCodeLayer 
	WHERE TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- ==========
	SET @StrWhere = '1 = 1'
	
	-- Init ------------------------------------------
	IF (@SerialNoTo Is Null) SET @SerialNoTo = @SerialNoFr;
	IF (@RepInfo Is Null)	 SET @RepInfo = '1@1@1';
							 
	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	--------------------------------------------------
	
	-- ==========
	DECLARE @QuantityDecimalsToForms AS Int

	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'

	SET @QuantityDecimalsToForms = @QuantityDecimalsToForms - 1
	
	-- ==========
	DECLARE @sal_ShowMainAndSubUnitInRpt Bit;
	SET @sal_ShowMainAndSubUnitInRpt = 0

	SELECT @sal_ShowMainAndSubUnitInRpt = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'sal_ShowMainAndSubUnitInRpt'
	
	-- ==========
	DECLARE @sal_AggregateSimilarGoodsInRpt Bit;
	SET @sal_AggregateSimilarGoodsInRpt = 0

	SELECT @sal_AggregateSimilarGoodsInRpt = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'sal_AggregateSimilarGoodsInRpt'

	-- ==========
	DECLARE @sal_AggregateSimilarGoodsUPI Bit;
	SET @sal_AggregateSimilarGoodsUPI = 0

	SELECT @sal_AggregateSimilarGoodsUPI = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'sal_AggregateSimilarGoodsUPI'	

	--====================================
	BEGIN TRY
		DROP TABLE ##tbl_Tmp1
	END TRY
	BEGIN CATCH
	END CATCH

	-- ==========
	BEGIN TRY
		DROP TABLE #tbl_result
	END TRY
	BEGIN CATCH
	END CATCH

	Create Table #tbl_result
	(
		SerialNo		Int,
		DocRowNo		Int,	
		GoodsID			varchar(20) collate Arabic_CS_AS null,
		BatchNo			nvarchar(20) collate Arabic_CS_AS null,
		GoodsName		nvarchar(200) collate Arabic_CS_AS null,
		GoodsQuantity	DECIMAL(28,9),
		UnitIDGoods1	varchar(20) collate Arabic_CS_AS null,
		UnitNameGoods1	nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity1	DECIMAL(28,9),
		UnitIDGoods2	varchar(20) collate Arabic_CS_AS null,
		UnitNameGoods2	nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity2	DECIMAL(28,9),
		Weight			float,
		Volume			float,
		BarCode			varchar(20) collate Arabic_CS_AS null
	);
		
	Declare @tbl_units as table
	(
		unit_id			varchar(20) not null, 
		unit_name		nvarchar(200) not null, 
		unit_value		float not null,
		Mainunit_value	float not null,
		cnt				int not null
	);

	-- ===============
	IF @sal_AggregateSimilarGoodsUPI = 0
	Begin
		SET	@StrUserPrice	 = 'IsNull((Select UParams From inv.tblGoodsUserPrice P Where P.ID = D.UserPriceID) ,0) As UserPrice'
		SET	@StrUserPriceID  = 'ISNULL(D.UserPriceID, '''') UserPriceID'
		SET	@StrUserPriceGrp = ', D.UserPriceID'				
	End	
	Else
	Begin
		SET	@StrUserPrice    = '0 UserPrice'				
		SET	@StrUserPriceID  = '0 UserPriceID'				
		SET	@StrUserPriceGrp = ''				
	End	
	
	-- ====================
	IF @sal_AggregateSimilarGoodsInRpt = 1
	BEGIN
		Set @strGoodsQuantity	= 'Sum(D.GoodsQuantity) GoodsQuantity'
		Set @strSubUnitQuantity	= 'Sum(D.SubUnitQuantity) SubUnitQuantity'
		Set @strDocRowNo		= '0 DocRowNo'
		Set @strRowNo			= '0 RowNo'
		Set @strBatchNo			= '0 BatchNo'
		Set @strDescDtl			= ''''' DescDtl'		
		Set @GroupBy			= '
	GROUP BY D.SerialNo, 
			 D.DocDate, 
			 D.StoreID, 
			 D.GoodsID, 
			 D.SubUnitID, 
			 H.DocDesc, 
			 U.UnitName, 
			 S.StoreName, 
			 D.GoodsID, 
			 H.SessionNo, 
			 G.TechnicalSpecifications, 
			 G.TechnicalNo, 
			 H.StoreID, 
			 H.DocDate ' + LTrim(RTrim(@StrUserPriceGrp))
	END
	ELSE
	BEGIN
		Set @strGoodsQuantity	= 'D.GoodsQuantity'
		Set @strSubUnitQuantity	= 'D.SubUnitQuantity'
		Set @strDocRowNo		= 'D.DocRowNo'
		Set @strRowNo			= 'D.RowNo'
		Set @strBatchNo			= 'D.BatchNo'
		Set @strDescDtl			= 'D.DescDtl'				
		Set @GroupBy			= ''
	END	

	-- Select Clause ----------------------------------------
	SET @StrSelect = '
		SELECT	D.SerialNo, 
				' + LTrim(RTrim(@strRowNo)) + ', 
				D.DocDate, 
				D.StoreID, 
				D.GoodsID, 
				' + LTrim(RTrim(@strDescDtl)) + ', 
				' + LTrim(RTrim(@strDocRowNo)) + ', 
				D.SubUnitID, 
				' + LTrim(RTrim(@strGoodsQuantity)) + ', 
				' + LTrim(RTrim(@strSubUnitQuantity)) + ', 
				' + LTrim(RTrim(@strBatchNo)) + ', 
				' + LTrim(RTrim(@StrUserPriceID)) + ', 
				H.DocDesc, 
				U.UnitName, 
				S.StoreName, 
				pub.funGetGoodsName(D.GoodsID, 
				' + LTrim(RTrim(@LangID)) + ') GoodsName,
				pub.GetUserName(H.SessionNo) AS UserName, 
				G.TechnicalSpecifications, 
				G.TechnicalNo,
				[inv].[funGetLastBuyGoodsPrice] (D.GoodsID,H.StoreID,H.DocDate, 0, ' + LTrim(RTrim(@LangID)) + ') As LastBuyPrice,
				' + LTrim(RTrim(@StrUserPrice)) + '
		INTO ##tbl_Tmp1
		FROM inv.tblStoresNumerationDtl D 
		INNER JOIN inv.tblStoresNumerationHdr H ON H.SerialNo = D.SerialNo
		LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(D.GoodsID, ' + LTrim(RTrim(Str(@str_Goods))) + ' + 1, ' + LTrim(RTrim(Str(@str_GoodsSum))) + ') AND PartNumber = ' + LTrim(RTrim(Str(@UnitPart))) + '
		LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = G.UnitID AND U.LanguageID = ' + LTrim(RTrim(@LangID)) + '
		LEFT JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID AND S.LanguageID = ' + LTrim(RTrim(@LangID)) + '
		WHERE D.SerialNo >= ' + LTrim(RTrim(Str(@SerialNoFr))) + ' 
		  AND D.SerialNo <= ' + LTrim(RTrim(Str(@SerialNoTo))) + ' ' + @GroupBy
	
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;	
	------------------------------------------------------------
	SET @StrSelect = '
		INSERT INTO #tbl_result
		SELECT S.SerialNo, 
			   S.DocRowNo, 
			   S.GoodsID, 
			   '''', 
			   '''', 
			   GoodsQuantity, 
			   '''', 
			   '''', 
			   0, 
			   '''', 
			   '''', 
			   0, 
			   0, 
			   0, 
			   ''''
		FROM ##tbl_Tmp1 S 
		-- =========='

	--Print @StrSelect;
	EXEC sp_executesql @StrSelect;
	--====================================

	--Select * From #tbl_result	
	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	DECLARE cur_goods CURSOR FOR
		SELECT SerialNo, DocRowNo, GoodsID, BatchNo, GoodsQuantity
		FROM #tbl_result
	OPEN cur_goods;
		
	FETCH NEXT FROM cur_goods INTO @serial_no, @docrowno, @goods_id, @batch_no, @goods_quantity
	WHILE (@@fetch_status = 0)
	BEGIN
		-- 1- empty units table
		DELETE FROM @tbl_units
		
		-- 2- fill units of 1 goods
		INSERT INTO @tbl_units
		SELECT TOP 3 t.UnitID, u.UnitName, t.UnitValue, t.MainUnitValue,
		(SELECT COUNT(*) 
		 FROM(
			SELECT UnitID, 1 AS UnitValue,1 MainUnitValue
			FROM inv.tblGoods
			WHERE GoodsID = @goods_id
			UNION
			SELECT SubUnitID, UnitValue,MainUnitValue
			FROM inv.tblSubUnitsDtl S
			WHERE GoodsID = @goods_id 
			  AND ShowInInvoice = 1) z)cnt
		FROM(
			SELECT UnitID, 1 AS UnitValue,1 MainUnitValue
			FROM inv.tblGoods
			WHERE GoodsID = @goods_id
			UNION
			SELECT SubUnitID, CASE WHEN UnitValue <> 0 THEN UnitValue ELSE 1 END UnitValue, MainUnitValue
			FROM inv.tblSubUnitsDtl S
			WHERE GoodsID = @goods_id 
			  AND ShowInInvoice = 1) t 
		INNER JOIN inv.tblUnitsDtl u ON u.UnitID = t.UnitID 
										AND u.LanguageID = @LangID
		ORDER BY (t.MainUnitValue / t.UnitValue) desc
			
		-- read units row by row
		DECLARE cur_units CURSOR FOR
			SELECT * FROM @tbl_units
		OPEN cur_units;
			
		--select * from @tbl_units

		-- init
		SET @unit_idGoods1			 = '';
		SET @unit_nameGoods1		 = '';
		SET @unit_valueGoods1		 =  0;
		SET @Mainunit_valueGoods1	 =  0;
		
		SET @unit_idGoods2			 = '';
		SET @unit_nameGoods2		 = '';
		SET @unit_valueGoods2		 =  0;
		SET @Mainunit_valueGoods2	 =  0;
		
		--select * from @tbl_units
		
		-- First Unit
		FETCH NEXT FROM cur_units INTO @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

		IF (@@fetch_status = 0)
		BEGIN
			set @unit_idGoods1		= @unit_id;
			set @unit_nameGoods1	= @unit_name;

			IF @unit_value = 0 SET @unit_value = 1
			IF @Mainunit_value = 0 SET @Mainunit_value = 1
			
			IF @Cnt > 1
			BEGIN
				SET @unit_valueGoods1	 = floor((@goods_quantity + 0.000000001) * @unit_value / @Mainunit_value)
			END
			ELSE
			BEGIN
				SET @unit_valueGoods1	 = @goods_quantity * @unit_value / @Mainunit_value
			END
			
			SET @goods_quantity = @goods_quantity - (@unit_valueGoods1 * @Mainunit_value / @unit_value)

			-- Second Unit
			FETCH NEXT FROM cur_units INTO @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

			IF (@@fetch_status = 0)
			BEGIN
				SET @unit_idGoods2	 = @unit_id;
				SET @unit_nameGoods2 = @unit_name;
				
				IF @Cnt > 2 
				BEGIN
					SET @unit_valueGoods2 = floor((@goods_quantity + 0.000000001) * @unit_value / @Mainunit_value)
				END
				ELSE	
				BEGIN
					SET @unit_valueGoods2 = @goods_quantity * @unit_value / @Mainunit_value
				END
				
				SET @goods_quantity	= @goods_quantity - (@unit_valueGoods2 * @Mainunit_value / @unit_value)
			END;

		END;

		-- close units cursor
		CLOSE cur_units;
		DEALLOCATE cur_units;
		-- update result
		UPDATE #tbl_result
		SET GoodsName		= IsNull([pub].[funGetGoodsName](G.GoodsID, @LangID), ''),
			UnitIDGoods1	= IsNull(@unit_idGoods1,''),
			UnitNameGoods1	= IsNull(@unit_nameGoods1,''),
			GoodsQuantity1	= IsNull(@unit_valueGoods1,0),
			
			UnitIDGoods2	= IsNull(@unit_idGoods2,''),
			UnitNameGoods2	= IsNull(@unit_nameGoods2,''),
			GoodsQuantity2	= IsNull(@unit_valueGoods2,0),
			
			Weight			= IsNull(G.GoodsWeight,0),
			Volume			= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0),
			BarCode			= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
			
		FROM inv.tblGoods G
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) 
									 AND GD.PartNumber= @UnitPart 
									 AND GD.LanguageID = @LangID
		WHERE G.GoodsID = @goods_id 
		  AND #tbl_result.BatchNo = @batch_no 
		  AND #tbl_result.GoodsID = @goods_id 
		  AND #tbl_result.SerialNo = @serial_no 
		  AND #tbl_result.DocRowNo = @docrowno
		
		-- next
		FETCH NEXT FROM cur_goods INTO @serial_no, @docrowno, @goods_id, @batch_no, @goods_quantity
	END

	-- close goods cursor
	CLOSE cur_goods;
	DEALLOCATE cur_goods;
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************
	--Select * From #tbl_result
	--Select * From ##tbl_Tmp1
	
	SELECT T.*, 
		   Round(IsNull(R.GoodsQuantity,0), @QuantityDecimalsToForms) RGoodsQuantity,
		   Round(IsNull(R.GoodsQuantity1,0), @QuantityDecimalsToForms) GoodsQuantity1, 
		   ISNULL(R.UnitIDGoods1,'') UnitIDGoods1, 
		   ISNULL(R.UnitNameGoods1,'') UnitNameGoods1, 
		   Round(IsNull(R.GoodsQuantity2,0), @QuantityDecimalsToForms) GoodsQuantity2, 
		   ISNULL(R.UnitIDGoods2,'') UnitIDGoods2, 
		   ISNULL(R.UnitNameGoods2,'') UnitNameGoods2, 
		   ISNULL(R.Weight,0) RWeight, 
		   ISNULL(R.Volume,0) RVolume, 
		   ISNULL(R.BarCode,0) RBarCode,
		   @sal_ShowMainAndSubUnitInRpt MainAndSubUnit
	FROM ##tbl_Tmp1 T
	LEFT JOIN #tbl_result R ON R.SerialNo = T.SerialNo 
						   And R.DocRowNo = T.DocRowNo 
						   And R.GoodsID = T.GoodsID 
						   And R.BatchNo = T.BatchNo
	-- ==============================
	
END
GO
