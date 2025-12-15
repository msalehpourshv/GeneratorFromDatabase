USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ==================
-- Author		 : TakroSyatem\Zia
-- Create date   : 1389/12/26
-- Viewed By	 : 
-- Last Modified : 1390/01/17
-- Last Modifier : TakroSyatem\Zia
-- Description   : 
-- ============================================
CREATE PROCEDURE [inv].[SpInvalidSerials] 
	@SessionNo	int
WITH ENCRYPTION
AS 
Begin
---- top0 به خاطر اینکه در سریالها  
-- EventNo
--کارایی ندارد و با تریر کنترل میشود
	select top 0 X.*, S.SerialNo, S.SerialPrefix
	from
	(
		select	ProductSerialID, StoreID, StoreID_Prev as StoreID2, EnterKind_Prev as EnterKind2, +1 as Flag
		from
		(
			select	S2.ProductSerialID, D2.StoreID,
					(
						select	top 1 D1.StoreID
						from	inv.tblStorageDocsDtl D1
									inner join inv.tblStorageDocsSerials S1 on S1.ProcessID = D1.ProcessID and S1.ProcessNo = D1.ProcessNo and S1.FiscalYear = D1.FiscalYear and S1.SerialNo = D1.SerialNo and S1.DocRowNo = D1.DocRowNo
						where	(S1.ProductSerialID = S2.ProductSerialID) and (S1.EventNo < S2.EventNo)
						order by S1.EventNo desc
					) StoreID_Prev,
					(
						select	top 1 D1.EnterKind
						from	inv.tblStorageDocsDtl D1
									inner join inv.tblStorageDocsSerials S1 on S1.ProcessID = D1.ProcessID and S1.ProcessNo = D1.ProcessNo and S1.FiscalYear = D1.FiscalYear and S1.SerialNo = D1.SerialNo and S1.DocRowNo = D1.DocRowNo
						where	(S1.ProductSerialID = S2.ProductSerialID) and (S1.EventNo < S2.EventNo) 
						order by S1.EventNo desc
					) EnterKind_Prev
			from	inv.tblStorageDocsSerials S2 
						inner join inv.tblStorageDocsDtl D2 on S2.ProcessID = D2.ProcessID and S2.ProcessNo = D2.ProcessNo and S2.FiscalYear = D2.FiscalYear and S2.SerialNo = D2.SerialNo and S2.DocRowNo = D2.DocRowNo
			where	(S2.ProductSerialID in (select PSID from inv.tblStorageTempSerials where SessionNo = @SessionNo)) and 
					(D2.EnterKind = -1) 
					
		) OUT 
		where (StoreID_Prev is null) or (StoreID <> StoreID_Prev) or (EnterKind_Prev <> +1)
		union	all
		select	ProductSerialID, StoreID, StoreID_Next as StoreID2, EnterKind_Next as EnterKind2, -1 as Flag
		from
		(
			select	S2.ProductSerialID, D2.StoreID,
					(
						select	top 1 D1.StoreID
						from	inv.tblStorageDocsDtl D1
									inner join inv.tblStorageDocsSerials S1 on S1.ProcessID = D1.ProcessID and S1.ProcessNo = D1.ProcessNo and S1.FiscalYear = D1.FiscalYear and S1.SerialNo = D1.SerialNo and S1.DocRowNo = D1.DocRowNo
						where	(S1.ProductSerialID = S2.ProductSerialID) and (S1.EventNo > S2.EventNo)
						order by S1.EventNo 
					) StoreID_Next,
					(
						select	top 1 D1.EnterKind
						from	inv.tblStorageDocsDtl D1
									inner join inv.tblStorageDocsSerials S1 on S1.ProcessID = D1.ProcessID and S1.ProcessNo = D1.ProcessNo and S1.FiscalYear = D1.FiscalYear and S1.SerialNo = D1.SerialNo and S1.DocRowNo = D1.DocRowNo
						where	(S1.ProductSerialID = S2.ProductSerialID) and (S1.EventNo > S2.EventNo) 
						order by S1.EventNo 
					) EnterKind_Next
			from	inv.tblStorageDocsSerials S2 
						inner join inv.tblStorageDocsDtl D2 on S2.ProcessID = D2.ProcessID and S2.ProcessNo = D2.ProcessNo and S2.FiscalYear = D2.FiscalYear and S2.SerialNo = D2.SerialNo and S2.DocRowNo = D2.DocRowNo
			where	(S2.ProductSerialID in (select PSID from inv.tblStorageTempSerials where SessionNo = @SessionNo)) and 
					(D2.EnterKind = +1) 
					
		) INP 
		where (StoreID <> StoreID_Next) or (EnterKind_Next <> -1)
	) X 
	inner join pln.tblProductSerials S on S.ProductSerialID = X.ProductSerialID
End
GO
