// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';
import './FakeAfenToken.sol';
import './FakeBscToken.sol';

contract Main is ERC1155{
    struct Nft {
        string _hash;
        uint _aprice;
        uint _bprice;
        uint _amount;
        address _creator;
        bool _isSell;
    }
    Nft[] nft_list;
    FakeAfenToken afen = new FakeAfenToken();
    FakeBscToken bsc = new FakeBscToken();

    event Minted(string _hash, uint aprice, uint bprice, uint amount, address creator);
    event Minted_nft_len(uint length);
    event SettedSell(uint id, bool isSet, address creator, address setter);
    constructor() ERC1155("") {}    
    function mint(string memory _hash, uint _aprice, uint _bprice, uint _amount) public {
        uint nft_len = nft_list.length;
        _mint(msg.sender, nft_len, _amount, "");
        Nft memory temp = Nft(_hash, _aprice, _bprice, _amount, msg.sender, false);
        nft_list.push(temp);
        emit Minted(_hash, _aprice, _bprice, _amount, msg.sender);
        emit Minted_nft_len(nft_len+1);
    }

    function get_nft(uint _id) public view returns(string memory, uint, uint, uint, address) {
        return (
            nft_list[_id]._hash,
            nft_list[_id]._aprice,
            nft_list[_id]._bprice,
            nft_list[_id]._amount,
            nft_list[_id]._creator
        );
    }

    function calc_fee(uint _price) public pure returns(uint) {
        return _price * 2;
    }

    event MainTestEvent(address from, uint bal_f, address to, uint bal_t);
    function set_sell(uint _id, uint token_id) public {
        nft_list[_id]._isSell = true;
        if(token_id == 0) {
            uint list_fee = calc_fee(nft_list[_id]._aprice);
            address sender = msg.sender;
            afen.sell(sender, 1000);
            (address a, uint bal_a, address b, uint bal_b) = afen.safeTransfer(sender, address(this), list_fee);
            emit MainTestEvent(a, bal_a, b, bal_b);
        } else {
            uint list_fee = calc_fee(nft_list[_id]._bprice);
            bsc.safeTransfer(msg.sender, address(this), list_fee);
        }
        emit SettedSell(_id, nft_list[_id]._isSell, nft_list[_id]._creator, msg.sender);
    }
}