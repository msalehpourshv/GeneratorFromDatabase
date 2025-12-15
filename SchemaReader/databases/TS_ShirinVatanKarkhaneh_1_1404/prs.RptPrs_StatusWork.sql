USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create Date   : 1393/12/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : صورت وضعیت تسویه کارکنان
-- ==============================================
Create PROCEDURE [prs].[RptPrs_StatusWork]
	@SelectedPrs	Int = 0,
	@ExtraParam		VarChar(10) = '',  -- bit array options
	@RepOptions		VarChar(10) = '00',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);
DECLARE @ShowRemain		Bit;
DECLARE @ExternalCall	Bit;
DECLARE @ShowByIsurance	Bit;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE @StrTemp	Char(5);

Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @ShowRemain		= Substring(@ExtraParam, 1, 1)
	SET @ShowByIsurance	= Substring(@ExtraParam, 2, 1)	

	SET @StrWhere=' 1=1 '
	----------------------------------------------------
	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'CD.PersonnelID')

	CREATE TABLE #tblP1
	(PersonnelID VarChar(20) COLLATE ARABIC_CS_AS,
	 Basepay int,
	 WorkH Int,
	 WorkE Int,
	 M1 int,
	 M2 int,
	 M3 int,
	 M4 int, 
	 M5 int, 
	 M6 int,
	 M7 int,
	 M8 int,
	 M9 int,
	 M10 int, 
	 M11 int,
	 M12 int, 
	 LT Char(7), --LeaveTime
	 LD int, --LeaveDay
	 RVD int--RedeemedVacationDays
	 )
	
IF @ShowByIsurance = 'False'
BEGIN
	SET @StrSelect = '	
		INSERT INTO #tblP1 --(PersonnelID,Basepay)
		SELECT DISTINCT PersonnelID,
						Basepay  
		,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		--12,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8
		FROM prs.tblCelebrationDtl CD
		WHERE Basepay <> 0 AND ' + @StrWhere
END
ELSE
BEGIN
	SET @StrSelect = '	
		INSERT INTO #tblP1 
		SELECT DISTINCT CD.PersonnelID,
						DH.InsuranceBasepay  
		,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		FROM prs.tblCelebrationDtl CD
		INNER JOIN prs.tblDecreeHdr DH ON CD.PersonnelID = DH.PersonnelID 
									  AND CD.DecreeSerialNo = DH.SerialNo
		WHERE DH.InsuranceBasepay <> 0 AND ' + @StrWhere
END
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

IF @ShowByIsurance = 'False'
BEGIN
	----M1------------------------------
	UPDATE #tblP1 
	SET M1 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 1) 
	  AND (CD.ProcessID = 320)
	
	UPDATE #tblP1 
	SET M1 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 1) 
	  AND (CD.ProcessID = 325)	
	
	--M2------------------------------
	UPDATE #tblP1 
	SET M2 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 2) 
	  AND (CD.ProcessID = 320)
	
	UPDATE #tblP1 
	SET M2 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 2) 
	  AND (CD.ProcessID = 325)
	
	--M3------------------------------
	UPDATE #tblP1 
	SET M3 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 3) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M3 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 3) 
	  AND (CD.ProcessID = 325)	
	
	--M4------------------------------
	UPDATE #tblP1 
	SET M4 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 4) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M4 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 4) 
	  AND (CD.ProcessID = 325)
	
	--M3------------------------------
	UPDATE #tblP1 
	SET M5 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 5) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M5 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 5) 
	  AND (CD.ProcessID = 325)
	
	--M6------------------------------
	UPDATE #tblP1 
	SET M6 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 6) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M6 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 6) 
	  AND (CD.ProcessID = 325)
	
	--M7------------------------------
	UPDATE #tblP1 
	SET M7 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 7) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M7 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 7) 
	  AND (CD.ProcessID = 325)
	
	--M8------------------------------
	UPDATE #tblP1 
	SET M8 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 8) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M8 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 8) 
	  AND (CD.ProcessID = 325)
	
	--M9------------------------------
	UPDATE #tblP1 
	SET M9 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 9)
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M9 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 9) 
	  AND (CD.ProcessID = 325)
	
	--M10------------------------------
	UPDATE #tblP1 
	SET M10 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 10) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M10 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 10) 
	  AND (CD.ProcessID = 325)
	
	--M11------------------------------
	UPDATE #tblP1 
	SET M11 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 11) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M11 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 11) 
	  AND (CD.ProcessID = 325)
	
	--M12------------------------------
	UPDATE #tblP1 
	SET M12 = MonthlyFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0) +
		ISNULL((SELECT Cost FROM prs.tblCelebrationDtl CD2 WHERE CD2.ProcessID=320 AND CD2.PersonnelID = CD.PersonnelID AND CD2.MonthCode=13)	,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 12) 
	  AND (CD.ProcessID = 320)
	
	UPDATE #tblP1 
	SET M12 = MonthlyFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0) + 
		ISNULL((SELECT Cost FROM prs.tblCelebrationDtl CD2 WHERE CD2.ProcessID=325 AND CD2.PersonnelID = CD.PersonnelID AND CD2.MonthCode=13)	,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 12) 
	  AND (CD.ProcessID = 325)

