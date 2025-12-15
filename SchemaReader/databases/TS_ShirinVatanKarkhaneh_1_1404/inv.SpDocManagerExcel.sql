USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/01/16
-- Viewed By	 : 
-- Last Modified : 1392/04/05

-- Description	 : 
-- ==============================================
Create PROCEDURE inv.SpDocManagerExcel
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	

WITH ENCRYPTION
AS
DECLARE	@RetPID int
DECLARE	@DateFr char(10)
DECLARE	@DateTo char(10)
DECLARE @MaxSmallDealAmount as bigint
--declare @TaxOverWorthBeforOverLoadInBuy as bit
DECLARE @ProcessID	int, -- 55 or 90
		@FSFR	int, 
		@SRFR	int, 
		@FSTO	int,
		@SRTO	int, 
		@StrWhereH		NVarChar(Max),
		@StrWhereIN		NVarChar(Max),
		@LangID			Char(1),
		@SessionNo		Int, 
		@ReportID		Int,
		@UserID			Int,
		@UserIsAdmin	bit
DECLARE @StrSelect			NVarChar(max);		
DECLARE @StrSelect2			NVarChar(max);		
DECLARE @StrWhere			NVarChar(max);		
DECLARE @StrPNO				NVarChar(max);		
DECLARE @PartNumber	int;
DECLARE @Start	int;
DECLARE @Len	int;
DECLARE @Type	int;
DECLARE @StoreID int;
DECLARE @GoodsID int;
DECLARE @SubRetQty int;
DECLARE @WithTaxToll int;
DECLARE @GBGoodsCID	 int;
DECLARE	@SelectedAcnt1	Int;
DECLARE	@SelectedAcnt2	Int;
DECLARE	@SelectedAcnt3	Int;
DECLARE	@SelectedAcnt4	Int;

 BEGIN 

	SELECT @PartNumber =[acc].[FunGetAcntInfoForRemain](1)
	SELECT @Start =	[acc].[FunGetAcntInfoForRemain](2)
	SELECT @Len =[acc].[FunGetAcntInfoForRemain](3)

 	SET @ProcessID		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
 	SET @FSFR			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
 	SET @SRFR			    = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
 	SET @FSTO			    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @SRTO			    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @DateFr		        = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @DateTo			    = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @StrPNO			    = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	SET @Type			    = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @StoreID			= LTRIM(pub.funSplitString(@ExtraParams, '@', 10));
	SET @GoodsID			= LTRIM(pub.funSplitString(@ExtraParams, '@', 11));
	SET @SubRetQty			= LTRIM(pub.funSplitString(@ExtraParams, '@', 12));
	SET @WithTaxToll		= LTRIM(pub.funSplitString(@ExtraParams, '@', 13));
	SET @GBGoodsCID			= LTRIM(pub.funSplitString(@ExtraParams, '@', 14));
	SET @SelectedAcnt1		= LTRIM(pub.funSplitString(@ExtraParams, '@', 15));
	SET @SelectedAcnt2		= LTRIM(pub.funSplitString(@ExtraParams, '@', 16));
	SET @SelectedAcnt3		= LTRIM(pub.funSplitString(@ExtraParams, '@', 17));
	SET @SelectedAcnt4		= LTRIM(pub.funSplitString(@ExtraParams, '@', 18));
	 
	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);

	--select @ProcessID,@FSFR,@SRFR,@FSTO,@SRTO,@DateFr,@DateTo

	  SELECT  @StrWhere = ' AND D.ProcessNo in ( '+@StrPNO+')'
	
		IF @FSFR>0
			SET @StrWhere =@StrWhere+ ' AND D.FiscalYear>=' +str(@FSFR)
		IF @SRFR>0
			SET @StrWhere = @StrWhere+' AND D.SerialNo  >=' +str(@SRFR)
		IF @FSTO>0
			SET @StrWhere =@StrWhere+ ' AND D.FiscalYear<=' +str(@FSTO)
		IF @SRTO>0
			SET @StrWhere = @StrWhere+' AND D.SerialNo	<=' +str(@SRTO)
		IF @DateFr<>''
			SET @StrWhere = @StrWhere+' AND D.DocDate	>=''' + @DateFr +''''
		IF @DateTo<>''
			SET @StrWhere = @StrWhere+' AND D.DocDate	<=''' + @DateTo +''''
		
		IF (@StoreID > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'H.StoreID')
		
		IF (@GoodsID > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'D.GoodsID')

		IF (@SelectedAcnt1 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')

		IF (@SelectedAcnt2 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')

		IF (@SelectedAcnt3 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')

		IF (@SelectedAcnt4 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

IF @ProcessID=90
BEGIN
	SET @StrWhere = @StrWhere+  'And D.ProcessID in (90) '
	IF @Type=1
	BEGIN
		IF @GBGoodsCID=0
		BEGIN
			IF @SubRetQty=0
				SET @StrSelect2=', (SELECT 0 GoodsQuantity,
										   0 GoodsPrice,
										   0 DiscountDtl,
										   0 TaxOverWorthCostDtl,
										   0 TollOverWorthCostDtl) DR 			'
			ELSE
				SET @StrSelect2=' LEFT JOIN (SELECT BaseProcessID,
													BaseProcessNo,
													BaseFiscalYear,
													BaseSerialNo,
													BaseDocRowNo, 
													SUM(GoodsQuantity) GoodsQuantity,
													SUM(GoodsPrice) GoodsPrice,
													SUM(DiscountDtl) DiscountDtl,
													SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl,
													SUM(TollOverWorthCostDtl) TollOverWorthCostDtl  
											 FROM inv.tblStorageDocsDtl D 
											 WHERE ProcessID = 100 
											 GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo) DR ON DR.BaseProcessID = D.ProcessID 
																																  AND DR.BaseProcessNo = D.ProcessNo 
																																  AND DR.BaseFiscalYear = D.FiscalYear 
																																  AND DR.BaseSerialNo = D.SerialNo 
																																  AND DR.BaseDocRowNo = D.DocRowNo '
			SET @StrSelect = '
			SELECT DISTINCT VchDate VchDate2,
							D.SerialNo SerialNo2,
							CASE WHEN DocRowNo=1 THEN VchDate ELSE '''' END VchDate,
							Cast (CASE WHEN DocRowNo = 1 THEN RTrim(LTrim((Str(D.FiscalYear))) + ''/'' + RTrim(LTrim(str(D.SerialNo)))) ELSE '''' END AS NVARCHAR) AS SerialNo,
							CASE WHEN DocRowNo = 1 THEN CASE WHEN A.NationalIDNumber = '''' THEN A.NationalIdentity ELSE A.NationalIDNumber END ELSE '''' END  NationalIdentity, 
							CASE WHEN DocRowNo = 1 THEN pub.GetCodeName(D.AcntCode,1)ELSE '''' END AcntName, 
							CASE WHEN DocRowNo = 1 THEN A.Mobile ELSE '''' END Mobile,
							CASE WHEN DocRowNo = 1 THEN S.ZipCode ELSE '''' END ZipCode,
							D.DescDtl,
							GoodsCID,
							CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0)AS FLOAT) GoodsQuantity,
							D.GoodsPrice - ISNULL(DR.GoodsPrice,0) GoodsPrice,
							D.DiscountDtl - ISNULL(DR.DiscountDtl ,0) DiscountDtl,
							0 ExtraPrice, 
							D.TaxOverWorthCostDtl + D.TollOverWorthCostDtl - ISNULL(DR.TaxOverWorthCostDtl,0) - ISNULL(DR.TollOverWorthCostDtl ,0)TAxToll,
							DocRowNo, 
							BuyerRole
			FROM inv.tblStorageDocsDtl D
			INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID 
											  AND H.ProcessNo = D.ProcessNo 
											  AND H.FiscalYear = D.FiscalYear 
											  AND H.SerialNo = D.SerialNo 
			INNER JOIN inv.tblGoods G ON D.GoodsID = G.GoodsID
			INNER JOIN inv.tblStores S ON D.StoreID = S.StoreID
			INNER JOIN pub.tblProcess P ON D.ProcessID = P.ProcessID 
									   AND D.ProcessNo = P.ProcessNo
			INNER JOIN acc.tblAcnt A ON SUBSTRING (D.AcntCode,'+str(@Start)+','+str(@Len)+') = A.AcntCode 
									AND A.PartNumber = '+str(@PartNumber )+'
			'+@StrSelect2+'
			WHERE CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0)AS FLOAT ) > 0 
			  AND EnterKind = -1 
			  AND VchDate <> '''' '+ @StrWhere +' '
		END 
		ELSE
		BEGIN
			IF @SubRetQty=0
				SET @StrSelect2=' ,(SELECT 0 GoodsQuantity,
										   0 GoodsPrice,
										   0 DiscountDtl,
										   0 TaxOverWorthCostDtl,
										   0 TollOverWorthCostDtl) DR 			'
			ELSE
				SET @StrSelect2=' LEFT JOIN (SELECT BaseProcessID,
													BaseProcessNo,
													BaseFiscalYear,
													BaseSerialNo,
													BaseDocRowNo, 
													SUM(GoodsQuantity) GoodsQuantity,
													SUM(GoodsPrice) GoodsPrice,
													SUM(DiscountDtl) DiscountDtl,
													SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl,
													SUM(TollOverWorthCostDtl ) TollOverWorthCostDtl  
											 FROM inv.tblStorageDocsDtl D 
											 WHERE ProcessID = 100 
											 GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo) DR ON DR.BaseProcessID = D.ProcessID 
																																  AND DR.BaseProcessNo = D.ProcessNo 
																																  AND DR.BaseFiscalYear = D.FiscalYear 
																																  AND DR.BaseSerialNo = D.SerialNo 
																																  AND DR.BaseDocRowNo = D.DocRowNo '
			SET @StrSelect = '
			SELECT DISTINCT VchDate VchDate2,
							D.SerialNo SerialNo2,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN VchDate ELSE '''' END VchDate,
							Cast (CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN RTrim(LTrim((Str(D.FiscalYear))) + ''/'' + RTrim(LTrim(str(D.SerialNo)))) ELSE '''' END as nvarchar) as SerialNo,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN CASE WHEN A.NationalIDNumber = '''' THEN A.NationalIdentity ELSE A.NationalIDNumber END  ELSE '''' END NationalIdentity, 
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN pub.GetCodeName(D.AcntCode,1) ELSE '''' END AcntName, 
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN A.Mobile ELSE '''' END Mobile,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN S.ZipCode ELSE '''' END ZipCode,
							''''DescDtl,
							GoodsCID,
							SUM(CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0) AS FLOAT )) GoodsQuantity,
							AVG(D.GoodsPrice - ISNULL(DR.GoodsPrice,0)) GoodsPrice,
							AVG(D.DiscountDtl - ISNULL(DR.DiscountDtl ,0)) DiscountDtl,
							0 ExtraPrice, 
							AVG(D.TaxOverWorthCostDtl + D.TollOverWorthCostDtl - ISNULL(DR.TaxOverWorthCostDtl,0) - ISNULL(DR.TollOverWorthCostDtl ,0)) TAxToll,
							(ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) DocRowNo, 
							BuyerRole
			FROM inv.tblStorageDocsDtl D
			INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID 
											  AND H.ProcessNo = D.ProcessNo 
											  AND H.FiscalYear = D.FiscalYear 
											  AND H.SerialNo = D.SerialNo 
			INNER JOIN inv.tblGoods G ON D.GoodsID = G.GoodsID
			INNER JOIN inv.tblStores S ON D.StoreID = S.StoreID
			INNER JOIN pub.tblProcess P ON D.ProcessID = P.ProcessID 
									   AND D.ProcessNo = P.ProcessNo
			INNER JOIN acc.tblAcnt A ON SUBSTRING (D.AcntCode,'+str(@Start)+','+str(@Len)+') = A.AcntCode 
									AND A.PartNumber = '+str(@PartNumber )+'
			'+@StrSelect2+'
			WHERE CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0) AS FLOAT ) > 0 
			  AND EnterKind = -1 
			  AND VchDate <> '''' '+ @StrWhere +'
			GROUP BY VchDate, D.SerialNo, D.FiscalYear, A.NationalIDNumber, A.NationalIdentity, D.AcntCode, A.Mobile, S.ZipCode, GoodsCID, BuyerRole
			'
	END 
	END 
	IF @Type=2
	BEGIN
		IF @GBGoodsCID=0
		BEGIN
			IF @SubRetQty=0
				SET @StrSelect2=' ,(SELECT 0 GoodsQuantity,
										   0 GoodsPrice,
										   0 DiscountDtl,
										   0 TaxOverWorthCostDtl,
										   0 TollOverWorthCostDtl) DR '
			ELSE
				SET @StrSelect2=' LEFT JOIN (SELECT BaseProcessID,
													BaseProcessNo,
													BaseFiscalYear,
													BaseSerialNo,
													BaseDocRowNo, 
													SUM(GoodsQuantity) GoodsQuantity,
													SUM(GoodsPrice) GoodsPrice,
													SUM(DiscountDtl) DiscountDtl,
													SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl,
													SUM(TollOverWorthCostDtl ) TollOverWorthCostDtl  
											 FROM inv.tblStorageDocsDtl D 
											 WHERE ProcessID = 100 
											 GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo) DR ON DR.BaseProcessID = D.ProcessID 
																																  AND DR.BaseProcessNo = D.ProcessNo 
																																  AND DR.BaseFiscalYear = D.FiscalYear 
																																  AND DR.BaseSerialNo = D.SerialNo 
																																  AND DR.BaseDocRowNo = D.DocRowNo '
			SET @StrSelect = '
			SELECT DISTINCT VchDate VchDate2,
							D.SerialNo SerialNo2,
							CASE WHEN DocRowNo = 1 THEN VchDate ELSE '''' END VchDate,
							CAST (CASE WHEN DocRowNo = 1 THEN RTrim(LTrim((Str(D.FiscalYear))) + ''/'' + RTrim(LTrim(str(D.SerialNo)))) ELSE '''' END AS NVARCHAR) AS SerialNo,
							CASE WHEN DocRowNo = 1 THEN CASE WHEN A.NationalIDNumber = '''' THEN A.NationalIdentity ELSE A.NationalIDNumber END  ELSE '''' END  NationalIdentity, 
							CASE WHEN DocRowNo = 1 THEN pub.GetCodeName(D.AcntCode,1) ELSE '''' END AcntName, 
							CASE WHEN DocRowNo = 1 THEN A.Mobile ELSE '''' END Mobile,
							CASE WHEN DocRowNo = 1 THEN S.ZipCode ELSE '''' END ZipCode,
							CASE WHEN DocRowNo = 1 THEN CASE WHEN ISNULL(GR.StoreZipCode , '''') = '''' THEN ISNULL(A.StoreZipCode , '''') ELSE ISNULL(GR.StoreZipCode , '''') END ELSE '''' END ZipCode2, 
							CASE WHEN DocRowNo = 1 THEN ContractNumber ELSE '''' END ContractNumber,
							CASE WHEN DocRowNo = 1 THEN CASE WHEN H.TransporterID3 <> '''' THEN ''دارای بارنامه '' ELSE '''' END ELSE '''' END Trans1, 
							CASE WHEN DocRowNo = 1 THEN TransporterID2 ELSE '''' END Trans2,
							CASE WHEN DocRowNo = 1 THEN TransporterDate ELSE '''' END Trans3,
							CASE WHEN DocRowNo = 1 THEN TransporterID3 ELSE '''' END Trans4,
							D.DescDtl,
							GoodsCID,
							CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0)AS FLOAT) GoodsQuantity,
							D.GoodsPrice - ISNULL(DR.GoodsPrice,0) GoodsPrice,
							D.DiscountDtl - ISNULL(DR.DiscountDtl ,0) DiscountDtl, 
							D.TaxOverWorthCostDtl + D.TollOverWorthCostDtl - ISNULL(DR.TaxOverWorthCostDtl,0) - ISNULL(DR.TollOverWorthCostDtl ,0)TAxToll, 
							D.ProcessID, 
							D.ProcessNo, 
							D.FiscalYear,
							DocRowNo, 
							BuyerRole, 
							D.OtherIncomeDtl
			FROM inv.tblStorageDocsDtl D
			INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID 
											  AND H.ProcessNo = D.ProcessNo 
											  AND H.FiscalYear = D.FiscalYear 
											  AND H.SerialNo = D.SerialNo 
			INNER JOIN inv.tblGoods G ON D.GoodsID = G.GoodsID
			INNER JOIN inv.tblStores S ON D.StoreID = S.StoreID
			INNER JOIN pub.tblProcess P ON D.ProcessID = P.ProcessID 
									   AND D.ProcessNo = P.ProcessNo
			INNER JOIN acc.tblAcnt A ON SUBSTRING (D.AcntCode,'+str(@Start)+','+str(@Len)+') = A.AcntCode 
									AND A.PartNumber = '+str(@PartNumber )+'
			LEFT JOIN inv.tblGoodsReciverDtl GR ON GR.ReciverID = H.GoodsReciverID 
											   AND GR.LanguageID=1
			LEFT JOIN sal.tblTransportersDtl TR ON TR.TransporterID = H.TransporterID 
											   AND TR.LanguageID=1		
			'+@StrSelect2+'
			WHERE CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0)as Float ) > 0 
			  AND EnterKind = -1 
			  AND VchDate <> '''' '+ @StrWhere +' '
		END 
		ELSE 
		BEGIN
			IF @SubRetQty=0
				SET @StrSelect2=', (SELECT 0 GoodsQuantity,
										   0 GoodsPrice,
										   0 DiscountDtl,
										   0 TaxOverWorthCostDtl,
										   0 TollOverWorthCostDtl) DR 			'
			ELSE
				SET @StrSelect2=' LEFT JOIN (SELECT BaseProcessID,
													BaseProcessNo,
													BaseFiscalYear,
													BaseSerialNo,
													BaseDocRowNo, 
													SUM(GoodsQuantity) GoodsQuantity,
													SUM(GoodsPrice) GoodsPrice,
													SUM(DiscountDtl) DiscountDtl,
													SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl,
													SUM(TollOverWorthCostDtl ) TollOverWorthCostDtl  
											 FROM inv.tblStorageDocsDtl D 
											 WHERE ProcessID = 100 
											 GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo
									) DR ON DR.BaseProcessID = D.ProcessID 
										AND DR.BaseProcessNo = D.ProcessNo 
										AND DR.BaseFiscalYear = D.FiscalYear 
										AND DR.BaseSerialNo = D.SerialNo 
										AND DR.BaseDocRowNo = D.DocRowNo '
			set @StrSelect = '
			SELECT DISTINCT VchDate VchDate2,
							D.SerialNo SerialNo2,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN VchDate ELSE '''' END VchDate,
							CAST (CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN RTrim(LTrim((Str(D.FiscalYear))) + ''/'' + RTrim(LTrim(str(D.SerialNo)))) ELSE '''' END AS NVARCHAR) AS SerialNo,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN CASE WHEN A.NationalIDNumber = '''' THEN A.NationalIdentity ELSE A.NationalIDNumber END  ELSE '''' END  NationalIdentity,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN pub.GetCodeName(D.AcntCode,1) else '''' END AcntName, 
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN A.Mobile ELSE '''' END Mobile,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN S.ZipCode ELSE '''' END ZipCode,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN CASE WHEN ISNULL(GR.StoreZipCode , '''') = '''' THEN  ISNULL(A.StoreZipCode , '''')  ELSE ISNULL(GR.StoreZipCode , '''')  END ELSE '''' END ZipCode2,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN ContractNumber ELSE '''' END  ContractNumber,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN CASE WHEN H.TransporterID3 <> '''' THEN ''دارای بارنامه '' ELSE '''' END ELSE '''' END  Trans1, 
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN TransporterID2  ELSE '''' END Trans2,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN TransporterDate  ELSE '''' END Trans3,
							CASE WHEN (ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) = 1 THEN TransporterID3  ELSE '''' END Trans4,
							'''' DescDtl,
							GoodsCID,
							SUM(CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0) as Float )) GoodsQuantity,
							AVG(D.GoodsPrice - ISNULL(DR.GoodsPrice,0) )GoodsPrice,
							AVG(D.DiscountDtl - ISNULL(DR.DiscountDtl ,0))DiscountDtl,
							AVG(D.TaxOverWorthCostDtl + D.TollOverWorthCostDtl - ISNULL(DR.TaxOverWorthCostDtl,0) - ISNULL(DR.TollOverWorthCostDtl ,0)) TAxToll, 
							D.ProcessID, 
							D.ProcessNo, 
							D.FiscalYear,
							(ROW_NUMBER() OVER (PARTITION BY VchDate,D.SerialNo,D.AcntCode ORDER BY VchDate,D.SerialNo,D.AcntCode)) DocRowNo, 
							BuyerRole, 
							D.OtherIncomeDtl
			FROM inv.tblStorageDocsDtl D
			INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID 
											  AND H.ProcessNo = D.ProcessNo 
											  AND H.FiscalYear = D.FiscalYear 
											  AND H.SerialNo = D.SerialNo 
			INNER JOIN inv.tblGoods G ON D.GoodsID = G.GoodsID
			INNER JOIN inv.tblStores S ON D.StoreID = S.StoreID
			INNER JOIN pub.tblProcess P ON D.ProcessID = P.ProcessID 
									   AND D.ProcessNo = P.ProcessNo
			INNER JOIN acc.tblAcnt A ON SUBSTRING (D.AcntCode,'+str(@Start)+','+str(@Len)+') = A.AcntCode 
									AND A.PartNumber = '+str(@PartNumber )+'
			LEFT JOIN inv.tblGoodsReciverDtl GR ON GR.ReciverID = H.GoodsReciverID 
											   AND GR.LanguageID = 1
			LEFT JOIN sal.tblTransportersDtl TR ON TR.TransporterID = H.TransporterID 
											   AND TR.LanguageID = 1		
			'+@StrSelect2+'
			WHERE CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0)as Float) > 0 
			  AND EnterKind = -1 
			  AND VchDate<>'''' '+ @StrWhere +' 
			GROUP BY VchDate, D.SerialNo, D.FiscalYear, A.NationalIDNumber, A.NationalIdentity, D.AcntCode, A.Mobile , S.ZipCode ,GoodsCID, BuyerRole,
					 ContractNumber, TransporterID3, TransporterID2, TransporterDate, D.ProcessID, D.ProcessNo, D.FiscalYear, D.OtherIncomeDtl,
					 A.StoreZipCode, GR.StoreZipCode
			'
		END 
	END 	 

		IF @GBGoodsCID=0
			SET @StrSelect =@StrSelect + 'ORDER BY VchDate2, SerialNo2, DocRowNo '
		ELSE
			SET @StrSelect =@StrSelect + 'ORDER BY VchDate2, SerialNo2'

	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;

	RETURN 

END 	 

IF @ProcessID=55

BEGIN
	SET @StrWhere = @StrWhere+  ' And D.ProcessID in (55) '
	IF @SubRetQty=0
		SET @StrSelect2=', (SELECT 0 GoodsQuantity, 
								   0 GoodsPrice,
								   0 DiscountDtl,
								   0 TaxOverWorthCostDtl,
								   0 TollOverWorthCostDtl) DR 			'
	ELSE
		SET @StrSelect2=' LEFT JOIN (SELECT BaseProcessID,
											BaseProcessNo,
											BaseFiscalYear,
											BaseSerialNo,
											BaseDocRowNo, 
											SUM(GoodsQuantity) GoodsQuantity,
											SUM(GoodsPrice) GoodsPrice,
											SUM(DiscountDtl) DiscountDtl,
											SUM(TaxOverWorthCostDtl) TaxOverWorthCostDtl,
											SUM(TollOverWorthCostDtl) TollOverWorthCostDtl  
									 FROM inv.tblStorageDocsDtl D 
									 WHERE ProcessID = 60 
									 GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo) DR ON DR.BaseProcessID = D.ProcessID 
																														  AND DR.BaseProcessNo = D.ProcessNo 
																														  AND DR.BaseFiscalYear = D.FiscalYear 
																														  AND DR.BaseSerialNo = D.SerialNo 
																														  AND DR.BaseDocRowNo = D.DocRowNo '
		SET @StrSelect = '	
		SELECT DISTINCT D.ProcessID, 
						D.ProcessNo, 
						D.FiscalYear, 
						D.SerialNo, 
						S.ZipCode,
						VchDate,
						P.ProcessName,
						D.AcntCode,
						pub.GetCodeName(D.AcntCode,1) AcntName,
						NationalIdentity, 
						A.Mobile,
						ExitLocation,
						AssessmentLocation,
						KotagNo,
						D.DescDtl,
						GoodsCID,
						CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0) as Float ) GoodsQuantity,
						D.GoodsPrice - ISNULL(DR.GoodsPrice,0) GoodsPrice,
						BuyerRole
		FROM inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = D.ProcessID 
										  AND H.ProcessNo = D.ProcessNo 
										  AND H.FiscalYear = D.FiscalYear 
										  AND H.SerialNo = D.SerialNo 
		INNER JOIN inv.tblGoods G ON D.GoodsID = G.GoodsID
		INNER JOIN inv.tblStores S ON D.StoreID = S.StoreID
		INNER JOIN pub.tblProcess P ON D.ProcessID = P.ProcessID 
								   AND D.ProcessNo = P.ProcessNo
		INNER JOIN acc.tblAcnt A ON SUBSTRING (D.AcntCode,'+str(@Start)+','+str(@Len)+') = A.AcntCode 
								AND A.PartNumber = '+str(@PartNumber )+'
		'+@StrSelect2+'
		WHERE CAST(D.GoodsQuantity - ISNULL(DR.GoodsQuantity ,0)as Float ) > 0 
		  AND EnterKind = 1 
		  AND VchDate <> '''' 
		'+ @StrWhere +' '
		
	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;

	RETURN 

