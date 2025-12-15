USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1387/11/09
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : دیسکت بانک
-- ==============================================
Create PROCEDURE [prs].[RptPrs_BankDiskette]
	@SalarySerialNo			 Int,
	@AdvanceSerialNo		 Int,
	@CelebrationSerialNo	 Int,
	@HistoryCalcDaysSerialNo Int	
WITH ENCRYPTION
AS 
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	
	SELECT TOP 0 Cast('' As NVarchar(100)) As PersonnelName, AccountNo, Amount, BankCartNo ,Cast('' As NVarchar(100)) As  NationalIDNumber,Cast('' As NVarchar(1000)) As  DocDesc,DocRowNo
	INTO #tblPersonnelPays 
	FROM prs.tblSalaryPaysDtl
		
	IF @SalarySerialNo > 0
		INSERT INTO #tblPersonnelPays
		SELECT	P.FirstName + ' ' + P.LastName As PersonnelName, AccountNo, Amount, BankCartNo,NationalIDNumber ,DocDesc,DocRowNo
		FROM	prs.tblSalaryPaysDtl S
		inner join 	prs.tblSalaryPaysHdr SH  on SH.SerialNo=S.SerialNo and SH.ProcessID=S.ProcessID
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = S.PersonnelID
		inner join prs.tblPersonnels pp on P.PersonnelID = pp.PersonnelID
		WHERE S.ProcessID=300	 	AND S.SerialNo=@SalarySerialNo  AND Len(LTRim(RTrim(AccountNo))) > 1
		ORDER BY DocRowNo
	
	IF @CelebrationSerialNo > 0
		INSERT INTO #tblPersonnelPays
		SELECT	P.FirstName + ' ' + P.LastName As PersonnelName, AccountNo, Amount, BankCartNo,NationalIDNumber ,'',DocRowNo
		FROM	prs.tblSalaryPaysDtl S
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = S.PersonnelID
		inner join prs.tblPersonnels pp on P.PersonnelID = pp.PersonnelID
		WHERE ProcessID=321	AND SerialNo=@CelebrationSerialNo AND Len(LTRim(RTrim(AccountNo))) > 1
		ORDER BY DocRowNo

	IF @HistoryCalcDaysSerialNo > 0
		INSERT INTO #tblPersonnelPays
		SELECT	P.FirstName + ' ' + P.LastName As PersonnelName, AccountNo, Amount, BankCartNo,NationalIDNumber ,'',DocRowNo
		FROM	prs.tblSalaryPaysDtl S
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = S.PersonnelID
			inner join prs.tblPersonnels pp on P.PersonnelID = pp.PersonnelID
		WHERE ProcessID=326	AND SerialNo=@HistoryCalcDaysSerialNo AND Len(LTRim(RTrim(AccountNo))) > 1
		ORDER BY DocRowNo

	IF @AdvanceSerialNo > 0
		INSERT INTO #tblPersonnelPays
		SELECT	P.FirstName + ' ' + P.LastName As PersonnelName, AccountNo, Amount, BankCartNo,NationalIDNumber ,'',DocRowNo
		FROM	prs.tblAdvancesDtl A
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = A.PersonnelID
		inner join prs.tblPersonnels pp on P.PersonnelID = pp.PersonnelID
		WHERE	SerialNo=@AdvanceSerialNo AND Len(LTRim(RTrim(AccountNo))) > 1
		ORDER BY DocRowNo

	SELECT PersonnelName, AccountNo, SUM(Amount) Amount, BankCartNo,NationalIDNumber ,DocDesc,DocRowNo
	FROM  #tblPersonnelPays
	GROUP BY PersonnelName, AccountNo, BankCartNo,NationalIDNumber  ,DocDesc,DocRowNo
	order by DocRowNo
  
	
End
GO
