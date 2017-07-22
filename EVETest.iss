#if ${ISXEVE(exists)}
#else
	#error EVEBot requires ISXEVE to be loaded before running
#endif
#include Branches/Stable/core/targets/obj_targets_generic.iss
#include Branches/Stable/core/targets/obj_targets_special.iss
#include Branches/Stable/core/targets/obj_targets_ignore.iss


function main()
{
	echo "---\n ${Time} EVETest: testing"
	declarevariable SpecialTargetsService obj_targets_special script
	declarevariable IgnoreTargetsService obj_targets_ignore script
	
	echo ${SpecialTargetsService.IsSpecialTarget["Tairei Namazoth"]}
	echo ${IgnoreTargetsService.IsIgnoredTarget["Blood Raiders Skiff"]}
	echo "Testing end \n---"
}