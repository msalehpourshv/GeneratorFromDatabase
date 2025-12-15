USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/12/02
-- Viewed By	 : 
-- Last Modified : 93/07/26
-- Description   : 
-- =============================================			   
Create PROCEDURE [sal].[spFrmSaleOrderHdrListSelect]
	@ProcessID		Smallint,
	@ProcessNo		tinyint,
	@DocStep		tinyint,
	@DocDate		Char(10),
	@AcntCode		Varchar(20),--,	@RetuenSalBackToOrder BIT 	
	@FilterInfo		NVarChar(100) = '@@0@0@@0@1@0@0@0@0@0'

WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

DECLARE @SalRet_RetToSalOdr AS BIT
DECLARE @LanguageID AS TinyInt
DECLARE @PreSaleDocStep Tinyint
DECLARE @PreSal_GetRemain AS BIT

DECLARE @FromDate		Char(10);
DECLARE @ToDate	    	Char(10);
DECLARE @FromSerialNo	Int;
DECLARE @ToSerialNo		Int;
DECLARE @FromYear		Int;
DECLARE @ToYear			Int;
DECLARE @RowDesc		NVarChar(4000);
DECLARE @UserID			NVarChar(4000);
DECLARE @UserIsAdmin	BIT;

Declare @iAcntStart	TinyInt;
Declare @iAcntLen	TinyInt;
Declare @iTempLen	TinyInt;
Declare @pPartLen	TinyInt;
Declare @pAcntStart	TinyInt;
Declare @pAcntLen	TinyInt;

Declare @Part1Start	TinyInt;
Declare @Part1Len	TinyInt;

Declare @Part2Start	TinyInt;
Declare @Part2Len	TinyInt;

Declare @Part3Start	TinyInt;
Declare @Part3Len	TinyInt;

Declare @Part4Start	TinyInt;
Declare @Part4Len	TinyInt;

Declare @LimitState1	int;
Declare @LimitState2	int;
Declare @LimitState3	int;
Declare @LimitState4	int;
Declare @ConfirmCount	int;
Declare @Confirm		int;
DECLARE @Sgn1			BIT;
DECLARE @Sgn2			BIT;
DECLARE @Sgn3			BIT;
DECLARE @Sgn4			BIT;
DECLARE @Sgn5			BIT;
DECLARE @LineConfirm	BIT;
DECLARE @ProgrammabilitySate	int;

