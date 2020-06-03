//+------------------------------------------------------------------+
//|                                                     MARibbon.mq5 |
//|                                      Copyright 2020, Emad Davis. |
//|                                             github.com/emaddavis |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Emad Davis."
#property link      "github.com/emaddavis"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers   1     //Amount of data buffers
#property indicator_plots     1     //Amount of indicators drawn on screen

#property indicator_type1     DRAW_LINE
#property indicator_label1    "SlowMA"
#property indicator_color1    clrGray
#property indicator_style1    STYLE_SOLID
#property indicator_width1    4

//--- input parameters
input int            InpSlowMAPeriod   =  34;         //Slow period
input ENUM_MA_METHOD InpSlowMAMode     =  MODE_EMA;   //Slow mode

input int            InpFastMAPeriod   =  13;         //Fast period
input ENUM_MA_METHOD InpFastMAMode     =  MODE_EMA;   //Fast mode

input int            InpSignalMAPeriod   =  5;           //Signal period
input ENUM_MA_METHOD InpSignalwMAMode     =  MODE_EMA;   //Signal mode

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
   SetIndexBuffer(0, BufferSlow, INDICATOR_DATA);
   
   MaxPeriod      = (int)MathMax(MathMax(InpSignalMAPeriod, InpFastMAPeriod), InpSlowMAPeriod);

   SlowHandle     = iMA(Symbol(), Period(), InpSlowMAPeriod,0,InpSlowMAMode, PRICE_CLOSE);
   FastHandle     = iMA(Symbol(), Period(), InpFastMAPeriod,0,InpFastMAMode,PRICE_CLOSE);
   SignalHandle   = iMA(Symbol(), Period(), InpSignalMAPeriod,0,InpSignalwMAMode,PRICE_CLOSE);   
   
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MaxPeriod);
   
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
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
