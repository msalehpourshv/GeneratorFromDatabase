USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Jabbari
-- Create date   : 1396/03/01
-- Viewed By	 : 
-- Last Modified : 1396/03/04 - Hamid
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[SpShowPreSalesList]
	@ProcessID		Int 	 	 = 240,
	@ProcessNo		Int 	 	 = Null,
	@FiscalYear		Int 	 	 = Null,
	@SerialNo		Int 	 	 = Null,
	@FiscalYearTo	Int 	 	 = Null,
	@SerialNoTo		Int 	 	 = Null,
	@DateFr			Char(10) 	 = NULL,
	@DateTo			Char(10) 	 = NULL,	
	@SelectedAcnt1	Int 		 = 0, 
	@SelectedAcnt2	Int 		 = 0, 
	@SelectedAcnt3	Int 		 = 0, 
	@SelectedAcnt4	Int 		 = 0,
	@SelectedVisitorAcnt1	Int 		 = 0, 
	@SelectedVisitorAcnt2	Int 		 = 0, 
	@SelectedVisitorAcnt3	Int 		 = 0, 
	@SelectedVisitorAcnt4	Int 		 = 0,
	@StoreID		Varchar(20)  = NULL,
	@ConfirmState	Smallint 	 = 0,
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION            
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StrSelect	NVarChar(Max);
	DECLARE @StrWhere	NVarChar(Max);
	
	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
	DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
	Declare @DocDesc		NVarChar(1000) = ''
	DECLARE	@Sgn			Int;
	DECLARE	@DocStepState	Int;
	-- =============================
	IF (@FiscalYear  Is Null)	SET @SerialNo	  = Null;
	IF (@FiscalYearTo  Is Null)	SET @SerialNoTo	  = Null;
	IF (@SerialNo	   Is Null)	SET @FiscalYear = Null;
	IF (@SerialNoTo	   Is Null)	SET @FiscalYearTo = Null;
		
	IF (@SelectedAcnt1	 	 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	 	 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	 	 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	 	 Is Null)	SET @SelectedAcnt4 = 0;

	IF (@SelectedVisitorAcnt1	 	 Is Null)	SET @SelectedVisitorAcnt1 = 0;
	IF (@SelectedVisitorAcnt2	 	 Is Null)	SET @SelectedVisitorAcnt2 = 0;
	IF (@SelectedVisitorAcnt3	 	 Is Null)	SET @SelectedVisitorAcnt3 = 0;
	IF (@SelectedVisitorAcnt4	 	 Is Null)	SET @SelectedVisitorAcnt4 = 0;

	SET @LangID		  = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	  = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	  = pub.funSplitString(@RepInfo, '@', 3);
	SET @DocDesc	  = pub.funSplitString(@RepInfo, '@', 6);
	SET @Sgn		  = pub.funSplitString(@RepInfo, '@', 7);
	SET @DocStepState = pub.funSplitString(@RepInfo, '@', 8);
				
	-- ============================= SELECT
	SET @StrWhere  = 'H.ProcessID = ' + LTRIM(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTRIM(RTrim(Str(@ProcessNo)))
	if (@DocDesc <> '' and @DocDesc	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDesc like N''%' + @DocDesc + '%'' OR H.DocDesc2 like N''%' + @DocDesc + '%'')'

	If (@FiscalYear	Is Not Null) And (@FiscalYear <> '')
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYear)) + ' OR 
		(H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '

	If (@FiscalYearTo Is Not Null) And (@FiscalYearTo <> '')
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '
		
	If (@DateFr Is Not Null) And (@DateFr <> '') And (@DateFr <> '0')
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DateFr + ''')'
	If (@DateTo Is Not Null) And (@DateTo <> '') And (@DateTo <> '0')
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DateTo + ''')'
	if @Sgn=0
		SET @StrWhere = @StrWhere + ' AND (SgnSN1=0 and 	SgnSN2=0 and 	SgnSN3=0 and 	SgnSN4=0 and 	SgnSN5=0 )'
	if @Sgn=1
		SET @StrWhere = @StrWhere + ' AND SgnSN1>0'
	if @Sgn=2
		SET @StrWhere = @StrWhere + ' AND SgnSN2>0 '
	if @Sgn=3
		SET @StrWhere = @StrWhere + ' AND SgnSN3>0 '
	if @Sgn=4
		SET @StrWhere = @StrWhere + ' AND SgnSN4>0 '
	if @Sgn=5
		SET @StrWhere = @StrWhere + ' AND SgnSN5>0 '
	
	IF @DocStepState = 1
		SET @StrWhere = @StrWhere + ''
	IF @DocStepState = 2
		SET @StrWhere = @StrWhere + ' AND H.DocStep in (0,1) '
	IF @DocStepState = 3
		SET @StrWhere = @StrWhere + ' AND H.DocStep = 2 '

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	If (@SelectedVisitorAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitorAcnt1, 'H.VisitorAcntCode')
	If (@SelectedVisitorAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitorAcnt2, 'H.VisitorAcntCode')
	If (@SelectedVisitorAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitorAcnt3, 'H.VisitorAcntCode')
	If (@SelectedVisitorAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitorAcnt4, 'H.VisitorAcntCode')

					
	If (@StoreID Is Not Null) And (@StoreID <> '') And (@StoreID <> '0')
		SET @StrWhere = @StrWhere + ' AND (H.StoreID = ''' + @StoreID + ''')'
						
	If (@ConfirmState Is Not Null) And (@ConfirmState > 1) And (@ConfirmState < 4)
		SET @StrWhere = @StrWhere + ' AND H.ConfirmState = ' + LTRIM(RTrim(Str(@ConfirmState))) + ' 
									  AND ((H.SaleSerialNo = ''0'' OR H.SaleSerialNo = '''') 
									  AND  (H.ProdSerialNo = ''0'' OR H.ProdSerialNo = ''''))'
	Else If (@ConfirmState Is Not Null) And  (@ConfirmState = 4)
		SET @StrWhere = @StrWhere + ' AND H.SaleSerialNo <> ''0'' AND H.SaleSerialNo <> '''''
	Else If (@ConfirmState Is Not Null) And  (@ConfirmState = 5)		
		SET @StrWhere = @StrWhere + ' AND H.ProdSerialNo <> ''0'' AND H.ProdSerialNo <> '''''
	Else If (@ConfirmState Is Not Null) And (@ConfirmState = 0) 
		SET @StrWhere = @StrWhere + ' AND H.ConfirmState = ''0'' and H.VchNo=0  '
	Else If (@ConfirmState Is Not Null) And (@ConfirmState =1) 
		SET @StrWhere = @StrWhere + ' AND (H.ConfirmState <= ''1''  or H.VchNo>0 )'
	Else If (@ConfirmState Is Not Null) And (@ConfirmState =7) 
		SET @StrWhere = @StrWhere + ' AND (H.ConfirmState = ''7''  )'			
	-- ============================= SELECT
	SET @StrSelect = '
	SELECT  Distinct   *
	FROM
	(	
		SELECT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo
			,LTrim(RTrim(Str(H.FiscalYear))) + ''/'' + LTrim(RTrim(Str(H.SerialNo))) FiscalSerial 
			,IsNull(stuff((select '''', '''',  ''   ''+IsNull(LTrim(RTrim(Str(Sale.FiscalYear))) + ''/'' + LTrim(RTrim(Str(Sale.SerialNo))), '''')  
			From inv.tblStorageDocsHdr Sale
			Where ProcessID = 90 And BaseProcessID = 240 
				and Sale.BaseProcessID = H.ProcessID And Sale.BaseProcessNo = H.ProcessNo 
				And Sale.BaseFiscalYear = H.FiscalYear And Sale.BaseSerialNo = H.SerialNo
			for xml path('''')		),1,1,''''),'''')  SaleSerialNo
			,IsNull(LTrim(RTrim(Str(Prod.FiscalYear))) + ''/'' + LTrim(RTrim(Str(Prod.SerialNo))), '''') ProdSerialNo
			,H.AcntCode, pub.GetCodeName(H.AcntCode, 1) AS AcntName
			,H.VisitorAcntCode, pub.GetCodeName(H.VisitorAcntCode, 1) AS VisitorAcntName, H.DocDate, H.StoreID, S1.StoreName
			,IsNull(SUM(D.SubUnitQuantity), 0) Quantity,IsNull(H.Discount, 0) +IsNull(H.Discount2, 0) +IsNull(H.TotalLineDiscount, 0) Discount,IsNull(H.EarnestMoney, 0) EarnestMoney
			,H.Amount ,H.Price, IsNull(Max(D.DocRowNo), 0) RowCounts
			,Case When (H.ConfirmState = 0  and H.VchNo=0 )Then ''عادي'' 
					When (H.ConfirmState = 1 or H.VchNo>0) And IsNull(Prod.SerialNo,0) = 0 And IsNull(Sale.SerialNo,0) = 0 Then ''تاييد شده''
					When H.ConfirmState = 2 And IsNull(Prod.SerialNo,0) = 0 And IsNull(Sale.SerialNo,0) = 0 Then ''تاييد نشده(ابطال)'' 
					When H.ConfirmState = 3 And IsNull(Prod.SerialNo,0) = 0 And IsNull(Sale.SerialNo,0) = 0 Then ''عدم تاييد (اتوماتيک)'' 
					When IsNull(Sale.SerialNo,0) > 0 Then ''فروش'' When IsNull(Prod.SerialNo,0) > 0 Then ''سفارش تولید'' End ConfirmStateStr,
			        ISNULL(RSD.DescRetSaleName,'''') DescRetSaleName,
					H.ConfirmState, H.DocDesc,H.DocDesc2,H.VchNo,H.SgnSN1,	H.SgnSN2	,H.SgnSN3	,H.SgnSN4	,H.SgnSN5
						,pub.GetUserName(H.SessionNo) AS UserName, H.DocStep
		FROM inv.tblPreSaleHdr H
		LEFT JOIN  inv.tblPreSaleDtl D ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
											H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
		LEFT JOIN  sal.tblDescRetSaleDtl RSD ON RSD.DescRetSaleID=H.DescRetSaleID
		INNER JOIN inv.tblStoresDtl S1 ON H.StoreID = S1.StoreID And S1.LanguageID = ' + LTrim(RTrim(@LangID)) + '
		LEFT JOIN  -- Sale
		(
			Select * 
			From inv.tblStorageDocsHdr
			Where ProcessID = 90 And BaseProcessID = 240 
		) Sale ON Sale.BaseProcessID = H.ProcessID And Sale.BaseProcessNo = H.ProcessNo And 
				  Sale.BaseFiscalYear = H.FiscalYear And Sale.BaseSerialNo = H.SerialNo
		LEFT JOIN  -- Produce
		(
			Select * 
			From pln.tblProduceOrderHdr
			Where ProcessID = 600 And BaseProcessID = 240 
		) Prod ON Prod.BaseProcessID = H.ProcessID And Prod.BaseProcessNo = H.ProcessNo And 
				  Prod.BaseFiscalYear = H.FiscalYear And Prod.BaseSerialNo = H.SerialNo
				  			  
		GROUP BY H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo,H.DocDesc,H.DocDesc2, Sale.FiscalYear, Sale.SerialNo, Prod.FiscalYear, Prod.SerialNo, 
				 H.ConfirmState, H.AcntCode, H.VisitorAcntCode, H.DocDate, H.StoreID, S1.StoreName,H.Amount,H.Price , H.TaxOverWorthCost, H.TollOverWorthCost, 
				 H.Discount, H.Discount2,H.VchNo,H.TotalLineDiscount,H.EarnestMoney,H.SgnSN1,	H.SgnSN2	,H.SgnSN3	,H.SgnSN4	,H.SgnSN5,
				 H.SessionNo,RSD.DescRetSaleName, H.DocStep
		) H	
	WHERE ' + @StrWhere + '
	ORDER BY H.FiscalYear, H.SerialNo'
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;	
 
END
GO
