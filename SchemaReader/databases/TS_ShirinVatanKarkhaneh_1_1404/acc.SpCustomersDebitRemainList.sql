USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [acc].[SpCustomersDebitRemainList]
	@Percent		Int,
	@intStartIndex	tinyint,
	@intLen			tinyint 
	
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

	declare @intPart1Len tinyint
	select @intPart1Len = (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9)
	from pub.tblCodeLayer
	where TableName = 'acc.tblAcnt' and PartNumber=1

	SELECT A.AcntCode,AD.AcntName,MaxDebitRemain,SumDebit,V.LastDocDate 
	FROM (SELECT * FROM acc.tblAcnt WHERE MaxDebitRemain>0 AND PartNumber=2) A 
	INNER JOIN 
		(SELECT SUBSTRING(a.AcntCode,@intStartIndex,@intLen) AcntCode ,SUM(Debit-Credit) SumDebit 
		 FROM acc.tblVoucherDtl a
		 INNER join acc.tblAcnt b 
		 ON b.PartNumber = 1 AND b.AcntCode = SUBSTRING(a.AcntCode,1,@intPart1Len) AND b.AcntType NOT IN (91, 92) AND a.VchKind <> 0 
		 GROUP BY SUBSTRING(a.AcntCode,@intStartIndex,@intLen)
		 HAVING SUM(Debit-Credit)>0
		) B
	ON A.AcntCode=B.AcntCode
	INNER JOIN acc.tblAcntDtl AD
	ON AD.AcntCode=A.AcntCode AND A.PartNumber=AD.PartNumber
	INNER JOIN 
		(SELECT SUBSTRING(AcntCode,@intStartIndex,@intLen) AcntCode, MAX(DocDate) LastDocDate 
		FROM acc.tblVoucherDtl WHERE Debit>0
		GROUP BY SUBSTRING(AcntCode,@intStartIndex,@intLen)) V
	ON A.AcntCode=V.AcntCode
	WHERE SumDebit >((MaxDebitRemain * (@Percent ) )/100)
	
END
GO
