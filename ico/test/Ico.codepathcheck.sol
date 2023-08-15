import "halmos-cheatcodes/SymTest.sol";
import "contracts/Ico.sol";

contract IcoCodePathChecker is SymTest { 

function check_advancePhase_function(string f_0, address[] c_0, address c_1) public {
                    Ico instance = new Ico(c_0, c_1);
                    instance.advancePhase(f_0);
                    assert(false);
                }

function check_contribute_function(address[] c_0, address c_1) public {
                    Ico instance = new Ico(c_0, c_1);
                    instance.contribute();
                    assert(false);
                }

function check_redeem_function(address[] c_0, address c_1) public {
                    Ico instance = new Ico(c_0, c_1);
                    instance.redeem();
                    assert(false);
                }

function check_toggleAcceptingContributions_function(address[] c_0, address c_1) public {
                    Ico instance = new Ico(c_0, c_1);
                    instance.toggleAcceptingContributions();
                    assert(false);
                }

function check_toggleAcceptingRedemptions_function(address[] c_0, address c_1) public {
                    Ico instance = new Ico(c_0, c_1);
                    instance.toggleAcceptingRedemptions();
                    assert(false);
                }

}