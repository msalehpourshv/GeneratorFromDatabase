USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 94/05/31
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--[prd].[SpDeleteInv_Input_CorrectVchNo] 82,1,94,12978
CREATE PROCEDURE [prd].[SpDeleteInv_Input_CorrectVchNo]
	@intProcessID	SmallInt,
	@intProcessNo	TinyInt,
	@intFiscalYear	SmallInt,
	@intSerialNo	Int
WITH ENCRYPTION
AS

BEGIN

	Declare	@ProcessID	SmallInt,
			@ProcessNo	TinyInt,
			@FiscalYear	SmallInt,
			@SerialNo	Int,
			@VchNo		Int
			
		
	select @ProcessID=c.ProcessID,@ProcessNo=c.ProcessNo ,@FiscalYear=c.FiscalYear ,@SerialNo=c.SerialNo ,@VchNo=c.VchNo
	FROM inv.tblStorageDocsHdr c
	Inner join
	(select TOP 1 a.* FROM inv.tblStorageDocsDtl a
	INNER JOIN (
	SELECT TOP 1 BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo 
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID= @intProcessID
	AND ProcessNo= @intProcessNo
	AND FiscalYear= @intFiscalYear
	AND SerialNo= @intSerialNo
	) b
	on a.BaseProcessID=b.BaseProcessID
	AND a.BaseProcessNo=b.BaseProcessNo
	AND a.BaseFiscalYear=b.BaseFiscalYear
	AND a.BaseSerialNo=b.BaseSerialNo
	AND a.BaseDocRowNo=b.BaseDocRowNo
	where a.ProcessID=72
	) d
	on c.ProcessID=d.ProcessID and c.ProcessNo=d.ProcessNo and
	c.FiscalYear=d.FiscalYear and c.SerialNo=d.SerialNo

	 exec [acc].[SpVch_DeleteDoc]  @VchNo ,@ProcessID, @ProcessNo, @FiscalYear ,@SerialNo
	 
END
GO
