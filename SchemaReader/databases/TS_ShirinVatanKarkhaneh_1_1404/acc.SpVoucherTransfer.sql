USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1396/06/25
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : انتقال اسناد
-- ==============================================
Create Procedure [acc].[SpVoucherTransfer]
	WITH ENCRYPTION
AS
BEGIN

select 'همه ' ProcessName,' 1=1 ' Sql,' 1=1 ' Sql2 ,0 ProcessID,  0 SourceProcessNo, 1  checked
union 
select ' دستی  ' ProcessName,' (SELECT COUNT(*) from acc.tblVoucherDtl b WHERE a.SerialNo=b.SerialNo and SourceProcessID=0 and SourceProcessNo=0)>0 ' Sql 
 ,' SourceProcessID=0 and SourceProcessNo=0'  Sql2 
,0 ProcessID,  0 SourceProcessNo,0 

union 
select Distinct case when SourceProcessNo=1 then ProcessName else ProcessName+' ' +ltrim(rtrim(str(SourceProcessNo))) end
 ,' (SELECT COUNT(*) from acc.tblVoucherDtl b WHERE a.SerialNo=b.SerialNo and SourceProcessID='+str(ProcessID)+' and SourceProcessNo='+str(SourceProcessNo)+')>0 ' Sql 
 ,' SourceProcessID='+str(ProcessID)+' and SourceProcessNo='+str(SourceProcessNo)+' '  Sql2 
 ,ProcessID,  SourceProcessNo,0 from ( select distinct SourceProcessID,SourceProcessNo from acc.tblVoucherDtl  )  a 
inner join  pub.tblProcess b on a.SourceProcessID=b.ProcessID
  WHERE SourceProcessID<>0
order by  ProcessID ,SourceProcessNo,checked Desc
  		
END


GO