END
ELSE
BEGIN
	----M1------------------------------
	UPDATE #tblP1 
	SET M1 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 1) 
	  AND (CD.ProcessID = 320)
	
	UPDATE #tblP1 
	SET M1 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 1) 
	  AND (CD.ProcessID = 325)
	
	
	--M2------------------------------
	UPDATE #tblP1 
	SET M2 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 2) 
	  AND (CD.ProcessID = 320)
	
	UPDATE #tblP1 
	SET M2 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 2) 
	  AND (CD.ProcessID = 325)
	
	--M3------------------------------
	UPDATE #tblP1 
	SET M3 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 3) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M3 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 3) 
	  AND (CD.ProcessID = 325)	
	
	--M4------------------------------
	UPDATE #tblP1 
	SET M4 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 4) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M4 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 4) 
	  AND (CD.ProcessID = 325)
	
	--M3------------------------------
	UPDATE #tblP1 
	SET M5 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 5) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M5 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 5) 
	  AND (CD.ProcessID = 325)
	
	--M6------------------------------
	UPDATE #tblP1 
	SET M6 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 6) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M6 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 6) 
	  AND (CD.ProcessID = 325)
	
	--M7------------------------------
	UPDATE #tblP1 
	SET M7 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 7) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M7 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 7) 
	  AND (CD.ProcessID = 325)
	
	--M8------------------------------
	UPDATE #tblP1 
	SET M8 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 8) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M8 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 8) 
	  AND (CD.ProcessID = 325)
	
	--M9------------------------------
	UPDATE #tblP1 
	SET M9 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 9) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M9 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 9) 
	  AND (CD.ProcessID = 325)
	
	--M10------------------------------
	UPDATE #tblP1 
	SET M10 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 10) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M10 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 10) 
	  AND (CD.ProcessID = 325)
	
	--M11------------------------------
	UPDATE #tblP1 
	SET M11 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE (FD.MonthCode = 11) 
	  AND (CD.ProcessID = 320)

	UPDATE #tblP1 
	SET M11 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 11) 
	  AND (CD.ProcessID = 325)
	
	--M12------------------------------
	UPDATE #tblP1 
	SET M12 = InsuranceFunction,
		WorkE = ISNULL(WorkE,0) + ISNULL(Cost,0) + 
		ISNULL((SELECT Cost FROM prs.tblCelebrationDtl CD2 WHERE CD2.ProcessID=320 AND CD2.PersonnelID = CD.PersonnelID AND CD2.MonthCode=13)	,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID                    
	WHERE     (FD.MonthCode = 12) AND (CD.ProcessID = 320)
	
	UPDATE #tblP1 
	SET M12 = InsuranceFunction,
		WorkH = ISNULL(WorkH,0) + ISNULL(Cost,0) + 
		ISNULL((SELECT Cost FROM prs.tblCelebrationDtl CD2 WHERE CD2.ProcessID=325 AND CD2.PersonnelID = CD.PersonnelID AND CD2.MonthCode=13)	,0)
	FROM #tblP1 P
	INNER JOIN prs.tblCelebrationDtl AS CD ON P.Basepay = CD.Basepay AND CD.PersonnelID = P.PersonnelID
	INNER JOIN prs.tblFunctionsDtl AS FD ON CD.MonthCode = FD.MonthCode AND CD.PersonnelID = FD.PersonnelID
	WHERE (FD.MonthCode = 12) 
	  AND (CD.ProcessID = 325)
END

IF @ShowByIsurance = 0
BEGIN
UPDATE #tblP1 
SET M1= ([prs].[funGetMonWork] (Basepay,1,PersonnelID))

UPDATE #tblP1 
SET M2= ([prs].[funGetMonWork] (Basepay,2,PersonnelID))

UPDATE #tblP1 
SET M3= ([prs].[funGetMonWork] (Basepay,3,PersonnelID))

UPDATE #tblP1 
SET M4= ([prs].[funGetMonWork] (Basepay,4,PersonnelID))

UPDATE #tblP1 
SET M5= ([prs].[funGetMonWork] (Basepay,5,PersonnelID))

UPDATE #tblP1 
SET M6= ([prs].[funGetMonWork] (Basepay,6,PersonnelID))

UPDATE #tblP1 
SET M7= ([prs].[funGetMonWork] (Basepay,7,PersonnelID))

UPDATE #tblP1 
SET M8= ([prs].[funGetMonWork] (Basepay,8,PersonnelID))

UPDATE #tblP1 
SET M9= ([prs].[funGetMonWork] (Basepay,9,PersonnelID))

UPDATE #tblP1 
SET M10= ([prs].[funGetMonWork] (Basepay,10,PersonnelID))

UPDATE #tblP1 
SET M11= ([prs].[funGetMonWork] (Basepay,11,PersonnelID))

UPDATE #tblP1 
SET M12= ([prs].[funGetMonWork] (Basepay,12,PersonnelID))		

END
ELSE
BEGIN

UPDATE #tblP1 
SET M1= (prs.funGetMonWorkInsurance (Basepay,1,PersonnelID))

UPDATE #tblP1 
SET M2= (prs.funGetMonWorkInsurance (Basepay,2,PersonnelID))

UPDATE #tblP1 
SET M3= (prs.funGetMonWorkInsurance (Basepay,3,PersonnelID))

UPDATE #tblP1 
SET M4= (prs.funGetMonWorkInsurance (Basepay,4,PersonnelID))

UPDATE #tblP1 
SET M5= (prs.funGetMonWorkInsurance (Basepay,5,PersonnelID))

UPDATE #tblP1 
SET M6= (prs.funGetMonWorkInsurance (Basepay,6,PersonnelID))

UPDATE #tblP1 
SET M7= (prs.funGetMonWorkInsurance (Basepay,7,PersonnelID))

UPDATE #tblP1 
SET M8= (prs.funGetMonWorkInsurance (Basepay,8,PersonnelID))

UPDATE #tblP1 
SET M9= (prs.funGetMonWorkInsurance (Basepay,9,PersonnelID))

UPDATE #tblP1 
SET M10= (prs.funGetMonWorkInsurance (Basepay,10,PersonnelID))

UPDATE #tblP1 
SET M11= (prs.funGetMonWorkInsurance (Basepay,11,PersonnelID))

UPDATE #tblP1 
SET M12= (prs.funGetMonWorkInsurance (Basepay,12,PersonnelID))	

END

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M1<>0 AND MonthCode=1


UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M2<>0 AND MonthCode=2

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M3<>0 AND MonthCode=3

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M4<>0 AND MonthCode=4

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M5<>0 AND MonthCode=5

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M6<>0 AND MonthCode=6

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M7<>0 AND MonthCode=7

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M8<>0 AND MonthCode=8

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M9<>0 AND MonthCode=9

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M10<>0 AND MonthCode=10

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M11<>0 AND MonthCode=11

UPDATE #tblP1 
SET LD= LD+ LeaveDay  , LT=LT+prs.funGetMinutes(LeaveTime)
FROM #tblP1 P
INNER JOIN prs.tblFunctionsDtl F 
ON P.PersonnelID=F.PersonnelID AND M12<>0 AND MonthCode=12

UPDATE #tblP1 
SET LT= prs.funGetHourMinutes(LT)
FROM #tblP1 

---------

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M1<>0 AND MonthCode=1

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M2<>0 AND MonthCode=2

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M3<>0 AND MonthCode=3

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M4<>0 AND MonthCode=4

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M5<>0 AND MonthCode=5

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M6<>0 AND MonthCode=6

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M7<>0 AND MonthCode=7

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M8<>0 AND MonthCode=8

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M9<>0 AND MonthCode=9

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M10<>0 AND MonthCode=10

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M11<>0 AND MonthCode=11

UPDATE #tblP1 
SET RVD=RVD+ RedeemedVacationAmount
FROM #tblP1 P
INNER JOIN  prs.tblSalaryCalculation F 
ON P.PersonnelID=F.PersonnelID AND M12<>0 AND MonthCode=12


--SELECT PersonnelID,MonthCode,RedeemedVacationAmount FROM  prs.tblSalaryCalculation
--WHERE RedeemedVacationAmount <>0

SELECT PersonnelID, 
	   prs.funGetPersonnelName(PersonnelID, @LangID ) AS PersonnelName,
	   Basepay,
	   WorkH,
	   WorkE, 
	   M1, 
	   M2, 
	   M3, 
	   M4, 
	   M5, 
	   M6, 
	   M7, 
	   M8, 
	   M9, 
	   M10, 
	   M11, 
	   M12, 
	   LT, 
	   LD, 
	   RVD  
FROM #tblP1

	--PRINT @StrSelect;
	--EXEC sp_executesql @StrSelect;
End
GO
