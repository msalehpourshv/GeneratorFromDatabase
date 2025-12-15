USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE pln.SP_Create_New_Produce_Step
	@ProductID          Varchar(20)   = '32030403007',
	@Formula_Update     Bit           = 0,
	@Update_By_Old_Info Bit           = 0,
	@Description        NVarchar(500) = '',
	@Do_Insert          Int           = 0

-- ===== Do_Insert    0  = Select
-- ===== Do_Insert    1  = Create
-- ===== Do_Insert    2  = Delete

WITH ENCRYPTION
AS 

DECLARE @StrSelect	NVarChar(Max) = '';
DECLARE @StrSelect2	NVarChar(Max) = '';
DECLARE @StrSelect3	NVarChar(Max) = '';
DECLARE @StrSelect4	NVarChar(Max) = '';
DECLARE @StrWhere	NVarChar(Max) = '';

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- ========================================================================================================
	-- ======================================================================================================== START
	-- ========================================================================================================
	-- ================================================= Find Duplicate Records In Tbl_AAATmpOprations
	--Select ProductID, Count(ProductID)
	--From acc.tblAAATmpOprations
	--Where 1 = 1
	--	--And ProductID IN ('41040221002001')
	--Group By ProductID
	--Having Count(ProductID) > 1

	-- ================================================= DELETE Duplicate Records In Tbl_AAATmpOprations
	WITH MyTable AS 
		(
			Select ProductID, 
				   RowNo = ROW_NUMBER()Over(Partition By ProductID Order By ProductID)
			From acc.tblAAATmpOprations 
			Where 1 = 1
		)
	--SELECT * FROM MyTable WHERE RowNo > 1
	DELETE FROM MyTable WHERE RowNo > 1
	
	-- ======================================================================================================== @StrSelect2
	-- =======================================================
	-- ======================================================= SELECT And UPDATE
	-- =======================================================
	IF @Do_Insert = 0 OR @Do_Insert = 1
	BEGIN
		SET @StrSelect2 = '
		-- ================================================= Hdr ' +
		Case When @Do_Insert = 1 Then '
		INSERT INTO pln.tblProduceStepHdr (ProductID, SerialNo, ProduceMethodName, IsDefaultMethod, FormulaNo, ProductionLineID)
		'
		Else '' 
		End

		SET @StrSelect2 = @StrSelect2 + '
		-- ====== Select
		SELECT Replace(T.ProductID, '' '', '''') ProductID,
			   ROW_NUMBER() Over(Partition By Replace(T.ProductID, '' '', '''') Order By Replace(T.ProductID, '' '', '''')) + 
					  (
					   Select IsNull(Max(SerialNo), 0)
					   From pln.tblProduceStepHdr 
					   Where ProductID = SH.ProductID
					  ) SerialNo,
			   LTrim(RTrim(Str(IsNull(ROW_NUMBER() Over(Partition By SH.ProductID Order By SH.ProductID) + 
					  (
					   Select IsNull(Max(SerialNo), 0)
					   From pln.tblProduceStepHdr 
					   Where ProductID = SH.ProductID
					  ), 1)))) +
					  '' - '' + pub.funChangeDate_GergorianToPersian(GETDATE()) + '''' ProduceMethodName, 
			   0 IsDefaultMethod, Case When 1 = 1 Then F.SerialNo Else SH.FormulaNo End FormulaNo, SH.ProductionLineID' +
					  Case When @Do_Insert = 0 Then ', 
			   Case When (AcceptStoreID Is Null OR SH.ProductionLineID Is Null) Then 
					''بدون استاندارد''
					When (AcceptStoreID Is Not Null And SH.ProductionLineID Is Not Null) And 
					                     (SH.FormulaNo = F.SerialNo OR F.SerialNo Is Null)  Then 
			        ''بدون فرمول جديد'' 
					When (AcceptStoreID Is Not Null And SH.ProductionLineID Is Not Null) And 
					             (SH.FormulaNo <> F.SerialNo And F.SerialNo Is Not Null) And
						            (IsDefaultMethod = 0 OR IsDefaultMethod Is Null OR NeedStep = 0 OR NeedStep Is Null) Then 
					''بدون استاندارد پیش فرض''
               Else '''' End [Status]' Else '' End + '
		-- ====== From
		FROM      acc.tblAAATmpOprations     T
		LEFT JOIN pln.tblProduceStepHdr     SH ON Replace(T.ProductID, '' '', '''') = SH.ProductID And SH.IsDefaultMethod = 1
		LEFT JOIN pln.tblProduceStepDtl     SD ON SH.ProductID = SD.ProductID And SH.SerialNo = SD.SerialNo
		LEFT JOIN inv.tblGoods              GH ON GH.GoodsID = Replace(T.ProductID, '' '', '''')
		LEFT JOIN inv.tblGoodsDtl           GD ON GD.GoodsID = Replace(T.ProductID, '' '', '''')
		LEFT JOIN pln.tblProductionLinesDtl PD ON PD.ProductionLineID = SH.ProductionLineID
		LEFT JOIN inv.tblStoresDtl          S1 ON S1.StoreID = SD.AcceptStoreID
		LEFT JOIN inv.tblStoresDtl          S2 ON S2.StoreID = SD.FailedStoreID
		LEFT JOIN inv.tblStoresDtl          S3 ON S3.StoreID = SD.UsageStoreID
		LEFT JOIN inv.tblStoresDtl          S4 ON S4.StoreID = SD.LossStoreID
		LEFT JOIN prd.tblFormulasHdr         F ON F.ProductID = Replace(T.ProductID, '' '', '''') And F.IsDefault = 1
		WHERE 1 = 1
          And CodeClosed           = 0
		  --And IsDefaultMethod      = 1 
		  --And SD.NeedStep          = 1 
		  --And SH.ProductionLineID <> ''001''' + 
		  Case When @ProductID Is Not Null And @ProductID <> '' Then '
		  And SH.ProductID        IN (''' + LTrim(RTrim(@ProductID)) + ''') '
		  Else '' End + 
		  Case When @Update_By_Old_Info = 0 Then '
		  And (SH.FormulaNo <> F.SerialNo And AcceptStoreID Is Not Null And SH.ProductionLineID Is Not Null) '
		  Else '' End + '
		Order By SH.ProductID
		'
		-- ======================================================================================================== @StrSelect3
		SET @StrSelect3 = '
		-- ================================================= Dtl ' +
		Case When @Do_Insert = 1 Then '
		INSERT INTO pln.tblProduceStepDtl(ProductID, SerialNo, RowNo, DocRowNo, ProduceStepID, ProduceStepName, ProduceStepTime, 
										  OperatorCount, AcceptStoreID, FailedStoreID, LossStoreID, UsageStoreID, NeedStep)
									  '
		Else '' 
		End

		SET @StrSelect3 = @StrSelect3 + '
		-- ====== Select
		Select Replace(T.ProductID, '' '', '''') ProductID,
			   ROW_NUMBER() Over(Partition By Replace(T.ProductID, '' '', '''') Order By Replace(T.ProductID, '' '', '''')) + 
					  (
					   Select IsNull(Max(SerialNo), 0)
					   From pln.tblProduceStepDtl 
					   Where ProductID = Replace(T.ProductID, '' '', '''')
					  ) SerialNo,
			   ROW_NUMBER()Over(Partition By Replace(T.ProductID, '' '', '''') Order By Replace(T.ProductID, '' '', '''')) RowNo,
			   ROW_NUMBER()Over(Partition By Replace(T.ProductID, '' '', '''') Order By Replace(T.ProductID, '' '', '''')) DocRowNo,
			   1 ProduceStepID, ''مرحله اول'' ProduceStepName, 
			   IsNull(Round((IsNull(SD.ProduceStepTime, 1) * F.ProductCount) / 
						(Select ProductCount From prd.tblFormulasHdr Where ProductID = Replace(T.ProductID, '' '', '''') And SerialNo = SH.FormulaNo), 2), 1) ProduceStepTime, SD.OperatorCount, 
			   AcceptStoreID, FailedStoreID, LossStoreID, UsageStoreID, 1 NeedStep
		   
		-- ====== From
		FROM      acc.tblAAATmpOprations     T
		LEFT JOIN pln.tblProduceStepHdr     SH ON Replace(T.ProductID, '' '', '''') = SH.ProductID And SH.IsDefaultMethod = 1
		LEFT JOIN pln.tblProduceStepDtl     SD ON SH.ProductID = SD.ProductID And SH.SerialNo = SD.SerialNo
		LEFT JOIN inv.tblGoods              GH ON GH.GoodsID = Replace(T.ProductID, '' '', '''')
		LEFT JOIN inv.tblStoresDtl          S1 ON S1.StoreID = SD.AcceptStoreID
		LEFT JOIN inv.tblStoresDtl          S2 ON S2.StoreID = SD.FailedStoreID
		LEFT JOIN inv.tblStoresDtl          S3 ON S3.StoreID = SD.UsageStoreID
		LEFT JOIN inv.tblStoresDtl          S4 ON S4.StoreID = SD.LossStoreID
		LEFT JOIN prd.tblFormulasHdr         F ON F.ProductID = Replace(T.ProductID, '' '', '''') And F.IsDefault = 1
		Where  1 = 1
           And CodeClosed           = 0
		   --And IsDefaultMethod      = 1 
		   --And SD.NeedStep          = 1 
		   --And SH.ProductionLineID <> ''001''' + 
		   Case When @ProductID Is Not Null And @ProductID <> '' Then '
		   And SH.ProductID        IN (''' + LTrim(RTrim(@ProductID)) + ''') '
		   Else '' End + 
		    Case When @Update_By_Old_Info = 0 Then '
		   And (SH.FormulaNo <> F.SerialNo And AcceptStoreID Is Not Null And SH.ProductionLineID Is Not Null) '
		   Else '' End + '
		Order By SH.ProductID
		'
		-- ======================================================================================================== @StrSelect4
		SET @StrSelect4 = '
		-- ================================================= Clear IsDefaultMethod
		--Select PH.ProductID, PH.SerialNo, PH.FormulaNo, PH.ProduceMethodName, PH.IsDefaultMethod
		UPDATE pln.tblProduceStepHdr SET IsDefaultMethod = 0
		From pln.tblProduceStepHdr PH
		INNER JOIN acc.tblAAATmpOprations T ON T.ProductID = PH.ProductID
		Where 1 = 1 ' +
			Case When @ProductID Is Not Null And @ProductID <> '' Then '
			And PH.ProductID        IN (''' + LTrim(RTrim(@ProductID)) + ''') '
			Else '' End + '
			And PH.ProductID IN (Select Distinct ProductID From acc.tblAAATmpOprations)
			'

		-- ==========
		SET @StrSelect4 = @StrSelect4 + '
		-- ================================================= Set IsDefaultMethod
		--Select PH.ProductID, PH.SerialNo, PH.FormulaNo, PH.ProduceMethodName, PH.IsDefaultMethod
		UPDATE pln.tblProduceStepHdr SET IsDefaultMethod = 1
		From pln.tblProduceStepHdr PH
		INNER JOIN acc.tblAAATmpOprations T ON T.ProductID = PH.ProductID
		Where 1 = 1 ' +
			Case When @ProductID Is Not Null And @ProductID <> '' Then '
			And PH.ProductID        IN (''' + LTrim(RTrim(@ProductID)) + ''') '
			Else '' End + '
			And PH.ProductID IN (Select Distinct ProductID From acc.tblAAATmpOprations)
			And PH.SerialNo   = (Select Max(SerialNo) From pln.tblProduceStepHdr Where ProductID = PH.ProductID)
			'
	END
	-- =======================================================
	-- ======================================================= DELETE
	-- =======================================================
	ELSE IF @Do_Insert = 2
	BEGIN
		SET @StrSelect2 = '
        --SELECT SH.ProductID, SH.SerialNo, (Select IsNull(Max(SerialNo), 0) From pln.tblProduceStepHdr Where ProductID = SH.ProductID),
        --       LTrim(RTrim(Str(IsNull(ROW_NUMBER() Over(Partition By SH.ProductID Order By SH.ProductID) + 
        --          (
        --           Select IsNull(Max(SerialNo), 0)
        --           From pln.tblProduceStepHdr 
        --           Where ProductID = SH.ProductID
        --          ), 1)))) + '' - '' + pub.funChangeDate_GergorianToPersian(GETDATE()) + '''' ProduceMethodName,
        --       pub.funChangeDate_GergorianToPersian(GETDATE())
		DELETE SH
		-- ====== From
		FROM       pln.tblProduceStepHdr     SH
		INNER JOIN acc.tblAAATmpOprations     T ON T.ProductID = SH.ProductID
		WHERE 1 = 1
			--And SH.ProductID IN(''43040205009000'')
			And SH.SerialNo = (Select IsNull(Max(SerialNo), 0) From pln.tblProduceStepHdr Where ProductID = SH.ProductID)
			And ProduceMethodName Like ''%'' + pub.funChangeDate_GergorianToPersian(GETDATE()) + ''%''
        --ORDER BY SH.ProductID
		'
	END

	-- ========================================================================================================
	-- ======================================================================================================== END
	-- ========================================================================================================	

	-- ==================================== EXEC
	PRINT @StrSelect2;
	PRINT @StrSelect3;
	PRINT @StrSelect4;
	SET   @StrSelect = @StrSelect2 + @StrSelect3 + @StrSelect4;
	EXEC  sp_executesql @StrSelect;	

END

GO
