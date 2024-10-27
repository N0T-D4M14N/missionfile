/*
    File: fn_saveDuringRestart.sqf
    Author: damian
    Description: Lets the player save his Vehicle before a restart
*/


private _vehicle = nearestObjects[getPosATL player,["Car","Ship","Submarine","Air"],10] select 0;

private _owner = (_vehicle getVariable ["dbinfo",[]]) select 0;
private _pID = getPlayerUID player;

if (_owner isNotEqualTo _pid) exitWith {hint "Das Fahrzeug gehört nicht dir";};

//private _position = [];

private _plate = (_vehicle getVariable ["dbinfo",[]]) select 1;
private _damage = getAllHitPointsDamage _vehicle;
private _damage = _damage select 2;
_damage = [_damage] call DB_fnc_mresArray;
private _fuel = (fuel _vehicle);
private _vItems = _vehicle getVariable ["Trunk",[[],0]];
_vItems = [_vItems] call DB_fnc_mresArray;
_position = getPosATL _vehicle;
private _rotation = getDir _vehicle;

private _vehItems = getItemCargo _vehicle;
private _vehMags = getMagazineCargo _vehicle;
private _vehWeapons = getWeaponCargo _vehicle;
private _vehBackpacks = getBackpackCargo _vehicle;
private _iItems = [_vehItems,_vehMags,_vehWeapons,_vehBackpacks];

if ((count (_vehItems select 0) isEqualTo 0) && (count (_vehMags select 0) isEqualTo 0) && (count (_vehWeapons select 0) isEqualTo 0) && (count (_vehBackpacks select 0) isEqualTo 0)) then {_iItems = [];};

_iItems = [_iItems] call DB_fnc_mresArray;

 if (_vehicle getVariable["restart_saved",false] isEqualTo false) then {
    private _reason = 0;
    private _vehicleData = [_pID, _plate, _vItems, _iItems, _position, _damage, _fuel, _rotation, _reason];
    [_vehicleData] remoteExec ["TON_fnc_updateVehicle",2];

    _vehicle setVariable ["restart_saved",true,true];
    _vehicle lockInventory true;
    _vehicle lock true;
    
    diag_log _position;
    diag_log "[INFO] Vehicle saved";
 } else {
    private _reason = 2;
    private _vehicleData = [_pID, _plate, _vItems, _iItems, _position, _damage, _fuel, _rotation, _reason];
    [_vehicleData] remoteExec ["TON_fnc_updateVehicle",2];
    _vehicle setVariable["restart_saved",false,true];
    _vehicle lockInventory false;

    diag_log "[INFO] Fahrzeug wieder freigegeben";
};
