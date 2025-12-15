USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1386/11/30
-- Viewed By	 : 
-- Last Modified : 1387/12/18
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[spGetUserIOAccessInStoreID] 
 @ProcessID		int,
 @ProcessNo		int,
 @FiscalYear	Smallint,
 @SerialNo		INT,
 @UserID		INT,
 @EnterKind		INT,
 @OutputStatus	TINYINT
  WITH ENCRYPTION
AS

BEGIN
SET NOCOUNT ON;

	Declare @StoreID		Varchar(20)
	
	IF (SELECT COUNT(*)
		FROM inv.tblUsersIOAccessDtl
		WHERE  StoreID in (SELECT	StoreID
			FROM inv.tblStorageDocsDtl 
			WHERE ProcessID = @ProcessID AND
			  ProcessNo = @ProcessNo AND
			  FiscalYear= @FiscalYear AND
			  SerialNo  = @SerialNo
				) 
		)=0
		begin
			Select '' StoreID
			return 
		END 

		IF @EnterKind = 1
		
			SELECT	 case when isnull(Input, 'False') = 'True' then '' else   s.StoreID end StoreID  
									FROM inv.tblStorageDocsDtl s
									left Join inv.tblUsersIOAccessDtl a on a.StoreID=s.StoreID and a.UserID=@UserID
									WHERE ProcessID = @ProcessID 
										AND ProcessNo = @ProcessNo
										AND FiscalYear= @FiscalYear 
										AND SerialNo  = @SerialNo		
			
		ELSE IF @EnterKind = -1
			BEGIN
				IF @OutputStatus = 1
				
					SELECT	 case when isnull([Output], 'False') = 'True' then '' else   s.StoreID end StoreID  
						FROM inv.tblStorageDocsDtl s
							left Join inv.tblUsersIOAccessDtl a on a.StoreID=s.StoreID and a.UserID=@UserID
						WHERE ProcessID = @ProcessID 
							AND ProcessNo = @ProcessNo
							AND FiscalYear= @FiscalYear 
							AND SerialNo  = @SerialNo									 

				ELSE IF @OutputStatus = 2		
			
					SELECT	 case when isnull([Output_Numeric], 'False') = 'True' then '' else   s.StoreID end StoreID  
						FROM inv.tblStorageDocsDtl s
							left Join inv.tblUsersIOAccessDtl a on a.StoreID=s.StoreID and a.UserID=@UserID
						WHERE ProcessID = @ProcessID 
							AND ProcessNo = @ProcessNo
							AND FiscalYear= @FiscalYear 
							AND SerialNo  = @SerialNo	

				ELSE IF @OutputStatus = 3
	
					SELECT	 case when isnull([Output_Numeric], 'False') = 'True' and isnull([Output], 'False')= 'True' then '' else   s.StoreID end StoreID  
						FROM inv.tblStorageDocsDtl s
							left Join inv.tblUsersIOAccessDtl a on a.StoreID=s.StoreID and a.UserID=@UserID
						WHERE ProcessID = @ProcessID 
							AND ProcessNo = @ProcessNo
							AND FiscalYear= @FiscalYear 
							AND SerialNo  = @SerialNo											 			
			END		
END
GO
