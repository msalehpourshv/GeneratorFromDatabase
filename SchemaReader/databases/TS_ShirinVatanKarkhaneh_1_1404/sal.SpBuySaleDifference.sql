USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Taha esmaeili
-- Create date   : 1400/10/06
-- Viewed By	 : 
-- Last Modified :  SellerAcntName
-- Last Modifier :  
-- Description	 :  
-- ----------------------------------------------
--   
-- ==============================================
Create PROCEDURE  [sal].[SpBuySaleDifference]
	@FiscalYear		Int = 1400,
	@BuyprocessNoRange varchar(50), 
	@SaleprocessNoRange varchar(50),   
	@RepInfo				NVarChar(110) = '0@0@0@0@0',
	@RepOptions			    NVarChar(12) = '0@0@0@0@0@'
WITH ENCRYPTION
AS
  DECLARE @DeclareQuery nvarchar(max)
  DECLARE @StrQuery1 nvarchar(max)
  DECLARE @StrQuery2 nvarchar(max)
  DECLARE @StrQuery3 nvarchar(max)
  DECLARE @StrQuery4 nvarchar(max)
  DECLARE @StrQuery5 nvarchar(max)
  DECLARE @StrQuery6 nvarchar(max)
  DECLARE @StrQuery7 nvarchar(max)
  DECLARE @StrQuery8 nvarchar(max)
  DECLARE @StrQuery9 nvarchar(max)
  DECLARE @StrQuery4buy nvarchar(max)
  DECLARE @StrQuerywhole1 nvarchar(max)
  DECLARE @StrQuerywhole2 nvarchar(max)
  DECLARE @StrQuery4update1 nvarchar(max)
  DECLARE @StrQuery4update2 nvarchar(max)
  DECLARE @StrQuery4select nvarchar(max)
  DECLARE @StrQuery4initialPeriod nvarchar(max)
  DECLARE @StrQuerywhole nvarchar(max)
  DECLARE @TempFiscalYear int
  DECLARE @StrWhere nvarchar(max)
  DECLARE @SaleStrWhere nvarchar(max)   
  Declare @DbName varchar(100)   
  Declare @BuyDateFrom char(10)
  Declare @BuyDateTo char(10)
  Declare @SaleDateFrom char(10)
  Declare @SaleDateTo char(10)  
  Declare @SerialNo varchar(20)
  Declare @GoodID varchar(20)
  Declare @GoodSerial varchar(20)
  Declare @PartNumber varchar(3)
  Declare @initialPeriod  char(1) 
  Declare @TaxIncluded  char(1)
  Declare @BuyTaxIncluded char(1)
  Declare @NotSoldGoods  char(1)
  Declare @OnlyNotSoldGoods  char(1)
  Declare @SetSalepriceToZero char(1)
  -------------

BEGIN
begin try
		drop table #buy
        drop table #initialPeriod
	end try
	begin catch
	end catch

