USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1393/07/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : چاپ قرارداد  
-- =============================================
create PROCEDURE [sal].[RptSal_Restaurant_Talar_Info] 
		
	@FromSerialNo		INT =3,
	@EarnestMoney		FLOAT =0,
	@SalonName1			NVarChar(100) = NULL,
    @SalonName2			NVarChar(100) = NULL,
    @SalonName3			NVarChar(100) = NULL,
    @SalonName4			NVarChar(100) = NULL,
	@RepInfo			NVarChar(100) = '1@1@1' ,
	@pmFixOptions		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی


BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

-- ================ WHERE ===========================

	set @StrWhere = '(1=1) '
	
	IF (@FromSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.ProcessID=182 AND h.SerialNo =' + LTRIM(STR(@FromSerialNo))
	
	
-- ================ SELECT ===========================

SET @StrSelect ='SELECT h.*,b.BranchName,t.TableName,
	d3.PartyDate,d3.StartTime,d3.EndTime,d3.StartTimeMen,d3.EndTimeMen,
	d3.SerialNo,d3.FiscalYear,d3.MealType,d3.PlusCost,
	pub.GetCodeName(h.ReciverAcntCode,' + LTRIM(STR(@LangID))+') AS ReciverName
	,pd.ReasonName,(d3.SalonPrice+d3.PlusCost)as SalonPrice,case 
	WHEN (SELECT IsService FROM sal.tblPartyReason where ReasonID =d3.ReasonID )=1 THEN 0 ELSE
	(d3.PersonQty) END  PersonQty
	FROM sal.tblRestaurantContractHdr h
		INNER JOIN  sal.tblRestaurantContractDtl3 d3
		ON h.ProcessID=d3.ProcessID and h.SerialNo = d3.SerialNo 
		AND h.BranchID = d3.BranchID
		INNER JOIN sal.tblBranchesDtl b
		ON h.BranchID=b.BranchID
		LEFT join sal.tblPartyReasonDtl pd
		on d3.ReasonID=pd.ReasonID
		Left JOIN sal.tblTablesDtl t
		on d3.SalonID=t.TableID 
      WHERE '  + @StrWhere
		 

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
