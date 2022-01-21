// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import '@solidstate/contracts/access/SafeOwnable.sol';
import '../lib/LibPausable.sol';
import '../lib/Cloneable.sol';

contract DeMineAdminFacet is Cloneable, Pausable, SafeOwnable { }