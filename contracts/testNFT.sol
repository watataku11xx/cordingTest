// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//変更箇所11/24
contract testNFT is ERC721URIStorage,Ownable,ReentrancyGuard
{
  //設問(1)
  //constantとして以下定数を設定せよ。
  // 1. 購入価格(設定値:500)
  // 2. 1アドレスあたりの発行上限(設定値:3)
  // 3. 総発行上限(設定値:20)
    uint256 constant PURCHASE_PRICE = 500;
    uint256 constant MAX_ISSUE_PER_ADDRESS = 3;
    uint256 constant TOTAL_MAX_ISSUE = 20;


  //設問(2)
  //variable(状態変数)として以下変数を設定せよ。
  // 1. 発行済みトークンのindex
  // 2. mint可能時刻
  // 3. 支払い通貨のinterface(IERC20)
  // 4. 発行対象のtokenid(uint)のリスト
  // 5. 発行対象のtokenmeta情報(string)のリスト
  // 6. 支払い通貨の受け取りアドレス

    uint256 public tokenIndex;
    uint256 public mintingTime;
    IERC20 public paymentCurrency;
    uint[] public tokenIdList;
    string[] public tokenMetaList;
    address public paymentAddress;

    uint256 public index_;

  //設問(3)
  //constructorとして、
  // 1. tokenのname
  // 2. tokenのsymbol
  // 3. 設問(2)の1~6
  //の8つを引数として、設問(2)の各variableに設定せよ。
  //(但し、設問(2)の3については、引数はaddress型で渡し、constructor内でinterfaceを初期化すること)
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _tokenIndex,
        uint256 _mintingTime,
        address _paymentCurrency,
        uint[] memory _tokenIdList,
        string[] memory _tokenMetaList,
        address _paymentAddress
    ) ERC721(_name, _symbol) {
        tokenIndex = _tokenIndex;
        mintingTime = _mintingTime;
        paymentCurrency = IERC20(_paymentCurrency);
        tokenIdList = _tokenIdList;
        tokenMetaList = _tokenMetaList;
        paymentAddress = _paymentAddress;
    }


  //設問(4)
  //以下仕様に基づき、アドレスを引数として、購入者の発行上限を取得する関数を作成せよ。
  //[前提]
  // 1.引数のアドレスが、0アドレスではないこと
  //[処理フロー]
  // 1.引数のアドレスが現在所有しているNFT数を取得
  // 2.NFT数が1アドレスあたりの発行上限を上回っている場合は0を戻す
  // 3.2.の条件に合致しない場合は、1アドレスあたりの発行上限からNFT数を差し引いた値を戻す

    function getMaxIssueCount(address _address) public view returns(uint256) {
        uint256 tokenCount = balanceOf(_address); //検討
        if (tokenCount >= MAX_ISSUE_PER_ADDRESS) {
            return 0;
        } else {
            return MAX_ISSUE_PER_ADDRESS - tokenCount;
        }
    }

  //設問(5)
  //以下仕様に基づき、購入数量を引数として、購入処理を行う関数を作成せよ。
  //[前提]
  // 1.関数実行時の時刻がmint可能時刻を超えていること
  // 2.関数実行者の支払い通貨残高が、NFTの購入に必要な金額以上であること
  // 3.関数実行者の購入数量が、1アドレスあたりの上限を超えていないこと(設問4で作成した関数を用いる)
  // 4.関数実行者の購入数量+今までの総発行数が、発行上限を超えていないこと
  //[処理フロー]
  // --1~4は、引数で指定した購入数量の数だけ、ループ処理--
  // 1.発行対象のtokenidとメタ情報をリストから取得
  // 2.idを指定して、トークンをmint
  // 3.tokenURIにメタ情報をセット
  // 4.発行済みトークンのindexを加算
  // 5.支払い通貨の受け取りアドレス宛に、購入金額分の通貨を送付

    function purchase(uint256 _count) external nonReentrant {
      require(block.timestamp >= mintingTime, "Cannot purchase");
      require(paymentCurrency.balanceOf(msg.sender) >= PURCHASE_PRICE * _count, "Insufficient payment currency balance");
      require(getMaxIssueCount(msg.sender) >= _count, "Exceeds max issue per address");
      require(tokenIndex + _count <= TOTAL_MAX_ISSUE, "Exceeds total max issue");

      for (uint256 i = 0; i < _count; i++) {
        uint256 tokenId = tokenIdList[tokenIndex];
        string memory tokenMeta = tokenMetaList[tokenIndex];
        tokenIndex++;
        
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenMeta); //検討
      }
    
      paymentCurrency.transferFrom(msg.sender, paymentAddress, PURCHASE_PRICE * _count);
      tokenIndex += _count;
    }
}
