#include core/defines.iss

/* unconverted files */
#include core/oCombat.iss
#include core/oSkills.iss
#include core/oSpace.iss

/* Base Requirements */
#include core/obj_AutoPatcher.iss
#include core/obj_Misc.iss
#include core/obj_Configuration.iss

/* Support File Includes */
#include core/obj_Asteroids.iss
#include core/obj_Ship.iss
#include core/obj_Station.iss
#include core/obj_Cargo.iss
#include core/obj_EVEBotUI.iss

/* Behavior/Mode Includes */
#include core/obj_Hauler.iss
#include core/obj_Miner.iss
#include core/obj_Combat.iss

/* Declare all script or global variables here */
variable bool play
variable bool ForcedReturn

/* Script-Defined Support Objects */
variable obj_EVEBotUI UI
variable obj_Misc Misc
variable obj_Configuration_BaseConfig BaseConfig
variable obj_Configuration Config
;variable obj_AutoPatcher AutoPatcher

/* Core Objects */
variable obj_Asteroids Asteroids
variable obj_Ship Ship
variable obj_Station Station
variable obj_Cargo Cargo
variable obj_Skills Skills

/* Script-Defined Behavior Objects */
variable index:string BotModules
variable obj_Miner Miner
variable obj_OreHauler Hauler
variable obj_Combat Combat
;variable obj_Salvager Salvager

function atexit()
{
	;redirect profile.txt Script:DumpProfiling
}

function main()
{
	;Script:Unsquelch
	;Script:EnableDebugLogging[debug.txt]
	;Script[EVEBot]:EnableProfiling

	/* Set Turbo to lowest value to try and avoid overloading the EVE Python engine */
	Turbo 20
		
	UI:Reload
	UI:UpdateConsole["-=Paused: Press Run-="]
	Script[EVEBot]:Pause
	
	variable iterator BotModule
	BotModules:GetIterator[BotModule]
	while TRUE
	{
		if ${BotModule:First(exists)}
		do
		{
			call ${BotModule.Value}.ProcessState
			wait 10
			while !${play}
			{
				wait 10
			}
		}
		
		while ${BotModule:Next(exists)}
		waitframe
	}
}

atom(global) forcedreturn()
{
	/* echo "forcedreturn" */
	ForcedReturn:Set[TRUE]
}
