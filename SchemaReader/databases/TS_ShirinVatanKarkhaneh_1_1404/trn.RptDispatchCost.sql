USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Taha Esmaeili
-- Creation Date : 1400/11/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE trn.RptDispatchCost
	@ProcessID			Int = 0,
	@ProcessNo	    	Int = 0,
	@FiscalYearFr		Int = 0,
	@SerialNoFr	    	Int = 0,
    @FiscalYearTo	    Int = 0,	
	@SerialNoTo			Int = 0,
    @RepOptions			VarChar(10) = '', 
	@RepInfo			NVarChar(100) = '',
	@ExtraParams	    NVarChar(400) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect			NVarChar(max);
Declare @StrWhere			NVarChar(2048);

Begin --============== S T A R T  C O D E ===================================================

	set @StrWhere=''
	-- Acnt Filter 
	IF (@SerialNoFr <>0)
		SET @StrWhere = @StrWhere + ' AND (DD.SerialNo >=' + LTrim(Str(@SerialNoFr)) + ')'	
	IF (@SerialNoTo  <>0)
		SET @StrWhere = @StrWhere + ' AND (DD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'		
	
 	
	Set @StrSelect = '
		SELECT DD.*,[acc].[funGetAcntFullName_LastLayers](CostAcntCode) CostAcntName , D.FirstName + '' '' + D.LastName as name, DH.DocDate, DH.DocDesc
          FROM trn.tblDispatchCostDtl  DD
		  inner join trn.tblDispatchCostHdr DH on DH.ProcessID=DD.ProcessID and DH.SerialNo=DD.SerialNo 
		  inner join pub.tblDriversDtl D on D.DriverID=DH.DriverID
          WHERE DD.ProcessID =' +  LTrim(Str(@ProcessID))  + @StrWhere +' ORDER BY DD.SerialNo, DD.DocRowNo '


               
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	
End
GO
