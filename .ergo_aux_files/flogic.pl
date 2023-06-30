
:-(compiler_options([xpp_on,canonical])).

/********** Tabling and Trailer Control Variables ************/

#define EQUALITYnone
#define INHERITANCEflogic
#define TABLINGreactive
#define TABLINGvariant
#define CUSTOMnone

#define FLORA_INCREMENTAL_TABLING 

/************************************************************************
  file: headerinc/flrheader_inc.flh

  Author(s): Guizhen Yang

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).
#mode standard Prolog

#include "flrheader.flh"
#include "flora_porting.flh"

/***********************************************************************/

/************************************************************************
  file: headerinc/flrheader_prog_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).
#mode standard Prolog

#include "flrheader_prog.flh"

/***********************************************************************/

#define FLORA_COMPILATION_ID 1

/************************************************************************
  file: headerinc/flrheader2_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
  It has files that must be included in the header and typically
  contain some Prolog statements. Such files cannot appear
  in flrheader.flh because flrheader.flh is included in various restricted
  contexts where Prolog statements are not allowed.

  NOT included in ADDED files (compiled for addition) -- only in LOADED
  ones and in trailers/patch
************************************************************************/

:-(compiler_options([xpp_on])).

#define TABLING_CONNECTIVE  :-

%% flora_tabling_methods is included here to affect preprocessing of
%% flrtable/flrhilogtable.flh dynamically
#include "flora_tabling_methods.flh"

/* note: inside flrtable.flh there are checks for FLORA_NONTABLED_DATA_MODULE
   that exclude tabling non-signature molecules
*/
#ifndef FLORA_NONTABLED_MODULE
#include "flrtable.flh"
#endif

/* if normal tabled module, then table hilog */
#if !defined(FLORA_NONTABLED_DATA_MODULE) && !defined(FLORA_NONTABLED_MODULE)
#include "flrhilogtable.flh"
#endif

#include "flrtable_always.flh"

#include "flrauxtables.flh"

%% include list of tabled predicates
#mode save
#mode nocomment "%"
#if defined(FLORA_FLT_FILENAME)
#include FLORA_FLT_FILENAME
#endif
#mode restore

/***********************************************************************/

/************************************************************************
  file: headerinc/flrdyna_inc.flh

  Author(s): Chang Zhao

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).

#define TABLING_CONNECTIVE  :-

#include "flrdyndeclare.flh"

/***********************************************************************/

/************************************************************************
  file: headerinc/flrindex_P_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).

#include "flrindex_P.flh"

/***********************************************************************/

#mode save
#mode nocomment "%"
#define FLORA_THIS_FILENAME  'flogic.ergo'
#mode restore
/************************************************************************
  file: headerinc/flrdefinition_inc.flh

  Author(s): Guizhen Yang

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

#include "flrdefinition.flh"

/***********************************************************************/

/************************************************************************
  file: headerinc/flrtrailerregistry_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

#include "flrtrailerregistry.flh"

/***********************************************************************/

/************************************************************************
  file: headerinc/flrrefreshtable_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).

#include "flrrefreshtable.flh"

/***********************************************************************/

/************************************************************************
  file: headerinc/flrdynamic_connectors_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).

#include "flrdynamic_connectors.flh"

/***********************************************************************/

/************************************************************************
  file: syslibinc/flrimportedcalls_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the FLORA-2 compiler.
************************************************************************/

%% Loads the file with all the import statements for predicates
%% that must be known everywhere

:-(compiler_options([xpp_on])).

#mode standard Prolog

#if !defined(FLORA_TERMS_FLH)
#define FLORA_TERMS_FLH
#include "flora_terms.flh"
#endif

?-(:(flrlibman,flora_load_library(FLLIBIMPORTEDCALLS))).

/***********************************************************************/

/************************************************************************
  file: headerinc/flrpatch_inc.flh

  Author(s): Guizhen Yang

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

#include "flrexportcheck.flh"
#include "flrpatch.flh"
/***********************************************************************/

/************************************************************************
  file: headerinc/flropposes_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

#include "flropposes.flh"

/***********************************************************************/

/************************************************************************
  file: headerinc/flrhead_dispatch_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).

#include "flrhead_dispatch.flh"

/***********************************************************************/

