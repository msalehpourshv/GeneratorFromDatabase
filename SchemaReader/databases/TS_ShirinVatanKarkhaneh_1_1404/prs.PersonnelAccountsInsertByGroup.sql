USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
Create  PROCEDURE [prs].[PersonnelAccountsInsertByGroup]
		@PersonnelID				varchar(20),
		@RecID						Bigint,
		@SessionNo					int,
		@AccountNo					varchar(30),
		@IsDefault					bit,
		@BankTypeID					varchar(20), 
		@BranchCode					nvarchar(30),
		@BranchName					nvarchar(100),
		@BankCartNo					varchar(30),
		@ShabaAccountNumber         nvarchar(50)	
WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E ===================================================
SET NOCOUNT ON;
 if (select count(*) from  prs.tblPersonnelAccountsHdr where PersonnelID=@PersonnelID)=0
    insert into prs.tblPersonnelAccountsHdr values(@PersonnelID,@RecID,@SessionNo)
 if (select count(*) from  prs.tblPersonnelAccountsDtl where PersonnelID=@PersonnelID and AccountNo=@AccountNo )=0
	insert into prs.tblPersonnelAccountsDtl
	values (@PersonnelID,(select isnull(Max(RowNo),0) from  prs.tblPersonnelAccountsDtl 
	where PersonnelID=@PersonnelID)+1,@AccountNo,@IsDefault,@BankTypeID,@BranchCode,@BranchName,
	(select isnull(Max(DocRowNo),0) from  prs.tblPersonnelAccountsDtl where PersonnelID=@PersonnelID)+1,@BankCartNo,@ShabaAccountNumber)
else
	update prs.tblPersonnelAccountsDtl 
	set IsDefault=@IsDefault,BankTypeID=@BankTypeID,BranchCode=@BranchCode,BranchName=@BranchName,BankCartNo=@BankCartNo,ShabaAccountNumber=@ShabaAccountNumber
	where PersonnelID=@PersonnelID and AccountNo=@AccountNo	
END
GO
