max_weight(150000).
cg_limit(15, 40).

% check weight centre of gravity
flight_load(120000,18).
check_weight_balance :- flight_load(Weight,CGPercentage), max_weight(MaxWeight),
                        Weight =< MaxWeight,
                        cg_limit(MinLimit,MaxLimit),
                        CGPercentage =< MaxLimit, CGPercentage >= MinLimit.

%calculate the total fuel level
flight_required_fuel_level(100). % in kg
flight_currrent_fuel_level(110).
check_fuel_level :- flight_required_fuel_level(Required_Fuel_Level),
                     flight_currrent_fuel_level(FuelLevel),
                     Required_Fuel_Level < FuelLevel.

% Engine parameter required limits
battery_volatage_required_min(20). % in volts
engine_temperature_required_level(100,120).
engine_oil_required_level(10,15). % in quanrts
engine_oil_required_pressure(30,100). % in psi

% Engine parameter current value
battery_voltage_current_level(22).
engine_temeperature_current_value(110).
engine_oil_level_current_value(12).
engine_current_oil_pressure(40).

% engine monitoring condition
check_engine_condition:- battery_volatage_required_min(BatteryMinLimit),
                         engine_temperature_required_level(TemperatureMinLimit,TemperatureMaxLimit),
                         engine_oil_required_level(OilMinLevel,OilMaxLevel),
                         engine_oil_required_pressure(PressureMinLimit,PressureMaxLimit),
                         battery_voltage_current_level(BatteryLevel),
                         engine_temeperature_current_value(EngineTemperature),
                         engine_oil_level_current_value(EngineOilLevel),
                         engine_current_oil_pressure(EngineOilPressure),
                         BatteryMinLimit =< BatteryLevel,
                         TemperatureMinLimit =< EngineTemperature,
                         TemperatureMaxLimit >= EngineTemperature,
                         OilMinLevel =< EngineOilLevel,
                         OilMaxLevel >= EngineOilLevel,
                         PressureMaxLimit >= EngineOilPressure,
                         PressureMinLimit =< EngineOilPressure.

% preflight complete check
preflight_check :- check_weight_balance,
                   check_engine_condition,
                   check_fuel_level.

% provide the takeoff distance and speed
takeOffDistance(5000).
takeOffSpeed(120).
get_take_off_parameter :- takeOffDistance(TakeoffDistance),
                      takeOffSpeed(TakeoffSpeed),
                      write("Takeoff Speed is " = TakeoffSpeed),
                      write(" and Takeoff Distance is" = TakeoffDistance).

% check landing protocol
airport_visibility(300,600).
destination_flight('DFW').
landing_protocol(LandingProtocol) :- airport_visibility(DecisionHeight,VisualRange),
                                     DecisionHeight > 200, VisualRange > 550 -> LandingProtocol = 'CATI';
                                     DecisionHeight > 100,DecisionHeight < 100 , VisualRange > 350, VisualRange < 550 -> LandingProtocol = 'CATII';
                                     DecisionHeight > 50, DecisionHeight < 100, VisualRange > 200, VisualRange < 350 -> LandingProtocol = 'CATIIIA';
                                     DecisionHeight > 10,DecisionHeight < 50 , VisualRange > 50, VisualRange < 200 -> LandingProtocol = 'CATIIIB';
                                     DecisionHeight > 0 ,DecisionHeight < 10 , VisualRange > 0, VisualRange < 50 -> LandingProtocol = 'CATIIIC'.

% check the destination flight has the required landing capability
landing_capability_checking :- landing_protocol(LandingProtocol),
                               destination_flight(Destination),airport(Destination, LandingCapability),
                               LandingCapability == LandingProtocol.

% performance monitoring
% Facts representing the current state of the aircraft
fuel_consumption(10). % current fuel consumption rate (in liters per hour)
crosswind(5).         % current crosswind speed (in knots)
tailwind(10).         % current tailwind speed (in knots)
airspeed(200).        % current airspeed (in knots)
altitude(5000).       % current altitude (in feet)

% Rules for detecting potential issues and alerting the pilot
potential_issue :-
    fuel_consumption(F), F > 12,
    write('WARNING: Fuel consumption rate is too high!'), nl.

potential_issue :-
    crosswind(C), C > 10,
    write('WARNING: Crosswind speed is too high!'), nl.

potential_issue :-
    tailwind(T), T > 20,
    write('WARNING: Tailwind speed is too high!'), nl.

potential_issue :-
    airspeed(A), A > 250,
    write('WARNING: Airspeed is too high!'), nl.

potential_issue :-
    altitude(H), H > 10000,
    write('WARNING: Altitude is too high!'), nl.


% Diversion use case
%facts representing major issue
engine_temp(140).     % current engine temperature (in degrees Celsius)
fuel_level(0).
major_issue :-
    engine_temp(Temperature), Temperature > 120,
    write('WARNING: Engine temperature is too high!'), nl.
major_issue :-
    fuel_level(FuelLevel), FuelLevel <  10,
    write('WARNING: Fuel Level is very low'), nl.

plane_current_location(14.7530002593994, 42.9762992858887).
% Convert degrees to radians
degrees_to_radians(Deg, Rad) :-
    Rad is Deg * pi / 180.

% Calculate the Great Circle Distance
great_circle_distance(Lat1, Lon1, Lat2, Lon2, Distance) :-
    degrees_to_radians(Lat1, Lat1Rad),
    degrees_to_radians(Lon1, Lon1Rad),
    degrees_to_radians(Lat2, Lat2Rad),
    degrees_to_radians(Lon2, Lon2Rad),
    DeltaLat is Lat2Rad - Lat1Rad,
    DeltaLon is Lon2Rad - Lon1Rad,
    A is sin(DeltaLat / 2) ** 2
        + cos(Lat1Rad) * cos(Lat2Rad) * sin(DeltaLon / 2) ** 2,
    C is 2 * atan2(sqrt(A), sqrt(1 - A)),
    Distance is 6371 * C.

%find the lowest value
min_nested_list([H|T], MinNestedList) :-
                         min_nested_list(T, H, MinNestedList).

min_nested_list([], MinNestedList, MinNestedList).
min_nested_list([[MinValue,_]|T], [CurValue,CurList], MinNestedList) :- MinValue =< CurValue,
                                                                       min_nested_list(T, [MinValue,CurList], MinNestedList).
min_nested_list([[CurValue,CurList]|T], _, MinNestedList) :- min_nested_list(T, [CurValue,CurList], MinNestedList).


% Find the nearest latitude and longitude
nearest_lat_lon(V,N) :- plane_current_location(Lat,Lon),
                        findall([Distance,X],
                       (airport(X, Y, Z, Lat2, Lon2, RunwayDistance),
                       great_circle_distance(Lat, Lon, Lat2, Lon2, Distance)),
                       Distances),min_nested_list(Distances, MinNestedList),[V,N] = MinNestedList.

diversion_use_case(Airport,Distance,RunwayDistance) :- major_issue,
                                                       airport(X, Y, Z, Lat, Lon, RunwayDistance),
                                                       nearest_lat_lon(Distance, Airport).


airport('DCA').
%get frequency
get_airport_frequency(Destination, Frequency) :- airport(Destination), airport_frequency(Destination, Frequency).
departure_airport('DCA').
%find the nearest airport
minimum_fact(FromAirport,NearestAirport,Min) :- departure_airport(FromAirport),
    findall(X, airports_distance(FromAirport, NearestAirport,X), List),
    min_list(List, Min),airports_distance(FromAirport,NearestAirport,Min).

finalPredicate :- potential_issue,landing_capability_checking,
                 get_take_off_parameter,preflight_check,potential_issue.


airport_frequency('ATL', 122.9).
airport_frequency('ANC', 122.9).
airport_frequency('AUS', 122.8).
airport_frequency('BNA', 122.9).
airport_frequency('BOS', 122.8).
airport_frequency('BWI', 123.0).
airport_frequency('DCA', 122.9).
airport_frequency('DFW', 122.8).
airport_frequency('FLL', 124.6).
airport_frequency('IAD', 121.65).
airport_frequency('IAH', 120.4).
airport_frequency('JFK', 122.9).
airport_frequency('LAX', 122.7).
airport_frequency('LGA', 126.85).
airport_frequency('MCO', 126.625).
airport_frequency('MIA', 122.8).
airport_frequency('MSP', 122.9).
airport_frequency('ORD', 122.8).
airport_frequency('PBI', 132.65).
airport_frequency('PHX', 122.95).
airport_frequency('RDU', 122.9).
airport_frequency('SEA', 122.9).
airport_frequency('SFO', 128.35).
airport_frequency('SJC', 122.8).
airport_frequency('TPA', 126.625).
airport_frequency('SAN', 122.8).
airport_frequency('LGB', 123.05).
airport_frequency('SNA', 134.85).
airport_frequency('SLC', 126.2).
airport_frequency('LAS', 38.9).
airport_frequency('DEN', 138.25).
airport_frequency('HPN', 119.75).
airport_frequency('SAT', 123.0).
airport_frequency('MSY', 119.35).
airport_frequency('EWR', 322.1).
airport_frequency('CID', 119.35).
airport_frequency('HNL', 126.625).
airport_frequency('HOU', 122.725).
airport_frequency('ELP', 123.0).
airport_frequency('SJU', 127.45).
airport_frequency('CLE', 122.975).
airport_frequency('OAK', 126.625).
airport_frequency('TUS', 122.8).
airport_frequency('SAF', 122.725).
airport_frequency('PHL', 122.9).
airport_frequency('DTW', 119.3).
airport_frequency('YYZ', 122.725).
airport_frequency('YVR', 122.9).
airport_frequency('LHR', 31.48).
airport_frequency('LGW', 122.9).
airport_frequency('CDG', 126.625).
airport_frequency('FRA', 122.9).
airport_frequency('HEL', 143.35).
airport_frequency('NRT', 118.8).
airport_frequency('SYD', 30.45).
airport_frequency('SIN', 38.75).
airport_frequency('MEL', 38.7).
airport_frequency('DXB', 41.2).
airport_frequency('DEL', 120.75).
airport_frequency('DUB', 143.35).
airport_frequency('HKG', 118.8).
airport_frequency('PER', 30.45).
airport_frequency('AKL', 38.75).
airport_frequency('PEK', 38.7).
airport_frequency('WLG', 41.2).
airport_frequency('BNE', 120.75).
airport_frequency('PVG', 122.9).
airport_frequency('FCO', 122.9).
airport_frequency('BOM', 126.625).
airport_frequency('AMS', 132.65).
airport_frequency('KUL', 122.9).
airport_frequency('PRG', 122.8).
airport_frequency('BCN', 126.625).
airport_frequency('MAD', 122.8).
airport_frequency('VIE', 122.8).
airport_frequency('ZRH', 127.45).
airport_frequency('GVA', 122.9).
airport_frequency('YOW', 122.9).
airport_frequency('BRU', 125.5).
airport_frequency('MUC', 122.8).
airport_frequency('CHC', 122.8).
airport_frequency('CBR', 122.8).
airport_frequency('RSW', 127.45).
airport_frequency('MAN', 126.625).
airport_frequency('YUL', 126.625).
airport_frequency('YEG', 126.625).
airport_frequency('CGN', 126.625).
airport_frequency('LCY', 122.725).
airport_frequency('GOT', 127.45).
airport_frequency('VCE', 122.9).
airport_frequency('SNN', 127.45).
airport_frequency('OSL', 126.625).
airport_frequency('ARN', 122.75).
airport_frequency('STN', 122.8).
airport_frequency('EMA', 122.9).
airport_frequency('EDI', 122.9).
airport_frequency('GLA', 122.9).
airport_frequency('LPL', 122.6).
airport_frequency('YYC', 119.225).
airport_frequency('MNL', 122.8).
airport_frequency('BKK', 122.8).
airport_frequency('DME', 122.8).
airport_frequency('SVO', 122.9).
airport_frequency('ITM', 122.9).
airport_frequency('HND', 122.9).
airport_frequency('DOH', 126.625).
airport_frequency('ORY', 126.625).
airport_frequency('NCE', 126.625).
airport_frequency('MXP', 126.625).
airport_frequency('ATH', 126.625).
airport_frequency('ZAG', 122.8).
airport_frequency('BUD', 123.0).
airport_frequency('ALC', 134.75).
airport_frequency('BIO', 122.8).
airport_frequency('IBZ', 122.9).
airport_frequency('MAH', 122.3).
airport_frequency('CCJ', 122.8).
airport_frequency('HYD', 126.45).
airport_frequency('MAA', 114.6).
airport_frequency('CCU', 123.0).
airport_frequency('BLR', 122.2).
airport_frequency('ICN', 126.625).
airport_frequency('YYT', 127.45).
airport_frequency('TFN', 122.75).
airport_frequency('CPT', 126.625).
airport_frequency('JNB', 126.625).
airport_frequency('DUR', 122.7).
airport_frequency('NBO', 122.9).
airport_frequency('MBA', 122.8).
airport_frequency('MVD', 122.9).
airport_frequency('GIG', 122.9).
airport_frequency('GRU', 122.8).
airport_frequency('EZE', 122.9).
airport_frequency('LIM', 122.8).
airport_frequency('SCL', 122.2).
airport_frequency('MEX', 123.3).
airport_frequency('KIN', 126.625).
airport_frequency('TLH', 122.975).
airport_frequency('LCA', 126.625).
airport_frequency('WAW', 122.75).
airport_frequency('MLA', 126.625).
airport_frequency('SOF', 122.9).
airport_frequency('BEG', 122.9).
airport_frequency('CAI', 122.9).
airport_frequency('ADD', 123.05).
airport_frequency('TLV', 122.7).
airport_frequency('PIT', 126.625).
airport_frequency('PWM', 122.9).
airport_frequency('PDX', 122.7).
airport_frequency('OKC', 127.45).
airport_frequency('ONT', 122.9).
airport_frequency('ROC', 122.75).
airport_frequency('RST', 126.625).
airport_frequency('KWI', 126.625).
airport_frequency('PNH', 127.45).
airport_frequency('AYQ', 122.725).
airport_frequency('ASP', 122.8).
airport_frequency('OOL', 127.45).
airport_frequency('FAI', 126.625).
airport_frequency('CNS', 132.65).
airport_frequency('IST', 126.625).
airport_frequency('BAH', 122.8).
airport_frequency('YHZ', 122.95).
airport_frequency('AUH', 122.9).
airport_frequency('SGN', 121.725).
airport_frequency('YWG', 122.975).
airport_frequency('HAM', 122.9).
airport_frequency('STR', 122.9).
airport_frequency('GOA', 129.9).
airport_frequency('NAP', 123.05).
airport_frequency('PSA', 126.625).
airport_frequency('TRN', 126.625).
airport_frequency('BLQ', 126.625).
airport_frequency('TSF', 126.625).
airport_frequency('VRN', 122.8).
airport_frequency('NTE', 127.45).
airport_frequency('CPH', 122.75).
airport_frequency('CLT', 127.45).
airport_frequency('LUX', 122.9).
airport_frequency('CUN', 126.625).
airport_frequency('PSP', 126.625).
airport_frequency('MEM', 122.9).
airport_frequency('CVG', 122.8).
airport_frequency('IND', 126.625).
airport_frequency('MCI', 122.9).
airport_frequency('DAL', 126.625).
airport_frequency('STL', 132.65).
airport_frequency('ABQ', 126.625).
airport_frequency('MKE', 127.45).
airport_frequency('MDW', 126.625).
airport_frequency('HRO', 126.625).
airport_frequency('SLN', 122.9).
airport_frequency('OMA', 126.625).
airport_frequency('TUL', 127.45).
airport_frequency('PVR', 126.625).
airport_frequency('OGG', 122.9).
airport_frequency('MCY', 122.9).
airport_frequency('DUS', 122.9).
airport_frequency('GUM', 122.9).
airport_frequency('TXL', 122.8).
airport_frequency('CMB', 122.8).
airport_frequency('LIS', 122.8).
airport_frequency('GIB', 132.65).
airport_frequency('TUN', 123.07).
airport_frequency('TPE', 126.625).
airport_frequency('LTN', 122.7).
airport_frequency('KTM', 34.2).
airport_frequency('NAS', 118.1).
airport_frequency('FPO', 342.5).
airport_frequency('GGT', 118.1).
airport_frequency('EYW', 118.1).
airport_frequency('FUK', 122.85).
airport_frequency('KIX', 122.8).
airport_frequency('CTS', 118.1).
airport_frequency('JED', 126.5).
airport_frequency('MCT', 123.5).
airport_frequency('KEF', 123.5).
airport_frequency('BGI', 123.0).
airport_frequency('ANU', 123.2).
airport_frequency('STT', 123.5).
airport_frequency('BDA', 123.5).
airport_frequency('TAB', 123.2).
airport_frequency('POS', 118.9).
airport_frequency('LOS', 122.1).
airport_frequency('MBJ', 126.7).
airport_frequency('HRE', 127.1).
airport_frequency('LIT', 126.7).
airport_frequency('LPA', 127.1).
airport_frequency('SOU', 126.7).
airport_frequency('PMI', 119.1).
airport_frequency('ADL', 126.7).
airport_frequency('DRW', 126.7).
airport_frequency('CUR', 122.4).
airport_frequency('DPS', 118.6).
airport_frequency('CGK', 113.7).
airport_frequency('BON', 119.6).
airport_frequency('AUA', 122.1).
airport_frequency('ORF', 119.0).
airport_frequency('JAX', 126.8).
airport_frequency('PVD', 119.0).
airport_frequency('PUJ', 126.8).
airport_frequency('MDT', 126.7).
airport_frequency('SJO', 121.0).
airport_frequency('SMF', 126.7).
airport_frequency('RTB', 119.5).
airport_frequency('TGU', 127.1).
airport_frequency('LXR', 120.2).
airport_frequency('RIX', 135.5).
airport_frequency('RUH', 120.7).
airport_frequency('CAN', 122.4).
airport_frequency('AGP', 122.6).
airport_frequency('FNC', 127.1).
airport_frequency('LBA', 124.9).
airport_frequency('ABZ', 118.7).
airport_frequency('AYT', 124.1).
airport_frequency('ISB', 127.1).
airport_frequency('JER', 120.9).
airport_frequency('ZTH', 127.1).
airport_frequency('RHO', 127.8).
airport_frequency('BRS', 120.1).
airport_frequency('NCL', 118.1).
airport_frequency('GCI', 128.4).
airport_frequency('COS', 120.5).
airport_frequency('HSV', 129.35).
airport_frequency('BHM', 120.1).
airport_frequency('YQB', 118.6).
airport_frequency('RAP', 128.6).
airport_frequency('SDF', 120.7).
airport_frequency('BUF', 121.7).
airport_frequency('SHV', 125.8).
airport_frequency('BOI', 117.0).
airport_frequency('LIH', 121.7).
airport_frequency('LBB', 118.1).
airport_frequency('EIN', 127.1).
airport_frequency('SVQ', 120.9).
airport_frequency('BSL', 118.2).
airport_frequency('ECP', 126.7).
airport_frequency('HRL', 128.2).
airport_frequency('DBV', 121.7).
airport_frequency('RNO', 126.7).
airport_frequency('CMH', 122.9).
airport_frequency('IDA', 122.9).
airport_frequency('ALB', 123.6).
airport_frequency('SVG', 119.1).
airport_frequency('HKT', 118.1).
airport_frequency('AMM', 119.1).
airport_frequency('BGO', 118.1).
airport_frequency('ICT', 118.1).
airport_frequency('MAF', 267.3).
airport_frequency('YXE', 118.1).
airport_frequency('BDL', 118.1).
airport_frequency('BIL', 126.2).
airport_frequency('SXM', 121.3).
airport_frequency('NAN', 118.3).
airport_frequency('SGF', 118.1).
airport_frequency('RIC', 836.4).
airport_frequency('CCS', 134.1).
airport_frequency('GYE', 119.9).
airport_frequency('NKG', 119.9).
airport_frequency('TXK', 131.1).
airport_frequency('PIA', 126.2).
airport_frequency('TLL', 118.1).
airport_frequency('ALG', 119.7).
airport_frequency('ITO', 118.7).
airport_frequency('LEX', 118.2).
airport_frequency('GUA', 119.7).
airport_frequency('ISP', 119.1).
airport_frequency('IAG', 119.7).
airport_frequency('SWF', 119.4).
airport_frequency('BIM', 119.7).
airport_frequency('ORK', 118.1).
airport_frequency('HAV', 119.7).
airport_frequency('WRO', 118.1).
airport_frequency('CRP', 119.7).
airport_frequency('KHI', 118.8).
airport_frequency('LHE', 131.9).
airport_frequency('ASB', 119.3).
airport_frequency('VKO', 128.3).
airport_frequency('SPU', 119.3).
airport_frequency('TSE', 121.9).
airport_frequency('GYD', 129.0).
airport_frequency('JAI', 125.0).
airport_frequency('ACC', 118.3).
airport_frequency('BHD', 118.2).
airport_frequency('EBB', 118.0).
airport_frequency('HAJ', 119.7).
airport_frequency('LIN', 119.1).
airport_frequency('LYS', 119.0).
airport_frequency('MRS', 128.1).
airport_frequency('OTP', 121.7).
airport_frequency('RTM', 126.55).
airport_frequency('CMN', 118.0).
airport_frequency('TNG', 118.1).
airport_frequency('ABV', 119.7).
airport_frequency('ALA', 118.1).
airport_frequency('BEY', 119.9).
airport_frequency('CTU', 119.7).
airport_frequency('FAO', 118.1).
airport_frequency('FNA', 119.7).
airport_frequency('JMK', 119.0).
airport_frequency('JTR', 118.5).
airport_frequency('KBP', 118.775).
airport_frequency('RJK', 118.0).
airport_frequency('TLS', 136.8).
airport_frequency('LAD', 120.125).
airport_frequency('LED', 123.2).
airport_frequency('OPO', 123.2).
airport_frequency('TIP', 127.7).
airport_frequency('DAC', 123.2).
airport_frequency('ZYL', 123.2).
airport_frequency('LCG', 123.2).
airport_frequency('TAS', 122.8).
airport_frequency('IKA', 123.2).
airport_frequency('MRU', 122.8).
airport_frequency('SEZ', 122.8).
airport_frequency('ABI', 123.4).
airport_frequency('ACT', 123.15).
airport_frequency('CLL', 123.2).
airport_frequency('BMI', 123.2).
airport_frequency('BOG', 122.8).
airport_frequency('BPT', 123.0).
airport_frequency('DSM', 123.2).
airport_frequency('MYR', 123.2).
airport_frequency('AEX', 123.4).
airport_frequency('CZM', 123.0).
airport_frequency('AGU', 122.9).
airport_frequency('MTY', 123.2).
airport_frequency('AMA', 122.9).
airport_frequency('BJX', 123.2).
airport_frequency('BRO', 123.2).
airport_frequency('BTR', 122.9).
airport_frequency('BZE', 122.9).
airport_frequency('CAE', 122.9).
airport_frequency('CHA', 41.5).
airport_frequency('CHS', 38.9).
airport_frequency('CMI', 122.9).
airport_frequency('COU', 122.8).
airport_frequency('CRW', 122.75).
airport_frequency('DAY', 123.2).
airport_frequency('CUU', 126.7).
airport_frequency('DRO', 123.2).
airport_frequency('EVV', 123.2).
airport_frequency('FAR', 123.35).
airport_frequency('FAT', 123.2).
airport_frequency('FSD', 123.2).
airport_frequency('FSM', 122.8).
airport_frequency('FWA', 122.8).
airport_frequency('GCK', 123.0).
airport_frequency('GDL', 123.3).
airport_frequency('GGG', 125.5).
airport_frequency('GJT', 118.1).
airport_frequency('GPT', 123.2).
airport_frequency('GRI', 122.8).
airport_frequency('GRK', 122.8).
airport_frequency('GRR', 122.8).
airport_frequency('GSO', 123.2).
airport_frequency('GSP', 123.2).
airport_frequency('JAN', 123.4).
airport_frequency('JLN', 129.9).
airport_frequency('LAW', 122.8).
airport_frequency('LCH', 123.7).
airport_frequency('LFT', 126.7).
airport_frequency('LIR', 122.8).
airport_frequency('LRD', 122.8).
airport_frequency('MFE', 123.2).
airport_frequency('MGM', 123.2).
airport_frequency('MHK', 123.2).
airport_frequency('MLI', 123.2).
airport_frequency('MLM', 122.8).
airport_frequency('MLU', 131.05).
airport_frequency('MOB', 123.475).
airport_frequency('MSN', 126.7).
airport_frequency('MZT', 123.4).
airport_frequency('PBC', 118.3).
airport_frequency('PLS', 123.2).
airport_frequency('PNS', 122.8).
airport_frequency('PTY', 123.2).
airport_frequency('QRO', 123.2).
airport_frequency('ROW', 123.0).
airport_frequency('SAL', 123.2).
airport_frequency('SAV', 123.2).
airport_frequency('SJD', 122.8).
airport_frequency('SJT', 123.2).
airport_frequency('SLP', 135.65).
airport_frequency('SPI', 123.2).
airport_frequency('SPS', 123.2).
airport_frequency('TRC', 123.2).
airport_frequency('TYR', 123.2).
airport_frequency('TYS', 123.2).
airport_frequency('VPS', 121.8).
airport_frequency('XNA', 122.8).
airport_frequency('ZCL', 123.0).
airport_frequency('INN', 123.2).
airport_frequency('UVF', 123.2).
airport_frequency('CAK', 123.4).
airport_frequency('BRL', 132.1).
airport_frequency('MHT', 123.2).
airport_frequency('SYR', 119.2).
airport_frequency('YQR', 123.0).
airport_frequency('FLO', 122.8).
airport_frequency('AVL', 122.8).
airport_frequency('POM', 123.2).
airport_frequency('EGE', 123.5).
airport_frequency('HDN', 120.6).
airport_frequency('SRQ', 119.5).
airport_frequency('FOE', 122.8).
airport_frequency('LAN', 122.8).
airport_frequency('ROA', 132.1).
airport_frequency('MQT', 123.2).
airport_frequency('GRB', 123.45).
airport_frequency('BHX', 123.0).
airport_frequency('INV', 123.2).
airport_frequency('SZG', 123.35).
airport_frequency('KGS', 123.2).
airport_frequency('TRD', 122.8).
airport_frequency('HAN', 123.2).
airport_frequency('KHH', 123.2).
airport_frequency('NGO', 123.2).
airport_frequency('BLL', 123.5).
airport_frequency('BRN', 123.2).
airport_frequency('IOM', 132.1).
airport_frequency('GRX', 123.2).
airport_frequency('FLR', 123.2).
airport_frequency('DRS', 122.7).
airport_frequency('DOL', 123.2).
airport_frequency('BVE', 123.2).
airport_frequency('BES', 122.8).
airport_frequency('ANR', 123.2).
airport_frequency('BRE', 123.55).
airport_frequency('CFE', 122.8).
airport_frequency('PRN', 122.8).
airport_frequency('HME', 123.0).
airport_frequency('SXF', 123.2).
airport_frequency('ERF', 123.4).
airport_frequency('BFS', 123.2).
airport_frequency('NQY', 122.9).
airport_frequency('NOC', 122.8).
airport_frequency('AAL', 122.8).
airport_frequency('AES', 123.4).
airport_frequency('TOS', 123.3).
airport_frequency('TRF', 122.8).
airport_frequency('KRK', 123.2).
airport_frequency('KUN', 133.45).
airport_frequency('FUE', 126.7).
airport_frequency('ACE', 122.8).
airport_frequency('TFS', 123.0).
airport_frequency('AGA', 123.0).
airport_frequency('RAK', 123.2).
airport_frequency('SID', 123.2).
airport_frequency('BVC', 123.0).
airport_frequency('HRG', 123.2).
airport_frequency('SSH', 123.2).
airport_frequency('TIA', 123.0).
airport_frequency('PFO', 123.2).
airport_frequency('LEI', 123.2).
airport_frequency('MJV', 123.0).
airport_frequency('SCQ', 122.8).
airport_frequency('VLC', 126.2).
airport_frequency('BOD', 123.2).
airport_frequency('BIA', 122.8).
airport_frequency('AJA', 122.8).
airport_frequency('MPL', 123.2).
airport_frequency('SXB', 123.2).
airport_frequency('HER', 122.8).
airport_frequency('EFL', 123.2).
airport_frequency('KLX', 123.2).
airport_frequency('CFU', 123.2).
airport_frequency('PVK', 122.8).
airport_frequency('CHQ', 122.2).
airport_frequency('SKG', 126.7).
airport_frequency('BRI', 123.2).
airport_frequency('CTA', 123.2).
airport_frequency('PMO', 122.8).
airport_frequency('OLB', 123.2).
airport_frequency('PDL', 122.8).
airport_frequency('ADB', 123.3).
airport_frequency('DLM', 123.5).
airport_frequency('BJV', 123.2).
airport_frequency('SAW', 123.2).
airport_frequency('TIV', 123.2).
airport_frequency('NBE', 123.5).
airport_frequency('MSQ', 122.35).
airport_frequency('MLE', 123.2).
airport_frequency('DTM', 123.2).
airport_frequency('AGS', 122.0).
airport_frequency('BGR', 49.9).
airport_frequency('BTV', 123.2).
airport_frequency('FAY', 135.5).
airport_frequency('HHH', 123.5).
airport_frequency('ILM', 134.025).
airport_frequency('OAJ', 123.55).
airport_frequency('NUE', 122.2).
airport_frequency('LEJ', 122.9).
airport_frequency('CWL', 130.275).
airport_frequency('SEN', 123.2).
airport_frequency('HUY', 123.2).
airport_frequency('MME', 49.9).
airport_frequency('NWI', 123.2).
airport_frequency('EXT', 123.2).
airport_frequency('KRS', 123.2).
airport_frequency('GDN', 122.8).
airport_frequency('VXO', 122.8).
airport_frequency('LPI', 123.2).
airport_frequency('SPC', 122.8).
airport_frequency('NDR', 123.2).
airport_frequency('VXE', 123.4).
airport_frequency('KGL', 123.2).
airport_frequency('JRO', 123.2).
airport_frequency('SFB', 122.9).
airport_frequency('GRO', 123.2).
airport_frequency('JKH', 123.2).
airport_frequency('KIT', 123.2).
airport_frequency('SMI', 123.2).
airport_frequency('SUF', 123.2).
airport_frequency('LJU', 123.0).
airport_frequency('KYA', 122.7).
airport_frequency('ASR', 123.2).
airport_frequency('POP', 122.8).
airport_frequency('HOG', 123.2).
airport_frequency('VRA', 122.8).
airport_frequency('DMM', 123.2).
airport_frequency('EBL', 122.8).
airport_frequency('UIO', 123.2).
airport_frequency('PBM', 122.8).
airport_frequency('GUW', 123.2).
airport_frequency('TBS', 123.2).
airport_frequency('XMN', 122.8).
airport_frequency('HGH', 123.55).
airport_frequency('BQN', 122.8).
airport_frequency('APF', 444.1).
airport_frequency('GNV', 123.2).
airport_frequency('LRM', 123.2).
airport_frequency('SDQ', 123.2).
airport_frequency('STI', 122.8).
airport_frequency('SAP', 122.8).
airport_frequency('MID', 122.8).
airport_frequency('MGA', 122.2).
airport_frequency('PAP', 123.2).
airport_frequency('CYB', 122.8).
airport_frequency('GCM', 122.8).
airport_frequency('MHH', 122.8).
airport_frequency('ELH', 123.2).
airport_frequency('BEL', 123.2).
airport_frequency('BSB', 122.8).
airport_frequency('CNF', 123.0).
airport_frequency('CWB', 122.8).
airport_frequency('MAO', 122.8).
airport_frequency('REC', 123.2).
airport_frequency('SSA', 123.2).
airport_frequency('ASU', 122.8).
airport_frequency('BAQ', 122.9).
airport_frequency('CTG', 121.0).
airport_frequency('CLO', 123.2).
airport_frequency('MDE', 123.2).
airport_frequency('LPB', 119.4).
airport_frequency('BLA', 119.4).
airport_frequency('MAR', 123.2).
airport_frequency('GEO', 123.2).
airport_frequency('FDF', 122.85).
airport_frequency('PTP', 123.2).
airport_frequency('GND', 123.2).
airport_frequency('STX', 123.35).
airport_frequency('SKB', 123.2).
airport_frequency('DKR', 118.3).
airport_frequency('BUR', 123.2).
airport_frequency('AZS', 123.2).
airport_frequency('PSE', 123.2).
airport_frequency('ACY', 123.4).
airport_frequency('ABE', 130.0).
airport_frequency('ABY', 119.4).
airport_frequency('ATW', 127.2).
airport_frequency('AVP', 121.65).
airport_frequency('AZO', 118.7).
airport_frequency('BQK', 124.025).
airport_frequency('CHO', 123.0).
airport_frequency('CSG', 122.8).
airport_frequency('DAB', 122.8).
airport_frequency('DHN', 122.8).
airport_frequency('EWN', 119.3).
airport_frequency('FNT', 123.3).
airport_frequency('GTR', 123.0).
airport_frequency('LWB', 129.275).
airport_frequency('MBS', 123.0).
airport_frequency('MCN', 123.2).
airport_frequency('MEI', 122.8).
airport_frequency('MLB', 122.8).
airport_frequency('MSL', 123.3).
airport_frequency('PHF', 123.3).
airport_frequency('PIB', 134.25).
airport_frequency('SBN', 122.725).
airport_frequency('TRI', 123.2).
airport_frequency('TTN', 122.8).
airport_frequency('TUP', 122.8).
airport_frequency('VLD', 126.7).
airport_frequency('KIR', 122.8).
airport_frequency('KTW', 126.0).
airport_frequency('LUZ', 126.0).
airport_frequency('PPT', 134.675).
airport_frequency('LNY', 118.525).
airport_frequency('KOA', 123.0).
airport_frequency('APW', 129.275).
airport_frequency('PPG', 122.9).
airport_frequency('MAJ', 122.725).
airport_frequency('CXI', 124.275).
airport_frequency('TRW', 122.7).
airport_frequency('INU', 123.2).
airport_frequency('JHM', 122.8).
airport_frequency('MKK', 122.725).
airport_frequency('YXU', 126.5).
airport_frequency('ALO', 133.4).
airport_frequency('SUX', 123.5).
airport_frequency('YKF', 135.3).
airport_frequency('VNO', 123.0).
airport_frequency('AGR', 122.8).
airport_frequency('HJR', 123.2).
airport_frequency('VNS', 129.275).
airport_frequency('VVO', 123.2).
airport_frequency('BOJ', 123.2).
airport_frequency('IXE', 123.2).
airport_frequency('REU', 123.2).
airport_frequency('BZR', 122.8).
airport_frequency('AMD', 129.275).
airport_frequency('JDH', 123.3).
airport_frequency('PNQ', 123.17).
airport_frequency('SZX', 122.775).
airport_frequency('HIJ', 123.35).
airport_frequency('DIL', 122.8).
airport_frequency('TSN', 122.8).
airport_frequency('CSX', 132.575).
airport_frequency('PEN', 122.85).
airport_frequency('WUH', 123.2).
airport_frequency('HAK', 123.2).
airport_frequency('KMG', 128.27).
airport_frequency('FOC', 125.0).
airport_frequency('NGB', 123.35).
airport_frequency('TAO', 122.8).
airport_frequency('CKG', 123.05).
airport_frequency('KWE', 123.3).
airport_frequency('NNG', 118.325).
airport_frequency('KOJ', 122.725).
airport_frequency('OIT', 123.2).
airport_frequency('KMQ', 123.2).
airport_frequency('YGJ', 122.8).
airport_frequency('MYJ', 122.9).
airport_frequency('TAK', 123.2).
airport_frequency('KIJ', 122.8).
airport_frequency('SDJ', 123.4).
airport_frequency('CJU', 123.2).
airport_frequency('PUS', 123.3).
airport_frequency('OKA', 129.275).
airport_frequency('SPN', 123.2).
airport_frequency('ROR', 132.65).
airport_frequency('RGN', 122.5).
airport_frequency('DMK', 122.8).
airport_frequency('CNX', 123.2).
airport_frequency('KBV', 122.8).
airport_frequency('USM', 123.2).
airport_frequency('HDY', 123.4).
airport_frequency('DAD', 122.8).
airport_frequency('BWN', 123.15).
airport_frequency('CEB', 118.8).
airport_frequency('ULN', 123.4).
airport_frequency('MFM', 123.4).
airport_frequency('BPN', 123.2).
airport_frequency('BKI', 123.2).
airport_frequency('CRK', 123.2).
airport_frequency('KBR', 123.2).
airport_frequency('ILO', 123.2).
airport_frequency('REP', 123.2).
airport_frequency('KHV', 123.4).
airport_frequency('UUS', 122.8).
airport_frequency('CGQ', 123.0).
airport_frequency('DLC', 123.4).
airport_frequency('SHE', 122.8).
airport_frequency('KCH', 122.8).
airport_frequency('MYY', 123.2).
airport_frequency('KUA', 123.2).
airport_frequency('IPH', 122.8).
airport_frequency('LGK', 122.725).
airport_frequency('TGG', 123.2).
airport_frequency('SZB', 123.5).
airport_frequency('SHJ', 123.2).
airport_frequency('ADE', 123.2).
airport_frequency('CJB', 123.3).
airport_frequency('COK', 122.35).
airport_frequency('VAR', 128.7).
airport_frequency('TRV', 122.9).
airport_frequency('DVO', 122.9).
airport_frequency('VTE', 122.9).
airport_frequency('SUB', 122.9).
airport_frequency('BDO', 122.8).
airport_frequency('LOP', 123.45).
airport_frequency('KLO', 139.33).
airport_frequency('PKU', 123.2).
airport_frequency('PLM', 122.9).
airport_frequency('SOC', 122.75).
airport_frequency('SRG', 122.7).
airport_frequency('UPG', 128.225).
airport_frequency('TRZ', 122.8).
airport_frequency('SAH', 123.0).
airport_frequency('JOG', 126.575).
airport_frequency('DIU', 122.1).
airport_frequency('PBD', 122.8).
airport_frequency('NOU', 122.9).
airport_frequency('TSA', 124.65).
airport_frequency('SHM', 132.85).
airport_frequency('UKB', 123.0).
airport_frequency('OBO', 122.8).
airport_frequency('HKD', 123.5).
airport_frequency('KUH', 123.2).
airport_frequency('MMB', 123.2).
airport_frequency('SHB', 123.2).
airport_frequency('WKJ', 122.8).
airport_frequency('UBJ', 122.35).
airport_frequency('MBE', 122.7).
airport_frequency('AKJ', 123.4).
airport_frequency('KMI', 129.275).
airport_frequency('KKJ', 123.0).
airport_frequency('HSG', 132.35).
airport_frequency('KMJ', 122.8).
airport_frequency('NGS', 123.2).
airport_frequency('ASJ', 122.8).
airport_frequency('TOY', 132.35).
airport_frequency('NTQ', 123.0).
airport_frequency('OKJ', 122.8).
airport_frequency('IZO', 125.9).
airport_frequency('KCZ', 126.7).
airport_frequency('TTJ', 123.5).
airport_frequency('TKS', 123.5).
airport_frequency('IWJ', 123.5).
airport_frequency('AOJ', 123.5).
airport_frequency('GAJ', 123.5).
airport_frequency('AXT', 123.2).
airport_frequency('MSJ', 123.2).
airport_frequency('ONJ', 130.25).
airport_frequency('SYO', 119.1).
airport_frequency('HAC', 123.2).
airport_frequency('OIM', 123.2).
airport_frequency('GMP', 126.7).
airport_frequency('ISG', 123.5).
airport_frequency('MMY', 123.2).
airport_frequency('SHA', 126.7).
airport_frequency('FNI', 122.35).
airport_frequency('CRL', 122.725).
airport_frequency('WAT', 123.2).
airport_frequency('RYG', 123.5).
airport_frequency('WMI', 123.2).
airport_frequency('RZE', 123.2).
airport_frequency('PUY', 123.2).
airport_frequency('ZAD', 123.2).
airport_frequency('BVA', 122.1).
airport_frequency('TPS', 120.0).
airport_frequency('BGY', 120.9).
airport_frequency('CIA', 122.8).
airport_frequency('CCC', 118.8).
airport_frequency('DJE', 133.05).
airport_frequency('HDF', 132.65).
airport_frequency('FMO', 121.7).
airport_frequency('FDH', 122.5).
airport_frequency('GWT', 118.8).
airport_frequency('POZ', 123.9).
airport_frequency('WDH', 122.8).
airport_frequency('XRY', 118.5).
airport_frequency('GPA', 125.8).
airport_frequency('GRZ', 121.8).
airport_frequency('LNZ', 118.5).
airport_frequency('ESB', 119.2).
airport_frequency('KIV', 126.2).
airport_frequency('TGD', 129.175).
airport_frequency('OVB', 121.7).
airport_frequency('DYU', 30.88).
airport_frequency('GOJ', 34.46).
airport_frequency('KUF', 119.0).
airport_frequency('LUN', 122.8).
airport_frequency('HGA', 122.3).
airport_frequency('BBO', 118.65).
airport_frequency('JIB', 133.0).
airport_frequency('HBE', 122.3).
airport_frequency('PZU', 123.275).
airport_frequency('JUB', 122.3).
airport_frequency('KRT', 132.9).
airport_frequency('DAR', 123.25).
airport_frequency('GSM', 123.3).
airport_frequency('SKP', 133.75).
airport_frequency('KBL', 123.55).
airport_frequency('BTS', 122.1).
airport_frequency('DLA', 122.1).
airport_frequency('AAE', 134.65).
airport_frequency('CZL', 118.3).
airport_frequency('ORN', 118.3).
airport_frequency('COO', 122.8).
airport_frequency('OUA', 126.7).
airport_frequency('ABJ', 123.2).
airport_frequency('NIM', 123.2).
airport_frequency('MIR', 127.2).
airport_frequency('SFA', 121.2).
airport_frequency('LFW', 124.2).
airport_frequency('BZV', 119.0).
airport_frequency('PNR', 121.7).
airport_frequency('BGF', 26.46).
airport_frequency('NSI', 34.46).
airport_frequency('RUN', 126.2).
airport_frequency('TNR', 568.0).
airport_frequency('LBV', 122.1).
airport_frequency('NDJ', 123.7).
airport_frequency('FIH', 122.0).
airport_frequency('BKO', 122.0).
airport_frequency('ROB', 128.55).
airport_frequency('RBA', 122.0).
airport_frequency('NKC', 126.7).
airport_frequency('CKY', 122.1).
airport_frequency('RAI', 132.25).
airport_frequency('OVD', 126.7).
airport_frequency('VGO', 122.1).
airport_frequency('PUF', 118.2).
airport_frequency('BIQ', 127.9).
airport_frequency('CLY', 121.8).
airport_frequency('RNS', 123.375).
airport_frequency('OSR', 118.2).
airport_frequency('EVN', 120.7).
airport_frequency('SVX', 122.0).
airport_frequency('UGC', 122.0).
airport_frequency('YYJ', 126.7).
airport_frequency('ACV', 126.7).
airport_frequency('BFL', 122.1).
airport_frequency('CEC', 22.89).
airport_frequency('CIC', 122.1).
airport_frequency('EUG', 135.25).
airport_frequency('LMT', 122.775).
airport_frequency('MFR', 133.95).
airport_frequency('MOD', 122.1).
airport_frequency('MRY', 128.425).
airport_frequency('OTH', 122.1).
airport_frequency('PSC', 126.7).
airport_frequency('RDD', 122.8).
airport_frequency('RDM', 122.1).
airport_frequency('SBA', 134.2).
airport_frequency('SBP', 126.7).
airport_frequency('RMQ', 122.1).
airport_frequency('TNN', 123.7).
airport_frequency('TYN', 122.7).
airport_frequency('YLW', 132.25).
airport_frequency('ASE', 123.2).
airport_frequency('BLI', 122.2).
airport_frequency('CLD', 122.2).
airport_frequency('GEG', 134.25).
airport_frequency('IGM', 126.7).
airport_frequency('MCE', 122.8).
airport_frequency('MMH', 122.1).
airport_frequency('YUM', 122.1).
airport_frequency('PRC', 123.2).
airport_frequency('SMX', 123.2).
airport_frequency('STS', 126.7).
airport_frequency('VIS', 122.8).
airport_frequency('DGO', 122.7).
airport_frequency('HMO', 122.1).
airport_frequency('LTO', 124.6).
airport_frequency('UPN', 122.1).
airport_frequency('ZIH', 123.2).
airport_frequency('ZLO', 126.7).
airport_frequency('RAR', 122.1).
airport_frequency('TNA', 126.7).
airport_frequency('XIY', 122.1).
airport_frequency('KHN', 122.1).
airport_frequency('CGO', 128.7).
airport_frequency('YNT', 126.7).
airport_frequency('PVU', 122.1).
airport_frequency('BTM', 123.2).
airport_frequency('BZN', 135.0).
airport_frequency('CDC', 125.85).
airport_frequency('CNY', 134.6).
airport_frequency('COD', 122.2).
airport_frequency('CPR', 126.7).
airport_frequency('EKO', 122.2).
airport_frequency('GCC', 123.2).
airport_frequency('FCA', 134.05).
airport_frequency('GTF', 126.7).
airport_frequency('HLN', 122.3).
airport_frequency('JAC', 128.6).
airport_frequency('LWS', 122.3).
airport_frequency('MSO', 126.7).
airport_frequency('PIH', 122.7).
airport_frequency('RKS', 122.2).
airport_frequency('SGU', 122.2).
airport_frequency('TWF', 124.025).
airport_frequency('VEL', 122.85).
airport_frequency('XUZ', 118.3).
airport_frequency('SYX', 118.3).
airport_frequency('BKG', 120.5).
airport_frequency('YMM', 128.0).
airport_frequency('AIA', 124.1).
airport_frequency('ALS', 133.65).
airport_frequency('BFF', 122.5).
airport_frequency('BIS', 121.7).
airport_frequency('CEZ', 122.95).
airport_frequency('CYS', 123.0).
airport_frequency('DDC', 118.3).
airport_frequency('DIK', 128.7).
airport_frequency('EAR', 122.1).
airport_frequency('FMN', 135.4).
airport_frequency('GUC', 123.0).
airport_frequency('ILG', 135.4).
airport_frequency('ISN', 122.8).
airport_frequency('LAR', 123.0).
airport_frequency('LBF', 122.8).
airport_frequency('LBL', 123.2).
airport_frequency('LNK', 128.75).
airport_frequency('MCK', 122.8).
airport_frequency('MOT', 128.5).
airport_frequency('MTJ', 122.3).
airport_frequency('PGA', 132.4).
airport_frequency('PIR', 122.3).
airport_frequency('PUB', 123.375).
airport_frequency('RIW', 122.3).
airport_frequency('SHR', 125.9).
airport_frequency('ART', 126.7).
airport_frequency('CMX', 122.8).
airport_frequency('CWA', 122.925).
airport_frequency('DBQ', 122.2).
airport_frequency('DEC', 126.9).
airport_frequency('DLH', 122.2).
airport_frequency('EAU', 134.55).
airport_frequency('ELM', 123.275).
airport_frequency('LSE', 122.2).
airport_frequency('MKG', 119.0).
airport_frequency('PAH', 124.3).
airport_frequency('STC', 119.0).
airport_frequency('TOL', 128.27).
airport_frequency('TVC', 122.825).
airport_frequency('SCE', 123.2).
airport_frequency('SUV', 122.7).
airport_frequency('TBU', 133.9).
airport_frequency('VLI', 122.0).
airport_frequency('ZQN', 122.0).
airport_frequency('ARM', 122.1).
airport_frequency('BHQ', 122.1).
airport_frequency('HTI', 135.4).
airport_frequency('MKY', 122.2).
airport_frequency('BNK', 126.7).
airport_frequency('PPP', 122.7).
airport_frequency('BME', 135.3).
airport_frequency('BHS', 122.7).
airport_frequency('TSV', 126.7).
airport_frequency('GLT', 122.8).
airport_frequency('GFF', 122.1).
airport_frequency('HVB', 126.7).
airport_frequency('LDH', 122.1).
airport_frequency('LSY', 122.5).
airport_frequency('AVV', 122.5).
airport_frequency('ABX', 122.5).
airport_frequency('MIM', 123.55).
airport_frequency('HBA', 122.5).
airport_frequency('MQL', 122.3).
airport_frequency('LST', 132.1).
airport_frequency('MRZ', 126.7).
airport_frequency('MYA', 122.3).
airport_frequency('NRA', 122.15).
airport_frequency('OAG', 122.15).
airport_frequency('KTA', 122.3).
airport_frequency('PKE', 122.3).
airport_frequency('PQQ', 123.475).
airport_frequency('CFS', 122.8).
airport_frequency('DBO', 134.35).
airport_frequency('NLK', 123.15).
airport_frequency('TMW', 126.7).
airport_frequency('WGA', 123.15).
airport_frequency('TRO', 125.95).
airport_frequency('TWB', 122.0).
airport_frequency('NTL', 122.0).
airport_frequency('DPO', 122.8).
airport_frequency('KNS', 122.9).
airport_frequency('MGB', 132.2).
airport_frequency('KGI', 122.1).
airport_frequency('PHE', 122.1).
airport_frequency('BWT', 123.3).
airport_frequency('TUO', 122.8).
airport_frequency('DUD', 122.1).
airport_frequency('GIS', 122.1).
airport_frequency('HLZ', 122.1).
airport_frequency('KKE', 122.1).
airport_frequency('KAT', 119.7).
airport_frequency('NPL', 128.1).
airport_frequency('NPE', 121.6).
airport_frequency('NSN', 125.0).
airport_frequency('PMR', 122.8).
airport_frequency('PPQ', 123.5).
airport_frequency('ROT', 122.55).
airport_frequency('TRG', 122.8).
airport_frequency('BHE', 118.4).
airport_frequency('WHK', 124.9).
airport_frequency('WRE', 125.15).
airport_frequency('WAG', 126.4).
airport_frequency('HLD', 134.15).
airport_frequency('TAE', 118.4).
airport_frequency('YKS', 118.4).
airport_frequency('MWX', 126.7).
airport_frequency('CJJ', 133.85).
airport_frequency('IKT', 122.3).
airport_frequency('UUD', 118.7).
airport_frequency('KJA', 121.0).
airport_frequency('FNJ', 123.95).
airport_frequency('LHW', 118.7).
airport_frequency('LXA', 121.9).
airport_frequency('HRB', 123.275).
airport_frequency('JMU', 122.125).
airport_frequency('MDG', 118.4).
airport_frequency('NDG', 122.3).
airport_frequency('YNJ', 122.3).
airport_frequency('JGS', 123.275).
airport_frequency('TLC', 122.8).
airport_frequency('LBE', 126.7).
airport_frequency('ORH', 123.5).
airport_frequency('PBG', 122.1).
airport_frequency('TCB', 122.1).
airport_frequency('GHB', 128.3).
airport_frequency('ZSA', 122.1).
airport_frequency('AXM', 123.2).
airport_frequency('YQM', 125.15).
airport_frequency('YTZ', 134.15).
airport_frequency('AOO', 118.2).
airport_frequency('BGM', 121.7).
airport_frequency('BKW', 118.2).
airport_frequency('HGR', 132.3).
airport_frequency('JST', 126.7).
airport_frequency('LNS', 122.1).
airport_frequency('MGW', 121.9).
airport_frequency('SHD', 125.7).
airport_frequency('ITH', 132.35).
airport_frequency('GFK', 123.0).
airport_frequency('AZA', 123.375).
airport_frequency('RFD', 125.7).
airport_frequency('ABR', 122.1).
airport_frequency('APN', 122.1).
airport_frequency('ATY', 128.275).
airport_frequency('BJI', 125.1).
airport_frequency('BRD', 128.275).
airport_frequency('HIB', 121.8).
airport_frequency('IMT', 126.0).
airport_frequency('INL', 128.275).
airport_frequency('RHI', 118.55).
airport_frequency('ACK', 126.0).
airport_frequency('AUG', 122.2).
airport_frequency('BHB', 124.6).
airport_frequency('HYA', 132.9).
airport_frequency('LEB', 126.7).
airport_frequency('MVY', 126.7).
airport_frequency('PQI', 122.8).
airport_frequency('PVC', 122.1).
airport_frequency('RKD', 122.1).
airport_frequency('RUT', 126.7).
airport_frequency('SLK', 122.8).
airport_frequency('BET', 122.8).
airport_frequency('BRW', 133.4).
airport_frequency('CDB', 127.1).
airport_frequency('CDV', 133.4).
airport_frequency('ADK', 121.8).
airport_frequency('DLG', 124.8).
airport_frequency('ADQ', 123.15).
airport_frequency('ENA', 124.8).
airport_frequency('HOM', 123.2).
airport_frequency('ILI', 134.7).
airport_frequency('JNU', 126.7).
airport_frequency('AKN', 122.8).
airport_frequency('MCG', 123.2).
airport_frequency('ANI', 124.5).
airport_frequency('OME', 122.8).
airport_frequency('OTZ', 122.2).
airport_frequency('STG', 133.45).
airport_frequency('SCC', 126.7).
airport_frequency('SDP', 122.2).
airport_frequency('KSM', 134.5).
airport_frequency('SNP', 122.8).
airport_frequency('UNK', 123.2).
airport_frequency('VDZ', 122.55).
airport_frequency('AHN', 124.025).
airport_frequency('MKL', 122.7).
airport_frequency('HOB', 568.0).
airport_frequency('VCT', 126.7).
airport_frequency('ACA', 127.5).
airport_frequency('HUX', 122.675).
airport_frequency('CME', 121.7).
airport_frequency('SLW', 119.6).
airport_frequency('OAX', 119.6).
airport_frequency('TAM', 119.6).
airport_frequency('VSA', 134.65).
airport_frequency('VER', 126.7).
airport_frequency('FLG', 122.1).
airport_frequency('SOW', 134.65).
airport_frequency('SVC', 122.8).
airport_frequency('YAM', 126.7).
airport_frequency('YDF', 122.8).
airport_frequency('YFC', 28.94).
airport_frequency('YGK', 38.13).
airport_frequency('YQG', 119.0).
airport_frequency('YQT', 25.78).
airport_frequency('YQY', 135.3).
airport_frequency('YSB', 119.0).
airport_frequency('YSJ', 121.8).
airport_frequency('YTS', 23.01).
airport_frequency('YYB', 34.46).
airport_frequency('YYG', 126.2).
airport_frequency('YZR', 125.1).
airport_frequency('CMW', 123.0).
airport_frequency('SNU', 128.5).
airport_frequency('VTZ', 135.7).
airport_frequency('MDC', 121.9).
airport_frequency('RDN', 118.1).
airport_frequency('SWA', 123.55).
airport_frequency('LJG', 118.1).
airport_frequency('WUX', 122.5).
airport_frequency('ERI', 122.5).
airport_frequency('HVN', 124.8).
airport_frequency('IPT', 133.725).
airport_frequency('SBY', 122.5).
airport_frequency('CIU', 127.3).
airport_frequency('ESC', 122.0).
airport_frequency('PLN', 126.57).
airport_frequency('BFD', 122.8).
airport_frequency('DUJ', 124.65).
airport_frequency('FKL', 132.85).
airport_frequency('JHW', 268.3).
airport_frequency('PKB', 125.7).
airport_frequency('YZF', 126.1).
airport_frequency('KDH', 132.85).
airport_frequency('AHB', 119.1).
airport_frequency('ELQ', 134.15).
airport_frequency('HAS', 122.4).
airport_frequency('MED', 122.8).
airport_frequency('TUU', 126.25).
airport_frequency('TIF', 122.2).
airport_frequency('YNB', 122.2).
airport_frequency('AWZ', 128.175).
airport_frequency('BUZ', 122.3).
airport_frequency('KIH', 128.175).
airport_frequency('BDH', 122.3).
airport_frequency('IFN', 123.375).
airport_frequency('BND', 127.7).
airport_frequency('MHD', 123.2).
airport_frequency('LRR', 124.5).
airport_frequency('LFM', 121.9).
airport_frequency('SYZ', 119.0).
airport_frequency('TBZ', 127.45).
airport_frequency('ZBR', 123.55).
airport_frequency('ZAH', 122.8).
airport_frequency('AZI', 122.7).
airport_frequency('SLL', 135.175).
airport_frequency('MUX', 123.275).
airport_frequency('PEW', 122.1).
airport_frequency('SKT', 122.1).
airport_frequency('BGW', 30.87).
airport_frequency('BSR', 124.5).
airport_frequency('NJF', 124.5).
airport_frequency('ISU', 26.0).
airport_frequency('RIY', 120.6).
airport_frequency('FRU', 124.5).
airport_frequency('HRK', 121.9).
airport_frequency('KRR', 34.02).
airport_frequency('MRV', 34.46).
airport_frequency('ROV', 126.2).
airport_frequency('VOG', 123.25).
airport_frequency('GOI', 123.7).
airport_frequency('CGP', 123.25).
airport_frequency('LKO', 126.7).
airport_frequency('XSB', 120.1).
airport_frequency('DWC', 133.4).
airport_frequency('ATQ', 125.675).
airport_frequency('SSG', 118.4).
airport_frequency('MLN', 120.1).
airport_frequency('BJZ', 122.8).
airport_frequency('RJL', 132.575).
airport_frequency('PNA', 123.0).
airport_frequency('EAS', 135.15).
airport_frequency('SDR', 121.15).
airport_frequency('LDE', 132.95).
airport_frequency('AHO', 119.4).
airport_frequency('CAG', 128.175).
airport_frequency('CLJ', 121.9).
airport_frequency('TSR', 123.15).
airport_frequency('SCU', 127.7).
airport_frequency('VVI', 118.8).
airport_frequency('RMF', 133.9).
airport_frequency('VOL', 133.9).
airport_frequency('KLU', 129.45).
airport_frequency('SJJ', 122.3).
airport_frequency('IAS', 122.3).
airport_frequency('SBZ', 123.475).
airport_frequency('ACH', 122.3).
airport_frequency('KSC', 122.1).
airport_frequency('DNK', 122.1).
airport_frequency('LWO', 126.7).
airport_frequency('ODS', 122.8).
airport_frequency('LIL', 122.3).
airport_frequency('BDS', 133.275).
airport_frequency('LUG', 122.3).
airport_frequency('EBA', 123.275).
airport_frequency('BNX', 126.2).
airport_frequency('LIG', 120.85).
airport_frequency('ETZ', 121.7).
airport_frequency('FSC', 126.2).
airport_frequency('CFR', 126.3).
airport_frequency('IPL', 125.0).
airport_frequency('YZZ', 123.8).
airport_frequency('QBC', 126.3).
airport_frequency('YBL', 122.2).
airport_frequency('YCD', 122.2).
airport_frequency('YCG', 123.5).
airport_frequency('YDQ', 126.925).
airport_frequency('YKA', 134.25).
airport_frequency('YPR', 123.0).
airport_frequency('YPW', 122.5).
airport_frequency('YQQ', 128.0).
airport_frequency('YQZ', 122.5).
airport_frequency('YWL', 126.7).
airport_frequency('YXC', 123.2).
airport_frequency('YXJ', 126.35).
airport_frequency('YXS', 123.2).
airport_frequency('YXT', 126.7).
airport_frequency('YXY', 135.05).
airport_frequency('YYD', 126.7).
airport_frequency('YYF', 123.7).
airport_frequency('YZP', 123.0).
airport_frequency('YZT', 126.7).
airport_frequency('ZMT', 122.1).
airport_frequency('HHN', 122.1).
airport_frequency('FMM', 126.7).
airport_frequency('BOH', 123.2).
airport_frequency('BLK', 123.45).
airport_frequency('PIK', 122.7).
airport_frequency('CFN', 122.95).
airport_frequency('BZG', 123.875).
airport_frequency('SZZ', 132.525).
airport_frequency('ALW', 123.375).
airport_frequency('EAT', 124.575).
airport_frequency('PIE', 122.3).
airport_frequency('PUW', 123.475).
airport_frequency('YKM', 124.0).
airport_frequency('LRH', 128.3).
airport_frequency('RDZ', 134.6).
airport_frequency('CCF', 135.025).
airport_frequency('PGF', 121.9).
airport_frequency('TUF', 123.55).
airport_frequency('CIY', 118.65).
airport_frequency('KTN', 122.2).
airport_frequency('DOM', 135.625).
airport_frequency('SBH', 122.2).
airport_frequency('CPX', 124.0).
airport_frequency('MAZ', 121.9).
airport_frequency('VQS', 118.5).
airport_frequency('NEV', 132.85).
airport_frequency('AXA', 123.475).
airport_frequency('EIS', 126.7).
airport_frequency('VIJ', 118.5).
airport_frequency('YFB', 126.85).
airport_frequency('SCK', 124.7).
airport_frequency('PGD', 134.3).
airport_frequency('TAY', 134.5).
airport_frequency('IVL', 121.7).
airport_frequency('JOE', 126.7).
airport_frequency('JYV', 124.7).
airport_frequency('KEM', 122.1).
airport_frequency('KAJ', 126.7).
airport_frequency('KOK', 122.1).
airport_frequency('KAO', 123.0).
airport_frequency('KUO', 123.9).
airport_frequency('MHQ', 124.0).
airport_frequency('OUL', 122.2).
airport_frequency('POR', 126.7).
airport_frequency('RVN', 122.2).
airport_frequency('SVL', 122.2).
airport_frequency('TMP', 121.0).
airport_frequency('TKU', 124.4).
airport_frequency('VAA', 132.75).
airport_frequency('BMA', 122.5).
airport_frequency('NRK', 121.0).
airport_frequency('GZP', 124.4).
airport_frequency('CEE', 128.65).
airport_frequency('HEA', 121.8).
airport_frequency('IXU', 122.075).
airport_frequency('BDQ', 122.5).
airport_frequency('BHO', 120.8).
airport_frequency('IDR', 122.8).
airport_frequency('JLR', 134.1).
airport_frequency('NAG', 128.1).
airport_frequency('RPR', 118.6).
airport_frequency('STV', 123.7).
airport_frequency('UDR', 119.75).
airport_frequency('IXB', 135.9).
airport_frequency('BBI', 34.46).
airport_frequency('GOP', 126.2).
airport_frequency('GAU', 118.6).
airport_frequency('DIB', 120.1).
airport_frequency('PAT', 127.0).
airport_frequency('IXR', 123.8).
airport_frequency('IXD', 120.1).
airport_frequency('KUU', 121.9).
airport_frequency('IXC', 122.5).
airport_frequency('DED', 118.6).
airport_frequency('DHM', 135.3).
airport_frequency('IXJ', 122.7).
airport_frequency('KNU', 119.2).
airport_frequency('LUH', 118.1).
airport_frequency('IXL', 128.8).
airport_frequency('SXR', 132.125).
airport_frequency('ALH', 121.9).
airport_frequency('BQB', 122.5).
airport_frequency('DCN', 118.1).
airport_frequency('EPR', 118.1).
airport_frequency('GET', 128.6).
airport_frequency('RVT', 134.5).
airport_frequency('ZNE', 118.1).
airport_frequency('PBO', 122.5).
airport_frequency('KNX', 122.2).
airport_frequency('LEA', 122.2).
airport_frequency('XCH', 122.1).
airport_frequency('PAD', 123.375).
airport_frequency('NRN', 128.5).
airport_frequency('LDY', 124.8).
airport_frequency('CAL', 121.9).
airport_frequency('KOI', 128.85).
airport_frequency('LSI', 126.7).
airport_frequency('WIC', 118.1).
airport_frequency('ILY', 118.6).
airport_frequency('BEB', 122.0).
airport_frequency('SYY', 122.0).
airport_frequency('BRR', 122.2).
airport_frequency('TRE', 124.4).
airport_frequency('GSE', 122.2).
airport_frequency('NYO', 126.7).
airport_frequency('RLG', 122.1).
airport_frequency('BJL', 127.2).
airport_frequency('FEZ', 118.4).
airport_frequency('OUD', 134.8).
airport_frequency('BJM', 121.9).
airport_frequency('RGS', 123.4).
airport_frequency('LEN', 118.4).
airport_frequency('SLM', 125.1).
airport_frequency('VLL', 122.8).
airport_frequency('EGC', 122.2).
airport_frequency('PIS', 126.7).
airport_frequency('AOK', 122.2).
airport_frequency('KVA', 135.325).
airport_frequency('MJT', 122.3).
airport_frequency('LMP', 122.3).
airport_frequency('PNL', 122.3).
airport_frequency('REG', 122.8).
airport_frequency('TRS', 134.3).
airport_frequency('AOI', 123.5).
airport_frequency('AOE', 123.375).
airport_frequency('DOK', 123.5).
airport_frequency('IEV', 122.8).
airport_frequency('CEK', 127.7).
airport_frequency('PEE', 122.8).
airport_frequency('VOZ', 128.22).
airport_frequency('RTW', 123.0).
airport_frequency('UFA', 122.2).
airport_frequency('BZO', 134.0).
airport_frequency('AAR', 123.55).
airport_frequency('ALF', 122.2).
airport_frequency('FDE', 122.2).
airport_frequency('BNN', 126.7).
airport_frequency('BOO', 122.8).
airport_frequency('BDU', 135.3).
airport_frequency('EVE', 122.8).
airport_frequency('VDB', 127.4).
airport_frequency('FRO', 135.5).
airport_frequency('HAU', 125.5).
airport_frequency('KSU', 123.475).
airport_frequency('KKN', 123.5).
airport_frequency('MOL', 126.25).
airport_frequency('OLA', 132.55).
airport_frequency('HOV', 123.5).
airport_frequency('RRS', 122.8).
airport_frequency('LYR', 124.0).
airport_frequency('SDN', 122.15).
airport_frequency('SOG', 128.175).
airport_frequency('SRP', 122.7).
airport_frequency('SSJ', 118.5).
airport_frequency('PLQ', 124.3).
airport_frequency('FKB', 118.5).
airport_frequency('DND', 124.75).
airport_frequency('MMX', 122.7).
airport_frequency('SFT', 123.55).
airport_frequency('VST', 122.2).
airport_frequency('PDV', 133.4).
airport_frequency('OSI', 123.25).
airport_frequency('ZAZ', 123.25).
airport_frequency('DNR', 128.525).
airport_frequency('TLN', 126.7).
airport_frequency('PSR', 123.25).
airport_frequency('PMF', 134.075).
airport_frequency('PEG', 123.55).
airport_frequency('BRQ', 122.8).
airport_frequency('HIR', 122.1).
airport_frequency('YBC', 122.1).
airport_frequency('YBG', 122.55).
airport_frequency('YGL', 124.4).
airport_frequency('YGW', 122.95).
airport_frequency('YHM', 123.2).
airport_frequency('YHY', 122.1).
airport_frequency('YMT', 122.1).
airport_frequency('YOJ', 122.8).
airport_frequency('YOP', 126.4).
airport_frequency('YQU', 122.8).
airport_frequency('YSM', 135.2).
airport_frequency('YUY', 122.8).
airport_frequency('YVO', 122.1).
airport_frequency('YVP', 128.7).
airport_frequency('YWK', 122.1).
airport_frequency('YXX', 127.2).
airport_frequency('YYY', 121.2).
airport_frequency('YZV', 123.0).
airport_frequency('ZBF', 122.5).
airport_frequency('SDL', 127.65).
airport_frequency('BLE', 133.15).
airport_frequency('FSP', 123.0).
airport_frequency('TIJ', 123.15).
airport_frequency('CYO', 122.5).
airport_frequency('SON', 135.3).
airport_frequency('HKK', 122.8).
airport_frequency('IVC', 128.4).
airport_frequency('TIU', 135.45).
airport_frequency('WSZ', 124.35).
airport_frequency('BCI', 23.21).
airport_frequency('BKQ', 121.9).
airport_frequency('CTL', 122.35).
airport_frequency('ISA', 34.46).
airport_frequency('ROK', 128.7).
airport_frequency('BDB', 122.3).
airport_frequency('CNJ', 124.95).
airport_frequency('EMD', 128.3).
airport_frequency('LRE', 123.55).
airport_frequency('MOV', 122.3).
airport_frequency('RMA', 133.4).
airport_frequency('DOY', 118.2).
airport_frequency('DDG', 133.6).
airport_frequency('NTG', 133.6).
airport_frequency('DQA', 133.4).
airport_frequency('HIA', 121.7).
airport_frequency('JIQ', 118.2).
airport_frequency('NBS', 122.1).
airport_frequency('CIF', 122.1).
airport_frequency('CIH', 122.075).
airport_frequency('DSN', 118.9).
airport_frequency('DAT', 126.9).
airport_frequency('ERL', 127.5).
airport_frequency('HET', 133.7).
airport_frequency('BAV', 125.6).
airport_frequency('TGO', 118.9).
airport_frequency('WUA', 121.9).
airport_frequency('HLH', 123.55).
airport_frequency('XIL', 119.9).
airport_frequency('YCU', 134.15).
airport_frequency('BHY', 122.1).
airport_frequency('CGD', 122.1).
airport_frequency('DYG', 122.2).
airport_frequency('KWL', 128.7).
airport_frequency('ZUH', 122.2).
airport_frequency('LZH', 228.9).
airport_frequency('ZHA', 256.6).
airport_frequency('LYA', 263.2).
airport_frequency('XFN', 364.2).
airport_frequency('YIH', 126.7).
airport_frequency('INC', 364.2).
airport_frequency('JNG', 122.2).
airport_frequency('XNN', 125.9).
airport_frequency('ENY', 126.7).
airport_frequency('UYN', 122.2).
airport_frequency('ZHY', 123.0).
airport_frequency('LUM', 123.55).
airport_frequency('AQG', 122.2).
airport_frequency('CZX', 126.4).
airport_frequency('FUG', 122.2).
airport_frequency('KOW', 123.55).
airport_frequency('JDZ', 122.8).
airport_frequency('JIU', 122.8).
airport_frequency('LYG', 122.1).
airport_frequency('HYN', 122.55).
airport_frequency('LYI', 122.1).
airport_frequency('HFE', 118.5).
airport_frequency('JJN', 125.9).
airport_frequency('TXN', 118.5).
airport_frequency('WEF', 126.7).
airport_frequency('WUS', 122.2).
airport_frequency('WNZ', 135.1).
airport_frequency('YNZ', 122.2).
airport_frequency('YIW', 123.55).
airport_frequency('HSN', 134.825).
airport_frequency('DAX', 122.2).
airport_frequency('GYS', 122.2).
airport_frequency('LZO', 128.6).
airport_frequency('MXZ', 124.6).
airport_frequency('YYE', 121.4).
airport_frequency('NAY', 126.125).
airport_frequency('CUL', 121.7).
airport_frequency('CTM', 123.15).
airport_frequency('CEN', 23.66).
airport_frequency('CPE', 118.7).
airport_frequency('CJS', 122.3).
airport_frequency('CVM', 122.3).
airport_frequency('TPQ', 122.2).
airport_frequency('CLQ', 132.575).
airport_frequency('JAL', 126.7).
airport_frequency('LZC', 126.4).
airport_frequency('LMM', 49.9).
airport_frequency('LAP', 29.74).
airport_frequency('MAM', 126.4).
airport_frequency('MXL', 119.5).
airport_frequency('MTT', 120.2).
airport_frequency('NLD', 121.3).
airport_frequency('PAZ', 119.9).
airport_frequency('PDS', 121.9).
airport_frequency('PQM', 131.4).
airport_frequency('PXM', 308.8).
airport_frequency('REX', 34.46).
airport_frequency('TGZ', 118.3).
airport_frequency('TAP', 125.4).
airport_frequency('ROS', 121.0).
airport_frequency('AEP', 132.25).
airport_frequency('COR', 122.0).
airport_frequency('MDZ', 126.7).
airport_frequency('IGR', 122.0).
airport_frequency('REL', 122.3).
airport_frequency('FTE', 134.0).
airport_frequency('USH', 381.4).
airport_frequency('BRC', 122.3).
airport_frequency('AJU', 123.275).
airport_frequency('ARU', 122.3).
airport_frequency('PLU', 123.2).
airport_frequency('CAC', 122.8).
airport_frequency('CGR', 122.1).
airport_frequency('CGB', 122.1).
airport_frequency('IGU', 122.3).
airport_frequency('FLN', 133.6).
airport_frequency('FOR', 126.7).
airport_frequency('GYN', 122.3).
airport_frequency('IOS', 119.5).
airport_frequency('IPN', 119.1).
airport_frequency('JPA', 118.8).
airport_frequency('JDO', 114.9).
airport_frequency('JOI', 128.625).
airport_frequency('VCP', 121.3).
airport_frequency('LDB', 121.9).
airport_frequency('MGF', 122.45).
airport_frequency('MCZ', 119.1).
airport_frequency('NVT', 119.1).
airport_frequency('POA', 119.9).
airport_frequency('PFB', 118.3).
airport_frequency('BPS', 128.4).
airport_frequency('VDC', 134.325).
airport_frequency('SDU', 121.9).
airport_frequency('RAO', 122.5).
airport_frequency('NAT', 118.3).
airport_frequency('SLZ', 122.2).
airport_frequency('CGH', 124.875).
airport_frequency('SJP', 126.7).
airport_frequency('THE', 122.2).
airport_frequency('UDI', 118.5).
airport_frequency('UBA', 128.5).
airport_frequency('VIX', 132.6).
airport_frequency('ARI', 118.5).
airport_frequency('CPO', 122.5).
airport_frequency('BBA', 122.1).
airport_frequency('CJC', 122.0).
airport_frequency('PUQ', 124.75).
airport_frequency('IQQ', 126.0).
airport_frequency('ANF', 122.0).
airport_frequency('CCP', 122.1).
airport_frequency('IPC', 122.1).
airport_frequency('ZOS', 128.6).
airport_frequency('LSC', 122.0).
airport_frequency('ZCO', 123.375).
airport_frequency('PMC', 128.725).
airport_frequency('AGT', 128.725).
airport_frequency('CBB', 121.9).
airport_frequency('PCL', 118.3).
airport_frequency('TGI', 133.8).
airport_frequency('CIX', 118.3).
airport_frequency('AYP', 122.1).
airport_frequency('ANS', 126.7).
airport_frequency('ATA', 118.3).
airport_frequency('JAU', 122.0).
airport_frequency('JUL', 128.4).
airport_frequency('CJA', 126.7).
airport_frequency('TBP', 122.0).
airport_frequency('HUU', 119.4).
airport_frequency('IQT', 127.8).
airport_frequency('AQP', 135.3).
airport_frequency('TRU', 121.9).
airport_frequency('TPP', 122.5).
airport_frequency('TCQ', 119.4).
airport_frequency('PEM', 132.7).
airport_frequency('PIU', 119.4).
airport_frequency('CUZ', 119.8).
airport_frequency('DOU', 121.8).
airport_frequency('YBR', 122.5).
airport_frequency('YLL', 119.4).
airport_frequency('YQF', 125.25).
airport_frequency('YQL', 121.9).
airport_frequency('YXH', 118.3).
airport_frequency('RNB', 132.1).
airport_frequency('JKG', 123.275).
airport_frequency('MXX', 118.3).
airport_frequency('KID', 236.6).
airport_frequency('KLR', 118.3).
airport_frequency('HAD', 124.075).
airport_frequency('EVG', 126.7).
airport_frequency('GEV', 122.8).
airport_frequency('KRF', 118.3).
airport_frequency('LYC', 124.9).
airport_frequency('OER', 121.225).
airport_frequency('KRN', 34.46).
airport_frequency('UME', 118.3).
airport_frequency('VHM', 123.85).
airport_frequency('OSD', 125.9).
airport_frequency('HFS', 126.525).
airport_frequency('KSD', 128.225).
airport_frequency('LLA', 120.825).
airport_frequency('VBY', 119.8).
airport_frequency('AGH', 121.9).
airport_frequency('ZAL', 125.35).
airport_frequency('CDR', 124.525).
airport_frequency('KTT', 133.3).
airport_frequency('WIN', 123.375).
airport_frequency('BJA', 121.3).
airport_frequency('QSF', 129.7).
airport_frequency('BLJ', 118.4).
airport_frequency('TLM', 118.875).
airport_frequency('BSK', 236.6).
airport_frequency('TOE', 119.4).
airport_frequency('DZA', 122.3).
airport_frequency('ESU', 122.3).
airport_frequency('OZZ', 126.7).
airport_frequency('AGF', 125.65).
airport_frequency('PGX', 122.5).
airport_frequency('DCM', 132.87).
airport_frequency('LPY', 134.85).
airport_frequency('AUR', 290.6).
airport_frequency('LRT', 122.5).
airport_frequency('LAI', 123.55).
airport_frequency('UIP', 122.5).
airport_frequency('CAY', 133.5).
airport_frequency('BHJ', 118.5).
airport_frequency('BHU', 122.5).
airport_frequency('HBX', 118.5).
airport_frequency('JGA', 118.0).
airport_frequency('RAJ', 135.65).
airport_frequency('GWL', 118.0).
airport_frequency('BFN', 122.1).
airport_frequency('ELS', 122.1).
airport_frequency('ELL', 125.95).
airport_frequency('GRJ', 118.8).
airport_frequency('HDS', 126.4).
airport_frequency('KIM', 133.85).
airport_frequency('MQP', 121.9).
airport_frequency('HLA', 119.7).
airport_frequency('MGH', 349.3).
airport_frequency('PLZ', 122.85).
airport_frequency('PBZ', 122.95).
airport_frequency('PHW', 119.7).
airport_frequency('PZB', 122.375).
airport_frequency('PTG', 127.8).
airport_frequency('RCB', 119.1).
airport_frequency('UTN', 119.7).
airport_frequency('UTT', 122.3).
airport_frequency('FRW', 135.05).
airport_frequency('BBK', 123.475).
airport_frequency('MUB', 122.3).
airport_frequency('GBE', 124.7).
airport_frequency('MTS', 132.8).
airport_frequency('LVI', 123.275).
airport_frequency('NLA', 123.2).
airport_frequency('BEW', 122.2).

%airport support landing system
airport('ATL', 'CATI').
airport('ATL', 'CATII').
airport('ATL', 'CATIIIA').
airport('ATL', 'CATIIIB').
airport('ATL', 'CATIIIC').
airport('ANC', 'CATI').
airport('ANC', 'CATII').
airport('ANC', 'CATIIIA').
airport('ANC', 'CATIIIB').
airport('ANC', 'CATIIIC').
airport('AUS', 'CATI').
airport('AUS', 'CATII').
airport('AUS', 'CATIIIA').
airport('AUS', 'CATIIIB').
airport('AUS', 'CATIIIC').
airport('BNA', 'CATI').
airport('BNA', 'CATII').
airport('BNA', 'CATIIIA').
airport('BNA', 'CATIIIB').
airport('BNA', 'CATIIIC').
airport('BOS', 'CATI').
airport('BOS', 'CATII').
airport('BOS', 'CATIIIA').
airport('BOS', 'CATIIIB').
airport('BOS', 'CATIIIC').
airport('BWI', 'CATI').
airport('BWI', 'CATII').
airport('BWI', 'CATIIIA').
airport('BWI', 'CATIIIB').
airport('BWI', 'CATIIIC').
airport('DCA', 'CATI').
airport('DCA', 'CATII').
airport('DCA', 'CATIIIA').
airport('DCA', 'CATIIIB').
airport('DCA', 'CATIIIC').
airport('DFW', 'CATI').
airport('DFW', 'CATII').
airport('DFW', 'CATIIIA').
airport('DFW', 'CATIIIB').
airport('DFW', 'CATIIIC').
airport('FLL', 'CATI').
airport('FLL', 'CATII').
airport('FLL', 'CATIIIA').
airport('FLL', 'CATIIIB').
airport('FLL', 'CATIIIC').
airport('IAD', 'CATI').
airport('IAD', 'CATII').
airport('IAD', 'CATIIIA').
airport('IAD', 'CATIIIB').
airport('IAD', 'CATIIIC').
airport('IAH', 'CATI').
airport('IAH', 'CATII').
airport('IAH', 'CATIIIA').
airport('IAH', 'CATIIIB').
airport('IAH', 'CATIIIC').
airport('JFK', 'CATI').
airport('JFK', 'CATII').
airport('JFK', 'CATIIIA').
airport('JFK', 'CATIIIB').
airport('JFK', 'CATIIIC').
airport('LAX', 'CATI').
airport('LAX', 'CATII').
airport('LAX', 'CATIIIA').
airport('LAX', 'CATIIIB').
airport('LAX', 'CATIIIC').
airport('LGA', 'CATI').
airport('LGA', 'CATII').
airport('LGA', 'CATIIIA').
airport('LGA', 'CATIIIB').
airport('LGA', 'CATIIIC').
airport('MCO', 'CATI').
airport('MCO', 'CATII').
airport('MCO', 'CATIIIA').
airport('MCO', 'CATIIIB').
airport('MCO', 'CATIIIC').
airport('MIA', 'CATI').
airport('MIA', 'CATII').
airport('MIA', 'CATIIIA').
airport('MIA', 'CATIIIB').
airport('MIA', 'CATIIIC').
airport('MSP', 'CATI').
airport('MSP', 'CATII').
airport('MSP', 'CATIIIA').
airport('MSP', 'CATIIIB').
airport('MSP', 'CATIIIC').
airport('ORD', 'CATI').
airport('ORD', 'CATII').
airport('ORD', 'CATIIIA').
airport('ORD', 'CATIIIB').
airport('ORD', 'CATIIIC').
airport('PBI', 'CATI').
airport('PBI', 'CATII').
airport('PBI', 'CATIIIA').
airport('PBI', 'CATIIIB').
airport('PBI', 'CATIIIC').
airport('PHX', 'CATI').
airport('PHX', 'CATII').
airport('PHX', 'CATIIIA').
airport('PHX', 'CATIIIB').
airport('PHX', 'CATIIIC').
airport('RDU', 'CATI').
airport('RDU', 'CATII').
airport('RDU', 'CATIIIA').
airport('RDU', 'CATIIIB').
airport('RDU', 'CATIIIC').
airport('SEA', 'CATI').
airport('SEA', 'CATII').
airport('SEA', 'CATIIIA').
airport('SEA', 'CATIIIB').
airport('SEA', 'CATIIIC').
airport('SFO', 'CATI').
airport('SFO', 'CATII').
airport('SFO', 'CATIIIA').
airport('SFO', 'CATIIIB').
airport('SFO', 'CATIIIC').
airport('SJC', 'CATI').
airport('SJC', 'CATII').
airport('SJC', 'CATIIIA').
airport('SJC', 'CATIIIB').
airport('SJC', 'CATIIIC').
airport('TPA', 'CATI').
airport('TPA', 'CATII').
airport('TPA', 'CATIIIA').
airport('TPA', 'CATIIIB').
airport('TPA', 'CATIIIC').
airport('SAN', 'CATI').
airport('SAN', 'CATII').
airport('SAN', 'CATIIIA').
airport('SAN', 'CATIIIB').
airport('SAN', 'CATIIIC').
airport('LGB', 'CATI').
airport('LGB', 'CATII').
airport('LGB', 'CATIIIA').
airport('LGB', 'CATIIIB').
airport('LGB', 'CATIIIC').
airport('SNA', 'CATI').
airport('SNA', 'CATII').
airport('SNA', 'CATIIIA').
airport('SNA', 'CATIIIB').
airport('SNA', 'CATIIIC').
airport('SLC', 'CATI').
airport('SLC', 'CATII').
airport('SLC', 'CATIIIA').
airport('SLC', 'CATIIIB').
airport('SLC', 'CATIIIC').
airport('LAS', 'CATI').
airport('LAS', 'CATII').
airport('LAS', 'CATIIIA').
airport('LAS', 'CATIIIB').
airport('LAS', 'CATIIIC').
airport('DEN', 'CATI').
airport('DEN', 'CATII').
airport('DEN', 'CATIIIA').
airport('DEN', 'CATIIIB').
airport('DEN', 'CATIIIC').
airport('HPN', 'CATI').
airport('HPN', 'CATII').
airport('HPN', 'CATIIIA').
airport('HPN', 'CATIIIB').
airport('HPN', 'CATIIIC').
airport('SAT', 'CATI').
airport('SAT', 'CATII').
airport('SAT', 'CATIIIA').
airport('SAT', 'CATIIIB').
airport('SAT', 'CATIIIC').
airport('MSY', 'CATI').
airport('MSY', 'CATII').
airport('MSY', 'CATIIIA').
airport('MSY', 'CATIIIB').
airport('MSY', 'CATIIIC').
airport('EWR', 'CATI').
airport('EWR', 'CATII').
airport('EWR', 'CATIIIA').
airport('EWR', 'CATIIIB').
airport('EWR', 'CATIIIC').
airport('CID', 'CATI').
airport('CID', 'CATII').
airport('CID', 'CATIIIA').
airport('CID', 'CATIIIB').
airport('CID', 'CATIIIC').
airport('HNL', 'CATI').
airport('HNL', 'CATII').
airport('HNL', 'CATIIIA').
airport('HNL', 'CATIIIB').
airport('HNL', 'CATIIIC').
airport('HOU', 'CATI').
airport('HOU', 'CATII').
airport('HOU', 'CATIIIA').
airport('HOU', 'CATIIIB').
airport('HOU', 'CATIIIC').
airport('ELP', 'CATI').
airport('ELP', 'CATII').
airport('ELP', 'CATIIIA').
airport('ELP', 'CATIIIB').
airport('ELP', 'CATIIIC').
airport('SJU', 'CATI').
airport('PFQ', 'CATIIIA').
airport('PFQ', 'CATIIIB').
airport('PFQ', 'CATIIIC').
airport('PBU', 'CATI').
airport('PBU', 'CATII').
airport('PBU', 'CATIIIA').
airport('PBU', 'CATIIIB').
airport('PBU', 'CATIIIC').
airport('PAC', 'CATI').
airport('PAC', 'CATII').
airport('PAC', 'CATIIIA').
airport('PAC', 'CATIIIB').
airport('PAC', 'CATIIIC').
airport('ORZ', 'CATI').
airport('ORZ', 'CATII').
airport('ORZ', 'CATIIIA').
airport('ORZ', 'CATIIIB').
airport('ORZ', 'CATIIIC').
airport('ORU', 'CATI').
airport('ORU', 'CATII').
airport('ORU', 'CATIIIA').
airport('ORU', 'CATIIIB').
airport('ORU', 'CATIIIC').
airport('ONG', 'CATI').
airport('ONG', 'CATII').
airport('ONG', 'CATIIIA').
airport('ONG', 'CATIIIB').
airport('ONG', 'CATIIIC').
airport('OLC', 'CATI').
airport('OLC', 'CATII').
airport('OLC', 'CATIIIA').
airport('OLC', 'CATIIIB').
airport('OLC', 'CATIIIC').
airport('OKL', 'CATI').
airport('OKL', 'CATII').
airport('OKL', 'CATIIIA').
airport('OKL', 'CATIIIB').
airport('OKL', 'CATIIIC').
airport('NTX', 'CATI').
airport('NTX', 'CATII').
airport('NTX', 'CATIIIA').
airport('NTX', 'CATIIIB').
airport('NTX', 'CATIIIC').
airport('NQU', 'CATI').
airport('NQU', 'CATII').
airport('NQU', 'CATIIIA').
airport('NQU', 'CATIIIB').
airport('NQU', 'CATIIIC').
airport('NNM', 'CATI').
airport('NNM', 'CATII').
airport('NNM', 'CATIIIA').
airport('NNM', 'CATIIIB').
airport('NNM', 'CATIIIC').
airport('KSA', 'CATI').
airport('KSA', 'CATII').
airport('KSA', 'CATIIIA').
airport('KSA', 'CATIIIB').
airport('KSA', 'CATIIIC').
airport('NLT', 'CATI').
airport('NLT', 'CATII').
airport('NLT', 'CATIIIA').
airport('NLT', 'CATIIIB').
airport('NLT', 'CATIIIC').
airport('NLG', 'CATI').
airport('NLG', 'CATII').
airport('NLG', 'CATIIIA').
airport('NLG', 'CATIIIB').
airport('NLG', 'CATIIIC').
airport('NBX', 'CATI').
airport('NBX', 'CATII').
airport('NBX', 'CATIIIA').
airport('NBX', 'CATIIIB').
airport('NBX', 'CATIIIC').
airport('MTV', 'CATI').
airport('MTV', 'CATII').
airport('MTV', 'CATIIIA').
airport('MTV', 'CATIIIB').
airport('MTV', 'CATIIIC').
airport('MSA', 'CATI').
airport('MSA', 'CATII').
airport('MSA', 'CATIIIA').
airport('MSA', 'CATIIIB').
airport('MSA', 'CATIIIC').
airport('KGX', 'CATI').
airport('KGX', 'CATII').
airport('KGX', 'CATIIIA').
airport('KGX', 'CATIIIB').
airport('KGX', 'CATIIIC').
airport('KAE', 'CATI').
airport('KAE', 'CATII').
airport('KAE', 'CATIIIA').
airport('KAE', 'CATIIIB').
airport('KAE', 'CATIIIC').
airport('JUV', 'CATI').
airport('JUV', 'CATII').
airport('JUV', 'CATIIIA').
airport('JUV', 'CATIIIB').
airport('JUV', 'CATIIIC').
airport('JQA', 'CATI').
airport('JQA', 'CATII').
airport('JQA', 'CATIIIA').
airport('JQA', 'CATIIIB').
airport('JQA', 'CATIIIC').
airport('SHC', 'CATI').
airport('SHC', 'CATII').
airport('SHC', 'CATIIIA').
airport('SHC', 'CATIIIB').
airport('SHC', 'CATIIIC').
airport('SDV', 'CATI').
airport('SDV', 'CATII').
airport('SDV', 'CATIIIA').
airport('SDV', 'CATIIIB').
airport('SDV', 'CATIIIC').
airport('SDG', 'CATI').
airport('SDG', 'CATII').
airport('SDG', 'CATIIIA').
airport('SDG', 'CATIIIB').
airport('SDG', 'CATIIIC').
airport('RIB', 'CATI').
airport('RIB', 'CATII').
airport('RIB', 'CATIIIA').
airport('RIB', 'CATIIIB').
airport('RIB', 'CATIIIC').
airport('ZTB', 'CATI').
airport('ZTB', 'CATII').
airport('ZTB', 'CATIIIA').
airport('ZTB', 'CATIIIB').
airport('ZTB', 'CATIIIC').
airport('ZPB', 'CATI').
airport('ZPB', 'CATII').
airport('ZPB', 'CATIIIA').
airport('ZPB', 'CATIIIB').
airport('ZPB', 'CATIIIC').
airport('ZLT', 'CATI').
airport('ZLT', 'CATII').
airport('ZLT', 'CATIIIA').
airport('ZLT', 'CATIIIB').
airport('ZLT', 'CATIIIC').
airport('YIF', 'CATI').
airport('YIF', 'CATII').
airport('YIF', 'CATIIIA').
airport('YIF', 'CATIIIB').
airport('YIF', 'CATIIIC').
airport('ZKG', 'CATI').
airport('ZKG', 'CATII').
airport('ZKG', 'CATIIIA').
airport('ZKG', 'CATIIIB').
airport('ZKG', 'CATIIIC').
airport('ARC', 'CATI').
airport('ARC', 'CATII').
airport('ARC', 'CATIIIA').
airport('ARC', 'CATIIIB').
airport('ARC', 'CATIIIC').
airport('ZFM', 'CATI').
airport('ZFM', 'CATII').
airport('ZFM', 'CATIIIA').
airport('ZFM', 'CATIIIB').
airport('ZFM', 'CATIIIC').
airport('YZG', 'CATI').
airport('YZG', 'CATII').
airport('YZG', 'CATIIIA').
airport('YZG', 'CATIIIB').
airport('YZG', 'CATIIIC').
airport('YWB', 'CATI').
airport('YWB', 'CATII').
airport('YWB', 'CATIIIA').
airport('YWB', 'CATIIIB').
airport('YWB', 'CATIIIC').
airport('YUB', 'CATI').
airport('YUB', 'CATII').
airport('YUB', 'CATIIIA').
airport('YUB', 'CATIIIB').
airport('YUB', 'CATIIIC').
airport('YSY', 'CATI').
airport('YSY', 'CATII').
airport('YSY', 'CATIIIA').
airport('YSY', 'CATIIIB').
airport('YSY', 'CATIIIC').
airport('YPC', 'CATI').
airport('YPC', 'CATII').
airport('YPC', 'CATIIIA').
airport('YPC', 'CATIIIB').
airport('YPC', 'CATIIIC').
airport('YNP', 'CATI').
airport('YNP', 'CATII').
airport('YNP', 'CATIIIA').
airport('YNP', 'CATIIIB').
airport('YNP', 'CATIIIC').
airport('YMN', 'CATI').
airport('YMN', 'CATII').
airport('YMN', 'CATIIIA').
airport('YMN', 'CATIIIB').
airport('YMN', 'CATIIIC').
airport('YHO', 'CATI').
airport('YHO', 'CATII').
airport('YHO', 'CATIIIA').
airport('YHO', 'CATIIIB').
airport('YHO', 'CATIIIC').
airport('YTL', 'CATI').
airport('YTL', 'CATII').
airport('YTL', 'CATIIIA').
airport('YTL', 'CATIIIB').
airport('YTL', 'CATIIIC').
airport('YGZ', 'CATI').
airport('YGZ', 'CATII').
airport('YGZ', 'CATIIIA').
airport('YGZ', 'CATIIIB').
airport('YGZ', 'CATIIIC').
airport('YRB', 'CATI').
airport('YRB', 'CATII').
airport('YRB', 'CATIIIA').
airport('YRB', 'CATIIIB').
airport('YRB', 'CATIIIC').
airport('YAB', 'CATI').
airport('YAB', 'CATII').
airport('YAB', 'CATIIIA').
airport('YAB', 'CATIIIB').
airport('YAB', 'CATIIIC').
airport('THU', 'CATI').
airport('THU', 'CATII').
airport('THU', 'CATIIIA').
airport('THU', 'CATIIIB').
airport('THU', 'CATIIIC').
airport('NAQ', 'CATI').
airport('NAQ', 'CATII').
airport('NAQ', 'CATIIIA').
airport('NAQ', 'CATIIIB').
airport('NAQ', 'CATIIIC').
airport('OLH', 'CATI').
airport('OLH', 'CATII').
airport('OLH', 'CATIIIA').
airport('OLH', 'CATIIIB').
airport('OLH', 'CATIIIC').
airport('INI', 'CATI').
airport('INI', 'CATII').
airport('INI', 'CATIIIA').
airport('INI', 'CATIIIB').
airport('INI', 'CATIIIC').
airport('PNI', 'CATI').
airport('PNI', 'CATII').
airport('PNI', 'CATIIIA').
airport('PNI', 'CATIIIB').
airport('PNI', 'CATIIIC').
airport('SZI', 'CATI').
airport('SZI', 'CATII').
airport('SZI', 'CATIIIA').
airport('SZI', 'CATIIIB').
airport('SZI', 'CATIIIC').
airport('TUR', 'CATI').
airport('TUR', 'CATII').
airport('TUR', 'CATIIIA').
airport('TUR', 'CATIIIB').
airport('TUR', 'CATIIIC').
airport('YAX', 'CATI').
airport('YAX', 'CATII').
airport('YAX', 'CATIIIA').
airport('YAX', 'CATIIIB').
airport('YAX', 'CATIIIC').
airport('YER', 'CATI').
airport('YER', 'CATII').
airport('YER', 'CATIIIA').
airport('YER', 'CATIIIB').
airport('YER', 'CATIIIC').
airport('ZSJ', 'CATI').
airport('ZSJ', 'CATII').
airport('ZSJ', 'CATIIIA').
airport('ZSJ', 'CATIIIB').
airport('ZSJ', 'CATIIIC').
airport('YVZ', 'CATI').
airport('YVZ', 'CATII').
airport('YVZ', 'CATIIIA').
airport('YVZ', 'CATIIIB').
airport('YVZ', 'CATIIIC').
airport('YPM', 'CATI').
airport('YPM', 'CATII').
airport('YPM', 'CATIIIA').
airport('YPM', 'CATIIIB').
airport('YPM', 'CATIIIC').
airport('KEW', 'CATI').
airport('KEW', 'CATII').
airport('KEW', 'CATIIIA').
airport('KEW', 'CATIIIB').
airport('KEW', 'CATIIIC').
airport('YHP', 'CATI').
airport('YHP', 'CATII').
airport('YHP', 'CATIIIA').
airport('YHP', 'CATIIIB').
airport('YHP', 'CATIIIC').
airport('YNO', 'CATI').
airport('YNO', 'CATII').
airport('YNO', 'CATIIIA').
airport('YNO', 'CATIIIB').
airport('YNO', 'CATIIIC').
airport('YHD', 'CATI').
airport('YHD', 'CATII').
airport('YHD', 'CATIIIA').
airport('YHD', 'CATIIIB').
airport('YHD', 'CATIIIC').
airport('ZRJ', 'CATI').
airport('ZRJ', 'CATII').
airport('ZRJ', 'CATIIIA').
airport('ZRJ', 'CATIIIB').
airport('ZRJ', 'CATIIIC').
airport('TTA', 'CATI').
airport('TTA', 'CATII').
airport('TTA', 'CATIIIA').
airport('TTA', 'CATIIIB').
airport('TTA', 'CATIIIC').
airport('SXK', 'CATI').
airport('SXK', 'CATII').
airport('SXK', 'CATIIIA').
airport('SXK', 'CATIIIB').
airport('SXK', 'CATIIIC').
airport('SVK', 'CATI').
airport('SVK', 'CATII').
airport('SVK', 'CATIIIA').
airport('SVK', 'CATIIIB').
airport('SVK', 'CATIIIC').
airport('INB', 'CATI').
airport('INB', 'CATII').
airport('INB', 'CATIIIA').
airport('INB', 'CATIIIB').
airport('INB', 'CATIIIC').
airport('RIG', 'CATI').
airport('RIG', 'CATII').
airport('RIG', 'CATIIIA').
airport('RIG', 'CATIIIB').
airport('RIG', 'CATIIIC').
airport('SHG', 'CATI').
airport('SHG', 'CATII').
airport('SHG', 'CATIIIA').
airport('SHG', 'CATIIIB').
airport('SHG', 'CATIIIC').
airport('OBU', 'CATI').
airport('OBU', 'CATII').
airport('OBU', 'CATIIIA').
airport('OBU', 'CATIIIB').
airport('OBU', 'CATIIIC').
airport('SCM', 'CATI').
airport('SCM', 'CATII').
airport('SCM', 'CATIIIA').
airport('SCM', 'CATIIIB').
airport('SCM', 'CATIIIC').
airport('SWO', 'CATI').
airport('SWO', 'CATII').
airport('SWO', 'CATIIIA').
airport('SWO', 'CATIIIB').
airport('SWO', 'CATIIIC').
airport('KNO', 'CATI').
airport('KNO', 'CATII').
airport('KNO', 'CATIIIA').
airport('KNO', 'CATIIIB').
airport('KNO', 'CATIIIC').
airport('NAA', 'CATI').
airport('NAA', 'CATII').
airport('NAA', 'CATIIIA').
airport('NAA', 'CATIIIB').
airport('NAA', 'CATIIIC').
airport('LUV', 'CATI').
airport('LUV', 'CATII').
airport('LUV', 'CATIIIA').
airport('LUV', 'CATIIIB').
airport('LUV', 'CATIIIC').
airport('DOB', 'CATI').
airport('DOB', 'CATII').
airport('DOB', 'CATIIIA').
airport('DOB', 'CATIIIB').
airport('DOB', 'CATIIIC').
airport('ZIA', 'CATI').
airport('ZIA', 'CATII').
airport('ZIA', 'CATIIIA').
airport('ZIA', 'CATIIIB').
airport('ZIA', 'CATIIIC').
airport('CFG', 'CATI').
airport('CFG', 'CATII').
airport('CFG', 'CATIIIA').
airport('CFG', 'CATIIIB').
airport('CFG', 'CATIIIC').
airport('CDT', 'CATI').
airport('CDT', 'CATII').
airport('CDT', 'CATIIIA').
airport('CDT', 'CATIIIB').
airport('CDT', 'CATIIIC').
airport('LCJ', 'CATI').
airport('LCJ', 'CATII').
airport('LCJ', 'CATIIIA').
airport('LCJ', 'CATIIIB').
airport('LCJ', 'CATIIIC').
airport('HLP', 'CATI').
airport('HLP', 'CATII').
airport('HLP', 'CATIIIA').
airport('HLP', 'CATIIIB').
airport('HLP', 'CATIIIC').
airport('BCM', 'CATI').
airport('BCM', 'CATII').
airport('BCM', 'CATIIIA').
airport('BCM', 'CATIIIB').
airport('BCM', 'CATIIIC').
airport('NIF', 'CATI').
airport('NIF', 'CATII').
airport('NIF', 'CATIIIA').
airport('NIF', 'CATIIIB').
airport('NIF', 'CATIIIC').
airport('INT', 'CATI').
airport('INT', 'CATII').
airport('INT', 'CATIIIA').
airport('INT', 'CATIIIB').
airport('INT', 'CATIIIC').
airport('APA', 'CATI').
airport('APA', 'CATII').
airport('APA', 'CATIIIA').
airport('APA', 'CATIIIB').
airport('APA', 'CATIIIC').
airport('USA', 'CATI').
airport('USA', 'CATII').
airport('USA', 'CATIIIA').
airport('USA', 'CATIIIB').
airport('USA', 'CATIIIC').
airport('DAM', 'CATI').
airport('DAM', 'CATII').
airport('DAM', 'CATIIIA').
airport('DAM', 'CATIIIB').
airport('DAM', 'CATIIIC').
airport('NAL', 'CATI').
airport('NAL', 'CATII').
airport('NAL', 'CATIIIA').
airport('NAL', 'CATIIIB').
airport('NAL', 'CATIIIC').
airport('SZY', 'CATI').
airport('SZY', 'CATII').
airport('SZY', 'CATIIIA').
airport('SZY', 'CATIIIB').
airport('SZY', 'CATIIIC').
airport('VDA', 'CATI').
airport('VDA', 'CATII').
airport('VDA', 'CATIIIA').
airport('VDA', 'CATIIIB').
airport('VDA', 'CATIIIC').
airport('WTB', 'CATI').
airport('WTB', 'CATII').
airport('WTB', 'CATIIIA').
airport('WTB', 'CATIIIB').
airport('WTB', 'CATIIIC').
airport('BLB', 'CATI').
airport('BLB', 'CATII').
airport('BLB', 'CATIIIA').
airport('BLB', 'CATIIIB').
airport('BLB', 'CATIIIC').
airport('OMC', 'CATI').
airport('OMC', 'CATII').
airport('OMC', 'CATIIIA').
airport('OMC', 'CATIIIB').
airport('OMC', 'CATIIIC').
airport('BWU', 'CATI').
airport('BWU', 'CATII').
airport('BWU', 'CATIIIA').
airport('BWU', 'CATIIIB').
airport('BWU', 'CATIIIC').
airport('VRB', 'CATI').
airport('VRB', 'CATII').
airport('VRB', 'CATIIIA').
airport('VRB', 'CATIIIB').
airport('VRB', 'CATIIIC').
airport('SUN', 'CATI').
airport('SUN', 'CATII').
airport('SUN', 'CATIIIA').
airport('SUN', 'CATIIIB').
airport('SUN', 'CATIIIC').
airport('BID', 'CATI').
airport('BID', 'CATII').
airport('BID', 'CATIIIA').
airport('BID', 'CATIIIB').
airport('BID', 'CATIIIC').
airport('DVL', 'CATI').
airport('DVL', 'CATII').
airport('DVL', 'CATIIIA').
airport('DVL', 'CATIIIB').
airport('DVL', 'CATIIIC').
airport('JMS', 'CATI').
airport('JMS', 'CATII').
airport('JMS', 'CATIIIA').
airport('JMS', 'CATIIIB').
airport('JMS', 'CATIIIC').
airport('HYS', 'CATI').
airport('HYS', 'CATII').
airport('HYS', 'CATIIIA').
airport('HYS', 'CATIIIB').
airport('HYS', 'CATIIIC').
airport('MCW', 'CATI').
airport('MCW', 'CATII').
airport('MCW', 'CATIIIA').
airport('MCW', 'CATIIIB').
airport('MCW', 'CATIIIC').
airport('NBW', 'CATI').
airport('NBW', 'CATII').
airport('NBW', 'CATIIIA').
airport('NBW', 'CATIIIB').
airport('NBW', 'CATIIIC').
airport('SFH', 'CATI').
airport('SFH', 'CATII').
airport('SFH', 'CATIIIA').
airport('SFH', 'CATIIIB').
airport('SFH', 'CATIIIC').
airport('SHF', 'CATI').
airport('SHF', 'CATII').
airport('SHF', 'CATIIIA').
airport('SHF', 'CATIIIB').
airport('SHF', 'CATIIIC').
airport('BPE', 'CATI').
airport('BPE', 'CATII').
airport('BPE', 'CATIIIA').
airport('BPE', 'CATIIIB').
airport('BPE', 'CATIIIC').
airport('FYJ', 'CATI').
airport('FYJ', 'CATII').
airport('FYJ', 'CATIIIA').
airport('FYJ', 'CATIIIB').
airport('FYJ', 'CATIIIC').
airport('PNT', 'CATI').
airport('PNT', 'CATII').
airport('PNT', 'CATIIIA').
airport('PNT', 'CATIIIB').
airport('PNT', 'CATIIIC').
airport('LLV', 'CATI').
airport('LLV', 'CATII').
airport('LLV', 'CATIIIA').
airport('LLV', 'CATIIIB').
airport('LLV', 'CATIIIC').
airport('WEH', 'CATI').
airport('WEH', 'CATII').
airport('WEH', 'CATIIIA').
airport('WEH', 'CATIIIB').
airport('WEH', 'CATIIIC').
airport('WDS', 'CATI').
airport('WDS', 'CATII').
airport('WDS', 'CATIIIA').
airport('WDS', 'CATIIIB').
airport('WDS', 'CATIIIC').
airport('UCB', 'CATI').
airport('UCB', 'CATII').
airport('UCB', 'CATIIIA').
airport('UCB', 'CATIIIB').
airport('UCB', 'CATIIIC').
airport('TNH', 'CATI').
airport('TNH', 'CATII').
airport('TNH', 'CATIIIA').
airport('TNH', 'CATIIIB').
airport('TNH', 'CATIIIC').
airport('TLQ', 'CATI').
airport('TLQ', 'CATII').
airport('TLQ', 'CATIIIA').
airport('TLQ', 'CATIIIB').
airport('TLQ', 'CATIIIC').
airport('THQ', 'CATI').
airport('THQ', 'CATII').
airport('THQ', 'CATIIIA').
airport('THQ', 'CATIIIB').
airport('THQ', 'CATIIIC').
airport('SQJ', 'CATI').
airport('SQJ', 'CATII').
airport('SQJ', 'CATIIIA').
airport('SQJ', 'CATIIIB').
airport('SQJ', 'CATIIIC').
airport('RKZ', 'CATI').
airport('RKZ', 'CATII').
airport('RKZ', 'CATIIIA').
airport('RKZ', 'CATIIIB').
airport('RKZ', 'CATIIIC').
airport('RIZ', 'CATI').
airport('RIZ', 'CATII').
airport('RIZ', 'CATIIIA').
airport('RIZ', 'CATIIIB').
airport('RIZ', 'CATIIIC').
airport('LPF', 'CATI').
airport('LPF', 'CATII').
airport('LPF', 'CATIIIA').
airport('LPF', 'CATIIIB').
airport('LPF', 'CATIIIC').
airport('CVN', 'CATI').
airport('CVN', 'CATII').
airport('CVN', 'CATIIIA').
airport('CVN', 'CATIIIB').
airport('CVN', 'CATIIIC').
airport('CVT', 'CATI').
airport('CVT', 'CATII').
airport('CVT', 'CATIIIA').
airport('CVT', 'CATIIIB').
airport('CVT', 'CATIIIC').
airport('SZF', 'CATI').
airport('SZF', 'CATII').
airport('SZF', 'CATIIIA').
airport('SZF', 'CATIIIB').
airport('SZF', 'CATIIIC').
airport('KHE', 'CATI').
airport('KHE', 'CATII').
airport('KHE', 'CATIIIA').
airport('KHE', 'CATIIIB').
airport('KHE', 'CATIIIC').
airport('NKT', 'CATI').
airport('NKT', 'CATII').
airport('NKT', 'CATIIIA').
airport('NKT', 'CATIIIB').
airport('NKT', 'CATIIIC').
airport('YKO', 'CATI').
airport('YKO', 'CATII').
airport('YKO', 'CATIIIA').
airport('YKO', 'CATIIIB').
airport('YKO', 'CATIIIC').
airport('OGU', 'CATI').
airport('OGU', 'CATII').
airport('OGU', 'CATIIIA').
airport('OGU', 'CATIIIB').
airport('OGU', 'CATIIIC').
airport('AFW', 'CATI').
airport('AFW', 'CATII').
airport('AFW', 'CATIIIA').
airport('AFW', 'CATIIIB').
airport('AFW', 'CATIIIC').
airport('IWD', 'CATI').
airport('IWD', 'CATII').
airport('IWD', 'CATIIIA').
airport('IWD', 'CATIIIB').
airport('IWD', 'CATIIIC').
airport('LFQ', 'CATI').
airport('LFQ', 'CATII').
airport('LFQ', 'CATIIIA').
airport('LFQ', 'CATIIIB').
airport('LFQ', 'CATIIIC').
airport('KJI', 'CATI').
airport('KJI', 'CATII').
airport('KJI', 'CATIIIA').
airport('KJI', 'CATIIIB').
airport('KJI', 'CATIIIC').
airport('MEB', 'CATI').
airport('MEB', 'CATII').
airport('MEB', 'CATIIIA').
airport('MEB', 'CATIIIB').
airport('MEB', 'CATIIIC').
airport('ENF', 'CATI').
airport('ENF', 'CATII').
airport('ENF', 'CATIIIA').
airport('ENF', 'CATIIIB').
airport('ENF', 'CATIIIC').
airport('WMB', 'CATI').
airport('WMB', 'CATII').
airport('WMB', 'CATIIIA').
airport('WMB', 'CATIIIB').
airport('WMB', 'CATIIIC').
airport('PTJ', 'CATI').
airport('PTJ', 'CATII').
airport('PTJ', 'CATIIIA').
airport('PTJ', 'CATIIIB').
airport('PTJ', 'CATIIIC').
airport('CMF', 'CATI').
airport('CMF', 'CATII').
airport('CMF', 'CATIIIA').
airport('CMF', 'CATIIIB').
airport('CMF', 'CATIIIC').
airport('MZO', 'CATI').
airport('MZO', 'CATII').
airport('MZO', 'CATIIIA').
airport('MZO', 'CATIIIB').
airport('MZO', 'CATIIIC').
airport('TEX', 'CATI').
airport('TEX', 'CATII').
airport('TEX', 'CATIIIA').
airport('TEX', 'CATIIIB').
airport('TEX', 'CATIIIC').
airport('LPK', 'CATI').
airport('LPK', 'CATII').
airport('LPK', 'CATIIIA').
airport('LPK', 'CATIIIB').
airport('LPK', 'CATIIIC').
airport('ULY', 'CATI').
airport('ULY', 'CATII').
airport('ULY', 'CATIIIA').
airport('ULY', 'CATIIIB').
airport('ULY', 'CATIIIC').
airport('FOD', 'CATI').
airport('FOD', 'CATII').
airport('FOD', 'CATIIIA').
airport('FOD', 'CATIIIB').
airport('FOD', 'CATIIIC').
airport('HUZ', 'CATI').
airport('HUZ', 'CATII').
airport('HUZ', 'CATIIIA').
airport('HUZ', 'CATIIIB').
airport('HUZ', 'CATIIIC').
airport('HZG', 'CATI').
airport('HZG', 'CATII').
airport('HZG', 'CATIIIA').
airport('HZG', 'CATIIIB').
airport('HZG', 'CATIIIC').
airport('HNY', 'CATI').
airport('HNY', 'CATII').
airport('HNY', 'CATIIIA').
airport('HNY', 'CATIIIB').
airport('HNY', 'CATIIIC').
airport('YKH', 'CATI').
airport('YKH', 'CATII').
airport('YKH', 'CATIIIA').
airport('YKH', 'CATIIIB').
airport('YKH', 'CATIIIC').
airport('MPN', 'CATI').
airport('MPN', 'CATII').
airport('MPN', 'CATIIIA').
airport('MPN', 'CATIIIB').
airport('MPN', 'CATIIIC').
airport('PSY', 'CATI').
airport('PSY', 'CATII').
airport('PSY', 'CATIIIA').
airport('PSY', 'CATIIIB').
airport('PSY', 'CATIIIC').
airport('ASI', 'CATI').
airport('ASI', 'CATII').
airport('ASI', 'CATIIIA').
airport('ASI', 'CATIIIB').
airport('ASI', 'CATIIIC').
airport('BZZ', 'CATI').
airport('BZZ', 'CATII').
airport('BZZ', 'CATIIIA').
airport('BZZ', 'CATIIIB').
airport('BZZ', 'CATIIIC').
airport('HLE', 'CATI').
airport('HLE', 'CATII').
airport('HLE', 'CATIIIA').
airport('HLE', 'CATIIIB').
airport('HLE', 'CATIIIC').
airport('RKT', 'CATI').
airport('RKT', 'CATII').
airport('RKT', 'CATIIIA').
airport('RKT', 'CATIIIB').
airport('RKT', 'CATIIIC').
airport('KAC', 'CATI').
airport('KAC', 'CATII').
airport('KAC', 'CATIIIA').
airport('KAC', 'CATIIIB').
airport('KAC', 'CATIIIC').
airport('GNB', 'CATI').
airport('GNB', 'CATII').
airport('GNB', 'CATIIIA').
airport('GNB', 'CATIIIB').
airport('GNB', 'CATIIIC').
airport('FYN', 'CATI').
airport('FYN', 'CATII').
airport('FYN', 'CATIIIA').
airport('FYN', 'CATIIIB').
airport('FYN', 'CATIIIC').
airport('MNI', 'CATI').
airport('MNI', 'CATII').
airport('MNI', 'CATIIIA').
airport('MNI', 'CATIIIB').
airport('MNI', 'CATIIIC').
airport('THG', 'CATI').
airport('THG', 'CATII').
airport('THG', 'CATIIIA').
airport('THG', 'CATIIIB').
airport('THG', 'CATIIIC').
airport('TDK', 'CATI').
airport('TDK', 'CATII').
airport('TDK', 'CATIIIA').
airport('TDK', 'CATIIIB').
airport('TDK', 'CATIIIC').
airport('XTO', 'CATI').
airport('XTO', 'CATII').
airport('XTO', 'CATIIIA').
airport('XTO', 'CATIIIB').
airport('XTO', 'CATIIIC').
airport('CCL', 'CATI').
airport('CCL', 'CATII').
airport('CCL', 'CATIIIA').
airport('CCL', 'CATIIIB').
airport('CCL', 'CATIIIC').
airport('TQP', 'CATI').
airport('TQP', 'CATII').
airport('TQP', 'CATIIIA').
airport('TQP', 'CATIIIB').
airport('TQP', 'CATIIIC').
airport('RDP', 'CATI').
airport('RDP', 'CATII').
airport('RDP', 'CATIIIA').
airport('RDP', 'CATIIIB').
airport('RDP', 'CATIIIC').
airport('IFP', 'CATI').
airport('IFP', 'CATII').
airport('IFP', 'CATIIIA').
airport('IFP', 'CATIIIB').
airport('IFP', 'CATIIIC').
airport('KXK', 'CATI').
airport('KXK', 'CATII').
airport('KXK', 'CATIIIA').
airport('KXK', 'CATIIIB').
airport('KXK', 'CATIIIC').
airport('GMQ', 'CATI').
airport('GMQ', 'CATII').
airport('GMQ', 'CATIIIA').
airport('GMQ', 'CATIIIB').
airport('GMQ', 'CATIIIC').
airport('GYU', 'CATI').
airport('GYU', 'CATII').
airport('GYU', 'CATIIIA').
airport('GYU', 'CATIIIB').
airport('GYU', 'CATIIIC').
airport('HPG', 'CATI').
airport('HPG', 'CATII').
airport('HPG', 'CATIIIA').
airport('HPG', 'CATIIIB').
airport('HPG', 'CATIIIC').
airport('HTT', 'CATI').
airport('HTT', 'CATII').
airport('HTT', 'CATIIIA').
airport('HTT', 'CATIIIB').
airport('HTT', 'CATIIIC').
airport('HCJ', 'CATI').
airport('HCJ', 'CATII').
airport('HCJ', 'CATIIIA').
airport('HCJ', 'CATIIIB').
airport('HCJ', 'CATIIIC').
airport('SCV', 'CATI').
airport('SCV', 'CATII').
airport('SCV', 'CATIIIA').
airport('SCV', 'CATIIIB').
airport('SCV', 'CATIIIC').
airport('VIT', 'CATI').
airport('VIT', 'CATII').
airport('VIT', 'CATIIIA').
airport('VIT', 'CATIIIB').
airport('VIT', 'CATIIIC').
airport('IQM', 'CATI').
airport('IQM', 'CATII').
airport('IQM', 'CATIIIA').
airport('IQM', 'CATIIIB').
airport('IQM', 'CATIIIC').
airport('KJH', 'CATI').
airport('KJH', 'CATII').
airport('KJH', 'CATIIIA').
airport('KJH', 'CATIIIB').
airport('KJH', 'CATIIIC').
airport('HXD', 'CATI').
airport('HXD', 'CATII').
airport('HXD', 'CATIIIA').
airport('HXD', 'CATIIIB').
airport('HXD', 'CATIIIC').
airport('AHJ', 'CATI').
airport('AHJ', 'CATII').
airport('AHJ', 'CATIIIA').
airport('AHJ', 'CATIIIB').
airport('AHJ', 'CATIIIC').
airport('CWC', 'CATI').
airport('CWC', 'CATII').
airport('CWC', 'CATIIIA').
airport('CWC', 'CATIIIB').
airport('CWC', 'CATIIIC').
airport('BZK', 'CATI').
airport('BZK', 'CATII').
airport('BZK', 'CATIIIA').
airport('BZK', 'CATIIIB').
airport('BZK', 'CATIIIC').
airport('UZR', 'CATI').
airport('UZR', 'CATII').
airport('UZR', 'CATIIIA').
airport('UZR', 'CATIIIB').
airport('UZR', 'CATIIIC').
airport('BBL', 'CATI').
airport('BBL', 'CATII').
airport('BBL', 'CATIIIA').
airport('BBL', 'CATIIIB').
airport('BBL', 'CATIIIC').
airport('MOO', 'CATI').
airport('MOO', 'CATII').
airport('MOO', 'CATIIIA').
airport('MOO', 'CATIIIB').
airport('MOO', 'CATIIIC').
airport('VTB', 'CATI').
airport('VTB', 'CATII').
airport('VTB', 'CATIIIA').
airport('VTB', 'CATIIIB').
airport('VTB', 'CATIIIC').
airport('ANE', 'CATI').
airport('ANE', 'CATII').
airport('ANE', 'CATIIIA').
airport('ANE', 'CATIIIB').
airport('ANE', 'CATIIIC').
airport('URO', 'CATI').
airport('URO', 'CATII').
airport('URO', 'CATIIIA').
airport('URO', 'CATIIIB').
airport('URO', 'CATIIIC').
airport('LOV', 'CATI').
airport('LOV', 'CATII').
airport('LOV', 'CATIIIA').
airport('LOV', 'CATIIIB').
airport('LOV', 'CATIIIC').
airport('OHS', 'CATI').
airport('OHS', 'CATII').
airport('OHS', 'CATIIIA').
airport('OHS', 'CATIIIB').
airport('OHS', 'CATIIIC').
airport('FIE', 'CATI').
airport('FIE', 'CATII').
airport('FIE', 'CATIIIA').
airport('FIE', 'CATIIIB').
airport('FIE', 'CATIIIC').
airport('LWK', 'CATI').
airport('LWK', 'CATII').
airport('LWK', 'CATIIIA').
airport('LWK', 'CATIIIB').
airport('LWK', 'CATIIIC').
airport('FOA', 'CATI').
airport('FOA', 'CATII').
airport('FOA', 'CATIIIA').
airport('FOA', 'CATIIIB').
airport('FOA', 'CATIIIC').
airport('PSV', 'CATI').
airport('PSV', 'CATII').
airport('PSV', 'CATIIIA').
airport('PSV', 'CATIIIB').
airport('PSV', 'CATIIIC').
airport('NDZ', 'CATI').
airport('NDZ', 'CATII').
airport('NDZ', 'CATIIIA').
airport('NDZ', 'CATIIIB').
airport('NDZ', 'CATIIIC').
airport('WOL', 'CATI').
airport('WOL', 'CATII').
airport('WOL', 'CATIIIA').
airport('WOL', 'CATIIIB').
airport('WOL', 'CATIIIC').
airport('OND', 'CATI').
airport('OND', 'CATII').
airport('OND', 'CATIIIA').
airport('OND', 'CATIIIB').
airport('OND', 'CATIIIC').
airport('GAY', 'CATI').
airport('GAY', 'CATII').
airport('GAY', 'CATIIIA').
airport('GAY', 'CATIIIB').
airport('GAY', 'CATIIIC').
airport('ENI', 'CATI').
airport('ENI', 'CATII').
airport('ENI', 'CATIIIA').
airport('ENI', 'CATIIIB').
airport('ENI', 'CATIIIC').
airport('IGT', 'CATI').
airport('IGT', 'CATII').
airport('IGT', 'CATIIIA').
airport('IGT', 'CATIIIB').
airport('IGT', 'CATIIIC').
airport('EPA', 'CATI').
airport('EPA', 'CATII').
airport('EPA', 'CATIIIA').
airport('EPA', 'CATIIIB').
airport('EPA', 'CATIIIC').
airport('YHG', 'CATI').
airport('YHG', 'CATII').
airport('YHG', 'CATIIIA').
airport('YHG', 'CATIIIB').
airport('YHG', 'CATIIIC').
airport('MBX', 'CATI').
airport('MBX', 'CATII').
airport('MBX', 'CATIIIA').
airport('MBX', 'CATIIIB').
airport('MBX', 'CATIIIC').
airport('KLF', 'CATI').
airport('KLF', 'CATII').
airport('KLF', 'CATIIIA').
airport('KLF', 'CATIIIB').
airport('KLF', 'CATIIIC').
airport('JSK', 'CATI').
airport('JSK', 'CATII').
airport('JSK', 'CATIIIA').
airport('JSK', 'CATIIIB').
airport('JSK', 'CATIIIC').
airport('CAT', 'CATI').
airport('CAT', 'CATII').
airport('CAT', 'CATIIIA').
airport('CAT', 'CATIIIB').
airport('CAT', 'CATIIIC').
airport('VRL', 'CATI').
airport('VRL', 'CATII').
airport('VRL', 'CATIIIA').
airport('VRL', 'CATIIIB').
airport('VRL', 'CATIIIC').
airport('VSE', 'CATI').
airport('VSE', 'CATII').
airport('VSE', 'CATIIIA').
airport('VSE', 'CATIIIB').
airport('VSE', 'CATIIIC').
airport('PRM', 'CATI').
airport('PRM', 'CATII').
airport('PRM', 'CATIIIA').
airport('PRM', 'CATIIIB').
airport('PRM', 'CATIIIC').
airport('BGC', 'CATI').
airport('BGC', 'CATII').
airport('BGC', 'CATIIIA').
airport('BGC', 'CATIIIB').
airport('BGC', 'CATIIIC').
airport('CNQ', 'CATI').
airport('CNQ', 'CATII').
airport('CNQ', 'CATIIIA').
airport('CNQ', 'CATIIIB').
airport('CNQ', 'CATIIIC').
airport('YAZ', 'CATI').
airport('YAZ', 'CATII').
airport('YAZ', 'CATIIIA').
airport('YAZ', 'CATIIIB').
airport('YAZ', 'CATIIIC').
airport('OHD', 'CATI').
airport('OHD', 'CATII').
airport('OHD', 'CATIIIA').
airport('OHD', 'CATIIIB').
airport('OHD', 'CATIIIC').
airport('MKZ', 'CATI').
airport('MKZ', 'CATII').
airport('MKZ', 'CATIIIA').
airport('MKZ', 'CATIIIB').
airport('MKZ', 'CATIIIC').
airport('CHR', 'CATI').
airport('CHR', 'CATII').
airport('CHR', 'CATIIIA').
airport('CHR', 'CATIIIB').
airport('CHR', 'CATIIIC').
airport('TLK', 'CATI').
airport('TLK', 'CATII').
airport('TLK', 'CATIIIA').
airport('TLK', 'CATIIIB').
airport('TLK', 'CATIIIC').
airport('GRS', 'CATI').
airport('GRS', 'CATII').
airport('GRS', 'CATIIIA').
airport('GRS', 'CATIIIB').
airport('GRS', 'CATIIIC').
airport('HHQ', 'CATI').
airport('HHQ', 'CATII').
airport('HHQ', 'CATIIIA').
airport('HHQ', 'CATIIIB').
airport('HHQ', 'CATIIIC').
airport('GME', 'CATI').
airport('GME', 'CATII').
airport('GME', 'CATIIIA').
airport('GME', 'CATIIIB').
airport('GME', 'CATIIIC').
airport('CRV', 'CATI').
airport('CRV', 'CATII').
airport('CRV', 'CATIIIA').
airport('CRV', 'CATIIIB').
airport('CRV', 'CATIIIC').
airport('NLI', 'CATI').
airport('NLI', 'CATII').
airport('NLI', 'CATIIIA').
airport('NLI', 'CATIIIB').
airport('NLI', 'CATIIIC').
airport('EKA', 'CATI').
airport('EKA', 'CATII').
airport('EKA', 'CATIIIA').
airport('EKA', 'CATIIIB').
airport('EKA', 'CATIIIC').
airport('CVQ', 'CATI').
airport('CVQ', 'CATII').
airport('CVQ', 'CATIIIA').
airport('CVQ', 'CATIIIB').
airport('CVQ', 'CATIIIC').
airport('MJK', 'CATI').
airport('MJK', 'CATII').
airport('MJK', 'CATIIIA').
airport('MJK', 'CATIIIB').
airport('MJK', 'CATIIIC').
airport('GOB', 'CATI').
airport('GOB', 'CATII').
airport('GOB', 'CATIIIA').
airport('GOB', 'CATIIIB').
airport('GOB', 'CATIIIC').
airport('AWA', 'CATI').
airport('AWA', 'CATII').
airport('AWA', 'CATIIIA').
airport('AWA', 'CATIIIB').
airport('AWA', 'CATIIIC').
airport('JRH', 'CATI').
airport('JRH', 'CATII').
airport('JRH', 'CATIIIA').
airport('JRH', 'CATIIIB').
airport('JRH', 'CATIIIC').
airport('BYK', 'CATI').
airport('BYK', 'CATII').
airport('BYK', 'CATIIIA').
airport('BYK', 'CATIIIB').
airport('BYK', 'CATIIIC').
airport('DTB', 'CATI').
airport('DTB', 'CATII').
airport('DTB', 'CATIIIA').
airport('DTB', 'CATIIIB').
airport('DTB', 'CATIIIC').
airport('TKQ', 'CATI').
airport('TKQ', 'CATII').
airport('TKQ', 'CATIIIA').
airport('TKQ', 'CATIIIB').
airport('TKQ', 'CATIIIC').
airport('AEH', 'CATI').
airport('AEH', 'CATII').
airport('AEH', 'CATIIIA').
airport('AEH', 'CATIIIB').
airport('AEH', 'CATIIIC').
airport('SRH', 'CATI').
airport('SRH', 'CATII').
airport('SRH', 'CATIIIA').
airport('SRH', 'CATIIIB').
airport('SRH', 'CATIIIC').
airport('DSS', 'CATI').
airport('DSS', 'CATII').
airport('DSS', 'CATIIIA').
airport('DSS', 'CATIIIB').
airport('DSS', 'CATIIIC').
airport('MQQ', 'CATI').
airport('MQQ', 'CATII').
airport('MQQ', 'CATIIIA').
airport('MQQ', 'CATIIIB').
airport('MQQ', 'CATIIIC').
airport('FYT', 'CATI').
airport('FYT', 'CATII').
airport('FYT', 'CATIIIA').
airport('FYT', 'CATIIIB').
airport('FYT', 'CATIIIC').
airport('ERH', 'CATI').
airport('ERH', 'CATII').
airport('ERH', 'CATIIIA').
airport('ERH', 'CATIIIB').
airport('ERH', 'CATIIIC').
airport('DRT', 'CATI').
airport('DRT', 'CATII').
airport('DRT', 'CATIIIA').
airport('DRT', 'CATIIIB').
airport('DRT', 'CATIIIC').
airport('BAR', 'CATI').
airport('BAR', 'CATII').
airport('BAR', 'CATIIIA').
airport('BAR', 'CATIIIB').
airport('BAR', 'CATIIIC').
airport('USJ', 'CATI').
airport('USJ', 'CATII').
airport('USJ', 'CATIIIA').
airport('USJ', 'CATIIIB').
airport('USJ', 'CATIIIC').
airport('TYL', 'CATI').
airport('TYL', 'CATII').
airport('TYL', 'CATIIIA').
airport('TYL', 'CATIIIB').
airport('TYL', 'CATIIIC').
airport('CNN', 'CATI').
airport('CNN', 'CATII').
airport('CNN', 'CATIIIA').
airport('CNN', 'CATIIIB').
airport('CNN', 'CATIIIC').
airport('JAE', 'CATI').
airport('JAE', 'CATII').
airport('JAE', 'CATIIIA').
airport('JAE', 'CATIIIB').
airport('JAE', 'CATIIIC').
airport('INF', 'CATI').
airport('INF', 'CATII').
airport('INF', 'CATIIIA').
airport('INF', 'CATIIIB').
airport('INF', 'CATIIIC').
airport('KLB', 'CATI').
airport('KLB', 'CATII').
airport('KLB', 'CATIIIA').
airport('KLB', 'CATIIIB').
airport('KLB', 'CATIIIC').
airport('VDO', 'CATI').
airport('VDO', 'CATII').
airport('VDO', 'CATIIIA').
airport('VDO', 'CATIIIB').
airport('VDO', 'CATIIIC').
airport('RMU', 'CATI').
airport('RMU', 'CATII').
airport('RMU', 'CATIIIA').
airport('RMU', 'CATIIIB').
airport('RMU', 'CATIIIC').
airport('PAE', 'CATI').
airport('PAE', 'CATII').
airport('PAE', 'CATIIIA').
airport('PAE', 'CATIIIB').
airport('PAE', 'CATIIIC').
airport('LUA', 'CATI').
airport('LUA', 'CATII').
airport('LUA', 'CATIIIA').
airport('LUA', 'CATIIIB').
airport('LUA', 'CATIIIC').
airport('MRQ', 'CATI').
airport('MRQ', 'CATII').
airport('MRQ', 'CATIIIA').
airport('MRQ', 'CATIIIB').
airport('MRQ', 'CATIIIC').
airport('SHI', 'CATI').
airport('SHI', 'CATII').
airport('SHI', 'CATIIIA').
airport('SHI', 'CATIIIB').
airport('SHI', 'CATIIIC').
airport('BXG', 'CATI').
airport('BXG', 'CATII').
airport('BXG', 'CATIIIA').
airport('BXG', 'CATIIIB').
airport('BXG', 'CATIIIC').
airport('UAR', 'CATI').
airport('UAR', 'CATII').
airport('UAR', 'CATIIIA').
airport('UAR', 'CATIIIB').
airport('UAR', 'CATIIIC').
airport('TRA', 'CATI').
airport('TRA', 'CATII').
airport('TRA', 'CATIIIA').
airport('TRA', 'CATIIIB').
airport('TRA', 'CATIIIC').
airport('ISL', 'CATI').
airport('ISL', 'CATII').
airport('ISL', 'CATIIIA').
airport('ISL', 'CATIIIB').
airport('ISL', 'CATIIIC').
airport('USQ', 'CATI').
airport('USQ', 'CATII').
airport('USQ', 'CATIIIA').
airport('USQ', 'CATIIIB').
airport('USQ', 'CATIIIC').
airport('MJI', 'CATI').
airport('MJI', 'CATII').
airport('MJI', 'CATIIIA').
airport('MJI', 'CATIIIB').
airport('MJI', 'CATIIIC').
airport('SXZ', 'CATI').
airport('SXZ', 'CATII').
airport('SXZ', 'CATIIIA').
airport('SXZ', 'CATIIIB').
airport('SXZ', 'CATIIIC').
airport('XSP', 'CATI').
airport('XSP', 'CATII').
airport('XSP', 'CATIIIA').
airport('XSP', 'CATIIIB').
airport('XSP', 'CATIIIC').
airport('ZTA', 'CATI').
airport('ZTA', 'CATII').
airport('ZTA', 'CATIIIA').
airport('ZTA', 'CATIIIB').
airport('ZTA', 'CATIIIC').
airport('BFM', 'CATI').
airport('BFM', 'CATII').
airport('BFM', 'CATIIIA').
airport('BFM', 'CATIIIB').
airport('BFM', 'CATIIIC').
airport('NUK', 'CATI').
airport('NUK', 'CATII').
airport('NUK', 'CATIIIA').
airport('NUK', 'CATIIIB').
airport('NUK', 'CATIIIC').
airport('DBB', 'CATI').
airport('DBB', 'CATII').
airport('DBB', 'CATIIIA').
airport('DBB', 'CATIIIB').
airport('DBB', 'CATIIIC').
airport('GGR', 'CATI').
airport('GGR', 'CATII').
airport('GGR', 'CATIIIA').
airport('GGR', 'CATIIIB').
airport('GGR', 'CATIIIC').
airport('KJT', 'CATI').
airport('KJT', 'CATII').
airport('KJT', 'CATIIIA').
airport('KJT', 'CATIIIB').
airport('KJT', 'CATIIIC').
airport('TSL', 'CATI').
airport('TSL', 'CATII').
airport('TSL', 'CATIIIA').
airport('TSL', 'CATIIIB').
airport('TSL', 'CATIIIC').
airport('PKX', 'CATI').
airport('PKX', 'CATII').
airport('PKX', 'CATIIIA').
airport('PKX', 'CATIIIB').
airport('PKX', 'CATIIIC').
airport('BZX', 'CATI').
airport('BZX', 'CATII').
airport('BZX', 'CATIIIA').
airport('BZX', 'CATIIIB').
airport('BZX', 'CATIIIC').
airport('DBC', 'CATI').
airport('DBC', 'CATII').
airport('DBC', 'CATIIIA').
airport('DBC', 'CATIIIB').
airport('DBC', 'CATIIIC').
airport('ETM', 'CATI').
airport('ETM', 'CATII').
airport('ETM', 'CATIIIA').
airport('ETM', 'CATIIIB').
airport('ETM', 'CATIIIC').
airport('KET', 'CATI').
airport('KET', 'CATII').
airport('KET', 'CATIIIA').
airport('KET', 'CATIIIB').
airport('KET', 'CATIIIC').
airport('KFE', 'CATI').
airport('KFE', 'CATII').
airport('KFE', 'CATIIIA').
airport('KFE', 'CATIIIB').
airport('KFE', 'CATIIIC').
airport('KHM', 'CATI').
airport('KHM', 'CATII').
airport('KHM', 'CATIIIA').
airport('KHM', 'CATIIIB').
airport('KHM', 'CATIIIC').
airport('KTR', 'CATI').
airport('KTR', 'CATII').
airport('KTR', 'CATIIIA').
airport('KTR', 'CATIIIB').
airport('KTR', 'CATIIIC').
airport('MNC', 'CATI').
airport('MNC', 'CATII').
airport('MNC', 'CATIIIA').
airport('MNC', 'CATIIIB').
airport('MNC', 'CATIIIC').
airport('SQD', 'CATI').
airport('SQD', 'CATII').
airport('SQD', 'CATIIIA').
airport('SQD', 'CATIIIB').
airport('SQD', 'CATIIIC').
airport('BPG', 'CATI').
airport('BPG', 'CATII').
airport('BPG', 'CATIIIA').
airport('BPG', 'CATIIIB').
airport('BPG', 'CATIIIC').
airport('CQA', 'CATI').
airport('CQA', 'CATII').
airport('CQA', 'CATIIIA').
airport('CQA', 'CATIIIB').
airport('CQA', 'CATIIIC').
airport('DOD', 'CATI').
airport('DOD', 'CATII').
airport('DOD', 'CATIIIA').
airport('DOD', 'CATIIIB').
airport('DOD', 'CATIIIC').
airport('SEU', 'CATI').
airport('SEU', 'CATII').
airport('SEU', 'CATIIIA').
airport('SEU', 'CATIIIB').
airport('SEU', 'CATIIIC').
airport('NRR', 'CATI').
airport('NRR', 'CATII').
airport('NRR', 'CATIIIA').
airport('NRR', 'CATIIIB').
airport('NRR', 'CATIIIC').
airport('LNL', 'CATI').
airport('LNL', 'CATII').
airport('LNL', 'CATIIIA').
airport('LNL', 'CATIIIB').
airport('LNL', 'CATIIIC').
airport('XAI', 'CATI').
airport('XAI', 'CATII').
airport('XAI', 'CATIIIA').
airport('XAI', 'CATIIIB').
airport('XAI', 'CATIIIC').
airport('YYA', 'CATI').
airport('YYA', 'CATII').
airport('YYA', 'CATIIIA').
airport('YYA', 'CATIIIB').
airport('YYA', 'CATIIIC').
airport('BQJ', 'CATI').
airport('BQJ', 'CATII').
airport('BQJ', 'CATIIIA').
airport('BQJ', 'CATIIIB').
airport('BQJ', 'CATIIIC').
airport('DPT', 'CATI').
airport('DPT', 'CATII').
airport('DPT', 'CATIIIA').
airport('DPT', 'CATIIIB').
airport('DPT', 'CATIIIC').
airport('AKR', 'CATI').
airport('AKR', 'CATII').
airport('AKR', 'CATIIIA').
airport('AKR', 'CATIIIB').
airport('AKR', 'CATIIIC').
airport('APK', 'CATI').
airport('APK', 'CATII').
airport('APK', 'CATIIIA').
airport('APK', 'CATIIIB').
airport('APK', 'CATIIIC').
airport('BWB', 'CATI').
airport('BWB', 'CATII').
airport('BWB', 'CATIIIA').
airport('BWB', 'CATIIIB').
airport('BWB', 'CATIIIC').
airport('CEH', 'CATI').
airport('CEH', 'CATII').
airport('CEH', 'CATIIIA').
airport('CEH', 'CATIIIB').
airport('CEH', 'CATIIIC').
airport('CMK', 'CATI').
airport('CMK', 'CATII').
airport('CMK', 'CATIIIA').
airport('CMK', 'CATIIIB').
airport('CMK', 'CATIIIC').
airport('CRC', 'CATI').
airport('CRC', 'CATII').
airport('CRC', 'CATIIIA').
airport('CRC', 'CATIIIB').
airport('CRC', 'CATIIIC').
airport('EUA', 'CATI').
airport('EUA', 'CATII').
airport('EUA', 'CATIIIA').
airport('EUA', 'CATIIIB').
airport('EUA', 'CATIIIC').
airport('GYG', 'CATI').
airport('GYG', 'CATII').
airport('GYG', 'CATIIIA').
airport('GYG', 'CATIIIB').
airport('GYG', 'CATIIIC').
airport('GYZ', 'CATI').
airport('GYZ', 'CATII').
airport('GYZ', 'CATIIIA').
airport('GYZ', 'CATIIIB').
airport('GYZ', 'CATIIIC').
airport('HFN', 'CATI').
airport('HFN', 'CATII').
airport('HFN', 'CATIIIA').
airport('HFN', 'CATIIIB').
airport('HFN', 'CATIIIC').
airport('HPA', 'CATI').
airport('HPA', 'CATII').
airport('HPA', 'CATIIIA').
airport('HPA', 'CATIIIB').
airport('HPA', 'CATIIIC').
airport('HZK', 'CATI').
airport('HZK', 'CATII').
airport('HZK', 'CATIIIA').
airport('HZK', 'CATIIIB').
airport('HZK', 'CATIIIC').
airport('LIX', 'CATI').
airport('LIX', 'CATII').
airport('LIX', 'CATIIIA').
airport('LIX', 'CATIIIB').
airport('LIX', 'CATIIIC').
airport('LRV', 'CATI').
airport('LRV', 'CATII').
airport('LRV', 'CATIIIA').
airport('LRV', 'CATIIIB').
airport('LRV', 'CATIIIC').
airport('MYC', 'CATI').
airport('MYC', 'CATII').
airport('MYC', 'CATIIIA').
airport('MYC', 'CATIIIB').
airport('MYC', 'CATIIIC').
airport('NFO', 'CATI').
airport('NFO', 'CATII').
airport('NFO', 'CATIIIA').
airport('NFO', 'CATIIIB').
airport('NFO', 'CATIIIC').
airport('SFD', 'CATI').
airport('SFD', 'CATII').
airport('SFD', 'CATIIIA').
airport('SFD', 'CATIIIB').
airport('SFD', 'CATIIIC').
airport('UMS', 'CATI').
airport('UMS', 'CATII').
airport('UMS', 'CATIIIA').
airport('UMS', 'CATIIIB').
airport('UMS', 'CATIIIC').
airport('VAV', 'CATI').
airport('VAV', 'CATII').
airport('VAV', 'CATIIIA').
airport('VAV', 'CATIIIB').
airport('VAV', 'CATIIIC').
airport('VCV', 'CATI').
airport('VCV', 'CATII').
airport('VCV', 'CATIIIA').
airport('VCV', 'CATIIIB').
airport('VCV', 'CATIIIC').
airport('VUU', 'CATI').
airport('VUU', 'CATII').
airport('VUU', 'CATIIIA').
airport('VUU', 'CATIIIB').
airport('VUU', 'CATIIIC').
airport('WZA', 'CATI').
airport('WZA', 'CATII').
airport('WZA', 'CATIIIA').
airport('WZA', 'CATIIIB').
airport('WZA', 'CATIIIC').
airport('XWA', 'CATI').
airport('XWA', 'CATII').
airport('XWA', 'CATIIIA').
airport('XWA', 'CATIIIB').
airport('XWA', 'CATIIIC').
airport('YEI', 'CATI').
airport('YEI', 'CATII').
airport('YEI', 'CATIIIA').
airport('YEI', 'CATIIIB').
airport('YEI', 'CATIIIC').
airport('ZZU', 'CATI').
airport('ZZU', 'CATII').
airport('ZZU', 'CATIIIA').
airport('ZZU', 'CATIIIB').
airport('ZZU', 'CATIIIC').
airport('YIA', 'CATI').
airport('YIA', 'CATII').
airport('YIA', 'CATIIIA').
airport('YIA', 'CATIIIB').
airport('YIA', 'CATIIIC').
airport('NUL', 'CATI').
airport('NUL', 'CATII').
airport('NUL', 'CATIIIA').
airport('NUL', 'CATIIIB').
airport('NUL', 'CATIIIC').
airport('KMV', 'CATI').
airport('KMV', 'CATII').
airport('KMV', 'CATIIIA').
airport('KMV', 'CATIIIB').
airport('KMV', 'CATIIIC').
airport('KHT', 'CATI').
airport('KHT', 'CATII').
airport('KHT', 'CATIIIA').
airport('KHT', 'CATIIIB').
airport('KHT', 'CATIIIC').
airport('SYS', 'CATI').
airport('SYS', 'CATII').
airport('SYS', 'CATIIIA').
airport('SYS', 'CATIIIB').
airport('SYS', 'CATIIIC').
airport('AAA', 'CATI').
airport('AAA', 'CATII').
airport('AAA', 'CATIIIA').
airport('AAA', 'CATIIIB').
airport('AAA', 'CATIIIC').
airport('GBI', 'CATI').
airport('GBI', 'CATII').
airport('GBI', 'CATIIIA').
airport('GBI', 'CATIIIB').
airport('GBI', 'CATIIIC').
airport('KVO', 'CATI').
airport('KVO', 'CATII').
airport('KVO', 'CATIIIA').
airport('KVO', 'CATIIIB').
airport('KVO', 'CATIIIC').
airport('FAC', 'CATI').
airport('FAC', 'CATII').
airport('FAC', 'CATIIIA').
airport('FAC', 'CATIIIB').
airport('FAC', 'CATIIIC').
airport('RRR', 'CATI').
airport('RRR', 'CATII').
airport('RRR', 'CATIIIA').
airport('RRR', 'CATIIIB').
airport('RRR', 'CATIIIC').
airport('PKP', 'CATI').
airport('PKP', 'CATII').
airport('PKP', 'CATIIIA').
airport('PKP', 'CATIIIB').
airport('PKP', 'CATIIIC').
airport('NAU', 'CATI').
airport('NAU', 'CATII').
airport('NAU', 'CATIIIA').
airport('NAU', 'CATIIIB').
airport('NAU', 'CATIIIC').
airport('FGU', 'CATI').
airport('FGU', 'CATII').
airport('FGU', 'CATIIIA').
airport('FGU', 'CATIIIB').
airport('FGU', 'CATIIIC').
airport('BER', 'CATI').
airport('BER', 'CATII').
airport('BER', 'CATIIIA').
airport('BER', 'CATIIIB').
airport('BER', 'CATIIIC').


airport('ATL', 'Hartsfield - Jackson Atlanta International Airport', 1026, 33.6366996765137, -84.4281005859375, 12390).
airport('ATL', 'Hartsfield - Jackson Atlanta International Airport', 1026, 33.6366996765137, -84.4281005859375, 11890).
airport('ATL', 'Hartsfield - Jackson Atlanta International Airport', 1026, 33.6366996765137, -84.4281005859375, 11390).
airport('ATL', 'Hartsfield - Jackson Atlanta International Airport', 1026, 33.6366996765137, -84.4281005859375, 10890).
airport('ATL', 'Hartsfield - Jackson Atlanta International Airport', 1026, 33.6366996765137, -84.4281005859375, 10390).
airport('ANC', 'Anchorage Ted Stevens', 151, 61.1744003295898, -149.996002197266, 12400).
airport('ANC', 'Anchorage Ted Stevens', 151, 61.1744003295898, -149.996002197266, 11900).
airport('ANC', 'Anchorage Ted Stevens', 151, 61.1744003295898, -149.996002197266, 11400).
airport('AUS', 'Austin Bergstrom International Airport', 542, 30.1944999694824, -97.6698989868164, 12250).
airport('AUS', 'Austin Bergstrom International Airport', 542, 30.1944999694824, -97.6698989868164, 11750).
airport('BNA', 'Nashville International Airport', 599, 36.1245002746582, -86.6781997680664, 11030).
airport('BNA', 'Nashville International Airport', 599, 36.1245002746582, -86.6781997680664, 10530).
airport('BNA', 'Nashville International Airport', 599, 36.1245002746582, -86.6781997680664, 10030).
airport('BNA', 'Nashville International Airport', 599, 36.1245002746582, -86.6781997680664, 9530).
airport('BOS', 'Boston Logan', 19, 42.36429977, -71.00520325, 10083).
airport('BOS', 'Boston Logan', 19, 42.36429977, -71.00520325, 9583).
airport('BOS', 'Boston Logan', 19, 42.36429977, -71.00520325, 9083).
airport('BOS', 'Boston Logan', 19, 42.36429977, -71.00520325, 8583).
airport('BOS', 'Boston Logan', 19, 42.36429977, -71.00520325, 8083).
airport('BOS', 'Boston Logan', 19, 42.36429977, -71.00520325, 7583).
airport('BWI', 'Baltimore/Washington International Airport', 143, 39.17539978, -76.66829681, 10502).
airport('BWI', 'Baltimore/Washington International Airport', 143, 39.17539978, -76.66829681, 10002).
airport('BWI', 'Baltimore/Washington International Airport', 143, 39.17539978, -76.66829681, 9502).
airport('DCA', 'Ronald Reagan Washington National Airport', 14, 38.8521003723145, -77.0376968383789, 7169).
airport('DCA', 'Ronald Reagan Washington National Airport', 14, 38.8521003723145, -77.0376968383789, 6669).
airport('DCA', 'Ronald Reagan Washington National Airport', 14, 38.8521003723145, -77.0376968383789, 6169).
airport('DFW', 'Dallas/Fort Worth International Airport', 607, 32.896800994873, -97.0380020141602, 13401).
airport('DFW', 'Dallas/Fort Worth International Airport', 607, 32.896800994873, -97.0380020141602, 12901).
airport('DFW', 'Dallas/Fort Worth International Airport', 607, 32.896800994873, -97.0380020141602, 12401).
airport('DFW', 'Dallas/Fort Worth International Airport', 607, 32.896800994873, -97.0380020141602, 11901).
airport('DFW', 'Dallas/Fort Worth International Airport', 607, 32.896800994873, -97.0380020141602, 11401).
airport('DFW', 'Dallas/Fort Worth International Airport', 607, 32.896800994873, -97.0380020141602, 10901).
airport('DFW', 'Dallas/Fort Worth International Airport', 607, 32.896800994873, -97.0380020141602, 10401).
airport('FLL', 'Fort Lauderdale/Hollywood International Airport', 64, 26.0725994110107, -80.152702331543, 9000).
airport('FLL', 'Fort Lauderdale/Hollywood International Airport', 64, 26.0725994110107, -80.152702331543, 8500).
airport('IAD', 'Washington Dulles International Airport', 313, 38.94449997, -77.45580292, 11500).
airport('IAD', 'Washington Dulles International Airport', 313, 38.94449997, -77.45580292, 11000).
airport('IAD', 'Washington Dulles International Airport', 313, 38.94449997, -77.45580292, 10500).
airport('IAD', 'Washington Dulles International Airport', 313, 38.94449997, -77.45580292, 10000).
airport('IAH', 'George Bush Intercontinental', 96, 29.9843997955322, -95.3414001464844, 12001).
airport('IAH', 'George Bush Intercontinental', 96, 29.9843997955322, -95.3414001464844, 11501).
airport('IAH', 'George Bush Intercontinental', 96, 29.9843997955322, -95.3414001464844, 11001).
airport('IAH', 'George Bush Intercontinental', 96, 29.9843997955322, -95.3414001464844, 10501).
airport('IAH', 'George Bush Intercontinental', 96, 29.9843997955322, -95.3414001464844, 10001).
airport('JFK', 'New York John F. Kennedy International Airport', 12, 40.63980103, -73.77890015, 14511).
airport('JFK', 'New York John F. Kennedy International Airport', 12, 40.63980103, -73.77890015, 14011).
airport('JFK', 'New York John F. Kennedy International Airport', 12, 40.63980103, -73.77890015, 13511).
airport('JFK', 'New York John F. Kennedy International Airport', 12, 40.63980103, -73.77890015, 13011).
airport('LAX', 'Los Angeles International Airport', 127, 33.94250107, -118.4079971, 12091).
airport('LAX', 'Los Angeles International Airport', 127, 33.94250107, -118.4079971, 11591).
airport('LAX', 'Los Angeles International Airport', 127, 33.94250107, -118.4079971, 11091).
airport('LAX', 'Los Angeles International Airport', 127, 33.94250107, -118.4079971, 10591).
airport('LGA', 'New York La Guardia', 20, 40.77719879, -73.87259674, 7003).
airport('LGA', 'New York La Guardia', 20, 40.77719879, -73.87259674, 6503).
airport('MCO', 'Orlando International Airport', 96, 28.4293994903564, -81.3089981079102, 12005).
airport('MCO', 'Orlando International Airport', 96, 28.4293994903564, -81.3089981079102, 11505).
airport('MCO', 'Orlando International Airport', 96, 28.4293994903564, -81.3089981079102, 11005).
airport('MCO', 'Orlando International Airport', 96, 28.4293994903564, -81.3089981079102, 10505).
airport('MIA', 'Miami International Airport', 8, 25.7931995391846, -80.2906036376953, 13016).
airport('MIA', 'Miami International Airport', 8, 25.7931995391846, -80.2906036376953, 12516).
airport('MIA', 'Miami International Airport', 8, 25.7931995391846, -80.2906036376953, 12016).
airport('MIA', 'Miami International Airport', 8, 25.7931995391846, -80.2906036376953, 11516).
airport('MSP', 'Minneapolis-St.Paul International Airport', 841, 44.8819999695, -93.2218017578, 11006).
airport('MSP', 'Minneapolis-St.Paul International Airport', 841, 44.8819999695, -93.2218017578, 10506).
airport('MSP', 'Minneapolis-St.Paul International Airport', 841, 44.8819999695, -93.2218017578, 10006).
airport('MSP', 'Minneapolis-St.Paul International Airport', 841, 44.8819999695, -93.2218017578, 9506).
airport('ORD', "Chicago O'Hare International Airport", 672, 41.97859955, -87.90480042, 13000).
airport('ORD', "Chicago O'Hare International Airport", 672, 41.97859955, -87.90480042, 12500).
airport('ORD', "Chicago O'Hare International Airport", 672, 41.97859955, -87.90480042, 12000).
airport('ORD', "Chicago O'Hare International Airport", 672, 41.97859955, -87.90480042, 11500).
airport('ORD', "Chicago O'Hare International Airport", 672, 41.97859955, -87.90480042, 11000).
airport('ORD', "Chicago O'Hare International Airport", 672, 41.97859955, -87.90480042, 10500).
airport('ORD', "Chicago O'Hare International Airport", 672, 41.97859955, -87.90480042, 10000).
airport('PBI', 'Palm Beach International Airport', 19, 26.6832008361816, -80.0955963134766, 10000).
airport('PBI', 'Palm Beach International Airport', 19, 26.6832008361816, -80.0955963134766, 9500).
airport('PBI', 'Palm Beach International Airport', 19, 26.6832008361816, -80.0955963134766, 9000).
airport('PHX', 'Phoenix Sky Harbor International Airport', 1135, 33.4342994689941, -112.012001037598, 11489).
airport('PHX', 'Phoenix Sky Harbor International Airport', 1135, 33.4342994689941, -112.012001037598, 10989).
airport('PHX', 'Phoenix Sky Harbor International Airport', 1135, 33.4342994689941, -112.012001037598, 10489).
airport('RDU', 'Raleigh-Durham', 435, 35.8776016235352, -78.7874984741211, 10000).
airport('RDU', 'Raleigh-Durham', 435, 35.8776016235352, -78.7874984741211, 9500).
airport('RDU', 'Raleigh-Durham', 435, 35.8776016235352, -78.7874984741211, 9000).
airport('SEA', 'Seattle-Tacoma', 432, 47.4490013122559, -122.30899810791, 11901).
airport('SEA', 'Seattle-Tacoma', 432, 47.4490013122559, -122.30899810791, 11401).
airport('SEA', 'Seattle-Tacoma', 432, 47.4490013122559, -122.30899810791, 10901).
airport('SFO', 'San Francisco International Airport', 13, 37.6189994812012, -122.375, 11870).
airport('SFO', 'San Francisco International Airport', 13, 37.6189994812012, -122.375, 11370).
airport('SFO', 'San Francisco International Airport', 13, 37.6189994812012, -122.375, 10870).
airport('SFO', 'San Francisco International Airport', 13, 37.6189994812012, -122.375, 10370).
airport('SJC', 'Norman Y. Mineta San Jose International Airport', 62, 37.3625984191895, -121.929000854492, 11000).
airport('SJC', 'Norman Y. Mineta San Jose International Airport', 62, 37.3625984191895, -121.929000854492, 10500).
airport('SJC', 'Norman Y. Mineta San Jose International Airport', 62, 37.3625984191895, -121.929000854492, 10000).
airport('TPA', 'Tampa International Airport', 26, 27.9755001068115, -82.533203125, 11002).
airport('TPA', 'Tampa International Airport', 26, 27.9755001068115, -82.533203125, 10502).
airport('TPA', 'Tampa International Airport', 26, 27.9755001068115, -82.533203125, 10002).
airport('SAN', 'San Diego Lindbergh', 16, 32.7336006165, -117.190002441, 9400).
airport('LGB', 'Long Beach Airport', 60, 33.81769943, -118.1520004, 10003).
airport('LGB', 'Long Beach Airport', 60, 33.81769943, -118.1520004, 9503).
airport('LGB', 'Long Beach Airport', 60, 33.81769943, -118.1520004, 9003).
airport('SNA', 'Orange County/Santa Ana, John Wayne', 56, 33.67570114, -117.8679962, 5701).
airport('SNA', 'Orange County/Santa Ana, John Wayne', 56, 33.67570114, -117.8679962, 5201).
airport('SLC', 'Salt Lake City', 56, 40.7883987426758, -111.977996826172, 12002).
airport('SLC', 'Salt Lake City', 56, 40.7883987426758, -111.977996826172, 11502).
airport('SLC', 'Salt Lake City', 56, 40.7883987426758, -111.977996826172, 11002).
airport('SLC', 'Salt Lake City', 56, 40.7883987426758, -111.977996826172, 10502).
airport('LAS', 'Las Vegas Mc Carran', 2181, 36.08010101, -115.1520004, 14512).
airport('LAS', 'Las Vegas Mc Carran', 2181, 36.08010101, -115.1520004, 14012).
airport('LAS', 'Las Vegas Mc Carran', 2181, 36.08010101, -115.1520004, 13512).
airport('LAS', 'Las Vegas Mc Carran', 2181, 36.08010101, -115.1520004, 13012).
airport('DEN', 'Denver International Airport', 5433, 39.8616981506348, -104.672996520996, 16000).
airport('DEN', 'Denver International Airport', 5433, 39.8616981506348, -104.672996520996, 15500).
airport('DEN', 'Denver International Airport', 5433, 39.8616981506348, -104.672996520996, 15000).
airport('DEN', 'Denver International Airport', 5433, 39.8616981506348, -104.672996520996, 14500).
airport('DEN', 'Denver International Airport', 5433, 39.8616981506348, -104.672996520996, 14000).
airport('DEN', 'Denver International Airport', 5433, 39.8616981506348, -104.672996520996, 13500).
airport('HPN', 'Westchester County', 439, 41.0670013427734, -73.7076034545898, 6549).
airport('HPN', 'Westchester County', 439, 41.0670013427734, -73.7076034545898, 6049).
airport('SAT', 'San Antonio', 809, 29.5337009429932, -98.4698028564453, 8505).
airport('SAT', 'San Antonio', 809, 29.5337009429932, -98.4698028564453, 8005).
airport('SAT', 'San Antonio', 809, 29.5337009429932, -98.4698028564453, 7505).
airport('MSY', 'New Orleans L. Armstrong', 3, 29.9934005737305, -90.2580032348633, 10104).
airport('MSY', 'New Orleans L. Armstrong', 3, 29.9934005737305, -90.2580032348633, 9604).
airport('EWR', 'Newark, Liberty', 17, 40.6925010681152, -74.168701171875, 11000).
airport('EWR', 'Newark, Liberty', 17, 40.6925010681152, -74.168701171875, 10500).
airport('EWR', 'Newark, Liberty', 17, 40.6925010681152, -74.168701171875, 10000).
airport('CID', 'The Eastern Iowa Airport', 869, 41.8847007751465, -91.7108001708984, 8600).
airport('CID', 'The Eastern Iowa Airport', 869, 41.8847007751465, -91.7108001708984, 8100).
airport('HNL', 'Honolulu International Airport', 13, 21.3187007904053, -157.921997070312, 12312).
airport('HNL', 'Honolulu International Airport', 13, 21.3187007904053, -157.921997070312, 11812).
airport('HNL', 'Honolulu International Airport', 13, 21.3187007904053, -157.921997070312, 11312).
airport('HNL', 'Honolulu International Airport', 13, 21.3187007904053, -157.921997070312, 10812).
airport('HOU', 'Houston Hobby', 46, 29.64539909, -95.27890015, 7602).
airport('HOU', 'Houston Hobby', 46, 29.64539909, -95.27890015, 7102).
airport('HOU', 'Houston Hobby', 46, 29.64539909, -95.27890015, 6602).
airport('HOU', 'Houston Hobby', 46, 29.64539909, -95.27890015, 6102).
airport('ELP', 'El Paso International Airport', 3961, 31.80719948, -106.3779984, 12020).
airport('ELP', 'El Paso International Airport', 3961, 31.80719948, -106.3779984, 11520).
airport('ELP', 'El Paso International Airport', 3961, 31.80719948, -106.3779984, 11020).
airport('SJU', 'Puerto Rico, Luis Munoz International Airport', 9, 18.4393997192, -66.0018005371, 10400).
airport('SJU', 'Puerto Rico, Luis Munoz International Airport', 9, 18.4393997192, -66.0018005371, 9900).
airport('CLE', 'Cleveland, Hopkins International Airport', 799, 41.4117012024, -81.8498001099, 9956).
airport('CLE', 'Cleveland, Hopkins International Airport', 799, 41.4117012024, -81.8498001099, 9456).
airport('CLE', 'Cleveland, Hopkins International Airport', 799, 41.4117012024, -81.8498001099, 8956).
airport('OAK', 'Oakland', 9, 37.7212982177734, -122.221000671387, 10520).
airport('OAK', 'Oakland', 9, 37.7212982177734, -122.221000671387, 10020).
airport('OAK', 'Oakland', 9, 37.7212982177734, -122.221000671387, 9520).
airport('OAK', 'Oakland', 9, 37.7212982177734, -122.221000671387, 9020).
airport('TUS', 'Tucson International Airport', 2643, 32.1161003112793, -110.94100189209, 10996).
airport('TUS', 'Tucson International Airport', 2643, 32.1161003112793, -110.94100189209, 10496).
airport('TUS', 'Tucson International Airport', 2643, 32.1161003112793, -110.94100189209, 9996).
airport('SAF', 'Santa Fe', 6348, 35.617099762, -106.088996887, 8366).
airport('SAF', 'Santa Fe', 6348, 35.617099762, -106.088996887, 7866).
airport('SAF', 'Santa Fe', 6348, 35.617099762, -106.088996887, 7366).
airport('PHL', 'Philadelphia International Airport', 36, 39.871898651123, -75.241096496582, 10506).
airport('PHL', 'Philadelphia International Airport', 36, 39.871898651123, -75.241096496582, 10006).
airport('PHL', 'Philadelphia International Airport', 36, 39.871898651123, -75.241096496582, 9506).
airport('PHL', 'Philadelphia International Airport', 36, 39.871898651123, -75.241096496582, 9006).
airport('DTW', 'Detroit Metropolitan, Wayne County', 645, 42.2123985290527, -83.353401184082, 12003).
airport('DTW', 'Detroit Metropolitan, Wayne County', 645, 42.2123985290527, -83.353401184082, 11503).
airport('DTW', 'Detroit Metropolitan, Wayne County', 645, 42.2123985290527, -83.353401184082, 11003).
airport('DTW', 'Detroit Metropolitan, Wayne County', 645, 42.2123985290527, -83.353401184082, 10503).
airport('DTW', 'Detroit Metropolitan, Wayne County', 645, 42.2123985290527, -83.353401184082, 10003).
airport('DTW', 'Detroit Metropolitan, Wayne County', 645, 42.2123985290527, -83.353401184082, 9503).
airport('YYZ', 'Toronto Pearson International Airport', 569, 43.6772003174, -79.6305999756, 11120).
airport('YYZ', 'Toronto Pearson International Airport', 569, 43.6772003174, -79.6305999756, 10620).
airport('YYZ', 'Toronto Pearson International Airport', 569, 43.6772003174, -79.6305999756, 10120).
airport('YYZ', 'Toronto Pearson International Airport', 569, 43.6772003174, -79.6305999756, 9620).
airport('YYZ', 'Toronto Pearson International Airport', 569, 43.6772003174, -79.6305999756, 9120).
airport('YVR', 'Vancouver International Airport', 14, 49.193901062, -123.183998108, 11500).
airport('YVR', 'Vancouver International Airport', 14, 49.193901062, -123.183998108, 11000).
airport('YVR', 'Vancouver International Airport', 14, 49.193901062, -123.183998108, 10500).
airport('LHR', 'London Heathrow', 83, 51.4706001282, -0.461941003799, 12799).
airport('LHR', 'London Heathrow', 83, 51.4706001282, -0.461941003799, 12299).
airport('LGW', 'London Gatwick', 202, 51.1481018066406, -0.190277993679047, 10364).
airport('LGW', 'London Gatwick', 202, 51.1481018066406, -0.190277993679047, 9864).
airport('CDG', 'Paris Charles de Gaulle', 392, 49.0127983093, 2.54999995232, 13829).
airport('CDG', 'Paris Charles de Gaulle', 392, 49.0127983093, 2.54999995232, 13329).
airport('CDG', 'Paris Charles de Gaulle', 392, 49.0127983093, 2.54999995232, 12829).
airport('CDG', 'Paris Charles de Gaulle', 392, 49.0127983093, 2.54999995232, 12329).
airport('FRA', 'Frankfurt am Main', 364, 50.0264015198, 8.54312992096, 13123).
airport('FRA', 'Frankfurt am Main', 364, 50.0264015198, 8.54312992096, 12623).
airport('FRA', 'Frankfurt am Main', 364, 50.0264015198, 8.54312992096, 12123).
airport('FRA', 'Frankfurt am Main', 364, 50.0264015198, 8.54312992096, 11623).
airport('HEL', 'Helsinki Ventaa', 179, 60.3171997070312, 24.9633007049561, 11286).
airport('HEL', 'Helsinki Ventaa', 179, 60.3171997070312, 24.9633007049561, 10786).
airport('HEL', 'Helsinki Ventaa', 179, 60.3171997070312, 24.9633007049561, 10286).
airport('NRT', 'Tokyo Narita', 141, 35.7647018433, 140.386001587, 13123).
airport('NRT', 'Tokyo Narita', 141, 35.7647018433, 140.386001587, 12623).
airport('SYD', 'Sydney Kingsford Smith', 21, -33.9460983276367, 151.177001953125, 12999).
airport('SYD', 'Sydney Kingsford Smith', 21, -33.9460983276367, 151.177001953125, 12499).
airport('SYD', 'Sydney Kingsford Smith', 21, -33.9460983276367, 151.177001953125, 11999).
airport('SIN', 'Singapore, Changi International Airport', 22, 1.3501900434494, 103.994003295898, 13123).
airport('SIN', 'Singapore, Changi International Airport', 22, 1.3501900434494, 103.994003295898, 12623).
airport('SIN', 'Singapore, Changi International Airport', 22, 1.3501900434494, 103.994003295898, 12123).
airport('MEL', 'Melbourne International Airport', 434, -37.6733016967773, 144.843002319336, 11998).
airport('MEL', 'Melbourne International Airport', 434, -37.6733016967773, 144.843002319336, 11498).
airport('DXB', 'Dubai International Airport', 62, 25.2527999878, 55.3643989563, 13124).
airport('DXB', 'Dubai International Airport', 62, 25.2527999878, 55.3643989563, 12624).
airport('DEL', 'Indira Gandhi International Airport', 777, 28.566499710083, 77.1031036376953, 14534).
airport('DEL', 'Indira Gandhi International Airport', 777, 28.566499710083, 77.1031036376953, 14034).
airport('DEL', 'Indira Gandhi International Airport', 777, 28.566499710083, 77.1031036376953, 13534).
airport('DUB', 'Dublin International Airport', 242, 53.4212989807129, -6.27007007598877, 8652).
airport('DUB', 'Dublin International Airport', 242, 53.4212989807129, -6.27007007598877, 8152).
airport('HKG', 'Hong Kong - Chek Lap Kok International Airport', 28, 22.3089008331, 113.915000916, 12467).
airport('HKG', 'Hong Kong - Chek Lap Kok International Airport', 28, 22.3089008331, 113.915000916, 11967).
airport('PER', 'Perth International Airport', 67, -31.940299987793, 115.967002868652, 11299).
airport('PER', 'Perth International Airport', 67, -31.940299987793, 115.967002868652, 10799).
airport('AKL', 'Auckland International Airport', 23, -37.0080986023, 174.792007446, 11926).
airport('AKL', 'Auckland International Airport', 23, -37.0080986023, 174.792007446, 11426).
airport('PEK', 'Beijing Capital International Airport', 116, 40.0801010131836, 116.584999084473, 12468).
airport('PEK', 'Beijing Capital International Airport', 116, 40.0801010131836, 116.584999084473, 11968).
airport('PEK', 'Beijing Capital International Airport', 116, 40.0801010131836, 116.584999084473, 11468).
airport('WLG', 'Wellington International Airport', 41, -41.3272018433, 174.804992676, 6352).
airport('BNE', 'Brisbane International Airport', 13, -27.3841991424561, 153.117004394531, 11680).
airport('BNE', 'Brisbane International Airport', 13, -27.3841991424561, 153.117004394531, 11180).
airport('PVG', 'Shanghai - Pudong International Airport', 13, 31.1434001922607, 121.805000305176, 13123).
airport('PVG', 'Shanghai - Pudong International Airport', 13, 31.1434001922607, 121.805000305176, 12623).
airport('FCO', 'Leonardo da Vinci-Fiumicino International Airport', 15, 41.8045005798, 12.2508001328, 12795).
airport('FCO', 'Leonardo da Vinci-Fiumicino International Airport', 15, 41.8045005798, 12.2508001328, 12295).
airport('FCO', 'Leonardo da Vinci-Fiumicino International Airport', 15, 41.8045005798, 12.2508001328, 11795).
airport('BOM', 'Mumbai, Chhatrapati Shivaji International Airport', 39, 19.0886993408, 72.8678970337, 11302).
airport('BOM', 'Mumbai, Chhatrapati Shivaji International Airport', 39, 19.0886993408, 72.8678970337, 10802).
airport('AMS', 'Amsterdam Airport Schiphol', -11, 52.3086013794, 4.76388978958, 12467).
airport('AMS', 'Amsterdam Airport Schiphol', -11, 52.3086013794, 4.76388978958, 11967).
airport('AMS', 'Amsterdam Airport Schiphol', -11, 52.3086013794, 4.76388978958, 11467).
airport('AMS', 'Amsterdam Airport Schiphol', -11, 52.3086013794, 4.76388978958, 10967).
airport('AMS', 'Amsterdam Airport Schiphol', -11, 52.3086013794, 4.76388978958, 10467).
airport('AMS', 'Amsterdam Airport Schiphol', -11, 52.3086013794, 4.76388978958, 9967).
airport('KUL', 'Kuala Lumpur International Airport', 69, 2.74557995796204, 101.709999084473, 13288).
airport('KUL', 'Kuala Lumpur International Airport', 69, 2.74557995796204, 101.709999084473, 12788).
airport('KUL', 'Kuala Lumpur International Airport', 69, 2.74557995796204, 101.709999084473, 12288).
airport('PRG', 'Prague, Ruzyne International Airport', 1247, 50.1007995605469, 14.2600002288818, 12189).
airport('PRG', 'Prague, Ruzyne International Airport', 1247, 50.1007995605469, 14.2600002288818, 11689).
airport('BCN', 'Barcelona International Airport', 12, 41.2971000671387, 2.07845997810364, 11654).
airport('BCN', 'Barcelona International Airport', 12, 41.2971000671387, 2.07845997810364, 11154).
airport('BCN', 'Barcelona International Airport', 12, 41.2971000671387, 2.07845997810364, 10654).
airport('MAD', 'Adolfo Suarez Barajas Airport International Airport', 1998, 40.4936, -3.56676, 13711).
airport('MAD', 'Adolfo Suarez Barajas Airport International Airport', 1998, 40.4936, -3.56676, 13211).
airport('MAD', 'Adolfo Suarez Barajas Airport International Airport', 1998, 40.4936, -3.56676, 12711).
airport('VIE', 'Vienna International Airport', 600, 48.1102981567383, 16.5697002410889, 11811).
airport('VIE', 'Vienna International Airport', 600, 48.1102981567383, 16.5697002410889, 11311).
airport('ZRH', 'Zurich-Kloten Airport', 1416, 47.4646987915039, 8.54916954040527, 12139).
airport('ZRH', 'Zurich-Kloten Airport', 1416, 47.4646987915039, 8.54916954040527, 11639).
airport('ZRH', 'Zurich-Kloten Airport', 1416, 47.4646987915039, 8.54916954040527, 11139).
airport('GVA', 'Geneva-Cointrin International Airport', 1411, 46.2380981445312, 6.10895013809204, 12795).
airport('GVA', 'Geneva-Cointrin International Airport', 1411, 46.2380981445312, 6.10895013809204, 12295).
airport('YOW', 'Ottawa Macdonald-Cartier International Airport', 374, 45.3224983215, -75.6691970825, 10000).
airport('YOW', 'Ottawa Macdonald-Cartier International Airport', 374, 45.3224983215, -75.6691970825, 9500).
airport('YOW', 'Ottawa Macdonald-Cartier International Airport', 374, 45.3224983215, -75.6691970825, 9000).
airport('BRU', 'Brussels Airport', 184, 50.9014015198, 4.48443984985, 11936).
airport('BRU', 'Brussels Airport', 184, 50.9014015198, 4.48443984985, 11436).
airport('BRU', 'Brussels Airport', 184, 50.9014015198, 4.48443984985, 10936).
airport('MUC', 'Munich International Airport', 1487, 48.3538017272949, 11.7861003875732, 13123).
airport('MUC', 'Munich International Airport', 1487, 48.3538017272949, 11.7861003875732, 12623).
airport('CHC', 'Christchurch International Airport', 123, -43.4893989562988, 172.531997680664, 10787).
airport('CHC', 'Christchurch International Airport', 123, -43.4893989562988, 172.531997680664, 10287).
airport('CHC', 'Christchurch International Airport', 123, -43.4893989562988, 172.531997680664, 9787).
airport('CBR', 'Canberra International Airport', 1886, -35.3069000244141, 149.195007324219, 10771).
airport('CBR', 'Canberra International Airport', 1886, -35.3069000244141, 149.195007324219, 10271).
airport('RSW', 'Southwest Florida International Airport', 30, 26.5361995697021, -81.7552032470703, 12000).
airport('MAN', 'Manchester Airport', 257, 53.3536987304688, -2.27495002746582, 10000).
airport('MAN', 'Manchester Airport', 257, 53.3536987304688, -2.27495002746582, 9500).
airport('YUL', 'Montreal / Pierre Elliott Trudeau International Airport', 118, 45.4706001282, -73.7407989502, 11000).
airport('YUL', 'Montreal / Pierre Elliott Trudeau International Airport', 118, 45.4706001282, -73.7407989502, 10500).
airport('YUL', 'Montreal / Pierre Elliott Trudeau International Airport', 118, 45.4706001282, -73.7407989502, 10000).
airport('YEG', 'Edmonton International Airport', 2373, 53.3097000122, -113.580001831, 11000).
airport('YEG', 'Edmonton International Airport', 2373, 53.3097000122, -113.580001831, 10500).
airport('CGN', 'Cologne Bonn Airport', 302, 50.8658981323, 7.1427397728, 12516).
airport('CGN', 'Cologne Bonn Airport', 302, 50.8658981323, 7.1427397728, 12016).
airport('CGN', 'Cologne Bonn Airport', 302, 50.8658981323, 7.1427397728, 11516).
airport('LCY', 'London City Airport', 19, 51.505278, 0.055278, 4948).
airport('GOT', 'Gothenburg-Landvetter Airport', 506, 57.6627998352051, 12.2798004150391, 10823).
airport('VCE', 'Venice Marco Polo Airport', 7, 45.5052986145, 12.3519001007, 10827).
airport('VCE', 'Venice Marco Polo Airport', 7, 45.5052986145, 12.3519001007, 10327).
airport('SNN', 'Shannon Airport', 46, 52.7019996643066, -8.92481994628906, 10495).
airport('SNN', 'Shannon Airport', 46, 52.7019996643066, -8.92481994628906, 9995).
airport('SNN', 'Shannon Airport', 46, 52.7019996643066, -8.92481994628906, 9495).
airport('SNN', 'Shannon Airport', 46, 52.7019996643066, -8.92481994628906, 8995).
airport('SNN', 'Shannon Airport', 46, 52.7019996643066, -8.92481994628906, 8495).
airport('OSL', 'Oslo Gardermoen Airport', 681, 60.1939010620117, 11.1003999710083, 11811).
airport('OSL', 'Oslo Gardermoen Airport', 681, 60.1939010620117, 11.1003999710083, 11311).
airport('ARN', 'Stockholm-Arlanda Airport', 137, 59.6519012451172, 17.9186000823975, 10830).
airport('ARN', 'Stockholm-Arlanda Airport', 137, 59.6519012451172, 17.9186000823975, 10330).
airport('ARN', 'Stockholm-Arlanda Airport', 137, 59.6519012451172, 17.9186000823975, 9830).
airport('STN', 'London Stansted Airport', 348, 51.8849983215, 0.234999999404, 10003).
airport('EMA', 'East Midlands Airport', 306, 52.8311004639, -1.32806003094, 9491).
airport('EDI', 'Edinburgh Airport', 135, 55.9500007629395, -3.37249994277954, 8400).
airport('EDI', 'Edinburgh Airport', 135, 55.9500007629395, -3.37249994277954, 7900).
airport('EDI', 'Edinburgh Airport', 135, 55.9500007629395, -3.37249994277954, 7400).
airport('GLA', 'Glasgow International Airport', 26, 55.8718986511, -4.43306016922, 8720).
airport('GLA', 'Glasgow International Airport', 26, 55.8718986511, -4.43306016922, 8220).
airport('LPL', 'Liverpool John Lennon Airport', 80, 53.3335990905762, -2.8497200012207, 7500).
airport('YYC', 'Calgary International Airport', 3557, 51.113899231, -114.019996643, 12675).
airport('YYC', 'Calgary International Airport', 3557, 51.113899231, -114.019996643, 12175).
airport('YYC', 'Calgary International Airport', 3557, 51.113899231, -114.019996643, 11675).
airport('MNL', 'Manila, Ninoy Aquino International Airport', 75, 14.508600235, 121.019996643, 12261).
airport('MNL', 'Manila, Ninoy Aquino International Airport', 75, 14.508600235, 121.019996643, 11761).
airport('BKK', 'Suvarnabhumi Bangkok International Airport', 5, 13.6810998916626, 100.747001647949, 13123).
airport('BKK', 'Suvarnabhumi Bangkok International Airport', 5, 13.6810998916626, 100.747001647949, 12623).
airport('DME', 'Moscow, Domodedovo International Airport', 588, 55.4087982177734, 37.9062995910645, 12448).
airport('DME', 'Moscow, Domodedovo International Airport', 588, 55.4087982177734, 37.9062995910645, 11948).
airport('DME', 'Moscow, Domodedovo International Airport', 588, 55.4087982177734, 37.9062995910645, 11448).
airport('SVO', 'Moscow, Sheremetyevo International Airport', 622, 55.972599029541, 37.4146003723145, 12139).
airport('SVO', 'Moscow, Sheremetyevo International Airport', 622, 55.972599029541, 37.4146003723145, 11639).
airport('ITM', 'Osaka International Airport', 50, 34.7854995727539, 135.438003540039, 9840).
airport('ITM', 'Osaka International Airport', 50, 34.7854995727539, 135.438003540039, 9340).
airport('HND', 'Tokyo Haneda International Airport', 35, 35.5522994995117, 139.779998779297, 9840).
airport('HND', 'Tokyo Haneda International Airport', 35, 35.5522994995117, 139.779998779297, 9340).
airport('HND', 'Tokyo Haneda International Airport', 35, 35.5522994995117, 139.779998779297, 8840).
airport('HND', 'Tokyo Haneda International Airport', 35, 35.5522994995117, 139.779998779297, 8340).
airport('DOH', 'Doha, Hamad International Airport', 13, 25.273056, 51.608056, 15912).
airport('DOH', 'Doha, Hamad International Airport', 13, 25.273056, 51.608056, 15412).
airport('ORY', 'Paris, Orly Airport', 291, 48.7252998352, 2.35944008827, 11975).
airport('ORY', 'Paris, Orly Airport', 291, 48.7252998352, 2.35944008827, 11475).
airport('ORY', 'Paris, Orly Airport', 291, 48.7252998352, 2.35944008827, 10975).
airport('NCE', "Nice-Cote d'Azur Airport", 12, 43.6584014893, 7.21586990356, 9712).
airport('NCE', "Nice-Cote d'Azur Airport", 12, 43.6584014893, 7.21586990356, 9212).
airport('MXP', 'Milan, Malpensa International Airport', 768, 45.6305999756, 8.72811031342, 12861).
airport('MXP', 'Milan, Malpensa International Airport', 768, 45.6305999756, 8.72811031342, 12361).
airport('ATH', 'Athens, Eleftherios Venizelos International Airport', 308, 37.9364013672, 23.9444999695, 13123).
airport('ATH', 'Athens, Eleftherios Venizelos International Airport', 308, 37.9364013672, 23.9444999695, 12623).
airport('ZAG', 'Zagreb Airport', 353, 45.7429008484, 16.0687999725, 10669).
airport('BUD', 'Budapest Ferenc Liszt International Airport', 495, 47.4369010925, 19.2555999756, 12162).
airport('BUD', 'Budapest Ferenc Liszt International Airport', 495, 47.4369010925, 19.2555999756, 11662).
airport('ALC', 'Alicante International Airport', 142, 38.2821998596191, -0.55815601348877, 9842).
airport('BIO', 'Bilbao Airport', 138, 43.3011016845703, -2.91060996055603, 8530).
airport('BIO', 'Bilbao Airport', 138, 43.3011016845703, -2.91060996055603, 8030).
airport('IBZ', 'Ibiza Airport', 24, 38.8728981018, 1.37311995029, 9186).
airport('MAH', 'Menorca Airport', 302, 39.8625984191895, 4.21864986419678, 7710).
airport('MAH', 'Menorca Airport', 302, 39.8625984191895, 4.21864986419678, 7210).
airport('CCJ', 'Calicut International Airport', 342, 11.1367998123, 75.9552993774, 9383).
airport('HYD', 'Hyderabad, Rajiv Gandhi International Airport', 2024, 17.2313175201, 78.4298553467, 13976).
airport('MAA', 'Chennai International Airport', 52, 12.9900054931641, 80.1692962646484, 12001).
airport('MAA', 'Chennai International Airport', 52, 12.9900054931641, 80.1692962646484, 11501).
airport('CCU', 'Kolkata, Netaji Subhash Chandra Bose International Airport', 16, 22.6546993255615, 88.4467010498047, 11900).
airport('CCU', 'Kolkata, Netaji Subhash Chandra Bose International Airport', 16, 22.6546993255615, 88.4467010498047, 11400).
airport('BLR', 'Bengaluru International Airport', 3000, 13.1978998184, 77.7062988281, 13123).
airport('ICN', 'Seoul, Incheon International Airport', 23, 37.4691009521484, 126.450996398926, 13000).
airport('ICN', 'Seoul, Incheon International Airport', 23, 37.4691009521484, 126.450996398926, 12500).
airport('ICN', 'Seoul, Incheon International Airport', 23, 37.4691009521484, 126.450996398926, 12000).
airport('YYT', "St. John's International Airport", 461, 47.618598938, -52.7518997192, 8502).
airport('YYT', "St. John's International Airport", 461, 47.618598938, -52.7518997192, 8002).
airport('YYT', "St. John's International Airport", 461, 47.618598938, -52.7518997192, 7502).
airport('TFN', 'Tenerife Norte Airport', 2076, 28.4827003479, -16.3414993286, 11155).
airport('CPT', 'Cape Town International Airport', 151, -33.9648017883, 18.6016998291, 10502).
airport('CPT', 'Cape Town International Airport', 151, -33.9648017883, 18.6016998291, 10002).
airport('JNB', 'Johannesburg, OR Tambo International Airport', 5558, -26.1392002106, 28.2460002899, 14495).
airport('JNB', 'Johannesburg, OR Tambo International Airport', 5558, -26.1392002106, 28.2460002899, 13995).
airport('DUR', 'Durban, King Shaka International Airport', 295, -29.6144444444, 31.1197222222, 12139).
airport('NBO', 'Nairobi, Jomo Kenyatta International Airport', 5330, -1.31923997402, 36.9277992249, 13507).
airport('MBA', 'Mombasa Moi International Airport', 200, -4.03483009338379, 39.5942001342773, 10991).
airport('MBA', 'Mombasa Moi International Airport', 200, -4.03483009338379, 39.5942001342773, 10491).
airport('MVD', 'Montevideo, Carrasco International /General C L Berisso Airport', 105, -34.8384017944336, -56.0307998657227, 10499).
airport('MVD', 'Montevideo, Carrasco International /General C L Berisso Airport', 105, -34.8384017944336, -56.0307998657227, 9999).
airport('MVD', 'Montevideo, Carrasco International /General C L Berisso Airport', 105, -34.8384017944336, -56.0307998657227, 9499).
airport('GIG', 'Rio de Janeiro ,Galeao Antonio Carlos Jobim International Airport', 28, -22.8099994659, -43.2505569458, 13123).
airport('GIG', 'Rio de Janeiro ,Galeao Antonio Carlos Jobim International Airport', 28, -22.8099994659, -43.2505569458, 12623).
airport('GRU', 'Sao Paulo, Guarulhos - Governador Andras Franco Montoro International Airport', 2459, -23.4355564117432, -46.4730567932129, 12139).
airport('EZE', 'Buenos Aires, Ministro Pistarini International Airport', 67, -34.8222, -58.5358, 10187).
airport('EZE', 'Buenos Aires, Ministro Pistarini International Airport', 67, -34.8222, -58.5358, 9687).
airport('LIM', 'Lima, Jorge Chavez International Airport', 113, -12.021900177, -77.1143035889, 11506).
airport('SCL', 'Santiago, Comodoro Arturo Merino Benitez International Airport', 1555, -33.3930015563965, -70.7857971191406, 12203).
airport('SCL', 'Santiago, Comodoro Arturo Merino Benitez International Airport', 1555, -33.3930015563965, -70.7857971191406, 11703).
airport('MEX', 'Mexico City, Licenciado Benito Juarez International Airport', 7316, 19.43630027771, -99.0720977783203, 12966).
airport('MEX', 'Mexico City, Licenciado Benito Juarez International Airport', 7316, 19.43630027771, -99.0720977783203, 12466).
airport('KIN', 'Kingston, Norman Manley International Airport', 10, 17.9356994628906, -76.7874984741211, 8900).
airport('TLH', 'Tallahassee Regional Airport', 81, 30.3964996337891, -84.3503036499023, 8000).
airport('TLH', 'Tallahassee Regional Airport', 81, 30.3964996337891, -84.3503036499023, 7500).
airport('LCA', 'Larnaca International Airport', 8, 34.8750991821289, 33.6249008178711, 9776).
airport('WAW', 'Warsaw Chopin Airport', 362, 52.1656990051, 20.9671001434, 12106).
airport('WAW', 'Warsaw Chopin Airport', 362, 52.1656990051, 20.9671001434, 11606).
airport('MLA', 'Malta International Airport', 300, 35.857498, 14.4775, 11627).
airport('MLA', 'Malta International Airport', 300, 35.857498, 14.4775, 11127).
airport('SOF', 'Sofia Airport', 1742, 42.6966934204102, 23.4114360809326, 9186).
airport('BEG', 'Belgrade Nikola Tesla Airport', 335, 44.8184013367, 20.3090991974, 11155).
airport('CAI', 'Cairo International Airport', 382, 30.1219005584717, 31.4055995941162, 13124).
airport('CAI', 'Cairo International Airport', 382, 30.1219005584717, 31.4055995941162, 12624).
airport('CAI', 'Cairo International Airport', 382, 30.1219005584717, 31.4055995941162, 12124).
airport('ADD', 'Addis Ababa Bole International Airport', 7630, 8.97789001465, 38.7993011475, 12467).
airport('ADD', 'Addis Ababa Bole International Airport', 7630, 8.97789001465, 38.7993011475, 11967).
airport('TLV', 'Tel Aviv, Ben Gurion International Airport', 135, 32.0113983154297, 34.8866996765137, 13327).
airport('TLV', 'Tel Aviv, Ben Gurion International Airport', 135, 32.0113983154297, 34.8866996765137, 12827).
airport('TLV', 'Tel Aviv, Ben Gurion International Airport', 135, 32.0113983154297, 34.8866996765137, 12327).
airport('PIT', 'Pittsburgh International Airport', 1203, 40.49150085, -80.23290253, 11500).
airport('PIT', 'Pittsburgh International Airport', 1203, 40.49150085, -80.23290253, 11000).
airport('PIT', 'Pittsburgh International Airport', 1203, 40.49150085, -80.23290253, 10500).
airport('PIT', 'Pittsburgh International Airport', 1203, 40.49150085, -80.23290253, 10000).
airport('PWM', 'Portland International Jetport Airport', 76, 43.64619827, -70.30930328, 7200).
airport('PWM', 'Portland International Jetport Airport', 76, 43.64619827, -70.30930328, 6700).
airport('PDX', 'Portland International Airport', 31, 45.58869934, -122.5979996, 11000).
airport('PDX', 'Portland International Airport', 31, 45.58869934, -122.5979996, 10500).
airport('PDX', 'Portland International Airport', 31, 45.58869934, -122.5979996, 10000).
airport('OKC', 'Oaklahoma City, Will Rogers World Airport', 1295, 35.3931007385254, -97.600700378418, 9800).
airport('OKC', 'Oaklahoma City, Will Rogers World Airport', 1295, 35.3931007385254, -97.600700378418, 9300).
airport('OKC', 'Oaklahoma City, Will Rogers World Airport', 1295, 35.3931007385254, -97.600700378418, 8800).
airport('OKC', 'Oaklahoma City, Will Rogers World Airport', 1295, 35.3931007385254, -97.600700378418, 8300).
airport('ONT', 'Ontario International Airport', 944, 34.0559997558594, -117.600997924805, 12198).
airport('ONT', 'Ontario International Airport', 944, 34.0559997558594, -117.600997924805, 11698).
airport('ROC', 'Greater Rochester International Airport', 559, 43.1189002990723, -77.6724014282227, 8001).
airport('ROC', 'Greater Rochester International Airport', 559, 43.1189002990723, -77.6724014282227, 7501).
airport('ROC', 'Greater Rochester International Airport', 559, 43.1189002990723, -77.6724014282227, 7001).
airport('RST', 'Rochester International Airport', 1317, 43.9082984924316, -92.5, 9033).
airport('RST', 'Rochester International Airport', 1317, 43.9082984924316, -92.5, 8533).
airport('KWI', 'Kuwait International Airport', 206, 29.2266006469727, 47.9688987731934, 11483).
airport('KWI', 'Kuwait International Airport', 206, 29.2266006469727, 47.9688987731934, 10983).
airport('PNH', 'Phnom Penh International Airport', 40, 11.5466003417969, 104.84400177002, 9843).
airport('AYQ', 'Ayers Rock Connellan Airport', 1626, -25.1861000061035, 130.975997924805, 8527).
airport('ASP', 'Alice Springs Airport', 1789, -23.8066997528076, 133.901992797852, 7999).
airport('ASP', 'Alice Springs Airport', 1789, -23.8066997528076, 133.901992797852, 7499).
airport('OOL', 'Gold Coast Airport', 21, -28.1644001007, 153.505004883, 6699).
airport('OOL', 'Gold Coast Airport', 21, -28.1644001007, 153.505004883, 6199).
airport('FAI', 'Fairbanks International Airport', 439, 64.81510162, -147.8560028, 11800).
airport('FAI', 'Fairbanks International Airport', 439, 64.81510162, -147.8560028, 11300).
airport('FAI', 'Fairbanks International Airport', 439, 64.81510162, -147.8560028, 10800).
airport('FAI', 'Fairbanks International Airport', 439, 64.81510162, -147.8560028, 10300).
airport('CNS', 'Cairns International Airport', 10, -16.885799408, 145.755004883, 10489).
airport('CNS', 'Cairns International Airport', 10, -16.885799408, 145.755004883, 9989).
airport('IST', 'Istanbul International Airport', 325, 41.275278, 28.751944, 13451).
airport('IST', 'Istanbul International Airport', 325, 41.275278, 28.751944, 12951).
airport('IST', 'Istanbul International Airport', 325, 41.275278, 28.751944, 12451).
airport('IST', 'Istanbul International Airport', 325, 41.275278, 28.751944, 11951).
airport('BAH', 'Bahrain International Airport', 6, 26.2707996368408, 50.6335983276367, 12979).
airport('BAH', 'Bahrain International Airport', 6, 26.2707996368408, 50.6335983276367, 12479).
airport('YHZ', 'Halifax / Stanfield International Airport', 477, 44.8807983398, -63.5085983276, 10500).
airport('YHZ', 'Halifax / Stanfield International Airport', 477, 44.8807983398, -63.5085983276, 10000).
airport('AUH', 'Abu Dhabi International Airport', 88, 24.4330005645752, 54.6511001586914, 13452).
airport('AUH', 'Abu Dhabi International Airport', 88, 24.4330005645752, 54.6511001586914, 12952).
airport('SGN', 'Ho Chi Minh City, Tan Son Nhat International Airport', 33, 10.8187999725, 106.652000427, 12468).
airport('SGN', 'Ho Chi Minh City, Tan Son Nhat International Airport', 33, 10.8187999725, 106.652000427, 11968).
airport('YWG', 'Winnipeg / James Armstrong Richardson International Airport', 783, 49.9099998474, -97.2398986816, 11000).
airport('YWG', 'Winnipeg / James Armstrong Richardson International Airport', 783, 49.9099998474, -97.2398986816, 10500).
airport('YWG', 'Winnipeg / James Armstrong Richardson International Airport', 783, 49.9099998474, -97.2398986816, 10000).
airport('HAM', 'Hamburg Airport', 53, 53.6304016113281, 9.98822975158691, 12028).
airport('HAM', 'Hamburg Airport', 53, 53.6304016113281, 9.98822975158691, 11528).
airport('STR', 'Stuttgart Airport', 1276, 48.6898994446, 9.22196006775, 10974).
airport('GOA', 'Genoa Cristoforo Colombo Airport', 13, 44.4132995605, 8.83749961853, 9564).
airport('NAP', 'Naples International Airport', 294, 40.8860015869, 14.2908000946, 8622).
airport('PSA', 'Pisa International Airport', 6, 43.6838989258, 10.3927001953, 9820).
airport('PSA', 'Pisa International Airport', 6, 43.6838989258, 10.3927001953, 9320).
airport('TRN', 'Turin Airport', 989, 45.2008018494, 7.64963006973, 10827).
airport('BLQ', 'Bologna Guglielmo Marconi Airport', 123, 44.5354003906, 11.2887001038, 9186).
airport('TSF', 'Venice, Treviso-Sant Angelo Airport', 59, 45.648399353, 12.1943998337, 7941).
airport('VRN', 'Verona Villafranca Airport', 239, 45.3956985474, 10.8885002136, 10064).
airport('NTE', 'Nantes Atlantique Airport', 90, 47.1531982422, -1.61073005199, 9514).
airport('CPH', 'Copenhagen Kastrup Airport', 17, 55.6179008483887, 12.6560001373291, 11811).
airport('CPH', 'Copenhagen Kastrup Airport', 17, 55.6179008483887, 12.6560001373291, 11311).
airport('CPH', 'Copenhagen Kastrup Airport', 17, 55.6179008483887, 12.6560001373291, 10811).
airport('CLT', 'Charlotte Douglas International Airport', 748, 35.2140007019043, -80.9430999755859, 10000).
airport('CLT', 'Charlotte Douglas International Airport', 748, 35.2140007019043, -80.9430999755859, 9500).
airport('CLT', 'Charlotte Douglas International Airport', 748, 35.2140007019043, -80.9430999755859, 9000).
airport('CLT', 'Charlotte Douglas International Airport', 748, 35.2140007019043, -80.9430999755859, 8500).
airport('LUX', 'Luxembourg-Findel International Airport', 1234, 49.6265983581543, 6.21152019500732, 13123).
airport('CUN', 'Cancun International Airport', 22, 21.0365009308, -86.8770980835, 11483).
airport('CUN', 'Cancun International Airport', 22, 21.0365009308, -86.8770980835, 10983).
airport('PSP', 'Palm Springs International Airport', 477, 33.8297004699707, -116.50700378418, 10000).
airport('PSP', 'Palm Springs International Airport', 477, 33.8297004699707, -116.50700378418, 9500).
airport('MEM', 'Memphis International Airport', 341, 35.0424003601074, -89.9766998291016, 11120).
airport('MEM', 'Memphis International Airport', 341, 35.0424003601074, -89.9766998291016, 10620).
airport('MEM', 'Memphis International Airport', 341, 35.0424003601074, -89.9766998291016, 10120).
airport('MEM', 'Memphis International Airport', 341, 35.0424003601074, -89.9766998291016, 9620).
airport('CVG', 'Cincinnati Northern Kentucky International Airport', 896, 39.0488014221, -84.6678009033, 12000).
airport('CVG', 'Cincinnati Northern Kentucky International Airport', 896, 39.0488014221, -84.6678009033, 11500).
airport('CVG', 'Cincinnati Northern Kentucky International Airport', 896, 39.0488014221, -84.6678009033, 11000).
airport('CVG', 'Cincinnati Northern Kentucky International Airport', 896, 39.0488014221, -84.6678009033, 10500).
airport('IND', 'Indianapolis International Airport', 797, 39.7173004150391, -86.2944030761719, 11200).
airport('IND', 'Indianapolis International Airport', 797, 39.7173004150391, -86.2944030761719, 10700).
airport('IND', 'Indianapolis International Airport', 797, 39.7173004150391, -86.2944030761719, 10200).
airport('MCI', 'Kansas City International Airport', 1026, 39.2975997924805, -94.7138977050781, 10801).
airport('MCI', 'Kansas City International Airport', 1026, 39.2975997924805, -94.7138977050781, 10301).
airport('MCI', 'Kansas City International Airport', 1026, 39.2975997924805, -94.7138977050781, 9801).
airport('DAL', 'Dallas Love Field', 487, 32.8470993041992, -96.8517990112305, 8800).
airport('DAL', 'Dallas Love Field', 487, 32.8470993041992, -96.8517990112305, 8300).
airport('DAL', 'Dallas Love Field', 487, 32.8470993041992, -96.8517990112305, 7800).
airport('STL', 'Lambert St Louis International Airport', 618, 38.7486991882324, -90.370002746582, 11019).
airport('STL', 'Lambert St Louis International Airport', 618, 38.7486991882324, -90.370002746582, 10519).
airport('STL', 'Lambert St Louis International Airport', 618, 38.7486991882324, -90.370002746582, 10019).
airport('STL', 'Lambert St Louis International Airport', 618, 38.7486991882324, -90.370002746582, 9519).
airport('ABQ', 'Albuquerque International Sunport Airport', 5355, 35.0401992797852, -106.609001159668, 13793).
airport('ABQ', 'Albuquerque International Sunport Airport', 5355, 35.0401992797852, -106.609001159668, 13293).
airport('ABQ', 'Albuquerque International Sunport Airport', 5355, 35.0401992797852, -106.609001159668, 12793).
airport('ABQ', 'Albuquerque International Sunport Airport', 5355, 35.0401992797852, -106.609001159668, 12293).
airport('MKE', 'General Mitchell International Airport', 723, 42.9472007751465, -87.896598815918, 9690).
airport('MKE', 'General Mitchell International Airport', 723, 42.9472007751465, -87.896598815918, 9190).
airport('MKE', 'General Mitchell International Airport', 723, 42.9472007751465, -87.896598815918, 8690).
airport('MKE', 'General Mitchell International Airport', 723, 42.9472007751465, -87.896598815918, 8190).
airport('MKE', 'General Mitchell International Airport', 723, 42.9472007751465, -87.896598815918, 7690).
airport('MDW', 'Chicago Midway International Airport', 620, 41.7859992980957, -87.7524032592773, 6522).
airport('MDW', 'Chicago Midway International Airport', 620, 41.7859992980957, -87.7524032592773, 6022).
airport('MDW', 'Chicago Midway International Airport', 620, 41.7859992980957, -87.7524032592773, 5522).
airport('MDW', 'Chicago Midway International Airport', 620, 41.7859992980957, -87.7524032592773, 5022).
airport('MDW', 'Chicago Midway International Airport', 620, 41.7859992980957, -87.7524032592773, 4522).
airport('HRO', 'Harrison, Boone County Airport', 1365, 36.2615013122559, -93.1547012329102, 6161).
airport('SLN', 'Salina Municipal Airport', 1288, 38.7910003662109, -97.6521987915039, 12300).
airport('SLN', 'Salina Municipal Airport', 1288, 38.7910003662109, -97.6521987915039, 11800).
airport('SLN', 'Salina Municipal Airport', 1288, 38.7910003662109, -97.6521987915039, 11300).
airport('SLN', 'Salina Municipal Airport', 1288, 38.7910003662109, -97.6521987915039, 10800).
airport('OMA', 'Eppley Airfield', 984, 41.3031997680664, -95.8940963745117, 9502).
airport('OMA', 'Eppley Airfield', 984, 41.3031997680664, -95.8940963745117, 9002).
airport('OMA', 'Eppley Airfield', 984, 41.3031997680664, -95.8940963745117, 8502).
airport('TUL', 'Tulsa International Airport', 677, 36.1983985900879, -95.8880996704102, 9999).
airport('TUL', 'Tulsa International Airport', 677, 36.1983985900879, -95.8880996704102, 9499).
airport('TUL', 'Tulsa International Airport', 677, 36.1983985900879, -95.8880996704102, 8999).
airport('PVR', 'Puerto Vallarta, Licenciado Gustavo Diaz Ordaz International Airport', 23, 20.6800994873047, -105.253997802734, 10171).
airport('OGG', 'Maui, Kahului Airport', 54, 20.8985996246338, -156.429992675781, 6995).
airport('OGG', 'Maui, Kahului Airport', 54, 20.8985996246338, -156.429992675781, 6495).
airport('MCY', 'Sunshine Coast Airport', 15, -26.6033000946, 153.091003418, 5896).
airport('MCY', 'Sunshine Coast Airport', 15, -26.6033000946, 153.091003418, 5396).
airport('DUS', 'Dusseldorf International Airport', 147, 51.2895011901855, 6.76677989959717, 9842).
airport('DUS', 'Dusseldorf International Airport', 147, 51.2895011901855, 6.76677989959717, 9342).
airport('GUM', 'Antonio B. Won Pat International Airport', 298, 13.4834003448, 144.796005249, 10015).
airport('GUM', 'Antonio B. Won Pat International Airport', 298, 13.4834003448, 144.796005249, 9515).
airport('TXL', 'Berlin, Tegel International Airport *Closed*', 122, 52.5597000122, 13.2876996994, 9918).
airport('TXL', 'Berlin, Tegel International Airport *Closed*', 122, 52.5597000122, 13.2876996994, 9418).
airport('CMB', 'Colombo, Bandaranaike International Airport', 30, 7.1807599067688, 79.8841018676758, 10991).
airport('LIS', 'Lisbon Portela Airport', 374, 38.7812995911, -9.13591957092, 12484).
airport('GIB', 'Gibraltar Airport', 15, 36.1511993408, -5.34965991974, 6000).
airport('TUN', 'Tunis Carthage International Airport', 22, 36.851001739502, 10.2271995544434, 10499).
airport('TUN', 'Tunis Carthage International Airport', 22, 36.851001739502, 10.2271995544434, 9999).
airport('TPE', 'Taiwan Taoyuan International Airport', 106, 25.0776996612549, 121.233001708984, 12008).
airport('TPE', 'Taiwan Taoyuan International Airport', 106, 25.0776996612549, 121.233001708984, 11508).
airport('LTN', 'London Luton Airport', 526, 51.874698638916, -0.368333011865616, 7086).
airport('KTM', 'Kathmandu, Tribhuvan International Airport', 4390, 27.6965999603, 85.3591003418, 10007).
airport('NAS', 'Nassau, Lynden Pindling International Airport', 16, 25.0389995575, -77.4662017822, 11353).
airport('NAS', 'Nassau, Lynden Pindling International Airport', 16, 25.0389995575, -77.4662017822, 10853).
airport('FPO', 'Freeport, Grand Bahama International Airport', 7, 26.5587005615, -78.695602417, 11019).
airport('GGT', 'George Town, Exuma International Airport', 9, 23.5625991821, -75.8779983521, 7051).
airport('EYW', 'Key West International Airport', 3, 24.5561008453369, -81.7595977783203, 4801).
airport('FUK', 'Fukuoka Airport', 32, 33.5858993530273, 130.45100402832, 9186).
airport('KIX', 'Osaka, Kansai International Airport', 26, 34.4272994995117, 135.244003295898, 13123).
airport('KIX', 'Osaka, Kansai International Airport', 26, 34.4272994995117, 135.244003295898, 12623).
airport('CTS', 'Sapporo, New Chitose Airport', 82, 42.7751998901367, 141.692001342773, 9840).
airport('CTS', 'Sapporo, New Chitose Airport', 82, 42.7751998901367, 141.692001342773, 9340).
airport('JED', 'King Abdulaziz International Airport', 48, 21.679599762, 39.15650177, 13123).
airport('JED', 'King Abdulaziz International Airport', 48, 21.679599762, 39.15650177, 12623).
airport('JED', 'King Abdulaziz International Airport', 48, 21.679599762, 39.15650177, 12123).
airport('MCT', 'Muscat International Airport', 48, 23.5932998657227, 58.2844009399414, 11775).
airport('MCT', 'Muscat International Airport', 48, 23.5932998657227, 58.2844009399414, 11275).
airport('KEF', 'Reykjavik, Keflavik International Airport', 171, 63.9850006103516, -22.6056003570557, 10056).
airport('KEF', 'Reykjavik, Keflavik International Airport', 171, 63.9850006103516, -22.6056003570557, 9556).
airport('BGI', 'Bridgetown, Sir Grantley Adams International Airport', 169, 13.0746002197, -59.4925003052, 11000).
airport('ANU', 'V.C. Bird International Airport', 62, 17.1367, -61.792702, 9003).
airport('STT', 'St. Thomas, Cyril E. King Airport', 23, 18.3372993469238, -64.9733963012695, 7000).
airport('BDA', 'Bermuda, L.F. Wade International International Airport', 12, 32.3639984130859, -64.6787033081055, 9713).
airport('TAB', 'Tobago-Crown Point Airport', 38, 11.1497001647949, -60.8321990966797, 9002).
airport('POS', 'Port of Spain, Piarco International Airport', 58, 10.5953998565674, -61.3372001647949, 10500).
airport('LOS', 'Lagos,Murtala Muhammed International Airport', 135, 6.57737016677856, 3.32116007804871, 11153).
airport('MBJ', 'Montego Bay, Sangster International Airport', 4, 18.5037002563477, -77.9133987426758, 8735).
airport('HRE', 'Harare International Airport', 4887, -17.9318008422852, 31.0928001403809, 15502).
airport('LIT', 'Little Rock, Bill and Hillary Clinton National Airport/Adams Field', 262, 34.7294006348, -92.2242965698, 8273).
airport('LIT', 'Little Rock, Bill and Hillary Clinton National Airport/Adams Field', 262, 34.7294006348, -92.2242965698, 7773).
airport('LIT', 'Little Rock, Bill and Hillary Clinton National Airport/Adams Field', 262, 34.7294006348, -92.2242965698, 7273).
airport('LPA', 'Gran Canaria Airport', 78, 27.9319000244141, -15.3865995407104, 10171).
airport('LPA', 'Gran Canaria Airport', 78, 27.9319000244141, -15.3865995407104, 9671).
airport('SOU', 'Southampton Airport', 44, 50.9502983093262, -1.35679996013641, 5653).
airport('PMI', 'Palma De Mallorca Airport', 27, 39.551700592, 2.73881006241, 10728).
airport('PMI', 'Palma De Mallorca Airport', 27, 39.551700592, 2.73881006241, 10228).
airport('ADL', 'Adelaide International Airport', 20, -34.9449996948242, 138.531005859375, 10171).
airport('ADL', 'Adelaide International Airport', 20, -34.9449996948242, 138.531005859375, 9671).
airport('DRW', 'Darwin International Airport', 103, -12.4146995544434, 130.876998901367, 11004).
airport('DRW', 'Darwin International Airport', 103, -12.4146995544434, 130.876998901367, 10504).
airport('CUR', 'Curacao, Hato International Airport', 29, 12.1888999939, -68.9598007202, 11188).
airport('DPS', 'Bali - Ngurah Rai International Airport', 14, -8.74816989898682, 115.166999816895, 9790).
airport('DPS', 'Bali - Ngurah Rai International Airport', 14, -8.74816989898682, 115.166999816895, 9290).
airport('CGK', 'Soekarno-Hatta International Airport', 34, -6.1255698204, 106.65599823, 12008).
airport('CGK', 'Soekarno-Hatta International Airport', 34, -6.1255698204, 106.65599823, 11508).
airport('BON', 'Bonaire, Flamingo International Airport', 20, 12.1309995651245, -68.2685012817383, 9449).
airport('AUA', 'Aruba, Queen Beatrix International Airport', 60, 12.5013999938965, -70.0151977539062, 9000).
airport('ORF', 'Norfolk International Airport', 26, 36.8945999145508, -76.2012023925781, 9001).
airport('ORF', 'Norfolk International Airport', 26, 36.8945999145508, -76.2012023925781, 8501).
airport('JAX', 'Jacksonville International Airport', 30, 30.4941005706787, -81.6878967285156, 10000).
airport('JAX', 'Jacksonville International Airport', 30, 30.4941005706787, -81.6878967285156, 9500).
airport('PVD', 'Providence, Theodore Francis Green State Airport', 55, 41.7326011657715, -71.4204025268555, 7166).
airport('PVD', 'Providence, Theodore Francis Green State Airport', 55, 41.7326011657715, -71.4204025268555, 6666).
airport('PUJ', 'Punta Cana International Airport', 47, 18.5673999786, -68.3634033203, 10171).
airport('MDT', 'Harrisburg International Airport', 310, 40.1935005188, -76.7633972168, 10001).
airport('MDT', 'Harrisburg International Airport', 310, 40.1935005188, -76.7633972168, 9501).
airport('SJO', 'San Jose, Juan Santamaria International Airport', 3021, 9.99386024475098, -84.2088012695312, 9882).
airport('SMF', 'Sacramento International Airport', 27, 38.6954002380371, -121.591003417969, 8601).
airport('SMF', 'Sacramento International Airport', 27, 38.6954002380371, -121.591003417969, 8101).
airport('RTB', 'Coxen Hole, Juan Manuel Galvez International Airport', 18, 16.3167991638184, -86.5230026245117, 7349).
airport('TGU', 'Tegucigalpa, Toncontin International Airport', 3294, 14.0608997344971, -87.2172012329102, 6112).
airport('LXR', 'Luxor International Airport', 294, 25.670999527, 32.7066001892, 9843).
airport('RIX', 'Riga International Airport', 36, 56.9235992431641, 23.9710998535156, 10499).
airport('RUH', 'Riyadh, King Khaled International Airport', 2049, 24.9575996398926, 46.6987991333008, 13796).
airport('RUH', 'Riyadh, King Khaled International Airport', 2049, 24.9575996398926, 46.6987991333008, 13296).
airport('CAN', 'Guangzhou Baiyun International Airport', 50, 23.3924007415771, 113.299003601074, 12467).
airport('CAN', 'Guangzhou Baiyun International Airport', 50, 23.3924007415771, 113.299003601074, 11967).
airport('AGP', 'Malaga Airport', 53, 36.6749000549316, -4.49911022186279, 10500).
airport('AGP', 'Malaga Airport', 53, 36.6749000549316, -4.49911022186279, 10000).
airport('FNC', 'Funchal, Madeira Airport', 192, 32.6978988647461, -16.7744998931885, 9110).
airport('LBA', 'Leeds Bradford Airport', 681, 53.8658981323242, -1.66057002544403, 7382).
airport('ABZ', 'Aberdeen Dyce Airport', 215, 57.2019004821777, -2.19777989387512, 6001).
airport('ABZ', 'Aberdeen Dyce Airport', 215, 57.2019004821777, -2.19777989387512, 5501).
airport('ABZ', 'Aberdeen Dyce Airport', 215, 57.2019004821777, -2.19777989387512, 5001).
airport('ABZ', 'Aberdeen Dyce Airport', 215, 57.2019004821777, -2.19777989387512, 4501).
airport('AYT', 'Antalya International Airport', 177, 36.8987007141113, 30.800500869751, 11155).
airport('AYT', 'Antalya International Airport', 177, 36.8987007141113, 30.800500869751, 10655).
airport('AYT', 'Antalya International Airport', 177, 36.8987007141113, 30.800500869751, 10155).
airport('ISB', 'Islamabad, Benazir Bhutto International Airport', 1668, 33.61669921875, 73.0991973876953, 10785).
airport('JER', 'Jersey Airport', 277, 49.2079010009766, -2.1955099105835, 5597).
airport('ZTH', 'Zakynthos, Dionysios Solomos Airport', 15, 37.7509002685547, 20.8843002319336, 7310).
airport('RHO', 'Rhodes, Diagoras Airport', 17, 36.4053993225098, 28.0862007141113, 10846).
airport('BRS', 'Bristol International Airport', 622, 51.3827018737793, -2.7190899848938, 6598).
airport('NCL', 'Newcastle Airport', 266, 55.0374984741211, -1.69166994094849, 7642).
airport('GCI', 'Guernsey Airport', 336, 49.435001373291, -2.60196995735168, 4800).
airport('COS', 'City of Colorado Springs Municipal Airport', 6187, 38.8058013916016, -104.700996398926, 13501).
airport('COS', 'City of Colorado Springs Municipal Airport', 6187, 38.8058013916016, -104.700996398926, 13001).
airport('COS', 'City of Colorado Springs Municipal Airport', 6187, 38.8058013916016, -104.700996398926, 12501).
airport('HSV', 'Huntsville International Carl T Jones Field', 629, 34.6371994018555, -86.7751007080078, 12600).
airport('HSV', 'Huntsville International Carl T Jones Field', 629, 34.6371994018555, -86.7751007080078, 12100).
airport('BHM', 'Birmingham-Shuttlesworth International Airport', 650, 33.56290054, -86.75350189, 10000).
airport('BHM', 'Birmingham-Shuttlesworth International Airport', 650, 33.56290054, -86.75350189, 9500).
airport('YQB', 'Quebec Jean Lesage International Airport', 244, 46.7910995483, -71.3933029175, 9000).
airport('YQB', 'Quebec Jean Lesage International Airport', 244, 46.7910995483, -71.3933029175, 8500).
airport('RAP', 'Rapid City Regional Airport', 3204, 44.0452995300293, -103.056999206543, 8701).
airport('RAP', 'Rapid City Regional Airport', 3204, 44.0452995300293, -103.056999206543, 8201).
airport('SDF', 'Louisville International Standiford Field', 501, 38.1744003295898, -85.7360000610352, 10850).
airport('SDF', 'Louisville International Standiford Field', 501, 38.1744003295898, -85.7360000610352, 10350).
airport('SDF', 'Louisville International Standiford Field', 501, 38.1744003295898, -85.7360000610352, 9850).
airport('BUF', 'Buffalo Niagara International Airport', 728, 42.94049835, -78.73220062, 8102).
airport('BUF', 'Buffalo Niagara International Airport', 728, 42.94049835, -78.73220062, 7602).
airport('SHV', 'Shreveport Regional Airport', 258, 32.4466018676758, -93.8255996704102, 8351).
airport('SHV', 'Shreveport Regional Airport', 258, 32.4466018676758, -93.8255996704102, 7851).
airport('BOI', 'Boise Air Terminal/Gowen field', 2871, 43.56439972, -116.2229996, 10000).
airport('BOI', 'Boise Air Terminal/Gowen field', 2871, 43.56439972, -116.2229996, 9500).
airport('BOI', 'Boise Air Terminal/Gowen field', 2871, 43.56439972, -116.2229996, 9000).
airport('LIH', 'Kuai, Lihue Airport', 153, 21.9759998321533, -159.339004516602, 6500).
airport('LIH', 'Kuai, Lihue Airport', 153, 21.9759998321533, -159.339004516602, 6000).
airport('LBB', 'Lubbock Preston Smith International Airport', 3282, 33.6636009216309, -101.822998046875, 11500).
airport('LBB', 'Lubbock Preston Smith International Airport', 3282, 33.6636009216309, -101.822998046875, 11000).
airport('LBB', 'Lubbock Preston Smith International Airport', 3282, 33.6636009216309, -101.822998046875, 10500).
airport('EIN', 'Eindhoven Airport', 74, 51.4500999451, 5.37452983856, 9843).
airport('SVQ', 'Sevilla Airport', 112, 37.4179992675781, -5.8931097984314, 11024).
airport('BSL', 'EuroAirport Basle-Mulhouse-Freiburg Airport (BSL/MLH/EAP)', 885, 47.5895996094, 7.52991008759, 12795).
airport('BSL', 'EuroAirport Basle-Mulhouse-Freiburg Airport (BSL/MLH/EAP)', 885, 47.5895996094, 7.52991008759, 12295).
airport('ECP', 'Northwest Florida Beaches International Airport', 69, 30.3417, -85.7973, 10000).
airport('HRL', 'Harlingen, Valley International Airport', 36, 26.2285003662109, -97.6544036865234, 8301).
airport('HRL', 'Harlingen, Valley International Airport', 36, 26.2285003662109, -97.6544036865234, 7801).
airport('HRL', 'Harlingen, Valley International Airport', 36, 26.2285003662109, -97.6544036865234, 7301).
airport('DBV', 'Dubrovnik Airport', 527, 42.5614013671875, 18.2681999206543, 10827).
airport('RNO', 'Reno Taoe International Airport', 4415, 39.4990997314453, -119.767997741699, 11002).
airport('RNO', 'Reno Taoe International Airport', 4415, 39.4990997314453, -119.767997741699, 10502).
airport('RNO', 'Reno Taoe International Airport', 4415, 39.4990997314453, -119.767997741699, 10002).
airport('CMH', 'Columbus, Port Columbus International Airport', 815, 39.9980010986328, -82.8918991088867, 10125).
airport('CMH', 'Columbus, Port Columbus International Airport', 815, 39.9980010986328, -82.8918991088867, 9625).
airport('IDA', 'Idaho Falls Regional Airport', 4744, 43.5145988464355, -112.070999145508, 9002).
airport('IDA', 'Idaho Falls Regional Airport', 4744, 43.5145988464355, -112.070999145508, 8502).
airport('ALB', 'Albany International Airport', 285, 42.7482986450195, -73.8016967773438, 7200).
airport('ALB', 'Albany International Airport', 285, 42.7482986450195, -73.8016967773438, 6700).
airport('SVG', 'Stavanger Airport', 29, 58.8767013549805, 5.63778018951416, 9369).
airport('SVG', 'Stavanger Airport', 29, 58.8767013549805, 5.63778018951416, 8869).
airport('HKT', 'Phuket International Airport', 82, 8.11320018768, 98.3169021606, 9843).
airport('AMM', 'Queen Alia International Airport', 2395, 31.7226009369, 35.9931983948, 12008).
airport('AMM', 'Queen Alia International Airport', 2395, 31.7226009369, 35.9931983948, 11508).
airport('BGO', 'Bergen Airport Flesland', 170, 60.293399810791, 5.21814012527466, 9810).
airport('ICT', 'Wichita Mid Continent Airport', 1333, 37.6498985290527, -97.4330978393555, 10301).
airport('ICT', 'Wichita Mid Continent Airport', 1333, 37.6498985290527, -97.4330978393555, 9801).
airport('ICT', 'Wichita Mid Continent Airport', 1333, 37.6498985290527, -97.4330978393555, 9301).
airport('MAF', 'Midland International Airport', 2871, 31.9424991607666, -102.202003479004, 9501).
airport('MAF', 'Midland International Airport', 2871, 31.9424991607666, -102.202003479004, 9001).
airport('MAF', 'Midland International Airport', 2871, 31.9424991607666, -102.202003479004, 8501).
airport('MAF', 'Midland International Airport', 2871, 31.9424991607666, -102.202003479004, 8001).
airport('YXE', 'Saskatoon John G. Diefenbaker International Airport', 1653, 52.1707992553711, -106.699996948242, 8300).
airport('YXE', 'Saskatoon John G. Diefenbaker International Airport', 1653, 52.1707992553711, -106.699996948242, 7800).
airport('BDL', 'Bradley International Airport', 173, 41.9388999939, -72.6831970215, 9510).
airport('BDL', 'Bradley International Airport', 173, 41.9388999939, -72.6831970215, 9010).
airport('BDL', 'Bradley International Airport', 173, 41.9388999939, -72.6831970215, 8510).
airport('BIL', 'Billings Logan International Airport', 3652, 45.8077011108398, -108.542999267578, 10518).
airport('BIL', 'Billings Logan International Airport', 3652, 45.8077011108398, -108.542999267578, 10018).
airport('BIL', 'Billings Logan International Airport', 3652, 45.8077011108398, -108.542999267578, 9518).
airport('SXM', 'Sint Martin, Princess Juliana International Airport', 13, 18.0410003662, -63.1088981628, 7708).
airport('SXM', 'Sint Martin, Princess Juliana International Airport', 13, 18.0410003662, -63.1088981628, 7208).
airport('NAN', 'Fiji, Nadi International Airport', 59, -17.7553997039795, 177.442993164062, 10739).
airport('NAN', 'Fiji, Nadi International Airport', 59, -17.7553997039795, 177.442993164062, 10239).
airport('SGF', 'Springfield Branson National Airport', 1268, 37.24570084, -93.38860321, 8000).
airport('SGF', 'Springfield Branson National Airport', 1268, 37.24570084, -93.38860321, 7500).
airport('RIC', 'Richmond International Airport', 167, 37.505199432373, -77.3197021484375, 9003).
airport('RIC', 'Richmond International Airport', 167, 37.505199432373, -77.3197021484375, 8503).
airport('RIC', 'Richmond International Airport', 167, 37.505199432373, -77.3197021484375, 8003).
airport('CCS', 'Simon Bolivar International Airport', 235, 10.6031169891, -66.9905853271, 11483).
airport('CCS', 'Simon Bolivar International Airport', 235, 10.6031169891, -66.9905853271, 10983).
airport('GYE', 'Jose Joaquin de Olmedo International Airport', 19, -2.15741991997, -79.8835983276, 9154).
airport('NKG', 'Nanjing Lukou Airport', 49, 31.742000579834, 118.861999511719, 11811).
airport('TXK', 'Texarkana Regional Webb Field', 390, 33.4537010192871, -93.9909973144531, 6601).
airport('TXK', 'Texarkana Regional Webb Field', 390, 33.4537010192871, -93.9909973144531, 6101).
airport('PIA', 'General Wayne A. Downing Peoria International Airport', 660, 40.6641998291, -89.6932983398, 10104).
airport('PIA', 'General Wayne A. Downing Peoria International Airport', 660, 40.6641998291, -89.6932983398, 9604).
airport('TLL', 'Tallinn Airport', 131, 59.4132995605, 24.8327999115, 10072).
airport('ALG', 'Algiers, Houari Boumediene Airport', 82, 36.6910018920898, 3.21540999412537, 11483).
airport('ALG', 'Algiers, Houari Boumediene Airport', 82, 36.6910018920898, 3.21540999412537, 10983).
airport('ITO', 'Hilo International Airport', 38, 19.721399307251, -155.048004150391, 9800).
airport('ITO', 'Hilo International Airport', 38, 19.721399307251, -155.048004150391, 9300).
airport('LEX', 'Blue Grass Airport', 979, 38.0364990234375, -84.6059036254883, 7003).
airport('GUA', 'La Aurora Airport', 4952, 14.5832996368408, -90.5274963378906, 9800).
airport('ISP', 'Long Island Mac Arthur Airport', 99, 40.79520035, -73.10019684, 7006).
airport('ISP', 'Long Island Mac Arthur Airport', 99, 40.79520035, -73.10019684, 6506).
airport('ISP', 'Long Island Mac Arthur Airport', 99, 40.79520035, -73.10019684, 6006).
airport('ISP', 'Long Island Mac Arthur Airport', 99, 40.79520035, -73.10019684, 5506).
airport('IAG', 'Niagara Falls International Airport', 589, 43.1072998046875, -78.9461975097656, 9829).
airport('IAG', 'Niagara Falls International Airport', 589, 43.1072998046875, -78.9461975097656, 9329).
airport('IAG', 'Niagara Falls International Airport', 589, 43.1072998046875, -78.9461975097656, 8829).
airport('SWF', 'Stewart International Airport', 491, 41.5041007995605, -74.1047973632812, 11818).
airport('SWF', 'Stewart International Airport', 491, 41.5041007995605, -74.1047973632812, 11318).
airport('BIM', 'South Bimini Airport', 10, 25.6998996735, -79.2647018433, 5430).
airport('ORK', 'Cork Airport', 502, 51.8413009643555, -8.49110984802246, 6998).
airport('ORK', 'Cork Airport', 502, 51.8413009643555, -8.49110984802246, 6498).
airport('HAV', 'Jose Marti International Airport', 210, 22.989200592041, -82.4091033935547, 13123).
airport('WRO', 'Copernicus Wroclaw Airport', 404, 51.1026992798, 16.885799408, 8202).
airport('CRP', 'Corpus Christi International Airport', 44, 27.7703990936279, -97.5011978149414, 7508).
airport('CRP', 'Corpus Christi International Airport', 44, 27.7703990936279, -97.5011978149414, 7008).
airport('KHI', 'Jinnah International Airport', 100, 24.9064998626709, 67.1607971191406, 11155).
airport('KHI', 'Jinnah International Airport', 100, 24.9064998626709, 67.1607971191406, 10655).
airport('LHE', 'Alama Iqbal International Airport', 712, 31.5216007232666, 74.4036026000977, 11024).
airport('LHE', 'Alama Iqbal International Airport', 712, 31.5216007232666, 74.4036026000977, 10524).
airport('ASB', 'Ashgabat Airport', 692, 37.9868011474609, 58.3610000610352, 12467).
airport('ASB', 'Ashgabat Airport', 692, 37.9868011474609, 58.3610000610352, 11967).
airport('ASB', 'Ashgabat Airport', 692, 37.9868011474609, 58.3610000610352, 11467).
airport('VKO', 'Vnukovo International Airport', 685, 55.5914993286, 37.2615013123, 10039).
airport('VKO', 'Vnukovo International Airport', 685, 55.5914993286, 37.2615013123, 9539).
airport('SPU', 'Split Airport', 79, 43.5388984680176, 16.2980003356934, 8366).
airport('TSE', 'Astana International Airport', 1165, 51.0222015380859, 71.4669036865234, 11484).
airport('GYD', 'Heydar Aliyev International Airport', 10, 40.4674987792969, 50.0466995239258, 10499).
airport('GYD', 'Heydar Aliyev International Airport', 10, 40.4674987792969, 50.0466995239258, 9999).
airport('JAI', 'Jaipur International Airport', 1263, 26.8241996765, 75.8122024536, 9177).
airport('JAI', 'Jaipur International Airport', 1263, 26.8241996765, 75.8122024536, 8677).
airport('ACC', 'Kotoka International Airport', 205, 5.60518980026245, -0.166786000132561, 11165).
airport('BHD', 'George Best Belfast City Airport', 15, 54.6180992126465, -5.87249994277954, 6001).
airport('EBB', 'Entebbe International Airport', 3782, 0.0423859991133213, 32.4435005187988, 12000).
airport('EBB', 'Entebbe International Airport', 3782, 0.0423859991133213, 32.4435005187988, 11500).
airport('HAJ', 'Hannover Airport', 183, 52.461101532, 9.68507957458, 12467).
airport('HAJ', 'Hannover Airport', 183, 52.461101532, 9.68507957458, 11967).
airport('HAJ', 'Hannover Airport', 183, 52.461101532, 9.68507957458, 11467).
airport('LIN', 'Linate Airport', 353, 45.445098877, 9.27674007416, 8005).
airport('LIN', 'Linate Airport', 353, 45.445098877, 9.27674007416, 7505).
airport('LYS', 'Lyon Saint-Exupery Airport', 821, 45.726398468, 5.09082984924, 11483).
airport('LYS', 'Lyon Saint-Exupery Airport', 821, 45.726398468, 5.09082984924, 10983).
airport('MRS', 'Marseille Provence Airport', 74, 43.439271922, 5.22142410278, 11483).
airport('MRS', 'Marseille Provence Airport', 74, 43.439271922, 5.22142410278, 10983).
airport('OTP', 'Henri Coanda International Airport', 314, 44.5722007751465, 26.1021995544434, 11484).
airport('OTP', 'Henri Coanda International Airport', 314, 44.5722007751465, 26.1021995544434, 10984).
airport('RTM', 'Rotterdam Airport', -15, 51.9569015503, 4.43722009659, 7218).
airport('CMN', 'Mohammed V International Airport', 656, 33.3675003051758, -7.58997011184692, 12205).
airport('CMN', 'Mohammed V International Airport', 656, 33.3675003051758, -7.58997011184692, 11705).
airport('TNG', 'Ibn Batouta Airport', 62, 35.7268981934, -5.91689014435, 11483).
airport('TNG', 'Ibn Batouta Airport', 62, 35.7268981934, -5.91689014435, 10983).
airport('ABV', 'Nnamdi Azikiwe International Airport', 1123, 9.00679016113281, 7.26316976547241, 11842).
airport('ALA', 'Almaty Airport', 2234, 43.3521003723145, 77.0404968261719, 14427).
airport('BEY', 'Beirut Rafic Hariri International Airport', 87, 33.8208999633789, 35.4883995056152, 12467).
airport('BEY', 'Beirut Rafic Hariri International Airport', 87, 33.8208999633789, 35.4883995056152, 11967).
airport('BEY', 'Beirut Rafic Hariri International Airport', 87, 33.8208999633789, 35.4883995056152, 11467).
airport('CTU', 'Chengdu Shuangliu International Airport', 1625, 30.5785007476807, 103.946998596191, 11811).
airport('FAO', 'Faro Airport', 24, 37.0144004822, -7.96590995789, 8169).
airport('FNA', 'Lungi International Airport', 84, 8.61643981933594, -13.1955003738403, 10498).
airport('JMK', 'Mikonos Airport', 405, 37.4351005554199, 25.3481006622314, 6244).
airport('JTR', 'Santorini Airport', 127, 36.3992004394531, 25.4792995452881, 6972).
airport('JTR', 'Santorini Airport', 127, 36.3992004394531, 25.4792995452881, 6472).
airport('KBP', 'Boryspil International Airport', 427, 50.3450012207031, 30.8946990966797, 13123).
airport('KBP', 'Boryspil International Airport', 427, 50.3450012207031, 30.8946990966797, 12623).
airport('RJK', 'Rijeka Airport', 278, 45.2168998718262, 14.5703001022339, 8164).
airport('RJK', 'Rijeka Airport', 278, 45.2168998718262, 14.5703001022339, 7664).
airport('TLS', 'Toulouse-Blagnac Airport', 499, 43.6291007995605, 1.36381995677948, 11483).
airport('TLS', 'Toulouse-Blagnac Airport', 499, 43.6291007995605, 1.36381995677948, 10983).
airport('LAD', 'Quatro de Fevereiro Airport', 243, -8.85836982727, 13.2312002182, 12190).
airport('LAD', 'Quatro de Fevereiro Airport', 243, -8.85836982727, 13.2312002182, 11690).
airport('LED', 'Pulkovo Airport', 78, 59.8003005981445, 30.2625007629395, 12402).
airport('LED', 'Pulkovo Airport', 78, 59.8003005981445, 30.2625007629395, 11902).
airport('OPO', 'Francisco de Sa Carneiro Airport', 228, 41.2481002808, -8.68138980865, 11417).
airport('TIP', 'Tripoli International Airport', 263, 32.6635017395, 13.1590003967, 11815).
airport('TIP', 'Tripoli International Airport', 263, 32.6635017395, 13.1590003967, 11315).
airport('DAC', 'Dhaka / Hazrat Shahjalal International Airport', 30, 23.843347, 90.397783, 10500).
airport('ZYL', 'Osmany International Airport', 50, 24.9631996154785, 91.8667984008789, 9478).
airport('LCG', 'A Coruna Airport', 326, 43.3021011352539, -8.37726020812988, 6365).
airport('TAS', 'Tashkent International Airport', 1417, 41.257900238, 69.2811965942, 13123).
airport('TAS', 'Tashkent International Airport', 1417, 41.257900238, 69.2811965942, 12623).
airport('IKA', 'Imam Khomeini International Airport', 3305, 35.4160995483398, 51.1521987915039, 13940).
airport('IKA', 'Imam Khomeini International Airport', 3305, 35.4160995483398, 51.1521987915039, 13440).
airport('MRU', 'Sir Seewoosagur Ramgoolam International Airport', 186, -20.4302005767822, 57.6836013793945, 11056).
airport('SEZ', 'Seychelles International Airport', 10, -4.67433977127075, 55.521800994873, 9800).
airport('ABI', 'Abilene Regional Airport', 1791, 32.4113006592, -99.6819000244, 7202).
airport('ABI', 'Abilene Regional Airport', 1791, 32.4113006592, -99.6819000244, 6702).
airport('ABI', 'Abilene Regional Airport', 1791, 32.4113006592, -99.6819000244, 6202).
airport('ACT', 'Waco Regional Airport', 516, 31.6112995147705, -97.2304992675781, 6596).
airport('ACT', 'Waco Regional Airport', 516, 31.6112995147705, -97.2304992675781, 6096).
airport('CLL', 'Easterwood Field', 320, 30.58860016, -96.36380005, 7000).
airport('CLL', 'Easterwood Field', 320, 30.58860016, -96.36380005, 6500).
airport('CLL', 'Easterwood Field', 320, 30.58860016, -96.36380005, 6000).
airport('BMI', 'Central Illinois Regional Airport at Bloomington-Normal', 871, 40.47710037, -88.91590118, 8000).
airport('BMI', 'Central Illinois Regional Airport at Bloomington-Normal', 871, 40.47710037, -88.91590118, 7500).
airport('BMI', 'Central Illinois Regional Airport at Bloomington-Normal', 871, 40.47710037, -88.91590118, 7000).
airport('BOG', 'El Dorado International Airport', 8361, 4.70159, -74.1469, 12467).
airport('BOG', 'El Dorado International Airport', 8361, 4.70159, -74.1469, 11967).
airport('BPT', 'Southeast Texas Regional Airport', 15, 29.9507999420166, -94.0206985473633, 6750).
airport('BPT', 'Southeast Texas Regional Airport', 15, 29.9507999420166, -94.0206985473633, 6250).
airport('DSM', 'Des Moines International Airport', 958, 41.5340003967285, -93.6631011962891, 9003).
airport('DSM', 'Des Moines International Airport', 958, 41.5340003967285, -93.6631011962891, 8503).
airport('MYR', 'Myrtle Beach International Airport', 25, 33.6796989441, -78.9282989502, 9503).
airport('AEX', 'Alexandria International Airport', 89, 31.3274002075195, -92.5497970581055, 9352).
airport('AEX', 'Alexandria International Airport', 89, 31.3274002075195, -92.5497970581055, 8852).
airport('CZM', 'Cozumel International Airport', 15, 20.5223999023438, -86.9255981445312, 10165).
airport('CZM', 'Cozumel International Airport', 15, 20.5223999023438, -86.9255981445312, 9665).
airport('AGU', 'Jesus Teran International Airport', 6112, 21.7056007385, -102.318000793, 9843).
airport('MTY', 'General Mariano Escobedo International Airport', 1278, 25.7784996033, -100.107002258, 5909).
airport('AMA', 'Rick Husband Amarillo International Airport', 3607, 35.2193984985352, -101.706001281738, 13502).
airport('AMA', 'Rick Husband Amarillo International Airport', 3607, 35.2193984985352, -101.706001281738, 13002).
airport('BJX', 'Del Bajio International Airport', 5956, 20.9934997559, -101.481002808, 11480).
airport('BRO', 'Brownsville South Padre Island International Airport', 22, 25.9067993164062, -97.4259033203125, 7400).
airport('BRO', 'Brownsville South Padre Island International Airport', 22, 25.9067993164062, -97.4259033203125, 6900).
airport('BRO', 'Brownsville South Padre Island International Airport', 22, 25.9067993164062, -97.4259033203125, 6400).
airport('BTR', 'Baton Rouge Metropolitan, Ryan Field', 70, 30.53319931, -91.14959717, 7004).
airport('BTR', 'Baton Rouge Metropolitan, Ryan Field', 70, 30.53319931, -91.14959717, 6504).
airport('BTR', 'Baton Rouge Metropolitan, Ryan Field', 70, 30.53319931, -91.14959717, 6004).
airport('BZE', 'Philip S. W. Goldson International Airport', 15, 17.5391006469727, -88.3081970214844, 7100).
airport('CAE', 'Columbia Metropolitan Airport', 236, 33.9388008117676, -81.119499206543, 8601).
airport('CAE', 'Columbia Metropolitan Airport', 236, 33.9388008117676, -81.119499206543, 8101).
airport('CHA', 'Lovell Field', 683, 35.0353012084961, -85.2037963867188, 7400).
airport('CHA', 'Lovell Field', 683, 35.0353012084961, -85.2037963867188, 6900).
airport('CHS', 'Charleston Air Force Base-International Airport', 46, 32.89860153, -80.04049683, 9001).
airport('CHS', 'Charleston Air Force Base-International Airport', 46, 32.89860153, -80.04049683, 8501).
airport('CMI', 'University of Illinois Willard Airport', 755, 40.03919983, -88.27809906, 8100).
airport('CMI', 'University of Illinois Willard Airport', 755, 40.03919983, -88.27809906, 7600).
airport('CMI', 'University of Illinois Willard Airport', 755, 40.03919983, -88.27809906, 7100).
airport('CMI', 'University of Illinois Willard Airport', 755, 40.03919983, -88.27809906, 6600).
airport('COU', 'Columbia Regional Airport', 889, 38.8180999755859, -92.219596862793, 6501).
airport('COU', 'Columbia Regional Airport', 889, 38.8180999755859, -92.219596862793, 6001).
airport('CRW', 'Yeager Airport', 981, 38.3731002807617, -81.5932006835938, 6302).
airport('CRW', 'Yeager Airport', 981, 38.3731002807617, -81.5932006835938, 5802).
airport('DAY', 'James M Cox Dayton International Airport', 1009, 39.902400970459, -84.2193984985352, 10900).
airport('DAY', 'James M Cox Dayton International Airport', 1009, 39.902400970459, -84.2193984985352, 10400).
airport('DAY', 'James M Cox Dayton International Airport', 1009, 39.902400970459, -84.2193984985352, 9900).
airport('CUU', 'General Roberto Fierro Villalobos International Airport', 4462, 28.7028999329, -105.964996338, 8530).
airport('CUU', 'General Roberto Fierro Villalobos International Airport', 4462, 28.7028999329, -105.964996338, 8030).
airport('CUU', 'General Roberto Fierro Villalobos International Airport', 4462, 28.7028999329, -105.964996338, 7530).
airport('DRO', 'Durango La Plata County Airport', 6685, 37.1515007019, -107.753997803, 9201).
airport('EVV', 'Evansville Regional Airport', 418, 38.0369987488, -87.5324020386, 8021).
airport('EVV', 'Evansville Regional Airport', 418, 38.0369987488, -87.5324020386, 7521).
airport('EVV', 'Evansville Regional Airport', 418, 38.0369987488, -87.5324020386, 7021).
airport('FAR', 'Hector International Airport', 902, 46.9207000732422, -96.815803527832, 9000).
airport('FAR', 'Hector International Airport', 902, 46.9207000732422, -96.815803527832, 8500).
airport('FAR', 'Hector International Airport', 902, 46.9207000732422, -96.815803527832, 8000).
airport('FAT', 'Fresno Yosemite International Airport', 336, 36.7761993408203, -119.718002319336, 9217).
airport('FAT', 'Fresno Yosemite International Airport', 336, 36.7761993408203, -119.718002319336, 8717).
airport('FSD', 'Joe Foss Field Airport', 1429, 43.5820007324, -96.741897583, 8999).
airport('FSD', 'Joe Foss Field Airport', 1429, 43.5820007324, -96.741897583, 8499).
airport('FSD', 'Joe Foss Field Airport', 1429, 43.5820007324, -96.741897583, 7999).
airport('FSM', 'Fort Smith Regional Airport', 469, 35.3366012573242, -94.3674011230469, 8000).
airport('FSM', 'Fort Smith Regional Airport', 469, 35.3366012573242, -94.3674011230469, 7500).
airport('FWA', 'Fort Wayne International Airport', 814, 40.97850037, -85.19509888, 12000).
airport('FWA', 'Fort Wayne International Airport', 814, 40.97850037, -85.19509888, 11500).
airport('FWA', 'Fort Wayne International Airport', 814, 40.97850037, -85.19509888, 11000).
airport('GCK', 'Garden City Regional Airport', 2891, 37.9275016785, -100.723999023, 7300).
airport('GCK', 'Garden City Regional Airport', 2891, 37.9275016785, -100.723999023, 6800).
airport('GDL', 'Don Miguel Hidalgo Y Costilla International Airport', 5016, 20.5217990875244, -103.310997009277, 13123).
airport('GDL', 'Don Miguel Hidalgo Y Costilla International Airport', 5016, 20.5217990875244, -103.310997009277, 12623).
airport('GGG', 'East Texas Regional Airport', 365, 32.3839988708496, -94.7115020751953, 10000).
airport('GGG', 'East Texas Regional Airport', 365, 32.3839988708496, -94.7115020751953, 9500).
airport('GJT', 'Grand Junction Regional Airport', 4858, 39.1223983765, -108.527000427, 10501).
airport('GJT', 'Grand Junction Regional Airport', 4858, 39.1223983765, -108.527000427, 10001).
airport('GPT', 'Gulfport Biloxi International Airport', 28, 30.4073009490967, -89.0700988769531, 9002).
airport('GPT', 'Gulfport Biloxi International Airport', 28, 30.4073009490967, -89.0700988769531, 8502).
airport('GRI', 'Central Nebraska Regional Airport', 1847, 40.9674987792969, -98.3096008300781, 7002).
airport('GRI', 'Central Nebraska Regional Airport', 1847, 40.9674987792969, -98.3096008300781, 6502).
airport('GRK', 'Robert Gray  Army Air Field Airport', 1015, 31.067199707, -97.8289031982, 10000).
airport('GRR', 'Gerald R. Ford International Airport', 794, 42.88079834, -85.52279663, 10000).
airport('GRR', 'Gerald R. Ford International Airport', 794, 42.88079834, -85.52279663, 9500).
airport('GRR', 'Gerald R. Ford International Airport', 794, 42.88079834, -85.52279663, 9000).
airport('GSO', 'Piedmont Triad International Airport', 925, 36.0978012084961, -79.9373016357422, 10001).
airport('GSO', 'Piedmont Triad International Airport', 925, 36.0978012084961, -79.9373016357422, 9501).
airport('GSO', 'Piedmont Triad International Airport', 925, 36.0978012084961, -79.9373016357422, 9001).
airport('GSP', 'Greenville Spartanburg International Airport', 964, 34.8956985474, -82.2189025879, 11000).
airport('JAN', 'Jackson-Medgar Wiley Evers International Airport', 346, 32.3111991882, -90.0758972168, 8500).
airport('JAN', 'Jackson-Medgar Wiley Evers International Airport', 346, 32.3111991882, -90.0758972168, 8000).
airport('JLN', 'Joplin Regional Airport', 981, 37.151798248291, -94.4982986450195, 6502).
airport('JLN', 'Joplin Regional Airport', 981, 37.151798248291, -94.4982986450195, 6002).
airport('JLN', 'Joplin Regional Airport', 981, 37.151798248291, -94.4982986450195, 5502).
airport('LAW', 'Lawton Fort Sill Regional Airport', 1110, 34.5676994324, -98.4166030884, 8599).
airport('LCH', 'Lake Charles Regional Airport', 15, 30.1261005401611, -93.2232971191406, 6500).
airport('LCH', 'Lake Charles Regional Airport', 15, 30.1261005401611, -93.2232971191406, 6000).
airport('LFT', 'Lafayette Regional Airport', 42, 30.20529938, -91.98760223, 7651).
airport('LFT', 'Lafayette Regional Airport', 42, 30.20529938, -91.98760223, 7151).
airport('LFT', 'Lafayette Regional Airport', 42, 30.20529938, -91.98760223, 6651).
airport('LIR', 'Daniel Oduber Quiros International Airport', 270, 10.5932998657227, -85.5444030761719, 9022).
airport('LRD', 'Laredo International Airport', 508, 27.5438003540039, -99.4616012573242, 8236).
airport('LRD', 'Laredo International Airport', 508, 27.5438003540039, -99.4616012573242, 7736).
airport('LRD', 'Laredo International Airport', 508, 27.5438003540039, -99.4616012573242, 7236).
airport('MFE', 'Mc Allen Miller International Airport', 107, 26.17580032, -98.23860168, 7120).
airport('MFE', 'Mc Allen Miller International Airport', 107, 26.17580032, -98.23860168, 6620).
airport('MGM', 'Montgomery Regional (Dannelly Field) Airport', 221, 32.30059814, -86.39399719, 9010).
airport('MGM', 'Montgomery Regional (Dannelly Field) Airport', 221, 32.30059814, -86.39399719, 8510).
airport('MHK', 'Manhattan Regional Airport', 1057, 39.140998840332, -96.6707992553711, 7000).
airport('MHK', 'Manhattan Regional Airport', 1057, 39.140998840332, -96.6707992553711, 6500).
airport('MLI', 'Quad City International Airport', 590, 41.4485015869141, -90.5074996948242, 10002).
airport('MLI', 'Quad City International Airport', 590, 41.4485015869141, -90.5074996948242, 9502).
airport('MLI', 'Quad City International Airport', 590, 41.4485015869141, -90.5074996948242, 9002).
airport('MLM', 'General Francisco J. Mujica International Airport', 6033, 19.849899292, -101.025001526, 11155).
airport('MLU', 'Monroe Regional Airport', 79, 32.5108985900879, -92.0376968383789, 7507).
airport('MLU', 'Monroe Regional Airport', 79, 32.5108985900879, -92.0376968383789, 7007).
airport('MLU', 'Monroe Regional Airport', 79, 32.5108985900879, -92.0376968383789, 6507).
airport('MOB', 'Mobile Regional Airport', 219, 30.6912002563477, -88.2427978515625, 8521).
airport('MOB', 'Mobile Regional Airport', 219, 30.6912002563477, -88.2427978515625, 8021).
airport('MSN', 'Dane County Regional Truax Field', 887, 43.1399002075195, -89.3375015258789, 9005).
airport('MSN', 'Dane County Regional Truax Field', 887, 43.1399002075195, -89.3375015258789, 8505).
airport('MSN', 'Dane County Regional Truax Field', 887, 43.1399002075195, -89.3375015258789, 8005).
airport('MZT', 'General Rafael Buelna International Airport', 38, 23.1613998413, -106.26599884, 8858).
airport('PBC', 'Hermanos Serdán International Airport', 7361, 19.1581001282, -98.3713989258, 11811).
airport('PLS', 'Providenciales Airport', 15, 21.7735996246338, -72.2658996582031, 7598).
airport('PNS', 'Pensacola Regional Airport', 121, 30.4734001159668, -87.1865997314453, 7004).
airport('PNS', 'Pensacola Regional Airport', 121, 30.4734001159668, -87.1865997314453, 6504).
airport('PTY', 'Tocumen International Airport', 135, 9.0713596344, -79.3834991455, 10006).
airport('PTY', 'Tocumen International Airport', 135, 9.0713596344, -79.3834991455, 9506).
airport('QRO', 'Querétaro Intercontinental Airport', 6296, 20.6173000336, -100.185997009, 11483).
airport('ROW', 'Roswell International Air Center Airport', 3671, 33.3016014099121, -104.53099822998, 13001).
airport('ROW', 'Roswell International Air Center Airport', 3671, 33.3016014099121, -104.53099822998, 12501).
airport('ROW', 'Roswell International Air Center Airport', 3671, 33.3016014099121, -104.53099822998, 12001).
airport('SAL', 'El Salvador International Airport', 101, 13.440899848938, -89.0557022094727, 10500).
airport('SAL', 'El Salvador International Airport', 101, 13.440899848938, -89.0557022094727, 10000).
airport('SAV', 'Savannah Hilton Head International Airport', 50, 32.12760162, -81.20210266, 9351).
airport('SAV', 'Savannah Hilton Head International Airport', 50, 32.12760162, -81.20210266, 8851).
airport('SJD', 'Los Cabos International Airport', 374, 23.1518001556396, -109.721000671387, 9843).
airport('SJT', 'San Angelo Regional Mathis Field', 1919, 31.3577003479004, -100.496002197266, 7003).
airport('SJT', 'San Angelo Regional Mathis Field', 1919, 31.3577003479004, -100.496002197266, 6503).
airport('SJT', 'San Angelo Regional Mathis Field', 1919, 31.3577003479004, -100.496002197266, 6003).
airport('SLP', 'Ponciano Arriaga International Airport', 6035, 22.2542991638, -100.930999756, 9867).
airport('SLP', 'Ponciano Arriaga International Airport', 6035, 22.2542991638, -100.930999756, 9367).
airport('SPI', 'Abraham Lincoln Capital Airport', 598, 39.84410095, -89.67790222, 7999).
airport('SPI', 'Abraham Lincoln Capital Airport', 598, 39.84410095, -89.67790222, 7499).
airport('SPI', 'Abraham Lincoln Capital Airport', 598, 39.84410095, -89.67790222, 6999).
airport('SPS', 'Sheppard Air Force Base-Wichita Falls Municipal Airport', 1019, 33.98880005, -98.49189758, 13101).
airport('SPS', 'Sheppard Air Force Base-Wichita Falls Municipal Airport', 1019, 33.98880005, -98.49189758, 12601).
airport('SPS', 'Sheppard Air Force Base-Wichita Falls Municipal Airport', 1019, 33.98880005, -98.49189758, 12101).
airport('SPS', 'Sheppard Air Force Base-Wichita Falls Municipal Airport', 1019, 33.98880005, -98.49189758, 11601).
airport('TRC', 'Francisco Sarabia International Airport', 3688, 25.5683002472, -103.411003113, 9022).
airport('TRC', 'Francisco Sarabia International Airport', 3688, 25.5683002472, -103.411003113, 8522).
airport('TYR', 'Tyler Pounds Regional Airport', 544, 32.3540992736816, -95.4023971557617, 7200).
airport('TYR', 'Tyler Pounds Regional Airport', 544, 32.3540992736816, -95.4023971557617, 6700).
airport('TYR', 'Tyler Pounds Regional Airport', 544, 32.3540992736816, -95.4023971557617, 6200).
airport('TYS', 'McGhee Tyson Airport', 981, 35.81100082, -83.9940033, 9005).
airport('TYS', 'McGhee Tyson Airport', 981, 35.81100082, -83.9940033, 8505).
airport('VPS', 'Eglin Air Force Base', 87, 30.4832000732422, -86.5253982543945, 12005).
airport('VPS', 'Eglin Air Force Base', 87, 30.4832000732422, -86.5253982543945, 11505).
airport('XNA', 'Northwest Arkansas Regional Airport', 1287, 36.2818984985, -94.3068008423, 8800).
airport('ZCL', 'General Leobardo C. Ruiz International Airport', 7141, 22.8971004486, -102.68699646, 9843).
airport('ZCL', 'General Leobardo C. Ruiz International Airport', 7141, 22.8971004486, -102.68699646, 9343).
airport('INN', 'Innsbruck Airport', 1906, 47.2602005005, 11.3439998627, 6562).
airport('UVF', 'Hewanorra International Airport', 14, 13.7332, -60.952599, 9003).
airport('CAK', 'Akron Canton Regional Airport', 1228, 40.9160995483398, -81.4421997070312, 7601).
airport('CAK', 'Akron Canton Regional Airport', 1228, 40.9160995483398, -81.4421997070312, 7101).
airport('CAK', 'Akron Canton Regional Airport', 1228, 40.9160995483398, -81.4421997070312, 6601).
airport('BRL', 'Southeast Iowa Regional Airport', 698, 40.7831993103027, -91.1255035400391, 6702).
airport('BRL', 'Southeast Iowa Regional Airport', 698, 40.7831993103027, -91.1255035400391, 6202).
airport('MHT', 'Manchester Airport', 266, 42.9325981140137, -71.4356994628906, 9250).
airport('MHT', 'Manchester Airport', 266, 42.9325981140137, -71.4356994628906, 8750).
airport('SYR', 'Syracuse Hancock International Airport', 421, 43.111198425293, -76.1063003540039, 9003).
airport('SYR', 'Syracuse Hancock International Airport', 421, 43.111198425293, -76.1063003540039, 8503).
airport('SYR', 'Syracuse Hancock International Airport', 421, 43.111198425293, -76.1063003540039, 8003).
airport('YQR', 'Regina International Airport', 1894, 50.4319000244141, -104.666000366211, 7900).
airport('YQR', 'Regina International Airport', 1894, 50.4319000244141, -104.666000366211, 7400).
airport('FLO', 'Florence Regional Airport', 146, 34.1853981018066, -79.7238998413086, 6499).
airport('FLO', 'Florence Regional Airport', 146, 34.1853981018066, -79.7238998413086, 5999).
airport('AVL', 'Asheville Regional Airport', 2165, 35.4361991882324, -82.5418014526367, 8001).
airport('POM', 'Port Moresby Jacksons International Airport', 146, -9.44338035583496, 147.220001220703, 9022).
airport('POM', 'Port Moresby Jacksons International Airport', 146, -9.44338035583496, 147.220001220703, 8522).
airport('EGE', 'Eagle County Regional Airport', 6548, 39.64260101, -106.9179993, 9000).
airport('EGE', 'Eagle County Regional Airport', 6548, 39.64260101, -106.9179993, 8500).
airport('HDN', 'Yampa Valley Airport', 6606, 40.48120117, -107.2180023, 10000).
airport('SRQ', 'Sarasota Bradenton International Airport', 30, 27.3953990936279, -82.5543975830078, 9500).
airport('SRQ', 'Sarasota Bradenton International Airport', 30, 27.3953990936279, -82.5543975830078, 9000).
airport('FOE', 'Topeka Regional Airport - Forbes Field', 1078, 38.9509010315, -95.6635971069, 12802).
airport('FOE', 'Topeka Regional Airport - Forbes Field', 1078, 38.9509010315, -95.6635971069, 12302).
airport('LAN', 'Capital City Airport', 861, 42.7787017822266, -84.58740234375, 7251).
airport('LAN', 'Capital City Airport', 861, 42.7787017822266, -84.58740234375, 6751).
airport('LAN', 'Capital City Airport', 861, 42.7787017822266, -84.58740234375, 6251).
airport('ROA', 'Roanoke–Blacksburg Regional Airport', 1175, 37.3255004883, -79.975402832, 6800).
airport('ROA', 'Roanoke–Blacksburg Regional Airport', 1175, 37.3255004883, -79.975402832, 6300).
airport('MQT', 'Sawyer International Airport', 1221, 46.3535995483, -87.395401001, 12370).
airport('GRB', 'Austin Straubel International Airport', 695, 44.4850997924805, -88.1296005249023, 8201).
airport('GRB', 'Austin Straubel International Airport', 695, 44.4850997924805, -88.1296005249023, 7701).
airport('GRB', 'Austin Straubel International Airport', 695, 44.4850997924805, -88.1296005249023, 7201).
airport('BHX', 'Birmingham International Airport', 327, 52.4538993835, -1.74802994728, 8527).
airport('INV', 'Inverness Airport', 31, 57.5424995422363, -4.0475001335144, 6191).
airport('INV', 'Inverness Airport', 31, 57.5424995422363, -4.0475001335144, 5691).
airport('SZG', 'Salzburg Airport', 1411, 47.7933006287, 13.0043001175, 9022).
airport('KGS', 'Kos Airport', 412, 36.7933006286621, 27.0916996002197, 7841).
airport('TRD', 'Trondheim Airport, Værnes', 56, 63.4578018188477, 10.923999786377, 9052).
airport('TRD', 'Trondheim Airport, Værnes', 56, 63.4578018188477, 10.923999786377, 8552).
airport('TRD', 'Trondheim Airport, Værnes', 56, 63.4578018188477, 10.923999786377, 8052).
airport('HAN', 'Noi Bai International Airport', 39, 21.2212009429932, 105.806999206543, 12466).
airport('HAN', 'Noi Bai International Airport', 39, 21.2212009429932, 105.806999206543, 11966).
airport('KHH', 'Kaohsiung International Airport', 31, 22.5771007537842, 120.349998474121, 10335).
airport('NGO', 'Chubu Centrair International Airport', 15, 34.8583984375, 136.804992675781, 11483).
airport('BLL', 'Billund Airport', 247, 55.7402992249, 9.15178012848, 10172).
airport('BRN', 'Bern Belp Airport', 1674, 46.914100647, 7.49714994431, 4954).
airport('BRN', 'Bern Belp Airport', 1674, 46.914100647, 7.49714994431, 4454).
airport('BRN', 'Bern Belp Airport', 1674, 46.914100647, 7.49714994431, 3954).
airport('IOM', 'Isle of Man Airport', 52, 54.0833015441895, -4.6238899230957, 5751).
airport('IOM', 'Isle of Man Airport', 52, 54.0833015441895, -4.6238899230957, 5251).
airport('IOM', 'Isle of Man Airport', 52, 54.0833015441895, -4.6238899230957, 4751).
airport('GRX', 'Federico Garcia Lorca Airport', 1860, 37.1887016296387, -3.77735996246338, 9514).
airport('FLR', 'Peretola Airport', 142, 43.8100013733, 11.2051000595, 5425).
airport('DRS', 'Dresden Airport', 755, 51.1328010559082, 13.7672004699707, 8228).
airport('DOL', 'Deauville-Saint-Gatien Airport', 479, 49.3652992249, 0.154305994511, 8366).
airport('BVE', 'Brive Souillac Airport', 1016, 45.0397222222, 1.48555555556, 6890).
airport('BVE', 'Brive Souillac Airport', 1016, 45.0397222222, 1.48555555556, 6390).
airport('BES', 'Brest Bretagne Airport', 325, 48.4478988647461, -4.41854000091553, 10171).
airport('BES', 'Brest Bretagne Airport', 325, 48.4478988647461, -4.41854000091553, 9671).
airport('ANR', 'Antwerp International Airport (Deurne)', 39, 51.1893997192, 4.46027994156, 4954).
airport('BRE', 'Bremen Airport', 14, 53.0475006104, 8.78666973114, 6693).
airport('BRE', 'Bremen Airport', 14, 53.0475006104, 8.78666973114, 6193).
airport('CFE', 'Clermont-Ferrand Auvergne Airport', 1090, 45.7867012023926, 3.16916990280151, 9892).
airport('CFE', 'Clermont-Ferrand Auvergne Airport', 1090, 45.7867012023926, 3.16916990280151, 9392).
airport('PRN', 'Priština International Airport', 1789, 42.5727996826172, 21.0358009338379, 8165).
airport('HME', 'Oued Irara Airport', 463, 31.6730003357, 6.14043998718, 9843).
airport('HME', 'Oued Irara Airport', 463, 31.6730003357, 6.14043998718, 9343).
airport('SXF', 'Berlin-Schönefeld International Airport *Closed*', 157, 52.3800010681152, 13.522500038147, 9843).
airport('SXF', 'Berlin-Schönefeld International Airport *Closed*', 157, 52.3800010681152, 13.522500038147, 9343).
airport('ERF', 'Erfurt Airport', 1036, 50.9798011779785, 10.9581003189087, 8530).
airport('BFS', 'Belfast International Airport', 268, 54.6575012207, -6.21582984924, 9121).
airport('BFS', 'Belfast International Airport', 268, 54.6575012207, -6.21582984924, 8621).
airport('NQY', 'Newquay Cornwall Airport', 390, 50.440601348877, -4.99540996551514, 9006).
airport('NOC', 'Ireland West Knock Airport', 665, 53.9103012084961, -8.81849002838135, 7546).
airport('AAL', 'Aalborg Airport', 10, 57.0927589138, 9.84924316406, 8707).
airport('AAL', 'Aalborg Airport', 10, 57.0927589138, 9.84924316406, 8207).
airport('AES', 'Ålesund Airport', 69, 62.5625, 6.11969995498657, 7592).
airport('TOS', 'Tromsø Airport', 31, 69.6832962036133, 18.9188995361328, 7848).
airport('TRF', 'Sandefjord Airport, Torp', 286, 59.1866989136, 10.258600235, 9675).
airport('KRK', 'John Paul II International Airport Kraków-Balice Airport', 791, 50.0777015686035, 19.7847995758057, 8366).
airport('KUN', 'Kaunas International Airport', 256, 54.9639015197754, 24.0848007202148, 10335).
airport('FUE', 'Fuerteventura Airport', 85, 28.4526996612549, -13.8638000488281, 11175).
airport('ACE', 'Lanzarote Airport', 46, 28.945499420166, -13.6051998138428, 7874).
airport('TFS', 'Tenerife South Airport', 209, 28.044500351, -16.5725002289, 10499).
airport('AGA', 'Al Massira Airport', 250, 30.3250007629395, -9.41306972503662, 10499).
airport('RAK', 'Menara Airport', 1545, 31.6068992615, -8.03629970551, 10170).
airport('SID', 'Amílcar Cabral International Airport', 177, 16.7413997650146, -22.9493999481201, 10735).
airport('SID', 'Amílcar Cabral International Airport', 177, 16.7413997650146, -22.9493999481201, 10235).
airport('BVC', 'Rabil Airport', 69, 16.1364994049072, -22.8889007568359, 4007).
airport('HRG', 'Hurghada International Airport', 52, 27.1783008575439, 33.7994003295898, 13124).
airport('SSH', 'Sharm El Sheikh International Airport', 143, 27.9773006439, 34.3950004578, 10108).
airport('SSH', 'Sharm El Sheikh International Airport', 143, 27.9773006439, 34.3950004578, 9608).
airport('TIA', 'Tirana International Airport Mother Teresa', 126, 41.4146995544, 19.7206001282, 8971).
airport('PFO', 'Paphos International Airport', 41, 34.7179985046387, 32.4856986999512, 8858).
airport('LEI', 'Almería International Airport', 70, 36.8438987731934, -2.3701000213623, 10499).
airport('MJV', 'San Javier Airport', 11, 37.7750015258789, -0.812389016151428, 7546).
airport('MJV', 'San Javier Airport', 11, 37.7750015258789, -0.812389016151428, 7046).
airport('MJV', 'San Javier Airport', 11, 37.7750015258789, -0.812389016151428, 6546).
airport('SCQ', 'Santiago de Compostela Airport', 1213, 42.8963012695312, -8.41514015197754, 10499).
airport('VLC', 'Valencia Airport', 240, 39.4892997741699, -0.481624990701675, 8858).
airport('VLC', 'Valencia Airport', 240, 39.4892997741699, -0.481624990701675, 8358).
airport('BOD', 'Bordeaux-Mérignac Airport', 162, 44.8283004761, -0.715556025505, 10171).
airport('BOD', 'Bordeaux-Mérignac Airport', 162, 44.8283004761, -0.715556025505, 9671).
airport('BIA', 'Bastia-Poretta Airport', 26, 42.5527000427246, 9.48373031616211, 8266).
airport('AJA', 'Ajaccio-Napoléon Bonaparte Airport', 18, 41.9235992431641, 8.8029203414917, 7897).
airport('MPL', 'Montpellier-Méditerranée Airport', 17, 43.5761985778809, 3.96301007270813, 8530).
airport('MPL', 'Montpellier-Méditerranée Airport', 17, 43.5761985778809, 3.96301007270813, 8030).
airport('SXB', 'Strasbourg Airport', 505, 48.5382995605469, 7.62823009490967, 7874).
airport('HER', 'Heraklion International Nikos Kazantzakis Airport', 115, 35.3396987915, 25.1802997589, 8800).
airport('HER', 'Heraklion International Nikos Kazantzakis Airport', 115, 35.3396987915, 25.1802997589, 8300).
airport('HER', 'Heraklion International Nikos Kazantzakis Airport', 115, 35.3396987915, 25.1802997589, 7800).
airport('EFL', 'Kefallinia Airport', 59, 38.1200981140137, 20.5004997253418, 7992).
airport('KLX', 'Kalamata Airport', 26, 37.0682983398438, 22.0254993438721, 9260).
airport('CFU', 'Ioannis Kapodistrias International Airport', 6, 39.6018981933594, 19.9116992950439, 7792).
airport('PVK', 'Aktion National Airport', 11, 38.9254989624023, 20.7653007507324, 9419).
airport('CHQ', 'Chania International Airport', 490, 35.5317001342773, 24.1497001647949, 10982).
airport('SKG', 'Thessaloniki Macedonia International Airport', 22, 40.5196990966797, 22.9708995819092, 8005).
airport('SKG', 'Thessaloniki Macedonia International Airport', 22, 40.5196990966797, 22.9708995819092, 7505).
airport('BRI', 'Bari Karol Wojtyła Airport', 177, 41.1389007568, 16.7605991364, 8005).
airport('BRI', 'Bari Karol Wojtyła Airport', 177, 41.1389007568, 16.7605991364, 7505).
airport('CTA', 'Catania-Fontanarossa Airport', 39, 37.4668006897, 15.0663995743, 7989).
airport('PMO', 'Falcone–Borsellino Airport', 65, 38.1759986877, 13.0909996033, 10912).
airport('PMO', 'Falcone–Borsellino Airport', 65, 38.1759986877, 13.0909996033, 10412).
airport('OLB', 'Olbia Costa Smeralda Airport', 37, 40.8987007141, 9.51762962341, 8025).
airport('PDL', 'João Paulo II Airport', 259, 37.7411994934, -25.6979007721, 8192).
airport('ADB', 'Adnan Menderes International Airport', 412, 38.2924003601, 27.156999588, 10630).
airport('ADB', 'Adnan Menderes International Airport', 412, 38.2924003601, 27.156999588, 10130).
airport('DLM', 'Dalaman International Airport', 20, 36.7131004333, 28.7924995422, 9842).
airport('BJV', 'Milas Bodrum International Airport', 21, 37.2505989075, 27.6643009186, 9842).
airport('SAW', 'Sabiha Gökçen International Airport', 312, 40.898601532, 29.3092002869, 9843).
airport('TIV', 'Tivat Airport', 20, 42.4047012329102, 18.7233009338379, 8208).
airport('NBE', 'Enfidha - Hammamet International Airport', 21, 36.075833, 10.438611, 10827).
airport('MSQ', 'Minsk International Airport', 670, 53.8824996948242, 28.0307006835938, 11946).
airport('MLE', 'Malé International Airport', 6, 4.19183015823364, 73.5290985107422, 10499).
airport('DTM', 'Dortmund Airport', 425, 51.5182991028, 7.61223983765, 6562).
airport('AGS', 'Augusta Regional At Bush Field', 144, 33.3698997497559, -81.9645004272461, 8001).
airport('AGS', 'Augusta Regional At Bush Field', 144, 33.3698997497559, -81.9645004272461, 7501).
airport('BGR', 'Bangor International Airport', 192, 44.8073997497559, -68.8281021118164, 11440).
airport('BTV', 'Burlington International Airport', 335, 44.4719009399, -73.1532974243, 8320).
airport('BTV', 'Burlington International Airport', 335, 44.4719009399, -73.1532974243, 7820).
airport('FAY', 'Fayetteville Regional Grannis Field', 189, 34.9911994934082, -78.8803024291992, 7712).
airport('FAY', 'Fayetteville Regional Grannis Field', 189, 34.9911994934082, -78.8803024291992, 7212).
airport('HHH', 'Hilton Head Airport', 19, 32.2243995667, -80.6975021362, 4300).
airport('ILM', 'Wilmington International Airport', 32, 34.2705993652344, -77.9026031494141, 8016).
airport('ILM', 'Wilmington International Airport', 32, 34.2705993652344, -77.9026031494141, 7516).
airport('OAJ', 'Albert J Ellis Airport', 94, 34.8292007446, -77.6120986938, 7100).
airport('NUE', 'Nuremberg Airport', 1046, 49.4986991882, 11.0669002533, 8858).
airport('LEJ', 'Leipzig Halle Airport', 465, 51.4323997497559, 12.2416000366211, 11811).
airport('LEJ', 'Leipzig Halle Airport', 465, 51.4323997497559, 12.2416000366211, 11311).
airport('CWL', 'Cardiff International Airport', 220, 51.3967018127441, -3.34332990646362, 7848).
airport('SEN', 'London Southend Airport', 49, 51.5713996887207, 0.695555984973907, 5023).
airport('HUY', 'Humberside Airport', 121, 53.5744018554688, -0.350832998752594, 7205).
airport('HUY', 'Humberside Airport', 121, 53.5744018554688, -0.350832998752594, 6705).
airport('MME', 'Durham Tees Valley Airport', 120, 54.5092010498047, -1.42940998077393, 7516).
airport('NWI', 'Norwich International Airport', 117, 52.6758003235, 1.28278005123, 6040).
airport('NWI', 'Norwich International Airport', 117, 52.6758003235, 1.28278005123, 5540).
airport('EXT', 'Exeter International Airport', 102, 50.7344017028809, -3.41388988494873, 6834).
airport('EXT', 'Exeter International Airport', 102, 50.7344017028809, -3.41388988494873, 6334).
airport('KRS', 'Kristiansand Airport', 57, 58.2042007446289, 8.08537006378174, 6660).
airport('GDN', 'Gdańsk Lech Wałęsa Airport', 489, 54.3776016235352, 18.4661998748779, 9186).
airport('VXO', 'Växjö Kronoberg Airport', 610, 56.9291000366211, 14.7279996871948, 6900).
airport('LPI', 'Linköping City Airport', 172, 58.4062004089, 15.6805000305, 6989).
airport('SPC', 'La Palma Airport', 107, 28.6264991760254, -17.7555999755859, 7218).
airport('NDR', 'Nador International Airport', 574, 34.9888000488, -3.0282099247, 9842).
airport('VXE', 'São Pedro Airport', 66, 16.8332004547119, -25.0552997589111, 6561).
airport('KGL', 'Kigali International Airport', 4859, -1.96862995625, 30.1394996643, 11483).
airport('JRO', 'Kilimanjaro International Airport', 2932, -3.42940998077, 37.0745010376, 11834).
airport('SFB', 'Orlando Sanford International Airport', 55, 28.7775993347168, -81.2375030517578, 9600).
airport('SFB', 'Orlando Sanford International Airport', 55, 28.7775993347168, -81.2375030517578, 9100).
airport('SFB', 'Orlando Sanford International Airport', 55, 28.7775993347168, -81.2375030517578, 8600).
airport('SFB', 'Orlando Sanford International Airport', 55, 28.7775993347168, -81.2375030517578, 8100).
airport('GRO', 'Girona Airport', 468, 41.9010009765625, 2.76055002212524, 7874).
airport('JKH', 'Chios Island National Airport', 15, 38.3432006835938, 26.1406002044678, 4957).
airport('KIT', 'Kithira Airport', 1045, 36.2742996216, 23.0170001984, 4794).
airport('SMI', 'Samos Airport', 19, 37.689998626709, 26.9116992950439, 6706).
airport('SUF', 'Lamezia Terme Airport', 39, 38.9053993225098, 16.2423000335693, 7920).
airport('LJU', 'Ljubljana Jože Pučnik Airport', 1273, 46.2237014770508, 14.4575996398926, 10827).
airport('KYA', 'Konya Airport', 3381, 37.9790000916, 32.5619010925, 10984).
airport('KYA', 'Konya Airport', 3381, 37.9790000916, 32.5619010925, 10484).
airport('ASR', 'Kayseri Erkilet Airport', 3463, 38.770401001, 35.4953994751, 9841).
airport('POP', 'Gregorio Luperon International Airport', 15, 19.7579002380371, -70.5699996948242, 10108).
airport('HOG', 'Frank Pais International Airport', 361, 20.7856006622314, -76.3151016235352, 10624).
airport('VRA', 'Juan Gualberto Gomez International Airport', 210, 23.0344009399414, -81.435302734375, 11490).
airport('DMM', 'King Fahd International Airport', 72, 26.4712009429932, 49.7979011535645, 13124).
airport('DMM', 'King Fahd International Airport', 72, 26.4712009429932, 49.7979011535645, 12624).
airport('EBL', 'Erbil International Airport', 1341, 36.2375984191895, 43.9631996154785, 13890).
airport('EBL', 'Erbil International Airport', 1341, 36.2375984191895, 43.9631996154785, 13390).
airport('EBL', 'Erbil International Airport', 1341, 36.2375984191895, 43.9631996154785, 12890).
airport('EBL', 'Erbil International Airport', 1341, 36.2375984191895, 43.9631996154785, 12390).
airport('UIO', 'Mariscal Sucre International Airport', 9200, -0.129166666667, -78.3575, 13445).
airport('PBM', 'Johan Adolf Pengel International Airport', 59, 5.4528298378, -55.1878013611, 11417).
airport('GUW', 'Atyrau Airport', -72, 47.121898651123, 51.8213996887207, 9842).
airport('TBS', 'Tbilisi International Airport', 1624, 41.6692008972, 44.95470047, 9843).
airport('TBS', 'Tbilisi International Airport', 1624, 41.6692008972, 44.95470047, 9343).
airport('XMN', 'Xiamen Gaoqi International Airport', 59, 24.5440006256104, 118.127998352051, 11155).
airport('HGH', 'Hangzhou Xiaoshan International Airport', 23, 30.2294998168945, 120.43399810791, 11811).
airport('BQN', 'Rafael Hernandez Airport', 237, 18.4948997497559, -67.1294021606445, 11702).
airport('APF', 'Naples Municipal Airport', 8, 26.1525993347, -81.7752990723, 5290).
airport('APF', 'Naples Municipal Airport', 8, 26.1525993347, -81.7752990723, 4790).
airport('APF', 'Naples Municipal Airport', 8, 26.1525993347, -81.7752990723, 4290).
airport('GNV', 'Gainesville Regional Airport', 152, 29.6900997162, -82.2717971802, 7504).
airport('GNV', 'Gainesville Regional Airport', 152, 29.6900997162, -82.2717971802, 7004).
airport('LRM', 'Casa De Campo International Airport', 240, 18.4507007598877, -68.9117965698242, 9676).
airport('SDQ', 'Las Américas International Airport', 59, 18.4297008514404, -69.6688995361328, 11000).
airport('STI', 'Cibao International Airport', 565, 19.406099319458, -70.6046981811523, 8595).
airport('SAP', 'Ramón Villeda Morales International Airport', 91, 15.4525995254517, -87.9235992431641, 9203).
airport('MID', 'Licenciado Manuel Crescencio Rejon Int Airport', 38, 20.9370002747, -89.657699585, 10499).
airport('MID', 'Licenciado Manuel Crescencio Rejon Int Airport', 38, 20.9370002747, -89.657699585, 9999).
airport('MGA', 'Augusto C. Sandino (Managua) International Airport', 194, 12.1415004730225, -86.1681976318359, 8012).
airport('PAP', 'Toussaint Louverture International Airport', 122, 18.5799999237061, -72.2925033569336, 9974).
airport('CYB', 'Gerrard Smith International Airport', 8, 19.6870002746582, -79.8827972412109, 6000).
airport('GCM', 'Owen Roberts International Airport', 8, 19.2928009033, -81.3576965332, 7021).
airport('MHH', 'Marsh Harbour International Airport', 6, 26.5114002228, -77.0835037231, 4998).
airport('ELH', 'North Eleuthera Airport', 13, 25.474899292, -76.6835021973, 6020).
airport('BEL', 'Val de Cans/Júlio Cezar Ribeiro International Airport', 54, -1.37925004959, -48.4762992859, 9186).
airport('BEL', 'Val de Cans/Júlio Cezar Ribeiro International Airport', 54, -1.37925004959, -48.4762992859, 8686).
airport('BSB', 'Presidente Juscelino Kubistschek International Airport', 3497, -15.8691673278809, -47.9208335876465, 10827).
airport('BSB', 'Presidente Juscelino Kubistschek International Airport', 3497, -15.8691673278809, -47.9208335876465, 10327).
airport('CNF', 'Tancredo Neves International Airport', 2715, -19.6244430541992, -43.9719429016113, 9843).
airport('CWB', 'Afonso Pena Airport', 2988, -25.5284996033, -49.1758003235, 7267).
airport('CWB', 'Afonso Pena Airport', 2988, -25.5284996033, -49.1758003235, 6767).
airport('MAO', 'Eduardo Gomes International Airport', 264, -3.03860998153687, -60.0497016906738, 8858).
airport('REC', 'Guararapes - Gilberto Freyre International Airport', 33, -8.12648963928223, -34.9235992431641, 9865).
airport('SSA', 'Deputado Luiz Eduardo Magalhães International Airport', 64, -12.9086112976, -38.3224983215, 9859).
airport('SSA', 'Deputado Luiz Eduardo Magalhães International Airport', 64, -12.9086112976, -38.3224983215, 9359).
airport('ASU', 'Silvio Pettirossi International Airport', 292, -25.2399997711182, -57.5200004577637, 11001).
airport('BAQ', 'Ernesto Cortissoz International Airport', 98, 10.8896, -74.7808, 9842).
airport('CTG', 'Rafael Nuñez International Airport', 4, 10.4424, -75.513, 8530).
airport('CLO', 'Alfonso Bonilla Aragon International Airport', 3162, 3.54322, -76.3816, 9842).
airport('MDE', 'Jose Maria Córdova International Airport', 6955, 6.16454, -75.4231, 11483).
airport('LPB', 'El Alto International Airport', 13355, -16.5132999420166, -68.1922988891602, 13123).
airport('LPB', 'El Alto International Airport', 13355, -16.5132999420166, -68.1922988891602, 12623).
airport('BLA', 'General Jose Antonio Anzoategui International Airport', 26, 10.1070995330811, -64.6892013549805, 9840).
airport('BLA', 'General Jose Antonio Anzoategui International Airport', 26, 10.1070995330811, -64.6892013549805, 9340).
airport('MAR', 'La Chinita International Airport', 239, 10.5582084656, -71.7278594971, 9843).
airport('MAR', 'La Chinita International Airport', 239, 10.5582084656, -71.7278594971, 9343).
airport('GEO', 'Cheddi Jagan International Airport', 95, 6.4985499382019, -58.2541007995605, 7448).
airport('GEO', 'Cheddi Jagan International Airport', 95, 6.4985499382019, -58.2541007995605, 6948).
airport('FDF', 'Martinique Aimé Césaire International Airport', 16, 14.5909996032715, -61.0032005310059, 10826).
airport('PTP', 'Pointe-à-Pitre Le Raizet', 36, 16.2653007507324, -61.5317993164062, 11499).
airport('GND', 'Point Salines International Airport', 41, 12.0041999816895, -61.7862014770508, 9003).
airport('STX', 'Henry E Rohlsen Airport', 74, 17.7019004821777, -64.7985992431641, 10004).
airport('SKB', 'Robert L. Bradshaw International Airport', 170, 17.3111991882324, -62.7187004089355, 7602).
airport('DKR', 'Léopold Sédar Senghor International Airport', 85, 14.7397003173828, -17.4902000427246, 11450).
airport('DKR', 'Léopold Sédar Senghor International Airport', 85, 14.7397003173828, -17.4902000427246, 10950).
airport('BUR', 'Bob Hope Airport', 778, 34.2006988525391, -118.359001159668, 6886).
airport('BUR', 'Bob Hope Airport', 778, 34.2006988525391, -118.359001159668, 6386).
airport('AZS', 'Samaná El Catey International Airport', 30, 19.2670001984, -69.7419967651, 9843).
airport('PSE', 'Mercedita Airport', 29, 18.00830078125, -66.5630035400391, 6904).
airport('ACY', 'Atlantic City International Airport', 75, 39.4575996398926, -74.5772018432617, 10000).
airport('ACY', 'Atlantic City International Airport', 75, 39.4575996398926, -74.5772018432617, 9500).
airport('ABE', 'Lehigh Valley International Airport', 393, 40.652099609375, -75.440803527832, 7600).
airport('ABE', 'Lehigh Valley International Airport', 393, 40.652099609375, -75.440803527832, 7100).
airport('ABY', 'Southwest Georgia Regional Airport', 197, 31.5354995727539, -84.1945037841797, 6601).
airport('ABY', 'Southwest Georgia Regional Airport', 197, 31.5354995727539, -84.1945037841797, 6101).
airport('ATW', 'Appleton International Airport', 918, 44.2580986023, -88.5190963745, 8002).
airport('ATW', 'Appleton International Airport', 918, 44.2580986023, -88.5190963745, 7502).
airport('AVP', 'Wilkes Barre Scranton International Airport', 962, 41.3385009766, -75.7233963013, 7501).
airport('AVP', 'Wilkes Barre Scranton International Airport', 962, 41.3385009766, -75.7233963013, 7001).
airport('AZO', 'Kalamazoo Battle Creek International Airport', 874, 42.2349014282227, -85.5521011352539, 6500).
airport('AZO', 'Kalamazoo Battle Creek International Airport', 874, 42.2349014282227, -85.5521011352539, 6000).
airport('AZO', 'Kalamazoo Battle Creek International Airport', 874, 42.2349014282227, -85.5521011352539, 5500).
airport('BQK', 'Brunswick Golden Isles Airport', 26, 31.2588005065918, -81.4664993286133, 8001).
airport('CHO', 'Charlottesville Albemarle Airport', 639, 38.138599395752, -78.4529037475586, 6001).
airport('CSG', 'Columbus Metropolitan Airport', 397, 32.516300201416, -84.9389038085938, 6997).
airport('CSG', 'Columbus Metropolitan Airport', 397, 32.516300201416, -84.9389038085938, 6497).
airport('DAB', 'Daytona Beach International Airport', 34, 29.1798992156982, -81.0580978393555, 10500).
airport('DAB', 'Daytona Beach International Airport', 34, 29.1798992156982, -81.0580978393555, 10000).
airport('DAB', 'Daytona Beach International Airport', 34, 29.1798992156982, -81.0580978393555, 9500).
airport('DHN', 'Dothan Regional Airport', 401, 31.3213005065918, -85.4496002197266, 8498).
airport('DHN', 'Dothan Regional Airport', 401, 31.3213005065918, -85.4496002197266, 7998).
airport('EWN', 'Coastal Carolina Regional Airport', 18, 35.0730018616, -77.0429000854, 6004).
airport('EWN', 'Coastal Carolina Regional Airport', 18, 35.0730018616, -77.0429000854, 5504).
airport('FNT', 'Bishop International Airport', 782, 42.9654006958008, -83.7435989379883, 7849).
airport('FNT', 'Bishop International Airport', 782, 42.9654006958008, -83.7435989379883, 7349).
airport('GTR', 'Golden Triangle Regional Airport', 264, 33.4502983093, -88.5914001465, 8002).
airport('LWB', 'Greenbrier Valley Airport', 2302, 37.8582992554, -80.3994979858, 7004).
airport('MBS', 'MBS International Airport', 668, 43.532901763916, -84.0795974731445, 8002).
airport('MBS', 'MBS International Airport', 668, 43.532901763916, -84.0795974731445, 7502).
airport('MCN', 'Middle Georgia Regional Airport', 354, 32.692798614502, -83.6492004394531, 6501).
airport('MCN', 'Middle Georgia Regional Airport', 354, 32.692798614502, -83.6492004394531, 6001).
airport('MEI', 'Key Field', 297, 32.3325996398926, -88.7518997192383, 10003).
airport('MEI', 'Key Field', 297, 32.3325996398926, -88.7518997192383, 9503).
airport('MLB', 'Melbourne International Airport', 33, 28.1028003692627, -80.6453018188477, 10181).
airport('MLB', 'Melbourne International Airport', 33, 28.1028003692627, -80.6453018188477, 9681).
airport('MLB', 'Melbourne International Airport', 33, 28.1028003692627, -80.6453018188477, 9181).
airport('MSL', 'Northwest Alabama Regional Airport', 551, 34.74530029, -87.61019897, 6693).
airport('MSL', 'Northwest Alabama Regional Airport', 551, 34.74530029, -87.61019897, 6193).
airport('PHF', 'Newport News Williamsburg International Airport', 42, 37.13190079, -76.49299622, 8003).
airport('PHF', 'Newport News Williamsburg International Airport', 42, 37.13190079, -76.49299622, 7503).
airport('PIB', 'Hattiesburg Laurel Regional Airport', 298, 31.4671001434326, -89.3370971679688, 6501).
airport('SBN', 'South Bend Regional Airport', 799, 41.7086982727051, -86.3172988891602, 8412).
airport('SBN', 'South Bend Regional Airport', 799, 41.7086982727051, -86.3172988891602, 7912).
airport('SBN', 'South Bend Regional Airport', 799, 41.7086982727051, -86.3172988891602, 7412).
airport('TRI', 'Tri Cities Regional Tn Va Airport', 1519, 36.4752006530762, -82.4074020385742, 8030).
airport('TRI', 'Tri Cities Regional Tn Va Airport', 1519, 36.4752006530762, -82.4074020385742, 7530).
airport('TTN', 'Trenton Mercer Airport', 213, 40.2766990661621, -74.8134994506836, 6006).
airport('TTN', 'Trenton Mercer Airport', 213, 40.2766990661621, -74.8134994506836, 5506).
airport('TUP', 'Tupelo Regional Airport', 346, 34.2681007385254, -88.7698974609375, 6500).
airport('VLD', 'Valdosta Regional Airport', 203, 30.7824993133545, -83.2767028808594, 6302).
airport('VLD', 'Valdosta Regional Airport', 203, 30.7824993133545, -83.2767028808594, 5802).
airport('VLD', 'Valdosta Regional Airport', 203, 30.7824993133545, -83.2767028808594, 5302).
airport('KIR', 'Kerry Airport', 112, 52.1809005737305, -9.52377986907959, 6562).
airport('KIR', 'Kerry Airport', 112, 52.1809005737305, -9.52377986907959, 6062).
airport('KTW', 'Katowice International Airport', 995, 50.4743003845, 19.0799999237, 9183).
airport('LUZ', 'Lublin Airport', 633, 51.240278, 22.713611, 8268).
airport('PPT', "Tahiti Faa'a International Airport", 5, -17.5536994934, -149.606994629, 11360).
airport('LNY', 'Lanai Airport', 1308, 20.7856006622314, -156.95100402832, 5001).
airport('KOA', 'Kona International At Keahole Airport', 47, 19.7388000488281, -156.046005249023, 11000).
airport('APW', 'Faleolo International Airport', 58, -13.8299999237061, -172.007995605469, 9843).
airport('PPG', 'Pago Pago International Airport', 32, -14.3310003281, -170.710006714, 10000).
airport('PPG', 'Pago Pago International Airport', 32, -14.3310003281, -170.710006714, 9500).
airport('MAJ', 'Marshall Islands International Airport', 6, 7.06476020812988, 171.272003173828, 7897).
airport('CXI', 'Kiritimati (Christmas Island) - Cassidy International Airport', 5, 1.98616003990173, -157.350006103516, 6900).
airport('TRW', 'Bonriki International Airport', 9, 1.38163995742798, 173.147003173828, 6598).
airport('INU', 'Nauru International Airport', 22, -0.547458, 166.919006, 7054).
airport('JHM', 'Kapalua Airport', 256, 20.9629001617432, -156.673004150391, 3000).
airport('MKK', 'Molokai Airport', 454, 21.1529006958008, -157.095993041992, 4494).
airport('MKK', 'Molokai Airport', 454, 21.1529006958008, -157.095993041992, 3994).
airport('YXU', 'London Airport', 912, 43.0355987549, -81.1539001465, 8800).
airport('YXU', 'London Airport', 912, 43.0355987549, -81.1539001465, 8300).
airport('ALO', 'Waterloo Regional Airport', 873, 42.5570983886719, -92.4002990722656, 8400).
airport('ALO', 'Waterloo Regional Airport', 873, 42.5570983886719, -92.4002990722656, 7900).
airport('ALO', 'Waterloo Regional Airport', 873, 42.5570983886719, -92.4002990722656, 7400).
airport('SUX', 'Sioux Gateway Col. Bud Day Field', 1098, 42.40259933, -96.38439941, 9002).
airport('SUX', 'Sioux Gateway Col. Bud Day Field', 1098, 42.40259933, -96.38439941, 8502).
airport('YKF', 'Waterloo Airport', 1055, 43.4608001709, -80.3786010742, 7002).
airport('YKF', 'Waterloo Airport', 1055, 43.4608001709, -80.3786010742, 6502).
airport('VNO', 'Vilnius International Airport', 646, 54.6341018676758, 25.2858009338379, 8251).
airport('AGR', 'Agra Airport', 551, 27.1557998657227, 77.9608993530273, 9000).
airport('AGR', 'Agra Airport', 551, 27.1557998657227, 77.9608993530273, 8500).
airport('HJR', 'Khajuraho Airport', 728, 24.817199707, 79.9186019897, 7460).
airport('VNS', 'Lal Bahadur Shastri Airport', 266, 25.4524002075, 82.8592987061, 7238).
airport('VVO', 'Vladivostok International Airport', 46, 43.398998260498, 132.147994995117, 11483).
airport('VVO', 'Vladivostok International Airport', 46, 43.398998260498, 132.147994995117, 10983).
airport('VVO', 'Vladivostok International Airport', 46, 43.398998260498, 132.147994995117, 10483).
airport('VVO', 'Vladivostok International Airport', 46, 43.398998260498, 132.147994995117, 9983).
airport('BOJ', 'Burgas Airport', 135, 42.5695991516113, 27.5151996612549, 10499).
airport('IXE', 'Mangalore International Airport', 337, 12.9612998962, 74.8900985718, 5300).
airport('IXE', 'Mangalore International Airport', 337, 12.9612998962, 74.8900985718, 4800).
airport('REU', 'Reus Air Base', 233, 41.1473999023438, 1.16717004776001, 8054).
airport('REU', 'Reus Air Base', 233, 41.1473999023438, 1.16717004776001, 7554).
airport('BZR', 'Béziers-Vias Airport', 56, 43.3235015869141, 3.35389995574951, 5971).
airport('AMD', 'Sardar Vallabhbhai Patel International Airport', 189, 23.0771999359, 72.6346969604, 11447).
airport('JDH', 'Jodhpur Airport', 717, 26.2511005401611, 73.0488967895508, 9005).
airport('PNQ', 'Pune Airport', 1942, 18.5820999145508, 73.9197006225586, 8329).
airport('PNQ', 'Pune Airport', 1942, 18.5820999145508, 73.9197006225586, 7829).
airport('SZX', "Shenzhen Bao'an International Airport", 13, 22.6392993927002, 113.810997009277, 11155).
airport('HIJ', 'Hiroshima Airport', 1088, 34.4361000061, 132.919006348, 9842).
airport('DIL', 'Presidente Nicolau Lobato International Airport', 154, -8.54640007019, 125.526000977, 6065).
airport('TSN', 'Tianjin Binhai International Airport', 10, 39.1244010925, 117.346000671, 10499).
airport('CSX', 'Changsha Huanghua International Airport', 217, 28.1891994476, 113.220001221, 8530).
airport('PEN', 'Penang International Airport', 11, 5.29714012145996, 100.277000427246, 10997).
airport('WUH', 'Wuhan Tianhe International Airport', 113, 30.7838001251221, 114.208000183105, 11155).
airport('HAK', 'Haikou Meilan International Airport', 75, 19.9349002838135, 110.458999633789, 11811).
airport('KMG', 'Kunming Wujiaba International Airport', 6217, 24.9923992156982, 102.744003295898, 11155).
airport('FOC', 'Fuzhou Changle International Airport', 46, 25.9351005554199, 119.66300201416, 11841).
airport('NGB', 'Ningbo Lishe International Airport', 13, 29.8267002105713, 121.46199798584, 10499).
airport('TAO', 'Liuting Airport', 33, 36.2661018372, 120.374000549, 11155).
airport('CKG', 'Chongqing Jiangbei International Airport', 1365, 29.7192001342773, 106.641998291016, 10499).
airport('KWE', 'Longdongbao Airport', 3736, 26.5384998321533, 106.801002502441, 10500).
airport('NNG', 'Nanning Wuxu Airport', 421, 22.6082992553711, 108.171997070312, 8858).
airport('KOJ', 'Kagoshima Airport', 906, 31.8034000396729, 130.718994140625, 9840).
airport('OIT', 'Oita Airport', 19, 33.4794006348, 131.736999512, 9840).
airport('KMQ', 'Komatsu Airport', 36, 36.3945999145508, 136.406997680664, 8876).
airport('KMQ', 'Komatsu Airport', 36, 36.3945999145508, 136.406997680664, 8376).
airport('YGJ', 'Miho Yonago Airport', 20, 35.4921989440918, 133.235992431641, 6560).
airport('MYJ', 'Matsuyama Airport', 25, 33.8272018432617, 132.699996948242, 8200).
airport('TAK', 'Takamatsu Airport', 607, 34.2141990662, 134.01600647, 8200).
airport('KIJ', 'Niigata Airport', 29, 37.9558982849, 139.121002197, 8200).
airport('KIJ', 'Niigata Airport', 29, 37.9558982849, 139.121002197, 7700).
airport('SDJ', 'Sendai Airport', 15, 38.1397018433, 140.917007446, 9842).
airport('SDJ', 'Sendai Airport', 15, 38.1397018433, 140.917007446, 9342).
airport('CJU', 'Jeju International Airport', 118, 33.5112991333008, 126.49299621582, 9843).
airport('CJU', 'Jeju International Airport', 118, 33.5112991333008, 126.49299621582, 9343).
airport('PUS', 'Gimhae International Airport', 6, 35.1795005798, 128.93800354, 10499).
airport('PUS', 'Gimhae International Airport', 6, 35.1795005798, 128.93800354, 9999).
airport('OKA', 'Naha Airport', 12, 26.1958007812, 127.646003723, 9840).
airport('SPN', 'Saipan International Airport', 215, 15.1190004349, 145.729003906, 8700).
airport('ROR', 'Babelthuap Airport', 176, 7.36765003204346, 134.544006347656, 7200).
airport('RGN', 'Yangon International Airport', 109, 16.9073009491, 96.1332015991, 11200).
airport('DMK', 'Don Mueang International Airport', 9, 13.9125995636, 100.607002258, 12139).
airport('DMK', 'Don Mueang International Airport', 9, 13.9125995636, 100.607002258, 11639).
airport('CNX', 'Chiang Mai International Airport', 1036, 18.7667999268, 98.962600708, 10171).
airport('KBV', 'Krabi Airport', 82, 8.09912014008, 98.9861984253, 9842).
airport('USM', 'Samui Airport', 64, 9.54778957367, 100.06199646, 6759).
airport('HDY', 'Hat Yai International Airport', 90, 6.93320989609, 100.392997742, 10007).
airport('DAD', 'Da Nang International Airport', 33, 16.0438995361328, 108.198997497559, 10000).
airport('DAD', 'Da Nang International Airport', 33, 16.0438995361328, 108.198997497559, 9500).
airport('BWN', 'Brunei International Airport', 73, 4.94420003890991, 114.928001403809, 12000).
airport('CEB', 'Mactan Cebu International Airport', 31, 10.3074998855591, 123.978996276855, 10827).
airport('ULN', 'Chinggis Khaan International Airport', 4364, 47.8431015014648, 106.766998291016, 10170).
airport('ULN', 'Chinggis Khaan International Airport', 4364, 47.8431015014648, 106.766998291016, 9670).
airport('MFM', 'Macau International Airport', 20, 22.1495990753174, 113.592002868652, 10544).
airport('BPN', 'Sultan Aji Muhamad Sulaiman Airport', 12, -1.26827001572, 116.893997192, 8185).
airport('BKI', 'Kota Kinabalu International Airport', 10, 5.93721008300781, 116.051002502441, 9800).
airport('CRK', 'Clark International Airport', 484, 15.1859998703, 120.559997559, 10499).
airport('CRK', 'Clark International Airport', 484, 15.1859998703, 120.559997559, 9999).
airport('KBR', 'Sultan Ismail Petra Airport', 16, 6.16685009002686, 102.292999267578, 6982).
airport('ILO', 'Iloilo International Airport', 27, 10.833017, 122.493358, 6890).
airport('REP', 'Siem Reap International Airport', 60, 13.4106998444, 103.81300354, 8366).
airport('KHV', 'Khabarovsk-Novy Airport', 244, 48.5279998779297, 135.188003540039, 13124).
airport('KHV', 'Khabarovsk-Novy Airport', 244, 48.5279998779297, 135.188003540039, 12624).
airport('UUS', 'Yuzhno-Sakhalinsk Airport', 59, 46.8886985778809, 142.718002319336, 11155).
airport('CGQ', 'Longjia Airport', 706, 43.9962005615, 125.684997559, 10500).
airport('DLC', 'Zhoushuizi Airport', 107, 38.9656982421875, 121.539001464844, 10827).
airport('SHE', 'Taoxian Airport', 198, 41.6398010253906, 123.483001708984, 10499).
airport('KCH', 'Kuching International Airport', 89, 1.48469996452332, 110.34700012207, 8051).
airport('MYY', 'Miri Airport', 59, 4.3220100402832, 113.986999511719, 9006).
airport('KUA', 'Kuantan Airport', 58, 3.77538990974426, 103.208999633789, 9200).
airport('IPH', 'Sultan Azlan Shah Airport', 130, 4.56796979904175, 101.092002868652, 5900).
airport('LGK', 'Langkawi International Airport', 29, 6.32973003387451, 99.7286987304688, 12500).
airport('TGG', 'Sultan Mahmud Airport', 21, 5.38263988494873, 103.102996826172, 6600).
airport('SZB', 'Sultan Abdul Aziz Shah International Airport', 90, 3.13057994842529, 101.549003601074, 12401).
airport('SHJ', 'Sharjah International Airport', 111, 25.3285999298096, 55.5172004699707, 13320).
airport('ADE', 'Aden International Airport', 7, 12.8295001983643, 45.0288009643555, 10171).
airport('CJB', 'Coimbatore International Airport', 1324, 11.029999733, 77.0434036255, 8480).
airport('COK', 'Cochin International Airport', 30, 10.1520004272, 76.4019012451, 11155).
airport('VAR', 'Varna Airport', 230, 43.2321014404297, 27.8250999450684, 8202).
airport('TRV', 'Trivandrum International Airport', 15, 8.48211956024, 76.9200973511, 11148).
airport('DVO', 'Francisco Bangoy International Airport', 96, 7.1255202293396, 125.646003723145, 9842).
airport('VTE', 'Wattay International Airport', 564, 17.9883003235, 102.56300354, 9843).
airport('SUB', 'Juanda International Airport', 9, -7.37982988357544, 112.787002563477, 9843).
airport('BDO', 'Husein Sastranegara International Airport', 2436, -6.90062999725342, 107.575996398926, 7361).
airport('LOP', 'Bandara International Lombok Airport', 319, -8.757322, 116.276675, 9000).
airport('KLO', 'Kalibo International Airport', 14, 11.679400444, 122.375999451, 7175).
airport('PKU', 'Sultan Syarif Kasim Ii (Simpang Tiga) Airport', 102, 0.460786014795303, 101.444999694824, 7360).
airport('PLM', 'Sultan Mahmud Badaruddin Ii Airport', 49, -2.89825010299683, 104.699996948242, 8202).
airport('SOC', 'Adi Sumarmo Wiryokusumo Airport', 421, -7.51608991622925, 110.75700378418, 8530).
airport('SRG', 'Achmad Yani Airport', 10, -6.97273015975952, 110.375, 6070).
airport('UPG', 'Hasanuddin International Airport', 47, -5.06162977218628, 119.554000854492, 8202).
airport('UPG', 'Hasanuddin International Airport', 47, -5.06162977218628, 119.554000854492, 7702).
airport('TRZ', 'Tiruchirapally Civil Airport Airport', 288, 10.7653999328613, 78.7097015380859, 6115).
airport('TRZ', 'Tiruchirapally Civil Airport Airport', 288, 10.7653999328613, 78.7097015380859, 5615).
airport('SAH', "Sana'a International Airport", 7216, 15.476300239563, 44.2196998596191, 10669).
airport('JOG', 'Adi Sutjipto International Airport', 350, -7.78817987442017, 110.431999206543, 7215).
airport('JOG', 'Adi Sutjipto International Airport', 350, -7.78817987442017, 110.431999206543, 6715).
airport('DIU', 'Diu Airport', 31, 20.7131004333496, 70.9210968017578, 5980).
airport('DIU', 'Diu Airport', 31, 20.7131004333496, 70.9210968017578, 5480).
airport('PBD', 'Porbandar Airport', 23, 21.6487007141, 69.6572036743, 4500).
airport('NOU', 'La Tontouta International Airport', 52, -22.0146007537842, 166.212997436523, 10663).
airport('TSA', 'Taipei Songshan Airport', 18, 25.0694007873535, 121.552001953125, 8547).
airport('SHM', 'Nanki Shirahama Airport', 298, 33.6622009277, 135.363998413, 6560).
airport('SHM', 'Nanki Shirahama Airport', 298, 33.6622009277, 135.363998413, 6060).
airport('UKB', 'Kobe Airport', 22, 34.6328010559082, 135.223999023438, 8202).
airport('OBO', 'Tokachi-Obihiro Airport', 505, 42.7332992554, 143.216995239, 8202).
airport('HKD', 'Hakodate Airport', 151, 41.7700004578, 140.822006226, 9842).
airport('KUH', 'Kushiro Airport', 327, 43.0410003662, 144.192993164, 8202).
airport('MMB', 'Memanbetsu Airport', 135, 43.8805999756, 144.164001465, 8202).
airport('SHB', 'Nakashibetsu Airport', 234, 43.5774993896, 144.960006714, 6560).
airport('WKJ', 'Wakkanai Airport', 30, 45.4042015076, 141.800994873, 6560).
airport('UBJ', 'Yamaguchi Ube Airport', 23, 33.9300003052, 131.279006958, 8200).
airport('MBE', 'Monbetsu Airport', 80, 44.3039016724, 143.404006958, 6562).
airport('AKJ', 'Asahikawa Airport', 721, 43.6707992553711, 142.447006225586, 8200).
airport('KMI', 'Miyazaki Airport', 20, 31.877199173, 131.449005127, 8200).
airport('KKJ', 'Kitakyūshū Airport', 21, 33.8459014893, 131.035003662, 8202).
airport('HSG', 'Saga Airport', 6, 33.1497001648, 130.302001953, 6562).
airport('KMJ', 'Kumamoto Airport', 642, 32.8372993469238, 130.854995727539, 9840).
airport('NGS', 'Nagasaki Airport', 15, 32.9169006348, 129.914001465, 9840).
airport('NGS', 'Nagasaki Airport', 15, 32.9169006348, 129.914001465, 9340).
airport('ASJ', 'Amami Airport', 27, 28.4305992126465, 129.712997436523, 6560).
airport('TOY', 'Toyama Airport', 95, 36.6483001708984, 137.188003540039, 6562).
airport('NTQ', 'Noto Airport', 718, 37.2930984497, 136.962005615, 6562).
airport('OKJ', 'Okayama Airport', 806, 34.7569007874, 133.854995728, 9843).
airport('IZO', 'Izumo Airport', 15, 35.4136009216, 132.88999939, 6562).
airport('KCZ', 'Kōchi Ryōma Airport', 42, 33.5461006165, 133.669006348, 8203).
airport('TTJ', 'Tottori Airport', 65, 35.5301017761, 134.167007446, 6562).
airport('TKS', 'Tokushima Airport', 26, 34.1328010559, 134.606994629, 6560).
airport('IWJ', 'Iwami Airport', 184, 34.676399231, 131.789993286, 6562).
airport('AOJ', 'Aomori Airport', 664, 40.7346992492676, 140.690994262695, 9846).
airport('GAJ', 'Yamagata Airport', 353, 38.4118995667, 140.371002197, 6560).
airport('AXT', 'Akita Airport', 313, 39.6156005859375, 140.218994140625, 8200).
airport('MSJ', 'Misawa Air Base', 119, 40.7032012939, 141.367996216, 10000).
airport('ONJ', 'Odate Noshiro Airport', 292, 40.1918983459, 140.371002197, 6562).
airport('SYO', 'Shonai Airport', 86, 38.8121986389, 139.787002563, 6560).
airport('HAC', 'Hachijojima Airport', 303, 33.1150016785, 139.785995483, 6563).
airport('OIM', 'Oshima Airport', 130, 34.7820014954, 139.36000061, 5905).
airport('GMP', 'Gimpo International Airport', 58, 37.5583000183, 126.791000366, 11811).
airport('GMP', 'Gimpo International Airport', 58, 37.5583000183, 126.791000366, 11311).
airport('ISG', 'Ishigaki Airport', 93, 24.344499588, 124.18699646, 4920).
airport('MMY', 'Miyako Airport', 150, 24.7828006744, 125.294998169, 6560).
airport('SHA', 'Shanghai Hongqiao International Airport', 10, 31.1979007720947, 121.335998535156, 11154).
airport('FNI', 'Nîmes-Arles-Camargue Airport', 309, 43.7574005126953, 4.4163498878479, 8005).
airport('CRL', 'Brussels South Charleroi Airport', 614, 50.4592018127, 4.45382022858, 8366).
airport('WAT', 'Waterford Airport', 119, 52.187198638916, -7.08695983886719, 4701).
airport('RYG', 'Moss Airport, Rygge', 174, 59.3788986206, 10.7855997086, 8012).
airport('WMI', 'Modlin Airport', 341, 52.4510993958, 20.6518001556, 8202).
airport('RZE', 'Rzeszów-Jasionka Airport', 675, 50.1100006104, 22.0189990997, 10499).
airport('RZE', 'Rzeszów-Jasionka Airport', 675, 50.1100006104, 22.0189990997, 9999).
airport('PUY', 'Pula Airport', 274, 44.8935012817383, 13.9222002029419, 9678).
airport('ZAD', 'Zemunik Airport', 289, 44.1082992553711, 15.3466997146606, 8202).
airport('ZAD', 'Zemunik Airport', 289, 44.1082992553711, 15.3466997146606, 7702).
airport('BVA', 'Paris Beauvais Tillé Airport', 359, 49.4543991088867, 2.11278009414673, 7972).
airport('BVA', 'Paris Beauvais Tillé Airport', 359, 49.4543991088867, 2.11278009414673, 7472).
airport('BVA', 'Paris Beauvais Tillé Airport', 359, 49.4543991088867, 2.11278009414673, 6972).
airport('TPS', 'Vincenzo Florio Airport Trapani-Birgi', 25, 37.9113998413, 12.4879999161, 8852).
airport('BGY', 'Il Caravaggio International Airport', 782, 45.6739006042, 9.70417022705, 9636).
airport('BGY', 'Il Caravaggio International Airport', 782, 45.6739006042, 9.70417022705, 9136).
airport('CIA', 'Ciampino–G. B. Pastine International Airport', 427, 41.7994003296, 12.5949001312, 7242).
airport('CCC', 'Jardines Del Rey Airport', 13, 22.4610004425, -78.3283996582, 9842).
airport('DJE', 'Djerba Zarzis International Airport', 19, 33.875, 10.7755002975464, 10171).
airport('HDF', 'Heringsdorf Airport', 93, 53.8787002563, 14.152299881, 7562).
airport('HDF', 'Heringsdorf Airport', 93, 53.8787002563, 14.152299881, 7062).
airport('FMO', 'Münster Osnabrück Airport', 160, 52.134601593, 7.68483018875, 7119).
airport('FDH', 'Friedrichshafen Airport', 1367, 47.6712989807, 9.51148986816, 7729).
airport('GWT', 'Westerland Sylt Airport', 51, 54.9132003784, 8.34047031403, 6955).
airport('GWT', 'Westerland Sylt Airport', 51, 54.9132003784, 8.34047031403, 6455).
airport('POZ', 'Poznań-Ławica Airport', 308, 52.4210014343, 16.8262996674, 8215).
airport('POZ', 'Poznań-Ławica Airport', 308, 52.4210014343, 16.8262996674, 7715).
airport('WDH', 'Hosea Kutako International Airport', 5640, -22.4799003601074, 17.4708995819092, 15010).
airport('WDH', 'Hosea Kutako International Airport', 5640, -22.4799003601074, 17.4708995819092, 14510).
airport('XRY', 'Jerez Airport', 93, 36.7445983886719, -6.06011009216309, 7546).
airport('GPA', 'Araxos Airport', 46, 38.1511001586914, 21.4256000518799, 10999).
airport('GPA', 'Araxos Airport', 46, 38.1511001586914, 21.4256000518799, 10499).
airport('GRZ', 'Graz Airport', 1115, 46.9911003112793, 15.4395999908447, 9842).
airport('GRZ', 'Graz Airport', 1115, 46.9911003112793, 15.4395999908447, 9342).
airport('GRZ', 'Graz Airport', 1115, 46.9911003112793, 15.4395999908447, 8842).
airport('LNZ', 'Linz Airport', 978, 48.2332000732422, 14.1875, 9843).
airport('LNZ', 'Linz Airport', 978, 48.2332000732422, 14.1875, 9343).
airport('ESB', 'Esenboğa International Airport', 3125, 40.1281013489, 32.995098114, 12303).
airport('ESB', 'Esenboğa International Airport', 3125, 40.1281013489, 32.995098114, 11803).
airport('KIV', 'Chişinău International Airport', 399, 46.9277000427246, 28.9309997558594, 11779).
airport('TGD', 'Podgorica Airport', 141, 42.3594017028809, 19.2518997192383, 8202).
airport('TGD', 'Podgorica Airport', 141, 42.3594017028809, 19.2518997192383, 7702).
airport('OVB', 'Tolmachevo Airport', 365, 55.0125999450684, 82.6507034301758, 11818).
airport('OVB', 'Tolmachevo Airport', 365, 55.0125999450684, 82.6507034301758, 11318).
airport('DYU', 'Dushanbe Airport', 2575, 38.5433006287, 68.8249969482, 10170).
airport('GOJ', 'Nizhny Novgorod International Airport', 256, 56.2300987243652, 43.7840003967285, 9203).
airport('GOJ', 'Nizhny Novgorod International Airport', 256, 56.2300987243652, 43.7840003967285, 8703).
airport('GOJ', 'Nizhny Novgorod International Airport', 256, 56.2300987243652, 43.7840003967285, 8203).
airport('GOJ', 'Nizhny Novgorod International Airport', 256, 56.2300987243652, 43.7840003967285, 7703).
airport('KUF', 'Kurumoch International Airport', 477, 53.5049018859863, 50.1642990112305, 9846).
airport('KUF', 'Kurumoch International Airport', 477, 53.5049018859863, 50.1642990112305, 9346).
airport('LUN', 'Lusaka International Airport', 3779, -15.3308000565, 28.4526004791, 12998).
airport('LUN', 'Lusaka International Airport', 3779, -15.3308000565, 28.4526004791, 12498).
airport('HGA', 'Egal International Airport', 4423, 9.51817035675049, 44.0887985229492, 8000).
airport('BBO', 'Berbera Airport', 30, 10.3892002105713, 44.9411010742188, 13582).
airport('JIB', 'Djibouti-Ambouli Airport', 49, 11.5473003387451, 43.1595001220703, 10335).
airport('HBE', 'Borg El Arab International Airport', 177, 30.9176998138428, 29.6963996887207, 11156).
airport('HBE', 'Borg El Arab International Airport', 177, 30.9176998138428, 29.6963996887207, 10656).
airport('HBE', 'Borg El Arab International Airport', 177, 30.9176998138428, 29.6963996887207, 10156).
airport('PZU', 'Port Sudan New International Airport', 135, 19.4335994720459, 37.2341003417969, 8202).
airport('JUB', 'Juba International Airport', 1513, 4.87201023102, 31.6011009216, 7874).
airport('KRT', 'Khartoum International Airport', 1265, 15.5895004272461, 32.5531997680664, 9751).
airport('DAR', 'Julius Nyerere International Airport', 182, -6.87810993195, 39.2025985718, 9843).
airport('DAR', 'Julius Nyerere International Airport', 182, -6.87810993195, 39.2025985718, 9343).
airport('GSM', 'Gheshm Airport', 45, 26.9486999511719, 56.268798828125, 13861).
airport('SKP', 'Skopje Alexander the Great Airport', 781, 41.9616012573242, 21.6214008331299, 8038).
airport('KBL', 'Kabul International Airport', 5877, 34.5658988952637, 69.2123031616211, 11483).
airport('BTS', 'M. R. Štefánik Airport', 436, 48.1702003479004, 17.2126998901367, 10466).
airport('BTS', 'M. R. Štefánik Airport', 436, 48.1702003479004, 17.2126998901367, 9966).
airport('DLA', 'Douala International Airport', 33, 4.0060801506, 9.71947956085, 9350).
airport('AAE', 'Annaba Airport', 16, 36.8222007751465, 7.80916976928711, 9843).
airport('AAE', 'Annaba Airport', 16, 36.8222007751465, 7.80916976928711, 9343).
airport('CZL', 'Mohamed Boudiaf International Airport', 2265, 36.2760009765625, 6.62038993835449, 9843).
airport('CZL', 'Mohamed Boudiaf International Airport', 2265, 36.2760009765625, 6.62038993835449, 9343).
airport('ORN', 'Es Senia Airport', 295, 35.6239013672, -0.621182978153, 10039).
airport('COO', 'Cadjehoun Airport', 19, 6.3572301864624, 2.38435006141663, 7874).
airport('OUA', 'Ouagadougou Airport', 1037, 12.3531999588013, -1.51242005825043, 9934).
airport('OUA', 'Ouagadougou Airport', 1037, 12.3531999588013, -1.51242005825043, 9434).
airport('ABJ', 'Port Bouet Airport', 21, 5.261390209198, -3.9262900352478, 9843).
airport('NIM', 'Diori Hamani International Airport', 732, 13.481499671936, 2.18360996246338, 9843).
airport('NIM', 'Diori Hamani International Airport', 732, 13.481499671936, 2.18360996246338, 9343).
airport('NIM', 'Diori Hamani International Airport', 732, 13.481499671936, 2.18360996246338, 8843).
airport('MIR', 'Monastir Habib Bourguiba International Airport', 9, 35.7580986022949, 10.7546997070312, 9678).
airport('SFA', 'Sfax Thyna International Airport', 85, 34.7179985046387, 10.6909999847412, 9843).
airport('LFW', 'Lomé-Tokoin Airport', 72, 6.16560983657837, 1.25451004505157, 9847).
airport('BZV', 'Maya-Maya Airport', 1048, -4.25169992446899, 15.2530002593994, 10827).
airport('PNR', 'Pointe Noire Airport', 55, -4.81603002548218, 11.8865995407104, 8530).
airport('BGF', "Bangui M'Poko International Airport", 1208, 4.39847993850708, 18.5188007354736, 8530).
airport('NSI', 'Yaoundé Nsimalen International Airport', 2278, 3.72255992889404, 11.5532999038696, 11155).
airport('RUN', 'Roland Garros Airport', 66, -20.8871002197266, 55.5102996826172, 10499).
airport('RUN', 'Roland Garros Airport', 66, -20.8871002197266, 55.5102996826172, 9999).
airport('TNR', 'Ivato Airport', 4198, -18.7968997955, 47.4788017273, 10171).
airport('LBV', "Libreville Leon M'ba International Airport", 39, 0.458600014448, 9.4122800827, 9844).
airport('NDJ', "N'Djamena International Airport", 968, 12.1337003707886, 15.0340003967285, 9186).
airport('FIH', 'Ndjili International Airport', 1027, -4.38574981689, 15.4446001053, 15420).
airport('BKO', 'Senou Airport', 1247, 12.5334997177124, -7.94994020462036, 8879).
airport('ROB', 'Roberts International Airport', 31, 6.23378992080688, -10.3622999191284, 11000).
airport('RBA', 'Rabat-Salé Airport', 276, 34.0514984130859, -6.75152015686035, 11483).
airport('NKC', 'Nouakchott International Airport', 13, 18.0981998443604, -15.9484996795654, 9876).
airport('CKY', 'Conakry Airport', 72, 9.57689, -13.612, 10826).
airport('RAI', 'Praia International Airport', 230, 14.9245004653931, -23.4934997558594, 6876).
airport('RAI', 'Praia International Airport', 230, 14.9245004653931, -23.4934997558594, 6376).
airport('RAI', 'Praia International Airport', 230, 14.9245004653931, -23.4934997558594, 5876).
airport('OVD', 'Asturias Airport', 416, 43.5635986328125, -6.03461980819702, 7218).
airport('VGO', 'Vigo Airport', 856, 42.2318000793457, -8.62677001953125, 7874).
airport('PUF', 'Pau Pyrénées Airport', 616, 43.3800010681152, -0.418610990047455, 8202).
airport('BIQ', 'Biarritz-Anglet-Bayonne Airport', 245, 43.4683990478516, -1.5233199596405, 7382).
airport('CLY', 'Calvi-Sainte-Catherine Airport', 209, 42.5307998657227, 8.79319000244141, 7579).
airport('RNS', 'Rennes-Saint-Jacques Airport', 124, 48.0694999695, -1.73478996754, 6890).
airport('RNS', 'Rennes-Saint-Jacques Airport', 124, 48.0694999695, -1.73478996754, 6390).
airport('OSR', 'Ostrava Leos Janáček Airport', 844, 49.6963005065918, 18.1110992431641, 11484).
airport('EVN', 'Zvartnots International Airport', 2838, 40.1473007202, 44.3959007263, 12629).
airport('SVX', 'Koltsovo Airport', 764, 56.7430992126465, 60.8027000427246, 9925).
airport('SVX', 'Koltsovo Airport', 764, 56.7430992126465, 60.8027000427246, 9425).
airport('UGC', 'Urgench Airport', 320, 41.584300994873, 60.6417007446289, 11065).
airport('YYJ', 'Victoria International Airport', 63, 48.646900177, -123.426002502, 7000).
airport('YYJ', 'Victoria International Airport', 63, 48.646900177, -123.426002502, 6500).
airport('YYJ', 'Victoria International Airport', 63, 48.646900177, -123.426002502, 6000).
airport('ACV', 'Arcata Airport', 221, 40.978099822998, -124.109001159668, 6000).
airport('ACV', 'Arcata Airport', 221, 40.978099822998, -124.109001159668, 5500).
airport('BFL', 'Meadows Field', 510, 35.43360138, -119.0569992, 10857).
airport('BFL', 'Meadows Field', 510, 35.43360138, -119.0569992, 10357).
airport('CEC', 'Jack Mc Namara Field Airport', 61, 41.78020096, -124.2369995, 5002).
airport('CEC', 'Jack Mc Namara Field Airport', 61, 41.78020096, -124.2369995, 4502).
airport('CIC', 'Chico Municipal Airport', 240, 39.79539871, -121.8580017, 6724).
airport('CIC', 'Chico Municipal Airport', 240, 39.79539871, -121.8580017, 6224).
airport('EUG', 'Mahlon Sweet Field', 374, 44.1245994567871, -123.21199798584, 8009).
airport('EUG', 'Mahlon Sweet Field', 374, 44.1245994567871, -123.21199798584, 7509).
airport('EUG', 'Mahlon Sweet Field', 374, 44.1245994567871, -123.21199798584, 7009).
airport('LMT', 'Klamath Falls Airport', 4095, 42.1561012268066, -121.733001708984, 10301).
airport('LMT', 'Klamath Falls Airport', 4095, 42.1561012268066, -121.733001708984, 9801).
airport('LMT', 'Klamath Falls Airport', 4095, 42.1561012268066, -121.733001708984, 9301).
airport('MFR', 'Rogue Valley International Medford Airport', 1335, 42.3741989135742, -122.873001098633, 8800).
airport('MFR', 'Rogue Valley International Medford Airport', 1335, 42.3741989135742, -122.873001098633, 8300).
airport('MOD', 'Modesto City Co-Harry Sham Field', 97, 37.62580109, -120.9540024, 5911).
airport('MOD', 'Modesto City Co-Harry Sham Field', 97, 37.62580109, -120.9540024, 5411).
airport('MRY', 'Monterey Peninsula Airport', 257, 36.5870018005371, -121.843002319336, 7616).
airport('MRY', 'Monterey Peninsula Airport', 257, 36.5870018005371, -121.843002319336, 7116).
airport('OTH', 'Southwest Oregon Regional Airport', 17, 43.4170989990234, -124.246002197266, 5321).
airport('OTH', 'Southwest Oregon Regional Airport', 17, 43.4170989990234, -124.246002197266, 4821).
airport('PSC', 'Tri Cities Airport', 410, 46.2647018432617, -119.119003295898, 7711).
airport('PSC', 'Tri Cities Airport', 410, 46.2647018432617, -119.119003295898, 7211).
airport('PSC', 'Tri Cities Airport', 410, 46.2647018432617, -119.119003295898, 6711).
airport('RDD', 'Redding Municipal Airport', 505, 40.50899887, -122.2929993, 7003).
airport('RDD', 'Redding Municipal Airport', 505, 40.50899887, -122.2929993, 6503).
airport('RDM', 'Roberts Field', 3080, 44.2541008, -121.1500015, 7040).
airport('RDM', 'Roberts Field', 3080, 44.2541008, -121.1500015, 6540).
airport('SBA', 'Santa Barbara Municipal Airport', 13, 34.42620087, -119.8399963, 6052).
airport('SBA', 'Santa Barbara Municipal Airport', 13, 34.42620087, -119.8399963, 5552).
airport('SBA', 'Santa Barbara Municipal Airport', 13, 34.42620087, -119.8399963, 5052).
airport('SBP', 'San Luis County Regional Airport', 212, 35.2368011475, -120.641998291, 6100).
airport('SBP', 'San Luis County Regional Airport', 212, 35.2368011475, -120.641998291, 5600).
airport('RMQ', 'Taichung Ching Chuang Kang Airport', 663, 24.2646999359131, 120.621002197266, 12000).
airport('TNN', 'Tainan Airport', 63, 22.9503993988037, 120.206001281738, 10007).
airport('TNN', 'Tainan Airport', 63, 22.9503993988037, 120.206001281738, 9507).
airport('TYN', 'Taiyuan Wusu Airport', 2575, 37.746898651123, 112.627998352051, 10500).
airport('YLW', 'Kelowna International Airport', 1421, 49.9561004639, -119.377998352, 8900).
airport('ASE', 'Aspen-Pitkin Co/Sardy Field', 7820, 39.22320175, -106.8690033, 7006).
airport('BLI', 'Bellingham International Airport', 170, 48.7928009033203, -122.53800201416, 6701).
airport('CLD', 'Mc Clellan-Palomar Airport', 331, 33.12829971, -117.2799988, 4897).
airport('GEG', 'Spokane International Airport', 2376, 47.6198997497559, -117.533996582031, 11002).
airport('GEG', 'Spokane International Airport', 2376, 47.6198997497559, -117.533996582031, 10502).
airport('IGM', 'Kingman Airport', 3449, 35.2594985961914, -113.938003540039, 6826).
airport('IGM', 'Kingman Airport', 3449, 35.2594985961914, -113.938003540039, 6326).
airport('IGM', 'Kingman Airport', 3449, 35.2594985961914, -113.938003540039, 5826).
airport('MCE', 'Merced Regional Macready Field', 155, 37.28469849, -120.5139999, 5903).
airport('MMH', 'Mammoth Yosemite Airport', 7135, 37.62409973, -118.8379974, 7000).
airport('YUM', 'Yuma MCAS/Yuma International Airport', 213, 32.65660095, -114.6060028, 13299).
airport('YUM', 'Yuma MCAS/Yuma International Airport', 213, 32.65660095, -114.6060028, 12799).
airport('YUM', 'Yuma MCAS/Yuma International Airport', 213, 32.65660095, -114.6060028, 12299).
airport('YUM', 'Yuma MCAS/Yuma International Airport', 213, 32.65660095, -114.6060028, 11799).
airport('PRC', 'Ernest A. Love Field', 5045, 34.65449905, -112.4199982, 7550).
airport('PRC', 'Ernest A. Love Field', 5045, 34.65449905, -112.4199982, 7050).
airport('PRC', 'Ernest A. Love Field', 5045, 34.65449905, -112.4199982, 6550).
airport('SMX', 'Santa Maria Pub/Capt G Allan Hancock Field', 261, 34.89889908, -120.4570007, 6304).
airport('SMX', 'Santa Maria Pub/Capt G Allan Hancock Field', 261, 34.89889908, -120.4570007, 5804).
airport('STS', 'Charles M. Schulz Sonoma County Airport', 128, 38.50899887, -122.8130035, 5115).
airport('STS', 'Charles M. Schulz Sonoma County Airport', 128, 38.50899887, -122.8130035, 4615).
airport('VIS', 'Visalia Municipal Airport', 295, 36.3186988831, -119.392997742, 6559).
airport('DGO', 'General Guadalupe Victoria International Airport', 6104, 24.1242008209, -104.527999878, 9514).
airport('HMO', 'General Ignacio P. Garcia International Airport', 627, 29.0958995819, -111.047996521, 7546).
airport('HMO', 'General Ignacio P. Garcia International Airport', 627, 29.0958995819, -111.047996521, 7046).
airport('LTO', 'Loreto International Airport', 34, 25.989200592041, -111.347999572754, 7218).
airport('UPN', 'Licenciado y General Ignacio Lopez Rayon Airport', 5258, 19.3966999053955, -102.039001464844, 7874).
airport('ZIH', 'Ixtapa Zihuatanejo International Airport', 26, 17.601600647, -101.460998535, 8202).
airport('ZLO', 'Playa De Oro International Airport', 30, 19.1448001862, -104.558998108, 7218).
airport('RAR', 'Rarotonga International Airport', 19, -21.2026996613, -159.805999756, 7638).
airport('TNA', 'Yaoqiang Airport', 76, 36.8572006225586, 117.216003417969, 11814).
airport('XIY', "Xi'an Xianyang International Airport", 1572, 34.4471015930176, 108.751998901367, 9842).
airport('KHN', 'Nanchang Changbei International Airport', 143, 28.8649997711182, 115.900001525879, 9186).
airport('CGO', 'Zhengzhou Xinzheng International Airport', 495, 34.5196990967, 113.841003418, 11155).
airport('YNT', 'Yantai Laishan Airport', 59, 37.4016990661621, 121.372001647949, 8530).
airport('PVU', 'Provo Municipal Airport', 4497, 40.2192001342773, -111.722999572754, 8599).
airport('PVU', 'Provo Municipal Airport', 4497, 40.2192001342773, -111.722999572754, 8099).
airport('BTM', 'Bert Mooney Airport', 5550, 45.9547996520996, -112.497001647949, 9001).
airport('BTM', 'Bert Mooney Airport', 5550, 45.9547996520996, -112.497001647949, 8501).
airport('BTM', 'Bert Mooney Airport', 5550, 45.9547996520996, -112.497001647949, 8001).
airport('BZN', 'Gallatin Field', 4473, 45.77750015, -111.1529999, 9003).
airport('BZN', 'Gallatin Field', 4473, 45.77750015, -111.1529999, 8503).
airport('BZN', 'Gallatin Field', 4473, 45.77750015, -111.1529999, 8003).
airport('CDC', 'Cedar City Regional Airport', 5622, 37.701000213623, -113.098999023438, 8653).
airport('CDC', 'Cedar City Regional Airport', 5622, 37.701000213623, -113.098999023438, 8153).
airport('CNY', 'Canyonlands Field', 4557, 38.75500107, -109.7549973, 7100).
airport('COD', 'Yellowstone Regional Airport', 5102, 44.520198822, -109.024002075, 8268).
airport('CPR', 'Casper-Natrona County International Airport', 5350, 42.90800095, -106.4639969, 10164).
airport('CPR', 'Casper-Natrona County International Airport', 5350, 42.90800095, -106.4639969, 9664).
airport('CPR', 'Casper-Natrona County International Airport', 5350, 42.90800095, -106.4639969, 9164).
airport('CPR', 'Casper-Natrona County International Airport', 5350, 42.90800095, -106.4639969, 8664).
airport('EKO', 'Elko Regional Airport', 5140, 40.8249015808105, -115.791999816895, 7214).
airport('EKO', 'Elko Regional Airport', 5140, 40.8249015808105, -115.791999816895, 6714).
airport('GCC', 'Gillette Campbell County Airport', 4365, 44.3488998413, -105.539001465, 7500).
airport('GCC', 'Gillette Campbell County Airport', 4365, 44.3488998413, -105.539001465, 7000).
airport('FCA', 'Glacier Park International Airport', 2977, 48.3105010986328, -114.255996704102, 9007).
airport('FCA', 'Glacier Park International Airport', 2977, 48.3105010986328, -114.255996704102, 8507).
airport('FCA', 'Glacier Park International Airport', 2977, 48.3105010986328, -114.255996704102, 8007).
airport('GTF', 'Great Falls International Airport', 3680, 47.48199844, -111.3710022, 10502).
airport('GTF', 'Great Falls International Airport', 3680, 47.48199844, -111.3710022, 10002).
airport('GTF', 'Great Falls International Airport', 3680, 47.48199844, -111.3710022, 9502).
airport('HLN', 'Helena Regional Airport', 3877, 46.6068000793457, -111.983001708984, 9000).
airport('HLN', 'Helena Regional Airport', 3877, 46.6068000793457, -111.983001708984, 8500).
airport('HLN', 'Helena Regional Airport', 3877, 46.6068000793457, -111.983001708984, 8000).
airport('JAC', 'Jackson Hole Airport', 6451, 43.6072998046875, -110.737998962402, 6300).
airport('LWS', 'Lewiston Nez Perce County Airport', 1442, 46.3745002746582, -117.014999389648, 6511).
airport('LWS', 'Lewiston Nez Perce County Airport', 1442, 46.3745002746582, -117.014999389648, 6011).
airport('MSO', 'Missoula International Airport', 3206, 46.91630173, -114.0910034, 9501).
airport('MSO', 'Missoula International Airport', 3206, 46.91630173, -114.0910034, 9001).
airport('PIH', 'Pocatello Regional Airport', 4452, 42.9098014831543, -112.596000671387, 9060).
airport('PIH', 'Pocatello Regional Airport', 4452, 42.9098014831543, -112.596000671387, 8560).
airport('RKS', 'Rock Springs Sweetwater County Airport', 6764, 41.59420013, -109.0650024, 10000).
airport('RKS', 'Rock Springs Sweetwater County Airport', 6764, 41.59420013, -109.0650024, 9500).
airport('SGU', 'St George Municipal Airport', 2941, 37.0363888889, -113.510305556, 6606).
airport('TWF', 'Joslin Field Magic Valley Regional Airport', 4154, 42.48180008, -114.487999, 8703).
airport('TWF', 'Joslin Field Magic Valley Regional Airport', 4154, 42.48180008, -114.487999, 8203).
airport('VEL', 'Vernal Regional Airport', 5278, 40.4408989, -109.5100021, 6201).
airport('VEL', 'Vernal Regional Airport', 5278, 40.4408989, -109.5100021, 5701).
airport('XUZ', 'Xuzhou Guanyin Airport', 115, 34.059056, 117.555278, 11548).
airport('SYX', 'Sanya Phoenix International Airport', 92, 18.3029003143311, 109.412002563477, 11155).
airport('BKG', 'Branson Airport', 1302, 36.532082, -93.200544, 7140).
airport('YMM', 'Fort McMurray Airport', 1211, 56.653301239, -111.222000122, 7503).
airport('AIA', 'Alliance Municipal Airport', 3931, 42.0531997681, -102.804000854, 9202).
airport('AIA', 'Alliance Municipal Airport', 3931, 42.0531997681, -102.804000854, 8702).
airport('AIA', 'Alliance Municipal Airport', 3931, 42.0531997681, -102.804000854, 8202).
airport('ALS', 'San Luis Valley Regional Bergman Field', 7539, 37.4348983765, -105.866996765, 8519).
airport('ALS', 'San Luis Valley Regional Bergman Field', 7539, 37.4348983765, -105.866996765, 8019).
airport('BFF', 'Western Neb. Rgnl/William B. Heilig Airport', 3967, 41.87400055, -103.5960007, 8279).
airport('BFF', 'Western Neb. Rgnl/William B. Heilig Airport', 3967, 41.87400055, -103.5960007, 7779).
airport('BIS', 'Bismarck Municipal Airport', 1661, 46.7727012634277, -100.746002197266, 8794).
airport('BIS', 'Bismarck Municipal Airport', 1661, 46.7727012634277, -100.746002197266, 8294).
airport('CEZ', 'Cortez Municipal Airport', 5918, 37.3030014038, -108.627998352, 7205).
airport('CYS', 'Cheyenne Regional Jerry Olson Field', 6159, 41.15570068, -104.8119965, 9267).
airport('CYS', 'Cheyenne Regional Jerry Olson Field', 6159, 41.15570068, -104.8119965, 8767).
airport('DDC', 'Dodge City Regional Airport', 2594, 37.7634010314941, -99.9655990600586, 6899).
airport('DDC', 'Dodge City Regional Airport', 2594, 37.7634010314941, -99.9655990600586, 6399).
airport('DIK', 'Dickinson Theodore Roosevelt Regional Airport', 2592, 46.7974014282, -102.802001953, 6400).
airport('DIK', 'Dickinson Theodore Roosevelt Regional Airport', 2592, 46.7974014282, -102.802001953, 5900).
airport('EAR', 'Kearney Regional Airport', 2131, 40.72700119, -99.00679779, 7094).
airport('EAR', 'Kearney Regional Airport', 2131, 40.72700119, -99.00679779, 6594).
airport('FMN', 'Four Corners Regional Airport', 5506, 36.7411994934, -108.230003357, 6704).
airport('FMN', 'Four Corners Regional Airport', 5506, 36.7411994934, -108.230003357, 6204).
airport('GUC', 'Gunnison Crested Butte Regional Airport', 7680, 38.53390121, -106.9329987, 9400).
airport('GUC', 'Gunnison Crested Butte Regional Airport', 7680, 38.53390121, -106.9329987, 8900).
airport('ILG', 'New Castle Airport', 80, 39.67869949, -75.60649872, 7181).
airport('ILG', 'New Castle Airport', 80, 39.67869949, -75.60649872, 6681).
airport('ILG', 'New Castle Airport', 80, 39.67869949, -75.60649872, 6181).
airport('ISN', 'Sloulin Field International Airport', 1982, 48.177898407, -103.641998291, 6650).
airport('ISN', 'Sloulin Field International Airport', 1982, 48.177898407, -103.641998291, 6150).
airport('LAR', 'Laramie Regional Airport', 7284, 41.3120994567871, -105.675003051758, 8500).
airport('LAR', 'Laramie Regional Airport', 7284, 41.3120994567871, -105.675003051758, 8000).
airport('LBF', 'North Platte Regional Airport Lee Bird Field', 2777, 41.12620163, -100.6839981, 8000).
airport('LBF', 'North Platte Regional Airport Lee Bird Field', 2777, 41.12620163, -100.6839981, 7500).
airport('LBL', 'Liberal Mid-America Regional Airport', 2885, 37.0442009, -100.9599991, 7105).
airport('LBL', 'Liberal Mid-America Regional Airport', 2885, 37.0442009, -100.9599991, 6605).
airport('LNK', 'Lincoln Airport', 1219, 40.851001739502, -96.7592010498047, 12901).
airport('LNK', 'Lincoln Airport', 1219, 40.851001739502, -96.7592010498047, 12401).
airport('LNK', 'Lincoln Airport', 1219, 40.851001739502, -96.7592010498047, 11901).
airport('MCK', 'Mc Cook Ben Nelson Regional Airport', 2583, 40.20629883, -100.5920029, 6449).
airport('MCK', 'Mc Cook Ben Nelson Regional Airport', 2583, 40.20629883, -100.5920029, 5949).
airport('MCK', 'Mc Cook Ben Nelson Regional Airport', 2583, 40.20629883, -100.5920029, 5449).
airport('MOT', 'Minot International Airport', 1716, 48.2593994140625, -101.279998779297, 7700).
airport('MOT', 'Minot International Airport', 1716, 48.2593994140625, -101.279998779297, 7200).
airport('MTJ', 'Montrose Regional Airport', 5759, 38.5097999573, -107.893997192, 10000).
airport('MTJ', 'Montrose Regional Airport', 5759, 38.5097999573, -107.893997192, 9500).
airport('PGA', 'Page Municipal Airport', 4316, 36.92610168, -111.447998, 5950).
airport('PGA', 'Page Municipal Airport', 4316, 36.92610168, -111.447998, 5450).
airport('PIR', 'Pierre Regional Airport', 1744, 44.38270187, -100.2860031, 6900).
airport('PIR', 'Pierre Regional Airport', 1744, 44.38270187, -100.2860031, 6400).
airport('PUB', 'Pueblo Memorial Airport', 4726, 38.2891006469727, -104.497001647949, 10496).
airport('PUB', 'Pueblo Memorial Airport', 4726, 38.2891006469727, -104.497001647949, 9996).
airport('PUB', 'Pueblo Memorial Airport', 4726, 38.2891006469727, -104.497001647949, 9496).
airport('PUB', 'Pueblo Memorial Airport', 4726, 38.2891006469727, -104.497001647949, 8996).
airport('RIW', 'Riverton Regional Airport', 5525, 43.064201355, -108.459999084, 8203).
airport('RIW', 'Riverton Regional Airport', 5525, 43.064201355, -108.459999084, 7703).
airport('SHR', 'Sheridan County Airport', 4021, 44.7691993713379, -106.980003356934, 8300).
airport('SHR', 'Sheridan County Airport', 4021, 44.7691993713379, -106.980003356934, 7800).
airport('SHR', 'Sheridan County Airport', 4021, 44.7691993713379, -106.980003356934, 7300).
airport('ART', 'Watertown International Airport', 325, 43.9919013977051, -76.0216979980469, 5000).
airport('ART', 'Watertown International Airport', 325, 43.9919013977051, -76.0216979980469, 4500).
airport('CMX', 'Houghton County Memorial Airport', 1095, 47.168399810791, -88.4890975952148, 6501).
airport('CMX', 'Houghton County Memorial Airport', 1095, 47.168399810791, -88.4890975952148, 6001).
airport('CWA', 'Central Wisconsin Airport', 1277, 44.7775993347, -89.6668014526, 7645).
airport('CWA', 'Central Wisconsin Airport', 1277, 44.7775993347, -89.6668014526, 7145).
airport('DBQ', 'Dubuque Regional Airport', 1077, 42.40200043, -90.70950317, 6502).
airport('DBQ', 'Dubuque Regional Airport', 1077, 42.40200043, -90.70950317, 6002).
airport('DEC', 'Decatur Airport', 682, 39.8345985412598, -88.8656997680664, 8496).
airport('DEC', 'Decatur Airport', 682, 39.8345985412598, -88.8656997680664, 7996).
airport('DEC', 'Decatur Airport', 682, 39.8345985412598, -88.8656997680664, 7496).
airport('DLH', 'Duluth International Airport', 1428, 46.8420982361, -92.1936035156, 10152).
airport('DLH', 'Duluth International Airport', 1428, 46.8420982361, -92.1936035156, 9652).
airport('EAU', 'Chippewa Valley Regional Airport', 913, 44.8657989501953, -91.4842987060547, 8101).
airport('EAU', 'Chippewa Valley Regional Airport', 913, 44.8657989501953, -91.4842987060547, 7601).
airport('ELM', 'Elmira Corning Regional Airport', 954, 42.1599006652832, -76.8916015625, 7000).
airport('ELM', 'Elmira Corning Regional Airport', 954, 42.1599006652832, -76.8916015625, 6500).
airport('ELM', 'Elmira Corning Regional Airport', 954, 42.1599006652832, -76.8916015625, 6000).
airport('LSE', 'La Crosse Municipal Airport', 655, 43.87900162, -91.25669861, 8537).
airport('LSE', 'La Crosse Municipal Airport', 655, 43.87900162, -91.25669861, 8037).
airport('LSE', 'La Crosse Municipal Airport', 655, 43.87900162, -91.25669861, 7537).
airport('MKG', 'Muskegon County Airport', 629, 43.16949844, -86.23819733, 6501).
airport('MKG', 'Muskegon County Airport', 629, 43.16949844, -86.23819733, 6001).
airport('PAH', 'Barkley Regional Airport', 410, 37.0607986450195, -88.7738037109375, 6499).
airport('PAH', 'Barkley Regional Airport', 410, 37.0607986450195, -88.7738037109375, 5999).
airport('STC', 'St Cloud Regional Airport', 1031, 45.5466003417969, -94.0598983764648, 7000).
airport('STC', 'St Cloud Regional Airport', 1031, 45.5466003417969, -94.0598983764648, 6500).
airport('TOL', 'Toledo Express Airport', 683, 41.58679962, -83.80780029, 10600).
airport('TOL', 'Toledo Express Airport', 683, 41.58679962, -83.80780029, 10100).
airport('TVC', 'Cherry Capital Airport', 624, 44.7414016723633, -85.5821990966797, 6501).
airport('TVC', 'Cherry Capital Airport', 624, 44.7414016723633, -85.5821990966797, 6001).
airport('TVC', 'Cherry Capital Airport', 624, 44.7414016723633, -85.5821990966797, 5501).
airport('SCE', 'University Park Airport', 1239, 40.8493003845, -77.8487014771, 6701).
airport('SUV', 'Nausori International Airport', 17, -18.0433006286621, 178.559005737305, 6129).
airport('TBU', "Fua'amotu International Airport", 126, -21.2411994934082, -175.149993896484, 8795).
airport('TBU', "Fua'amotu International Airport", 126, -21.2411994934082, -175.149993896484, 8295).
airport('VLI', 'Port Vila Bauerfield Airport', 70, -17.6993007659912, 168.320007324219, 8530).
airport('VLI', 'Port Vila Bauerfield Airport', 70, -17.6993007659912, 168.320007324219, 8030).
airport('ZQN', 'Queenstown International Airport', 1171, -45.0210990906, 168.738998413, 6204).
airport('ZQN', 'Queenstown International Airport', 1171, -45.0210990906, 168.738998413, 5704).
airport('ZQN', 'Queenstown International Airport', 1171, -45.0210990906, 168.738998413, 5204).
airport('ZQN', 'Queenstown International Airport', 1171, -45.0210990906, 168.738998413, 4704).
airport('ARM', 'Armidale Airport', 3556, -30.5280990601, 151.617004395, 5702).
airport('ARM', 'Armidale Airport', 3556, -30.5280990601, 151.617004395, 5202).
airport('BHQ', 'Broken Hill Airport', 958, -32.0013999939, 141.472000122, 8251).
airport('BHQ', 'Broken Hill Airport', 958, -32.0013999939, 141.472000122, 7751).
airport('HTI', 'Hamilton Island Airport', 15, -20.3581008911, 148.95199585, 5591).
airport('MKY', 'Mackay Airport', 19, -21.1716995239, 149.179992676, 6499).
airport('MKY', 'Mackay Airport', 19, -21.1716995239, 149.179992676, 5999).
airport('BNK', 'Ballina Byron Gateway Airport', 7, -28.8339004517, 153.56199646, 6234).
airport('PPP', 'Proserpine Whitsunday Coast Airport', 82, -20.4950008392, 148.552001953, 6801).
airport('PPP', 'Proserpine Whitsunday Coast Airport', 82, -20.4950008392, 148.552001953, 6301).
airport('BME', 'Broome International Airport', 56, -17.9447002410889, 122.232002258301, 8064).
airport('BHS', 'Bathurst Airport', 2435, -33.4094009399, 149.651992798, 5594).
airport('BHS', 'Bathurst Airport', 2435, -33.4094009399, 149.651992798, 5094).
airport('TSV', 'Townsville Airport', 18, -19.2525005340576, 146.764999389648, 7999).
airport('TSV', 'Townsville Airport', 18, -19.2525005340576, 146.764999389648, 7499).
airport('GLT', 'Gladstone Airport', 64, -23.8696994781, 151.223007202, 5364).
airport('GFF', 'Griffith Airport', 439, -34.2508010864, 146.067001343, 4931).
airport('GFF', 'Griffith Airport', 439, -34.2508010864, 146.067001343, 4431).
airport('HVB', 'Hervey Bay Airport', 60, -25.3188991547, 152.880004883, 6561).
airport('LDH', 'Lord Howe Island Airport', 5, -31.5382995605, 159.07699585, 2907).
airport('LSY', 'Lismore Airport', 35, -28.8302993774, 153.259994507, 5404).
airport('AVV', 'Avalon Airport', 35, -38.0393981934, 144.468994141, 10000).
airport('ABX', 'Albury Airport', 539, -36.067798614502, 146.957992553711, 6234).
airport('MIM', 'Merimbula Airport', 7, -36.9085998535, 149.901000977, 5256).
airport('HBA', 'Hobart International Airport', 13, -42.836101532, 147.509994507, 7385).
airport('MQL', 'Mildura Airport', 167, -34.2291984558, 142.085998535, 6004).
airport('MQL', 'Mildura Airport', 167, -34.2291984558, 142.085998535, 5504).
airport('LST', 'Launceston Airport', 562, -41.54529953, 147.214004517, 6499).
airport('LST', 'Launceston Airport', 562, -41.54529953, 147.214004517, 5999).
airport('LST', 'Launceston Airport', 562, -41.54529953, 147.214004517, 5499).
airport('MRZ', 'Moree Airport', 701, -29.4988994598, 149.845001221, 5292).
airport('MRZ', 'Moree Airport', 701, -29.4988994598, 149.845001221, 4792).
airport('MYA', 'Moruya Airport', 14, -35.8978004456, 150.143997192, 4997).
airport('MYA', 'Moruya Airport', 14, -35.8978004456, 150.143997192, 4497).
airport('NRA', 'Narrandera Airport', 474, -34.7022018433, 146.511993408, 5302).
airport('NRA', 'Narrandera Airport', 474, -34.7022018433, 146.511993408, 4802).
airport('OAG', 'Orange Airport', 3115, -33.3816986084, 149.132995605, 5499).
airport('OAG', 'Orange Airport', 3115, -33.3816986084, 149.132995605, 4999).
airport('KTA', 'Karratha Airport', 29, -20.7122001648, 116.773002625, 6070).
airport('PKE', 'Parkes Airport', 1069, -33.131401062, 148.238998413, 5525).
airport('PKE', 'Parkes Airport', 1069, -33.131401062, 148.238998413, 5025).
airport('PQQ', 'Port Macquarie Airport', 12, -31.4358005524, 152.863006592, 5203).
airport('PQQ', 'Port Macquarie Airport', 12, -31.4358005524, 152.863006592, 4703).
airport('CFS', 'Coffs Harbour Airport', 18, -30.3206005096, 153.115997314, 6824).
airport('CFS', 'Coffs Harbour Airport', 18, -30.3206005096, 153.115997314, 6324).
airport('DBO', 'Dubbo City Regional Airport', 935, -32.2167015076, 148.574996948, 5604).
airport('DBO', 'Dubbo City Regional Airport', 935, -32.2167015076, 148.574996948, 5104).
airport('NLK', 'Norfolk Island International Airport', 371, -29.0415992736816, 167.938995361328, 6398).
airport('NLK', 'Norfolk Island International Airport', 371, -29.0415992736816, 167.938995361328, 5898).
airport('TMW', 'Tamworth Airport', 1334, -31.0839004517, 150.847000122, 7218).
airport('TMW', 'Tamworth Airport', 1334, -31.0839004517, 150.847000122, 6718).
airport('TMW', 'Tamworth Airport', 1334, -31.0839004517, 150.847000122, 6218).
airport('TMW', 'Tamworth Airport', 1334, -31.0839004517, 150.847000122, 5718).
airport('WGA', 'Wagga Wagga City Airport', 724, -35.1652984619, 147.466003418, 5801).
airport('WGA', 'Wagga Wagga City Airport', 724, -35.1652984619, 147.466003418, 5301).
airport('TRO', 'Taree Airport', 38, -31.8885993958, 152.514007568, 4934).
airport('TRO', 'Taree Airport', 38, -31.8885993958, 152.514007568, 4434).
airport('TWB', 'Toowoomba Airport', 2086, -27.5428009033203, 151.916000366211, 3678).
airport('TWB', 'Toowoomba Airport', 2086, -27.5428009033203, 151.916000366211, 3178).
airport('NTL', 'Newcastle Airport', 31, -32.7949981689453, 151.833999633789, 7999).
airport('DPO', 'Devonport Airport', 33, -41.1697006226, 146.429992676, 6030).
airport('DPO', 'Devonport Airport', 33, -41.1697006226, 146.429992676, 5530).
airport('KNS', 'King Island Airport', 132, -39.877498626709, 143.878005981445, 5198).
airport('KNS', 'King Island Airport', 132, -39.877498626709, 143.878005981445, 4698).
airport('KNS', 'King Island Airport', 132, -39.877498626709, 143.878005981445, 4198).
airport('MGB', 'Mount Gambier Airport', 212, -37.7456016540527, 140.785003662109, 5000).
airport('MGB', 'Mount Gambier Airport', 212, -37.7456016540527, 140.785003662109, 4500).
airport('MGB', 'Mount Gambier Airport', 212, -37.7456016540527, 140.785003662109, 4000).
airport('KGI', 'Kalgoorlie Boulder Airport', 1203, -30.7894001007, 121.461997986, 6562).
airport('KGI', 'Kalgoorlie Boulder Airport', 1203, -30.7894001007, 121.461997986, 6062).
airport('PHE', 'Port Hedland International Airport', 33, -20.3777999878, 118.625999451, 8202).
airport('PHE', 'Port Hedland International Airport', 33, -20.3777999878, 118.625999451, 7702).
airport('BWT', 'Wynyard Airport', 62, -40.9989013671875, 145.731002807617, 5413).
airport('BWT', 'Wynyard Airport', 62, -40.9989013671875, 145.731002807617, 4913).
airport('TUO', 'Taupo Airport', 1335, -38.7397003173828, 176.083999633789, 4547).
airport('TUO', 'Taupo Airport', 1335, -38.7397003173828, 176.083999633789, 4047).
airport('DUD', 'Dunedin Airport', 4, -45.9281005859375, 170.197998046875, 6234).
airport('GIS', 'Gisborne Airport', 15, -38.6632995605469, 177.977996826172, 4298).
airport('GIS', 'Gisborne Airport', 15, -38.6632995605469, 177.977996826172, 3798).
airport('GIS', 'Gisborne Airport', 15, -38.6632995605469, 177.977996826172, 3298).
airport('GIS', 'Gisborne Airport', 15, -38.6632995605469, 177.977996826172, 2798).
airport('GIS', 'Gisborne Airport', 15, -38.6632995605469, 177.977996826172, 2298).
airport('HLZ', 'Hamilton International Airport', 172, -37.8666992188, 175.332000732, 6430).
airport('HLZ', 'Hamilton International Airport', 172, -37.8666992188, 175.332000732, 5930).
airport('HLZ', 'Hamilton International Airport', 172, -37.8666992188, 175.332000732, 5430).
airport('HLZ', 'Hamilton International Airport', 172, -37.8666992188, 175.332000732, 4930).
airport('HLZ', 'Hamilton International Airport', 172, -37.8666992188, 175.332000732, 4430).
airport('KKE', 'Kerikeri Airport', 492, -35.2627983093262, 173.912002563477, 3904).
airport('KKE', 'Kerikeri Airport', 492, -35.2627983093262, 173.912002563477, 3404).
airport('KKE', 'Kerikeri Airport', 492, -35.2627983093262, 173.912002563477, 2904).
airport('KKE', 'Kerikeri Airport', 492, -35.2627983093262, 173.912002563477, 2404).
airport('KAT', 'Kaitaia Airport', 270, -35.0699996948242, 173.285003662109, 4600).
airport('KAT', 'Kaitaia Airport', 270, -35.0699996948242, 173.285003662109, 4100).
airport('NPL', 'New Plymouth Airport', 97, -39.0085983276367, 174.179000854492, 4298).
airport('NPL', 'New Plymouth Airport', 97, -39.0085983276367, 174.179000854492, 3798).
airport('NPL', 'New Plymouth Airport', 97, -39.0085983276367, 174.179000854492, 3298).
airport('NPE', 'Napier Airport', 6, -39.4658012390137, 176.869995117188, 4298).
airport('NPE', 'Napier Airport', 6, -39.4658012390137, 176.869995117188, 3798).
airport('NPE', 'Napier Airport', 6, -39.4658012390137, 176.869995117188, 3298).
airport('NPE', 'Napier Airport', 6, -39.4658012390137, 176.869995117188, 2798).
airport('NPE', 'Napier Airport', 6, -39.4658012390137, 176.869995117188, 2298).
airport('NSN', 'Nelson Airport', 17, -41.2983016967773, 173.220993041992, 4420).
airport('NSN', 'Nelson Airport', 17, -41.2983016967773, 173.220993041992, 3920).
airport('NSN', 'Nelson Airport', 17, -41.2983016967773, 173.220993041992, 3420).
airport('NSN', 'Nelson Airport', 17, -41.2983016967773, 173.220993041992, 2920).
airport('NSN', 'Nelson Airport', 17, -41.2983016967773, 173.220993041992, 2420).
airport('PMR', 'Palmerston North Airport', 151, -40.3205986022949, 175.617004394531, 6240).
airport('PMR', 'Palmerston North Airport', 151, -40.3205986022949, 175.617004394531, 5740).
airport('PMR', 'Palmerston North Airport', 151, -40.3205986022949, 175.617004394531, 5240).
airport('PPQ', 'Paraparaumu Airport', 22, -40.9047012329102, 174.988998413086, 4429).
airport('PPQ', 'Paraparaumu Airport', 22, -40.9047012329102, 174.988998413086, 3929).
airport('PPQ', 'Paraparaumu Airport', 22, -40.9047012329102, 174.988998413086, 3429).
airport('PPQ', 'Paraparaumu Airport', 22, -40.9047012329102, 174.988998413086, 2929).
airport('PPQ', 'Paraparaumu Airport', 22, -40.9047012329102, 174.988998413086, 2429).
airport('ROT', 'Rotorua Regional Airport', 935, -38.1091995239258, 176.317001342773, 5321).
airport('ROT', 'Rotorua Regional Airport', 935, -38.1091995239258, 176.317001342773, 4821).
airport('ROT', 'Rotorua Regional Airport', 935, -38.1091995239258, 176.317001342773, 4321).
airport('TRG', 'Tauranga Airport', 13, -37.6719017028809, 176.195999145508, 5988).
airport('TRG', 'Tauranga Airport', 13, -37.6719017028809, 176.195999145508, 5488).
airport('TRG', 'Tauranga Airport', 13, -37.6719017028809, 176.195999145508, 4988).
airport('TRG', 'Tauranga Airport', 13, -37.6719017028809, 176.195999145508, 4488).
airport('TRG', 'Tauranga Airport', 13, -37.6719017028809, 176.195999145508, 3988).
airport('BHE', 'Woodbourne Airport', 109, -41.5182991027832, 173.869995117188, 4675).
airport('BHE', 'Woodbourne Airport', 109, -41.5182991027832, 173.869995117188, 4175).
airport('BHE', 'Woodbourne Airport', 109, -41.5182991027832, 173.869995117188, 3675).
airport('WHK', 'Whakatane Airport', 20, -37.9206008911133, 176.914001464844, 4200).
airport('WHK', 'Whakatane Airport', 20, -37.9206008911133, 176.914001464844, 3700).
airport('WHK', 'Whakatane Airport', 20, -37.9206008911133, 176.914001464844, 3200).
airport('WRE', 'Whangarei Airport', 133, -35.7682991027832, 174.365005493164, 3599).
airport('WRE', 'Whangarei Airport', 133, -35.7682991027832, 174.365005493164, 3099).
airport('WAG', 'Wanganui Airport', 27, -39.9622001647949, 175.024993896484, 4521).
airport('HLD', 'Dongshan Airport', 2169, 49.2050018311, 119.824996948, 8530).
airport('TAE', 'Daegu Airport', 116, 35.8941001892, 128.658996582, 9039).
airport('TAE', 'Daegu Airport', 116, 35.8941001892, 128.658996582, 8539).
airport('YKS', 'Yakutsk Airport', 325, 62.0932998657227, 129.77099609375, 11155).
airport('YKS', 'Yakutsk Airport', 325, 62.0932998657227, 129.77099609375, 10655).
airport('MWX', 'Muan International Airport', 51, 34.991406, 126.382814, 9186).
airport('CJJ', 'Cheongju International Airport', 191, 36.7165985107, 127.499000549, 9000).
airport('CJJ', 'Cheongju International Airport', 191, 36.7165985107, 127.499000549, 8500).
airport('IKT', 'Irkutsk Airport', 1675, 52.2680015563965, 104.388999938965, 10384).
airport('UUD', 'Ulan-Ude Airport (Mukhino)', 1690, 51.8078002929688, 107.438003540039, 9780).
airport('UUD', 'Ulan-Ude Airport (Mukhino)', 1690, 51.8078002929688, 107.438003540039, 9280).
airport('UUD', 'Ulan-Ude Airport (Mukhino)', 1690, 51.8078002929688, 107.438003540039, 8780).
airport('KJA', 'Yemelyanovo Airport', 942, 56.1729011535645, 92.4933013916016, 12150).
airport('FNJ', 'Sunan International Airport', 117, 39.2240982055664, 125.669998168945, 12475).
airport('FNJ', 'Sunan International Airport', 117, 39.2240982055664, 125.669998168945, 11975).
airport('LHW', 'Lanzhou Zhongchuan Airport', 6388, 36.5152015686, 103.620002747, 11811).
airport('LXA', 'Lhasa Gonggar Airport', 11713, 29.2978000641, 90.9119033813, 13123).
airport('LXA', 'Lhasa Gonggar Airport', 11713, 29.2978000641, 90.9119033813, 12623).
airport('HRB', 'Taiping Airport', 457, 45.6234016418457, 126.25, 10500).
airport('JMU', 'Jiamusi Airport', 262, 46.8433990479, 130.464996338, 7218).
airport('MDG', 'Mudanjiang Hailang International Airport', 883, 44.5241012573, 129.569000244, 8530).
airport('NDG', 'Qiqihar Sanjiazi Airport', 477, 47.2396011352539, 123.917999267578, 8530).
airport('YNJ', 'Yanji Chaoyangchuan Airport', 624, 42.8828010559, 129.451004028, 8530).
airport('JGS', 'Jinggangshan Airport', 281, 26.8568992615, 114.736999512, 10499).
airport('TLC', 'Licenciado Adolfo Lopez Mateos International Airport', 8466, 19.3370990753, -99.5660018921, 13780).
airport('LBE', 'Arnold Palmer Regional Airport', 1199, 40.27590179, -79.40480042, 7001).
airport('LBE', 'Arnold Palmer Regional Airport', 1199, 40.27590179, -79.40480042, 6501).
airport('ORH', 'Worcester Regional Airport', 1009, 42.2672996520996, -71.8757019042969, 7000).
airport('ORH', 'Worcester Regional Airport', 1009, 42.2672996520996, -71.8757019042969, 6500).
airport('PBG', 'Plattsburgh International Airport', 234, 44.6509017944336, -73.4681015014648, 11758).
airport('TCB', 'Treasure Cay Airport', 8, 26.745300293, -77.3912963867, 7001).
airport('GHB', "Governor's Harbour Airport", 26, 25.2847003937, -76.3310012817, 8024).
airport('ZSA', 'San Salvador Airport', 24, 24.0632991790771, -74.5240020751953, 8000).
airport('AXM', 'El Eden Airport', 3990, 4.45278, -75.7664, 7045).
airport('YQM', 'Greater Moncton International Airport', 232, 46.1122016906738, -64.678596496582, 10001).
airport('YQM', 'Greater Moncton International Airport', 232, 46.1122016906738, -64.678596496582, 9501).
airport('YTZ', 'Billy Bishop Toronto City Centre Airport', 252, 43.6274986267, -79.3962020874, 3988).
airport('YTZ', 'Billy Bishop Toronto City Centre Airport', 252, 43.6274986267, -79.3962020874, 3488).
airport('YTZ', 'Billy Bishop Toronto City Centre Airport', 252, 43.6274986267, -79.3962020874, 2988).
airport('AOO', 'Altoona Blair County Airport', 1503, 40.29639816, -78.31999969, 5466).
airport('AOO', 'Altoona Blair County Airport', 1503, 40.29639816, -78.31999969, 4966).
airport('BGM', 'Greater Binghamton/Edwin A Link field', 1636, 42.20869827, -75.97979736, 7100).
airport('BGM', 'Greater Binghamton/Edwin A Link field', 1636, 42.20869827, -75.97979736, 6600).
airport('BKW', 'Raleigh County Memorial Airport', 2504, 37.7873001099, -81.1241989136, 6750).
airport('BKW', 'Raleigh County Memorial Airport', 2504, 37.7873001099, -81.1241989136, 6250).
airport('HGR', 'Hagerstown Regional Richard A Henson Field', 703, 39.707901, -77.72949982, 5461).
airport('HGR', 'Hagerstown Regional Richard A Henson Field', 703, 39.707901, -77.72949982, 4961).
airport('JST', 'John Murtha Johnstown Cambria County Airport', 2284, 40.3161010742188, -78.8339004516602, 7003).
airport('JST', 'John Murtha Johnstown Cambria County Airport', 2284, 40.3161010742188, -78.8339004516602, 6503).
airport('JST', 'John Murtha Johnstown Cambria County Airport', 2284, 40.3161010742188, -78.8339004516602, 6003).
airport('LNS', 'Lancaster Airport', 403, 40.1217002868652, -76.2960968017578, 6934).
airport('LNS', 'Lancaster Airport', 403, 40.1217002868652, -76.2960968017578, 6434).
airport('MGW', 'Morgantown Municipal Walter L. Bill Hart Field', 1248, 39.64289856, -79.91629791, 5199).
airport('MGW', 'Morgantown Municipal Walter L. Bill Hart Field', 1248, 39.64289856, -79.91629791, 4699).
airport('SHD', 'Shenandoah Valley Regional Airport', 1201, 38.2638015747, -78.8964004517, 6002).
airport('ITH', 'Ithaca Tompkins Regional Airport', 1099, 42.4910011291504, -76.4583969116211, 6601).
airport('ITH', 'Ithaca Tompkins Regional Airport', 1099, 42.4910011291504, -76.4583969116211, 6101).
airport('GFK', 'Grand Forks International Airport', 845, 47.9492988586426, -97.1761016845703, 7349).
airport('GFK', 'Grand Forks International Airport', 845, 47.9492988586426, -97.1761016845703, 6849).
airport('GFK', 'Grand Forks International Airport', 845, 47.9492988586426, -97.1761016845703, 6349).
airport('GFK', 'Grand Forks International Airport', 845, 47.9492988586426, -97.1761016845703, 5849).
airport('AZA', 'Phoenix-Mesa-Gateway Airport', 1382, 33.30780029, -111.6549988, 10401).
airport('AZA', 'Phoenix-Mesa-Gateway Airport', 1382, 33.30780029, -111.6549988, 9901).
airport('AZA', 'Phoenix-Mesa-Gateway Airport', 1382, 33.30780029, -111.6549988, 9401).
airport('RFD', 'Chicago Rockford International Airport', 742, 42.1954002380371, -89.0971984863281, 10004).
airport('RFD', 'Chicago Rockford International Airport', 742, 42.1954002380371, -89.0971984863281, 9504).
airport('ABR', 'Aberdeen Regional Airport', 1302, 45.4491004943848, -98.4217987060547, 6901).
airport('ABR', 'Aberdeen Regional Airport', 1302, 45.4491004943848, -98.4217987060547, 6401).
airport('APN', 'Alpena County Regional Airport', 690, 45.0780983, -83.56030273, 9001).
airport('APN', 'Alpena County Regional Airport', 690, 45.0780983, -83.56030273, 8501).
airport('ATY', 'Watertown Regional Airport', 1749, 44.91400146, -97.15470123, 6900).
airport('ATY', 'Watertown Regional Airport', 1749, 44.91400146, -97.15470123, 6400).
airport('BJI', 'Bemidji Regional Airport', 1391, 47.50939941, -94.93370056, 6598).
airport('BJI', 'Bemidji Regional Airport', 1391, 47.50939941, -94.93370056, 6098).
airport('BRD', 'Brainerd Lakes Regional Airport', 1232, 46.39830017, -94.13809967, 6500).
airport('BRD', 'Brainerd Lakes Regional Airport', 1232, 46.39830017, -94.13809967, 6000).
airport('BRD', 'Brainerd Lakes Regional Airport', 1232, 46.39830017, -94.13809967, 5500).
airport('BRD', 'Brainerd Lakes Regional Airport', 1232, 46.39830017, -94.13809967, 5000).
airport('HIB', 'Range Regional Airport', 1354, 47.38660049, -92.83899689, 6758).
airport('HIB', 'Range Regional Airport', 1354, 47.38660049, -92.83899689, 6258).
airport('IMT', 'Ford Airport', 1182, 45.8184013367, -88.1145019531, 6500).
airport('IMT', 'Ford Airport', 1182, 45.8184013367, -88.1145019531, 6000).
airport('INL', 'Falls International Airport', 1185, 48.5662002563477, -93.4030990600586, 6508).
airport('INL', 'Falls International Airport', 1185, 48.5662002563477, -93.4030990600586, 6008).
airport('RHI', 'Rhinelander Oneida County Airport', 1624, 45.6311988830566, -89.4674987792969, 6800).
airport('RHI', 'Rhinelander Oneida County Airport', 1624, 45.6311988830566, -89.4674987792969, 6300).
airport('RHI', 'Rhinelander Oneida County Airport', 1624, 45.6311988830566, -89.4674987792969, 5800).
airport('ACK', 'Nantucket Memorial Airport', 47, 41.25310135, -70.06020355, 6303).
airport('ACK', 'Nantucket Memorial Airport', 47, 41.25310135, -70.06020355, 5803).
airport('ACK', 'Nantucket Memorial Airport', 47, 41.25310135, -70.06020355, 5303).
airport('AUG', 'Augusta State Airport', 352, 44.3205986023, -69.7973022461, 5001).
airport('AUG', 'Augusta State Airport', 352, 44.3205986023, -69.7973022461, 4501).
airport('BHB', 'Hancock County-Bar Harbor Airport', 83, 44.45000076, -68.3615036, 5200).
airport('BHB', 'Hancock County-Bar Harbor Airport', 83, 44.45000076, -68.3615036, 4700).
airport('BHB', 'Hancock County-Bar Harbor Airport', 83, 44.45000076, -68.3615036, 4200).
airport('HYA', 'Barnstable Municipal Boardman Polando Field', 54, 41.66930008, -70.28040314, 5425).
airport('HYA', 'Barnstable Municipal Boardman Polando Field', 54, 41.66930008, -70.28040314, 4925).
airport('LEB', 'Lebanon Municipal Airport', 603, 43.6260986328, -72.3041992188, 5496).
airport('LEB', 'Lebanon Municipal Airport', 603, 43.6260986328, -72.3041992188, 4996).
airport('MVY', "Martha's Vineyard Airport", 67, 41.3931007385, -70.6143035889, 5504).
airport('MVY', "Martha's Vineyard Airport", 67, 41.3931007385, -70.6143035889, 5004).
airport('MVY', "Martha's Vineyard Airport", 67, 41.3931007385, -70.6143035889, 4504).
airport('PQI', 'Northern Maine Regional Airport at Presque Isle', 534, 46.68899918, -68.0447998, 7440).
airport('PQI', 'Northern Maine Regional Airport at Presque Isle', 534, 46.68899918, -68.0447998, 6940).
airport('PVC', 'Provincetown Municipal Airport', 9, 42.0718994141, -70.2213973999, 3500).
airport('RKD', 'Knox County Regional Airport', 56, 44.06010056, -69.09919739, 5007).
airport('RKD', 'Knox County Regional Airport', 56, 44.06010056, -69.09919739, 4507).
airport('RUT', 'Rutland - Southern Vermont Regional Airport', 787, 43.52939987, -72.94960022, 5000).
airport('RUT', 'Rutland - Southern Vermont Regional Airport', 787, 43.52939987, -72.94960022, 4500).
airport('SLK', 'Adirondack Regional Airport', 1663, 44.3852996826172, -74.2061996459961, 6573).
airport('SLK', 'Adirondack Regional Airport', 1663, 44.3852996826172, -74.2061996459961, 6073).
airport('BET', 'Bethel Airport', 126, 60.77980042, -161.8379974, 6400).
airport('BET', 'Bethel Airport', 126, 60.77980042, -161.8379974, 5900).
airport('BET', 'Bethel Airport', 126, 60.77980042, -161.8379974, 5400).
airport('BRW', 'Wiley Post Will Rogers Memorial Airport', 44, 71.285400390625, -156.766006469727, 6500).
airport('CDB', 'Cold Bay Airport', 96, 55.2061004638672, -162.725006103516, 10415).
airport('CDB', 'Cold Bay Airport', 96, 55.2061004638672, -162.725006103516, 9915).
airport('CDV', 'Merle K (Mudhole) Smith Airport', 54, 60.4917984, -145.4779968, 7500).
airport('CDV', 'Merle K (Mudhole) Smith Airport', 54, 60.4917984, -145.4779968, 7000).
airport('ADK', 'Adak Airport', 18, 51.8779983520508, -176.64599609375, 7790).
airport('ADK', 'Adak Airport', 18, 51.8779983520508, -176.64599609375, 7290).
airport('DLG', 'Dillingham Airport', 81, 59.04470062, -158.5050049, 6400).
airport('ADQ', 'Kodiak Airport', 78, 57.75, -152.4940033, 7542).
airport('ADQ', 'Kodiak Airport', 78, 57.75, -152.4940033, 7042).
airport('ADQ', 'Kodiak Airport', 78, 57.75, -152.4940033, 6542).
airport('ENA', 'Kenai Municipal Airport', 99, 60.5731010437012, -151.244995117188, 7576).
airport('ENA', 'Kenai Municipal Airport', 99, 60.5731010437012, -151.244995117188, 7076).
airport('ENA', 'Kenai Municipal Airport', 99, 60.5731010437012, -151.244995117188, 6576).
airport('HOM', 'Homer Airport', 84, 59.6455993652344, -151.477005004883, 6701).
airport('ILI', 'Iliamna Airport', 192, 59.75439835, -154.9109955, 5087).
airport('ILI', 'Iliamna Airport', 192, 59.75439835, -154.9109955, 4587).
airport('ILI', 'Iliamna Airport', 192, 59.75439835, -154.9109955, 4087).
airport('ILI', 'Iliamna Airport', 192, 59.75439835, -154.9109955, 3587).
airport('JNU', 'Juneau International Airport', 21, 58.3549995422363, -134.57600402832, 8457).
airport('JNU', 'Juneau International Airport', 21, 58.3549995422363, -134.57600402832, 7957).
airport('AKN', 'King Salmon Airport', 73, 58.67679977, -156.6490021, 8901).
airport('AKN', 'King Salmon Airport', 73, 58.67679977, -156.6490021, 8401).
airport('AKN', 'King Salmon Airport', 73, 58.67679977, -156.6490021, 7901).
airport('MCG', 'McGrath Airport', 341, 62.95289993, -155.6060028, 5936).
airport('MCG', 'McGrath Airport', 341, 62.95289993, -155.6060028, 5436).
airport('ANI', 'Aniak Airport', 88, 61.581600189209, -159.542999267578, 6000).
airport('ANI', 'Aniak Airport', 88, 61.581600189209, -159.542999267578, 5500).
airport('OME', 'Nome Airport', 37, 64.5121994018555, -165.445007324219, 6001).
airport('OME', 'Nome Airport', 37, 64.5121994018555, -165.445007324219, 5501).
airport('OTZ', 'Ralph Wien Memorial Airport', 14, 66.88469696, -162.598999, 5900).
airport('OTZ', 'Ralph Wien Memorial Airport', 14, 66.88469696, -162.598999, 5400).
airport('STG', 'St George Airport', 125, 56.5783004761, -169.662002563, 5000).
airport('SCC', 'Deadhorse Airport', 65, 70.19470215, -148.4649963, 6500).
airport('SDP', 'Sand Point Airport', 21, 55.314998626709, -160.522994995117, 4000).
airport('KSM', "St Mary's Airport", 312, 62.0605011, -163.302002, 6003).
airport('KSM', "St Mary's Airport", 312, 62.0605011, -163.302002, 5503).
airport('SNP', 'St Paul Island Airport', 63, 57.1673011779785, -170.220001220703, 6500).
airport('UNK', 'Unalakleet Airport', 27, 63.88840103, -160.798996, 6004).
airport('UNK', 'Unalakleet Airport', 27, 63.88840103, -160.798996, 5504).
airport('VDZ', 'Valdez Pioneer Field', 121, 61.13389969, -146.2480011, 6508).
airport('AHN', 'Athens Ben Epps Airport', 808, 33.948600769043, -83.326301574707, 5522).
airport('AHN', 'Athens Ben Epps Airport', 808, 33.948600769043, -83.326301574707, 5022).
airport('MKL', 'Mc Kellar Sipes Regional Airport', 434, 35.59989929, -88.91560364, 6006).
airport('MKL', 'Mc Kellar Sipes Regional Airport', 434, 35.59989929, -88.91560364, 5506).
airport('HOB', 'Lea County Regional Airport', 3661, 32.6875, -103.2170029, 7398).
airport('HOB', 'Lea County Regional Airport', 3661, 32.6875, -103.2170029, 6898).
airport('HOB', 'Lea County Regional Airport', 3661, 32.6875, -103.2170029, 6398).
airport('VCT', 'Victoria Regional Airport', 115, 28.8526000976562, -96.9185028076172, 9101).
airport('VCT', 'Victoria Regional Airport', 115, 28.8526000976562, -96.9185028076172, 8601).
airport('VCT', 'Victoria Regional Airport', 115, 28.8526000976562, -96.9185028076172, 8101).
airport('VCT', 'Victoria Regional Airport', 115, 28.8526000976562, -96.9185028076172, 7601).
airport('ACA', 'General Juan N Alvarez International Airport', 16, 16.7570991516113, -99.7539978027344, 10832).
airport('ACA', 'General Juan N Alvarez International Airport', 16, 16.7570991516113, -99.7539978027344, 10332).
airport('HUX', 'Bahías de Huatulco International Airport', 464, 15.7753000259399, -96.2626037597656, 8858).
airport('CME', 'Ciudad del Carmen International Airport', 10, 18.6536998748779, -91.7990036010742, 7218).
airport('SLW', 'Plan De Guadalupe International Airport', 4778, 25.5494995117188, -100.929000854492, 9506).
airport('SLW', 'Plan De Guadalupe International Airport', 4778, 25.5494995117188, -100.929000854492, 9006).
airport('OAX', 'Xoxocotlán International Airport', 4989, 16.9999008179, -96.726600647, 8038).
airport('TAM', 'General Francisco Javier Mina International Airport', 80, 22.2964000702, -97.8658981323, 8366).
airport('TAM', 'General Francisco Javier Mina International Airport', 80, 22.2964000702, -97.8658981323, 7866).
airport('TAM', 'General Francisco Javier Mina International Airport', 80, 22.2964000702, -97.8658981323, 7366).
airport('VSA', 'Carlos Rovirosa Pérez International Airport', 46, 17.9969997406006, -92.8173980712891, 7218).
airport('VER', 'General Heriberto Jara International Airport', 90, 19.1459007263, -96.1873016357, 7874).
airport('VER', 'General Heriberto Jara International Airport', 90, 19.1459007263, -96.1873016357, 7374).
airport('FLG', 'Flagstaff Pulliam Airport', 7014, 35.13850021, -111.6709976, 6999).
airport('SOW', 'Show Low Regional Airport', 6415, 34.265499115, -110.005996704, 7200).
airport('SOW', 'Show Low Regional Airport', 6415, 34.265499115, -110.005996704, 6700).
airport('SVC', 'Grant County Airport', 5446, 32.6365013122559, -108.15599822998, 6802).
airport('SVC', 'Grant County Airport', 5446, 32.6365013122559, -108.15599822998, 6302).
airport('SVC', 'Grant County Airport', 5446, 32.6365013122559, -108.15599822998, 5802).
airport('SVC', 'Grant County Airport', 5446, 32.6365013122559, -108.15599822998, 5302).
airport('YAM', 'Sault Ste Marie Airport', 630, 46.4850006103516, -84.5093994140625, 6000).
airport('YAM', 'Sault Ste Marie Airport', 630, 46.4850006103516, -84.5093994140625, 5500).
airport('YDF', 'Deer Lake Airport', 72, 49.2108001708984, -57.3913993835449, 8005).
airport('YFC', 'Fredericton Airport', 68, 45.8689002990723, -66.5372009277344, 8005).
airport('YFC', 'Fredericton Airport', 68, 45.8689002990723, -66.5372009277344, 7505).
airport('YGK', 'Kingston Norman Rogers Airport', 305, 44.2252998352051, -76.5969009399414, 5000).
airport('YGK', 'Kingston Norman Rogers Airport', 305, 44.2252998352051, -76.5969009399414, 4500).
airport('YQG', 'Windsor Airport', 622, 42.2756004333496, -82.9555969238281, 9000).
airport('YQG', 'Windsor Airport', 622, 42.2756004333496, -82.9555969238281, 8500).
airport('YQT', 'Thunder Bay Airport', 653, 48.371898651123, -89.3238983154297, 7318).
airport('YQT', 'Thunder Bay Airport', 653, 48.371898651123, -89.3238983154297, 6818).
airport('YQY', 'Sydney / J.A. Douglas McCurdy Airport', 203, 46.1613998413, -60.0477981567, 7070).
airport('YQY', 'Sydney / J.A. Douglas McCurdy Airport', 203, 46.1613998413, -60.0477981567, 6570).
airport('YSB', 'Sudbury Airport', 1141, 46.625, -80.7988967895508, 6600).
airport('YSB', 'Sudbury Airport', 1141, 46.625, -80.7988967895508, 6100).
airport('YSJ', 'Saint John Airport', 357, 45.3161010742188, -65.8902969360352, 7000).
airport('YSJ', 'Saint John Airport', 357, 45.3161010742188, -65.8902969360352, 6500).
airport('YTS', 'Timmins/Victor M. Power', 967, 48.5696983337, -81.376701355, 6000).
airport('YTS', 'Timmins/Victor M. Power', 967, 48.5696983337, -81.376701355, 5500).
airport('YYB', 'North Bay Airport', 1215, 46.3636016845703, -79.4227981567383, 10000).
airport('YYB', 'North Bay Airport', 1215, 46.3636016845703, -79.4227981567383, 9500).
airport('YYB', 'North Bay Airport', 1215, 46.3636016845703, -79.4227981567383, 9000).
airport('YYG', 'Charlottetown Airport', 160, 46.2900009155273, -63.1211013793945, 7000).
airport('YYG', 'Charlottetown Airport', 160, 46.2900009155273, -63.1211013793945, 6500).
airport('YZR', 'Chris Hadfield Airport', 594, 42.9994010925293, -82.3088989257812, 5100).
airport('YZR', 'Chris Hadfield Airport', 594, 42.9994010925293, -82.3088989257812, 4600).
airport('CMW', 'Ignacio Agramonte International Airport', 413, 21.4202995300293, -77.8475036621094, 9842).
airport('SNU', 'Abel Santamaria Airport', 338, 22.4922008514404, -79.943603515625, 9898).
airport('VTZ', 'Vishakhapatnam Airport', 10, 17.721200943, 83.2245025635, 10000).
airport('VTZ', 'Vishakhapatnam Airport', 10, 17.721200943, 83.2245025635, 9500).
airport('MDC', 'Sam Ratulangi Airport', 264, 1.54926002025604, 124.926002502441, 8693).
airport('RDN', 'LTS Pulau Redang Airport', 36, 5.76527976989746, 103.00700378418, 3084).
airport('SWA', 'Shantou Waisha Airport', 52, 23.4269008636475, 116.762001037598, 9186).
airport('LJG', 'Lijiang Airport', 7359, 26.6800003052, 100.246002197, 9843).
airport('WUX', 'Sunan Shuofang International Airport', 16, 31.4944000244, 120.429000854, 10499).
airport('ERI', 'Erie International Tom Ridge Field', 732, 42.0831270134, -80.1738667488, 8420).
airport('ERI', 'Erie International Tom Ridge Field', 732, 42.0831270134, -80.1738667488, 7920).
airport('HVN', 'Tweed New Haven Airport', 12, 41.26369858, -72.88680267, 5600).
airport('HVN', 'Tweed New Haven Airport', 12, 41.26369858, -72.88680267, 5100).
airport('IPT', 'Williamsport Regional Airport', 529, 41.2417984008789, -76.9210968017578, 6474).
airport('IPT', 'Williamsport Regional Airport', 529, 41.2417984008789, -76.9210968017578, 5974).
airport('SBY', 'Salisbury Ocean City Wicomico Regional Airport', 52, 38.3404998779297, -75.5102996826172, 5500).
airport('SBY', 'Salisbury Ocean City Wicomico Regional Airport', 52, 38.3404998779297, -75.5102996826172, 5000).
airport('CIU', 'Chippewa County International Airport', 800, 46.2508010864258, -84.4723968505859, 7201).
airport('CIU', 'Chippewa County International Airport', 800, 46.2508010864258, -84.4723968505859, 6701).
airport('ESC', 'Delta County Airport', 609, 45.7226982117, -87.0936965942, 6501).
airport('ESC', 'Delta County Airport', 609, 45.7226982117, -87.0936965942, 6001).
airport('PLN', 'Pellston Regional Airport of Emmet County', 721, 45.57089996, -84.79669952, 6512).
airport('PLN', 'Pellston Regional Airport of Emmet County', 721, 45.57089996, -84.79669952, 6012).
airport('BFD', 'Bradford Regional Airport', 2143, 41.8031005859375, -78.6400985717773, 6309).
airport('BFD', 'Bradford Regional Airport', 2143, 41.8031005859375, -78.6400985717773, 5809).
airport('DUJ', 'DuBois Regional Airport', 1817, 41.17829895, -78.8986969, 5504).
airport('FKL', 'Venango Regional Airport', 1540, 41.3778991699, -79.8603973389, 5200).
airport('FKL', 'Venango Regional Airport', 1540, 41.3778991699, -79.8603973389, 4700).
airport('JHW', 'Chautauqua County-Jamestown Airport', 1723, 42.15340042, -79.25800323, 5299).
airport('JHW', 'Chautauqua County-Jamestown Airport', 1723, 42.15340042, -79.25800323, 4799).
airport('PKB', 'Mid Ohio Valley Regional Airport', 858, 39.345100402832, -81.4392013549805, 6781).
airport('PKB', 'Mid Ohio Valley Regional Airport', 858, 39.345100402832, -81.4392013549805, 6281).
airport('YZF', 'Yellowknife Airport', 675, 62.4627990722656, -114.440002441406, 7500).
airport('YZF', 'Yellowknife Airport', 675, 62.4627990722656, -114.440002441406, 7000).
airport('KDH', 'Kandahar Airport', 3337, 31.5058002471924, 65.8478012084961, 10532).
airport('AHB', 'Abha Regional Airport', 6858, 18.2404003143, 42.6566009521, 10991).
airport('ELQ', 'Gassim/Prince Nayef bin Abdulaziz Regional Airport', 2126, 26.3027992248535, 43.7743988037109, 9843).
airport('HAS', 'Hail Regional Airport', 3331, 27.4379005432129, 41.6862983703613, 12204).
airport('MED', 'Prince Mohammad Bin Abdulaziz Airport', 2151, 24.5534000396729, 39.7051010131836, 14222).
airport('MED', 'Prince Mohammad Bin Abdulaziz Airport', 2151, 24.5534000396729, 39.7051010131836, 13722).
airport('TUU', 'Tabuk Airport', 2551, 28.3654003143311, 36.6189002990723, 10991).
airport('TUU', 'Tabuk Airport', 2551, 28.3654003143311, 36.6189002990723, 10491).
airport('TIF', 'Ta’if Regional Airport', 4848, 21.4834003448486, 40.5443000793457, 12254).
airport('TIF', 'Ta’if Regional Airport', 4848, 21.4834003448486, 40.5443000793457, 11754).
airport('YNB', 'Yenbo - Prince Abdul Mohsin Bin Airport', 26, 24.1441993713379, 38.0634002685547, 10532).
airport('AWZ', 'Ahwaz Airport', 66, 31.3374004364, 48.7620010376, 11149).
airport('BUZ', 'Bushehr Airport', 68, 28.9447994232, 50.8345985413, 14664).
airport('BUZ', 'Bushehr Airport', 68, 28.9447994232, 50.8345985413, 14164).
airport('KIH', 'Kish International Airport', 101, 26.5261993408, 53.9802017212, 12004).
airport('KIH', 'Kish International Airport', 101, 26.5261993408, 53.9802017212, 11504).
airport('BDH', 'Bandar Lengeh Airport', 67, 26.531999588, 54.824798584, 8203).
airport('IFN', 'Esfahan Shahid Beheshti International Airport', 5059, 32.7508010864258, 51.8613014221191, 14425).
airport('IFN', 'Esfahan Shahid Beheshti International Airport', 5059, 32.7508010864258, 51.8613014221191, 13925).
airport('BND', 'Bandar Abbas International Airport', 22, 27.2182998657227, 56.377799987793, 12008).
airport('BND', 'Bandar Abbas International Airport', 22, 27.2182998657227, 56.377799987793, 11508).
airport('MHD', 'Mashhad International Airport', 3263, 36.2351989746094, 59.640998840332, 12877).
airport('MHD', 'Mashhad International Airport', 3263, 36.2351989746094, 59.640998840332, 12377).
airport('LRR', 'Lar Airport', 2641, 27.6746997833, 54.3833007812, 10334).
airport('LFM', 'Lamerd Airport', 1337, 27.3726997375, 53.1888008118, 10020).
airport('SYZ', 'Shiraz Shahid Dastghaib International Airport', 4920, 29.5391998291016, 52.5898017883301, 14345).
airport('SYZ', 'Shiraz Shahid Dastghaib International Airport', 4920, 29.5391998291016, 52.5898017883301, 13845).
airport('TBZ', 'Tabriz International Airport', 4459, 38.1338996887207, 46.2350006103516, 11825).
airport('TBZ', 'Tabriz International Airport', 4459, 38.1338996887207, 46.2350006103516, 11325).
airport('ZBR', 'Konarak Airport', 43, 25.4433002472, 60.3820991516, 12514).
airport('ZBR', 'Konarak Airport', 43, 25.4433002472, 60.3820991516, 12014).
airport('ZAH', 'Zahedan International Airport', 4564, 29.475700378418, 60.9062004089355, 13993).
airport('ZAH', 'Zahedan International Airport', 4564, 29.475700378418, 60.9062004089355, 13493).
airport('AZI', 'Bateen Airport', 16, 24.4283008575439, 54.4580993652344, 10499).
airport('SLL', 'Salalah Airport', 73, 17.0387001037598, 54.0913009643555, 10965).
airport('SLL', 'Salalah Airport', 73, 17.0387001037598, 54.0913009643555, 10465).
airport('MUX', 'Multan International Airport', 403, 30.2031993865967, 71.4190979003906, 9046).
airport('PEW', 'Peshawar International Airport', 1158, 33.9939002990723, 71.5146026611328, 9000).
airport('SKT', 'Sialkot Airport', 837, 32.5355567932, 74.3638916016, 11811).
airport('BGW', 'Baghdad International Airport', 114, 33.2625007629, 44.2346000671, 13124).
airport('BGW', 'Baghdad International Airport', 114, 33.2625007629, 44.2346000671, 12624).
airport('BSR', 'Basrah International Airport', 11, 30.5491008758545, 47.6621017456055, 13124).
airport('NJF', 'Al Najaf International Airport', 107, 31.989853, 44.404317, 9843).
airport('ISU', 'Sulaymaniyah International Airport', 2494, 35.5617485046, 45.3167381287, 11481).
airport('RIY', 'Mukalla International Airport', 54, 14.6625995635986, 49.375, 9846).
airport('FRU', 'Manas International Airport', 2090, 43.0612983704, 74.4776000977, 13792).
airport('HRK', 'Kharkiv International Airport', 508, 49.9248008728027, 36.2900009155273, 7285).
airport('KRR', 'Krasnodar International Airport', 118, 45.0346984863281, 39.1705017089844, 9835).
airport('KRR', 'Krasnodar International Airport', 118, 45.0346984863281, 39.1705017089844, 9335).
airport('MRV', 'Mineralnyye Vody Airport', 1054, 44.2251014709473, 43.081901550293, 12795).
airport('ROV', 'Rostov-na-Donu Airport', 280, 47.2582015991, 39.8180999756, 8202).
airport('ROV', 'Rostov-na-Donu Airport', 280, 47.2582015991, 39.8180999756, 7702).
airport('ROV', 'Rostov-na-Donu Airport', 280, 47.2582015991, 39.8180999756, 7202).
airport('VOG', 'Volgograd International Airport', 482, 48.7825012207031, 44.3455009460449, 8101).
airport('VOG', 'Volgograd International Airport', 482, 48.7825012207031, 44.3455009460449, 7601).
airport('VOG', 'Volgograd International Airport', 482, 48.7825012207031, 44.3455009460449, 7101).
airport('GOI', 'Dabolim Airport', 187, 15.3808002472, 73.8313980103, 11253).
airport('CGP', 'Shah Amanat International Airport', 12, 22.2495994567871, 91.8133010864258, 9646).
airport('LKO', 'Chaudhary Charan Singh International Airport', 410, 26.7605991364, 80.8892974854, 8996).
airport('XSB', 'Sir Bani Yas Island Airport', 21, 24.2856083, 52.5783472, 8760).
airport('DWC', 'Al Maktoum International Airport', 114, 24.8966666667, 55.1613888889, 14764).
airport('ATQ', 'Sri Guru Ram Dass Jee International Airport', 756, 31.7096004486, 74.7973022461, 10791).
airport('SSG', 'Malabo Airport', 76, 3.75527000427246, 8.70872020721436, 9647).
airport('MLN', 'Melilla Airport', 156, 35.279800415, -2.9562599659, 4685).
airport('BJZ', 'Badajoz Airport', 609, 38.891300201416, -6.82133007049561, 9350).
airport('RJL', 'Logroño-Agoncillo Airport', 1161, 42.4609534888, -2.32223510742, 6562).
airport('PNA', 'Pamplona Airport', 1504, 42.7700004577637, -1.64632999897003, 7241).
airport('PNA', 'Pamplona Airport', 1504, 42.7700004577637, -1.64632999897003, 6741).
airport('EAS', 'San Sebastian Airport', 16, 43.3564987182617, -1.79060995578766, 5755).
airport('SDR', 'Santander Airport', 16, 43.4271011352539, -3.82000994682312, 7612).
airport('LDE', 'Tarbes-Lourdes-Pyrénées Airport', 1260, 43.1786994934082, -0.006438999902457, 9843).
airport('AHO', 'Alghero-Fertilia Airport', 87, 40.6320991516, 8.29076957703, 9843).
airport('CAG', 'Cagliari Elmas Airport', 13, 39.251499176, 9.05428028107, 9196).
airport('CLJ', 'Cluj-Napoca International Airport', 1036, 46.7851982116699, 23.6861991882324, 6070).
airport('CLJ', 'Cluj-Napoca International Airport', 1036, 46.7851982116699, 23.6861991882324, 5570).
airport('TSR', 'Timişoara Traian Vuia Airport', 348, 45.8098983764648, 21.3379001617432, 11483).
airport('SCU', 'Antonio Maceo International Airport', 249, 19.9698009490967, -75.8354034423828, 13123).
airport('SCU', 'Antonio Maceo International Airport', 249, 19.9698009490967, -75.8354034423828, 12623).
airport('VVI', 'Viru Viru International Airport', 1224, -17.6448001861572, -63.1353988647461, 11483).
airport('RMF', 'Marsa Alam International Airport', 251, 25.557100296, 34.5836982727, 9843).
airport('VOL', 'Nea Anchialos Airport', 83, 39.2196006774902, 22.7943000793457, 9052).
airport('KLU', 'Klagenfurt Airport', 1470, 46.6425018311, 14.3376998901, 8924).
airport('KLU', 'Klagenfurt Airport', 1470, 46.6425018311, 14.3376998901, 8424).
airport('SJJ', 'Sarajevo International Airport', 1708, 43.8246002197266, 18.3314990997314, 8666).
airport('IAS', 'Iaşi Airport', 397, 47.1785011291504, 27.6205997467041, 5841).
airport('SBZ', 'Sibiu International Airport', 1496, 45.7855987548828, 24.0912990570068, 6562).
airport('ACH', 'St Gallen Altenrhein Airport', 1306, 47.4850006104, 9.56077003479, 4922).
airport('ACH', 'St Gallen Altenrhein Airport', 1306, 47.4850006104, 9.56077003479, 4422).
airport('ACH', 'St Gallen Altenrhein Airport', 1306, 47.4850006104, 9.56077003479, 3922).
airport('KSC', 'Košice Airport', 755, 48.6631011962891, 21.2411003112793, 10171).
airport('DNK', 'Dnipropetrovsk International Airport', 481, 48.3572006225586, 35.1006011962891, 9320).
airport('LWO', 'Lviv International Airport', 1071, 49.8125, 23.9561004638672, 10843).
airport('ODS', 'Odessa International Airport', 172, 46.4267997741699, 30.6765003204346, 9183).
airport('ODS', 'Odessa International Airport', 172, 46.4267997741699, 30.6765003204346, 8683).
airport('ODS', 'Odessa International Airport', 172, 46.4267997741699, 30.6765003204346, 8183).
airport('LIL', 'Lille-Lesquin Airport', 157, 50.5619010925293, 3.08944010734558, 9268).
airport('LIL', 'Lille-Lesquin Airport', 157, 50.5619010925293, 3.08944010734558, 8768).
airport('BDS', 'Brindisi – Salento Airport', 47, 40.6576004028, 17.9470005035, 8307).
airport('BDS', 'Brindisi – Salento Airport', 47, 40.6576004028, 17.9470005035, 7807).
airport('LUG', 'Lugano Airport', 915, 46.0042991638, 8.9105796814, 4429).
airport('EBA', 'Marina Di Campo Airport', 31, 42.7602996826172, 10.2393999099731, 3114).
airport('BNX', 'Banja Luka International Airport', 400, 44.9413986206055, 17.2975006103516, 8213).
airport('LIG', 'Limoges Airport', 1300, 45.8628005981445, 1.17944002151489, 8202).
airport('ETZ', 'Metz-Nancy-Lorraine Airport', 870, 48.9821014404, 6.25131988525, 8202).
airport('FSC', 'Figari Sud-Corse Airport', 87, 41.5005989074707, 9.09778022766113, 8136).
airport('CFR', 'Caen-Carpiquet Airport', 256, 49.1733016967773, -0.449999988079071, 6233).
airport('CFR', 'Caen-Carpiquet Airport', 256, 49.1733016967773, -0.449999988079071, 5733).
airport('IPL', 'Imperial County Airport', -54, 32.8342018127, -115.57900238, 5304).
airport('IPL', 'Imperial County Airport', -54, 32.8342018127, -115.57900238, 4804).
airport('YZZ', 'Trail Airport', 1427, 49.0555992126, -117.60900116, 4000).
airport('QBC', 'Bella Coola Airport', 117, 52.3875007629395, -126.596000671387, 4200).
airport('YBL', 'Campbell River Airport', 346, 49.9508018493652, -125.271003723145, 5000).
airport('YCD', 'Nanaimo Airport', 92, 49.0549702249, -123.869862556, 6602).
airport('YCG', 'Castlegar/West Kootenay Regional Airport', 1624, 49.2963981628, -117.632003784, 5300).
airport('YDQ', 'Dawson Creek Airport', 2148, 55.7422981262207, -120.182998657227, 5000).
airport('YKA', 'Kamloops Airport', 1133, 50.7022018433, -120.444000244, 6000).
airport('YKA', 'Kamloops Airport', 1133, 50.7022018433, -120.444000244, 5500).
airport('YPR', 'Prince Rupert Airport', 116, 54.2860984802, -130.445007324, 6000).
airport('YPW', 'Powell River Airport', 425, 49.8342018127441, -124.5, 3627).
airport('YQQ', 'Comox Airport', 84, 49.7108001708984, -124.887001037598, 10000).
airport('YQQ', 'Comox Airport', 84, 49.7108001708984, -124.887001037598, 9500).
airport('YQZ', 'Quesnel Airport', 1789, 53.0261001586914, -122.51000213623, 5500).
airport('YWL', 'Williams Lake Airport', 3085, 52.1831016541, -122.054000854, 7000).
airport('YXC', 'Cranbrook Airport', 3082, 49.6108016967773, -115.781997680664, 6000).
airport('YXJ', 'Fort St John Airport', 2280, 56.2380981445312, -120.73999786377, 6900).
airport('YXJ', 'Fort St John Airport', 2280, 56.2380981445312, -120.73999786377, 6400).
airport('YXS', 'Prince George Airport', 2267, 53.8894004822, -122.679000854, 11450).
airport('YXS', 'Prince George Airport', 2267, 53.8894004822, -122.679000854, 10950).
airport('YXS', 'Prince George Airport', 2267, 53.8894004822, -122.679000854, 10450).
airport('YXT', 'Terrace Airport', 713, 54.4684982299805, -128.57600402832, 7497).
airport('YXT', 'Terrace Airport', 713, 54.4684982299805, -128.57600402832, 6997).
airport('YXY', 'Whitehorse / Erik Nielsen International Airport', 2317, 60.7095985413, -135.067001343, 9497).
airport('YXY', 'Whitehorse / Erik Nielsen International Airport', 2317, 60.7095985413, -135.067001343, 8997).
airport('YXY', 'Whitehorse / Erik Nielsen International Airport', 2317, 60.7095985413, -135.067001343, 8497).
airport('YYD', 'Smithers Airport', 1712, 54.8246994018555, -127.182998657227, 5000).
airport('YYF', 'Penticton Airport', 1129, 49.4631004333496, -119.601997375488, 6000).
airport('YZP', 'Sandspit Airport', 21, 53.2542991638, -131.813995361, 5120).
airport('YZT', 'Port Hardy Airport', 71, 50.6805992126465, -127.366996765137, 5000).
airport('YZT', 'Port Hardy Airport', 71, 50.6805992126465, -127.366996765137, 4500).
airport('YZT', 'Port Hardy Airport', 71, 50.6805992126465, -127.366996765137, 4000).
airport('ZMT', 'Masset Airport', 25, 54.0275001525879, -132.125, 5000).
airport('HHN', 'Frankfurt-Hahn Airport', 1649, 49.9486999512, 7.26388978958, 12467).
airport('FMM', 'Memmingen Allgau Airport', 2077, 47.9888000488, 10.2395000458, 9780).
airport('BOH', 'Bournemouth Airport', 38, 50.7799987792969, -1.84249997138977, 7451).
airport('BLK', 'Blackpool International Airport', 34, 53.7717018127441, -3.02860999107361, 6132).
airport('BLK', 'Blackpool International Airport', 34, 53.7717018127441, -3.02860999107361, 5632).
airport('BLK', 'Blackpool International Airport', 34, 53.7717018127441, -3.02860999107361, 5132).
airport('PIK', 'Glasgow Prestwick Airport', 65, 55.5093994140625, -4.586669921875, 9800).
airport('PIK', 'Glasgow Prestwick Airport', 65, 55.5093994140625, -4.586669921875, 9300).
airport('CFN', 'Donegal Airport', 30, 55.0442008972168, -8.34099960327148, 4908).
airport('BZG', 'Bydgoszcz Ignacy Jan Paderewski Airport', 235, 53.0968017578, 17.9776992798, 8202).
airport('SZZ', 'Szczecin-Goleniów Solidarność Airport', 154, 53.5847015381, 14.9021997452, 8202).
airport('ALW', 'Walla Walla Regional Airport', 1194, 46.09489822, -118.288002, 6526).
airport('ALW', 'Walla Walla Regional Airport', 1194, 46.09489822, -118.288002, 6026).
airport('ALW', 'Walla Walla Regional Airport', 1194, 46.09489822, -118.288002, 5526).
airport('EAT', 'Pangborn Memorial Airport', 1249, 47.3988990784, -120.207000732, 5700).
airport('EAT', 'Pangborn Memorial Airport', 1249, 47.3988990784, -120.207000732, 5200).
airport('PIE', 'St Petersburg Clearwater International Airport', 11, 27.91020012, -82.68740082, 8800).
airport('PIE', 'St Petersburg Clearwater International Airport', 11, 27.91020012, -82.68740082, 8300).
airport('PIE', 'St Petersburg Clearwater International Airport', 11, 27.91020012, -82.68740082, 7800).
airport('PIE', 'St Petersburg Clearwater International Airport', 11, 27.91020012, -82.68740082, 7300).
airport('PUW', 'Pullman Moscow Regional Airport', 2556, 46.7439002990723, -117.110000610352, 6730).
airport('YKM', 'Yakima Air Terminal McAllister Field', 1099, 46.56819916, -120.5439987, 7603).
airport('YKM', 'Yakima Air Terminal McAllister Field', 1099, 46.56819916, -120.5439987, 7103).
airport('LRH', 'La Rochelle-Île de Ré Airport', 74, 46.17919921875, -1.19527995586395, 7398).
airport('RDZ', 'Rodez-Marcillac Airport', 1910, 44.407901763916, 2.48267006874084, 6693).
airport('CCF', 'Carcassonne Airport', 433, 43.2159996032715, 2.30631995201111, 6726).
airport('PGF', 'Perpignan-Rivesaltes (Llabanère) Airport', 144, 42.7403984069824, 2.87067008018494, 8202).
airport('PGF', 'Perpignan-Rivesaltes (Llabanère) Airport', 144, 42.7403984069824, 2.87067008018494, 7702).
airport('TUF', 'Tours-Val-de-Loire Airport', 357, 47.4322013855, 0.727605998516, 7887).
airport('CIY', 'Comiso Airport', 623, 36.9946010208, 14.6071815491, 8070).
airport('KTN', 'Ketchikan International Airport', 89, 55.35559845, -131.7140045, 9500).
airport('KTN', 'Ketchikan International Airport', 89, 55.35559845, -131.7140045, 9000).
airport('DOM', 'Melville Hall Airport', 73, 15.5469999313354, -61.2999992370605, 4777).
airport('SBH', 'Gustaf III Airport', 48, 17.9043998718262, -62.8436012268066, 2119).
airport('CPX', 'Benjamin Rivera Noriega Airport', 49, 18.313289, -65.304324, 2600).
airport('MAZ', 'Eugenio Maria De Hostos Airport', 28, 18.2556991577148, -67.1484985351562, 4998).
airport('VQS', 'Antonio Rivera Rodriguez Airport', 49, 18.1347999573, -65.493598938, 4301).
airport('NEV', 'Vance W. Amory International Airport', 14, 17.2056999206543, -62.589900970459, 3996).
airport('AXA', 'Wallblake Airport', 127, 18.2047996520996, -63.0550994873047, 5462).
airport('EIS', 'Terrance B. Lettsome International Airport', 15, 18.4447994232178, -64.5429992675781, 4642).
airport('VIJ', 'Virgin Gorda Airport', 14, 18.4463996887207, -64.4274978637695, 2500).
airport('YFB', 'Iqaluit Airport', 110, 63.756401062, -68.5558013916, 8605).
airport('SCK', 'Stockton Metropolitan Airport', 33, 37.8941993713379, -121.237998962402, 10650).
airport('SCK', 'Stockton Metropolitan Airport', 33, 37.8941993713379, -121.237998962402, 10150).
airport('PGD', 'Charlotte County Airport', 26, 26.92020035, -81.9905014, 6695).
airport('PGD', 'Charlotte County Airport', 26, 26.92020035, -81.9905014, 6195).
airport('PGD', 'Charlotte County Airport', 26, 26.92020035, -81.9905014, 5695).
airport('TAY', 'Tartu Airport', 219, 58.3074989319, 26.6903991699, 5902).
airport('IVL', 'Ivalo Airport', 481, 68.6072998046875, 27.4053001403809, 8199).
airport('IVL', 'Ivalo Airport', 481, 68.6072998046875, 27.4053001403809, 7699).
airport('JOE', 'Joensuu Airport', 398, 62.662899017334, 29.6075000762939, 8202).
airport('JOE', 'Joensuu Airport', 398, 62.662899017334, 29.6075000762939, 7702).
airport('JYV', 'Jyvaskyla Airport', 459, 62.3995018005371, 25.6783008575439, 8533).
airport('KEM', 'Kemi-Tornio Airport', 61, 65.7787017822266, 24.5820999145508, 8212).
airport('KAJ', 'Kajaani Airport', 483, 64.2854995727539, 27.6923999786377, 8199).
airport('KOK', 'Kruunupyy Airport', 84, 63.7211990356445, 23.1431007385254, 8202).
airport('KOK', 'Kruunupyy Airport', 84, 63.7211990356445, 23.1431007385254, 7702).
airport('KAO', 'Kuusamo Airport', 866, 65.9876022338867, 29.2394008636475, 8202).
airport('KUO', 'Kuopio Airport', 323, 63.0070991516113, 27.7978000640869, 9186).
airport('KUO', 'Kuopio Airport', 323, 63.0070991516113, 27.7978000640869, 8686).
airport('MHQ', 'Mariehamn Airport', 17, 60.122200012207, 19.8981990814209, 6243).
airport('OUL', 'Oulu Airport', 47, 64.9300994873047, 25.3546009063721, 8205).
airport('POR', 'Pori Airport', 44, 61.4617004394531, 21.7999992370605, 7713).
airport('POR', 'Pori Airport', 44, 61.4617004394531, 21.7999992370605, 7213).
airport('RVN', 'Rovaniemi Airport', 642, 66.5647964477539, 25.8304004669189, 9849).
airport('SVL', 'Savonlinna Airport', 311, 61.9430999755859, 28.9451007843018, 7546).
airport('TMP', 'Tampere-Pirkkala Airport', 390, 61.4141006469727, 23.6044006347656, 8858).
airport('TKU', 'Turku Airport', 161, 60.5140991210938, 22.2628002166748, 8202).
airport('VAA', 'Vaasa Airport', 19, 63.0507011413574, 21.7621994018555, 8727).
airport('BMA', 'Stockholm-Bromma Airport', 47, 59.3544006347656, 17.9416999816895, 5472).
airport('NRK', 'Norrköping Airport', 32, 58.5862998962402, 16.2506008148193, 7228).
airport('NRK', 'Norrköping Airport', 32, 58.5862998962402, 16.2506008148193, 6728).
airport('GZP', 'Gazipaşa Airport', 86, 36.2992172241, 32.3005981445, 7710).
airport('CEE', 'Cherepovets Airport', 377, 59.273601532, 38.0158004761, 8277).
airport('HEA', 'Herat Airport', 3206, 34.2099990844727, 62.2282981872559, 8218).
airport('IXU', 'Aurangabad Airport', 1911, 19.862699508667, 75.3981018066406, 7713).
airport('BDQ', 'Vadodara Airport', 129, 22.3362007141, 73.2263031006, 8100).
airport('BHO', 'Raja Bhoj International Airport', 1711, 23.2875003815, 77.3374023438, 6700).
airport('BHO', 'Raja Bhoj International Airport', 1711, 23.2875003815, 77.3374023438, 6200).
airport('IDR', 'Devi Ahilyabai Holkar Airport', 1850, 22.7217998505, 75.8011016846, 7480).
airport('JLR', 'Jabalpur Airport', 1624, 23.1777992248535, 80.052001953125, 6522).
airport('NAG', 'Dr. Babasaheb Ambedkar International Airport', 1033, 21.0921993255615, 79.0472030639648, 10500).
airport('NAG', 'Dr. Babasaheb Ambedkar International Airport', 1033, 21.0921993255615, 79.0472030639648, 10000).
airport('RPR', 'Raipur Airport', 1041, 21.1804008484, 81.7388000488, 6414).
airport('STV', 'Surat Airport', 16, 21.1140995026, 72.7417984009, 7382).
airport('UDR', 'Maharana Pratap Airport', 1684, 24.6177005768, 73.8961029053, 7484).
airport('IXB', 'Bagdogra Airport', 412, 26.6812000274658, 88.3285980224609, 9035).
airport('BBI', 'Biju Patnaik Airport', 138, 20.2444000244, 85.8178024292, 7359).
airport('BBI', 'Biju Patnaik Airport', 138, 20.2444000244, 85.8178024292, 6859).
airport('GOP', 'Gorakhpur Airport', 259, 26.7397003174, 83.4496994019, 9000).
airport('GAU', 'Lokpriya Gopinath Bordoloi International Airport', 162, 26.1061000823975, 91.5858993530273, 9000).
airport('DIB', 'Dibrugarh Airport', 362, 27.4839000702, 95.0168991089, 6000).
airport('PAT', 'Lok Nayak Jayaprakash Airport', 170, 25.591299057, 85.0879974365, 6410).
airport('IXR', 'Birsa Munda Airport', 2148, 23.3143005371, 85.3217010498, 8855).
airport('IXD', 'Allahabad Airport', 322, 25.4400997161865, 81.7339019775391, 8110).
airport('IXD', 'Allahabad Airport', 322, 25.4400997161865, 81.7339019775391, 7610).
airport('KUU', 'Kullu Manali Airport', 3573, 31.8766994476318, 77.1544036865234, 3690).
airport('IXC', 'Chandigarh Airport', 1012, 30.6735000610352, 76.7884979248047, 9001).
airport('DED', 'Dehradun Airport', 1831, 30.189699173, 78.1802978516, 3755).
airport('DHM', 'Kangra Airport', 2525, 32.1651000976562, 76.2633972167969, 4620).
airport('IXJ', 'Jammu Airport', 1029, 32.6890983582, 74.8374023438, 6755).
airport('KNU', 'Kanpur Airport', 411, 26.4414005279541, 80.3648986816406, 3685).
airport('LUH', 'Ludhiana Airport', 834, 30.854700088501, 75.9525985717773, 4800).
airport('IXL', 'Leh Kushok Bakula Rimpochee Airport', 10682, 34.1358985901, 77.5465011597, 9040).
airport('IXL', 'Leh Kushok Bakula Rimpochee Airport', 10682, 34.1358985901, 77.5465011597, 8540).
airport('IXL', 'Leh Kushok Bakula Rimpochee Airport', 10682, 34.1358985901, 77.5465011597, 8040).
airport('SXR', 'Sheikh ul Alam Airport', 5429, 33.9870986938477, 74.7742004394531, 12090).
airport('ALH', 'Albany Airport', 233, -34.9432983398438, 117.80899810791, 5906).
airport('ALH', 'Albany Airport', 233, -34.9432983398438, 117.80899810791, 5406).
airport('BQB', 'Busselton Regional Airport', 55, -33.6884231567, 115.401596069, 5906).
airport('DCN', 'RAAF Base Curtin', 300, -17.5813999176, 123.82800293, 10003).
airport('EPR', 'Esperance Airport', 470, -33.684398651123, 121.822998046875, 4921).
airport('EPR', 'Esperance Airport', 470, -33.684398651123, 121.822998046875, 4421).
airport('GET', 'Geraldton Airport', 121, -28.7961006164551, 114.707000732422, 6499).
airport('GET', 'Geraldton Airport', 121, -28.7961006164551, 114.707000732422, 5999).
airport('GET', 'Geraldton Airport', 121, -28.7961006164551, 114.707000732422, 5499).
airport('RVT', 'Ravensthorpe Airport', 197, -33.7971992493, 120.208000183, 5512).
airport('RVT', 'Ravensthorpe Airport', 197, -33.7971992493, 120.208000183, 5012).
airport('ZNE', 'Newman Airport', 1724, -23.4178009033, 119.803001404, 6798).
airport('PBO', 'Paraburdoo Airport', 1406, -23.1711006165, 117.745002747, 6995).
airport('KNX', 'Kununurra Airport', 145, -15.7781000137, 128.707992554, 6000).
airport('LEA', 'Learmonth Airport', 19, -22.2355995178, 114.088996887, 9997).
airport('XCH', 'Christmas Island Airport', 916, -10.4505996704102, 105.690002441406, 6900).
airport('PAD', 'Paderborn Lippstadt Airport', 699, 51.6141014099, 8.61631965637, 7152).
airport('NRN', 'Niederrhein Airport', 106, 51.6024017334, 6.14216995239, 8005).
airport('LDY', 'City of Derry Airport', 22, 55.0428009033203, -7.16110992431641, 6076).
airport('LDY', 'City of Derry Airport', 22, 55.0428009033203, -7.16110992431641, 5576).
airport('CAL', 'Campbeltown Airport', 42, 55.437198638916, -5.6863899230957, 10003).
airport('KOI', 'Kirkwall Airport', 50, 58.9578018188477, -2.90499997138977, 4685).
airport('KOI', 'Kirkwall Airport', 50, 58.9578018188477, -2.90499997138977, 4185).
airport('KOI', 'Kirkwall Airport', 50, 58.9578018188477, -2.90499997138977, 3685).
airport('LSI', 'Sumburgh Airport, Shetland Islands', 20, 59.8788986206055, -1.29556000232697, 4678).
airport('LSI', 'Sumburgh Airport, Shetland Islands', 20, 59.8788986206055, -1.29556000232697, 4178).
airport('LSI', 'Sumburgh Airport, Shetland Islands', 20, 59.8788986206055, -1.29556000232697, 3678).
airport('WIC', 'Wick Airport', 126, 58.4589004516602, -3.09306001663208, 5988).
airport('WIC', 'Wick Airport', 126, 58.4589004516602, -3.09306001663208, 5488).
airport('ILY', 'Islay Airport', 56, 55.6819000244141, -6.25666999816895, 5069).
airport('ILY', 'Islay Airport', 56, 55.6819000244141, -6.25666999816895, 4569).
airport('BEB', 'Benbecula Airport', 19, 57.4810981750488, -7.36278009414673, 6024).
airport('BEB', 'Benbecula Airport', 19, 57.4810981750488, -7.36278009414673, 5524).
airport('SYY', 'Stornoway Airport', 26, 58.2155990600586, -6.33111000061035, 7218).
airport('SYY', 'Stornoway Airport', 26, 58.2155990600586, -6.33111000061035, 6718).
airport('BRR', 'Barra Airport', 5, 57.0228004455566, -7.44305992126465, 2776).
airport('BRR', 'Barra Airport', 5, 57.0228004455566, -7.44305992126465, 2276).
airport('BRR', 'Barra Airport', 5, 57.0228004455566, -7.44305992126465, 1776).
airport('TRE', 'Tiree Airport', 38, 56.4991989135742, -6.86917018890381, 4600).
airport('TRE', 'Tiree Airport', 38, 56.4991989135742, -6.86917018890381, 4100).
airport('TRE', 'Tiree Airport', 38, 56.4991989135742, -6.86917018890381, 3600).
airport('GSE', 'Gothenburg City Airport', 59, 57.7747001647949, 11.870400428772, 6689).
airport('GSE', 'Gothenburg City Airport', 59, 57.7747001647949, 11.870400428772, 6189).
airport('NYO', 'Stockholm Skavsta Airport', 140, 58.7886009216309, 16.9122009277344, 9442).
airport('NYO', 'Stockholm Skavsta Airport', 140, 58.7886009216309, 16.9122009277344, 8942).
airport('RLG', 'Rostock-Laage Airport', 138, 53.9182014465, 12.2783002853, 8202).
airport('BJL', 'Banjul International Airport', 95, 13.3380002975464, -16.6522006988525, 11811).
airport('FEZ', 'Saïss Airport', 1900, 33.9272994995, -4.97796010971, 10499).
airport('OUD', 'Angads Airport', 1535, 34.7872009277344, -1.92399001121521, 9843).
airport('BJM', 'Bujumbura International Airport', 2582, -3.32401990890503, 29.3185005187988, 11811).
airport('BJM', 'Bujumbura International Airport', 2582, -3.32401990890503, 29.3185005187988, 11311).
airport('RGS', 'Burgos Airport', 2945, 42.3576011657715, -3.62075996398926, 4393).
airport('LEN', 'Leon Airport', 3006, 42.5890007019043, -5.65556001663208, 6890).
airport('LEN', 'Leon Airport', 3006, 42.5890007019043, -5.65556001663208, 6390).
airport('SLM', 'Salamanca Airport', 2595, 40.9520988464355, -5.50198984146118, 8202).
airport('SLM', 'Salamanca Airport', 2595, 40.9520988464355, -5.50198984146118, 7702).
airport('VLL', 'Valladolid Airport', 2776, 41.7061004639, -4.85194015503, 9843).
airport('VLL', 'Valladolid Airport', 2776, 41.7061004639, -4.85194015503, 9343).
airport('EGC', 'Bergerac-Roumanière Airport', 171, 44.8252983093262, 0.518611013889313, 7234).
airport('PIS', 'Poitiers-Biard Airport', 423, 46.5876998901367, 0.306665986776352, 7710).
airport('AOK', 'Karpathos Airport', 66, 35.4213981628418, 27.1459999084473, 7871).
airport('KVA', 'Alexander the Great International Airport', 18, 40.9132995605469, 24.6191997528076, 9844).
airport('MJT', 'Mytilene International Airport', 60, 39.0567016602, 26.5983009338, 7894).
airport('LMP', 'Lampedusa Airport', 70, 35.4978981018066, 12.6181001663208, 5906).
airport('PNL', 'Pantelleria Airport', 628, 36.8165016174316, 11.9688997268677, 5495).
airport('PNL', 'Pantelleria Airport', 628, 36.8165016174316, 11.9688997268677, 4995).
airport('REG', 'Reggio Calabria Airport', 96, 38.0712013244629, 15.6515998840332, 6549).
airport('REG', 'Reggio Calabria Airport', 96, 38.0712013244629, 15.6515998840332, 6049).
airport('TRS', 'Trieste–Friuli Venezia Giulia Airport', 39, 45.8274993896, 13.4722003937, 9843).
airport('AOI', 'Ancona Falconara Airport', 49, 43.6162986755, 13.3622999191, 9718).
airport('AOE', 'Anadolu University Airport', 2588, 39.8098983765, 30.5193996429, 8261).
airport('DOK', 'Donetsk International Airport', 791, 48.073600769043, 37.7397003173828, 13123).
airport('IEV', 'Kiev Zhuliany International Airport', 586, 50.4016990661621, 30.4496994018555, 5905).
airport('CEK', 'Chelyabinsk Balandino Airport', 769, 55.3058013916016, 61.5032997131348, 10499).
airport('PEE', 'Bolshoye Savino Airport', 404, 57.9145011901855, 56.0211982727051, 10520).
airport('VOZ', 'Voronezh International Airport', 514, 51.8142013549805, 39.2295989990234, 7546).
airport('RTW', 'Saratov Central Airport', 499, 51.564998626709, 46.0466995239258, 7485).
airport('UFA', 'Ufa International Airport', 449, 54.5574989318848, 55.8744010925293, 12339).
airport('UFA', 'Ufa International Airport', 449, 54.5574989318848, 55.8744010925293, 11839).
airport('UFA', 'Ufa International Airport', 449, 54.5574989318848, 55.8744010925293, 11339).
airport('UFA', 'Ufa International Airport', 449, 54.5574989318848, 55.8744010925293, 10839).
airport('UFA', 'Ufa International Airport', 449, 54.5574989318848, 55.8744010925293, 10339).
airport('BZO', 'Bolzano Airport', 789, 46.4602012634277, 11.3263998031616, 4255).
airport('BZO', 'Bolzano Airport', 789, 46.4602012634277, 11.3263998031616, 3755).
airport('AAR', 'Aarhus Airport', 82, 56.2999992371, 10.6190004349, 9111).
airport('AAR', 'Aarhus Airport', 82, 56.2999992371, 10.6190004349, 8611).
airport('ALF', 'Alta Airport', 9, 69.9760971069336, 23.3717002868652, 7165).
airport('FDE', 'Bringeland Airport', 1046, 61.3911018371582, 5.75693988800049, 3084).
airport('BNN', 'Brønnøysund Airport', 25, 65.4610977172852, 12.2174997329712, 3937).
airport('BOO', 'Bodø Airport', 42, 67.2692031860352, 14.3653001785278, 11136).
airport('BDU', 'Bardufoss Airport', 252, 69.0558013916016, 18.5403995513916, 8015).
airport('EVE', 'Harstad/Narvik Airport, Evenes', 84, 68.4913024902344, 16.6781005859375, 9236).
airport('VDB', 'Leirin Airport', 2697, 61.0155982971191, 9.28806018829346, 6722).
airport('FRO', 'Florø Airport', 37, 61.5835990905762, 5.02472019195557, 3934).
airport('HAU', 'Haugesund Airport', 86, 59.3452987670898, 5.20836019515991, 6957).
airport('KSU', 'Kristiansund Airport, Kvernberget', 204, 63.1118011474609, 7.82452011108398, 6037).
airport('KKN', 'Kirkenes Airport, Høybuktmoen', 283, 69.7257995605469, 29.891300201416, 6939).
airport('MOL', 'Molde Airport', 10, 62.744701385498, 7.26249980926514, 6922).
airport('OLA', 'Ørland Airport', 28, 63.6988983154297, 9.60400009155273, 8904).
airport('HOV', 'Ørsta-Volda Airport, Hovden', 243, 62.1800003051758, 6.07410001754761, 2920).
airport('RRS', 'Røros Airport', 2054, 62.5783996582031, 11.3423004150391, 5643).
airport('LYR', 'Svalbard Airport, Longyear', 88, 78.2461013793945, 15.4656000137329, 7608).
airport('SDN', 'Sandane Airport, Anda', 196, 61.8300018310547, 6.10583019256592, 2756).
airport('SOG', 'Sogndal Airport', 1633, 61.1561012268066, 7.13778018951416, 3150).
airport('SRP', 'Stord Airport', 160, 59.7919006347656, 5.34084987640381, 3937).
airport('SSJ', 'Sandnessjøen Airport, Stokka', 56, 65.9568023681641, 12.4688997268677, 3563).
airport('PLQ', 'Palanga International Airport', 33, 55.973201751709, 21.093900680542, 6562).
airport('FKB', 'Karlsruhe Baden-Baden Airport', 408, 48.7793998718, 8.08049964905, 9787).
airport('DND', 'Dundee Airport', 17, 56.4524993896484, -3.02583003044128, 4593).
airport('MMX', 'Malmö Sturup Airport', 236, 55.536305364, 13.3761978149, 9186).
airport('MMX', 'Malmö Sturup Airport', 236, 55.536305364, 13.3761978149, 8686).
airport('SFT', 'Skellefteå Airport', 157, 64.6248016357422, 21.0769004821777, 6890).
airport('VST', 'Stockholm Västerås Airport', 21, 59.5894012451172, 16.6336002349854, 8468).
airport('PDV', 'Plovdiv International Airport', 597, 42.067798614502, 24.8507995605469, 8202).
airport('OSI', 'Osijek Airport', 290, 45.4626998901367, 18.8101997375488, 8199).
airport('ZAZ', 'Zaragoza Air Base', 863, 41.6661987304688, -1.04155004024506, 12198).
airport('ZAZ', 'Zaragoza Air Base', 863, 41.6661987304688, -1.04155004024506, 11698).
airport('DNR', 'Dinard-Pleurtuit-Saint-Malo Airport', 219, 48.5876998901367, -2.07996010780334, 7218).
airport('DNR', 'Dinard-Pleurtuit-Saint-Malo Airport', 219, 48.5876998901367, -2.07996010780334, 6718).
airport('TLN', 'Toulon-Hyères Airport', 7, 43.0973014832, 6.14602994919, 6955).
airport('TLN', 'Toulon-Hyères Airport', 7, 43.0973014832, 6.14602994919, 6455).
airport('PSR', 'Pescara International Airport', 48, 42.4317016601562, 14.1810998916626, 7933).
airport('PMF', 'Parma Airport', 161, 44.8245010375977, 10.2964000701904, 6962).
airport('PEG', "Perugia San Francesco d'Assisi – Umbria International Airport", 697, 43.0959014893, 12.5131998062, 5564).
airport('BRQ', 'Brno-Tuřany Airport', 778, 49.1512985229492, 16.6944007873535, 8694).
airport('HIR', 'Honiara International Airport', 28, -9.42800045013428, 160.054992675781, 7218).
airport('YBC', 'Baie Comeau Airport', 71, 49.1324996948242, -68.2043991088867, 6000).
airport('YBG', 'CFB Bagotville', 522, 48.3306007385254, -70.9963989257812, 10000).
airport('YBG', 'CFB Bagotville', 522, 48.3306007385254, -70.9963989257812, 9500).
airport('YGL', 'La Grande Rivière Airport', 639, 53.625301361084, -77.7042007446289, 6500).
airport('YGW', 'Kuujjuarapik Airport', 34, 55.2818984985352, -77.7652969360352, 5052).
airport('YHM', 'John C. Munro Hamilton International Airport', 780, 43.1735992432, -79.9349975586, 10000).
airport('YHM', 'John C. Munro Hamilton International Airport', 780, 43.1735992432, -79.9349975586, 9500).
airport('YHY', 'Hay River / Merlyn Carter Airport', 541, 60.8396987915, -115.782997131, 6000).
airport('YHY', 'Hay River / Merlyn Carter Airport', 541, 60.8396987915, -115.782997131, 5500).
airport('YMT', 'Chapais Airport', 1270, 49.771900177002, -74.5280990600586, 6496).
airport('YOJ', 'High Level Airport', 1110, 58.6213989257812, -117.165000915527, 5000).
airport('YOP', 'Rainbow Lake Airport', 1759, 58.4914016723633, -119.407997131348, 4539).
airport('YQU', 'Grande Prairie Airport', 2195, 55.1796989441, -118.885002136, 6500).
airport('YQU', 'Grande Prairie Airport', 2195, 55.1796989441, -118.885002136, 6000).
airport('YSM', 'Fort Smith Airport', 671, 60.0203018188477, -111.96199798584, 6000).
airport('YSM', 'Fort Smith Airport', 671, 60.0203018188477, -111.96199798584, 5500).
airport('YUY', 'Rouyn Noranda Airport', 988, 48.2061004638672, -78.8356018066406, 7485).
airport('YVO', "Val-d'Or Airport", 1107, 48.0532989502, -77.7827987671, 10000).
airport('YVP', 'Kuujjuaq Airport', 129, 58.0960998535156, -68.4269027709961, 6000).
airport('YVP', 'Kuujjuaq Airport', 129, 58.0960998535156, -68.4269027709961, 5500).
airport('YWK', 'Wabush Airport', 1808, 52.9219017028809, -66.8644027709961, 6002).
airport('YXX', 'Abbotsford Airport', 195, 49.0252990722656, -122.361000061035, 9600).
airport('YXX', 'Abbotsford Airport', 195, 49.0252990722656, -122.361000061035, 9100).
airport('YXX', 'Abbotsford Airport', 195, 49.0252990722656, -122.361000061035, 8600).
airport('YYY', 'Mont Joli Airport', 172, 48.6086006164551, -68.2080993652344, 6000).
airport('YYY', 'Mont Joli Airport', 172, 48.6086006164551, -68.2080993652344, 5500).
airport('YZV', 'Sept-Îles Airport', 180, 50.2233009338379, -66.2656021118164, 6552).
airport('YZV', 'Sept-Îles Airport', 180, 50.2233009338379, -66.2656021118164, 6052).
airport('YZV', 'Sept-Îles Airport', 180, 50.2233009338379, -66.2656021118164, 5552).
airport('ZBF', 'Bathurst Airport', 193, 47.629699707, -65.738899231, 4500).
airport('SDL', 'Sundsvall-Härnösand Airport', 16, 62.5280990600586, 17.4438991546631, 6857).
airport('BLE', 'Borlange Airport', 503, 60.4220008850098, 15.5151996612549, 7579).
airport('FSP', 'St Pierre Airport', 27, 46.7629013061523, -56.1730995178223, 5900).
airport('TIJ', 'General Abelardo L. Rodríguez International Airport', 489, 32.5410995483398, -116.970001220703, 9711).
airport('CYO', 'Vilo Acuña International Airport', 10, 21.6165008545, -81.5459976196, 9869).
airport('SON', 'Santo Pekoa International Airport', 184, -15.5050001144, 167.220001221, 6523).
airport('HKK', 'Hokitika Airfield', 146, -42.7136001586914, 170.985000610352, 4311).
airport('HKK', 'Hokitika Airfield', 146, -42.7136001586914, 170.985000610352, 3811).
airport('IVC', 'Invercargill Airport', 5, -46.4123992919922, 168.313003540039, 7251).
airport('IVC', 'Invercargill Airport', 5, -46.4123992919922, 168.313003540039, 6751).
airport('IVC', 'Invercargill Airport', 5, -46.4123992919922, 168.313003540039, 6251).
airport('IVC', 'Invercargill Airport', 5, -46.4123992919922, 168.313003540039, 5751).
airport('TIU', 'Timaru Airport', 89, -44.3027992248535, 171.225006103516, 4200).
airport('TIU', 'Timaru Airport', 89, -44.3027992248535, 171.225006103516, 3700).
airport('TIU', 'Timaru Airport', 89, -44.3027992248535, 171.225006103516, 3200).
airport('WSZ', 'Westport Airport', 13, -41.7380981445312, 171.580993652344, 4200).
airport('BCI', 'Barcaldine Airport', 878, -23.5652999878, 145.307006836, 5591).
airport('BCI', 'Barcaldine Airport', 878, -23.5652999878, 145.307006836, 5091).
airport('BKQ', 'Blackall Airport', 928, -24.4277992249, 145.429000854, 5538).
airport('BKQ', 'Blackall Airport', 928, -24.4277992249, 145.429000854, 5038).
airport('CTL', 'Charleville Airport', 1003, -26.4132995605, 146.261993408, 5000).
airport('CTL', 'Charleville Airport', 1003, -26.4132995605, 146.261993408, 4500).
airport('ISA', 'Mount Isa Airport', 1121, -20.6639003754, 139.488998413, 8399).
airport('ISA', 'Mount Isa Airport', 1121, -20.6639003754, 139.488998413, 7899).
airport('ROK', 'Rockhampton Airport', 34, -23.3819007874, 150.475006104, 8622).
airport('ROK', 'Rockhampton Airport', 34, -23.3819007874, 150.475006104, 8122).
airport('BDB', 'Bundaberg Airport', 107, -24.9039001465, 152.319000244, 5030).
airport('BDB', 'Bundaberg Airport', 107, -24.9039001465, 152.319000244, 4530).
airport('CNJ', 'Cloncurry Airport', 616, -20.6686000824, 140.503997803, 6562).
airport('CNJ', 'Cloncurry Airport', 616, -20.6686000824, 140.503997803, 6062).
airport('EMD', 'Emerald Airport', 624, -23.5674991608, 148.179000854, 6234).
airport('EMD', 'Emerald Airport', 624, -23.5674991608, 148.179000854, 5734).
airport('LRE', 'Longreach Airport', 627, -23.4342002869, 144.279998779, 6352).
airport('LRE', 'Longreach Airport', 627, -23.4342002869, 144.279998779, 5852).
airport('MOV', 'Moranbah Airport', 770, -22.057800293, 148.07699585, 5000).
airport('RMA', 'Roma Airport', 1032, -26.5450000763, 148.774993896, 4934).
airport('RMA', 'Roma Airport', 1032, -26.5450000763, 148.774993896, 4434).
airport('DOY', 'Dongying Shengli Airport', 15, 37.5085983276, 118.788002014, 6890).
airport('DDG', 'Dandong Airport', 18, 40.0247001648, 124.286003113, 8530).
airport('NTG', 'Nantong Airport', 16, 32.0708007812, 120.975997925, 11155).
airport('DQA', 'Saertu Airport', 496, 46.7463888889, 125.140555556, 8530).
airport('HIA', 'Lianshui Airport', 28, 33.7908333333, 119.125, 7874).
airport('JIQ', 'Qianjiang Wulingshan Airport', 2075, 29.5133333333, 108.831111111, 7874).
airport('NBS', 'Changbaishan Airport', 2874, 42.0669444444, 127.602222222, 8530).
airport('CIF', 'Chifeng Airport', 1902, 42.2350006103516, 118.907997131348, 5774).
airport('CIH', 'Changzhi Airport', 3015, 36.247501373291, 113.125999450684, 8530).
airport('DSN', 'Ordos Ejin Horo Airport', 4557, 39.49, 109.861388889, 9186).
airport('DAT', 'Datong Airport', 3442, 40.0602989196777, 113.482002258301, 7874).
airport('ERL', 'Erenhot Saiwusu International Airport', 3301, 43.4225, 112.096666667, 7874).
airport('HET', 'Baita International Airport', 3556, 40.851398468, 111.823997498, 11811).
airport('HET', 'Baita International Airport', 3556, 40.851398468, 111.823997498, 11311).
airport('BAV', 'Baotou Airport', 3321, 40.560001373291, 109.997001647949, 8038).
airport('TGO', 'Tongliao Airport', 584, 43.5567016601562, 122.199996948242, 7546).
airport('WUA', 'Wuhai Airport', 3650, 39.7934, 106.7993, 7546).
airport('HLH', 'Ulanhot Airport', 981, 46.195333, 122.008333, 5906).
airport('XIL', 'Xilinhot Airport', 3316, 43.915599822998, 115.963996887207, 5906).
airport('YCU', 'Yuncheng Guangong Airport', 1242, 35.116391, 111.031388889, 9843).
airport('BHY', 'Beihai Airport', 75, 21.539400100708, 109.293998718262, 10499).
airport('CGD', 'Changde Airport', 128, 28.9188995361, 111.63999939, 8366).
airport('DYG', 'Dayong Airport', 692, 29.1028003692627, 110.443000793457, 8530).
airport('KWL', 'Guilin Liangjiang International Airport', 570, 25.2180995941162, 110.039001464844, 9186).
airport('ZUH', 'Zhuhai Airport', 18, 22.0063991546631, 113.375999450684, 13123).
airport('LZH', 'Bailian Airport', 295, 24.2075004577637, 109.390998840332, 8202).
airport('ZHA', 'Zhanjiang Airport', 121, 21.2143993377686, 110.358001708984, 7546).
airport('LYA', 'Luoyang Airport', 840, 34.7411003113, 112.388000488, 8202).
airport('XFN', 'Xiangfan Airport', 219, 32.1506004333496, 112.291000366211, 7808).
airport('YIH', 'Yichang Airport', 643, 30.556549722, 111.479988333, 8500).
airport('INC', 'Yinchuan Airport', 3763, 38.4818992614746, 106.009002685547, 10499).
airport('JNG', 'Jining Qufu Airport', 134, 35.2927777778, 116.346666667, 9186).
airport('XNN', 'Xining Caojiabu Airport', 7112, 36.5275001525879, 102.042999267578, 9843).
airport('ENY', "Yan'an Airport", 3087, 36.6369018554688, 109.554000854492, 9186).
airport('UYN', 'Yulin Airport', 3865, 38.2691993713379, 109.731002807617, 9186).
airport('ZHY', 'Zhongwei Shapotou Airport', 4040, 37.573125, 105.154454, 9186).
airport('LUM', 'Mangshi Airport', 2890, 24.4011001586914, 98.5317001342773, 7218).
airport('AQG', 'Anqing Airport', 46, 30.5821990966797, 117.050003051758, 9186).
airport('CZX', 'Changzhou Airport', 19, 31.9197006225586, 119.778999328613, 9186).
airport('FUG', 'Fuyang Xiguan Airport', 104, 32.882157, 115.734364, 7874).
airport('KOW', 'Ganzhou Airport', 387, 25.853333, 114.778889, 8530).
airport('JDZ', 'Jingdezhen Airport', 112, 29.3386001587, 117.176002502, 7874).
airport('JIU', 'Jiujiang Lushan Airport', 142, 29.476944, 115.801111, 9186).
airport('LYG', 'Lianyungang Airport', 46, 34.571667, 118.873611, 8202).
airport('HYN', 'Huangyan Luqiao Airport', 10, 28.5622005462646, 121.429000854492, 8202).
airport('LYI', 'Shubuling Airport', 203, 35.0461006164551, 118.412002563477, 7546).
airport('HFE', 'Hefei Luogang International Airport', 108, 31.7800006866455, 117.297996520996, 11155).
airport('JJN', 'Quanzhou Airport', 20, 24.7964000701904, 118.589996337891, 8465).
airport('TXN', 'Tunxi International Airport', 446, 29.7332992553711, 118.255996704102, 8530).
airport('WEF', 'Weifang Airport', 125, 36.6467018127441, 119.119003295898, 8530).
airport('WUS', 'Nanping Wuyishan Airport', 614, 27.7019004821777, 118.000999450684, 6890).
airport('WNZ', 'Wenzhou Yongqiang Airport', 10, 27.9122009277344, 120.851997375488, 7874).
airport('YNZ', 'Yancheng Airport', 10, 33.425833, 120.203056, 7218).
airport('YIW', 'Yiwu Airport', 262, 29.3446998596, 120.031997681, 8202).
airport('HSN', 'Zhoushan Airport', 3, 29.9342002869, 122.361999512, 7546).
airport('DAX', 'Dachuan Airport', 919, 31.1302, 107.4295, 6562).
airport('GYS', 'Guangyuan Airport', 2018, 32.3911018371582, 105.702003479004, 8202).
airport('LZO', 'Luzhou Airport', 807, 28.8521995544434, 105.392997741699, 7874).
airport('MXZ', 'Meixian Airport', 321, 24.3500003814697, 116.133003234863, 7874).
airport('YYE', 'Fort Nelson Airport', 1253, 58.8363990784, -122.597000122, 6400).
airport('YYE', 'Fort Nelson Airport', 1253, 58.8363990784, -122.597000122, 5900).
airport('YYE', 'Fort Nelson Airport', 1253, 58.8363990784, -122.597000122, 5400).
airport('NAY', 'Beijing Nanyuan Airport', 131, 39.7827987670898, 116.388000488281, 9514).
airport('CUL', 'Bachigualato Federal International Airport', 108, 24.7644996643, -107.474998474, 7546).
airport('CTM', 'Chetumal International Airport', 39, 18.5046997070312, -88.3267974853516, 7244).
airport('CEN', 'Ciudad Obregón International Airport', 243, 27.392599105835, -109.833000183105, 7546).
airport('CPE', 'Ingeniero Alberto Acuña Ongay International Airport', 34, 19.8167991638, -90.5002975464, 8202).
airport('CJS', 'Abraham González International Airport', 3904, 31.636100769043, -106.429000854492, 8858).
airport('CJS', 'Abraham González International Airport', 3904, 31.636100769043, -106.429000854492, 8358).
airport('CVM', 'General Pedro Jose Mendez International Airport', 761, 23.7033004761, -98.9564971924, 7218).
airport('CVM', 'General Pedro Jose Mendez International Airport', 761, 23.7033004761, -98.9564971924, 6718).
airport('TPQ', 'Amado Nervo National Airport', 3020, 21.4195003509521, -104.843002319336, 7546).
airport('CLQ', 'Licenciado Miguel de la Madrid Airport', 2467, 19.2770004272, -103.577003479, 7546).
airport('JAL', 'El Lencero Airport', 3127, 19.4750995636, -96.7975006104, 5577).
airport('LZC', 'Lázaro Cárdenas Airport', 39, 18.0016994476, -102.221000671, 4900).
airport('LMM', 'Valle del Fuerte International Airport', 16, 25.6851997375, -109.081001282, 6562).
airport('LAP', 'Manuel Márquez de León International Airport', 69, 24.0727005005, -110.361999512, 8202).
airport('MAM', 'General Servando Canales International Airport', 25, 25.7698993683, -97.5252990723, 7546).
airport('MXL', 'General Rodolfo Sánchez Taboada International Airport', 74, 32.6305999756, -115.241996765, 8530).
airport('MTT', 'Minatitlán/Coatzacoalcos National Airport', 36, 18.1033992767, -94.5807037354, 6890).
airport('NLD', 'Quetzalcóatl International Airport', 484, 27.4438991547, -99.5705032349, 6562).
airport('PAZ', 'El Tajín National Airport', 497, 20.6026992798, -97.4608001709, 5906).
airport('PDS', 'Piedras Negras International Airport', 901, 28.6273994445801, -100.535003662109, 6655).
airport('PQM', 'Palenque International Airport', 200, 17.5333995819092, -91.9844970703125, 4888).
airport('PXM', 'Puerto Escondido International Airport', 294, 15.8768997192, -97.0891036987, 7546).
airport('REX', 'General Lucio Blanco International Airport', 139, 26.0088996887, -98.2285003662, 6243).
airport('TGZ', 'Angel Albino Corzo International Airport', 1499, 16.5636005402, -93.0224990845, 8202).
airport('TGZ', 'Angel Albino Corzo International Airport', 1499, 16.5636005402, -93.0224990845, 7702).
airport('TGZ', 'Angel Albino Corzo International Airport', 1499, 16.5636005402, -93.0224990845, 7202).
airport('TAP', 'Tapachula International Airport', 97, 14.7943000793, -92.3700027466, 6562).
airport('ROS', 'Islas Malvinas Airport', 85, -32.9036, -60.785, 9842).
airport('AEP', 'Jorge Newbery Airpark', 18, -34.5592, -58.4156, 6890).
airport('COR', 'Ingeniero Ambrosio Taravella Airport', 1604, -31.323600769, -64.2080001831, 10499).
airport('COR', 'Ingeniero Ambrosio Taravella Airport', 1604, -31.323600769, -64.2080001831, 9999).
airport('MDZ', 'El Plumerillo Airport', 2310, -32.8316993713, -68.7929000854, 9301).
airport('IGR', 'Cataratas Del Iguazú International Airport', 916, -25.7373008728, -54.473400116, 10827).
airport('REL', 'Almirante Marco Andres Zar Airport', 141, -43.2105, -65.2703, 8399).
airport('FTE', 'El Calafate Airport', 669, -50.2803001404, -72.0531005859, 8366).
airport('USH', 'Malvinas Argentinas Airport', 102, -54.8433, -68.2958, 9186).
airport('BRC', 'San Carlos De Bariloche Airport', 2774, -41.1511993408, -71.1575012207, 7703).
airport('AJU', 'Santa Maria Airport', 23, -10.984000206, -37.0703010559, 7218).
airport('ARU', 'Araçatuba Airport', 1361, -21.1413002014, -50.4247016907, 6955).
airport('PLU', 'Pampulha - Carlos Drummond de Andrade Airport', 2589, -19.8512001037598, -43.9505996704102, 8333).
airport('CAC', 'Cascavel Airport', 2473, -25.0002994537, -53.5008010864, 5299).
airport('CGR', 'Campo Grande Airport', 1833, -20.4687004089, -54.6725006104, 8530).
airport('CGB', 'Marechal Rondon Airport', 617, -15.6528997421, -56.1166992188, 7546).
airport('IGU', 'Cataratas International Airport', 786, -25.6002788543701, -54.4850006103516, 7201).
airport('FLN', 'Hercílio Luz International Airport', 16, -27.6702785491943, -48.5525016784668, 7546).
airport('FLN', 'Hercílio Luz International Airport', 16, -27.6702785491943, -48.5525016784668, 7046).
airport('FOR', 'Pinto Martins International Airport', 82, -3.77627992630005, -38.532600402832, 8350).
airport('GYN', 'Santa Genoveva Airport', 2450, -16.6319999694824, -49.2206993103027, 8202).
airport('IOS', 'Bahia - Jorge Amado Airport', 15, -14.8159999847412, -39.0331993103027, 5174).
airport('IPN', 'Usiminas Airport', 784, -19.4706993103027, -42.4875984191895, 6575).
airport('JPA', 'Presidente Castro Pinto International Airport', 217, -7.14583301544, -34.9486122131, 8251).
airport('JDO', 'Orlando Bezerra de Menezes Airport', 1392, -7.21895980835, -39.2700996399, 5906).
airport('JOI', 'Lauro Carneiro de Loyola Airport', 15, -26.2245006561279, -48.7974014282227, 5381).
airport('VCP', 'Viracopos International Airport', 2170, -23.0074005127, -47.1344985962, 10630).
airport('LDB', 'Governador José Richa Airport', 1867, -23.3335990906, -51.1301002502, 6890).
airport('MGF', 'Regional de Maringá - Sílvio Nane Junior Airport', 1788, -23.4794445038, -52.01222229, 6890).
airport('MCZ', 'Zumbi dos Palmares Airport', 387, -9.51080989837646, -35.7916984558105, 8537).
airport('NVT', 'Ministro Victor Konder International Airport', 18, -26.8799991607666, -48.6514015197754, 5581).
airport('POA', 'Salgado Filho Airport', 11, -29.9944000244141, -51.1713981628418, 7480).
airport('PFB', 'Lauro Kurtz Airport', 2376, -28.2439994812012, -52.3265991210938, 5577).
airport('BPS', 'Porto Seguro Airport', 168, -16.4386005401611, -39.0808982849121, 6562).
airport('VDC', 'Vitória da Conquista Airport', 3002, -14.8627996445, -40.8630981445, 5823).
airport('SDU', 'Santos Dumont Airport', 11, -22.9104995728, -43.1631011963, 4341).
airport('SDU', 'Santos Dumont Airport', 11, -22.9104995728, -43.1631011963, 3841).
airport('RAO', 'Leite Lopes Airport', 1806, -21.1363887786865, -47.776668548584, 6890).
airport('NAT', 'Governador Aluízio Alves International Airport', 272, -5.768056, -35.376111, 9843).
airport('SLZ', 'Marechal Cunha Machado International Airport', 178, -2.58536005020142, -44.2341003417969, 7828).
airport('SLZ', 'Marechal Cunha Machado International Airport', 178, -2.58536005020142, -44.2341003417969, 7328).
airport('CGH', 'Congonhas Airport', 2631, -23.6261100769043, -46.6563873291016, 6365).
airport('CGH', 'Congonhas Airport', 2631, -23.6261100769043, -46.6563873291016, 5865).
airport('SJP', 'Prof. Eribelto Manoel Reino State Airport', 1784, -20.8166007996, -49.40650177, 5381).
airport('THE', 'Senador Petrônio Portela Airport', 219, -5.0599398613, -42.8235015869, 7218).
airport('UDI', 'Ten. Cel. Aviador César Bombonato Airport', 3094, -18.8836116790771, -48.2252769470215, 6398).
airport('UBA', 'Mário de Almeida Franco Airport', 2655, -19.7647228240967, -47.9661102294922, 5771).
airport('VIX', 'Eurico de Aguiar Salles Airport', 11, -20.258056640625, -40.2863883972168, 5741).
airport('ARI', 'Chacalluta Airport', 167, -18.3484992980957, -70.3386993408203, 7119).
airport('CPO', 'Desierto de Atacama Airport', 670, -27.2611999512, -70.7791976929, 7218).
airport('BBA', 'Balmaceda Airport', 1722, -45.9160995483398, -71.6894989013672, 8205).
airport('CJC', 'El Loa Airport', 7543, -22.4981994628906, -68.9036026000977, 9478).
airport('PUQ', 'Pdte. Carlos Ibañez del Campo Airport', 139, -53.0026016235352, -70.8545989990234, 9154).
airport('PUQ', 'Pdte. Carlos Ibañez del Campo Airport', 139, -53.0026016235352, -70.8545989990234, 8654).
airport('PUQ', 'Pdte. Carlos Ibañez del Campo Airport', 139, -53.0026016235352, -70.8545989990234, 8154).
airport('IQQ', 'Diego Aracena Airport', 155, -20.5352001190186, -70.1812973022461, 10991).
airport('ANF', 'Cerro Moreno Airport', 455, -23.4444999694824, -70.4450988769531, 8527).
airport('CCP', 'Carriel Sur Airport', 26, -36.7727012634277, -73.063102722168, 7540).
airport('IPC', 'Mataveri Airport', 227, -27.1648006439, -109.42199707, 10827).
airport('ZOS', 'Cañal Bajo Carlos - Hott Siebert Airport', 187, -40.611198425293, -73.0609970092773, 5578).
airport('LSC', 'La Florida Airport', 481, -29.9162006378, -71.1995010376, 6358).
airport('ZCO', 'Maquehue Airport', 304, -38.7667999267578, -72.6371002197266, 5577).
airport('PMC', 'El Tepual Airport', 294, -41.4388999938965, -73.0940017700195, 8694).
airport('AGT', 'Guarani International Airport', 846, -25.4599990844727, -54.8400001525879, 11154).
airport('CBB', 'Jorge Wilsterman International Airport', 8360, -17.4211006164551, -66.1771011352539, 12460).
airport('CBB', 'Jorge Wilsterman International Airport', 8360, -17.4211006164551, -66.1771011352539, 11960).
airport('PCL', 'Cap FAP David Abenzur Rengifo International Airport', 513, -8.37794017791748, -74.5743026733398, 9186).
airport('TGI', 'Tingo Maria Airport', 2010, -9.13300037384033, -75.9499969482422, 6890).
airport('CIX', 'Capitan FAP Jose A Quinones Gonzales International Airport', 97, -6.78747987747192, -79.8281021118164, 8266).
airport('AYP', 'Coronel FAP Alfredo Mendivil Duarte Airport', 8917, -13.1548004150391, -74.2043991088867, 9186).
airport('ANS', 'Andahuaylas Airport', 11300, -13.7063999176025, -73.3504028320312, 8202).
airport('ATA', 'Comandante FAP German Arias Graziani Airport', 9097, -9.34743976593018, -77.5983963012695, 10007).
airport('JAU', 'Francisco Carle Airport', 11034, -11.7831001282, -75.4733963013, 9220).
airport('JUL', 'Inca Manco Capac International Airport', 12552, -15.4671001434326, -70.158203125, 13779).
airport('CJA', 'Mayor General FAP Armando Revoredo Iglesias Airport', 8781, -7.13918018341064, -78.4894027709961, 8201).
airport('TBP', 'Capitan FAP Pedro Canga Rodriguez Airport', 115, -3.55253005027771, -80.3814010620117, 8202).
airport('HUU', 'Alferez Fap David Figueroa Fernandini Airport', 6070, -9.87880992889404, -76.2048034667969, 8202).
airport('IQT', 'Coronel FAP Francisco Secada Vignetta International Airport', 306, -3.78473997116089, -73.3087997436523, 8202).
airport('AQP', 'Rodríguez Ballón International Airport', 8405, -16.3411006927, -71.5830993652, 9777).
airport('TRU', 'Capitan FAP Carlos Martinez De Pinillos International Airport', 106, -8.08141040802002, -79.1088027954102, 9920).
airport('TPP', 'Cadete FAP Guillermo Del Castillo Paredes Airport', 869, -6.50873994827271, -76.3731994628906, 8530).
airport('TCQ', 'Coronel FAP Carlos Ciriani Santa Rosa International Airport', 1538, -18.0533008575, -70.2758026123, 8202).
airport('PEM', 'Padre Aldamiz International Airport', 659, -12.6135997772, -69.2285995483, 11482).
airport('PIU', 'Capitán FAP Guillermo Concha Iberico International Airport', 120, -5.20574998856, -80.6164016724, 8202).
airport('CUZ', 'Alejandro Velasco Astete International Airport', 10860, -13.5356998444, -71.9387969971, 11146).
airport('DOU', 'Dourados Airport', 1503, -22.2019004822, -54.9266014099, 6374).
airport('YBR', 'Brandon Municipal Airport', 1343, 49.9099998474121, -99.9518966674805, 6500).
airport('YBR', 'Brandon Municipal Airport', 1343, 49.9099998474121, -99.9518966674805, 6000).
airport('YBR', 'Brandon Municipal Airport', 1343, 49.9099998474121, -99.9518966674805, 5500).
airport('YLL', 'Lloydminster Airport', 2193, 53.3092002868652, -110.072998046875, 5577).
airport('YLL', 'Lloydminster Airport', 2193, 53.3092002868652, -110.072998046875, 5077).
airport('YQF', 'Red Deer Regional Airport', 2968, 52.182201385498, -113.893997192383, 5528).
airport('YQF', 'Red Deer Regional Airport', 2968, 52.182201385498, -113.893997192383, 5028).
airport('YQL', 'Lethbridge County Airport', 3048, 49.6302986145, -112.800003052, 6500).
airport('YQL', 'Lethbridge County Airport', 3048, 49.6302986145, -112.800003052, 6000).
airport('YXH', 'Medicine Hat Airport', 2352, 50.0189018249512, -110.721000671387, 5000).
airport('YXH', 'Medicine Hat Airport', 2352, 50.0189018249512, -110.721000671387, 4500).
airport('RNB', 'Ronneby Airport', 191, 56.2667007446289, 15.2650003433228, 7648).
airport('JKG', 'Jönköping Airport', 741, 57.7575988769531, 14.068699836731, 7228).
airport('JKG', 'Jönköping Airport', 741, 57.7575988769531, 14.068699836731, 6728).
airport('MXX', 'Mora Airport', 634, 60.9579010009766, 14.5114002227783, 5951).
airport('KID', 'Kristianstad Airport', 76, 55.9216995239258, 14.0854997634888, 7267).
airport('KLR', 'Kalmar Airport', 17, 56.6855010986328, 16.2875995635986, 6726).
airport('KLR', 'Kalmar Airport', 17, 56.6855010986328, 16.2875995635986, 6226).
airport('HAD', 'Halmstad Airport', 101, 56.6911010742188, 12.8201999664307, 7419).
airport('EVG', 'Sveg Airport', 1178, 62.0477981567383, 14.4229001998901, 5579).
airport('GEV', 'Gällivare Airport', 1027, 67.1324005126953, 20.8145999908447, 5623).
airport('KRF', 'Kramfors Sollefteå Airport', 34, 63.0485992431641, 17.7688999176025, 6565).
airport('LYC', 'Lycksele Airport', 705, 64.5483016967773, 18.7161998748779, 6564).
airport('OER', 'Örnsköldsvik Airport', 354, 63.4082984924316, 18.9899997711182, 6607).
airport('KRN', 'Kiruna Airport', 1508, 67.8219985961914, 20.336799621582, 8209).
airport('UME', 'Umeå Airport', 24, 63.7918014526367, 20.2828006744385, 7551).
airport('VHM', 'Vilhelmina Airport', 1140, 64.5791015625, 16.8335990905762, 4928).
airport('OSD', 'Östersund Airport', 1233, 63.1944007873535, 14.5003004074097, 8202).
airport('OSD', 'Östersund Airport', 1233, 63.1944007873535, 14.5003004074097, 7702).
airport('HFS', 'Hagfors Airport', 474, 60.0200996398926, 13.5789003372192, 4951).
airport('KSD', 'Karlstad Airport', 352, 59.4446983337, 13.3374004364, 8255).
airport('KSD', 'Karlstad Airport', 352, 59.4446983337, 13.3374004364, 7755).
airport('LLA', 'Luleå Airport', 65, 65.5438003540039, 22.1219997406006, 10990).
airport('VBY', 'Visby Airport', 164, 57.6627998352051, 18.3462009429932, 6562).
airport('VBY', 'Visby Airport', 164, 57.6627998352051, 18.3462009429932, 6062).
airport('AGH', 'Ängelholm-Helsingborg Airport', 68, 56.2961006164551, 12.8471002578735, 6552).
airport('AGH', 'Ängelholm-Helsingborg Airport', 68, 56.2961006164551, 12.8471002578735, 6052).
airport('ZAL', 'Pichoy Airport', 59, -39.6500015259, -73.0860977173, 6870).
airport('CDR', 'Chadron Municipal Airport', 3297, 42.837600708, -103.095001221, 6001).
airport('CDR', 'Chadron Municipal Airport', 3297, 42.837600708, -103.095001221, 5501).
airport('KTT', 'Kittila Airport', 644, 67.7009963989258, 24.8467998504639, 8202).
airport('WIN', 'Winton Airport', 638, -22.3635997772217, 143.085998535156, 4600).
airport('WIN', 'Winton Airport', 638, -22.3635997772217, 143.085998535156, 4100).
airport('BJA', 'Soummam Airport', 20, 36.7120018005, 5.06992006302, 7874).
airport('QSF', 'Ain Arnat Airport', 3360, 36.1781005859, 5.32449007034, 9495).
airport('BLJ', 'Batna Airport', 2697, 35.7521018982, 6.3085899353, 9843).
airport('TLM', 'Zenata – Messali El Hadj Airport', 814, 35.0167007446, -1.45000004768, 8530).
airport('BSK', 'Biskra Airport', 289, 34.7933006287, 5.73823022842, 9469).
airport('TOE', 'Tozeur Nefta International Airport', 287, 33.9397010803223, 8.11056041717529, 10581).
airport('DZA', 'Dzaoudzi Pamandzi International Airport', 23, -12.8046998977661, 45.2811012268066, 6330).
airport('ESU', 'Mogador Airport', 384, 31.3974990845, -9.6816701889, 6890).
airport('OZZ', 'Ouarzazate Airport', 3782, 30.9391002655, -6.90943002701, 9842).
airport('AGF', 'Agen-La Garenne Airport', 204, 44.1747016906738, 0.590556025505066, 7103).
airport('PGX', 'Périgueux-Bassillac Airport', 328, 45.1981010437012, 0.815555989742279, 5741).
airport('DCM', 'Castres-Mazamet Airport', 788, 43.5563011169434, 2.2891800403595, 5988).
airport('LPY', 'Le Puy-Loudes Airport', 2731, 45.0806999206543, 3.76289010047913, 4741).
airport('LPY', 'Le Puy-Loudes Airport', 2731, 45.0806999206543, 3.76289010047913, 4241).
airport('AUR', 'Aurillac Airport', 2096, 44.8913993835449, 2.42194008827209, 5577).
airport('LRT', 'Lorient South Brittany (Bretagne Sud) Airport', 160, 47.7606010437012, -3.44000005722046, 7884).
airport('LRT', 'Lorient South Brittany (Bretagne Sud) Airport', 160, 47.7606010437012, -3.44000005722046, 7384).
airport('LAI', 'Lannion-Côte de Granit Airport', 290, 48.7543983459473, -3.47165989875793, 5577).
airport('UIP', 'Quimper-Cornouaille Airport', 297, 47.9749984741211, -4.16778993606567, 7054).
airport('UIP', 'Quimper-Cornouaille Airport', 297, 47.9749984741211, -4.16778993606567, 6554).
airport('CAY', 'Cayenne-Rochambeau Airport', 26, 4.81980991364, -52.3604011536, 10486).
airport('BHJ', 'Bhuj Airport', 268, 23.2877998352, 69.6701965332, 8205).
airport('BHU', 'Bhavnagar Airport', 44, 21.752199173, 72.1852035522, 6300).
airport('HBX', 'Hubli Airport', 2171, 15.361700058, 75.0848999023, 5495).
airport('JGA', 'Jamnagar Airport', 69, 22.4654998779297, 70.0126037597656, 8242).
airport('JGA', 'Jamnagar Airport', 69, 22.4654998779297, 70.0126037597656, 7742).
airport('RAJ', 'Rajkot Airport', 441, 22.3092002869, 70.7795028687, 6040).
airport('GWL', 'Gwalior Airport', 617, 26.2933006286621, 78.2277984619141, 9000).
airport('BFN', 'Bram Fischer International Airport', 4458, -29.0926990509, 26.302400589, 8396).
airport('BFN', 'Bram Fischer International Airport', 4458, -29.0926990509, 26.302400589, 7896).
airport('ELS', 'Ben Schoeman Airport', 435, -33.0355987549, 27.8258991241, 6362).
airport('ELS', 'Ben Schoeman Airport', 435, -33.0355987549, 27.8258991241, 5862).
airport('ELL', 'Ellisras Matimba Airport', 2799, -23.7266998291016, 27.6882991790771, 5902).
airport('GRJ', 'George Airport', 648, -34.0055999756, 22.378900528, 6562).
airport('HDS', 'Hoedspruit Air Force Base Airport', 1743, -24.3686008453, 31.0487003326, 13095).
airport('HDS', 'Hoedspruit Air Force Base Airport', 1743, -24.3686008453, 31.0487003326, 12595).
airport('KIM', 'Kimberley Airport', 3950, -28.8027992249, 24.7651996613, 9843).
airport('KIM', 'Kimberley Airport', 3950, -28.8027992249, 24.7651996613, 9343).
airport('MQP', 'Kruger Mpumalanga International Airport', 2829, -25.3831996918, 31.1056003571, 10171).
airport('HLA', 'Lanseria Airport', 4517, -25.9384994507, 27.9260997772, 10000).
airport('HLA', 'Lanseria Airport', 4517, -25.9384994507, 27.9260997772, 9500).
airport('MGH', 'Margate Airport', 495, -30.8574008942, 30.343000412, 4495).
airport('PLZ', 'Port Elizabeth Airport', 226, -33.9849014282, 25.6173000336, 6496).
airport('PLZ', 'Port Elizabeth Airport', 226, -33.9849014282, 25.6173000336, 5996).
airport('PLZ', 'Port Elizabeth Airport', 226, -33.9849014282, 25.6173000336, 5496).
airport('PBZ', 'Plettenberg Bay Airport', 465, -34.0881601675, 23.3287234306, 4003).
airport('PHW', 'Hendrik Van Eck Airport', 1432, -23.9372005463, 31.1553993225, 4491).
airport('PZB', 'Pietermaritzburg Airport', 2423, -29.6490001678, 30.3987007141, 5043).
airport('PTG', 'Polokwane International Airport', 4076, -23.8453006744, 29.4585990906, 8400).
airport('PTG', 'Polokwane International Airport', 4076, -23.8453006744, 29.4585990906, 7900).
airport('RCB', 'Richards Bay Airport', 109, -28.7409992218, 32.0920982361, 4265).
airport('UTN', 'Pierre Van Ryneveld Airport', 2782, -28.39909935, 21.2602005005, 16076).
airport('UTN', 'Pierre Van Ryneveld Airport', 2782, -28.39909935, 21.2602005005, 15576).
airport('UTT', 'K. D. Matanzima Airport', 2400, -31.5463631849, 28.6733551025, 6562).
airport('UTT', 'K. D. Matanzima Airport', 2400, -31.5463631849, 28.6733551025, 6062).
airport('FRW', 'Francistown Airport', 3283, -21.1595993041992, 27.4745006561279, 7218).
airport('FRW', 'Francistown Airport', 3283, -21.1595993041992, 27.4745006561279, 6718).
airport('BBK', 'Kasane Airport', 3289, -17.8328990936279, 25.1623992919922, 6562).
airport('MUB', 'Maun Airport', 3093, -19.9726009368896, 23.4311008453369, 6562).
airport('GBE', 'Sir Seretse Khama International Airport', 3299, -24.5552005767822, 25.9181995391846, 9843).
airport('MTS', 'Matsapha Airport', 2075, -26.5289993286133, 31.3075008392334, 8530).
airport('LVI', 'Livingstone Airport', 3302, -17.8218002319336, 25.8227005004883, 7520).
airport('LVI', 'Livingstone Airport', 3302, -17.8218002319336, 25.8227005004883, 7020).
airport('NLA', 'Ndola Airport', 4167, -12.9981002807617, 28.6648998260498, 8250).
airport('NLA', 'Ndola Airport', 4167, -12.9981002807617, 28.6648998260498, 7750).
airport('BEW', 'Beira Airport', 33, -19.7964000701904, 34.907600402832, 7874).
airport('BEW', 'Beira Airport', 33, -19.7964000701904, 34.907600402832, 7374).
airport('BEW', 'Beira Airport', 33, -19.7964000701904, 34.907600402832, 6874).
airport('INH', 'Inhambane Airport', 30, -23.8763999938965, 35.4085006713867, 4921).
airport('INH', 'Inhambane Airport', 30, -23.8763999938965, 35.4085006713867, 4421).
airport('MPM', 'Maputo Airport', 145, -25.9207992553711, 32.5726013183594, 12008).
airport('MPM', 'Maputo Airport', 145, -25.9207992553711, 32.5726013183594, 11508).
airport('APL', 'Nampula Airport', 1444, -15.1056003570557, 39.2817993164062, 6562).
airport('APL', 'Nampula Airport', 1444, -15.1056003570557, 39.2817993164062, 6062).
airport('POL', 'Pemba Airport', 331, -12.9917621612549, 40.5240135192871, 5905).
airport('POL', 'Pemba Airport', 331, -12.9917621612549, 40.5240135192871, 5405).
airport('TET', 'Chingozi Airport', 525, -16.1047992706299, 33.6402015686035, 8225).
airport('VNX', 'Vilankulo Airport', 46, -22.0184001922607, 35.3133010864258, 4823).
airport('VNX', 'Vilankulo Airport', 46, -22.0184001922607, 35.3133010864258, 4323).
airport('BUQ', 'Joshua Mqabuko Nkomo International Airport', 4359, -20.0174007415771, 28.6179008483887, 8491).
airport('BUQ', 'Joshua Mqabuko Nkomo International Airport', 4359, -20.0174007415771, 28.6179008483887, 7991).
airport('VFA', 'Victoria Falls International Airport', 3490, -18.0958995819092, 25.8390007019043, 7708).
airport('BLZ', 'Chileka International Airport', 2555, -15.6791000366211, 34.9739990234375, 7628).
airport('BLZ', 'Chileka International Airport', 2555, -15.6791000366211, 34.9739990234375, 7128).
airport('LLW', 'Lilongwe International Airport', 4035, -13.7894001007, 33.78099823, 11614).
airport('MSU', 'Moshoeshoe I International Airport', 5348, -29.4622993469238, 27.5524997711182, 10498).
airport('MSU', 'Moshoeshoe I International Airport', 5348, -29.4622993469238, 27.5524997711182, 9998).
airport('WVB', 'Walvis Bay Airport', 299, -22.9799003601074, 14.645299911499, 7001).
airport('FBM', 'Lubumbashi International Airport', 4295, -11.5913000107, 27.5308990479, 10623).
airport('ZNZ', 'Abeid Amani Karume International Airport', 54, -6.22202014923, 39.224899292, 8077).
airport('GAF', 'Gafsa Ksar International Airport', 1060, 34.4220008850098, 8.82250022888184, 9514).
airport('GAE', 'Gabès Matmata International Airport', 26, 33.8768997192383, 10.1033000946045, 3702).
airport('LGG', 'Liège Airport', 659, 50.6374015808105, 5.4432201385498, 10784).
airport('LGG', 'Liège Airport', 659, 50.6374015808105, 5.4432201385498, 10284).
airport('OST', 'Ostend-Bruges International Airport', 13, 51.1988983154, 2.8622200489, 10499).
airport('OST', 'Ostend-Bruges International Airport', 13, 51.1988983154, 2.8622200489, 9999).
airport('SCN', 'Saarbrücken Airport', 1058, 49.2145996094, 7.10950994492, 6562).
airport('SCN', 'Saarbrücken Airport', 1058, 49.2145996094, 7.10950994492, 6062).
airport('LBC', 'Lübeck Blankensee Airport', 53, 53.8054008484, 10.7192001343, 6896).
airport('ZQW', 'Zweibrücken Airport', 1132, 49.209400177002, 7.40055990219116, 9677).
airport('KSF', 'Kassel-Calden Airport', 909, 51.408332824707, 9.3774995803833, 4921).
airport('KSF', 'Kassel-Calden Airport', 909, 51.408332824707, 9.3774995803833, 4421).
airport('DSA', 'Robin Hood Doncaster Sheffield Airport', 55, 53.4805378105, -1.01065635681, 9491).
airport('MST', 'Maastricht Aachen Airport', 375, 50.9117012024, 5.77014017105, 8202).
airport('GRQ', 'Eelde Airport', 17, 53.1197013855, 6.57944011688, 8202).
airport('GRQ', 'Eelde Airport', 17, 53.1197013855, 6.57944011688, 7702).
airport('TMS', 'São Tomé International Airport', 33, 0.378174990415573, 6.71215009689331, 7283).
airport('SRX', 'Gardabya Airport', 267, 31.0634994507, 16.5949993134, 11807).
airport('SRX', 'Gardabya Airport', 267, 31.0634994507, 16.5949993134, 11307).
airport('TOB', 'Gamal Abdel Nasser Airport', 519, 31.8610000610352, 23.9069995880127, 9895).
airport('TOB', 'Gamal Abdel Nasser Airport', 519, 31.8610000610352, 23.9069995880127, 9395).
airport('TOB', 'Gamal Abdel Nasser Airport', 519, 31.8610000610352, 23.9069995880127, 8895).
airport('BEN', 'Benina International Airport', 433, 32.0968017578, 20.2695007324, 11732).
airport('BEN', 'Benina International Airport', 433, 32.0968017578, 20.2695007324, 11232).
airport('LAQ', 'La Abraq Airport', 2157, 32.7887001037598, 21.9643001556396, 11824).
airport('LAQ', 'La Abraq Airport', 2157, 32.7887001037598, 21.9643001556396, 11324).
airport('ILD', 'Lleida-Alguaire Airport', 1170, 41.728185, 0.535023, 8202).
airport('DLE', 'Dole-Tavaux Airport', 645, 47.0390014648438, 5.42724990844727, 7318).
airport('AXD', 'Dimokritos Airport', 24, 40.855899810791, 25.9563007354736, 8471).
airport('JIK', 'Ikaria Airport', 79, 37.6827011108, 26.3470993042, 4530).
airport('IOA', 'Ioannina Airport', 1558, 39.6963996887207, 20.8225002288818, 7874).
airport('KSO', 'Kastoria National Airport', 2167, 40.4463005066, 21.2821998596, 8852).
airport('KZS', 'Kastelorizo Airport', 489, 36.1417007446, 29.5764007568, 2618).
airport('JKL', 'Kalymnos Airport', 771, 36.9632987976, 26.9405994415, 3330).
airport('KZI', 'Filippos Airport', 2059, 40.2860984802246, 21.840799331665, 5978).
airport('LRS', 'Leros Airport', 39, 37.1848983765, 26.8003005981, 3320).
airport('LXS', 'Limnos Airport', 14, 39.917098999, 25.2362995148, 9895).
airport('MLO', 'Milos Airport', 10, 36.6968994141, 24.4769001007, 2608).
airport('JNX', 'Naxos Airport', 10, 37.0811004639, 25.3680992126, 2953).
airport('PAS', 'Paros Airport', 131, 37.0102996826, 25.1280994415, 2329).
airport('JTY', 'Astypalaia Airport', 165, 36.5798988342, 26.3757991791, 3245).
airport('JSI', 'Skiathos Island National Airport', 54, 39.1771011352539, 23.5037002563477, 5341).
airport('JSY', 'Syros Airport', 236, 37.4227981567, 24.9508991241, 3542).
airport('JSH', 'Sitia Airport', 376, 35.2160987854004, 26.1012992858887, 6804).
airport('SKU', 'Skiros Airport', 44, 38.9676017761, 24.4871997833, 9849).
airport('SMA', 'Santa Maria Airport', 308, 36.9714012145996, -25.1706008911133, 10000).
airport('SMA', 'Santa Maria Airport', 308, 36.9714012145996, -25.1706008911133, 9500).
airport('SMA', 'Santa Maria Airport', 308, 36.9714012145996, -25.1706008911133, 9000).
airport('HOR', 'Horta Airport', 118, 38.5199012756348, -28.7159004211426, 5233).
airport('TER', 'Lajes Field', 180, 38.7617988586, -27.0907993317, 10870).
airport('PIX', 'Pico Airport', 109, 38.5542984008789, -28.4412994384766, 5725).
airport('PXO', 'Porto Santo Airport', 341, 33.0733985901, -16.3500003815, 9861).
airport('PXO', 'Porto Santo Airport', 341, 33.0733985901, -16.3500003815, 9361).
airport('MRA', 'Misratah Airport', 60, 32.3250007629395, 15.0609998703003, 11154).
airport('ATT', 'Atmautluak Airport', 17, 60.8666992188, -162.272994995, 3000).
airport('KOZ', 'Ouzinkie Airport', 55, 57.9229011536, -152.50100708, 3300).
airport('CHU', 'Chuathbaluk Airport', 244, 61.57910156, -159.2160034, 3401).
airport('KLL', 'Levelock Airport', 39, 59.1281013489, -156.85899353, 3284).
airport('WTL', 'Tuntutuliak Airport', 16, 60.3353004456, -162.667007446, 3025).
airport('RNA', 'Ulawa Airport', 40, -9.86054358262, 161.979546547, 2822).
airport('ATD', 'Uru Harbour Airport', 17, -8.87333011627197, 161.011001586914, 2769).
airport('BNY', 'Bellona/Anua Airport', 60, -11.3022222222, 159.798333333, 2187).
airport('CHY', 'Choiseul Bay/Taro Island Airport', 5, -6.711944, 156.396111, 2164).
airport('FRE', 'Fera/Maringe Airport', 9, -8.10750007629395, 159.576995849609, 1854).
airport('IRA', 'Ngorangora Airport', 54, -10.4497003555, 161.897994995, 4377).
airport('SCZ', 'Santa Cruz/Graciosa Bay/Luova Airport', 18, -10.7202997207642, 165.794998168945, 2999).
airport('MUA', 'Munda Airport', 10, -8.32796955108643, 157.263000488281, 4593).
airport('GZO', 'Nusatupe Airport', 13, -8.09778022766, 156.863998413, 3609).
airport('RNL', 'Rennell/Tingoa Airport', 82, -11.5339002609253, 160.063003540039, 2206).
airport('EGM', 'Sege Airport', 11, -8.57888984680176, 157.876007080078, 3002).
airport('NNB', 'Santa Ana Airport', 3, -10.847994, 162.454108, 2655).
airport('RUS', 'Marau Airport', 3, -9.86166954041, 160.824996948, 2001).
airport('VAO', 'Suavanao Airport', 20, -7.5855598449707, 158.731002807617, 2789).
airport('KGE', 'Kaghau Airport', 30, -7.3305, 157.585, 2428).
airport('RBV', 'Ramata Airport', 46, -8.16806030273438, 157.643005371094, 3950).
airport('BUA', 'Buka Airport', 11, -5.4223198890686, 154.673004150391, 5125).
airport('CMU', 'Chimbu Airport', 4974, -6.02429008483887, 144.970993041992, 3330).
airport('DAU', 'Daru Airport', 20, -9.08675956726, 143.207992554, 4593).
airport('GKA', 'Goroka Airport', 5282, -6.08168983459, 145.391998291, 5400).
airport('GKA', 'Goroka Airport', 5282, -6.08168983459, 145.391998291, 4900).
airport('GUR', 'Gurney Airport', 88, -10.3114995956, 150.333999634, 5546).
airport('PNP', 'Girua Airport', 311, -8.80453968048, 148.309005737, 5485).
airport('HKN', 'Kimbe Airport', 66, -5.46217012405396, 150.404998779297, 5212).
airport('UNG', 'Kiunga Airport', 88, -6.12571001052856, 141.281997680664, 3691).
airport('KVG', 'Kavieng Airport', 7, -2.57940006256, 150.807998657, 5592).
airport('LNV', 'Londolovit Airport', 167, -3.04361009598, 152.628997803, 3937).
airport('MAG', 'Madang Airport', 20, -5.20707988739, 145.789001465, 5174).
airport('HGU', 'Mount Hagen Kagamuga Airport', 5388, -5.82678985595703, 144.296005249023, 7185).
airport('HGU', 'Mount Hagen Kagamuga Airport', 5388, -5.82678985595703, 144.296005249023, 6685).
airport('MDU', 'Mendi Airport', 5680, -6.14773988723755, 143.656997680664, 4411).
airport('MAS', 'Momote Airport', 12, -2.06188988685608, 147.42399597168, 6136).
airport('MXH', 'Moro Airport', 2740, -6.36332988739, 143.238006592, 5774).
airport('LAE', 'Lae Nadzab Airport', 239, -6.5698299408, 146.725997925, 8004).
airport('TIZ', 'Tari Airport', 5500, -5.84499979019, 142.947998047, 5197).
airport('TBG', 'Tabubil Airport', 1570, -5.27861022949219, 141.225997924805, 4232).
airport('RAB', 'Tokua Airport', 32, -4.34045982361, 152.380004883, 5643).
airport('VAI', 'Vanimo Airport', 10, -2.69717001914978, 141.302001953125, 5775).
airport('WBM', 'Wapenamanda Airport', 5889, -5.64330005645752, 143.895004272461, 5052).
airport('WWK', 'Wewak International Airport', 19, -3.58383011818, 143.669006348, 5234).
airport('GOH', 'Godthaab / Nuuk Airport', 283, 64.19090271, -51.6781005859, 3117).
airport('SFJ', 'Kangerlussuaq Airport', 165, 67.0122218992, -50.7116031647, 9219).
airport('RBQ', 'Rurenabaque Airport', 899, -14.4279003143, -67.4968032837, 6141).
airport('BUL', 'Bulolo Airport', 2240, -7.21628667141, 146.649541855, 4373).
airport('BCV', 'Belmopan Airport', 200, 17.2695999145508, -88.776496887207, 3609).
airport('CUK', 'Caye Caulker Airport', 1, 17.7346992492676, -88.0325012207031, 2610).
airport('DGA', 'Dangriga Airport', 508, 16.9825096130371, -88.2309875488281, 2090).
airport('PLJ', 'Placencia Airport', 42, 16.5369567871094, -88.3615112304688, 2135).
airport('SPR', 'San Pedro Airport', 3, 17.9139003753662, -87.9710998535156, 3501).
airport('SQS', 'Matthew Spain Airport', 416, 17.1859, -89.0098, 2231).
airport('TZA', 'Belize City Municipal Airport', 16, 17.5163898468018, -88.1944427490234, 1825).
airport('YAA', 'Anahim Lake Airport', 3635, 52.4524993896484, -125.303001403809, 3930).
airport('YAA', 'Anahim Lake Airport', 3635, 52.4524993896484, -125.303001403809, 3430).
airport('YLE', 'Whatì Airport', 882, 63.1316986083984, -117.246002197266, 2991).
airport('TVS', 'Tangshan Sannühe Airport', 50, 39.7178001404, 118.002624512, 8858).
airport('OHE', 'Gu-Lian Airport', 1836, 52.9127777778, 122.43, 7218).
airport('BSD', 'Baoshan Yunduan Airport', 5453, 25.0533008575, 99.168296814, 7874).
airport('LNJ', 'Lintsang Airfield', 6230, 23.7381000519, 100.025001526, 7874).
airport('PZI', "Bao'anying Airport", 6483, 26.54, 101.79852, 9186).
airport('FUO', 'Foshan Shadi Airport', 6, 23.0832996368, 113.069999695, 9186).
airport('AEB', 'Baise Youjiang Airport', 148, 23.7206001282, 106.959999084, 8202).
airport('YZY', 'Zhangye Southeast Air Base', 2264, 38.8018989563, 100.675003052, 9843).
airport('YZY', 'Zhangye Southeast Air Base', 2264, 38.8018989563, 100.675003052, 9343).
airport('LDS', 'Lindu Airport', 791, 47.7520555556, 129.019125, 7546).
airport('YKU', 'Chisasibi Airport', 43, 53.8055992126465, -78.9169006347656, 3792).
airport('YAG', 'Fort Frances Municipal Airport', 1125, 48.6542015075684, -93.439697265625, 4500).
airport('YAG', 'Fort Frances Municipal Airport', 1125, 48.6542015075684, -93.439697265625, 4000).
airport('YKG', 'Kangirsuk Airport', 403, 60.0271987915039, -69.9991989135742, 3521).
airport('YAY', 'St. Anthony Airport', 108, 51.3918991089, -56.0830993652, 4000).
airport('YCB', 'Cambridge Bay Airport', 90, 69.1081008911, -105.138000488, 5000).
airport('YCL', 'Charlo Airport', 132, 47.9907989501953, -66.3302993774414, 6000).
airport('YCO', 'Kugluktuk Airport', 74, 67.8167037964, -115.143997192, 5500).
airport('YCY', 'Clyde River Airport', 87, 70.4860992432, -68.5167007446, 3500).
airport('YFH', 'Fort Hope Airport', 899, 51.5619010925293, -87.9077987670898, 3500).
airport('YFO', 'Flin Flon Airport', 997, 54.6781005859375, -101.681999206543, 5000).
airport('YFS', 'Fort Simpson Airport', 555, 61.7602005004883, -121.236999511719, 6000).
airport('YGP', 'Gaspé (Michel-Pouliot) Airport', 112, 48.7752990723, -64.4785995483, 4500).
airport('YGR', 'Îles-de-la-Madeleine Airport', 35, 47.4247016906738, -61.7780990600586, 4500).
airport('YGR', 'Îles-de-la-Madeleine Airport', 35, 47.4247016906738, -61.7780990600586, 4000).
airport('YGT', 'Igloolik Airport', 174, 69.3647003174, -81.8161010742, 3800).
airport('YGV', 'Havre St Pierre Airport', 124, 50.2818984985352, -63.611400604248, 4500).
airport('YGX', 'Gillam Airport', 476, 56.3574981689453, -94.7106018066406, 5000).
airport('YNS', 'Nemiscau Airport', 802, 51.6911010742188, -76.1355972290039, 5000).
airport('YHK', 'Gjoa Haven Airport', 152, 68.635597229, -95.8497009277, 4400).
airport('YHU', 'Montréal / Saint-Hubert Airport', 90, 45.5175018311, -73.4169006348, 7840).
airport('YHU', 'Montréal / Saint-Hubert Airport', 90, 45.5175018311, -73.4169006348, 7340).
airport('YHU', 'Montréal / Saint-Hubert Airport', 90, 45.5175018311, -73.4169006348, 6840).
airport('ZEL', 'Denny Island Airport', 162, 52.1397018433, -128.063995361, 2954).
airport('YJT', 'Stephenville Airport', 84, 48.5442008972168, -58.5499992370605, 10000).
airport('YJT', 'Stephenville Airport', 84, 48.5442008972168, -58.5499992370605, 9500).
airport('YKL', 'Schefferville Airport', 1709, 54.8053016662598, -66.8052978515625, 5000).
airport('YKQ', 'Waskaganish Airport', 80, 51.4733009338379, -78.75830078125, 3500).
airport('YPJ', 'Aupaluk Airport', 119, 59.2966995239258, -69.5997009277344, 3521).
airport('YPJ', 'Aupaluk Airport', 119, 59.2966995239258, -69.5997009277344, 3021).
airport('YLC', 'Kimmirut Airport', 175, 62.8499984741, -69.8833007812, 1900).
airport('YSG', "Lutselk'e Airport", 596, 62.4183006286621, -110.681999206543, 2996).
airport('XGR', 'Kangiqsualujjuaq (Georges River) Airport', 215, 58.7113990783691, -65.9927978515625, 3521).
airport('YMO', 'Moosonee Airport', 30, 51.2910995483398, -80.6078033447266, 4000).
airport('YMO', 'Moosonee Airport', 30, 51.2910995483398, -80.6078033447266, 3500).
airport('YUD', 'Umiujaq Airport', 250, 56.5360984802246, -76.5183029174805, 3500).
airport('YNA', 'Natashquan Airport', 39, 50.189998626709, -61.7891998291016, 4494).
airport('YPH', 'Inukjuak Airport', 83, 58.4719009399414, -78.0768966674805, 3500).
airport('YPN', 'Port Menier Airport', 167, 49.8363990783691, -64.2885971069336, 4886).
airport('YPX', 'Puvirnituq Airport', 74, 60.0505981445312, -77.2869033813477, 5013).
airport('YPY', 'Fort Chipewyan Airport', 761, 58.7672004699707, -111.116996765137, 5000).
airport('YQD', 'The Pas Airport', 887, 53.9714012145996, -101.091003417969, 5901).
airport('YQK', 'Kenora Airport', 1332, 49.7882995605469, -94.3630981445312, 5800).
airport('YQX', 'Gander International Airport', 496, 48.9369010925293, -54.5680999755859, 10200).
airport('YQX', 'Gander International Airport', 496, 48.9369010925293, -54.5680999755859, 9700).
airport('YQX', 'Gander International Airport', 496, 48.9369010925293, -54.5680999755859, 9200).
airport('YRA', 'Rae Lakes Airport', 723, 64.116096496582, -117.309997558594, 3000).
airport('YRL', 'Red Lake Airport', 1265, 51.0668983459473, -93.793098449707, 5000).
airport('YRT', 'Rankin Inlet Airport', 94, 62.8114013672, -92.1157989502, 6000).
airport('YSK', 'Sanikiluaq Airport', 104, 56.5377998352, -79.2466964722, 3800).
airport('YTE', 'Cape Dorset Airport', 164, 64.2300033569, -76.5267028809, 4000).
airport('YTH', 'Thompson Airport', 729, 55.8011016845703, -97.8641967773438, 5800).
airport('YTH', 'Thompson Airport', 729, 55.8011016845703, -97.8641967773438, 5300).
airport('YTQ', 'Tasiujaq Airport', 122, 58.6678009033203, -69.9558029174805, 3519).
airport('YUX', 'Hall Beach Airport', 30, 68.7761001587, -81.2425, 5410).
airport('YVB', 'Bonaventure Airport', 123, 48.0710983276367, -65.4602966308594, 5985).
airport('YVQ', 'Norman Wells Airport', 238, 65.2816009521484, -126.797996520996, 5997).
airport('YWJ', 'Déline Airport', 703, 65.2110977172852, -123.435997009277, 3933).
airport('YWP', 'Webequie Airport', 685, 52.9593933975, -87.3748683929, 3500).
airport('YXL', 'Sioux Lookout Airport', 1258, 50.113899230957, -91.9052963256836, 5300).
airport('YXL', 'Sioux Lookout Airport', 1258, 50.113899230957, -91.9052963256836, 4800).
airport('YXP', 'Pangnirtung Airport', 75, 66.1449966431, -65.7136001587, 2920).
airport('YYH', 'Taloyoak Airport', 92, 69.5466995239, -93.5766983032, 4020).
airport('YYQ', 'Churchill Airport', 94, 58.739200592041, -94.0650024414062, 9200).
airport('YYQ', 'Churchill Airport', 94, 58.739200592041, -94.0650024414062, 8700).
airport('YYR', 'Goose Bay Airport', 160, 53.3191986084, -60.4258003235, 11046).
airport('YYR', 'Goose Bay Airport', 160, 53.3191986084, -60.4258003235, 10546).
airport('YYU', 'Kapuskasing Airport', 743, 49.4138984680176, -82.4674987792969, 5500).
airport('YYU', 'Kapuskasing Airport', 743, 49.4138984680176, -82.4674987792969, 5000).
airport('ZUM', 'Churchill Falls Airport', 1442, 53.5619010925293, -64.1063995361328, 5500).
airport('DJG', 'Djanet Inedbirene Airport', 3176, 24.2928009033, 9.45244026184, 9843).
airport('DJG', 'Djanet Inedbirene Airport', 3176, 24.2928009033, 9.45244026184, 9343).
airport('MZW', 'Mecheria Airport', 3855, 33.535900116, -0.242353007197, 11780).
airport('MZW', 'Mecheria Airport', 3855, 33.535900116, -0.242353007197, 11280).
airport('TEE', 'Cheikh Larbi Tébessi Airport', 2661, 35.4315986633, 8.12071990967, 9843).
airport('TEE', 'Cheikh Larbi Tébessi Airport', 2661, 35.4315986633, 8.12071990967, 9343).
airport('HRM', "Hassi R'Mel Airport", 2540, 32.9304008483887, 3.31153988838196, 9835).
airport('HRM', "Hassi R'Mel Airport", 2540, 32.9304008483887, 3.31153988838196, 9335).
airport('TID', 'Bou Chekif Airport', 3245, 35.3410987854, 1.46315002441, 9843).
airport('CFK', 'Ech Cheliff Airport', 463, 36.2126998901, 1.33176994324, 5413).
airport('CBH', 'Béchar Boudghene Ben Ali Lotfi Airport', 2661, 31.6457004547119, -2.26986002922058, 12245).
airport('CBH', 'Béchar Boudghene Ben Ali Lotfi Airport', 2661, 31.6457004547119, -2.26986002922058, 11745).
airport('MUW', 'Ghriss/Mascara Airport', 1686, 35.2076988220215, 0.147141993045807, 5577).
airport('EBH', 'El Bayadh Airport', 4482, 33.7216666667, 1.0925, 9843).
airport('AZR', 'Touat Cheikh Sidi Mohamed Belkebir Airport', 919, 27.8376007080078, -0.186414003372192, 9843).
airport('GHA', 'Noumérat - Moufdi Zakaria Airport', 1512, 32.3841018676758, 3.79411005973816, 10171).
airport('GHA', 'Noumérat - Moufdi Zakaria Airport', 1512, 32.3841018676758, 3.79411005973816, 9671).
airport('INZ', 'In Salah Airport', 896, 27.2509994507, 2.51202011108, 9843).
airport('TGR', 'Touggourt Sidi Madhi Airport', 279, 33.067798614502, 6.0886697769165, 9843).
airport('ELU', 'Guemar Airport', 203, 33.5113983154, 6.77679014206, 9843).
airport('ELU', 'Guemar Airport', 203, 33.5113983154, 6.77679014206, 9343).
airport('OGX', 'Ain el Beida Airport', 492, 31.917200088501, 5.41277980804443, 10171).
airport('OGX', 'Ain el Beida Airport', 492, 31.917200088501, 5.41277980804443, 9671).
airport('IAM', 'In Aménas Airport', 1847, 28.0515003204, 9.64291000366, 9843).
airport('IAM', 'In Aménas Airport', 1847, 28.0515003204, 9.64291000366, 9343).
airport('BOY', 'Bobo Dioulasso Airport', 1511, 11.1600999832153, -4.33096981048584, 10826).
airport('TML', 'Tamale Airport', 553, 9.55718994140625, -0.863214015960693, 7999).
airport('KMS', 'Kumasi Airport', 942, 6.71456003189087, -1.59081995487213, 6502).
airport('NYI', 'Sunyani Airport', 1014, 7.36183023452759, -2.32875990867615, 4227).
airport('TKD', 'Takoradi Airport', 21, 4.8960599899292, -1.77476000785828, 5745).
airport('QUO', 'Akwa Ibom International Airport', 170, 4.8725, 8.093, 11811).
airport('ABB', 'Asaba International Airport', 20, 6.20333333333, 6.65888888889, 11155).
airport('BNI', 'Benin Airport', 258, 6.31697988510132, 5.59950017929077, 7870).
airport('CBQ', 'Margaret Ekpo International Airport', 210, 4.97601985931396, 8.34720039367676, 8040).
airport('ENU', 'Akanu Ibiam International Airport', 466, 6.47426986694336, 7.56196022033691, 7879).
airport('IBA', 'Ibadan Airport', 725, 7.36246013641357, 3.97832989692688, 7875).
airport('ILR', 'Ilorin International Airport', 1126, 8.44021034240723, 4.49391984939575, 10169).
airport('QOW', 'Sam Mbakwe International Airport', 373, 5.4270601272583, 7.20602989196777, 8858).
airport('JOS', 'Yakubu Gowon Airport', 4232, 9.63982963562012, 8.86905002593994, 9845).
airport('KAD', 'Kaduna Airport', 2073, 10.6960000991821, 7.32010984420776, 9843).
airport('KAN', 'Mallam Aminu International Airport', 1562, 12.0475997924805, 8.52462005615234, 10831).
airport('KAN', 'Mallam Aminu International Airport', 1562, 12.0475997924805, 8.52462005615234, 10331).
airport('PHC', 'Port Harcourt International Airport', 87, 5.01549005508423, 6.94959020614624, 9846).
airport('SKO', 'Sadiq Abubakar III International Airport', 1010, 12.9162998199463, 5.20719003677368, 9844).
airport('YOL', 'Yola Airport', 599, 9.25755023956299, 12.4303998947144, 9840).
airport('YOL', 'Yola Airport', 599, 9.25755023956299, 12.4303998947144, 9340).
airport('MHG', 'Mannheim-City Airport', 308, 49.4730567932129, 8.51416683197021, 3497).
airport('MHG', 'Mannheim-City Airport', 308, 49.4730567932129, 8.51416683197021, 2997).
airport('XFW', 'Hamburg-Finkenwerder Airport', 23, 53.5352783203125, 9.83555603027344, 8629).
airport('AGB', 'Augsburg Airport', 1516, 48.4252777099609, 10.9316673278809, 4199).
airport('AGB', 'Augsburg Airport', 1516, 48.4252777099609, 10.9316673278809, 3699).
airport('URE', 'Kuressaare Airport', 14, 58.2299003601074, 22.50950050354, 4980).
airport('URE', 'Kuressaare Airport', 14, 58.2299003601074, 22.50950050354, 4480).
airport('LPP', 'Lappeenranta Airport', 349, 61.0446014404297, 28.1443996429443, 8202).
airport('GLO', 'Gloucestershire Airport', 101, 51.8941993713379, -2.16722011566162, 4656).
airport('GLO', 'Gloucestershire Airport', 101, 51.8941993713379, -2.16722011566162, 4156).
airport('GLO', 'Gloucestershire Airport', 101, 51.8941993713379, -2.16722011566162, 3656).
airport('EOI', 'Eday Airport', 10, 59.190601348877, -2.77221989631653, 1896).
airport('EOI', 'Eday Airport', 10, 59.190601348877, -2.77221989631653, 1396).
airport('NRL', 'North Ronaldsay Airport', 40, 59.3675003052, -2.43443989754, 1729).
airport('NRL', 'North Ronaldsay Airport', 40, 59.3675003052, -2.43443989754, 1229).
airport('NRL', 'North Ronaldsay Airport', 40, 59.3675003052, -2.43443989754, 729).
airport('PPW', 'Papa Westray Airport', 91, 59.3516998291, -2.90027999878, 1729).
airport('PPW', 'Papa Westray Airport', 91, 59.3516998291, -2.90027999878, 1229).
airport('PPW', 'Papa Westray Airport', 91, 59.3516998291, -2.90027999878, 729).
airport('SOY', 'Stronsay Airport', 39, 59.1553001404, -2.64139008522, 1689).
airport('SOY', 'Stronsay Airport', 39, 59.1553001404, -2.64139008522, 1189).
airport('SOY', 'Stronsay Airport', 39, 59.1553001404, -2.64139008522, 689).
airport('NDY', 'Sanday Airport', 68, 59.250301361084, -2.57666993141174, 1532).
airport('NDY', 'Sanday Airport', 68, 59.250301361084, -2.57666993141174, 1032).
airport('NDY', 'Sanday Airport', 68, 59.250301361084, -2.57666993141174, 532).
airport('WRY', 'Westray Airport', 29, 59.3502998352, -2.95000004768, 1729).
airport('WRY', 'Westray Airport', 29, 59.3502998352, -2.95000004768, 1229).
airport('WRY', 'Westray Airport', 29, 59.3502998352, -2.95000004768, 729).
airport('ISC', "St. Mary's Airport", 116, 49.9132995605469, -6.29166984558105, 1968).
airport('ISC', "St. Mary's Airport", 116, 49.9132995605469, -6.29166984558105, 1468).
airport('ISC', "St. Mary's Airport", 116, 49.9132995605469, -6.29166984558105, 968).
airport('ACI', 'Alderney Airport', 290, 49.7061004638672, -2.21472001075745, 2887).
airport('ACI', 'Alderney Airport', 290, 49.7061004638672, -2.21472001075745, 2387).
airport('ACI', 'Alderney Airport', 290, 49.7061004638672, -2.21472001075745, 1887).
airport('CEG', 'Hawarden Airport', 45, 53.1781005859375, -2.97778010368347, 6702).
airport('VLY', 'Anglesey Airport', 37, 53.2481002808, -4.53533983231, 7513).
airport('VLY', 'Anglesey Airport', 37, 53.2481002808, -4.53533983231, 7013).
airport('VLY', 'Anglesey Airport', 37, 53.2481002808, -4.53533983231, 6513).
airport('EBJ', 'Esbjerg Airport', 97, 55.5259017944336, 8.55340003967285, 8527).
airport('KRP', 'Karup Airport', 170, 56.2975006103516, 9.12462997436523, 9816).
airport('KRP', 'Karup Airport', 170, 56.2975006103516, 9.12462997436523, 9316).
airport('KRP', 'Karup Airport', 170, 56.2975006103516, 9.12462997436523, 8816).
airport('KRP', 'Karup Airport', 170, 56.2975006103516, 9.12462997436523, 8316).
airport('KRP', 'Karup Airport', 170, 56.2975006103516, 9.12462997436523, 7816).
airport('RNN', 'Bornholm Airport', 52, 55.0633010864258, 14.7595996856689, 6568).
airport('SGD', 'Sønderborg Airport', 24, 54.9644012451172, 9.79172992706299, 5895).
airport('FAE', 'Vagar Airport', 280, 62.0635986328125, -7.27721977233887, 5902).
airport('ANX', 'Andøya Airport', 43, 69.2925033569336, 16.1441993713379, 8097).
airport('ANX', 'Andøya Airport', 43, 69.2925033569336, 16.1441993713379, 7597).
airport('HFT', 'Hammerfest Airport', 266, 70.6797027587891, 23.6686000823975, 2894).
airport('HAA', 'Hasvik Airport', 21, 70.486701965332, 22.1396999359131, 3179).
airport('LKN', 'Leknes Airport', 78, 68.1524963378906, 13.6093997955322, 2881).
airport('MJF', 'Mosjøen Airport, Kjærstad', 237, 65.7839965820312, 13.2149000167847, 3015).
airport('LKL', 'Banak Airport', 25, 70.0688018798828, 24.9734992980957, 9147).
airport('NVK', 'Narvik Framnes Airport', 95, 68.436897277832, 17.3866996765137, 2982).
airport('OSY', 'Namsos Høknesøra Airport', 7, 64.4721984863281, 11.5785999298096, 2749).
airport('MQN', 'Mo i Rana Airport, Røssvoll', 229, 66.363899230957, 14.3014001846313, 2759).
airport('RVK', 'Rørvik Airport, Ryum', 14, 64.8383026123047, 11.1461000442505, 2887).
airport('RET', 'Røst Airport', 7, 67.5278015136719, 12.1033000946045, 2887).
airport('SVJ', 'Svolvær Helle Airport', 27, 68.2433013916016, 14.6691999435425, 2812).
airport('SKN', 'Stokmarknes Skagen Airport', 11, 68.5788269042969, 15.0334167480469, 2848).
airport('SKE', 'Skien Airport', 463, 59.185001373291, 9.56694030761719, 4596).
airport('SOJ', 'Sørkjosen Airport', 16, 69.7867965698242, 20.959400177002, 3015).
airport('VAW', 'Vardø Airport, Svartnes', 42, 70.3554000854492, 31.044900894165, 3707).
airport('VDS', 'Vadsø Airport', 127, 70.065299987793, 29.8446998596191, 3271).
airport('THN', 'Trollhättan-Vänersborg Airport', 137, 58.3180999755859, 12.3450002670288, 5610).
airport('AJR', 'Arvidsjaur Airport', 1245, 65.5903015136719, 19.2819004058838, 8201).
airport('ORB', 'Örebro Airport', 188, 59.2237014770508, 15.0380001068115, 8535).
airport('TYF', 'Torsby Airport', 393, 60.1576004028, 12.9912996292, 5219).
airport('PJA', 'Pajala Airport', 542, 67.2455978393555, 23.0688991546631, 4659).
airport('HMV', 'Hemavan Airport', 1503, 65.8060989379883, 15.082799911499, 5254).
airport('BSG', 'Bata Airport', 13, 1.90547001361847, 9.80568027496338, 7001).
airport('BSG', 'Bata Airport', 13, 1.90547001361847, 9.80568027496338, 6501).
airport('RRG', 'Sir Charles Gaetan Duval Airport', 95, -19.7576999664307, 63.3610000610352, 4223).
airport('MVR', 'Salak Airport', 1390, 10.4513998031616, 14.257399559021, 6890).
airport('NGE', "N'Gaoundéré Airport", 3655, 7.35700988769531, 13.5592002868652, 8858).
airport('GOU', 'Garoua International Airport', 794, 9.33588981628418, 13.3701000213623, 11032).
airport('CIP', 'Chipata Airport', 3360, -13.5583000183105, 32.5872001647949, 4823).
airport('KAA', 'Kasama Airport', 4541, -10.2166996002197, 31.13330078125, 6148).
airport('MNS', 'Mansa Airport', 4100, -11.1370000839233, 28.8726005554199, 5610).
airport('MFU', 'Mfuwe Airport', 1853, -13.2588996887207, 31.9365997314453, 7218).
airport('SLI', 'Solwesi Airport', 4547, -12.1737003326416, 26.3651008605957, 4400).
airport('HAH', 'Prince Said Ibrahim International Airport', 93, -11.5336999893188, 43.271900177002, 9514).
airport('ZSE', 'Pierrefonds Airport', 59, -21.3208999633789, 55.4249992370605, 4965).
airport('SMS', 'Sainte Marie Airport', 7, -17.093900680542, 49.8157997131348, 3451).
airport('TMM', 'Toamasina Airport', 22, -18.1095008850098, 49.3925018310547, 7218).
airport('MOQ', 'Morondava Airport', 30, -20.2847003936768, 44.3176002502441, 4921).
airport('MOQ', 'Morondava Airport', 30, -20.2847003936768, 44.3176002502441, 4421).
airport('DIE', 'Arrachart Airport', 374, -12.3493995666504, 49.2916984558105, 4921).
airport('ANM', 'Antsirabato Airport', 20, -14.999400138855, 50.3202018737793, 3914).
airport('MJN', 'Philibert Tsiranana (Amborovy) Airport', 87, -15.6668417421, 46.3512325287, 7218).
airport('NOS', 'Fascene Airport', 36, -13.3121004105, 48.3148002625, 7185).
airport('WMN', 'Maroantsetra Airport', 13, -15.4366998672485, 49.6883010864258, 4265).
airport('SVB', 'Sambava Airport', 20, -14.2785997390747, 50.1747016906738, 4577).
airport('FTU', 'Tôlanaro Airport', 29, -25.0380992889404, 46.9561004638672, 4916).
airport('TLE', 'Toliara Airport', 29, -23.3833999633789, 43.7285003662109, 6562).
airport('TLE', 'Toliara Airport', 29, -23.3833999633789, 43.7285003662109, 6062).
airport('SSY', 'Mbanza Congo Airport', 1860, -6.26989984512329, 14.2469997406006, 5905).
airport('CAB', 'Cabinda Airport', 66, -5.59699010848999, 12.1884002685547, 8202).
airport('CBT', 'Catumbela Airport', 124, -12.4792003631592, 13.4869003295898, 12139).
airport('VPE', 'Ngjiva Pereira Airport', 3566, -17.0435009003, 15.6837997437, 10640).
airport('NOV', 'Nova Lisboa Airport', 5587, -12.8088998794556, 15.7604999542236, 8727).
airport('NOV', 'Nova Lisboa Airport', 5587, -12.8088998794556, 15.7604999542236, 8227).
airport('SVP', 'Kuito Airport', 5618, -12.4046001434326, 16.9473991394043, 8202).
airport('MEG', 'Malanje Airport', 3868, -9.52509021759033, 16.3124008178711, 7283).
airport('SPP', 'Menongue Airport', 4469, -14.657600402832, 17.7198009490967, 11483).
airport('MSZ', 'Namibe Airport', 210, -15.2611999511719, 12.1468000411987, 8202).
airport('VHC', 'Saurimo Airport', 3584, -9.6890697479248, 20.4319000244141, 11155).
airport('SZA', 'Soyo Airport', 15, -6.14108991622925, 12.3718004226685, 6857).
airport('SDD', 'Lubango Airport', 5778, -14.9246997833252, 13.5749998092651, 9570).
airport('LUO', 'Luena Airport', 4360, -11.7680997848511, 19.8976993560791, 7875).
airport('POG', 'Port Gentil Airport', 13, -0.711739003658295, 8.75438022613525, 6234).
airport('VPY', 'Chimoio Airport', 2287, -19.1513004302979, 33.4290008544922, 7874).
airport('VXC', 'Lichinga Airport', 4505, -13.2740001678467, 35.266300201416, 8300).
airport('UEL', 'Quelimane Airport', 36, -17.8554992675781, 36.8690986633301, 5905).
airport('UEL', 'Quelimane Airport', 36, -17.8554992675781, 36.8690986633301, 5405).
airport('PRI', 'Praslin Airport', 10, -4.31929016113281, 55.6913986206055, 4318).
airport('LUD', 'Luderitz Airport', 457, -26.6874008178711, 15.2428998947144, 6004).
airport('LUD', 'Luderitz Airport', 457, -26.6874008178711, 15.2428998947144, 5504).
airport('MDK', 'Mbandaka Airport', 1040, 0.0226000007242, 18.2887001038, 7223).
airport('BNB', 'Boende Airport', 1168, -0.216999992728233, 20.8500003814697, 4593).
airport('FKI', 'Bangoka International Airport', 1417, 0.481638997793, 25.3379993439, 11483).
airport('KND', 'Kindu Airport', 1630, -2.91917991638, 25.9153995514, 7218).
airport('KGA', 'Kananga Airport', 2139, -5.90005016327, 22.4692001343, 7218).
airport('TSH', 'Tshikapa Airport', 1595, -6.43833017349243, 20.7947006225586, 5249).
airport('MJM', 'Mbuji Mayi Airport', 2221, -6.12124013901, 23.5690002441, 6558).
airport('GMZ', 'La Gomera Airport', 716, 28.0296001434326, -17.214599609375, 4921).
airport('VDE', 'Hierro Airport', 103, 27.8148002624512, -17.8871002197266, 4101).
airport('OXB', 'Osvaldo Vieira International Airport', 129, 11.8948001861572, -15.6536998748779, 10499).
airport('MLW', 'Spriggs Payne Airport', 25, 6.28906011581421, -10.7587003707886, 6000).
airport('VIL', 'Dakhla Airport', 36, 23.7182998657227, -15.9320001602173, 9842).
airport('EUN', 'Hassan I Airport', 207, 27.1516990661621, -13.2192001342773, 8861).
airport('EUN', 'Hassan I Airport', 207, 27.1516990661621, -13.2192001342773, 8361).
airport('TTU', 'Saniat Rmel Airport', 10, 35.5942993164062, -5.32002019882202, 7546).
airport('GNU', 'Goodnews Airport', 18, 59.117401123, -161.57699585, 3300).
airport('ZIG', 'Ziguinchor Airport', 75, 12.5556001663208, -16.2817993164062, 5069).
airport('NDB', 'Nouadhibou International Airport', 24, 20.9330997467041, -17.0300006866455, 7961).
airport('OUZ', 'Tazadit Airport', 1129, 22.7563991546631, -12.4835996627808, 7874).
airport('MMO', 'Maio Airport', 36, 15.1559000015259, -23.2136993408203, 3924).
airport('MMO', 'Maio Airport', 36, 15.1559000015259, -23.2136993408203, 3424).
airport('SFL', 'São Filipe Airport', 617, 14.8850002289, -24.4799995422, 3937).
airport('SNE', 'Preguiça Airport', 669, 16.588399887085, -24.2847003936768, 4593).
airport('AMH', 'Arba Minch Airport', 3901, 6.03939008712769, 37.5904998779297, 9170).
airport('AXU', 'Axum Airport', 6959, 14.1468000411987, 38.7728004455566, 7874).
airport('BJR', 'Bahir Dar Airport', 5978, 11.608099937439, 37.3216018676758, 9842).
airport('DIR', 'Aba Tenna Dejazmach Yilma International Airport', 3827, 9.62469959259033, 41.8541984558105, 8791).
airport('GMB', 'Gambella Airport', 1614, 8.12876033782959, 34.5630989074707, 8248).
airport('GDQ', 'Gonder Airport', 6449, 12.5199003219604, 37.4339981079102, 9072).
airport('JIJ', 'Wilwal International Airport', 5954, 9.3325, 42.9121, 8060).
airport('JIM', 'Jimma Airport', 5500, 7.66609001159668, 36.8166007995605, 6562).
airport('MQX', 'Alula Aba Nega Airport', 7396, 13.467399597168, 39.5335006713867, 11825).
airport('ASO', 'Asosa Airport', 5100, 10.018500328064, 34.5862998962402, 6398).
airport('BSA', 'Bosaso Airport', 3, 11.2753000259399, 49.1493988037109, 5873).
airport('MGQ', 'Aden Adde International Airport', 29, 2.01444005966187, 45.3046989440918, 10335).
airport('GLK', 'Galcaio Airport', 975, 6.78082990646, 47.45470047, 9843).
airport('ATZ', 'Assiut International Airport', 772, 27.0464992523, 31.0119991302, 9905).
airport('HMB', 'Sohag International Airport', 859, 26.3427777778, 31.7427777778, 9843).
airport('ASW', 'Aswan International Airport', 662, 23.9643993378, 32.8199996948, 11161).
airport('ASM', 'Asmara International Airport', 7661, 15.2918996810913, 38.910701751709, 9842).
airport('ASM', 'Asmara International Airport', 7661, 15.2918996810913, 38.910701751709, 9342).
airport('HKB', 'Healy River Airport', 1180, 63.9958, -144.6926, 2910).
airport('EDL', 'Eldoret International Airport', 6941, 0.404457986354828, 35.238899230957, 11480).
airport('KIS', 'Kisumu Airport', 3734, -0.0861390009522438, 34.7289009094238, 6511).
airport('LOK', 'Lodwar Airport', 1715, 3.1219699382782, 35.608699798584, 3281).
airport('LOK', 'Lodwar Airport', 1715, 3.1219699382782, 35.608699798584, 2781).
airport('LOK', 'Lodwar Airport', 1715, 3.1219699382782, 35.608699798584, 2281).
airport('MYD', 'Malindi Airport', 80, -3.22931003570557, 40.1016998291016, 4600).
airport('MYD', 'Malindi Airport', 80, -3.22931003570557, 40.1016998291016, 4100).
airport('WIL', 'Nairobi Wilson Airport', 5536, -1.32172000408173, 36.8148002624512, 5052).
airport('WIL', 'Nairobi Wilson Airport', 5536, -1.32172000408173, 36.8148002624512, 4552).
airport('WJR', 'Wajir Airport', 770, 1.73324000835419, 40.0915985107422, 9193).
airport('GHT', 'Ghat Airport', 2296, 25.1455993652, 10.1426000595, 11811).
airport('GHT', 'Ghat Airport', 2296, 25.1455993652, 10.1426000595, 11311).
airport('AKF', 'Kufra Airport', 1367, 24.1786994934082, 23.3139991760254, 12007).
airport('AKF', 'Kufra Airport', 1367, 24.1786994934082, 23.3139991760254, 11507).
airport('LTD', 'Ghadames East Airport', 1122, 30.1516990661621, 9.71531009674072, 11811).
airport('LTD', 'Ghadames East Airport', 1122, 30.1516990661621, 9.71531009674072, 11311).
airport('KME', 'Kamembe Airport', 5192, -2.46223998069763, 28.9078998565674, 4921).
airport('ELF', 'El Fasher Airport', 2393, 13.6148996353149, 25.3246002197266, 9744).
airport('ELF', 'El Fasher Airport', 2393, 13.6148996353149, 25.3246002197266, 9244).
airport('EGN', 'Geneina Airport', 2650, 13.4816999435425, 22.4671993255615, 6194).
airport('EGN', 'Geneina Airport', 2650, 13.4816999435425, 22.4671993255615, 5694).
airport('UYL', 'Nyala Airport', 2106, 12.0535001754761, 24.9561996459961, 9880).
airport('ARK', 'Arusha Airport', 4550, -3.36778998374939, 36.63330078125, 5377).
airport('MBI', 'Mbeya Airport', 5600, -8.91699981689453, 33.4669990539551, 4921).
airport('MYW', 'Mtwara Airport', 371, -10.3390998840332, 40.1818008422852, 7410).
airport('MYW', 'Mtwara Airport', 371, -10.3390998840332, 40.1818008422852, 6910).
airport('MWZ', 'Mwanza Airport', 3763, -2.4444899559021, 32.9327011108398, 10212).
airport('RUA', 'Arua Airport', 3951, 3.04999995231628, 30.9169998168945, 5600).
airport('KSE', 'Kasese Airport', 3146, 0.18299999833107, 30.1000003814697, 5151).
airport('PAF', 'Pakuba Airport', 2365, 2.202222, 31.554444, 5528).
airport('PUM', 'Pomala Airport', 88, -4.18108987808228, 121.61799621582, 3177).
airport('JGD', 'Jiagedaqi Airport', 1205, 50.375, 124.116666667, 7546).
airport('JIC', 'Jinchuan Airport', 4740, 38.5422222222, 102.348333333, 9843).
airport('JUH', 'Jiuhuashan Airport', 60, 30.7403, 117.6856, 7874).
airport('BLV', 'Scott AFB/Midamerica Airport', 459, 38.54520035, -89.83519745, 10000).
airport('BLV', 'Scott AFB/Midamerica Airport', 459, 38.54520035, -89.83519745, 9500).
airport('CGI', 'Cape Girardeau Regional Airport', 342, 37.2252998352051, -89.57080078125, 6499).
airport('CGI', 'Cape Girardeau Regional Airport', 342, 37.2252998352051, -89.57080078125, 5999).
airport('CKB', 'North Central West Virginia Airport', 1217, 39.2966003418, -80.2281036377, 7000).
airport('CNM', 'Cavern City Air Terminal', 3295, 32.3375015258789, -104.263000488281, 7854).
airport('CNM', 'Cavern City Air Terminal', 3295, 32.3375015258789, -104.263000488281, 7354).
airport('CNM', 'Cavern City Air Terminal', 3295, 32.3375015258789, -104.263000488281, 6854).
airport('CNM', 'Cavern City Air Terminal', 3295, 32.3375015258789, -104.263000488281, 6354).
airport('ELD', 'South Arkansas Regional At Goodwin Field', 277, 33.2210006713867, -92.8133010864258, 6600).
airport('ELD', 'South Arkansas Regional At Goodwin Field', 277, 33.2210006713867, -92.8133010864258, 6100).
airport('ELD', 'South Arkansas Regional At Goodwin Field', 277, 33.2210006713867, -92.8133010864258, 5600).
airport('EWB', 'New Bedford Regional Airport', 80, 41.6761016845703, -70.956901550293, 5000).
airport('EWB', 'New Bedford Regional Airport', 80, 41.6761016845703, -70.956901550293, 4500).
airport('GCN', 'Grand Canyon National Park Airport', 6609, 35.9524002075195, -112.147003173828, 8999).
airport('GDV', 'Dawson Community Airport', 2458, 47.13869858, -104.8069992, 5704).
airport('GDV', 'Dawson Community Airport', 2458, 47.13869858, -104.8069992, 5204).
airport('GGW', 'Wokal Field Glasgow International Airport', 2296, 48.2125015258789, -106.61499786377, 5001).
airport('GGW', 'Wokal Field Glasgow International Airport', 2296, 48.2125015258789, -106.61499786377, 4501).
airport('GLH', 'Mid Delta Regional Airport', 131, 33.4828987121582, -90.9856033325195, 8001).
airport('GLH', 'Mid Delta Regional Airport', 131, 33.4828987121582, -90.9856033325195, 7501).
airport('HON', 'Huron Regional Airport', 1289, 44.3852005004883, -98.2285003662109, 7201).
airport('HON', 'Huron Regional Airport', 1289, 44.3852005004883, -98.2285003662109, 6701).
airport('HOT', 'Memorial Field', 540, 34.4780006408691, -93.0961990356445, 6595).
airport('HOT', 'Memorial Field', 540, 34.4780006408691, -93.0961990356445, 6095).
airport('HTS', 'Tri-State/Milton J. Ferguson Field', 828, 38.36669922, -82.55799866, 6509).
airport('HTS', 'Tri-State/Milton J. Ferguson Field', 828, 38.36669922, -82.55799866, 6009).
airport('HVR', 'Havre City County Airport', 2591, 48.54299927, -109.762001, 5205).
airport('HVR', 'Havre City County Airport', 2591, 48.54299927, -109.762001, 4705).
airport('IRK', 'Kirksville Regional Airport', 966, 40.0934982299805, -92.5448989868164, 6005).
airport('IRK', 'Kirksville Regional Airport', 966, 40.0934982299805, -92.5448989868164, 5505).
airport('JBR', 'Jonesboro Municipal Airport', 262, 35.8316993713379, -90.6464004516602, 6200).
airport('JBR', 'Jonesboro Municipal Airport', 262, 35.8316993713379, -90.6464004516602, 5700).
airport('LAM', 'Los Alamos Airport', 7171, 35.8797988892, -106.268997192, 5550).
airport('LCK', 'Rickenbacker International Airport', 744, 39.8138008118, -82.9278030396, 12102).
airport('LCK', 'Rickenbacker International Airport', 744, 39.8138008118, -82.9278030396, 11602).
airport('LCK', 'Rickenbacker International Airport', 744, 39.8138008118, -82.9278030396, 11102).
airport('LUK', 'Cincinnati Municipal Airport Lunken Field', 483, 39.10329819, -84.41860199, 6101).
airport('LUK', 'Cincinnati Municipal Airport Lunken Field', 483, 39.10329819, -84.41860199, 5601).
airport('LUK', 'Cincinnati Municipal Airport Lunken Field', 483, 39.10329819, -84.41860199, 5101).
airport('LYH', 'Lynchburg Regional Preston Glenn Field', 938, 37.3266983032227, -79.2004013061523, 5799).
airport('LYH', 'Lynchburg Regional Preston Glenn Field', 938, 37.3266983032227, -79.2004013061523, 5299).
airport('MBL', 'Manistee Co Blacker Airport', 621, 44.2723999, -86.24690247, 5502).
airport('MBL', 'Manistee Co Blacker Airport', 621, 44.2723999, -86.24690247, 5002).
airport('MMU', 'Morristown Municipal Airport', 187, 40.7994003295898, -74.4149017333984, 5999).
airport('MMU', 'Morristown Municipal Airport', 187, 40.7994003295898, -74.4149017333984, 5499).
airport('MSS', 'Massena International Richards Field', 215, 44.9357986450195, -74.8455963134766, 4998).
airport('MSS', 'Massena International Richards Field', 215, 44.9357986450195, -74.8455963134766, 4498).
airport('MWA', 'Williamson County Regional Airport', 472, 37.75500107, -89.01110077, 8012).
airport('MWA', 'Williamson County Regional Airport', 472, 37.75500107, -89.01110077, 7512).
airport('OGS', 'Ogdensburg International Airport', 297, 44.6819000244, -75.4654998779, 5200).
airport('OLF', 'L M Clayton Airport', 1986, 48.0945014954, -105.574996948, 5089).
airport('OWB', 'Owensboro Daviess County Airport', 407, 37.74010086, -87.16680145, 6494).
airport('OWB', 'Owensboro Daviess County Airport', 407, 37.74010086, -87.16680145, 5994).
airport('PDT', 'Eastern Oregon Regional At Pendleton Airport', 1497, 45.695098877, -118.841003418, 6300).
airport('PDT', 'Eastern Oregon Regional At Pendleton Airport', 1497, 45.695098877, -118.841003418, 5800).
airport('PDT', 'Eastern Oregon Regional At Pendleton Airport', 1497, 45.695098877, -118.841003418, 5300).
airport('PGV', 'Pitt Greenville Airport', 26, 35.6352005, -77.38529968, 6500).
airport('PGV', 'Pitt Greenville Airport', 26, 35.6352005, -77.38529968, 6000).
airport('PGV', 'Pitt Greenville Airport', 26, 35.6352005, -77.38529968, 5500).
airport('PSM', 'Portsmouth International at Pease Airport', 100, 43.0778999329, -70.8233032227, 11321).
airport('SDY', 'Sidney Richland Municipal Airport', 1985, 47.70690155, -104.1930008, 5705).
airport('SDY', 'Sidney Richland Municipal Airport', 1985, 47.70690155, -104.1930008, 5205).
airport('TBN', 'Waynesville-St. Robert Regional Forney field', 1159, 37.74160004, -92.14070129, 6038).
airport('TEB', 'Teterboro Airport', 9, 40.8501014709, -74.060798645, 7000).
airport('TEB', 'Teterboro Airport', 9, 40.8501014709, -74.060798645, 6500).
airport('TVF', 'Thief River Falls Regional Airport', 1119, 48.06570053, -96.18499756, 6503).
airport('TVF', 'Thief River Falls Regional Airport', 1119, 48.06570053, -96.18499756, 6003).
airport('UIN', 'Quincy Regional Baldwin Field', 768, 39.94269943, -91.19460297, 7098).
airport('UIN', 'Quincy Regional Baldwin Field', 768, 39.94269943, -91.19460297, 6598).
airport('UIN', 'Quincy Regional Baldwin Field', 768, 39.94269943, -91.19460297, 6098).
airport('WRL', 'Worland Municipal Airport', 4227, 43.9656982421875, -107.950996398926, 7005).
airport('WRL', 'Worland Municipal Airport', 4227, 43.9656982421875, -107.950996398926, 6505).
airport('WRL', 'Worland Municipal Airport', 4227, 43.9656982421875, -107.950996398926, 6005).
airport('YNG', 'Youngstown Warren Regional Airport', 1192, 41.26070023, -80.67910004, 9003).
airport('YNG', 'Youngstown Warren Regional Airport', 1192, 41.26070023, -80.67910004, 8503).
airport('YNG', 'Youngstown Warren Regional Airport', 1192, 41.26070023, -80.67910004, 8003).
airport('DZN', 'Dzhezkazgan Airport', 1134, 47.7708015441895, 67.6734008789062, 8530).
airport('ECN', 'Ercan International Airport', 404, 35.1547012329102, 33.4961013793945, 9039).
airport('BWK', 'Bol Airport', 1776, 43.285701751709, 16.6797008514404, 4724).
airport('EBU', 'Saint-Étienne-Bouthéon Airport', 1325, 45.540599822998, 4.29639005661011, 7546).
airport('AVN', 'Avignon-Caumont Airport', 124, 43.907299041748, 4.90183019638062, 6168).
airport('LEH', 'Le Havre Octeville Airport', 313, 49.5339012145996, 0.0880559980869293, 7546).
airport('XCR', 'Châlons-Vatry Air Base', 587, 48.7761001586914, 4.18449020385742, 12664).
airport('DIJ', 'Dijon-Bourgogne Airport', 726, 47.268901825, 5.09000015259, 7874).
airport('DIJ', 'Dijon-Bourgogne Airport', 726, 47.268901825, 5.09000015259, 7374).
airport('KSJ', 'Kasos Airport', 35, 35.4213981628, 26.9099998474, 3221).
airport('DEB', 'Debrecen International Airport', 359, 47.488899230957, 21.6152992248535, 8196).
airport('DEB', 'Debrecen International Airport', 359, 47.488899230957, 21.6152992248535, 7696).
airport('CUF', 'Cuneo International Airport', 1267, 44.547000885, 7.62321996689, 6903).
airport('RMI', 'Federico Fellini International Airport', 40, 44.0203018188, 12.611700058, 9828).
airport('KLV', 'Karlovy Vary International Airport', 1989, 50.2029991149902, 12.914999961853, 7054).
airport('PED', 'Pardubice Airport', 741, 50.0134010314941, 15.7385997772217, 8203).
airport('ETH', 'Eilat Airport', 42, 29.56130027771, 34.9600982666016, 6234).
airport('CVU', 'Corvo Airport', 19, 39.671501159668, -31.1135997772217, 2756).
airport('FLW', 'Flores Airport', 112, 39.4552993774414, -31.1313991546631, 4593).
airport('GRW', 'Graciosa Airport', 86, 39.0922012329102, -28.0298004150391, 4529).
airport('SJZ', 'São Jorge Airport', 311, 38.6655006408691, -28.1758003234863, 4508).
airport('OMO', 'Mostar International Airport', 156, 43.282901763916, 17.8458995819092, 7874).
airport('TZL', 'Tuzla International Airport', 784, 44.4586982727051, 18.7248001098633, 8152).
airport('ARW', 'Arad International Airport', 352, 46.1766014099121, 21.261999130249, 6562).
airport('BAY', 'Tautii Magheraus Airport', 605, 47.6584014892578, 23.4699993133545, 5905).
airport('CND', 'Mihail Kogălniceanu International Airport', 353, 44.3622016906738, 28.4883003234863, 11483).
airport('CRA', 'Craiova Airport', 626, 44.3180999755859, 23.888599395752, 8203).
airport('OMR', 'Oradea International Airport', 465, 47.0252990722656, 21.9025001525879, 5906).
airport('SUJ', 'Satu Mare Airport', 405, 47.7033004760742, 22.8857002258301, 8160).
airport('TGM', 'Transilvania Târgu Mureş International Airport', 963, 46.467700958252, 24.4125003814697, 6562).
airport('ADA', 'Adana Airport', 65, 36.9822006226, 35.2803993225, 9022).
airport('GZT', 'Gaziantep International Airport', 2315, 36.9472007751, 37.4786987305, 9843).
airport('GZT', 'Gaziantep International Airport', 2315, 36.9472007751, 37.4786987305, 9343).
airport('KFS', 'Kastamonu Airport', 3524, 41.3142013549805, 33.7957992553711, 7382).
airport('MZH', 'Amasya Merzifon Airport', 1758, 40.8293991089, 35.5219993591, 9600).
airport('VAS', 'Sivas Airport', 5236, 39.8138008117676, 36.9034996032715, 12503).
airport('ONQ', 'Zonguldak Airport', 44, 41.506401062, 32.0886001587, 5906).
airport('MLX', 'Malatya Erhaç Airport', 2828, 38.4352989197, 38.0909996033, 10990).
airport('DNZ', 'Çardak Airport', 2795, 37.7855987549, 29.7012996674, 9842).
airport('NAV', 'Nevşehir Kapadokya International Airport', 3100, 38.771900177, 34.5345001221, 9842).
airport('CKZ', 'Çanakkale Airport', 23, 40.1376991272, 26.4267997742, 5905).
airport('KCO', 'Cengiz Topel Airport', 182, 40.7350006103516, 30.0832996368408, 9842).
airport('TEQ', 'Tekirdağ Çorlu Airport', 574, 41.1381988525391, 27.9190998077393, 9844).
airport('EZS', 'Elazığ Airport', 2927, 38.6068992615, 39.2914009094, 5643).
airport('DIY', 'Diyarbakir Airport', 2251, 37.893901825, 40.2010002136, 11644).
airport('ERC', 'Erzincan Airport', 3783, 39.7102012634, 39.5270004272, 9842).
airport('ERC', 'Erzincan Airport', 3783, 39.7102012634, 39.5270004272, 9342).
airport('ERZ', 'Erzurum International Airport', 5763, 39.9565010071, 41.1702003479, 12500).
airport('ERZ', 'Erzurum International Airport', 5763, 39.9565010071, 41.1702003479, 12000).
airport('ERZ', 'Erzurum International Airport', 5763, 39.9565010071, 41.1702003479, 11500).
airport('KSY', 'Kars Airport', 5889, 40.562198638916, 43.1150016784668, 11483).
airport('TZX', 'Trabzon International Airport', 104, 40.9950981140137, 39.7896995544434, 8661).
airport('VAN', 'Van Ferit Melen Airport', 5480, 38.4682006835938, 43.3322982788086, 9022).
airport('BAL', 'Batman Airport', 1822, 37.9290008545, 41.1166000366, 10000).
airport('MSR', 'Muş Airport', 4157, 38.7477989196777, 41.6612014770508, 11649).
airport('KCM', 'Kahramanmaraş Airport', 1723, 37.5388259888, 36.9535217285, 7546).
airport('AJI', 'Ağrı Airport', 5462, 39.654541015625, 43.0259780883789, 6562).
airport('ADF', 'Adıyaman Airport', 2216, 37.7313995361, 38.4688987732, 8212).
airport('MQM', 'Mardin Airport', 1729, 37.2233009338, 40.6316986084, 8204).
airport('GNY', 'Şanlıurfa GAP Airport', 2708, 37.4456634521484, 38.8955917358398, 13123).
airport('HTY', 'Hatay Airport', 269, 36.36277771, 36.2822227478, 9843).
airport('ISE', 'Süleyman Demirel International Airport', 2835, 37.8554000854, 30.3684005737, 9843).
airport('EDO', 'Balıkesir Körfez Airport', 50, 39.554599762, 27.0137996674, 9842).
airport('QUB', 'Ubari Airport', 1387, 26.5674991608, 12.82310009, 9349).
airport('GLN', 'Goulimime Airport', 984, 29.0266990662, -10.0502996445, 10007).
airport('GDT', 'JAGS McCartney International Airport', 13, 21.4444999694824, -71.1423034667969, 6362).
airport('XSC', 'South Caicos Airport', 6, 21.5156993866, -71.528503418, 5991).
airport('JBQ', 'La Isabela International Airport', 98, 18.5725002288818, -69.9856033325195, 5412).
airport('FRS', 'Mundo Maya International Airport', 427, 16.9137992859, -89.8664016724, 9842).
airport('LCE', 'Goloson International Airport', 49, 15.7425003051758, -86.8529968261719, 9875).
airport('PEU', 'Puerto Lempira Airport', 25, 15.2622003555298, -83.7811965942383, 5006).
airport('JXA', 'Jixi Xingkaihu Airport', 760, 45.293, 131.193, 7546).
airport('BOC', 'Bocas Del Toro International Airport', 10, 9.34084987640381, -82.2508010864258, 4921).
airport('DAV', 'Enrique Malek International Airport', 89, 8.39099979400635, -82.4349975585938, 6890).
airport('FON', 'Arenal Airport', 377, 10.4779996871948, -84.6344985961914, 2625).
airport('TTQ', 'Aerotortuguero Airport', 82, 10.5690002441406, -83.5148010253906, 3118).
airport('HEK', 'Heihe Airport', 8530, 50.1716209371, 127.308883667, 8202).
airport('DRK', 'Drake Bay Airport', 13, 8.71889019012, -83.6417007446, 2461).
airport('GLF', 'Golfito Airport', 49, 8.65400981903076, -83.1821975708008, 4593).
airport('NOB', 'Nosara Airport', 33, 9.97649002075, -85.6529998779, 3281).
airport('PJM', 'Puerto Jimenez Airport', 7, 8.53332996368408, -83.3000030517578, 2707).
airport('PMZ', 'Palmar Sur Airport', 49, 8.95102977752686, -83.4685974121094, 4593).
airport('SYQ', 'Tobias Bolanos International Airport', 3287, 9.95705032348633, -84.1398010253906, 5250).
airport('XQP', 'Quepos Managua Airport', 85, 9.44316005706787, -84.1297988891602, 3609).
airport('TNO', 'Tamarindo De Santa Cruz Airport', 41, 10.3135004043579, -85.8154983520508, 2625).
airport('TMU', 'Tambor Airport', 33, 9.7385196685791, -85.013801574707, 2297).
airport('CAP', 'Cap Haitien International Airport', 10, 19.7329998016357, -72.1947021484375, 4886).
airport('GAO', 'Mariana Grajales Airport', 56, 20.0853004455566, -75.1583023071289, 8025).
airport('LYB', 'Edward Bodden Airfield', 3, 19.6669998168945, -80.0999984741211, 3300).
airport('AXP', 'Spring Point Airport', 11, 22.4417991638, -73.9709014893, 5000).
airport('ATC', "Arthur's Town Airport", 18, 24.6294002533, -75.6737976074, 7015).
airport('ATC', "Arthur's Town Airport", 18, 24.6294002533, -75.6737976074, 6515).
airport('CRI', 'Colonel Hill Airport', 5, 22.7455997467, -74.1824035645, 4061).
airport('RSD', 'Rock Sound Airport', 10, 24.8950787333, -76.1768817902, 7213).
airport('IGA', 'Inagua Airport', 8, 20.9750003814697, -73.6669006347656, 7020).
airport('IGA', 'Inagua Airport', 8, 20.9750003814697, -73.6669006347656, 6520).
airport('LGI', "Deadman's Cay Airport", 9, 23.1790008545, -75.0935974121, 4000).
airport('SML', 'Stella Maris Airport', 10, 23.5823168043, -75.2686214447, 4000).
airport('MYG', 'Mayaguana Airport', 11, 22.3794994354, -73.0134963989, 7297).
airport('RCY', 'Rum Cay Airport', 15, 23.6844005584717, -74.8361968994141, 4500).
airport('AIT', 'Aitutaki Airport', 14, -18.8309001922607, -159.764007568359, 5920).
airport('AIT', 'Aitutaki Airport', 14, -18.8309001922607, -159.764007568359, 5420).
airport('AIU', 'Enua Airport', 36, -19.9678001403809, -158.119003295898, 3947).
airport('MGS', 'Mangaia Island Airport', 45, -21.8959865570068, -157.906661987305, 3274).
airport('MUK', 'Mauke Airport', 26, -20.136100769043, -157.345001220703, 4921).
airport('MOI', 'Mitiaro Island Airport', 25, -19.8425006866455, -157.703002929688, 5000).
airport('ICI', 'Cicia Airport', 13, -17.7432994843, -179.341995239, 2500).
airport('BFJ', 'Bijie Feixiong Airport', 4751, 27.300278, 105.301389, 8530).
airport('KDV', 'Vunisea Airport', 6, -19.0580997467, 178.156997681, 3005).
airport('LKB', 'Lakeba Island Airport', 280, -18.1991996765, -178.817001343, 2372).
airport('LBS', 'Labasa Airport', 44, -16.4666996002197, 179.339996337891, 3521).
airport('TVU', 'Matei Airport', 60, -16.6905994415, -179.876998901, 3281).
airport('RTA', 'Rotuma Airport', 22, -12.4825000762939, 177.070999145508, 4806).
airport('SVU', 'Savusavu Airport', 17, -16.8027992249, 179.341003418, 2526).
airport('VBV', 'Vanua Balavu Airport', 156, -17.2689990997314, -178.975997924805, 2480).
airport('GMO', 'Gombe Lawanti International Airport', 1590, 10.2983333333, 10.8963888889, 10827).
airport('QRW', 'Warri Airport', 242, 5.59610986709595, 5.81778001785278, 6890).
airport('FUN', 'Funafuti International Airport', 9, -8.525, 179.195999, 5000).
airport('WLS', 'Hihifo Airport', 79, -13.2383003235, -176.199005127, 6890).
airport('RMT', 'Rimatara Airport', 60, -22.63725, -152.8059, 4593).
airport('RUR', 'Rurutu Airport', 18, -22.4340991973877, -151.360992431641, 4757).
airport('TUB', 'Tubuai Airport', 7, -23.3654003143311, -149.524002075195, 4921).
airport('RVV', 'Raivavae Airport', 7, -23.8852005005, -147.662002563, 4592).
airport('TIH', 'Tikehau Airport', 6, -15.1196002960205, -148.231002807617, 3937).
airport('FAV', 'Fakarava Airport', 13, -16.0541000366211, -145.656997680664, 3871).
airport('XMH', 'Manihi Airport', 14, -14.4368000030518, -146.070007324219, 3051).
airport('AXR', 'Arutua Airport', 9, -15.2482995986938, -146.617004394531, 4268).
airport('MVT', 'Mataiva Airport', 11, -14.8681001663208, -148.716995239258, 3937).
airport('AHE', 'Ahe Airport', 11, -14.4280996322632, -146.25700378418, 4068).
airport('RKA', 'Aratika Nord Airport', 10, -15.4853000641, -145.470001221, 4150).
airport('TKX', 'Takaroa Airport', 13, -14.4558000564575, -145.024993896484, 3452).
airport('NHV', 'Nuku Hiva Airport', 220, -8.79559993743896, -140.22900390625, 5578).
airport('AUQ', 'Hiva Oa-Atuona Airport', 1481, -9.76879024506, -139.011001587, 3986).
airport('BOB', 'Bora Bora Airport', 10, -16.4444007873535, -151.751007080078, 4921).
airport('BOB', 'Bora Bora Airport', 10, -16.4444007873535, -151.751007080078, 4421).
airport('RGI', 'Rangiroa Airport', 10, -14.9542999267578, -147.660995483398, 6890).
airport('HUH', 'Huahine-Fare Airport', 7, -16.6872005462646, -151.022003173828, 4921).
airport('MOZ', 'Moorea Airport', 9, -17.4899997711182, -149.761993408203, 3871).
airport('HOI', 'Hao Airport', 10, -18.074800491333, -140.945999145508, 11089).
airport('MAU', 'Maupiti Airport', 15, -16.4265003204346, -152.244003295898, 3135).
airport('RFP', 'Raiatea Airport', 3, -16.722900390625, -151.466003417969, 4593).
airport('SLH', 'Sola Airport', 7, -13.8516998291, 167.537002563, 2723).
airport('EAE', 'Siwo Airport', 7, -17.0902996063, 168.343002319, 2307).
airport('CCV', 'Craig Cove Airport', 69, -16.2649993896484, 167.92399597168, 2674).
airport('LOD', 'Longana Airport', 167, -15.3066997528, 167.966995239, 2887).
airport('SSR', 'Sara Airport', 493, -15.4708003998, 168.151992798, 1600).
airport('PBJ', 'Tavie Airport', 160, -16.438999176, 168.257003784, 1968).
airport('LPM', 'Lamap Airport', 7, -16.4540004730225, 167.822998046875, 2755).
airport('LNB', 'Lamen Bay Airport', 7, -16.5841999054, 168.158996582, 2789).
airport('MWF', 'Maewo-Naone Airport', 509, -15.0, 168.082992554, 2789).
airport('LNE', 'Lonorore Airport', 43, -15.8655996323, 168.17199707, 2175).
airport('NUS', 'Norsup Airport', 23, -16.0797004699707, 167.401000976562, 2972).
airport('ZGU', 'Gaua Island Airport', 100, -14.2180995941, 167.587005615, 2802).
airport('TGH', 'Tongoa Airport', 443, -16.8910999298, 168.550994873, 2329).
airport('VLS', 'Valesdir Airport', 10, -16.7961006165, 168.177001953, 2625).
airport('WLH', 'Walaha Airport', 151, -15.4119997025, 167.690994263, 2379).
airport('SWJ', 'Southwest Bay Airport', 68, -16.4864, 167.4472, 2674).
airport('DLY', "Dillon's Bay Airport", 630, -18.7693996429, 169.00100708, 2428).
airport('IPA', 'Ipota Airport', 23, -18.856389, 169.283333, 2995).
airport('TAH', 'Tanna Airport', 19, -19.455099105835, 169.223999023438, 4035).
airport('KRL', 'Korla Airport', 3051, 41.6977996826172, 86.1288986206055, 9121).
airport('MZR', 'Mazar I Sharif Airport', 1284, 36.706901550293, 67.2097015380859, 10437).
airport('MZR', 'Mazar I Sharif Airport', 1284, 36.706901550293, 67.2097015380859, 9937).
airport('HOF', 'Al Ahsa Airport', 588, 25.2852993011475, 49.4851989746094, 10039).
airport('ABT', 'Al Baha Airport', 5486, 20.2961006165, 41.6343002319, 10991).
airport('BHH', 'Bisha Airport', 3887, 19.9843997955322, 42.6208992004395, 10007).
airport('DWD', 'Dawadmi Domestic Airport', 3429, 24.5, 44.4000015258789, 10007).
airport('GIZ', 'Jizan Regional Airport', 20, 16.9011001586914, 42.5858001708984, 10006).
airport('URY', 'Guriat Domestic Airport', 1672, 31.4118995666504, 37.2794990539551, 10007).
airport('EAM', 'Nejran Airport', 3982, 17.611400604248, 44.4192008972168, 10007).
airport('AQI', 'Qaisumah Domestic Airport', 1174, 28.3351993561, 46.1250991821, 9843).
airport('RAH', 'Rafha Domestic Airport', 1474, 29.6263999938965, 43.4906005859375, 9834).
airport('RAE', 'Arar Domestic Airport', 1813, 30.9066009521484, 41.1381988525391, 10007).
airport('SHW', 'Sharurah Airport', 2363, 17.4668998718262, 47.1213989257812, 11975).
airport('AJF', 'Al-Jawf Domestic Airport', 2261, 29.7851009368896, 40.0999984741211, 12011).
airport('TUI', 'Turaif Domestic Airport', 2803, 31.692699432373, 38.731201171875, 9843).
airport('WAE', 'Wadi al-Dawasir Airport', 2062, 20.5042991638, 45.1996002197, 10007).
airport('EJH', 'Al Wajh Domestic Airport', 66, 26.198600769043, 36.4763984680176, 10007).
airport('YUS', 'Yushu Batang Airport', 12816, 32.8363888889, 97.0363888889, 12467).
airport('ABD', 'Abadan Airport', 10, 30.371099472, 48.2282981873, 10169).
airport('ABD', 'Abadan Airport', 10, 30.371099472, 48.2282981873, 9669).
airport('MRX', 'Mahshahr Airport', 8, 30.5562000274658, 49.1519012451172, 8874).
airport('SXI', 'Sirri Island Airport', 43, 25.908899307251, 54.5393981933594, 8345).
airport('KSH', 'Shahid Ashrafi Esfahani Airport', 4307, 34.3459014893, 47.1581001282, 11213).
airport('RAS', 'Sardar-e-Jangal Airport', -40, 37.323333, 49.617778, 9571).
airport('HDM', 'Hamadan Airport', 5755, 34.8692016601562, 48.5525016784668, 10611).
airport('THR', 'Mehrabad International Airport', 3962, 35.6892013549805, 51.3134002685547, 13248).
airport('THR', 'Mehrabad International Airport', 3962, 35.6892013549805, 51.3134002685547, 12748).
airport('THR', 'Mehrabad International Airport', 3962, 35.6892013549805, 51.3134002685547, 12248).
airport('KER', 'Kerman Airport', 5741, 30.2744007111, 56.9510993958, 12620).
airport('KER', 'Kerman Airport', 5741, 30.2744007111, 56.9510993958, 12120).
airport('XBJ', 'Birjand Airport', 4952, 32.8981018066406, 59.2661018371582, 9521).
airport('XBJ', 'Birjand Airport', 4952, 32.8981018066406, 59.2661018371582, 9021).
airport('GBT', 'Gorgan Airport', -24, 36.9094009399, 54.4012985229, 7540).
airport('NSH', 'Now Shahr Airport', -61, 36.6632995605469, 51.4646987915039, 6182).
airport('RZR', 'Ramsar Airport', -70, 36.9099006652832, 50.6795997619629, 4920).
airport('SRY', 'Dasht-e Naz Airport', 35, 36.635799408, 53.1935997009, 8688).
airport('ADU', 'Ardabil Airport', 4315, 38.3256988525, 48.4244003296, 10823).
airport('OMH', 'Urmia Airport', 4343, 37.6680984497, 45.0686988831, 10658).
airport('AZD', 'Shahid Sadooghi Airport', 4054, 31.9048995972, 54.2765007019, 13446).
airport('ACZ', 'Zabol Airport', 1628, 31.0983009338379, 61.5438995361328, 9848).
airport('AQJ', 'Aqaba King Hussein International Airport', 175, 29.6116008758545, 35.0181007385254, 9855).
airport('AAN', 'Al Ain International Airport', 869, 24.2616996765137, 55.6091995239258, 13123).
airport('FJR', 'Fujairah International Airport', 152, 25.1121997833252, 56.3240013122559, 12303).
airport('KHS', 'Khasab Air Base', 100, 26.1709995269775, 56.2406005859375, 8202).
airport('BHV', 'Bahawalpur Airport', 392, 29.3481006622314, 71.7180023193359, 9345).
airport('CJL', 'Chitral Airport', 4920, 35.8866004943848, 71.8005981445312, 5741).
airport('DEA', 'Dera Ghazi Khan Airport', 492, 29.9610004425049, 70.4859008789062, 6499).
airport('DSK', 'Dera Ismael Khan Airport', 594, 31.9094009399414, 70.896598815918, 5000).
airport('LYP', 'Faisalabad International Airport', 591, 31.3649997711182, 72.9947967529297, 9272).
airport('GWD', 'Gwadar International Airport', 36, 25.2332992553711, 62.3294982910156, 4960).
airport('GIL', 'Gilgit Airport', 4796, 35.9188003540039, 74.3336029052734, 5400).
airport('GIL', 'Gilgit Airport', 4796, 35.9188003540039, 74.3336029052734, 4900).
airport('MJD', 'Moenjodaro Airport', 154, 27.3351993560791, 68.1430969238281, 6512).
airport('PJG', 'Panjgur Airport', 3289, 26.9545001983643, 64.1324996948242, 5000).
airport('UET', 'Quetta International Airport', 5267, 30.2513999938965, 66.9377975463867, 12000).
airport('UET', 'Quetta International Airport', 5267, 30.2513999938965, 66.9377975463867, 11500).
airport('RYK', 'Shaikh Zaid Airport', 271, 28.3838996887207, 70.2796020507812, 9842).
airport('KDU', 'Skardu Airport', 7316, 35.3354988098145, 75.536003112793, 11944).
airport('KDU', 'Skardu Airport', 7316, 35.3354988098145, 75.536003112793, 11444).
airport('SKZ', 'Sukkur Airport', 196, 27.7220001220703, 68.7917022705078, 9000).
airport('TUK', 'Turbat International Airport', 498, 25.986400604248, 63.030200958252, 6000).
airport('ORI', 'Port Lions Airport', 52, 57.8853988647461, -152.845993041992, 2200).
airport('AXK', 'Ataq Airport', 3735, 14.5513000488281, 46.8261985778809, 9482).
airport('AAY', 'Al Ghaidah International Airport', 134, 16.1916999816895, 52.1749992370605, 8858).
airport('HOD', 'Hodeidah International Airport', 41, 14.7530002593994, 42.9762992858887, 9843).
airport('SCT', 'Socotra International Airport', 146, 12.6307001113892, 53.9057998657227, 10827).
airport('GXF', 'Sayun International Airport', 2097, 15.9660997391, 48.7882995605, 9843).
airport('TAI', "Ta'izz International Airport", 4838, 13.6859998703, 44.1390991211, 10040).
airport('BTI', 'Barter Island LRRS Airport', 2, 70.1340026855, -143.582000732, 4820).
airport('BKC', 'Buckland Airport', 31, 65.9815979004, -161.149002075, 3200).
airport('BTT', 'Bettles Airport', 647, 66.91390228, -151.529007, 5190).
airport('CEM', 'Central Airport', 937, 65.57379913, -144.7830048, 2782).
airport('CIK', 'Chalkyitsik Airport', 544, 66.6449966431, -143.740005493, 4000).
airport('CYF', 'Chefornak Airport', 40, 60.1492004395, -164.285995483, 2500).
airport('DRG', 'Deering Airport', 21, 66.0696029663, -162.76600647, 3300).
airport('DRG', 'Deering Airport', 21, 66.0696029663, -162.76600647, 2800).
airport('MLL', 'Marshall Don Hunter Sr Airport', 103, 61.8642997742, -162.026000977, 3201).
airport('KKH', 'Kongiganak Airport', 30, 59.9608001709, -162.880996704, 1885).
airport('EEK', 'Eek Airport', 12, 60.21367264, -162.0438843, 3243).
airport('EMK', 'Emmonak Airport', 13, 62.78609848, -164.4909973, 4601).
airport('ABL', 'Ambler Airport', 334, 67.106300354, -157.856994629, 3000).
airport('ABL', 'Ambler Airport', 334, 67.106300354, -157.856994629, 2500).
airport('GAL', 'Edward G. Pitka Sr Airport', 153, 64.73619843, -156.9369965, 7254).
airport('GAL', 'Edward G. Pitka Sr Airport', 153, 64.73619843, -156.9369965, 6754).
airport('GLV', 'Golovin Airport', 59, 64.5504989624, -163.007003784, 4000).
airport('GAM', 'Gambell Airport', 27, 63.7667999267578, -171.733001708984, 4501).
airport('GST', 'Gustavus Airport', 35, 58.4253006, -135.7070007, 6720).
airport('GST', 'Gustavus Airport', 35, 58.4253006, -135.7070007, 6220).
airport('SGY', 'Skagway Airport', 44, 59.4600982666016, -135.315994262695, 3550).
airport('HCR', 'Holy Cross Airport', 70, 62.1883010864258, -159.774993896484, 4000).
airport('HNS', 'Haines Airport', 15, 59.2438011169434, -135.524002075195, 4000).
airport('HPB', 'Hooper Bay Airport', 13, 61.52389908, -166.1470032, 3300).
airport('SHX', 'Shageluk Airport', 79, 62.6922988892, -159.569000244, 5000).
airport('SHX', 'Shageluk Airport', 79, 62.6922988892, -159.569000244, 4500).
airport('IAN', 'Bob Baker Memorial Airport', 166, 66.9759979248, -160.43699646, 3400).
airport('WAA', 'Wales Airport', 22, 65.6225967407, -168.095001221, 4000).
airport('KFP', 'False Pass Airport', 20, 54.8474006652832, -163.410003662109, 2100).
airport('AKK', 'Akhiok Airport', 44, 56.9387016296, -154.182998657, 3120).
airport('KPN', 'Kipnuk Airport', 11, 59.9329986572, -164.031005859, 2120).
airport('KKA', 'Koyuk Alfred Adams Airport', 154, 64.9394989014, -161.154006958, 3000).
airport('AKP', 'Anaktuvuk Pass Airport', 2102, 68.13359833, -151.7429962, 4800).
airport('KLW', 'Klawock Airport', 80, 55.5792007446, -133.076004028, 5000).
airport('KLN', 'Larsen Bay Airport', 87, 57.5350990295, -153.977996826, 2690).
airport('KLG', 'Kalskag Airport', 55, 61.5363006591797, -160.341003417969, 3172).
airport('SMK', 'St Michael Airport', 98, 63.49010086, -162.1100006, 4001).
airport('MLY', 'Manley Hot Springs Airport', 270, 64.9975967407, -150.643997192, 2875).
airport('MOU', 'Mountain Village Airport', 337, 62.095401763916, -163.682006835938, 3500).
airport('WNA', 'Napakiak Airport', 17, 60.690299987793, -161.97900390625, 3248).
airport('HNH', 'Hoonah Airport', 19, 58.0960998535156, -135.410003662109, 2997).
airport('OOK', 'Toksook Bay Airport', 59, 60.54140091, -165.0870056, 3218).
airport('PSG', 'Petersburg James A Johnson Airport', 111, 56.80170059, -132.9450073, 6000).
airport('PIP', 'Pilot Point Airport', 57, 57.5803985596, -157.572006226, 3280).
airport('PHO', 'Point Hope Airport', 12, 68.3488006591797, -166.79899597168, 4000).
airport('KWN', 'Quinhagak Airport', 42, 59.75510025, -161.8450012, 4000).
airport('NUI', 'Nuiqsut Airport', 38, 70.2099990845, -151.005996704, 4343).
airport('RBY', 'Ruby Airport', 658, 64.72720337, -155.4700012, 4000).
airport('SVA', 'Savoonga Airport', 53, 63.6864013671875, -170.49299621582, 4400).
airport('SHH', 'Shishmaref Airport', 12, 66.2496032714844, -166.089004516602, 5000).
airport('SIT', 'Sitka Rocky Gutierrez Airport', 21, 57.0471000671387, -135.361999511719, 6500).
airport('WLK', 'Selawik Airport', 17, 66.60009766, -159.9859924, 3002).
airport('WLK', 'Selawik Airport', 17, 66.60009766, -159.9859924, 2502).
airport('TAL', 'Ralph M Calhoun Memorial Airport', 236, 65.1744003296, -152.10899353, 4400).
airport('TNC', 'Tin City Long Range Radar Station Airport', 271, 65.56310272, -167.9219971, 4700).
airport('TLA', 'Teller Airport', 294, 65.2404022217, -166.339004517, 3000).
airport('ATK', 'Atqasuk Edward Burnell Sr Memorial Airport', 96, 70.4673004150391, -157.436004638672, 4370).
airport('VAK', 'Chevak Airport', 75, 61.5409, -165.6005, 3200).
airport('VAK', 'Chevak Airport', 75, 61.5409, -165.6005, 2700).
airport('KVC', 'King Cove Airport', 155, 55.1162986755371, -162.266006469727, 3500).
airport('KVL', 'Kivalina Airport', 13, 67.736198425293, -164.563003540039, 3000).
airport('WBQ', 'Beaver Airport', 359, 66.362197876, -147.406997681, 3954).
airport('WRG', 'Wrangell Airport', 49, 56.48429871, -132.3699951, 5999).
airport('AIN', 'Wainwright Airport', 41, 70.6380004883, -159.994995117, 4494).
airport('WMO', 'White Mountain Airport', 267, 64.689201355, -163.412994385, 3000).
airport('WTK', 'Noatak Airport', 88, 67.5661010742188, -162.975006103516, 4000).
airport('YAK', 'Yakutat Airport', 33, 59.5032997131, -139.660003662, 7745).
airport('YAK', 'Yakutat Airport', 33, 59.5032997131, -139.660003662, 7245).
airport('AET', 'Allakaket Airport', 441, 66.5518035889, -152.621994019, 4000).
airport('ELI', 'Elim Airport', 162, 64.61470032, -162.2720032, 3401).
airport('KUK', 'Kasigluk Airport', 48, 60.87440109, -162.5240021, 3000).
airport('KOT', 'Kotlik Airport', 15, 63.0306015015, -163.533004761, 4422).
airport('KTS', 'Brevig Mission Airport', 38, 65.3312988281, -166.466003418, 2990).
airport('KTS', 'Brevig Mission Airport', 38, 65.3312988281, -166.466003418, 2490).
airport('KWT', 'Kwethluk Airport', 25, 60.7902984619, -161.444000244, 3198).
airport('ORV', 'Robert (Bob) Curtis Memorial Airport', 55, 66.81790161, -161.0189972, 4000).
airport('SKK', 'Shaktoolik Airport', 24, 64.37110138, -161.223999, 4001).
airport('WSN', 'South Naknek Nr 2 Airport', 162, 58.7033996582, -157.007995605, 3314).
airport('WSN', 'South Naknek Nr 2 Airport', 162, 58.7033996582, -157.007995605, 2814).
airport('FYU', 'Fort Yukon Airport', 433, 66.5715026855469, -145.25, 5810).
airport('TFI', 'Tufi Airport', 85, -9.07595443726, 149.319839478, 2623).
airport('ROP', 'Rota International Airport', 607, 14.1743001937866, 145.24299621582, 6000).
airport('CHG', 'Chaoyang Airport', 173, 41.5381011962891, 120.434997558594, 6562).
airport('HNM', 'Hana Airport', 78, 20.7956008911133, -156.014007568359, 3606).
airport('MUE', 'Waimea Kohala Airport', 2671, 20.0013008117676, -155.667999267578, 5197).
airport('KWA', 'Bucholz Army Air Field', 9, 8.72012042999268, 167.731994628906, 6668).
airport('PIZ', 'Point Lay LRRS Airport', 22, 69.73290253, -163.0050049, 3519).
airport('TKK', 'Chuuk International Airport', 11, 7.46187019348145, 151.843002319336, 6006).
airport('YAP', 'Yap International Airport', 91, 9.49890995025635, 138.082992553711, 6000).
airport('KNH', 'Kinmen Airport', 93, 24.4279003143311, 118.359001159668, 9865).
airport('TTT', 'Taitung Airport', 143, 22.7549991607666, 121.101997375488, 7999).
airport('MZG', 'Makung Airport', 103, 23.5687007904053, 119.627998352051, 9843).
airport('HUN', 'Hualien Airport', 52, 24.023099899292, 121.61799621582, 9022).
airport('HUN', 'Hualien Airport', 52, 24.023099899292, 121.61799621582, 8522).
airport('HUN', 'Hualien Airport', 52, 24.023099899292, 121.61799621582, 8022).
airport('MMJ', 'Matsumoto Airport', 2182, 36.1668014526367, 137.923004150391, 6560).
airport('IBR', 'Hyakuri Airport', 105, 36.181098938, 140.414993286, 8860).
airport('IKI', 'Iki Airport', 41, 33.7490005493, 129.785003662, 4331).
airport('TSJ', 'Tsushima Airport', 213, 34.2849006653, 129.330993652, 6234).
airport('FUJ', 'Fukue Airport', 273, 32.6663017272949, 128.832992553711, 6561).
airport('NKM', 'Nagoya Airport', 52, 35.2550010681152, 136.92399597168, 8990).
airport('FSZ', 'Mt. Fuji Shizuoka Airport', 433, 34.7960434679, 138.18775177, 8202).
airport('FKS', 'Fukushima Airport', 1221, 37.2274017333984, 140.430999755859, 8202).
airport('HNA', 'Hanamaki Airport', 297, 39.4286003112793, 141.134994506836, 8202).
airport('KWJ', 'Gwangju Airport', 39, 35.1263999939, 126.808998108, 9300).
airport('KWJ', 'Gwangju Airport', 39, 35.1263999939, 126.808998108, 8800).
airport('KUV', 'Kunsan Air Base', 29, 35.9038009643555, 126.615997314453, 9000).
airport('RSU', 'Yeosu Airport', 53, 34.8423004150391, 127.616996765137, 6890).
airport('WJU', 'Wonju Airport', 329, 37.4380989075, 127.959999084, 9000).
airport('YNY', 'Yangyang International Airport', 241, 38.0612983703613, 128.669006347656, 8202).
airport('HIN', 'Sacheon Air Base', 25, 35.0885009765625, 128.070007324219, 9000).
airport('HIN', 'Sacheon Air Base', 25, 35.0885009765625, 128.070007324219, 8500).
airport('USN', 'Ulsan Airport', 45, 35.59349823, 129.352005005, 6561).
airport('KPO', 'Pohang Airport', 70, 35.9878997803, 129.419998169, 7000).
airport('RMP', 'Rampart Airport', 302, 65.5078964233398, -150.141006469727, 3520).
airport('UEO', 'Kumejima Airport', 23, 26.3635005950928, 126.713996887207, 6562).
airport('LAO', 'Laoag International Airport', 25, 18.1781005859375, 120.531997680664, 9120).
airport('LGP', 'Legazpi City International Airport', 66, 13.1575, 123.735, 7480).
airport('CBO', 'Awang Airport', 189, 7.1652398109436, 124.209999084473, 6234).
airport('BXU', 'Bancasi Airport', 141, 8.9515, 125.4788, 6450).
airport('DPL', 'Dipolog Airport', 12, 8.60198349877, 123.341875076, 6273).
airport('CGM', 'Camiguin Airport', 53, 9.25352001190186, 124.707000732422, 3945).
airport('CGY', 'Cagayan De Oro Airport', 601, 8.41561985016, 124.611000061, 8050).
airport('OZC', 'Labo Airport', 75, 8.17850971221924, 123.842002868652, 5720).
airport('PAG', 'Pagadian Airport', 5, 7.83073144787, 123.461179733, 5512).
airport('GES', 'General Santos International Airport', 505, 6.05800008774, 125.096000671, 10587).
airport('SUG', 'Surigao Airport', 20, 9.75583832563, 125.480947495, 5603).
airport('ZAM', 'Zamboanga International Airport', 33, 6.92242002487183, 122.059997558594, 8560).
airport('IAO', 'Siargao Airport', 10, 9.8591003418, 126.013999939, 4167).
airport('SJI', 'San Jose Airport', 14, 12.3614997864, 121.04699707, 6024).
airport('WNP', 'Naga Airport', 142, 13.5848999023438, 123.269996643066, 4599).
airport('BSO', 'Basco Airport', 291, 20.4512996674, 121.980003357, 4101).
airport('TUG', 'Tuguegarao Airport', 70, 17.6433676823, 121.733150482, 6455).
airport('VRC', 'Virac Airport', 121, 13.5763998031616, 124.206001281738, 5118).
airport('CYZ', 'Cauayan Airport', 200, 16.9298992157, 121.752998352, 6890).
airport('TAC', 'Daniel Z. Romualdez Airport', 10, 11.2276000977, 125.027999878, 7014).
airport('BCD', 'Bacolod-Silay City International Airport', 25, 10.7763996124268, 123.014999389648, 6416).
airport('CYP', 'Calbayog Airport', 12, 12.072699546814, 124.544998168945, 4843).
airport('DGT', 'Sibulan Airport', 15, 9.3337097168, 123.300003052, 6136).
airport('MPH', 'Malay, Godofredo P. Ramos Airport', 7, 11.9245004654, 121.95400238, 3117).
airport('CRM', 'Catarman National Airport', 6, 12.5024003982544, 124.636001586914, 4429).
airport('MBT', 'Moises R. Espinosa Airport', 26, 12.3694000244, 123.628997803, 4921).
airport('PPS', 'Puerto Princesa Airport', 71, 9.74211978912354, 118.759002685547, 8530).
airport('RXS', 'Roxas Airport', 10, 11.5977001190186, 122.751998901367, 6201).
airport('TAG', 'Tagbilaran Airport', 38, 9.6640796661377, 123.852996826172, 5837).
airport('USU', 'Francisco B. Reyes Airport', 148, 12.1215000153, 120.099998474, 3300).
airport('NGK', 'Nogliki Airport', 98, 51.7801017761, 143.139007568, 5741).
airport('GRV', 'Grozny North Airport', 544, 43.3883018493652, 45.698600769043, 8202).
airport('VUS', 'Velikiy Ustyug Airport', 331, 60.7882995605469, 46.2599983215332, 4199).
airport('PRA', 'General Urquiza Airport', 242, -31.7948, -60.4804, 6890).
airport('SFN', 'Sauce Viejo Airport', 55, -31.7117, -60.8117, 7628).
airport('AFA', 'Suboficial Ay Santiago Germano Airport', 2470, -34.5882987976, -68.4039001465, 6923).
airport('CTC', 'Catamarca Airport', 1522, -28.5956001282, -65.751701355, 9186).
airport('SDE', 'Vicecomodoro Angel D. La Paz Aragonés Airport', 656, -27.7655563354, -64.3099975586, 7946).
airport('RHD', 'Las Termas Airport', 1130, -27.4736995697, -64.9055023193, 8197).
airport('IRJ', 'Capitan V A Almonacid Airport', 1437, -29.3815994263, -66.7957992554, 9383).
airport('TUC', 'Teniente Benjamin Matienzo Airport', 1493, -26.8409004211, -65.1048965454, 9514).
airport('UAQ', 'Domingo Faustino Sarmiento Airport', 1958, -31.5715007782, -68.4181976318, 8071).
airport('LUQ', 'Brigadier Mayor D Cesar Raul Ojeda Airport', 2328, -33.2732009888, -66.3563995361, 9678).
airport('RES', 'Resistencia International Airport', 173, -27.45, -59.0561, 9088).
airport('FMA', 'Formosa Airport', 193, -26.2127, -58.2281, 5905).
airport('PSS', 'Libertador Gral D Jose De San Martin Airport', 430, -27.3858, -55.9707, 7218).
airport('SLA', 'Martin Miguel De Guemes International Airport', 4088, -24.8560009003, -65.4861984253, 9842).
airport('SLA', 'Martin Miguel De Guemes International Airport', 4088, -24.8560009003, -65.4861984253, 9342).
airport('JUJ', 'Gobernador Horacio Guzman International Airport', 3019, -24.3927993774, -65.0978012085, 9698).
airport('CRD', 'General E. Mosconi Airport', 189, -45.7853, -67.4655, 9219).
airport('EQS', 'Brigadier Antonio Parodi Airport', 2621, -42.908000946, -71.139503479, 7874).
airport('EQS', 'Brigadier Antonio Parodi Airport', 2621, -42.908000946, -71.139503479, 7374).
airport('VDM', 'Gobernador Castello Airport', 20, -40.8692, -63.0004, 8366).
airport('VDM', 'Gobernador Castello Airport', 20, -40.8692, -63.0004, 7866).
airport('PMY', 'El Tehuelche Airport', 427, -42.7592, -65.1027, 8202).
airport('RGA', 'Hermes Quijada International Airport', 65, -53.7777, -67.7494, 6562).
airport('RGL', 'Piloto Civil N. Fernández Airport', 61, -51.6089, -69.3126, 11644).
airport('BHI', 'Comandante Espora Airport', 246, -38.725, -62.1693, 8579).
airport('BHI', 'Comandante Espora Airport', 246, -38.725, -62.1693, 8079).
airport('BHI', 'Comandante Espora Airport', 246, -38.725, -62.1693, 7579).
airport('MDQ', 'Ástor Piazzola International Airport', 72, -37.9342, -57.5733, 7218).
airport('NQN', 'Presidente Peron Airport', 895, -38.9490013123, -68.1557006836, 8432).
airport('RSA', 'Santa Rosa Airport', 630, -36.5882987976, -64.2757034302, 7546).
airport('CPC', 'Aviador C. Campos Airport', 2569, -40.0754013062, -71.137298584, 8202).
airport('AQA', 'Araraquara Airport', 2334, -21.8120002747, -48.1329994202, 5907).
airport('AFL', 'Alta Floresta Airport', 948, -9.8663892746, -56.1049995422, 8202).
airport('AAX', 'Araxá Airport', 3276, -19.5631999969482, -46.9603996276855, 6234).
airport('BVB', 'Atlas Brasil Cantanhede Airport', 276, 2.84138894081, -60.6922225952, 8858).
airport('CFB', 'Cabo Frio Airport', 23, -22.9216995239, -42.0742988586, 8366).
airport('CFC', 'Caçador Airport', 3376, -26.78840065, -50.9398002625, 5331).
airport('XAP', 'Chapecó Airport', 2146, -27.1341991424561, -52.6566009521484, 6768).
airport('CKS', 'Carajás Airport', 2064, -6.11527776718, -50.0013885498, 6562).
airport('CCM', 'Diomício Freitas Airport', 93, -28.7244434357, -49.4213905334, 4882).
airport('CLV', 'Caldas Novas Airport', 2247, -17.7252998352051, -48.6074981689453, 6890).
airport('CAW', 'Bartolomeu Lisandro Airport', 57, -21.698299408, -41.301700592, 5066).
airport('CMG', 'Corumbá International Airport', 461, -19.0119438171, -57.6713905334, 5446).
airport('CXJ', 'Hugo Cantergiani Regional Airport', 2472, -29.1970996857, -51.1875, 5479).
airport('BYO', 'Bonito Airport', 1180, -21.2473, -56.4525, 6562).
airport('PPB', 'Presidente Prudente Airport', 1477, -22.1751003265, -51.4245986938, 6923).
airport('FEN', 'Fernando de Noronha Airport', 193, -3.85492992401123, -32.4233016967773, 6053).
airport('GPB', 'Tancredo Thomas de Faria Airport', 3494, -25.3875007629, -51.520198822, 5315).
airport('GVR', 'Governador Valadares Airport', 561, -18.8952007293701, -41.9822006225586, 4593).
airport('ATM', 'Altamira Airport', 369, -3.25391006469727, -52.2540016174316, 6572).
airport('IMP', 'Prefeito Renato Moreira Airport', 432, -5.53129005432129, -47.4599990844727, 5899).
airport('CPV', 'Presidente João Suassuna Airport', 1646, -7.26991987228394, -35.8964004516602, 5249).
airport('LEC', 'Chapada Diamantina Airport', 1676, -12.4822998047, -41.2770004272, 6831).
airport('LAZ', 'Bom Jesus da Lapa Airport', 1454, -13.2621002197, -43.4081001282, 3973).
airport('MAB', 'João Correa da Rocha Airport', 357, -5.36858987808, -49.1380004883, 6562).
airport('MEU', 'Monte Dourado Airport', 677, -0.889838993549, -52.6021995544, 5906).
airport('MEA', 'Macaé Airport', 8, -22.343000412, -41.7659988403, 3937).
airport('MOC', 'Mário Ribeiro Airport', 2191, -16.7068996429, -43.818901062, 6890).
airport('MII', 'Marília Airport', 2122, -22.1968994141, -49.926399231, 4921).
airport('MCP', 'Alberto Alcolumbre Airport', 56, 0.0506640002131, -51.0722007751, 6890).
airport('PHB', 'Prefeito Doutor João Silva Filho Airport', 16, -2.89374995232, -41.7319984436, 6890).
airport('PMW', 'Brigadeiro Lysias Rodrigues Airport', 774, -10.2915000916, -48.3569984436, 8202).
airport('PET', 'Pelotas Airport', 59, -31.7183990478516, -52.3277015686035, 6496).
airport('PET', 'Pelotas Airport', 59, -31.7183990478516, -52.3277015686035, 5996).
airport('PNZ', 'Senador Nilo Coelho Airport', 1263, -9.3624095916748, -40.5690994262695, 9055).
airport('PVH', 'Governador Jorge Teixeira de Oliveira Airport', 290, -8.70928955078125, -63.9023017883301, 7874).
airport('RBR', 'Plácido de Castro Airport', 633, -9.86888885498047, -67.8980560302734, 7080).
airport('SJK', 'Professor Urbano Ernesto Stumpf Airport', 2120, -23.2292003631592, -45.861499786377, 8780).
airport('RIA', 'Santa Maria Airport', 287, -29.7113990783691, -53.6882019042969, 8858).
airport('RIA', 'Santa Maria Airport', 287, -29.7113990783691, -53.6882019042969, 8358).
airport('STM', 'Maestro Wilson Fonseca Airport', 198, -2.42472195625305, -54.785831451416, 7874).
airport('TFF', 'Tefé Airport', 188, -3.38294005394, -64.7240982056, 7218).
airport('TBT', 'Tabatinga Airport', 279, -4.25567007064819, -69.9357986450195, 7054).
airport('PAV', 'Paulo Afonso Airport', 883, -9.40087985992432, -38.2505989074707, 5906).
airport('BVH', 'Vilhena Airport', 2018, -12.6943998336792, -60.0983009338379, 8530).
airport('IZA', 'Zona da Mata Regional Airport', 1348, -21.5130558014, -43.1730575562, 8284).
airport('MHC', 'Mocopulli Airport', 528, -42.340388, -73.715693, 6562).
airport('AOG', 'Anshan Air Base', 46, 41.1053009033203, 122.853996276855, 8530).
airport('OCC', 'Francisco De Orellana Airport', 834, -0.46288600564003, -76.9868011474609, 6760).
airport('CUE', 'Mariscal Lamar Airport', 8306, -2.88947010040283, -78.9843978881836, 6234).
airport('GPS', 'Seymour Airport', 207, -0.453758001327515, -90.2658996582031, 7876).
airport('LTX', 'Cotopaxi International Airport', 9205, -0.906832993031, -78.6157989502, 12117).
airport('XMS', 'Coronel E Carvajal Airport', 3452, -2.29917001724243, -78.1207962036133, 8202).
airport('MEC', 'Eloy Alfaro International Airport', 48, -0.94607800245285, -80.6788024902344, 9383).
airport('LGQ', 'Nueva Loja Airport', 980, 0.0930560007691, -76.8675003052, 7546).
airport('ETR', 'Coronel Artilleria Victor Larrea Airport', 170, -3.43515992165, -79.9777984619, 3255).
airport('SCY', 'San Cristóbal Airport', 62, -0.910206019878387, -89.6174011230469, 6214).
airport('LOH', 'Camilo Ponce Enriquez Airport', 4056, -3.99588990211487, -79.3719024658203, 6725).
airport('ESM', 'General Rivadeneira Airport', 32, 0.978519022464752, -79.6266021728516, 7874).
airport('TUA', 'Teniente Coronel Luis a Mantilla Airport', 9649, 0.809505999088287, -77.7080993652344, 8071).
airport('JTC', 'Bauru - Arealva Airport', 1949, -22.1668591409, -49.0502866745, 6594).
airport('PUU', 'Tres De Mayo Airport', 815, 0.505228, -76.5008, 5331).
airport('PUU', 'Tres De Mayo Airport', 815, 0.505228, -76.5008, 4831).
airport('BGA', 'Palonegro Airport', 3897, 7.1265, -73.1848, 7381).
airport('BUN', 'Gerardo Tobar López Airport', 48, 3.81963, -76.9898, 3945).
airport('CUC', 'Camilo Daza International Airport', 1096, 7.92757, -72.5115, 7700).
airport('CUC', 'Camilo Daza International Airport', 1096, 7.92757, -72.5115, 7200).
airport('TCO', 'La Florida Airport', 8, 1.81442, -78.7492, 5249).
airport('CZU', 'Las Brujas Airport', 528, 9.33274, -75.2856, 4930).
airport('EJA', 'Yariguíes Airport', 412, 7.02433, -73.8068, 5905).
airport('FLA', 'Gustavo Artunduaga Paredes Airport', 803, 1.58919, -75.5644, 4921).
airport('GPI', 'Juan Casiano Airport', 164, 2.57013, -77.8986, 4256).
airport('IBE', 'Perales Airport', 2999, 4.42161, -75.1333, 5905).
airport('IPI', 'San Luis Airport', 9765, 0.861925, -77.6718, 5774).
airport('APO', 'Antonio Roldan Betancourt Airport', 46, 7.81196, -76.7164, 7153).
airport('LET', 'Alfredo Vásquez Cobo International Airport', 277, -4.19355, -69.9432, 6168).
airport('EOH', 'Enrique Olaya Herrera Airport', 4949, 6.220549, -75.590582, 8202).
airport('MTR', 'Los Garzones Airport', 36, 8.82374, -75.8258, 6285).
airport('MVP', 'Fabio Alberto Leon Bentley Airport', 680, 1.25366, -70.2339, 5889).
airport('MZL', 'La Nubia Airport', 6871, 5.0296, -75.4647, 4835).
airport('MZL', 'La Nubia Airport', 6871, 5.0296, -75.4647, 4335).
airport('NVA', 'Benito Salas Airport', 1464, 2.95015, -75.294, 5880).
airport('PCR', 'German Olano Airport', 177, 6.18472, -67.4932, 5907).
airport('PDA', 'Obando Airport', 460, 3.85353, -67.9062, 5910).
airport('PEI', 'Matecaña International Airport', 4416, 4.81267, -75.7395, 6627).
airport('PPN', 'Guillermo León Valencia Airport', 5687, 2.4544, -76.6093, 6266).
airport('PSO', 'Antonio Narino Airport', 5951, 1.39625, -77.2915, 7585).
airport('RCH', 'Almirante Padilla Airport', 43, 11.5262, -72.926, 5413).
airport('RCH', 'Almirante Padilla Airport', 43, 11.5262, -72.926, 4913).
airport('SJE', 'Jorge E. Gonzalez Torres Airport', 605, 2.57969, -72.6394, 4897).
airport('SMR', 'Simón Bolívar International Airport', 22, 11.1196, -74.2306, 5577).
airport('ADZ', 'Gustavo Rojas Pinilla International Airport', 19, 12.5836, -81.7112, 7808).
airport('SVI', 'Eduardo Falla Solano Airport', 920, 2.15217, -74.7663, 4921).
airport('SVI', 'Eduardo Falla Solano Airport', 920, 2.15217, -74.7663, 4421).
airport('TME', 'Gustavo Vargas Airport', 1050, 6.45108, -71.7603, 6561).
airport('AUC', 'Santiago Perez Airport', 420, 7.06888, -70.7369, 6890).
airport('UIB', 'El Caraño Airport', 204, 5.69076, -76.6412, 4593).
airport('VUP', 'Alfonso López Pumarejo Airport', 483, 10.435, -73.2495, 6890).
airport('VVC', 'Vanguardia Airport', 1394, 4.16787, -73.6138, 5616).
airport('EYP', 'El Yopal Airport', 1028, 5.31911, -72.384, 8448).
airport('CIJ', 'Capitán Aníbal Arab Airport', 889, -11.0403995514, -68.7829971313, 6562).
airport('SRZ', 'El Trompillo Airport', 1371, -17.8115997314, -63.1715011597, 9144).
airport('POI', 'Capitan Nicolas Rojas Airport', 12913, -19.5431003571, -65.7237014771, 9130).
airport('SRE', 'Juana Azurduy De Padilla Airport', 9540, -19.0070991516113, -65.2886962890625, 9300).
airport('TJA', 'Capitan Oriel Lea Plaza Airport', 6079, -21.5557003021, -64.7013015747, 10007).
airport('TDD', 'Teniente Av. Jorge Henrich Arauz Airport', 509, -14.8186998367, -64.9179992676, 7874).
airport('UYU', 'Uyuni Airport', 12972, -20.4463005066, -66.8483963013, 13123).
airport('BRA', 'Barreiras Airport', 2447, -12.0789003372192, -45.0089988708496, 5249).
airport('POJ', 'Patos de Minas Airport', 2793, -18.6728000640869, -46.4911994934082, 5577).
airport('BVS', 'Breves Airport', 98, -1.63653004169464, -50.4435997009277, 5249).
airport('ERM', 'Erechim Airport', 2498, -27.6618995666504, -52.2682991027832, 4199).
airport('JCB', 'Santa Terezinha Airport', 2546, -27.1714000702, -51.5532989502, 4134).
airport('OAL', 'Cacoal Airport', 778, -11.496, -61.4508, 6890).
airport('SRA', 'Santa Rosa Airport', 984, -27.9067001342773, -54.5204010009766, 3937).
airport('PDP', 'Capitan Corbeta CA Curbelo International Airport', 95, -34.8550987243652, -55.0942993164062, 6998).
airport('PDP', 'Capitan Corbeta CA Curbelo International Airport', 95, -34.8550987243652, -55.0942993164062, 6498).
airport('BNS', 'Barinas Airport', 666, 8.61956977844238, -70.2208023071289, 6560).
airport('BNS', 'Barinas Airport', 666, 8.61956977844238, -70.2208023071289, 6060).
airport('BRM', 'Barquisimeto International Airport', 2042, 10.0427465438843, -69.3586196899414, 9350).
airport('CZE', 'José Leonardo Chirinos Airport', 52, 11.4149436950684, -69.6809005737305, 6761).
airport('CUM', 'Cumaná (Antonio José de Sucre) Airport', 14, 10.4503326416016, -64.1304702758789, 10171).
airport('LSP', 'Josefa Camejo International Airport', 75, 11.7807750701904, -70.151496887207, 9186).
airport('LFR', 'La Fria Airport', 305, 8.23916721343994, -72.2710266113281, 6643).
airport('LFR', 'La Fria Airport', 305, 8.23916721343994, -72.2710266113281, 6143).
airport('MRD', 'Alberto Carnevalli Airport', 5007, 8.5820779800415, -71.1610412597656, 5348).
airport('PMV', 'Del Caribe Santiago Mariño International Airport', 74, 10.9126033782959, -63.9665985107422, 10499).
airport('PMV', 'Del Caribe Santiago Mariño International Airport', 74, 10.9126033782959, -63.9665985107422, 9999).
airport('MUN', 'Maturín Airport', 224, 9.75452995300293, -63.1473999023438, 6890).
airport('CBS', 'Oro Negro Airport', 164, 10.3306999206543, -71.3225021362305, 6160).
airport('PYH', 'Cacique Aramare Airport', 245, 5.61998987197876, -67.6061019897461, 8272).
airport('PBL', 'General Bartolome Salom International Airport', 32, 10.4805002212524, -68.072998046875, 6970).
airport('PZO', 'General Manuel Carlos Piar International Airport', 472, 8.28853034973145, -62.7603988647461, 6726).
airport('SVS', 'Stevens Village Airport', 329, 66.0090026855, -149.095993042, 4000).
airport('SVZ', 'Juan Vicente Gomez International Airport', 1312, 7.84082984924316, -72.439697265625, 6135).
airport('STD', 'Mayor Buenaventura Vivas International Airport', 1083, 7.56538009643555, -72.0351028442383, 9990).
airport('SOM', 'San Tome Airport', 861, 8.94514656066895, -64.1510848999023, 6299).
airport('SOM', 'San Tome Airport', 861, 8.94514656066895, -64.1510848999023, 5799).
airport('VLN', 'Arturo Michelena International Airport', 1411, 10.1497325897217, -67.9283981323242, 9842).
airport('VIG', 'Juan Pablo Pérez Alfonso Airport', 250, 8.62413883209229, -71.6726684570312, 10645).
airport('VLV', 'Dr. Antonio Nicolás Briceño Airport', 2060, 9.34047794342041, -70.5840606689453, 6791).
airport('BAZ', 'Barcelos Airport', 112, -0.981292009353638, -62.9196014404297, 3937).
airport('AUX', 'Araguaína Airport', 771, -7.22786998748779, -48.2405014038086, 5919).
airport('JPR', 'Ji-Paraná Airport', 594, -10.8708000183, -61.8465003967, 5905).
airport('CIZ', 'Coari Airport', 131, -4.13405990600586, -63.1325988769531, 5249).
airport('RVD', 'General Leite de Castro Airport', 2464, -17.8347225189209, -50.956111907959, 4921).
airport('PIN', 'Parintins Airport', 87, -2.67301988601685, -56.7771987915039, 5906).
airport('ROO', 'Rondonópolis Airport', 1467, -16.5860004425049, -54.7248001098633, 6070).
airport('OPS', 'Presidente João Batista Figueiredo Airport', 1227, -11.8850002288818, -55.586109161377, 5348).
airport('SXP', 'Sheldon Point Airport', 12, 62.5205993652344, -164.848007202148, 3015).
airport('OGL', 'Ogle Airport', 10, 6.80628013611, -58.1058998108, 4000).
airport('TCT', 'Takotna Airport', 423, 62.9926986694, -156.067993164, 3300).
airport('SFG', "L'Espérance Airport", 7, 18.0998992919922, -63.0471992492676, 3937).
airport('SLU', 'George F. L. Charles Airport', 22, 14.0202, -60.992901, 5735).
airport('TLT', 'Tuluksak Airport', 30, 61.0968017578, -160.968994141, 3300).
airport('EUX', 'F. D. Roosevelt Airport', 129, 17.4965000152588, -62.9794006347656, 4265).
airport('SAB', 'Juancho E. Yrausquin Airport', 60, 17.6450004577637, -63.2200012207031, 1300).
airport('BGG', 'Bingöl Çeltiksuyu Airport', 3474, 38.8592605591, 40.5959625244, 7546).
airport('IGD', 'Iğdır Airport', 3101, 39.9766273499, 43.8766479492, 9843).
airport('SVD', 'E. T. Joshua Airport', 66, 13.1443004608154, -61.2108993530273, 4595).
airport('KOV', 'Kokshetau Airport', 900, 53.3291015625, 69.594596862793, 8325).
airport('PPK', 'Petropavlosk South Airport', 453, 54.7747001647949, 69.1838989257812, 8190).
airport('DMB', 'Taraz Airport', 2184, 42.8535995483398, 71.303596496582, 9514).
airport('OSS', 'Osh Airport', 2927, 40.6090011597, 72.793296814, 9232).
airport('CIT', 'Shymkent Airport', 1385, 42.364200592041, 69.4788970947266, 9186).
airport('JNZ', 'Jinzhou Airport', 1, 41.1013984680176, 121.061996459961, 8202).
airport('KGF', 'Sary-Arka Airport', 1765, 49.6707992553711, 73.3343963623047, 10831).
airport('KZO', 'Kzyl-Orda Southwest Airport', 433, 44.706901550293, 65.5924987792969, 8858).
airport('URA', 'Uralsk Airport', 125, 51.1507987976074, 51.543098449707, 7874).
airport('UKK', 'Ust-Kamennogorsk Airport', 939, 50.0365982055664, 82.4942016601562, 8234).
airport('UKK', 'Ust-Kamennogorsk Airport', 939, 50.0365982055664, 82.4942016601562, 7734).
airport('PWQ', 'Pavlodar Airport', 410, 52.1949996948242, 77.0738983154297, 8202).
airport('SCO', 'Aktau Airport', 73, 43.8600997924805, 51.0919990539551, 9630).
airport('SCO', 'Aktau Airport', 73, 43.8600997924805, 51.0919990539551, 9130).
airport('AKX', 'Aktobe Airport', 738, 50.2458000183105, 57.2066993713379, 10160).
airport('KSN', 'Kostanay West Airport', 595, 53.206901550293, 63.5503005981445, 8150).
airport('KVD', 'Ganja Airport', 1083, 40.7377014160156, 46.3176002502441, 8217).
airport('LLK', 'Lankaran International Airport', 30, 38.7463989258, 48.8180007935, 5172).
airport('NAJ', 'Nakhchivan Airport', 2863, 39.1888008117676, 45.4584007263184, 10826).
airport('NAJ', 'Nakhchivan Airport', 2863, 39.1888008117676, 45.4584007263184, 10326).
airport('GBB', 'Gabala International Airport', 935, 40.8266666667, 47.7125, 11811).
airport('LWN', 'Gyumri Shirak Airport', 5000, 40.7504005432, 43.8592987061, 10564).
airport('ULK', 'Lensk Airport', 801, 60.7206001282, 114.825996399, 6562).
airport('ULK', 'Lensk Airport', 801, 60.7206001282, 114.825996399, 6062).
airport('PYJ', 'Polyarny Airport', 1660, 66.4003982544, 112.029998779, 10170).
airport('MJZ', 'Mirny Airport', 1156, 62.5346984863281, 114.039001464844, 9187).
airport('CKH', 'Chokurdakh Airport', 151, 70.6231002807617, 147.901992797852, 6562).
airport('CYX', 'Cherskiy Airport', 20, 68.7406005859375, 161.337997436523, 5479).
airport('IKS', 'Tiksi Airport', 26, 71.6977005004883, 128.90299987793, 9845).
airport('KUT', 'Kopitnari Airport', 223, 42.176700592, 42.4826011658, 8202).
airport('BUS', 'Batumi International Airport', 105, 41.6102981567, 41.5997009277, 7325).
airport('BQS', 'Ignatyevo Airport', 638, 50.4253997802734, 127.412002563477, 9256).
airport('DYR', 'Ugolny Airport', 194, 64.7349014282227, 177.740997314453, 11483).
airport('GDX', 'Sokol Airport', 574, 59.9109992980957, 150.720001220703, 11326).
airport('PWE', 'Pevek Airport', 11, 69.7833023071289, 170.59700012207, 8202).
airport('PKC', 'Yelizovo Airport', 131, 53.1679000854492, 158.453994750977, 11155).
airport('PKC', 'Yelizovo Airport', 131, 53.1679000854492, 158.453994750977, 10655).
airport('PKC', 'Yelizovo Airport', 131, 53.1679000854492, 158.453994750977, 10155).
airport('BVV', 'Burevestnik Airport', 79, 44.9199981689, 147.621994019, 7808).
airport('OHH', 'Okha Airport', 115, 53.5200004578, 142.88999939, 4265).
airport('EKS', 'Shakhtyorsk Airport', 50, 49.1902999878, 142.082992554, 6601).
airport('DEE', 'Mendeleyevo Airport', 584, 43.9584007263, 145.682998657, 6955).
airport('HTA', 'Chita-Kadala Airport', 2272, 52.0262985229492, 113.305999755859, 9430).
airport('HTA', 'Chita-Kadala Airport', 2272, 52.0262985229492, 113.305999755859, 8930).
airport('BTK', 'Bratsk Airport', 1610, 56.3706016540527, 101.697998046875, 10368).
airport('ODO', 'Bodaybo Airport', 919, 57.8661003113, 114.242996216, 7530).
airport('KCK', 'Kirensk Airport', 840, 57.773, 108.064, 5118).
airport('UKX', 'Ust-Kut Airport', 2188, 56.8567008972168, 105.730003356934, 6562).
airport('OZH', 'Zaporizhzhia International Airport', 373, 47.867000579834, 35.3157005310059, 8210).
airport('UKS', 'Belbek Airport', 344, 44.688999176, 33.5709991455, 9865).
airport('SIP', 'Simferopol International Airport', 639, 45.0522003173828, 33.9751014709473, 12142).
airport('SIP', 'Simferopol International Airport', 639, 45.0522003173828, 33.9751014709473, 11642).
airport('IFO', 'Ivano-Frankivsk International Airport', 919, 48.8842010498047, 24.6861000061035, 8226).
airport('UDJ', 'Uzhhorod International Airport', 383, 48.6343002319336, 22.2633991241455, 6686).
airport('VIN', 'Vinnytsia/Gavyryshivka Airport', 961, 49.242531, 28.613778, 8202).
airport('ARH', 'Talagi Airport', 62, 64.6003036499023, 40.7167015075684, 8202).
airport('ULH', 'Majeed Bin Abdulaziz Airport', 2050, 26.48, 38.1288888889, 10007).
airport('KVK', 'Kirovsk-Apatity Airport', 515, 67.4633026123047, 33.5882987976074, 8189).
airport('MMK', 'Murmansk Airport', 266, 68.7817001342773, 32.7508010864258, 8202).
airport('PES', 'Petrozavodsk Airport', 151, 61.8852005004883, 34.1547012329102, 8202).
airport('KGD', 'Khrabrovo Airport', 42, 54.8899993896484, 20.5925998687744, 8202).
airport('ABA', 'Abakan Airport', 831, 53.7400016784668, 91.3850021362305, 10663).
airport('ABA', 'Abakan Airport', 831, 53.7400016784668, 91.3850021362305, 10163).
airport('ABA', 'Abakan Airport', 831, 53.7400016784668, 91.3850021362305, 9663).
airport('BAX', 'Barnaul Airport', 837, 53.3638000488281, 83.5384979248047, 9350).
airport('RGK', 'Gorno-Altaysk Airport', 965, 51.9667015076, 85.8332977295, 1640).
airport('KEJ', 'Kemerovo Airport', 863, 55.2700996398926, 86.1072006225586, 10499).
airport('KEJ', 'Kemerovo Airport', 863, 55.2700996398926, 86.1072006225586, 9999).
airport('KYZ', 'Kyzyl Airport', 2123, 51.6693992614746, 94.4005966186523, 8858).
airport('OMS', 'Omsk Central Airport', 311, 54.9669990539551, 73.3105010986328, 9435).
airport('OMS', 'Omsk Central Airport', 311, 54.9669990539551, 73.3105010986328, 8935).
airport('OMS', 'Omsk Central Airport', 311, 54.9669990539551, 73.3105010986328, 8435).
airport('TOF', 'Bogashevo Airport', 597, 56.380298614502, 85.2082977294922, 8202).
airport('NOZ', 'Spichenkovo Airport', 1024, 53.8114013671875, 86.877197265625, 8789).
airport('IAA', 'Igarka Airport', 82, 67.4372024536133, 86.6219024658203, 8245).
airport('NSK', 'Norilsk-Alykel Airport', 574, 69.3110961914062, 87.3321990966797, 11290).
airport('THX', 'Turukhansk Airport', 128, 65.797203064, 87.9353027344, 5906).
airport('AAQ', 'Anapa Airport', 174, 45.0021018981934, 37.3473014831543, 8202).
airport('GDZ', 'Gelendzhik Airport', 98, 44.5820926295, 38.0124807358, 10171).
airport('MCX', 'Uytash Airport', 12, 42.8167991638184, 47.6523017883301, 8688).
airport('MCX', 'Uytash Airport', 12, 42.8167991638184, 47.6523017883301, 8188).
airport('OGZ', 'Beslan Airport', 1673, 43.2051010132, 44.6066017151, 9843).
airport('STW', 'Stavropol Shpakovskoye Airport', 1486, 45.1091995239258, 42.1128005981445, 8631).
airport('TGK', 'Taganrog Yuzhny Airport', 118, 47.2000007629, 38.8499984741, 9052).
airport('AER', 'Sochi International Airport', 89, 43.4499015808105, 39.956600189209, 9482).
airport('AER', 'Sochi International Airport', 89, 43.4499015808105, 39.956600189209, 8982).
airport('ASF', 'Astrakhan Airport', -65, 46.2832984924, 48.0063018799, 8202).
airport('ASF', 'Astrakhan Airport', -65, 46.2832984924, 48.0063018799, 7702).
airport('ESL', 'Elista Airport', 501, 46.3739013671875, 44.3308982849121, 7555).
airport('ESL', 'Elista Airport', 501, 46.3739013671875, 44.3308982849121, 7055).
airport('MQF', 'Magnitogorsk International Airport', 1430, 53.3931007385254, 58.7556991577148, 10663).
airport('SLY', 'Salekhard Airport', 218, 66.5907974243164, 66.6110000610352, 8917).
airport('HMA', 'Khanty Mansiysk Airport', 76, 61.0284996032715, 69.0860977172852, 9180).
airport('NYA', 'Nyagan Airport', 361, 62.1100006103516, 65.6149978637695, 8301).
airport('OVS', 'Sovetskiy Airport', 351, 61.3266220092773, 63.6019134521484, 8209).
airport('URJ', 'Uray Airport', 190, 60.1032981872559, 64.8266983032227, 7456).
airport('EYK', 'Beloyarskiy Airport', 82, 63.6869010925, 66.698600769, 7028).
airport('IJK', 'Izhevsk Airport', 531, 56.8280982971191, 53.4575004577637, 8202).
airport('KVX', 'Pobedilovo Airport', 479, 58.5032997131348, 49.3483009338379, 7228).
airport('NYM', 'Nadym Airport', 49, 65.4809036254883, 72.6988983154297, 8711).
airport('NUX', 'Novy Urengoy Airport', 210, 66.0693969726562, 76.5203018188477, 8366).
airport('NJC', 'Nizhnevartovsk Airport', 177, 60.9492988586426, 76.4835968017578, 10499).
airport('KGP', 'Kogalym International Airport', 220, 62.1903991699219, 74.5337982177734, 8225).
airport('NOJ', 'Noyabrsk Airport', 446, 63.1833000183105, 75.2699966430664, 8222).
airport('SGC', 'Surgut Airport', 200, 61.3437004089355, 73.4018020629883, 9154).
airport('TJM', 'Roshchino International Airport', 378, 57.1896018982, 65.3243026733, 9852).
airport('TJM', 'Roshchino International Airport', 378, 57.1896018982, 65.3243026733, 9352).
airport('KRO', 'Kurgan Airport', 240, 55.4752998352051, 65.4156036376953, 8533).
airport('TJU', 'Kulob Airport', 2293, 37.9880981445312, 69.8050003051758, 9843).
airport('LBD', 'Khudzhand Airport', 1450, 40.2154006958008, 69.6947021484375, 10450).
airport('KQT', 'Qurghonteppa International Airport', 1473, 37.8664016723633, 68.8647003173828, 7497).
airport('AZN', 'Andizhan Airport', 1515, 40.7276992798, 72.2939987183, 9770).
airport('FEG', 'Fergana International Airport', 1980, 40.3587989807, 71.7450027466, 9383).
airport('NMA', 'Namangan Airport', 1555, 40.9846000671, 71.5567016602, 10698).
airport('NCU', 'Nukus Airport', 246, 42.4883995056152, 59.6232986450195, 9175).
airport('NCU', 'Nukus Airport', 246, 42.4883995056152, 59.6232986450195, 8675).
airport('NVI', 'Navoi Airport', 11420, 40.1171989440918, 65.1707992553711, 9186).
airport('BHK', 'Bukhara Airport', 751, 39.7750015258789, 64.4832992553711, 9843).
airport('KSQ', 'Karshi Khanabad Airport', 1365, 38.8335990906, 65.9215011597, 8195).
airport('SKD', 'Samarkand Airport', 2224, 39.7005004882812, 66.9838027954102, 10170).
airport('TMJ', 'Termez Airport', 1027, 37.2867012023926, 67.3099975585938, 9843).
airport('IAR', 'Tunoshna Airport', 287, 57.5606994628906, 40.157398223877, 9870).
airport('EGO', 'Belgorod International Airport', 735, 50.643798828125, 36.5900993347168, 7930).
airport('EGO', 'Belgorod International Airport', 735, 50.643798828125, 36.5900993347168, 7430).
airport('URS', 'Kursk East Airport', 686, 51.7505989074707, 36.2956008911133, 8202).
airport('TBW', 'Donskoye Airport', 413, 52.8060989379883, 41.4827995300293, 6890).
airport('UCT', 'Ukhta Airport', 482, 63.5668983459473, 53.8046989440918, 8714).
airport('VKT', 'Vorkuta Airport', 604, 67.4886016845703, 63.9930992126465, 7218).
airport('SCW', 'Syktyvkar Airport', 342, 61.6469993591309, 50.845100402832, 8203).
airport('UUA', 'Bugulma Airport', 991, 54.6399993896484, 52.801700592041, 6561).
airport('KZN', 'Kazan International Airport', 411, 55.606201171875, 49.2787017822266, 12218).
airport('KZN', 'Kazan International Airport', 411, 55.606201171875, 49.2787017822266, 11718).
airport('NBC', 'Begishevo Airport', 643, 55.5647010803223, 52.0924987792969, 8222).
airport('NBC', 'Begishevo Airport', 643, 55.5647010803223, 52.0924987792969, 7722).
airport('CSY', 'Cheboksary Airport', 558, 56.0903015136719, 47.3473014831543, 8241).
airport('CSY', 'Cheboksary Airport', 558, 56.0903015136719, 47.3473014831543, 7741).
airport('ULV', 'Ulyanovsk Baratayevka Airport', 463, 54.2682991028, 48.2266998291, 12559).
airport('REN', 'Orenburg Central Airport', 387, 51.7957992553711, 55.4566993713379, 8212).
airport('OSW', 'Orsk Airport', 909, 51.0724983215332, 58.5956001281738, 9550).
airport('OSW', 'Orsk Airport', 909, 51.0724983215332, 58.5956001281738, 9050).
airport('OSW', 'Orsk Airport', 909, 51.0724983215332, 58.5956001281738, 8550).
airport('OSW', 'Orsk Airport', 909, 51.0724983215332, 58.5956001281738, 8050).
airport('PEZ', 'Penza Airport', 604, 53.1105995178223, 45.0210990905762, 9186).
airport('SKX', 'Saransk Airport', 676, 54.125129699707, 45.2122573852539, 9190).
airport('YIN', 'Yining Airport', 2185, 43.9557991027832, 81.3302993774414, 7874).
airport('IXG', 'Belgaum Airport', 2487, 15.8592996597, 74.6183013916, 4786).
airport('KCT', 'Koggala Airport', 10, 5.99368000030518, 80.3202972412109, 3142).
airport('GIU', 'Sigiriya Air Force Base', 630, 7.95666980743, 80.7285003662, 5925).
airport('HRI', 'Mattala Rajapaksa International Airport', 157, 6.284467, 81.124128, 11483).
airport('KOS', 'Sihanoukville International Airport', 33, 10.57970047, 103.637001038, 4251).
airport('IXA', 'Agartala Airport', 46, 23.8869991302, 91.2404022217, 7500).
airport('IXA', 'Agartala Airport', 46, 23.8869991302, 91.2404022217, 7000).
airport('SHL', 'Shillong Airport', 2910, 25.7035999298096, 91.9786987304688, 6000).
airport('IMF', 'Imphal Airport', 2540, 24.7600002289, 93.896697998, 9009).
airport('IXS', 'Silchar Airport', 352, 24.9129009247, 92.9786987305, 5993).
airport('AJL', 'Lengpui Airport', 1398, 23.8405990601, 92.6196975708, 8202).
airport('DMU', 'Dimapur Airport', 487, 25.8838996887, 93.7711029053, 7513).
airport('BZL', 'Barisal Airport', 23, 22.8010005950928, 90.3012008666992, 5995).
airport('CXB', "Cox's Bazar Airport", 12, 21.4521999359131, 91.9638977050781, 6790).
airport('JSR', 'Jessore Airport', 20, 23.1837997436523, 89.1607971191406, 8000).
airport('SPD', 'Saidpur Airport', 125, 25.7591991424561, 88.9088973999023, 6000).
airport('HOE', 'Ban Huoeisay Airport', 1380, 20.2572994232, 100.43699646, 4922).
airport('LPQ', 'Luang Phabang International Airport', 955, 19.8973007202148, 102.161003112793, 7218).
airport('LXG', 'Luang Namtha Airport', 1968, 20.9669990539551, 101.400001525879, 4429).
airport('ODY', 'Oudomsay Airport', 1804, 20.6826992034912, 101.994003295898, 3937).
airport('PKZ', 'Pakse International Airport', 351, 15.1321001052856, 105.78099822998, 5332).
airport('ZVK', 'Savannakhet Airport', 509, 16.5566005706787, 104.76000213623, 5358).
airport('XKH', 'Xieng Khouang Airport', 3445, 19.4500007629395, 103.157997131348, 8555).
airport('VDH', 'Dong Hoi Airport', 59, 17.515, 106.590556, 7874).
airport('BHR', 'Bharatpur Airport', 600, 27.6781005859375, 84.4293975830078, 3799).
airport('BWA', 'Bhairahawa Airport', 358, 27.5056991577148, 83.4162979125977, 5000).
airport('BDP', 'Bhadrapur Airport', 300, 26.5708007812, 88.0795974731, 3965).
airport('DHI', 'Dhangarhi Airport', 690, 28.7532997131348, 80.581901550293, 5000).
airport('JKR', 'Janakpur Airport', 256, 26.7087993622, 85.9224014282, 3300).
airport('KEP', 'Nepalgunj Airport', 540, 28.1035995483398, 81.6669998168945, 4935).
airport('PKR', 'Pokhara Airport', 2712, 28.2008991241455, 83.9821014404297, 4720).
airport('TMI', 'Tumling Tar Airport', 1700, 27.3150005340576, 87.1932983398438, 4000).
airport('BIR', 'Biratnagar Airport', 236, 26.4815006256104, 87.2639999389648, 4937).
airport('AGX', 'Agatti Airport', 14, 10.8236999511719, 72.1760025024414, 4235).
airport('VGA', 'Vijayawada Airport', 82, 16.5303993225098, 80.7967987060547, 7900).
airport('IXM', 'Madurai Airport', 459, 9.83450984955, 78.0933990479, 5990).
airport('IXM', 'Madurai Airport', 459, 9.83450984955, 78.0933990479, 5490).
airport('MYQ', 'Mysore Airport', 2349, 12.3072004318237, 76.6496963500977, 4421).
airport('IXZ', 'Vir Savarkar International Airport', 14, 11.6412000656128, 92.7296981811523, 10795).
airport('RJA', 'Rajahmundry Airport', 151, 17.1103992462, 81.8181991577, 5710).
airport('TIR', 'Tirupati Airport', 350, 13.6324996948, 79.543296814, 7500).
airport('PBH', 'Paro Airport', 7332, 27.4032001495, 89.4245986938, 6445).
airport('FVM', 'Fuvahmulah Airport', 6, -0.309722222222, 73.435, 3609).
airport('GAN', 'Gan International Airport', 6, -0.693341970443726, 73.1556015014648, 8694).
airport('HAQ', 'Hanimaadhoo Airport', 4, 6.74422979354858, 73.1705017089844, 4003).
airport('KDO', 'Kadhdhoo Airport', 4, 1.85916996002197, 73.5218963623047, 4003).
airport('GKK', 'Kooddoo Airport', 29, 0.7324, 73.4336, 3901).
airport('KDM', 'Kaadedhdhoo Airport', 2, 0.488130986690521, 72.9969024658203, 4003).
airport('TDX', 'Trat Airport', 105, 12.274600029, 102.319000244, 4950).
airport('UTP', 'U-Tapao International Airport', 42, 12.6799001693726, 101.004997253418, 11500).
airport('HGN', 'Mae Hong Son Airport', 929, 19.3013000488281, 97.9757995605469, 6562).
airport('PYY', 'Pai Airport', 1271, 19.3719997406, 98.43699646, 3018).
airport('LPT', 'Lampang Airport', 811, 18.2709007263184, 99.5042037963867, 6465).
airport('NNT', 'Nan Airport', 685, 18.8078994750977, 100.782997131348, 6562).
airport('PRH', 'Phrae Airport', 538, 18.1322002410889, 100.165000915527, 4921).
airport('CEI', 'Chiang Rai International Airport', 1280, 19.952299118, 99.8828964233, 9843).
airport('MAQ', 'Mae Sot Airport', 690, 16.6998996734619, 98.5450973510742, 4921).
airport('THS', 'Sukhothai Airport', 179, 17.238000869751, 99.8181991577148, 6890).
airport('PHS', 'Phitsanulok Airport', 154, 16.7828998565674, 100.278999328613, 9843).
airport('URT', 'Surat Thani Airport', 20, 9.13259983063, 99.135597229, 9843).
airport('NAW', 'Narathiwat Airport', 16, 6.51991987228394, 101.74299621582, 6562).
airport('CJM', 'Chumphon Airport', 18, 10.711199760437, 99.361701965332, 6890).
airport('NST', 'Nakhon Si Thammarat Airport', 13, 8.5396203994751, 99.9447021484375, 6890).
airport('URC', 'Ürümqi Diwopu International Airport', 2125, 43.9071006774902, 87.4741973876953, 11811).
airport('UNN', 'Ranong Airport', 57, 9.77762031555176, 98.5855026245117, 6562).
airport('TST', 'Trang Airport', 67, 7.50873994827271, 99.6166000366211, 6890).
airport('UTH', 'Udon Thani Airport', 579, 17.3864002228, 102.788002014, 10000).
airport('SNO', 'Sakon Nakhon Airport', 529, 17.1951007843018, 104.119003295898, 8530).
airport('KKC', 'Khon Kaen Airport', 670, 16.4666004181, 102.783996582, 10007).
airport('LOE', 'Loei Airport', 860, 17.4391002655029, 101.72200012207, 6890).
airport('BFV', 'Buri Ram Airport', 590, 15.2294998168945, 103.252998352051, 6890).
airport('UBP', 'Ubon Ratchathani Airport', 406, 15.2512998581, 104.870002747, 9848).
airport('ROI', 'Roi Et Airport', 451, 16.1168003082275, 103.774002075195, 6890).
airport('KOP', 'Nakhon Phanom Airport', 587, 17.3838005065918, 104.642997741699, 8203).
airport('BMV', 'Buon Ma Thuot Airport', 1729, 12.668299675, 108.120002747, 9843).
airport('VCL', 'Chu Lai International Airport', 10, 15.4033002853, 108.706001282, 10300).
airport('HPH', 'Cat Bi International Airport', 6, 20.8194007873535, 106.724998474121, 7880).
airport('CAH', 'Cà Mau Airport', 6, 9.17766666667, 105.177777778, 4921).
airport('CXR', 'Cam Ranh Airport', 40, 11.9982004165649, 109.21900177002, 10000).
airport('VCS', 'Co Ong Airport', 20, 8.73182964325, 106.633003235, 6046).
airport('VCA', 'Can Tho International Airport', 9, 10.085100174, 105.711997986, 7886).
airport('DIN', 'Dien Bien Phu Airport', 1611, 21.3974990845, 103.008003235, 6003).
airport('DLI', 'Lien Khuong Airport', 3156, 11.75, 108.366996765137, 10663).
airport('HUI', 'Phu Bai Airport', 48, 16.4015007019, 107.70300293, 8775).
airport('UIH', 'Phu Cat Airport', 80, 13.9549999237, 109.041999817, 10010).
airport('PXU', 'Pleiku Airport', 2434, 14.0045003890991, 108.016998291016, 5960).
airport('PQC', 'Phu Quoc Airport', 23, 10.2270002365, 103.967002869, 6900).
airport('VKG', 'Rach Gia Airport', 7, 9.95802997234, 105.132379532, 4921).
airport('TBB', 'Dong Tac Airport', 20, 13.0495996475, 109.333999634, 9520).
airport('TBB', 'Dong Tac Airport', 20, 13.0495996475, 109.333999634, 9020).
airport('TBB', 'Dong Tac Airport', 20, 13.0495996475, 109.333999634, 8520).
airport('VII', 'Vinh Airport', 23, 18.7376003265, 105.67099762, 7875).
airport('NYU', 'Bagan Airport', 312, 21.1788005828857, 94.9301986694336, 8500).
airport('TVY', 'Dawei Airport', 84, 14.1038999557495, 98.2035980224609, 7005).
airport('NYT', 'Naypyidaw Airport', 302, 19.623500824, 96.2009963989, 12000).
airport('HEH', 'Heho Airport', 3858, 20.7469997406006, 96.7919998168945, 8500).
airport('KYP', 'Kyaukpyu Airport', 20, 19.426399230957, 93.534797668457, 4600).
airport('MDL', 'Mandalay International Airport', 300, 21.7021999359131, 95.977897644043, 14003).
airport('MYT', 'Myitkyina Airport', 475, 25.3836002349854, 97.3518981933594, 6100).
airport('AKY', 'Sittwe Airport', 27, 20.1326999664307, 92.8725967407227, 6001).
airport('SNW', 'Thandwe Airport', 20, 18.4606990814209, 94.3001022338867, 5502).
airport('THL', 'Tachileik Airport', 1280, 20.4838008880615, 99.9354019165039, 7002).
airport('MJU', 'Tampa Padang Airport', 49, -2.583333, 119.033333, 6726).
airport('BIK', 'Frans Kaisiepo Airport', 46, -1.19001996517181, 136.108001708984, 11715).
airport('TIM', 'Moses Kilangin Airport', 103, -4.52827978134155, 136.886993408203, 7841).
airport('BMU', 'Muhammad Salahuddin Airport', 3, -8.53964996337891, 118.686996459961, 5405).
airport('TMC', 'Tambolaka Airport', 161, -9.4097204208374, 119.244003295898, 5905).
airport('WGP', 'Waingapu Airport', 33, -9.6692199707, 120.302001953, 5415).
airport('DJJ', 'Sentani Airport', 289, -2.57695007324219, 140.516006469727, 7161).
airport('BEJ', 'Barau(Kalimaru) Airport', 59, 2.15549993515, 117.431999207, 4625).
airport('TRK', 'Juwata Airport', 23, 3.32666666667, 117.569444444, 7382).
airport('GTO', 'Jalaluddin Airport', 105, 0.63711899519, 122.849998474, 7407).
airport('NAH', 'Naha Airport', 16, 3.68320989608765, 125.52799987793, 3597).
airport('KAZ', 'Kao Airport', 27, 1.1852799654007, 127.896003723145, 2963).
airport('PLW', 'Mutiara Airport', 284, -0.91854202747345, 119.910003662109, 6781).
airport('MNA', 'Melangguane Airport', 3, 4.00693988800049, 126.672996520996, 8858).
airport('PSJ', 'Kasiguncu Airport', 174, -1.41674995422, 120.657997131, 3650).
airport('TTE', 'Sultan Khairun Babullah Airport', 49, 0.831413984298706, 127.380996704102, 5875).
airport('LUW', 'Bubung Airport', 56, -1.03892004489899, 122.772003173828, 4258).
airport('PKN', 'Iskandar Airport', 75, -2.70519995689, 111.672996521, 5415).
airport('KBU', 'Stagen Airport', 4, -3.2947199344635, 116.165000915527, 4593).
airport('BDJ', 'Syamsudin Noor Airport', 66, -3.44235992431641, 114.763000488281, 8202).
airport('PKY', 'Tjilik Riwut Airport', 82, -2.22513008118, 113.943000793, 6890).
airport('AMQ', 'Pattimura Airport, Ambon', 33, -3.7102599144, 128.089004517, 8202).
airport('MLG', 'Abdul Rachman Saleh Airport', 1726, -7.92655992508, 112.714996338, 6464).
airport('MLG', 'Abdul Rachman Saleh Airport', 1726, -7.92655992508, 112.714996338, 5964).
airport('MKW', 'Rendani Airport', 23, -0.891833007335663, 134.04899597168, 6576).
airport('SOQ', 'Sorong (Jefman) Airport', 10, -0.926357984542847, 131.121002197266, 5414).
airport('MOF', 'Maumere(Wai Oti) Airport', 115, -8.64064979553, 122.236999512, 5980).
airport('LBJ', 'Komodo (Mutiara II) Airport', 66, -8.48666000366211, 119.888999938965, 4570).
airport('KOE', 'El Tari Airport', 335, -10.1716003417969, 123.670997619629, 8202).
airport('KOE', 'El Tari Airport', 335, -10.1716003417969, 123.670997619629, 7702).
airport('BUW', 'Betoambari Airport', 164, -5.48687982559204, 122.569000244141, 3445).
airport('KDI', 'Wolter Monginsidi Airport', 538, -4.08161020278931, 122.417999267578, 6890).
airport('WBB', 'Stebbins Airport', 19, 63.5159988403, -162.277999878, 2999).
airport('BTU', 'Bintulu Airport', 74, 3.12385010719, 113.019996643, 9006).
airport('LGL', 'Long Lellang Airport', 1400, 3.42100000381, 115.153999329, 2559).
airport('ODN', 'Long Seridan Airport', 607, 3.96700000762939, 115.050003051758, 1798).
airport('LMN', 'Limbang Airport', 14, 4.80830001831055, 115.01000213623, 4922).
airport('MKM', 'Mukah Airport', 13, 2.90638995170593, 112.080001831055, 3599).
airport('LKH', 'Long Akah Airport', 289, 3.29999995231628, 114.782997131348, 2231).
airport('MUR', 'Marudi Airport', 103, 4.17897987365723, 114.329002380371, 3274).
airport('SBW', 'Sibu Airport', 122, 2.26160001754761, 111.985000610352, 9036).
airport('TGC', 'Tanjung Manis Airport', 15, 2.17783999443054, 111.202003479004, 4912).
airport('LWY', 'Lawas Airport', 5, 4.84917020797729, 115.407997131348, 2251).
airport('BBN', 'Bario Airport', 3350, 3.73389005661011, 115.478996276855, 2198).
airport('LDU', 'Lahad Datu Airport', 45, 5.03224992752075, 118.323997497559, 4498).
airport('LBU', 'Labuan Airport', 101, 5.30068016052246, 115.25, 7546).
airport('SDK', 'Sandakan Airport', 46, 5.90089988708496, 118.05899810791, 7000).
airport('KUD', 'Kudat Airport', 10, 6.9225001335144, 116.835998535156, 2395).
airport('TWU', 'Tawau Airport', 57, 4.32015991210938, 118.127998352051, 8800).
airport('MZV', 'Mulu Airport', 80, 4.04832983016968, 114.805000305176, 4921).
airport('TKG', 'Radin Inten II (Branti) Airport', 282, -5.240556, 105.175556, 6070).
airport('BTH', 'Hang Nadim International Airport', 126, 1.12102997303, 104.119003296, 13270).
airport('TNJ', 'Raja Haji Fisabilillah International Airport', 52, 0.922683000565, 104.531997681, 7380).
airport('KHG', 'Kashgar Airport', 4529, 39.5429000854, 76.0199966431, 10499).
airport('TJQ', 'Buluh Tumbang (H A S Hanandjoeddin) Airport', 164, -2.74571990967, 107.754997253, 6065).
airport('PNK', 'Supadio Airport', 10, -0.150710999965668, 109.403999328613, 7380).
airport('DJB', 'Sultan Thaha Airport', 82, -1.63802003860474, 103.643997192383, 6562).
airport('PGK', 'Pangkal Pinang (Depati Amir) Airport', 109, -2.16219997406, 106.138999939, 6550).
airport('BKS', 'Padang Kemiling (Fatmawati Soekarno) Airport', 50, -3.8636999130249, 102.338996887207, 7345).
airport('PDG', 'Minangkabau Airport', 18, -0.786916971206665, 100.28099822998, 9020).
airport('BTJ', 'Sultan Iskandar Muda International Airport', 65, 5.52287202401, 95.4206371307, 9843).
airport('AOR', 'Sultan Abdul Halim Airport', 15, 6.18967008590698, 100.398002624512, 9005).
airport('KTE', 'Kerteh Airport', 18, 4.5372200012207, 103.427001953125, 4446).
airport('JHB', 'Senai International Airport', 135, 1.64130997657776, 103.669998168945, 12467).
airport('AUU', 'Aurukun Airport', 31, -13.3538999557, 141.720993042, 4140).
airport('ABM', 'Bamaga Injinoo Airport', 34, -10.9507999420166, 142.458999633789, 5462).
airport('BQL', 'Boulia Airport', 542, -22.9132995605469, 139.899993896484, 4180).
airport('WEI', 'Weipa Airport', 63, -12.6786003113, 141.925003052, 5397).
airport('CPD', 'Coober Pedy Airport', 740, -29.0400009155273, 134.720993041992, 4685).
airport('CPD', 'Coober Pedy Airport', 740, -29.0400009155273, 134.720993041992, 4185).
airport('CED', 'Ceduna Airport', 77, -32.1305999755859, 133.710006713867, 5709).
airport('CED', 'Ceduna Airport', 77, -32.1305999755859, 133.710006713867, 5209).
airport('CUQ', 'Coen Airport', 532, -13.7608003616333, 143.113998413086, 4107).
airport('DMD', 'Doomadgee Airport', 153, -17.940299987793, 138.822006225586, 5433).
airport('FLS', 'Flinders Island Airport', 10, -40.0917015076, 147.992996216, 5643).
airport('FLS', 'Flinders Island Airport', 10, -40.0917015076, 147.992996216, 5143).
airport('GFN', 'Grafton Airport', 110, -29.7593994140625, 153.029998779297, 5607).
airport('GTE', 'Groote Eylandt Airport', 53, -13.9750003815, 136.460006714, 6237).
airport('HID', 'Horn Island Airport', 43, -10.586400032, 142.289993286, 4557).
airport('HID', 'Horn Island Airport', 43, -10.586400032, 142.289993286, 4057).
airport('JCK', 'Julia Creek Airport', 404, -20.6683006286621, 141.723007202148, 4600).
airport('KWM', 'Kowanyama Airport', 35, -15.4856004714966, 141.751007080078, 4528).
airport('KGC', 'Kingscote Airport', 24, -35.7139015197754, 137.52099609375, 4600).
airport('KGC', 'Kingscote Airport', 24, -35.7139015197754, 137.52099609375, 4100).
airport('KGC', 'Kingscote Airport', 24, -35.7139015197754, 137.52099609375, 3600).
airport('IRG', 'Lockhart River Airport', 77, -12.7868995666504, 143.304992675781, 4919).
airport('MNG', 'Maningrida Airport', 123, -12.0560998917, 134.23399353, 5020).
airport('MCV', 'McArthur River Mine Airport', 131, -16.4424991608, 136.083999634, 4931).
airport('NTN', 'Normanton Airport', 73, -17.6835994720459, 141.070007324219, 5499).
airport('OLP', 'Olympic Dam Airport', 343, -30.4850006104, 136.876998901, 5220).
airport('PUG', 'Port Augusta Airport', 56, -32.5069007873535, 137.716995239258, 5413).
airport('CCK', 'Cocos (Keeling) Islands Airport', 10, -12.1883001328, 96.8339004517, 7999).
airport('GOV', 'Gove Airport', 192, -12.2693996429, 136.817993164, 7244).
airport('PLO', 'Port Lincoln Airport', 36, -34.6053009033, 135.880004883, 4918).
airport('PLO', 'Port Lincoln Airport', 36, -34.6053009033, 135.880004883, 4418).
airport('PLO', 'Port Lincoln Airport', 36, -34.6053009033, 135.880004883, 3918).
airport('EDR', 'Pormpuraaw Airport', 10, -14.8966999053955, 141.608993530273, 4462).
airport('ULP', 'Quilpie Airport', 655, -26.6121997833252, 144.253005981445, 4898).
airport('ULP', 'Quilpie Airport', 655, -26.6121997833252, 144.253005981445, 4398).
airport('SGO', 'St George Airport', 656, -28.0496997833252, 148.595001220703, 4987).
airport('WYA', 'Whyalla Airport', 41, -33.0588989257812, 137.514007568359, 5531).
airport('WYA', 'Whyalla Airport', 41, -33.0588989257812, 137.514007568359, 5031).
airport('KBC', 'Birch Creek Airport', 450, 66.2740020752, -145.824005127, 4000).
airport('HDG', 'Handan Airport', 229, 36.5258333333, 114.425555556, 7218).
airport('SHP', 'Shanhaiguan Airport', 30, 39.9681015015, 119.731002808, 8005).
airport('SJW', 'Shijiazhuang Daguocun International Airport', 233, 38.2807006835938, 114.696998596191, 11155).
airport('HJJ', 'Zhijiang Airport', 882, 27.4411111111, 109.7, 6562).
airport('LLF', 'Lingling Airport', 340, 26.338661, 111.610043, 8530).
airport('WUZ', 'Changzhoudao Airport', 89, 23.4566993713379, 111.248001098633, 5906).
airport('ENH', 'Enshi Airport', 1605, 30.3202991486, 109.48500061, 6890).
airport('NNY', 'Nanyang Airport', 407, 32.9808006286621, 112.61499786377, 9186).
airport('DNH', 'Dunhuang Airport', 3697, 40.1610984802246, 94.809196472168, 9186).
airport('GOQ', 'Golmud Airport', 9337, 36.4006004333496, 94.7861022949219, 15748).
airport('JGN', 'Jiayuguan Airport', 118, 39.8568992615, 98.3414001465, 9834).
airport('IQN', 'Qingyang Airport', 4593, 35.7997016906738, 107.602996826172, 5791).
airport('GXH', 'Gannan Xiahe Airport', 10510, 34.8105, 102.6447, 10499).
airport('BYN', 'Bayankhongor Airport', 6085, 46.1632995605469, 100.704002380371, 9186).
airport('BYN', 'Bayankhongor Airport', 6085, 46.1632995605469, 100.704002380371, 8686).
airport('COQ', 'Choibalsan Airport', 2457, 48.1357002258301, 114.646003723145, 8530).
airport('ULZ', 'Donoi Airport', 5800, 47.7093, 96.5258, 10498).
airport('DLZ', 'Dalanzadgad Airport', 4787, 43.5917015075684, 104.430000305176, 7545).
airport('HVD', 'Khovd Airport', 4898, 47.9541015625, 91.6281967163086, 9352).
airport('HVD', 'Khovd Airport', 4898, 47.9541015625, 91.6281967163086, 8852).
airport('HVD', 'Khovd Airport', 4898, 47.9541015625, 91.6281967163086, 8352).
airport('MXV', 'Mörön Airport', 4272, 49.6632995605469, 100.098999023438, 8005).
airport('ULO', 'Ulaangom Airport', 3068, 49.973333, 92.079722, 6234).
airport('ULG', 'Olgii Mongolei Airport', 5732, 48.9933013916, 89.9225006104, 7874).
airport('DLU', 'Dali Airport', 7050, 25.6494007110596, 100.319000244141, 8202).
airport('DIG', 'Diqing Airport', 10761, 27.7936000823975, 99.6772003173828, 11811).
airport('JHG', 'Xishuangbanna Gasa Airport', 1815, 21.9738998413086, 100.76000213623, 7218).
airport('SYM', 'Simao Airport', 4255, 22.7933006286621, 100.958999633789, 8104).
airport('ZAT', 'Zhaotong Airport', 6300, 27.3255996704102, 103.754997253418, 8465).
airport('JUZ', 'Quzhou Airport', 220, 28.965799331665, 118.899002075195, 6234).
airport('LCX', 'Longyan Guanzhishan Airport', 1225, 25.6746997833, 116.747001648, 7874).
airport('NGQ', 'Ngari Gunsa Airport', 14022, 32.1, 80.0530555556, 14764).
airport('AVA', 'Anshun Huangguoshu Airport', 4812, 26.2605555556, 105.873333333, 9186).
airport('BPX', 'Qamdo Bangda Airport', 14219, 30.5536003112793, 97.1082992553711, 18045).
airport('JZH', 'Jiuzhai Huanglong Airport', 11327, 32.8533333333, 103.682222222, 10499).
airport('MIG', 'Mianyang Airport', 1690, 31.4281005859375, 104.740997314453, 4593).
airport('NAO', 'Nanchong Airport', 1152, 30.79545, 106.1626, 5906).
airport('HZH', 'Liping Airport', 1620, 26.32217, 109.1499, 7218).
airport('LZY', 'Nyingchi Airport', 9675, 29.3033008575439, 94.3352966308594, 9843).
airport('TCZ', 'Tengchong Tuofeng Airport', 6250, 24.9380555556, 98.4858333333, 7710).
airport('TEN', 'Tongren Fenghuang Airport', 2300, 27.883333, 109.308889, 6562).
airport('WXN', 'Wanxian Airport', 1808, 30.8017, 108.433, 7874).
airport('XIC', 'Xichang Qingshan Airport', 5112, 27.9890995025635, 102.18399810791, 11811).
airport('YBP', 'Yibin Caiba Airport', 924, 28.8005555556, 104.545, 7054).
airport('ACX', 'Xingyi Airport', 4150, 25.0863888889, 104.959444444, 7546).
airport('ZYI', 'Zunyi Xinzhou Airport', 2920, 27.5895, 107.0007, 5577).
airport('AKU', 'Aksu Airport', 3816, 41.2625007629395, 80.2917022705078, 7874).
airport('HMI', 'Hami Airport', 2703, 42.8414001465, 93.6691970825, 7710).
airport('PLX', 'Semipalatinsk Airport', 761, 50.3512992858887, 80.2343978881836, 10157).
airport('YTY', 'Taizhou Airport', 16, 32.5617, 119.715, 7874).
airport('GEL', 'Santo Ângelo Airport', 1056, -28.2817001342773, -54.1691017150879, 5331).
airport('TLJ', 'Tatalina LRRS Airport', 964, 62.8944015503, -155.977005005, 3800).
airport('IGG', 'Igiugig Airport', 90, 59.3240013122559, -155.901992797852, 3000).
airport('CKD', 'Crooked Creek Airport', 178, 61.8679008484, -158.134994507, 2029).
airport('AHU', 'Cherif Al Idrissi Airport', 95, 35.1771011352539, -3.83951997756958, 8202).
airport('RDV', 'Red Devil Airport', 180, 61.7881011963, -157.350006104, 4820).
airport('OMD', 'Oranjemund Airport', 14, -28.5846996307373, 16.4466991424561, 5252).
airport('OMD', 'Oranjemund Airport', 14, -28.5846996307373, 16.4466991424561, 4752).
airport('OMD', 'Oranjemund Airport', 14, -28.5846996307373, 16.4466991424561, 4252).
airport('TMR', 'Aguenar – Hadj Bey Akhamok Airport', 4518, 22.8115005493, 5.45107984543, 11811).
airport('TMR', 'Aguenar – Hadj Bey Akhamok Airport', 4518, 22.8115005493, 5.45107984543, 11311).
airport('YPL', 'Pickle Lake Airport', 1267, 51.4463996887207, -90.2142028808594, 4921).
airport('YLH', 'Lansdowne House Airport', 834, 52.1955986022949, -87.934196472168, 3500).
airport('KGG', 'Kédougou Airport', 584, 12.5722999572754, -12.2202997207642, 5906).
airport('SLQ', 'Sleetmute Airport', 190, 61.7005004883, -157.166000366, 3100).
airport('NUP', 'Nunapitchuk Airport', 12, 60.9057998657, -162.438995361, 2420).
airport('MNT', 'Minto Al Wright Airport', 499, 65.143699646, -149.369995117, 3400).
airport('IRC', 'Circle City /New/ Airport', 613, 65.83049774, -144.076004, 2979).
airport('TNW', 'Jumandy Airport', 1234, -1.0626, -77.5736, 8202).
airport('KYK', 'Karluk Airport', 137, 57.5671005249, -154.449996948, 2000).
airport('GMR', 'Totegegie Airport', 7, -23.0799007415771, -134.889999389648, 6562).
airport('MKP', 'Makemo Airport', 3, -16.5839004516602, -143.658004760742, 4920).
airport('GNM', 'Guanambi Airport', 1815, -14.2082004547119, -42.7461013793945, 5577).
airport('KKR', 'Kaukura Airport', 11, -15.6632995605469, -146.884994506836, 3543).
airport('UGB', 'Ugashik Bay Airport', 132, 57.4253997803, -157.740005493, 5280).
airport('MYU', 'Mekoryuk Airport', 48, 60.3713989257812, -166.27099609375, 3070).
airport('TNK', 'Tununak Airport', 14, 60.5755004882812, -165.272003173828, 3300).
airport('NME', 'Nightmute Airport', 4, 60.4710006713867, -164.70100402832, 1600).
airport('PTU', 'Platinum Airport', 15, 59.0113983154297, -161.820007324219, 3304).
airport('PTU', 'Platinum Airport', 15, 59.0113983154297, -161.820007324219, 2804).
airport('RSH', 'Russian Mission Airport', 51, 61.7788848876953, -161.319458007812, 3600).
airport('RSH', 'Russian Mission Airport', 51, 61.7788848876953, -161.319458007812, 3100).
airport('PQS', 'Pilot Station Airport', 305, 61.9346008300781, -162.899993896484, 2540).
airport('KHZ', 'Kauehi Airport', 13, -15.7807998657227, -145.123992919922, 3937).
airport('PKA', 'Napaskiak Airport', 24, 60.70289993, -161.7779999, 15000).
airport('PKA', 'Napaskiak Airport', 24, 60.70289993, -161.7779999, 14500).
airport('EGX', 'Egegik Airport', 92, 58.1855010986, -157.375, 5600).
airport('EGX', 'Egegik Airport', 92, 58.1855010986, -157.375, 5100).
airport('WWT', 'Newtok Airport', 25, 60.9390983581543, -164.641006469727, 2202).
airport('PTH', 'Port Heiden Airport', 95, 56.959098815918, -158.632995605469, 5000).
airport('PTH', 'Port Heiden Airport', 95, 56.959098815918, -158.632995605469, 4500).
airport('KXU', 'Katiu Airport', 7, -16.3393993378, -144.402999878, 3871).
airport('YZS', 'Coral Harbour Airport', 210, 64.1932983398, -83.3593978882, 5000).
airport('RKV', 'Reykjavik Airport', 48, 64.1299972534, -21.9405994415, 5141).
airport('RKV', 'Reykjavik Airport', 48, 64.1299972534, -21.9405994415, 4641).
airport('RKV', 'Reykjavik Airport', 48, 64.1299972534, -21.9405994415, 4141).
airport('LEQ', "Land's End Airport", 401, 50.1027984619141, -5.67055988311768, 2598).
airport('LEQ', "Land's End Airport", 401, 50.1027984619141, -5.67055988311768, 2098).
airport('LEQ', "Land's End Airport", 401, 50.1027984619141, -5.67055988311768, 1598).
airport('LEQ', "Land's End Airport", 401, 50.1027984619141, -5.67055988311768, 1098).
airport('UST', 'Northeast Florida Regional Airport', 9, 29.9591999053955, -81.3397979736328, 8002).
airport('UST', 'Northeast Florida Regional Airport', 9, 29.9591999053955, -81.3397979736328, 7502).
airport('UST', 'Northeast Florida Regional Airport', 9, 29.9591999053955, -81.3397979736328, 7002).
airport('YIC', 'Mingyueshan Airport', 430, 27.802222, 114.306111, 7874).
airport('WNH', 'Wenshan Puzhehei Airport', 1590, 23.558056, 104.325278, 7874).
airport('NER', 'Chulman Neryungri Airport', 2811, 56.9138984680176, 124.914001464844, 11811).
airport('NZH', 'Manzhouli Xijiao Airport', 2231, 49.566667, 117.329444, 9252).
airport('RLK', 'Bayannur Tianjitai Airport', 3389, 40.926389, 107.738889, 8530).
airport('IWK', 'Iwakuni Marine Corps Air Station', 7, 34.1439018249512, 132.235992431641, 8000).
airport('IWK', 'Iwakuni Marine Corps Air Station', 7, 34.1439018249512, 132.235992431641, 7500).
airport('TCR', 'Tuticorin Southwest Airport', 129, 8.72424030303955, 78.0258026123047, 4434).
airport('SZE', 'Semera Airport', 1436, 11.7875, 40.991389, 7218).
airport('LMA', 'Minchumina Airport', 681, 63.8860015869141, -152.302001953125, 4184).
airport('KZR', 'Zafer Airport', 3322, 39.111456, 30.130217, 9843).
airport('NOP', 'Sinop Airport', 3524, 42.0158004760742, 35.0663986206055, 5420).
airport('OSM', 'Mosul International Airport', 719, 36.3058013916016, 43.1473999023438, 8694).
airport('THD', 'Tho Xuan Airport', 73, 19.9025, 105.469167, 10499).
airport('LLB', 'Libo Airport', 2707, 25.450833, 107.962222, 7546).
airport('DCY', 'Daocheng Yading Airport', 14472, 29.323056, 100.053333, 13780).
airport('KGT', 'Kangding Airport', 14042, 30.142778, 101.738611, 13123).
airport('RVE', 'Los Colonizadores Airport', 698, 6.951667, -71.856943, 3937).
airport('VGZ', 'Villa Garzón Airport', 1248, 0.978767, -76.605557, 4320).
airport('DRV', 'Dharavandhoo Airport', 6, 5.158, 73.131, 3937).
airport('OLL', 'Oyo Ollombo International Airport', 1073, -1.221499, 15.913583, 10827).
airport('OLL', 'Oyo Ollombo International Airport', 1073, -1.221499, 15.913583, 10327).
airport('YFA', 'Fort Albany Airport', 48, 52.2014007568359, -81.6968994140625, 3500).
airport('HTN', 'Hotan Airport', 4672, 37.038501739502, 79.8648986816406, 10499).
airport('WMX', 'Wamena Airport', 5085, -4.10250997543335, 138.957000732422, 5436).
airport('MGZ', 'Myeik Airport', 75, 12.4398002624512, 98.6214981079102, 8795).
airport('TGP', 'Podkamennaya Tunguska Airport', 214, 61.5896987915039, 89.9940032958984, 5597).
airport('SUK', 'Sakkyryr Airport', 1642, 67.792222, 130.3925, 6562).
airport('OGD', 'Ogden Hinckley Airport', 4472, 41.1958999633789, -112.012001037598, 8103).
airport('OGD', 'Ogden Hinckley Airport', 4472, 41.1958999633789, -112.012001037598, 7603).
airport('OGD', 'Ogden Hinckley Airport', 4472, 41.1958999633789, -112.012001037598, 7103).
airport('JOL', 'Jolo Airport', 118, 6.05366992950439, 121.011001586914, 4144).
airport('KAW', 'Kawthoung Airport', 180, 10.0493001937866, 98.5380020141602, 6000).
airport('ZKE', 'Kashechewan Airport', 35, 52.2825012207031, -81.6778030395508, 3500).
airport('YAT', 'Attawapiskat Airport', 30, 52.9275016784668, -82.4319000244141, 3495).
airport('KUS', 'Kulusuk Airport', 117, 65.573600769, -37.1236000061, 3934).
airport('IFJ', 'Ísafjörður Airport', 8, 66.0580978393555, -23.1352996826172, 4593).
airport('EGS', 'Egilsstaðir Airport', 76, 65.2833023071289, -14.4013996124268, 6562).
airport('AEY', 'Akureyri Airport', 6, 65.6600036621094, -18.0727005004883, 6365).
airport('YCS', 'Chesterfield Inlet Airport', 32, 63.3469009399, -90.7311019897, 3600).
airport('YUT', 'Repulse Bay Airport', 80, 66.5214004517, -86.2247009277, 3400).
airport('ELG', 'El Golea Airport', 1306, 30.5713005065918, 2.85959005355835, 9843).
airport('ELG', 'El Golea Airport', 1306, 30.5713005065918, 2.85959005355835, 9343).
airport('LTI', 'Altai Airport', 7260, 46.3763999938965, 96.2210998535156, 7513).
airport('ZQZ', 'Zhangjiakou Ningyuan Airport', 2347, 40.7386016846, 114.930000305, 8202).
airport('CMA', 'Cunnamulla Airport', 630, -28.0300006866455, 145.621994018555, 5686).
airport('CMA', 'Cunnamulla Airport', 630, -28.0300006866455, 145.621994018555, 5186).
airport('XTG', 'Thargomindah Airport', 433, -27.986400604248, 143.811004638672, 4800).
airport('XTG', 'Thargomindah Airport', 433, -27.986400604248, 143.811004638672, 4300).
airport('AAT', 'Altay Air Base', 2491, 47.7498855591, 88.0858078003, 5741).
airport('ABS', 'Abu Simbel Airport', 616, 22.3759994507, 31.611700058, 9843).
airport('ACR', 'Araracuara Airport', 1250, -0.5833, -72.4083, 4199).
airport('AFZ', 'Sabzevar National Airport', 3010, 36.168098449707, 57.5951995849609, 10428).
airport('AKI', 'Akiak Airport', 30, 60.9029006958, -161.231002808, 3196).
airport('AKV', 'Akulivik Airport', 75, 60.8185997009277, -78.1485977172852, 3510).
airport('ANG', 'Angoulême-Brie-Champniers Airport', 436, 45.7291984558105, 0.221456006169319, 5938).
airport('ANV', 'Anvik Airport', 291, 62.64670181, -160.1909943, 2960).
airport('ASV', 'Amboseli Airport', 3755, -2.64505004882812, 37.253101348877, 3871).
airport('AUK', 'Alakanuk Airport', 10, 62.6800422668, -164.659927368, 2200).
airport('AUY', 'Aneityum Airport', 7, -20.2492008209, 169.770996094, 2001).
airport('AWD', 'Aniwa Airport', 69, -19.2346, 169.6009, 2625).
airport('BEU', 'Bedourie Airport', 300, -24.3460998535156, 139.460006713867, 4921).
airport('BJB', 'Bojnord Airport', 3499, 37.4930000305176, 57.3082008361816, 10582).
airport('BJF', 'Båtsfjord Airport', 490, 70.6005020141602, 29.6914005279541, 3281).
airport('BKM', 'Bakalalan Airport', 2900, 3.97399997711182, 115.61799621582, 1801).
airport('BKY', 'Bukavu Kavumu Airport', 5643, -2.30897998809814, 28.8087997436523, 6562).
airport('BKZ', 'Bukoba Airport', 3745, -1.332, 31.8212, 3445).
airport('BMW', 'Bordj Badji Mokhtar Airport', 1303, 21.375, 0.923888981342, 7372).
airport('BPL', 'Alashankou Bole (Bortala) airport', 1253, 44.895, 82.3, 8530).
airport('BSC', 'José Celestino Mutis Airport', 80, 6.20292, -77.3947, 3973).
airport('BSC', 'José Celestino Mutis Airport', 80, 6.20292, -77.3947, 3473).
airport('BTC', 'Batticaloa Airport', 20, 7.70576000213623, 81.6788024902344, 3592).
airport('BUC', 'Burketown Airport', 21, -17.7486000061035, 139.533996582031, 4501).
airport('BUC', 'Burketown Airport', 21, -17.7486000061035, 139.533996582031, 4001).
airport('BVG', 'Berlevåg Airport', 42, 70.8713989257812, 29.034200668335, 3372).
airport('BVI', 'Birdsville Airport', 159, -25.8974990844727, 139.348007202148, 5682).
airport('BVI', 'Birdsville Airport', 159, -25.8974990844727, 139.348007202148, 5182).
airport('BXB', 'Babo Airport', 10, -2.53223991394043, 133.438995361328, 4280).
airport('BXR', 'Bam Airport', 3231, 29.0841999053955, 58.4500007629395, 11107).
airport('BYC', 'Yacuiba Airport', 2112, -21.9608993530273, -63.6516990661621, 6890).
airport('CAJ', 'Canaima Airport', 1450, 6.23198890686035, -62.8544311523438, 7070).
airport('CNP', 'Neerlerit Inaat Airport', 45, 70.7431030273, -22.6504993439, 3281).
airport('CSH', 'Solovki Airport', 60, 65.0299987793, 35.7333335876, 4921).
airport('CZH', 'Corozal Municipal Airport', 40, 18.3822002410889, -88.4119033813477, 2200).
airport('CZS', 'Cruzeiro do Sul Airport', 637, -7.59990978241, -72.7695007324, 7874).
airport('DEF', 'Dezful Airport', 474, 32.4343986511, 48.3975982666, 12641).
airport('DEF', 'Dezful Airport', 474, 32.4343986511, 48.3975982666, 12141).
airport('ELC', 'Elcho Island Airport', 101, -12.0193996429, 135.570999146, 4724).
airport('ENE', 'Ende (H Hasan Aroeboesman) Airport', 49, -8.8492898941, 121.661003113, 5440).
airport('ERN', 'Eirunepé Airport', 412, -6.63953018188477, -69.8797988891602, 7546).
airport('FTA', 'Futuna Airport', 95, -19.5163993835, 170.231994629, 2297).
airport('FUT', 'Pointe Vele Airport', 20, -14.3114004135, -178.065994263, 3609).
airport('GCH', 'Gachsaran Airport', 2414, 30.337600708, 50.827999115, 6070).
airport('GDE', 'Gode Airport', 834, 5.93513011932, 43.5786018372, 7505).
airport('GJA', 'La Laguna Airport', 49, 16.4454002380371, -85.9066009521484, 3990).
airport('GYA', 'Capitán de Av. Emilio Beltrán Airport', 557, -10.820599556, -65.3455963135, 5905).
airport('HFA', 'Haifa International Airport', 28, 32.809398651123, 35.043098449707, 4324).
airport('IIL', 'Ilam Airport', 4404, 33.5866012573242, 46.4048004150391, 9183).
airport('IRZ', 'Tapuruquara Airport', 223, -0.3786, -64.9923, 3937).
airport('ITB', 'Itaituba Airport', 110, -4.24234008789062, -56.0007019042969, 5266).
airport('JAV', 'Ilulissat Airport', 95, 69.2432022095, -51.0570983887, 2772).
airport('JEG', 'Aasiaat Airport', 74, 68.7218017578, -52.7846984863, 2621).
airport('JFR', 'Paamiut Airport', 120, 62.0147361755, -49.6709365845, 2621).
airport('JHS', 'Sisimiut Airport', 33, 66.9513015747, -53.7293014526, 2621).
airport('JSU', 'Maniitsoq Airport', 91, 65.4124984741, -52.9393997192, 2621).
airport('KAL', 'Kaltag Airport', 181, 64.31909943, -158.7409973, 3986).
airport('KCA', 'Kuqa Airport', 3524, 41.7181015014648, 82.9869003295898, 5577).
airport('KHD', 'Khoram Abad Airport', 3782, 33.4353981018066, 48.282901763916, 10498).
airport('KHY', 'Khoy Airport', 3981, 38.4275016784668, 44.9735984802246, 9190).
airport('KIF', 'Kingfisher Lake Airport', 866, 53.0125007629395, -89.8553009033203, 3520).
airport('KRY', 'Karamay Airport', 1096, 45.46655, 84.9527, 8530).
airport('KTL', 'Kitale Airport', 6070, 0.97198897600174, 34.9585990905762, 4757).
airport('KTG', 'Ketapang(Rahadi Usman) Airport', 46, -1.81664001941681, 109.962997436523, 4585).
airport('KWK', 'Kwigillingok Airport', 18, 59.8764991760254, -163.169006347656, 1835).
airport('LAU', 'Manda Airstrip', 20, -2.25241994857788, 40.9131011962891, 3293).
airport('LAU', 'Manda Airstrip', 20, -2.25241994857788, 40.9131011962891, 2793).
airport('LAU', 'Manda Airstrip', 20, -2.25241994857788, 40.9131011962891, 2293).
airport('LBP', 'Long Banga Airport', 750, 3.202, 115.4018, 1804).
airport('LCR', 'La Chorrera Airport', 709, -0.733333, -73.01667, 4757).
airport('LKG', 'Lokichoggio Airport', 2074, 4.20412015914917, 34.348201751709, 6195).
airport('LMC', 'La Macarena Airport', 790, 2.17565, -73.78674, 5184).
airport('LPD', 'La Pedrera Airport', 590, -1.32861, -69.5797, 5643).
airport('LQM', 'Caucaya Airport', 573, -0.182278, -74.7708, 3937).
airport('LSA', 'Losuia Airport', 27, -8.50582027435303, 151.080993652344, 5348).
airport('MGT', 'Milingimbi Airport', 53, -12.0944004059, 134.893997192, 4626).
airport('MKQ', 'Mopah Airport', 10, -8.52029037475586, 140.417999267578, 6070).
airport('NIB', 'Nikolai Airport', 441, 63.0186004638672, -154.358001708984, 4021).
airport('GMA', 'Gemena Airport', 1378, 3.23536992073, 19.7712993622, 6550).
airport('MEH', 'Mehamn Airport', 39, 71.0297012329102, 27.8267002105713, 2887).
airport('ZFN', 'Tulita Airport', 332, 64.9096984863281, -125.572998046875, 3935).
airport('ZEM', 'Eastmain River Airport', 24, 52.2263984680176, -78.5224990844727, 3510).
airport('ZDY', 'Delma Island', 25, 24.509722, 52.335, 8202).
airport('ZGS', 'La Romaine Airport', 90, 50.2597007751465, -60.6794013977051, 3932).
airport('YXN', 'Whale Cove Airport', 40, 62.2400016785, -92.5980987549, 4000).
airport('YVM', 'Qikiqtarjuaq Airport', 21, 67.5457992554, -64.0314025879, 3800).
airport('YSO', 'Postville Airport', 193, 54.9105987548828, -59.7867012023926, 2675).
airport('YRG', 'Rigolet Airport', 180, 54.1796989440918, -58.4575004577637, 2680).
airport('YQC', 'Quaqtaq Airport', 103, 61.0463981628418, -69.6177978515625, 3520).
airport('YPO', 'Peawanuck Airport', 173, 54.9880981445312, -85.4432983398438, 3500).
airport('YOG', 'Ogoki Post Airport', 594, 51.6585998535, -85.9017028809, 3500).
airport('YNC', 'Wemindji Airport', 66, 53.0106010437012, -78.8311004638672, 3510).
airport('YIO', 'Pond Inlet Airport', 181, 72.6832962036, -77.9666976929, 4000).
airport('YIK', 'Ivujivik Airport', 126, 62.4173011779785, -77.9253005981445, 3521).
airport('YIE', 'Yiershi Airport', 3182, 47.310556, 119.911944, 7874).
airport('YHR', 'Chevery Airport', 39, 50.4688987731934, -59.6366996765137, 4500).
airport('YHI', 'Ulukhaktok Holman Airport', 117, 70.7628021240234, -117.805999755859, 4300).
airport('YGH', 'Fort Good Hope Airport', 268, 66.2407989501953, -128.651000976562, 3000).
airport('YFJ', 'Wekweètì Airport', 1208, 64.1908035278, -114.077003479, 3000).
airport('YEV', 'Inuvik Mike Zubko Airport', 224, 68.3041992188, -133.483001709, 6000).
airport('YES', 'Yasouj Airport', 5939, 30.7005004882812, 51.5451011657715, 8522).
airport('YEK', 'Arviat Airport', 32, 61.0942001343, -94.0708007812, 4000).
airport('YDP', 'Nain Airport', 22, 56.5491981506348, -61.6803016662598, 2000).
airport('YBX', 'Lourdes de Blanc Sablon Airport', 121, 51.4435997009, -57.1852989197, 4500).
airport('YBK', 'Baker Lake Airport', 59, 64.2988967896, -96.077796936, 4200).
airport('YAC', 'Cat Lake Airport', 1344, 51.7271995544434, -91.8244018554688, 3900).
airport('XKS', 'Kasabonika Airport', 672, 53.5247001647949, -88.6427993774414, 3500).
airport('XBE', 'Bearskin Lake Airport', 800, 53.9655990600586, -91.0271987915039, 3500).
airport('WNR', 'Windorah Airport', 452, -25.4130992889404, 142.667007446289, 4508).
airport('WMR', 'Mananara Nord Airport', 9, -16.1639003753662, 49.7737998962402, 4101).
airport('VEE', 'Venetie Airport', 574, 67.0086975098, -146.365997314, 4000).
airport('UTS', 'Ust-Tsylma Airport', 262, 65.4372940063, 52.2003364563, 4370).
airport('USK', 'Usinsk Airport', 262, 66.0046997070312, 57.3671989440918, 8209).
airport('URG', 'Rubem Berta Airport', 256, -29.7821998596, -57.0382003784, 4921).
airport('URG', 'Rubem Berta Airport', 256, -29.7821998596, -57.0382003784, 4421).
airport('UKA', 'Ukunda Airstrip', 98, -4.29333019256592, 39.5710983276367, 3609).
airport('UAS', 'Samburu South Airport', 3295, 0.530583024024963, 37.5341949462891, 3281).
airport('UAP', 'Ua Pou Airport', 16, -9.35167026519775, -140.078002929688, 2723).
airport('UAK', 'Narsarsuaq Airport', 112, 61.1604995728, -45.4259986877, 6004).
airport('UAH', 'Ua Huka Airport', 160, -8.93610954284668, -139.552001953125, 2477).
airport('TRR', 'China Bay Airport', 6, 8.5385103225708, 81.1819000244141, 7850).
airport('TQL', 'Tarko-Sale Airport', 80, 64.9308013916, 77.8180999756, 6562).
airport('TOH', 'Torres Airstrip', 75, -13.3280000687, 166.638000488, 2789).
airport('TOG', 'Togiak Airport', 21, 59.0527992248535, -160.397003173828, 4400).
airport('TOG', 'Togiak Airport', 21, 59.0527992248535, -160.397003173828, 3900).
airport('TMT', 'Trombetas Airport', 287, -1.48959994316101, -56.396800994873, 5249).
airport('TKP', 'Takapoto Airport', 12, -14.7095003128052, -145.246002197266, 3018).
airport('TCG', 'Tacheng Airport', 1982, 46.6725006103516, 83.3407974243164, 5052).
airport('SNV', 'Santa Elena de Uairen Airport', 2938, 4.55499982833862, -61.1500015258789, 5445).
airport('SLX', 'Salt Cay Airport', 3, 21.3330001831, -71.1999969482, 2697).
airport('SJL', 'São Gabriel da Cachoeira Airport', 251, -0.14835, -66.9855, 8530).
airport('RCM', 'Richmond Airport', 676, -20.7019004821777, 143.115005493164, 5000).
airport('PZH', 'Zhob Airport', 4728, 31.3584003448486, 69.4636001586914, 6001).
airport('PVA', 'El Embrujo Airport', 10, 13.3569, -81.3583, 3832).
airport('PND', 'Punta Gorda Airport', 7, 16.102399826, -88.8082962036, 2297).
airport('PGU', 'Persian Gulf International Airport', 27, 27.3796005249023, 52.7377014160156, 13115).
airport('PFQ', 'Parsabade Moghan Airport', 251, 39.6035995483398, 47.8815002441406, 8515).
airport('PBU', 'Putao Airport', 1500, 27.3299007415771, 97.4263000488281, 7002).
airport('PAC', 'Marcos A. Gelabert International Airport', 31, 8.97334003448486, -79.5556030273438, 5906).
airport('ORZ', 'Orange Walk Airport', 111, 18.0467662811, -88.5838699341, 2297).
airport('ORU', 'Juan Mendoza Airport', 12152, -17.962600708, -67.0762023926, 8075).
airport('ORU', 'Juan Mendoza Airport', 12152, -17.962600708, -67.0762023926, 7575).
airport('ONG', 'Mornington Island Airport', 33, -16.6625003814697, 139.177993774414, 4987).
airport('ONG', 'Mornington Island Airport', 33, -16.6625003814697, 139.177993774414, 4487).
airport('OLC', 'Senadora Eunice Micheles Airport', 335, -3.46792950765, -68.9204120636, 3937).
airport('OKL', 'Oksibil Airport', 2500, -5.09106016159058, 140.610000610352, 2854).
airport('NTX', 'Ranai Airport', 7, 3.90871000289917, 108.388000488281, 8410).
airport('NQU', 'Reyes Murillo Airport', 12, 5.6964, -77.2806, 2427).
airport('NNM', 'Naryan Mar Airport', 36, 67.6399993896484, 53.121898651123, 8406).
airport('KSA', 'Kosrae International Airport', 11, 5.35697984695, 162.957992554, 5750).
airport('NLT', 'Xinyuan Nalati Airport', 3051, 43.433056, 83.380278, 7546).
airport('NLG', 'Nelson Lagoon Airport', 14, 56.0074996948242, -161.160003662109, 4003).
airport('NBX', 'Nabire Airport', 20, -3.3681800365448, 135.496002197266, 4593).
airport('MTV', 'Mota Lava Airport', 63, -13.6660003662, 167.712005615, 2953).
airport('MSA', 'Muskrat Dam Airport', 911, 53.4413986206055, -91.7628021240234, 3500).
airport('KGX', 'Grayling Airport', 137, 62.8945999146, -160.065002441, 4000).
airport('KAE', 'Kake Airport', 171, 56.9613990784, -133.910003662, 4000).
airport('JUV', 'Upernavik Airport', 414, 72.7901992798, -56.1305999756, 2621).
airport('JQA', 'Qaarsut Airport', 289, 70.7341995239, -52.6962013245, 2953).
airport('SHC', 'Shire Inda Selassie Airport', 6207, 14.0781002044678, 38.2724990844727, 7694).
airport('SDV', 'Sde Dov Airport', 43, 32.1147003173828, 34.7821998596191, 5712).
airport('SDG', 'Sanandaj Airport', 4522, 35.2458992004395, 47.0092010498047, 8660).
airport('RIB', 'Capitán Av. Selin Zeitun Lopez Airport', 462, -11.0, -66.0, 5906).
airport('ZTB', 'Tête-à-la-Baleine Airport', 107, 50.6744003295898, -59.3835983276367, 1640).
airport('ZPB', 'Sachigo Lake Airport', 876, 53.8911018371582, -92.196403503418, 3500).
airport('ZLT', 'La Tabatière Airport', 102, 50.8307991027832, -58.9756011962891, 1640).
airport('YIF', 'St Augustin Airport', 20, 51.2117004395, -58.6582984924, 4590).
airport('ZKG', 'Kegaska Airport', 32, 50.1958007812, -61.2658004761, 1640).
airport('ARC', 'Arctic Village Airport', 2092, 68.1147003173828, -145.578994750977, 4500).
airport('ZFM', 'Fort Mcpherson Airport', 116, 67.4075012207031, -134.860992431641, 3500).
airport('YZG', 'Salluit Airport', 743, 62.1794013977051, -75.6671981811523, 3500).
airport('YWB', 'Kangiqsujuaq (Wakeham Bay) Airport', 501, 61.5886001587, -71.929397583, 3511).
airport('YUB', 'Tuktoyaktuk Airport', 15, 69.4332962036133, -133.026000976562, 5000).
airport('YSY', 'Sachs Harbour (David Nasogaluak Jr. Saaryuaq) Airport', 282, 71.9938964844, -125.242996216, 4000).
airport('YPC', 'Paulatuk (Nora Aliqatchialuk Ruben) Airport', 15, 69.3608381154, -124.075469971, 4000).
airport('YNP', 'Natuashish Airport', 30, 55.9138984680176, -61.184398651123, 2500).
airport('YMN', 'Makkovik Airport', 234, 55.0769004821777, -59.1864013671875, 2500).
airport('YHO', 'Hopedale Airport', 39, 55.448299407959, -60.2285995483398, 2500).
airport('YTL', 'Big Trout Lake Airport', 729, 53.817798614502, -89.8968963623047, 3900).
airport('YGZ', 'Grise Fiord Airport', 146, 76.4261016846, -82.9092025757, 1988).
airport('YRB', 'Resolute Bay Airport', 215, 74.7169036865, -94.9693984985, 6500).
airport('YAB', 'Arctic Bay Airport', 72, 73.0057668174, -85.0425052643, 3935).
airport('THU', 'Thule Air Base', 251, 76.5311965942, -68.7032012939, 9997).
airport('THU', 'Thule Air Base', 251, 76.5311965942, -68.7032012939, 9497).
airport('NAQ', 'Qaanaaq Airport', 51, 77.4886016846, -69.3887023926, 2953).
airport('OLH', 'Old Harbor Airport', 55, 57.2181015014648, -153.270004272461, 2750).
airport('INI', 'Nis Constantine the Great Airport', 648, 43.337299, 21.853701, 8202).
airport('PNI', 'Pohnpei International Airport', 10, 6.98509979248047, 158.208999633789, 6001).
airport('SZI', 'Zaisan (Zaysan) Airport', 1900, 47.487083, 84.888156, 4938).
airport('TUR', 'Tucuruí Airport', 830, -3.78601002693176, -49.7202987670898, 6562).
airport('YAX', 'Wapekeka Airport', 712, 53.8492012023926, -89.5793991088867, 3600).
airport('YER', 'Fort Severn Airport', 48, 56.0189018249512, -87.6761016845703, 3500).
airport('ZSJ', 'Sandy Lake Airport', 951, 53.0642013549805, -93.3443984985352, 3500).
airport('YVZ', 'Deer Lake Airport', 1092, 52.6557998657227, -94.0614013671875, 3500).
airport('YPM', 'Pikangikum Airport', 1114, 51.8196983337402, -93.9732971191406, 3500).
airport('KEW', 'Keewaywin Airport', 988, 52.9911003113, -92.8364028931, 3500).
airport('YHP', 'Poplar Hill Airport', 1095, 52.1133003234863, -94.2555999755859, 3500).
airport('YNO', 'North Spirit Lake Airport', 1082, 52.4900016784668, -92.9710998535156, 3500).
airport('YHD', 'Dryden Regional Airport', 1354, 49.8316993713379, -92.7442016601562, 6000).
airport('YHD', 'Dryden Regional Airport', 1354, 49.8316993713379, -92.7442016601562, 5500).
airport('ZRJ', 'Round Lake (Weagamow Lake) Airport', 974, 52.9435997009277, -91.3127975463867, 3500).
airport('TTA', 'Tan Tan Airport', 653, 28.4482002258301, -11.1612997055054, 6562).
airport('SXK', 'Saumlaki/Olilit Airport', 218, -7.9886097908, 131.305999756, 2953).
airport('SVK', 'Silver Creek Airport', 216, 16.7252998352051, -88.3399963378906, 2900).
airport('INB', 'Independence Airport, Stann Creek', 18, 16.5345001220703, -88.4412994384766, 2720).
airport('RIG', 'Rio Grande Airport', 27, -32.081699, -52.163299, 4921).
airport('SHG', 'Shungnak Airport', 197, 66.8880996704102, -157.162002563477, 4000).
airport('OBU', 'Kobuk Airport', 137, 66.9123001099, -156.897003174, 4000).
airport('SCM', 'Scammon Bay Airport', 14, 61.8452987671, -165.570999146, 3000).
airport('SWO', 'Stillwater Regional Airport', 1000, 36.1612014770508, -97.0857009887695, 7401).
airport('SWO', 'Stillwater Regional Airport', 1000, 36.1612014770508, -97.0857009887695, 6901).
airport('SWO', 'Stillwater Regional Airport', 1000, 36.1612014770508, -97.0857009887695, 6401).
airport('KNO', 'Medan/Kualanamu International Airport', 90, 3.642222, 98.885278, 9514).
airport('NAA', 'Narrabri Airport', 788, -30.3192005157, 149.82699585, 5000).
airport('NAA', 'Narrabri Airport', 788, -30.3192005157, 149.82699585, 4500).
airport('LUV', 'Dumatumbun Airport', 10, -5.66162014007568, 132.731002807617, 4265).
airport('DOB', 'Rar Gwamar Airport', 61, -5.77222013474, 134.212005615, 2625).
airport('ZIA', 'Ramenskoye Airport', 404, 55.5532989501953, 38.1500015258789, 15092).
airport('CFG', 'Jaime Gonzalez Airport', 102, 22.1499996185303, -80.4141998291016, 7874).
airport('CDT', 'Castellon De La Plana Airport', 20, 39.9991989136, 0.0261109992862, 3117).
airport('LCJ', 'Łódź Władysław Reymont Airport', 604, 51.7219009399, 19.3980998993, 8022).
airport('LCJ', 'Łódź Władysław Reymont Airport', 604, 51.7219009399, 19.3980998993, 7522).
airport('HLP', 'Halim Perdanakusuma International Airport', 84, -6.26661014556885, 106.890998840332, 9843).
airport('BCM', 'Bacău Airport', 607, 46.521900177002, 26.9102993011475, 8203).
airport('NIF', 'Camp Nifty Airport', 295, -21.6716995239258, 121.58699798584, 5577).
airport('INT', 'Smith Reynolds Airport', 969, 36.1337013244629, -80.2220001220703, 6655).
airport('INT', 'Smith Reynolds Airport', 969, 36.1337013244629, -80.2220001220703, 6155).
airport('APA', 'Centennial Airport', 5885, 39.57009888, -104.848999, 10002).
airport('APA', 'Centennial Airport', 5885, 39.57009888, -104.848999, 9502).
airport('APA', 'Centennial Airport', 5885, 39.57009888, -104.848999, 9002).
airport('USA', 'Concord Regional Airport', 705, 35.3877983093262, -80.709098815918, 7403).
airport('DAM', 'Damascus International Airport', 2020, 33.4114990234375, 36.5155982971191, 11811).
airport('DAM', 'Damascus International Airport', 2020, 33.4114990234375, 36.5155982971191, 11311).
airport('NAL', 'Nalchik Airport', 1461, 43.5129013061523, 43.6366004943848, 7218).
airport('SZY', 'Olsztyn-Mazury Airport', 463, 53.481858, 20.937692, 6562).
airport('VDA', 'Ovda International Airport', 1492, 29.940299987793, 34.9357986450195, 9843).
airport('VDA', 'Ovda International Airport', 1492, 29.940299987793, 34.9357986450195, 9343).
airport('WTB', 'Brisbane West Wellcamp Airport', 1509, -27.558332, 151.793333, 9416).
airport('BLB', 'Panama Pacific International Airport', 52, 8.9147901535, -79.5996017456, 8500).
airport('OMC', 'Ormoc Airport', 83, 11.0579996109009, 124.565002441406, 6120).
airport('BWU', 'Sydney Bankstown Airport', 29, -33.9244003295898, 150.988006591797, 4644).
airport('BWU', 'Sydney Bankstown Airport', 29, -33.9244003295898, 150.988006591797, 4144).
airport('BWU', 'Sydney Bankstown Airport', 29, -33.9244003295898, 150.988006591797, 3644).
airport('VRB', 'Vero Beach Municipal Airport', 24, 27.6555995941162, -80.4179000854492, 7314).
airport('VRB', 'Vero Beach Municipal Airport', 24, 27.6555995941162, -80.4179000854492, 6814).
airport('VRB', 'Vero Beach Municipal Airport', 24, 27.6555995941162, -80.4179000854492, 6314).
airport('SUN', 'Friedman Memorial Airport', 5318, 43.50439835, -114.2959976, 6952).
airport('BID', 'Block Island State Airport', 108, 41.1680984497, -71.577796936, 2502).
airport('DVL', 'Devils Lake Regional Airport', 1456, 48.11420059, -98.90879822, 5509).
airport('DVL', 'Devils Lake Regional Airport', 1456, 48.11420059, -98.90879822, 5009).
airport('JMS', 'Jamestown Regional Airport', 1500, 46.92969894, -98.67819977, 6500).
airport('JMS', 'Jamestown Regional Airport', 1500, 46.92969894, -98.67819977, 6000).
airport('HYS', 'Hays Regional Airport', 1999, 38.84220123, -99.27320099, 6500).
airport('HYS', 'Hays Regional Airport', 1999, 38.84220123, -99.27320099, 6000).
airport('MCW', 'Mason City Municipal Airport', 1213, 43.1577987671, -93.3312988281, 6501).
airport('MCW', 'Mason City Municipal Airport', 1213, 43.1577987671, -93.3312988281, 6001).
airport('NBW', 'Leeward Point Field', 56, 19.9064998626709, -75.2070999145508, 8000).
airport('SFH', 'San Felipe International Airport', 148, 30.9302005767822, -114.80899810791, 4921).
airport('SHF', 'Shikezi Huayuan Airport', 1690, 44.242064, 85.890539, 7874).
airport('BPE', 'Qinhuangdao Beidaihe Airport', 46, 39.666389, 119.061389, 8530).
airport('FYJ', 'Fuyuan Dongji Airport', 190, 48.19949, 134.366447, 8202).
airport('PNT', 'Teniente Julio Gallardo Airport', 217, -51.671501159668, -72.5283966064453, 5786).
airport('LLV', 'Luliang Airport', 1273, 37.681667, 111.142778, 8530).
airport('WEH', 'Weihai Airport', 145, 37.1870994567871, 122.228996276855, 8530).
airport('WDS', 'Shiyan Wudangshan Airport', 1207, 32.593056, 110.905833, 8530).
airport('UCB', 'Ulanqab Airport', 4622, 41.13, 113.106389, 8530).
airport('TNH', 'Tonghua Sanyuanpu Airport', 1200, 42.2538888889, 125.703333333, 7874).
airport('TLQ', 'Turpan Jiaohe Airport', 108, 43.030556, 89.098611, 9186).
airport('THQ', 'Tianshui Maijishan Airport', 3590, 34.5593986511, 105.86000061, 9186).
airport('SQJ', 'Sanming Shaxian Airport', 889, 26.426111, 117.833611, 8530).
airport('RKZ', 'Shigatse Peace Airport', 12408, 29.351944, 89.310278, 16404).
airport('RIZ', 'Rizhao Shanzihe Airport', 98, 35.402, 119.32, 8530).
airport('LPF', 'Liupanshui Yuezhao Airport', 6440, 26.608889, 104.978333, 9186).
airport('CVN', 'Clovis Municipal Airport', 4216, 34.4250984192, -103.07900238, 6200).
airport('CVN', 'Clovis Municipal Airport', 4216, 34.4250984192, -103.07900238, 5700).
airport('CVN', 'Clovis Municipal Airport', 4216, 34.4250984192, -103.07900238, 5200).
airport('CVT', 'Coventry Airport', 267, 52.3697013855, -1.47971999645, 5988).
airport('SZF', 'Samsun Çarşamba Airport', 18, 41.2545013428, 36.5671005249, 9843).
airport('KHE', 'Chernobayevka Airport', 148, 46.6758003235, 32.506401062, 8202).
airport('NKT', 'Sirnak Airport', 2038, 37.359722, 42.0625, 9843).
airport('YKO', 'Hakkari Selahaddin Eyyubi Airport', 2038, 37.551667, 44.233611, 10499).
airport('OGU', 'Ordu Giresun Airport', 18, 40.966667, 38.066667, 9843).
airport('AFW', 'Fort Worth Alliance Airport', 722, 32.9875984192, -97.3188018799, 9600).
airport('AFW', 'Fort Worth Alliance Airport', 722, 32.9875984192, -97.3188018799, 9100).
airport('IWD', 'Gogebic Iron County Airport', 1230, 46.5275001526, -90.131401062, 6501).
airport('LFQ', 'Linfen Qiaoli Airport', 1620, 36.041944, 111.492222, 8530).
airport('KJI', 'Kanas Airport', 3898, 48.222222, 86.995556, 8202).
airport('MEB', 'Melbourne Essendon Airport', 282, -37.728099822998, 144.901992797852, 6302).
airport('MEB', 'Melbourne Essendon Airport', 282, -37.728099822998, 144.901992797852, 5802).
airport('ENF', 'Enontekio Airport', 1005, 68.3626022338867, 23.4242992401123, 6565).
airport('WMB', 'Warrnambool Airport', 242, -38.2952995300293, 142.447006225586, 4501).
airport('WMB', 'Warrnambool Airport', 242, -38.2952995300293, 142.447006225586, 4001).
airport('PTJ', 'Portland Airport', 265, -38.3180999755859, 141.470993041992, 5202).
airport('PTJ', 'Portland Airport', 265, -38.3180999755859, 141.470993041992, 4702).
airport('CMF', 'Chambéry-Savoie Airport', 779, 45.6380996704102, 5.88022994995117, 6628).
airport('MZO', 'Sierra Maestra Airport', 112, 20.2880992889404, -77.0892028808594, 7875).
airport('TEX', 'Telluride Regional Airport', 9069, 37.9538002, -107.9079971, 7111).
airport('LPK', 'Lipetsk Airport', 585, 52.7028007507324, 39.5377998352051, 7546).
airport('ULY', 'Ulyanovsk East Airport', 253, 54.4010009765625, 48.8027000427246, 16404).
airport('FOD', 'Fort Dodge Regional Airport', 1156, 42.55149841, -94.19259644, 6547).
airport('FOD', 'Fort Dodge Regional Airport', 1156, 42.55149841, -94.19259644, 6047).
airport('HUZ', 'Huizhou Airport', 50, 23.0499992371, 114.599998474, 7874).
airport('HZG', 'Hanzhong Airport', 1657, 33.0635986328125, 107.008003234863, 8203).
airport('HNY', 'Hengyang Airport', 305, 26.9053001403809, 112.627998352051, 8530).
airport('YKH', 'Yingkou Lanqi Airport', 2, 40.542222, 122.358333, 8202).
airport('MPN', 'Mount Pleasant Airport', 244, -51.8227996826172, -58.4472007751465, 8497).
airport('MPN', 'Mount Pleasant Airport', 244, -51.8227996826172, -58.4472007751465, 7997).
airport('PSY', 'Stanley Airport', 75, -51.6856994628906, -57.7775993347168, 3013).
airport('PSY', 'Stanley Airport', 75, -51.6856994628906, -57.7775993347168, 2513).
airport('ASI', 'RAF Ascension Island', 278, -7.96960020065308, -14.3936996459961, 10019).
airport('BZZ', 'RAF Brize Norton', 288, 51.749964, -1.58361995220184, 10007).
airport('HLE', 'St. Helena Airport', 1017, -15.959166, -5.645832, 6398).
airport('RKT', 'Ras Al Khaimah International Airport', 102, 25.6135005950928, 55.9388008117676, 12336).
airport('KAC', 'Kamishly Airport', 1480, 37.0205993652344, 41.1913986206055, 11860).
airport('GNB', 'Grenoble Alpes-Isère Airport', 1302, 45.3628997802734, 5.32937002182007, 10007).
airport('FYN', 'Fuyun Kroktokay Airport', 3064, 46.811897, 89.555514, 8530).
airport('MNI', 'John A. Osborne Airport', 550, 16.7914009094238, -62.1932983398438, 1968).
airport('THG', 'Thangool Airport', 644, -24.4939002990723, 150.57600402832, 4993).
airport('THG', 'Thangool Airport', 644, -24.4939002990723, 150.57600402832, 4493).
airport('TDK', 'Taldykorgan Airport', 1925, 45.1262016296387, 78.4469985961914, 9846).
airport('XTO', 'Taroom Airport', 240, -25.801700592041, 149.899993896484, 3609).
airport('XTO', 'Taroom Airport', 240, -25.801700592041, 149.899993896484, 3109).
airport('CCL', 'Chinchilla Airport', 1028, -26.7749996185303, 150.617004394531, 3497).
airport('CCL', 'Chinchilla Airport', 1028, -26.7749996185303, 150.617004394531, 2997).
airport('TQP', 'Trepell Airport', 891, -21.8349990844727, 140.888000488281, 5903).
airport('RDP', 'Kazi Nazrul Islam Airport', 289, 23.6225, 87.242778, 9186).
airport('IFP', 'Laughlin Bullhead International Airport', 698, 35.15739822, -114.5599976, 7500).
airport('KXK', 'Komsomolsk-on-Amur Airport', 92, 50.4090003967285, 136.934005737305, 8202).
airport('GMQ', 'Golog Maqin Airport', 12427, 34.415833, 100.311111, 12467).
airport('GYU', 'Guyuan Liupanshan Airport', 5577, 36.078611, 106.216667, 8858).
airport('HPG', 'Shennongjia Hongping Airport', 8465, 31.633611, 110.338056, 9186).
airport('HTT', 'Huatugou Airport', 9662, 38.203333, 90.841667, 11811).
airport('HCJ', 'Hechi Jin Cheng Jiang Airport', 2221, 24.783889, 107.699722, 7218).
airport('SCV', 'Suceava Stefan cel Mare Airport', 1375, 47.6875, 26.3540992736816, 5906).
airport('VIT', 'Vitoria/Foronda Airport', 1682, 42.8828010559082, -2.72446990013123, 11483).
airport('IQM', 'Qiemo Yudu Airport', 4108, 38.233611, 85.465556, 9186).
airport('KJH', 'Kaili Huangping Airport', 3115, 26.971667, 107.987778, 8530).
airport('HXD', 'Delingha Airport', 9383, 37.125, 97.268611, 9843).
airport('AHJ', 'Hongyuan Aba  Airport', 11598, 32.531389, 102.352222, 11811).
airport('CWC', 'Chernivtsi International Airport', 826, 48.2593002319336, 25.9808006286621, 7270).
airport('BZK', 'Bryansk Airport', 666, 53.2141990662, 34.176399231, 7874).
airport('UZR', 'Urdzhar Airport', 1680, 47.09115, 81.66521, 4957).
airport('BBL', 'Ballera Airport', 385, -27.4083003997803, 141.807998657227, 5906).
airport('MOO', 'Moomba Airport', 143, -28.0993995666504, 140.197006225586, 5636).
airport('VTB', 'Vitebsk East Airport', 683, 55.1264991760254, 30.3495998382568, 8550).
airport('ANE', 'Marce, Angers - Loire Airport', 194, 47.5602989196777, -0.312222003936768, 5906).
airport('ANE', 'Marce, Angers - Loire Airport', 194, 47.5602989196777, -0.312222003936768, 5406).
airport('URO', 'Vallee de Seine Airport', 512, 49.3842010498047, 1.17480003833771, 5577).
airport('URO', 'Vallee de Seine Airport', 512, 49.3842010498047, 1.17480003833771, 5077).
airport('LOV', 'Venustiano Carranza International Airport', 1864, 26.9556999206543, -101.470001220703, 6890).
airport('LOV', 'Venustiano Carranza International Airport', 1864, 26.9556999206543, -101.470001220703, 6390).
airport('OHS', 'Sohar Airport', 105, 24.386167, 56.625667, 13100).
airport('FIE', 'Shetland Islands, Fair Isle Airport', 223, 59.5358009338379, -1.62805998325348, 1667).
airport('LWK', 'Tingwall Airport', 43, 60.192199707, -1.24361002445, 2395).
airport('FOA', 'Foula Airport', 150, 60.1209983825684, -2.05200004577637, 1444).
airport('PSV', 'Papa Stour Airport', 59, 60.3217010498047, -1.69306004047394, 1465).
airport('NDZ', 'Nordholz-Spieka', 74, 53.7677001953, 8.65849971771, 8002).
airport('WOL', 'Illawarra Regional Airport', 31, -34.5611, 150.788611, 5967).
airport('OND', 'Ondangwa Airport', 3599, -17.8782005310059, 15.9525995254517, 9800).
airport('GAY', 'Gaya Airport', 380, 24.7443008422852, 84.9512023925781, 7500).
airport('ENI', 'El Nido Airport', 17, 11.2019996643066, 119.416999816895, 3280).
airport('IGT', 'Magas Airport', 1207, 43.3222999573, 45.0125999451, 9843).
airport('EPA', 'El Palomar Airport', 59, -34.6099, -58.6126, 6923).
airport('YHG', 'Charlottetown Airport', 209, 52.7649993896484, -56.1156005859375, 2502).
airport('MBX', 'Maribor Airport', 876, 46.4799003601074, 15.6861000061035, 8202).
airport('MBX', 'Maribor Airport', 876, 46.4799003601074, 15.6861000061035, 7702).
airport('KLF', 'Grabtsevo Airport', 666, 54.548611, 36.371389, 7218).
airport('JSK', 'Jask Airport', 19, 25.653600692749, 57.7993011474609, 6200).
airport('CAT', 'Cascais Airport', 325, 38.7249984741211, -9.3552303314209, 4593).
airport('VRL', 'Vila Real Airport', 1805, 41.274299621582, -7.72046995162964, 3107).
airport('VSE', 'Viseu Airport', 2060, 40.7254981994629, -7.88898992538452, 4015).
airport('PRM', 'Portimao Airport', 5, 37.149299621582, -8.58395957946777, 2819).
airport('BGC', 'Braganca Airport', 2241, 41.85779953, -6.70712995529, 5600).
airport('CNQ', 'Corrientes Airport', 202, -27.445502, -58.761863, 6890).
airport('YAZ', 'Long Beach Airport', 80, 49.0798255464, -125.775604248, 5000).
airport('YAZ', 'Long Beach Airport', 80, 49.0798255464, -125.775604248, 4500).
airport('YAZ', 'Long Beach Airport', 80, 49.0798255464, -125.775604248, 4000).
airport('OHD', 'Ohrid St. Paul the Apostle Airport', 2313, 41.179956, 20.7423000335693, 8366).
airport('MKZ', 'Malacca Airport', 40, 2.263056, 102.2525, 7005).
airport('CHR', 'Châteauroux-Déols Marcel Dassault Airport', 529, 46.8622016906738, 1.73066997528076, 11483).
airport('TLK', 'Talakan Airport', 1330, 59.881667, 111.045556, 10171).
airport('GRS', 'Grosseto Airport', 15, 42.7597007751465, 11.0719003677368, 9823).
airport('GRS', 'Grosseto Airport', 15, 42.7597007751465, 11.0719003677368, 9323).
airport('HHQ', 'Hua Hin Airport', 62, 12.6361999512, 99.951499939, 6890).
airport('GME', 'Gomel Airport', 471, 52.5270004272461, 31.0167007446289, 8432).
airport('CRV', "Crotone-Sant'Anna Airport", 521, 38.997200012207, 17.0802001953125, 6562).
airport('NLI', 'Nikolayevsk-na-Amure Airport', 187, 53.1549987792969, 140.649993896484, 6112).
airport('EKA', 'Murray Field', 7, 40.8033981323, -124.112998962, 3011).
airport('CVQ', 'Carnarvon Airport', 13, -24.8805999755859, 113.671997070312, 5509).
airport('CVQ', 'Carnarvon Airport', 13, -24.8805999755859, 113.671997070312, 5009).
airport('MJK', 'Shark Bay Airport', 111, -25.8938999176, 113.577003479, 5545).
airport('GOB', 'Robe Airport', 7892, 7.1160634, 40.0463033, 6562).
airport('AWA', 'Awassa Airport', 5604, 7.067222, 38.490278, 3937).
airport('JRH', 'Jorhat Airport', 311, 26.7315006256, 94.1754989624, 9000).
airport('BYK', 'Bouaké Airport', 1230, 7.73880004882812, -5.07366991043091, 10827).
airport('DTB', 'Silangit Airport', 4059, 2.25973010063171, 98.9918975830078, 5225).
airport('TKQ', 'Kigoma Airport', 2700, -4.8862, 29.6709, 5906).
airport('AEH', 'Abeche Airport', 1788, 13.8470001220703, 20.8442993164062, 9186).
airport('SRH', 'Sarh Airport', 1198, 9.14443969726562, 18.3743991851807, 5905).
airport('DSS', 'Blaise Diagne International Airport', 290, 14.670833, -17.072777, 11483).
airport('MQQ', 'Moundou Airport', 1407, 8.62440967559814, 16.0713996887207, 5906).
airport('FYT', 'Faya-Largeau Airport', 771, 17.9171009063721, 19.1110992431641, 9186).
airport('ERH', 'Moulay Ali Cherif Airport', 3428, 31.9475002289, -4.39833021164, 10499).
airport('DRT', 'Del Rio International Airport', 1002, 29.3742008209, -100.927001953, 6300).
airport('BAR', "Bo'ao Airport", 52, 19.138889, 110.454167, 8858).
airport('USJ', 'Usharal Airport', 1293, 46.1908, 80.8309, 7546).
airport('TYL', 'Capitan Montes Airport', 282, -4.57664012908936, -81.2540969848633, 8071).
airport('CNN', 'Kannurl International Airport', 344, 11.92, 75.55, 10007).
airport('JAE', 'Shumba Airport', 2477, -5.591388, -78.771388, 7874).
airport('INF', 'In Guezzam Airport', 1325, 19.5669994354248, 5.75, 7218).
airport('KLB', 'Kalabo Airport', 3450, -14.9982995986938, 22.6453990936279, 3609).
airport('VDO', 'Van Don International Airport', 26, 21.117778, 107.414167, 11811).
airport('RMU', 'Region of Murcia International Airport', 633, 37.803, -1.125, 9842).
airport('PAE', 'Snohomish County (Paine Field) Airport', 607, 47.90629959, -122.2819977, 9010).
airport('PAE', 'Snohomish County (Paine Field) Airport', 607, 47.90629959, -122.2819977, 8510).
airport('PAE', 'Snohomish County (Paine Field) Airport', 607, 47.90629959, -122.2819977, 8010).
airport('LUA', 'Tenzing-Hillary Airport', 9100, 27.6868991851807, 86.7296981811523, 1500).
airport('MRQ', 'Gasan Airport', 32, 13.3610000610352, 121.825996398926, 4785).
airport('SHI', 'Shimojishima Airport', 54, 24.8267002106, 125.144996643, 9842).
airport('BXG', 'Bendigo Airport', 705, -36.7393989563, 144.330001831, 3724).
airport('BXG', 'Bendigo Airport', 705, -36.7393989563, 144.330001831, 3224).
airport('UAR', 'Bouarfa Airport', 3680, 32.5143055556, -1.98305555556, 10499).
airport('TRA', 'Tarama Airport', 36, 24.6539001465, 124.675003052, 4921).
airport('ISL', 'Ataturk International Airport', 163, 40.9768981934, 28.8145999908, 9843).
airport('ISL', 'Ataturk International Airport', 163, 40.9768981934, 28.8145999908, 9343).
airport('ISL', 'Ataturk International Airport', 163, 40.9768981934, 28.8145999908, 8843).
airport('USQ', 'Uşak Airport', 2897, 38.6814994812012, 29.471700668335, 8385).
airport('MJI', 'Mitiga Airport', 36, 32.894100189209, 13.2760000228882, 11076).
airport('MJI', 'Mitiga Airport', 36, 32.894100189209, 13.2760000228882, 10576).
airport('SXZ', 'Siirt Airport', 2001, 37.9789009094238, 41.8404006958008, 5905).
airport('XSP', 'Seletar Airport', 45, 1.4169499874115, 103.86799621582, 6024).
airport('ZTA', 'Tureia Airport', 12, -20.7896995544434, -138.570007324219, 3445).
airport('BFM', 'Mobile Downtown Airport', 26, 30.6268005371, -88.0680999756, 9618).
airport('BFM', 'Mobile Downtown Airport', 26, 30.6268005371, -88.0680999756, 9118).
airport('NUK', 'Nukutavake Airport', 17, -19.2849998474121, -138.772003173828, 2789).
airport('DBB', 'Al Alamein International Airport', 143, 30.9244995117188, 28.4613990783691, 11479).
airport('GGR', 'Garowe International Airport', 1465, 8.458333, 48.567778, 8202).
airport('KJT', 'Kertajati International Airport', 134, -6.647777, 108.166111, 11483).
airport('TSL', 'Tamuin National Airport', 164, 22.038292, -98.806502, 4735).
airport('PKX', 'Beijing Daxing International Airport', 98, 39.509167, 116.410556, 12467).
airport('PKX', 'Beijing Daxing International Airport', 98, 39.509167, 116.410556, 11967).
airport('PKX', 'Beijing Daxing International Airport', 98, 39.509167, 116.410556, 11467).
airport('PKX', 'Beijing Daxing International Airport', 98, 39.509167, 116.410556, 10967).
airport('BZX', 'Bazhong Enyang Airport', 1804, 31.737778, 106.642778, 8530).
airport('DBC', "Chang'an", 479, 45.505278, 123.019722, 8202).
airport('ETM', 'Ramon International Airport', 42, 29.723694, 35.723694, 11811).
airport('KET', 'Kengtung Airport', 2798, 21.301611, 99.635997, 11811).
airport('KFE', 'Fortescue - Dave Forrest Aerodrome', 1565, -22.2854555556, 119.429161111, 7546).
airport('KHM', 'Kanti Airport', 6000, 25.9883003234863, 95.6744003295898, 4200).
airport('KTR', 'Tindal Airport', 443, -14.5211000442505, 132.378005981445, 2744).
airport('MNC', 'Nacala Airport', 410, -14.4882001876831, 40.7122001647949, 8202).
airport('SQD', 'Shangrao Sanqingshan Airport', 340, 28.379444, 117.964167, 7874).
airport('BPG', 'Barra do Garças Airport', 1147, -15.8613004684, -52.3889007568, 5243).
airport('CQA', 'Canarana Airport', 1314, -13.5744438171387, -52.2705574035645, 3412).
airport('DOD', 'Dodoma Airport', 3637, -6.17044019699097, 35.7526016235352, 6700).
airport('SEU', 'Seronera Airport', 5080, -2.45806002616882, 34.8224983215332, 5177).
airport('NRR', 'Jose Aponte de la Torre Airport', 38, 18.245300293, -65.6434020996, 11000).
airport('LNL', 'Cheng Xian Airport', 3707, 33.789722, 105.788611, 9186).
airport('XAI', 'Xinyang Minggang Airport', 4528, 32.540556, 114.078889, 8858).
airport('YYA', 'Sanhe Airport', 230, 29.3125, 113.281667, 8530).
airport('BQJ', 'Batagay Airport', 699, 67.647778, 134.693611, 6562).
airport('BQJ', 'Batagay Airport', 699, 67.647778, 134.693611, 6062).
airport('DPT', 'Deputatskij Airport', 920, 69.3925, 139.889444, 7021).
airport('AKR', 'Akure Airport', 1100, 7.24673986434937, 5.30101013183594, 9195).
airport('APK', 'Apataki Airport', 8, -15.5735998153687, -146.414993286133, 2700).
airport('BWB', 'Barrow Island Airport', 26, -20.8644008636475, 115.40599822998, 6234).
airport('CEH', 'Chelinda Malawi Airport', 7759, -10.5500001907, 33.7999992371, 4249).
airport('CMK', 'Club Makokola Airport', 1587, -14.3069000244141, 35.1324996948242, 3576).
airport('CRC', 'Santa Ana Airport', 2979, 4.75818, -75.9557, 7218).
airport('EUA', 'Kaufana Airport', 325, -21.3782997131, -174.957992554, 2247).
airport('GYG', 'Magan Airport', 577, 62.1034812927246, 129.545288085938, 3839).
airport('GYG', 'Magan Airport', 577, 62.1034812927246, 129.545288085938, 3339).
airport('GYZ', 'Gruyere Airport', 2257, 46.5942001342773, 7.09443998336792, 2661).
airport('HFN', 'Hornafjordur Airport', 24, 64.2956008911133, -15.2271995544434, 4921).
airport('HPA', 'Lifuka Island Airport', 31, -19.7770004272461, -174.341003417969, 2300).
airport('HZK', 'Husavik Airport', 48, 65.9523010253906, -17.4260005950928, 5266).
airport('LIX', 'Likoma Island Airport', 1600, -12.0830001831055, 34.7330017089844, 3707).
airport('LRV', 'Los Roques Airport', 17, 11.9499998093, -66.6699981689, 3281).
airport('MYC', 'Escuela Mariscal Sucre Airport', 1338, 10.2499780654907, -67.6494216918945, 6846).
airport('MYC', 'Escuela Mariscal Sucre Airport', 1338, 10.2499780654907, -67.6494216918945, 6346).
airport('NFO', "Mata'aho Airport", 160, -15.5707998276, -175.632995605, 2800).
airport('SFD', 'San Fernando De Apure Airport', 154, 7.88331985473633, -67.4440002441406, 6240).
airport('UMS', 'Ust-Maya Airport', 561, 60.3569984436035, 134.434997558594, 6234).
airport('VAV', "Vava'u International Airport", 236, -18.5853004455566, -173.962005615234, 5593).
airport('VCV', 'Southern California Logistics Airport', 2885, 34.5974998474, -117.383003235, 15050).
airport('VCV', 'Southern California Logistics Airport', 2885, 34.5974998474, -117.383003235, 14550).
airport('VUU', 'Mvuu Camp Airport', 1600, -14.8386111111, 35.3013888889, 4429).
airport('WZA', 'Wa Airport', 1060, 10.0826997756958, -2.50768995285034, 6612).
airport('XWA', 'Williston Basin International Airport', 2353, 48.260864, -103.751138, 7501).
airport('YEI', 'Bursa Yenişehir Airport', 764, 40.2551994324, 29.5625991821, 9818).
airport('YEI', 'Bursa Yenişehir Airport', 764, 40.2551994324, 29.5625991821, 9318).
airport('ZZU', 'Mzuzu Airport', 4115, -11.4447002410889, 34.0117988586426, 4291).
airport('YIA', 'Yogyakarta International Airport', 350, -7.907499, 110.054444, 10663).
airport('NUL', 'Nulato Airport', 405, 64.7293014526367, -158.074005126953, 4011).
airport('KMV', 'Kalay Airport', 499, 23.1888008117676, 94.0511016845703, 5502).
airport('KHT', 'Khost Airport', 3844, 33.3334007263, 69.952003479, 8805).
airport('SYS', 'Saskylakh Airport', 200, 71.9279022216797, 114.080001831055, 5906).
airport('AAA', 'Anaa Airport', 10, -17.3526000976562, -145.509994506836, 4921).
airport('GBI', 'Kalaburagi International Airport', 1571, 17.521111, 77.597778, 10745).
airport('KVO', 'Morava Airport', 686, 43.818298, 20.5872, 7218).
airport('FAC', 'Faaite Airport', 7, -16.6867008209229, -145.328994750977, 3871).
airport('RRR', 'Raroia Airport', 12, -16.044999, -142.476944, 3871).
airport('PKP', 'Puka Puka Airport', 5, -14.8094997406006, -138.813003540039, 3051).
airport('NAU', 'Napuka Island Airport', 7, -14.1767997741699, -141.266998291016, 4101).
airport('FGU', 'Fangatau Airport', 9, -15.819899559021, -140.886993408203, 3936).
airport('BER', 'Berlin Brandenburg International Airport', 157, 52.378333, 13.520556, 13123).
airport('BER', 'Berlin Brandenburg International Airport', 157, 52.378333, 13.520556, 12623).

% Distance between airport
airports_distance('ATL', 'AUS', 811).
airports_distance('ATL', 'BNA', 214).
airports_distance('ATL', 'BOS', 945).
airports_distance('ATL', 'BWI', 576).
airports_distance('ATL', 'DCA', 546).
airports_distance('ATL', 'DFW', 729).
airports_distance('ATL', 'FLL', 581).
airports_distance('ATL', 'IAD', 533).
airports_distance('ATL', 'IAH', 688).
airports_distance('ATL', 'JFK', 759).
airports_distance('ATL', 'LAX', 1941).
airports_distance('ATL', 'LGA', 761).
airports_distance('ATL', 'MCO', 404).
airports_distance('ATL', 'MIA', 596).
airports_distance('ATL', 'MSP', 906).
airports_distance('ATL', 'ORD', 606).
airports_distance('ATL', 'PBI', 545).
airports_distance('ATL', 'PHX', 1583).
airports_distance('ATL', 'RDU', 355).
airports_distance('ATL', 'SEA', 2176).
airports_distance('ATL', 'SFO', 2133).
airports_distance('ATL', 'SJC', 2110).
airports_distance('ATL', 'TPA', 407).
airports_distance('ATL', 'SAN', 1886).
airports_distance('ATL', 'LGB', 1928).
airports_distance('ATL', 'SNA', 1913).
airports_distance('ATL', 'SLC', 1586).
airports_distance('ATL', 'LAS', 1742).
airports_distance('ATL', 'DEN', 1196).
airports_distance('ATL', 'HPN', 780).
airports_distance('ATL', 'SAT', 872).
airports_distance('ATL', 'MSY', 424).
airports_distance('ATL', 'EWR', 745).
airports_distance('ATL', 'CID', 694).
airports_distance('ATL', 'HNL', 4492).
airports_distance('ATL', 'HOU', 694).
airports_distance('ATL', 'ELP', 1279).
airports_distance('ATL', 'SJU', 1547).
airports_distance('ATL', 'CLE', 555).
airports_distance('ATL', 'OAK', 2124).
airports_distance('ATL', 'TUS', 1537).
airports_distance('ATL', 'PHL', 665).
airports_distance('ATL', 'DTW', 595).
airports_distance('ANC', 'DFW', 3036).
airports_distance('ANC', 'IAH', 3259).
airports_distance('ANC', 'LAX', 2341).
airports_distance('ANC', 'MSP', 2510).
airports_distance('ANC', 'ORD', 2837).
airports_distance('ANC', 'PHX', 2547).
airports_distance('ANC', 'SEA', 1444).
airports_distance('ANC', 'SFO', 2014).
airports_distance('ANC', 'LGB', 2356).
airports_distance('ANC', 'LAS', 2300).
airports_distance('ANC', 'DEN', 2399).
airports_distance('ANC', 'HNL', 2778).
airports_distance('AUS', 'ATL', 811).
airports_distance('AUS', 'BNA', 755).
airports_distance('AUS', 'BOS', 1695).
airports_distance('AUS', 'BWI', 1339).
airports_distance('AUS', 'DCA', 1313).
airports_distance('AUS', 'DFW', 190).
airports_distance('AUS', 'FLL', 1103).
airports_distance('AUS', 'IAD', 1294).
airports_distance('AUS', 'IAH', 140).
airports_distance('AUS', 'JFK', 1518).
airports_distance('AUS', 'LAX', 1238).
airports_distance('AUS', 'MCO', 992).
airports_distance('AUS', 'MIA', 1101).
airports_distance('AUS', 'MSP', 1042).
airports_distance('AUS', 'ORD', 978).
airports_distance('AUS', 'PHX', 870).
airports_distance('AUS', 'RDU', 1159).
airports_distance('AUS', 'SEA', 1768).
airports_distance('AUS', 'SFO', 1500).
airports_distance('AUS', 'SJC', 1473).
airports_distance('AUS', 'TPA', 925).
airports_distance('AUS', 'SAN', 1161).
airports_distance('AUS', 'LGB', 1223).
airports_distance('AUS', 'SNA', 1206).
airports_distance('AUS', 'SLC', 1085).
airports_distance('AUS', 'LAS', 1087).
airports_distance('AUS', 'DEN', 775).
airports_distance('AUS', 'SAT', 66).
airports_distance('AUS', 'HNL', 3755).
airports_distance('AUS', 'MSY', 443).
airports_distance('AUS', 'EWR', 1501).
airports_distance('AUS', 'HOU', 148).
airports_distance('AUS', 'ELP', 527).
airports_distance('AUS', 'CLE', 1173).
airports_distance('AUS', 'OAK', 1494).
airports_distance('AUS', 'TUS', 795).
airports_distance('AUS', 'PHL', 1428).
airports_distance('AUS', 'DTW', 1148).
airports_distance('BNA', 'ATL', 214).
airports_distance('BNA', 'AUS', 755).
airports_distance('BNA', 'BOS', 940).
airports_distance('BNA', 'BWI', 586).
airports_distance('BNA', 'DCA', 560).
airports_distance('BNA', 'DFW', 630).
airports_distance('BNA', 'FLL', 794).
airports_distance('BNA', 'IAD', 541).
airports_distance('BNA', 'IAH', 656).
airports_distance('BNA', 'JFK', 764).
airports_distance('BNA', 'LAX', 1792).
airports_distance('BNA', 'LGA', 762).
airports_distance('BNA', 'MCO', 617).
airports_distance('BNA', 'MIA', 807).
airports_distance('BNA', 'MSP', 695).
airports_distance('BNA', 'ORD', 409).
airports_distance('BNA', 'PHX', 1445).
airports_distance('BNA', 'RDU', 441).
airports_distance('BNA', 'SEA', 1972).
airports_distance('BNA', 'SFO', 1963).
airports_distance('BNA', 'TPA', 613).
airports_distance('BNA', 'SAN', 1746).
airports_distance('BNA', 'SLC', 1400).
airports_distance('BNA', 'LAS', 1583).
airports_distance('BNA', 'DEN', 1011).
airports_distance('BNA', 'SAT', 821).
airports_distance('BNA', 'MSY', 471).
airports_distance('BNA', 'EWR', 746).
airports_distance('BNA', 'CID', 481).
airports_distance('BNA', 'HOU', 669).
airports_distance('BNA', 'CLE', 448).
airports_distance('BNA', 'OAK', 1953).
airports_distance('BNA', 'PHL', 673).
airports_distance('BNA', 'DTW', 456).
airports_distance('BOS', 'ATL', 945).
airports_distance('BOS', 'AUS', 1695).
airports_distance('BOS', 'BNA', 940).
airports_distance('BOS', 'BWI', 369).
airports_distance('BOS', 'DCA', 398).
airports_distance('BOS', 'DFW', 1558).
airports_distance('BOS', 'FLL', 1238).
airports_distance('BOS', 'IAD', 412).
airports_distance('BOS', 'IAH', 1594).
airports_distance('BOS', 'JFK', 186).
airports_distance('BOS', 'LAX', 2604).
airports_distance('BOS', 'LGA', 184).
airports_distance('BOS', 'MCO', 1121).
airports_distance('BOS', 'MIA', 1259).
airports_distance('BOS', 'MSP', 1120).
airports_distance('BOS', 'ORD', 864).
airports_distance('BOS', 'PBI', 1198).
airports_distance('BOS', 'PHX', 2294).
airports_distance('BOS', 'RDU', 611).
airports_distance('BOS', 'SEA', 2487).
airports_distance('BOS', 'SFO', 2696).
airports_distance('BOS', 'SJC', 2680).
airports_distance('BOS', 'TPA', 1185).
airports_distance('BOS', 'SAN', 2581).
airports_distance('BOS', 'LGB', 2595).
airports_distance('BOS', 'SLC', 2098).
airports_distance('BOS', 'LAS', 2374).
airports_distance('BOS', 'DEN', 1748).
airports_distance('BOS', 'HPN', 166).
airports_distance('BOS', 'MSY', 1366).
airports_distance('BOS', 'EWR', 200).
airports_distance('BOS', 'HNL', 5083).
airports_distance('BOS', 'HOU', 1606).
airports_distance('BOS', 'SJU', 1678).
airports_distance('BOS', 'CLE', 561).
airports_distance('BOS', 'OAK', 2685).
airports_distance('BOS', 'PHL', 280).
airports_distance('BOS', 'DTW', 630).
airports_distance('BWI', 'ATL', 576).
airports_distance('BWI', 'BNA', 586).
airports_distance('BWI', 'BOS', 369).
airports_distance('BWI', 'DFW', 1214).
airports_distance('BWI', 'FLL', 927).
airports_distance('BWI', 'IAH', 1233).
airports_distance('BWI', 'JFK', 183).
airports_distance('BWI', 'LAX', 2322).
airports_distance('BWI', 'MCO', 788).
airports_distance('BWI', 'MIA', 948).
airports_distance('BWI', 'MSP', 934).
airports_distance('BWI', 'ORD', 620).
airports_distance('BWI', 'PBI', 885).
airports_distance('BWI', 'PHX', 1993).
airports_distance('BWI', 'RDU', 256).
airports_distance('BWI', 'SEA', 2327).
airports_distance('BWI', 'SFO', 2449).
airports_distance('BWI', 'SJC', 2431).
airports_distance('BWI', 'TPA', 843).
airports_distance('BWI', 'SAN', 2289).
airports_distance('BWI', 'SLC', 1859).
airports_distance('BWI', 'AUS', 1339).
airports_distance('BWI', 'LAS', 2099).
airports_distance('BWI', 'DEN', 1486).
airports_distance('BWI', 'SAT', 1405).
airports_distance('BWI', 'MSY', 997).
airports_distance('BWI', 'EWR', 169).
airports_distance('BWI', 'HOU', 1244).
airports_distance('BWI', 'SJU', 1568).
airports_distance('BWI', 'CLE', 313).
airports_distance('BWI', 'OAK', 2439).
airports_distance('BWI', 'PHL', 90).
airports_distance('BWI', 'DTW', 408).
airports_distance('DCA', 'ATL', 546).
airports_distance('DCA', 'AUS', 1313).
airports_distance('DCA', 'BNA', 560).
airports_distance('DCA', 'BOS', 398).
airports_distance('DCA', 'DFW', 1189).
airports_distance('DCA', 'FLL', 901).
airports_distance('DCA', 'IAH', 1206).
airports_distance('DCA', 'JFK', 212).
airports_distance('DCA', 'LAX', 2304).
airports_distance('DCA', 'LGA', 214).
airports_distance('DCA', 'MCO', 760).
airports_distance('DCA', 'MIA', 921).
airports_distance('DCA', 'MSP', 928).
airports_distance('DCA', 'ORD', 610).
airports_distance('DCA', 'PBI', 859).
airports_distance('DCA', 'RDU', 227).
airports_distance('DCA', 'SEA', 2321).
airports_distance('DCA', 'SFO', 2435).
airports_distance('DCA', 'TPA', 815).
airports_distance('DCA', 'SAN', 2269).
airports_distance('DCA', 'LAS', 2082).
airports_distance('DCA', 'DEN', 1471).
airports_distance('DCA', 'HPN', 233).
airports_distance('DCA', 'MSY', 968).
airports_distance('DCA', 'EWR', 198).
airports_distance('DCA', 'HOU', 1216).
airports_distance('DCA', 'SJU', 1557).
airports_distance('DCA', 'PHL', 119).
airports_distance('DCA', 'CLE', 309).
airports_distance('DCA', 'DTW', 404).
airports_distance('DFW', 'ATL', 729).
airports_distance('DFW', 'ANC', 3036).
airports_distance('DFW', 'AUS', 190).
airports_distance('DFW', 'BNA', 630).
airports_distance('DFW', 'BOS', 1558).
airports_distance('DFW', 'BWI', 1214).
airports_distance('DFW', 'DCA', 1189).
airports_distance('DFW', 'FLL', 1117).
airports_distance('DFW', 'IAD', 1169).
airports_distance('DFW', 'IAH', 225).
airports_distance('DFW', 'JFK', 1388).
airports_distance('DFW', 'LAX', 1231).
airports_distance('DFW', 'LGA', 1386).
airports_distance('DFW', 'MCO', 983).
airports_distance('DFW', 'MIA', 1119).
airports_distance('DFW', 'MSP', 852).
airports_distance('DFW', 'ORD', 801).
airports_distance('DFW', 'PBI', 1100).
airports_distance('DFW', 'PHX', 866).
airports_distance('DFW', 'RDU', 1058).
airports_distance('DFW', 'SEA', 1657).
airports_distance('DFW', 'SFO', 1460).
airports_distance('DFW', 'SJC', 1435).
airports_distance('DFW', 'TPA', 927).
airports_distance('DFW', 'SAN', 1168).
airports_distance('DFW', 'SNA', 1201).
airports_distance('DFW', 'SLC', 987).
airports_distance('DFW', 'LAS', 1052).
airports_distance('DFW', 'DEN', 641).
airports_distance('DFW', 'SAT', 247).
airports_distance('DFW', 'MSY', 447).
airports_distance('DFW', 'EWR', 1369).
airports_distance('DFW', 'CID', 686).
airports_distance('DFW', 'HNL', 3776).
airports_distance('DFW', 'HOU', 247).
airports_distance('DFW', 'ELP', 550).
airports_distance('DFW', 'SJU', 2162).
airports_distance('DFW', 'CLE', 1019).
airports_distance('DFW', 'OAK', 1453).
airports_distance('DFW', 'TUS', 811).
airports_distance('DFW', 'SAF', 549).
airports_distance('DFW', 'PHL', 1300).
airports_distance('DFW', 'DTW', 985).
airports_distance('FLL', 'ATL', 581).
airports_distance('FLL', 'AUS', 1103).
airports_distance('FLL', 'BNA', 794).
airports_distance('FLL', 'BOS', 1238).
airports_distance('FLL', 'BWI', 927).
airports_distance('FLL', 'DCA', 901).
airports_distance('FLL', 'DFW', 1117).
airports_distance('FLL', 'IAD', 902).
airports_distance('FLL', 'IAH', 963).
airports_distance('FLL', 'JFK', 1070).
airports_distance('FLL', 'LAX', 2337).
airports_distance('FLL', 'LGA', 1077).
airports_distance('FLL', 'MCO', 178).
airports_distance('FLL', 'MSP', 1488).
airports_distance('FLL', 'ORD', 1183).
airports_distance('FLL', 'PHX', 1968).
airports_distance('FLL', 'RDU', 682).
airports_distance('FLL', 'SEA', 2712).
airports_distance('FLL', 'SFO', 2577).
airports_distance('FLL', 'TPA', 197).
airports_distance('FLL', 'SAN', 2263).
airports_distance('FLL', 'LGB', 2322).
airports_distance('FLL', 'SLC', 2080).
airports_distance('FLL', 'LAS', 2168).
airports_distance('FLL', 'DEN', 1701).
airports_distance('FLL', 'HPN', 1099).
airports_distance('FLL', 'SAT', 1143).
airports_distance('FLL', 'MSY', 672).
airports_distance('FLL', 'EWR', 1066).
airports_distance('FLL', 'HOU', 955).
airports_distance('FLL', 'SJU', 1045).
airports_distance('FLL', 'CLE', 1064).
airports_distance('FLL', 'PHL', 994).
airports_distance('FLL', 'DTW', 1129).
airports_distance('IAD', 'ATL', 533).
airports_distance('IAD', 'AUS', 1294).
airports_distance('IAD', 'BNA', 541).
airports_distance('IAD', 'BOS', 412).
airports_distance('IAD', 'DFW', 1169).
airports_distance('IAD', 'FLL', 902).
airports_distance('IAD', 'IAH', 1188).
airports_distance('IAD', 'JFK', 227).
airports_distance('IAD', 'LAX', 2281).
airports_distance('IAD', 'LGA', 228).
airports_distance('IAD', 'MCO', 759).
airports_distance('IAD', 'MIA', 923).
airports_distance('IAD', 'MSP', 906).
airports_distance('IAD', 'ORD', 587).
airports_distance('IAD', 'PHX', 1951).
airports_distance('IAD', 'RDU', 224).
airports_distance('IAD', 'SEA', 2298).
airports_distance('IAD', 'SFO', 2411).
airports_distance('IAD', 'TPA', 811).
airports_distance('IAD', 'SAN', 2247).
airports_distance('IAD', 'SLC', 1822).
airports_distance('IAD', 'LAS', 2059).
airports_distance('IAD', 'DEN', 1448).
airports_distance('IAD', 'SAT', 1359).
airports_distance('IAD', 'MSY', 954).
airports_distance('IAD', 'EWR', 212).
airports_distance('IAD', 'HNL', 4806).
airports_distance('IAD', 'SJU', 1573).
airports_distance('IAD', 'CLE', 288).
airports_distance('IAD', 'OAK', 2401).
airports_distance('IAD', 'PHL', 134).
airports_distance('IAD', 'DTW', 383).
airports_distance('IAH', 'ATL', 688).
airports_distance('IAH', 'ANC', 3259).
airports_distance('IAH', 'AUS', 140).
airports_distance('IAH', 'BNA', 656).
airports_distance('IAH', 'BOS', 1594).
airports_distance('IAH', 'BWI', 1233).
airports_distance('IAH', 'DCA', 1206).
airports_distance('IAH', 'DFW', 225).
airports_distance('IAH', 'FLL', 963).
airports_distance('IAH', 'IAD', 1188).
airports_distance('IAH', 'JFK', 1414).
airports_distance('IAH', 'LAX', 1375).
airports_distance('IAH', 'LGA', 1414).
airports_distance('IAH', 'MCO', 852).
airports_distance('IAH', 'MIA', 962).
airports_distance('IAH', 'MSP', 1035).
airports_distance('IAH', 'ORD', 926).
airports_distance('IAH', 'PBI', 953).
airports_distance('IAH', 'PHX', 1007).
airports_distance('IAH', 'RDU', 1040).
airports_distance('IAH', 'SEA', 1871).
airports_distance('IAH', 'SFO', 1631).
airports_distance('IAH', 'SJC', 1604).
airports_distance('IAH', 'TPA', 786).
airports_distance('IAH', 'SAN', 1300).
airports_distance('IAH', 'SNA', 1343).
airports_distance('IAH', 'SLC', 1194).
airports_distance('IAH', 'LAS', 1219).
airports_distance('IAH', 'DEN', 862).
airports_distance('IAH', 'SAT', 190).
airports_distance('IAH', 'MSY', 304).
airports_distance('IAH', 'EWR', 1397).
airports_distance('IAH', 'HNL', 3895).
airports_distance('IAH', 'ELP', 666).
airports_distance('IAH', 'SJU', 2004).
airports_distance('IAH', 'CLE', 1090).
airports_distance('IAH', 'TUS', 934).
airports_distance('IAH', 'PHL', 1322).
airports_distance('IAH', 'DTW', 1075).
airports_distance('JFK', 'ATL', 759).
airports_distance('JFK', 'AUS', 1518).
airports_distance('JFK', 'BNA', 764).
airports_distance('JFK', 'BOS', 186).
airports_distance('JFK', 'BWI', 183).
airports_distance('JFK', 'DCA', 212).
airports_distance('JFK', 'DFW', 1388).
airports_distance('JFK', 'FLL', 1070).
airports_distance('JFK', 'IAD', 227).
airports_distance('JFK', 'IAH', 1414).
airports_distance('JFK', 'LAX', 2468).
airports_distance('JFK', 'MCO', 945).
airports_distance('JFK', 'MIA', 1091).
airports_distance('JFK', 'MSP', 1025).
airports_distance('JFK', 'ORD', 738).
airports_distance('JFK', 'PBI', 1029).
airports_distance('JFK', 'PHX', 2147).
airports_distance('JFK', 'RDU', 426).
airports_distance('JFK', 'SEA', 2413).
airports_distance('JFK', 'SFO', 2578).
airports_distance('JFK', 'SJC', 2561).
airports_distance('JFK', 'TPA', 1006).
airports_distance('JFK', 'SAN', 2439).
airports_distance('JFK', 'LGB', 2458).
airports_distance('JFK', 'SNA', 2447).
airports_distance('JFK', 'SLC', 1983).
airports_distance('JFK', 'LAS', 2241).
airports_distance('JFK', 'DEN', 1621).
airports_distance('JFK', 'SAT', 1584).
airports_distance('JFK', 'MSY', 1181).
airports_distance('JFK', 'HNL', 4972).
airports_distance('JFK', 'HOU', 1426).
airports_distance('JFK', 'SJU', 1601).
airports_distance('JFK', 'CLE', 424).
airports_distance('JFK', 'OAK', 2568).
airports_distance('JFK', 'TUS', 2131).
airports_distance('JFK', 'PHL', 94).
airports_distance('JFK', 'DTW', 507).
airports_distance('LAX', 'ATL', 1941).
airports_distance('LAX', 'ANC', 2341).
airports_distance('LAX', 'AUS', 1238).
airports_distance('LAX', 'BNA', 1792).
airports_distance('LAX', 'BOS', 2604).
airports_distance('LAX', 'BWI', 2322).
airports_distance('LAX', 'DCA', 2304).
airports_distance('LAX', 'DFW', 1231).
airports_distance('LAX', 'FLL', 2337).
airports_distance('LAX', 'IAD', 2281).
airports_distance('LAX', 'IAH', 1375).
airports_distance('LAX', 'JFK', 2468).
airports_distance('LAX', 'MCO', 2212).
airports_distance('LAX', 'MIA', 2336).
airports_distance('LAX', 'MSP', 1532).
airports_distance('LAX', 'ORD', 1740).
airports_distance('LAX', 'PBI', 2324).
airports_distance('LAX', 'PHX', 369).
airports_distance('LAX', 'RDU', 2232).
airports_distance('LAX', 'SEA', 954).
airports_distance('LAX', 'SFO', 337).
airports_distance('LAX', 'SJC', 308).
airports_distance('LAX', 'TPA', 2152).
airports_distance('LAX', 'SAN', 109).
airports_distance('LAX', 'SLC', 589).
airports_distance('LAX', 'LAS', 236).
airports_distance('LAX', 'DEN', 860).
airports_distance('LAX', 'SAT', 1208).
airports_distance('LAX', 'MSY', 1666).
airports_distance('LAX', 'EWR', 2447).
airports_distance('LAX', 'CID', 1546).
airports_distance('LAX', 'HNL', 2551).
airports_distance('LAX', 'HOU', 1386).
airports_distance('LAX', 'ELP', 713).
airports_distance('LAX', 'CLE', 2047).
airports_distance('LAX', 'OAK', 337).
airports_distance('LAX', 'TUS', 450).
airports_distance('LAX', 'SAF', 708).
airports_distance('LAX', 'PHL', 2395).
airports_distance('LAX', 'DTW', 1973).
airports_distance('LGA', 'ATL', 761).
airports_distance('LGA', 'BNA', 762).
airports_distance('LGA', 'BOS', 184).
airports_distance('LGA', 'DCA', 214).
airports_distance('LGA', 'DFW', 1386).
airports_distance('LGA', 'FLL', 1077).
airports_distance('LGA', 'IAD', 228).
airports_distance('LGA', 'IAH', 1414).
airports_distance('LGA', 'MCO', 951).
airports_distance('LGA', 'MIA', 1098).
airports_distance('LGA', 'MSP', 1017).
airports_distance('LGA', 'ORD', 731).
airports_distance('LGA', 'PBI', 1036).
airports_distance('LGA', 'PHX', 2143).
airports_distance('LGA', 'RDU', 430).
airports_distance('LGA', 'TPA', 1011).
airports_distance('LGA', 'DEN', 1614).
airports_distance('LGA', 'MSY', 1182).
airports_distance('LGA', 'HOU', 1425).
airports_distance('LGA', 'CLE', 417).
airports_distance('LGA', 'PHL', 95).
airports_distance('LGA', 'DTW', 500).
airports_distance('MCO', 'ATL', 404).
airports_distance('MCO', 'AUS', 992).
airports_distance('MCO', 'BNA', 617).
airports_distance('MCO', 'BOS', 1121).
airports_distance('MCO', 'BWI', 788).
airports_distance('MCO', 'DCA', 760).
airports_distance('MCO', 'DFW', 983).
airports_distance('MCO', 'FLL', 178).
airports_distance('MCO', 'IAD', 759).
airports_distance('MCO', 'IAH', 852).
airports_distance('MCO', 'JFK', 945).
airports_distance('MCO', 'LAX', 2212).
airports_distance('MCO', 'LGA', 951).
airports_distance('MCO', 'MIA', 192).
airports_distance('MCO', 'MSP', 1310).
airports_distance('MCO', 'ORD', 1006).
airports_distance('MCO', 'PHX', 1844).
airports_distance('MCO', 'RDU', 535).
airports_distance('MCO', 'SEA', 2549).
airports_distance('MCO', 'SFO', 2440).
airports_distance('MCO', 'SJC', 2415).
airports_distance('MCO', 'SAN', 2143).
airports_distance('MCO', 'SLC', 1927).
airports_distance('MCO', 'LAS', 2034).
airports_distance('MCO', 'DEN', 1544).
airports_distance('MCO', 'HPN', 972).
airports_distance('MCO', 'SAT', 1038).
airports_distance('MCO', 'MSY', 550).
airports_distance('MCO', 'EWR', 938).
airports_distance('MCO', 'CID', 1097).
airports_distance('MCO', 'HOU', 847).
airports_distance('MCO', 'SJU', 1188).
airports_distance('MCO', 'CLE', 897).
airports_distance('MCO', 'PHL', 862).
airports_distance('MCO', 'DTW', 959).
airports_distance('MIA', 'ATL', 596).
airports_distance('MIA', 'AUS', 1101).
airports_distance('MIA', 'BNA', 807).
airports_distance('MIA', 'BOS', 1259).
airports_distance('MIA', 'BWI', 948).
airports_distance('MIA', 'DCA', 921).
airports_distance('MIA', 'DFW', 1119).
airports_distance('MIA', 'IAD', 923).
airports_distance('MIA', 'IAH', 962).
airports_distance('MIA', 'JFK', 1091).
airports_distance('MIA', 'LAX', 2336).
airports_distance('MIA', 'LGA', 1098).
airports_distance('MIA', 'MCO', 192).
airports_distance('MIA', 'MSP', 1501).
airports_distance('MIA', 'ORD', 1198).
airports_distance('MIA', 'PHX', 1967).
airports_distance('MIA', 'RDU', 702).
airports_distance('MIA', 'SEA', 2719).
airports_distance('MIA', 'SFO', 2579).
airports_distance('MIA', 'TPA', 204).
airports_distance('MIA', 'SAN', 2262).
airports_distance('MIA', 'SLC', 2085).
airports_distance('MIA', 'LAS', 2170).
airports_distance('MIA', 'DEN', 1707).
airports_distance('MIA', 'HPN', 1120).
airports_distance('MIA', 'SAT', 1140).
airports_distance('MIA', 'MSY', 673).
airports_distance('MIA', 'EWR', 1087).
airports_distance('MIA', 'HOU', 953).
airports_distance('MIA', 'SJU', 1044).
airports_distance('MIA', 'CLE', 1082).
airports_distance('MIA', 'PHL', 1015).
airports_distance('MIA', 'DTW', 1147).
airports_distance('MSP', 'ATL', 906).
airports_distance('MSP', 'ANC', 2510).
airports_distance('MSP', 'AUS', 1042).
airports_distance('MSP', 'BNA', 695).
airports_distance('MSP', 'BOS', 1120).
airports_distance('MSP', 'BWI', 934).
airports_distance('MSP', 'DCA', 928).
airports_distance('MSP', 'DFW', 852).
airports_distance('MSP', 'FLL', 1488).
airports_distance('MSP', 'IAD', 906).
airports_distance('MSP', 'IAH', 1035).
airports_distance('MSP', 'JFK', 1025).
airports_distance('MSP', 'LAX', 1532).
airports_distance('MSP', 'LGA', 1017).
airports_distance('MSP', 'MCO', 1310).
airports_distance('MSP', 'MIA', 1501).
airports_distance('MSP', 'ORD', 333).
airports_distance('MSP', 'PBI', 1452).
airports_distance('MSP', 'PHX', 1274).
airports_distance('MSP', 'RDU', 979).
airports_distance('MSP', 'SEA', 1394).
airports_distance('MSP', 'SFO', 1584).
airports_distance('MSP', 'SJC', 1571).
airports_distance('MSP', 'TPA', 1307).
airports_distance('MSP', 'SAN', 1529).
airports_distance('MSP', 'SNA', 1519).
airports_distance('MSP', 'SLC', 988).
airports_distance('MSP', 'LAS', 1296).
airports_distance('MSP', 'DEN', 678).
airports_distance('MSP', 'SAT', 1098).
airports_distance('MSP', 'MSY', 1041).
airports_distance('MSP', 'EWR', 1005).
airports_distance('MSP', 'CID', 220).
airports_distance('MSP', 'HNL', 3964).
airports_distance('MSP', 'CLE', 620).
airports_distance('MSP', 'OAK', 1574).
airports_distance('MSP', 'TUS', 1296).
airports_distance('MSP', 'PHL', 978).
airports_distance('MSP', 'DTW', 527).
airports_distance('ORD', 'ATL', 606).
airports_distance('ORD', 'ANC', 2837).
airports_distance('ORD', 'AUS', 978).
airports_distance('ORD', 'BNA', 409).
airports_distance('ORD', 'BOS', 864).
airports_distance('ORD', 'BWI', 620).
airports_distance('ORD', 'DCA', 610).
airports_distance('ORD', 'DFW', 801).
airports_distance('ORD', 'FLL', 1183).
airports_distance('ORD', 'IAD', 587).
airports_distance('ORD', 'IAH', 926).
airports_distance('ORD', 'JFK', 738).
airports_distance('ORD', 'LAX', 1740).
airports_distance('ORD', 'LGA', 731).
airports_distance('ORD', 'MCO', 1006).
airports_distance('ORD', 'MIA', 1198).
airports_distance('ORD', 'MSP', 333).
airports_distance('ORD', 'PBI', 1145).
airports_distance('ORD', 'PHX', 1436).
airports_distance('ORD', 'RDU', 645).
airports_distance('ORD', 'SEA', 1715).
airports_distance('ORD', 'SFO', 1840).
airports_distance('ORD', 'SJC', 1824).
airports_distance('ORD', 'TPA', 1013).
airports_distance('ORD', 'SAN', 1719).
airports_distance('ORD', 'SNA', 1721).
airports_distance('ORD', 'SLC', 1246).
airports_distance('ORD', 'LAS', 1510).
airports_distance('ORD', 'DEN', 885).
airports_distance('ORD', 'HPN', 736).
airports_distance('ORD', 'SAT', 1042).
airports_distance('ORD', 'MSY', 838).
airports_distance('ORD', 'EWR', 717).
airports_distance('ORD', 'CID', 196).
airports_distance('ORD', 'HNL', 4234).
airports_distance('ORD', 'ELP', 1234).
airports_distance('ORD', 'SJU', 2072).
airports_distance('ORD', 'CLE', 315).
airports_distance('ORD', 'OAK', 1830).
airports_distance('ORD', 'TUS', 1434).
airports_distance('ORD', 'PHL', 676).
airports_distance('ORD', 'DTW', 234).
airports_distance('PBI', 'ATL', 545).
airports_distance('PBI', 'BOS', 1198).
airports_distance('PBI', 'BWI', 885).
airports_distance('PBI', 'DCA', 859).
airports_distance('PBI', 'DFW', 1100).
airports_distance('PBI', 'IAH', 953).
airports_distance('PBI', 'JFK', 1029).
airports_distance('PBI', 'LAX', 2324).
airports_distance('PBI', 'LGA', 1036).
airports_distance('PBI', 'MSP', 1452).
airports_distance('PBI', 'ORD', 1145).
airports_distance('PBI', 'RDU', 639).
airports_distance('PBI', 'TPA', 174).
airports_distance('PBI', 'DEN', 1677).
airports_distance('PBI', 'HPN', 1058).
airports_distance('PBI', 'EWR', 1025).
airports_distance('PBI', 'SJU', 1062).
airports_distance('PBI', 'CLE', 1022).
airports_distance('PBI', 'PHL', 952).
airports_distance('PBI', 'DTW', 1088).
airports_distance('PHX', 'ATL', 1583).
airports_distance('PHX', 'ANC', 2547).
airports_distance('PHX', 'AUS', 870).
airports_distance('PHX', 'BNA', 1445).
airports_distance('PHX', 'BOS', 2294).
airports_distance('PHX', 'BWI', 1993).
airports_distance('PHX', 'DFW', 866).
airports_distance('PHX', 'FLL', 1968).
airports_distance('PHX', 'IAD', 1951).
airports_distance('PHX', 'IAH', 1007).
airports_distance('PHX', 'JFK', 2147).
airports_distance('PHX', 'LAX', 369).
airports_distance('PHX', 'LGA', 2143).
airports_distance('PHX', 'MCO', 1844).
airports_distance('PHX', 'MIA', 1967).
airports_distance('PHX', 'MSP', 1274).
airports_distance('PHX', 'ORD', 1436).
airports_distance('PHX', 'RDU', 1885).
airports_distance('PHX', 'SEA', 1106).
airports_distance('PHX', 'SFO', 650).
airports_distance('PHX', 'SJC', 620).
airports_distance('PHX', 'SAN', 303).
airports_distance('PHX', 'SNA', 337).
airports_distance('PHX', 'SLC', 508).
airports_distance('PHX', 'LAS', 255).
airports_distance('PHX', 'DEN', 601).
airports_distance('PHX', 'SAT', 841).
airports_distance('PHX', 'MSY', 1297).
airports_distance('PHX', 'EWR', 2127).
airports_distance('PHX', 'HNL', 2911).
airports_distance('PHX', 'HOU', 1018).
airports_distance('PHX', 'ELP', 346).
airports_distance('PHX', 'CLE', 1733).
airports_distance('PHX', 'OAK', 645).
airports_distance('PHX', 'TUS', 110).
airports_distance('PHX', 'SAF', 369).
airports_distance('PHX', 'PHL', 2069).
airports_distance('PHX', 'DTW', 1667).
airports_distance('RDU', 'ATL', 355).
airports_distance('RDU', 'AUS', 1159).
airports_distance('RDU', 'BNA', 441).
airports_distance('RDU', 'BOS', 611).
airports_distance('RDU', 'BWI', 256).
airports_distance('RDU', 'DCA', 227).
airports_distance('RDU', 'DFW', 1058).
airports_distance('RDU', 'FLL', 682).
airports_distance('RDU', 'IAD', 224).
airports_distance('RDU', 'IAH', 1040).
airports_distance('RDU', 'JFK', 426).
airports_distance('RDU', 'LAX', 2232).
airports_distance('RDU', 'LGA', 430).
airports_distance('RDU', 'MCO', 535).
airports_distance('RDU', 'MIA', 702).
airports_distance('RDU', 'MSP', 979).
airports_distance('RDU', 'ORD', 645).
airports_distance('RDU', 'PBI', 639).
airports_distance('RDU', 'PHX', 1885).
airports_distance('RDU', 'SEA', 2347).
airports_distance('RDU', 'SFO', 2393).
airports_distance('RDU', 'TPA', 588).
airports_distance('RDU', 'SAN', 2187).
airports_distance('RDU', 'SLC', 1818).
airports_distance('RDU', 'LAS', 2020).
airports_distance('RDU', 'DEN', 1432).
airports_distance('RDU', 'SAT', 1222).
airports_distance('RDU', 'EWR', 416).
airports_distance('RDU', 'MSY', 778).
airports_distance('RDU', 'HOU', 1048).
airports_distance('RDU', 'SJU', 1434).
airports_distance('RDU', 'CLE', 416).
airports_distance('RDU', 'PHL', 337).
airports_distance('RDU', 'DTW', 501).
airports_distance('SEA', 'ATL', 2176).
airports_distance('SEA', 'ANC', 1444).
airports_distance('SEA', 'AUS', 1768).
airports_distance('SEA', 'BNA', 1972).
airports_distance('SEA', 'BOS', 2487).
airports_distance('SEA', 'DCA', 2321).
airports_distance('SEA', 'BWI', 2327).
airports_distance('SEA', 'DFW', 1657).
airports_distance('SEA', 'FLL', 2712).
airports_distance('SEA', 'IAD', 2298).
airports_distance('SEA', 'IAH', 1871).
airports_distance('SEA', 'JFK', 2413).
airports_distance('SEA', 'LAX', 954).
airports_distance('SEA', 'MCO', 2549).
airports_distance('SEA', 'MIA', 2719).
airports_distance('SEA', 'MSP', 1394).
airports_distance('SEA', 'ORD', 1715).
airports_distance('SEA', 'PHX', 1106).
airports_distance('SEA', 'RDU', 2347).
airports_distance('SEA', 'SFO', 679).
airports_distance('SEA', 'SJC', 697).
airports_distance('SEA', 'TPA', 2515).
airports_distance('SEA', 'SAN', 1051).
airports_distance('SEA', 'LGB', 966).
airports_distance('SEA', 'SNA', 979).
airports_distance('SEA', 'SLC', 687).
airports_distance('SEA', 'LAS', 866).
airports_distance('SEA', 'DEN', 1021).
airports_distance('SEA', 'SAT', 1772).
airports_distance('SEA', 'MSY', 2082).
airports_distance('SEA', 'EWR', 2394).
airports_distance('SEA', 'HNL', 2675).
airports_distance('SEA', 'HOU', 1891).
airports_distance('SEA', 'ELP', 1367).
airports_distance('SEA', 'OAK', 672).
airports_distance('SEA', 'TUS', 1215).
airports_distance('SEA', 'PHL', 2371).
airports_distance('SEA', 'DTW', 1921).
airports_distance('SFO', 'ATL', 2133).
airports_distance('SFO', 'ANC', 2014).
airports_distance('SFO', 'AUS', 1500).
airports_distance('SFO', 'BNA', 1963).
airports_distance('SFO', 'BOS', 2696).
airports_distance('SFO', 'BWI', 2449).
airports_distance('SFO', 'DCA', 2435).
airports_distance('SFO', 'DFW', 1460).
airports_distance('SFO', 'FLL', 2577).
airports_distance('SFO', 'IAD', 2411).
airports_distance('SFO', 'IAH', 1631).
airports_distance('SFO', 'JFK', 2578).
airports_distance('SFO', 'LAX', 337).
airports_distance('SFO', 'MCO', 2440).
airports_distance('SFO', 'MIA', 2579).
airports_distance('SFO', 'MSP', 1584).
airports_distance('SFO', 'ORD', 1840).
airports_distance('SFO', 'PHX', 650).
airports_distance('SFO', 'RDU', 2393).
airports_distance('SFO', 'SEA', 679).
airports_distance('SFO', 'TPA', 2387).
airports_distance('SFO', 'SAN', 446).
airports_distance('SFO', 'LGB', 353).
airports_distance('SFO', 'SNA', 371).
airports_distance('SFO', 'SLC', 597).
airports_distance('SFO', 'LAS', 413).
airports_distance('SFO', 'DEN', 964).
airports_distance('SFO', 'SAT', 1479).
airports_distance('SFO', 'MSY', 1906).
airports_distance('SFO', 'EWR', 2557).
airports_distance('SFO', 'HNL', 2395).
airports_distance('SFO', 'CLE', 2155).
airports_distance('SFO', 'TUS', 750).
airports_distance('SFO', 'PHL', 2513).
airports_distance('SFO', 'DTW', 2072).
airports_distance('SJC', 'ATL', 2110).
airports_distance('SJC', 'AUS', 1473).
airports_distance('SJC', 'BOS', 2680).
airports_distance('SJC', 'BWI', 2431).
airports_distance('SJC', 'DFW', 1435).
airports_distance('SJC', 'IAH', 1604).
airports_distance('SJC', 'JFK', 2561).
airports_distance('SJC', 'LAX', 308).
airports_distance('SJC', 'MCO', 2415).
airports_distance('SJC', 'MSP', 1571).
airports_distance('SJC', 'ORD', 1824).
airports_distance('SJC', 'PHX', 620).
airports_distance('SJC', 'SEA', 697).
airports_distance('SJC', 'SAN', 417).
airports_distance('SJC', 'LGB', 324).
airports_distance('SJC', 'SNA', 342).
airports_distance('SJC', 'SLC', 583).
airports_distance('SJC', 'LAS', 385).
airports_distance('SJC', 'DEN', 945).
airports_distance('SJC', 'SAT', 1451).
airports_distance('SJC', 'MSY', 1880).
airports_distance('SJC', 'EWR', 2541).
airports_distance('SJC', 'HNL', 2413).
airports_distance('SJC', 'HOU', 1618).
airports_distance('SJC', 'TUS', 720).
airports_distance('SJC', 'DTW', 2056).
airports_distance('TPA', 'ATL', 407).
airports_distance('TPA', 'AUS', 925).
airports_distance('TPA', 'BNA', 613).
airports_distance('TPA', 'BOS', 1185).
airports_distance('TPA', 'BWI', 843).
airports_distance('TPA', 'DCA', 815).
airports_distance('TPA', 'DFW', 927).
airports_distance('TPA', 'FLL', 197).
airports_distance('TPA', 'IAD', 811).
airports_distance('TPA', 'IAH', 786).
airports_distance('TPA', 'JFK', 1006).
airports_distance('TPA', 'LAX', 2152).
airports_distance('TPA', 'LGA', 1011).
airports_distance('TPA', 'MIA', 204).
airports_distance('TPA', 'MSP', 1307).
airports_distance('TPA', 'ORD', 1013).
airports_distance('TPA', 'PBI', 174).
airports_distance('TPA', 'RDU', 588).
airports_distance('TPA', 'SEA', 2515).
airports_distance('TPA', 'SFO', 2387).
airports_distance('TPA', 'SAN', 2081).
airports_distance('TPA', 'SLC', 1884).
airports_distance('TPA', 'LAS', 1979).
airports_distance('TPA', 'DEN', 1504).
airports_distance('TPA', 'HPN', 1033).
airports_distance('TPA', 'SAT', 970).
airports_distance('TPA', 'MSY', 487).
airports_distance('TPA', 'EWR', 998).
airports_distance('TPA', 'HOU', 779).
airports_distance('TPA', 'SJU', 1236).
airports_distance('TPA', 'CLE', 929).
airports_distance('TPA', 'PHL', 921).
airports_distance('TPA', 'DTW', 984).
airports_distance('SAN', 'ATL', 1886).
airports_distance('SAN', 'AUS', 1161).
airports_distance('SAN', 'BNA', 1746).
airports_distance('SAN', 'BOS', 2581).
airports_distance('SAN', 'BWI', 2289).
airports_distance('SAN', 'DCA', 2269).
airports_distance('SAN', 'DFW', 1168).
airports_distance('SAN', 'FLL', 2263).
airports_distance('SAN', 'IAD', 2247).
airports_distance('SAN', 'IAH', 1300).
airports_distance('SAN', 'JFK', 2439).
airports_distance('SAN', 'LAX', 109).
airports_distance('SAN', 'MCO', 2143).
airports_distance('SAN', 'MIA', 2262).
airports_distance('SAN', 'MSP', 1529).
airports_distance('SAN', 'ORD', 1719).
airports_distance('SAN', 'PHX', 303).
airports_distance('SAN', 'RDU', 2187).
airports_distance('SAN', 'SEA', 1051).
airports_distance('SAN', 'SFO', 446).
airports_distance('SAN', 'SJC', 417).
airports_distance('SAN', 'TPA', 2081).
airports_distance('SAN', 'SLC', 626).
airports_distance('SAN', 'LAS', 259).
airports_distance('SAN', 'DEN', 852).
airports_distance('SAN', 'SAT', 1127).
airports_distance('SAN', 'MSY', 1595).
airports_distance('SAN', 'EWR', 2419).
airports_distance('SAN', 'HNL', 2608).
airports_distance('SAN', 'HOU', 1309).
airports_distance('SAN', 'ELP', 634).
airports_distance('SAN', 'OAK', 446).
airports_distance('SAN', 'CLE', 2021).
airports_distance('SAN', 'TUS', 367).
airports_distance('SAN', 'PHL', 2363).
airports_distance('SAN', 'DTW', 1951).
airports_distance('LGB', 'ATL', 1928).
airports_distance('LGB', 'ANC', 2356).
airports_distance('LGB', 'AUS', 1223).
airports_distance('LGB', 'BOS', 2595).
airports_distance('LGB', 'FLL', 2322).
airports_distance('LGB', 'JFK', 2458).
airports_distance('LGB', 'SEA', 966).
airports_distance('LGB', 'SFO', 353).
airports_distance('LGB', 'SJC', 324).
airports_distance('LGB', 'LAS', 231).
airports_distance('LGB', 'HNL', 2564).
airports_distance('LGB', 'OAK', 353).
airports_distance('SNA', 'ATL', 1913).
airports_distance('SNA', 'AUS', 1206).
airports_distance('SNA', 'DFW', 1201).
airports_distance('SNA', 'IAH', 1343).
airports_distance('SNA', 'JFK', 2447).
airports_distance('SNA', 'MSP', 1519).
airports_distance('SNA', 'ORD', 1721).
airports_distance('SNA', 'PHX', 337).
airports_distance('SNA', 'SEA', 979).
airports_distance('SNA', 'SFO', 371).
airports_distance('SNA', 'SJC', 342).
airports_distance('SNA', 'SLC', 588).
airports_distance('SNA', 'LAS', 226).
airports_distance('SNA', 'DEN', 844).
airports_distance('SNA', 'SAT', 1174).
airports_distance('SNA', 'EWR', 2426).
airports_distance('SNA', 'HOU', 1353).
airports_distance('SNA', 'OAK', 371).
airports_distance('SNA', 'DTW', 1954).
airports_distance('SLC', 'ATL', 1586).
airports_distance('SLC', 'AUS', 1085).
airports_distance('SLC', 'BNA', 1400).
airports_distance('SLC', 'BOS', 2098).
airports_distance('SLC', 'BWI', 1859).
airports_distance('SLC', 'DFW', 987).
airports_distance('SLC', 'FLL', 2080).
airports_distance('SLC', 'IAD', 1822).
airports_distance('SLC', 'IAH', 1194).
airports_distance('SLC', 'JFK', 1983).
airports_distance('SLC', 'LAX', 589).
airports_distance('SLC', 'MCO', 1927).
airports_distance('SLC', 'MIA', 2085).
airports_distance('SLC', 'MSP', 988).
airports_distance('SLC', 'ORD', 1246).
airports_distance('SLC', 'PHX', 508).
airports_distance('SLC', 'RDU', 1818).
airports_distance('SLC', 'SEA', 687).
airports_distance('SLC', 'SFO', 597).
airports_distance('SLC', 'SJC', 583).
airports_distance('SLC', 'TPA', 1884).
airports_distance('SLC', 'SAN', 626).
airports_distance('SLC', 'SNA', 588).
airports_distance('SLC', 'LAS', 368).
airports_distance('SLC', 'DEN', 390).
airports_distance('SLC', 'SAT', 1086).
airports_distance('SLC', 'MSY', 1426).
airports_distance('SLC', 'EWR', 1962).
airports_distance('SLC', 'ELP', 694).
airports_distance('SLC', 'CLE', 1560).
airports_distance('SLC', 'OAK', 587).
airports_distance('SLC', 'TUS', 602).
airports_distance('SLC', 'PHL', 1920).
airports_distance('SLC', 'DTW', 1477).
airports_distance('LAS', 'ATL', 1742).
airports_distance('LAS', 'ANC', 2300).
airports_distance('LAS', 'AUS', 1087).
airports_distance('LAS', 'BNA', 1583).
airports_distance('LAS', 'BOS', 2374).
airports_distance('LAS', 'BWI', 2099).
airports_distance('LAS', 'DCA', 2082).
airports_distance('LAS', 'DFW', 1052).
airports_distance('LAS', 'FLL', 2168).
airports_distance('LAS', 'IAD', 2059).
airports_distance('LAS', 'IAH', 1219).
airports_distance('LAS', 'JFK', 2241).
airports_distance('LAS', 'LAX', 236).
airports_distance('LAS', 'MCO', 2034).
airports_distance('LAS', 'MIA', 2170).
airports_distance('LAS', 'MSP', 1296).
airports_distance('LAS', 'ORD', 1510).
airports_distance('LAS', 'PHX', 255).
airports_distance('LAS', 'RDU', 2020).
airports_distance('LAS', 'SEA', 866).
airports_distance('LAS', 'SFO', 413).
airports_distance('LAS', 'SJC', 385).
airports_distance('LAS', 'TPA', 1979).
airports_distance('LAS', 'SAN', 259).
airports_distance('LAS', 'LGB', 231).
airports_distance('LAS', 'SNA', 226).
airports_distance('LAS', 'SLC', 368).
airports_distance('LAS', 'DEN', 627).
airports_distance('LAS', 'SAT', 1066).
airports_distance('LAS', 'MSY', 1496).
airports_distance('LAS', 'EWR', 2220).
airports_distance('LAS', 'CID', 1316).
airports_distance('LAS', 'HNL', 2757).
airports_distance('LAS', 'HOU', 1232).
airports_distance('LAS', 'ELP', 582).
airports_distance('LAS', 'CLE', 1819).
airports_distance('LAS', 'OAK', 406).
airports_distance('LAS', 'TUS', 364).
airports_distance('LAS', 'PHL', 2170).
airports_distance('LAS', 'DTW', 1744).
airports_distance('DEN', 'ATL', 1196).
airports_distance('DEN', 'ANC', 2399).
airports_distance('DEN', 'AUS', 775).
airports_distance('DEN', 'BNA', 1011).
airports_distance('DEN', 'BOS', 1748).
airports_distance('DEN', 'BWI', 1486).
airports_distance('DEN', 'DCA', 1471).
airports_distance('DEN', 'DFW', 641).
airports_distance('DEN', 'FLL', 1701).
airports_distance('DEN', 'IAD', 1448).
airports_distance('DEN', 'IAH', 862).
airports_distance('DEN', 'JFK', 1621).
airports_distance('DEN', 'LAX', 860).
airports_distance('DEN', 'LGA', 1614).
airports_distance('DEN', 'MCO', 1544).
airports_distance('DEN', 'MIA', 1707).
airports_distance('DEN', 'MSP', 678).
airports_distance('DEN', 'ORD', 885).
airports_distance('DEN', 'PBI', 1677).
airports_distance('DEN', 'PHX', 601).
airports_distance('DEN', 'RDU', 1432).
airports_distance('DEN', 'SEA', 1021).
airports_distance('DEN', 'SFO', 964).
airports_distance('DEN', 'SJC', 945).
airports_distance('DEN', 'TPA', 1504).
airports_distance('DEN', 'SAN', 852).
airports_distance('DEN', 'SNA', 844).
airports_distance('DEN', 'SLC', 390).
airports_distance('DEN', 'LAS', 627).
airports_distance('DEN', 'SAT', 795).
airports_distance('DEN', 'MSY', 1061).
airports_distance('DEN', 'EWR', 1600).
airports_distance('DEN', 'CID', 690).
airports_distance('DEN', 'HNL', 3358).
airports_distance('DEN', 'HOU', 883).
airports_distance('DEN', 'ELP', 564).
airports_distance('DEN', 'CLE', 1197).
airports_distance('DEN', 'OAK', 954).
airports_distance('DEN', 'TUS', 639).
airports_distance('DEN', 'SAF', 303).
airports_distance('DEN', 'PHL', 1553).
airports_distance('DEN', 'DTW', 1119).
airports_distance('HPN', 'ATL', 780).
airports_distance('HPN', 'BOS', 166).
airports_distance('HPN', 'DCA', 233).
airports_distance('HPN', 'FLL', 1099).
airports_distance('HPN', 'MCO', 972).
airports_distance('HPN', 'MIA', 1120).
airports_distance('HPN', 'ORD', 736).
airports_distance('HPN', 'PBI', 1058).
airports_distance('HPN', 'TPA', 1033).
airports_distance('HPN', 'PHL', 115).
airports_distance('HPN', 'DTW', 504).
airports_distance('SAT', 'ATL', 872).
airports_distance('SAT', 'AUS', 66).
airports_distance('SAT', 'BNA', 821).
airports_distance('SAT', 'BWI', 1405).
airports_distance('SAT', 'DFW', 247).
airports_distance('SAT', 'FLL', 1143).
airports_distance('SAT', 'IAD', 1359).
airports_distance('SAT', 'IAH', 190).
airports_distance('SAT', 'JFK', 1584).
airports_distance('SAT', 'LAX', 1208).
airports_distance('SAT', 'MCO', 1038).
airports_distance('SAT', 'MIA', 1140).
airports_distance('SAT', 'MSP', 1098).
airports_distance('SAT', 'ORD', 1042).
airports_distance('SAT', 'PHX', 841).
airports_distance('SAT', 'RDU', 1222).
airports_distance('SAT', 'SEA', 1772).
airports_distance('SAT', 'SFO', 1479).
airports_distance('SAT', 'SJC', 1451).
airports_distance('SAT', 'TPA', 970).
airports_distance('SAT', 'SAN', 1127).
airports_distance('SAT', 'SNA', 1174).
airports_distance('SAT', 'SLC', 1086).
airports_distance('SAT', 'LAS', 1066).
airports_distance('SAT', 'DEN', 795).
airports_distance('SAT', 'MSY', 493).
airports_distance('SAT', 'EWR', 1566).
airports_distance('SAT', 'HOU', 192).
airports_distance('SAT', 'ELP', 495).
airports_distance('SAT', 'CLE', 1239).
airports_distance('SAT', 'OAK', 1473).
airports_distance('SAT', 'PHL', 1493).
airports_distance('SAT', 'DTW', 1214).
airports_distance('MSY', 'ATL', 424).
airports_distance('MSY', 'AUS', 443).
airports_distance('MSY', 'BNA', 471).
airports_distance('MSY', 'BOS', 1366).
airports_distance('MSY', 'BWI', 997).
airports_distance('MSY', 'DCA', 968).
airports_distance('MSY', 'DFW', 447).
airports_distance('MSY', 'FLL', 672).
airports_distance('MSY', 'IAD', 954).
airports_distance('MSY', 'IAH', 304).
airports_distance('MSY', 'JFK', 1181).
airports_distance('MSY', 'LAX', 1666).
airports_distance('MSY', 'LGA', 1182).
airports_distance('MSY', 'MCO', 550).
airports_distance('MSY', 'MIA', 673).
airports_distance('MSY', 'MSP', 1041).
airports_distance('MSY', 'ORD', 838).
airports_distance('MSY', 'PHX', 1297).
airports_distance('MSY', 'RDU', 778).
airports_distance('MSY', 'SEA', 2082).
airports_distance('MSY', 'SFO', 1906).
airports_distance('MSY', 'SJC', 1880).
airports_distance('MSY', 'TPA', 487).
airports_distance('MSY', 'SAN', 1595).
airports_distance('MSY', 'SLC', 1426).
airports_distance('MSY', 'LAS', 1496).
airports_distance('MSY', 'DEN', 1061).
airports_distance('MSY', 'SAT', 493).
airports_distance('MSY', 'EWR', 1166).
airports_distance('MSY', 'HOU', 302).
airports_distance('MSY', 'CLE', 917).
airports_distance('MSY', 'OAK', 1898).
airports_distance('MSY', 'PHL', 1087).
airports_distance('MSY', 'DTW', 927).
airports_distance('EWR', 'ATL', 745).
airports_distance('EWR', 'AUS', 1501).
airports_distance('EWR', 'BNA', 746).
airports_distance('EWR', 'BOS', 200).
airports_distance('EWR', 'BWI', 169).
airports_distance('EWR', 'DCA', 198).
airports_distance('EWR', 'DFW', 1369).
airports_distance('EWR', 'FLL', 1066).
airports_distance('EWR', 'IAD', 212).
airports_distance('EWR', 'IAH', 1397).
airports_distance('EWR', 'LAX', 2447).
airports_distance('EWR', 'MCO', 938).
airports_distance('EWR', 'MIA', 1087).
airports_distance('EWR', 'MSP', 1005).
airports_distance('EWR', 'ORD', 717).
airports_distance('EWR', 'PBI', 1025).
airports_distance('EWR', 'PHX', 2127).
airports_distance('EWR', 'RDU', 416).
airports_distance('EWR', 'SEA', 2394).
airports_distance('EWR', 'SFO', 2557).
airports_distance('EWR', 'SJC', 2541).
airports_distance('EWR', 'TPA', 998).
airports_distance('EWR', 'SAN', 2419).
airports_distance('EWR', 'SNA', 2426).
airports_distance('EWR', 'SLC', 1962).
airports_distance('EWR', 'LAS', 2220).
airports_distance('EWR', 'DEN', 1600).
airports_distance('EWR', 'SAT', 1566).
airports_distance('EWR', 'MSY', 1166).
airports_distance('EWR', 'HNL', 4951).
airports_distance('EWR', 'HOU', 1409).
airports_distance('EWR', 'SJU', 1611).
airports_distance('EWR', 'CLE', 403).
airports_distance('EWR', 'OAK', 2547).
airports_distance('EWR', 'PHL', 80).
airports_distance('EWR', 'DTW', 486).
airports_distance('CID', 'ATL', 694).
airports_distance('CID', 'BNA', 481).
airports_distance('CID', 'DFW', 686).
airports_distance('CID', 'LAX', 1546).
airports_distance('CID', 'MCO', 1097).
airports_distance('CID', 'MSP', 220).
airports_distance('CID', 'ORD', 196).
airports_distance('CID', 'DEN', 690).
airports_distance('CID', 'LAS', 1316).
airports_distance('CID', 'DTW', 429).
airports_distance('HNL', 'ATL', 4492).
airports_distance('HNL', 'ANC', 2778).
airports_distance('HNL', 'AUS', 3755).
airports_distance('HNL', 'BOS', 5083).
airports_distance('HNL', 'DFW', 3776).
airports_distance('HNL', 'IAD', 4806).
airports_distance('HNL', 'IAH', 3895).
airports_distance('HNL', 'JFK', 4972).
airports_distance('HNL', 'LAX', 2551).
airports_distance('HNL', 'MSP', 3964).
airports_distance('HNL', 'ORD', 4234).
airports_distance('HNL', 'PHX', 2911).
airports_distance('HNL', 'SEA', 2675).
airports_distance('HNL', 'SFO', 2395).
airports_distance('HNL', 'SJC', 2413).
airports_distance('HNL', 'SAN', 2608).
airports_distance('HNL', 'LGB', 2564).
airports_distance('HNL', 'LAS', 2757).
airports_distance('HNL', 'DEN', 3358).
airports_distance('HNL', 'EWR', 4951).
airports_distance('HNL', 'OAK', 2405).
airports_distance('HOU', 'ATL', 694).
airports_distance('HOU', 'AUS', 148).
airports_distance('HOU', 'BNA', 669).
airports_distance('HOU', 'BOS', 1606).
airports_distance('HOU', 'BWI', 1244).
airports_distance('HOU', 'DCA', 1216).
airports_distance('HOU', 'DFW', 247).
airports_distance('HOU', 'FLL', 955).
airports_distance('HOU', 'JFK', 1426).
airports_distance('HOU', 'LAX', 1386).
airports_distance('HOU', 'LGA', 1425).
airports_distance('HOU', 'MCO', 847).
airports_distance('HOU', 'MIA', 953).
airports_distance('HOU', 'PHX', 1018).
airports_distance('HOU', 'RDU', 1048).
airports_distance('HOU', 'SJC', 1618).
airports_distance('HOU', 'SEA', 1891).
airports_distance('HOU', 'TPA', 779).
airports_distance('HOU', 'SAN', 1309).
airports_distance('HOU', 'SNA', 1353).
airports_distance('HOU', 'LAS', 1232).
airports_distance('HOU', 'DEN', 883).
airports_distance('HOU', 'SAT', 192).
airports_distance('HOU', 'MSY', 302).
airports_distance('HOU', 'EWR', 1409).
airports_distance('HOU', 'ELP', 675).
airports_distance('HOU', 'SJU', 1994).
airports_distance('HOU', 'CLE', 1106).
airports_distance('HOU', 'OAK', 1638).
airports_distance('HOU', 'PHL', 1333).
airports_distance('ELP', 'ATL', 1279).
airports_distance('ELP', 'AUS', 527).
airports_distance('ELP', 'DFW', 550).
airports_distance('ELP', 'IAH', 666).
airports_distance('ELP', 'LAX', 713).
airports_distance('ELP', 'ORD', 1234).
airports_distance('ELP', 'PHX', 346).
airports_distance('ELP', 'SEA', 1367).
airports_distance('ELP', 'SAN', 634).
airports_distance('ELP', 'SLC', 694).
airports_distance('ELP', 'LAS', 582).
airports_distance('ELP', 'DEN', 564).
airports_distance('ELP', 'SAT', 495).
airports_distance('ELP', 'HOU', 675).
airports_distance('ELP', 'OAK', 985).
airports_distance('SJU', 'ATL', 1547).
airports_distance('SJU', 'BOS', 1678).
airports_distance('SJU', 'BWI', 1568).
airports_distance('SJU', 'DCA', 1557).
airports_distance('SJU', 'DFW', 2162).
airports_distance('SJU', 'FLL', 1045).
airports_distance('SJU', 'IAD', 1573).
airports_distance('SJU', 'IAH', 2004).
airports_distance('SJU', 'JFK', 1601).
airports_distance('SJU', 'MCO', 1188).
airports_distance('SJU', 'MIA', 1044).
airports_distance('SJU', 'ORD', 2072).
airports_distance('SJU', 'PBI', 1062).
airports_distance('SJU', 'RDU', 1434).
airports_distance('SJU', 'TPA', 1236).
airports_distance('SJU', 'EWR', 1611).
airports_distance('SJU', 'HOU', 1994).
airports_distance('SJU', 'PHL', 1579).
airports_distance('CLE', 'ATL', 555).
airports_distance('CLE', 'AUS', 1173).
airports_distance('CLE', 'BNA', 448).
airports_distance('CLE', 'BOS', 561).
airports_distance('CLE', 'BWI', 313).
airports_distance('CLE', 'DCA', 309).
airports_distance('CLE', 'DFW', 1019).
airports_distance('CLE', 'FLL', 1064).
airports_distance('CLE', 'IAD', 288).
airports_distance('CLE', 'IAH', 1090).
airports_distance('CLE', 'JFK', 424).
airports_distance('CLE', 'LAX', 2047).
airports_distance('CLE', 'LGA', 417).
airports_distance('CLE', 'MCO', 897).
airports_distance('CLE', 'MIA', 1082).
airports_distance('CLE', 'MSP', 620).
airports_distance('CLE', 'ORD', 315).
airports_distance('CLE', 'PBI', 1022).
airports_distance('CLE', 'PHX', 1733).
airports_distance('CLE', 'RDU', 416).
airports_distance('CLE', 'SFO', 2155).
airports_distance('CLE', 'TPA', 929).
airports_distance('CLE', 'SAN', 2021).
airports_distance('CLE', 'SLC', 1560).
airports_distance('CLE', 'LAS', 1819).
airports_distance('CLE', 'DEN', 1197).
airports_distance('CLE', 'SAT', 1239).
airports_distance('CLE', 'MSY', 917).
airports_distance('CLE', 'EWR', 403).
airports_distance('CLE', 'HOU', 1106).
airports_distance('CLE', 'PHL', 362).
airports_distance('CLE', 'DTW', 95).
airports_distance('OAK', 'ATL', 2124).
airports_distance('OAK', 'AUS', 1494).
airports_distance('OAK', 'BNA', 1953).
airports_distance('OAK', 'BOS', 2685).
airports_distance('OAK', 'BWI', 2439).
airports_distance('OAK', 'DFW', 1453).
airports_distance('OAK', 'IAD', 2401).
airports_distance('OAK', 'JFK', 2568).
airports_distance('OAK', 'LAX', 337).
airports_distance('OAK', 'MSP', 1574).
airports_distance('OAK', 'ORD', 1830).
airports_distance('OAK', 'PHX', 645).
airports_distance('OAK', 'SEA', 672).
airports_distance('OAK', 'SAN', 446).
airports_distance('OAK', 'LGB', 353).
airports_distance('OAK', 'SNA', 371).
airports_distance('OAK', 'SLC', 587).
airports_distance('OAK', 'LAS', 406).
airports_distance('OAK', 'DEN', 954).
airports_distance('OAK', 'SAT', 1473).
airports_distance('OAK', 'EWR', 2547).
airports_distance('OAK', 'MSY', 1898).
airports_distance('OAK', 'HNL', 2405).
airports_distance('OAK', 'HOU', 1638).
airports_distance('OAK', 'ELP', 985).
airports_distance('OAK', 'DTW', 2062).
airports_distance('TUS', 'ATL', 1537).
airports_distance('TUS', 'AUS', 795).
airports_distance('TUS', 'DFW', 811).
airports_distance('TUS', 'IAH', 934).
airports_distance('TUS', 'JFK', 2131).
airports_distance('TUS', 'LAX', 450).
airports_distance('TUS', 'MSP', 1296).
airports_distance('TUS', 'ORD', 1434).
airports_distance('TUS', 'PHX', 110).
airports_distance('TUS', 'SEA', 1215).
airports_distance('TUS', 'SFO', 750).
airports_distance('TUS', 'SJC', 720).
airports_distance('TUS', 'SAN', 367).
airports_distance('TUS', 'SLC', 602).
airports_distance('TUS', 'LAS', 364).
airports_distance('TUS', 'DEN', 639).
airports_distance('SAF', 'DFW', 549).
airports_distance('SAF', 'LAX', 708).
airports_distance('SAF', 'PHX', 369).
airports_distance('SAF', 'DEN', 303).
airports_distance('PHL', 'ATL', 665).
airports_distance('PHL', 'AUS', 1428).
airports_distance('PHL', 'BNA', 673).
airports_distance('PHL', 'BOS', 280).
airports_distance('PHL', 'BWI', 90).
airports_distance('PHL', 'DCA', 119).
airports_distance('PHL', 'DFW', 1300).
airports_distance('PHL', 'FLL', 994).
airports_distance('PHL', 'IAD', 134).
airports_distance('PHL', 'IAH', 1322).
airports_distance('PHL', 'JFK', 94).
airports_distance('PHL', 'LAX', 2395).
airports_distance('PHL', 'LGA', 95).
airports_distance('PHL', 'MCO', 862).
airports_distance('PHL', 'MIA', 1015).
airports_distance('PHL', 'MSP', 978).
airports_distance('PHL', 'ORD', 676).
airports_distance('PHL', 'PBI', 952).
airports_distance('PHL', 'PHX', 2069).
airports_distance('PHL', 'RDU', 337).
airports_distance('PHL', 'SEA', 2371).
airports_distance('PHL', 'SFO', 2513).
airports_distance('PHL', 'TPA', 921).
airports_distance('PHL', 'SAN', 2363).
airports_distance('PHL', 'SLC', 1920).
airports_distance('PHL', 'LAS', 2170).
airports_distance('PHL', 'DEN', 1553).
airports_distance('PHL', 'HPN', 115).
airports_distance('PHL', 'SAT', 1493).
airports_distance('PHL', 'MSY', 1087).
airports_distance('PHL', 'EWR', 80).
airports_distance('PHL', 'HOU', 1333).
airports_distance('PHL', 'SJU', 1579).
airports_distance('PHL', 'CLE', 362).
airports_distance('PHL', 'DTW', 452).
airports_distance('DTW', 'ATL', 595).
airports_distance('DTW', 'AUS', 1148).
airports_distance('DTW', 'BNA', 456).
airports_distance('DTW', 'BOS', 630).
airports_distance('DTW', 'BWI', 408).
airports_distance('DTW', 'DCA', 404).
airports_distance('DTW', 'DFW', 985).
airports_distance('DTW', 'FLL', 1129).
airports_distance('DTW', 'IAD', 383).
airports_distance('DTW', 'IAH', 1075).
airports_distance('DTW', 'JFK', 507).
airports_distance('DTW', 'LAX', 1973).
airports_distance('DTW', 'LGA', 500).
airports_distance('DTW', 'MCO', 959).
airports_distance('DTW', 'MIA', 1147).
airports_distance('DTW', 'MSP', 527).
airports_distance('DTW', 'ORD', 234).
airports_distance('DTW', 'PBI', 1088).
airports_distance('DTW', 'PHX', 1667).
airports_distance('DTW', 'RDU', 501).
airports_distance('DTW', 'SEA', 1921).
airports_distance('DTW', 'SFO', 2072).
airports_distance('DTW', 'SJC', 2056).
airports_distance('DTW', 'TPA', 984).
airports_distance('DTW', 'SAN', 1951).
airports_distance('DTW', 'SNA', 1954).
airports_distance('DTW', 'SLC', 1477).
airports_distance('DTW', 'LAS', 1744).
airports_distance('DTW', 'DEN', 1119).
airports_distance('DTW', 'HPN', 504).
airports_distance('DTW', 'SAT', 1214).
airports_distance('DTW', 'MSY', 927).
airports_distance('DTW', 'EWR', 486).
airports_distance('DTW', 'CID', 429).
airports_distance('DTW', 'CLE', 95).
airports_distance('DTW', 'OAK', 2062).
airports_distance('DTW', 'PHL', 452).
airports_distance('ATL', 'YYZ', 740).
airports_distance('ATL', 'LHR', 4198).
airports_distance('ATL', 'CDG', 4381).
airports_distance('ATL', 'FRA', 4600).
airports_distance('ATL', 'NRT', 6832).
airports_distance('ATL', 'DXB', 7581).
airports_distance('ATL', 'DUB', 3926).
airports_distance('ATL', 'PVG', 7640).
airports_distance('ATL', 'FCO', 5021).
airports_distance('ATL', 'AMS', 4387).
airports_distance('ATL', 'MAD', 4322).
airports_distance('ATL', 'ZRH', 4677).
airports_distance('ATL', 'BRU', 4412).
airports_distance('ATL', 'MUC', 4782).
airports_distance('ATL', 'RSW', 516).
airports_distance('ATL', 'MAN', 4086).
airports_distance('ATL', 'YUL', 994).
airports_distance('ATL', 'YYC', 1910).
airports_distance('ATL', 'DOH', 7442).
airports_distance('ATL', 'ICN', 7133).
airports_distance('ATL', 'JNB', 8434).
airports_distance('ATL', 'GIG', 4745).
airports_distance('ATL', 'GRU', 4663).
airports_distance('ATL', 'EZE', 5015).
airports_distance('ATL', 'LIM', 3189).
airports_distance('ATL', 'SCL', 4712).
airports_distance('ATL', 'MEX', 1331).
airports_distance('ATL', 'KIN', 1183).
airports_distance('ATL', 'TLH', 224).
airports_distance('ATL', 'PIT', 527).
airports_distance('ATL', 'PWM', 1026).
airports_distance('ATL', 'PDX', 2167).
airports_distance('ATL', 'OKC', 759).
airports_distance('ATL', 'ONT', 1894).
airports_distance('ATL', 'ROC', 749).
airports_distance('ATL', 'RST', 831).
airports_distance('ATL', 'IST', 5742).
airports_distance('ATL', 'STR', 4667).
airports_distance('ATL', 'CLT', 226).
airports_distance('ATL', 'CUN', 883).
airports_distance('ATL', 'PSP', 1834).
airports_distance('ATL', 'MEM', 331).
airports_distance('ATL', 'CVG', 374).
airports_distance('ATL', 'IND', 432).
airports_distance('ATL', 'MCI', 691).
airports_distance('ATL', 'DAL', 719).
airports_distance('ATL', 'STL', 484).
airports_distance('ATL', 'ABQ', 1266).
airports_distance('ATL', 'MKE', 670).
airports_distance('ATL', 'MDW', 591).
airports_distance('ATL', 'OMA', 820).
airports_distance('ATL', 'TUL', 672).
airports_distance('ATL', 'PVR', 1556).
airports_distance('ATL', 'DUS', 4493).
airports_distance('ATL', 'LIS', 4089).
airports_distance('ATL', 'NAS', 726).
airports_distance('ATL', 'FPO', 596).
airports_distance('ATL', 'GGT', 867).
airports_distance('ATL', 'EYW', 647).
airports_distance('ATL', 'BGI', 2113).
airports_distance('ATL', 'STT', 1599).
airports_distance('ATL', 'BDA', 1145).
airports_distance('ATL', 'LOS', 5834).
airports_distance('ATL', 'MBJ', 1120).
airports_distance('ATL', 'LIT', 452).
airports_distance('ATL', 'BON', 1800).
airports_distance('ATL', 'AUA', 1718).
airports_distance('ATL', 'ORF', 515).
airports_distance('ATL', 'JAX', 270).
airports_distance('ATL', 'PVD', 902).
airports_distance('ATL', 'PUJ', 1437).
airports_distance('ATL', 'MDT', 619).
airports_distance('ATL', 'SJO', 1632).
airports_distance('ATL', 'SMF', 2086).
airports_distance('ATL', 'RTB', 1203).
airports_distance('ATL', 'TGU', 1363).
airports_distance('ATL', 'COS', 1181).
airports_distance('ATL', 'HSV', 151).
airports_distance('ATL', 'BHM', 134).
airports_distance('ATL', 'SDF', 322).
airports_distance('ATL', 'BUF', 712).
airports_distance('ATL', 'SHV', 550).
airports_distance('ATL', 'ECP', 241).
airports_distance('ATL', 'RNO', 1988).
airports_distance('ATL', 'CMH', 447).
airports_distance('ATL', 'ALB', 852).
airports_distance('ATL', 'ICT', 780).
airports_distance('ATL', 'BDL', 858).
airports_distance('ATL', 'SXM', 1701).
airports_distance('ATL', 'SGF', 562).
airports_distance('ATL', 'RIC', 480).
airports_distance('ATL', 'CCS', 1936).
airports_distance('ATL', 'PIA', 565).
airports_distance('ATL', 'LEX', 304).
airports_distance('ATL', 'GUA', 1370).
airports_distance('ATL', 'ISP', 794).
airports_distance('ATL', 'HAV', 745).
airports_distance('ATL', 'BMI', 533).
airports_distance('ATL', 'BOG', 2104).
airports_distance('ATL', 'DSM', 743).
airports_distance('ATL', 'MYR', 316).
airports_distance('ATL', 'AEX', 499).
airports_distance('ATL', 'CZM', 918).
airports_distance('ATL', 'MTY', 1084).
airports_distance('ATL', 'BJX', 1359).
airports_distance('ATL', 'BTR', 448).
airports_distance('ATL', 'BZE', 1137).
airports_distance('ATL', 'CAE', 191).
airports_distance('ATL', 'CHA', 106).
airports_distance('ATL', 'CHS', 258).
airports_distance('ATL', 'CRW', 363).
airports_distance('ATL', 'DAY', 433).
airports_distance('ATL', 'EVV', 350).
airports_distance('ATL', 'FAR', 1123).
airports_distance('ATL', 'FSD', 953).
airports_distance('ATL', 'FSM', 577).
airports_distance('ATL', 'FWA', 509).
airports_distance('ATL', 'GDL', 1468).
airports_distance('ATL', 'GPT', 351).
airports_distance('ATL', 'GRK', 801).
airports_distance('ATL', 'GRR', 641).
airports_distance('ATL', 'GSO', 306).
airports_distance('ATL', 'GSP', 153).
airports_distance('ATL', 'JAN', 340).
airports_distance('ATL', 'LFT', 502).
airports_distance('ATL', 'LIR', 1593).
airports_distance('ATL', 'MGM', 147).
airports_distance('ATL', 'MLI', 633).
airports_distance('ATL', 'MLU', 447).
airports_distance('ATL', 'MOB', 302).
airports_distance('ATL', 'MSN', 708).
airports_distance('ATL', 'PLS', 1104).
airports_distance('ATL', 'PNS', 272).
airports_distance('ATL', 'PTY', 1726).
airports_distance('ATL', 'QRO', 1318).
airports_distance('ATL', 'SAL', 1424).
airports_distance('ATL', 'SAV', 214).
airports_distance('ATL', 'SJD', 1692).
airports_distance('ATL', 'TYS', 152).
airports_distance('ATL', 'VPS', 250).
airports_distance('ATL', 'XNA', 588).
airports_distance('ATL', 'UVF', 2013).
airports_distance('ATL', 'CAK', 529).
airports_distance('ATL', 'MHT', 951).
airports_distance('ATL', 'SYR', 793).
airports_distance('ATL', 'AVL', 164).
airports_distance('ATL', 'SRQ', 445).
airports_distance('ATL', 'LAN', 631).
airports_distance('ATL', 'ROA', 357).
airports_distance('ATL', 'GRB', 775).
airports_distance('ATL', 'AGS', 143).
airports_distance('ATL', 'BTV', 960).
airports_distance('ATL', 'FAY', 330).
airports_distance('ATL', 'HHH', 237).
airports_distance('ATL', 'ILM', 376).
airports_distance('ATL', 'OAJ', 398).
airports_distance('ATL', 'UIO', 2364).
airports_distance('ATL', 'GNV', 300).
airports_distance('ATL', 'SDQ', 1390).
airports_distance('ATL', 'STI', 1299).
airports_distance('ATL', 'SAP', 1274).
airports_distance('ATL', 'MID', 933).
airports_distance('ATL', 'MGA', 1488).
airports_distance('ATL', 'PAP', 1281).
airports_distance('ATL', 'GCM', 1008).
airports_distance('ATL', 'MHH', 659).
airports_distance('ATL', 'ELH', 730).
airports_distance('ATL', 'BSB', 4178).
airports_distance('ATL', 'CTG', 1698).
airports_distance('ATL', 'PTP', 1861).
airports_distance('ATL', 'STX', 1638).
airports_distance('ATL', 'ABE', 692).
airports_distance('ATL', 'ABY', 146).
airports_distance('ATL', 'ATW', 765).
airports_distance('ATL', 'AVP', 714).
airports_distance('ATL', 'AZO', 597).
airports_distance('ATL', 'BQK', 238).
airports_distance('ATL', 'CHO', 456).
airports_distance('ATL', 'CSG', 83).
airports_distance('ATL', 'DAB', 366).
airports_distance('ATL', 'DHN', 171).
airports_distance('ATL', 'EWN', 432).
airports_distance('ATL', 'FNT', 645).
airports_distance('ATL', 'GTR', 240).
airports_distance('ATL', 'LWB', 369).
airports_distance('ATL', 'MBS', 684).
airports_distance('ATL', 'MCN', 79).
airports_distance('ATL', 'MEI', 266).
airports_distance('ATL', 'MLB', 443).
airports_distance('ATL', 'MSL', 197).
airports_distance('ATL', 'PHF', 507).
airports_distance('ATL', 'PIB', 323).
airports_distance('ATL', 'SBN', 567).
airports_distance('ATL', 'TRI', 227).
airports_distance('ATL', 'TTN', 700).
airports_distance('ATL', 'TUP', 252).
airports_distance('ATL', 'VLD', 208).
airports_distance('ATL', 'ASE', 1301).
airports_distance('ATL', 'LNK', 840).
airports_distance('ANC', 'PDX', 1538).
airports_distance('ANC', 'FAI', 260).
airports_distance('ANC', 'KEF', 3368).
airports_distance('ANC', 'BLI', 1366).
airports_distance('ANC', 'GEG', 1579).
airports_distance('ANC', 'BET', 397).
airports_distance('ANC', 'BRW', 722).
airports_distance('ANC', 'CDB', 618).
airports_distance('ANC', 'CDV', 159).
airports_distance('ANC', 'ADK', 1188).
airports_distance('ANC', 'DLG', 327).
airports_distance('ANC', 'ADQ', 252).
airports_distance('ANC', 'ENA', 59).
airports_distance('ANC', 'HOM', 117).
airports_distance('ANC', 'ILI', 194).
airports_distance('ANC', 'JNU', 569).
airports_distance('ANC', 'AKN', 287).
airports_distance('ANC', 'MCG', 219).
airports_distance('ANC', 'ANI', 317).
airports_distance('ANC', 'OME', 537).
airports_distance('ANC', 'OTZ', 546).
airports_distance('ANC', 'STG', 766).
airports_distance('ANC', 'SCC', 624).
airports_distance('ANC', 'SDP', 555).
airports_distance('ANC', 'KSM', 440).
airports_distance('ANC', 'SNP', 763).
airports_distance('ANC', 'UNK', 391).
airports_distance('ANC', 'VDZ', 125).
airports_distance('ANC', 'PKC', 1950).
airports_distance('AUS', 'YYZ', 1357).
airports_distance('AUS', 'LHR', 4901).
airports_distance('AUS', 'LGW', 4921).
airports_distance('AUS', 'FRA', 5294).
airports_distance('AUS', 'YYC', 1671).
airports_distance('AUS', 'MEX', 748).
airports_distance('AUS', 'PIT', 1209).
airports_distance('AUS', 'PDX', 1712).
airports_distance('AUS', 'OKC', 359).
airports_distance('AUS', 'ONT', 1193).
airports_distance('AUS', 'CLT', 1030).
airports_distance('AUS', 'CUN', 922).
airports_distance('AUS', 'MEM', 558).
airports_distance('AUS', 'CVG', 957).
airports_distance('AUS', 'IND', 919).
airports_distance('AUS', 'MCI', 650).
airports_distance('AUS', 'DAL', 189).
airports_distance('AUS', 'STL', 722).
airports_distance('AUS', 'ABQ', 618).
airports_distance('AUS', 'MKE', 1032).
airports_distance('AUS', 'MDW', 972).
airports_distance('AUS', 'OMA', 773).
airports_distance('AUS', 'TUL', 427).
airports_distance('AUS', 'NAS', 1284).
airports_distance('AUS', 'LIT', 446).
airports_distance('AUS', 'JAX', 952).
airports_distance('AUS', 'PVD', 1660).
airports_distance('AUS', 'SMF', 1477).
airports_distance('AUS', 'BHM', 681).
airports_distance('AUS', 'SDF', 875).
airports_distance('AUS', 'BUF', 1364).
airports_distance('AUS', 'BOI', 1373).
airports_distance('AUS', 'LBB', 341).
airports_distance('AUS', 'ECP', 708).
airports_distance('AUS', 'HRL', 274).
airports_distance('AUS', 'RNO', 1402).
airports_distance('AUS', 'CMH', 1072).
airports_distance('AUS', 'DSM', 814).
airports_distance('AUS', 'AMA', 419).
airports_distance('AUS', 'BTR', 389).
airports_distance('AUS', 'CHS', 1053).
airports_distance('AUS', 'GDL', 755).
airports_distance('AUS', 'GRR', 1103).
airports_distance('AUS', 'PNS', 625).
airports_distance('AUS', 'SJD', 887).
airports_distance('AUS', 'TYS', 881).
airports_distance('AUS', 'VPS', 664).
airports_distance('AUS', 'XNA', 463).
airports_distance('AUS', 'HDN', 890).
airports_distance('AUS', 'SFB', 992).
airports_distance('AUS', 'BUR', 1238).
airports_distance('AUS', 'ASE', 812).
airports_distance('AUS', 'BZN', 1298).
airports_distance('AUS', 'BKG', 508).
airports_distance('AUS', 'PIE', 917).
airports_distance('BNA', 'YYZ', 641).
airports_distance('BNA', 'LHR', 4168).
airports_distance('BNA', 'RSW', 723).
airports_distance('BNA', 'YYC', 1698).
airports_distance('BNA', 'PIT', 461).
airports_distance('BNA', 'PDX', 1967).
airports_distance('BNA', 'OKC', 614).
airports_distance('BNA', 'CLT', 328).
airports_distance('BNA', 'CUN', 1042).
airports_distance('BNA', 'MEM', 200).
airports_distance('BNA', 'CVG', 230).
airports_distance('BNA', 'IND', 249).
airports_distance('BNA', 'MCI', 490).
airports_distance('BNA', 'DAL', 621).
airports_distance('BNA', 'STL', 272).
airports_distance('BNA', 'MKE', 476).
airports_distance('BNA', 'MDW', 395).
airports_distance('BNA', 'JAX', 484).
airports_distance('BNA', 'PVD', 905).
airports_distance('BNA', 'BUF', 632).
airports_distance('BNA', 'ECP', 402).
airports_distance('BNA', 'CMH', 337).
airports_distance('BNA', 'RIC', 526).
airports_distance('BNA', 'MYR', 470).
airports_distance('BNA', 'CHS', 438).
airports_distance('BNA', 'GSP', 265).
airports_distance('BNA', 'PNS', 391).
airports_distance('BNA', 'SAV', 417).
airports_distance('BNA', 'VPS', 390).
airports_distance('BNA', 'SYR', 740).
airports_distance('BNA', 'SRQ', 649).
airports_distance('BNA', 'SFB', 598).
airports_distance('BNA', 'ABE', 683).
airports_distance('BNA', 'MSL', 109).
airports_distance('BNA', 'TTN', 704).
airports_distance('BNA', 'TUP', 174).
airports_distance('BNA', 'AHN', 242).
airports_distance('BNA', 'MKL', 130).
airports_distance('BNA', 'PIE', 613).
airports_distance('BNA', 'PGD', 693).
airports_distance('BOS', 'YYZ', 445).
airports_distance('BOS', 'YVR', 2505).
airports_distance('BOS', 'LHR', 3254).
airports_distance('BOS', 'LGW', 3272).
airports_distance('BOS', 'CDG', 3436).
airports_distance('BOS', 'FRA', 3656).
airports_distance('BOS', 'NRT', 6682).
airports_distance('BOS', 'DXB', 6645).
airports_distance('BOS', 'DUB', 2982).
airports_distance('BOS', 'HKG', 7952).
airports_distance('BOS', 'PEK', 6716).
airports_distance('BOS', 'PVG', 7288).
airports_distance('BOS', 'FCO', 4079).
airports_distance('BOS', 'AMS', 3445).
airports_distance('BOS', 'BCN', 3637).
airports_distance('BOS', 'MAD', 3398).
airports_distance('BOS', 'ZRH', 3732).
airports_distance('BOS', 'YOW', 309).
airports_distance('BOS', 'BRU', 3468).
airports_distance('BOS', 'MUC', 3838).
airports_distance('BOS', 'RSW', 1250).
airports_distance('BOS', 'MAN', 3143).
airports_distance('BOS', 'YUL', 254).
airports_distance('BOS', 'CGN', 3576).
airports_distance('BOS', 'SNN', 2885).
airports_distance('BOS', 'OSL', 3492).
airports_distance('BOS', 'STN', 3273).
airports_distance('BOS', 'EDI', 3058).
airports_distance('BOS', 'DOH', 6501).
airports_distance('BOS', 'ICN', 6808).
airports_distance('BOS', 'GRU', 4805).
airports_distance('BOS', 'MEX', 2276).
airports_distance('BOS', 'TLV', 5475).
airports_distance('BOS', 'PIT', 495).
airports_distance('BOS', 'PDX', 2529).
airports_distance('BOS', 'ROC', 342).
airports_distance('BOS', 'IST', 4798).
airports_distance('BOS', 'YHZ', 413).
airports_distance('BOS', 'CPH', 3658).
airports_distance('BOS', 'CLT', 727).
airports_distance('BOS', 'CUN', 1736).
airports_distance('BOS', 'PSP', 2510).
airports_distance('BOS', 'CVG', 750).
airports_distance('BOS', 'IND', 816).
airports_distance('BOS', 'MCI', 1252).
airports_distance('BOS', 'DAL', 1551).
airports_distance('BOS', 'STL', 1044).
airports_distance('BOS', 'MKE', 857).
airports_distance('BOS', 'MDW', 858).
airports_distance('BOS', 'DUS', 3550).
airports_distance('BOS', 'LIS', 3182).
airports_distance('BOS', 'NAS', 1251).
airports_distance('BOS', 'KEF', 2406).
airports_distance('BOS', 'BGI', 2136).
airports_distance('BOS', 'STT', 1696).
airports_distance('BOS', 'BDA', 772).
airports_distance('BOS', 'MBJ', 1697).
airports_distance('BOS', 'AUA', 2063).
airports_distance('BOS', 'ORF', 468).
airports_distance('BOS', 'JAX', 1010).
airports_distance('BOS', 'PUJ', 1650).
airports_distance('BOS', 'MDT', 334).
airports_distance('BOS', 'BUF', 394).
airports_distance('BOS', 'CMH', 638).
airports_distance('BOS', 'ALB', 145).
airports_distance('BOS', 'SXM', 1742).
airports_distance('BOS', 'RIC', 473).
airports_distance('BOS', 'ISP', 153).
airports_distance('BOS', 'HAV', 1490).
airports_distance('BOS', 'BOG', 2608).
airports_distance('BOS', 'MYR', 738).
airports_distance('BOS', 'CHS', 818).
airports_distance('BOS', 'PLS', 1424).
airports_distance('BOS', 'PTY', 2354).
airports_distance('BOS', 'SAL', 2270).
airports_distance('BOS', 'SAV', 901).
airports_distance('BOS', 'CAK', 547).
airports_distance('BOS', 'SYR', 264).
airports_distance('BOS', 'SRQ', 1221).
airports_distance('BOS', 'PDL', 2387).
airports_distance('BOS', 'SDQ', 1654).
airports_distance('BOS', 'STI', 1585).
airports_distance('BOS', 'PAP', 1644).
airports_distance('BOS', 'FDF', 2008).
airports_distance('BOS', 'PTP', 1887).
airports_distance('BOS', 'BUR', 2593).
airports_distance('BOS', 'ACY', 274).
airports_distance('BOS', 'RAI', 3385).
airports_distance('BOS', 'PBG', 200).
airports_distance('BOS', 'YTZ', 432).
airports_distance('BOS', 'ACK', 91).
airports_distance('BOS', 'AUG', 148).
airports_distance('BOS', 'BHB', 196).
airports_distance('BOS', 'HYA', 61).
airports_distance('BOS', 'LEB', 109).
airports_distance('BOS', 'MVY', 70).
airports_distance('BOS', 'PQI', 332).
airports_distance('BOS', 'PVC', 45).
airports_distance('BOS', 'RKD', 151).
airports_distance('BOS', 'RUT', 127).
airports_distance('BOS', 'SLK', 213).
airports_distance('BOS', 'TER', 2291).
airports_distance('BOS', 'MSS', 261).
airports_distance('BWI', 'YYZ', 347).
airports_distance('BWI', 'LHR', 3622).
airports_distance('BWI', 'RSW', 921).
airports_distance('BWI', 'YUL', 460).
airports_distance('BWI', 'PIT', 210).
airports_distance('BWI', 'PWM', 451).
airports_distance('BWI', 'PDX', 2351).
airports_distance('BWI', 'OKC', 1176).
airports_distance('BWI', 'ROC', 277).
airports_distance('BWI', 'CLT', 361).
airports_distance('BWI', 'CUN', 1391).
airports_distance('BWI', 'MEM', 785).
airports_distance('BWI', 'CVG', 429).
airports_distance('BWI', 'IND', 514).
airports_distance('BWI', 'MCI', 963).
airports_distance('BWI', 'DAL', 1206).
airports_distance('BWI', 'STL', 735).
airports_distance('BWI', 'ABQ', 1665).
airports_distance('BWI', 'MKE', 639).
airports_distance('BWI', 'MDW', 609).
airports_distance('BWI', 'TUL', 1068).
airports_distance('BWI', 'NAS', 977).
airports_distance('BWI', 'FPO', 879).
airports_distance('BWI', 'KEF', 2754).
airports_distance('BWI', 'MBJ', 1429).
airports_distance('BWI', 'LIT', 910).
airports_distance('BWI', 'AUA', 1886).
airports_distance('BWI', 'ORF', 160).
airports_distance('BWI', 'JAX', 663).
airports_distance('BWI', 'PVD', 327).
airports_distance('BWI', 'PUJ', 1507).
airports_distance('BWI', 'SJO', 2068).
airports_distance('BWI', 'SMF', 2388).
airports_distance('BWI', 'BHM', 681).
airports_distance('BWI', 'SDF', 493).
airports_distance('BWI', 'BUF', 281).
airports_distance('BWI', 'ECP', 799).
airports_distance('BWI', 'CMH', 336).
airports_distance('BWI', 'ALB', 288).
airports_distance('BWI', 'BDL', 283).
airports_distance('BWI', 'LEX', 435).
airports_distance('BWI', 'ISP', 219).
airports_distance('BWI', 'MYR', 400).
airports_distance('BWI', 'CHS', 472).
airports_distance('BWI', 'DAY', 405).
airports_distance('BWI', 'GRR', 527).
airports_distance('BWI', 'GSP', 425).
airports_distance('BWI', 'SAV', 549).
airports_distance('BWI', 'TYS', 463).
airports_distance('BWI', 'VPS', 819).
airports_distance('BWI', 'MHT', 376).
airports_distance('BWI', 'AVL', 413).
airports_distance('BWI', 'SRQ', 881).
airports_distance('BWI', 'FDF', 1946).
airports_distance('BWI', 'PTP', 1826).
airports_distance('BWI', 'FNT', 452).
airports_distance('BWI', 'JST', 139).
airports_distance('BWI', 'MGW', 176).
airports_distance('DCA', 'YYZ', 359).
airports_distance('DCA', 'YOW', 452).
airports_distance('DCA', 'RSW', 893).
airports_distance('DCA', 'YUL', 487).
airports_distance('DCA', 'TLH', 716).
airports_distance('DCA', 'PIT', 204).
airports_distance('DCA', 'PDX', 2343).
airports_distance('DCA', 'OKC', 1154).
airports_distance('DCA', 'ROC', 296).
airports_distance('DCA', 'YHZ', 809).
airports_distance('DCA', 'CLT', 331).
airports_distance('DCA', 'MEM', 760).
airports_distance('DCA', 'CVG', 410).
airports_distance('DCA', 'IND', 498).
airports_distance('DCA', 'MCI', 946).
airports_distance('DCA', 'DAL', 1181).
airports_distance('DCA', 'STL', 717).
airports_distance('DCA', 'MKE', 633).
airports_distance('DCA', 'MDW', 599).
airports_distance('DCA', 'OMA', 1008).
airports_distance('DCA', 'NAS', 954).
airports_distance('DCA', 'LIT', 885).
airports_distance('DCA', 'ORF', 143).
airports_distance('DCA', 'JAX', 634).
airports_distance('DCA', 'PVD', 356).
airports_distance('DCA', 'HSV', 612).
airports_distance('DCA', 'BHM', 652).
airports_distance('DCA', 'SDF', 472).
airports_distance('DCA', 'BUF', 296).
airports_distance('DCA', 'CMH', 322).
airports_distance('DCA', 'ALB', 318).
airports_distance('DCA', 'BDL', 313).
airports_distance('DCA', 'LEX', 413).
airports_distance('DCA', 'ISP', 248).
airports_distance('DCA', 'DSM', 895).
airports_distance('DCA', 'MYR', 372).
airports_distance('DCA', 'CAE', 408).
airports_distance('DCA', 'CHA', 522).
airports_distance('DCA', 'CHS', 444).
airports_distance('DCA', 'DAY', 390).
airports_distance('DCA', 'GRR', 523).
airports_distance('DCA', 'GSO', 248).
airports_distance('DCA', 'GSP', 395).
airports_distance('DCA', 'JAN', 859).
airports_distance('DCA', 'MGM', 693).
airports_distance('DCA', 'MSN', 705).
airports_distance('DCA', 'PNS', 816).
airports_distance('DCA', 'SAV', 520).
airports_distance('DCA', 'TYS', 436).
airports_distance('DCA', 'VPS', 789).
airports_distance('DCA', 'XNA', 960).
airports_distance('DCA', 'CAK', 273).
airports_distance('DCA', 'MHT', 406).
airports_distance('DCA', 'SYR', 298).
airports_distance('DCA', 'SRQ', 852).
airports_distance('DCA', 'LAN', 478).
airports_distance('DCA', 'AGS', 468).
airports_distance('DCA', 'BGR', 589).
airports_distance('DCA', 'BTV', 437).
airports_distance('DCA', 'FAY', 285).
airports_distance('DCA', 'HHH', 502).
airports_distance('DCA', 'ILM', 320).
airports_distance('DCA', 'OAJ', 280).
airports_distance('DCA', 'MLB', 771).
airports_distance('DCA', 'ACK', 404).
airports_distance('DCA', 'MVY', 382).
airports_distance('DFW', 'YYZ', 1197).
airports_distance('DFW', 'YVR', 1751).
airports_distance('DFW', 'LHR', 4736).
airports_distance('DFW', 'CDG', 4933).
airports_distance('DFW', 'FRA', 5127).
airports_distance('DFW', 'NRT', 6410).
airports_distance('DFW', 'SYD', 8574).
airports_distance('DFW', 'DXB', 8022).
airports_distance('DFW', 'DUB', 4458).
airports_distance('DFW', 'HKG', 8105).
airports_distance('DFW', 'PEK', 6951).
airports_distance('DFW', 'PVG', 7332).
airports_distance('DFW', 'FCO', 5597).
airports_distance('DFW', 'AMS', 4905).
airports_distance('DFW', 'MAD', 4950).
airports_distance('DFW', 'MUC', 5313).
airports_distance('DFW', 'RSW', 1015).
airports_distance('DFW', 'YUL', 1510).
airports_distance('DFW', 'YEG', 1629).
airports_distance('DFW', 'YYC', 1522).
airports_distance('DFW', 'DOH', 7914).
airports_distance('DFW', 'ICN', 6822).
airports_distance('DFW', 'GIG', 5228).
airports_distance('DFW', 'GRU', 5119).
airports_distance('DFW', 'EZE', 5299).
airports_distance('DFW', 'LIM', 3368).
airports_distance('DFW', 'SCL', 4884).
airports_distance('DFW', 'MEX', 938).
airports_distance('DFW', 'TLH', 765).
airports_distance('DFW', 'PIT', 1065).
airports_distance('DFW', 'PDX', 1613).
airports_distance('DFW', 'OKC', 175).
airports_distance('DFW', 'ONT', 1185).
airports_distance('DFW', 'AUH', 8053).
airports_distance('DFW', 'CLT', 933).
airports_distance('DFW', 'CUN', 1029).
airports_distance('DFW', 'PSP', 1123).
airports_distance('DFW', 'MEM', 430).
airports_distance('DFW', 'CVG', 810).
airports_distance('DFW', 'IND', 760).
airports_distance('DFW', 'MCI', 461).
airports_distance('DFW', 'STL', 550).
airports_distance('DFW', 'ABQ', 567).
airports_distance('DFW', 'MKE', 853).
airports_distance('DFW', 'OMA', 584).
airports_distance('DFW', 'TUL', 237).
airports_distance('DFW', 'PVR', 983).
airports_distance('DFW', 'OGG', 3702).
airports_distance('DFW', 'DUS', 5015).
airports_distance('DFW', 'NAS', 1298).
airports_distance('DFW', 'EYW', 1088).
airports_distance('DFW', 'KEF', 3733).
airports_distance('DFW', 'MBJ', 1545).
airports_distance('DFW', 'LIT', 304).
airports_distance('DFW', 'AUA', 2211).
airports_distance('DFW', 'ORF', 1209).
airports_distance('DFW', 'JAX', 916).
airports_distance('DFW', 'PUJ', 2029).
airports_distance('DFW', 'SJO', 1780).
airports_distance('DFW', 'SMF', 1427).
airports_distance('DFW', 'RTB', 1319).
airports_distance('DFW', 'TGU', 1440).
airports_distance('DFW', 'COS', 591).
airports_distance('DFW', 'HSV', 601).
airports_distance('DFW', 'BHM', 596).
airports_distance('DFW', 'RAP', 835).
airports_distance('DFW', 'SDF', 731).
airports_distance('DFW', 'BUF', 1210).
airports_distance('DFW', 'SHV', 189).
airports_distance('DFW', 'BOI', 1270).
airports_distance('DFW', 'LBB', 281).
airports_distance('DFW', 'ECP', 684).
airports_distance('DFW', 'HRL', 462).
airports_distance('DFW', 'RNO', 1342).
airports_distance('DFW', 'CMH', 924).
airports_distance('DFW', 'ICT', 329).
airports_distance('DFW', 'MAF', 308).
airports_distance('DFW', 'BDL', 1467).
airports_distance('DFW', 'BIL', 1080).
airports_distance('DFW', 'SGF', 364).
airports_distance('DFW', 'RIC', 1155).
airports_distance('DFW', 'CCS', 2450).
airports_distance('DFW', 'TXK', 180).
airports_distance('DFW', 'PIA', 672).
airports_distance('DFW', 'LEX', 783).
airports_distance('DFW', 'GUA', 1329).
airports_distance('DFW', 'CRP', 355).
airports_distance('DFW', 'ABI', 157).
airports_distance('DFW', 'ACT', 89).
airports_distance('DFW', 'CLL', 164).
airports_distance('DFW', 'BMI', 689).
airports_distance('DFW', 'BOG', 2442).
airports_distance('DFW', 'BPT', 270).
airports_distance('DFW', 'DSM', 624).
airports_distance('DFW', 'MYR', 1045).
airports_distance('DFW', 'AEX', 284).
airports_distance('DFW', 'CZM', 1056).
airports_distance('DFW', 'AGU', 837).
airports_distance('DFW', 'MTY', 525).
airports_distance('DFW', 'AMA', 311).
airports_distance('DFW', 'BJX', 866).
airports_distance('DFW', 'BRO', 483).
airports_distance('DFW', 'BTR', 382).
airports_distance('DFW', 'BZE', 1191).
airports_distance('DFW', 'CAE', 919).
airports_distance('DFW', 'CHA', 693).
airports_distance('DFW', 'CHS', 984).
airports_distance('DFW', 'CMI', 692).
airports_distance('DFW', 'COU', 490).
airports_distance('DFW', 'DAY', 860).
airports_distance('DFW', 'CUU', 603).
airports_distance('DFW', 'DRO', 673).
airports_distance('DFW', 'EVV', 641).
airports_distance('DFW', 'FAR', 968).
airports_distance('DFW', 'FAT', 1310).
airports_distance('DFW', 'FSD', 738).
airports_distance('DFW', 'FSM', 227).
airports_distance('DFW', 'FWA', 858).
airports_distance('DFW', 'GCK', 404).
airports_distance('DFW', 'GDL', 937).
airports_distance('DFW', 'GGG', 140).
airports_distance('DFW', 'GJT', 771).
airports_distance('DFW', 'GPT', 499).
airports_distance('DFW', 'GRI', 562).
airports_distance('DFW', 'GRK', 135).
airports_distance('DFW', 'GRR', 930).
airports_distance('DFW', 'GSO', 996).
airports_distance('DFW', 'GSP', 860).
airports_distance('DFW', 'JAN', 407).
airports_distance('DFW', 'JLN', 327).
airports_distance('DFW', 'LAW', 140).
airports_distance('DFW', 'LCH', 295).
airports_distance('DFW', 'LFT', 350).
airports_distance('DFW', 'LIR', 1704).
airports_distance('DFW', 'LRD', 397).
airports_distance('DFW', 'MFE', 470).
airports_distance('DFW', 'MGM', 620).
airports_distance('DFW', 'MHK', 432).
airports_distance('DFW', 'MLI', 691).
airports_distance('DFW', 'MLM', 934).
airports_distance('DFW', 'MLU', 292).
airports_distance('DFW', 'MOB', 538).
airports_distance('DFW', 'MSN', 821).
airports_distance('DFW', 'MZT', 876).
airports_distance('DFW', 'PBC', 952).
airports_distance('DFW', 'PLS', 1696).
airports_distance('DFW', 'PNS', 602).
airports_distance('DFW', 'PTY', 1993).
airports_distance('DFW', 'QRO', 870).
airports_distance('DFW', 'ROW', 434).
airports_distance('DFW', 'SAL', 1434).
airports_distance('DFW', 'SAV', 923).
airports_distance('DFW', 'SJD', 1023).
airports_distance('DFW', 'SJT', 228).
airports_distance('DFW', 'SLP', 772).
airports_distance('DFW', 'SPI', 630).
airports_distance('DFW', 'SPS', 113).
airports_distance('DFW', 'TRC', 635).
airports_distance('DFW', 'TYR', 102).
airports_distance('DFW', 'TYS', 770).
airports_distance('DFW', 'VPS', 639).
airports_distance('DFW', 'XNA', 281).
airports_distance('DFW', 'ZCL', 771).
airports_distance('DFW', 'AVL', 846).
airports_distance('DFW', 'EGE', 720).
airports_distance('DFW', 'HDN', 768).
airports_distance('DFW', 'SRQ', 943).
airports_distance('DFW', 'AGS', 871).
airports_distance('DFW', 'ILM', 1103).
airports_distance('DFW', 'UIO', 2584).
airports_distance('DFW', 'GNV', 898).
airports_distance('DFW', 'SDQ', 1965).
airports_distance('DFW', 'SAP', 1333).
airports_distance('DFW', 'MID', 942).
airports_distance('DFW', 'MGA', 1589).
airports_distance('DFW', 'GCM', 1349).
airports_distance('DFW', 'SKB', 2385).
airports_distance('DFW', 'BUR', 1228).
airports_distance('DFW', 'MEI', 483).
airports_distance('DFW', 'PIB', 461).
airports_distance('DFW', 'SBN', 845).
airports_distance('DFW', 'KOA', 3716).
airports_distance('DFW', 'SUX', 657).
airports_distance('DFW', 'BFL', 1267).
airports_distance('DFW', 'MRY', 1426).
airports_distance('DFW', 'SBA', 1312).
airports_distance('DFW', 'ASE', 701).
airports_distance('DFW', 'GEG', 1475).
airports_distance('DFW', 'YUM', 1019).
airports_distance('DFW', 'DGO', 757).
airports_distance('DFW', 'BZN', 1162).
airports_distance('DFW', 'JAC', 1045).
airports_distance('DFW', 'MSO', 1318).
airports_distance('DFW', 'BKG', 332).
airports_distance('DFW', 'BIS', 978).
airports_distance('DFW', 'CYS', 713).
airports_distance('DFW', 'GUC', 677).
airports_distance('DFW', 'MTJ', 721).
airports_distance('DFW', 'TVC', 1022).
airports_distance('DFW', 'AUG', 1657).
airports_distance('DFW', 'ACA', 1127).
airports_distance('DFW', 'OAX', 1098).
airports_distance('DFW', 'FLG', 851).
airports_distance('DFW', 'CNM', 422).
airports_distance('DFW', 'GLH', 352).
airports_distance('DFW', 'SWO', 225).
airports_distance('DFW', 'CVN', 363).
airports_distance('DFW', 'DRT', 335).
airports_distance('FLL', 'YYZ', 1216).
airports_distance('FLL', 'LGW', 4410).
airports_distance('FLL', 'CDG', 4558).
airports_distance('FLL', 'DXB', 7808).
airports_distance('FLL', 'BCN', 4667).
airports_distance('FLL', 'MAD', 4395).
airports_distance('FLL', 'YOW', 1352).
airports_distance('FLL', 'YUL', 1386).
airports_distance('FLL', 'OSL', 4708).
airports_distance('FLL', 'ARN', 4944).
airports_distance('FLL', 'YYC', 2477).
airports_distance('FLL', 'YYT', 2101).
airports_distance('FLL', 'LIM', 2638).
airports_distance('FLL', 'MEX', 1287).
airports_distance('FLL', 'KIN', 602).
airports_distance('FLL', 'TLH', 393).
airports_distance('FLL', 'PIT', 996).
airports_distance('FLL', 'ROC', 1185).
airports_distance('FLL', 'YHZ', 1594).
airports_distance('FLL', 'YWG', 1880).
airports_distance('FLL', 'CPH', 4851).
airports_distance('FLL', 'CLT', 633).
airports_distance('FLL', 'CUN', 549).
airports_distance('FLL', 'MEM', 850).
airports_distance('FLL', 'CVG', 933).
airports_distance('FLL', 'IND', 1006).
airports_distance('FLL', 'MCI', 1242).
airports_distance('FLL', 'DAL', 1106).
airports_distance('FLL', 'STL', 1057).
airports_distance('FLL', 'MKE', 1244).
airports_distance('FLL', 'MDW', 1168).
airports_distance('FLL', 'NAS', 182).
airports_distance('FLL', 'FPO', 96).
airports_distance('FLL', 'GGT', 319).
airports_distance('FLL', 'EYW', 145).
airports_distance('FLL', 'BGI', 1612).
airports_distance('FLL', 'STT', 1106).
airports_distance('FLL', 'POS', 1628).
airports_distance('FLL', 'MBJ', 542).
airports_distance('FLL', 'AUA', 1145).
airports_distance('FLL', 'ORF', 782).
airports_distance('FLL', 'JAX', 319).
airports_distance('FLL', 'PVD', 1190).
airports_distance('FLL', 'PUJ', 913).
airports_distance('FLL', 'SJO', 1141).
airports_distance('FLL', 'SDF', 897).
airports_distance('FLL', 'BUF', 1167).
airports_distance('FLL', 'CMH', 974).
airports_distance('FLL', 'ALB', 1206).
airports_distance('FLL', 'BDL', 1175).
airports_distance('FLL', 'SXM', 1222).
airports_distance('FLL', 'RIC', 807).
airports_distance('FLL', 'GYE', 1949).
airports_distance('FLL', 'LEX', 866).
airports_distance('FLL', 'GUA', 1038).
airports_distance('FLL', 'ISP', 1094).
airports_distance('FLL', 'IAG', 1178).
airports_distance('FLL', 'SWF', 1120).
airports_distance('FLL', 'BIM', 61).
airports_distance('FLL', 'HAV', 256).
airports_distance('FLL', 'BOG', 1528).
airports_distance('FLL', 'MYR', 530).
airports_distance('FLL', 'BZE', 787).
airports_distance('FLL', 'CHS', 471).
airports_distance('FLL', 'GDL', 1515).
airports_distance('FLL', 'GRR', 1199).
airports_distance('FLL', 'GSO', 692).
airports_distance('FLL', 'GSP', 621).
airports_distance('FLL', 'PLS', 579).
airports_distance('FLL', 'PNS', 524).
airports_distance('FLL', 'PTY', 1175).
airports_distance('FLL', 'SAL', 1046).
airports_distance('FLL', 'TYS', 710).
airports_distance('FLL', 'VPS', 493).
airports_distance('FLL', 'CAK', 1028).
airports_distance('FLL', 'SYR', 1198).
airports_distance('FLL', 'AVL', 662).
airports_distance('FLL', 'HOG', 439).
airports_distance('FLL', 'VRA', 225).
airports_distance('FLL', 'UIO', 1813).
airports_distance('FLL', 'BQN', 982).
airports_distance('FLL', 'SDQ', 852).
airports_distance('FLL', 'STI', 762).
airports_distance('FLL', 'SAP', 888).
airports_distance('FLL', 'MGA', 1038).
airports_distance('FLL', 'PAP', 720).
airports_distance('FLL', 'GCM', 474).
airports_distance('FLL', 'MHH', 192).
airports_distance('FLL', 'ELH', 220).
airports_distance('FLL', 'BEL', 2837).
airports_distance('FLL', 'REC', 3843).
airports_distance('FLL', 'CTG', 1121).
airports_distance('FLL', 'CLO', 1575).
airports_distance('FLL', 'MDE', 1409).
airports_distance('FLL', 'PTP', 1374).
airports_distance('FLL', 'STX', 1139).
airports_distance('FLL', 'ACY', 979).
airports_distance('FLL', 'ABE', 1042).
airports_distance('FLL', 'DAB', 222).
airports_distance('FLL', 'FNT', 1184).
airports_distance('FLL', 'TTN', 1028).
airports_distance('FLL', 'CCC', 275).
airports_distance('FLL', 'TLC', 1319).
airports_distance('FLL', 'LBE', 982).
airports_distance('FLL', 'ORH', 1213).
airports_distance('FLL', 'PBG', 1336).
airports_distance('FLL', 'TCB', 177).
airports_distance('FLL', 'GHB', 244).
airports_distance('FLL', 'ZSA', 378).
airports_distance('FLL', 'AXM', 1521).
airports_distance('FLL', 'CMW', 353).
airports_distance('FLL', 'SNU', 248).
airports_distance('FLL', 'SCU', 503).
airports_distance('FLL', 'YHM', 1181).
airports_distance('FLL', 'VCP', 4044).
airports_distance('FLL', 'BLV', 1029).
airports_distance('FLL', 'LCK', 962).
airports_distance('FLL', 'OGS', 1311).
airports_distance('FLL', 'PSM', 1286).
airports_distance('FLL', 'CAP', 669).
airports_distance('FLL', 'CFG', 271).
airports_distance('FLL', 'USA', 644).
airports_distance('FLL', 'MZO', 444).
airports_distance('IAD', 'YYZ', 346).
airports_distance('IAD', 'LHR', 3665).
airports_distance('IAD', 'CDG', 3848).
airports_distance('IAD', 'FRA', 4067).
airports_distance('IAD', 'NRT', 6734).
airports_distance('IAD', 'DXB', 7051).
airports_distance('IAD', 'DEL', 7487).
airports_distance('IAD', 'DUB', 3393).
airports_distance('IAD', 'HKG', 8135).
airports_distance('IAD', 'PEK', 6900).
airports_distance('IAD', 'FCO', 4491).
airports_distance('IAD', 'AMS', 3854).
airports_distance('IAD', 'BCN', 4046).
airports_distance('IAD', 'MAD', 3804).
airports_distance('IAD', 'VIE', 4449).
airports_distance('IAD', 'ZRH', 4144).
airports_distance('IAD', 'GVA', 4077).
airports_distance('IAD', 'YOW', 450).
airports_distance('IAD', 'BRU', 3879).
airports_distance('IAD', 'MUC', 4249).
airports_distance('IAD', 'MAN', 3553).
airports_distance('IAD', 'YUL', 489).
airports_distance('IAD', 'STN', 3684).
airports_distance('IAD', 'EDI', 3465).
airports_distance('IAD', 'SVO', 4851).
airports_distance('IAD', 'DOH', 6909).
airports_distance('IAD', 'ICN', 6938).
airports_distance('IAD', 'GRU', 4750).
airports_distance('IAD', 'LIM', 3519).
airports_distance('IAD', 'MEX', 1864).
airports_distance('IAD', 'ADD', 7180).
airports_distance('IAD', 'TLV', 5887).
airports_distance('IAD', 'PIT', 182).
airports_distance('IAD', 'PWM', 492).
airports_distance('IAD', 'PDX', 2320).
airports_distance('IAD', 'OKC', 1133).
airports_distance('IAD', 'ROC', 288).
airports_distance('IAD', 'KWI', 6557).
airports_distance('IAD', 'IST', 5208).
airports_distance('IAD', 'AUH', 7070).
airports_distance('IAD', 'CPH', 4060).
airports_distance('IAD', 'CLT', 321).
airports_distance('IAD', 'CUN', 1357).
airports_distance('IAD', 'CVG', 387).
airports_distance('IAD', 'IND', 475).
airports_distance('IAD', 'MCI', 923).
airports_distance('IAD', 'STL', 694).
airports_distance('IAD', 'MDW', 576).
airports_distance('IAD', 'OMA', 985).
airports_distance('IAD', 'TUL', 1025).
airports_distance('IAD', 'LIS', 3580).
airports_distance('IAD', 'NAS', 960).
airports_distance('IAD', 'JED', 6577).
airports_distance('IAD', 'KEF', 2791).
airports_distance('IAD', 'STT', 1608).
airports_distance('IAD', 'MBJ', 1412).
airports_distance('IAD', 'AUA', 1882).
airports_distance('IAD', 'ORF', 157).
airports_distance('IAD', 'JAX', 631).
airports_distance('IAD', 'PVD', 371).
airports_distance('IAD', 'PUJ', 1509).
airports_distance('IAD', 'MDT', 94).
airports_distance('IAD', 'SJO', 2042).
airports_distance('IAD', 'SMF', 2350).
airports_distance('IAD', 'RUH', 6732).
airports_distance('IAD', 'COS', 1459).
airports_distance('IAD', 'HSV', 594).
airports_distance('IAD', 'SDF', 450).
airports_distance('IAD', 'BUF', 284).
airports_distance('IAD', 'CMH', 299).
airports_distance('IAD', 'ALB', 325).
airports_distance('IAD', 'BDL', 325).
airports_distance('IAD', 'SXM', 1681).
airports_distance('IAD', 'RIC', 100).
airports_distance('IAD', 'LEX', 391).
airports_distance('IAD', 'GUA', 1860).
airports_distance('IAD', 'ACC', 5289).
airports_distance('IAD', 'CMN', 3818).
airports_distance('IAD', 'BOG', 2373).
airports_distance('IAD', 'CAE', 401).
airports_distance('IAD', 'CHA', 505).
airports_distance('IAD', 'CHS', 442).
airports_distance('IAD', 'DAY', 367).
airports_distance('IAD', 'GRR', 501).
airports_distance('IAD', 'GSO', 239).
airports_distance('IAD', 'GSP', 384).
airports_distance('IAD', 'PTY', 2066).
airports_distance('IAD', 'SAL', 1898).
airports_distance('IAD', 'SAV', 515).
airports_distance('IAD', 'SJD', 2181).
airports_distance('IAD', 'TYS', 419).
airports_distance('IAD', 'MHT', 417).
airports_distance('IAD', 'SYR', 296).
airports_distance('IAD', 'AVL', 370).
airports_distance('IAD', 'EGE', 1568).
airports_distance('IAD', 'HDN', 1577).
airports_distance('IAD', 'ROA', 177).
airports_distance('IAD', 'SID', 3601).
airports_distance('IAD', 'BTV', 441).
airports_distance('IAD', 'FAY', 284).
airports_distance('IAD', 'HHH', 498).
airports_distance('IAD', 'ILM', 324).
airports_distance('IAD', 'GCM', 1377).
airports_distance('IAD', 'DKR', 3974).
airports_distance('IAD', 'AVP', 189).
airports_distance('IAD', 'CHO', 77).
airports_distance('IAD', 'LWB', 176).
airports_distance('IAD', 'ELM', 224).
airports_distance('IAD', 'TVC', 578).
airports_distance('IAD', 'SCE', 133).
airports_distance('IAD', 'PBG', 444).
airports_distance('IAD', 'YTZ', 339).
airports_distance('IAD', 'AOO', 104).
airports_distance('IAD', 'BGM', 238).
airports_distance('IAD', 'BKW', 214).
airports_distance('IAD', 'HGR', 55).
airports_distance('IAD', 'JST', 120).
airports_distance('IAD', 'LNS', 102).
airports_distance('IAD', 'MGW', 140).
airports_distance('IAD', 'SHD', 91).
airports_distance('IAD', 'ITH', 250).
airports_distance('IAD', 'CKB', 150).
airports_distance('IAD', 'DSS', 3999).
airports_distance('IAH', 'YYZ', 1279).
airports_distance('IAH', 'YVR', 1968).
airports_distance('IAH', 'LHR', 4820).
airports_distance('IAH', 'CDG', 5012).
airports_distance('IAH', 'FRA', 5217).
airports_distance('IAH', 'NRT', 6625).
airports_distance('IAH', 'SYD', 8591).
airports_distance('IAH', 'DXB', 8150).
airports_distance('IAH', 'AKL', 7416).
airports_distance('IAH', 'PEK', 7176).
airports_distance('IAH', 'AMS', 4998).
airports_distance('IAH', 'MUC', 5402).
airports_distance('IAH', 'RSW', 859).
airports_distance('IAH', 'MAN', 4701).
airports_distance('IAH', 'YUL', 1583).
airports_distance('IAH', 'YEG', 1853).
airports_distance('IAH', 'YYC', 1746).
airports_distance('IAH', 'DME', 5919).
airports_distance('IAH', 'DOH', 8030).
airports_distance('IAH', 'ICN', 7045).
airports_distance('IAH', 'GIG', 5022).
airports_distance('IAH', 'GRU', 4909).
airports_distance('IAH', 'EZE', 5075).
airports_distance('IAH', 'LIM', 3143).
airports_distance('IAH', 'SCL', 4660).
airports_distance('IAH', 'MEX', 765).
airports_distance('IAH', 'PIT', 1116).
airports_distance('IAH', 'PDX', 1822).
airports_distance('IAH', 'OKC', 396).
airports_distance('IAH', 'ONT', 1330).
airports_distance('IAH', 'IST', 6353).
airports_distance('IAH', 'CLT', 911).
airports_distance('IAH', 'CUN', 812).
airports_distance('IAH', 'PSP', 1266).
airports_distance('IAH', 'MEM', 468).
airports_distance('IAH', 'CVG', 871).
airports_distance('IAH', 'IND', 844).
airports_distance('IAH', 'MCI', 644).
airports_distance('IAH', 'DAL', 217).
airports_distance('IAH', 'STL', 668).
airports_distance('IAH', 'ABQ', 742).
airports_distance('IAH', 'MKE', 985).
airports_distance('IAH', 'OMA', 782).
airports_distance('IAH', 'TUL', 430).
airports_distance('IAH', 'PVR', 891).
airports_distance('IAH', 'TPE', 7921).
airports_distance('IAH', 'NAS', 1145).
airports_distance('IAH', 'STT', 2067).
airports_distance('IAH', 'POS', 2561).
airports_distance('IAH', 'LOS', 6501).
airports_distance('IAH', 'MBJ', 1351).
airports_distance('IAH', 'LIT', 375).
airports_distance('IAH', 'BON', 2126).
airports_distance('IAH', 'AUA', 2019).
airports_distance('IAH', 'ORF', 1199).
airports_distance('IAH', 'JAX', 815).
airports_distance('IAH', 'PUJ', 1865).
airports_distance('IAH', 'SJO', 1555).
airports_distance('IAH', 'SMF', 1606).
airports_distance('IAH', 'RTB', 1096).
airports_distance('IAH', 'TGU', 1215).
airports_distance('IAH', 'COS', 809).
airports_distance('IAH', 'HSV', 594).
airports_distance('IAH', 'BHM', 561).
airports_distance('IAH', 'SDF', 787).
airports_distance('IAH', 'SHV', 192).
airports_distance('IAH', 'BOI', 1480).
airports_distance('IAH', 'LBB', 457).
airports_distance('IAH', 'ECP', 570).
airports_distance('IAH', 'HRL', 295).
airports_distance('IAH', 'RNO', 1527).
airports_distance('IAH', 'CMH', 985).
airports_distance('IAH', 'ICT', 543).
airports_distance('IAH', 'MAF', 428).
airports_distance('IAH', 'BDL', 1504).
airports_distance('IAH', 'SGF', 514).
airports_distance('IAH', 'RIC', 1155).
airports_distance('IAH', 'CCS', 2260).
airports_distance('IAH', 'LEX', 828).
airports_distance('IAH', 'GUA', 1107).
airports_distance('IAH', 'HAV', 933).
airports_distance('IAH', 'CRP', 201).
airports_distance('IAH', 'CLL', 74).
airports_distance('IAH', 'BOG', 2226).
airports_distance('IAH', 'DSM', 803).
airports_distance('IAH', 'MYR', 995).
airports_distance('IAH', 'AEX', 190).
airports_distance('IAH', 'CZM', 838).
airports_distance('IAH', 'AGU', 717).
airports_distance('IAH', 'MTY', 411).
airports_distance('IAH', 'AMA', 517).
airports_distance('IAH', 'BJX', 729).
airports_distance('IAH', 'BRO', 309).
airports_distance('IAH', 'BTR', 253).
airports_distance('IAH', 'BZE', 967).
airports_distance('IAH', 'CAE', 876).
airports_distance('IAH', 'CHS', 923).
airports_distance('IAH', 'CRW', 974).
airports_distance('IAH', 'DAY', 929).
airports_distance('IAH', 'CUU', 645).
airports_distance('IAH', 'GDL', 821).
airports_distance('IAH', 'GJT', 978).
airports_distance('IAH', 'GPT', 375).
airports_distance('IAH', 'GRK', 166).
airports_distance('IAH', 'GRR', 1042).
airports_distance('IAH', 'GSP', 836).
airports_distance('IAH', 'JAN', 350).
airports_distance('IAH', 'LCH', 127).
airports_distance('IAH', 'LFT', 201).
airports_distance('IAH', 'LIR', 1480).
airports_distance('IAH', 'LRD', 301).
airports_distance('IAH', 'MFE', 317).
airports_distance('IAH', 'MLM', 785).
airports_distance('IAH', 'MLU', 262).
airports_distance('IAH', 'MOB', 426).
airports_distance('IAH', 'MZT', 822).
airports_distance('IAH', 'PBC', 771).
airports_distance('IAH', 'PLS', 1538).
airports_distance('IAH', 'PNS', 488).
airports_distance('IAH', 'PTY', 1774).
airports_distance('IAH', 'QRO', 714).
airports_distance('IAH', 'SAL', 1211).
airports_distance('IAH', 'SAV', 849).
airports_distance('IAH', 'SJD', 1004).
airports_distance('IAH', 'SLP', 636).
airports_distance('IAH', 'TRC', 579).
airports_distance('IAH', 'TYR', 164).
airports_distance('IAH', 'TYS', 770).
airports_distance('IAH', 'VPS', 527).
airports_distance('IAH', 'XNA', 439).
airports_distance('IAH', 'CAK', 1084).
airports_distance('IAH', 'EGE', 934).
airports_distance('IAH', 'HDN', 985).
airports_distance('IAH', 'UIO', 2360).
airports_distance('IAH', 'GNV', 783).
airports_distance('IAH', 'SAP', 1108).
airports_distance('IAH', 'MID', 718).
airports_distance('IAH', 'MGA', 1365).
airports_distance('IAH', 'GCM', 1145).
airports_distance('IAH', 'ACY', 1343).
airports_distance('IAH', 'LFW', 6393).
airports_distance('IAH', 'BFL', 1424).
airports_distance('IAH', 'ASE', 913).
airports_distance('IAH', 'DGO', 694).
airports_distance('IAH', 'ZIH', 938).
airports_distance('IAH', 'ZLO', 945).
airports_distance('IAH', 'BZN', 1384).
airports_distance('IAH', 'JAC', 1264).
airports_distance('IAH', 'GUC', 885).
airports_distance('IAH', 'MTJ', 926).
airports_distance('IAH', 'HOB', 500).
airports_distance('IAH', 'VCT', 123).
airports_distance('IAH', 'ACA', 955).
airports_distance('IAH', 'HUX', 983).
airports_distance('IAH', 'CME', 813).
airports_distance('IAH', 'SLW', 458).
airports_distance('IAH', 'OAX', 901).
airports_distance('IAH', 'TAM', 553).
airports_distance('IAH', 'VSA', 843).
airports_distance('IAH', 'VER', 750).
airports_distance('JFK', 'YYZ', 365).
airports_distance('JFK', 'YVR', 2441).
airports_distance('JFK', 'LHR', 3440).
airports_distance('JFK', 'LGW', 3458).
airports_distance('JFK', 'CDG', 3622).
airports_distance('JFK', 'FRA', 3842).
airports_distance('JFK', 'HEL', 4103).
airports_distance('JFK', 'NRT', 6725).
airports_distance('JFK', 'DXB', 6831).
airports_distance('JFK', 'DEL', 7299).
airports_distance('JFK', 'DUB', 3169).
airports_distance('JFK', 'HKG', 8054).
airports_distance('JFK', 'PEK', 6817).
airports_distance('JFK', 'PVG', 7373).
airports_distance('JFK', 'FCO', 4264).
airports_distance('JFK', 'BOM', 7782).
airports_distance('JFK', 'AMS', 3631).
airports_distance('JFK', 'BCN', 3819).
airports_distance('JFK', 'MAD', 3577).
airports_distance('JFK', 'VIE', 4226).
airports_distance('JFK', 'ZRH', 3918).
airports_distance('JFK', 'GVA', 3851).
airports_distance('JFK', 'BRU', 3655).
airports_distance('JFK', 'MUC', 4024).
airports_distance('JFK', 'RSW', 1075).
airports_distance('JFK', 'MAN', 3330).
airports_distance('JFK', 'YUL', 334).
airports_distance('JFK', 'LCY', 3460).
airports_distance('JFK', 'VCE', 4141).
airports_distance('JFK', 'SNN', 3071).
airports_distance('JFK', 'OSL', 3674).
airports_distance('JFK', 'ARN', 3907).
airports_distance('JFK', 'EDI', 3244).
airports_distance('JFK', 'GLA', 3205).
airports_distance('JFK', 'YYC', 2035).
airports_distance('JFK', 'MNL', 8504).
airports_distance('JFK', 'SVO', 4645).
airports_distance('JFK', 'HND', 6753).
airports_distance('JFK', 'DOH', 6687).
airports_distance('JFK', 'ORY', 3622).
airports_distance('JFK', 'NCE', 3978).
airports_distance('JFK', 'MXP', 3982).
airports_distance('JFK', 'BUD', 4356).
airports_distance('JFK', 'ICN', 6885).
airports_distance('JFK', 'JNB', 7967).
airports_distance('JFK', 'NBO', 7350).
airports_distance('JFK', 'GIG', 4799).
airports_distance('JFK', 'GRU', 4759).
airports_distance('JFK', 'EZE', 5300).
airports_distance('JFK', 'LIM', 3642).
airports_distance('JFK', 'SCL', 5115).
airports_distance('JFK', 'MEX', 2090).
airports_distance('JFK', 'KIN', 1578).
airports_distance('JFK', 'WAW', 4252).
airports_distance('JFK', 'BEG', 4496).
airports_distance('JFK', 'CAI', 5599).
airports_distance('JFK', 'TLV', 5661).
airports_distance('JFK', 'PIT', 339).
airports_distance('JFK', 'PWM', 273).
airports_distance('JFK', 'PDX', 2446).
airports_distance('JFK', 'ONT', 2422).
airports_distance('JFK', 'ROC', 263).
airports_distance('JFK', 'KWI', 6335).
airports_distance('JFK', 'IST', 4984).
airports_distance('JFK', 'YHZ', 597).
airports_distance('JFK', 'AUH', 6850).
airports_distance('JFK', 'CPH', 3843).
airports_distance('JFK', 'CLT', 541).
airports_distance('JFK', 'CUN', 1556).
airports_distance('JFK', 'PSP', 2371).
airports_distance('JFK', 'CVG', 587).
airports_distance('JFK', 'IND', 663).
airports_distance('JFK', 'STL', 890).
airports_distance('JFK', 'ABQ', 1820).
airports_distance('JFK', 'DUS', 3736).
airports_distance('JFK', 'LIS', 3356).
airports_distance('JFK', 'TPE', 7789).
airports_distance('JFK', 'NAS', 1098).
airports_distance('JFK', 'KIX', 6926).
airports_distance('JFK', 'JED', 6349).
airports_distance('JFK', 'KEF', 2585).
airports_distance('JFK', 'BGI', 2090).
airports_distance('JFK', 'ANU', 1773).
airports_distance('JFK', 'STT', 1626).
airports_distance('JFK', 'BDA', 762).
airports_distance('JFK', 'TAB', 2183).
airports_distance('JFK', 'POS', 2209).
airports_distance('JFK', 'LOS', 5243).
airports_distance('JFK', 'MBJ', 1548).
airports_distance('JFK', 'CUR', 1986).
airports_distance('JFK', 'AUA', 1956).
airports_distance('JFK', 'ORF', 290).
airports_distance('JFK', 'JAX', 829).
airports_distance('JFK', 'PUJ', 1557).
airports_distance('JFK', 'SJO', 2210).
airports_distance('JFK', 'SMF', 2513).
airports_distance('JFK', 'RIX', 4189).
airports_distance('JFK', 'RUH', 6508).
airports_distance('JFK', 'CAN', 7984).
airports_distance('JFK', 'AGP', 3647).
airports_distance('JFK', 'YQB', 441).
airports_distance('JFK', 'SDF', 660).
airports_distance('JFK', 'BUF', 300).
airports_distance('JFK', 'RNO', 2403).
airports_distance('JFK', 'CMH', 482).
airports_distance('JFK', 'AMM', 5722).
airports_distance('JFK', 'BGO', 3480).
airports_distance('JFK', 'SXM', 1684).
airports_distance('JFK', 'RIC', 288).
airports_distance('JFK', 'CCS', 2115).
airports_distance('JFK', 'GYE', 2980).
airports_distance('JFK', 'GUA', 2062).
airports_distance('JFK', 'HAV', 1318).
airports_distance('JFK', 'VKO', 4658).
airports_distance('JFK', 'GYD', 5812).
airports_distance('JFK', 'ACC', 5105).
airports_distance('JFK', 'CMN', 3598).
airports_distance('JFK', 'CTU', 7509).
airports_distance('JFK', 'KBP', 4677).
airports_distance('JFK', 'BOG', 2481).
airports_distance('JFK', 'MTY', 1823).
airports_distance('JFK', 'CHS', 636).
airports_distance('JFK', 'GDL', 2220).
airports_distance('JFK', 'LIR', 2195).
airports_distance('JFK', 'PLS', 1306).
airports_distance('JFK', 'PTY', 2207).
airports_distance('JFK', 'SAL', 2092).
airports_distance('JFK', 'SAV', 717).
airports_distance('JFK', 'UVF', 2013).
airports_distance('JFK', 'SYR', 208).
airports_distance('JFK', 'SRQ', 1042).
airports_distance('JFK', 'BHX', 3367).
airports_distance('JFK', 'PDL', 2549).
airports_distance('JFK', 'BGR', 382).
airports_distance('JFK', 'BTV', 266).
airports_distance('JFK', 'POP', 1454).
airports_distance('JFK', 'UIO', 2830).
airports_distance('JFK', 'BQN', 1579).
airports_distance('JFK', 'LRM', 1559).
airports_distance('JFK', 'SDQ', 1553).
airports_distance('JFK', 'STI', 1478).
airports_distance('JFK', 'SAP', 1935).
airports_distance('JFK', 'PAP', 1526).
airports_distance('JFK', 'GCM', 1540).
airports_distance('JFK', 'CTG', 2088).
airports_distance('JFK', 'MDE', 2383).
airports_distance('JFK', 'GEO', 2545).
airports_distance('JFK', 'FDF', 1956).
airports_distance('JFK', 'PTP', 1835).
airports_distance('JFK', 'GND', 2107).
airports_distance('JFK', 'SKB', 1740).
airports_distance('JFK', 'DKR', 3800).
airports_distance('JFK', 'BUR', 2458).
airports_distance('JFK', 'AZS', 1495).
airports_distance('JFK', 'PSE', 1620).
airports_distance('JFK', 'DAB', 891).
airports_distance('JFK', 'FOC', 7751).
airports_distance('JFK', 'CKG', 7570).
airports_distance('JFK', 'ORH', 149).
airports_distance('JFK', 'ACK', 198).
airports_distance('JFK', 'HYA', 195).
airports_distance('JFK', 'SVD', 2045).
airports_distance('JFK', 'BER', 3968).
airports_distance('LAX', 'YYZ', 2170).
airports_distance('LAX', 'YVR', 1081).
airports_distance('LAX', 'LHR', 5439).
airports_distance('LAX', 'LGW', 5463).
airports_distance('LAX', 'CDG', 5652).
airports_distance('LAX', 'FRA', 5788).
airports_distance('LAX', 'HEL', 5597).
airports_distance('LAX', 'NRT', 5436).
airports_distance('LAX', 'SYD', 7489).
airports_distance('LAX', 'SIN', 8756).
airports_distance('LAX', 'MEL', 7922).
airports_distance('LAX', 'DXB', 8321).
airports_distance('LAX', 'DUB', 5165).
airports_distance('LAX', 'HKG', 7243).
airports_distance('LAX', 'AKL', 6512).
airports_distance('LAX', 'PEK', 6232).
airports_distance('LAX', 'BNE', 7162).
airports_distance('LAX', 'PVG', 6467).
airports_distance('LAX', 'FCO', 6336).
airports_distance('LAX', 'AMS', 5561).
airports_distance('LAX', 'BCN', 6007).
airports_distance('LAX', 'MAD', 5828).
airports_distance('LAX', 'VIE', 6119).
airports_distance('LAX', 'ZRH', 5920).
airports_distance('LAX', 'MUC', 5971).
airports_distance('LAX', 'MAN', 5296).
airports_distance('LAX', 'YUL', 2467).
airports_distance('LAX', 'YEG', 1358).
airports_distance('LAX', 'OSL', 5328).
airports_distance('LAX', 'ARN', 5503).
airports_distance('LAX', 'YYC', 1206).
airports_distance('LAX', 'MNL', 7290).
airports_distance('LAX', 'SVO', 6059).
airports_distance('LAX', 'HND', 5472).
airports_distance('LAX', 'DOH', 8287).
airports_distance('LAX', 'MXP', 6020).
airports_distance('LAX', 'ICN', 5977).
airports_distance('LAX', 'GRU', 6159).
airports_distance('LAX', 'EZE', 6123).
airports_distance('LAX', 'LIM', 4173).
airports_distance('LAX', 'SCL', 5580).
airports_distance('LAX', 'MEX', 1552).
airports_distance('LAX', 'WAW', 5997).
airports_distance('LAX', 'TLV', 7555).
airports_distance('LAX', 'PIT', 2130).
airports_distance('LAX', 'PWM', 2635).
airports_distance('LAX', 'PDX', 834).
airports_distance('LAX', 'OKC', 1184).
airports_distance('LAX', 'IST', 6832).
airports_distance('LAX', 'AUH', 8372).
airports_distance('LAX', 'CPH', 5606).
airports_distance('LAX', 'CLT', 2119).
airports_distance('LAX', 'CUN', 2115).
airports_distance('LAX', 'PSP', 109).
airports_distance('LAX', 'MEM', 1614).
airports_distance('LAX', 'CVG', 1894).
airports_distance('LAX', 'IND', 1809).
airports_distance('LAX', 'MCI', 1360).
airports_distance('LAX', 'DAL', 1243).
airports_distance('LAX', 'STL', 1588).
airports_distance('LAX', 'ABQ', 675).
airports_distance('LAX', 'MKE', 1751).
airports_distance('LAX', 'MDW', 1746).
airports_distance('LAX', 'OMA', 1327).
airports_distance('LAX', 'TUL', 1279).
airports_distance('LAX', 'PVR', 1218).
airports_distance('LAX', 'OGG', 2481).
airports_distance('LAX', 'DUS', 5671).
airports_distance('LAX', 'GUM', 6077).
airports_distance('LAX', 'TPE', 6782).
airports_distance('LAX', 'KIX', 5726).
airports_distance('LAX', 'JED', 8314).
airports_distance('LAX', 'KEF', 4301).
airports_distance('LAX', 'MBJ', 2703).
airports_distance('LAX', 'SJO', 2721).
airports_distance('LAX', 'SMF', 373).
airports_distance('LAX', 'RUH', 8246).
airports_distance('LAX', 'CAN', 7214).
airports_distance('LAX', 'COS', 832).
airports_distance('LAX', 'SDF', 1837).
airports_distance('LAX', 'BUF', 2211).
airports_distance('LAX', 'BOI', 675).
airports_distance('LAX', 'LIH', 2610).
airports_distance('LAX', 'RNO', 391).
airports_distance('LAX', 'CMH', 1990).
airports_distance('LAX', 'ICT', 1199).
airports_distance('LAX', 'BDL', 2519).
airports_distance('LAX', 'NAN', 5521).
airports_distance('LAX', 'SGF', 1419).
airports_distance('LAX', 'NKG', 6561).
airports_distance('LAX', 'ITO', 2445).
airports_distance('LAX', 'GUA', 2193).
airports_distance('LAX', 'HAV', 2298).
airports_distance('LAX', 'VKO', 6082).
airports_distance('LAX', 'CTU', 7188).
airports_distance('LAX', 'BOG', 3477).
airports_distance('LAX', 'AGU', 1293).
airports_distance('LAX', 'MTY', 1230).
airports_distance('LAX', 'BJX', 1366).
airports_distance('LAX', 'BZE', 2175).
airports_distance('LAX', 'DRO', 638).
airports_distance('LAX', 'FAT', 209).
airports_distance('LAX', 'GDL', 1308).
airports_distance('LAX', 'GJT', 654).
airports_distance('LAX', 'LIR', 2626).
airports_distance('LAX', 'MLM', 1442).
airports_distance('LAX', 'MSN', 1683).
airports_distance('LAX', 'MZT', 1045).
airports_distance('LAX', 'PTY', 3009).
airports_distance('LAX', 'SAL', 2319).
airports_distance('LAX', 'SJD', 912).
airports_distance('LAX', 'XNA', 1367).
airports_distance('LAX', 'ZCL', 1219).
airports_distance('LAX', 'EGE', 746).
airports_distance('LAX', 'HDN', 762).
airports_distance('LAX', 'XMN', 6947).
airports_distance('LAX', 'HGH', 6570).
airports_distance('LAX', 'SBN', 1818).
airports_distance('LAX', 'PPT', 4105).
airports_distance('LAX', 'KOA', 2500).
airports_distance('LAX', 'SZX', 7231).
airports_distance('LAX', 'CSX', 6971).
airports_distance('LAX', 'TAO', 6279).
airports_distance('LAX', 'CKG', 7141).
airports_distance('LAX', 'CEB', 7330).
airports_distance('LAX', 'SHE', 5902).
airports_distance('LAX', 'LFW', 7621).
airports_distance('LAX', 'ACV', 577).
airports_distance('LAX', 'BFL', 109).
airports_distance('LAX', 'EUG', 748).
airports_distance('LAX', 'MFR', 630).
airports_distance('LAX', 'MRY', 266).
airports_distance('LAX', 'PSC', 852).
airports_distance('LAX', 'RDM', 727).
airports_distance('LAX', 'SBA', 88).
airports_distance('LAX', 'SBP', 155).
airports_distance('LAX', 'YLW', 1107).
airports_distance('LAX', 'ASE', 736).
airports_distance('LAX', 'BLI', 1047).
airports_distance('LAX', 'CLD', 86).
airports_distance('LAX', 'GEG', 945).
airports_distance('LAX', 'IGM', 270).
airports_distance('LAX', 'MCE', 259).
airports_distance('LAX', 'MMH', 255).
airports_distance('LAX', 'YUM', 237).
airports_distance('LAX', 'PRC', 345).
airports_distance('LAX', 'SMX', 134).
airports_distance('LAX', 'STS', 399).
airports_distance('LAX', 'VIS', 173).
airports_distance('LAX', 'DGO', 1076).
airports_distance('LAX', 'HMO', 547).
airports_distance('LAX', 'LTO', 692).
airports_distance('LAX', 'UPN', 1420).
airports_distance('LAX', 'ZIH', 1539).
airports_distance('LAX', 'ZLO', 1330).
airports_distance('LAX', 'RAR', 4680).
airports_distance('LAX', 'TNA', 6372).
airports_distance('LAX', 'XIY', 6807).
airports_distance('LAX', 'PVU', 568).
airports_distance('LAX', 'BZN', 902).
airports_distance('LAX', 'FCA', 1015).
airports_distance('LAX', 'JAC', 784).
airports_distance('LAX', 'MSO', 924).
airports_distance('LAX', 'SGU', 348).
airports_distance('LAX', 'MTJ', 665).
airports_distance('LAX', 'ACA', 1656).
airports_distance('LAX', 'OAX', 1780).
airports_distance('LAX', 'FLG', 392).
airports_distance('LAX', 'IPL', 180).
airports_distance('LAX', 'OGD', 611).
airports_distance('LAX', 'SUN', 696).
airports_distance('LAX', 'PAE', 985).
airports_distance('LAX', 'BER', 5802).
airports_distance('LGA', 'YYZ', 356).
airports_distance('LGA', 'YOW', 327).
airports_distance('LGA', 'RSW', 1081).
airports_distance('LGA', 'YUL', 324).
airports_distance('LGA', 'PIT', 334).
airports_distance('LGA', 'PWM', 269).
airports_distance('LGA', 'ROC', 253).
airports_distance('LGA', 'YHZ', 596).
airports_distance('LGA', 'CLT', 543).
airports_distance('LGA', 'MEM', 961).
airports_distance('LGA', 'CVG', 584).
airports_distance('LGA', 'IND', 658).
airports_distance('LGA', 'MCI', 1104).
airports_distance('LGA', 'DAL', 1378).
airports_distance('LGA', 'STL', 885).
airports_distance('LGA', 'MKE', 736).
airports_distance('LGA', 'MDW', 723).
airports_distance('LGA', 'OMA', 1144).
airports_distance('LGA', 'NAS', 1106).
airports_distance('LGA', 'EYW', 1209).
airports_distance('LGA', 'LIT', 1083).
airports_distance('LGA', 'AUA', 1966).
airports_distance('LGA', 'ORF', 296).
airports_distance('LGA', 'JAX', 834).
airports_distance('LGA', 'BHM', 865).
airports_distance('LGA', 'SDF', 657).
airports_distance('LGA', 'BUF', 291).
airports_distance('LGA', 'CMH', 477).
airports_distance('LGA', 'RIC', 292).
airports_distance('LGA', 'LEX', 603).
airports_distance('LGA', 'DSM', 1028).
airports_distance('LGA', 'MYR', 563).
airports_distance('LGA', 'CAE', 617).
airports_distance('LGA', 'CHA', 733).
airports_distance('LGA', 'CHS', 642).
airports_distance('LGA', 'DAY', 548).
airports_distance('LGA', 'GRR', 616).
airports_distance('LGA', 'GSO', 460).
airports_distance('LGA', 'GSP', 609).
airports_distance('LGA', 'MSN', 809).
airports_distance('LGA', 'SAV', 722).
airports_distance('LGA', 'TYS', 646).
airports_distance('LGA', 'XNA', 1144).
airports_distance('LGA', 'CAK', 395).
airports_distance('LGA', 'MHT', 195).
airports_distance('LGA', 'SYR', 198).
airports_distance('LGA', 'AVL', 598).
airports_distance('LGA', 'EGE', 1734).
airports_distance('LGA', 'SRQ', 1048).
airports_distance('LGA', 'ROA', 405).
airports_distance('LGA', 'BGR', 378).
airports_distance('LGA', 'BTV', 258).
airports_distance('LGA', 'ILM', 500).
airports_distance('LGA', 'CHO', 305).
airports_distance('LGA', 'DAB', 897).
airports_distance('LGA', 'MTJ', 1804).
airports_distance('LGA', 'TVC', 653).
airports_distance('LGA', 'ACK', 201).
airports_distance('LGA', 'MVY', 175).
airports_distance('MCO', 'YYZ', 1057).
airports_distance('MCO', 'YVR', 2622).
airports_distance('MCO', 'LGW', 4341).
airports_distance('MCO', 'CDG', 4495).
airports_distance('MCO', 'FRA', 4730).
airports_distance('MCO', 'DXB', 7737).
airports_distance('MCO', 'DUB', 4062).
airports_distance('MCO', 'AMS', 4527).
airports_distance('MCO', 'ZRH', 4790).
airports_distance('MCO', 'RSW', 134).
airports_distance('MCO', 'MAN', 4225).
airports_distance('MCO', 'YUL', 1247).
airports_distance('MCO', 'YEG', 2369).
airports_distance('MCO', 'CGN', 4654).
airports_distance('MCO', 'OSL', 4609).
airports_distance('MCO', 'ARN', 4843).
airports_distance('MCO', 'GLA', 4115).
airports_distance('MCO', 'YYC', 2304).
airports_distance('MCO', 'YYT', 2021).
airports_distance('MCO', 'GRU', 4265).
airports_distance('MCO', 'LIM', 2807).
airports_distance('MCO', 'SCL', 4324).
airports_distance('MCO', 'MEX', 1279).
airports_distance('MCO', 'KIN', 779).
airports_distance('MCO', 'TLH', 228).
airports_distance('MCO', 'PIT', 835).
airports_distance('MCO', 'PWM', 1214).
airports_distance('MCO', 'PDX', 2529).
airports_distance('MCO', 'OKC', 1067).
airports_distance('MCO', 'ONT', 2166).
airports_distance('MCO', 'ROC', 1034).
airports_distance('MCO', 'YHZ', 1497).
airports_distance('MCO', 'YWG', 1703).
airports_distance('MCO', 'CLT', 469).
airports_distance('MCO', 'CUN', 618).
airports_distance('MCO', 'MEM', 683).
airports_distance('MCO', 'CVG', 758).
airports_distance('MCO', 'IND', 830).
airports_distance('MCO', 'MCI', 1072).
airports_distance('MCO', 'DAL', 971).
airports_distance('MCO', 'STL', 882).
airports_distance('MCO', 'ABQ', 1549).
airports_distance('MCO', 'MKE', 1067).
airports_distance('MCO', 'MDW', 991).
airports_distance('MCO', 'OMA', 1210).
airports_distance('MCO', 'TUL', 1004).
airports_distance('MCO', 'DUS', 4629).
airports_distance('MCO', 'NAS', 333).
airports_distance('MCO', 'FPO', 206).
airports_distance('MCO', 'EYW', 269).
airports_distance('MCO', 'KEF', 3527).
airports_distance('MCO', 'STT', 1246).
airports_distance('MCO', 'POS', 1785).
airports_distance('MCO', 'MBJ', 718).
airports_distance('MCO', 'LIT', 775).
airports_distance('MCO', 'AUA', 1318).
airports_distance('MCO', 'ORF', 655).
airports_distance('MCO', 'PVD', 1073).
airports_distance('MCO', 'PUJ', 1064).
airports_distance('MCO', 'MDT', 852).
airports_distance('MCO', 'SJO', 1287).
airports_distance('MCO', 'SMF', 2402).
airports_distance('MCO', 'COS', 1518).
airports_distance('MCO', 'HSV', 536).
airports_distance('MCO', 'BHM', 479).
airports_distance('MCO', 'SDF', 719).
airports_distance('MCO', 'BUF', 1012).
airports_distance('MCO', 'CMH', 804).
airports_distance('MCO', 'ALB', 1074).
airports_distance('MCO', 'YXE', 2093).
airports_distance('MCO', 'BDL', 1051).
airports_distance('MCO', 'RIC', 668).
airports_distance('MCO', 'GUA', 1123).
airports_distance('MCO', 'ISP', 972).
airports_distance('MCO', 'IAG', 1022).
airports_distance('MCO', 'SWF', 990).
airports_distance('MCO', 'HAV', 382).
airports_distance('MCO', 'BMI', 937).
airports_distance('MCO', 'BOG', 1704).
airports_distance('MCO', 'DSM', 1141).
airports_distance('MCO', 'MYR', 389).
airports_distance('MCO', 'MTY', 1169).
airports_distance('MCO', 'DAY', 809).
airports_distance('MCO', 'GDL', 1483).
airports_distance('MCO', 'GRR', 1025).
airports_distance('MCO', 'GSO', 535).
airports_distance('MCO', 'GSP', 450).
airports_distance('MCO', 'JAN', 587).
airports_distance('MCO', 'LFT', 654).
airports_distance('MCO', 'PNS', 380).
airports_distance('MCO', 'PTY', 1342).
airports_distance('MCO', 'SAL', 1148).
airports_distance('MCO', 'TYS', 533).
airports_distance('MCO', 'CAK', 862).
airports_distance('MCO', 'MHT', 1142).
airports_distance('MCO', 'SYR', 1054).
airports_distance('MCO', 'YQR', 1947).
airports_distance('MCO', 'AVL', 489).
airports_distance('MCO', 'BTV', 1195).
airports_distance('MCO', 'BQN', 1128).
airports_distance('MCO', 'GNV', 105).
airports_distance('MCO', 'SDQ', 1009).
airports_distance('MCO', 'SAP', 990).
airports_distance('MCO', 'PAP', 887).
airports_distance('MCO', 'MHH', 291).
airports_distance('MCO', 'BSB', 3785).
airports_distance('MCO', 'CNF', 4149).
airports_distance('MCO', 'REC', 3989).
airports_distance('MCO', 'CTG', 1297).
airports_distance('MCO', 'MDE', 1585).
airports_distance('MCO', 'PSE', 1178).
airports_distance('MCO', 'ACY', 853).
airports_distance('MCO', 'FNT', 1013).
airports_distance('MCO', 'MCN', 326).
airports_distance('MCO', 'TTN', 897).
airports_distance('MCO', 'LBE', 825).
airports_distance('MCO', 'ORH', 1092).
airports_distance('MCO', 'PBG', 1200).
airports_distance('MCO', 'YQM', 1518).
airports_distance('MCO', 'YYG', 1578).
airports_distance('MCO', 'YHM', 1021).
airports_distance('MCO', 'FOR', 3605).
airports_distance('MCO', 'VCP', 4217).
airports_distance('MCO', 'LCK', 791).
airports_distance('MCO', 'PSM', 1167).
airports_distance('MIA', 'YYZ', 1235).
airports_distance('MIA', 'LHR', 4414).
airports_distance('MIA', 'LGW', 4429).
airports_distance('MIA', 'CDG', 4577).
airports_distance('MIA', 'FRA', 4820).
airports_distance('MIA', 'HEL', 5171).
airports_distance('MIA', 'DUB', 4156).
airports_distance('MIA', 'FCO', 5172).
airports_distance('MIA', 'AMS', 4622).
airports_distance('MIA', 'BCN', 4685).
airports_distance('MIA', 'MAD', 4413).
airports_distance('MIA', 'VIE', 5206).
airports_distance('MIA', 'ZRH', 4871).
airports_distance('MIA', 'YOW', 1373).
airports_distance('MIA', 'BRU', 4632).
airports_distance('MIA', 'MUC', 4994).
airports_distance('MIA', 'RSW', 104).
airports_distance('MIA', 'MAN', 4320).
airports_distance('MIA', 'YUL', 1406).
airports_distance('MIA', 'YEG', 2555).
airports_distance('MIA', 'CGN', 4745).
airports_distance('MIA', 'OSL', 4729).
airports_distance('MIA', 'ARN', 4965).
airports_distance('MIA', 'SVO', 5713).
airports_distance('MIA', 'DOH', 7662).
airports_distance('MIA', 'MXP', 4918).
airports_distance('MIA', 'MVD', 4477).
airports_distance('MIA', 'GIG', 4171).
airports_distance('MIA', 'GRU', 4082).
airports_distance('MIA', 'EZE', 4420).
airports_distance('MIA', 'LIM', 2620).
airports_distance('MIA', 'SCL', 4134).
airports_distance('MIA', 'MEX', 1273).
airports_distance('MIA', 'KIN', 587).
airports_distance('MIA', 'TLH', 403).
airports_distance('MIA', 'WAW', 5272).
airports_distance('MIA', 'TLV', 6587).
airports_distance('MIA', 'PIT', 1015).
airports_distance('MIA', 'IST', 5952).
airports_distance('MIA', 'YWG', 1894).
airports_distance('MIA', 'CPH', 4871).
airports_distance('MIA', 'CLT', 652).
airports_distance('MIA', 'CUN', 531).
airports_distance('MIA', 'MEM', 860).
airports_distance('MIA', 'CVG', 950).
airports_distance('MIA', 'IND', 1022).
airports_distance('MIA', 'MCI', 1251).
airports_distance('MIA', 'STL', 1069).
airports_distance('MIA', 'MKE', 1260).
airports_distance('MIA', 'OMA', 1393).
airports_distance('MIA', 'TUL', 1167).
airports_distance('MIA', 'DUS', 4721).
airports_distance('MIA', 'LIS', 4146).
airports_distance('MIA', 'NAS', 184).
airports_distance('MIA', 'FPO', 112).
airports_distance('MIA', 'GGT', 317).
airports_distance('MIA', 'EYW', 125).
airports_distance('MIA', 'KEF', 3658).
airports_distance('MIA', 'BGI', 1610).
airports_distance('MIA', 'ANU', 1328).
airports_distance('MIA', 'STT', 1106).
airports_distance('MIA', 'BDA', 1044).
airports_distance('MIA', 'TAB', 1623).
airports_distance('MIA', 'POS', 1623).
airports_distance('MIA', 'MBJ', 526).
airports_distance('MIA', 'CUR', 1194).
airports_distance('MIA', 'BON', 1226).
airports_distance('MIA', 'AUA', 1135).
airports_distance('MIA', 'ORF', 803).
airports_distance('MIA', 'JAX', 336).
airports_distance('MIA', 'PVD', 1211).
airports_distance('MIA', 'PUJ', 910).
airports_distance('MIA', 'SJO', 1121).
airports_distance('MIA', 'RTB', 767).
airports_distance('MIA', 'TGU', 926).
airports_distance('MIA', 'BHM', 662).
airports_distance('MIA', 'YQB', 1530).
airports_distance('MIA', 'SDF', 912).
airports_distance('MIA', 'BUF', 1187).
airports_distance('MIA', 'CMH', 992).
airports_distance('MIA', 'BDL', 1196).
airports_distance('MIA', 'SXM', 1222).
airports_distance('MIA', 'RIC', 827).
airports_distance('MIA', 'CCS', 1362).
airports_distance('MIA', 'GYE', 1930).
airports_distance('MIA', 'GUA', 1018).
airports_distance('MIA', 'ISP', 1115).
airports_distance('MIA', 'BIM', 64).
airports_distance('MIA', 'HAV', 235).
airports_distance('MIA', 'VKO', 5724).
airports_distance('MIA', 'CMN', 4310).
airports_distance('MIA', 'BMI', 1128).
airports_distance('MIA', 'BOG', 1512).
airports_distance('MIA', 'CZM', 556).
airports_distance('MIA', 'MTY', 1231).
airports_distance('MIA', 'BZE', 767).
airports_distance('MIA', 'CHS', 491).
airports_distance('MIA', 'GDL', 1504).
airports_distance('MIA', 'GRR', 1216).
airports_distance('MIA', 'GSO', 712).
airports_distance('MIA', 'GSP', 639).
airports_distance('MIA', 'LIR', 1104).
airports_distance('MIA', 'PLS', 578).
airports_distance('MIA', 'PNS', 530).
airports_distance('MIA', 'PTY', 1156).
airports_distance('MIA', 'SAL', 1025).
airports_distance('MIA', 'SAV', 441).
airports_distance('MIA', 'TYS', 726).
airports_distance('MIA', 'UVF', 1504).
airports_distance('MIA', 'EGE', 1808).
airports_distance('MIA', 'SFB', 214).
airports_distance('MIA', 'POP', 746).
airports_distance('MIA', 'HOG', 428).
airports_distance('MIA', 'VRA', 204).
airports_distance('MIA', 'UIO', 1794).
airports_distance('MIA', 'PBM', 2172).
airports_distance('MIA', 'APF', 95).
airports_distance('MIA', 'GNV', 295).
airports_distance('MIA', 'LRM', 886).
airports_distance('MIA', 'SDQ', 848).
airports_distance('MIA', 'STI', 758).
airports_distance('MIA', 'SAP', 867).
airports_distance('MIA', 'MID', 682).
airports_distance('MIA', 'MGA', 1017).
airports_distance('MIA', 'PAP', 713).
airports_distance('MIA', 'GCM', 454).
airports_distance('MIA', 'MHH', 205).
airports_distance('MIA', 'ELH', 226).
airports_distance('MIA', 'BEL', 2833).
airports_distance('MIA', 'BSB', 3606).
airports_distance('MIA', 'CNF', 3971).
airports_distance('MIA', 'MAO', 2407).
airports_distance('MIA', 'REC', 3840).
airports_distance('MIA', 'SSA', 3885).
airports_distance('MIA', 'ASU', 3837).
airports_distance('MIA', 'BAQ', 1090).
airports_distance('MIA', 'CTG', 1105).
airports_distance('MIA', 'CLO', 1558).
airports_distance('MIA', 'MDE', 1393).
airports_distance('MIA', 'LPB', 3032).
airports_distance('MIA', 'BLA', 1488).
airports_distance('MIA', 'MAR', 1191).
airports_distance('MIA', 'GEO', 1971).
airports_distance('MIA', 'FDF', 1467).
airports_distance('MIA', 'PTP', 1374).
airports_distance('MIA', 'GND', 1535).
airports_distance('MIA', 'STX', 1138).
airports_distance('MIA', 'SKB', 1269).
airports_distance('MIA', 'TTN', 1048).
airports_distance('MIA', 'ZSA', 380).
airports_distance('MIA', 'CMW', 339).
airports_distance('MIA', 'SNU', 229).
airports_distance('MIA', 'SCU', 492).
airports_distance('MIA', 'VVI', 3213).
airports_distance('MIA', 'COR', 4084).
airports_distance('MIA', 'FOR', 3459).
airports_distance('MIA', 'POA', 4307).
airports_distance('MIA', 'CAP', 664).
airports_distance('MIA', 'SMR', 1088).
airports_distance('MIA', 'SVD', 1515).
airports_distance('MIA', 'CFG', 252).
airports_distance('MIA', 'BER', 4975).
airports_distance('MSP', 'YYZ', 676).
airports_distance('MSP', 'YVR', 1431).
airports_distance('MSP', 'LHR', 4001).
airports_distance('MSP', 'CDG', 4207).
airports_distance('MSP', 'DUB', 3722).
airports_distance('MSP', 'FCO', 4886).
airports_distance('MSP', 'AMS', 4151).
airports_distance('MSP', 'RSW', 1417).
airports_distance('MSP', 'YUL', 947).
airports_distance('MSP', 'YEG', 1083).
airports_distance('MSP', 'YYC', 1048).
airports_distance('MSP', 'HND', 5963).
airports_distance('MSP', 'ICN', 6228).
airports_distance('MSP', 'PIT', 724).
airports_distance('MSP', 'PDX', 1421).
airports_distance('MSP', 'OKC', 694).
airports_distance('MSP', 'ROC', 781).
airports_distance('MSP', 'RST', 76).
airports_distance('MSP', 'YWG', 395).
airports_distance('MSP', 'CLT', 929).
airports_distance('MSP', 'CUN', 1686).
airports_distance('MSP', 'PSP', 1451).
airports_distance('MSP', 'MEM', 701).
airports_distance('MSP', 'CVG', 595).
airports_distance('MSP', 'IND', 502).
airports_distance('MSP', 'MCI', 393).
airports_distance('MSP', 'STL', 448).
airports_distance('MSP', 'ABQ', 979).
airports_distance('MSP', 'MKE', 297).
airports_distance('MSP', 'MDW', 348).
airports_distance('MSP', 'OMA', 281).
airports_distance('MSP', 'TUL', 616).
airports_distance('MSP', 'KEF', 2934).
airports_distance('MSP', 'MBJ', 2023).
airports_distance('MSP', 'AUA', 2620).
airports_distance('MSP', 'ORF', 1042).
airports_distance('MSP', 'JAX', 1174).
airports_distance('MSP', 'PVD', 1113).
airports_distance('MSP', 'PUJ', 2311).
airports_distance('MSP', 'SMF', 1513).
airports_distance('MSP', 'COS', 723).
airports_distance('MSP', 'BHM', 854).
airports_distance('MSP', 'RAP', 488).
airports_distance('MSP', 'SDF', 603).
airports_distance('MSP', 'BUF', 732).
airports_distance('MSP', 'BOI', 1138).
airports_distance('MSP', 'HRL', 1311).
airports_distance('MSP', 'CMH', 624).
airports_distance('MSP', 'ALB', 976).
airports_distance('MSP', 'ICT', 545).
airports_distance('MSP', 'YXE', 794).
airports_distance('MSP', 'BDL', 1047).
airports_distance('MSP', 'BIL', 745).
airports_distance('MSP', 'SXM', 2537).
airports_distance('MSP', 'RIC', 968).
airports_distance('MSP', 'PIA', 342).
airports_distance('MSP', 'LEX', 649).
airports_distance('MSP', 'ISP', 1054).
airports_distance('MSP', 'BMI', 374).
airports_distance('MSP', 'DSM', 232).
airports_distance('MSP', 'MYR', 1084).
airports_distance('MSP', 'BZE', 1909).
airports_distance('MSP', 'DAY', 573).
airports_distance('MSP', 'FAR', 223).
airports_distance('MSP', 'FSD', 196).
airports_distance('MSP', 'FWA', 487).
airports_distance('MSP', 'GRR', 407).
airports_distance('MSP', 'MLI', 274).
airports_distance('MSP', 'MSN', 227).
airports_distance('MSP', 'SAV', 1092).
airports_distance('MSP', 'TYS', 791).
airports_distance('MSP', 'XNA', 596).
airports_distance('MSP', 'MHT', 1089).
airports_distance('MSP', 'SYR', 857).
airports_distance('MSP', 'YQR', 655).
airports_distance('MSP', 'LAN', 454).
airports_distance('MSP', 'MQT', 299).
airports_distance('MSP', 'GRB', 251).
airports_distance('MSP', 'SKB', 2593).
airports_distance('MSP', 'ATW', 235).
airports_distance('MSP', 'AZO', 425).
airports_distance('MSP', 'FNT', 489).
airports_distance('MSP', 'MBS', 462).
airports_distance('MSP', 'SBN', 410).
airports_distance('MSP', 'TTN', 986).
airports_distance('MSP', 'PSC', 1250).
airports_distance('MSP', 'SBA', 1578).
airports_distance('MSP', 'ASE', 800).
airports_distance('MSP', 'GEG', 1171).
airports_distance('MSP', 'STS', 1578).
airports_distance('MSP', 'BZN', 871).
airports_distance('MSP', 'FCA', 1022).
airports_distance('MSP', 'GTF', 884).
airports_distance('MSP', 'HLN', 910).
airports_distance('MSP', 'MSO', 1009).
airports_distance('MSP', 'BIS', 385).
airports_distance('MSP', 'DIK', 479).
airports_distance('MSP', 'ISN', 544).
airports_distance('MSP', 'LNK', 331).
airports_distance('MSP', 'MOT', 448).
airports_distance('MSP', 'CWA', 174).
airports_distance('MSP', 'DLH', 144).
airports_distance('MSP', 'LSE', 119).
airports_distance('MSP', 'TVC', 374).
airports_distance('MSP', 'GFK', 283).
airports_distance('MSP', 'ABR', 256).
airports_distance('MSP', 'APN', 472).
airports_distance('MSP', 'ATY', 192).
airports_distance('MSP', 'BJI', 199).
airports_distance('MSP', 'BRD', 114).
airports_distance('MSP', 'HIB', 174).
airports_distance('MSP', 'IMT', 256).
airports_distance('MSP', 'INL', 255).
airports_distance('MSP', 'RHI', 190).
airports_distance('MSP', 'IWD', 187).
airports_distance('MSP', 'FOD', 168).
airports_distance('MSP', 'XWA', 551).
airports_distance('ORD', 'YYZ', 435).
airports_distance('ORD', 'YVR', 1758).
airports_distance('ORD', 'LHR', 3939).
airports_distance('ORD', 'LGW', 3960).
airports_distance('ORD', 'CDG', 4138).
airports_distance('ORD', 'FRA', 4328).
airports_distance('ORD', 'NRT', 6255).
airports_distance('ORD', 'DXB', 7228).
airports_distance('ORD', 'DEL', 7464).
airports_distance('ORD', 'DUB', 3661).
airports_distance('ORD', 'HKG', 7776).
airports_distance('ORD', 'AKL', 8186).
airports_distance('ORD', 'PEK', 6559).
airports_distance('ORD', 'PVG', 7038).
airports_distance('ORD', 'FCO', 4807).
airports_distance('ORD', 'AMS', 4106).
airports_distance('ORD', 'BCN', 4405).
airports_distance('ORD', 'MAD', 4188).
airports_distance('ORD', 'VIE', 4698).
airports_distance('ORD', 'ZRH', 4428).
airports_distance('ORD', 'YOW', 653).
airports_distance('ORD', 'BRU', 4145).
airports_distance('ORD', 'MUC', 4514).
airports_distance('ORD', 'RSW', 1122).
airports_distance('ORD', 'MAN', 3813).
airports_distance('ORD', 'YUL', 746).
airports_distance('ORD', 'YEG', 1416).
airports_distance('ORD', 'VCE', 4653).
airports_distance('ORD', 'ARN', 4257).
airports_distance('ORD', 'YYC', 1381).
airports_distance('ORD', 'HND', 6286).
airports_distance('ORD', 'DOH', 7115).
airports_distance('ORD', 'MXP', 4508).
airports_distance('ORD', 'ATH', 5446).
airports_distance('ORD', 'BUD', 4824).
airports_distance('ORD', 'ICN', 6532).
airports_distance('ORD', 'GRU', 5233).
airports_distance('ORD', 'MEX', 1688).
airports_distance('ORD', 'WAW', 4669).
airports_distance('ORD', 'ADD', 7563).
airports_distance('ORD', 'PIT', 411).
airports_distance('ORD', 'PWM', 897).
airports_distance('ORD', 'PDX', 1733).
airports_distance('ORD', 'OKC', 692).
airports_distance('ORD', 'ONT', 1695).
airports_distance('ORD', 'ROC', 526).
airports_distance('ORD', 'RST', 268).
airports_distance('ORD', 'IST', 5456).
airports_distance('ORD', 'YHZ', 1235).
airports_distance('ORD', 'AUH', 7257).
airports_distance('ORD', 'YWG', 707).
airports_distance('ORD', 'CPH', 4256).
airports_distance('ORD', 'CLT', 599).
airports_distance('ORD', 'CUN', 1447).
airports_distance('ORD', 'PSP', 1647).
airports_distance('ORD', 'MEM', 492).
airports_distance('ORD', 'CVG', 264).
airports_distance('ORD', 'IND', 177).
airports_distance('ORD', 'MCI', 402).
airports_distance('ORD', 'STL', 258).
airports_distance('ORD', 'ABQ', 1115).
airports_distance('ORD', 'MKE', 67).
airports_distance('ORD', 'SLN', 557).
airports_distance('ORD', 'OMA', 415).
airports_distance('ORD', 'TUL', 585).
airports_distance('ORD', 'PVR', 1784).
airports_distance('ORD', 'OGG', 4175).
airports_distance('ORD', 'DUS', 4215).
airports_distance('ORD', 'LIS', 3996).
airports_distance('ORD', 'TPE', 7439).
airports_distance('ORD', 'NAS', 1313).
airports_distance('ORD', 'EYW', 1253).
airports_distance('ORD', 'KEF', 2934).
airports_distance('ORD', 'STT', 2116).
airports_distance('ORD', 'MBJ', 1724).
airports_distance('ORD', 'LIT', 552).
airports_distance('ORD', 'AUA', 2302).
airports_distance('ORD', 'ORF', 715).
airports_distance('ORD', 'JAX', 865).
airports_distance('ORD', 'PVD', 847).
airports_distance('ORD', 'PUJ', 1982).
airports_distance('ORD', 'MDT', 592).
airports_distance('ORD', 'SJO', 2220).
airports_distance('ORD', 'SMF', 1776).
airports_distance('ORD', 'COS', 908).
airports_distance('ORD', 'HSV', 511).
airports_distance('ORD', 'BHM', 584).
airports_distance('ORD', 'YQB', 878).
airports_distance('ORD', 'RAP', 777).
airports_distance('ORD', 'SDF', 287).
airports_distance('ORD', 'BUF', 472).
airports_distance('ORD', 'BOI', 1432).
airports_distance('ORD', 'ECP', 812).
airports_distance('ORD', 'RNO', 1666).
airports_distance('ORD', 'CMH', 295).
airports_distance('ORD', 'ALB', 721).
airports_distance('ORD', 'AMM', 6218).
airports_distance('ORD', 'ICT', 587).
airports_distance('ORD', 'YXE', 1124).
airports_distance('ORD', 'BDL', 781).
airports_distance('ORD', 'SXM', 2204).
airports_distance('ORD', 'SGF', 438).
airports_distance('ORD', 'RIC', 641).
airports_distance('ORD', 'PIA', 130).
airports_distance('ORD', 'LEX', 323).
airports_distance('ORD', 'GUA', 1898).
airports_distance('ORD', 'ISP', 770).
airports_distance('ORD', 'BMI', 116).
airports_distance('ORD', 'BOG', 2710).
airports_distance('ORD', 'DSM', 298).
airports_distance('ORD', 'MYR', 753).
airports_distance('ORD', 'MTY', 1316).
airports_distance('ORD', 'BJX', 1650).
airports_distance('ORD', 'BRO', 1234).
airports_distance('ORD', 'CAE', 666).
airports_distance('ORD', 'CHA', 501).
airports_distance('ORD', 'CHS', 760).
airports_distance('ORD', 'CMI', 135).
airports_distance('ORD', 'COU', 315).
airports_distance('ORD', 'CRW', 416).
airports_distance('ORD', 'DAY', 240).
airports_distance('ORD', 'EVV', 273).
airports_distance('ORD', 'FAR', 556).
airports_distance('ORD', 'FAT', 1725).
airports_distance('ORD', 'FSD', 461).
airports_distance('ORD', 'FWA', 156).
airports_distance('ORD', 'GDL', 1732).
airports_distance('ORD', 'GJT', 1097).
airports_distance('ORD', 'GRR', 136).
airports_distance('ORD', 'GSO', 589).
airports_distance('ORD', 'GSP', 577).
airports_distance('ORD', 'JAN', 678).
airports_distance('ORD', 'MHK', 500).
airports_distance('ORD', 'MLI', 139).
airports_distance('ORD', 'MOB', 780).
airports_distance('ORD', 'MSN', 108).
airports_distance('ORD', 'MZT', 1674).
airports_distance('ORD', 'PLS', 1663).
airports_distance('ORD', 'PNS', 795).
airports_distance('ORD', 'PTY', 2330).
airports_distance('ORD', 'SAL', 1972).
airports_distance('ORD', 'SAV', 773).
airports_distance('ORD', 'SJD', 1806).
airports_distance('ORD', 'SPI', 174).
airports_distance('ORD', 'TYS', 475).
airports_distance('ORD', 'VPS', 797).
airports_distance('ORD', 'XNA', 521).
airports_distance('ORD', 'UVF', 2529).
airports_distance('ORD', 'CAK', 342).
airports_distance('ORD', 'BRL', 186).
airports_distance('ORD', 'MHT', 840).
airports_distance('ORD', 'SYR', 605).
airports_distance('ORD', 'YQR', 987).
airports_distance('ORD', 'AVL', 536).
airports_distance('ORD', 'EGE', 1004).
airports_distance('ORD', 'HDN', 1006).
airports_distance('ORD', 'SRQ', 1051).
airports_distance('ORD', 'FOE', 458).
airports_distance('ORD', 'LAN', 178).
airports_distance('ORD', 'ROA', 530).
airports_distance('ORD', 'MQT', 303).
airports_distance('ORD', 'GRB', 173).
airports_distance('ORD', 'KRK', 4723).
airports_distance('ORD', 'BGR', 974).
airports_distance('ORD', 'BTV', 761).
airports_distance('ORD', 'HHH', 781).
airports_distance('ORD', 'ILM', 759).
airports_distance('ORD', 'GCM', 1613).
airports_distance('ORD', 'ACY', 718).
airports_distance('ORD', 'ABE', 652).
airports_distance('ORD', 'ATW', 160).
airports_distance('ORD', 'AVP', 629).
airports_distance('ORD', 'AZO', 122).
airports_distance('ORD', 'CHO', 565).
airports_distance('ORD', 'FNT', 223).
airports_distance('ORD', 'MBS', 222).
airports_distance('ORD', 'MEI', 668).
airports_distance('ORD', 'SBN', 84).
airports_distance('ORD', 'YXU', 351).
airports_distance('ORD', 'ALO', 233).
airports_distance('ORD', 'SUX', 435).
airports_distance('ORD', 'YKF', 395).
airports_distance('ORD', 'CKG', 7392).
airports_distance('ORD', 'EUG', 1774).
airports_distance('ORD', 'RDM', 1671).
airports_distance('ORD', 'ASE', 1010).
airports_distance('ORD', 'GEG', 1493).
airports_distance('ORD', 'DGO', 1558).
airports_distance('ORD', 'BZN', 1182).
airports_distance('ORD', 'JAC', 1159).
airports_distance('ORD', 'MSO', 1328).
airports_distance('ORD', 'BKG', 471).
airports_distance('ORD', 'BIS', 714).
airports_distance('ORD', 'GUC', 1028).
airports_distance('ORD', 'LNK', 465).
airports_distance('ORD', 'MTJ', 1078).
airports_distance('ORD', 'ART', 615).
airports_distance('ORD', 'CMX', 359).
airports_distance('ORD', 'CWA', 213).
airports_distance('ORD', 'DBQ', 146).
airports_distance('ORD', 'DEC', 156).
airports_distance('ORD', 'DLH', 397).
airports_distance('ORD', 'EAU', 268).
airports_distance('ORD', 'ELM', 564).
airports_distance('ORD', 'LSE', 214).
airports_distance('ORD', 'MKG', 118).
airports_distance('ORD', 'PAH', 343).
airports_distance('ORD', 'STC', 393).
airports_distance('ORD', 'TOL', 213).
airports_distance('ORD', 'TVC', 224).
airports_distance('ORD', 'SCE', 526).
airports_distance('ORD', 'ERI', 396).
airports_distance('ORD', 'PGD', 1092).
airports_distance('ORD', 'CGI', 340).
airports_distance('ORD', 'CKB', 443).
airports_distance('ORD', 'UIN', 222).
airports_distance('ORD', 'UST', 907).
airports_distance('ORD', 'SUN', 1337).
airports_distance('ORD', 'MCW', 288).
airports_distance('ORD', 'IWD', 333).
airports_distance('ORD', 'BFM', 784).
airports_distance('ORD', 'BER', 4412).
airports_distance('PBI', 'YYZ', 1174).
airports_distance('PBI', 'PIT', 953).
airports_distance('PBI', 'CLT', 591).
airports_distance('PBI', 'IND', 968).
airports_distance('PBI', 'DAL', 1089).
airports_distance('PBI', 'STL', 1023).
airports_distance('PBI', 'NAS', 199).
airports_distance('PBI', 'PVD', 1150).
airports_distance('PBI', 'CMH', 933).
airports_distance('PBI', 'BDL', 1134).
airports_distance('PBI', 'ISP', 1053).
airports_distance('PBI', 'BIM', 85).
airports_distance('PBI', 'MHH', 186).
airports_distance('PBI', 'ELH', 227).
airports_distance('PBI', 'TTN', 986).
airports_distance('PHX', 'YYZ', 1871).
airports_distance('PHX', 'YVR', 1230).
airports_distance('PHX', 'LHR', 5255).
airports_distance('PHX', 'FRA', 5620).
airports_distance('PHX', 'RSW', 1864).
airports_distance('PHX', 'YUL', 2178).
airports_distance('PHX', 'YEG', 1374).
airports_distance('PHX', 'YYC', 1225).
airports_distance('PHX', 'MEX', 1252).
airports_distance('PHX', 'PIT', 1809).
airports_distance('PHX', 'PDX', 1009).
airports_distance('PHX', 'OKC', 831).
airports_distance('PHX', 'ONT', 324).
airports_distance('PHX', 'CLT', 1769).
airports_distance('PHX', 'CUN', 1758).
airports_distance('PHX', 'PSP', 260).
airports_distance('PHX', 'MEM', 1260).
airports_distance('PHX', 'CVG', 1565).
airports_distance('PHX', 'IND', 1485).
airports_distance('PHX', 'MCI', 1041).
airports_distance('PHX', 'DAL', 877).
airports_distance('PHX', 'STL', 1259).
airports_distance('PHX', 'ABQ', 328).
airports_distance('PHX', 'MKE', 1457).
airports_distance('PHX', 'MDW', 1440).
airports_distance('PHX', 'OMA', 1035).
airports_distance('PHX', 'TUL', 933).
airports_distance('PHX', 'PVR', 973).
airports_distance('PHX', 'OGG', 2839).
airports_distance('PHX', 'LIT', 1133).
airports_distance('PHX', 'ORF', 2024).
airports_distance('PHX', 'SMF', 646).
airports_distance('PHX', 'COS', 551).
airports_distance('PHX', 'SDF', 1502).
airports_distance('PHX', 'BUF', 1907).
airports_distance('PHX', 'BOI', 735).
airports_distance('PHX', 'LIH', 2973).
airports_distance('PHX', 'LBB', 586).
airports_distance('PHX', 'RNO', 600).
airports_distance('PHX', 'CMH', 1666).
airports_distance('PHX', 'ICT', 868).
airports_distance('PHX', 'MAF', 579).
airports_distance('PHX', 'DSM', 1147).
airports_distance('PHX', 'AMA', 600).
airports_distance('PHX', 'CUU', 484).
airports_distance('PHX', 'DRO', 351).
airports_distance('PHX', 'FAT', 492).
airports_distance('PHX', 'FSD', 1079).
airports_distance('PHX', 'GDL', 1039).
airports_distance('PHX', 'GJT', 438).
airports_distance('PHX', 'GRR', 1570).
airports_distance('PHX', 'MSN', 1393).
airports_distance('PHX', 'MZT', 790).
airports_distance('PHX', 'ROW', 431).
airports_distance('PHX', 'SJD', 723).
airports_distance('PHX', 'EGE', 513).
airports_distance('PHX', 'BUR', 368).
airports_distance('PHX', 'KOA', 2854).
airports_distance('PHX', 'BFL', 424).
airports_distance('PHX', 'EUG', 951).
airports_distance('PHX', 'MFR', 854).
airports_distance('PHX', 'MRY', 597).
airports_distance('PHX', 'RDM', 893).
airports_distance('PHX', 'SBA', 454).
airports_distance('PHX', 'SBP', 507).
airports_distance('PHX', 'ASE', 491).
airports_distance('PHX', 'GEG', 1021).
airports_distance('PHX', 'YUM', 159).
airports_distance('PHX', 'STS', 697).
airports_distance('PHX', 'HMO', 305).
airports_distance('PHX', 'ZIH', 1274).
airports_distance('PHX', 'JAC', 706).
airports_distance('PHX', 'SGU', 263).
airports_distance('PHX', 'PGA', 243).
airports_distance('PHX', 'FLG', 119).
airports_distance('PHX', 'SOW', 129).
airports_distance('PHX', 'SVC', 230).
airports_distance('PHX', 'CUL', 658).
airports_distance('PHX', 'IFP', 188).
airports_distance('PHX', 'PAE', 1132).
airports_distance('RDU', 'YYZ', 540).
airports_distance('RDU', 'LHR', 3860).
airports_distance('RDU', 'CDG', 4039).
airports_distance('RDU', 'RSW', 668).
airports_distance('RDU', 'YUL', 713).
airports_distance('RDU', 'PIT', 328).
airports_distance('RDU', 'PWM', 699).
airports_distance('RDU', 'CLT', 129).
airports_distance('RDU', 'CUN', 1135).
airports_distance('RDU', 'MEM', 632).
airports_distance('RDU', 'CVG', 389).
airports_distance('RDU', 'IND', 488).
airports_distance('RDU', 'MCI', 901).
airports_distance('RDU', 'DAL', 1049).
airports_distance('RDU', 'STL', 666).
airports_distance('RDU', 'MKE', 688).
airports_distance('RDU', 'MDW', 631).
airports_distance('RDU', 'MBJ', 1201).
airports_distance('RDU', 'JAX', 408).
airports_distance('RDU', 'PVD', 566).
airports_distance('RDU', 'PUJ', 1354).
airports_distance('RDU', 'BUF', 488).
airports_distance('RDU', 'CMH', 362).
airports_distance('RDU', 'ALB', 544).
airports_distance('RDU', 'BDL', 531).
airports_distance('RDU', 'ISP', 458).
airports_distance('RDU', 'VPS', 582).
airports_distance('RDU', 'SYR', 519).
airports_distance('RDU', 'SFB', 511).
airports_distance('RDU', 'TTN', 373).
airports_distance('RDU', 'PIE', 596).
airports_distance('RDU', 'PGD', 647).
airports_distance('SEA', 'YYZ', 2053).
airports_distance('SEA', 'YVR', 127).
airports_distance('SEA', 'LHR', 4783).
airports_distance('SEA', 'LGW', 4807).
airports_distance('SEA', 'CDG', 4998).
airports_distance('SEA', 'FRA', 5090).
airports_distance('SEA', 'NRT', 4754).
airports_distance('SEA', 'SIN', 8059).
airports_distance('SEA', 'DXB', 7406).
airports_distance('SEA', 'DUB', 4523).
airports_distance('SEA', 'HKG', 6484).
airports_distance('SEA', 'PEK', 5389).
airports_distance('SEA', 'PVG', 5705).
airports_distance('SEA', 'AMS', 4868).
airports_distance('SEA', 'MUC', 5264).
airports_distance('SEA', 'MAN', 4633).
airports_distance('SEA', 'YEG', 557).
airports_distance('SEA', 'CGN', 5008).
airports_distance('SEA', 'YYC', 451).
airports_distance('SEA', 'HND', 4788).
airports_distance('SEA', 'ICN', 5199).
airports_distance('SEA', 'MEX', 2333).
airports_distance('SEA', 'PIT', 2118).
airports_distance('SEA', 'PDX', 129).
airports_distance('SEA', 'OKC', 1516).
airports_distance('SEA', 'ONT', 956).
airports_distance('SEA', 'FAI', 1528).
airports_distance('SEA', 'CLT', 2273).
airports_distance('SEA', 'CUN', 2683).
airports_distance('SEA', 'PSP', 988).
airports_distance('SEA', 'IND', 1860).
airports_distance('SEA', 'MCI', 1485).
airports_distance('SEA', 'DAL', 1667).
airports_distance('SEA', 'STL', 1704).
airports_distance('SEA', 'ABQ', 1178).
airports_distance('SEA', 'MKE', 1689).
airports_distance('SEA', 'MDW', 1728).
airports_distance('SEA', 'OMA', 1363).
airports_distance('SEA', 'PVR', 2079).
airports_distance('SEA', 'OGG', 2638).
airports_distance('SEA', 'TPE', 6058).
airports_distance('SEA', 'KIX', 5024).
airports_distance('SEA', 'KEF', 3608).
airports_distance('SEA', 'SMF', 605).
airports_distance('SEA', 'COS', 1065).
airports_distance('SEA', 'BOI', 398).
airports_distance('SEA', 'LIH', 2698).
airports_distance('SEA', 'RNO', 563).
airports_distance('SEA', 'CMH', 2010).
airports_distance('SEA', 'ICT', 1426).
airports_distance('SEA', 'BIL', 662).
airports_distance('SEA', 'CHS', 2409).
airports_distance('SEA', 'FAT', 749).
airports_distance('SEA', 'GDL', 2141).
airports_distance('SEA', 'SJD', 1816).
airports_distance('SEA', 'HDN', 889).
airports_distance('SEA', 'XMN', 6204).
airports_distance('SEA', 'BUR', 937).
airports_distance('SEA', 'KOA', 2687).
airports_distance('SEA', 'SZX', 6469).
airports_distance('SEA', 'YYJ', 97).
airports_distance('SEA', 'EUG', 234).
airports_distance('SEA', 'MFR', 351).
airports_distance('SEA', 'PSC', 171).
airports_distance('SEA', 'RDM', 228).
airports_distance('SEA', 'SBA', 908).
airports_distance('SEA', 'SBP', 848).
airports_distance('SEA', 'YLW', 219).
airports_distance('SEA', 'BLI', 93).
airports_distance('SEA', 'GEG', 223).
airports_distance('SEA', 'STS', 618).
airports_distance('SEA', 'BZN', 541).
airports_distance('SEA', 'FCA', 377).
airports_distance('SEA', 'GTF', 510).
airports_distance('SEA', 'HLN', 489).
airports_distance('SEA', 'JAC', 619).
airports_distance('SEA', 'LWS', 260).
airports_distance('SEA', 'MSO', 387).
airports_distance('SEA', 'JNU', 907).
airports_distance('SEA', 'ALW', 212).
airports_distance('SEA', 'EAT', 98).
airports_distance('SEA', 'PUW', 249).
airports_distance('SEA', 'YKM', 103).
airports_distance('SEA', 'KTN', 679).
airports_distance('SFO', 'YYZ', 2252).
airports_distance('SFO', 'YVR', 800).
airports_distance('SFO', 'LHR', 5350).
airports_distance('SFO', 'LGW', 5374).
airports_distance('SFO', 'CDG', 5565).
airports_distance('SFO', 'FRA', 5680).
airports_distance('SFO', 'HEL', 5417).
airports_distance('SFO', 'NRT', 5109).
airports_distance('SFO', 'SYD', 7420).
airports_distance('SFO', 'SIN', 8433).
airports_distance('SFO', 'MEL', 7857).
airports_distance('SFO', 'DXB', 8085).
airports_distance('SFO', 'DEL', 7688).
airports_distance('SFO', 'DUB', 5081).
airports_distance('SFO', 'HKG', 6910).
airports_distance('SFO', 'AKL', 6525).
airports_distance('SFO', 'PEK', 5895).
airports_distance('SFO', 'BNE', 7065).
airports_distance('SFO', 'PVG', 6133).
airports_distance('SFO', 'AMS', 5455).
airports_distance('SFO', 'BCN', 5952).
airports_distance('SFO', 'MAD', 5794).
airports_distance('SFO', 'ZRH', 5822).
airports_distance('SFO', 'MUC', 5860).
airports_distance('SFO', 'MAN', 5204).
airports_distance('SFO', 'YUL', 2531).
airports_distance('SFO', 'YEG', 1162).
airports_distance('SFO', 'YYC', 1017).
airports_distance('SFO', 'MNL', 6972).
airports_distance('SFO', 'HND', 5145).
airports_distance('SFO', 'ORY', 5574).
airports_distance('SFO', 'MXP', 5928).
airports_distance('SFO', 'ICN', 5641).
airports_distance('SFO', 'MEX', 1880).
airports_distance('SFO', 'TLV', 7402).
airports_distance('SFO', 'PIT', 2247).
airports_distance('SFO', 'PDX', 550).
airports_distance('SFO', 'OKC', 1379).
airports_distance('SFO', 'ONT', 363).
airports_distance('SFO', 'FAI', 2144).
airports_distance('SFO', 'IST', 6684).
airports_distance('SFO', 'AUH', 8139).
airports_distance('SFO', 'CPH', 5469).
airports_distance('SFO', 'CLT', 2289).
airports_distance('SFO', 'CUN', 2404).
airports_distance('SFO', 'PSP', 420).
airports_distance('SFO', 'CVG', 2030).
airports_distance('SFO', 'IND', 1937).
airports_distance('SFO', 'MCI', 1494).
airports_distance('SFO', 'DAL', 1472).
airports_distance('SFO', 'STL', 1730).
airports_distance('SFO', 'ABQ', 894).
airports_distance('SFO', 'MKE', 1839).
airports_distance('SFO', 'MDW', 1849).
airports_distance('SFO', 'OMA', 1429).
airports_distance('SFO', 'PVR', 1555).
airports_distance('SFO', 'OGG', 2335).
airports_distance('SFO', 'DUS', 5564).
airports_distance('SFO', 'GUM', 5801).
airports_distance('SFO', 'LIS', 5664).
airports_distance('SFO', 'TPE', 6452).
airports_distance('SFO', 'KIX', 5397).
airports_distance('SFO', 'KEF', 4190).
airports_distance('SFO', 'SMF', 86).
airports_distance('SFO', 'CAN', 6880).
airports_distance('SFO', 'COS', 961).
airports_distance('SFO', 'BOI', 522).
airports_distance('SFO', 'LIH', 2443).
airports_distance('SFO', 'RNO', 191).
airports_distance('SFO', 'CMH', 2113).
airports_distance('SFO', 'BDL', 2617).
airports_distance('SFO', 'NAN', 5462).
airports_distance('SFO', 'CTU', 6851).
airports_distance('SFO', 'DSM', 1544).
airports_distance('SFO', 'BJX', 1695).
airports_distance('SFO', 'FAT', 157).
airports_distance('SFO', 'GDL', 1642).
airports_distance('SFO', 'MLM', 1774).
airports_distance('SFO', 'MSN', 1767).
airports_distance('SFO', 'PTY', 3318).
airports_distance('SFO', 'SAL', 2639).
airports_distance('SFO', 'SJD', 1249).
airports_distance('SFO', 'XNA', 1546).
airports_distance('SFO', 'EGE', 844).
airports_distance('SFO', 'HDN', 835).
airports_distance('SFO', 'HGH', 6235).
airports_distance('SFO', 'BUR', 326).
airports_distance('SFO', 'PPT', 4200).
airports_distance('SFO', 'KOA', 2365).
airports_distance('SFO', 'WUH', 6461).
airports_distance('SFO', 'KMG', 7208).
airports_distance('SFO', 'TAO', 5942).
airports_distance('SFO', 'YYJ', 763).
airports_distance('SFO', 'ACV', 250).
airports_distance('SFO', 'BFL', 238).
airports_distance('SFO', 'CEC', 304).
airports_distance('SFO', 'CIC', 153).
airports_distance('SFO', 'EUG', 451).
airports_distance('SFO', 'LMT', 315).
airports_distance('SFO', 'MFR', 329).
airports_distance('SFO', 'MOD', 78).
airports_distance('SFO', 'MRY', 77).
airports_distance('SFO', 'OTH', 412).
airports_distance('SFO', 'PSC', 620).
airports_distance('SFO', 'RDD', 200).
airports_distance('SFO', 'RDM', 463).
airports_distance('SFO', 'SBA', 262).
airports_distance('SFO', 'SBP', 191).
airports_distance('SFO', 'ASE', 845).
airports_distance('SFO', 'GEG', 733).
airports_distance('SFO', 'MMH', 193).
airports_distance('SFO', 'STS', 66).
airports_distance('SFO', 'XIY', 6470).
airports_distance('SFO', 'BZN', 806).
airports_distance('SFO', 'FCA', 843).
airports_distance('SFO', 'JAC', 736).
airports_distance('SFO', 'MSO', 768).
airports_distance('SFO', 'MTJ', 789).
airports_distance('SFO', 'SUN', 587).
airports_distance('SFO', 'PAE', 710).
airports_distance('SFO', 'BER', 5673).
airports_distance('SJC', 'YVR', 819).
airports_distance('SJC', 'LHR', 5352).
airports_distance('SJC', 'FRA', 5684).
airports_distance('SJC', 'NRT', 5139).
airports_distance('SJC', 'PEK', 5925).
airports_distance('SJC', 'PVG', 6163).
airports_distance('SJC', 'MEX', 1850).
airports_distance('SJC', 'PDX', 569).
airports_distance('SJC', 'ONT', 333).
airports_distance('SJC', 'CLT', 2268).
airports_distance('SJC', 'CVG', 2011).
airports_distance('SJC', 'DAL', 1446).
airports_distance('SJC', 'STL', 1710).
airports_distance('SJC', 'ABQ', 867).
airports_distance('SJC', 'MDW', 1832).
airports_distance('SJC', 'TUL', 1438).
airports_distance('SJC', 'OGG', 2352).
airports_distance('SJC', 'BOI', 522).
airports_distance('SJC', 'LIH', 2462).
airports_distance('SJC', 'RNO', 188).
airports_distance('SJC', 'BJX', 1665).
airports_distance('SJC', 'GDL', 1612).
airports_distance('SJC', 'MLM', 1743).
airports_distance('SJC', 'SJD', 1219).
airports_distance('SJC', 'ZCL', 1517).
airports_distance('SJC', 'BUR', 296).
airports_distance('SJC', 'KOA', 2381).
airports_distance('SJC', 'EUG', 472).
airports_distance('SJC', 'CLD', 393).
airports_distance('SJC', 'GEG', 742).
airports_distance('SJC', 'PAE', 728).
airports_distance('TPA', 'YYZ', 1096).
airports_distance('TPA', 'LGW', 4416).
airports_distance('TPA', 'FRA', 4804).
airports_distance('TPA', 'AMS', 4600).
airports_distance('TPA', 'ZRH', 4865).
airports_distance('TPA', 'YYT', 2094).
airports_distance('TPA', 'TLH', 200).
airports_distance('TPA', 'PIT', 874).
airports_distance('TPA', 'PWM', 1277).
airports_distance('TPA', 'PDX', 2492).
airports_distance('TPA', 'ROC', 1080).
airports_distance('TPA', 'YWG', 1701).
airports_distance('TPA', 'CLT', 508).
airports_distance('TPA', 'CUN', 551).
airports_distance('TPA', 'MEM', 655).
airports_distance('TPA', 'CVG', 774).
airports_distance('TPA', 'IND', 839).
airports_distance('TPA', 'MCI', 1047).
airports_distance('TPA', 'DAL', 916).
airports_distance('TPA', 'STL', 870).
airports_distance('TPA', 'MKE', 1076).
airports_distance('TPA', 'MDW', 998).
airports_distance('TPA', 'NAS', 373).
airports_distance('TPA', 'EYW', 241).
airports_distance('TPA', 'KEF', 3590).
airports_distance('TPA', 'ORF', 717).
airports_distance('TPA', 'JAX', 181).
airports_distance('TPA', 'PVD', 1137).
airports_distance('TPA', 'COS', 1475).
airports_distance('TPA', 'BHM', 460).
airports_distance('TPA', 'SDF', 728).
airports_distance('TPA', 'BUF', 1055).
airports_distance('TPA', 'CMH', 830).
airports_distance('TPA', 'ALB', 1131).
airports_distance('TPA', 'BDL', 1112).
airports_distance('TPA', 'RIC', 724).
airports_distance('TPA', 'ISP', 1034).
airports_distance('TPA', 'HAV', 344).
airports_distance('TPA', 'CHS', 371).
airports_distance('TPA', 'DAY', 829).
airports_distance('TPA', 'GRR', 1043).
airports_distance('TPA', 'GSO', 581).
airports_distance('TPA', 'GSP', 478).
airports_distance('TPA', 'MSN', 1114).
airports_distance('TPA', 'PNS', 329).
airports_distance('TPA', 'PTY', 1321).
airports_distance('TPA', 'CAK', 896).
airports_distance('TPA', 'MHT', 1204).
airports_distance('TPA', 'SYR', 1105).
airports_distance('TPA', 'AVL', 515).
airports_distance('TPA', 'GNV', 119).
airports_distance('TPA', 'GCM', 604).
airports_distance('TPA', 'ACY', 914).
airports_distance('TPA', 'FNT', 1037).
airports_distance('TPA', 'TTN', 956).
airports_distance('TPA', 'LBE', 868).
airports_distance('TPA', 'YHM', 1059).
airports_distance('SAN', 'YYZ', 2152).
airports_distance('SAN', 'YVR', 1178).
airports_distance('SAN', 'LHR', 5469).
airports_distance('SAN', 'FRA', 5823).
airports_distance('SAN', 'NRT', 5542).
airports_distance('SAN', 'ZRH', 5952).
airports_distance('SAN', 'YYC', 1279).
airports_distance('SAN', 'MEX', 1447).
airports_distance('SAN', 'PIT', 2101).
airports_distance('SAN', 'PDX', 933).
airports_distance('SAN', 'OKC', 1133).
airports_distance('SAN', 'CLT', 2071).
airports_distance('SAN', 'CVG', 1860).
airports_distance('SAN', 'IND', 1777).
airports_distance('SAN', 'MCI', 1330).
airports_distance('SAN', 'DAL', 1179).
airports_distance('SAN', 'STL', 1553).
airports_distance('SAN', 'ABQ', 627).
airports_distance('SAN', 'MKE', 1734).
airports_distance('SAN', 'MDW', 1724).
airports_distance('SAN', 'OMA', 1310).
airports_distance('SAN', 'PVR', 1109).
airports_distance('SAN', 'OGG', 2536).
airports_distance('SAN', 'PVD', 2560).
airports_distance('SAN', 'SMF', 480).
airports_distance('SAN', 'COS', 815).
airports_distance('SAN', 'SDF', 1799).
airports_distance('SAN', 'BOI', 750).
airports_distance('SAN', 'LIH', 2670).
airports_distance('SAN', 'RNO', 489).
airports_distance('SAN', 'FAT', 314).
airports_distance('SAN', 'SJD', 803).
airports_distance('SAN', 'HDN', 768).
airports_distance('SAN', 'KOA', 2551).
airports_distance('SAN', 'EUG', 851).
airports_distance('SAN', 'MRY', 375).
airports_distance('SAN', 'BLI', 1143).
airports_distance('SAN', 'GEG', 1028).
airports_distance('SAN', 'MMH', 350).
airports_distance('SAN', 'STS', 508).
airports_distance('SAN', 'PVU', 599).
airports_distance('SAN', 'IPL', 94).
airports_distance('SAN', 'SCK', 423).
airports_distance('SAN', 'PAE', 1081).
airports_distance('LGB', 'PDX', 846).
airports_distance('LGB', 'SMF', 387).
airports_distance('LGB', 'RNO', 402).
airports_distance('LGB', 'BZN', 905).
airports_distance('SNA', 'YVR', 1106).
airports_distance('SNA', 'MEX', 1516).
airports_distance('SNA', 'PDX', 860).
airports_distance('SNA', 'MCI', 1338).
airports_distance('SNA', 'DAL', 1213).
airports_distance('SNA', 'STL', 1565).
airports_distance('SNA', 'ABQ', 648).
airports_distance('SNA', 'MDW', 1727).
airports_distance('SNA', 'PVR', 1183).
airports_distance('SNA', 'SMF', 404).
airports_distance('SNA', 'RNO', 416).
airports_distance('SNA', 'ISP', 2482).
airports_distance('SNA', 'GDL', 1272).
airports_distance('SNA', 'SJD', 878).
airports_distance('SNA', 'STS', 433).
airports_distance('SNA', 'PAE', 1009).
airports_distance('SLC', 'YYZ', 1655).
airports_distance('SLC', 'YVR', 796).
airports_distance('SLC', 'LHR', 4850).
airports_distance('SLC', 'CDG', 5063).
airports_distance('SLC', 'AMS', 4973).
airports_distance('SLC', 'RSW', 1982).
airports_distance('SLC', 'YYC', 720).
airports_distance('SLC', 'MEX', 1659).
airports_distance('SLC', 'PIT', 1654).
airports_distance('SLC', 'PDX', 628).
airports_distance('SLC', 'OKC', 864).
airports_distance('SLC', 'ONT', 558).
airports_distance('SLC', 'CLT', 1722).
airports_distance('SLC', 'CUN', 2004).
airports_distance('SLC', 'PSP', 541).
airports_distance('SLC', 'MEM', 1258).
airports_distance('SLC', 'CVG', 1445).
airports_distance('SLC', 'IND', 1351).
airports_distance('SLC', 'MCI', 917).
airports_distance('SLC', 'DAL', 998).
airports_distance('SLC', 'STL', 1152).
airports_distance('SLC', 'ABQ', 493).
airports_distance('SLC', 'MKE', 1243).
airports_distance('SLC', 'MDW', 1255).
airports_distance('SLC', 'OMA', 837).
airports_distance('SLC', 'TUL', 924).
airports_distance('SLC', 'PVR', 1443).
airports_distance('SLC', 'OGG', 2931).
airports_distance('SLC', 'PVD', 2086).
airports_distance('SLC', 'SMF', 530).
airports_distance('SLC', 'COS', 409).
airports_distance('SLC', 'RAP', 507).
airports_distance('SLC', 'BOI', 290).
airports_distance('SLC', 'RNO', 421).
airports_distance('SLC', 'IDA', 188).
airports_distance('SLC', 'BIL', 387).
airports_distance('SLC', 'FAR', 863).
airports_distance('SLC', 'FAT', 500).
airports_distance('SLC', 'GDL', 1489).
airports_distance('SLC', 'GJT', 216).
airports_distance('SLC', 'MSN', 1170).
airports_distance('SLC', 'SJD', 1225).
airports_distance('SLC', 'BUR', 573).
airports_distance('SLC', 'EUG', 616).
airports_distance('SLC', 'MFR', 573).
airports_distance('SLC', 'PSC', 520).
airports_distance('SLC', 'RDM', 524).
airports_distance('SLC', 'SBA', 614).
airports_distance('SLC', 'ASE', 291).
airports_distance('SLC', 'GEG', 546).
airports_distance('SLC', 'BTM', 358).
airports_distance('SLC', 'BZN', 347).
airports_distance('SLC', 'CDC', 221).
airports_distance('SLC', 'CNY', 183).
airports_distance('SLC', 'COD', 298).
airports_distance('SLC', 'CPR', 319).
airports_distance('SLC', 'EKO', 199).
airports_distance('SLC', 'GCC', 409).
airports_distance('SLC', 'FCA', 531).
airports_distance('SLC', 'GTF', 463).
airports_distance('SLC', 'HLN', 402).
airports_distance('SLC', 'JAC', 205).
airports_distance('SLC', 'LWS', 460).
airports_distance('SLC', 'MSO', 436).
airports_distance('SLC', 'PIH', 150).
airports_distance('SLC', 'RKS', 161).
airports_distance('SLC', 'SGU', 272).
airports_distance('SLC', 'TWF', 174).
airports_distance('SLC', 'VEL', 132).
airports_distance('LAS', 'YYZ', 1938).
airports_distance('LAS', 'YVR', 992).
airports_distance('LAS', 'LHR', 5213).
airports_distance('LAS', 'LGW', 5236).
airports_distance('LAS', 'FRA', 5565).
airports_distance('LAS', 'NRT', 5496).
airports_distance('LAS', 'PEK', 6229).
airports_distance('LAS', 'AMS', 5338).
airports_distance('LAS', 'ZRH', 5695).
airports_distance('LAS', 'MUC', 5749).
airports_distance('LAS', 'RSW', 2065).
airports_distance('LAS', 'MAN', 5071).
airports_distance('LAS', 'YUL', 2233).
airports_distance('LAS', 'YEG', 1192).
airports_distance('LAS', 'CGN', 5481).
airports_distance('LAS', 'OSL', 5118).
airports_distance('LAS', 'ARN', 5299).
airports_distance('LAS', 'YYC', 1040).
airports_distance('LAS', 'ICN', 6004).
airports_distance('LAS', 'GRU', 6074).
airports_distance('LAS', 'MEX', 1507).
airports_distance('LAS', 'PIT', 1904).
airports_distance('LAS', 'PDX', 762).
airports_distance('LAS', 'OKC', 983).
airports_distance('LAS', 'ONT', 197).
airports_distance('LAS', 'YWG', 1309).
airports_distance('LAS', 'CPH', 5392).
airports_distance('LAS', 'CLT', 1910).
airports_distance('LAS', 'CUN', 1993).
airports_distance('LAS', 'PSP', 173).
airports_distance('LAS', 'MEM', 1412).
airports_distance('LAS', 'CVG', 1673).
airports_distance('LAS', 'IND', 1585).
airports_distance('LAS', 'MCI', 1136).
airports_distance('LAS', 'DAL', 1064).
airports_distance('LAS', 'STL', 1367).
airports_distance('LAS', 'ABQ', 485).
airports_distance('LAS', 'MKE', 1519).
airports_distance('LAS', 'MDW', 1516).
airports_distance('LAS', 'OMA', 1096).
airports_distance('LAS', 'TUL', 1072).
airports_distance('LAS', 'LIT', 1291).
airports_distance('LAS', 'ORF', 2148).
airports_distance('LAS', 'JAX', 1960).
airports_distance('LAS', 'PVD', 2356).
airports_distance('LAS', 'SMF', 397).
airports_distance('LAS', 'COS', 603).
airports_distance('LAS', 'BHM', 1613).
airports_distance('LAS', 'RAP', 842).
airports_distance('LAS', 'SDF', 1619).
airports_distance('LAS', 'BUF', 1980).
airports_distance('LAS', 'SHV', 1240).
airports_distance('LAS', 'BOI', 520).
airports_distance('LAS', 'LBB', 773).
airports_distance('LAS', 'RNO', 345).
airports_distance('LAS', 'CMH', 1765).
airports_distance('LAS', 'IDA', 539).
airports_distance('LAS', 'ALB', 2230).
airports_distance('LAS', 'ICT', 983).
airports_distance('LAS', 'MAF', 794).
airports_distance('LAS', 'YXE', 1185).
airports_distance('LAS', 'BDL', 2290).
airports_distance('LAS', 'BIL', 754).
airports_distance('LAS', 'SGF', 1205).
airports_distance('LAS', 'PIA', 1409).
airports_distance('LAS', 'DSM', 1212).
airports_distance('LAS', 'MTY', 1138).
airports_distance('LAS', 'AMA', 756).
airports_distance('LAS', 'FAR', 1203).
airports_distance('LAS', 'FAT', 258).
airports_distance('LAS', 'FSD', 1102).
airports_distance('LAS', 'GDL', 1291).
airports_distance('LAS', 'GJT', 419).
airports_distance('LAS', 'GRI', 968).
airports_distance('LAS', 'GRR', 1638).
airports_distance('LAS', 'GSP', 1844).
airports_distance('LAS', 'LRD', 1091).
airports_distance('LAS', 'MFE', 1208).
airports_distance('LAS', 'MLI', 1372).
airports_distance('LAS', 'PTY', 2916).
airports_distance('LAS', 'SJD', 950).
airports_distance('LAS', 'TYS', 1734).
airports_distance('LAS', 'VPS', 1690).
airports_distance('LAS', 'XNA', 1160).
airports_distance('LAS', 'CAK', 1840).
airports_distance('LAS', 'YQR', 1120).
airports_distance('LAS', 'BUR', 223).
airports_distance('LAS', 'ATW', 1506).
airports_distance('LAS', 'FNT', 1728).
airports_distance('LAS', 'SBN', 1589).
airports_distance('LAS', 'YXU', 1859).
airports_distance('LAS', 'YYJ', 964).
airports_distance('LAS', 'EUG', 699).
airports_distance('LAS', 'MFR', 599).
airports_distance('LAS', 'MRY', 374).
airports_distance('LAS', 'PSC', 733).
airports_distance('LAS', 'RDM', 647).
airports_distance('LAS', 'SBA', 288).
airports_distance('LAS', 'SBP', 313).
airports_distance('LAS', 'BLI', 954).
airports_distance('LAS', 'CLD', 237).
airports_distance('LAS', 'GEG', 806).
airports_distance('LAS', 'SMX', 309).
airports_distance('LAS', 'STS', 453).
airports_distance('LAS', 'BZN', 701).
airports_distance('LAS', 'CPR', 660).
airports_distance('LAS', 'FCA', 846).
airports_distance('LAS', 'GTF', 811).
airports_distance('LAS', 'MSO', 750).
airports_distance('LAS', 'BIS', 1046).
airports_distance('LAS', 'MOT', 1097).
airports_distance('LAS', 'DLH', 1393).
airports_distance('LAS', 'TLC', 1494).
airports_distance('LAS', 'GFK', 1228).
airports_distance('LAS', 'AZA', 276).
airports_distance('LAS', 'RFD', 1451).
airports_distance('LAS', 'SCK', 358).
airports_distance('LAS', 'YHM', 1920).
airports_distance('LAS', 'BLV', 1396).
airports_distance('LAS', 'OGD', 392).
airports_distance('LAS', 'PAE', 894).
airports_distance('DEN', 'YYZ', 1311).
airports_distance('DEN', 'YVR', 1111).
airports_distance('DEN', 'LHR', 4655).
airports_distance('DEN', 'LGW', 4678).
airports_distance('DEN', 'CDG', 4864).
airports_distance('DEN', 'FRA', 5022).
airports_distance('DEN', 'NRT', 5770).
airports_distance('DEN', 'ZRH', 5142).
airports_distance('DEN', 'MUC', 5208).
airports_distance('DEN', 'RSW', 1605).
airports_distance('DEN', 'YUL', 1607).
airports_distance('DEN', 'YEG', 1018).
airports_distance('DEN', 'YYC', 897).
airports_distance('DEN', 'MEX', 1449).
airports_distance('DEN', 'PIT', 1286).
airports_distance('DEN', 'PWM', 1776).
airports_distance('DEN', 'PDX', 989).
airports_distance('DEN', 'OKC', 494).
airports_distance('DEN', 'ONT', 817).
airports_distance('DEN', 'YWG', 782).
airports_distance('DEN', 'CLT', 1334).
airports_distance('DEN', 'CUN', 1670).
airports_distance('DEN', 'PSP', 774).
airports_distance('DEN', 'MEM', 870).
airports_distance('DEN', 'CVG', 1066).
airports_distance('DEN', 'IND', 973).
airports_distance('DEN', 'MCI', 531).
airports_distance('DEN', 'DAL', 650).
airports_distance('DEN', 'STL', 767).
airports_distance('DEN', 'ABQ', 349).
airports_distance('DEN', 'MKE', 893).
airports_distance('DEN', 'MDW', 892).
airports_distance('DEN', 'SLN', 382).
airports_distance('DEN', 'OMA', 471).
airports_distance('DEN', 'TUL', 540).
airports_distance('DEN', 'PVR', 1325).
airports_distance('DEN', 'OGG', 3296).
airports_distance('DEN', 'KEF', 3556).
airports_distance('DEN', 'LIT', 769).
airports_distance('DEN', 'ORF', 1548).
airports_distance('DEN', 'JAX', 1444).
airports_distance('DEN', 'PVD', 1732).
airports_distance('DEN', 'MDT', 1470).
airports_distance('DEN', 'SJO', 2414).
airports_distance('DEN', 'SMF', 906).
airports_distance('DEN', 'COS', 73).
airports_distance('DEN', 'HSV', 1045).
airports_distance('DEN', 'BHM', 1080).
airports_distance('DEN', 'RAP', 301).
airports_distance('DEN', 'SDF', 1021).
airports_distance('DEN', 'BUF', 1355).
airports_distance('DEN', 'SHV', 791).
airports_distance('DEN', 'BOI', 647).
airports_distance('DEN', 'LIH', 3407).
airports_distance('DEN', 'LBB', 456).
airports_distance('DEN', 'HRL', 1024).
airports_distance('DEN', 'RNO', 802).
airports_distance('DEN', 'CMH', 1150).
airports_distance('DEN', 'IDA', 457).
airports_distance('DEN', 'ICT', 419).
airports_distance('DEN', 'MAF', 564).
airports_distance('DEN', 'YXE', 855).
airports_distance('DEN', 'BDL', 1666).
airports_distance('DEN', 'BIL', 455).
airports_distance('DEN', 'SGF', 635).
airports_distance('DEN', 'RIC', 1477).
airports_distance('DEN', 'PIA', 790).
airports_distance('DEN', 'BMI', 831).
airports_distance('DEN', 'DSM', 587).
airports_distance('DEN', 'MYR', 1481).
airports_distance('DEN', 'CZM', 1697).
airports_distance('DEN', 'MTY', 1007).
airports_distance('DEN', 'AMA', 359).
airports_distance('DEN', 'BZE', 1825).
airports_distance('DEN', 'CHS', 1446).
airports_distance('DEN', 'COU', 668).
airports_distance('DEN', 'DAY', 1081).
airports_distance('DEN', 'DRO', 250).
airports_distance('DEN', 'FAR', 626).
airports_distance('DEN', 'FAT', 841).
airports_distance('DEN', 'FSD', 482).
airports_distance('DEN', 'GDL', 1338).
airports_distance('DEN', 'GJT', 212).
airports_distance('DEN', 'GRR', 1012).
airports_distance('DEN', 'GSO', 1366).
airports_distance('DEN', 'GSP', 1275).
airports_distance('DEN', 'JAN', 965).
airports_distance('DEN', 'LFT', 977).
airports_distance('DEN', 'LIR', 2336).
airports_distance('DEN', 'MLI', 749).
airports_distance('DEN', 'MSN', 823).
airports_distance('DEN', 'PNS', 1177).
airports_distance('DEN', 'PTY', 2634).
airports_distance('DEN', 'SAV', 1410).
airports_distance('DEN', 'SJD', 1191).
airports_distance('DEN', 'TYS', 1159).
airports_distance('DEN', 'VPS', 1208).
airports_distance('DEN', 'XNA', 615).
airports_distance('DEN', 'CAK', 1220).
airports_distance('DEN', 'SYR', 1487).
airports_distance('DEN', 'YQR', 730).
airports_distance('DEN', 'AVL', 1244).
airports_distance('DEN', 'EGE', 120).
airports_distance('DEN', 'HDN', 141).
airports_distance('DEN', 'GRB', 903).
airports_distance('DEN', 'BTV', 1634).
airports_distance('DEN', 'GCM', 1982).
airports_distance('DEN', 'BUR', 848).
airports_distance('DEN', 'ATW', 880).
airports_distance('DEN', 'PHF', 1528).
airports_distance('DEN', 'KOA', 3323).
airports_distance('DEN', 'ACV', 1022).
airports_distance('DEN', 'BFL', 842).
airports_distance('DEN', 'EUG', 993).
airports_distance('DEN', 'MFR', 961).
airports_distance('DEN', 'MRY', 957).
airports_distance('DEN', 'PSC', 850).
airports_distance('DEN', 'RDM', 896).
airports_distance('DEN', 'SBA', 914).
airports_distance('DEN', 'SBP', 929).
airports_distance('DEN', 'ASE', 125).
airports_distance('DEN', 'BLI', 1072).
airports_distance('DEN', 'GEG', 834).
airports_distance('DEN', 'MMH', 777).
airports_distance('DEN', 'PRC', 557).
airports_distance('DEN', 'STS', 974).
airports_distance('DEN', 'BZN', 524).
airports_distance('DEN', 'CNY', 282).
airports_distance('DEN', 'COD', 391).
airports_distance('DEN', 'CPR', 230).
airports_distance('DEN', 'GCC', 313).
airports_distance('DEN', 'FCA', 751).
airports_distance('DEN', 'GTF', 623).
airports_distance('DEN', 'HLN', 593).
airports_distance('DEN', 'JAC', 405).
airports_distance('DEN', 'MSO', 678).
airports_distance('DEN', 'RKS', 259).
airports_distance('DEN', 'SGU', 516).
airports_distance('DEN', 'VEL', 258).
airports_distance('DEN', 'BKG', 663).
airports_distance('DEN', 'YMM', 1197).
airports_distance('DEN', 'AIA', 180).
airports_distance('DEN', 'ALS', 179).
airports_distance('DEN', 'BFF', 150).
airports_distance('DEN', 'BIS', 516).
airports_distance('DEN', 'CEZ', 277).
airports_distance('DEN', 'CYS', 90).
airports_distance('DEN', 'DDC', 292).
airports_distance('DEN', 'DIK', 488).
airports_distance('DEN', 'EAR', 304).
airports_distance('DEN', 'FMN', 289).
airports_distance('DEN', 'GUC', 152).
airports_distance('DEN', 'ISN', 576).
airports_distance('DEN', 'LAR', 113).
airports_distance('DEN', 'LBF', 227).
airports_distance('DEN', 'LBL', 280).
airports_distance('DEN', 'LNK', 422).
airports_distance('DEN', 'MCK', 217).
airports_distance('DEN', 'MOT', 604).
airports_distance('DEN', 'MTJ', 196).
airports_distance('DEN', 'PGA', 419).
airports_distance('DEN', 'PIR', 384).
airports_distance('DEN', 'PUB', 109).
airports_distance('DEN', 'RIW', 295).
airports_distance('DEN', 'SHR', 359).
airports_distance('DEN', 'FLG', 503).
airports_distance('DEN', 'CDR', 221).
airports_distance('DEN', 'SUN', 556).
airports_distance('DEN', 'JMS', 573).
airports_distance('DEN', 'HYS', 297).
airports_distance('DEN', 'TEX', 218).
airports_distance('DEN', 'PAE', 1034).
airports_distance('DEN', 'BFM', 1130).
airports_distance('DEN', 'XWA', 582).
airports_distance('HPN', 'RSW', 1103).
airports_distance('HPN', 'CLT', 563).
airports_distance('HPN', 'MYR', 585).
airports_distance('HPN', 'ACK', 190).
airports_distance('HPN', 'LEB', 191).
airports_distance('HPN', 'MVY', 162).
airports_distance('HPN', 'EWB', 149).
airports_distance('SAT', 'YYZ', 1423).
airports_distance('SAT', 'MEX', 698).
airports_distance('SAT', 'PDX', 1712).
airports_distance('SAT', 'OKC', 408).
airports_distance('SAT', 'ONT', 1163).
airports_distance('SAT', 'CLT', 1093).
airports_distance('SAT', 'CUN', 931).
airports_distance('SAT', 'MEM', 624).
airports_distance('SAT', 'CVG', 1023).
airports_distance('SAT', 'MCI', 707).
airports_distance('SAT', 'DAL', 248).
airports_distance('SAT', 'STL', 786).
airports_distance('SAT', 'ABQ', 608).
airports_distance('SAT', 'MDW', 1036).
airports_distance('SAT', 'OMA', 825).
airports_distance('SAT', 'TUL', 484).
airports_distance('SAT', 'JAX', 1005).
airports_distance('SAT', 'COS', 732).
airports_distance('SAT', 'HRL', 234).
airports_distance('SAT', 'CMH', 1138).
airports_distance('SAT', 'CRP', 135).
airports_distance('SAT', 'MTY', 278).
airports_distance('SAT', 'GDL', 692).
airports_distance('SAT', 'SFB', 1039).
airports_distance('SAT', 'TLC', 707).
airports_distance('MSY', 'YYZ', 1110).
airports_distance('MSY', 'LHR', 4616).
airports_distance('MSY', 'FRA', 5017).
airports_distance('MSY', 'PIT', 918).
airports_distance('MSY', 'CLT', 650).
airports_distance('MSY', 'CUN', 653).
airports_distance('MSY', 'MEM', 349).
airports_distance('MSY', 'CVG', 701).
airports_distance('MSY', 'IND', 708).
airports_distance('MSY', 'MCI', 690).
airports_distance('MSY', 'DAL', 435).
airports_distance('MSY', 'STL', 605).
airports_distance('MSY', 'MKE', 904).
airports_distance('MSY', 'MDW', 826).
airports_distance('MSY', 'TUL', 538).
airports_distance('MSY', 'EYW', 642).
airports_distance('MSY', 'LIT', 346).
airports_distance('MSY', 'JAX', 512).
airports_distance('MSY', 'PVD', 1325).
airports_distance('MSY', 'HSV', 380).
airports_distance('MSY', 'SHV', 270).
airports_distance('MSY', 'CMH', 806).
airports_distance('MSY', 'ISP', 1216).
airports_distance('MSY', 'GRR', 927).
airports_distance('MSY', 'PTY', 1606).
airports_distance('MSY', 'SFB', 549).
airports_distance('MSY', 'SAP', 1015).
airports_distance('MSY', 'ACY', 1101).
airports_distance('MSY', 'PIE', 479).
airports_distance('MSY', 'USA', 668).
airports_distance('EWR', 'YYZ', 347).
airports_distance('EWR', 'YVR', 2421).
airports_distance('EWR', 'LHR', 3453).
airports_distance('EWR', 'CDG', 3637).
airports_distance('EWR', 'FRA', 3856).
airports_distance('EWR', 'NRT', 6712).
airports_distance('EWR', 'SIN', 9523).
airports_distance('EWR', 'DEL', 7305).
airports_distance('EWR', 'DUB', 3182).
airports_distance('EWR', 'HKG', 8047).
airports_distance('EWR', 'PEK', 6810).
airports_distance('EWR', 'PVG', 7364).
airports_distance('EWR', 'FCO', 4279).
airports_distance('EWR', 'BOM', 7790).
airports_distance('EWR', 'AMS', 3644).
airports_distance('EWR', 'PRG', 4081).
airports_distance('EWR', 'BCN', 3835).
airports_distance('EWR', 'MAD', 3594).
airports_distance('EWR', 'VIE', 4239).
airports_distance('EWR', 'ZRH', 3932).
airports_distance('EWR', 'GVA', 3865).
airports_distance('EWR', 'YOW', 329).
airports_distance('EWR', 'BRU', 3668).
airports_distance('EWR', 'MUC', 4038).
airports_distance('EWR', 'RSW', 1069).
airports_distance('EWR', 'MAN', 3343).
airports_distance('EWR', 'YUL', 331).
airports_distance('EWR', 'YEG', 2017).
airports_distance('EWR', 'SNN', 3085).
airports_distance('EWR', 'OSL', 3684).
airports_distance('EWR', 'ARN', 3916).
airports_distance('EWR', 'STN', 3473).
airports_distance('EWR', 'EDI', 3257).
airports_distance('EWR', 'GLA', 3218).
airports_distance('EWR', 'YYC', 2016).
airports_distance('EWR', 'ORY', 3636).
airports_distance('EWR', 'NCE', 3994).
airports_distance('EWR', 'MXP', 3997).
airports_distance('EWR', 'ATH', 4940).
airports_distance('EWR', 'YYT', 1159).
airports_distance('EWR', 'CPT', 7819).
airports_distance('EWR', 'GRU', 4771).
airports_distance('EWR', 'EZE', 5308).
airports_distance('EWR', 'LIM', 3645).
airports_distance('EWR', 'MEX', 2076).
airports_distance('EWR', 'WAW', 4264).
airports_distance('EWR', 'ADD', 6972).
airports_distance('EWR', 'TLV', 5676).
airports_distance('EWR', 'PIT', 318).
airports_distance('EWR', 'PWM', 284).
airports_distance('EWR', 'PDX', 2426).
airports_distance('EWR', 'OKC', 1321).
airports_distance('EWR', 'ROC', 246).
airports_distance('EWR', 'YHZ', 612).
airports_distance('EWR', 'HAM', 3811).
airports_distance('EWR', 'STR', 3923).
airports_distance('EWR', 'NAP', 4402).
airports_distance('EWR', 'CPH', 3854).
airports_distance('EWR', 'CLT', 528).
airports_distance('EWR', 'CUN', 1548).
airports_distance('EWR', 'PSP', 2351).
airports_distance('EWR', 'MEM', 944).
airports_distance('EWR', 'CVG', 567).
airports_distance('EWR', 'IND', 642).
airports_distance('EWR', 'MCI', 1089).
airports_distance('EWR', 'STL', 870).
airports_distance('EWR', 'MKE', 722).
airports_distance('EWR', 'MDW', 709).
airports_distance('EWR', 'OMA', 1130).
airports_distance('EWR', 'TUL', 1211).
airports_distance('EWR', 'PVR', 2285).
airports_distance('EWR', 'DUS', 3749).
airports_distance('EWR', 'LIS', 3374).
airports_distance('EWR', 'NAS', 1097).
airports_distance('EWR', 'FPO', 1010).
airports_distance('EWR', 'EYW', 1197).
airports_distance('EWR', 'KEF', 2594).
airports_distance('EWR', 'ANU', 1786).
airports_distance('EWR', 'STT', 1637).
airports_distance('EWR', 'BDA', 779).
airports_distance('EWR', 'POS', 2220).
airports_distance('EWR', 'MBJ', 1548).
airports_distance('EWR', 'BON', 2004).
airports_distance('EWR', 'AUA', 1963).
airports_distance('EWR', 'ORF', 284).
airports_distance('EWR', 'JAX', 820).
airports_distance('EWR', 'PVD', 160).
airports_distance('EWR', 'PUJ', 1566).
airports_distance('EWR', 'SJO', 2207).
airports_distance('EWR', 'SMF', 2492).
airports_distance('EWR', 'YQB', 443).
airports_distance('EWR', 'RAP', 1484).
airports_distance('EWR', 'SDF', 640).
airports_distance('EWR', 'BUF', 281).
airports_distance('EWR', 'CMH', 461).
airports_distance('EWR', 'ALB', 143).
airports_distance('EWR', 'BDL', 115).
airports_distance('EWR', 'SXM', 1696).
airports_distance('EWR', 'RIC', 277).
airports_distance('EWR', 'LEX', 586).
airports_distance('EWR', 'GUA', 2054).
airports_distance('EWR', 'HAV', 1313).
airports_distance('EWR', 'OPO', 3329).
airports_distance('EWR', 'BOG', 2485).
airports_distance('EWR', 'DSM', 1014).
airports_distance('EWR', 'MYR', 550).
airports_distance('EWR', 'BZE', 1806).
airports_distance('EWR', 'CHA', 716).
airports_distance('EWR', 'CHS', 628).
airports_distance('EWR', 'DAY', 532).
airports_distance('EWR', 'FWA', 576).
airports_distance('EWR', 'GRR', 603).
airports_distance('EWR', 'GSO', 445).
airports_distance('EWR', 'GSP', 594).
airports_distance('EWR', 'LIR', 2191).
airports_distance('EWR', 'MSN', 796).
airports_distance('EWR', 'PLS', 1311).
airports_distance('EWR', 'PNS', 1014).
airports_distance('EWR', 'PTY', 2207).
airports_distance('EWR', 'SAL', 2085).
airports_distance('EWR', 'SAV', 708).
airports_distance('EWR', 'SJD', 2386).
airports_distance('EWR', 'TYS', 630).
airports_distance('EWR', 'VPS', 987).
airports_distance('EWR', 'XNA', 1127).
airports_distance('EWR', 'UVF', 2025).
airports_distance('EWR', 'CAK', 380).
airports_distance('EWR', 'MHT', 209).
airports_distance('EWR', 'SYR', 194).
airports_distance('EWR', 'AVL', 582).
airports_distance('EWR', 'EGE', 1719).
airports_distance('EWR', 'SRQ', 1035).
airports_distance('EWR', 'BHX', 3381).
airports_distance('EWR', 'BFS', 3166).
airports_distance('EWR', 'BGR', 392).
airports_distance('EWR', 'BTV', 266).
airports_distance('EWR', 'HHH', 687).
airports_distance('EWR', 'POP', 1461).
airports_distance('EWR', 'BQN', 1588).
airports_distance('EWR', 'APF', 1094).
airports_distance('EWR', 'SDQ', 1560).
airports_distance('EWR', 'STI', 1485).
airports_distance('EWR', 'SAP', 1928).
airports_distance('EWR', 'GCM', 1537).
airports_distance('EWR', 'SKB', 1752).
airports_distance('EWR', 'AVP', 92).
airports_distance('EWR', 'FNT', 517).
airports_distance('EWR', 'SBN', 634).
airports_distance('EWR', 'RZE', 4377).
airports_distance('EWR', 'ABJ', 4946).
airports_distance('EWR', 'LFW', 5175).
airports_distance('EWR', 'BZN', 1876).
airports_distance('EWR', 'JAC', 1868).
airports_distance('EWR', 'ELM', 174).
airports_distance('EWR', 'YQM', 605).
airports_distance('EWR', 'YTZ', 336).
airports_distance('EWR', 'ITH', 171).
airports_distance('EWR', 'BHB', 393).
airports_distance('EWR', 'PQI', 514).
airports_distance('EWR', 'VRB', 968).
airports_distance('EWR', 'BER', 3980).
airports_distance('CID', 'CLT', 741).
airports_distance('CID', 'SFB', 1078).
airports_distance('CID', 'AZA', 1237).
airports_distance('CID', 'PIE', 1090).
airports_distance('CID', 'PGD', 1170).
airports_distance('HNL', 'YYZ', 4639).
airports_distance('HNL', 'YVR', 2703).
airports_distance('HNL', 'NRT', 3810).
airports_distance('HNL', 'SYD', 5073).
airports_distance('HNL', 'SIN', 6699).
airports_distance('HNL', 'MEL', 5511).
airports_distance('HNL', 'AKL', 4402).
airports_distance('HNL', 'PEK', 5050).
airports_distance('HNL', 'BNE', 4690).
airports_distance('HNL', 'PVG', 4914).
airports_distance('HNL', 'KUL', 6810).
airports_distance('HNL', 'HND', 3845).
airports_distance('HNL', 'ICN', 4566).
airports_distance('HNL', 'PDX', 2601).
airports_distance('HNL', 'OGG', 100).
airports_distance('HNL', 'GUM', 3793).
airports_distance('HNL', 'TPE', 5057).
airports_distance('HNL', 'FUK', 4386).
airports_distance('HNL', 'KIX', 4107).
airports_distance('HNL', 'CTS', 3743).
airports_distance('HNL', 'SMF', 2459).
airports_distance('HNL', 'LIH', 102).
airports_distance('HNL', 'NAN', 3171).
airports_distance('HNL', 'ITO', 216).
airports_distance('HNL', 'NGO', 4016).
airports_distance('HNL', 'PPT', 2742).
airports_distance('HNL', 'LNY', 73).
airports_distance('HNL', 'KOA', 163).
airports_distance('HNL', 'APW', 2608).
airports_distance('HNL', 'PPG', 2610).
airports_distance('HNL', 'MAJ', 2278).
airports_distance('HNL', 'CXI', 1335).
airports_distance('HNL', 'JHM', 84).
airports_distance('HNL', 'MKK', 54).
airports_distance('HNL', 'BLI', 2713).
airports_distance('HOU', 'MEX', 744).
airports_distance('HOU', 'PIT', 1130).
airports_distance('HOU', 'OKC', 419).
airports_distance('HOU', 'CLT', 918).
airports_distance('HOU', 'CUN', 792).
airports_distance('HOU', 'MEM', 484).
airports_distance('HOU', 'IND', 861).
airports_distance('HOU', 'MCI', 667).
airports_distance('HOU', 'DAL', 240).
airports_distance('HOU', 'STL', 688).
airports_distance('HOU', 'ABQ', 758).
airports_distance('HOU', 'MDW', 937).
airports_distance('HOU', 'OMA', 806).
airports_distance('HOU', 'TUL', 454).
airports_distance('HOU', 'PVR', 878).
airports_distance('HOU', 'MBJ', 1335).
airports_distance('HOU', 'LIT', 394).
airports_distance('HOU', 'JAX', 814).
airports_distance('HOU', 'SJO', 1533).
airports_distance('HOU', 'SMF', 1620).
airports_distance('HOU', 'BHM', 569).
airports_distance('HOU', 'SDF', 803).
airports_distance('HOU', 'LBB', 474).
airports_distance('HOU', 'ECP', 569).
airports_distance('HOU', 'HRL', 277).
airports_distance('HOU', 'CMH', 1000).
airports_distance('HOU', 'MAF', 440).
airports_distance('HOU', 'CRP', 187).
airports_distance('HOU', 'AMA', 537).
airports_distance('HOU', 'BZE', 944).
airports_distance('HOU', 'CHS', 926).
airports_distance('HOU', 'GSP', 843).
airports_distance('HOU', 'JAN', 359).
airports_distance('HOU', 'LIR', 1457).
airports_distance('HOU', 'PNS', 487).
airports_distance('HOU', 'SJD', 998).
airports_distance('HOU', 'GCM', 1128).
airports_distance('HOU', 'BUR', 1385).
airports_distance('HOU', 'BKG', 490).
airports_distance('ELP', 'DAL', 560).
airports_distance('ELP', 'SFB', 1510).
airports_distance('SJU', 'YYZ', 1914).
airports_distance('SJU', 'FRA', 4565).
airports_distance('SJU', 'MAD', 3961).
airports_distance('SJU', 'RSW', 1148).
airports_distance('SJU', 'YUL', 1918).
airports_distance('SJU', 'PIT', 1741).
airports_distance('SJU', 'CLT', 1476).
airports_distance('SJU', 'CUN', 1367).
airports_distance('SJU', 'CVG', 1809).
airports_distance('SJU', 'ANU', 291).
airports_distance('SJU', 'STT', 68).
airports_distance('SJU', 'JAX', 1288).
airports_distance('SJU', 'PUJ', 155).
airports_distance('SJU', 'BDL', 1669).
airports_distance('SJU', 'SXM', 192).
airports_distance('SJU', 'CCS', 545).
airports_distance('SJU', 'ISP', 1600).
airports_distance('SJU', 'BOG', 1096).
airports_distance('SJU', 'PLS', 467).
airports_distance('SJU', 'PTY', 1105).
airports_distance('SJU', 'SFB', 1197).
airports_distance('SJU', 'POP', 312).
airports_distance('SJU', 'LRM', 191).
airports_distance('SJU', 'SDQ', 240).
airports_distance('SJU', 'STI', 308).
airports_distance('SJU', 'FDF', 424).
airports_distance('SJU', 'PTP', 331).
airports_distance('SJU', 'STX', 94).
airports_distance('SJU', 'SKB', 229).
airports_distance('SJU', 'AZS', 251).
airports_distance('SJU', 'DOM', 369).
airports_distance('SJU', 'SBH', 210).
airports_distance('SJU', 'CPX', 47).
airports_distance('SJU', 'MAZ', 76).
airports_distance('SJU', 'VQS', 39).
airports_distance('SJU', 'NEV', 240).
airports_distance('SJU', 'AXA', 194).
airports_distance('SJU', 'EIS', 96).
airports_distance('SJU', 'VIJ', 103).
airports_distance('CLE', 'SJC', 2138).
airports_distance('CLE', 'YYZ', 193).
airports_distance('CLE', 'RSW', 1027).
airports_distance('CLE', 'PDX', 2039).
airports_distance('CLE', 'ROC', 244).
airports_distance('CLE', 'CLT', 431).
airports_distance('CLE', 'CUN', 1437).
airports_distance('CLE', 'IND', 261).
airports_distance('CLE', 'MCI', 692).
airports_distance('CLE', 'DAL', 1013).
airports_distance('CLE', 'STL', 486).
airports_distance('CLE', 'MKE', 327).
airports_distance('CLE', 'MDW', 306).
airports_distance('CLE', 'KEF', 2783).
airports_distance('CLE', 'ORF', 434).
airports_distance('CLE', 'JAX', 754).
airports_distance('CLE', 'PUJ', 1766).
airports_distance('CLE', 'SDF', 304).
airports_distance('CLE', 'BUF', 191).
airports_distance('CLE', 'CMH', 112).
airports_distance('CLE', 'ALB', 422).
airports_distance('CLE', 'RIC', 362).
airports_distance('CLE', 'MYR', 557).
airports_distance('CLE', 'CHS', 596).
airports_distance('CLE', 'DAY', 162).
airports_distance('CLE', 'GRR', 214).
airports_distance('CLE', 'GSP', 450).
airports_distance('CLE', 'SAV', 642).
airports_distance('CLE', 'VPS', 798).
airports_distance('CLE', 'SYR', 316).
airports_distance('CLE', 'SRQ', 969).
airports_distance('CLE', 'SFB', 873).
airports_distance('CLE', 'FNT', 145).
airports_distance('CLE', 'TTN', 376).
airports_distance('CLE', 'AZA', 1719).
airports_distance('CLE', 'ERI', 98).
airports_distance('CLE', 'BFD', 168).
airports_distance('CLE', 'DUJ', 154).
airports_distance('CLE', 'FKL', 103).
airports_distance('CLE', 'JHW', 143).
airports_distance('CLE', 'PKB', 144).
airports_distance('CLE', 'PIE', 933).
airports_distance('CLE', 'PGD', 1001).
airports_distance('OAK', 'LGW', 5364).
airports_distance('OAK', 'CDG', 5554).
airports_distance('OAK', 'FCO', 6235).
airports_distance('OAK', 'BCN', 5941).
airports_distance('OAK', 'YEG', 1153).
airports_distance('OAK', 'ARN', 5332).
airports_distance('OAK', 'PDX', 544).
airports_distance('OAK', 'OKC', 1371).
airports_distance('OAK', 'ONT', 362).
airports_distance('OAK', 'CPH', 5459).
airports_distance('OAK', 'MEM', 1793).
airports_distance('OAK', 'IND', 1927).
airports_distance('OAK', 'MCI', 1484).
airports_distance('OAK', 'DAL', 1464).
airports_distance('OAK', 'STL', 1720).
airports_distance('OAK', 'ABQ', 886).
airports_distance('OAK', 'MDW', 1839).
airports_distance('OAK', 'PVR', 1553).
airports_distance('OAK', 'OGG', 2345).
airports_distance('OAK', 'BOI', 511).