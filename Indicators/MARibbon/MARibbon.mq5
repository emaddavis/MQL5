//+------------------------------------------------------------------+
//|                                                     MARibbon.mq5 |
//|                                      Copyright 2020, Emad Davis. |
//|                                             github.com/emaddavis |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Emad Davis."
#property link      "github.com/emaddavis"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers   5     //Amount of data buffers
#property indicator_plots     3     //Amount of indicators drawn on screen

#property indicator_type1     DRAW_FILLING
#property indicator_label1    "Channel FastMA;Channel SlowMA"  //The ; lets us put two labels in the channel
#property indicator_color1    clrYellow,clrFireBrick           //Two colors when fast>slow or slow>fast

#property indicator_type2     DRAW_LINE
#property indicator_label2    "SlowMA"
#property indicator_color2    clrGray
#property indicator_style2    STYLE_SOLID
#property indicator_width2    4

#property indicator_type3     DRAW_LINE
#property indicator_label3   "SlowMA"
#property indicator_color3    clrBlue
#property indicator_style3    STYLE_SOLID
#property indicator_width3    4


//--- input parameters
input int            InpSlowMAPeriod   =  34;         //Slow period
input ENUM_MA_METHOD InpSlowMAMode     =  MODE_EMA;   //Slow mode

input int            InpFastMAPeriod   =  13;         //Fast period
input ENUM_MA_METHOD InpFastMAMode     =  MODE_EMA;   //Fast mode

input int            InpSignalMAPeriod   =  5;           //Signal period
input ENUM_MA_METHOD InpSignalwMAMode     =  MODE_EMA;   //Signal mode

double BufferFastChannel[];   //BufferFast/SlowChannel = BufferFast/Slow, 
double BufferSlowChannel[];   //they are just different vairables bc they are used in different idicators   
double BufferFast[];
double BufferSlow[];
double BufferSignal[];

int MaxPeriod;

int FastHandle;
int SlowHandle;
int SignalHandle;




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, BufferFastChannel, INDICATOR_DATA);
   SetIndexBuffer(1, BufferSlowChannel, INDICATOR_DATA);
   SetIndexBuffer(2, BufferSlow, INDICATOR_DATA);
   SetIndexBuffer(3, BufferFast, INDICATOR_DATA);
   SetIndexBuffer(4, BufferSignal, INDICATOR_DATA);
   
   MaxPeriod      = (int)MathMax(MathMax(InpSignalMAPeriod, InpFastMAPeriod), InpSlowMAPeriod);

   SlowHandle     = iMA(Symbol(), Period(), InpSlowMAPeriod,0,InpSlowMAMode, PRICE_CLOSE);
   FastHandle     = iMA(Symbol(), Period(), InpFastMAPeriod,0,InpFastMAMode,PRICE_CLOSE);
   SignalHandle   = iMA(Symbol(), Period(), InpSignalMAPeriod,0,InpSignalwMAMode,PRICE_CLOSE);   
   
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MaxPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,MaxPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,MaxPeriod);
   
//---
   return(INIT_SUCCEEDED);
  }
  
  void OnDeinit(const int reason) {
   if(SlowHandle!=INVALID_HANDLE)   IndicatorRelease(SlowHandle);
   if(FastHandle!=INVALID_HANDLE)   IndicatorRelease(FastHandle);
   if(SignalHandle!=INVALID_HANDLE) IndicatorRelease(SignalHandle);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if (IsStopped())           return(0); //if stop flag triggered
   if (rates_total<MaxPeriod) return(0); // if not enought bars to calculate
   
   //Check that moving averages have all been claculated
   if (BarsCalculated(SlowHandle)<rates_total)     return(0);
   if (BarsCalculated(FastHandle)<rates_total)     return(0);
   if (BarsCalculated(SignalHandle)<rates_total)   return(0);
   
   //copy minimum amount of bars 
   int copyBars = 0;
   int startBar = 0;
   if(prev_calculated>rates_total || prev_calculated<=0) // if prev_calculated<=0 then it is the first run throught the loop,
     {                                                   // if prev_calculated>rates_total then we have reached the charts limit and dropped some bars
      copyBars = rates_total;                            // etiher way we wnat to copy all the available bars
      startBar = MaxPeriod;                              // in this case we copy from the first bar (MaxPeriod)
     }
   else                                                  
     {
      copyBars = rates_total-prev_calculated;            // else we copy the new bars that have been created
      if(prev_calculated>0) copyBars++;                  // we add 1 to copyBars to get the value of the current/most recent bar
      startBar = prev_calculated -1;                     // in this case we just overlap the last bar, to keep it updated
     }
     
     if (IsStopped())                                                return(0); 
     if (CopyBuffer(SlowHandle,0,0,copyBars,BufferSlowChannel)<=0)   return(0); //Notice, still copying from SlowHandle, just to BufferSlowChannel now,
     if (CopyBuffer(FastHandle,0,0,copyBars,BufferFastChannel)<=0)   return(0); //this is bc BufferSlowChannel=BufferSlow
     if (CopyBuffer(SlowHandle,0,0,copyBars,BufferSlow)<=0)          return(0); //Copy from Slowhandle, for the number of copyBars into BufferSlow 
     if (CopyBuffer(FastHandle,0,0,copyBars,BufferFast)<=0)          return(0); //Copy from Slowhandle, for the number of copyBars into BufferSlow
     if (CopyBuffer(SignalHandle,0,0,copyBars,BufferSignal)<=0)      return(0); 
     
     if (IsStopped()) return(0);
     for(int i=startBar;i<rates_total && !IsStopped();i++)
       {
        if((BufferFast[i]>=BufferSlow[i]&&BufferSignal[i]<BufferFast[i])
          ||(BufferFast[i]<BufferSlow[i]&&BufferSignal[i]>BufferFast[i]))
          {
           BufferFast[i] = EMPTY_VALUE;
           BufferSlow[i] = EMPTY_VALUE;
          }
       }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
