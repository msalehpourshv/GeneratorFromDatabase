USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE pln.SP_Set_Latest_ProduceStep_To_TaskOrder
	@FiscalYear Int = 0,
	@SerialNo_1 Int = 0,
	@SerialNo_2 Int = 0,
	@SerialNo_3 Int = 0,
	@Do_Update  Bit = 0

WITH ENCRYPTION
AS 

DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrSelect2	NVarChar(Max);
DECLARE @StrSelect3	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- ========================================================================================================
	-- ======================================================================================================== START
	-- ========================================================================================================
	SET @StrSelect = '
		 -- ================================================================================= Tbl_TaskOrder' + '
		 -- ========================================= Hdr' +
		Case When @Do_Update = 0 Then '
			Select P.ProductID, P.SerialNo, P.FormulaNo, P.IsDefaultMethod, P.ProductionLineID '
		Else '
			UPDATE pln.tblTaskOrderHdr SET ProduceStepSerialNo = P.SerialNo, FormulaNo = P.FormulaNo '
		End + '
			From pln.tblTaskOrderHdr H
			Inner Join pln.tblProduceStepHdr P ON H.ProductID = P.ProductID
			Where 1 = 1
			    And H.FiscalYear     IN(' + LTrim(RTrim(Str(@FiscalYear))) + ')
				And H.SerialNo       IN(' + Case When @SerialNo_1 <> 0 Then        LTrim(RTrim(Str(@SerialNo_1))) Else '' End
										   + Case When @SerialNo_2 <> 0 Then ', ' + LTrim(RTrim(Str(@SerialNo_2))) Else '' End
										   + Case When @SerialNo_3 <> 0 Then ', ' + LTrim(RTrim(Str(@SerialNo_3))) Else '' End
										   + 
                                       ')
				And P.IsDefaultMethod = 1 ' + '

		 -- ========================================= Dtl' +
		Case When @Do_Update = 0 Then '
			Select P.ProductID, P.SerialNo, P.FormulaNo, P.IsDefaultMethod, P.ProductionLineID '
		Else '
			UPDATE pln.tblTaskOrderDtl SET ProduceStepSerialNo = P.SerialNo'
		End + '
			From pln.tblTaskOrderDtl D
            Inner Join pln.tblTaskOrderHdr H ON H.ProcessID  = D.ProcessID  And H.ProcessNo = D.ProcessNo And
                                           H.FiscalYear = D.FiscalYear And H.SerialNo  = D.SerialNo
			Inner Join pln.tblProduceStepHdr P ON H.ProductID = P.ProductID
			Where 1 = 1
			    And H.FiscalYear     IN(' + LTrim(RTrim(Str(@FiscalYear))) + ')
				And H.SerialNo       IN(' + Case When @SerialNo_1 <> 0 Then        LTrim(RTrim(Str(@SerialNo_1))) Else '' End
										  + Case When @SerialNo_2 <> 0 Then ', ' + LTrim(RTrim(Str(@SerialNo_2))) Else '' End
										  + Case When @SerialNo_3 <> 0 Then ', ' + LTrim(RTrim(Str(@SerialNo_3))) Else '' End
										  + 
                                       ')
				And P.IsDefaultMethod = 1 ' + '

		 -- ================================================================================= Tbl_ProduceOrder' +
		Case When @Do_Update = 0 Then '
			Select P.ProductID, P.SerialNo, P.FormulaNo, P.IsDefaultMethod, P.ProductionLineID, T.DocDate '
		Else '
			UPDATE pln.tblProduceOrderDtl SET StepNo = P.SerialNo, FormulaNo = P.FormulaNo '
		End + '
			From pln.tblProduceOrderDtl D
			Inner Join pln.tblProduceOrderHdr H ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And
												   D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
			Inner Join pln.tblProduceStepHdr  P ON D.ProductID = P.ProductID
			Inner Join pln.tblTaskOrderHdr    T ON T.ProductID = D.ProductID And T.DocDate = H.DocDate
			Where 1 = 1
			    And T.FiscalYear     IN(' + LTrim(RTrim(Str(@FiscalYear))) + ')
				And T.SerialNo       IN(' + Case When @SerialNo_1 <> 0 Then        LTrim(RTrim(Str(@SerialNo_1))) Else '' End
										   + Case When @SerialNo_2 <> 0 Then ', ' + LTrim(RTrim(Str(@SerialNo_2))) Else '' End
										   + Case When @SerialNo_3 <> 0 Then ', ' + LTrim(RTrim(Str(@SerialNo_3))) Else '' End
										   + 
                                       ')
				And P.IsDefaultMethod = 1'

	-- ========================================================================================================
	-- ======================================================================================================== END
	-- ========================================================================================================	
	-- ==================================== EXEC
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	

END

GO
