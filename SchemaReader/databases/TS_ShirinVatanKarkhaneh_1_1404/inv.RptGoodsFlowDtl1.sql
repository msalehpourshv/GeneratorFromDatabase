USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 95/08/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
--  [inv].[RptGoodsFlow] Null,Null,Null,Null,Null,Null,Null,Null,Null,'','','11111'
Create PROCEDURE [inv].[RptGoodsFlowDtl1]
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111', -- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE 
	@Acnt1    VarChar(20) = Null, 
	@Acnt2    VarChar(20) = Null, 
	@Acnt3    VarChar(20) = Null, 
	@Acnt4    VarChar(20) = Null, 
	@StoreID		Int = 0, 
	@GoodsID		Int = 0, 
	@DocDateFrom	Char(10) = '',
	@DocDateTo		Char(10) = '',
	@BatchNo		varchar(20) = '', 
	@DriverID		VarChar(20) = Null, 
	@FarmerID		VarChar(20) = Null, 
	@LocationID     VarChar(20) = Null ,
	@BaseSendID		VarChar(20) = Null ,
	@TransporterID2 VarChar(20) = Null, 
	@ReciverID		VarChar(20) = Null, 
	@SortOrder		Int = 0
                
DECLARE	@SortByName		Bit; -- مرتب بر اساس اسامی حسابها باشد یا کد حسابها؟
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@QtyType		Int;
DECLARE	@ProcessNo		Int;
DECLARE	@FromBaseSerialNo		Int;
DECLARE	@ToBaseSerialNo		Int;
DECLARE	@FromBaseFiscalYear		Int;
DECLARE	@ToBaseFiscalYear		Int;
DECLARE	@FromSerialNo		Int;
DECLARE	@ToSerialNo		Int;
DECLARE	@ProcessID50		bit;
DECLARE	@ProcessID190		bit;
DECLARE	@ProcessID192		bit;
DECLARE	@ProcessID193		bit;

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrHaving		NVarChar(1000);

