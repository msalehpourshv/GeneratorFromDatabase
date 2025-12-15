USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
Create Procedure [sal].[SpGetVisitorPercent]
	@AcntCode			Varchar(20),
	@VisitorAcntCode	Varchar(20),
	@DocDate			char(10),
	@ProcessNo	        tinyint, 
	@FiscalYear         Smallint, 
	@SerialNo			int 

WITH ENCRYPTION
AS
BEGIN

declare @decPrc float, @decAmnt float

if (select COUNT(*) FROM sal.tblVisitorsCustomersDtl where VisitorAcntCode = @VisitorAcntCode and VisitorPursant>0)=0
BEGIN
		SET @decPrc = 0
		SET @decAmnt = 0

		SELECT @decPrc=VisitorPercent,@decAmnt=VisitorCost 
		from inv.tblStorageDocsHdr	
		WHERE ProcessID  = 90 AND ProcessNo  = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo   = @SerialNo

		return @decAmnt
END

	Declare @GoodsID		VarChar(20);
	Declare @GoodsGroupID	VarChar(20);
	Declare @CustomerKindID	VarChar(20);
	Declare @AcntPartNumber tinyint;
	Declare @Result			Float;
	Declare @LayerLen AS tinyint;
	Declare @StartLayerIndex AS tinyint;
	DECLARE @VisitorPursantH  Float;
	DECLARE @VisitorPursant  Float;
	DECLARE @VisitorPursantAmount  Float;
	DECLARE @Discount  Float;
	DECLARE @Discount2  Float;
	DECLARE @TotalLineDiscount  Float;
	DECLARE @Price			Float;
	DECLARE @DiscountDtl	Float;
	DECLARE @GoodsLineAmount FLOAT

	SET @LayerLen = 0
	SET @StartLayerIndex = 0
	SET @Result = 0
	SET @AcntPartNumber = 0
	SET @VisitorPursant = 0
	SET @VisitorPursantAmount = 0

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'
	
	SELECT @AcntPartNumber = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'
	
	SELECT @CustomerKindID = CustomerKindID 
	FROM acc.tblAcnt
	WHERE PartNumber = @AcntPartNumber AND 
		  AcntCode=RTRIM(SUBSTRING(@AcntCode,@StartLayerIndex ,@LayerLen))

	SELECT  @Price = Price , @Discount = Discount , @Discount2 = Discount2+Discount3 , @TotalLineDiscount = TotalLineDiscount
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID  = 90 AND
		  ProcessNo  = @ProcessNo AND
		  FiscalYear = @FiscalYear AND
		  SerialNo   = @SerialNo 
		  
	Declare	curVisitorPrcent CURSOR For 
	SELECT	GoodsID , SubUnitPrice*SubUnitQuantity,DiscountDtl
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID=90 AND
		  ProcessNo=@ProcessNo AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo 
	
	Open  curVisitorPrcent; 
	
	Fetch NEXT From curVisitorPrcent Into @GoodsID,@GoodsLineAmount,@DiscountDtl
	While (@@Fetch_Status = 0)
		BEGIN
			SET @VisitorPursant = 0
			
			SELECT TOP 1 @GoodsGroupID = GoodsGroupID 
			FROM inv.tblGoodsGroupsGoodsListDtl
			WHERE GoodsID = LEFT(@GoodsID,LEN(GoodsID))

-------------------------------------------------------------------------------------------------------------------
-----1
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
					CustomerKindID = @CustomerKindID AND 
					GoodsGroupID = @GoodsGroupID  AND 
					LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))

-----2
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
					CustomerKindID = @CustomerKindID AND 
					GoodsGroupID = @GoodsGroupID  AND 
					GoodsID = ''

-----3
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
					CustomerKindID = @CustomerKindID AND 
					GoodsGroupID = '' AND
					LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))

					
-----4
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
					CustomerKindID = '' AND 
					GoodsGroupID = @GoodsGroupID  AND 
					LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
-----5
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					CustomerAcntCode = '' AND 
					CustomerKindID = @CustomerKindID AND 
					GoodsGroupID = @GoodsGroupID  AND 
					LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
