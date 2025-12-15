USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/10
-- Viewed By	 : 
-- Last Modified : 1389/02/28
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : گزارش میانگین زمانی فاکتورهای مشتریان
-- ==============================================
CREATE PROCEDURE [sal].[RptSal_AverageSale] 
	@ProcessNo			Int = 1,
	@DocDateFr			Char(10) = NULL,
	@DocDateTo			Char(10) = NULL,
	@SelectedAcnt1		Int = Null, -- انتخاب طرف حساب
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@DaysLeftOnly		Bit = 0,
	@DistributeInfo		NVarChar(2000) = 'null#null#null#null#null#null#null#null#null#null#null#null',
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
DECLARE @Today		VarChar(10);
DECLARE @Finished	Bit
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrSelect	NVarChar(2000);
DECLARE @LangID		Char(1);
DECLARE @SessionNo	Int;
DECLARE @ReportID	Int;

DECLARE @Dist0		NVarChar(20); -- DriverID
DECLARE @Dist1		NVarChar(20); -- DistributerID1
DECLARE @Dist2		NVarChar(20); -- DistributerID2
DECLARE @Dist3		NVarChar(20); -- BaseDistributionProcessID
DECLARE @Dist4		NVarChar(20); -- BaseDistributionProcessNo
DECLARE @Dist5		NVarChar(20); -- BaseDistributionFiscalYear fr
DECLARE @Dist6		NVarChar(20); -- BaseDistributionSerialNo   fr
DECLARE @Dist7		NVarChar(20); -- BaseDistributionFiscalYear to
DECLARE @Dist8		NVarChar(20); -- BaseDistributionSerialNo   to
Begin 

	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- Init ------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1
	If (@DaysLeftOnly Is Null)	SET @DaysLeftOnly = 0;
	IF (@DistributeInfo	Is Null)	SET @DistributeInfo = 'null#null#null#null#null#null';

	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0

	IF (@DistributeInfo <> '')
	Begin
		SET @Dist0	= pub.funSplitString(@DistributeInfo, '#', 1);
		SET @Dist1	= pub.funSplitString(@DistributeInfo, '#', 3);
		SET @Dist2	= pub.funSplitString(@DistributeInfo, '#', 5);
		SET @Dist3	= pub.funSplitString(@DistributeInfo, '#', 7);
		SET @Dist4	= pub.funSplitString(@DistributeInfo, '#', 8);
		SET @Dist5	= pub.funSplitString(@DistributeInfo, '#', 9);
		SET @Dist6	= pub.funSplitString(@DistributeInfo, '#', 10);
		SET @Dist7	= pub.funSplitString(@DistributeInfo, '#', 11);
		SET @Dist8	= pub.funSplitString(@DistributeInfo, '#', 12);
	End
	Else
	Begin
		SET @Dist0	= 'null';
		SET @Dist1	= 'null';
		SET @Dist2	= 'null';
		SET @Dist3	= 'null'; 
		SET @Dist4	= 'null';
		SET @Dist5	= 'null';
		SET @Dist6	= 'null';
		SET @Dist7	= 'null';
		SET @Dist8	= 'null';
	End

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @Today = pub.funFarsiDate(GetDate());
	----------------------------------------------------
	---- WHERE -----------------------------------------
	SET @StrWhere = '(H.ProcessID = 90)'

	If (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@Dist0 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DriverID = ''' + LTrim(@Dist0) + ''''
	If (@Dist1 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID1 = ''' + LTrim(@Dist1) + ''''
	If (@Dist2 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.DistributerID2 = ''' + LTrim(@Dist2) + ''''

	If (@Dist5 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist5) + ' AND H.BaseDistributionSerialNo >= ' + LTrim(@Dist6)
	If (@Dist7 <> 'null')
		SET @StrWhere = @StrWhere + ' AND H.BaseDistributionProcessID = ' + LTrim(@Dist3) + ' AND H.BaseDistributionProcessNo = ' + LTrim(@Dist4) + ' AND H.BaseDistributionFiscalYear = ' + LTrim(@Dist7) + ' AND H.BaseDistributionSerialNo <= ' + LTrim(@Dist8)

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (H.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		BEGIN
			IF (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
		END

	-- Acnt Filter 
	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
	----------------------------------------------------
	---- FROM ------------------------------------------

	----------------------------------------------------
	---- SELECT ----------------------------------------
	---------------------------------------------------------

	DECLARE @AcntCode		VarChar(20)
	DECLARE @PreAcntCode	VarChar(20)
	DECLARE @DocDate		VarChar(10)
	DECLARE @PreDocDate		VarChar(10)
	DECLARE @Count			Int
	DECLARE @Diffs			Int

	CREATE Table #tbl_RptSal_AverageSale_AD
	(
		AcntCode VarChar(20),
		DocDate	 VarChar(10)
	);

	CREATE Table #tbl_RptSal_AverageSale_Result
	(
		AcntCode VarChar(20),
		SaleCount Int,
		DurationAvg Int,
		LastDocDate VarChar(10),
		DaysLeft Bit
	);

	SET @Count = 0
	SET @Diffs = 0

	SET @StrSelect = '
		INSERT INTO #tbl_RptSal_AverageSale_AD
		SELECT	AcntCode, DocDate
		FROM	inv.tblStorageDocsHdr H
		WHERE	' + @StrWhere
	EXEC sp_executesql @StrSelect;

	-- <<< dont clear this line >>>
	SELECT @StrSelect =	'
		INSERT INTO #tbl_RptSal_AverageSale_Result
		SELECT	H.AcntCode, Cast(Count(*) As Int) SaleCount, Cast(0 As Int) DurationAvg, Max(H.DocDate) LastDocDate, Cast(0 As Bit) DaysLeft
		FROM	inv.tblStorageDocsHdr H
		WHERE	' + @StrWhere + '
		GROUP BY H.AcntCode '
	EXEC sp_executesql @StrSelect;
	
	DECLARE csr_RptSal_AverageSale CURSOR FOR
		SELECT	AcntCode, DocDate
		FROM	#tbl_RptSal_AverageSale_AD
		ORDER BY AcntCode, DocDate
	
	OPEN csr_RptSal_AverageSale
	FETCH NEXT FROM csr_RptSal_AverageSale INTO @AcntCode, @DocDate

	SET @PreDocDate  = @DocDate	
	SET @PreAcntCode = @AcntCode
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@PreAcntCode = @AcntCode)
		BEGIN
			SET @Diffs = @Diffs + Abs(pub.funFarsiDateDiff('Day', @DocDate, @PreDocDate))
			SET @Count = @Count + 1
			SET @Finished = 0
		END
		ELSE
		BEGIN
			IF (@Count = 2)
				SET @Count = @Count - 1

			UPDATE	#tbl_RptSal_AverageSale_Result
			SET		DurationAvg = @Diffs / @Count, 
					DaysLeft =	CASE WHEN (Abs(pub.funFarsiDateDiff('Day', @Today, @PreDocDate)) > Round(@Diffs / @Count, 0)) THEN
									1
								ELSE
									0
								END
			WHERE	AcntCode = @PreAcntCode
			
			SET @Count = 1
			SET @Diffs = 0
			SET @Finished = 1
		END

		SET @PreDocDate = @DocDate
		SET @PreAcntCode = @AcntCode

		FETCH NEXT FROM csr_RptSal_AverageSale INTO @AcntCode, @DocDate
	END
		
	CLOSE csr_RptSal_AverageSale
	DEALLOCATE csr_RptSal_AverageSale

	If (@Finished = 0)
	BEGIN
		IF (@Count = 2)
			SET @Count = @Count - 1

		UPDATE	#tbl_RptSal_AverageSale_Result
		SET		DurationAvg = Round(@Diffs / @Count, 0), 
				DaysLeft =	CASE WHEN (Abs(pub.funFarsiDateDiff('Day', @Today, @PreDocDate)) > Round(@Diffs / @Count, 0)) THEN
								1
							ELSE
								0
							END
		WHERE	AcntCode = @PreAcntCode
	END;

	SELECT R.*, F.AcntName, F.Address1 + ' ' + F.Address2 [Address], 
			F.Tel, F.Mobile, F.OrganzationName
	FROM #tbl_RptSal_AverageSale_Result R
		outer apply acc.funGetCodeInfo(R.AcntCode) F
	WHERE (@DaysLeftOnly = 1 AND DaysLeft = 1) OR (@DaysLeftOnly = 0)
	
End
GO
