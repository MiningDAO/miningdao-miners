// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import '@solidstate/contracts/introspection/ERC165Storage.sol';
import '@solidstate/contracts/token/ERC1155/IERC1155Receiver.sol';
// use IERC20 from openzeppelin so we can use SafeERC20 lib
import "@openzeppelin/contracts/interfaces/IERC20.sol";

import '../shared/lib/DeMineBase.sol';
import '../shared/interfaces/IDiamondFacet.sol';
import '../nft/interfaces/IDeMineNFT.sol';
import './facets/MortgageFacet.sol';
import './facets/PrimaryMarketFacet.sol';
import './facets/BillingFacet.sol';

contract DeMineAgent is DeMineBase {
    AppStorage internal s;
    using ERC165Storage for ERC165Storage.Layout;

    function initialize(
        address baseFacet,
        address diamondFacet,
        address mortgageFacet,
        address primaryMarketFacet,
        address billingFacet,
        // initialization args
        uint256 tokenCost,
        address income,
        address payment,
        address nft
    ) external initializer {
        __DeMineBase_init();
        IDiamondCuttable.FacetCut[] memory facetCuts = new IDiamondCuttable.FacetCut[](5);
        facetCuts[0] = IDiamondFacet(baseFacet).genFacetCutAdd();
        facetCuts[1] = IDiamondFacet(diamondFacet).genFacetCutAdd();
        facetCuts[2] = genCutMortagage(mortgageFacet);
        facetCuts[3] = genCutPrimaryMarket(primaryMarketFacet);
        facetCuts[4] = genCutBilling(billingFacet);
        cutFacets(facetCuts, diamondFacet);

        // init storage
        s.nft = nft;
        s.tokenCost = tokenCost;
        s.income = IERC20(income);
        s.payment = IERC20(payment);
    }

    function genCutMortagage(
        address target
    ) internal returns(IDiamondCuttable.FacetCut memory) {
        ERC165Storage.Layout storage erc165 = ERC165Storage.layout();

        bytes4[] memory selectors = new bytes4[](7);
        selectors[0] = IERC1155Receiver.onERC1155Received.selector;
        selectors[1] = IERC1155Receiver.onERC1155BatchReceived.selector;
        erc165.setSupportedInterface(type(IERC1155Receiver).interfaceId, true);

        selectors[2] = MortgageFacet.redeem.selector;
        selectors[3] = MortgageFacet.payoff.selector;
        selectors[4] = MortgageFacet.adjustDeposit.selector;
        selectors[5] = MortgageFacet.getAccountInfo.selector;
        selectors[6] = MortgageFacet.balanceOfBatch.selector;
        return genFacetCut(target, selectors);
    }

    function genCutPrimaryMarket(
        address target
    ) internal pure returns(IDiamondCuttable.FacetCut memory) {
        bytes4[] memory selectors = new bytes4[](9);
        selectors[0] = PrimaryMarketFacet.setPricingStrategy.selector;
        selectors[1] = PrimaryMarketFacet.increaseAllowance.selector;
        selectors[2] = PrimaryMarketFacet.decreaseAllowance.selector;
        selectors[3] = PrimaryMarketFacet.claim.selector;
        selectors[4] = PrimaryMarketFacet.getListedPrices.selector;
        selectors[5] = PrimaryMarketFacet.getAllowances.selector;
        selectors[6] = PricingStatic.setStaticBase.selector;
        selectors[7] = PricingStatic.setStaticOverride.selector;
        selectors[8] = PricingLinearDecay.setLinearDecay.selector;
        return genFacetCut(target, selectors);
    }

    function genCutBilling(
        address target
    ) internal pure returns(IDiamondCuttable.FacetCut memory) {
        bytes4[] memory selectors = new bytes4[](6);
        selectors[0] = BillingFacet.tryBilling.selector;
        selectors[1] = BillingFacet.lockPrice.selector;
        selectors[2] = BillingFacet.buyWithLockedPrice.selector;
        selectors[3] = BillingFacet.closeBilling.selector;
        selectors[4] = BillingFacet.resetShrink.selector;
        selectors[5] = BillingFacet.getStatement.selector;
        return genFacetCut(target, selectors);
    }
}