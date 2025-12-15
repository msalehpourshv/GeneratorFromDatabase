USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1402/05/16
-- Viewed By	 : 
-- Last Modified : 
-- Description   : گزارش باشگاه مشتریان
-- =============================================
Create PROCEDURE sal.SPCustomerScoreReview
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin
DECLARE @StrSelect				NVarChar(max)
DECLARE @StrWhere				NVarChar(max)

DECLARE @FiscalYearFR		int
DECLARE @SerialNoFR			int
DECLARE @FiscalYearTO		int
DECLARE @SerialNoTO			int

DECLARE @FiscalYearRetFR		int
DECLARE @SerialNoRetFR			int
DECLARE @FiscalYearRetTO		int
DECLARE @SerialNoRetTO			int

DECLARE @FromDate as varchar(10)
DECLARE @ToDate as varchar(10)

DECLARE @Mobile as Varchar(50) 
DECLARE @dbname0000 as Varchar(50) 
DECLARE @dbname1400 as Varchar(50) 


set @dbname1400 =db_name()
set @dbname0000 =Substring(db_name(), 1, Len(db_name()) - 4) + '0000' 
 

 --select @dbname1400,@dbname0000
 --return 

if @CallType=1
	begin
		SET @Mobile				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @FromDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @ToDate				= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @FiscalYearFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @SerialNoFR			= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		SET @FiscalYearTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
		SET @SerialNoTO			= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @FiscalYearRetFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @SerialNoRetFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
		SET @FiscalYearRetTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
		SET @SerialNoRetTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 

		set @StrWhere=' 1=1 '
	if @Mobile<>''
		set @StrWhere =@StrWhere+ ' AND Mobile=''' + @Mobile +''''
	if @FromDate<>''
		set @StrWhere =@StrWhere+ ' AND DocDate>=''' + @FromDate+''''
	if @ToDate<>''
		set @StrWhere =@StrWhere+ ' AND DocDate<=''' + @ToDate+''''
 
		if @FiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND ProcessID=90 AND FiscalYear>=' +str(@FiscalYearFR)
		if @SerialNoFR>0
			set @StrWhere = @StrWhere+' AND ProcessID=90 AND SerialNo  >=' +str(@SerialNoFR)
		if @FiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND ProcessID=90 AND FiscalYear<=' +str(@FiscalYearTO)
		if @SerialNoTO>0
			set @StrWhere = @StrWhere+' AND ProcessID=90 AND SerialNo	<=' +str(@SerialNoTO)
	
		if @FiscalYearRetFR>0
			set @StrWhere =@StrWhere+ ' AND ProcessID=100 AND FiscalYear>=' +str(@FiscalYearRetFR)
		if @SerialNoRetFR>0
			set @StrWhere = @StrWhere+' AND ProcessID=100 AND SerialNo  >=' +str(@SerialNoRetFR)
		if @FiscalYearRetTO>0
			set @StrWhere =@StrWhere+ ' AND ProcessID=100 AND FiscalYear<=' +str(@FiscalYearRetTO)
		if @SerialNoRetTO>0
			set @StrWhere = @StrWhere+' AND ProcessID=100 AND SerialNo	<=' +str(@SerialNoRetTO)
	

		set @StrSelect = ' select *, Score-ScoreUsed ScoreRemain  from (
				select P.Mobile , isnull(FirstName, '''') +'' ''+isnull(LastName, '''') CustName,	 Sum( EnterKind	*(DiscountCust+	ScoreLaterCust	+DiscountPlan	+ScoreLaterPlan)) Score,Sum(EnterKind	*ScoreUsed) ScoreUsed
					 from '+ @dbname0000 +'.sal.tblClubPos P
					 left join lyl.tblCustomerInfoDtl C on C.CustomerInfoID=P.Mobile
					 where '+@StrWhere+'
					 group by P.Mobile , FirstName	,LastName ) a '
	
	Print @StrSelect	 
	EXEC sp_executesql @StrSelect;


end 

if @CallType=2
	begin
		SET @Mobile				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		
	set @StrWhere=' 1=1 '
	if @Mobile<>''
		set @StrWhere =@StrWhere+ ' AND Mobile=''' + @Mobile +''''
	
		set @StrSelect = ' 
			select * from (
				select FiscalYear, SerialNo, Case when ProcessID=90 then ''فروش'' else ''برگشت'' end SaleType, P.Mobile, DocDate 
					, isnull(FirstName, '''') +'' ''+isnull(LastName, '''') CustName
					, EnterKind	*(DiscountCust+	DiscountPlan	) Score
					, EnterKind	*(	ScoreLaterCust	+ScoreLaterPlan) ScoreLater
					, EnterKind	*ScoreUsed ScoreUsed, ValidDate
				from '+ @dbname0000 +'.sal.tblClubPos P
				left join lyl.tblCustomerInfoDtl C on C.CustomerInfoID=P.Mobile
				where '+@StrWhere+'
			) a '	
	Print @StrSelect	 
	EXEC sp_executesql @StrSelect;


end 


end 
GO
