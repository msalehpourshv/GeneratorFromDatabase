USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/11/23
-- Viewed By	 : 
-- Last Modified : 1390/05/23
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- ==============================================
CREATE PROCEDURE [trn].[RptTrn_TrnDoc]
	@ProcessID		Int = 801, 
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 0,
	@SerialNo		Int = 1,
	@FiscalYearTo	Int = 0,
	@SerialNoTo		Int = 1
WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E ===================================================

	SET NoCount On;

	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1;
	If (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	If (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	---------------------------------------------------------------------------

	select	H.*, VD.VehicleName, VH.PlaqueNo, VH.PlaqueSerial, G.GoodsName, 
			DH.DrivingLicenseNo, DH.DriverCardNo, DH.IDNumber, 
			L3.LocationName as DriverHabitatCity,
			L4.LocationName as DrvLicensIssuancePlaceName,
			DH2.DrivingLicenseNo as DrivingLicenseNo2, 
			DH2.DriverCardNo as DriverCardNo2, 
			DH2.IDNumber as IDNumber2, FD.FactoryName,
			L5.LocationName as DriverHabitatCity2,
			L6.LocationName as DrvLicensIssuancePlaceName2,
			DD.FirstName + ' ' + DD.LastName as DriverName,	
			DD2.FirstName + ' ' + DD2.LastName as DriverName2, 
			L1.LocationName as SourceLocationName, 
			L2.LocationName as TargetLocationName,
			pub.GetCodeName(CustomerAcntCodeFrom, 1) CustomerAcntName,
			F.Address1, CD.CarriageTypeName, VehicleCardNo
	from	trn.tblRoadBillsHdr H
		left join trn.tblVehicles VH on VH.VehicleID = H.VehicleID
		left join trn.tblVehiclesDtl VD on VD.VehicleID = VH.VehicleID
		left join trn.tblVehicleFactoriesDtl FD on FD.FactoryID = VH.FactoryID
		left join pub.tblDrivers    DH on DH.DriverID = H.DriverID
		left join pub.tblDriversDtl DD on DD.DriverID = H.DriverID
		left join pub.tblDrivers    DH2 on DH2.DriverID = H.DriverID2
		left join pub.tblDriversDtl DD2 on DD2.DriverID = H.DriverID2
		left join inv.tblGoodsDtl G on G.GoodsID = H.GoodsID
		left join pub.tblLocationsDtl L1 on L1.LocationID = H.SourceLocationID
		left join pub.tblLocationsDtl L2 on L2.LocationID = H.DestinationLocationID
		left join pub.tblLocationsDtl L3 on L3.LocationID = DH.HabitatCity
		left join pub.tblLocationsDtl L4 on L4.LocationID = DH.DrvLicensIssuancePlace
		left join pub.tblLocationsDtl L5 on L5.LocationID = DH2.HabitatCity
		left join pub.tblLocationsDtl L6 on L6.LocationID = DH2.DrvLicensIssuancePlace
		left join trn.tblCarriageTypesDtl CD on CD.CarriageTypeID = VH.CarriageTypeID
		OUTER APPLY acc.funGetCodeInfo(H.CustomerAcntCodeFrom) AS F 
	WHERE   (H.ProcessID = @ProcessID) and (H.SerialNo >= @SerialNo) and (H.SerialNo <= @SerialNoTo)
End
--go
--[trn].[RptTrn_TrnDoc]
GO
