#include "..\..\script_macros.hpp"
/*
    File: fn_playerInitials.sqf
    Author: damian.

    Description:
    Turns names into initials (Damian van Berg -> D. van Berg)
*/
params["_playername"];

_playername = _playername splitString " ";

diag_log _playername;

_playername set [0, [_playername#0 select [0,0]] + "."];