create Table #buy(
SellerAcntName nvarchar(200),
CustomerAcntName nvarchar(200),
BuyProcessName nvarchar(100) collate Arabic_CS_AS null,
ProcessID int,
SaleProcessName nvarchar(100) collate Arabic_CS_AS null,
GoodsID varchar(50) collate Arabic_CS_AS null,
GoodsName nvarchar(100) collate Arabic_CS_AS null,
BuyPrice float,
SalePrice float,
BuySaleDifference float,
BuySaleDifferencePercent float,
ProductSerialID int,
PSerialNo varchar(50) collate Arabic_CS_AS null,
BuyFiscalSerialNo int,
SaleFiscalSerialNo int,
BuyDate char(10),
SaleDate char(10),
BuyStoreName varchar(50),
BuyStoreID int,
SaleStoreName varchar(50),
SaleStoreID varchar(20)
)
create Table #initialPeriod(
SellerAcntName nvarchar(200),
CustomerAcntName nvarchar(200),
BuyProcessName nvarchar(100) collate Arabic_CS_AS null,
ProcessID int,
SaleProcessName nvarchar(100) collate Arabic_CS_AS null,
GoodsID varchar(50) collate Arabic_CS_AS null,
GoodsName nvarchar(100) collate Arabic_CS_AS null,
BuyPrice float,
SalePrice float,
BuySaleDifference float,
BuySaleDifferencePercent float,
ProductSerialID int,
PSerialNo varchar(50) collate Arabic_CS_AS null,
BuyFiscalSerialNo int,
SaleFiscalSerialNo int,
BuyDate char(10),
SaleDate char(10),
BuyStoreName varchar(50),
BuyStoreID int,
SaleStoreName varchar(50),
SaleStoreID varchar(20)
)
	SET @BuyDateFrom= LTrim(pub.funSplitString(@RepInfo, '@', 1));  
	SET @BuyDateTo = LTrim(pub.funSplitString(@RepInfo, '@', 2));  
	SET @SaleDateFrom = LTrim(pub.funSplitString(@RepInfo, '@', 3));  
	SET @SaleDateTo	= LTrim(pub.funSplitString(@RepInfo, '@', 4));  
	SET @SerialNo = LTrim(pub.funSplitString(@RepInfo, '@', 5));  
	SET @GoodID	= LTrim(pub.funSplitString(@RepInfo, '@', 6));  
	SET @GoodSerial	= LTrim(pub.funSplitString(@RepInfo, '@', 7)); 
	SET @PartNumber	= LTrim(pub.funSplitString(@RepInfo, '@', 8)); 

	SET @initialPeriod	= LTrim(pub.funSplitString(@RepOptions, '@', 1)); 		
	SET @TaxIncluded	= LTrim(pub.funSplitString(@RepOptions, '@', 2)); 
	SET @BuyTaxIncluded	= LTrim(pub.funSplitString(@RepOptions, '@', 3)); 
	SET @NotSoldGoods	= LTrim(pub.funSplitString(@RepOptions, '@', 4)); 
	SET @OnlyNotSoldGoods = LTrim(pub.funSplitString(@RepOptions, '@', 5)); 
	SET @SetSalepriceToZero = LTrim(pub.funSplitString(@RepOptions, '@', 6)); 
	set @StrQuery1=''
	set @StrQuery2=''
	set @StrQuery3=''
	set @StrQuery4=''
	set @StrQuery5=''
	set @StrQuery6=''
	set @StrQuery7=''
	set @StrWhere=''
	set @SaleStrWhere=''
	set @StrQuery4buy=''
	set @StrQuery4initialPeriod=''
	set @StrQuery4update1=''
	set @StrQuery4update2=''
	set @StrQuery4select=''
	set @StrQuerywhole=''
	set @StrQuerywhole1=''
	set @StrQuerywhole2=''

