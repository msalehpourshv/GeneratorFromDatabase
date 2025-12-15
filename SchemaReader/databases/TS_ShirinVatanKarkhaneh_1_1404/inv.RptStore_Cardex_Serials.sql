USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/ZiA
-- Create date   : 1394/11/21
-- Viewed By	 : 
-- Last Modified : 1394/11/21
-- Last Modifier : TakroSystem/ZiA
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[RptStore_Cardex_Serials]
	@SerialPrefix		Varchar(20),
	@ProductSerialNo	Varchar(30),
	@DateFr				char(10) = '0000/00/00',
	@DateTo				char(10) = '9999/99/99',
	@RepOptions			varchar(20) = '0101',
	@RepInfo			varchar(50) = '1@1@1',
	@ExtraParams		nvarchar(500) = ''
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @PSID  int;
DECLARE @PSCID  varchar(20);

DECLARE @ProductSerialNoTo  Varchar(30);

BEGIN
	--============== S T A R T  C O D E ===================================================
	Set NoCount On;
	
	SET @LanguageID			= pub.funGetCurrentLanguageID();
	SET @ProductSerialNoTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @PSCID	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 

	Set @StrSelect = '';
	Set @StrWhere = '1 = 1';
	Set @PSID = 0

	-- ===========================================		
	BEGIN TRY
		DROP TABLE ##tbl_SerialsTmp		
	END TRY
	BEGIN CATCH
	END CATCH
	
	print @ProductSerialNo
	--Select @PSID = ProductSerialID
	Select PSerialNo
	Into ##tbl_SerialsTmp
	From inv.tblStorageDocsSerials a 
		 LEFT JOIN pln.tblProductSerials S ON S.ProductSerialID = a.ProductSerialID			
	Where (Case When @ProductSerialNo <> '' And @ProductSerialNo Is Not Null Then PSerialNo Else '1' End >= 
		  Case When @ProductSerialNo <> '' And @ProductSerialNo Is Not Null Then @ProductSerialNo Else '1' End 
		  AND 
		  Case When @ProductSerialNoTo <> '' And @ProductSerialNoTo Is Not Null Then PSerialNo Else '1' End <= 
		  Case When @ProductSerialNoTo <> '' And @ProductSerialNoTo Is Not Null Then @ProductSerialNoTo Else '1' End 
		  AND 
		  Case When @SerialPrefix <> '' And @SerialPrefix Is Not Null Then S.SerialPrefix Else '1' End = 
		  Case When @SerialPrefix <> '' And @SerialPrefix Is Not Null Then @SerialPrefix Else '1' End
		  AND @ProductSerialNo<>'')
		  OR (@PSCID <>'' AND PSerialCID=@PSCID )
		
	--select * from ##tbl_SerialsTmp
	-- ===========================================		
	Select S.*, ISNULL(D.DocDate,'') DocDate, ISNULL(D.DescDtl,'') DescDtl, ISNULL(D.StoreID,'')StoreID,pub.funGetProcessNameWithProcessNo(ISNULL(D.ProcessID,''),ISNULL(D.ProcessNo,1)) ProcessName
	From inv.tblStorageDocsSerials S
	LEFT Join inv.tblStorageDocsDtl D on D.ProcessID = S.ProcessID
			and D.ProcessNo  = S.ProcessNo
			and D.FiscalYear = S.FiscalYear
			and D.SerialNo   = S.SerialNo
			and D.DocRowNo   = S.DocRowNo
	--LEFT Join (select * from sal.tblSaleOrderDtl WHERE ProcessID  in (188,189)) D2 on D2.ProcessID = S.ProcessID
	--		and D2.ProcessNo  = S.ProcessNo
	--		and D2.FiscalYear = S.FiscalYear
	--		and D2.SerialNo   = S.SerialNo
	--		and D2.DocRowNo   = S.DocRowNo
	--left join pub.tblProcess P on P.ProcessID=D.ProcessID and P.ProcessNo=D.ProcessNo
	--left join pub.tblProcess P2 on P2.ProcessID=D2.ProcessID and P2.ProcessNo=D2.ProcessNo
	where PSerialNo In (Select PSerialNo From ##tbl_SerialsTmp) 
		  and ((D.DocDate >= @DateFr and D.DocDate <= @DateTo)  )
	order By ISNULL(D.DocDate,''),D.VolumeRowNo, S.EventNo
	
	---- Run -----------------------------------------------------
	--Print @StrSelect;
	--Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
