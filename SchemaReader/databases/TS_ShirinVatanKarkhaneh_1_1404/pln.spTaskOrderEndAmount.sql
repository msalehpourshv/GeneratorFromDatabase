USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[pln].[spTaskOrderEndAmount]'','',0,30
CREATE PROCEDURE [pln].[spTaskOrderEndAmount] 
 @SumMonthlyBenfitID	VARCHAR(1000),
 @SumDailyBenfitID		VARCHAR(1000),
 @DailyMin	INT

WITH ENCRYPTION
 AS

BEGIN

	DECLARE @StrSelect NVarChar(4000);

	IF @DailyMin = 0
		SET @DailyMin = 1
		
	IF @SumMonthlyBenfitID<>''
		SET @SumMonthlyBenfitID  = ',SUM(' + @SumMonthlyBenfitID + ')'
	ELSE
		SET @SumMonthlyBenfitID  = ',1'
	
	IF @SumDailyBenfitID<>''
		SET @SumDailyBenfitID  = ',SUM(' + @SumDailyBenfitID + ')'
	ELSE
		SET @SumDailyBenfitID  = ',1'	
		
	SET @StrSelect = '
			SELECT ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,SUM(CASE WHEN Basepay = 0 THEN 0 ELSE (Time*Basepay) END + CASE WHEN MonthlyBenfit = 0 THEN 0 ELSE (Time*MonthlyBenfit) END + CASE WHEN DailyBenfit = 0 THEN 0 ELSE (Time*DailyBenfit) END) Pay
			FROM(
				SELECT D2.*,Basepay/' + LTRIM(STR(@DailyMin)) + ' Basepay ' + @SumMonthlyBenfitID + '/ (pub.FunGetMonthDays(DocDate) * ' + LTRIM(STR(@DailyMin)) + ') MonthlyBenfit' + @SumDailyBenfitID + '/ (pub.FunGetMonthDays(DocDate) * ' + LTRIM(STR(@DailyMin)) +  ')  DailyBenfit
				FROM ( 	
					SELECT *, (TotalTime / OrderCount) Time , (SELECT Top 1 SerialNo 
								FROM prs.tblDecreeHdr 
								WHERE PersonnelID = D.OperatorID AND ExecutionDate<=DocDate ORDER BY ExecutionDate Desc ) DecreeNo 	
					FROM (
							--SELECT ProcessID, ProcessNo, FiscalYear, SerialNo,DocDate, OperatorID,OrderCount,SUM(TotalTime) TotalTime
							--FROM (
							SELECT T.ProcessID, T.ProcessNo, T.FiscalYear, T.SerialNo,T.RowNo,TH.DocDate, OperatorID,(AcceptableCount +UnacceptableCount) OrderCount,(SUM(TotalTime)/60 )TotalTime
							FROM pln.tblTaskOrderDtl T INNER JOIN pln.tblTaskOrderOperators TOO 
							ON  TOO.ProcessID=T.ProcessID AND TOO.ProcessNo=T.ProcessNo AND TOO.FiscalYear=T.FiscalYear AND TOO.SerialNo=T.SerialNo --AND TOO.RowNo=T.RowNo
							INNER JOIN pln.tblTaskOrderHdr TH 
							ON TH.ProcessID=T.ProcessID AND TH.ProcessNo=T.ProcessNo AND TH.FiscalYear=T.FiscalYear AND TH.SerialNo=T.SerialNo AND TOO.RowNo=T.RowNo
							GROUP BY T.ProcessID, T.ProcessNo, T.FiscalYear, T.SerialNo,T.RowNo,TH.DocDate, OperatorID, (AcceptableCount +UnacceptableCount)
							--) A
							--GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo,DocDate, OperatorID, OrderCount
						 )D 
					   ) D2	 
				INNER JOIN	prs.tblDecreeHdr DH ON  PersonnelID = OperatorID AND DH.SerialNo = DecreeNo
				GROUP BY	ProcessID, ProcessNo, FiscalYear, D2.SerialNo,D2.RowNo,D2.DocDate, OperatorID, OrderCount,TotalTime,Time,DecreeNo,Basepay
				) D3
			GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;				
		
END	
GO
