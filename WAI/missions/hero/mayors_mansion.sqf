private ["_rndnum","_room","_complete","_mayor_himself","_crate_type","_mission","_position","_crate","_baserunover","_mayor"];

// Get mission number, important we do this early
_mission = count wai_mission_data -1;

_position = [40] call find_position;

diag_log format["WAI: [Mission:[Hero] Mayors Mansion]: Starting... %1",_position];

//Setup the crate
_crate_type = crates_large call BIS_fnc_selectRandom;
_crate = createVehicle [_crate_type,[(_position select 0),(_position select 1),0], [], 0, "CAN_COLLIDE"];
_crate call wai_crate_setup;
 
//Mayors Mansion
_baserunover 	= createVehicle ["Land_A_Villa_EP1",[(_position select 0), (_position select 1),0],[], 0, "CAN_COLLIDE"];
_baserunover 	setVectorUp surfaceNormal position _baserunover;

//Troops
_rndnum = round (random 5);
[[_position select 0,_position select 1,0],5,"Extreme",["Random","AT"],4,"Random","Bandit","Random","Bandit",_mission] call spawn_group;
[[_position select 0,_position select 1,0],5,"Extreme","Random",4,"Random","Bandit","Random","Bandit",_mission] call spawn_group;
[[_position select 0,_position select 1,0],5,"Extreme","Random",4,"Random","Bandit","Random","Bandit",_mission] call spawn_group;
[[_position select 0,_position select 1,0],5,"Extreme","Random",4,"Random","Bandit","Random","Bandit",_mission] call spawn_group;
[[_position select 0,_position select 1,0],_rndnum,"Extreme","Random",4,"Random","Bandit","Random","Bandit",_mission] call spawn_group;

//The Mayor Himself
_mayor = [_position,1,"Extreme","Random",4,"Random","Special","Random",["Bandit",100],_mission] call spawn_group;
_mayor_himself = (units _mayor) select 0;

//Put the Mayor in his room
_room = (6 + ceil(random(3)));
_mayor_himself disableAI "MOVE";
_mayor_himself setPos (_baserunover buildingPos _room);

//Let him move once player is near
_mayor_himself spawn {
	private ["_mayor","_player_near"];
	_mayor = _this;
	_player_near = false;
	while {!_player_near} do {
		_player_near = [(position _mayor),30] call isNearPlayer;
		uiSleep 1;
	};
	_mayor enableAI "MOVE";
};

//Humvee Patrol
[[(_position select 0) + 100, _position select 1, 0],[(_position select 0) + 100, _position select 1, 0],50,2,"HMMWV_Armored","Random","Bandit","Bandit",_mission] call vehicle_patrol;

//Heli Paradrop
[[(_position select 0),(_position select 1),0],400,"UH60M_EP1_DZE","North",[3000,4000],150,1.0,100,10,"Random","Random",4,"Random","Bandit","Random","Bandit",false,_mission] spawn heli_para;

//Static mounted guns
[[
	[(_position select 0) - 15, (_position select 1) + 15, 8],
	[(_position select 0) + 15, (_position select 1) - 15, 8]
],"M2StaticMG","Extreme","Bandit","Bandit",1,2,"Random","Random",_mission] call spawn_static;

// Array of mission variables to send
[
	_mission, // Mission number
	_position, // Position of mission
	"Extreme", // Difficulty
	"Mayors Mansion", // Name of Mission
	"MainHero", // Mission Type: MainHero or MainBandit
	true, // show mission marker?
	true, // make minefields available for this mission
	_crate, // crate object info
	["assassinate",_mayor], // Completion type: ["crate"], ["kill"], or ["assassinate", _unitGroup],
	[_baserunover], // cleanup objects
	"STR_CL_HERO_MAYOR_ANNOUNCE", // mission announcement
	"STR_CL_HERO_MAYOR_WIN", // mission success
	"STR_CL_HERO_MAYOR_FAIL", // mission fail
	[16,4,0,3,4] // Dynamic crate array
] call mission_winorfail;
