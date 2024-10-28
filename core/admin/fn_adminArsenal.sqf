#include "..\..\script_macros.hpp"
/*
    File: fn_adminArsenal.sqf
    Author: damian

    Description: Opens the Arsenal
*/

if (FETCH_CONST(life_adminlevel) < 4) exitWith {closeDialog 0; hint localize "STR_ANOTF_ErrorLevel";};

closeDialog 0;

["Open",true] call BIS_fnc_arsenal;