if @BuyDateFrom<>'0' 
set @StrWhere = @StrWhere + ' And D.DocDate>=''' + @BuyDateFrom +''''
if @BuyDateTo<>'0' 
set @StrWhere = @StrWhere + ' And D.DocDate<=''' + @BuyDateTo+''''
if @SerialNo<>'0' 
set @StrWhere = @StrWhere + ' And D.SerialNo=' + @SerialNo
if @GoodID<>'0' 
set @StrWhere = @StrWhere + ' And D.GoodsID=' + @GoodID
if @GoodSerial<>'0' 
set @StrWhere = @StrWhere + ' And S.PSerialNo=' + @GoodSerial

if @SaleDateFrom<>'0' 
set @SaleStrWhere = @SaleStrWhere + ' And D2.DocDate>=''' + @SaleDateFrom +''''
if @SaleDateTo<>'0' 
set @SaleStrWhere = @SaleStrWhere + ' And D2.DocDate<=''' + @SaleDateTo+''''
if @SaleprocessNoRange<>'0' 
set @SaleStrWhere = @SaleStrWhere + ' And D2.ProcessNo in (' + @SaleprocessNoRange + ')'

set @DeclareQuery='
declare @TempPSerialNo varchar(20)
declare @TempBuyDate  varchar(10)
declare @SaleSerialNo int
declare @SalePrice float
declare @BuySaleDifferencePercent float
declare @BuySaleDifference float
declare @TempBuyPrice float
declare @ProcessName nvarchar(100)
declare @TempDocDate varchar(10)
declare @RepetitivePSerialNo varchar(20)
declare @RepetitiveGoodsID varchar(20)
declare @counter int
declare @firstFetch int
declare @outterFetch int
declare @innerFetch int
declare @Cursor1RowNumber int
declare @Cursor2RowNumber int
declare @firstOne varchar(20)
declare @TempGoodsID  varchar(20)
declare @Updated bit
'
 set @StrQuery1= ' 
 Select [acc].[funPartAcntName] (D.AcntCode,' + @PartNumber +') as SellerAcntName, cast('''' as nvarchar(200))  as CustomerAcntName,LTRIM(RTRIM(P.ProcessName)) as BuyProcessName ,cast('''' as nvarchar(100))  as SaleProcessName, D.ProcessID,G.GoodsID,G.GoodsName,D.GoodsPrice-(D.DiscountDtl/D.GoodsQuantity) + case ' + @BuyTaxIncluded + ' when 0 then 0 
  else  case when D.TaxOverWorthCostDtl>0 then (D.TollOverWorthCostDtl/D.GoodsQuantity) + (D.TaxOverWorthCostDtl/D.GoodsQuantity) else case D.GoodsPrice when 0 then 0 else ((D.GoodsPrice*D.GoodsQuantity) * (select TaxOverWorthCost+TollOverWorthCost from inv.tblStorageDocsHdr where SerialNo=D.SerialNo and ProcessID=D.ProcessID and ProcessNo=D.ProcessNo ) / (select sum(GoodsQuantity*GoodsPrice) from inv.tblStorageDocsDtl where SerialNo=D.SerialNo and ProcessID=D.ProcessID and ProcessNo=D.ProcessNo))/GoodsQuantity end end end As BuyPrice
               
          ,D.GoodsPrice As SalePrice,D.GoodsPrice-(D.DiscountDtl/D.GoodsQuantity) + case ' + @BuyTaxIncluded + ' when 0 then 0 
		  else  case when D.TaxOverWorthCostDtl>0 then (D.TollOverWorthCostDtl/D.GoodsQuantity) + (D.TaxOverWorthCostDtl/D.GoodsQuantity) else case D.GoodsPrice when 0 then 0 else ((D.GoodsPrice*D.GoodsQuantity) * (select TaxOverWorthCost+TollOverWorthCost from inv.tblStorageDocsHdr where SerialNo=D.SerialNo and ProcessID=D.ProcessID and ProcessNo=D.ProcessNo ) / (select sum(GoodsQuantity*GoodsPrice) from inv.tblStorageDocsDtl where SerialNo=D.SerialNo and ProcessID=D.ProcessID and ProcessNo=D.ProcessNo))/GoodsQuantity end end end As BuySaleDifference
               
                  , D.GoodsPrice as BuySaleDifferencePercent , S.ProductSerialID,S.PSerialNo, Cast(D.SerialNo as varchar(10)) As BuyFiscalSerialNo,	SD.StoreID as BuyStoreID, SD.StoreName as BuyStoreName,  cast('''' as varchar(20)) as SaleStoreID, cast('''' as nvarchar(50))  as SaleStoreName, Cast('''' as varchar(10)) As SaleFiscalSerialNo,D.DocDate As BuyDate,  Cast('''' as char(10)) As SaleDate
                into ' 
set @StrQuery2= ' From inv.tblStorageDocsDtl D
		                                 inner join inv.tblStorageDocsSerials S ON S.ProcessID = D.ProcessID AND S.ProcessNo = D.ProcessNo AND S.FiscalYear = D.FiscalYear AND S.SerialNo=D.SerialNo and S.DocRowNo=D.DocRowNo
		                                 inner join inv.tblGoodsDtl G On  G.GoodsID=D.GoodsID
                                         inner join pub.tblProcess P on P.ProcessNo= D.ProcessNo and P.ProcessID = D.ProcessID
										 inner join inv.tblStoresDtl SD on 	SD.StoreID=D.StoreID 
										 where '
if @SaleDateFrom<>'0' or  @SaleDateTo<>'0'
          	       set @StrQuery2= @StrQuery2 + ' (Select  count(*) From  inv.tblStorageDocsDtl  D2  where  (D2.ProcessID=90 or D2.ProcessID=60) ' + @SaleStrWhere + ')>0 And '

 if @initialPeriod='0' and @BuyprocessNoRange='0' 
  begin   
   set @StrQuery4buy= @StrQuery1 + '#buy' + @StrQuery2+ '(D.ProcessID=55 or D.ProcessID=100)' + @StrWhere    
   set @StrQuery4initialPeriod=  @StrQuery1 + '#initialPeriod' + @StrQuery2+ + 'D.ProcessID=50' + @StrWhere 	 	
   end 
else if @initialPeriod='0' and @BuyprocessNoRange<>'0'
  begin   
    set @StrQuery4buy= @StrQuery1 + '#buy' + @StrQuery2 + '(D.ProcessID=55 or D.ProcessID=100) And D.ProcessNo in (' + @BuyprocessNoRange + ')'  + @StrWhere
  end
else if @initialPeriod='1' and @BuyprocessNoRange='0'
 begin   
    set @StrQuery4initialPeriod= @StrQuery1 + '#initialPeriod' + @StrQuery2+ + 'D.ProcessID=50' + @StrWhere 
 end
else if @initialPeriod='1' and @BuyprocessNoRange<>'0'
begin  
  set @StrQuery4buy=  @StrQuery1 + '#buy' + @StrQuery2  + '(D.ProcessID=55 or D.ProcessID=100) And D.ProcessNo in (' + @BuyprocessNoRange + ')'  + @StrWhere
  set @StrQuery4initialPeriod=  @StrQuery1 + '#initialPeriod' + @StrQuery2  + 'D.ProcessID=50' + @StrWhere 
end

set @StrQuerywhole1= @DeclareQuery + @StrQuery4buy + @StrQuery4initialPeriod  		
print @DeclareQuery						
print  @StrQuery4buy 
print @StrQuery4initialPeriod  
--EXECUTE sp_executesql @StrQuerywhole  

 --استخراج و به روزرسانی مشخصات کالاهای خریدی ای که در سال فعلی ،اول دوره می باشند و در سال های قبل خرید هستند 
                             if not ( @initialPeriod='1' and @BuyprocessNoRange='0')
								begin
										 set @TempFiscalYear=@FiscalYear		
 	                                     while @TempFiscalYear >1385 begin
	                                       set @TempFiscalYear =@TempFiscalYear-1 
	                                       set @DbName=LEFT(DB_NAME(),LEN(DB_NAME())-4) + cast(@TempFiscalYear as char(4))
	                                       if (select Count(*) from sys.databases where name = @DbName )=1 begin	       
		                                     set @StrQuery3= ' 
											 update  #buy                                           
                                             set BuyPrice= Buy2.GoodsPrice-(Buy2.DiscountDtl/Buy2.GoodsQuantity) + case ' + @BuyTaxIncluded + ' when 0 then 0 
                                               else  case when Buy2.TaxOverWorthCostDtl>0 then (Buy2.TollOverWorthCostDtl/Buy2.GoodsQuantity) + (Buy2.TaxOverWorthCostDtl/Buy2.GoodsQuantity) else case Buy2.GoodsPrice when 0 then 0 else ((Buy2.GoodsPrice*Buy2.GoodsQuantity) * (select TaxOverWorthCost+TollOverWorthCost from inv.tblStorageDocsHdr where SerialNo=Buy2.SerialNo and ProcessID=Buy2.ProcessID and ProcessNo=Buy2.ProcessNo ) / (select sum(GoodsQuantity*GoodsPrice) from inv.tblStorageDocsDtl where SerialNo=Buy2.SerialNo and ProcessID=Buy2.ProcessID and ProcessNo=Buy2.ProcessNo))/GoodsQuantity end end end
											
                                             ,BuySaleDifference= Buy2.GoodsPrice-(Buy2.DiscountDtl/Buy2.GoodsQuantity) + case ' + @BuyTaxIncluded + ' when 0 then 0 
                                               else  case when Buy2.TaxOverWorthCostDtl>0 then (Buy2.TollOverWorthCostDtl/Buy2.GoodsQuantity) + (Buy2.TaxOverWorthCostDtl/Buy2.GoodsQuantity) else case Buy2.GoodsPrice when 0 then 0 else ((Buy2.GoodsPrice*Buy2.GoodsQuantity) * (select TaxOverWorthCost+TollOverWorthCost from inv.tblStorageDocsHdr where SerialNo=Buy2.SerialNo and ProcessID=Buy2.ProcessID and ProcessNo=Buy2.ProcessNo ) / (select sum(GoodsQuantity*GoodsPrice) from inv.tblStorageDocsDtl where SerialNo=Buy2.SerialNo and ProcessID=Buy2.ProcessID and ProcessNo=Buy2.ProcessNo))/GoodsQuantity end end end
											 ,BuyDate=Buy2.DocDate
	                                         ,BuyFiscalSerialNo= Cast(Buy2.SerialNo as varchar(10))
                                             From #buy Buy
	                                         inner Join  	      
		                                     (Select S.ProductSerialID,S.PSerialNo,D3.GoodsID, D3.GoodsPrice,D3.FiscalYear , D3.SerialNo, D3.DocDate,D3.TollOverWorthCostDtl,D3.TaxOverWorthCostDtl,D3.GoodsQuantity,D3.DiscountDtl,D3.ProcessID,D3.ProcessNo From '+ @DbName +'.inv.tblStorageDocsDtl  D3			 			   
			                 			     inner join '+@DbName+'.inv.tblStorageDocsSerials S ON S.ProcessID = D3.ProcessID AND S.ProcessNo = D3.ProcessNo AND S.FiscalYear = D3.FiscalYear AND S.SerialNo=D3.SerialNo and S.DocRowNo=D3.DocRowNo			
			                                 where  D3.ProcessID=55	)Buy2		
			                                 ON Buy.PSerialNo = Buy2.PSerialNo And	Buy.GoodsID = Buy2.GoodsID 
			                                 where Buy.ProcessID=50
											 '
											  PRINT @StrQuery3
                                           end 		 	   
	                                    end                                 
                                     EXECUTE sp_executesql @StrQuery3  
                               end
								  -------------------------------------------------------------------
set @StrQuery1= '  set  SalePrice= case ' + @SetSalepriceToZero + ' when 0 then 0 else Sale.GoodsPrice - (Sale.DiscountDtl/Sale.GoodsQuantity)  + case ' + @TaxIncluded + ' when 0 then 0 
					else case when Sale.TaxOverWorthCostDtl>0 then (Sale.TollOverWorthCostDtl/Sale.GoodsQuantity) + (Sale.TaxOverWorthCostDtl/Sale.GoodsQuantity) else					
					case Sale.GoodsPrice when 0 then 0 else ((Sale.GoodsPrice*Sale.GoodsQuantity) * (select TaxOverWorthCost+TollOverWorthCost from inv.tblStorageDocsHdr where SerialNo=Sale.SerialNo and ProcessID=Sale.ProcessID and ProcessNo=Sale.ProcessNo ) / (select sum(GoodsQuantity*GoodsPrice) from inv.tblStorageDocsDtl where SerialNo=Sale.SerialNo and ProcessID=Sale.ProcessID and ProcessNo=Sale.ProcessNo))/Sale.GoodsQuantity end end end end

                    ,BuySaleDifference= case ' + @SetSalepriceToZero + ' when 0 then 0 else isnull(Sale.GoodsPrice,0) - (Sale.DiscountDtl/Sale.GoodsQuantity) - BuySaleDifference + case ' + @TaxIncluded + ' when 0 then 0 
			    	else case when Sale.TaxOverWorthCostDtl>0 then (Sale.TollOverWorthCostDtl/Sale.GoodsQuantity) + (Sale.TaxOverWorthCostDtl/Sale.GoodsQuantity) else					
					case Sale.GoodsPrice when 0 then 0 else ((Sale.GoodsPrice*Sale.GoodsQuantity) * (select TaxOverWorthCost+TollOverWorthCost from inv.tblStorageDocsHdr where SerialNo=Sale.SerialNo and ProcessID=Sale.ProcessID and ProcessNo=Sale.ProcessNo ) / (select sum(GoodsQuantity*GoodsPrice) from inv.tblStorageDocsDtl where SerialNo=Sale.SerialNo and ProcessID=Sale.ProcessID and ProcessNo=Sale.ProcessNo))/Sale.GoodsQuantity end end end end
                    ,SaleFiscalSerialNo= Cast(isnull(Sale.SerialNo,''0'') as varchar(10))
					'
					if  @TaxIncluded='1'
					   set @StrQuery1=  @StrQuery1 + ',BuySaleDifferencePercent= case ' + @SetSalepriceToZero + ' when 0 then 0 else  case Buy.BuyPrice when 0 then  (100 * (Sale.GoodsPrice-(Sale.DiscountDtl/Sale.GoodsQuantity) + (Sale.TollOverWorthCostDtl/Sale.GoodsQuantity) + (Sale.TaxOverWorthCostDtl/Sale.GoodsQuantity))) else Round((100 * (Sale.GoodsPrice-(Sale.DiscountDtl/Sale.GoodsQuantity) + (Sale.TollOverWorthCostDtl/Sale.GoodsQuantity) + (Sale.TaxOverWorthCostDtl/Sale.GoodsQuantity))/Buy.BuyPrice)-100,3) end end
					    From '
					else
                     set @StrQuery1=  @StrQuery1 +  ', BuySaleDifferencePercent=  case ' + @SetSalepriceToZero + ' when 0 then 0 else case Buy.BuyPrice when 0 then  (100 * (Sale.GoodsPrice-(Sale.DiscountDtl/Sale.GoodsQuantity))) else Round((100 * (Sale.GoodsPrice-(Sale.DiscountDtl/Sale.GoodsQuantity))/Buy.BuyPrice)-100,3) end end
					 From '			 
set @StrQuery2= ' Buy
	                          inner Join  
	                         	(Select S.ProductSerialID,S.PSerialNo,D2.GoodsID, D2.GoodsPrice,D2.SerialNo , D2.ProcessID , D2.ProcessNo,D2.TollOverWorthCostDtl,D2.TaxOverWorthCostDtl,D2.DiscountDtl,D2.GoodsQuantity From  inv.tblStorageDocsDtl  D2	                    
								 inner join inv.tblStorageDocsSerials S ON S.ProcessID = D2.ProcessID AND S.ProcessNo = D2.ProcessNo AND S.FiscalYear = D2.FiscalYear AND S.SerialNo=D2.SerialNo and S.DocRowNo=D2.DocRowNo				                   
								 where  (D2.ProcessID=90 or D2.ProcessID=60)' + @SaleStrWhere + ')Sale		
			                     ON	 Sale.PSerialNo = Buy.PSerialNo And	Sale.GoodsID = Buy.GoodsID'

set @StrQuery3= ' set SaleProcessName=LTRIM(RTRIM(Sale.ProcessName)),                            
                     SaleDate=Sale.DocDate,
				 	 SaleStoreName=Sale.StoreName,
				 	 SaleStoreID=Sale.StoreID,
					 CustomerAcntName=Sale.CustomerAcntName  From '
set @StrQuery4= ' Buy
	                          inner Join  
	                         	(Select P.ProcessName, SD.StoreID,SD.StoreName,S.ProductSerialID,S.PSerialNo,[acc].[funPartAcntName] (D2.AcntCode,2) as CustomerAcntName,D2.GoodsID,D2.FiscalYear , D2.ProcessID , D2.ProcessNo, D2.SerialNo, D2.DocDate,D2.TollOverWorthCostDtl,D2.TaxOverWorthCostDtl,D2.DiscountDtl,D2.GoodsQuantity From  inv.tblStorageDocsDtl  D2			 			   
			                     inner join inv.tblStoresDtl SD on 	SD.StoreID=D2.StoreID
								 inner join inv.tblStorageDocsSerials S ON S.ProcessID = D2.ProcessID AND S.ProcessNo = D2.ProcessNo AND S.FiscalYear = D2.FiscalYear AND S.SerialNo=D2.SerialNo and S.DocRowNo=D2.DocRowNo			
			                     inner join pub.tblProcess P on P.ProcessNo= D2.ProcessNo and P.ProcessID = D2.ProcessID
								 where  (D2.ProcessID=90 or D2.ProcessID=60) ' + @SaleStrWhere + ')Sale		
			                     ON	 Sale.PSerialNo = Buy.PSerialNo And	Sale.GoodsID = Buy.GoodsID'

 set @StrQuery5= '  set  BuySaleDifference=0, BuySaleDifferencePercent=0, SalePrice=0
                    From '
				
set @StrQuery6= '  Buy   where SaleFiscalSerialNo=''''' 


