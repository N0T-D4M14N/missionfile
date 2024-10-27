#include "..\script_macros.hpp"
/*
    File: init.sqf
    Author: Bryan "Tonic" Boardwine
    Description:
    Master client initialization file
*/
diag_log "----------------------------------------------------------------------------------------------------";
diag_log "--------------------------------- Starting Altis Life Client Init ----------------------------------";
diag_log format["------------------------------------------ Version %1 -------------------------------------------",(LIFE_SETTINGS(getText,"framework_version"))];
diag_log "----------------------------------------------------------------------------------------------------";

0 cutText[localize "STR_Init_ClientSetup","BLACK FADED",99999999];
_timeStamp = diag_tickTime;

waitUntil {!isNull (findDisplay 46)};
[] call compile preprocessFileLineNumbers "core\clientValidator.sqf";
enableSentences false;

diag_log "[Life Client] Initialization Variables";
[] call compile preprocessFileLineNumbers "core\configuration.sqf";
diag_log "[Life Client] Variables initialized";

diag_log "[Life Client] Setting up Eventhandlers";
[] call life_fnc_setupEVH;
diag_log "[Life Client] Eventhandlers completed";

diag_log "[Life Client] Setting up user actions";
[] call life_fnc_setupActions;
diag_log "[Life Client] User actions completed";

/* Setting Up Ace Interactions*/

/* break open druglab to class */
private _condition = {(cursorObject isKindOf "Land_Ryb_domek") && (cursorObject getVariable ["rl_dl_building",false])}; 
private _statement = {[cursorObject] spawn life_fnc_druglabbreakopen;}; 
private _action = ["druglabBreakOpen","Drogenlabor aufbrechen","",_statement,_condition] call ace_interact_menu_fnc_createAction; 
["Land_TransferSwitch_01_F", 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToClass;

/* lock Druglab Selfinteraction */
private _condition = {(cursorObject isKindOf "Land_Ryb_domek") && (cursorObject getVariable ["rl_dl_building",false]) && (playerSide == WEST)};
private _statement = {[cursorObject] spawn life_fnc_druglabLock;};
private _action = ["lock_druglab_door","Drogenlabor Tür abschließen","",_statement,_condition] call ace_interact_menu_fnc_createAction;
[(typeOf player), 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

/* Vehicle save option */
private _condition = {(restart_in < 5) && ((vehicle player) isEqualTo player) && {cursorObject isKindOf "Car" || cursorObject isKindOf "Ship" || CursorObject isKindOf "Air"}};
private _statement = {[cursorObject] spawn life_fnc_saveDuringRestart;};
private _action = ["restart_save_vehicle","Fahrzeug speichern","",_statement,_condition] call ace_interact_menu_fnc_createAction;
[(typeOf player), 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToClass;

diag_log "[Life Client] Waiting for the server to be ready...";
waitUntil {!isNil "life_server_isReady" && {!isNil "life_server_extDB_notLoaded"}};

if (life_server_extDB_notLoaded) exitWith {
    0 cutText [localize "STR_Init_ExtdbFail","BLACK FADED",99999999];
};

waitUntil {life_server_isReady};
diag_log "[Life Client] Server loading completed ";
0 cutText [localize "STR_Init_ServerReady","BLACK FADED",99999999];

[] call SOCK_fnc_dataQuery;
waitUntil {life_session_completed};
0 cutText[localize "STR_Init_ClientFinish","BLACK FADED",99999999];

[] spawn life_fnc_escInterupt;

switch (playerSide) do {
    case west: {
        life_paycheck = LIFE_SETTINGS(getNumber,"paycheck_cop");
        [] call life_fnc_initCop;
    };
    case civilian: {
        life_paycheck = LIFE_SETTINGS(getNumber,"paycheck_civ");
        [] call life_fnc_initCiv;
    };
    case independent: {
        life_paycheck = LIFE_SETTINGS(getNumber,"paycheck_med");
        [] call life_fnc_initMedic;
    };
};
CONSTVAR(life_paycheck);

player setVariable ["restrained", false, true];
player setVariable ["Escorting", false, true];
player setVariable ["transporting", false, true];
player setVariable ["playerSurrender", false, true];
player setVariable ["realname", profileName, true];

diag_log "[Life Client] Past Settings Init";
[] execFSM "core\fsm\client.fsm";
diag_log "[Life Client] Executing client.fsm";

(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call life_fnc_keyHandler"];
[player, life_settings_enableSidechannel, playerSide] remoteExecCall ["TON_fnc_manageSC", RSERV];

[] call life_fnc_hudSetup;
[] spawn life_fnc_survival;

0 cutText ["","BLACK IN"];

[] spawn {
    for "_i" from 0 to 1 step 0 do {
        waitUntil {(!isNull (findDisplay 49)) && {(!isNull (findDisplay 602))}}; // Check if Inventory and ESC dialogs are open
        (findDisplay 49) closeDisplay 2; // Close ESC dialog
        (findDisplay 602) closeDisplay 2; // Close Inventory dialog
    };
};

addMissionEventHandler ["EachFrame", life_fnc_playerTags];
addMissionEventHandler ["EachFrame", life_fnc_revealObjects];

if (LIFE_SETTINGS(getNumber,"enable_fatigue") isEqualTo 0) then {player enableFatigue false;};
if (LIFE_SETTINGS(getNumber,"pump_service") isEqualTo 1) then {
    [] execVM "core\fn_setupStationService.sqf";
};

life_fnc_RequestClientId = player;
publicVariableServer "life_fnc_RequestClientId";

/*
    https://feedback.bistudio.com/T117205 - disableChannels settings cease to work when leaving/rejoining mission
    Universal workaround for usage in a preInit function. - AgentRev
    Remove if Bohemia actually fixes the issue.
*/
{
    _x params [["_chan",-1,[0]], ["_noText","false",[""]], ["_noVoice","false",[""]]];

    _noText = [false,true] select ((["false","true"] find toLower _noText) max 0);
    _noVoice = [false,true] select ((["false","true"] find toLower _noVoice) max 0);

    _chan enableChannel [!_noText, !_noVoice];

} forEach getArray (missionConfigFile >> "disableChannels");

if (life_HC_isActive) then {
    [getPlayerUID player, player getVariable ["realname", name player]] remoteExec ["HC_fnc_wantedProfUpdate", HC_Life];
} else {
    [getPlayerUID player, player getVariable ["realname", name player]] remoteExec ["life_fnc_wantedProfUpdate", RSERV];
};

[player] remoteExec ["TON_fnc_afterRestartSpawn",2];

diag_log "----------------------------------------------------------------------------------------------------";
diag_log format ["               End of Altis Life Client Init :: Total Execution Time %1 seconds ",(diag_tickTime - _timeStamp)];
diag_log "----------------------------------------------------------------------------------------------------";

