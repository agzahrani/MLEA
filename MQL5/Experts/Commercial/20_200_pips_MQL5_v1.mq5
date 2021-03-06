//+------------------------------------------------------------------+
//|                                          20_200_pips_MQL5_v1.mq5 |
//|                                    Copyright 2010, 鸯桊眍?相忮?|
//|                                          http://www.autoforex.ru |
//+------------------------------------------------------------------+

#property copyright "Copyright 2010"
#property link      "http://www.autoforex.ru"
#property version   "1.00"

//Input parameters
input int      TakeProfit=200;
input int      StopLoss=2000;
input int      TradeTime=18;
input int      t1=7;
input int      t2=2;
input int      delta=70;
input double   lot=0.1;

bool cantrade=true;  // can we trade?
double Ask; // variable for Ask price of the new tick
double Bid; // variable for Bid price of the new tick

// Long position opening function.
int OpenLong(double volume=0.1,int slippage=10,string comment="EUR/USD 20 pips expert (Long)",int magic=0)
  {
   MqlTradeRequest my_trade;        //declare a structure of MqlTradeRequest type
   MqlTradeResult my_trade_result;  //declare a structure of for trade request result
   
   //fill all the NECESSARY fields
   my_trade.action=TRADE_ACTION_DEAL;//instant execution

   my_trade.symbol=Symbol();// current symbol of the chart

   my_trade.volume=NormalizeDouble(volume,1);//lot size

   my_trade.price=NormalizeDouble(Ask,_Digits);// order price  
   //in our case (TRADE_ACTION_DEAL) it's the current price, so it isn't necessary to specify it
   
   my_trade.sl=NormalizeDouble(Ask-StopLoss*_Point,_Digits);    //stop loss price
   my_trade.tp=NormalizeDouble(Ask+TakeProfit*_Point,_Digits);  //take profit price
   
   my_trade.deviation=slippage;   //slippage in pips
   
   my_trade.type=ORDER_TYPE_BUY;  //order type (buy)
   my_trade.type_filling=ORDER_FILLING_AON; //order filling type All Or Nothing) 
   
   my_trade.comment=comment; //order comment
   my_trade.magic=magic;     //order magic
   
   ResetLastError();         //reset last error code
   if(OrderSend(my_trade,my_trade_result))//sending request to open position and checking the result
     {
      // if the order has been accepted, print the result
      Print("Operation result code - ",my_trade_result.retcode);
     }
   else
     {
      // there are some errors in the order, print them in Journal
      Print("Operation result code - ",my_trade_result.retcode);
      Print("Error in request = ",GetLastError());    
     }  
return(0);// return from the function
}

// Short position opening function. it's similar to OpenLong
int OpenShort(double volume=0.1,int slippage=10,string comment="EUR/USD 20 pips expert (Short)",int magic=0)
  {
   MqlTradeRequest my_trade;
   MqlTradeResult my_trade_result;
   my_trade.action=TRADE_ACTION_DEAL;
   my_trade.symbol=Symbol();
   my_trade.volume=NormalizeDouble(volume,1);
   my_trade.price=NormalizeDouble(Bid,_Digits);
   my_trade.sl=NormalizeDouble(Bid+StopLoss*_Point,_Digits);
   my_trade.tp=NormalizeDouble(Bid-TakeProfit*_Point,_Digits);
   my_trade.deviation=slippage;
   my_trade.type=ORDER_TYPE_SELL;
   my_trade.type_filling=ORDER_FILLING_AON;
   my_trade.comment=comment;
   my_trade.magic=magic;

   ResetLastError();  
   if(OrderSend(my_trade,my_trade_result))
     {
      Print("Operation result code - ",my_trade_result.retcode);
     }
   else
     {
      Print("Operation result code - ",my_trade_result.retcode);
      Print("Error in request = ",GetLastError());    
      }        
return(0);     
}

int OnInit()
  {
   return(0);
  }


void OnDeinit(const int reason){}

void OnTick()
   {
   double Open[];      //array for opening prices (Open[t1] and Open[t2] will be used)
   MqlDateTime mqldt;  //current time
   TimeCurrent(mqldt); //update current time
   int len;            //variable for Open[] array size.
        
   MqlTick last_tick;  //structure for last tick
   SymbolInfoTick(_Symbol,last_tick); //filling last_tick with recent prices
   Ask=last_tick.ask;  // update bid and ask
   Bid=last_tick.bid;
   
   ArraySetAsSeries(Open,true); //set Open[] array as timeseries
   
   //calculate size of the array to include, Open[t1] and Open[t2]
   if (t1>=t2)len=t1+1; //t1 ?t2 - bar indexes, get the largest value
   else len=t2+1;       //and add 1 (for zeroth bar)

   CopyOpen(_Symbol,PERIOD_H1,0,len,Open);//filling the Open[] array with current values
   
   //set cantrade to true, to allow trading of Expert Advisor
   if(((mqldt.hour)>TradeTime)) cantrade=true;
                 
   // check for position opening:
   if(!PositionSelect(_Symbol))// If there isn't any opened positions
   {
      if((mqldt.hour==TradeTime) && (cantrade))//time to trade
        {
         if(Open[t1]>(Open[t2]+delta*_Point))  //check sell conditions
           {                  
               OpenShort(lot,10,"EUR/USD 20 pips expert (Short)",1234);//open Short position
               cantrade=false; // reset flag (disable trading until the next day)
               return; // exit
           }
         if((Open[t1]+delta*_Point)<Open[t2])//check buy conditions
           {
               OpenLong(lot,10,"EUR/USD 20 pips expert (Long)",1234);//铗牮噱?镱玷鲨?Long
               cantrade=false; // reset flag (disable trading until the next day)
               return; // exit
           }
        }
   }
   return;
  }
//+------------------------------------------------------------------+
