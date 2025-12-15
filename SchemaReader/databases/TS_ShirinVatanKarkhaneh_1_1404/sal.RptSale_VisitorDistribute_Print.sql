USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid	
-- Create date   : 1393/05/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_VisitorDistribute_Print]
	@PartNo			Int = 1,
	@VisitorCode1	Int = 0,
	@VisitorCode2	Int = 0,
	@VisitorCode3	Int = 0,
	@VisitorCode4	Int = 0,
	@CustomerCode1	Int = 0,
	@CustomerCode2	Int = 0,
	@CustomerCode3	Int = 0,
	@CustomerCode4	Int = 0,
	@FiscalFr		Int = Null,
	@SerialFr		Int = Null,
	@FiscalTo		Int = Null,
	@SerialTo		Int = Null,
	@SerialList		varchar(60) = Null,
	@VisitPathID1	int = 0,
	@VisitPathID2	int = 0,
	@VisitPathID3	int = 0,
	@VisitPathID4	int = 0,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@RepOptions		VarChar(10) = '1000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(Max)
DECLARE @StrWhereA	NVarChar(Max)
--DECLARE @StrWhereS 	NVarChar(Max)
--DECLARE @StrWhereT	    NVarChar(Max)
DECLARE @StrFrom	NVarChar(Max)
DECLARE @AcntCode	NVarChar(1024)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

DECLARE @PartStart	int;
DECLARE @PartLen	int;

DECLARE @Part1Start	int;
DECLARE @Part1Len	int;

DECLARE @Part2Start	int;
DECLARE @Part2Len	int;

DECLARE @Part3Start	int;
DECLARE @Part3Len	int;

DECLARE @Part4Start	int;
DECLARE @Part4Len	int;

DECLARE @VPathName1	nvarchar(50);
DECLARE @VPathName2	nvarchar(50);
DECLARE @VPathName3	nvarchar(50);
DECLARE @VPathName4	nvarchar(50);

DECLARE @PartNoLen	Int;
DECLARE @CustomerLayer AS tinyint;
DECLARE @AreaLayerLen AS tinyint;

DECLARE @PrePartsLen TinyInt;
DECLARE @StartLen	TinyInt;

