USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation Date : 1398/08/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : ثبت تطبیق اتوماتیک
-- ==============================================
Create procedure acc.SpFrmDebitAcntList
@ExtraParams nvarchar(1000)
WITH ENCRYPTION
as
begin


Declare @StrSelect	NVarChar(3000);
Declare @StrWhere	NVarChar(3000);

declare @PartNumber as int
declare @StartLayer as int
declare @LenLayer as int

select @PartNumber=[acc].[FunGetAcntInfoForRemain](1),@StartLayer=[acc].[FunGetAcntInfoForRemain](2),@LenLayer=[acc].[FunGetAcntInfoForRemain](3)



set @StrWhere  =@StrWhere  + ' And A.PartNumber = '+ str (@PartNumber)

SET @StrWhere	    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
 Select A.AcntCode AcntCodePart, A.AcntCode , MaxDebitRemain AcntRemain 
 into #tblRemain From acc.tblAcnt A where 1=0


set @StrSelect=' 
insert into #tblRemain  
select subString (AcntCode, '+str (@StartLayer)+ ', '+str (@LenLayer)+ ') AcntCodePart,AcntCode  ,(IsNull(Sum(Debit), 0) - IsNull(Sum(Credit), 0)) As AcntRemain 
FROM	acc.tblVoucherDtl  
where subString (AcntCode, '+str (@StartLayer)+ ', '+str (@LenLayer)+ ') in ( select AcntCode from   acc.tblAcnt A  where  '  +@StrWhere   +')
group by subString (AcntCode, '+str (@StartLayer)+ ', '+str (@LenLayer)+ '),AcntCode
'
	 Print @StrSelect;
	Exec sp_executesql @StrSelect;

	delete from #tblRemain   where AcntRemain<=0

	--select * from #tblRemain 


set @StrSelect='
Select R.AcntCode ,A.AcntCode AcntCodePart, AD.AcntName, AD.FirstName + '' '' + AD.LastName As Name_Family
 ,VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4 
 ,V1.VisitPathName VisitPathName1 ,V2.VisitPathName VisitPathName2,V3.VisitPathName VisitPathName3,V4.VisitPathName VisitPathName4,LocationID  
 ,AcntRemain,  isnull(A.Tel,''-'') + ''-'' + isnull(A.Mobile,''-'') as TelMobile,MaxDebitRemain
  From acc.tblAcnt A Inner Join acc.tblAcntDtl AD
   ON A.AcntCode = AD.AcntCode And AD.PartNumber = '+str(@PartNumber)+' 
  inner join acc.tblVisitPathDtl V1 on V1.PartNumber=1 and V1.VisitPathID =A.VisitPathID1 
   inner join acc.tblVisitPathDtl V2 on V2.PartNumber=2 and V2.VisitPathID =A.VisitPathID2
    inner join acc.tblVisitPathDtl V3 on V3.PartNumber=3 and V3.VisitPathID =A.VisitPathID3 
	inner join acc.tblVisitPathDtl V4 on V4.PartNumber=4 and V4.VisitPathID =A.VisitPathID4 
	inner join #tblRemain  R on R.AcntCodePart =A.AcntCode 
	Where   '  +@StrWhere   +'
	
	
	ORDER BY A.Sequence
'

	 Print @StrSelect;
	Exec sp_executesql @StrSelect;
	 




end





            --strWhr += "AND (SELECT COUNT(*) from acc.tblAcnt B where B.PartNumber = " &
            --       ClsSettings.funGetIntegerValue(EnmSettings.AcntPartNumberForRemainCalculation) &
            --      " AND substring(B.AcntCode,1,LEN(A.AcntCode))=A.AcntCode )=1 "

            --da.CommandText = "Select A.AcntCode, AD.AcntName, AD.FirstName + ' ' + AD.LastName As Name_Family ,VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4 " &
            -- ",V1.VisitPathName VisitPathName1 ,V2.VisitPathName VisitPathName2,V3.VisitPathName VisitPathName3,V4.VisitPathName VisitPathName4,LocationID " &
            -- " ,(select (IsNull(Sum(Debit), 0) - IsNull(Sum(Credit), 0)) As AcntRemain FROM	acc.tblVoucherDtl D where D.AcntCode = substring (A.AcntCode," & StartLayer & "," & LenLayer & ")) AcntRemain " &
            -- " ,  isnull(A.Tel,'-') + '-' + isnull(A.Mobile,'-') as TelMobile" &
            --"From acc.tblAcnt A " &
            --             "Inner Join acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode And AD.PartNumber = " &
            --             ClsSettings.funGetIntegerValue(EnmSettings.AcntPartNumberForRemainCalculation) &
            --             " inner join acc.tblVisitPathDtl V1 on V1.PartNumber=1 and V1.VisitPathID =A.VisitPathID1 " &
            --             " inner join acc.tblVisitPathDtl V2 on V2.PartNumber=2 and V2.VisitPathID =A.VisitPathID2" &
            --             " inner join acc.tblVisitPathDtl V3 on V3.PartNumber=3 and V3.VisitPathID =A.VisitPathID3" &
            --             " inner join acc.tblVisitPathDtl V4 on V4.PartNumber=4 and V4.VisitPathID =A.VisitPathID4" &
            --             " Where " & strWhr &
            --             " ORDER BY A.Sequence"
            --dtOrder.Clear()
            --da.Fill(dtOrder)
            --'dtgDetail.Rows.Clear()
GO
