#if ${ISXEVE(exists)}
#else
	#error EVEBot requires ISXEVE to be loaded before running
#endif
#include Branches/Stable/core/defines.iss
#include Branches/Stable/core/targets/obj_targets_generic.iss
#include Branches/Stable/core/targets/obj_targets_special.iss
#include Branches/Stable/core/targets/obj_targets_ignore.iss
#include Branches/Stable/core/obj_Ship.iss


function main()
{
	echo "---\n ${Time} EVETest: testing"
	declarevariable SpecialTargetsService obj_targets_special script
	declarevariable IgnoreTargetsService obj_targets_ignore script
	declarevariable TestAPIService TestAPI script
	declarevariable ShipService obj_Ship script


	echo ${ShipService.HasCovOpsCloak}
	
	;echo ${SpecialTargetsService.IsSpecialTarget["Tairei Namazoth"]}
	;echo ${IgnoreTargetsService.IsIgnoredTarget["Blood Raiders Skiff"]}
	echo "Testing end \n---"
}