set @StrQuery7= '  ---- Cursor_RowNo used to find Goods that have been bought and sold more than one time. because such Goods have more than one buy date and sale date ,they must match. To match them Cursor1 and Cursor2 is used to match them buy their row number.
set @counter=0
set @firstOne=''''
	Declare Cursor_RowNo CURSOR For 
	select PSerialNo,GoodsID From #buy union All select PSerialNo,GoodsID From #initialPeriod
	   Open  Cursor_RowNo; 
          Fetch NEXT From Cursor_RowNo Into @RepetitivePSerialNo,@RepetitiveGoodsID 
		   While (@@Fetch_Status = 0)
		   begin
		   if @counter=0 
		     begin 		       
				set @counter=@counter+1
		     end
		  else if @firstOne=@RepetitivePSerialNo 
		     begin 
			     Declare Cursor1 CURSOR For 
	             Select *,ROW_NUMBER() over (order by BuyDate) RowNumber,0 as bit From (select PSerialNo,GoodsID,BuyDate,BuyPrice From #initialPeriod where PSerialNo=@RepetitivePSerialNo and GoodsID=@RepetitiveGoodsID union All				
				  select PSerialNo,GoodsID,BuyDate,BuyPrice From #buy where PSerialNo=@RepetitivePSerialNo and GoodsID=@RepetitiveGoodsID) a
				  '
set @StrQuery8= '  ---- Cursor_RowNo used to find Goods that have been bought and sold more than one time. because such Goods have more than one buy date and sale date ,they must match. To match them Cursor1 and Cursor2 is used to match them buy their row number.
set @counter=0
set @firstOne=''''
	Declare Cursor_RowNo CURSOR For 
	select PSerialNo,GoodsID From #buy   
	   Open  Cursor_RowNo; 
          Fetch NEXT From Cursor_RowNo Into @RepetitivePSerialNo,@RepetitiveGoodsID 
		   While (@@Fetch_Status = 0)
		   begin
		   if @counter=0 
		     begin 		       
				set @counter=@counter+1
		     end
		  else if @firstOne=@RepetitivePSerialNo 
		     begin 
			     Declare Cursor1 CURSOR For 
	            select PSerialNo,GoodsID,BuyDate,BuyPrice,ROW_NUMBER() over (order by BuyDate) RowNumber,0 as bit  From #buy where PSerialNo=@RepetitivePSerialNo and GoodsID=@RepetitiveGoodsID
				 '
