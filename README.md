![Voting System Interface](assets/image.png)

# Sui Voting System Workshop

This workshop is centered around a Move contract, designed to facilitate a voting system on the Sui blockchain. Accompanying the contract is a script enabling the execution of on-chain methods.

The contract serves as a foundation to explore various key concepts of blockchain development within the Sui ecosystem, such as object ownership, Table data structures, error handling, and NFT (Non-Fungible Token) lifecycle, including creation and display mechanisms. The workshop is crafted to provide a educational experience, bridging the gap between theoretical knowledge and practical application in blockchain technology.

Through this workshop, participants will gain hands-on experience with the Sui blockchain's unique features, empowering them with the skills to build decentralized applications (dApps).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Methods](#methods)

## Prerequisites

Ensure you have the following installed:

- **Sui CLI**: The command-line interface for interacting with the Sui blockchain. Installation instructions can be found in the [Sui documentation](https://docs.sui.io/build/install).

- **Node.js**: The runtime environment for executing JavaScript code server-side. You can download and install it from the [official Node.js website](https://nodejs.org/). (IF YOU PLAN ON USING THE SCRIPT)

- **Git**: Version control system to clone the repository. Install from [git-scm.com](https://git-scm.com/) if it's not already available on your system.

### Usage

1. **Clone the Repository**: Obtain a copy of the source code on your local machine.

   ```bash
   git clone https://github.com/4-point-0/sui_workshop.git
   ```

2. **Publish the Smart Contract**: Publish the package.

   ```bash
   sui client publish --gas-budget <BUDGET_VALUE> --skip-dependency-verification
   ```

3. **Use Node script OR CLI to invoke methods**: Use the Node script or CLI to invoke the on-chain methods

   CLI usage:

   ```bash
   sui client call --package <PACKAGE> --module <MODULE> --function <FUNCTION_NAME> --args <ARGUMENTS> --gas-budget <BUDGET>
   ```

   Node script usage:

   **GO AND CHANGE THE VALUES (addresses, packages etc.) IN METHODS BEFORE USING**

   1. Go to script folder and install dependencies

   ```bash
   cd scripts
   ```

   ```bash
   npm i
   ```

   2. Call a method via the script

   ```bash
   node script.js <METHOD_NAME>
   ```

## Methods

The Sui Voting System contract provides a set of callable methods to interact with the polling system on the Sui blockchain. Below are the primary methods and their descriptions:

### `createPoll`

- **Description**: This method allows a user to create a new poll with a specified question and a list of options.
- **Parameters**:
  - `question`: A `String` representing the poll's question.
  - `options`: A `vector<String>` representing the different choices available in the poll.

### `registerVote`

- **Description**: Cast a vote in an active poll and receive an "I voted" NFT as a reward.

- **Parameters**:
  - `poll`: A reference to the active `Poll` object.
  - `option`: A `u64` index of the selected option from the poll.
  - `name`: A `String` representing the voter's identity. (would be an wallet address, but for workshop simplicity we left this as a name string)

### `changePollStatus`

- **Description**: Change the active status of a poll to either open or close it to further voting.

- **Parameters**:
  - `poll`: A mutable reference to the `Poll` object.
  - `status`: A `bool` flag representing the desired status (`true` for open, `false` for closed).

### `getPollVotes`

- **Description**: Retrieve the current tally of votes for each option in a poll. (only for devInspect or dryRun through script)

- **Parameters**:
  - `poll`: A mutable reference to the `Poll` object.
