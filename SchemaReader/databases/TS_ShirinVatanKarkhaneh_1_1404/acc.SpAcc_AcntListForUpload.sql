USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Reza NP
-- Create date   : 1392/07/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpAcc_AcntListForUpload]
	@AcntPart	int=2,
	@AcntStart	int=2,
	@AcntLen	int=6,
	@ChequeDate	char(10)='1393/05/01'


WITH ENCRYPTION
AS
Begin
	
	create table #tbl_Temp
	(
		AcntCode	varchar(20) collate arabic_cs_as,
		SumAmount	float
	);

	create table #tbl_Acnt
	(
		AcntCode	varchar(20) collate arabic_cs_as,
		DebitRemain	float
	); 
	
 

			
		insert into #tbl_Acnt(AcntCode, DebitRemain)
		select SUBSTRING(V.AcntCode, @AcntStart, @AcntLen), SUM(Debit-Credit)
		from acc.tblVoucherDtl V
		where (VchKind <> 0) 
		group by SUBSTRING(V.AcntCode, @AcntStart, @AcntLen) 

		insert into #tbl_Temp(AcntCode, SumAmount)
		select substring(D.CreditCode, @AcntStart, @AcntLen) CreditCode, SUM(D.Amount) SumAmount
		from trs.tblPayDtl D 
			inner join 
			(
				select VolumeFiscalYear,e.VolumeRowNo
				from trs.tblPayDtl e
				where e.ProcessID in(1,10) AND e.PayTypeID IN (6,26)
				except
				select VolumeFiscalYear,dd.VolumeRowNo
				from trs.tblPayDtl dd
				where dd.ProcessID  IN (12,22,13,24,18) AND dd.PayTypeID IN (6,26)
				except
				select cc.VolumeFiscalYear,cc.VolumeRowNo
				from trs.tblPayDtl cc
				where cc.ProcessID  IN (2) AND cc.PayTypeID IN (6,26) AND cc.ChequeDate < @ChequeDate
			) X on X.VolumeFiscalYear=D.VolumeFiscalYear and X.VolumeRowNo=D.VolumeRowNo
		where D.EventNo=1
			AND D.PayTypeID IN (6,26) 
		group by substring(D.CreditCode, @AcntStart, @AcntLen)
		
		SELECT A.AcntCode,A.VisitPathID1,A.VisitPathID2,A.VisitPathID3,A.VisitPathID4,
		A.CustomerKindID,A.Tel,A.MaxDebitRemain,A.MaxReceivableRemain,A.MaxReturnCheque,
		A.Mobile,A.GPSPoint,AD.LanguageID, AD.AcntName, AD.AcntComment, AD.FirstName, 
		AD.LastName, AD.OrganzationName,AD.Address1, AD.Address2, AD.GradDesc,
		AD.DistributionPoint, AD.AsnafID, AD.TableauText, AD.SensiblePoint,
		AD.PlaceOldName, AD.CustomerFamous, AD.ParticularDateText1, 
		AD.ParticularDateText2, AD.ParticularDateText3,
		AD.ParticularDateText4,	isnull(X.DebitRemain, 0) DebitRemain, 
			isnull(T.SumAmount,0) as ReceivableRemain,
			(
				SELECT	IsNull(COUNT(*), 0)
				FROM	[trs].tblPayDtl AS PD
				WHERE	PD.PayTypeID IN (6,26) AND
						PD.ProcessID IN (13) AND
						PD.ProcessNo = 1 AND
						SUBSTRING(PD.DebitCode, @AcntStart, @AcntLen) = A.AcntCode
			) as ReturnCheque 
		FROM acc.tblAcnt A
			INNER JOIN acc.tblAcntDtl AD ON AD.AcntCode=A.AcntCode AND AD.PartNumber=A.PartNumber 
			left join #tbl_Temp T on T.AcntCode=A.AcntCode
			left join #tbl_Acnt X on X.AcntCode=A.AcntCode
		
		WHERE A.PartNumber=@AcntPart 
	
 
	
End
GO
