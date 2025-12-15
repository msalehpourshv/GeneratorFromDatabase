USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ZiA
-- Creation date : 1392/02/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [prs].[SpPrs_BenefitsList]
	@PersonnelID	VarChar(20),
	@DecreeSerialNo	Int,
	@RepOptions		VarChar(10) = '',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@StrResult	nvarchar(max);
DECLARE	@BenefitID	varchar(20);
DECLARE	@BenefitName	nvarchar(50);
DECLARE	@BenefitAmount	float;
DECLARE	@BenefitSum	float;
DECLARE	@AmountOnly	bit;
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @AmountOnly	= Substring(@RepOptions, 1, 1);

	SET @BenefitSum = 0;
	SET @StrResult	= '';
	
	create table #tbl_Prs_BenefitsList_BenefitAmount
	(
		BenefitAmount float not null
	)
	
	DECLARE curBenefits CURSOR FOR 
		select H.BenefitID, D.BenefitName
		from prs.tblBenefits1Dtl D inner join prs.tblBenefits1 H on H.BenefitID=D.BenefitID
		where (H.CodeClosed = 0) and (H.BenefitID <> '')
	
	OPEN curBenefits;
	
	FETCH NEXT FROM curBenefits INTO @BenefitID, @BenefitName
	
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		if (@StrResult <> '')
			set @StrResult = @StrResult + ' و '
			
		set @StrSelect = '
		delete from #tbl_Prs_BenefitsList_BenefitAmount;
		
		insert into #tbl_Prs_BenefitsList_BenefitAmount(BenefitAmount)
		select isnull(Benefit' + LTrim(@BenefitID) + ',0)
		from prs.tblDecreeHdr
		where (PersonnelID=''' + LTrim(@PersonnelID) + ''') and (SerialNo=' + LTrim(STR(@DecreeSerialNo)) + ')'
		
		print @StrSelect;
		exec sp_executesql @StrSelect;
		
		set @BenefitAmount = 0;
		
		select @BenefitAmount = BenefitAmount
		from #tbl_Prs_BenefitsList_BenefitAmount
		
		set @StrResult = @StrResult + @BenefitName + ' بمبلغ ' + LTRIM(STR(@BenefitAmount)) + ' ریال'
		set @BenefitSum = @BenefitSum + @BenefitAmount;
		
		FETCH NEXT FROM curBenefits INTO @BenefitID, @BenefitName
	END

	CLOSE curBenefits;
	DEALLOCATE curBenefits;

	if (@AmountOnly = 1)
		select LTRIM(RTRIM(STR(@BenefitSum)))
	else
		select LTRIM(RTRIM(@StrResult))
End
GO