Begin
	SET NOCOUNT ON;
	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '1000';

	--If (@FiscalYear=0)	SET @SerialNo = 0;
	--If (@SerialNo =0)		SET @FiscalYear = 0;
		
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	IF (@VisitorCode1	Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2	Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3	Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4	Is Null)	SET @VisitorCode4 = 0;
	IF (@CustomerCode1	Is Null)	SET @CustomerCode1 = 0;
	IF (@CustomerCode2	Is Null)	SET @CustomerCode2 = 0;
	IF (@CustomerCode3	Is Null)	SET @CustomerCode3 = 0;
	IF (@CustomerCode4	Is Null)	SET @CustomerCode4 = 0;
		
	If (@FiscalFr Is Null)	SET @SerialFr = Null;
	If (@FiscalTo Is Null)	SET @SerialTo = Null;
	If (@SerialFr Is Null)	SET @FiscalFr = Null;
	If (@SerialTo Is Null)	SET @FiscalTo = Null;
			
	-----------------------------------------------------------------------------------------------
	-------- set layers len -----------------------------------------------------------------------
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	If (@PartNo = 1)
	Begin
		Set @PartStart = @Part1Start
		set @PartLen = @Part1Len
	End
	Else If (@PartNo = 2)
	Begin
		Set @PartStart = @Part2Start
		set @PartLen = @Part2Len
	End
	Else If (@PartNo = 3)
	Begin
		Set @PartStart = @Part3Start
		set @PartLen = @Part3Len
	End
	Else If (@PartNo = 4)
	Begin
		Set @PartStart = @Part4Start
		set @PartLen = @Part4Len
	End
	
	SET @VPathName1 = ''
	SET @VPathName2 = ''
	SET @VPathName3 = ''
	SET @VPathName4 = ''
	
	-- ================= AreaLayerLen
	SET @AreaLayerLen = 0
	
	SELECT @AreaLayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AreaLayerLen'
	
	-- ================= AcntPartNumberForRemainCalculation
	DECLARE @AcntPartNumberForRemainCalculation int
	SELECT @AcntPartNumberForRemainCalculation=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	-- ================= Select StartLen
	SET @StartLen = 1
	SET @PrePartsLen = 0
	
	Select @PrePartsLen = Sum(Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9) + @AcntPartNumberForRemainCalculation - 1
	From pub.tblCodeLayer
	Where TableName = 'acc.tblAcnt' And PartNumber < @AcntPartNumberForRemainCalculation
		
	-----------------------------------------------------------------------------------------------
	-- W H E R E ----------------------------------------------------------------------------------
	--SET @StrWhereA = '(AH.PartNumber=' + LTrim(Str(@PartNo)) + ') and (FirstName<>'''' or LastName<>'''')'
	SET @StrWhereA = '(A.PartNumber=' + LTrim(Str(@PartNo)) + ')'
	--SET @StrWhereS = '(A.PartNumber=' + LTrim(Str(@PartNo)) + ')'
	
	--IF (@SerialNo <>0)
	--	Set @StrWhereA = @StrWhereA + ' AND VD.SerialNo=' + LTrim(Str(@SerialNo))
		
	IF (@VisitPathID1 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'A.VisitPathID1')
	IF (@VisitPathID2 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'A.VisitPathID2')
	IF (@VisitPathID3 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'A.VisitPathID3')
	IF (@VisitPathID4 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'A.VisitPathID4')
				
	IF (@SerialList is not null)
		SET @StrWhereA = @StrWhereA + ' AND (H.SerialNo in (' + LTrim(@SerialList) + '))'
						
	IF (@VisitorCode1 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	IF (@VisitorCode2 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	IF (@VisitorCode3 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	IF (@VisitorCode4 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')
		
	IF (@CustomerCode1 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerCode1, 'F.CustomerAcntCode')
	IF (@CustomerCode2 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerCode2, 'F.CustomerAcntCode')
	IF (@CustomerCode3 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerCode3, 'F.CustomerAcntCode')
	IF (@CustomerCode4 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerCode4, 'F.CustomerAcntCode')
		
	IF (@SerialFr Is Not Null)
		Set @StrWhereA = @StrWhereA + ' AND H.SerialNo >= ' + LTrim(Str(@SerialFr))
	IF (@SerialTo Is Not Null)
		Set @StrWhereA = @StrWhereA + ' AND H.SerialNo <= ' + LTrim(Str(@SerialTo))
				
	IF (@DocDateFr is not null)
		SET @StrWhereA = @StrWhereA + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo is not null)
		SET @StrWhereA = @StrWhereA + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
									
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	set @AcntCode = 'Substring(H.AcntCode,' + LTrim(Str(@PartStart)) + ',' + LTrim(Str(@PartLen)) + ')'
	declare @Eqal nvarchar(500)
	
	create table #tblResult1
	(
		AcntCode			varchar(20) collate arabic_cs_as,
		RemainFr			float,
		Purchase			float,
		CheqPaid			float,
		CheqRcpt			float,
		CheqCurr			float,
		CheqRetr			float,
		CashBill			float,
		SalePric			float,
		SaleRetr			float,
		SaleRetP			float,
		SaleDisc			float,
		SaleInvc			float,
		IvcAvgFn			char(10) null,
		IvcAvgRe			char(10) null,
		RecAvgFn			char(10) null,
		RemainTo			float,
		MaxDebitRemain		float,
		MaxReceivableRemain	float,
		ComplementCredit	float,
		AccountRemain		float,
		ManagerView         varchar(500) ,
		VisitorView         varchar(500) ,		
		MaxReturnCheque		 int,
		MaxDaysAfterExpiration int 
	);

	create table #tblAcnt1
	(
		AcntCode	varchar(20) collate arabic_cs_as,
		PartNo  int
	);
	Set @StrSelect = ''
	--IF (@SerialNo <>0)
	--	Set @StrSelect = @StrSelect + ' AND D.SerialNo=' + LTrim(Str(@SerialNo))
		
	
	set @StrSelect = 
		' INSERT INTO #tblAcnt1 ' +
		' SELECT DISTINCT CustomerAcntCode ,' + LTrim(Str(@PartNo)) +
		' FROM sal.tblVisitorDistributeDtl  D ' + 
		' WHERE 1 = 1 ' + @StrSelect
		
	--Print @StrSelect;
	exec sp_executesql @StrSelect;
	
	declare @AcntCodeF varchar(20)
	declare @PartNoF varchar(20)
	
	--declare csr_rem1 cursor for
	--	select AcntCode, PartNo
	--	from #tblAcnt1
	--open csr_rem1
	--fetch next from csr_rem1 into @AcntCodeF, @PartNoF
	
	--while (@@FETCH_STATUS = 0)
	--begin

	--	insert into #tblResult1
	--	exec [pub].[CustomerCreditInfo]  @AcntCodeF, @PartNoF
			
	--	fetch next from csr_rem1 into @AcntCodeF, @PartNoF
	--end

	--close csr_rem1 
	--deallocate csr_rem1 

	SET @StrSelect = '
	Select
		    VH.SerialNo, VH.DocDate, VH.DateForVisit, VH.VisitorAcntCode,
			IsNull(VH.Branch,'''') As Branch_Code, 
			IsNull(VPD1.VisitPathName,'''') As Branch,
			IsNull(VH.SuperVision,'''') As SuperVisor_Code, 
			IsNull(VPD2.VisitPathName,'''') As SuperVisor, 
			IsNull(VH.VisitArea,'''') As VisitArea_Code, 
			IsNull(VPD3.VisitPathName,'''') As VisitArea,	
			IsNull(VH.VisitRout,'''') As VisitRout_Code,
			IsNull(VPD4.VisitPathName,'''') As VisitRout,	
			AD.AcntCode, AD.AcntName, AD.FirstName + '' '' + AD.LastName as CustomerName,
			AH.Tel, AH.CustomerKindID, K.CustomerKindName, AD.Address1, AD.Address2, L.LastDate,
			SaleCount, PayableAmount,
			isnull((
				SELECT	IsNull(Sum(D.Debit-D.Credit),0) 
				FROM	acc.tblVoucherDtl D
							INNER JOIN acc.tblVoucherHdr H ON H.SerialNo=D.SerialNo
				WHERE   (H.DocRegisterState>0) AND (Substring(D.AcntCode,' + LTrim(Str(@PartStart)) + ',' + LTrim(Str(@PartLen)) + ')=AH.AcntCode)
			),0) DebitRemain,
			(			
				SELECT	IsNull(Sum(PD.Amount), 0)
				FROM	[trs].tblPayDtl AS PD
						INNER JOIN 
						(
							SELECT MX.*, CreditCode
							FROM 
							(
								SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
								FROM	[trs].tblPayDtl PD2
								WHERE	PD2.PayTypeID IN (6,26)
								GROUP BY VolumeFiscalYear, VolumeRowNo
							) MX, 
							(
								SELECT VolumeFiscalYear, VolumeRowNo, CreditCode
								FROM	trs.tblPayDtl
								WHERE	ProcessID IN (1,10) AND 
										PayTypeID IN (6,26) AND 
										Substring(CreditCode,' + LTrim(Str(@PartStart)) + ',' + LTrim(Str(@PartLen)) + ') = AH.AcntCode
							) B
							WHERE MX.VolumeFiscalYear=B.VolumeFiscalYear AND MX.VolumeRowNo=B.VolumeRowNo 
						) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
				WHERE	PD.PayTypeID IN (6,26) AND ProcessID IN (13,18,24) AND
						Substring(VOL.CreditCode,' + LTrim(Str(@PartStart)) + ',' + LTrim(Str(@PartLen)) + ') = AH.AcntCode
			) ChequesRetAmount, 
			cast(''' + @VPathName1 + ''' as nvarchar(50)) as VPathName1, cast(''' + @VPathName2 + ''' as nvarchar(50)) as VPathName2,
			cast(''' + @VPathName3 + ''' as nvarchar(50)) as VPathName3, cast(''' + @VPathName4 + ''' as nvarchar(50)) as VPathName4
	from  sal.tblVisitorDistributeDtl VD
	
	Inner Join sal.tblVisitorDistributeHdr VH ON VH.SerialNo = VD.SerialNo
	
	LEFT JOIN acc.tblVisitPathDtl VPD1 ON VPD1.VisitPathID = VH.Branch And VPD1.PartNumber = 1
	LEFT JOIN acc.tblVisitPathDtl VPD2 ON VPD2.VisitPathID = VH.SuperVision And VPD2.PartNumber = 2
	LEFT JOIN acc.tblVisitPathDtl VPD3 ON VPD3.VisitPathID = VH.VisitArea And VPD3.PartNumber = 3
	LEFT JOIN acc.tblVisitPathDtl VPD4 ON VPD4.VisitPathID = VH.VisitRout And VPD4.PartNumber = 4
	INNER JOIN acc.tblAcnt AH on AH.AcntCode = VD.CustomerAcntCode and AH.PartNumber = ' + LTrim(Str(@PartNo)) + '
			INNER JOIN acc.tblAcntDtl AD on AD.AcntCode=AH.AcntCode and AD.PartNumber=AH.PartNumber
			INNER JOIN sal.tblCustomerKindsDtl K on K.CustomerKindID=AH.CustomerKindID
			LEFT JOIN 
			(
				select CustomerCode, sum(PayableAmount) PayableAmount, Count(*) SaleCount
				from
				(
					select  ' + @AcntCode + ' CustomerCode,
							isnull((
								select Sum(D.GoodsPrice*D.GoodsQuantity) 
								from inv.tblStorageDocsDtl D
								where (H.ProcessID=D.ProcessID) AND (H.ProcessNo=D.ProcessNo) AND (H.FiscalYear=D.FiscalYear) AND (H.SerialNo=D.SerialNo)
							),0) + SidePriceSum PayableAmount
					from	inv.vwStorageDocsHdr H
					where  (H.ProcessID=90)
				) X
				group by CustomerCode
			) T on T.CustomerCode = AH.AcntCode
			left join 
			(			
				select  ' + @AcntCode + ' CustomerCode, 
						Max(DocDate) LastDate
				from	inv.tblStorageDocsHdr H
				where  (H.ProcessID=90) 
				group by ' + @AcntCode + '
			) L on L.CustomerCode = AH.AcntCode
	where --' + @StrWhereA + '
	order by AH.AcntCode '

--PRINT @StrSelect
PRINT '--================================================'
PRINT '--================================================'

	DECLARE	@LayerLen	int;
	DECLARE	@StartLayerIndex	int;
	DECLARE	@AcntPartNumber	int;

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'

	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'

	SELECT @AcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	--==================================================
	--SET @StartLen = @StartLen - @PrePartsLen
	SET @AreaLayerLen = @AreaLayerLen - @PrePartsLen
	
	SET @StrSelect =
	   'SELECT  H.SerialNo, AD.*, F.CustomerAcntCode, H.DateForVisit, A.CustomerKindID, K.CustomerKindName,
				SubString(F.CustomerAcntCode,1,acc.funGetBeforeLayerLen (F.CustomerAcntCode,' + LTrim(RTrim(Str(@AcntPartNumber))) + ')) CustomerAcntGroup,
				[acc].[funPartAcntFullName](SubString(F.CustomerAcntCode,1,acc.funGetBeforeLayerLen (F.CustomerAcntCode,' + LTrim(RTrim(Str(@AcntPartNumber))) + ')),' + LTrim(RTrim(Str(@AcntPartNumber))) + ') CustomerAcntGroupName,
				pub.funGetCustRemain(F.CustomerAcntCode) as AccountRemain, H.VisitorAcntCode, pub.GetCodeName(H.VisitorAcntCode,  1) As VisitorName,
				CASE WHEN  pub.funGetCustRemain(F.CustomerAcntCode) < 0 THEN ''بد'' ELSE ''بس'' END as State,
				acc.funGetAcntName(SubString(F.CustomerAcntCode, ' + LTrim(RTrim(Str(@StartLen))) + ', ' + LTrim(RTrim(Str(@AreaLayerLen))) + ') ,' + LTrim(RTrim(Str(@AcntPartNumberForRemainCalculation))) + ',' + LTrim(RTrim(str(@LangID))) + ') As AcntNamePart,
				IsNull(H.Branch,'''') As Branch_Code, 
				IsNull(VPD1.VisitPathName,'''') As Branch,
				IsNull(H.SuperVision,'''') As SuperVisor_Code, 
				IsNull(VPD2.VisitPathName,'''') As SuperVisor, 
				IsNull(H.VisitArea,'''') As VisitArea_Code, 
				IsNull(VPD3.VisitPathName,'''') As VisitArea,	
				IsNull(H.VisitRout,'''') As VisitRout_Code,
				IsNull(VPD4.VisitPathName,'''') As VisitRout,	
				ISNULL(A.Tel,''-'') + '' - '' + IsNull(A.Mobile,''-'') as TelMobile, '''' As IvcAvgRe, 
				A.*, IsNull(STD.SaleTypeName, '''') SaleTypeName,
				[inv].[FunGetCustomerLastProcessDate] (90, AD.AcntCode, 0, 0, 0, 0, '''', '''') LaseSaleDate
		FROM acc.tblAcntDtl AS AD 
		INNER	JOIN acc.tblAcnt as A ON AD.AcntCode = A.AcntCode AND AD.PartNumber = A.PartNumber 
		INNER JOIN sal.tblCustomerKindsDtl K on K.CustomerKindID=A.CustomerKindID
		RIGHT OUTER JOIN sal.tblVisitorDistributeHdr AS H 
		INNER JOIN sal.tblVisitorDistributeDtl AS F ON H.SerialNo = F.SerialNo ON AD.AcntCode = F.CustomerAcntCode
		LEFT OUTER JOIN acc.tblVisitPathDtl AS VPD1 ON VPD1.VisitPathID = H.Branch		AND VPD1.PartNumber = 1 
		LEFT OUTER JOIN acc.tblVisitPathDtl AS VPD2 ON VPD2.VisitPathID = H.SuperVision AND VPD2.PartNumber = 2 
		LEFT OUTER JOIN acc.tblVisitPathDtl AS VPD3 ON VPD3.VisitPathID = H.VisitArea	AND VPD3.PartNumber = 3 
		LEFT OUTER JOIN acc.tblVisitPathDtl AS VPD4 ON VPD4.VisitPathID = H.VisitRout	AND VPD4.PartNumber = 4
		LEFT JOIN sal.tblSaleTypesDtl STD ON STD.SaleTypeID = A.SaleTypeID AND STD.LanguageID = 1
		OUTER APPLY acc.funGetCodeInfo(F.CustomerAcntCode) AS TR 

		Where ' + @StrWhereA + '
		Order By ISNULL(TR.Sequence,0),F.DocRowNo '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
