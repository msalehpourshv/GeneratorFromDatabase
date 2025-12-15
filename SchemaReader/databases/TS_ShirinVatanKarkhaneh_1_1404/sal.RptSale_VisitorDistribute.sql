USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/03/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_VisitorDistribute]
	@PartNo			int = 1,
	@ProcessNo		int = 10,
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
	@SaleTypeID		VarChar(20) = null, 
	@CustomerKindID	varchar(20) = null,
	@DocStep		Int = 0,  -- مرحله
	@SortFields		NVarChar(100) = Null,
	@RepOptions		VarChar(10) = '1000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrWhereA	NVarChar(max)
DECLARE @StrWhereS	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @AcntCode	NVarChar(1024)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

declare @PartStart	int;
declare @PartLen	int;

declare @Part1Start	int;
declare @Part1Len	int;

declare @Part2Start	int;
declare @Part2Len	int;

declare @Part3Start	int;
declare @Part3Len	int;

declare @Part4Start	int;
declare @Part4Len	int;

declare @VPathName1	nvarchar(50);
declare @VPathName2	nvarchar(50);
declare @VPathName3	nvarchar(50);
declare @VPathName4	nvarchar(50);

Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '1000';
	IF (@SortFields		Is Null)	SET @SortFields = 'AH.AcntCode';
	IF (@DocStep		Is Null)	SET @DocStep = 0;

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

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
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
	
	set @VPathName1 = ''
	set @VPathName2 = ''
	set @VPathName3 = ''
	set @VPathName4 = ''
	-----------------------------------------------------------------------------------------------
	-- W H E R E ----------------------------------------------------------------------------------
	SET @StrWhereA = '(AH.PartNumber=' + LTrim(Str(@PartNo)) + ') and (FirstName<>'''' or LastName<>'''')'
	SET @StrWhereS = '(ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'
	
	if (@CustomerKindID is not null)
		SET @StrWhereA = @StrWhereA + ' AND (K.CustomerKindID=''' + LTrim(@CustomerKindID) + ''')'
		
	if (@VisitPathID1 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID1, 'AH.VisitPathID1')
	if (@VisitPathID2 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID2, 'AH.VisitPathID2')
	if (@VisitPathID3 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID3, 'AH.VisitPathID3')
	if (@VisitPathID4 <> 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitPathID4, 'AH.VisitPathID4')

	IF (@SerialList is not null)
		SET @StrWhereS = @StrWhereS + ' AND (H.SerialNo in (' + LTrim(@SerialList) + '))'
	IF (@DocStep > 0)
		SET @StrWhereS = @StrWhereS + ' AND (H.DocStep>=' + LTrim(Str(@DocStep)) + ')'

	If (@SaleTypeID Is Not Null)
		Set @StrWhereS = @StrWhereS + ' AND (H.SaleTypeID=''' + @SaleTypeID + ''')'

	IF (@VisitorCode1 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	IF (@VisitorCode2 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	IF (@VisitorCode3 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	IF (@VisitorCode4 > 0)
		SET @StrWhereS = @StrWhereS + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	IF (@SerialFr Is Not Null)
		Set @StrWhereS = @StrWhereS + ' AND (H.FiscalYear>' + LTrim(Str(@FiscalFr)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalFr)) + ' AND H.SerialNo>=' + LTrim(Str(@SerialFr)) + '))' 
	IF (@SerialTo Is Not Null)
		Set @StrWhereS = @StrWhereS + ' AND (H.FiscalYear<' + LTrim(Str(@FiscalTo)) + ' OR (H.FiscalYear=' + LTrim(Str(@FiscalTo)) + ' AND H.SerialNo<=' + LTrim(Str(@SerialTo)) + '))' 

	IF (@DocDateFr is not null)
		SET @StrWhereS = @StrWhereS + ' AND (H.DocDate>=''' + @DocDateFr + ''')'
	IF (@DocDateTo is not null)
		SET @StrWhereS = @StrWhereS + ' AND (H.DocDate<=''' + @DocDateTo + ''')'

	IF (@CustomerCode1 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerCode1, 'AH.AcntCode')
	IF (@CustomerCode2 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerCode2, 'AH.AcntCode')
	IF (@CustomerCode3 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerCode3, 'AH.AcntCode')
	IF (@CustomerCode4 > 0)
		SET @StrWhereA = @StrWhereA + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CustomerCode4, 'AH.AcntCode')

	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	set @AcntCode = 'Substring(H.AcntCode,' + LTrim(Str(@PartStart)) + ',' + LTrim(Str(@PartLen)) + ')'
	declare @Eqal nvarchar(500)
	
	SET @StrSelect = '
	select	AD.AcntCode, AD.AcntName, AD.FirstName + '' '' + AD.LastName as CustomerName,
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
	from	acc.tblAcnt AH
			inner join acc.tblAcntDtl AD on AD.AcntCode=AH.AcntCode and AD.PartNumber=AH.PartNumber
			inner join sal.tblCustomerKindsDtl K on K.CustomerKindID=AH.CustomerKindID
			left join 
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
					where  (H.ProcessID=90) and ' + @StrWhereS + ' 
				) X
				group by CustomerCode
			) T on T.CustomerCode = AH.AcntCode
			left join 
			(			
				select  ' + @AcntCode + ' CustomerCode, 
						Max(DocDate) LastDate
				from	inv.tblStorageDocsHdr H
				where  (H.ProcessID=90) and ' + @StrWhereS + ' 
				group by ' + @AcntCode + '
			) L on L.CustomerCode = AH.AcntCode
	where ' + @StrWhereA + '
	order by ' + @SortFields 

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