--================================
Set @FromDate		=''
Set @ToDate	    	=''
Set @FromSerialNo	=0
Set @ToSerialNo		=0
Set @RowDesc		=''
	
	-- Init -------------------------------------------------
	IF (@FilterInfo Is Null)	SET @FilterInfo ='@@0@0@@0@1@0@0@0@0@0'

	SET @FromDate		= pub.funSplitString(@FilterInfo, '@', 1);
	SET @ToDate			= pub.funSplitString(@FilterInfo, '@', 2);
	SET @FromSerialNo	= pub.funSplitString(@FilterInfo, '@', 3);
	SET @ToSerialNo		= pub.funSplitString(@FilterInfo, '@', 4);
	SET @RowDesc		= pub.funSplitString(@FilterInfo, '@', 5);
	SET @UserID			= pub.funSplitString(@FilterInfo, '@', 6);
	SET @UserIsAdmin	= pub.funSplitString(@FilterInfo, '@', 7);
	SET @LineConfirm	= pub.funSplitString(@FilterInfo, '@', 8);
	SET @FromYear		= pub.funSplitString(@FilterInfo, '@', 9);
	SET @ToYear			= pub.funSplitString(@FilterInfo, '@', 10);
	SET @ConfirmCount	= pub.funSplitString(@FilterInfo, '@', 12);
	SET @Sgn1			= pub.funSplitString(@FilterInfo, '@', 13);
	SET @Sgn2			= pub.funSplitString(@FilterInfo, '@', 14);
	SET @Sgn3			= pub.funSplitString(@FilterInfo, '@', 15);
	SET @Sgn4			= pub.funSplitString(@FilterInfo, '@', 16);
	SET @Sgn5			= pub.funSplitString(@FilterInfo, '@', 17);
	SET @Confirm		= pub.funSplitString(@FilterInfo, '@', 18);
	SET @ProgrammabilitySate	= pub.funSplitString(@FilterInfo, '@', 21);
	
	SET @SalRet_RetToSalOdr = 'False'
	SET @LanguageID = pub.funGetCurrentLanguageID()
	SET @PreSal_GetRemain = 'False'

	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @PreSal_GetRemain=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PreSal_GetRemain'

	--=====================================
	If @UserIsAdmin = 1
	Begin
		SET	@LimitState1 = 1
		SET	@LimitState2 = 1
		SET	@LimitState3 = 1
		SET	@LimitState4 = 1
	End
	Else
	Begin
		SELECT	TOP 1 @LimitState1 = 1
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 1) AND AccessAllCode = 'True'

		SET @LimitState1 = IsNull(@LimitState1, -1);

		SELECT	TOP 1 @LimitState2 = 1
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 2) AND AccessAllCode = 'True'

		SET @LimitState2 = IsNull(@LimitState2, -1);

		SELECT	TOP 1 @LimitState3 = 1
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 3) AND AccessAllCode = 'True'

		SET @LimitState3 = IsNull(@LimitState3, -1);

		SELECT	TOP 1 @LimitState4 = 1
		FROM	acc.tblAcntRng
		WHERE	(UserID = @UserID) AND (PartNumber = 4) AND AccessAllCode = 'True'

		SET @LimitState4 = IsNull(@LimitState4, -1);
	End

	-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT	@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
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

	-----------------------------
	--------------------------------------------------------------------	
	Declare @InSaleOrderDonotShowWithoutVchNoInPreSale AS bit
	SELECT @InSaleOrderDonotShowWithoutVchNoInPreSale = SettingValue FROM pub.tblSettings WHERE SettingKey = 'InSaleOrderDonotShowWithoutVchNoInPreSale'

	set @InSaleOrderDonotShowWithoutVchNoInPreSale=isnull(@InSaleOrderDonotShowWithoutVchNoInPreSale,'False')
	Declare @CustomerPartNo AS Tinyint
	SET @CustomerPartNo = 0
	
	SELECT @CustomerPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	Declare @CustomerPartStart	TinyInt;
	Declare @CustomePartLen		TinyInt;
	Declare @CustomeLimitState	int;
		
	---- CALC LEN ----
	If (@CustomerPartNo=1)
	begin
		set @CustomerPartStart  = @Part1Start
		set @CustomePartLen		= @Part1Len
		set @CustomeLimitState  = @LimitState1
	end
		
	Else If (@CustomerPartNo=2)
	begin
		set @CustomerPartStart  = @Part2Start
		set @CustomePartLen		= @Part2Len
		set @CustomeLimitState  = @LimitState2
	end

	Else If (@CustomerPartNo=3)
	begin
		set @CustomerPartStart  = @Part3Start
		set @CustomePartLen		= @Part3Len
		set @CustomeLimitState  = @LimitState3
	end

	Else If (@CustomerPartNo=4)
	begin
		set @CustomerPartStart  = @Part4Start
		set @CustomePartLen		= @Part4Len
		set @CustomeLimitState  = @LimitState4
	end
	if @Part2Len=0
		SET	@LimitState2 = 1
	if @Part3Len=0
		SET	@LimitState3 = 1
	if @Part4Len=0
		SET	@LimitState4 = 1

	--set @pAcntLen = pub.funLayerSum('acc.tblAcnt', @CustomerPartNo, @LevelNo)
	--Set @iAcntLen = @iTempLen + @pAcntLen
	--Set @iAcntStart = 1

	--=====================================
	--=====================================	 
	IF @ProcessID = 240 AND @DocStep = 0
	
		SELECT Distinct  ProcessID,
			   ProcessNo,
			   FiscalYear,
			   SerialNo,
			   DocDate,
			   DocDesc,
			   AcntCode,
			   [pub].[GetCodeName](AcntCode,@LanguageID) AcntName,
			   Price,
			   Amount SumPrice,
			   DocDesc2
		FROM inv.tblPreSaleHdr
		WHERE ProcessID= @ProcessID 
		  AND ProcessNo= @ProcessNo 
		  AND ConfirmState <> 2 
		  AND (@AcntCode IS NULL OR (@AcntCode IS NOT NULL AND AcntCode = @AcntCode )) 
		  AND (@FromDate ='' OR (@FromDate <> '' AND DocDate >= @FromDate )) 
		  AND (@ToDate ='' OR (@ToDate <> '' AND DocDate <= @ToDate )) 
		  AND (@FromSerialNo =0 OR (@FromSerialNo <> 0 AND SerialNo >= @FromSerialNo )) 
		  AND (@ToSerialNo =0 OR (@ToSerialNo <> 0 AND SerialNo  <= @ToSerialNo )) 
		  AND (@FromYear =0 OR (@FromYear <> 0 AND FiscalYear >= @FromYear )) 
		  AND (@ToYear =0 OR (@ToYear <> 0 AND FiscalYear  <= @ToYear )) 
		  AND (@RowDesc ='' OR (@RowDesc <> '' AND DocDesc Like '%'+@RowDesc+'%' )) 
		  AND (@InSaleOrderDonotShowWithoutVchNoInPreSale='False' or VchNo<>0)
		
	ELSE IF @ProcessID = 240 AND @DocDate = '' 
		SELECT Distinct ProcessID,
			   ProcessNo,
			   FiscalYear,
			   SerialNo,
			   DocDate,
			   DocDesc,
			   AcntCode,
			   [pub].[GetCodeName](AcntCode,@LanguageID) AcntName,
			   Price,
			   Amount SumPrice
		FROM inv.tblPreSaleHdr
		WHERE ProcessID= @ProcessID 
		  AND ProcessNo= @ProcessNo 
		  AND DocStep=@DocStep 
		  AND ConfirmState <> 2 
		  AND (@AcntCode IS NULL OR (@AcntCode IS NOT NULL AND AcntCode LIKE @AcntCode+'%' )) 
		  AND (@FromDate ='' OR (@FromDate <> '' AND DocDate >= @FromDate )) 
		  AND (@ToDate ='' OR (@ToDate <> '' AND DocDate <= @ToDate )) 
		  AND (@FromSerialNo =0 OR (@FromSerialNo <> 0 AND SerialNo >= @FromSerialNo )) 
		  AND (@ToSerialNo =0 OR (@ToSerialNo <> 0 AND SerialNo  <= @ToSerialNo )) 
		  AND (@FromYear =0 OR (@FromYear <> 0 AND FiscalYear >= @FromYear )) 
		  AND (@ToYear =0 OR (@ToYear <> 0 AND FiscalYear  <= @ToYear )) 
		  AND (@RowDesc ='' OR (@RowDesc <> '' AND DocDesc Like '%'+@RowDesc+'%' )) 
		  AND ConfirmState<>2 
		  AND (@InSaleOrderDonotShowWithoutVchNoInPreSale='False' or VchNo<>0)

	ELSE IF @DocDate = ''
		BEGIN	
			IF @ProcessID = 180 AND @DocStep = 0
			   SELECT d.ProcessID,d.ProcessNo,d.FiscalYear,d.SerialNo,d.DocDate,
					  d.AcntCode,[pub].[GetCodeName](d.AcntCode,@LanguageID) AcntName,
						Price,Amount SumPrice
			   FROM sal.tblSaleOrderHdr d
			   WHERE d.ProcessID = @ProcessID AND 
					 d.ProcessNo = @ProcessNo AND 
					((@ProgrammabilitySate = 0 AND d.ProgrammabilitySate = 0) OR 
					 (@ProgrammabilitySate = 1 AND d.ProgrammabilitySate = 1) OR 
					 (@ProgrammabilitySate = 2 AND d.ProgrammabilitySate = 2) OR
					 (@ProgrammabilitySate = 3 AND d.ProgrammabilitySate in (0,1,2))) AND  
					((@UserIsAdmin = 1 OR @LimitState1 = 1) OR Substring(d.AcntCode, @Part1Start, @Part1Len) ='' OR  (@LimitState1 = -1 AND  Substring(d.AcntCode, @Part1Start, @Part1Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 1 And (@LimitState1 = 1 OR (acc.funPermitted(@UserID, AcntCode, 1) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState2 = 1) OR Substring(d.AcntCode, @Part2Start, @Part2Len) ='' OR (@LimitState2 = -1 AND Substring(d.AcntCode, @Part2Start, @Part2Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 2 And (@LimitState2 = 1 OR (acc.funPermitted(@UserID, AcntCode, 2) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState3 = 1) OR Substring(d.AcntCode, @Part3Start, @Part3Len) ='' OR (@LimitState3 = -1 AND Substring(d.AcntCode, @Part3Start, @Part3Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 3 And (@LimitState3 = 1 OR (acc.funPermitted(@UserID, AcntCode, 3) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState4 = 1) OR Substring(d.AcntCode, @Part4Start, @Part4Len) ='' OR (@LimitState4 = -1 AND Substring(d.AcntCode, @Part4Start, @Part4Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 4 And (@LimitState4 = 1 OR (acc.funPermitted(@UserID, AcntCode, 4) = 1)))))
					And (d.AcntCode Like @AcntCode+'%' or  @AcntCode is null) AND 
					(@FromDate ='' OR (@FromDate <> '' AND d.DocDate >= @FromDate )) AND
					(@ToDate ='' OR (@ToDate <> '' AND d.DocDate <= @ToDate )) AND
					(@FromSerialNo =0 OR (@FromSerialNo <> 0 AND d.SerialNo >= @FromSerialNo )) AND
					(@ToSerialNo =0 OR (@ToSerialNo <> 0 AND d.SerialNo  <= @ToSerialNo )) AND
					(@FromYear =0 OR (@FromYear <> 0 AND FiscalYear >= @FromYear )) AND
					(@ToYear =0 OR (@ToYear <> 0 AND FiscalYear  <= @ToYear )) AND
					( DocDesc Like '%'+@RowDesc+'%' ) 
					and (@ConfirmCount=0 
							or(@ConfirmCount>0 
										and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
										and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
						))
						AND (@LineConfirm ='False' OR 
						     (@LineConfirm ='True' AND 
							  (SELECT COUNT(*) FROM sal.tblSaleOrderDtl a 
						       WHERE a.ProcessID=d.ProcessID and 
							         a.ProcessNo=d.ProcessNo and 
							         a.FiscalYear=d.FiscalYear and 
							         a.SerialNo=d.SerialNo and 
									 a.LineConfirm='False'
							  )>0
							 )
							)
				

			ELSE IF @ProcessID = 180 AND @SalRet_RetToSalOdr = 'False'
			BEGIN	
			   SELECT d.ProcessID,d.ProcessNo,d.FiscalYear,d.SerialNo,d.DocDate,
					  d.AcntCode,[pub].[GetCodeName](d.AcntCode,@LanguageID) AcntName,
					  Price,Amount SumPrice, d.ProgrammabilitySate
			   FROM sal.tblSaleOrderHdr d 
	           WHERE d.ProcessID= @ProcessID AND d.ProcessNo= @ProcessNo AND 
					((@ProgrammabilitySate = 0 AND d.ProgrammabilitySate = 0) OR 
					 (@ProgrammabilitySate = 1 AND d.ProgrammabilitySate = 1) OR 
					 (@ProgrammabilitySate = 2 AND d.ProgrammabilitySate = 2) OR
					 (@ProgrammabilitySate = 3 AND d.ProgrammabilitySate in (0,1,2))) AND  
					(d.DocStep=@DocStep OR @LineConfirm ='True'  OR (d.DocStep>1 AND  @ConfirmCount>0))  AND 
					((@UserIsAdmin = 1 OR @LimitState1 = 1) OR Substring(d.AcntCode, @Part1Start, @Part1Len) ='' OR  (@LimitState1 = -1 AND  Substring(d.AcntCode, @Part1Start, @Part1Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 1 And (@LimitState1 = 1 OR (acc.funPermitted(@UserID, AcntCode, 1) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState2 = 1) OR Substring(d.AcntCode, @Part2Start, @Part2Len) ='' OR (@LimitState2 = -1 AND Substring(d.AcntCode, @Part2Start, @Part2Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 2 And (@LimitState2 = 1 OR (acc.funPermitted(@UserID, AcntCode, 2) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState3 = 1) OR Substring(d.AcntCode, @Part3Start, @Part3Len) ='' OR (@LimitState3 = -1 AND Substring(d.AcntCode, @Part3Start, @Part3Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 3 And (@LimitState3 = 1 OR (acc.funPermitted(@UserID, AcntCode, 3) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState4 = 1) OR Substring(d.AcntCode, @Part4Start, @Part4Len) ='' OR (@LimitState4 = -1 AND Substring(d.AcntCode, @Part4Start, @Part4Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 4 And (@LimitState4 = 1 OR (acc.funPermitted(@UserID, AcntCode, 4) = 1))))) AND
					(d.AcntCode Like @AcntCode+'%' or  @AcntCode is null) AND 
					(@FromDate ='' OR (@FromDate <> '' AND d.DocDate >= @FromDate )) AND
					(@ToDate ='' OR (@ToDate <> '' AND d.DocDate <= @ToDate )) AND
					(@FromSerialNo =0 OR (@FromSerialNo <> 0 AND d.SerialNo >= @FromSerialNo )) AND
					(@ToSerialNo =0 OR (@ToSerialNo <> 0 AND d.SerialNo  <= @ToSerialNo )) AND
					(@FromYear =0 OR (@FromYear <> 0 AND FiscalYear >= @FromYear )) AND
					(@ToYear =0 OR (@ToYear <> 0 AND FiscalYear  <= @ToYear )) AND
					( DocDesc Like '%'+@RowDesc+'%' ) 
					 AND LTRIM(STR(d.FiscalYear)) + '@'+ LTRIM(STR(d.SerialNo)) NOT IN (SELECT LTRIM(STR(BaseFiscalYear)) + '@'+ LTRIM(STR(BaseSerialNo)) FROM sal.tblSaleOrderDtl  WHERE ProcessID=185 AND ProcessNo=@ProcessNo)
						and (@ConfirmCount=0 
							or(@ConfirmCount>0 
										and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
										and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
						))
						AND (@LineConfirm ='False' OR 
						     (@LineConfirm ='True' AND 
							  (SELECT COUNT(*) FROM sal.tblSaleOrderDtl a 
						       WHERE a.ProcessID=d.ProcessID and 
							         a.ProcessNo=d.ProcessNo and 
							         a.FiscalYear=d.FiscalYear and 
							         a.SerialNo=d.SerialNo and 
									 a.LineConfirm='False'
							  )>0
							 )
							)

			END
			ELSE
			BEGIN					
				SELECT d.ProcessID,d.ProcessNo,d.FiscalYear,d.SerialNo,d.DocDate,
					   d.AcntCode,[pub].[GetCodeName](d.AcntCode,@LanguageID) AcntName,
					  Price,Amount SumPrice
				FROM sal.tblSaleOrderHdr d 
				WHERE d.ProcessID= @ProcessID AND d.ProcessNo= @ProcessNo AND  
					(d.DocStep=@DocStep OR @LineConfirm ='True')  AND 
					((@UserIsAdmin = 1 OR @LimitState1 = 1) OR Substring(d.AcntCode, @Part1Start, @Part1Len) ='' OR  (@LimitState1 = -1 AND  Substring(d.AcntCode, @Part1Start, @Part1Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 1 And (@LimitState1 = 1 OR (acc.funPermitted(@UserID, AcntCode, 1) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState2 = 1) OR Substring(d.AcntCode, @Part2Start, @Part2Len) ='' OR (@LimitState2 = -1 AND Substring(d.AcntCode, @Part2Start, @Part2Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 2 And (@LimitState2 = 1 OR (acc.funPermitted(@UserID, AcntCode, 2) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState3 = 1) OR Substring(d.AcntCode, @Part3Start, @Part3Len) ='' OR (@LimitState3 = -1 AND Substring(d.AcntCode, @Part3Start, @Part3Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 3 And (@LimitState3 = 1 OR (acc.funPermitted(@UserID, AcntCode, 3) = 1))))) AND
					((@UserIsAdmin = 1 OR @LimitState4 = 1) OR Substring(d.AcntCode, @Part4Start, @Part4Len) ='' OR (@LimitState4 = -1 AND Substring(d.AcntCode, @Part4Start, @Part4Len) IN 
					(Select AcntCode From acc.tblAcnt Where PartNumber = 4 And (@LimitState4 = 1 OR (acc.funPermitted(@UserID, AcntCode, 4) = 1))))) AND
					(d.AcntCode Like @AcntCode+'%' or  @AcntCode is null) AND 
					(@FromDate ='' OR (@FromDate <> '' AND d.DocDate >= @FromDate )) AND
					(@ToDate ='' OR (@ToDate <> '' AND d.DocDate <= @ToDate )) AND
					(@FromSerialNo =0 OR (@FromSerialNo <> 0 AND d.SerialNo >= @FromSerialNo )) AND
					(@ToSerialNo =0 OR (@ToSerialNo <> 0 AND d.SerialNo  <= @ToSerialNo )) AND
					(@FromYear =0 OR (@FromYear <> 0 AND FiscalYear >= @FromYear )) AND
					(@ToYear =0 OR (@ToYear <> 0 AND FiscalYear  <= @ToYear )) AND
					( DocDesc Like '%'+@RowDesc+'%' ) AND
						(@ConfirmCount=0 
							or(@ConfirmCount>0 
										and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
										and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
						))						AND (@LineConfirm ='False' OR 
						     (@LineConfirm ='True' AND 
							  (SELECT COUNT(*) FROM sal.tblSaleOrderDtl a 
						       WHERE a.ProcessID=d.ProcessID and 
							         a.ProcessNo=d.ProcessNo and 
							         a.FiscalYear=d.FiscalYear and 
							         a.SerialNo=d.SerialNo and 
									 a.LineConfirm='False'
							  )>0
							 )
							)

	
			END	
			
		END
		          
	ELSE IF @ProcessID = 180 Or @ProcessID = 185
		BEGIN	
 
 			IF @SalRet_RetToSalOdr = 'False'					
				SELECT * FROM (
				SELECT DISTINCT acc.funIsCodeClosed(Cnf.AcntCode) IsCodeClosed, Cnf.ProcessID, Cnf.ProcessNo, Cnf.FiscalYear, Cnf.SerialNo,
								DocDate, AcntCode, [pub].[GetCodeName](AcntCode,@LanguageID) AcntName
				From 
					(
						Select d.ProcessID , d.ProcessNo , d.FiscalYear , d.SerialNo , d.DocRowNo ,   GoodsQuantity ,d.DocDate,d.AcntCode
						From sal.tblSaleOrderDtl d 
						inner join sal.tblSaleOrderHdr h
						   on d.ProcessID=h.ProcessID AND d.ProcessNo = h.ProcessNo  AND d.FiscalYear = h.FiscalYear  AND d.SerialNo = h.SerialNo 
					Where d.ProcessID = 180  and d.ProcessNo= @ProcessNo AND
					   ((@ProgrammabilitySate = 0 AND h.ProgrammabilitySate = 0) OR 
					    (@ProgrammabilitySate = 1 AND h.ProgrammabilitySate = 1) OR 
					    (@ProgrammabilitySate = 2 AND h.ProgrammabilitySate = 2) OR
					    (@ProgrammabilitySate = 3 AND h.ProgrammabilitySate in (0,1,2))) and 
						(
							(@ConfirmCount=0 and (	(@Confirm=0 and h.DocStep=1)
													or(@Confirm=1 and h.DocStep=2)
													)
							) 
							or(@ConfirmCount>0 
							and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
							and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
							and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
							and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
							and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
						) OR @ProcessID = 185)
					) Cnf
					LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
								, BaseDocRowNo , SUM(GoodsQuantity) GoodsQuantity
						From sal.tblSaleOrderDtl 
						Where BaseProcessID = 180 and ProcessNo= @ProcessNo
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
								BaseDocRowNo
					) Rtn
					ON	Cnf.ProcessID  = Rtn.BaseProcessID  AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
						Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo  = Rtn.BaseSerialNo AND 
						Cnf.DocRowNo   = Rtn.BaseDocRowNo
					LEFT JOIN 
					(	
						Select	BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
								BaseDocRowNo, SUM(GoodsQuantity) GoodsQuantity
						From inv.tblStorageDocsDtl 
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
					) Stg
					ON	Cnf.ProcessID = Stg.BaseProcessID AND Cnf.ProcessNo = Stg.BaseProcessNo AND 
						Cnf.FiscalYear = Stg.BaseFiscalYear AND Cnf.SerialNo = Stg.BaseSerialNo AND 
						Cnf.DocRowNo = Stg.BaseDocRowNo
				WHERE	Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) - ISNULL(Stg.GoodsQuantity,0) > 0  AND
						DocDate<=@DocDate AND
						( @AcntCode IS NULL OR AcntCode=@AcntCode) 
				) A WHERE IsCodeClosed = 0
				
			ELSE						
				SELECT * FROM (
				SELECT DISTINCT acc.funIsCodeClosed(Cnf.AcntCode) IsCodeClosed,Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo 
						,DocDate,AcntCode,[pub].[GetCodeName](AcntCode,@LanguageID) AcntName
				From 
					(
						Select d.ProcessID , d.ProcessNo , d.FiscalYear , d.SerialNo , d.DocRowNo ,   GoodsQuantity ,d.DocDate,d.AcntCode
						From sal.tblSaleOrderDtl  d 
						inner join sal.tblSaleOrderHdr h
						   on d.ProcessID=h.ProcessID AND d.ProcessNo = h.ProcessNo  AND d.FiscalYear = h.FiscalYear  AND d.SerialNo = h.SerialNo 
						Where d.ProcessID = 180 and d.ProcessNo= @ProcessNo and 
							((@ProgrammabilitySate = 0 AND h.ProgrammabilitySate = 0) OR 
							 (@ProgrammabilitySate = 1 AND h.ProgrammabilitySate = 1) OR 
							 (@ProgrammabilitySate = 2 AND h.ProgrammabilitySate = 2) OR
							 (@ProgrammabilitySate = 3 AND h.ProgrammabilitySate in (0,1,2))) AND  
						(
							(@ConfirmCount=0 and (	(@Confirm=0 and h.DocStep=1)
													or(@Confirm=1 and h.DocStep=2)
													)
							) 
							or(@ConfirmCount>0 
							and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
							and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
							and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
							and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
							and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
						)OR @ProcessID = 185)
					) Cnf
					LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
								, BaseDocRowNo , SUM(GoodsQuantity) GoodsQuantity
						From sal.tblSaleOrderDtl 
						Where BaseProcessID = 180 and ProcessNo= @ProcessNo
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
								BaseDocRowNo
					) Rtn
					ON	Cnf.ProcessID  = Rtn.BaseProcessID  AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
						Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo  = Rtn.BaseSerialNo AND 
						Cnf.DocRowNo   = Rtn.BaseDocRowNo
					LEFT JOIN 
					(	
						Select	BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,
								BaseDocRowNo, SUM(GoodsQuantity) GoodsQuantity
						From inv.tblStorageDocsDtl 
						Where BaseProcessID = 180 and BaseProcessNo = @ProcessNo
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
					) Stg
					ON	Cnf.ProcessID = Stg.BaseProcessID AND Cnf.ProcessNo = Stg.BaseProcessNo AND 
						Cnf.FiscalYear = Stg.BaseFiscalYear AND Cnf.SerialNo = Stg.BaseSerialNo AND 
						Cnf.DocRowNo = Stg.BaseDocRowNo
					LEFT JOIN
					(
						SELECT SD.BaseProcessID , SD.BaseProcessNo , SD.BaseFiscalYear , SD.BaseSerialNo , SD.BaseDocRowNo ,GoodsQuantity from 
						(Select	  DISTINCT ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo 
								, BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo 
						From inv.tblStorageDocsDtl 
						WHERE ProcessID = 90 AND BaseProcessID=180 and ProcessNo= @ProcessNo
						)SD
						LEFT JOIN
						(Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
								, BaseDocRowNo , SUM(GoodsQuantity) GoodsQuantity
						From inv.tblStorageDocsDtl 
						WHERE ProcessID = 100 AND BaseProcessID=90 and ProcessNo= @ProcessNo
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
						)SDRet		
						ON	SD.ProcessID = SDRet.BaseProcessID AND SD.ProcessNo = SDRet.BaseProcessNo AND 
							SD.FiscalYear = SDRet.BaseFiscalYear AND SD.SerialNo = SDRet.BaseSerialNo AND 
							SD.DocRowNo = SDRet.BaseDocRowNo	
						WHERE GoodsQuantity IS NOT NULL
					)	SalRet
					ON	Cnf.ProcessID = SalRet.BaseProcessID AND Cnf.ProcessNo = SalRet.BaseProcessNo AND 
						Cnf.FiscalYear = SalRet.BaseFiscalYear AND Cnf.SerialNo = SalRet.BaseSerialNo AND 
						Cnf.DocRowNo = SalRet.BaseDocRowNo
				WHERE	Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) - ISNULL(Stg.GoodsQuantity,0) + ISNULL(SalRet.GoodsQuantity,0) > 0  AND
						DocDate<=@DocDate AND
						( @AcntCode IS NULL OR AcntCode=@AcntCode) 
				) A WHERE IsCodeClosed = 0
	END
	ELSE IF @ProcessID = 240
	BEGIN			

		DECLARE @DocStep1 tinyint
		
		DECLARE @HasConfirmForPreSale AS BIT
		
		SET @HasConfirmForPreSale = 'False'
		
		SELECT @HasConfirmForPreSale=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'HasConfirmForPreSale'
		
		--============			
		DECLARE @ConfirmState1 tinyint
		DECLARE @ConfirmState2 tinyint		
		DECLARE @PreSaleConfirmDayLimit AS Int
		DECLARE @PreSaleConfirmHourLimit AS Varchar(10)
				
		SELECT @PreSaleConfirmDayLimit=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'PreSaleConfirmDay'	
			
		SELECT @PreSaleConfirmHourLimit=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'PreSaleConfirmHour'	
						
		IF @PreSaleConfirmDayLimit > 0 OR (@PreSaleConfirmHourLimit <> '' and @PreSaleConfirmHourLimit <> '0' )
		Begin
			SET @ConfirmState1 = 1
			SET @ConfirmState2 = 1
		End
		ELSE
		Begin
			SET @ConfirmState1 = 0
			SET @ConfirmState2 = 3
		End				

		IF @HasConfirmForPreSale = 'False' 
			SET @DocStep1 = 1
		ELSE
			SET @DocStep1 = 2
			
		--============			
		DECLARE @DocStepOrd tinyint
		DECLARE @SorHasFirstConfirm AS BIT
		DECLARE @SorHasSecondConfirm AS BIT
		DECLARE @salNotShowPresaleIfRemain AS BIT
				
		SET @SorHasFirstConfirm = 'False'
		SET @SorHasSecondConfirm = 'False'
		SET @salNotShowPresaleIfRemain = 'False'
		
		SELECT @SorHasFirstConfirm = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'Sor_HasFirstConfirm'	
		
		SELECT @SorHasSecondConfirm = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'Sor_HasSecondConfirm'			

		SELECT @salNotShowPresaleIfRemain = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'salNotShowPresaleIfRemain'	

					
		IF @SorHasFirstConfirm = 'False' And @SorHasSecondConfirm = 'False'
			SET @DocStepOrd = 1
		ELSE IF @SorHasFirstConfirm = 'True' And @SorHasSecondConfirm = 'False'
			SET @DocStepOrd = 2
		ELSE IF @SorHasFirstConfirm = 'True' And @SorHasSecondConfirm = 'True'
			SET @DocStepOrd = 3			
						
		IF @PreSaleConfirmDayLimit > 0 OR (@PreSaleConfirmHourLimit <> '' and @PreSaleConfirmHourLimit <> '0' )
		Begin
			SET @ConfirmState1 = 1
			SET @ConfirmState2 = 1
		End
		ELSE
		Begin
			SET @ConfirmState1 = 0
			SET @ConfirmState2 = 3
		End
	 
		SELECT	DISTINCT Cnf.ProcessID, Cnf.ProcessNo, Cnf.FiscalYear, Cnf.SerialNo, Cnf.DocDate, Cnf.AcntCode, 
		                 [pub].[GetCodeName](Cnf.AcntCode,@LanguageID) AcntName
		FROM	inv.tblPreSaleDtl Cnf
		Inner Join (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo from inv.tblPreSaleHdr 
					except	
					SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo from inv.tblStorageDocsDtl where ProcessID=90 and BaseProcessID=240)S
		ON Cnf.ProcessID = S.ProcessID AND Cnf.ProcessNo = S.ProcessNo AND Cnf.FiscalYear = S.FiscalYear AND Cnf.SerialNo = S.SerialNo
		Inner Join (SELECT * from inv.tblPreSaleHdr a
		WHERE ( @salNotShowPresaleIfRemain = 'False' OR 
				 (@salNotShowPresaleIfRemain = 'True' AND (
				     SELECT COUNT(*) FROM sal.tblSaleOrderDtl b 
					 WHERE a.ProcessID = b.BaseProcessID AND a.ProcessNo = b.BaseProcessNo AND 
						   a.FiscalYear = b.BaseFiscalYear AND a.SerialNo = b.BaseSerialNo
					 )=0 )  
				)  and 
			(@InSaleOrderDonotShowWithoutVchNoInPreSale='False' or VchNo<>0) AND a.ConfirmState <> 2

		) PH ON Cnf.ProcessID = PH.ProcessID AND Cnf.ProcessNo = PH.ProcessNo AND 
			                               Cnf.FiscalYear = PH.FiscalYear AND Cnf.SerialNo = PH.SerialNo
		LEFT JOIN (
				Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) GoodsQuantity 
				From sal.tblSaleOrderDtl b
				Where BaseProcessID = 240 AND DocStep = @DocStepOrd AND DocDate <= @DocDate  
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo ,BaseDocRowNo
			) sd

		ON	Cnf.ProcessID = sd.BaseProcessID AND Cnf.ProcessNo = sd.BaseProcessNo AND 
			Cnf.FiscalYear = sd.BaseFiscalYear AND Cnf.SerialNo = sd.BaseSerialNo AND 
			Cnf.DocRowNo = sd.BaseDocRowNo
		WHERE (Cnf.DocStep = @DocStep1 And (PH.ConfirmState >= @ConfirmState1 And PH.ConfirmState <= @ConfirmState2)) And 
			  (@AcntCode IS NULL OR Cnf.AcntCode LIKE  @AcntCode + '%') And Cnf.GoodsQuantity - ISNULL(sd.GoodsQuantity,0) > 0	
			  and (@ConfirmCount=0 
							or(@ConfirmCount>0 
										and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
										and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
						))
			 	 
	END
END
GO
