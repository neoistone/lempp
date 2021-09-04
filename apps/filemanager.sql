-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Sep 04, 2021 at 03:52 PM
-- Server version: 10.3.31-MariaDB
-- PHP Version: 7.4.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------

--
-- Table structure for table `filemanager_users`
--

CREATE TABLE `filemanager_users` (
  `id` int(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `passsword` text NOT NULL,
  `home_dir` varchar(255) NOT NULL,
  `status` enum('active','suspend') NOT NULL DEFAULT 'active',
  `domain` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `filemanager_users`
--

INSERT INTO `filemanager_users` (`id`, `username`, `passsword`, `home_dir`, `status`, `domain`) VALUES
(1, 'neoistone', 'b5cc3a21a6e91f69ee96b7fe07d0320313e6b8a5', '/var/www/neoistone', 'active', 'neoistone.com'),
(2, 'hostingaro', 'b5cc3a21a6e91f69ee96b7fe07d0320313e6b8a5', '/var/www/hostingaro', 'active', 'hostingaro.com'),
(3, 'avd', 'b5cc3a21a6e91f69ee96b7fe07d0320313e6b8a5', '/var/www/avd', 'active', 'avdsecuritysolutions.com'),
(4, 'others', 'b5cc3a21a6e91f69ee96b7fe07d0320313e6b8a5', '/var/www/others', 'active', 'api.neoistone.com'),
(6, 'kishore', 'b5cc3a21a6e91f69ee96b7fe07d0320313e6b8a5', '/var/www/others/kishore', 'active', 'hosting.tamiltechkey.xyz');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `filemanager_users`
--
ALTER TABLE `filemanager_users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `filemanager_users`
--
ALTER TABLE `filemanager_users`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
