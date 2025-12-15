USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 98/12/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--[prs].[SPControlPersonnelFunctionInCalc] 1,'1399/01/31',1
Create PROCEDURE [prs].[SPControlPersonnelFunctionInCalc]
	@MonthCode	smallint,
	@ExecutionDate	varchar(10),
	@LanguageID	TINYINT
	
WITH ENCRYPTION
AS

BEGIN

	SELECT D.PersonnelID,PD.FirstName + '  ' + PD.LastName Name,D.ContractEndDate,D.CodeClosed 
	FROM (

		SELECT D.PersonnelID,D.ContractEndDate,P.CodeClosed
		FROM (
			select D1.* 
			from (
					SELECT a.PersonnelID,SerialNo,DecreeTypeID,ContractEndDate 
					from (
						SELECT ROW_NUMBER()over(partition by PersonnelID order by ExecutionDate desc,SerialNo Desc 			)LastRowNo,* 
						FROM prs.tblDecreeHdr D
						WHERE ExecutionDate<@ExecutionDate--AND D.IssueDate<@ExecutionDate
						) a WHERE a.LastRowNo=1		
				) D1
				---جهت حذف پرسنلهایی که در حکم نهایی ترک کار خورده اند
			inner join (select PersonnelID,SerialNo from prs.tblDecreeHdr  where (LTRIM(QuitJobDate) = '' OR (LTRIM(QuitJobDate)<>'' AND QuitJobDate>@ExecutionDate))) PP
				on PP.PersonnelID=D1.PersonnelID and  PP.SerialNo=D1.SerialNo
		) D

		inner join (select * from prs.tblPersonnels where (LTRIM(QuitJobDate) = '' OR (LTRIM(QuitJobDate)<>'' AND QuitJobDate>@ExecutionDate))) P on D.PersonnelID=P.PersonnelID 		
		inner join prs.tblDecreeTypes DT on D.DecreeTypeID=DT.DecreeTypeID
		WHERE P.QuitJobDate<@ExecutionDate AND DT.Payable='True'
		and D.PersonnelID not in (SELECT PersonnelID from prs.tblFunctionsDtl where MonthCode=@MonthCode)
		
	) D
	inner join prs.tblPersonnelsDtl PD on D.PersonnelID=PD.PersonnelID AND PD.LanguageID=@LanguageID

END
GO
