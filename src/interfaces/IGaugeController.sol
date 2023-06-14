pragma solidity >=0.7.0 <0.9.0;

interface IGaugeController {
    event CommitOwnership(address admin);
    event ApplyOwnership(address admin);
    event AddType(string name, int128 type_id);
    event NewTypeWeight(int128 type_id, uint256 time, uint256 weight, uint256 total_weight);
    event NewGaugeWeight(address gauge_address, uint256 time, uint256 weight, uint256 total_weight);
    event VoteForGauge(uint256 time, address user, address gauge_addr, uint256 weight);
    event NewGauge(address addr, int128 gauge_type, uint256 weight);

    function commit_transfer_ownership(address addr) external;

    function apply_transfer_ownership() external;

    function gauge_types(address _addr) external view returns (int128);

    function add_gauge(address addr, int128 gauge_type) external;

    function add_gauge(address addr, int128 gauge_type, uint256 weight) external;

    function checkpoint() external;

    function checkpoint_gauge(address addr) external;

    function gauge_relative_weight(address addr) external view returns (uint256);

    function gauge_relative_weight(address addr, uint256 time) external view returns (uint256);

    function gauge_relative_weight_write(address addr) external returns (uint256);

    function gauge_relative_weight_write(address addr, uint256 time) external returns (uint256);

    function add_type(string memory _name) external;

    function add_type(string memory _name, uint256 weight) external;

    function change_type_weight(int128 type_id, uint256 weight) external;

    function change_gauge_weight(address addr, uint256 weight) external;

    function vote_for_gauge_weights(address _gauge_addr, uint256 _user_weight) external;

    function get_gauge_weight(address addr) external view returns (uint256);

    function get_type_weight(int128 type_id) external view returns (uint256);

    function get_total_weight() external view returns (uint256);

    function get_weights_sum_per_type(int128 type_id) external view returns (uint256);

    function admin() external view returns (address);

    function future_admin() external view returns (address);

    function token() external view returns (address);

    function voting_escrow() external view returns (address);

    function n_gauge_types() external view returns (int128);

    function n_gauges() external view returns (int128);

    function gauge_type_names(int128 arg0) external view returns (string memory);

    function gauges(uint256 arg0) external view returns (address);

    function vote_user_slopes(address arg0, address arg1) external view returns (uint256 slope, uint256 power, uint256 end);

    function vote_user_power(address arg0) external view returns (uint256);

    function last_user_vote(address arg0, address arg1) external view returns (uint256);

    function points_weight(address arg0, uint256 arg1) external view returns (uint256 bias, uint256 slope);

    function time_weight(address arg0) external view returns (uint256);

    function points_sum(int128 arg0, uint256 arg1) external view returns (uint256 bias, uint256 slope);

    function time_sum(uint256 arg0) external view returns (uint256);

    function points_total(uint256 arg0) external view returns (uint256);

    function time_total() external view returns (uint256);

    function points_type_weight(int128 arg0, uint256 arg1) external view returns (uint256);

    function time_type_weight(uint256 arg0) external view returns (uint256);
}