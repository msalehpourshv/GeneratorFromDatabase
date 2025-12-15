USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        :h.sadeghi
-- Create date   : 1401/07/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.SPCheckProductSerials 
@ProcessID Int, 
@ProcessNo Int, 
@FiscalYear int , 
@SerialNo int,
@EnterKind int,
@LanguageID tinyint,
@PSerialNo varchar(30),
@AfterDelete bit

WITH ENCRYPTION
AS
begin

	declare @DocDate varchar(10)
	declare @VolumeRowNo float
	declare @RetValue INT  -- = 0 موجود نیست در این برگه
						   -- = 1 موجود نیست در این برگه
						   -- = 2 موجودی  سریال منفی
						   -- = 3 موجودی  سریال بیش از یک عدد
						   -- = 4 گردش بعد از این حالت دارد
	if @PSerialNo=''
	BEGIN
		select 1 Val
		return 
	END
    SELECT  @RetValue=COUNT(*)  
    FROM inv.tblStorageDocsSerials 
    WHERE ProcessID = @ProcessID
        AND ProcessNo =  @ProcessNo 
        AND FiscalYear =  @FiscalYear 
        AND SerialNo =  @SerialNo 
        AND PSerialNo = @PSerialNo

	if @AfterDelete=0 AND @RetValue = 0
	BEGIN
		select 1 Val
		return 
	END

	SELECT @RetValue= isnull(sum ( case when d.EnterKind=0 then s.EnterKind else d.EnterKind end )  ,0) 
    FROM inv.tblStorageDocsSerials s 
    INNER JOIN pln.tblProductSerials p 
    ON s.ProductSerialID=p.ProductSerialID 
    INNER JOIN inv.tblStorageDocsDtl d 
    ON d.ProcessID=s.ProcessID AND d.ProcessNo=s.ProcessNo and 
	   d.FiscalYear=s.FiscalYear and s.SerialNo=d.SerialNo and s.DocRowNo=d.DocRowNo 
    WHERE  s.ProcessID NOT IN (180) and s.PSerialNo = @PSerialNo

	If @AfterDelete = 1 
        If @EnterKind = 1 
            SET @RetValue = +1
        Else If @EnterKind = -1 
            SET @RetValue = -1

    If @RetValue = 0 And @EnterKind = 1 
	begin 
		select 2 val
		Return 
	END	
    Else If @RetValue = 1 And @EnterKind = -1 
	begin 
		select 3 val
		Return 
	END	

	IF @AfterDelete = 0
	BEGIN
		SELECT top 1 @DocDate=d.DocDate,@VolumeRowNo=VolumeRowNo
		FROM inv.tblStorageDocsSerials s  
		INNER JOIN inv.tblStorageDocsDtl d 
		ON d.ProcessID=s.ProcessID AND d.ProcessNo=s.ProcessNo and d.FiscalYear=s.FiscalYear and s.SerialNo=d.SerialNo and s.DocRowNo=d.DocRowNo 
		WHERE  s.ProcessID NOT IN (180) and s.PSerialNo = @PSerialNo
			AND d.ProcessID =@ProcessID 
			AND d.ProcessNo = @ProcessNo
			AND d.FiscalYear = @FiscalYear 
			AND d.SerialNo = @SerialNo 

		SET @RetValue = 0
		SELECT @RetValue=COUNT(*)
		FROM inv.tblStorageDocsSerials s  
		INNER JOIN inv.tblStorageDocsDtl d 
		ON d.ProcessID=s.ProcessID AND d.ProcessNo=s.ProcessNo and d.FiscalYear=s.FiscalYear and s.SerialNo=d.SerialNo and s.DocRowNo=d.DocRowNo 
		WHERE  s.ProcessID NOT IN (180) and s.PSerialNo = @PSerialNo
			AND ((d.DocDate= @DocDate and VolumeRowNo>@VolumeRowNo) OR 
				 d.DocDate> @DocDate ) 
	END
	ELSE
	BEGIN
		SET @RetValue = 0
		SELECT @RetValue = COUNT(Balance )
		FROM (
			SELECT (select SUM(case when dd.EnterKind=0 then ss.EnterKind else dd.EnterKind end ) FROM inv.tblStorageDocsSerials ss  
			INNER JOIN inv.tblStorageDocsDtl dd 
			ON dd.ProcessID=ss.ProcessID AND dd.ProcessNo=ss.ProcessNo and dd.FiscalYear=ss.FiscalYear and ss.SerialNo=dd.SerialNo and ss.DocRowNo=dd.DocRowNo 
			WHERE  ss.ProcessID NOT IN (180) and ss.PSerialNo = @PSerialNo AND dd.StoreID=d.StoreID AND (dd.DocDate < d.DocDate OR( dd.DocDate = d.DocDate AND dd.VolumeRowNo<=d.VolumeRowNo))) Balance
			--SUM(d.EnterKind)over (partition by d.StoreID,GoodsID,d.BatchNo,UserPriceID order by d.StoreID,GoodsID,DocDate,VolumeRowNo) Balance
			FROM inv.tblStorageDocsSerials s  
			INNER JOIN inv.tblStorageDocsDtl d 
			ON d.ProcessID=s.ProcessID AND d.ProcessNo=s.ProcessNo and d.FiscalYear=s.FiscalYear and s.SerialNo=d.SerialNo and s.DocRowNo=d.DocRowNo 
			WHERE  s.ProcessID NOT IN (180) and s.PSerialNo = @PSerialNo
			) a
			where Balance<0
	END

    If @RetValue > 0 
	begin 
		select 4 val
		Return 
	END	
	else
		select 0 val

end
GO
