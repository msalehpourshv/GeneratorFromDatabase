USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1399/10/08
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE trn.RptDispatch
	@CallType			Int = 0,
	@ExtraParam			NVarChar(100) = '1@1@1',
	@RepOptions			NVarChar(100) = '1@1', -- bit array (showQty-showPrc)
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect			NVarChar(max);
Declare @StrWhere			NVarChar(2048);
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int; 
DECLARE @DocDate			Char(10);
DECLARE @HasSgn1	bit;
DECLARE @HasSgn2	bit;
DECLARE @HasSgn3	bit;
DECLARE @HasSgn4	bit;
DECLARE @HasSgn5	bit;
DECLARE @NotSgn1	bit;
DECLARE @NotSgn2	bit;
DECLARE @NotSgn3	bit;
DECLARE @NotSgn4	bit;
DECLARE @NotSgn5	bit;
DECLARE @HideTax	char(1);

DECLARE @Sgn1	VarChar(10);
DECLARE @Sgn2	VarChar(10);
DECLARE @Sgn3	VarChar(10);
DECLARE @Sgn4	VarChar(10);
DECLARE @Sgn5	VarChar(10);
DECLARE @db_0000   nvarchar(50)
DECLARE @Receiver TINYINT
DECLARE @NotDeliveredDispatch bit;
DECLARE @DeliveredDispatch bit;
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	
		-- Init -------------------------------------------------
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)		SET @RepOptions = '11';
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @NotDeliveredDispatch  = pub.funSplitString(@RepOptions, '@', 1);
	SET @DeliveredDispatch  = pub.funSplitString(@RepOptions, '@', 2);
	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	SET @Receiver = 0

	select @LangID=isnull(@LangID,1)
	DECLARE @PartNumber TINYINT
	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)