-----6
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
					CustomerKindID = @CustomerKindID AND 
					GoodsGroupID = ''  AND 
					GoodsID = ''
-----7
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
					CustomerKindID = '' AND 
					GoodsGroupID = @GoodsGroupID  AND
					GoodsID = ''
-----8
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
					CustomerKindID = '' AND 
					GoodsGroupID = ''  AND
					LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))

-----9
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					CustomerAcntCode ='' AND
					CustomerKindID = @CustomerKindID AND 
					GoodsGroupID = @GoodsGroupID AND  
					GoodsID = ''

-----10
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					CustomerAcntCode ='' AND
					CustomerKindID = @CustomerKindID AND 
					GoodsGroupID = '' AND  
					LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))

-----11
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					CustomerAcntCode ='' AND
					CustomerKindID = '' AND 
					GoodsGroupID = @GoodsGroupID  AND 
					LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))

-----12
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					LEN(CustomerAcntCode)>0 AND CustomerAcntCode =@AcntCode AND
					CustomerKindID = '' AND 
					GoodsGroupID = '' AND  
					GoodsID = ''

-----13
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					CustomerAcntCode ='' AND
					CustomerKindID = @CustomerKindID  AND 
					GoodsGroupID = '' AND  
					GoodsID = ''

-----14
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					CustomerAcntCode ='' AND
					CustomerKindID = ''  AND 
					GoodsGroupID = @GoodsGroupID  AND
					GoodsID = ''
-----15
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					CustomerAcntCode ='' AND
					CustomerKindID = ''  AND 
					GoodsGroupID = '' AND 
					LEN(GoodsID) > 0 AND GoodsID = LEFT(@GoodsID,LEN(GoodsID))
-----16
		IF @VisitorPursant = 0 
			SELECT TOP 1 @VisitorPursant = VisitorPursant 
			FROM sal.tblVisitorsCustomersDtl D INNER JOIN sal.tblVisitorsCustomersHdr H 
			ON	 D.VisitorAcntCode = H.VisitorAcntCode 
			WHERE	(FromDate<=@DocDate AND ToDate>=@DocDate) AND H.VisitorAcntCode = @VisitorAcntCode AND
					CustomerAcntCode ='' AND
					CustomerKindID = ''  AND 
					GoodsGroupID = ''  AND
					GoodsID = ''
-------------------------------------------------------------------------------------------------------------------
		IF @Price >0 
		begin
			if @Price - @TotalLineDiscount=0
				set @VisitorPursantAmount = 0
			else
				SET @VisitorPursantAmount = @VisitorPursantAmount + 
										((@GoodsLineAmount -@DiscountDtl) - ((@GoodsLineAmount -@DiscountDtl) * (@Discount + @Discount2) / (@Price - @TotalLineDiscount))) * @VisitorPursant / 100
		end 
			
			Fetch NEXT From curVisitorPrcent Into @GoodsID,@GoodsLineAmount,@DiscountDtl
		END

		Close curVisitorPrcent;
		Deallocate curVisitorPrcent; 
		
		SET @decPrc = 0
		SET @decAmnt = 0

		SELECT @decPrc=VisitorPercent,@decAmnt=VisitorCost 
		from inv.tblStorageDocsHdr	
		WHERE ProcessID  = 90 AND ProcessNo  = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo   = @SerialNo

		IF (  @VisitorPursantAmount>0 or (@decPrc=0 and @decAmnt=0 ))
			UPDATE inv.tblStorageDocsHdr 
			SET VisitorCost =ROUND(@VisitorPursantAmount,0)
			WHERE ProcessID  = 90 AND
				ProcessNo  = @ProcessNo AND
				FiscalYear = @FiscalYear AND
				SerialNo   = @SerialNo 
		else IF @decPrc>0 AND @decAmnt>0
		BEGIn
	
			SET @VisitorPursantAmount = @decAmnt
		END	
	SELECT ROUND(@VisitorPursantAmount,0)  VisitorCost
END
GO