/************************************************************************
  file: syslibinc/flrclause_inc.flh

  Author(s): Chang Zhao

  This file is automatically included by the FLORA-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).

#mode standard Prolog

#if !defined(FLORA_TERMS_FLH)
#define FLORA_TERMS_FLH
#include "flora_terms.flh"
#endif

?-(:(flrlibman,flora_load_library(FLLIBCLAUSE))).

/***********************************************************************/

 
#if !defined(FLORA_FDB_FILENAME)
#if !defined(FLORA_LOADDYN_DATA)
#define FLORA_LOADDYN_DATA
#endif
#mode save
#mode nocomment "%"
#define FLORA_FDB_FILENAME  'flogic.fdb'
#mode restore
?-(:(flrutils,flora_loaddyn_data(FLORA_FDB_FILENAME,FLORA_THIS_MODULE_NAME,'fdb'))).
#else
#if !defined(FLORA_READ_CANONICAL_AND_INSERT)
#define FLORA_READ_CANONICAL_AND_INSERT
#endif
?-(:(flrutils,flora_read_canonical_and_insert(FLORA_FDB_FILENAME,FLORA_THIS_FDB_STORAGE))).
#endif

 
#if !defined(FLORA_FLM_FILENAME)
#if !defined(FLORA_LOADDYN_DATA)
#define FLORA_LOADDYN_DATA
#endif
#mode save
#mode nocomment "%"
#define FLORA_FLM_FILENAME  'flogic.flm'
#mode restore
?-(:(flrutils,flora_loaddyn_data(FLORA_FLM_FILENAME,FLORA_THIS_MODULE_NAME,'flm'))).
#else
#if !defined(FLORA_READ_CANONICAL_AND_INSERT)
#define FLORA_READ_CANONICAL_AND_INSERT
#endif
?-(:(flrutils,flora_read_descriptor_metafacts_canonical_and_insert(flogic,_ErrNum))).
#endif

 
#if !defined(FLORA_FLD_FILENAME)
#if !defined(FLORA_LOADDYN_DATA)
#define FLORA_LOADDYN_DATA
#endif
#mode save
#mode nocomment "%"
#define FLORA_FLD_FILENAME  'flogic.fld'
#mode restore
?-(:(flrutils,flora_loaddyn_data(FLORA_FLD_FILENAME,FLORA_THIS_MODULE_NAME,'fld'))).
#else
#if !defined(FLORA_READ_CANONICAL_AND_INSERT)
#define FLORA_READ_CANONICAL_AND_INSERT
#endif
?-(:(flrutils,flora_read_canonical_and_insert(FLORA_FLD_FILENAME,FLORA_THIS_FLD_STORAGE))).
#endif

 
#if !defined(FLORA_FLS_FILENAME)
#if !defined(FLORA_LOADDYN_DATA)
#define FLORA_LOADDYN_DATA
#endif
#mode save
#mode nocomment "%"
#define FLORA_FLS_FILENAME  'flogic.fls'
#mode restore
?-(:(flrutils,flora_loaddyn_data(FLORA_FLS_FILENAME,FLORA_THIS_MODULE_NAME,'fls'))).
#else
#if !defined(FLORA_READ_CANONICAL_AND_INSERT)
#define FLORA_READ_CANONICAL_AND_INSERT
#endif
?-(:(flrutils,flora_read_symbols_canonical_and_insert(FLORA_FLS_FILENAME,FLORA_THIS_FLS_STORAGE,_SymbolErrNum))).
#endif


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rules %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:-(FLORA_THIS_WORKSPACE(static^tblflapply)(check_weight_balance,'_$ctxt'(_CallerModuleVar,4,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(4,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasMaximumWeight,__FlightMaxWeight,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,4)),','(','(FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasMinCGLimit,__FlightMinCGLimit,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,4)),FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasMaxCGLimit,__FlightMaxCGLimit,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,4))),','(','(FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasCurrentWeight,__FlightCurrentWeight,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar5,4)),FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasCurrentCGPercentage,__CurrentCGPercentage,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar6,4))),','(fllibdelayedliteral(>,'flogic.flr',27,[__FlightMaxWeight,__FlightCurrentWeight]),','(fllibdelayedliteral(<,'flogic.flr',27,[__FlightMinCGLimit,__CurrentCGPercentage]),fllibdelayedliteral(>,'flogic.flr',28,[__FlightMaxCGLimit,__CurrentCGPercentage])))))),fllibexecute_delayed_calls([__CurrentCGPercentage,__FlightCurrentWeight,__FlightMaxCGLimit,__FlightMaxWeight,__FlightMinCGLimit],[])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(check_fuel_level,'_$ctxt'(_CallerModuleVar,6,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(6,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^mvd)('FuelChecking',hasFlightFuelLevel,__FlightCurrentFuelLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,6)),','(FLORA_THIS_WORKSPACE(d^mvd)('FuelChecking',hasRequiredFuelLevel,__FlightRequiredFuelLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,6)),fllibdelayedliteral(>=,'flogic.flr',36,[__FlightCurrentFuelLevel,__FlightRequiredFuelLevel]))),fllibexecute_delayed_calls([__FlightCurrentFuelLevel,__FlightRequiredFuelLevel],[])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(check_battery_voltage,'_$ctxt'(_CallerModuleVar,8,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(8,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^mvd)('BatteryVoltageChecking',hasCurrrentValue,__EngineCurrentBatteryVoltage,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,8)),','(FLORA_THIS_WORKSPACE(d^mvd)('BatteryVoltageChecking',hasMinimumRequiredValue,__EngineRequiredBatteryVoltage,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,8)),fllibdelayedliteral(>,'flogic.flr',46,[__EngineCurrentBatteryVoltage,__EngineRequiredBatteryVoltage]))),fllibexecute_delayed_calls([__EngineCurrentBatteryVoltage,__EngineRequiredBatteryVoltage],[])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(check_engine_temperature,'_$ctxt'(_CallerModuleVar,10,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(10,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineTemperatureChecking',hasCurrrentValue,__EngineCurrentTemperature,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,10)),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineTemperatureChecking',hasMinimumRequiredValue,__EngineRequiredMinimumTemperature,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,10)),FLORA_THIS_WORKSPACE(d^mvd)('EngineTemperatureChecking',hasMaximumRequiredValue,__EngineMaximumTemperature,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,10))),','(fllibdelayedliteral(>,'flogic.flr',54,[__EngineCurrentTemperature,__EngineRequiredMinimumTemperature]),fllibdelayedliteral(<,'flogic.flr',55,[__EngineCurrentTemperature,__EngineMaximumTemperature])))),fllibexecute_delayed_calls([__EngineCurrentTemperature,__EngineMaximumTemperature,__EngineRequiredMinimumTemperature],[])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(check_engine_oil_pressure,'_$ctxt'(_CallerModuleVar,12,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(12,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineOilPressureChecking',hasCurrrentValue,__EngineOilCurrentPressure,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,12)),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineOilPressureChecking',hasMinimumRequiredValue,__EngineOilRequiredMinimumPressure,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,12)),FLORA_THIS_WORKSPACE(d^mvd)('EngineOilPressureChecking',hasMaximumRequiredValue,__EngineOilMaximumPressure,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,12))),','(fllibdelayedliteral(>,'flogic.flr',62,[__EngineOilCurrentPressure,__EngineOilRequiredMinimumPressure]),fllibdelayedliteral(<,'flogic.flr',63,[__EngineOilCurrentPressure,__EngineOilMaximumPressure])))),fllibexecute_delayed_calls([__EngineOilCurrentPressure,__EngineOilMaximumPressure,__EngineOilRequiredMinimumPressure],[])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(check_engine_oil_level,'_$ctxt'(_CallerModuleVar,14,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(14,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineOilLevelChecking',hasCurrrentValue,__EngineCurrentOilLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,14)),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineOilLevelChecking',hasMinimumRequiredValue,__EngineMinimumOilLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,14)),FLORA_THIS_WORKSPACE(d^mvd)('EngineOilLevelChecking',hasMaximumRequiredValue,__EngineMaximumOilLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,14))),','(fllibdelayedliteral(>,'flogic.flr',71,[__EngineCurrentOilLevel,__EngineMinimumOilLevel]),fllibdelayedliteral(<,'flogic.flr',72,[__EngineCurrentOilLevel,__EngineMaximumOilLevel])))),fllibexecute_delayed_calls([__EngineCurrentOilLevel,__EngineMaximumOilLevel,__EngineMinimumOilLevel],[])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(check_engine_condition,'_$ctxt'(_CallerModuleVar,16,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(16,'flogic.flr',FLORA_THIS_MODULE_NAME),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_battery_voltage,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,16)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_temperature,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,16)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_oil_pressure,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,16)),FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_oil_level,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar5,16))))))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(preflight_check,'_$ctxt'(_CallerModuleVar,18,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(18,'flogic.flr',FLORA_THIS_MODULE_NAME),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_condition,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,18)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_fuel_level,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,18)),FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_condition,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,18)))))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(landing_protocol,__LandingProtocol,'_$ctxt'(_CallerModuleVar,20,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(20,'flogic.flr',FLORA_THIS_MODULE_NAME),','(';'(->(','(','(FLORA_THIS_WORKSPACE(d^mvd)('AirportVisibility',hasForcastedDecisionHeight,__CurrentDecisionHeight,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,20)),FLORA_THIS_WORKSPACE(d^mvd)('AirportVisibility',hasForcastedVisualRange,__CurrentVisualRange,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,20))),','(fllibdelayedliteral(>,'flogic.flr',91,[__CurrentDecisionHeight,200]),fllibdelayedliteral(>,'flogic.flr',91,[__CurrentVisualRange,550]))),=(__LandingProtocol,'CATI')),';'(->(','(fllibdelayedliteral(>,'flogic.flr',92,[__CurrentDecisionHeight,100]),','(fllibdelayedliteral(<,'flogic.flr',92,[__CurrentDecisionHeight,200]),','(fllibdelayedliteral(>,'flogic.flr',92,[__CurrentVisualRange,350]),fllibdelayedliteral(<,'flogic.flr',92,[__CurrentVisualRange,550])))),=(__LandingProtocol,'CATII')),';'(->(','(fllibdelayedliteral(>,'flogic.flr',93,[__CurrentDecisionHeight,50]),','(fllibdelayedliteral(<,'flogic.flr',93,[__CurrentDecisionHeight,100]),','(fllibdelayedliteral(>,'flogic.flr',93,[__CurrentVisualRange,200]),fllibdelayedliteral(<,'flogic.flr',93,[__CurrentVisualRange,350])))),=(__LandingProtocol,'CATIIIA')),';'(->(','(fllibdelayedliteral(>,'flogic.flr',94,[__CurrentDecisionHeight,10]),','(fllibdelayedliteral(<,'flogic.flr',94,[__CurrentDecisionHeight,50]),','(fllibdelayedliteral(>,'flogic.flr',94,[__CurrentVisualRange,50]),fllibdelayedliteral(<,'flogic.flr',94,[__CurrentVisualRange,200])))),=(__LandingProtocol,'CATIIIB')),->(','(fllibdelayedliteral(>,'flogic.flr',95,[__CurrentDecisionHeight,0]),','(fllibdelayedliteral(<,'flogic.flr',95,[__CurrentDecisionHeight,10]),','(fllibdelayedliteral(>,'flogic.flr',95,[__CurrentVisualRange,0]),fllibdelayedliteral(<,'flogic.flr',95,[__CurrentVisualRange,50])))),=(__LandingProtocol,'CATIIIC')))))),fllibexecute_delayed_calls([__CurrentDecisionHeight,__CurrentVisualRange,__LandingProtocol],[__LandingProtocol])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,22,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(22,'flogic.flr',FLORA_THIS_MODULE_NAME),','(';'(->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasFuelConsumption,__CurrentFuelConsumption,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,22)),fllibdelayedliteral(>,'flogic.flr',110,[__CurrentFuelConsumption,12])),=(__Print,'Increased fuel consumption rate')),->(fllibdelayedliteral(<,'flogic.flr',111,[__CurrentFuelConsumption,12]),=(__Print,'Increased fuel consumption rate is optimum'))),fllibexecute_delayed_calls([__CurrentFuelConsumption,__Print],[__Print])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,24,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(24,'flogic.flr',FLORA_THIS_MODULE_NAME),','(->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasCrossWind,__CurrentCrossWind,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,24)),fllibdelayedliteral(>,'flogic.flr',116,[__CurrentCrossWind,10])),=(__Print,'Heavy crosswinds')),fllibexecute_delayed_calls([__CurrentCrossWind,__Print],[__Print])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,26,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(26,'flogic.flr',FLORA_THIS_MODULE_NAME),','(->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasTailWind,__CurrentTailWind,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,26)),fllibdelayedliteral(>,'flogic.flr',120,[__CurrentTailWind,10])),=(__Print,'Heavy Tailwinds')),fllibexecute_delayed_calls([__CurrentTailWind,__Print],[__Print])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,28,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(28,'flogic.flr',FLORA_THIS_MODULE_NAME),','(->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasAirSpeed,__CurrentAirSpeed,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,28)),fllibdelayedliteral(>,'flogic.flr',124,[__CurrentAirSpeed,300])),=(__Print,'High AirSpeed')),fllibexecute_delayed_calls([__CurrentAirSpeed,__Print],[__Print])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,30,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(30,'flogic.flr',FLORA_THIS_MODULE_NAME),','(->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasAltitude,__CurrentAltitude,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,30)),fllibdelayedliteral(>,'flogic.flr',128,[__CurrentAltitude,6000])),=(__Print,'Altitude limit is reached')),fllibexecute_delayed_calls([__CurrentAltitude,__Print],[__Print])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(findRunways,__AirportName,__RunwayName,__Distance,'_$ctxt'(_CallerModuleVar,32,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(32,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^mvd)(__AirportName,flapply(hasRunway,__RunwayName),__Distance,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,32)),','(FLORA_THIS_WORKSPACE(d^mvd)(a01,hasLandingDistance,__RequiredLandingDistance,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,32)),fllibdelayedliteral(>,'flogic.flr',135,[__Distance,__RequiredLandingDistance]))),fllibexecute_delayed_calls([__AirportName,__Distance,__RequiredLandingDistance,__RunwayName],[__AirportName,__Distance,__RunwayName])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(final,'_$ctxt'(_CallerModuleVar,34,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(34,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^tblflapply)(potential_issue,__Print,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,34)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(landing_protocol,__LandingProtocol,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,34)),FLORA_THIS_WORKSPACE(d^tblflapply)(preflight_check,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,34)))),fllibexecute_delayed_calls([__LandingProtocol,__Print],[])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(lowfuellevel,__FuelLevel,'_$ctxt'(_CallerModuleVar,36,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(36,'flogic.flr',FLORA_THIS_MODULE_NAME),','(FLORA_THIS_WORKSPACE(d^mvd)(a01,hasFuelLevel,__FuelLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,36)),fllibdelayedliteral(>,'flogic.flr',153,[__FuelLevel,30.0])))).
:-(FLORA_THIS_WORKSPACE(static^tblflapply)(findRunways,__AirportName,__RunwayName,__Distance,'_$ctxt'(_CallerModuleVar,38,__newcontextvar1)),','('_$_$_ergo''rule_enabled'(38,'flogic.flr',FLORA_THIS_MODULE_NAME),','(','(FLORA_THIS_WORKSPACE(d^mvd)(__AirportName,flapply(hasRunway,__RunwayName),__Distance,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,38)),','(FLORA_THIS_WORKSPACE(d^mvd)(a01,hasFuelLevel,__FuelLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,38)),','(fllibdelayedliteral(<,'flogic.flr',158,[__FuelLevel,30.0]),','(FLORA_THIS_WORKSPACE(d^mvd)(a01,hasLandingDistance,__RequiredLandingDistance,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,38)),fllibdelayedliteral(>,'flogic.flr',160,[__Distance,__RequiredLandingDistance]))))),fllibexecute_delayed_calls([__AirportName,__Distance,__FuelLevel,__RequiredLandingDistance,__RunwayName],[__AirportName,__Distance,__RunwayName])))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rule signatures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