END 
  
IF @ProcessID=80
BEGIN
		SET @StrWhere = @StrWhere+  ' And D.ProcessID in (72,80) '
		IF @WithTaxToll<>0
			SET @StrWhere = @StrWhere+  'And (H.TaxOverWorthCost > 0 OR D.TaxOverWorthCostDtl > 0)'
		IF @GBGoodsCID=0
		BEGIN
		SET @StrSelect = '
		SELECT DISTINCT D.ProcessID,
						D.ProcessNo, 
						D.FiscalYear, 
						D.SerialNo, 
						S.ZipCode,
						D.DocDate,
						CASE WHEN D.DescDtl <> '''' THEN D.DescDtl ELSE H.DocDesc END AS DescDtl,
						GoodsCID,
						D.GoodsID,
						[pub].[funGetGoodsName](D.GoodsID,' + Ltrim(Rtrim(Str(@LangID))) + ') GoodsName,
						CAST(D.GoodsQuantity as Float) GoodsQuantity
		FROM inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H ON D.ProcessID = H.ProcessID 
										  AND D.ProcessNo = H.ProcessNo 
										  AND D.FiscalYear = H.FiscalYear 
										  AND D.SerialNo = H.SerialNo
		INNER JOIN inv.tblGoods G ON D.GoodsID = G.GoodsID
		INNER JOIN inv.tblStores S ON D.StoreID = S.StoreID
		WHERE 1 = 1 '+ @StrWhere +' '
		END
		ELSE
		BEGIN
		SET @StrSelect = '
		SELECT DISTINCT D.ProcessID, 
						D.ProcessNo, 
						D.FiscalYear, 
						S.ZipCode, 
						D.DocDate,
						'''' DescDtl, 
						G.GoodsCID,
						CASE WHEN ( SELECT COUNT (DISTINCT G1.GoodsID)
									FROM inv.tblGoods G1
									WHERE G1.GoodsCID = G.GoodsCID) = 1 THEN ( SELECT TOP 1 G2.GoodsID
																			   FROM inv.tblGoods G2
																			   WHERE G2.GoodsCID = G.GoodsCID)
						ELSE '''' END AS GoodsID,
						CASE WHEN ( SELECT COUNT (DISTINCT G1.GoodsID)
									FROM inv.tblGoods G1
									WHERE G1.GoodsCID = G.GoodsCID) = 1 THEN ( SELECT TOP 1 [pub].[GetGoodsName](G2.GoodsID,1) GoodsName
																			   FROM inv.tblGoods G2
																			   WHERE G2.GoodsCID = G.GoodsCID)
						ELSE ''شناسه برای بیش از یک کد کالا ثبت شده'' END AS GoodsName,
						SUM(CAST(D.GoodsQuantity as Float)) GoodsQuantity 
		FROM inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H ON D.ProcessID = H.ProcessID 
										  AND D.ProcessNo = H.ProcessNo 
										  AND D.FiscalYear = H.FiscalYear 
										  AND D.SerialNo = H.SerialNo
		INNER JOIN inv.tblGoods G ON D.GoodsID = G.GoodsID
		INNER JOIN inv.tblStores S ON D.StoreID = S.StoreID
		WHERE 1 = 1 '+ @StrWhere +'
		GROUP BY D.ProcessID, D.ProcessNo, D.FiscalYear, D.DocDate, GoodsCID, S.ZipCode '
		END

	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;

	RETURN 
END 	 

END----end
GO
