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
CREATE PROCEDURE [acc].[SpAcc_AcntListForUpload_WS]
	@AcntPart	int=2,
	@AcntStart	int=2,
	@AcntLen	int=6,
	@ChequeDate	char(10)='1393/05/01',
	@UserID		int=1,
	@IsSayman	bit='False',
	@AllVisitPath Bit='True',
	@AcntConstPart VARCHAR(20)=''

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
    create table #tbl_SaleOrder
	(
		AcntCode	varchar(20) collate arabic_cs_as,
		DocDate		char(10)
	); 

	
	INSERT INTO #tbl_SaleOrder(AcntCode,DocDate)
	SELECT SUBSTRING(S.AcntCode, @AcntStart, @AcntLen),MAX(DocDate)
	FROM	sal.tblSaleOrderHdr AS S
	WHERE	S.ProcessID IN (180)
	GROUP BY SUBSTRING(S.AcntCode, @AcntStart, @AcntLen)

 if @IsSayman='False'
		
	begin
	
		insert into #tbl_Acnt(AcntCode, DebitRemain)
		select SUBSTRING(V.AcntCode, @AcntStart, @AcntLen), SUM(Debit-Credit)
		from acc.tblVoucherDtl V
		where (VchKind <> 0) AND V.AcntCode LIKE @AcntConstPart + '%'
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
		A.CustomerKindID,A.Tel,A.MaxDebitRemain,A.MaxReceivableRemain,A.MaxReturnCheque,A.NationalIDNumber,A.NationalIdentity,
		A.Mobile,A.GPSPoint,AD.LanguageID, AD.AcntName, AD.AcntComment, AD.FirstName, 
		AD.LastName, AD.OrganzationName,AD.Address1, AD.Address2, AD.GradDesc,A.SaleTypeID,AD.FirstName,AD.LastName,
		AD.DistributionPoint, AD.AsnafID, AD.TableauText, AD.SensiblePoint,
		AD.PlaceOldName, AD.CustomerFamous, AD.ParticularDateText1, 
		AD.ParticularDateText2, AD.ParticularDateText3,AD.OrganzationName,AD.TableauText,AD.GradDesc,AD.Address2,
		AD.ParticularDateText4,	isnull(X.DebitRemain, 0) DebitRemain, A.CodeClosed,A.ContainTax,
			isnull(T.SumAmount,0) as ReceivableRemain,
			(
				SELECT	IsNull(COUNT(*), 0)
				FROM	[trs].tblPayDtl AS PD
				WHERE	PD.PayTypeID IN (6,26) AND
						PD.ProcessID IN (13) AND
						PD.ProcessNo = 1 AND
						SUBSTRING(PD.DebitCode, @AcntStart, @AcntLen) = A.AcntCode
			) as ReturnCheque ,
			ISNULL((
				SELECT  DocDate
				FROM	#tbl_SaleOrder AS S
				WHERE	S.AcntCode = A.AcntCode
			),'') as LastSaleOrderDate
		FROM acc.tblAcnt A
			INNER JOIN acc.tblAcntDtl AD ON AD.AcntCode=A.AcntCode AND AD.PartNumber=A.PartNumber 
			left join #tbl_Temp T on T.AcntCode=A.AcntCode
			left join #tbl_Acnt X on X.AcntCode=A.AcntCode
		
		WHERE A.PartNumber=@AcntPart 
			 
			 

		 ---- حیطه
		  AND(
			(Select COUNT(*) from acc.tblAcntRng
				where acc.tblAcntRng.UserID=@UserID AND AllowCodeView=1 AND acc.tblAcntRng.PartNumber=@AcntPart  AND
				(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
			AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
			)>0 
			
			OR 
				(Select COUNT(*) from acc.tblAcntRng
				where  acc.tblAcntRng.UserID=@UserID  and acc.tblAcntRng.PartNumber=@AcntPart  AND AccessAllCode=1)>0
			)
			
		  AND(
			(Select COUNT(*) from acc.tblAcntRng
				where acc.tblAcntRng.UserID=@UserID AND AllowCodeView=0 AND acc.tblAcntRng.PartNumber=@AcntPart  AND
				(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
			AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
			)=0 
			OR
			(Select COUNT(*) from acc.tblAcntRng
				where acc.tblAcntRng.UserID=-1 AND AllowCodeView=0 AND acc.tblAcntRng.PartNumber=@AcntPart  AND
				(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
			AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
			)=0 
			)
				 ---- حیطه آخر
		  AND( @AllVisitPath='True'  OR
---- Path1
		  ((
			(Select COUNT(*) from acc.tblVisitPathRng
				where acc.tblVisitPathRng.PartNumber=1 AND acc.tblVisitPathRng.UserID=@UserID AND AllowCodeView=1 AND
				LEFT(A.VisitPathID1,LEN(A.VisitPathID1))>=LEFT(acc.tblVisitPathRng.FromCode,LEN(A.VisitPathID1))
			AND LEFT(A.VisitPathID1,LEN(A.VisitPathID1))<=LEFT(acc.tblVisitPathRng.ToCode,LEN(A.VisitPathID1))
			)>0 
			
			OR 
				(Select COUNT(*) from acc.tblVisitPathRng
				where  acc.tblVisitPathRng.PartNumber=1 AND acc.tblVisitPathRng.UserID=@UserID and AccessAllCode=1)>0
			)
 ---- Path2
		  AND(
			(Select COUNT(*) from acc.tblVisitPathRng
				where acc.tblVisitPathRng.PartNumber=2 AND acc.tblVisitPathRng.UserID=@UserID AND AllowCodeView=1 AND
				LEFT(A.VisitPathID2,LEN(A.VisitPathID2))>=LEFT(acc.tblVisitPathRng.FromCode,LEN(A.VisitPathID2))
			AND LEFT(A.VisitPathID2,LEN(A.VisitPathID2))<=LEFT(acc.tblVisitPathRng.ToCode,LEN(A.VisitPathID2))
			)>0 
			
			OR 
				(Select COUNT(*) from acc.tblVisitPathRng
				where  acc.tblVisitPathRng.PartNumber=2 AND acc.tblVisitPathRng.UserID=@UserID and AccessAllCode=1)>0
			)
 ---- Path3
		  AND(
			(Select COUNT(*) from acc.tblVisitPathRng
				where acc.tblVisitPathRng.PartNumber=3 AND acc.tblVisitPathRng.UserID=@UserID AND AllowCodeView=1 AND
				LEFT(A.VisitPathID3,LEN(A.VisitPathID3))>=LEFT(acc.tblVisitPathRng.FromCode,LEN(A.VisitPathID3))
			AND LEFT(A.VisitPathID3,LEN(A.VisitPathID3))<=LEFT(acc.tblVisitPathRng.ToCode,LEN(A.VisitPathID3))
			)>0 
			
			OR 
				(Select COUNT(*) from acc.tblVisitPathRng
				where  acc.tblVisitPathRng.PartNumber=3 AND acc.tblVisitPathRng.UserID=@UserID and AccessAllCode=1)>0
			)
---- Path4
		  AND(
			(Select COUNT(*) from acc.tblVisitPathRng
				where acc.tblVisitPathRng.PartNumber=4 AND acc.tblVisitPathRng.UserID=@UserID AND AllowCodeView=1 AND
				LEFT(A.VisitPathID4,LEN(A.VisitPathID4))>=LEFT(acc.tblVisitPathRng.FromCode,LEN(A.VisitPathID4))
			AND LEFT(A.VisitPathID4,LEN(A.VisitPathID4))<=LEFT(acc.tblVisitPathRng.ToCode,LEN(A.VisitPathID4))
			)>0 
			
			OR 
				(Select COUNT(*) from acc.tblVisitPathRng
				where  acc.tblVisitPathRng.PartNumber=4 AND acc.tblVisitPathRng.UserID=@UserID and AccessAllCode=1)>0
			)
		))
						
	end -- end if
	
		
  if @IsSayman='True'
		
	 BEGIN

		insert into #tbl_Acnt(AcntCode, DebitRemain)
		select SUBSTRING(V.AcntCode, @AcntStart, @AcntLen), SUM(Debit-Credit)
		from acc.tblVoucherDtl V
		where (VchKind <> 0) AND V.AcntCode LIKE @AcntConstPart + '%'
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
		A.CustomerKindID,A.Tel,A.MaxDebitRemain,A.MaxReceivableRemain,A.MaxReturnCheque,A.NationalIDNumber,A.NationalIdentity,
		A.Mobile,A.GPSPoint,AD.LanguageID, AD.AcntName, AD.AcntComment, AD.FirstName, 
		AD.LastName, AD.OrganzationName,AD.Address1, AD.Address2, AD.GradDesc,A.SaleTypeID,AD.FirstName,AD.LastName,
		AD.DistributionPoint, AD.AsnafID, AD.TableauText, AD.SensiblePoint,
		AD.PlaceOldName, AD.CustomerFamous, AD.ParticularDateText1, 
		AD.ParticularDateText2, AD.ParticularDateText3,AD.OrganzationName,AD.TableauText,AD.GradDesc,AD.Address2,
		AD.ParticularDateText4,	isnull(X.DebitRemain, 0) DebitRemain, 
			isnull(T.SumAmount,0) as ReceivableRemain, A.CodeClosed,A.ContainTax,
			(
				SELECT	IsNull(COUNT(*), 0)
				FROM	[trs].tblPayDtl AS PD
				WHERE	PD.PayTypeID IN (6,26) AND
						PD.ProcessID IN (13) AND
						PD.ProcessNo = 1 AND
						SUBSTRING(PD.DebitCode, @AcntStart, @AcntLen) = A.AcntCode
			) as ReturnCheque ,
			ISNULL((
				SELECT  DocDate
				FROM	#tbl_SaleOrder AS S
				WHERE	S.AcntCode = A.AcntCode
			),'') as LastSaleOrderDate
		FROM acc.tblAcnt A
			INNER JOIN acc.tblAcntDtl AD ON AD.AcntCode=A.AcntCode AND AD.PartNumber=A.PartNumber 
			left join #tbl_Temp T on T.AcntCode=A.AcntCode
			left join #tbl_Acnt X on X.AcntCode=A.AcntCode
		
		WHERE A.PartNumber=@AcntPart 
		
	END -- end if
	
	
End
GO