DECLARE @ReciveAcnt1    VarChar(20) 
DECLARE @ReciveAcnt2    VarChar(20) 
DECLARE @ReciveAcnt3    VarChar(20) 
DECLARE @ReciveAcnt4    VarChar(20) 

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

	SET @QtyType		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @ProcessNo		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @ReciveAcnt1		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @ReciveAcnt2		= pub.funSplitString(@ExtraParams, '@', 4);
	SET @ReciveAcnt3		= pub.funSplitString(@ExtraParams, '@', 5);
	SET @ReciveAcnt4		= pub.funSplitString(@ExtraParams, '@', 6);
	SET @ProcessID190		= pub.funSplitString(@ExtraParams, '@', 7);
	SET @ProcessID192		= pub.funSplitString(@ExtraParams, '@', 8);
	SET @ProcessID193		= pub.funSplitString(@ExtraParams, '@', 9);
	SET @FromSerialNo		= pub.funSplitString(@ExtraParams, '@', 10);
	SET @ToSerialNo		= pub.funSplitString(@ExtraParams, '@', 11);
	--------------------------------------------------------
	SET @Acnt1			= pub.funSplitString(@ExtraParams, '@', 12);
	SET @Acnt2			= pub.funSplitString(@ExtraParams, '@', 13);
	SET @Acnt3			= pub.funSplitString(@ExtraParams, '@', 14);
	SET @Acnt4			= pub.funSplitString(@ExtraParams, '@', 15);
	SET @StoreID		= pub.funSplitString(@ExtraParams, '@', 16);
	SET @GoodsID		= pub.funSplitString(@ExtraParams, '@', 17);
	SET @BatchNo		= pub.funSplitString(@ExtraParams, '@', 18);
	SET @DocDateFrom	= pub.funSplitString(@ExtraParams, '@', 19);
	SET @DocDateTo		= pub.funSplitString(@ExtraParams, '@', 20);
	SET @DriverID		= pub.funSplitString(@ExtraParams, '@', 21);
	SET @FarmerID		= pub.funSplitString(@ExtraParams, '@', 22);
	SET @LocationID		= pub.funSplitString(@ExtraParams, '@', 23);
	SET @ReciverID		= pub.funSplitString(@ExtraParams, '@', 24);
	SET @SortOrder		= pub.funSplitString(@ExtraParams, '@', 25);
	SET @FromBaseSerialNo		= pub.funSplitString(@ExtraParams, '@', 26);
	SET @FromBaseFiscalYear		= pub.funSplitString(@ExtraParams, '@', 27);
	SET @ToBaseSerialNo		= pub.funSplitString(@ExtraParams, '@', 28);
	SET @ToBaseFiscalYear	= pub.funSplitString(@ExtraParams, '@', 29);
	SET @BaseSendID			= pub.funSplitString(@ExtraParams, '@', 30);
	SET @TransporterID2		= pub.funSplitString(@ExtraParams, '@', 31);
	SET @ProcessID50		= pub.funSplitString(@ExtraParams, '@', 32);
	
	 
	-------------------------------------------------------------------------------------
	-- where ----------------------------------------------------------------------------
	SET @StrWhere = ' and d.ProcessID in(50,192,193,260,265) '--' LanguageID = ' + @LangID + ' '

	IF (@Acnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt1, 'd.AcntCode')
	IF (@Acnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt2, 'd.AcntCode')
	IF (@Acnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt3, 'd.AcntCode')
	IF (@Acnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Acnt4, 'd.AcntCode')

	IF (@BatchNo <> '' AND @BatchNo is not NULL )
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @BatchNo, 'd.BatchNo')
	IF (@StoreID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'd.StoreID')
	IF (@GoodsID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'd.GoodsID')

	If (@DocDateTo Is Not Null  and LTRIM(RTRIM(@DocDateTo))<>'') 
			SET @StrWhere = @StrWhere + ' AND (d.DocDate <= ''' + @DocDateTo + ''')'
	if (@DocDateFrom Is Not Null  and LTRIM(RTRIM(@DocDateFrom))<>'')
			SET @StrWhere = @StrWhere + ' AND (d.DocDate >= ''' + @DocDateFrom + ''')'
	IF (@ProcessNo> 0 AND @ProcessNo is not NULL)
			SET @StrWhere = @StrWhere + ' AND (d.ProcessNo = ' + str(@ProcessNo) + ')'

	If (@DocDateTo Is Not Null and LTRIM(RTRIM(@DocDateTo))<>'') 
			SET @StrWhere = @StrWhere + ' AND (d.DocDate <= ''' + @DocDateTo + ''')'
	if (@DocDateFrom Is Not Null and LTRIM(RTRIM(@DocDateFrom))<>'')
			SET @StrWhere = @StrWhere + ' AND (d.DocDate >= ''' + @DocDateFrom + ''')'

	if (@DriverID Is Not Null and LTRIM(RTRIM(@DriverID))<>'')
			SET @StrWhere = @StrWhere + ' AND (h.DriverID = ''' + @DriverID + ''')'
	if (@FarmerID Is Not Null and LTRIM(RTRIM(@FarmerID))<>'')
			SET @StrWhere = @StrWhere + ' AND (h.FarmerID = ''' + @FarmerID + ''')'
	if (@LocationID Is Not Null and LTRIM(RTRIM(@LocationID))<>'')
			SET @StrWhere = @StrWhere + ' AND (h.LocationID = ''' + @LocationID + ''')'
	if (@BaseSendID Is Not Null and LTRIM(RTRIM(@BaseSendID))<>'')
			SET @StrWhere = @StrWhere + ' AND (h.BaseSendID = ''' + @BaseSendID + ''')'
	if (@ReciverID Is Not Null and LTRIM(RTRIM(@ReciverID))<>'')
			SET @StrWhere = @StrWhere + ' AND (d.ReciverID = ''' + @ReciverID + ''')'

	if (@TransporterID2 Is Not Null and LTRIM(RTRIM(@TransporterID2))<>'')
			SET @StrWhere = @StrWhere + ' AND (h.TransporterID2 = ''' + @TransporterID2 + ''')'
	
	if @FromSerialNo	<>0
			SET @StrWhere = @StrWhere + ' and h.SerialNo>= ' + str( @FromSerialNo)
	if @ToSerialNo	<>0
			SET @StrWhere = @StrWhere + ' and  h.SerialNo<= ' + Str(@ToSerialNo)

if @FromBaseSerialNo	<>0
			SET @StrWhere = @StrWhere + ' and h.BaseSerialNo>= ' + str( @FromBaseSerialNo)
if @FromBaseFiscalYear	<>0
			SET @StrWhere = @StrWhere + ' and h.BaseFiscalYear>= ' + str( @FromBaseFiscalYear)
	if @ToBaseSerialNo	<>0
			SET @StrWhere = @StrWhere + ' and  h.BaseSerialNo<= ' + Str(@ToBaseSerialNo)
	if @ToBaseFiscalYear	<>0
			SET @StrWhere = @StrWhere + ' and  h.BaseFiscalYear<= ' + Str(@ToBaseFiscalYear)



	
	IF (@ProcessID50= 1 or @ProcessID190= 1 or @ProcessID192= 1 or @ProcessID193= 1 )
	begin
	
	SET @StrWhere = @StrWhere + ' and ( 1=0 '
		IF (@ProcessID50=1) 
				SET @StrWhere = @StrWhere + ' or (d.ProcessID in(50))'
		IF (@ProcessID190=1) 
				SET @StrWhere = @StrWhere + ' or (d.ProcessID in(190,191))'
		IF (@ProcessID192=1) 
				SET @StrWhere = @StrWhere + ' or (d.ProcessID in(192,265))'
		IF (@ProcessID193=1) 
				SET @StrWhere = @StrWhere + ' or (d.ProcessID in(193,260))'
	SET @StrWhere = @StrWhere + ' ) '
		
	end 
	

	-------------------------------------------------------------------------------------
	-- select ---------------------------------------------------------------------------
	SET @StrSelect = '
Select d.*,DriverTel, g.ReciverID, ReciverName, ReciverAddress,VehicleNo, drd.DriverID, FirstName, LastName
, pub.funGetGoodsUnitName(d.GoodsID,'+ str(@LangID) +') as UnitName,U.SubUnitID SubUnitID2
, inv.funGetUnitName(isnull(U.SubUnitID,'''') ,'+ str(@LangID) +') as UnitName2
,pub.funGetGoodsName(d.GoodsID,'+ str(@LangID) +')  AS GoodsName 
,pub.GetCodeName(d.AcntCode,'+ str(@LangID) +') AS AcntName 
 ,g.ReciverName
 ,f.FarmerName,l.LocationName
 ,h.BaseSerialNo BaseSerialNoH, h.BaseFiscalYear BaseFiscalYearH
 ,ltrim(rtrim(str(h.BaseFiscalYear))) +''/''+ltrim(rtrim(str(h.BaseSerialNo))) BaseFiscalYearSerialNoH
 ,TrukNo,TransporterID2,CarNo,  d.SubUnitQuantity / (Case When d.VirtualQuantity=0 Then 1 Else d.VirtualQuantity End) Averge
 ,ST.StoreName,ST.Address,h.LoadWeight  HLoadWeight
 , h.BaseSendID, BS.BaseSendName
 From inv.tblStorageDocsDtl d inner join	inv.tblStorageDocsHdr h
 on d.ProcessID= h.ProcessID  and d.ProcessNo= h.ProcessNo  and d.FiscalYear= h.FiscalYear  and d.SerialNo= h.SerialNo 
 left join  pub.tblDrivers drh on drh.DriverID=h.DriverID
 left join  pub.tblDriversDtl drd on drd.DriverID=h.DriverID and LanguageID='+ str(@LangID) +'
 left join  inv.tblGoodsReciverDtl g on g.ReciverID=d.ReciverID and g.LanguageID='+ str(@LangID) +'
 left join  inv.tblFarmersDtl f on f.FarmerID=h.FarmerID and f.LanguageID='+ str(@LangID) +'
 left join    pub.tblLocationsDtl l on l.LocationID=h.LocationID and l.LanguageID='+ str(@LangID) +'
 left join  inv.tblStoresDtl ST on ST.StoreID=d.StoreID and ST.LanguageID='+ str(@LangID) +'
 left join   inv.tblSubUnitsDtl  U on U.GoodsID=d.GoodsID and  U.ShowInInvoice=1
 LEFT JOIN sal.tblBaseSendDtl BS ON BS.BaseSendID = h.BaseSendID    
 where 1=1 
 '+ @StrWhere
 
	If (@SortOrder = 1)
		SET @StrSelect = @StrSelect + '		ORDER By d.SerialNo '
	Else
		SET @StrSelect = @StrSelect + '		ORDER By d.DocDate '
	
	-------------------------------------------------------------------------------------
	-- run ------------------------------------------------------------------------------
	Print @StrSelect;	
	Exec sp_executesql @StrSelect;
	-------------------------------------------------------------------------------------
END
GO
