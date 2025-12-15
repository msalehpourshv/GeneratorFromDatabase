USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\M.Mostafavi
-- Creation date : 1404/02/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : دیسکت بانک جدید
-- ==============================================
Create PROCEDURE [prs].[RptPrs_BankDisketteNew]
	@SalarySerialNo			 Int,
	@AdvanceSerialNo		 Int,
	@CelebrationSerialNo	 Int,
	@HistoryCalcDaysSerialNo Int	
WITH ENCRYPTION
AS 
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	SELECT TOP 0 CAST('' AS NVarchar(200)) AS PersonnelName, 
			     CAST('' AS NVarchar(200)) AS PersonnelFName, 
			     AccountNo, 
			     Amount, 
			     BankCartNo,
			     CAST('' AS NVarchar(100)) AS NationalIDNumber,
			     CAST('' AS NVarchar(2000)) AS DocDesc,
			     DocRowNo
	INTO #tblPersonnelPays 
	FROM prs.tblSalaryPaysDtl
		
	IF @SalarySerialNo > 0
		INSERT INTO #tblPersonnelPays
		SELECT P.FirstName AS PersonnelName,
			   P.LastName AS PersonnelFName, 
			   AccountNo, 
			   Amount, 
			   BankCartNo,
			   NationalIDNumber,
			   DocDesc,
			   DocRowNo
		FROM prs.tblSalaryPaysDtl S
		INNER JOIN prs.tblSalaryPaysHdr SH ON SH.SerialNo = S.SerialNo 
										  AND SH.ProcessID = S.ProcessID
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = S.PersonnelID
		INNER JOIN prs.tblPersonnels pp ON P.PersonnelID = pp.PersonnelID
		WHERE S.ProcessID=300 
		  AND S.SerialNo = @SalarySerialNo 
		  AND Len(LTRim(RTrim(AccountNo))) > 1
		ORDER BY DocRowNo
	
	IF @CelebrationSerialNo > 0
		INSERT INTO #tblPersonnelPays
		SELECT P.FirstName AS PersonnelName,
			   P.LastName AS PersonnelFName, 
			   AccountNo, 
			   Amount, 
			   BankCartNo,
			   NationalIDNumber,
			   S.DescDtl,
			   DocRowNo
		FROM prs.tblSalaryPaysDtl S
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = S.PersonnelID
		INNER JOIN prs.tblPersonnels pp ON P.PersonnelID = pp.PersonnelID
		WHERE ProcessID=321	
		  AND SerialNo = @CelebrationSerialNo 
		  AND Len(LTRim(RTrim(AccountNo))) > 1
		ORDER BY DocRowNo

	IF @HistoryCalcDaysSerialNo > 0
		INSERT INTO #tblPersonnelPays
		SELECT P.FirstName AS PersonnelName,
			   P.LastName AS PersonnelFName, 
			   AccountNo, 
			   Amount, 
			   BankCartNo,
			   NationalIDNumber,
			   S.DescDtl,
			   DocRowNo
		FROM prs.tblSalaryPaysDtl S
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = S.PersonnelID
		INNER JOIN prs.tblPersonnels pp ON P.PersonnelID = pp.PersonnelID
		WHERE ProcessID=326	
		  AND SerialNo = @HistoryCalcDaysSerialNo 
		  AND Len(LTRim(RTrim(AccountNo))) > 1
		ORDER BY DocRowNo

	IF @AdvanceSerialNo > 0
		INSERT INTO #tblPersonnelPays
		SELECT P.FirstName AS PersonnelName,
			   P.LastName AS PersonnelFName,
			   AccountNo, 
			   Amount, 
			   BankCartNo,
			   NationalIDNumber,
			   A.DescDtl,
			   DocRowNo
		FROM prs.tblAdvancesDtl A
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = A.PersonnelID
		INNER JOIN prs.tblPersonnels pp ON P.PersonnelID = pp.PersonnelID
		WHERE SerialNo = @AdvanceSerialNo 
		  AND Len(LTRim(RTrim(AccountNo))) > 1
		ORDER BY DocRowNo

	SELECT PersonnelName, 
		   PersonnelFName, 
		   AccountNo, 
		   SUM(Amount) Amount, 
		   BankCartNo,
		   NationalIDNumber,
		   DocDesc,
		   DocRowNo
	FROM #tblPersonnelPays
	GROUP BY PersonnelName, PersonnelFName, AccountNo, BankCartNo,NationalIDNumber, DocDesc, DocRowNo
	ORDER BY DocRowNo
  
END
GO
