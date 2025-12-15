USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Reza NP
-- Create date   : 1392/12/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_SpecialList]

	@DializAmount		FLOAT = 0,
	@TalasemiAmount		FLOAT = 0,
	@HemophilyAmount	FLOAT = 0,
	@KolieAmount		FLOAT = 0,
	@MSAmount			FLOAT = 0,
	@PharmacyID  VARCHAR(20)='',
	@PharmacyName NVARCHAR(50)='',
	@Year INT=0,
	@Mount INT=0,
	@Percent INT=0
	
	
WITH ENCRYPTION
AS 

Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	
	Set @StrWhere = '1 = 1'
	
	
				
	-- Select Clause -------------------------------------------

	
	SET @StrSelect = 'SELECT 1'
	
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
