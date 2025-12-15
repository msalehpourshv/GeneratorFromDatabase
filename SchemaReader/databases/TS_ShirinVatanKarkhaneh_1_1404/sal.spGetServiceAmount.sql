USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 
 
CREATE PROCEDURE  [sal].[spGetServiceAmount]

 @GoodsID2 as VARCHAR(20),
 @GoodsID3 as VARCHAR(20),
 @SubUnitID AS VARCHAR(20),
 @DocDate AS CHAR(10),
 @PartNumberEnd as int
 


WITH ENCRYPTION
AS
BEGIN


Declare @SubUnitQty Decimal(28,9)
Declare @Counter int
Declare @lenGoodsID2 as int
Declare @lenGoodsID3 as int

select @lenGoodsID2 = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName=N'inv.tblGoods' AND PartNumber<@PartNumberEnd
           
	select @lenGoodsID3 = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName=N'inv.tblGoods' AND PartNumber=@PartNumberEnd

       
--Select @lenGoodsID2,@lenGoodsID3

set @Counter=0
set @SubUnitQty=1


	

 SELECT   @Counter =COUNT(*)
                 FROM         sal.tblServicePriceDtl AS D INNER JOIN sal.tblServicePriceHdr AS H  
                 ON D.SerialNo = H.SerialNo  
                 Where H.FromDate<=@DocDate  and H.ToDate>=@DocDate
                 And substring (D.GoodsID1,1 ,@lenGoodsID2 )=substring (@GoodsID2, 1, @lenGoodsID2) 
                 And D.GoodsID2= @GoodsID3 
                 And  D.UnitID= @SubUnitID
            
if @Counter>0
begin

 SELECT   D.UnitID, isnull( case when @SubUnitID <> pub.funGetGoodsUnitID(@GoodsID2) THEN pub.funGetSubUnitIDRate(substring (@GoodsID2, 1, @lenGoodsID2) + @GoodsID3,D.UnitID) ELSE 1 END*D.Price,0) Price,isnull( case when @SubUnitID <> pub.funGetGoodsUnitID(@GoodsID2) THEN pub.funGetSubUnitIDRate(substring (@GoodsID2, 1, @lenGoodsID2) + @GoodsID3,D.UnitID) ELSE 1 END *D.TaxTellPrice,0) TaxTellPrice 
                 FROM         sal.tblServicePriceDtl AS D INNER JOIN sal.tblServicePriceHdr AS H  
                 ON D.SerialNo = H.SerialNo  
                 Where H.FromDate<=@DocDate  and H.ToDate>=@DocDate
                 And substring (D.GoodsID1,1 ,@lenGoodsID2 )=substring (@GoodsID2, 1, @lenGoodsID2) 
                 And D.GoodsID2= @GoodsID3 
                 And  D.UnitID= @SubUnitID
                 ORDER BY H.SerialNo DESC 
          
            
end 
else
begin 
set @SubUnitID = pub.funGetGoodsSubUnitID(@GoodsID2)

SELECT   D.UnitID, isnull(case when @SubUnitID = pub.funGetGoodsUnitID(@GoodsID2) THEN pub.funGetSubUnitIDRate(substring (@GoodsID2, 1, @lenGoodsID2) + @GoodsID3,D.UnitID) ELSE 1 END*D.Price,0) Price,isnull(case when @SubUnitID = pub.funGetGoodsUnitID(@GoodsID2) THEN pub.funGetSubUnitIDRate(substring (@GoodsID2, 1, @lenGoodsID2) + @GoodsID3,D.UnitID) ELSE 1 END*D.TaxTellPrice,0) TaxTellPrice 
                     FROM         sal.tblServicePriceDtl AS D INNER JOIN sal.tblServicePriceHdr AS H  
                     ON D.SerialNo = H.SerialNo  
                     Where H.FromDate<=@DocDate  and H.ToDate>=@DocDate
                     And substring (D.GoodsID1,1,@lenGoodsID2)= substring (@GoodsID2, 1, @lenGoodsID2)
                     And D.GoodsID2=@GoodsID3
                     And  D.UnitID=@SubUnitID 
                     ORDER BY H.SerialNo DESC 

                
                
end            
            
	
END

GO
