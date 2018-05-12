#if ${ISXEVE(exists)}
#else
	#error EVEBot requires ISXEVE to be loaded before running
#endif
#include Branches/Stable/core/defines.iss
#include Branches/Stable/core/targets/obj_targets_generic.iss
#include Branches/Stable/core/targets/obj_targets_special.iss
#include Branches/Stable/core/targets/obj_targets_ignore.iss
#include Branches/Stable/core/obj_Ship.iss
#include Branches/Stable/core/obj_Sound.iss

function main()
{
	echo "---\n ${Time} EVETest: testing"
	declarevariable SpecialTargetsService obj_targets_special script
	declarevariable IgnoreTargetsService obj_targets_ignore script
	declarevariable TestAPIService TestAPI script
	declarevariable Sound obj_Sound script
	;declarevariable ShipService obj_Ship script

	;ShipService:UpdateModuleList
	
	echo ${SpecialTargetsService.IsSpecialTarget["Tairei Namazoth"]}
	echo ${SpecialTargetsService.IsSpecialTarget["Dark Blood Archon"]}
	;echo ${IgnoreTargetsService.IsIgnoredTarget["Dark Blood Archon"]}
	echo "Testing end \n---"
}