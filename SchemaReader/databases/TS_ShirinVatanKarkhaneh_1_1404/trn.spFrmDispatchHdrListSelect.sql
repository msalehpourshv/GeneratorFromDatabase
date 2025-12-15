USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 99/10/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================			   
Create PROCEDURE [trn].[spFrmDispatchHdrListSelect]
	@ProcessID		Smallint,
	@BaseProcessID	Smallint,
	@BaseSerialNo	int,
	@CustomerCode	varchar(20),
	@DocDate		Char(10),
	@DocStep		tinyint,
	@FilterInfo		NVarChar(100) = '@@0@0@@0@1@0@0@0@0@0'

WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @LanguageID AS  TinyInt

	DECLARE @FromDate		Char(10);
	DECLARE @ToDate	    	Char(10);

	Declare @ConfirmCountInDispatch	tinyint;
	Declare @ConfirmCount	tinyint;
	Declare @PartNo			tinyint;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;

	--================================
	Set @FromDate		=''
	Set @ToDate	    	=''
	
	-- Init -------------------------------------------------
	IF (@FilterInfo Is Null)	SET @FilterInfo ='@@0@0@@0@1@0@0@0@0@0'

	SET @FromDate		= pub.funSplitString(@FilterInfo, '@', 1);
	SET @ToDate			= pub.funSplitString(@FilterInfo, '@', 2);
	SET @PartNo			= pub.funSplitString(@FilterInfo, '@', 3);
	SET @ConfirmCount	= pub.funSplitString(@FilterInfo, '@', 5);
	SET @Sgn1			= pub.funSplitString(@FilterInfo, '@', 6);
	SET @Sgn2			= pub.funSplitString(@FilterInfo, '@', 7);
	SET @Sgn3			= pub.funSplitString(@FilterInfo, '@', 8);
	SET @Sgn4			= pub.funSplitString(@FilterInfo, '@', 9);
	SET @Sgn5			= pub.funSplitString(@FilterInfo, '@', 10);
	
	SET @LanguageID = pub.funGetCurrentLanguageID()
	
	SET @ConfirmCountInDispatch=0
	SELECT @ConfirmCountInDispatch = SettingValue from pub.tblSettings where SettingKey = 'ConfirmCountInDispatch'
	 
	--=====================================
	--=====================================	 
	IF @ProcessID = 820 
	
	    SELECT H.*,
			   [acc].[funGetAcntName](H.CustomerCode,@PartNo,@LanguageID) CustomerName,
               pub.funGetLocationName(H.SourceLocationID,@LanguageID) SourceLocationName, 
               pub.funGetLocationName(H.DestinationLocationID,@LanguageID) DestinationLocationName
        FROM trn.tblTransportationOfferHdr H 
        WHERE (H.ProcessID = 820) AND 
              (H.SerialNo not in (SELECT BaseSerialNo FROM trn.tblDispatchHdr) ) AND
    		  (@FromDate ='' OR (@FromDate <> '' AND DocDate >= @FromDate )) AND
			  (@ToDate ='' OR (@ToDate <> '' AND DocDate <= @ToDate )) 
			
	ELSE IF  @ProcessID = 821 AND @BaseProcessID=0
	BEGIN

		IF @DocStep = 1
		   SELECT H.ProcessID,
				  H.SerialNo,
				  H.DocDate,
				  H.CustomerCode,
				  H.WaybillNo,
				  H.VehicleID,
				  [trn].[funGetVehicleName](H.VehicleID,1) VehicleName,
				  H.RefrigeratorID,
				  [trn].[funGetRefrigeratorName] (H.RefrigeratorID,1) RefrigeratorName,
				  H.TransportationKindID,
				  [trn].[funGetTransportationKindName](H.TransportationKindID,1) TransportationKindName,
				  CASE Receiver WHEN 1 THEN 'راننده' WHEN 2 THEN 'مشتری' WHEN 3 THEN 'حق العمل کار' ELSE '' END ReceiverName,
				  pub.funGetLocationName(H.SourceLocationID,@LanguageID) SourceLocationName, 
				  pub.funGetLocationName(H.DestinationLocationID,@LanguageID) DestinationLocationName,
				  acc.funGetAcntName(H.CustomerCode,@PartNo,@LanguageID) CustomerName
		   FROM  trn.tblDispatchHdr H
		   WHERE ProcessID = 821 AND DocStep=1 AND 
				(@FromDate ='' OR (@FromDate <> '' AND DocDate >= @FromDate )) AND
				(@ToDate ='' OR (@ToDate <> '' AND DocDate <= @ToDate )) AND
				 (@ConfirmCount=0 
			   OR(@ConfirmCount>0 
				AND ((@Sgn1=0 AND SgnSN1=0) OR (@Sgn1>0 AND SgnSN1>0))
				AND ((@Sgn2=0 AND SgnSN2=0) OR (@Sgn2>0 AND SgnSN2>0))
				AND ((@Sgn3=0 AND SgnSN3=0) OR (@Sgn3>0 AND SgnSN3>0))
				AND ((@Sgn4=0 AND SgnSN4=0) OR (@Sgn4>0 AND SgnSN4>0))
				AND ((@Sgn5=0 AND SgnSN5=0) OR (@Sgn5>0 AND SgnSN5>0))
				 ))
		ELSE

		   SELECT H.ProcessID,
				  H.SerialNo,
				  H.DocDate,
				  H.CustomerCode,
				  H.WaybillNo,
				  H.VehicleID,
				  [trn].[funGetVehicleName](H.VehicleID,1) VehicleName,
				  H.RefrigeratorID,
				  [trn].[funGetRefrigeratorName] (H.RefrigeratorID,1) RefrigeratorName,
				  H.TransportationKindID,
				  [trn].[funGetTransportationKindName](H.TransportationKindID,1) TransportationKindName,
				  CASE Receiver WHEN 1 THEN 'راننده' WHEN 2 THEN 'مشتری' WHEN 3 THEN 'حق العمل کار' ELSE '' END ReceiverName,
				  pub.funGetLocationName(H.SourceLocationID,@LanguageID) SourceLocationName, 
				  pub.funGetLocationName(H.DestinationLocationID,@LanguageID) DestinationLocationName,
				  acc.funGetAcntName(H.CustomerCode,@PartNo,@LanguageID) CustomerName
		   FROM trn.tblDispatchHdr H
		   WHERE ProcessID = 821 AND DocStep=1 AND VchNo>0 AND
				(@FromDate ='' OR (@FromDate <> '' AND DocDate >= @FromDate )) AND
				(@ToDate ='' OR (@ToDate <> '' AND DocDate <= @ToDate ))

	END
	ELSE IF  @ProcessID = 821 AND @BaseProcessID=822

	   SELECT H.ProcessID,
			  H.SerialNo,
			  H.DocDate,
			  H.CustomerCode,
			  H.WaybillNo,
			  H.VehicleID,
			  [trn].[funGetVehicleName](H.VehicleID,1) VehicleName,
			  H.RefrigeratorID,
			  [trn].[funGetRefrigeratorName] (H.RefrigeratorID,1) RefrigeratorName,
			  H.TransportationKindID,
			  [trn].[funGetTransportationKindName](H.TransportationKindID,1) TransportationKindName,
			  CASE Receiver WHEN 1 THEN 'راننده' WHEN 2 THEN 'مشتری' WHEN 3 THEN 'حق العمل کار' ELSE '' END ReceiverName,
			  pub.funGetLocationName(H.SourceLocationID,@LanguageID) SourceLocationName, 
			  pub.funGetLocationName(H.DestinationLocationID,@LanguageID) DestinationLocationName,
			  acc.funGetAcntName(H.CustomerCode,@PartNo,@LanguageID) CustomerName
	   FROM trn.tblDispatchHdr H
	   WHERE ProcessID = 821 AND 
			(@FromDate ='' OR (@FromDate <> '' AND DocDate >= @FromDate )) AND
			(@ToDate ='' OR (@ToDate <> '' AND DocDate <= @ToDate )) AND
			 (@ConfirmCount=0 
		   OR(@ConfirmCount>0 
			AND ((@Sgn1=0 AND SgnSN1=0) OR (@Sgn1>0 AND SgnSN1>0))
			AND ((@Sgn2=0 AND SgnSN2=0) OR (@Sgn2>0 AND SgnSN2>0))
			AND ((@Sgn3=0 AND SgnSN3=0) OR (@Sgn3>0 AND SgnSN3>0))
			AND ((@Sgn4=0 AND SgnSN4=0) OR (@Sgn4>0 AND SgnSN4>0))
			AND ((@Sgn5=0 AND SgnSN5=0) OR (@Sgn5>0 AND SgnSN5>0))
			 ))

	ELSE IF  @ProcessID = 822

	   SELECT H.ProcessID,
			  H.SerialNo,
			  HD.FiscalYear,
			  H.DocDate,
			  HD.CustomerCode,
	          pub.funGetLocationName(HD.SourceLocationID,@LanguageID) SourceLocationName, 
              pub.funGetLocationName(HD.DestinationLocationID,@LanguageID) DestinationLocationName,
			  acc.funGetAcntName(HD.CustomerCode,@PartNo,@LanguageID) CustomerName
	   FROM  trn.tblDispatchCostHdr H
	   INNER JOIN trn.tblDispatchHdr HD ON H.SerialNo = HD.BaseSerialNo 
									   AND HD.ProcessID = 821
	   WHERE H.ProcessID = 822 AND 
			(@FromDate ='' OR (@FromDate <> '' AND H.DocDate >= @FromDate )) AND
			(@ToDate ='' OR (@ToDate <> '' AND H.DocDate <= @ToDate )) AND
			 (@ConfirmCount=0 
		   OR(@ConfirmCount>0 
			AND ((@Sgn1=0 AND H.SgnSN1=0) OR (@Sgn1>0 AND H.SgnSN1>0))
			AND ((@Sgn2=0 AND H.SgnSN2=0) OR (@Sgn2>0 AND H.SgnSN2>0))
			AND ((@Sgn3=0 AND H.SgnSN3=0) OR (@Sgn3>0 AND H.SgnSN3>0))
			AND ((@Sgn4=0 AND H.SgnSN4=0) OR (@Sgn4>0 AND H.SgnSN4>0))
			AND ((@Sgn5=0 AND H.SgnSN5=0) OR (@Sgn5>0 AND H.SgnSN5>0))
			 ))

	ELSE IF  @ProcessID = 823

		SELECT H.*,
               acc.funGetAcntName(H.CustomerCode,@PartNo,@LanguageID) CustomerName,
               acc.funGetAcntName(H.DriverID,@PartNo,@LanguageID) DriverName,
               acc.funGetAcntName(H.CommissionCode,@PartNo,@LanguageID) CommissionName,
               acc.funGetAcntName(H.VisitorCode,@PartNo,@LanguageID) VisitorName,
               pub.funGetLocationName(H.SourceLocationID,@LanguageID) AS SourceLocationName,
               pub.funGetLocationName(H.DestinationLocationID,@LanguageID) AS DestinationLocationName,
               trn.funGetTransportationKindName(H.TransportationKindID,@LanguageID) AS TransportationKindName,
               trn.funGetVehicleName(H.VehicleID,@LanguageID) AS VehicleName,
               trn.funGetRefrigeratorName(H.RefrigeratorID,@LanguageID) AS RefrigeratorName,
               pub.funGetGoodsName(H.GoodsID,@LanguageID) AS GoodsName,
			   CASE H.Receiver WHEN 1 THEN 'راننده' WHEN 2 THEN 'مشتری' WHEN 3 THEN 'حق العمل کار' ELSE '' END ReceiverName
		FROM trn.tblDispatchHdr H
		INNER JOIN (SELECT ProcessID,
						   SerialNo 
					FROM trn.tblDispatchHdr 
					WHERE ProcessID = 821 
					  AND ( @BaseSerialNo =0 OR SerialNo = @BaseSerialNo)
					  AND ( @CustomerCode ='' OR CustomerCode = @CustomerCode)
					EXCEPT
					SELECT BaseProcessID,
						   BaseSerialNo 
					FROM trn.tblDispatchInvoiceDtl
					) B ON H.ProcessID = B.ProcessID 
					   AND H.SerialNo = B.SerialNo					   
		WHERE H.ProcessID = 821  AND 
			(@FromDate ='' OR (@FromDate <> '' AND DocDate >= @FromDate )) AND
			(@ToDate ='' OR (@ToDate <> '' AND DocDate <= @ToDate )) AND
		    (@ConfirmCountInDispatch=0 OR 
			(@ConfirmCountInDispatch=1 AND (H.SgnSN1>0)) OR
			(@ConfirmCountInDispatch=2 AND (H.SgnSN1>0 AND H.SgnSN2>0 )) OR
			(@ConfirmCountInDispatch=3 AND (H.SgnSN1>0 AND H.SgnSN2>0 AND H.SgnSN3>0 )) OR
			(@ConfirmCountInDispatch=4 AND (H.SgnSN1>0 AND H.SgnSN2>0 AND H.SgnSN3>0 AND H.SgnSN4>0 )) OR
			(@ConfirmCountInDispatch=5 AND (H.SgnSN1>0 AND H.SgnSN2>0 AND H.SgnSN3>0 AND H.SgnSN4>0 AND H.SgnSN5>0 )) 
			 )

END
GO
