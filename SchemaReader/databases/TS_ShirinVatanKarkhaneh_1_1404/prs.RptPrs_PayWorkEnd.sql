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
-- Description	 : پایانکار پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptPrs_PayWorkEnd]
	@SelectedPrs	Int = 0,
	@DepartmentID	VarChar(20) = Null,
	@dateto	VarChar(20) = Null,
	@ExtraParam		VarChar(10) = '',  -- bit array options
	@RepOptions		VarChar(10) = '00',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);
DECLARE @ShowRemain		Bit;
DECLARE @ExternalCall	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE @StrTemp Char(5);
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
	
	if  (@dateto	is null  or @dateto	='')
		set @dateto=[pub].[funChangeDate_GergorianToPersian](GETDATE())
	set @StrWhere=' 1=1 '
	----------------------------------------------------
		IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'D.PersonnelID')

	If (@DepartmentID Is Not Null and @DepartmentID <>'')
		SET @StrWhere = @StrWhere + ' AND D.DepartmentID = ''' + @DepartmentID + ''''
	if (@ShowRemain=0)
	SET @StrWhere = @StrWhere + ' AND (ISNULL(V2.CD2, 0) +ISNULL(V.CD, 0)<>0 )'

	SELECT  AcntSalary, PersonnelID, DepartmentID ,ExecutionDate, SerialNo into #DecreeHdr
		FROM          prs.tblDecreeHdr
		where 1=0
		order by ExecutionDate Desc ,SerialNo Desc , IssueDate


	DECLARE @PersonnelID			VARCHAR(20)

	DECLARE csr CURSOR FOR 
		SELECT Distinct PersonnelID from  prs.tblDecreeHdr

	OPEN csr
	FETCH NEXT FROM csr INTO @PersonnelID

	WHILE @@Fetch_Status = 0
	BEGIN

	 insert into  #DecreeHdr
		SELECT top 1  AcntSalary, PersonnelID, DepartmentID ,ExecutionDate, SerialNo  
		FROM          prs.tblDecreeHdr
			where PersonnelID=@PersonnelID and  ExecutionDate<=@dateto
		order by ExecutionDate Desc ,SerialNo Desc , IssueDate

		FETCH NEXT FROM csr INTO @PersonnelID
	END

	CLOSE csr
	DEALLOCATE csr


	SET @StrSelect = '	
	SELECT    TS.pub.funFarsiDateDiff (''DAY'',D.HireDate,'''+@dateto +''') as WorkDay ,D.PersonnelID, D.PersonnelName, D.AcntCode, ISNULL(V2.CD2, 0) AS CD2, ISNULL(V.CD, 0) AS CD, D.DepartmentID
				,isnull((select SUM(Amount)	FROM prs.tblSalaryPaysDtl WHERE PersonnelID=D.PersonnelID AND ProcessID=326	),0) AmountPay
	FROM         (SELECT     P.PersonnelID, P.HireDate, prs.funGetPersonnelName(P.PersonnelID, '''+@LangID +''') AS PersonnelName, D.AcntCode, D.DepartmentID
					FROM          prs.tblPersonnels AS P 
					INNER JOIN	(SELECT     DP.AcntHistory + '''' + SUBSTRING(D_1.AcntSalary, LEN(DP.AcntHistory) + 1, LEN(D_1.AcntSalary) - LEN(DP.AcntHistory)) AS AcntCode, D_1.PersonnelID, D_1.DepartmentID
								FROM          (SELECT DISTINCT ltrim(rtrim(AcntHistoryCalcDaysReserve)) AS AcntHistory,DepartmentID FROM          prs.tblDepartments) AS DP 
									INNER JOIN	(SELECT DISTINCT AcntSalary, PersonnelID, DepartmentID FROM         #DecreeHdr) AS D_1 ON LEN(DP.AcntHistory) < LEN(D_1.AcntSalary) and DP.DepartmentID = D_1.DepartmentID WHERE (D_1.AcntSalary IS NOT NULL)) AS D ON P.PersonnelID = D.PersonnelID  ) AS D 
		LEFT OUTER JOIN (SELECT     AcntCode, SUM(Credit - Debit) AS CD FROM          acc.tblVoucherDtl AS tblVoucherDtl_1 WHERE      (VchKind <> 2 and  DocDate<='''+@dateto +''') GROUP BY AcntCode) AS V ON D.AcntCode = V.AcntCode 
		LEFT OUTER JOIN (SELECT     AcntCode, SUM(Credit - Debit) AS CD2 FROM          acc.tblVoucherDtl WHERE      (VchKind = 2)and  DocDate<='''+@dateto +''' GROUP BY AcntCode) AS V2 ON D.AcntCode = V2.AcntCode	
		Where D.HireDate<= '''+@dateto +''' and 	' + @StrWhere

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
