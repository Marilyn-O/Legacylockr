## capsule creation and capsule storage

---

## Overview

The **Capsule Storage** smart contract is designed to create and manage digital time capsules. Users can store various media, set unlock dates, and manage the visibility of their capsules in a decentralized manner. This contract supports functions for capsule creation, retrieval, status updates, and visibility management.

## Features

### 1. Capsule Creation

- Users can create a new capsule by providing:
  - Unlock date
  - Media links (e.g., photos, videos)
  - Contributors (participants who can access or contribute to the capsule)
  - Public or private visibility status
- Upon creation, the contract assigns a unique ID to each capsule and stores all relevant information securely.

### 2. Capsule Retrieval

- Users can retrieve capsule data using the capsule ID.
- The retrieved data includes:
  - Owner's address
  - Unlock date
  - Media links
  - List of contributors
  - Visibility status (public/private)
  - Current status (active, unlocked, archived)

### 3. Capsule Status Management

- Users can update the status of their capsules:
  - **ACTIVE**: The capsule is active and can be accessed.
  - **UNLOCKED**: The capsule has been unlocked and can be accessed by contributors.
  - **ARCHIVED**: The capsule is archived and no longer active.
- Status updates are restricted to the owner of the capsule to maintain security.

### 4. Public/Private Visibility Management

- Users can control the visibility of their capsules:
  - **PUBLIC**: The capsule can be viewed by anyone.
  - **PRIVATE**: The capsule is restricted to specified contributors only.
- Visibility updates are also restricted to the owner, ensuring control over who can view the capsule.

### 5. Event Logging

- The contract emits events upon the creation of capsules, enabling front-end applications to react to state changes in real-time.

## Technical Specifications

### Data Structures

- **Capsule Map**: Stores capsule data with capsule ID as the key.
  - `owner`: Principal address of the capsule creator.
  - `unlock-date`: Timestamp for when the capsule can be accessed.
  - `media-links`: List of media links associated with the capsule.
  - `contributors`: List of principals who can access the capsule.
  - `public-status`: Indicates whether the capsule is public or private.
  - `status`: Current status of the capsule (ACTIVE, UNLOCKED, ARCHIVED).

### Constants

- **Status Values**:
  - `ACTIVE` (u0)
  - `UNLOCKED` (u1)
  - `ARCHIVED` (u2)

- **Visibility Values**:
  - `PUBLIC` (u0)
  - `PRIVATE` (u1)

### Key Functions

- **create-capsule**: Creates a new time capsule with specified parameters.
- **get-capsule**: Retrieves capsule data by capsule ID.
- **update-capsule-status**: Updates the current status of the capsule.
- **update-public-status**: Changes the visibility of the capsule between public and private.

## Conclusion

The Capsule Storage smart contract provides a robust and secure platform for managing digital time capsules. By leveraging the capabilities of Clarity and the Stacks blockchain, users can ensure that their digital memories are preserved and managed in a decentralized manner.
