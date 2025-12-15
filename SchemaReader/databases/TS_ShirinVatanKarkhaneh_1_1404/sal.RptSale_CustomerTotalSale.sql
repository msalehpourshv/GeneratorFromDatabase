USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1395/02/29
-- Viewed By	 : 
-- Last Modified : 1395/02/29
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
Create PROCEDURE [sal].[RptSale_CustomerTotalSale]
	@ProcessID		VarChar(20) = 90,
	@FromDate		Char(10) = Null,
	@ToDate			Char(10) = Null,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0, 
	@SelectedAcnt3	Int = 0, 
	@SelectedAcnt4	Int = 0,

	@ExtraParams	NVarChar(500) = Null,
	@RepOptions		VarChar(10) = '111011111',  -- Bit Array Options
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

---- Declarations ---------------
DECLARE @StrSelect1	NVarChar(max);
DECLARE @StrSelect2	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhere2	NVarChar(max);

DECLARE @strGroupBy NVarchar (100);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@ProcessNo	VarChar(20);

DECLARE @CustomerInfo Int;
DECLARE @chkRetail	  bit;
DECLARE @chkShowNoSaleRecords bit;
DECLARE @SelectedVisitor1	  Int ;
DECLARE @SelectedVisitor2	  Int ;
DECLARE @SelectedVisitor3	  Int ;
DECLARE @SelectedVisitor4	  Int ;
DECLARE @SelectedVisitor21	  Int ;
DECLARE @SelectedVisitor22	  Int ;
DECLARE @SelectedVisitor23	  Int ;
DECLARE @SelectedVisitor24	  Int ;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- Init Variables -------------------------------------

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ProcessNo			  = pub.funSplitString(@ExtraParams, '@', 1);
	SET @CustomerInfo		  = pub.funSplitString(@ExtraParams, '@', 2);
	SET @chkRetail			  = pub.funSplitString(@ExtraParams, '@', 3);
	SET @chkShowNoSaleRecords = pub.funSplitString(@ExtraParams, '@', 4);
	SET @SelectedVisitor1	  = pub.funSplitString(@ExtraParams, '@', 5);
	SET @SelectedVisitor2	  = pub.funSplitString(@ExtraParams, '@', 6);
	SET @SelectedVisitor3	  = pub.funSplitString(@ExtraParams, '@', 7);
	SET @SelectedVisitor4	  = pub.funSplitString(@ExtraParams, '@', 8);
	SET @SelectedVisitor21	  = pub.funSplitString(@ExtraParams, '@', 9);
	SET @SelectedVisitor22	  = pub.funSplitString(@ExtraParams, '@', 10);
	SET @SelectedVisitor23	  = pub.funSplitString(@ExtraParams, '@', 11);
	SET @SelectedVisitor24	  = pub.funSplitString(@ExtraParams, '@', 12);
	
	IF (@SelectedAcnt1	 	 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	 	 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	 	 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	 	 Is Null)	SET @SelectedAcnt4 = 0;

	IF (@CustomerInfo	   Is Null)  SET @CustomerInfo = 0;

	IF (@SelectedVisitor1  Is Null)	SET @SelectedVisitor1 = 0;
	IF (@SelectedVisitor2  Is Null)	SET @SelectedVisitor2 = 0;
	IF (@SelectedVisitor3  Is Null)	SET @SelectedVisitor3 = 0;
	IF (@SelectedVisitor4  Is Null)	SET @SelectedVisitor4 = 0;
	IF (@SelectedVisitor21 Is Null)	SET @SelectedVisitor21 = 0;
	IF (@SelectedVisitor22 Is Null)	SET @SelectedVisitor22 = 0;
	IF (@SelectedVisitor23 Is Null)	SET @SelectedVisitor23 = 0;
	IF (@SelectedVisitor24 Is Null)	SET @SelectedVisitor24 = 0;

	-- Where Clause -----------------------------------------
	Select @StrWhere = '1 = 1'
	Select @StrWhere2 = ''

	If (@chkRetail = 1)
	Begin
		set @SelectedAcnt1 = 0;
		set @SelectedAcnt2 = 0;
		set @SelectedAcnt3 = 0;
		set @SelectedAcnt4 = 0;
	End
	If (@chkRetail = 0)
		set @CustomerInfo = 0;

	IF (@ProcessID Is Not Null And @ProcessID <> '')
	Begin
		IF @chkShowNoSaleRecords = 0
			Set @StrWhere = @StrWhere + ' AND (ProcessID = ' + @ProcessID + ')  AND (ProcessNo in ( ' + @ProcessNo + ')) '
		ELSE
			Set @StrWhere = @StrWhere + ' AND (ProcessID in (' + @ProcessID + ', 100) )  AND (ProcessNo in ( ' + @ProcessNo + ')) '
		--Set @StrWhere2 = @StrWhere2 + ' AND (BaseProcessID = ' + @ProcessID + ')AND (BaseProcessNo in ( ' + @ProcessNo + '))'
	End
	
	IF (@FromDate Is Not Null And @FromDate <> '')
	Begin
		Set @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @FromDate + ''')'
		Set @StrWhere2 = @StrWhere2 + ' AND (DocDate >= ''' + @FromDate + ''')'
	End
		
	IF (@ToDate Is Not Null And @ToDate <> '')
	Begin
		Set @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @ToDate + ''')'
		Set @StrWhere2 = @StrWhere2 + ' AND (DocDate <= ''' + @ToDate + ''')'
	End

	IF (@SelectedAcnt1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	End
	IF (@SelectedAcnt2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	End
	IF (@SelectedAcnt3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	End
	IF (@SelectedAcnt4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	End
	IF (@CustomerInfo > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND  OrderAcntCode in (Select CustomerInfoID from lyl.tblCustomerInfo where 1=1 and   ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerInfo, 'CustomerInfoID') +' )'
		SET @StrWhere2 = @StrWhere2 + ' AND  OrderAcntCode in (Select CustomerInfoID from lyl.tblCustomerInfo where 1=1 and   ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerInfo, 'CustomerInfoID') +' )'
	End

	IF (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'D.VisitorAcntCode') + ')'
	IF (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'D.VisitorAcntCode') + ')'
	IF (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'D.VisitorAcntCode') + ')'
	IF (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'D.VisitorAcntCode') + ')'
	IF (@SelectedVisitor21 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor21, 'D.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor22 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor22, 'D.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor23 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor23, 'D.VisitorAcntCode2') + ')'
	IF (@SelectedVisitor24 > 0)
		SET @StrWhere = @StrWhere + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor24, 'D.VisitorAcntCode2') + ')'
	
	-- Select Clause -------------------------------------------
		
	IF (@chkRetail = 0)
	BEGIN
			SET @StrSelect1 = '
					SELECT a.AcntCode, 
						   [pub].[GetCodeName](a.AcntCode, ' + LTrim(RTrim(STR(@LangID))) + ') As AcntName, 
						   SaleAmount, 
						   IsNull(RetSaleAmount,0) RetSaleAmount, 
						   DiscountDtl, 
						   IsNull(RetDiscountDtl,0) RetDiscountDtl,
						   Discount, 
						   IsNull(RetDiscount,0) RetDiscount, 
						   IsNull(TaxOverWorthCost,0) TaxOverWorthCost, 
						   IsNull(RetTaxOverWorthCost,0) RetTaxOverWorthCost, 
						   IsNull(TollOverWorthCost,0) TollOverWorthCost, 
						   IsNull(RetTollOverWorthCost,0) RetTollOverWorthCost, 
						   IsNull(TransportationCost,0) TransportationCost,
						   IsNull(AfterSaleDiscount,0) AfterSaleDiscount,
						   IsNull(RetTransportationCost,0) RetTransportationCost,
						   IsNull(VisitorCost,0) VisitorCost, 
						   IsNull(RetVisitorCost,0) RetVisitorCost, 
						   IsNull(VisitorCost2,0) VisitorCost2,
						   IsNull(RetVisitorCost2,0) RetVisitorCost2,
						   Cast('''' as varchar(100)) LYL_CustomerInfoID,
						   '+str(@chkRetail)+' checkRetail,
						   Cast('''' as varchar(100)) LYL_BirthDate,
						   Cast('''' as varchar(100)) LYL_RegisterDate,
						   Cast('''' as varchar(100)) LYL_MobileNumber,
						   Cast('''' as varchar(100)) LYL_PhoneNumber,
						   Cast('''' as varchar(100)) LYL_Gender,
						   Cast('''' as varchar(100)) LYL_FirstName,
						   Cast('''' as varchar(100)) LYL_LastName,
						   Cast('''' as varchar(100)) LYL_Adress,
						   F.*
					FROM
					(SELECT AcntCode, 
						    Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ')=1 AND ProcessID =100 THEN 0 ELSE D.GoodsQuantity * D.GoodsPrice END ) As SaleAmount, 
							Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ')=1 AND ProcessID =100 THEN 0 ELSE D.DiscountDtl END ) As DiscountDtl  
					 FROM inv.tblStorageDocsDtl D
					 WHERE ' + @StrWhere + '
					 GROUP BY AcntCode) a
					 INNER JOIN (SELECT AcntCode,
										Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ') = 1 AND ProcessID = 100 THEN 0 ELSE (Discount + Discount2 + Discount3) END ) As Discount, 	
										Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ') = 1 AND ProcessID = 100 THEN 0 ELSE TaxOverWorthCost END ) As TaxOverWorthCost, 	
										Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ') = 1 AND ProcessID = 100 THEN 0 ELSE TollOverWorthCost END ) As TollOverWorthCost, 	
										Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ') = 1 AND ProcessID = 100 THEN 0 ELSE TransportationCost END ) As TransportationCost, 	
										Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ') = 1 AND ProcessID = 100 THEN 0 ELSE AfterSaleDiscount END ) As AfterSaleDiscount, 	
										Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ') = 1 AND ProcessID = 100 THEN 0 ELSE VisitorCost END ) As VisitorCost, 	
										Sum(CASE WHEN LTRIM(' + STR(@chkShowNoSaleRecords) + ') = 1 AND ProcessID = 100 THEN 0 ELSE VisitorCost2 END ) As VisitorCost2
								 FROM inv.tblStorageDocsHdr D								 	 				 
								 WHERE  ' + @StrWhere + '									 	 				 
								 GROUP BY AcntCode) b ON a.AcntCode = b.AcntCode'			 	 				 
			SET @StrSelect2 = '														 	 				 
						LEFT JOIN (SELECT AcntCode,
										  Sum(CASE WHEN (BaseProcessID = 90 AND (D.GoodsQuantity * D.GoodsPrice) <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN (D.GoodsQuantity * D.GoodsPrice) ELSE 0 END ) As RetSaleAmount,
										  Sum(CASE WHEN (BaseProcessID = 90 AND D.DiscountDtl <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN D.DiscountDtl ELSE 0 END ) As RetDiscountDtl 	    
								   FROM inv.tblStorageDocsDtl D								 	 				 
								   WHERE ProcessID = 100 										 	 				 
								     AND ProcessNo in ( ' + @ProcessNo + ') ' + @StrWhere2 + '	 	 				 
								   GROUP BY AcntCode) c ON a.AcntCode = c.AcntCode				 	 				 
						LEFT JOIN (SELECT AcntCode,
										  Sum(CASE WHEN (BaseProcessID = 90 AND (Discount + Discount2 + Discount3) <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN (Discount + Discount2 + Discount3) ELSE 0 END ) As RetDiscount,
										  Sum(CASE WHEN (BaseProcessID = 90 AND TaxOverWorthCost <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN TaxOverWorthCost ELSE 0 END ) As RetTaxOverWorthCost,
										  Sum(CASE WHEN (BaseProcessID = 90 AND TollOverWorthCost <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN TollOverWorthCost ELSE 0 END ) As RetTollOverWorthCost, 	   
										  Sum(CASE WHEN (BaseProcessID = 90 AND TransportationCost <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN TransportationCost ELSE 0 END ) As RetTransportationCost, 	
										  Sum(CASE WHEN (BaseProcessID = 90 AND VisitorCost <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN VisitorCost ELSE 0 END ) As RetVisitorCost, 	
										  Sum(CASE WHEN (BaseProcessID = 90 AND VisitorCost2 <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN VisitorCost2 ELSE 0 END ) As RetVisitorCost2	
								   FROM inv.tblStorageDocsHdr D
								   WHERE ProcessID = 100 AND ProcessNo in ( ' + @ProcessNo + ') ' + @StrWhere2 + '
								   GROUP BY AcntCode) d ON a.AcntCode = d.AcntCode
						OUTER APPLY acc.funGetCodeInfo(a.AcntCode) F
						ORDER BY AcntCode
									'
	END
	ELSE IF (@chkRetail = 1)
	BEGIN
			SET @StrSelect1 = '
				SELECT Cast('''' as varchar(100)) AcntCode,
					   Cast('''' as varchar(100)) AcntName,
					   SaleAmount, 
					   IsNull(RetSaleAmount,0) RetSaleAmount, 
					   DiscountDtl, 
					   IsNull(RetDiscountDtl,0) RetDiscountDtl,
					   Discount, 
					   IsNull(RetDiscount,0) RetDiscount, 
					   IsNull(TaxOverWorthCost,0) TaxOverWorthCost, 
					   IsNull(RetTaxOverWorthCost,0) RetTaxOverWorthCost, 
					   IsNull(TollOverWorthCost,0) TollOverWorthCost, 
					   IsNull(RetTollOverWorthCost,0) RetTollOverWorthCost, 
					   IsNull(TransportationCost,0) TransportationCost,
					   IsNull(AfterSaleDiscount,0) AfterSaleDiscount,
					   IsNull(RetTransportationCost,0) RetTransportationCost,
					   IsNull(VisitorCost,0) VisitorCost, 
					   IsNull(RetVisitorCost,0) RetVisitorCost, 
					   IsNull(VisitorCost2,0) VisitorCost2,
					   IsNull(RetVisitorCost2,0) RetVisitorCost2,
					   ISNULL(CI.CustomerInfoID,'''') LYL_CustomerInfoID,
					   '+str(@chkRetail)+' checkRetail,
					   ISNULL(CI.BirthDate,'''') LYL_BirthDate,
					   ISNULL(CI.RegisterDate,'''') LYL_RegisterDate,
					   ISNULL(CI.MobileNumber,'''') LYL_MobileNumber,
					   ISNULL(CI.PhoneNumber,'''') LYL_PhoneNumber,
					   ISNULL(CI.Gender,'''') LYL_Gender,
					   ISNULL(CID.FirstName,'''') LYL_FirstName,
					   ISNULL(CID.LastName,'''') LYL_LastName,
					   ISNULL(CID.Adress,'''') LYL_Adress,
					   Cast('''' as varchar(100))Tel,
					   Cast('''' as varchar(100))OtherTels,
					   Cast('''' as varchar(100))EconomicalCode,
					   Cast('''' as varchar(100))AcntName,
					   Cast('''' as varchar(100))AcntComment,
					   Cast('''' as varchar(100))Address1,
					   Cast('''' as varchar(100))Address2,
					   Cast(0 as bit)InitialGrad,
					   Cast('''' as varchar(100))CustomerFirstName,
					   Cast('''' as varchar(100))CustomerLastName,
					   Cast('''' as varchar(100))ZipCode,
					   Cast('''' as varchar(100))CompanyRegisterNo,
					   Cast('''' as varchar(100))NationalIDNumber,
					   Cast('''' as varchar(100))LocationID,
					   Cast('''' as varchar(100))Mobile,
					   Cast('''' as varchar(100))SMSMobile,
					   Cast('''' as varchar(100))OrganzationName,
					   Cast('''' as varchar(100))MaxDebitRemain,
					   Cast('''' as varchar(100))MaxReceivableRemain,
					   Cast('''' as varchar(100))DistributionPoint,
					   Cast('''' as varchar(100))AsnafID,
					   Cast('''' as varchar(100))Sequence,
					   Cast('''' as varchar(100))Fax,
					   Cast('''' as varchar(100))Email,
					   Cast('''' as varchar(100))MemberDate,
					   Cast('''' as varchar(100))VisitPathID1,
					   Cast('''' as varchar(100))VisitPathID2,
					   Cast('''' as varchar(100))VisitPathID3,
					   Cast('''' as varchar(100))VisitPathID4,
					   Cast('''' as varchar(100))CampaignID,
					   Cast('''' as varchar(100))TransporterID,
					   Cast('''' as varchar(100))NationalIdentity,
					   Cast('''' as varchar(100))SaleCustomerType,
					   Cast('''' as varchar(100))BuyCustomerType,
					   Cast('''' as varchar(100))CustomerKindID,
					   Cast('''' as varchar(100))SalesRoomClass,
					   Cast('''' as varchar(100))SaleCash,
					   Cast('''' as varchar(100))TableauText,
					   Cast('''' as varchar(100))AcntContainTax,
					   Cast('''' as varchar(100))PersonType,
					   Cast('''' as varchar(100))AccountNumber,
					   Cast('''' as varchar(100))ShabaAccountNumber,
					   Cast('''' as varchar(100))PayIdentity,
					   Cast('''' as varchar(100))CodeClosed,
					   Cast('''' as varchar(100))StoreZipCode

				FROM
				(

					SELECT OrderAcntCode,
						   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ')=1 AND ProcessID =100 THEN 0 ELSE D.GoodsQuantity * D.GoodsPrice END ) As SaleAmount, 
						   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ')=1 AND ProcessID =100 THEN 0 ELSE D.DiscountDtl END ) As DiscountDtl 
					FROM inv.tblStorageDocsDtl D
					WHERE ' + @StrWhere + '
					GROUP BY OrderAcntCode) a'
			SET @StrSelect2 = '
					INNER JOIN (
								SELECT OrderAcntCode,
									   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ') = 1 AND ProcessID = 100 THEN 0 ELSE (Discount + Discount2 + Discount3) END ) As Discount,
									   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ') = 1 AND ProcessID = 100 THEN 0 ELSE TaxOverWorthCost END ) As TaxOverWorthCost,
									   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ') = 1 AND ProcessID = 100 THEN 0 ELSE TollOverWorthCost END ) As TollOverWorthCost,
									   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ') = 1 AND ProcessID = 100 THEN 0 ELSE TransportationCost END ) As TransportationCost, 
									   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ') = 1 AND ProcessID = 100 THEN 0 ELSE AfterSaleDiscount END ) As AfterSaleDiscount, 
									   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ') = 1 AND ProcessID = 100 THEN 0 ELSE VisitorCost END ) As VisitorCost, 
									   Sum(CASE WHEN LTRIM(' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ') = 1 AND ProcessID = 100 THEN 0 ELSE VisitorCost2 END ) As VisitorCost2 
								FROM inv.tblStorageDocsHdr D													 
								WHERE  ' + @StrWhere + '														 
								GROUP BY OrderAcntCode) b ON a.OrderAcntCode = b.OrderAcntCode					 
					LEFT JOIN lyl.tblCustomerInfo CI ON CI.CustomerInfoID = a.OrderAcntCode						 
					LEFT JOIN lyl.tblCustomerInfoDtl CID ON CID.CustomerInfoID = a.OrderAcntCode AND CID.LanguageID=' + LTrim(RTrim(STR(@LangID))) + '	
					LEFT JOIN (																					 
								SELECT OrderAcntCode, 															 
									   Sum(CASE WHEN (ProcessID = 90 AND (D.GoodsQuantity * D.GoodsPrice) <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN (D.GoodsQuantity * D.GoodsPrice) ELSE 0 END ) As RetSaleAmount,
									   Sum(CASE WHEN (ProcessID = 90 AND D.DiscountDtl <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN D.DiscountDtl ELSE 0 END ) As RetDiscountDtl 	   
								FROM inv.tblStorageDocsDtl D													 
								WHERE ProcessID = 100 															 
								  AND ProcessNo in ( ' + @ProcessNo + ') ' + @StrWhere2 + '						 
								GROUP BY OrderAcntCode) c ON a.OrderAcntCode = c.OrderAcntCode					 
					LEFT JOIN (																					 
								SELECT OrderAcntCode,															 
									   Sum(CASE WHEN (ProcessID = 90 AND (Discount + Discount2 + Discount3) <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN (Discount + Discount2 + Discount3) ELSE 0 END ) As RetDiscount,
									   Sum(CASE WHEN (ProcessID = 90 AND TaxOverWorthCost <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN TaxOverWorthCost ELSE 0 END ) As RetTaxOverWorthCost,
									   Sum(CASE WHEN (ProcessID = 90 AND TollOverWorthCost <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN TollOverWorthCost ELSE 0 END ) As RetTollOverWorthCost, 	   
									   Sum(CASE WHEN (ProcessID = 90 AND TransportationCost <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN TransportationCost ELSE 0 END ) As RetTransportationCost, 	
									   Sum(CASE WHEN (ProcessID = 90 AND VisitorCost <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN VisitorCost ELSE 0 END ) As RetVisitorCost, 	
									   Sum(CASE WHEN (ProcessID = 90 AND VisitorCost2 <> 0) OR (' + LTrim(RTrim(STR(@chkShowNoSaleRecords))) + ' = 1 AND ProcessID = 100) THEN VisitorCost2 ELSE 0 END ) As RetVisitorCost2	
								FROM inv.tblStorageDocsHdr D
								WHERE ProcessID = 100 
								  AND ProcessNo in ( ' + @ProcessNo + ') ' + @StrWhere2 + '
					GROUP BY OrderAcntCode) d ON a.OrderAcntCode = d.OrderAcntCode
					ORDER BY a.OrderAcntCode
								'
	END
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	PRINT @StrSelect1;
	PRINT @StrSelect2;

	SET @StrSelect1 = @StrSelect1 + @StrSelect2

	EXEC sp_executesql @StrSelect1;
	------------------------------------------------------------

END
GO
