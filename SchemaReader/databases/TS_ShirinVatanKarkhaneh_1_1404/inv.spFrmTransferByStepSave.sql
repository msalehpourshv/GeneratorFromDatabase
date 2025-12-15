USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [inv].[spFrmTransferByStepSave]
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @IsNewDoc		BIT
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;

---------------------------------------------------------------------------------------
	--IF @IsNewDoc = 0
	--BEGIN
		--DELETE FROM [inv].[tblStorageDocsHdr]
		--WHERE	ProcessID = 125 AND 
				--ProcessNo = @ProcessNo AND 
				--FiscalYear = @FiscalYear AND 
				--SerialNo = @SerialNo 

		--DELETE FROM [inv].[tblStorageDocsDtl]
		--WHERE	ProcessID = 125 AND 
				--ProcessNo = @ProcessNo AND 
				--FiscalYear = @FiscalYear AND 
				--SerialNo = @SerialNo 

	--END

---------------------------------------------------------------------------------------
	SELECT * INTO #tblTransferHdr 
	FROM inv.tblStorageDocsHdr 
	WHERE	ProcessID = @ProcessID AND 
			ProcessNo = @ProcessNo AND 
			FiscalYear = @FiscalYear AND 
			SerialNo = @SerialNo 

	UPDATE #tblTransferHdr
	SET StoreID=StoreID2 , StoreID2=StoreID , ProcessID=125 

	declare @DocDate varchar(10)=''
	declare @DocDate3 varchar(10)=''
	select @DocDate=DocDate,@DocDate3=DocDate3 from #tblTransferHdr
	IF @DocDate3<>'' and @DocDate3>@DocDate
		SET @DocDate = @DocDate3

	IF 	(SELECT COUNT(*)
		 FROM inv.tblStorageDocsDtl
		 WHERE	ProcessID = 125 AND 
				ProcessNo = @ProcessNo AND 
				FiscalYear = @FiscalYear AND 
				SerialNo = @SerialNo )=0
	BEGIN

		INSERT INTO [inv].[tblStorageDocsHdr]
		SELECT * FROM #tblTransferHdr

---------------------------------------------------------------------------------------

		SELECT * INTO #tblTransferDtl 
		FROM inv.tblStorageDocsDtl
		WHERE	ProcessID = @ProcessID AND 
				ProcessNo = @ProcessNo AND 
				FiscalYear = @FiscalYear AND 
				SerialNo = @SerialNo 

		UPDATE #tblTransferDtl
		SET StoreID=StoreID2 , StoreID2=StoreID ,DocDate=@DocDate, ProcessID=125,EnterKind=1,VolumeRowNo=0,GoodsQuantity = GoodsQuantity +Wage,SubUnitQuantity = SubUnitQuantity  +Wage


		INSERT INTO [inv].[tblStorageDocsDtl]
		SELECT * FROM #tblTransferDtl

		DROP TABLE #tblTransferDtl

	---------------------------------------------------------------------------------------
		SELECT * INTO #tblTransferSerials
		FROM inv.tblStorageDocsSerials
		WHERE	ProcessID = @ProcessID AND 
				ProcessNo = @ProcessNo AND 
				FiscalYear = @FiscalYear AND 
				SerialNo = @SerialNo 

		UPDATE #tblTransferSerials
		SET ProcessID=125,ContainerID=ContainerID2,ContainerID2=ContainerID,ContainerStoresID=ContainerStoresID2,ContainerStoresID2=ContainerStoresID, StoreID=b.StoreID2, EnterKind=1
		FROM #tblTransferSerials a
		INNER JOIN inv.tblStorageDocsDtl b
		ON  a.ProcessID = b.ProcessID 
		and a.ProcessNo=b.ProcessNo
		and a.FiscalYear=b.FiscalYear
		and a.SerialNo=b.SerialNo
		and a.DocRowNo=b.DocRowNo

		INSERT INTO [inv].[tblStorageDocsSerials]
		SELECT * FROM #tblTransferSerials

		DROP TABLE #tblTransferSerials
	END
	ELSE
	BEGIN
		UPDATE  [inv].[tblStorageDocsDtl]
		SET DocDate = @DocDate
		WHERE	ProcessID = 125 AND 
				ProcessNo = @ProcessNo AND 
				FiscalYear = @FiscalYear AND 
				SerialNo = @SerialNo AND 
				DocDate <> @DocDate
 
	END
	IF 	(SELECT COUNT(*) FROM inv.tblStorageDocsSerials 
			WHERE	ProcessID = 125 AND ProcessNo = @ProcessNo AND 
			FiscalYear = @FiscalYear AND SerialNo = @SerialNo )
		<>
		(SELECT COUNT(*) FROM inv.tblStorageDocsSerials 
			WHERE	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND 
			FiscalYear = @FiscalYear AND SerialNo = @SerialNo )
		and (SELECT COUNT(*) FROM inv.tblStorageDocsDtl
			 WHERE	ProcessID = 125 AND ProcessNo = @ProcessNo AND 
			FiscalYear = @FiscalYear AND SerialNo = @SerialNo )>0
	BEGIN

		insert into inv.tblStorageDocsSerials (ProcessID	,ProcessNo	,FiscalYear	,SerialNo	,DocRowNo	,AtomRowNo	,DocAtomRowNo	,ProductSerialID	,EventNo	,BatchNo	,ExpireDate	,PSerialNo	,StoreID	,EnterKind	,NumberPerSerial	,ContainerID	,NumberPerContainer	,SerialDesc	,ContainerWeight	,ContainerID2	,SerialGoodsWeight	,ProductSerialID2	,PSerialNo2	,Confirmed	,DescRetSaleID	,SubUnitNumberPerContainer	,ContainerStoresID	,ContainerStoresID2	,ProductionDate)
		
		select 125	,ProcessNo	,FiscalYear	,SerialNo	,DocRowNo	,AtomRowNo	,DocAtomRowNo	,ProductSerialID	,EventNo	,BatchNo	,ExpireDate	,PSerialNo	
		,(SELECT StoreID2	FROM inv.tblStorageDocsHdr 	WHERE	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND 
			FiscalYear = @FiscalYear AND SerialNo = @SerialNo )
			,1	,NumberPerSerial	,ContainerID	,NumberPerContainer	,SerialDesc	,ContainerWeight	,ContainerID2	,SerialGoodsWeight	,ProductSerialID2	,PSerialNo2	,Confirmed	,DescRetSaleID	,SubUnitNumberPerContainer	,ContainerStoresID	,ContainerStoresID2	,ProductionDate from inv.tblStorageDocsSerials 
		where ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo
		and PSerialNo in (
						SELECT PSerialNo FROM inv.tblStorageDocsSerials 
							WHERE	ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo
						except
						SELECT PSerialNo FROM inv.tblStorageDocsSerials 
							WHERE	ProcessID = 125 AND ProcessNo = @ProcessNo AND FiscalYear = @FiscalYear AND SerialNo = @SerialNo
							)
	end 

	DROP TABLE #tblTransferHdr

END


GO
