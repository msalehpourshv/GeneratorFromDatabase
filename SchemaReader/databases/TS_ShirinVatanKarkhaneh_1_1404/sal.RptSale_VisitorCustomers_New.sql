USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED =====================
-- Author		 : TakroSystem\Hamid
-- Creation Date : 1393/04/21
-- Viewed By	 : 
-- Last Modified : 1393/05/12
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_VisitorCustomers_New]
	@FiscalYearFr		Int = NULL,
	@SerialNoFr			Int = NULL,
	@FiscalYearTo		Int = NULL,
	@SerialNoTo			Int = NULL,
	@FromDate			Char(10) = Null,
	@ToDate				Char(10) = Null,	
	@VistAcnt1			Int = 0,
	@VistAcnt2			Int = 0,
	@VistAcnt3			Int = 0,
	@VistAcnt4			Int = 0,
	@CustAcnt1			Int = 0,
	@CustAcnt2			Int = 0,
	@CustAcnt3			Int = 0,
	@CustAcnt4			Int = 0,
	@SelectedGoods		Int = 0,
	@CustomerKindID		Varchar(20) = Null,
	@ExtraParams		NVarChar(200) = '',
	@RepOptions			NVarChar(100) = '1',
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect		NVarChar(4000);
Declare @StrSelect2		NVarChar(4000);
Declare @StrFrom		NVarChar(2000);
Declare @StrWhere		NVarChar(2000);
Declare @StrWhere2		NVarChar(2000);

DECLARE @LangID				Char(1);
DECLARE @SessionNo			Int;
DECLARE @ReportID			Int;
DECLARE @LastVisitorPercent	Bit;

Begin --============== S T A R T  C O D E ===================================================
	set NOCOUNT ON;

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
	
	-- Init Variables ------------------------------------------
	IF (@RepInfo Is Null) SET @RepInfo = '1@1@1';
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '1000';
	
	IF (@VistAcnt1	Is Null)	SET @VistAcnt1 = 0;
	IF (@VistAcnt2	Is Null)	SET @VistAcnt2 = 0;
	IF (@VistAcnt3	Is Null)	SET @VistAcnt3 = 0;
	IF (@VistAcnt4	Is Null)	SET @VistAcnt4 = 0;
	IF (@CustAcnt1	Is Null)	SET @CustAcnt1 = 0;
	IF (@CustAcnt2	Is Null)	SET @CustAcnt2 = 0;
	IF (@CustAcnt3	Is Null)	SET @CustAcnt3 = 0;
	IF (@CustAcnt4	Is Null)	SET @CustAcnt4 = 0;
	
	--IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	--IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	--IF (@SerialNoFr Is Null)	SET @FiscalYearFr = Null;
	--IF (@SerialNoTo Is Null)	SET @FiscalYearTo = Null;
	
	SET @LastVisitorPercent = Substring(@RepOptions, 1, 1);
	
	-- ---------------------------------------------------------
	-- Where Clause --------------------------------------------
	SET @StrSelect = ''
	SET @StrSelect2 = ''
	SET @StrWhere = '(1 = 1)'
	SET @StrWhere2 = '(1 = 1)'
	
	-- VisitorAcntCode	
	IF (@VistAcnt1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt1, 'D.VisitorAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt1, 'CD.VisitorAcntCode')
	End
	IF (@VistAcnt2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt2, 'D.VisitorAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt2, 'CD.VisitorAcntCode')
	End
	IF (@VistAcnt3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt3, 'D.VisitorAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt3, 'CD.VisitorAcntCode')
	End
	IF (@VistAcnt4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt4, 'D.VisitorAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VistAcnt4, 'CD.VisitorAcntCode')
	End
	
	-- CustomerAcntCode	
	IF (@CustAcnt1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt1, 'D.CustomerAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt1, 'CD.CustomerAcntCode')
	End
	IF (@CustAcnt2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt2, 'D.CustomerAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt2, 'CD.CustomerAcntCode')
	End
	IF (@CustAcnt3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt3, 'D.CustomerAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt3, 'CD.CustomerAcntCode')
	End
	IF (@CustAcnt4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt4, 'D.CustomerAcntCode')
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustAcnt4, 'CD.CustomerAcntCode')
	End
	-------------------
	
	IF (@FromDate is not null) And (@ToDate is not null)
		SET @StrWhere = @StrWhere + ' AND (''' + LTrim(@FromDate) + ''' >= H.FromDate or ''' + LTrim(@FromDate) + ''' <= H.ToDate)'

	IF (@FromDate is not null) And (@ToDate is null)
		SET @StrWhere = @StrWhere + ' AND (''' + LTrim(@FromDate) + ''' <= H.ToDate)'

	IF (@FromDate is null) And (@ToDate is not null)
		SET @StrWhere = @StrWhere + ' AND (''' + LTrim(@ToDate) + ''' >= H.FromDate)'
		
	IF (@SelectedGoods > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		SET @StrWhere2 = @StrWhere2 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'CD.GoodsID') 
	End
		
	IF (@CustomerKindID is not null)
		SET @StrWhere = @StrWhere + ' AND (D.CustomerKindID=''' + LTrim(@CustomerKindID) + ''')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.SerialNo>=' + LTrim(Str(@SerialNoFr)) 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.SerialNo<=' + LTrim(Str(@SerialNoTo))
				
	IF (@LastVisitorPercent = 1)				
		SET @StrSelect2 = '	
		Inner Join 
		(
			Select CD.VisitorAcntCode, CD.CustomerAcntCode, CD.GoodsID, CD.CustomerKindID, MAX(CH.FromDate) As FromDate
			From sal.tblVisitorsCustomersDtl CD
			INNER JOIN sal.tblVisitorsCustomersHdr CH ON CH.VisitorAcntCode = CD.VisitorAcntCode
			Where ' + @StrWhere2 + '
			Group By CD.VisitorAcntCode, CD.CustomerAcntCode, CD.GoodsID, CD.CustomerKindID	
		) S2 ON S1.VisitorAcntCode = S2.VisitorAcntCode And S1.CustomerAcntCode = S2.CustomerAcntCode And 
		   S1.GoodsID = S2.GoodsID And S1.CustomerKindID = S2.CustomerKindID '
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	set @StrSelect = '
	Select S1.* From 
	(
		Select	D.*, H.FromDate, H.ToDate, C.CustomerKindName, 
				[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
				pub.GetCodeName(H.VisitorAcntCode, 1) VisitorAcntName,
				pub.GetCodeName(D.CustomerAcntCode, 1) CustomerAcntName,
				IsNull((
					Select Sum(Debit-Credit)
					From acc.tblVoucherDtl V
					Where (V.VchKind<>0) And (V.AcntCode=D.CustomerAcntCode)
				),0) CustomerRemain,
				IsNull((
					Select Sum(Debit-Credit)
					From acc.tblVoucherDtl V
					Where (V.VchKind<>0) And (V.AcntCode=H.VisitorAcntCode)
					),0) VisitorRemain
		From	sal.tblVisitorsCustomersHdr H
					INNER JOIN sal.tblVisitorsCustomersDtl D ON D.VisitorAcntCode = H.VisitorAcntCode and H.SerialNo=D.SerialNo
					left  join sal.tblCustomerKindsDtl C on C.CustomerKindID=D.CustomerKindID
					left  join inv.tblGoodsDtl G ON G.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
		Where ' + @StrWhere + '
		--Order By SerialNo, DocRowNo 
		) S1 ' + @StrSelect2
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