?-(fllibinsrulesig(4,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,16,FLORA_THIS_WORKSPACE(d^tblflapply)(check_weight_balance,'_$ctxt'(_CallerModuleVar,4,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasMaximumWeight,__FlightMaxWeight,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,4)),','(','(FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasMinCGLimit,__FlightMinCGLimit,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,4)),FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasMaxCGLimit,__FlightMaxCGLimit,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,4))),','(','(FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasCurrentWeight,__FlightCurrentWeight,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar5,4)),FLORA_THIS_WORKSPACE(d^mvd)('LoadChecking',hasCurrentCGPercentage,__CurrentCGPercentage,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar6,4))),','(fllibdelayedliteral(>,'flogic.flr',27,[__FlightMaxWeight,__FlightCurrentWeight]),','(fllibdelayedliteral(<,'flogic.flr',27,[__FlightMinCGLimit,__CurrentCGPercentage]),fllibdelayedliteral(>,'flogic.flr',28,[__FlightMaxCGLimit,__CurrentCGPercentage])))))),null,'_$_$_ergo''rule_enabled'(4,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__CurrentCGPercentage,__FlightCurrentWeight,__FlightMaxCGLimit,__FlightMaxWeight,__FlightMinCGLimit],[]),true)).
?-(fllibinsrulesig(6,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,19,FLORA_THIS_WORKSPACE(d^tblflapply)(check_fuel_level,'_$ctxt'(_CallerModuleVar,6,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)('FuelChecking',hasFlightFuelLevel,__FlightCurrentFuelLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,6)),','(FLORA_THIS_WORKSPACE(d^mvd)('FuelChecking',hasRequiredFuelLevel,__FlightRequiredFuelLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,6)),fllibdelayedliteral(>=,'flogic.flr',36,[__FlightCurrentFuelLevel,__FlightRequiredFuelLevel]))),null,'_$_$_ergo''rule_enabled'(6,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__FlightCurrentFuelLevel,__FlightRequiredFuelLevel],[]),true)).
?-(fllibinsrulesig(8,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,22,FLORA_THIS_WORKSPACE(d^tblflapply)(check_battery_voltage,'_$ctxt'(_CallerModuleVar,8,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)('BatteryVoltageChecking',hasCurrrentValue,__EngineCurrentBatteryVoltage,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,8)),','(FLORA_THIS_WORKSPACE(d^mvd)('BatteryVoltageChecking',hasMinimumRequiredValue,__EngineRequiredBatteryVoltage,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,8)),fllibdelayedliteral(>,'flogic.flr',46,[__EngineCurrentBatteryVoltage,__EngineRequiredBatteryVoltage]))),null,'_$_$_ergo''rule_enabled'(8,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__EngineCurrentBatteryVoltage,__EngineRequiredBatteryVoltage],[]),true)).
?-(fllibinsrulesig(10,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,25,FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_temperature,'_$ctxt'(_CallerModuleVar,10,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)('EngineTemperatureChecking',hasCurrrentValue,__EngineCurrentTemperature,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,10)),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineTemperatureChecking',hasMinimumRequiredValue,__EngineRequiredMinimumTemperature,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,10)),FLORA_THIS_WORKSPACE(d^mvd)('EngineTemperatureChecking',hasMaximumRequiredValue,__EngineMaximumTemperature,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,10))),','(fllibdelayedliteral(>,'flogic.flr',54,[__EngineCurrentTemperature,__EngineRequiredMinimumTemperature]),fllibdelayedliteral(<,'flogic.flr',55,[__EngineCurrentTemperature,__EngineMaximumTemperature])))),null,'_$_$_ergo''rule_enabled'(10,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__EngineCurrentTemperature,__EngineMaximumTemperature,__EngineRequiredMinimumTemperature],[]),true)).
?-(fllibinsrulesig(12,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,28,FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_oil_pressure,'_$ctxt'(_CallerModuleVar,12,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)('EngineOilPressureChecking',hasCurrrentValue,__EngineOilCurrentPressure,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,12)),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineOilPressureChecking',hasMinimumRequiredValue,__EngineOilRequiredMinimumPressure,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,12)),FLORA_THIS_WORKSPACE(d^mvd)('EngineOilPressureChecking',hasMaximumRequiredValue,__EngineOilMaximumPressure,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,12))),','(fllibdelayedliteral(>,'flogic.flr',62,[__EngineOilCurrentPressure,__EngineOilRequiredMinimumPressure]),fllibdelayedliteral(<,'flogic.flr',63,[__EngineOilCurrentPressure,__EngineOilMaximumPressure])))),null,'_$_$_ergo''rule_enabled'(12,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__EngineOilCurrentPressure,__EngineOilMaximumPressure,__EngineOilRequiredMinimumPressure],[]),true)).
?-(fllibinsrulesig(14,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,31,FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_oil_level,'_$ctxt'(_CallerModuleVar,14,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)('EngineOilLevelChecking',hasCurrrentValue,__EngineCurrentOilLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,14)),','(','(FLORA_THIS_WORKSPACE(d^mvd)('EngineOilLevelChecking',hasMinimumRequiredValue,__EngineMinimumOilLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,14)),FLORA_THIS_WORKSPACE(d^mvd)('EngineOilLevelChecking',hasMaximumRequiredValue,__EngineMaximumOilLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,14))),','(fllibdelayedliteral(>,'flogic.flr',71,[__EngineCurrentOilLevel,__EngineMinimumOilLevel]),fllibdelayedliteral(<,'flogic.flr',72,[__EngineCurrentOilLevel,__EngineMaximumOilLevel])))),null,'_$_$_ergo''rule_enabled'(14,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__EngineCurrentOilLevel,__EngineMaximumOilLevel,__EngineMinimumOilLevel],[]),true)).
?-(fllibinsrulesig(16,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,32,FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_condition,'_$ctxt'(_CallerModuleVar,16,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_battery_voltage,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,16)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_temperature,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,16)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_oil_pressure,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,16)),FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_oil_level,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar5,16))))),null,'_$_$_ergo''rule_enabled'(16,'flogic.flr',FLORA_THIS_MODULE_NAME),null,true)).
?-(fllibinsrulesig(18,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,33,FLORA_THIS_WORKSPACE(d^tblflapply)(preflight_check,'_$ctxt'(_CallerModuleVar,18,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_condition,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,18)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(check_fuel_level,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,18)),FLORA_THIS_WORKSPACE(d^tblflapply)(check_engine_condition,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,18)))),null,'_$_$_ergo''rule_enabled'(18,'flogic.flr',FLORA_THIS_MODULE_NAME),null,true)).
?-(fllibinsrulesig(20,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,36,FLORA_THIS_WORKSPACE(d^tblflapply)(landing_protocol,__LandingProtocol,'_$ctxt'(_CallerModuleVar,20,__newcontextvar1)),';'(->(','(','(FLORA_THIS_WORKSPACE(d^mvd)('AirportVisibility',hasForcastedDecisionHeight,__CurrentDecisionHeight,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,20)),FLORA_THIS_WORKSPACE(d^mvd)('AirportVisibility',hasForcastedVisualRange,__CurrentVisualRange,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,20))),','(fllibdelayedliteral(>,'flogic.flr',91,[__CurrentDecisionHeight,200]),fllibdelayedliteral(>,'flogic.flr',91,[__CurrentVisualRange,550]))),=(__LandingProtocol,'CATI')),';'(->(','(fllibdelayedliteral(>,'flogic.flr',92,[__CurrentDecisionHeight,100]),','(fllibdelayedliteral(<,'flogic.flr',92,[__CurrentDecisionHeight,200]),','(fllibdelayedliteral(>,'flogic.flr',92,[__CurrentVisualRange,350]),fllibdelayedliteral(<,'flogic.flr',92,[__CurrentVisualRange,550])))),=(__LandingProtocol,'CATII')),';'(->(','(fllibdelayedliteral(>,'flogic.flr',93,[__CurrentDecisionHeight,50]),','(fllibdelayedliteral(<,'flogic.flr',93,[__CurrentDecisionHeight,100]),','(fllibdelayedliteral(>,'flogic.flr',93,[__CurrentVisualRange,200]),fllibdelayedliteral(<,'flogic.flr',93,[__CurrentVisualRange,350])))),=(__LandingProtocol,'CATIIIA')),';'(->(','(fllibdelayedliteral(>,'flogic.flr',94,[__CurrentDecisionHeight,10]),','(fllibdelayedliteral(<,'flogic.flr',94,[__CurrentDecisionHeight,50]),','(fllibdelayedliteral(>,'flogic.flr',94,[__CurrentVisualRange,50]),fllibdelayedliteral(<,'flogic.flr',94,[__CurrentVisualRange,200])))),=(__LandingProtocol,'CATIIIB')),->(','(fllibdelayedliteral(>,'flogic.flr',95,[__CurrentDecisionHeight,0]),','(fllibdelayedliteral(<,'flogic.flr',95,[__CurrentDecisionHeight,10]),','(fllibdelayedliteral(>,'flogic.flr',95,[__CurrentVisualRange,0]),fllibdelayedliteral(<,'flogic.flr',95,[__CurrentVisualRange,50])))),=(__LandingProtocol,'CATIIIC')))))),null,'_$_$_ergo''rule_enabled'(20,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__CurrentDecisionHeight,__CurrentVisualRange,__LandingProtocol],[__LandingProtocol]),true)).
?-(fllibinsrulesig(22,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,43,FLORA_THIS_WORKSPACE(d^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,22,__newcontextvar1)),';'(->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasFuelConsumption,__CurrentFuelConsumption,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,22)),fllibdelayedliteral(>,'flogic.flr',110,[__CurrentFuelConsumption,12])),=(__Print,'Increased fuel consumption rate')),->(fllibdelayedliteral(<,'flogic.flr',111,[__CurrentFuelConsumption,12]),=(__Print,'Increased fuel consumption rate is optimum'))),null,'_$_$_ergo''rule_enabled'(22,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__CurrentFuelConsumption,__Print],[__Print]),true)).
?-(fllibinsrulesig(24,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,44,FLORA_THIS_WORKSPACE(d^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,24,__newcontextvar1)),->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasCrossWind,__CurrentCrossWind,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,24)),fllibdelayedliteral(>,'flogic.flr',116,[__CurrentCrossWind,10])),=(__Print,'Heavy crosswinds')),null,'_$_$_ergo''rule_enabled'(24,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__CurrentCrossWind,__Print],[__Print]),true)).
?-(fllibinsrulesig(26,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,45,FLORA_THIS_WORKSPACE(d^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,26,__newcontextvar1)),->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasTailWind,__CurrentTailWind,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,26)),fllibdelayedliteral(>,'flogic.flr',120,[__CurrentTailWind,10])),=(__Print,'Heavy Tailwinds')),null,'_$_$_ergo''rule_enabled'(26,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__CurrentTailWind,__Print],[__Print]),true)).
?-(fllibinsrulesig(28,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,46,FLORA_THIS_WORKSPACE(d^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,28,__newcontextvar1)),->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasAirSpeed,__CurrentAirSpeed,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,28)),fllibdelayedliteral(>,'flogic.flr',124,[__CurrentAirSpeed,300])),=(__Print,'High AirSpeed')),null,'_$_$_ergo''rule_enabled'(28,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__CurrentAirSpeed,__Print],[__Print]),true)).
?-(fllibinsrulesig(30,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,47,FLORA_THIS_WORKSPACE(d^tblflapply)(potential_issue,__Print,'_$ctxt'(_CallerModuleVar,30,__newcontextvar1)),->(','(FLORA_THIS_WORKSPACE(d^mvd)('PerformanceMonitoring',hasAltitude,__CurrentAltitude,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,30)),fllibdelayedliteral(>,'flogic.flr',128,[__CurrentAltitude,6000])),=(__Print,'Altitude limit is reached')),null,'_$_$_ergo''rule_enabled'(30,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__CurrentAltitude,__Print],[__Print]),true)).
?-(fllibinsrulesig(32,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,49,FLORA_THIS_WORKSPACE(d^tblflapply)(findRunways,__AirportName,__RunwayName,__Distance,'_$ctxt'(_CallerModuleVar,32,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)(__AirportName,flapply(hasRunway,__RunwayName),__Distance,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,32)),','(FLORA_THIS_WORKSPACE(d^mvd)(a01,hasLandingDistance,__RequiredLandingDistance,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,32)),fllibdelayedliteral(>,'flogic.flr',135,[__Distance,__RequiredLandingDistance]))),null,'_$_$_ergo''rule_enabled'(32,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__AirportName,__Distance,__RequiredLandingDistance,__RunwayName],[__AirportName,__Distance,__RunwayName]),true)).
?-(fllibinsrulesig(34,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,50,FLORA_THIS_WORKSPACE(d^tblflapply)(final,'_$ctxt'(_CallerModuleVar,34,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(potential_issue,__Print,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,34)),','(FLORA_THIS_WORKSPACE(d^tblflapply)(landing_protocol,__LandingProtocol,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,34)),FLORA_THIS_WORKSPACE(d^tblflapply)(preflight_check,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,34)))),null,'_$_$_ergo''rule_enabled'(34,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__LandingProtocol,__Print],[]),true)).
?-(fllibinsrulesig(36,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,58,FLORA_THIS_WORKSPACE(d^tblflapply)(lowfuellevel,__FuelLevel,'_$ctxt'(_CallerModuleVar,36,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)(a01,hasFuelLevel,__FuelLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,36)),fllibdelayedliteral(>,'flogic.flr',153,[__FuelLevel,30.0])),null,'_$_$_ergo''rule_enabled'(36,'flogic.flr',FLORA_THIS_MODULE_NAME),null,true)).
?-(fllibinsrulesig(38,'flogic.flr','_$_$_ergo''descr_vars',FLORA_THIS_MODULE_NAME,59,FLORA_THIS_WORKSPACE(d^tblflapply)(findRunways,__AirportName,__RunwayName,__Distance,'_$ctxt'(_CallerModuleVar,38,__newcontextvar1)),','(FLORA_THIS_WORKSPACE(d^mvd)(__AirportName,flapply(hasRunway,__RunwayName),__Distance,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar2,38)),','(FLORA_THIS_WORKSPACE(d^mvd)(a01,hasFuelLevel,__FuelLevel,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar3,38)),','(fllibdelayedliteral(<,'flogic.flr',158,[__FuelLevel,30.0]),','(FLORA_THIS_WORKSPACE(d^mvd)(a01,hasLandingDistance,__RequiredLandingDistance,'_$ctxt'(FLORA_THIS_MODULE_NAME,__newcontextvar4,38)),fllibdelayedliteral(>,'flogic.flr',160,[__Distance,__RequiredLandingDistance]))))),null,'_$_$_ergo''rule_enabled'(38,'flogic.flr',FLORA_THIS_MODULE_NAME),fllibexecute_delayed_calls([__AirportName,__Distance,__FuelLevel,__RequiredLandingDistance,__RunwayName],[__AirportName,__Distance,__RunwayName]),true)).


