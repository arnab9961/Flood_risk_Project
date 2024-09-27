-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 27, 2024 at 08:15 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `flood_risk_db2`
--

-- --------------------------------------------------------

--
-- Table structure for table `donations`
--

CREATE TABLE `donations` (
  `donation_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `donor_name` varchar(255) NOT NULL,
  `timestamp` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `donations`
--

INSERT INTO `donations` (`donation_id`, `type`, `amount`, `donor_name`, `timestamp`) VALUES
(1, 'money', 1.00, 'Arnab', '2024-09-27 16:56:28'),
(2, 'money', 10000.00, 'Rafiun', '2024-09-27 16:56:28'),
(3, 'money', 200000.00, 'Rafiun', '2024-09-27 16:57:00'),
(4, 'money', 1.00, 'Rafiun', '2024-09-27 16:59:47'),
(5, 'money', 200000.00, 'Arif', '2024-09-27 17:00:22'),
(6, 'money', 200.00, 'Arif', '2024-09-27 17:02:12'),
(7, 'money', 600000.00, 'Arnab', '2024-09-27 22:10:25');

-- --------------------------------------------------------

--
-- Table structure for table `equipment`
--

CREATE TABLE `equipment` (
  `equipment_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `status` enum('Available','In Use','Maintenance') NOT NULL,
  `team_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evacuation_centers`
--

CREATE TABLE `evacuation_centers` (
  `center_id` int(11) NOT NULL,
  `location` text NOT NULL,
  `capacity` int(11) NOT NULL,
  `current_occupancy` int(11) NOT NULL,
  `location_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `evacuation_centers`
--

INSERT INTO `evacuation_centers` (`center_id`, `location`, `capacity`, `current_occupancy`, `location_id`) VALUES
(1, 'Dhaka Convention Hall', 100, 50, 1),
(2, 'Chittagong Convention Hall', 300, 250, 2),
(3, 'Dhaka Central Evacuation Center', 1000, 500, 3),
(4, 'Chattogram Evacuation Center', 800, 200, 4),
(5, 'Sylhet Emergency Shelter', 600, 300, 5),
(6, 'Khulna Flood Shelter', 750, 400, 6),
(7, 'Barishal Relief Center', 500, 250, 7),
(8, 'Rajshahi Temporary Shelter', 300, 100, 8),
(9, 'Bogra Evacuation Center', 450, 200, 9),
(10, 'Rangpur Relief Camp', 700, 350, 10),
(11, 'Mymensingh Evacuation Center', 550, 280, 11),
(12, 'Narayanganj Disaster Shelter', 900, 600, 12);

-- --------------------------------------------------------

--
-- Table structure for table `flood_reports`
--

CREATE TABLE `flood_reports` (
  `id` int(11) NOT NULL,
  `upazilla` varchar(255) NOT NULL,
  `needs` varchar(255) NOT NULL,
  `contact_details` varchar(255) DEFAULT NULL,
  `location_details` text DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `status` enum('Processing','Resolved') DEFAULT 'Processing',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `location_id` int(11) DEFAULT NULL,
  `flood_zone` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flood_reports`
--

INSERT INTO `flood_reports` (`id`, `upazilla`, `needs`, `contact_details`, `location_details`, `source`, `status`, `created_at`, `updated_at`, `location_id`, `flood_zone`) VALUES
(3, 'Dhaka', 'asd', '134', 'asd', 'asd', 'Resolved', '2024-09-27 11:20:36', '2024-09-27 11:37:12', NULL, 'Zone 1'),
(6, 'Dhaka', 'food', '123', 'sfd', '123', 'Processing', '2024-09-27 15:56:53', '2024-09-27 15:56:53', NULL, 'Zone 5'),
(11, 'Tangail', 'food', 'asd', 'asd', 'asd', 'Resolved', '2024-09-27 17:17:21', '2024-09-27 17:20:00', NULL, 'Zone 1');

-- --------------------------------------------------------

--
-- Table structure for table `flood_zones`
--

CREATE TABLE `flood_zones` (
  `id` int(11) NOT NULL,
  `zone_name` varchar(255) NOT NULL,
  `risk_level` enum('Low','Moderate','High') NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `flood_zones`
--

INSERT INTO `flood_zones` (`id`, `zone_name`, `risk_level`, `description`, `created_at`) VALUES
(1, 'Dhaka', 'High', 'Highly flood-prone area with heavy rainfall during monsoon', '2024-09-25 02:00:53'),
(2, 'Chittagong', 'Moderate', 'Moderate risk due to coastal proximity', '2024-09-25 02:00:53'),
(3, 'Sylhet', 'Low', 'Low flood risk but prone to flash floods in some areas', '2024-09-25 02:00:53');

-- --------------------------------------------------------

--
-- Table structure for table `locations`
--

CREATE TABLE `locations` (
  `location_id` int(11) NOT NULL,
  `address` varchar(255) NOT NULL,
  `risk_level` enum('Low','Moderate','High') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `locations`
--

INSERT INTO `locations` (`location_id`, `address`, `risk_level`) VALUES
(1, 'Dhaka', 'Low'),
(2, 'Chittagong', 'High'),
(3, 'Dhaka, Mirpur', 'High'),
(4, 'Chattogram, Cox\'s Bazar', 'Moderate'),
(5, 'Sylhet, Jaintiapur', 'High'),
(6, 'Khulna, Satkhira', 'High'),
(7, 'Barishal, Babuganj', 'Moderate'),
(8, 'Rajshahi, Godagari', 'Low'),
(9, 'Bogra, Sherpur', 'Moderate'),
(10, 'Rangpur, Pirganj', 'Low'),
(11, 'Mymensingh, Gaffargaon', 'Moderate'),
(12, 'Narayanganj, Siddhirganj', 'High');

-- --------------------------------------------------------

--
-- Table structure for table `rescue_teams`
--

CREATE TABLE `rescue_teams` (
  `team_id` int(11) NOT NULL,
  `team_name` varchar(255) NOT NULL,
  `base_location` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `response_actions`
--

CREATE TABLE `response_actions` (
  `id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `action_taken` text NOT NULL,
  `response_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `response_actions`
--

INSERT INTO `response_actions` (`id`, `report_id`, `action_taken`, `response_by`, `created_at`) VALUES
(3, 3, 'Assisted by Volunteer ID 1', '1', '2024-09-27 16:44:14'),
(4, 3, 'Assisted by Volunteer ID 3', '3', '2024-09-27 16:46:12'),
(5, 3, 'Assisted by Volunteer ID 3', '3', '2024-09-27 16:46:15'),
(6, 3, 'Assisted by Volunteer ID 2', '2', '2024-09-27 16:46:17'),
(7, 3, 'Assisted by Volunteer ID 3', '3', '2024-09-27 16:46:21'),
(10, 3, 'Assisted by Volunteer ID 1', '1', '2024-09-27 17:04:11'),
(11, 6, 'Assisted by Volunteer ID 1', '1', '2024-09-27 17:50:36'),
(12, 11, 'Assisted by Volunteer ID 1', '1', '2024-09-27 17:50:40'),
(13, 11, 'Assisted by Volunteer ID 3', '3', '2024-09-27 17:50:45');

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `staff_id` int(11) NOT NULL,
  `department` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `volunteers`
--

CREATE TABLE `volunteers` (
  `volunteer_id` int(11) NOT NULL,
  `availability` varchar(255) NOT NULL,
  `skills` varchar(255) DEFAULT NULL,
  `contact_info` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `volunteers`
--

INSERT INTO `volunteers` (`volunteer_id`, `availability`, `skills`, `contact_info`) VALUES
(1, 'Available', 'working', '123'),
(2, 'Available', 'working', '123'),
(3, 'Available', 'working', '123');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `donations`
--
ALTER TABLE `donations`
  ADD PRIMARY KEY (`donation_id`);

--
-- Indexes for table `equipment`
--
ALTER TABLE `equipment`
  ADD PRIMARY KEY (`equipment_id`),
  ADD KEY `team_id` (`team_id`);

--
-- Indexes for table `evacuation_centers`
--
ALTER TABLE `evacuation_centers`
  ADD PRIMARY KEY (`center_id`),
  ADD KEY `location_id` (`location_id`);

--
-- Indexes for table `flood_reports`
--
ALTER TABLE `flood_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `location_id` (`location_id`);

--
-- Indexes for table `flood_zones`
--
ALTER TABLE `flood_zones`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `locations`
--
ALTER TABLE `locations`
  ADD PRIMARY KEY (`location_id`);

--
-- Indexes for table `rescue_teams`
--
ALTER TABLE `rescue_teams`
  ADD PRIMARY KEY (`team_id`);

--
-- Indexes for table `response_actions`
--
ALTER TABLE `response_actions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `report_id` (`report_id`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`staff_id`);

--
-- Indexes for table `volunteers`
--
ALTER TABLE `volunteers`
  ADD PRIMARY KEY (`volunteer_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `donations`
--
ALTER TABLE `donations`
  MODIFY `donation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `equipment`
--
ALTER TABLE `equipment`
  MODIFY `equipment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `evacuation_centers`
--
ALTER TABLE `evacuation_centers`
  MODIFY `center_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `flood_reports`
--
ALTER TABLE `flood_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `flood_zones`
--
ALTER TABLE `flood_zones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `locations`
--
ALTER TABLE `locations`
  MODIFY `location_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `rescue_teams`
--
ALTER TABLE `rescue_teams`
  MODIFY `team_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `response_actions`
--
ALTER TABLE `response_actions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `volunteers`
--
ALTER TABLE `volunteers`
  MODIFY `volunteer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `equipment`
--
ALTER TABLE `equipment`
  ADD CONSTRAINT `equipment_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `rescue_teams` (`team_id`);

--
-- Constraints for table `evacuation_centers`
--
ALTER TABLE `evacuation_centers`
  ADD CONSTRAINT `evacuation_centers_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`);

--
-- Constraints for table `flood_reports`
--
ALTER TABLE `flood_reports`
  ADD CONSTRAINT `flood_reports_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`);

--
-- Constraints for table `response_actions`
--
ALTER TABLE `response_actions`
  ADD CONSTRAINT `response_actions_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `flood_reports` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `staff`
--
ALTER TABLE `staff`
  ADD CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `personnel` (`personnel_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
