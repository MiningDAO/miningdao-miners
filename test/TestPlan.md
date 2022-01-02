# Test Cases

## DeMineNFT

ERC2981:
[x] setRoyaltyInfo from non-owner should fail
[x] setRoyaltyInfo, getRoyaltyInfo should updated

DeMineNFT Specific:
- create new pool from non owner, should fail
- create new pool with wrong supply array, should fail
- create new pool from rewarded cycles, should fail
- create new pool
  - event TransferBatch from address(0) should be emitted
  - event NewPool should be emitted
  - DeMineAgent should with pool set
  - balanceOf issuer for ids should be same with supplies

- reward from non-owner should fail
- reward with unauthorized rewarder, should fail
- reward with reward divisible by cycle supply
- reward with reward not divisible by cycle supply

- cashout unrewarded cycle, should fail
- cashout rewarded cycle with approved operator
  - tokens should be burned
  - recipient should receive reward tokens
  - reward token balance of nft contract should decrease
- cashout rewarded cycle with account owner
  - tokens should be burned
  - recipient should receive reward tokens
  - reward token balance of nft contract should decrease

ERC1155:
- check uri
- transfer/transferBatch with account owner
  - balanceOf/balanceOfBatch should be updated
- SetApprovedForAll
- isApprovedForAll
- transfer/transferBatch with authorized operator
  - balanceOf/balanceOfBatch should be updated

## DeMineAgent

NFT Contract only:
- pool set, from non-nft should fail
- pool set, pool stats should be updated
- receive nft, from non-nft should fail
- receive nft, token stats should be updated

DeMineAgent View:
- isPaymentSupported
- listingInfo
- tokenInfo
- incomeInfo

DeMineAgent State Update:
- set reward token recipient from non owner should fail
- set reward token recipient, recipient should be updated
- set payment from non owner should fail
- set payment, payment info should be updated

DeMineAgent Actions:
- list
  - with sender as non token issuer, should fail
  - with token issuer as recipient, should fail
  - with cashedout token, should fail
  - with price lower than cost, should fail
  - with amount exceeding locked + listed, should fail
  - to address(0)
     - token stats should be updated
     - check listing result is set
  - to address(0) again
     - token stats should be updated
     - listing should be updated
  - to one recipient
     - token stats should be updated
     - check listing result is set
     - list event should be emitted
  - to one recipient again
     - token stats should be updated
     - listing should be updated
     - list event should be emitted

- unlist
  - with sender as non token issuer, should fail
  - with cashedout token, should fail
  - to address(0)
     - token stats should be updated
     - tokens should be unlisted
     - Unlist event should be emitted
  - to normal recipient
     - token stats should be updated
     - tokens should be unlisted
     - Unlist event should be emitted

- claim
  - with cashedout token, should fail
  - with unsupported payment method, should fail
  - with amount exceeding listed, should fail
  - with not enough cost tokens to pay, should fail
  - with amount lower than listed for recipient
    - token stats should be updated
    - cost recipient should be paid
    - income of token issuer should increase
    - token should be transferred to claimer
  - with amount larger than listed for recipient but lower than total listed
    - token stats should be updated
      - check listingInfo for address(0)
    - cost token balance of payment recipient should increase
    - income info of token issuer should increase
    - cost token balance of agent should increase
    - nft tokens should be transferred from agent to claimer
    - Claim event should be emitted

- redeem
  - with non token issuer, should fail
  - with unsupported payment method, should fail
  - with amount larger than total locked, should fail
  - with not enough tokens to pay, should fail
  - with correct ids and amounts
    - token stats should be updated
    - cost recipient should be paid with proper payment method
    - nft token should be transferred from agent to token issuer
    - Redeem event should be emitted

- withdraw
  - with payments/amounts array mismatch, should fail
  - with amount exceeding income, should fail
  - with correct input
    - income info of sender should decrease
    - balance of sender should increase
    - balance of agent contract should decrease
    - Withdraw event should be emitted

- cashout
  - with token already cashedout, should fail
  - with tokens with unrewarded cycle, should fail
  - with proper tokens to cashout
    - token stats should be updated
    - owner should receive reward tokens
    - tokens should be burned