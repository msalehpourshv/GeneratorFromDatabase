USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--use TS_ShirinVatanKarkhaneh_1_1398

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/06/28
-- Viewed By	 : 
-- Last Modified : 1389/06/28
-- Last Modifier : Takrosystem\Zia
-- Description	 : مشخصات مشتریان
-- ===============================================
CREATE PROCEDURE [inv].[RptBatchBarcode]
	@BatchNo		varchar(20) = '', -- شماره بخش
	@Extraparam	    VarChar(1000) = Null, 
	@RepOptions		NVarChar(10) = '11',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@SortByName		Bit; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@QtyForPrint	Int;
DECLARE	@BaseFiscalYear	varchar(4);
DECLARE	@BaseSerialNo	varchar(20);
DECLARE	@ProcessID		varchar(20);

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrHaving		NVarChar(1000);

BEGIN 
	--============================ S T A R T ===========================================

	-- init ------------------------------------------------
	SET NOCOUNT ON;

	If (@RepInfo Is Null)	SET @RepInfo = '1@1@1'
	If (@RepOptions Is Null) SET @RepOptions = '11'

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @SortByName		= Substring(@RepOptions, 2, 1);
	--------------------------------------------------------
	SET @BaseFiscalYear = pub.funSplitString(@Extraparam, '@', 1);
	SET @BaseSerialNo = pub.funSplitString(@Extraparam, '@', 2);
	SET @ProcessID = pub.funSplitString(@Extraparam, '@', 3);
	SET @QtyForPrint = pub.funSplitString(@Extraparam, '@', 4);



	--------------------------------------------------------
	--------------------------------------------------------
	--drop table  #T
	select @QtyForPrint RR into #T

	while @QtyForPrint>1
	BEGIN
		Set @QtyForPrint=@QtyForPrint-1
		insert into #T
		select @QtyForPrint
	END

--	select * from #T
	-------------------------------------------------------------------------------------
	-- where ----------------------------------------------------------------------------
	SET @StrWhere = ' D.LanguageID = ' + @LangID + ' '


	IF (@BatchNo <> '' and @BatchNo is not NULL )
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BatchNo, 'H.BatchNo')

    IF (@BaseSerialNo IS NOT NULL AND @BaseSerialNo>0)
		SET @StrWhere = @StrWhere + ' AND BaseFiscalYear=' + @BaseFiscalYear + '  AND BaseSerialNo = ' + @BaseSerialNo

    IF (@ProcessID IS NOT NULL AND @ProcessID>0)
		SET @StrWhere = @StrWhere + ' AND BaseProcessID=' + @ProcessID 

	-------------------------------------------------------------------------------------
	-- select ---------------------------------------------------------------------------
	SET @StrSelect = '
		SELECT	H.*,D.BatchName,BatchExtraField1,BatchExtraField2,BatchExtraField3,BatchExtraField4,[pub].[funGetGoodsName](RelatedGoodsID,' + @LangID +') GoodsName,[pub].[GetCodeName](OrderAcntCode,' + @LangID +') AcntName,pub.funFarsiDate(getdate()) PrintDate
		,ProductionLineName,ShiftName
	    From inv.tblBatch H 
		INNER JOIN inv.tblBatchDtl D ON H.BatchNo = D.BatchNo
		LEFT JOIN emp.tblShiftsDtl SH ON H.ShiftID = SH.ShiftID AND SH.LanguageID=' + @LangID + '
		LEFT JOIN pln.tblProductionLinesDtl PL ON H.ProductionLineID = PL.ProductionLineID AND PL.LanguageID=' + @LangID + '
		CROSS JOIN #T
		WHERE  ' + @StrWhere 

	If (@SortByName = 1)
		SET @StrSelect = @StrSelect + '
		ORDER By BatchName '
	Else
		SET @StrSelect = @StrSelect + '
		ORDER By BatchNo '
		
	
	-------------------------------------------------------------------------------------
	-- run ------------------------------------------------------------------------------
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	-------------------------------------------------------------------------------------
END
GO
