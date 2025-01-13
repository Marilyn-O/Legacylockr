# Capsule contributors management Smart contract

## Overview

This smart contract, written in Clarity for the Stacks blockchain, manages contributors for capsules. It allows capsule owners to add and remove contributors, and provides functionality to check if an address is a contributor to a specific capsule.

## Contract Details

- **Name**: Capsule-contribution-management
- **Version**: 1.0.0
- **Language**: Clarity

## Features

1. Add contributors to a capsule
2. Remove contributors from a capsule
3. Check if an address is a contributor to a capsule
4. Initialize new capsules (for testing purposes)

## Data Structures

The contract uses two main data maps:

1. `capsules`: Maps capsule IDs to their owners
2. `contributors`: Maps capsule IDs and contributor addresses to their contributor status

## Functions

### Public Functions

1. `add-contributor (capsule-id uint) (contributor principal) -> (response bool uint)`
   - Adds a contributor to a capsule
   - Only the capsule owner can add contributors
   - Returns `(ok true)` on success, or an error if the caller is not the owner or if the contributor already exists

2. `remove-contributor (capsule-id uint) (contributor principal) -> (response bool uint)`
   - Removes a contributor from a capsule
   - Only the capsule owner can remove contributors
   - Returns `(ok true)` on success, or an error if the caller is not the owner or if the contributor doesn't exist

3. `is-contributor (capsule-id uint) (contributor principal) -> bool`
   - Checks if an address is a contributor to a specific capsule
   - Returns `true` if the address is a contributor, `false` otherwise

4. `initialize-capsule (capsule-id uint) -> (response bool uint)`
   - Initializes a new capsule with the sender as the owner
   - Primarily used for testing purposes
   - Returns `(ok true)` on success, or an error if the capsule already exists

### Private Functions

1. `is-owner (capsule-id uint) -> bool`
   - Checks if the transaction sender is the owner of the specified capsule
   - Used internally to enforce ownership checks

## Error Codes

- `ERR-NOT-OWNER (err u100)`: Returned when a non-owner tries to perform an owner-only action
- `ERR-ALREADY-CONTRIBUTOR (err u101)`: Returned when trying to add an existing contributor
- `ERR-NOT-CONTRIBUTOR (err u102)`: Returned when trying to remove a non-existent contributor

## Usage Examples

1. Adding a contributor:

   ```clarity
   (contract-call? .capsule-contribution-management add-contributor u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
   ```

2. Removing a contributor:

   ```clarity
   (contract-call? .capsule-contribution-management remove-contributor u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
   ```

3. Checking if an address is a contributor:

   ```clarity
   (contract-call? .capsule-contribution-management is-contributor u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
   ```

## Security Considerations

- Only capsule owners can add or remove contributors
- The contract includes checks to prevent duplicate additions or removals of contributors
- Ensure proper access control when integrating this contract with other systems.
