#include "..\..\script_macros.hpp"
/*
    File: fn_logFiredShot.sqf
    Author: damian...

    Description:
    Logs fired shots into the database
*/
params ["_unit","_weapon"];

private _playerId = getPlayerUID _unit; //STRING
private _playerName = name _unit; //STRING
private _playerSide = side _unit; //SIDE
private _date = systemTime; //Array
private _shotCount = 1; //SCALAR
life_log_fired_last_shot = serverTime;

if (life_log_fired_data isEqualTo []) then {
    life_log_fired_data = [_playerId,_playerName,_playerSide,_date, _weapon, _shotCount];
    [] spawn { 
        waitUntil {(life_log_fired_last_shot + 10 < serverTime) || (life_log_forcesave)};
        [life_log_fired_data] remoteExec ["TON_fnc_handleShots",2];
        life_log_fired_data = [];
        life_log_forcesave = false;   
    }; 
} else {
    if (life_log_fired_data#4 == _weapon) then {
        life_log_fired_data set [5, (life_log_fired_data#5 + 1)];
    } else {
        life_log_forcesave = true;
        _this spawn life_fnc_logFiredShot;
    };
};


