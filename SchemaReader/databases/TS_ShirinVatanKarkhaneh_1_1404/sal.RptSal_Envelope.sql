USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/12/21
-- Viewed By	 : 
-- Last Modified : 1393/04/29
-- Last Modifier : Takrosystem\Hamid
-- Description	 : چاپ پاکت
-- ==============================================
Create PROCEDURE [sal].[RptSal_Envelope]
	@ProcessNo		TinyInt = Null,
	@FiscalYear		SmallInt = Null,
	@SerialNo		SmallInt = Null,
	@AcntCode		VarChar(20) = Null,
	@SecondAddr		Bit
WITH ENCRYPTION
AS 

Declare @PartNumber	TinyInt;
Declare @PartStart	TinyInt;
Declare @PartLen	TinyInt;
Declare @LanguageID TinyInt;

Begin --============== S T A R T  C O D E =======================================

	Set NoCount On;

	-- Init ------------------------------------------
	If (@ProcessNo Is Null) Set @ProcessNo = 1;
	SET @LanguageID = pub.funGetCurrentLanguageID();
	--------------------------------------------------

	If (@AcntCode Is Null) AND (@FiscalYear Is Null) AND (@SerialNo Is Null) 
		Return

	If (@AcntCode Is Null) 
		SELECT	@AcntCode = AcntCode
		FROM	inv.tblStorageDocsHdr
		WHERE	ProcessID = 90 AND ProcessNo = @ProcessNo AND
				FiscalYear = @FiscalYear AND SerialNo = @SerialNo

	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
	select @PartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @PartLen=[acc].[FunGetAcntInfoForRemain](3)

	SELECT	Tel, Mobile, OtherTels, LH.AreaCode, LD.LocationName, OrganzationName, ZipCode, 
			CASE WHEN (@SecondAddr = 0)
				THEN Address1
				ELSE Address2
			END AS Address, @AcntCode As AcntCode, [acc].[funGetAcntName](SubString (@AcntCode,@PartStart,@PartLen),@PartNumber, 1) as AcntName
	FROM	acc.tblAcnt A 
				INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber
				LEFT JOIN pub.tblLocationsDtl LD ON A.LocationID = LD.LocationID
				LEFT JOIN pub.tblLocations LH ON A.LocationID = LH.LocationID
	WHERE   A.AcntCode = SubString (@AcntCode,@PartStart,@PartLen) AND A.PartNumber=@PartNumber

End
GO
