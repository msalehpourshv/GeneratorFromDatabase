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
Create PROCEDURE [prs].[SPControlDecreeConfirmInCalc]
	@MonthCode	smallint,
	@ExecutionDate	varchar(10),
	@LanguageID	TINYINT,
	@ExtraParams		NVarChar(max) = ''
	
WITH ENCRYPTION
AS

BEGIN

	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;


	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2); 
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);

	SELECT D.PersonnelID,PD.FirstName + '  ' + PD.LastName Name 
	FROM (

		SELECT D.PersonnelID 
		FROM (
			select D1.* 
			from (
					SELECT a.PersonnelID,SerialNo,DecreeTypeID 
					from (
						SELECT ROW_NUMBER()over(partition by PersonnelID order by ExecutionDate desc,SerialNo Desc 			)LastRowNo,* 
						FROM prs.tblDecreeHdr D
						WHERE ExecutionDate<=@ExecutionDate And (PersonnelID <> null or PersonnelID <>'') and 
							  ((@ConfirmCount = 1 and SgnSN1<1) or (@ConfirmCount = 2 and SgnSN1<1 and SgnSN2<1)
							  or (@ConfirmCount = 3 and SgnSN1<1 and SgnSN2<1 and SgnSN3<1)
							  or (@ConfirmCount = 4 and SgnSN1<1 and SgnSN2<1 and SgnSN3<1 and SgnSN4<1)
							  or (@ConfirmCount = 5 and SgnSN1<1 and SgnSN2<1 and SgnSN3<1 and SgnSN4<1 and SgnSN5<1))
								
						) a WHERE a.LastRowNo=1		
				) D1
				---جهت حذف پرسنلهایی که در حکم نهایی ترک کار خورده اند
			inner join (select PersonnelID,SerialNo from prs.tblDecreeHdr  where (LTRIM(QuitJobDate) = '' OR (LTRIM(QuitJobDate)<>'' AND QuitJobDate>@ExecutionDate))) PP
				on PP.PersonnelID=D1.PersonnelID and  PP.SerialNo=D1.SerialNo
		) D

		inner join (select * from prs.tblPersonnels where (LTRIM(QuitJobDate) = '' OR (LTRIM(QuitJobDate)<>'' AND QuitJobDate>@ExecutionDate))) P on D.PersonnelID=P.PersonnelID 		
		inner join prs.tblDecreeTypes DT on D.DecreeTypeID=DT.DecreeTypeID
		WHERE P.QuitJobDate<@ExecutionDate AND DT.Payable='True'		
		EXCEPT 
		SELECT PersonnelID from prs.tblFunctionsDtl where MonthCode=@MonthCode
		
	) D
	inner join prs.tblPersonnelsDtl PD on D.PersonnelID=PD.PersonnelID AND PD.LanguageID=@LanguageID

END
GO
