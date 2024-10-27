#include "..\..\script_macros.hpp"
/*
    File: fn_druglabBreakOpen.sqf
    Author: damian...

    Description:
    Script to break open the Druglab door.
*/

private ["_building","_door","_doors","_cpRate","_title","_progressBar","_titleText","_cP","_ui"];
_building = param [0,objNull,[objNull]];
_door = 1;

if (isNull _building) exitWith {};
if (!(_building isKindOf "Land_Ryb_domek")) exitWith {hint localize "STR_ISTR_Bolt_NotNear";};
if ((_building getVariable [format ["bis_disabled_Door_%1",_door],0]) isEqualTo 0) exitWith {hint "Die Tür ist bereits offen!";};
if (_building isKindOf "Land_Ryb_domek") then {[[1,2],"STR_ISTR_Bolt_AlertDruglab",true,[]] remoteExecCall ["life_fnc_broadcast",RCLIENT];};

life_action_inUse = true;
//Setup the progress bar
disableSerialization;
_title = localize "STR_ISTR_Bolt_Process";
"progressBar" cutRsc ["life_progress","PLAIN"];
_ui = uiNamespace getVariable "life_progress";
_progressBar = _ui displayCtrl 38201;
_titleText = _ui displayCtrl 38202;
_titleText ctrlSetText format ["%2 (1%1)...","%",_title];
_progressBar progressSetPosition 0.01;
_cP = 0.01;
_cpRate = 0.08;

for "_i" from 0 to 1 step 0 do {
    if (animationState player != "AinvPknlMstpSnonWnonDnon_medic_1") then {
        [player,"AinvPknlMstpSnonWnonDnon_medic_1",true] remoteExecCall ["life_fnc_animSync",RCLIENT];
        player switchMove "AinvPknlMstpSnonWnonDnon_medic_1";
        player playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
    };
    uiSleep 0.26;
    if (isNull _ui) then {
        "progressBar" cutRsc ["life_progress","PLAIN"];
        _ui = uiNamespace getVariable "life_progress";
        _progressBar = _ui displayCtrl 38201;
        _titleText = _ui displayCtrl 38202;
    };
    _cP = _cP + _cpRate;
    _progressBar progressSetPosition _cP;
    _titleText ctrlSetText format ["%3 (%1%2)...",round(_cP * 100),"%",_title];
    if (_cP >= 1 || !alive player) exitWith {};
    if (life_istazed) exitWith {}; //Tazed
    if (life_isknocked) exitWith {}; //Knocked
    if (life_interrupted) exitWith {};
};

//Kill the UI display and check for various states
"progressBar" cutText ["","PLAIN"];
player playActionNow "stop";
if (!alive player || life_istazed || life_isknocked) exitWith {life_action_inUse = false;};
if (player getVariable ["restrained",false]) exitWith {life_action_inUse = false;};
if (life_interrupted) exitWith {life_interrupted = false; titleText[localize "STR_NOTF_ActionCancel","PLAIN"]; life_action_inUse = false;};
life_action_inUse = false;

_building setVariable [format ["bis_disabled_Door_%1",_door],0,true];
_building setVariable ["locked",false,true];

private _checkStatus = _building getVariable [format ["bis_disabled_Door_%1",_door],0];
if (_checkStatus isEqualTo 0) then {hint "Du hast die Tür aufgebrochen, jetzt aber schnell!";};

//spawn marker on map for everyone 
private _pos = DRUGLAB_SETTINGS(getArray, "building_position");

private _marker = createMarker ["druglab_heist", _pos];
_marker setMarkerType "hd_warning";
_marker setMarkerColor "ColorRed";
_marker setMarkerText "Achtung Raub!";