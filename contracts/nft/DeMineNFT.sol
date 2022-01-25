// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import '@solidstate/contracts/proxy/diamond/IDiamondCuttable.sol';
import '@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataStorage.sol';
import '@solidstate/contracts/token/ERC1155/metadata/IERC1155Metadata.sol';
import '@solidstate/contracts/token/ERC1155/IERC1155.sol';
import "@openzeppelin/contracts/proxy/Clones.sol";
import '@solidstate/contracts/introspection/IERC165.sol';

import '../shared/lib/DeMineBase.sol';
import './lib/AppStorage.sol';
import './interfaces/IMiningPool.sol';
import './interfaces/IERC1155Mineable.sol';
import './interfaces/IERC2981.sol';

contract DeMineNFT is DeMineBase {
    AppStorage internal s;

    function initialize(
        address owner,
        address diamondFacet,
        address erc1155Facet,
        IDiamondCuttable.FacetCut[] calldata facetCuts,
        address income,
        address recipient,
        uint16 bps,
        string memory uri
    ) external initializer {
        __DeMineBase_init(diamondFacet, erc1155Facet, facetCuts, owner);
        ERC1155MetadataStorage.layout().baseURI = uri;
        s.royalty = RoyaltyInfo(recipient, bps);
        s.income = IERC20(income);
    }

    function create(
        address owner,
        address diamondFacet,
        address erc1155Facet,
        IDiamondCuttable.FacetCut[] calldata facetCuts,
        address income,
        address recipient,
        uint16 bps,
        string memory uri
    ) external {
        address cloned = Clones.clone(address(this));
        DeMineNFT(payable(cloned)).initialize(
            owner, diamondFacet, erc1155Facet, facetCuts, income, recipient, bps, uri
        );
        emit Clone(address(this), cloned);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public override(DeMineBase) view returns (bool) {
        return super.supportsInterface(interfaceId) ||
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155Mineable).interfaceId ||
            interfaceId == type(IERC1155Metadata).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            interfaceId == type(IMiningPool).interfaceId;
    }
}
