#include "..\..\script_macros.hpp"
/*
    File: fn_druglabLock.sqf
    Author: damian...

    Description:
    Script to lock the Druglab door.
*/

if !(playerSide == WEST) exitWith {hint "Du bist kein Polizist!";};//check if player is a cop

private _building = param [0,objNull,[objNull]];
if !(_building isKindOf "Land_Ryb_Domek") exitWith {hint "Du bist nicht in der Nähe des Drogenlabor.";};//check if building is druglab

private _door = 1;
private _doorLocked = _building getVariable [format ["bis_disabled_Door_%1",_door],0];
if (_doorLocked isEqualTo 1) exitWith {hint "Die Tür ist bereits abgeschlossen!";};//check if door is already locked

_building setVariable [format ["bis_disabled_Door_%1",_door],1,true]; //lock the druglabdoor

private _checkStatus = _building getVariable [format ["bis_disabled_Door_%1",_door],0];
if (_checkStatus isEqualTo 1) then {hint "Die Tür ist jetzt verschlossen!";};

call TON_fnc_druglabFill; //call function to refill
deleteMarker "druglab_heist"; //delete Marker from Map
_building setVariable ["locked",true,true];//lock the safe