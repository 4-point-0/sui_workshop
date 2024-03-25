// Define a module for creating and managing polls within the Sui blockchain.
module workshop_voting::voting {
    // Import necessary libraries and modules.
    use std::string::{String,utf8};
    use sui::object::{Self, UID, ID};
    use sui::table::{Self,Table};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::vector;
    use sui::display;
    use sui::package;

    // Constants used for the creation of an "I voted" NFT.
    const NAME: vector<u8> = b"I voted";
    const DESCRIPTION: vector<u8> = b"There was a poll and I was brave enough to state my opinion(anonymously lol)";
    const URL: vector<u8> = b"https://media.istockphoto.com/id/1204426739/vector/i-voted-sticker-with-us-american-flag.jpg?s=612x612&w=0&k=20&c=Qe88b5NShFhgGczuYJSXWyOFNUhoPnMg3tDyWUAo69o=";
    
    // An error code indicating that a user has already voted.
    const EALREADY_VOTED: u64 = 1;
    // An error code indicating that the poll was closed
    const EPOLL_CLOSED: u64 = 2;
    // An error code indicating that the options vector is empty
    const MISSING_OPTION: u64 = 3;
    // An error code indicating that the option is invalid 
    const VALID_OPTION: u64 = 3;

    // A struct representing a single poll, containing its details and voting data.
    struct Poll has key{
        id: UID, // Unique identifier of the poll.
        question: String, // The question being asked in the poll.
        options: vector<String>, // The options that can be voted on.
        vote_counts: vector<u64>, // A count of votes for each option.
        votes: Table<String,u64>, // A mapping of voters to their selected options.
        isActive: bool // Flag indicating whether the poll is active or closed.
    }
    // A struct representing a collection of polls.
    struct PollCollection has key{
        id: UID,
        poll_collection: vector<ID>, // Vector storing the identifiers of polls in the collection.
    }

    // A struct representing an NFT given as a reward for voting.
    struct NFT has key, store{
        id: UID,
        name: String,
        descripton: String,
        image_url: String
    }

    //One-time Witness
    struct VOTING has drop {}

     // Initializes the voting module, setting up necessary display and permissions.
    fun init(otw:VOTING,ctx: &mut TxContext) {
        // Define display fields for NFTs.
        let keys = vector[
          utf8(b"name"),
          utf8(b"image_url"),
          utf8(b"description"),
        ];

        let values = vector[
          utf8(b"{name}"),
          utf8(b"{image_url}"),
          utf8(b"{description}"),
        ];

        // Claim the package and initialize display settings for NFTs.
        let publisher = package::claim(otw, ctx);
        let display = display::new_with_fields<NFT>(
            &publisher, keys, values, ctx
        );

        // Update display version and transfer ownership of publisher and display.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));

        // Create a new poll collection and transfer ownership.
        transfer::transfer(PollCollection {
            id: object::new(ctx),
            poll_collection: vector[],
        }, tx_context::sender(ctx));
    }

    // Creates a new poll with specified details and adds it to a poll collection.
    public entry fun createPoll(question: String, options: vector<String>, poll_collection_obj: &mut PollCollection,ctx: &mut TxContext):bool{
        // Check if options vector is not empty
        if (vector::length(&options) == 0) {
            abort(MISSING_OPTION); // Arbitrary error code
        }

        // Initialize vote counters for each option.
        let options_len = vector::length(&options);
        let vote_counts = vector::empty<u64>();
        let i = 0;
        while (i < options_len) {
            vector::push_back(&mut vote_counts, 0);
            i = i + 1;
        };


        // Create a new Poll instance and add it to the collection.
        let poll = Poll{
            id: object::new(ctx),
            question: question,
            options: options,
            votes: table::new(ctx),
            vote_counts: vote_counts,
            isActive: true,
        };
        vector::push_back(&mut poll_collection_obj.poll_collection, object::id(&poll));
        transfer::transfer(poll, tx_context::sender(ctx));

        //This is here for devInspect show
        true
    }

    // Records a vote for a specific option in a poll, ensuring each voter can only vote once.
    public entry fun registerVote(poll: &mut Poll, option:u64, name:String, ctx: &mut TxContext){
        // Check if the voter has already voted and abort if so.
        if (table::contains(&poll.votes, name)) {
            abort(EALREADY_VOTED)
        };
        // Check if poll is active and abort if not.
        if (!poll.isActive){
            abort(EPOLL_CLOSED)
        };
        // Check if option is valid
        if (option >= vector::length(&poll.options)) {
            abort(VALID_OPTION); // Arbitrary error code
        }

         // Record the new vote and update the corresponding vote count.
        table::add(&mut poll.votes, name, option);
        let current_count = vector::borrow_mut(&mut poll.vote_counts, option);
        *current_count = *current_count + 1;


        // Create and transfer an NFT to the voter as a reward for participating.
        let nft = NFT {
            id: object::new(ctx),
            name: utf8(NAME),
            descripton: utf8(DESCRIPTION),
            image_url:utf8(URL)
        };
        transfer::transfer(nft, tx_context::sender(ctx));
    }

    // Allows changing the active status of a poll, effectively opening or closing it.
    public entry fun changePollStatus(poll: &mut Poll, status: bool){
        poll.isActive = status;
    }

    // Retrieves the current vote counts for each option in a poll. Also for devInspect or dryRun display
    public entry fun getPollVotes(poll: &Poll): vector<u64> {
        poll.vote_counts
    }

}