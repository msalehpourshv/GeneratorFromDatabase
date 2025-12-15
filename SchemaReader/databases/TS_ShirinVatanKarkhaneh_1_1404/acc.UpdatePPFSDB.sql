USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/10/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier :
-- ----------------------------------------------
-- Description	 :  بروز رسانی فیلد های کمکی 
-- ==============================================
Create PROCEDURE acc.UpdatePPFSDB
WITH ENCRYPTION
as

BEGIN -- ============================ S T A R T =====================================================
 update acc.tblAccState 
        set PPFS1= right('00000'+LTRIM (rtrim( cast([SourceProcessID1] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo1] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear1] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo1] as char(20)))) , 8) 
        ,PPFS2=    right('00000'+LTRIM (rtrim( cast([SourceProcessID2] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo2] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear2] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo2] as char(20)))) , 8) 
        ,PPFSD1=   right('00000'+LTRIM (rtrim( cast([SourceProcessID1] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo1] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear1] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo1] as char(20)))) , 8) +right('00000'+LTRIM (rtrim( cast([SourceDocRowNo1] as char(20)))) , 5) 
        ,PPFSD2=   right('00000'+LTRIM (rtrim( cast([SourceProcessID2] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo2] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear2] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo2] as char(20)))) , 8) +right('00000'+LTRIM (rtrim( cast([SourceDocRowNo2] as char(20)))) , 5) 
        ,PPFSDB1=  right('00000'+LTRIM (rtrim( cast([SourceProcessID1] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo1] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear1] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo1] as char(20)))) , 8) +right('00000'+LTRIM (rtrim( cast([SourceDocRowNo1] as char(20)))) , 5) +right('00000'+LTRIM (rtrim( cast([BaseID1] as char(20)))) , 5)
        ,PPFSDB2=  right('00000'+LTRIM (rtrim( cast([SourceProcessID2] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo2] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear2] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo2] as char(20)))) , 8) +right('00000'+LTRIM (rtrim( cast([SourceDocRowNo2] as char(20)))) , 5) +right('00000'+LTRIM (rtrim( cast([BaseID2] as char(20)))) , 5)
        where len(PPFS1)<18 or len(PPFS2)<18

update [acc].[tblVoucher2AccState]
        set PPFS1=  right('00000'+LTRIM (rtrim( cast([SourceProcessID] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo] as char(20)))) , 8) 
        ,PPFSD1=    right('00000'+LTRIM (rtrim( cast([SourceProcessID] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo] as char(20)))) , 8) +right('00000'+LTRIM (rtrim( cast([SourceDocRowNo] as char(20)))) , 5) 
        ,PPFSDB1=   right('00000'+LTRIM (rtrim( cast([SourceProcessID] as char(20)))) , 4) +right('00000'+LTRIM (rtrim( cast([SourceProcessNo] as char(20)))) , 2) +right('00000'+LTRIM (rtrim( cast([SourceFiscalYear] as char(20)))) , 4) +right('00000000'+LTRIM (rtrim( cast([SourceSerialNo] as char(20)))) , 8) +right('00000'+LTRIM (rtrim( cast([SourceDocRowNo] as char(20)))) , 5) +right('00000'+LTRIM (rtrim( cast([BaseID] as char(20)))) , 5)
        where len(PPFS1)<18  

END


GO
