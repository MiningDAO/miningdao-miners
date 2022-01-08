// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import '@solidstate/contracts/access/OwnableStorage.sol';
import '@solidstate/contracts/proxy/diamond/IDiamondCuttable.sol';
import '@solidstate/contracts/proxy/diamond/IDiamondLoupe.sol';

import './LibDiamond.sol';
import './LibERC1155WithAgent.sol';
import '../facets/ERC2981Facet.sol';
import '../facets/ERC1155MetadataFacet.sol';
import '../facets/ERC1155WithAgentFacet.sol';

library LibDeMineNFT {
    using DiamondBaseStorage for DiamondBaseStorage.Layout;
    using LibERC1155WithAgent for LibERC1155WithAgent.Layout;
    using OwnableStorage for OwnableStorage.Layout;
    using ERC165Storage for ERC165Storage.Layout;

    function genCutERC2981(
        address target
    ) internal returns(IDiamondCuttable.FacetCut memory) {
        ERC165Storage.Layout storage erc165 = ERC165Storage.layout();
        erc165.setSupportedInterface(type(IERC2981).interfaceId, true);

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = IERC2981.royaltyInfo.selector;
        selectors[1] = ERC2981Facet.setRoyaltyInfo.selector;
        return LibDiamond.genFacetCut(target, selectors);
    }

    function genCutERC1155Metadata(
        address target
    ) internal returns(IDiamondCuttable.FacetCut memory) {
        ERC165Storage.Layout storage erc165 = ERC165Storage.layout();
        erc165.setSupportedInterface(type(IERC1155Metadata).interfaceId, true);

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = IERC1155Metadata.uri.selector;
        selectors[1] = ERC1155MetadataFacet.setBaseURI.selector;
        selectors[2] = ERC1155MetadataFacet.setTokenURI.selector;
        return LibDiamond.genFacetCut(target, selectors);
    }

    function genCutERC1155WithAgent(
        address target
    ) internal returns(IDiamondCuttable.FacetCut memory) {
        ERC165Storage.Layout storage erc165 = ERC165Storage.layout();

        bytes4[] memory selectors = new bytes4[](8);
        // register ERC1155
        selectors[0] = IERC1155.balanceOf.selector;
        selectors[1] = IERC1155.balanceOfBatch.selector;
        selectors[2] = IERC1155.isApprovedForAll.selector;
        selectors[3] = IERC1155.setApprovalForAll.selector;
        selectors[4] = IERC1155.safeTransferFrom.selector;
        selectors[5] = IERC1155.safeBatchTransferFrom.selector;
        erc165.setSupportedInterface(type(IERC1155).interfaceId, true);

        // register ERC1155WithAgent
        selectors[6] = ERC1155WithAgentFacet.mintBatch.selector;
        selectors[7] = ERC1155WithAgentFacet.burnBatch.selector;
        return LibDiamond.genFacetCut(target, selectors);
    }

    function initialize(
        address demineAgent,
        address diamondFacet,
        address erc2981Facet,
        address erc1155MetadataFacet,
        address erc1155WithAgentFacet
    ) external {
        OwnableStorage.layout().setOwner(msg.sender);
        LibERC1155WithAgent.layout().agent = demineAgent;

        IDiamondCuttable.FacetCut[] memory facetCuts
            = new IDiamondCuttable.FacetCut[](4);
        facetCuts[0] = LibDiamond.genCutDiamond(diamondFacet);
        facetCuts[1] = genCutERC2981(erc2981Facet);
        facetCuts[2] = genCutERC1155Metadata(erc1155MetadataFacet);
        facetCuts[3] = genCutERC1155WithAgent(erc1155WithAgentFacet);
        (bool success, bytes memory returndata) = diamondFacet.delegatecall(
            abi.encodeWithSelector(IDiamondCuttable.diamondCut.selector, facetCuts, address(0), "")
        );
        require(success, string(returndata));
    }
}
