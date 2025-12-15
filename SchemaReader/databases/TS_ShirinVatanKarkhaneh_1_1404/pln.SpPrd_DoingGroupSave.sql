USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
create   PROCEDURE [pln].[SpPrd_DoingGroupSave]
	@Date as varchar(10),
	@FiscalYear as int,
	@SerialNo as int,
	@ProductCount as int,
	@ProductWeight as float,
	@RowNo as int 
	
WITH ENCRYPTION
AS
DECLARE @LangID		Char(1);

 BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRAN
   
    INSERT INTO [pln].[tblTaskOrderDtl]
           ([ProcessID]
           ,[ProcessNo]
           ,[FiscalYear]
           ,[SerialNo]
           ,[RowNo]
           ,[DocRowNo]
           ,[ProduceStepID]
           ,[ProduceStepTime]
           ,[ToolID]
           ,[ToolFixTime]
           ,[StartTime]
           ,[FinishTime]
           ,[TotalTime]
           ,[ProductCount]
           ,[AcceptableCount]
           ,[UnacceptableCount]
           ,[OverProduct]
           ,[ProductDeduction]
           ,[StartDate]
           ,[FinishDate]
           ,[ProductCostAmount]
           ,[ProduceStepSerialNo]
           ,[StepToolTime]
           ,[DoingFiscalYear]
           ,[AcceptStoreID]
           ,[FailedStoreID]
           ,[UsageStoreID]
           ,[LossStoreID]
           ,[MobInfo]
           ,[UserPriceID])
    select 
            610 --[ProcessID]
           ,1   --[ProcessNo]
           ,@FiscalYear  --[FiscalYear]
           ,SerialNo   -- [SerialNo]
           ,@RowNo--(SELECT ISNULL(MAX(RowNo),0) + 1 FROM [pln].[tblTaskOrderDtl] WHERE SerialNo = TH.SerialNo  )  -- [RowNo]
           ,@RowNo --(SELECT ISNULL(MAX(DocRowNo),0) + 1 FROM [pln].[tblTaskOrderDtl] WHERE SerialNo = TH.SerialNo  )    --[DocRowNo]
           ,1   --[ProduceStepID]  
           ,0 --[ProduceStepTime]
           ,NULL --[ToolID]
           ,0 --[ToolFixTime]
           ,LEFT(CONVERT(TIME,GETDATE()),5) --[StartTime]
           ,LEFT(CONVERT(TIME,GETDATE()),5) --[FinishTime]
           ,0 --[TotalTime]
           ,@ProductCount  --[ProductCount]
           ,@ProductWeight  --[AcceptableCount]
           ,0 --[UnacceptableCount]
           ,0 --[OverProduct]
           ,0 --[ProductDeduction]
           ,@Date  --[StartDate]
           ,@Date  --[FinishDate]
           ,0 --[ProductCostAmount]
           ,1 --[ProduceStepSerialNo]
           ,0 --[StepToolTime]
           ,@FiscalYear  --[DoingFiscalYear]
           , [AcceptStoreID]
           , [FailedStoreID]
           , [UsageStoreID]
           , [LossStoreID]
           ,'' --[MobInfo]
           ,0 --[UserPriceID]
            FROM  [pln].[tblTaskOrderHdr] TH
            WHERE SerialNo   =  @SerialNo 
           and ProcessID = 610 

    IF @@ERROR <>0
      BEGIN
     	 RAISERROR('ERROR' , 16, 1)
	     ROLLBACK TRAN
	     RETURN
      END
 
   
 
 COMMIT	TRAN
END
GO
