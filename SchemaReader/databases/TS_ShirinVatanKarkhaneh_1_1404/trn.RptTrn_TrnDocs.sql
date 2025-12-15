USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1390/03/18
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- ==============================================
CREATE PROCEDURE [trn].[RptTrn_TrnDocs]
	@ProcessID		int = 801, 
	@SerialNoFr		int = null,
	@SerialNoTo		int = null,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@Sender1		int = 0,
	@Sender2		int = 0,
	@Sender3		int = 0,
	@Sender4		int = 0,
	@driver1		int = 0,
	@driver2		int = 0,
	@source			int = 0,
	@target			int = 0,
	@valueFr		bigint = -1,
	@valueTo		bigint = -1,
	@totalFr		bigint = -1,
	@totalTo		bigint = -1,
	@terminalFr		bigint = -1,
	@terminalTo		bigint = -1,
	@comissionFr	bigint = -1,
	@comissionTo	bigint = -1,
	@RepOptions		VarChar(20) = '', -- bit array options
	@RepInfo		NVarChar(100) = Null,
	@SortFields		NVarChar(100) = Null
WITH ENCRYPTION
AS 
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

declare @select nvarchar(4000);
declare @where nvarchar(4000);
Begin --============== S T A R T  C O D E ===================================================

	SET NoCount On;

	-- I N I T ----------------------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '';
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';

	IF (@Sender1	Is Null)	SET @Sender1 = 0
	IF (@Sender2	Is Null)	SET @Sender2 = 0
	IF (@Sender3	Is Null)	SET @Sender3 = 0
	IF (@Sender4	Is Null)	SET @Sender4 = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------

	set @where = '(H.ProcessID = ' + ltrim(str(@ProcessID)) + ')'
	
	if (@SerialNoFr is not null) 
		set @where = @where + ' and (H.SerialNo >= ' + ltrim(str(@SerialNoFr)) + ')'
	if (@SerialNoTo is not null) 
		set @where = @where + ' and (H.SerialNo <= ' + ltrim(str(@SerialNoTo)) + ')'

	if (@DocDateFr is not null) 
		set @where = @where + ' and (H.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo is not null) 
		set @where = @where + ' and (H.DocDate <= ''' + @DocDateTo + ''')'

	if (@Sender1 > 0)
		SET @where = @where + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Sender1, 'H.CustomerAcntCodeFrom')
	if (@Sender2 > 0)
		SET @where = @where + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Sender2, 'H.CustomerAcntCodeFrom')
	if (@Sender3 > 0)
		SET @where = @where + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Sender3, 'H.CustomerAcntCodeFrom')
	if (@Sender4 > 0)
		SET @where = @where + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @Sender4, 'H.CustomerAcntCodeFrom')

	if (@driver1 <> 0)
		set @where = @where + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @driver1, 'H.DriverID') 
	if (@driver2 <> 0)
		set @where = @where + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @driver2, 'H.DriverID2') 

	if (@source <> 0) 
		set @where = @where + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @source, 'H.SourceLocationID') 
	if (@target <> 0) 
		set @where = @where + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @target, 'H.DestinationLocationID') 

	if (@valueFr > -1) 
		set @where = @where + ' and (X >= ' + ltrim(str(@valueFr)) + ')'
	if (@valueTo > -1) 
		set @where = @where + ' and (X <= ' + ltrim(str(@valueTo)) + ')'

	if (@totalFr > -1) 
		set @where = @where + ' and (X >= ' + ltrim(str(@totalFr)) + ')'
	if (@totalTo > -1) 
		set @where = @where + ' and (X <= ' + ltrim(str(@totalTo)) + ')'

	if (@terminalFr > -1) 
		set @where = @where + ' and (X >= ' + ltrim(str(@terminalFr)) + ')'
	if (@terminalTo > -1) 
		set @where = @where + ' and (X <= ' + ltrim(str(@terminalTo)) + ')'

	if (@comissionFr > -1) 
		set @where = @where + ' and (H.Commission >= ' + ltrim(str(@comissionFr)) + ')'
	if (@comissionTo > -1) 
		set @where = @where + ' and (H.Commission <= ' + ltrim(str(@comissionTo)) + ')'

	select @select = '
	select	H.*, VD.VehicleName, VH.PlaqueNo, VH.PlaqueSerial, DH.DrivingLicenseNo, 
			DD.FirstName + '' '' + DD.LastName as DriverName, G.GoodsName, 
			L1.LocationName as SourceLocationName, 
			L2.LocationName as TargetLocationName,
			pub.GetCodeName(H.CustomerAcntCodeFrom, 1) CustomerAcntName
	from	trn.tblRoadBillsHdr H
		left join trn.tblVehicles VH on VH.VehicleID = H.VehicleID
		left join trn.tblVehiclesDtl VD on VD.VehicleID = VH.VehicleID
		left join pub.tblDrivers DH on DH.DriverID = H.DriverID
		left join pub.tblDriversDtl DD on DD.DriverID = H.DriverID
		left join inv.tblGoodsDtl G on G.GoodsID = H.GoodsID
		left join pub.tblLocationsDtl L1 on L1.LocationID = H.SourceLocationID
		left join pub.tblLocationsDtl L2 on L2.LocationID = H.DestinationLocationID
	WHERE   ' + @where 

	print @select;
	exec sp_executesql @select;
End
GO