DECLARE	
		@SerialNoFr			Int ,
		@SerialNoTo			Int ,
		@DocDateFr			Char(10) ,
		@DocDateTo			Char(10) ,
		@CommissionCode  	Varchar(20),
		@StoreID			Varchar(20),
		@GoodsID			Varchar(20),
		@VisitorCode		Varchar(20),
		@CustomerCode		Varchar(20),
		@DestLocationID		Varchar(20),
		@DriverID			Varchar(20),
		@RefrigeratorID		Varchar(20),
		@SourceLocationID	Varchar(20),
		@TransportationKind	Varchar(20),
		@VehicleID			Varchar(20),
		@Quantity			float,
		@WaybillNoFrom		NVARCHAR(30),
		@WaybillNoTo		NVARCHAR(30),
		@DispatchInvoice	tinyint
		

	SET @SerialNoFr			    = LTrim(pub.funSplitString(@ExtraParam, '@', 1)); 
	SET @SerialNoTo			    = LTrim(pub.funSplitString(@ExtraParam, '@', 2)); 
	SET @DocDateFr				= LTrim(pub.funSplitString(@ExtraParam, '@', 3)); 
	SET @DocDateTo		    	= LTrim(pub.funSplitString(@ExtraParam, '@', 4));
	SET @WaybillNoFrom		    = LTrim(pub.funSplitString(@ExtraParam, '@', 5)); 
	SET @Quantity			    = LTrim(pub.funSplitString(@ExtraParam, '@', 6)); 
	SET @GoodsID  				= LTrim(pub.funSplitString(@ExtraParam, '@', 7)); 
	SET @CustomerCode  			= LTrim(pub.funSplitString(@ExtraParam, '@', 8)); 
	SET @CommissionCode 		= LTrim(pub.funSplitString(@ExtraParam, '@', 9));
	SET @DestLocationID			= LTrim(pub.funSplitString(@ExtraParam, '@', 10));
	SET @DriverID				= LTrim(pub.funSplitString(@ExtraParam, '@', 11)); 
	SET @RefrigeratorID		    = LTrim(pub.funSplitString(@ExtraParam, '@', 12)); 
	SET @SourceLocationID		= LTrim(pub.funSplitString(@ExtraParam, '@', 13));
	SET @TransportationKind		= LTrim(pub.funSplitString(@ExtraParam, '@', 14));
	SET @VehicleID				= LTrim(pub.funSplitString(@ExtraParam, '@', 15));
	SET @HasSgn1				= LTrim(pub.funSplitString(@ExtraParam, '@', 16));
	SET @HasSgn2				= LTrim(pub.funSplitString(@ExtraParam, '@', 17));
	SET @HasSgn3				= LTrim(pub.funSplitString(@ExtraParam, '@', 18));
	SET @HasSgn4				= LTrim(pub.funSplitString(@ExtraParam, '@', 19));
	SET @HasSgn5				= LTrim(pub.funSplitString(@ExtraParam, '@', 20));
	SET @NotSgn1				= LTrim(pub.funSplitString(@ExtraParam, '@', 21));
	SET @NotSgn2				= LTrim(pub.funSplitString(@ExtraParam, '@', 22));
	SET @NotSgn3				= LTrim(pub.funSplitString(@ExtraParam, '@', 23));
	SET @NotSgn4				= LTrim(pub.funSplitString(@ExtraParam, '@', 24));
	SET @NotSgn5				= LTrim(pub.funSplitString(@ExtraParam, '@', 25));
	SET @Sgn1					= LTrim(pub.funSplitString(@ExtraParam, '@', 26));	
	SET @Sgn2					= LTrim(pub.funSplitString(@ExtraParam, '@', 27));	
	SET @Sgn3					= LTrim(pub.funSplitString(@ExtraParam, '@', 28));	
	SET @Sgn4					= LTrim(pub.funSplitString(@ExtraParam, '@', 29));	
	SET @Sgn5					= LTrim(pub.funSplitString(@ExtraParam, '@', 30));	
	SET @VisitorCode			= LTrim(pub.funSplitString(@ExtraParam, '@', 31));	
	SET @DispatchInvoice		= LTrim(pub.funSplitString(@ExtraParam, '@', 32));	
	SET @HideTax				= LTrim(pub.funSplitString(@ExtraParam, '@', 33));	
	SET @Receiver				= LTrim(pub.funSplitString(@ExtraParam, '@', 34));	
	SET @WaybillNoTo			= LTrim(pub.funSplitString(@ExtraParam, '@', 35));	
	
	update trn.tblDispatchInvoiceDtl
	set WaybillNo = b.WaybillNo
	from trn.tblDispatchInvoiceDtl a
	inner join trn.tblDispatchHdr b
	on a.BaseProcessID=b.ProcessID and a.BaseProcessNo=b.ProcessNo  and a.BaseFiscalYear=b.FiscalYear   and a.BaseSerialNo=b.SerialNo
	where b.WaybillNo <>'' and a.WaybillNo <>b.WaybillNo

	set @StrWhere='1=1'
	-- Acnt Filter 
	IF (@SerialNoFr <>0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo >=' + LTrim(Str(@SerialNoFr)) + ') '	
	IF (@SerialNoTo  <>0)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'		
	If  LTRIM(rtrim(@DocDateFr ))<>''
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	If  LTRIM(rtrim(@DocDateTo ))<>''
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	If (@CommissionCode Is Not Null  and  LTRIM(rtrim(@CommissionCode ))<>'')
		SET @StrWhere = @StrWhere + ' AND (H.CommissionCode = ''' + @CommissionCode + ''')'		
		
	If (@CustomerCode Is Not Null  and  LTRIM(rtrim(@CustomerCode ))<>'')
		SET @StrWhere = @StrWhere + ' AND (H.CustomerCode = ''' + @CustomerCode + ''')'
	
	IF (@GoodsID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @GoodsID, 'H.GoodsID')

	IF (@WaybillNoFrom > 0)
		SET @StrWhere = @StrWhere + ' AND WaybillNo >= '''+ @WaybillNoFrom +''''
	IF (@WaybillNoTo > 0)
		SET @StrWhere = @StrWhere + ' AND WaybillNo <= '''+ @WaybillNoTo +''''
	IF (@Quantity > 0)
		SET @StrWhere = @StrWhere + ' AND Quantity='+str( @Quantity)+''
 

	IF (@DestLocationID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DestLocationID, 'H.DestinationLocationID')
	IF (@DriverID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DriverID, 'H.DriverID')
	IF (@RefrigeratorID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @RefrigeratorID, 'H.RefrigeratorID')
	IF (@SourceLocationID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SourceLocationID, 'H.SourceLocationID')
	IF (@TransportationKind > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @TransportationKind, 'H.TransportationKindID')
	IF (@VehicleID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VehicleID, 'H.VehicleID')
	IF (@VisitorCode > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode, 'H.VisitorCode')

	IF @HasSgn1 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN1<>0 '
	IF @HasSgn2 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN2<>0 '
	IF @HasSgn3 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN3<>0 '
	IF @HasSgn4 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN4<>0 '
	IF @HasSgn5 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN5<>0 '

	IF @NotSgn1 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN1=0 '
	IF @NotSgn2 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN2=0 '
	IF @NotSgn3 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN3=0 '
	IF @NotSgn4 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN4=0 '
	IF @NotSgn5 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN5=0 '


	IF @Sgn1 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN1)=' + @Sgn1 + ' '
	
	IF @Sgn2 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN2)=' + @Sgn2 + ' '

	IF @Sgn3 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN3)=' + @Sgn3 + ' '

	IF @Sgn4 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN4)=' + @Sgn4 + ' '

	IF @Sgn5 <> '-1'
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN5)=' + @Sgn5 + ' '

	 IF @NotDeliveredDispatch='1' and @DeliveredDispatch='0' 
			Set @StrWhere = @StrWhere + ' And (select count(*) from trn.tblDispatchInvoiceDtl where BaseSerialNo=H.SerialNo and BaseFiscalYear=H.FiscalYear and BaseProcessID=H.ProcessID and BaseProcessNo=H.ProcessNo )=0 '

     IF @NotDeliveredDispatch='0' and @DeliveredDispatch='1' 
			Set @StrWhere = @StrWhere + ' And (select count(*) from trn.tblDispatchInvoiceDtl where BaseSerialNo=H.SerialNo and BaseFiscalYear=H.FiscalYear and BaseProcessID=H.ProcessID and BaseProcessNo=H.ProcessNo )>0 '
						
   
	DECLARE @strTableName as varchar(1000)
	DECLARE @strBaseDate as varchar(1000)
	SET @strTableName = 'trn.tblDispatchHdr'
	SET @strBaseDate = ','''' BaseDocDate '
	
	IF @DispatchInvoice<>2 AND (@Receiver > 0)
		SET @StrWhere = @StrWhere + ' AND H.Receiver='+str(@Receiver)+''
	
	IF @DispatchInvoice = 2
	BEGIN
		SET @strTableName = 'trn.tblDispatchInvoiceDtl'
		SET @strBaseDate = ',ISNULL((SELECT TOP 1 DocDate FROM trn.tblDispatchHdr a 
		                     WHERE a.ProcessID=H.BaseProcessID
							   AND a.ProcessNo=H.BaseProcessNo
							   AND a.FiscalYear=H.BaseFiscalYear
							   AND a.SerialNo=H.BaseSerialNo
							   ),'''') BaseDocDate '

	END	
	
	DECLARE @strAcntName As VarChar(100) = ''
	IF @DispatchInvoice = 2
		SET @strAcntName = '''''' 
	ELSE
		SET @strAcntName = '[acc].[funPartAcntName](H.AcntCode,'+str(@PartNumber) +')'

	Set @StrSelect = '
		select  
			H.*
			' + @strBaseDate + ',
			' + @strAcntName +' AcntName,
			[acc].[funGetAcntName](H.CustomerCode,'+str(@PartNumber) +', '+@LangID +') CustomerName,
			[acc].[funGetAcntName](H.CommissionCode,'+str(@PartNumber) +', '+@LangID +') CommissionName,
			[pub].[funGetGoodsName](H.GoodsID,1) GoodsName,
			pub.funGetLocationName(H.SourceLocationID,1) SourceLocationName, pub.funGetLocationName(H.DestinationLocationID,1) DestinationLocationName,
			D.FirstName FirstNameDtl, 
			D.LastName LastNameDtl,
			TransportationKindName,
			V.VehicleName,
			RefrigeratorName,
			A.EconomicalCode,
			AD.Address1, 
			AD.Address2, 
			AD.TableauText, 
			A.Tel,
			A.LocationID,
			A.ZipCode, 
			AD.FirstName, 
			AD.LastName,
			A.CompanyRegisterNo, 
			A.NationalIDNumber,  
			A.SalesRoomClass, 
			AD.OrganzationName,
			A.Mobile,
			A.SMSMobile,
			A.Sequence, 
			A.SaleCash, 
			AD.AsnafID, 
			A.OtherTels, 
			A.NationalIdentity, 
			A.Fax, 
			A.CustomerKindID,
			[pub].[funGetDriverName](H.DriverID, '+@LangID +') DriverName,
			' + @HideTax +' HideTax 
		 FROM ' + @strTableName + ' H
		 left join pub.tblDriversDtl D on D.DriverID=H.DriverID and D.LanguageID='+@LangID +'	
		 left join trn.tblTransportationKindDtl T on T.TransportationKindID=H.TransportationKindID and T.LanguageID='+@LangID +'	
		 left join trn.tblVehiclesDtl V on V.VehicleID=H.VehicleID and V.LanguageID='+@LangID +'	
		 left join trn.tblRefrigeratorDtl R on R.RefrigeratorID=H.RefrigeratorID and R.LanguageID='+@LangID +'	
		 left join acc.tblAcnt A on A.AcntCode=H.CustomerCode AND A.PartNumber= '+str(@PartNumber) +'	
		 left join acc.tblAcntDtl AD on AD.AcntCode=H.CustomerCode and R.LanguageID='+@LangID +' AND AD.PartNumber='+str(@PartNumber) +'	
		WHERE ' + @StrWhere

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	
End
GO