set @StrQuery9='Open  Cursor1; 
                Fetch NEXT From Cursor1 Into @TempPSerialNo,@TempGoodsID,@TempBuyDate,@TempBuyPrice,@Cursor1RowNumber,@Updated			
		        While (@@Fetch_Status = 0)
		         begin				
				   Declare Cursor2 CURSOR For 
	               select DocDate,D2.SerialNo,ROW_NUMBER() over (order by DocDate) as RowNumber,
				   case ' + @SetSalepriceToZero + ' when 0 then 0 else GoodsPrice - (DiscountDtl/GoodsQuantity)  + case ' + @TaxIncluded + ' when 0 then 0 
					else case when TaxOverWorthCostDtl>0 then (TollOverWorthCostDtl/GoodsQuantity) + (TaxOverWorthCostDtl/GoodsQuantity) else					
					case GoodsPrice when 0 then 0 else ((GoodsPrice*GoodsQuantity) * (select TaxOverWorthCost+TollOverWorthCost from inv.tblStorageDocsHdr H where H.SerialNo=D2.SerialNo and H.ProcessID=D2.ProcessID and H.ProcessNo=D2.ProcessNo ) / (select sum(GoodsQuantity*GoodsPrice) from inv.tblStorageDocsDtl))/GoodsQuantity end end end end
					,  case ' + @TaxIncluded + ' when 1 then case ' + @SetSalepriceToZero + ' when 0 then 0 else  case  @TempBuyPrice  when 0 then  (100 * (GoodsPrice-(DiscountDtl/GoodsQuantity) + (TollOverWorthCostDtl/GoodsQuantity) + (TaxOverWorthCostDtl/GoodsQuantity))) else Round((100 * (GoodsPrice-(DiscountDtl/GoodsQuantity) + (TollOverWorthCostDtl/GoodsQuantity) + (TaxOverWorthCostDtl/GoodsQuantity))/@TempBuyPrice)-100,3) end end
				     else case ' + @SetSalepriceToZero + ' when 0 then 0 else  case @TempBuyPrice when 0 then  (100 * (GoodsPrice-(DiscountDtl/GoodsQuantity))) else Round((100 * (GoodsPrice-(DiscountDtl/GoodsQuantity))/@TempBuyPrice)-100,3) end end end
				   , P.ProcessName
				   From inv.tblStorageDocsDtl  D2
			       inner join inv.tblStorageDocsSerials S ON S.ProcessID = D2.ProcessID AND S.ProcessNo = D2.ProcessNo AND S.FiscalYear = D2.FiscalYear AND S.SerialNo=D2.SerialNo and S.DocRowNo=D2.DocRowNo			
			       inner join pub.tblProcess P on P.ProcessNo= D2.ProcessNo and P.ProcessID = D2.ProcessID
				   where  S.PSerialNo=@RepetitivePSerialNo and D2.GoodsID=@RepetitiveGoodsID and (D2.ProcessID=90 or D2.ProcessID=60)
				 
				   Open  Cursor2; 
                   Fetch NEXT From Cursor2 Into @TempDocDate,@SaleSerialNo,@Cursor2RowNumber,@SalePrice,@BuySaleDifferencePercent,@ProcessName		 
		           While (@@Fetch_Status = 0)
		            begin										 					
					if @Cursor1RowNumber=@Cursor2RowNumber 
					  begin						   								   
					   update #buy set SaleDate=@TempDocDate,SaleFiscalSerialNo=@SaleSerialNo,SalePrice=@SalePrice,BuySaleDifference=@SalePrice-BuyPrice,BuySaleDifferencePercent=@BuySaleDifferencePercent,SaleProcessName=LTRIM(RTRIM(@ProcessName)) where BuyDate=@TempBuyDate and  PSerialNo=@TempPSerialNo and GoodsID=@TempGoodsID 
					   set @Updated=1
					  end
					 else if @Cursor1RowNumber<>@Cursor2RowNumber and @Updated=0
					  begin						   								   
					   update #buy set SalePrice=0,BuySaleDifference=0, BuySaleDifferencePercent=0,SellerAcntName='''', SaleProcessName='''', SaleStoreName='''', SaleStoreID='''', CustomerAcntName='''',SaleDate='''',SaleFiscalSerialNo=0 where BuyDate=@TempBuyDate and  PSerialNo=@TempPSerialNo and GoodsID=@TempGoodsID 
					  end					
					Fetch NEXT From Cursor2 Into @TempDocDate,@SaleSerialNo,@Cursor2RowNumber,@SalePrice,@BuySaleDifferencePercent,@ProcessName
					end
					Close Cursor2
                    Deallocate Cursor2
		            Fetch NEXT From Cursor1 Into @TempPSerialNo,@TempGoodsID,@TempBuyDate,@TempBuyPrice,@Cursor1RowNumber,@Updated
		         end
				Close Cursor1
                Deallocate Cursor1
			   ----
		     end
			 set @firstOne=@RepetitivePSerialNo
		   Fetch NEXT From Cursor_RowNo Into  @RepetitivePSerialNo,@RepetitiveGoodsID
            end
       Close Cursor_RowNo
       Deallocate Cursor_RowNo '
	        
	  if @SaleDateFrom<>'0' 
        set @StrQuery9 =@StrQuery9 + ' Delete from #buy where SaleDate<''' + @SaleDateFrom + '''' 
 if @SaleDateTo<>'0' 
        set @StrQuery9 =@StrQuery9 + ' Delete from #buy where SaleDate>''' + @SaleDateTo + ''''    					 
										 	
if (@initialPeriod='0' and @BuyprocessNoRange='0') OR (@initialPeriod='1' and @BuyprocessNoRange<>'0')
  begin   
    set @StrQuery4update1=' update #buy' +@StrQuery1 + '#buy' + @StrQuery2 + ' update #buy' +@StrQuery3 + '#buy' + @StrQuery4 + ' update  #buy ' + @StrQuery5  + '#buy' + @StrQuery6 + @StrQuery7+ @StrQuery9	   
    set @StrQuery4update2= ' update #initialPeriod' +@StrQuery1 + '#initialPeriod' + @StrQuery2  + ' update #initialPeriod' +@StrQuery3 + '#initialPeriod' + @StrQuery4 + ' update  #initialPeriod ' + @StrQuery5 + '#initialPeriod' + @StrQuery6 
    if @OnlyNotSoldGoods='1' 
	 set @StrQuery4select = '  select * from #buy where SaleFiscalSerialNo='''' union All  select * from  #initialPeriod  where  SaleFiscalSerialNo='''' '
	else if  @NotSoldGoods='0' 
        set @StrQuery4select = '  select * from #buy where SaleFiscalSerialNo<>'''' union All  select * from  #initialPeriod  where  SaleFiscalSerialNo<>'''' '	
    else
     	set @StrQuery4select = '  select * from #buy union All  select * from  #initialPeriod '	
 end
else if @initialPeriod='0' and @BuyprocessNoRange<>'0'
  begin   
     set @StrQuery4update1=' update #buy' +@StrQuery1 + '#buy' + @StrQuery2 + ' update #buy' +@StrQuery3 + '#buy' + @StrQuery4 + ' update  #buy ' + @StrQuery5  + '#buy' + @StrQuery6 + @StrQuery8 + @StrQuery9
	   if @OnlyNotSoldGoods='1' 
	    set @StrQuery4select = '  select * from #buy where SaleFiscalSerialNo='''' '
	   else  if  @NotSoldGoods='0' 
        set @StrQuery4select = '  select * from #buy  where  SaleFiscalSerialNo<>'''' '	
      else
  	    set @StrQuery4select = '  select * from #buy'
  end
else if @initialPeriod='1' and @BuyprocessNoRange='0'
 begin   
    set @StrQuery4update2= ' update #initialPeriod' +@StrQuery1 + '#initialPeriod' + @StrQuery2 + ' update #buy' +@StrQuery3 + '#buy' + @StrQuery4 + ' update  #initialPeriod ' + @StrQuery5  + '#initialPeriod' + @StrQuery6
	 if @OnlyNotSoldGoods='1' 
	   set @StrQuery4select = '  select * from  #initialPeriod  where  SaleFiscalSerialNo='''' '
	 else if  @NotSoldGoods='0' 
        set @StrQuery4select = ' select * from  #initialPeriod  where  SaleFiscalSerialNo<>'''' '	
    else
     	set @StrQuery4select = ' select * from  #initialPeriod ' 
 end
 
 		
						
  set @StrQuerywhole2= @StrQuery4update1 + @StrQuery4update2 + @StrQuery4select

  set @StrQuerywhole=@StrQuerywhole1 + @StrQuerywhole2
  
 print @StrQuery4update1 
 print @StrQuery4update2
  print @StrQuery4select
  EXECUTE sp_executesql @StrQuerywhole  

END
GO
