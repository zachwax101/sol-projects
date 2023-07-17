//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Ico.sol";

contract SpaceCoin is ERC20 {
    address public treasury;
    address public owner;
    bool public taxEnabled = true;
    Ico public ico;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyICO() {
        require(msg.sender == address(ico), "Only ICO can call this function");
        _;
    }

    constructor(address _treasury, address _owner) ERC20("SpaceCoin", "SPC") {
        owner = _owner;
        treasury = _treasury;
        _mint(_msgSender(), 150000);
        _mint(treasury, 350000);
        ico = Ico(_msgSender());
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        // 2 percent tax
        if(taxEnabled) {
            // the tax will round down, I'm ok with that.
            uint256 tax = amount / 50;
            uint256 amountAfterTax = amount - tax;

            _transfer(_msgSender(), treasury, tax);
            _transfer(_msgSender(), recipient, amountAfterTax);
        } else {
            _transfer(_msgSender(), recipient, amount);
        }

        
        return true;
    }

    function toggleTax() public onlyOwner {
        taxEnabled = !taxEnabled;
    }
}