%%%%%%%%%%%%%%%%%%%%%%%%% Signatures for latent queries %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%% Queries found in the source file %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 
#if !defined(FLORA_FLS2_FILENAME)
#if !defined(FLORA_LOADDYN_DATA)
#define FLORA_LOADDYN_DATA
#endif
#mode save
#mode nocomment "%"
#define FLORA_FLS2_FILENAME  'flogic.fls2'
#mode restore
?-(:(flrutils,flora_loaddyn_data(FLORA_FLS2_FILENAME,FLORA_THIS_MODULE_NAME,'fls2'))).
#else
#if !defined(FLORA_READ_CANONICAL_AND_INSERT)
#define FLORA_READ_CANONICAL_AND_INSERT
#endif
?-(:(flrutils,flora_read_symbols_canonical_and_insert(FLORA_FLS2_FILENAME,FLORA_THIS_FLS_STORAGE,_SymbolErrNum))).
#endif

?-(:(flrutils,util_load_structdb('flogic.ergo',FLORA_THIS_MODULE_NAME))).

/************************************************************************
  file: headerinc/flrtrailer_inc.flh

  Author(s): Michael Kifer

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

#include "flrtrailer.flh"

/***********************************************************************/

/************************************************************************
  file: headerinc/flrpreddef_inc.flh

  Author(s): Chang Zhao

  This file is automatically included by the Flora-2 compiler.
************************************************************************/

:-(compiler_options([xpp_on])).

#include "flrpreddef.flh"

/***********************************************************************/

