-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 26, 2021 at 11:03 AM
-- Server version: 10.4.16-MariaDB
-- PHP Version: 7.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `progetto_covid19`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `citta_max_in_quarantena`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `citta_max_in_quarantena` (IN `tipo_lockdown` CHAR(50))  begin
drop table if exists temp1;
create temporary table temp1(citta char(50), numero_in_quarantena integer);
insert into temp1 select domicilio, count(*) from persona where domicilio in (select codice from citta where lockdown_attuale=tipo_lockdown) and cf in (select cf from paziente where obbligo_quarantena='Si') group by domicilio;
select c.codice, c.nome, c.nazione, c.lockdown_attuale, t.numero_in_quarantena from citta c join temp1 t on c.codice=t.citta where codice in (select citta from temp1 where numero_in_quarantena =(select max(numero_in_quarantena) from temp1));
end$$

DROP PROCEDURE IF EXISTS `confronto_efficacia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `confronto_efficacia` (IN `cod_miglioramento` INTEGER)  begin
SET AUTOCOMMIT=false;
start transaction;
drop table if exists temp1;
drop table if exists temp2;
drop table if exists temp3;
create temporary table temp1 (codice integer, tampone char(50), miglioria numeric(4,2), data date);
insert into temp1 select codice, tampone, miglioria, data from miglioramento where tampone = (select tampone from miglioramento where codice=cod_miglioramento) order by data;
create temporary table temp2(miglioramento_prima numeric(4,2));
insert into temp2 (select efficacia_nominale from caratteristiche_tampone where codice in(select distinct tampone from temp1));
update temp2 set miglioramento_prima = miglioramento_prima -(select sum(miglioria) from temp1 where data>=(select data from temp1 where codice=cod_miglioramento));
create temporary table temp3(miglioramento_dopo numeric(4,2) default 0);
insert into temp3 select miglioramento_prima from temp2;
update temp3 set miglioramento_dopo=miglioramento_dopo+(select miglioria from miglioramento where codice=cod_miglioramento);
update caratteristiche_tampone set efficacia_nominale=(select miglioramento_prima from temp2) where codice = (select distinct tampone from temp1);
select * from caratteristiche_tampone where codice = (select distinct tampone from temp1);
update caratteristiche_tampone set efficacia_nominale=(select miglioramento_dopo from temp3) where codice = (select distinct tampone from temp1);
select * from caratteristiche_tampone where codice = (select distinct tampone from temp1);
rollback;
SET AUTOCOMMIT=true;
end$$

DROP PROCEDURE IF EXISTS `decessi_e_positivi_in_lockdown`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `decessi_e_positivi_in_lockdown` (IN `tipo_lockdown` CHAR(50))  begin
drop table if exists temp1;
drop table if exists temp2;
create temporary table temp1(CF integer, domicilio char(10), data_decesso date);
insert into temp1 select cf, domicilio, data_decesso from persona where domicilio in (select distinct citta from storico_lockdown where lockdown=tipo_lockdown) and decesso_COVID19='Si';
select * from persona where cf in (select t.cf from temp1 t left join storico_lockdown s on t.domicilio=s.citta where t.data_decesso between s.data_inizio and s.data_fine);
create temporary table temp2(domicilio char(10));
insert into temp2 select domicilio from persona where cf in (select t.cf from temp1 t left join storico_lockdown s on t.domicilio=s.citta where t.data_decesso between s.data_inizio and s.data_fine) group by domicilio;
select cf, nome, cognome, domicilio from persona where cf in(select cf from paziente where condiz_attuale='Positivo') and domicilio in (select * from temp2 where domicilio in(select codice from citta where lockdown_attuale=tipo_lockdown));
end$$

DROP PROCEDURE IF EXISTS `laboratorio_migliore`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `laboratorio_migliore` ()  begin
drop table if exists temp1;
create temporary table temp1(lab integer, max_esito integer);
insert into temp1 select lab_analisi, max(risultato) from esito group by lab_analisi;
select * from lab_analisi l join temp1 t on l.codice=t.lab where t.max_esito in(select max(max_esito) from temp1);
end$$

DROP PROCEDURE IF EXISTS `media_tamponi_paziente_periodo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `media_tamponi_paziente_periodo` (IN `inizio` DATE, IN `fine` DATE, OUT `media` NUMERIC(6,2))  begin
drop table if exists temp1;
drop table if exists temp2;
create temporary table temp1 (paziente integer, num_tamponi_periodo integer);
insert into temp1 select paziente, count(*) from full_tampone where data_effettuaz between inizio and fine group by paziente;
create temporary table temp2(paziente integer, n_tamponi_periodo integer);
insert into temp2 select t.paziente, coalesce(n.num_tamponi_periodo, '0') as num_tamponi_periodo from tampone_eseguito t left join temp1 n on t.paziente=n.paziente group by t.paziente;
select avg(n_tamponi_periodo) as numero_medio_tamponi_fatti_da_paziente_nel_periodo into media from temp2;
end$$

DROP PROCEDURE IF EXISTS `monitorare_nulli_efficienzaPS`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `monitorare_nulli_efficienzaPS` (IN `efficienza` INTEGER)  begin
drop table if exists temp1;
create temporary table temp1(ente char(50), numero_nulli integer);
insert into temp1 select t.ente, count(*) from tampone_eseguito t right join esito e on (e.tampone=t.codice and e.tipo_tampone=t.tipo_tampone) where risultato<10 group by ente;
select e.codice, e.nome, s.efficienza_PS, t1.numero_nulli from ente_covid19 e, struttura_ente s, temp1 t1 where e.codice=s.codice and t1.ente=e.codice and s.efficienza_PS<efficienza;
end$$

DROP PROCEDURE IF EXISTS `positivi_totali_nel_periodo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `positivi_totali_nel_periodo` (IN `inizio` DATE, IN `fine` DATE, OUT `totale` INTEGER, OUT `positivi` INTEGER)  begin
drop table if exists temp1;
create temporary table temp1 (codice integer, tampone char(50), esito numeric(4,2));
insert into temp1 select codice, tampone, esito from full_tampone_plus where (codice, tampone, data_esito) in(select codice, tampone, max(data_esito) from full_tampone_plus group by codice, tampone)and data_effettuaz between inizio and fine group by codice, tampone;
select count(*) into totale from temp1;
select count(*) into positivi from temp1 where esito>50;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `azienda_controllo`
--

DROP TABLE IF EXISTS `azienda_controllo`;
CREATE TABLE `azienda_controllo` (
  `Codice` int(11) NOT NULL,
  `nome` char(50) NOT NULL,
  `indirizzo` char(50) NOT NULL,
  `sede` char(8) NOT NULL,
  `ente_controllato` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `azienda_controllo`
--

INSERT INTO `azienda_controllo` (`Codice`, `nome`, `indirizzo`, `sede`, `ente_controllato`) VALUES
(1, 'Dictum Institute', '136-969 Enim St.', 'WW', 44),
(2, 'Libero Est Congue PC', '9695 Diam Street', '016', 57),
(3, 'Massa Vestibulum Accumsan Incorporated', '131-6088 Eget, Ave', 'LA', 56),
(4, 'Lorem Luctus Ut Consulting', '2420 Congue, Avenue', '733', 48),
(5, 'Leo Cras Foundation', '1753 Arcu Street', 'PPL', NULL),
(6, 'Nunc Foundation', 'Ap #161-4793 Blandit Road', 'MAD', 46),
(7, 'Magna Phasellus Dolor Associates', 'Ap #867-7752 Dictum Av.', 'PORT', 54),
(8, 'Non Magna Corporation', 'P.O. Box 740, 1900 Aliquet, Rd.', 'LIO', NULL),
(9, 'Dictum Eu Limited', 'P.O. Box 960, 467 Nunc Road', 'IZ', 45),
(10, 'Suspendisse Aliquet LLP', 'Ap #388-6866 Semper Ave', 'DESD', 53),
(11, 'Euismod Et Foundation', '863-1779 Tellus, Avenue', 'MI', 66),
(12, 'Convallis Company', '7848 Mattis Road', '016', 64),
(13, 'Sed Industries', '1695 Amet St.', 'CRAK', 67),
(14, 'Elit Curabitur Consulting', 'P.O. Box 483, 4415 Ornare, Avenue', '112', NULL),
(15, 'Nec Diam Duis Inc.', '772-6586 Id St.', 'PORT', 41),
(16, 'Duis Associates', '969-1947 Malesuada Rd.', 'WW', 42),
(17, 'Pharetra Ut PC', '790-506 At St.', 'REN', NULL),
(18, 'Curabitur Consequat Lectus LLC', '1546 Sit Street', '112', 43),
(19, 'Quis Turpis LLC', 'P.O. Box 745, 5194 Natoque Rd.', 'DESD', NULL),
(20, 'At Libero Morbi Industries', '843-5808 Justo Av.', '112', 73),
(21, 'Mus Proin Vel Company', 'Ap #335-5454 Fringilla St.', 'NIZ', NULL),
(22, 'Pede Cras Ltd', '8156 Tincidunt, Av.', 'MAD', NULL),
(23, 'Magna Phasellus Dolor Company', 'Ap #573-8946 Placerat Ave', 'DIG', 59),
(24, 'Iaculis Enim Corporation', 'Ap #360-5762 Sed Rd.', '113', 47),
(25, 'Per Company', '173-2724 Malesuada Rd.', 'NIZ', NULL),
(26, 'Adipiscing Lacus Ut Inc.', 'P.O. Box 253, 5722 Quam Avenue', 'NA', 51),
(27, 'Consectetuer LLP', '619-1804 Tempor Street', 'BAR', 50),
(28, 'Metus Vitae Velit LLP', 'Ap #349-441 In Av.', 'MI', 52),
(29, 'Nulla Corporation', 'P.O. Box 489, 8675 In St.', 'DESD', 49),
(30, 'Mus Aenean Eget Consulting', '825-9762 Nec Rd.', 'CT', NULL),
(31, 'Aliquet Magna LLC', '4511 Lacus Av.', 'NA', 63),
(32, 'Tempor Lorem Eget Inc.', 'Ap #219-8142 Aliquet Rd.', 'NY', 62),
(33, 'Ligula Donec Luctus Company', '191-1713 Velit Av.', 'AVI', 60);

-- --------------------------------------------------------

--
-- Table structure for table `caratteristiche_tampone`
--

DROP TABLE IF EXISTS `caratteristiche_tampone`;
CREATE TABLE `caratteristiche_tampone` (
  `Codice` char(60) NOT NULL,
  `Tipo` char(50) NOT NULL,
  `Analisi` char(50) NOT NULL,
  `Attuazione` char(50) NOT NULL,
  `Efficacia_nominale` decimal(4,2) NOT NULL,
  `Struttura` enum('Rigido','Flessibile') NOT NULL,
  `Efficacia_reale` decimal(4,2) NOT NULL DEFAULT 0.00
) ;

--
-- Dumping data for table `caratteristiche_tampone`
--

INSERT INTO `caratteristiche_tampone` (`Codice`, `Tipo`, `Analisi`, `Attuazione`, `Efficacia_nominale`, `Struttura`, `Efficacia_reale`) VALUES
('2-Plex', 'Molecolare', 'RT-PCR', 'Naso-Faringeo', '75.00', 'Rigido', '73.50'),
('Anti-SARS-CoV-2_NCP', 'Siero', 'Analisi del sangue', 'Prelievo', '77.10', 'Rigido', '75.60'),
('Lumipulse_G_SARS-CoV-2_Ag', 'Siero', 'Chemiluminescenza', 'Prelievo', '74.15', 'Flessibile', '74.65'),
('PrimeStore_MTM', 'Molecolare', 'RT-PCR', 'Naso-Faringeo', '92.72', 'Flessibile', '93.22'),
('YIG-AN-0010', 'Siero', 'Analisi del sangue', 'Prelievo', '82.31', 'Flessibile', '82.81'),
('YIG-GM-0010', 'Siero rapido', 'Analisi del sangue', 'Prelievo', '73.10', 'Flessibile', '73.60');

--
-- Triggers `caratteristiche_tampone`
--
DROP TRIGGER IF EXISTS `aggiorna_efficacia_reale_insert`;
DELIMITER $$
CREATE TRIGGER `aggiorna_efficacia_reale_insert` BEFORE INSERT ON `caratteristiche_tampone` FOR EACH ROW begin
set new.efficacia_reale = (case
when new.struttura='Rigido' then new.efficacia_nominale-1.5
when new.struttura='Flessibile' then new.efficacia_nominale+0.5
end);
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `aggiorna_efficacia_reale_update`;
DELIMITER $$
CREATE TRIGGER `aggiorna_efficacia_reale_update` BEFORE UPDATE ON `caratteristiche_tampone` FOR EACH ROW begin
set new.efficacia_reale = (case
when new.struttura='Rigido' then new.efficacia_nominale-1.5
when new.struttura='Flessibile' then new.efficacia_nominale+0.5
end);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `caratteristiche_tecnica`
--

DROP TABLE IF EXISTS `caratteristiche_tecnica`;
CREATE TABLE `caratteristiche_tecnica` (
  `Nome` char(50) NOT NULL,
  `Luogo` char(50) NOT NULL,
  `Test` char(50) NOT NULL,
  `Costo` int(11) NOT NULL
) ;

--
-- Dumping data for table `caratteristiche_tecnica`
--

INSERT INTO `caratteristiche_tecnica` (`Nome`, `Luogo`, `Test`, `Costo`) VALUES
('Cromatografia', 'Laboratorio Biologico', 'Rivealare sostanza eluita', 43),
('Dicroismo Circolare', 'Laboratorio Chimico', 'Polarizzazione Luce', 63),
('Elettroforesi', 'Vuoto', 'Ellettrificazione Gomma', 23),
('Elettroporazione', 'Bolla di Greiman', 'Scarica elettrica su DNA', 443),
('Northem Blot', 'Laboratorio Chimico', 'Denaturazione RNA', 78),
('Sequenziamento DNA', 'Laboratorio Chimico', 'Terminatori di catena', 93),
('Spettroscopia', 'Vuoto', 'Diffusione e rifrazione', 11);

-- --------------------------------------------------------

--
-- Table structure for table `citta`
--

DROP TABLE IF EXISTS `citta`;
CREATE TABLE `citta` (
  `codice` char(5) NOT NULL,
  `nome` char(50) NOT NULL,
  `nazione` char(50) NOT NULL,
  `lockdown_attuale` char(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `citta`
--

INSERT INTO `citta` (`codice`, `nome`, `nazione`, `lockdown_attuale`) VALUES
('012', 'Hong Kong', 'China', 'Totale'),
('013', 'Whuan', 'China', 'Totale'),
('016', 'Yunnigo', 'China', 'Totale'),
('112', 'Philadelphia', 'US', 'Weekend'),
('113', 'Washington', 'US', 'Giornaliero'),
('733', 'Las Vegas', 'US', NULL),
('ADAN', 'Adana', 'Turchia', 'Weekend'),
('AVI', 'Avila', 'Spagna', 'Weekend'),
('BAR', 'Barcelona', 'Spagna', 'Weekend'),
('BOR', 'Bordeaux', 'Francia', NULL),
('CRAK', 'Cracow', 'Polonia', 'Giornaliero'),
('CT', 'Catania', 'Italia', 'Giornaliero'),
('DESD', 'Dresda', 'Germania', NULL),
('DIG', 'Digione', 'Francia', 'Giornaliero'),
('DORT', 'Dortmund', 'Germania', 'Totale'),
('IST', 'Istanbul', 'Turchia', 'Giornaliero'),
('IZ', 'Izmir', 'Turchia', 'Giornaliero'),
('KIELC', 'Kielce', 'Polonia', 'Giornaliero'),
('LA', 'Latina', 'Italia', NULL),
('LIO', 'Lione', 'Francia', 'Giornaliero'),
('LISB', 'Lisboa', 'Portogallo', 'Weekend'),
('LZ', 'Lodz', 'Polonia', 'Giornaliero'),
('MAD', 'Madrid', 'Spagna', 'Totale'),
('ME', 'Messina', 'Italia', 'Giornaliero'),
('MI', 'Milano', 'Italia', 'Giornaliero'),
('NA', 'Napoli', 'Italia', 'Weekend'),
('NIZ', 'Nizza', 'Francia', 'Weekend'),
('NY', 'New York', 'US', NULL),
('PA', 'Palermo', 'Italia', 'Weekend'),
('PORT', 'Porto', 'Portogallo', 'Giornaliero'),
('PPL', 'Pamplona', 'Spagna', 'Totale'),
('REN', 'Rennes', 'Francia', 'Giornaliero'),
('RO', 'Roma', 'Italia', 'Totale'),
('STR', 'Strasburg', 'Francia', 'Giornaliero'),
('TRAB', 'Trabzon', 'Turchia', 'Giornaliero'),
('VIGO', 'Vigo', 'Spagna', NULL),
('WW', 'Wolfsburg', 'Germania', 'Totale');

-- --------------------------------------------------------

--
-- Table structure for table `ente_covid19`
--

DROP TABLE IF EXISTS `ente_covid19`;
CREATE TABLE `ente_covid19` (
  `Codice` int(11) NOT NULL,
  `Nome` char(50) NOT NULL,
  `Sede` char(8) NOT NULL,
  `indirizzo` char(50) NOT NULL,
  `Tipo` enum('Ospedale','Centro Privato') NOT NULL,
  `Controllore` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `ente_covid19`
--

INSERT INTO `ente_covid19` (`Codice`, `Nome`, `Sede`, `indirizzo`, `Tipo`, `Controllore`) VALUES
(41, 'Cursus Nunc Mauris Hospital', 'WW', 'P.O. Box 120, 4859 Facilisis, Rd.', 'Ospedale', 15),
(42, 'Sed Leo Cras Centre', '113', '838-7264 Tempus St.', 'Centro Privato', 16),
(43, 'Nec Mollis Vitae', 'PORT', 'P.O. Box 964, 5672 Elementum, Street', 'Ospedale', 18),
(44, 'Elit Dictum Eu Hospital', 'NY', 'Ap #129-1732 Consectetuer Rd.', 'Ospedale', 1),
(45, 'Eleifend Hospital', 'IST', '686-3689 Nisl. Ave', 'Ospedale', 9),
(46, 'Enim Etiam Hospital', 'NA', 'P.O. Box 241, 7038 Parturient Av.', 'Ospedale', 6),
(47, 'Iaculis Odio Hospital', 'IST', 'Ap #726-7839 Sapien. Street', 'Ospedale', 24),
(48, 'Ipsum', '733', '8360 Ut Rd.', 'Ospedale', 4),
(49, 'Vehicula Hospital', 'PORT', 'Ap #145-8506 Sem Street', 'Ospedale', 29),
(50, 'Vulputate Medical Centre', 'IST', 'Ap #775-8949 Dictum Rd.', 'Centro Privato', 27),
(51, 'Sabanci Policlinic', 'IST', 'Ap #833-1414 Dignissim Av.', 'Ospedale', 26),
(52, 'Lectus Convallis Policlinic', 'TRAB', 'P.O. Box 230, 9691 Pede, Rd.', 'Ospedale', 28),
(53, 'Felis Centre', '016', '6533 Dui. Street', 'Centro Privato', 10),
(54, 'Enim Diam Institute', 'DESD', 'Ap #751-8367 Curabitur Street', 'Centro Privato', 7),
(56, 'Besiktas Hastane', 'IST', '1605 Cras Street', 'Ospedale', 3),
(57, 'Aliquam Vulputate Hospital', '113', 'Ap #773-4120 Sagittis. St.', 'Ospedale', 2),
(59, 'Tincidunt Neque Hospital', '113', '429-7640 Tempor Rd.', 'Ospedale', 23),
(60, 'Nullam Consulting', 'NIZ', '9664 Mauris St.', 'Centro Privato', 33),
(62, 'Eu Institute', 'LA', 'P.O. Box 827, 7096 Tristique Road', 'Centro Privato', 32),
(63, 'Lione Hospitale', 'LIO', '929-2975 Ligula. Street', 'Ospedale', 31),
(64, 'Non Limited', 'DORT', '142-5503 Sit Av.', 'Centro Privato', 12),
(66, 'Policlinico della Sapienza', 'RO', 'Ap #224-7613 Sed Avenue', 'Ospedale', 11),
(67, 'Lisboa Ospitau', 'LISB', '911-1748 Nulla Rd.', 'Ospedale', 13),
(68, 'Semper Tellus Hospital', 'PORT', 'Ap #782-2145 Magna St.', 'Ospedale', NULL),
(70, 'Urna Incorporated', '016', 'Ap #353-2849 Est. Road', 'Centro Privato', NULL),
(71, 'Et Netus LLP', 'LISB', 'P.O. Box 971, 5031 Libero. Avenue', 'Centro Privato', NULL),
(73, 'Fusce Hospital', 'IST', 'Ap #705-5468 Proin Rd.', 'Ospedale', 20),
(74, 'Nulla Hospital', 'WW', 'P.O. Box 280, 5358 Nullam St.', 'Ospedale', NULL),
(75, 'Augue Porttitor PC', 'AVI', '1275 Nunc Ave', 'Centro Privato', NULL),
(76, 'Nam Corporation', '013', '311 Nullam Road', 'Centro Privato', NULL),
(78, 'Non Lorem Vitae LLP', 'AVI', '4157 Dui, Av.', 'Centro Privato', NULL),
(79, 'Parturient Montes Nascetur Company', 'NY', '9173 At Rd.', 'Centro Privato', NULL),
(80, 'Tempor Bibendum LLC', 'DIG', 'P.O. Box 263, 1168 Donec Av.', 'Centro Privato', NULL);

--
-- Triggers `ente_covid19`
--
DROP TRIGGER IF EXISTS `aggiorna_controllore`;
DELIMITER $$
CREATE TRIGGER `aggiorna_controllore` AFTER INSERT ON `ente_covid19` FOR EACH ROW begin
if(new.controllore is not null)
then
update azienda_controllo
set ente_controllato = new.codice
where codice=new.controllore;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `aggiorna_controllore_update`;
DELIMITER $$
CREATE TRIGGER `aggiorna_controllore_update` AFTER UPDATE ON `ente_covid19` FOR EACH ROW begin
if(new.controllore is not null)
then
update azienda_controllo
set ente_controllato = new.codice
where codice=new.controllore;
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `esito`
--

DROP TABLE IF EXISTS `esito`;
CREATE TABLE `esito` (
  `Tampone` int(11) NOT NULL,
  `Tipo_tampone` char(60) NOT NULL,
  `Lab_analisi` int(11) NOT NULL,
  `data_e` date NOT NULL,
  `Risultato` decimal(4,2) NOT NULL
) ;

--
-- Dumping data for table `esito`
--

INSERT INTO `esito` (`Tampone`, `Tipo_tampone`, `Lab_analisi`, `data_e`, `Risultato`) VALUES
(2, '2-Plex', 4700, '2021-02-20', '98.00'),
(2, '2-Plex', 4700, '2021-12-11', '99.00'),
(2, '2-Plex', 4700, '2022-02-20', '33.00'),
(2, '2-Plex', 4700, '2022-02-21', '12.00'),
(3, '2-Plex', 4700, '2021-06-24', '99.00'),
(6, '2-Plex', 4700, '2020-08-26', '67.00'),
(6, '2-Plex', 4701, '2020-08-20', '97.00'),
(6, '2-Plex', 4701, '2020-08-27', '27.00'),
(6, '2-Plex', 4702, '2020-08-27', '37.00'),
(6, '2-Plex', 4702, '2020-08-28', '57.00'),
(6, '2-Plex', 4703, '2020-08-28', '27.00'),
(6, '2-Plex', 4703, '2020-08-29', '27.00'),
(7, '2-Plex', 4705, '2020-10-26', '97.00'),
(11, 'Lumipulse_G_SARS-CoV-2_Ag', 4709, '2020-06-25', '57.00'),
(12, 'PrimeStore_MTM', 4706, '2020-06-17', '97.00'),
(15, '2-Plex', 4706, '2020-07-17', '97.00'),
(17, 'YIG-AN-0010', 4702, '2020-07-07', '56.00'),
(18, 'Anti-SARS-CoV-2_NCP', 4708, '2020-09-23', '47.00'),
(19, 'Anti-SARS-CoV-2_NCP', 4708, '2020-07-25', '97.00'),
(20, 'Anti-SARS-CoV-2_NCP', 4707, '2020-07-03', '37.00'),
(22, '2-Plex', 4700, '2020-05-26', '67.00'),
(23, 'Lumipulse_G_SARS-CoV-2_Ag', 4709, '2020-10-25', '87.00'),
(24, 'YIG-AN-0010', 4701, '2020-07-25', '17.00'),
(25, 'PrimeStore_MTM', 4703, '2020-08-07', '23.00'),
(30, 'YIG-GM-0010', 4709, '2020-09-29', '67.00'),
(32, 'YIG-GM-0010', 4708, '2020-09-15', '17.00'),
(34, '2-Plex', 4705, '2020-05-26', '97.00'),
(34, 'PrimeStore_MTM', 4703, '2020-12-07', '23.00'),
(35, 'PrimeStore_MTM', 4706, '2020-11-27', '23.00'),
(36, 'PrimeStore_MTM', 4703, '2020-07-07', '23.00'),
(38, 'YIG-AN-0010', 4701, '2020-07-27', '17.00'),
(39, 'Anti-SARS-CoV-2_NCP', 4708, '2020-11-23', '7.00'),
(39, 'Anti-SARS-CoV-2_NCP', 4709, '2020-11-26', '27.00'),
(41, 'Anti-SARS-CoV-2_NCP', 4706, '2020-06-25', '97.00'),
(41, 'YIG-GM-0010', 4709, '2020-07-29', '17.00'),
(43, '2-Plex', 4704, '2020-11-26', '97.00'),
(45, 'Lumipulse_G_SARS-CoV-2_Ag', 4708, '2020-06-30', '17.00'),
(45, 'Lumipulse_G_SARS-CoV-2_Ag', 4709, '2020-05-30', '87.00'),
(47, 'Lumipulse_G_SARS-CoV-2_Ag', 4708, '2020-07-30', '57.00'),
(48, 'Anti-SARS-CoV-2_NCP', 4708, '2020-09-23', '37.00'),
(48, 'Lumipulse_G_SARS-CoV-2_Ag', 4708, '2020-05-30', '17.00'),
(52, 'PrimeStore_MTM', 4703, '2020-12-07', '23.00'),
(53, 'YIG-AN-0010', 4702, '2020-11-27', '1.00'),
(54, '2-Plex', 4705, '2020-10-26', '97.00'),
(54, 'YIG-AN-0010', 4702, '2020-08-27', '17.00'),
(60, 'Anti-SARS-CoV-2_NCP', 4708, '2020-06-23', '7.00'),
(63, 'YIG-AN-0010', 4702, '2020-08-30', '56.00'),
(64, 'PrimeStore_MTM', 4705, '2020-07-17', '97.00'),
(65, 'Lumipulse_G_SARS-CoV-2_Ag', 4709, '2020-09-30', '47.00'),
(67, 'Anti-SARS-CoV-2_NCP', 4700, '2021-04-12', '1.00'),
(67, 'Anti-SARS-CoV-2_NCP', 4708, '2020-04-23', '77.00'),
(69, 'Anti-SARS-CoV-2_NCP', 4708, '2020-07-23', '77.00'),
(70, 'PrimeStore_MTM', 4706, '2020-07-17', '97.00'),
(71, 'Lumipulse_G_SARS-CoV-2_Ag', 4702, '2020-10-30', '7.00'),
(74, 'Lumipulse_G_SARS-CoV-2_Ag', 4700, '2021-04-12', '2.00'),
(74, 'Lumipulse_G_SARS-CoV-2_Ag', 4702, '2020-09-30', '27.00'),
(75, '2-Plex', 4705, '2020-06-29', '97.00'),
(77, 'PrimeStore_MTM', 4705, '2020-11-17', '97.00'),
(80, 'YIG-AN-0010', 4702, '2020-10-27', '16.00'),
(81, 'PrimeStore_MTM', 4703, '2020-11-07', '83.00'),
(89, '2-Plex', 4702, '2020-08-26', '87.00'),
(89, '2-Plex', 4705, '2020-08-26', '67.00'),
(94, 'Anti-SARS-CoV-2_NCP', 4708, '2020-08-23', '37.00'),
(94, 'Lumipulse_G_SARS-CoV-2_Ag', 4709, '2020-06-25', '17.00'),
(96, 'YIG-GM-0010', 4702, '2020-11-25', '97.00'),
(97, '2-Plex', 4705, '2020-06-26', '97.00'),
(99, 'YIG-AN-0010', 4702, '2020-05-30', '78.00'),
(99, 'YIG-GM-0010', 4708, '2020-08-05', '7.00'),
(100, '2-Plex', 4701, '2020-05-26', '37.00'),
(219, '2-Plex', 4700, '2021-12-12', '22.00'),
(225, '2-Plex', 4700, '2021-12-12', '12.00'),
(229, '2-Plex', 4700, '2021-12-12', '11.00');

--
-- Triggers `esito`
--
DROP TRIGGER IF EXISTS `aggiorna_condizione_paziente`;
DELIMITER $$
CREATE TRIGGER `aggiorna_condizione_paziente` BEFORE INSERT ON `esito` FOR EACH ROW begin

update paziente
set condiz_attuale = (case
when (new.risultato>50)
then 'Positivo'
when (new.risultato between 10 and 50)
then 'Negativo'
when (new.risultato <10)
then 'Attesa ri-effettuazione'
end)
where CF = (select paziente from tampone_eseguito where (paziente, data_effettuazione) in(select paziente, max(data_effettuazione) from tampone_eseguito group by paziente) and codice=new.tampone and tipo_tampone=new.tipo_tampone)
and(
new.data_e>(select data_e from esito where (tampone, tipo_tampone,data_e) in(select tampone, tipo_tampone, max(data_e) from esito group by tampone, tipo_tampone) and tampone=new.tampone and tipo_tampone=new.tipo_tampone group by data_e) or not exists(select * from esito where new.tampone=tampone and new.tipo_tampone=tipo_tampone))
;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `aggiorna_condizione_paziente_update`;
DELIMITER $$
CREATE TRIGGER `aggiorna_condizione_paziente_update` BEFORE UPDATE ON `esito` FOR EACH ROW begin

update paziente
set condiz_attuale = (case
when (new.risultato>50)
then 'Positivo'
when (new.risultato between 10 and 50)
then 'Negativo'
when (new.risultato <10)
then 'Attesa ri-effettuazione'
end)
where CF = (select paziente from tampone_eseguito where (paziente, data_effettuazione) in(select paziente, max(data_effettuazione) from tampone_eseguito group by paziente) and codice=new.tampone and tipo_tampone=new.tipo_tampone)
and(
new.data_e>=(select data_e from esito where (tampone, tipo_tampone,data_e) in(select tampone, tipo_tampone, max(data_e) from esito group by tampone, tipo_tampone) and tampone=new.tampone and tipo_tampone=new.tipo_tampone group by data_e) or not exists(select * from esito where new.tampone=tampone and new.tipo_tampone=tipo_tampone))
;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `data_esito_insert`;
DELIMITER $$
CREATE TRIGGER `data_esito_insert` BEFORE INSERT ON `esito` FOR EACH ROW begin
declare msg char(255);
set msg = concat('Non e stato effettuato un tampone ', new.tipo_tampone, ' alla data ', new.data_e);
if(new.data_e<(select data_effettuazione from tampone_eseguito where new.tampone=codice and new.tipo_tampone=tipo_tampone))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `data_esito_update`;
DELIMITER $$
CREATE TRIGGER `data_esito_update` BEFORE UPDATE ON `esito` FOR EACH ROW begin
declare msg char(255);
set msg = concat('Non e stato effettuato un tampone ', new.tipo_tampone, ' alla data ', new.data_e);
if(new.data_e<(select data_effettuazione from tampone_eseguito where new.tampone=codice and new.tipo_tampone=tipo_tampone))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `risultato_esito`;
DELIMITER $$
CREATE TRIGGER `risultato_esito` BEFORE INSERT ON `esito` FOR EACH ROW begin
declare msg char(255);
set msg = 'Il risultato inserito non risulta tra 0 e 99.99';
if(new.risultato not between 0 and 99.99)
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `risultato_esito_update`;
DELIMITER $$
CREATE TRIGGER `risultato_esito_update` BEFORE UPDATE ON `esito` FOR EACH ROW begin
declare msg char(255);
set msg = 'Il risultato inserito non risulta tra 0 e 99.99';
if(new.risultato not between 0 and 99.99)
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `full_tampone`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `full_tampone`;
CREATE TABLE `full_tampone` (
`codice` int(11)
,`tampone` char(60)
,`prod` char(60)
,`tipo` char(50)
,`analisi` char(50)
,`attuazione` char(50)
,`e_nominal` decimal(4,2)
,`struttura` enum('Rigido','Flessibile')
,`e_reale` decimal(4,2)
,`creazione` date
,`data_effettuaz` date
,`operatore` int(11)
,`paziente` int(11)
,`ente` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `full_tampone_plus`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `full_tampone_plus`;
CREATE TABLE `full_tampone_plus` (
);

-- --------------------------------------------------------

--
-- Table structure for table `lab_analisi`
--

DROP TABLE IF EXISTS `lab_analisi`;
CREATE TABLE `lab_analisi` (
  `codice` int(11) NOT NULL,
  `nome` char(50) NOT NULL,
  `indirizzo` char(50) NOT NULL,
  `sede` char(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `lab_analisi`
--

INSERT INTO `lab_analisi` (`codice`, `nome`, `indirizzo`, `sede`) VALUES
(4700, 'Interdum Analysis', 'P.O. Box 695, 2908 Metus. Road', '112'),
(4701, 'Mauris Ut Mi Analysis', 'P.O. Box 611, 6621 Ligula. Road', 'DORT'),
(4702, 'Phasellus Dapibus Quam Analysis', '3993 Condimentum. Road', 'WW'),
(4703, 'Sit Analysis', 'Ap #769-2172 Ultrices Street', 'LISB'),
(4704, 'Eu Analysis', '3613 Orci Rd.', '012'),
(4705, 'Dui Nec PC', '297-7996 At, Avenue', 'WW'),
(4706, 'Cursus Et Eros Analysis', 'P.O. Box 443, 8793 Morbi Av.', 'DORT'),
(4707, 'Lobortis Ultrices Vivamus PC', '286-6299 Curabitur St.', '113'),
(4708, 'Elementum Analysis', 'P.O. Box 761, 8115 Donec St.', 'KIELC'),
(4709, 'In Magna Phasellus Analysis', 'Ap #324-8334 A, Road', 'BOR'),
(4710, 'Pellentesque Sed PC', '142-1562 Congue Av.', '013'),
(4711, 'Nam Ltd', 'Ap #764-2525 Magna. Rd.', 'IST');

-- --------------------------------------------------------

--
-- Table structure for table `lockdown`
--

DROP TABLE IF EXISTS `lockdown`;
CREATE TABLE `lockdown` (
  `tipo` char(30) NOT NULL,
  `orario_inizio_coprifuoco` time NOT NULL,
  `orario_fine_coprifuoco` time NOT NULL,
  `numero_giorni_settimana_lockdown` int(11) NOT NULL
) ;

--
-- Dumping data for table `lockdown`
--

INSERT INTO `lockdown` (`tipo`, `orario_inizio_coprifuoco`, `orario_fine_coprifuoco`, `numero_giorni_settimana_lockdown`) VALUES
('Giornaliero', '22:00:00', '05:00:00', 7),
('Totale', '00:00:00', '24:00:00', 7),
('Weekend', '13:00:00', '05:00:00', 3);

-- --------------------------------------------------------

--
-- Table structure for table `miglioramento`
--

DROP TABLE IF EXISTS `miglioramento`;
CREATE TABLE `miglioramento` (
  `codice` int(11) NOT NULL,
  `tampone` char(60) NOT NULL,
  `team` char(5) NOT NULL,
  `tecnica` char(50) NOT NULL,
  `miglioria` decimal(4,2) NOT NULL,
  `data` date NOT NULL
) ;

--
-- Dumping data for table `miglioramento`
--

INSERT INTO `miglioramento` (`codice`, `tampone`, `team`, `tecnica`, `miglioria`, `data`) VALUES
(759, 'PrimeStore_MTM', 'LS032', 'Elettroforesi', '1.56', '2020-12-19'),
(63177, 'PrimeStore_MTM', 'HSCII', 'Dicroismo Circolare', '-0.14', '2020-10-03'),
(63178, 'Anti-SARS-CoV-2_NCP', 'KSAKL', 'Dicroismo Circolare', '-0.32', '2020-08-14'),
(63179, 'YIG-AN-0010', '74DSS', 'Northem Blot', '-0.14', '2020-09-03'),
(63180, 'PrimeStore_MTM', '78BSJ', 'Sequenziamento DNA', '0.89', '2020-11-13'),
(63184, 'Lumipulse_G_SARS-CoV-2_Ag', 'OIACS', 'Northem Blot', '-9.10', '2020-09-05'),
(63201, 'Lumipulse_G_SARS-CoV-2_Ag', '09DHJ', 'Dicroismo Circolare', '0.41', '2020-05-30'),
(63202, 'YIG-AN-0010', '74DSS', 'Dicroismo Circolare', '-0.59', '2020-11-04'),
(63203, 'Anti-SARS-CoV-2_NCP', 'HSCII', 'Sequenziamento DNA', '0.24', '2020-07-08'),
(63204, 'Lumipulse_G_SARS-CoV-2_Ag', 'KSAKL', 'Cromatografia', '0.41', '2020-07-30'),
(63205, 'PrimeStore_MTM', '3FJHD', 'Spettroscopia', '5.76', '2020-09-22'),
(63206, 'Anti-SARS-CoV-2_NCP', '111SS', 'Dicroismo Circolare', '0.00', '2020-10-31'),
(63207, 'YIG-AN-0010', 'HJSCS', 'Elettroporazione', '0.59', '2020-07-16'),
(63208, 'YIG-AN-0010', 'SING1', 'Sequenziamento DNA', '-0.14', '2020-04-30'),
(63209, 'YIG-GM-0010', '78BSJ', 'Sequenziamento DNA', '12.12', '2020-08-01'),
(63210, 'Lumipulse_G_SARS-CoV-2_Ag', 'JFWWO', 'Sequenziamento DNA', '0.89', '2020-10-31'),
(63211, '2-Plex', '111SS', 'Elettroforesi', '0.36', '2020-04-30'),
(63212, 'PrimeStore_MTM', 'HJSCS', 'Cromatografia', '0.56', '2020-05-27'),
(63213, 'YIG-GM-0010', 'HJSCS', 'Sequenziamento DNA', '-5.32', '2020-10-17'),
(63214, 'Anti-SARS-CoV-2_NCP', 'LS032', 'Elettroporazione', '-0.32', '2020-05-31'),
(63215, '2-Plex', 'HSCII', 'Northem Blot', '7.47', '2020-06-08'),
(63216, '2-Plex', 'HSCII', 'Elettroforesi', '-8.41', '2020-09-17');

--
-- Triggers `miglioramento`
--
DROP TRIGGER IF EXISTS `data_miglioramento_insert`;
DELIMITER $$
CREATE TRIGGER `data_miglioramento_insert` BEFORE INSERT ON `miglioramento` FOR EACH ROW begin
declare msg char(255);
set msg = concat('Il tampone ', new.tampone, ' non risulta nel database alla data ', new.data);
if(new.data<(select data_creazione from tampone where new.tampone=codice))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `data_miglioramento_update`;
DELIMITER $$
CREATE TRIGGER `data_miglioramento_update` BEFORE UPDATE ON `miglioramento` FOR EACH ROW begin
declare msg char(255);
set msg = concat('Il tampone ', new.tampone, ' non risulta nel database alla data ', new.data);
if(new.data<(select data_creazione from tampone where new.tampone=codice))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `miglioria_insert`;
DELIMITER $$
CREATE TRIGGER `miglioria_insert` AFTER INSERT ON `miglioramento` FOR EACH ROW update caratteristiche_tampone
set efficacia_nominale=efficacia_nominale+new.miglioria
where codice=new.tampone
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `miglioria_update`;
DELIMITER $$
CREATE TRIGGER `miglioria_update` AFTER UPDATE ON `miglioramento` FOR EACH ROW update caratteristiche_tampone
set efficacia_nominale=(efficacia_nominale+new.miglioria)-old.miglioria
where codice=new.tampone
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `operatore`
--

DROP TABLE IF EXISTS `operatore`;
CREATE TABLE `operatore` (
  `CF` int(11) NOT NULL,
  `Matricola` int(11) DEFAULT NULL,
  `Qualifica` char(50) NOT NULL,
  `anni_servizio` int(11) NOT NULL
) ;

--
-- Dumping data for table `operatore`
--

INSERT INTO `operatore` (`CF`, `Matricola`, `Qualifica`, `anni_servizio`) VALUES
(118, 731500, 'Infermiere', 2),
(120, 731514, 'Guardia Medica', 14),
(121, 731497, 'Guardia Medica', 7),
(124, 731494, 'Infermiere', 27),
(128, 731490, 'Infermiere', 7),
(129, 731493, 'Infermiere', 14),
(130, 731513, 'Guardia Medica', 12),
(131, 731515, 'Guardia Medica', 8),
(132, 731518, 'Medico', 28),
(137, 731505, 'Medico', 19),
(138, 731520, 'Medico', 30),
(139, 731510, 'Ausiliario', 22),
(140, 731492, 'Infermiere', 15),
(145, 731501, 'Medico', 8),
(147, 731495, 'Guardia Medica', 14),
(149, 731498, 'Infermiere', 12),
(153, 731496, 'Infermiere', 2),
(159, 731516, 'Guardia Medica', 7),
(163, 731511, 'Medico', 6),
(165, 731489, 'Guardia Medica', 21),
(174, 731523, 'Guardia Medica', 6),
(178, 731504, 'Medico', 8),
(186, 731506, 'Medico', 14),
(187, 731507, 'Ausiliario', 26),
(189, 731499, 'Infermiere', 26),
(190, 731509, 'Ausiliario', 18),
(193, 731508, 'Medico', 22),
(194, 731525, 'Guardia Medica', 24),
(196, 731527, 'Infermiere', 28),
(206, 731502, 'Medico', 7),
(208, 731524, 'Guardia Medica', 2),
(210, 731503, 'Guardia Medica', 27),
(213, 731491, 'Guardia Medica', 25);

-- --------------------------------------------------------

--
-- Table structure for table `paziente`
--

DROP TABLE IF EXISTS `paziente`;
CREATE TABLE `paziente` (
  `CF` int(11) NOT NULL,
  `condiz_attuale` enum('Negativo','Positivo','Attesa ri-effettuazione','Attesa esito') NOT NULL DEFAULT 'Attesa esito',
  `obbligo_quarantena` enum('Si','No') NOT NULL DEFAULT 'No'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `paziente`
--

INSERT INTO `paziente` (`CF`, `condiz_attuale`, `obbligo_quarantena`) VALUES
(181, 'Positivo', 'Si'),
(183, 'Positivo', 'Si'),
(184, 'Attesa ri-effettuazione', 'No'),
(185, 'Positivo', 'Si'),
(186, 'Negativo', 'No'),
(188, 'Negativo', 'No'),
(189, 'Positivo', 'Si'),
(190, 'Positivo', 'Si'),
(191, 'Positivo', 'Si'),
(193, 'Positivo', 'Si'),
(194, 'Negativo', 'No'),
(197, 'Positivo', 'Si'),
(199, 'Negativo', 'No'),
(200, 'Negativo', 'No'),
(201, 'Negativo', 'No'),
(207, 'Positivo', 'Si'),
(208, 'Negativo', 'No'),
(210, 'Negativo', 'No'),
(212, 'Positivo', 'Si'),
(213, 'Attesa ri-effettuazione', 'No'),
(215, 'Positivo', 'Si'),
(217, 'Positivo', 'Si'),
(218, 'Negativo', 'No'),
(219, 'Attesa ri-effettuazione', 'No'),
(221, 'Positivo', 'Si');

--
-- Triggers `paziente`
--
DROP TRIGGER IF EXISTS `quarantena`;
DELIMITER $$
CREATE TRIGGER `quarantena` BEFORE UPDATE ON `paziente` FOR EACH ROW begin
set new.obbligo_quarantena = (case
when new.condiz_attuale='Positivo'
then 'Si'
when new.condiz_attuale='Negativo'
then 'No'
when new.condiz_attuale='Attesa esito'
then 'No'
when new.condiz_attuale='Attesa ri-effettuazione'
then 'No'
end);
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `quarantena_insert`;
DELIMITER $$
CREATE TRIGGER `quarantena_insert` BEFORE INSERT ON `paziente` FOR EACH ROW begin
set new.obbligo_quarantena = (case
when new.condiz_attuale='Positivo'
then 'Si'
when new.condiz_attuale='Negativo'
then 'No'
when new.condiz_attuale='Attesa esito'
then 'No'
when new.condiz_attuale='Attesa ri-effettuazione'
then 'No'
end);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `persona`
--

DROP TABLE IF EXISTS `persona`;
CREATE TABLE `persona` (
  `CF` int(11) NOT NULL,
  `Nome` char(50) NOT NULL,
  `Cognome` char(50) NOT NULL,
  `Data_nascita` date NOT NULL,
  `email` char(50) NOT NULL,
  `Indirizzo` char(30) NOT NULL,
  `Domicilio` char(5) NOT NULL,
  `data_decesso` date DEFAULT NULL,
  `decesso_COVID19` enum('Si','No') DEFAULT NULL
) ;

--
-- Dumping data for table `persona`
--

INSERT INTO `persona` (`CF`, `Nome`, `Cognome`, `Data_nascita`, `email`, `Indirizzo`, `Domicilio`, `data_decesso`, `decesso_COVID19`) VALUES
(118, 'Luke', 'Anthony', '1972-06-18', 'libero.dui@Fusce.co.uk', '4280 Ut St.', '012', '2020-08-01', 'Si'),
(119, 'Chester', 'Cunningham', '2000-06-07', 'et.commodo.at@eros.com', '146-1936 Fermentum St.', 'CT', '2020-05-10', 'Si'),
(120, 'Hayfa', 'Lloyd', '1952-02-12', 'montes@euismod.co.uk', 'P.O. Box 244, 8303 Lorem Rd.', 'ME', '2020-07-19', 'No'),
(121, 'Ann', 'Wooten', '1988-04-06', 'tristique.ac@rutrumFusce.com', 'Ap #627-5361 Eu Avenue', 'IST', '2020-09-15', 'Si'),
(122, 'Fleur', 'Rodriquez', '1957-12-13', 'at.augue.id@lacus.co.uk', 'Ap #327-7493 Purus, Road', 'LA', NULL, NULL),
(123, 'Sierra', 'Hoover', '1967-06-14', 'lectus.sit.amet@luctusaliquet.com', 'P.O. Box 347, 2292 Per St.', '016', NULL, NULL),
(124, 'Chava', 'Gillespie', '1997-10-29', 'ac.urna.Ut@odioauctorvitae.co.uk', '727-3232 Nulla. Ave', 'TRAB', NULL, NULL),
(125, 'Zachary', 'Guthrie', '1979-12-25', 'fames.ac.turpis@Inornaresagittis.org', '362-2626 Cursus Rd.', 'NA', '2020-09-19', 'Si'),
(126, 'Hasad', 'Mosley', '1980-11-12', 'faucibus.lectus@malesuada.ca', '3609 Adipiscing Street', 'MI', '2020-09-30', 'No'),
(127, 'Eugenia', 'Gonzales', '1973-02-02', 'Integer.vitae.nibh@Donecconsectetuermauris.edu', 'P.O. Box 878, 9369 Penatibus A', 'CRAK', '2020-04-12', 'Si'),
(128, 'Guy', 'Cox', '1968-10-30', 'In.ornare@aliquam.edu', '870-5362 Feugiat Rd.', 'TRAB', '2020-11-01', 'Si'),
(129, 'Tyrone', 'Floyd', '2004-01-06', 'amet.ultricies@orciluctus.net', '6347 In St.', '112', NULL, NULL),
(130, 'Sean', 'Stout', '2001-07-30', 'commodo.ipsum@Cras.ca', '3945 Dui. Road', '112', NULL, NULL),
(131, 'Sonia', 'Sykes', '1984-04-06', 'sagittis.augue@adipiscing.co.uk', '2880 Molestie Rd.', 'PA', NULL, NULL),
(132, 'Ivor', 'Pennington', '1989-09-01', 'id@posuereenim.net', 'P.O. Box 254, 8342 Rutrum Rd.', 'TRAB', NULL, NULL),
(133, 'Stacy', 'Gonzales', '1988-12-08', 'elit.fermentum.risus@feugiatLorem.co.uk', 'P.O. Box 503, 5336 Morbi Rd.', 'BOR', NULL, NULL),
(134, 'Sasha', 'Bass', '1983-03-19', 'eu.dolor@Integertinciduntaliquam.org', 'Ap #378-309 Tincidunt, Rd.', 'BOR', NULL, NULL),
(135, 'Glenna', 'Santiago', '1962-11-20', 'leo.elementum@euismod.ca', '934-9066 Lobortis Street', 'STR', '2020-09-09', 'Si'),
(136, 'Zeph', 'Bryan', '1970-10-27', 'enim.non.nisi@ac.org', 'P.O. Box 180, 2966 Blandit Str', '113', '2020-12-12', 'No'),
(137, 'Cameron', 'Love', '1982-08-18', 'pede@egestasblandit.co.uk', 'Ap #451-5715 Nullam Rd.', 'NA', NULL, NULL),
(138, 'Calvin', 'Talley', '1990-12-08', 'est.mauris.rhoncus@libero.ca', '6775 Sem Road', 'LIO', NULL, NULL),
(139, 'Otto', 'Shepherd', '1962-02-05', 'ante.iaculis.nec@Etiamlaoreet.org', '231-9075 Id, Ave', '733', '2020-07-10', 'Si'),
(140, 'Phillip', 'Schroeder', '1959-11-06', 'lacus.Quisque@nectempus.com', 'Ap #809-4951 Rhoncus Avenue', 'CRAK', NULL, NULL),
(141, 'Odysseus', 'Frazier', '1949-11-24', 'aliquam@augue.edu', 'Ap #871-179 Egestas, St.', 'DESD', NULL, NULL),
(142, 'Allen', 'Woodard', '1958-10-04', 'malesuada@sapienCras.edu', '4303 In Road', 'NY', NULL, NULL),
(143, 'Ronan', 'Sullivan', '2006-07-17', 'aliquet@Uttinciduntvehicula.ca', '102 Arcu. Rd.', 'IZ', NULL, NULL),
(144, 'India', 'Carpenter', '1996-12-25', 'ultrices@Cras.co.uk', 'P.O. Box 309, 9160 Feugiat Str', 'BOR', NULL, NULL),
(145, 'Colleen', 'Blair', '1949-10-22', 'scelerisque.dui@elitEtiam.net', 'P.O. Box 354, 8623 Nec, St.', 'DORT', NULL, NULL),
(146, 'Hayfa', 'Clemons', '1989-06-25', 'hymenaeos.Mauris.ut@etipsum.org', '148-5634 Magna Road', 'IST', '2020-01-01', 'No'),
(147, 'Xena', 'Bonner', '1999-10-22', 'Donec.porttitor.tellus@Integer.org', 'Ap #929-5940 Gravida Road', 'NA', NULL, NULL),
(148, 'Inez', 'Bridges', '1985-02-18', 'bibendum.sed.est@sapienimperdietornare.net', 'Ap #514-1257 Tristique Ave', 'PA', '2019-12-30', 'No'),
(149, 'Kirby', 'Barr', '1954-02-03', 'in@laciniaSed.com', '9083 Tortor, St.', 'LIO', NULL, NULL),
(150, 'Xenos', 'Heath', '1977-10-31', 'ac@arcuVestibulum.org', 'Ap #964-4262 Sit Street', 'NY', NULL, NULL),
(151, 'Rinah', 'Burgess', '1991-02-15', 'Maecenas.iaculis@sodales.com', 'Ap #301-4034 Dolor Street', 'DIG', NULL, NULL),
(152, 'Cade', 'Tyson', '2006-10-16', 'sit.amet@aauctornon.ca', '4807 Magna. Avenue', 'MAD', NULL, NULL),
(153, 'Tucker', 'Bishop', '2001-04-30', 'purus.gravida@quis.net', '806-9232 Eget, St.', 'AVI', NULL, NULL),
(154, 'Tara', 'Farley', '1996-11-10', 'magna@ipsumsodales.edu', 'P.O. Box 590, 9835 Pharetra, S', 'NIZ', NULL, NULL),
(155, 'Sopoline', 'Marshall', '1972-09-21', 'ac.mattis@eu.co.uk', 'Ap #149-1056 Arcu. Rd.', 'NIZ', NULL, NULL),
(156, 'Shafira', 'Stanton', '1951-08-30', 'enim.condimentum@etmagnis.net', 'Ap #182-3953 Donec St.', 'REN', NULL, NULL),
(157, 'Upton', 'Mann', '1991-11-27', 'urna@nibhAliquam.org', 'P.O. Box 601, 2215 Vel St.', 'MAD', NULL, NULL),
(158, 'Ciaran', 'Richards', '1989-12-08', 'tincidunt.pede@eget.edu', 'Ap #444-3624 Consectetuer Road', 'CRAK', NULL, NULL),
(159, 'Gavin', 'Hardy', '1992-07-06', 'neque.pellentesque.massa@libero.com', 'P.O. Box 745, 4695 Dictum St.', 'LZ', '2020-12-01', 'Si'),
(160, 'Igor', 'Hurley', '1965-02-02', 'laoreet.posuere@dignissim.net', 'Ap #784-6666 Quam Avenue', '016', NULL, NULL),
(161, 'Kenneth', 'Sosa', '1989-01-22', 'volutpat.nunc.sit@Praesent.com', '3665 Sit Rd.', 'ME', NULL, NULL),
(162, 'Marny', 'Mullen', '1995-02-22', 'facilisis.facilisis.magna@ut.net', 'Ap #360-1815 Auctor Rd.', 'WW', NULL, NULL),
(163, 'Jenna', 'Roman', '1999-07-03', 'quis.urna@sedpede.ca', '4690 Sed Road', 'CRAK', NULL, NULL),
(164, 'Myra', 'Flynn', '1989-12-09', 'dapibus@Morbi.com', 'Ap #964-4500 Sed Ave', 'BAR', NULL, NULL),
(165, 'Shannon', 'Marquez', '1976-12-08', 'lobortis.quis@necante.ca', '587-3566 Suspendisse St.', 'STR', NULL, NULL),
(166, 'Julian', 'Ayala', '1961-04-16', 'dignissim.Maecenas@pellentesque.net', 'Ap #134-6005 Imperdiet Road', 'MAD', NULL, NULL),
(167, 'Bertha', 'Pugh', '1978-12-02', 'quam.dignissim.pharetra@mollisnec.net', 'P.O. Box 131, 1313 Non, Rd.', 'DORT', NULL, NULL),
(168, 'Lucius', 'Aguilar', '2001-07-15', 'cursus.luctus.ipsum@amet.com', 'Ap #928-4627 Eu Av.', '013', NULL, NULL),
(169, 'Willa', 'Barrera', '2001-04-19', 'Donec@enim.ca', 'Ap #169-213 At Rd.', 'NA', NULL, NULL),
(170, 'Whoopi', 'Short', '1975-06-18', 'rhoncus@lectus.com', 'P.O. Box 898, 9766 Mauris Stre', 'WW', NULL, NULL),
(171, 'Shaine', 'Castro', '1962-12-17', 'diam.dictum@anteiaculis.co.uk', 'P.O. Box 983, 6232 Tempus Aven', 'PA', NULL, NULL),
(172, 'Ursula', 'Merritt', '1952-11-12', 'mollis@lorem.edu', '233 Aliquet St.', 'IST', NULL, NULL),
(173, 'Joseph', 'Velasquez', '1976-02-26', 'dolor@Morbineque.net', 'P.O. Box 640, 250 Nec Rd.', 'PORT', NULL, NULL),
(174, 'Lester', 'Bolton', '1960-01-22', 'mi.pede.nonummy@Maecenasornareegestas.com', '390-6889 Elit Ave', 'WW', NULL, NULL),
(175, 'Kylynn', 'Wise', '2004-10-30', 'gravida.sit@dictumPhasellusin.ca', 'P.O. Box 297, 4091 Neque Rd.', 'NIZ', NULL, NULL),
(176, 'Hollee', 'Solomon', '1949-06-26', 'luctus@euismodurnaNullam.edu', '1060 Cras Ave', 'WW', NULL, NULL),
(177, 'Angelica', 'Ferrell', '1951-07-06', 'luctus@sociis.ca', '4861 At, Rd.', 'ME', NULL, NULL),
(178, 'Xandra', 'Reeves', '1964-06-28', 'molestie.arcu@massa.edu', '225-1521 Velit St.', 'DIG', '2020-12-07', 'Si'),
(179, 'Graiden', 'Mcleod', '2000-10-13', 'euismod.mauris@pede.co.uk', '1419 Egestas. Avenue', 'DORT', NULL, NULL),
(180, 'Emerson', 'Gamble', '1988-01-24', 'Quisque.purus@Fuscefermentum.co.uk', '384-8892 Varius. Street', 'KIELC', NULL, NULL),
(181, 'Madonna', 'Spence', '1952-09-25', 'Morbi@convalliserat.org', 'P.O. Box 770, 3243 Dolor Avenu', 'DIG', '2020-08-18', 'Si'),
(182, 'Linus', 'Shepard', '1969-07-25', 'eu.dui@sed.org', 'P.O. Box 355, 4575 Morbi Ave', 'LA', '2020-09-09', 'No'),
(183, 'Selma', 'Ellison', '1975-08-20', 'molestie@nec.net', 'Ap #340-5699 Lacinia Rd.', 'MAD', '2020-06-30', 'Si'),
(184, 'Nathan', 'Mccormick', '1954-09-17', 'dolor.Fusce.feugiat@sociisnatoque.org', 'P.O. Box 781, 5143 Egestas Ave', 'PORT', '2020-08-21', 'Si'),
(185, 'Aphrodite', 'Combs', '1949-07-14', 'faucibus.orci@tincidunt.co.uk', 'P.O. Box 972, 300 Cum Street', 'IST', '2020-11-20', 'Si'),
(186, 'Gregory', 'Leon', '1987-01-27', 'vitae.dolor@gravidamauris.net', 'P.O. Box 800, 8570 Porttitor S', 'ADAN', '2020-11-29', 'Si'),
(187, 'Kaye', 'Sanford', '1958-03-30', 'lacinia.Sed@rhoncusidmollis.edu', 'P.O. Box 589, 4466 Donec St.', 'LA', NULL, NULL),
(188, 'Gay', 'Young', '1964-10-15', 'a@aliquetodio.net', 'Ap #987-1612 Placerat Street', 'DESD', '2020-07-30', 'Si'),
(189, 'Dorothy', 'Becker', '1960-08-13', 'eu.enim@ac.net', 'P.O. Box 655, 6975 Nisl. St.', 'AVI', '2020-12-01', 'No'),
(190, 'Cecilia', 'Riddle', '1982-12-03', 'Aliquam@velit.net', '450-7467 Placerat Rd.', '016', NULL, NULL),
(191, 'Tobias', 'Hall', '2001-09-17', 'posuere@dictum.edu', 'Ap #436-9909 Eget St.', 'LIO', '2020-10-02', 'Si'),
(192, 'Hyatt', 'Wilkerson', '1998-10-22', 'feugiat.tellus@malesuadaaugueut.edu', 'Ap #208-8362 Morbi Road', 'MI', '2010-01-02', 'No'),
(193, 'Jerry', 'Livingston', '1961-01-04', 'primis.in.faucibus@nectempusscelerisque.co.uk', 'Ap #853-824 Eget Rd.', 'ME', '2020-12-10', 'Si'),
(194, 'Quinlan', 'Camacho', '1988-11-25', 'convallis@cursus.com', 'P.O. Box 271, 4668 Molestie St', 'CRAK', '2020-10-10', 'No'),
(195, 'Ayanna', 'Irwin', '1953-04-14', 'risus.Donec@cursusluctus.co.uk', 'Ap #323-8092 Amet, St.', 'BOR', NULL, NULL),
(196, 'Sean', 'Daniel', '1952-05-25', 'gravida.Praesent@sollicitudinamalesuada.ca', '936 Dolor Av.', 'ADAN', '2020-11-10', 'No'),
(197, 'Karen', 'Hayes', '1977-06-14', 'est.ac.facilisis@Phasellus.org', '3236 Quam, Ave', 'MAD', '2020-05-10', 'Si'),
(198, 'Hayes', 'Powell', '1949-12-13', 'tellus.id@placerataugueSed.net', 'P.O. Box 289, 4169 Elit, St.', 'DESD', NULL, NULL),
(199, 'Brenna', 'Vinson', '1957-09-30', 'arcu.imperdiet.ullamcorper@doloregestasrhoncus.ca', 'P.O. Box 826, 1611 Aenean Ave', 'IST', '2020-09-30', 'No'),
(200, 'Suki', 'Young', '2004-10-21', 'Duis.a.mi@musAenean.org', '292-1273 Porttitor Street', 'ADAN', NULL, NULL),
(201, 'Quamar', 'Tanner', '1972-04-02', 'Suspendisse@commodoipsumSuspendisse.com', '421-8245 Nonummy Ave', '016', NULL, NULL),
(202, 'Lester', 'Rodriguez', '1992-04-18', 'gravida.Praesent.eu@elementumsemvitae.edu', '3942 Sollicitudin Av.', '112', '2020-04-01', 'No'),
(203, 'Ira', 'Alexander', '1991-02-14', 'elit.Nulla@lectus.net', '2019 Nam St.', 'NIZ', NULL, NULL),
(204, 'Zachery', 'Decker', '1979-12-03', 'tincidunt@erat.edu', '5736 Sed Ave', 'LA', '2020-01-02', 'No'),
(205, 'Echo', 'Daniel', '1986-08-08', 'Vivamus.nisi.Mauris@fermentumvel.co.uk', '4228 Leo. Road', 'REN', '2020-01-19', 'No'),
(206, 'Jerome', 'Sawyer', '1949-03-24', 'at@Duisrisus.co.uk', 'Ap #668-4983 Vulputate St.', 'LZ', NULL, NULL),
(207, 'Lucian', 'Sharp', '1972-12-28', 'Curabitur.vel.lectus@imperdiet.ca', '701-8566 At, Ave', '113', NULL, NULL),
(208, 'Elijah', 'Hester', '1997-09-11', 'magna@Phasellusataugue.edu', '396-3428 Ante. Rd.', '013', NULL, NULL),
(209, 'Steven', 'Soto', '1960-05-08', 'mattis.velit.justo@necimperdiet.com', '6967 Cursus Road', 'CRAK', NULL, NULL),
(210, 'Aladdin', 'Rivas', '1987-05-31', 'dictum.magna.Ut@atarcuVestibulum.edu', '621-192 Morbi Avenue', 'ME', NULL, NULL),
(211, 'Cooper', 'Haney', '1959-01-03', 'dis.parturient.montes@eget.org', '4622 Non, Ave', 'ME', NULL, NULL),
(212, 'Fritz', 'Weiss', '1987-10-09', 'mauris@nequesed.org', 'Ap #654-6360 Et St.', 'TRAB', '2020-11-01', 'Si'),
(213, 'Emily', 'Hopkins', '1962-06-16', 'ultricies@sedorci.org', 'P.O. Box 711, 3728 Risus. Av.', 'TRAB', '2020-12-02', 'Si'),
(214, 'Elliott', 'Hill', '1985-10-16', 'sit.amet@Maecenasmifelis.com', '158-1369 Nisi Rd.', 'IST', NULL, NULL),
(215, 'Xenos', 'Potter', '1995-07-09', 'non.justo@sedsapien.com', 'Ap #474-9791 Mauris, Rd.', 'DORT', '2020-07-01', 'Si'),
(216, 'Hilary', 'Yang', '1951-12-22', 'dui@enimnec.org', '222-1034 Magna Av.', 'RO', '2020-12-12', 'Si'),
(217, 'Lisandra', 'Simmons', '1985-12-21', 'enim@consectetuermaurisid.net', 'Ap #384-4068 Nec St.', '013', '2020-05-30', 'Si'),
(218, 'Andrea', 'La Greca', '1959-09-09', 'shvfw@gmail.com', 'Via A.Gagini', 'CT', NULL, NULL),
(219, 'Michele', 'La Greca', '1998-03-28', 'miky@gmail.com', 'Via A.Gagini', 'CT', NULL, NULL),
(220, 'Alfio', 'Lombardo', '1991-04-18', 'kkAS@gmail.com', 'Via Sassi', 'CT', NULL, NULL),
(221, 'Giovanni', 'Petrarca', '1973-02-11', 'oqoiso@gmail.com', 'Viale Mario Rapisardi', 'CT', NULL, NULL),
(222, 'Michele', 'La Greca', '1998-03-28', 'miky@gmail.com', 'Via A.Gagini', 'CT', NULL, NULL),
(223, 'Inigo', 'Arrauco Collazo', '1998-06-16', 'inigo6@Maecenasmifelis.com', '158-1369 Nisi Rd.', 'VIGO', '2020-04-12', 'No'),
(224, 'Claudia', 'Gaglione', '1998-11-09', 'claudia@gmail.com', 'Estora Rd.', 'PPL', NULL, NULL),
(225, 'Federico', 'Lo Bianco', '1998-10-16', 'flb@business.com', 'Praio do Conc 89', 'LISB', '2020-12-12', 'No');

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
CREATE TABLE `staff` (
  `code` int(11) DEFAULT NULL,
  `username` char(50) NOT NULL,
  `password` char(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`code`, `username`, `password`) VALUES
(731510, 'antonio', '123'),
(731511, 'ciao', '123'),
(731497, 'medicalresol', 'sadadadasd'),
(731491, 'michele', '123'),
(731500, 'michelone', '123'),
(731514, 'profile12', 'djafjcbsdj'),
(731494, 'sabasbkadwe232befjkczla', 'ss1234567890'),
(731493, 'sanfriero', 'ciaone');

-- --------------------------------------------------------

--
-- Table structure for table `storico_lockdown`
--

DROP TABLE IF EXISTS `storico_lockdown`;
CREATE TABLE `storico_lockdown` (
  `ID` int(11) NOT NULL,
  `Citta` char(5) NOT NULL,
  `Lockdown` char(30) NOT NULL,
  `Data_inizio` date NOT NULL,
  `Data_fine` date NOT NULL
) ;

--
-- Dumping data for table `storico_lockdown`
--

INSERT INTO `storico_lockdown` (`ID`, `Citta`, `Lockdown`, `Data_inizio`, `Data_fine`) VALUES
(1, 'CT', 'Giornaliero', '2020-12-01', '2020-12-24'),
(2, 'CT', 'Giornaliero', '2020-03-01', '2020-04-24'),
(5, 'PA', 'Giornaliero', '2020-12-01', '2020-12-24'),
(6, 'NA', 'Giornaliero', '2020-12-01', '2020-12-24'),
(7, 'RO', 'Totale', '2020-12-01', '2020-12-24'),
(8, 'RO', 'Totale', '2020-11-01', '2020-11-24'),
(9, 'RO', 'Totale', '2020-10-01', '2020-10-24'),
(10, 'LA', 'Totale', '2020-10-01', '2020-10-24'),
(11, 'MI', 'Totale', '2020-12-01', '2020-12-24'),
(12, 'STR', 'Totale', '2020-12-01', '2020-12-24'),
(13, 'BOR', 'Weekend', '2020-03-09', '2020-04-19'),
(14, 'LIO', 'Weekend', '2020-12-01', '2020-12-24'),
(15, 'DIG', 'Giornaliero', '2020-12-01', '2020-12-24'),
(16, 'REN', 'Giornaliero', '2020-12-01', '2020-12-24'),
(17, 'NIZ', 'Giornaliero', '2020-12-01', '2020-12-24'),
(18, 'AVI', 'Weekend', '2020-12-01', '2020-12-24'),
(19, 'BAR', 'Weekend', '2020-12-01', '2020-12-24'),
(20, 'BAR', 'Weekend', '2020-08-08', '2020-08-11'),
(21, 'MAD', 'Totale', '2020-12-01', '2020-12-24'),
(22, 'PPL', 'Totale', '2020-12-01', '2020-12-24'),
(23, 'DORT', 'Totale', '2020-03-01', '2020-04-24'),
(24, 'DESD', 'Totale', '2020-11-01', '2020-11-07'),
(25, 'WW', 'Totale', '2020-12-01', '2020-12-24'),
(26, 'PORT', 'Giornaliero', '2020-12-01', '2020-12-24'),
(27, 'LISB', 'Giornaliero', '2020-12-01', '2020-12-24'),
(28, 'CRAK', 'Giornaliero', '2020-12-01', '2020-12-24'),
(29, 'LZ', 'Giornaliero', '2020-12-01', '2020-12-24'),
(30, 'KIELC', 'Giornaliero', '2020-12-01', '2020-12-24'),
(31, 'VIGO', 'Giornaliero', '2020-06-01', '2020-06-24'),
(32, 'IZ', 'Giornaliero', '2020-12-01', '2020-12-24'),
(33, 'IZ', 'Totale', '2020-04-01', '2020-04-24'),
(34, 'IZ', 'Weekend', '2020-04-25', '2020-05-24'),
(35, 'IST', 'Giornaliero', '2020-12-01', '2020-12-24'),
(36, 'ADAN', 'Giornaliero', '2020-12-01', '2020-12-24'),
(37, 'TRAB', 'Giornaliero', '2020-12-01', '2020-12-24'),
(38, '012', 'Totale', '2020-12-01', '2020-12-24'),
(39, '013', 'Totale', '2020-12-01', '2020-12-24'),
(40, '016', 'Totale', '2020-12-01', '2020-12-24'),
(41, 'NY', 'Giornaliero', '2020-09-01', '2020-09-24'),
(42, '733', 'Weekend', '2020-09-01', '2020-09-24'),
(43, '112', 'Giornaliero', '2020-12-01', '2020-12-24'),
(44, '113', 'Giornaliero', '2020-12-01', '2020-12-24'),
(45, 'PPL', 'Totale', '2020-12-25', '2020-12-26'),
(46, 'BAR', 'Totale', '2020-11-01', '2020-11-05');

--
-- Triggers `storico_lockdown`
--
DROP TRIGGER IF EXISTS `no_stessi_lockdown`;
DELIMITER $$
CREATE TRIGGER `no_stessi_lockdown` BEFORE INSERT ON `storico_lockdown` FOR EACH ROW begin
declare msg char(255);
set msg = concat('Il lockdown inserito risulta essere nel periodo di qualche altro lockdown avvenuto a ', new.citta);
if(exists(select * from storico_lockdown where new.citta=citta and ((new.data_inizio>=data_inizio and new.data_inizio<data_fine) or (new.data_inizio=data_inizio and new.data_fine=data_fine) or (new.data_inizio<data_inizio and new.data_fine>data_inizio))))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `no_stessi_lockdown_update`;
DELIMITER $$
CREATE TRIGGER `no_stessi_lockdown_update` BEFORE UPDATE ON `storico_lockdown` FOR EACH ROW begin
declare msg char(255);
set msg = concat('Il lockdown inserito risulta essere nel periodo di qualche altro lockdown avvenuto a ', new.citta);
if(exists(select * from storico_lockdown where new.citta=citta and ((new.data_inizio>=data_inizio and new.data_inizio<data_fine) or (new.data_inizio=data_inizio and new.data_fine=data_fine) or (new.data_inizio<data_inizio and new.data_fine>data_inizio))))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `struttura_ente`
--

DROP TABLE IF EXISTS `struttura_ente`;
CREATE TABLE `struttura_ente` (
  `Codice` int(11) NOT NULL,
  `p_iva` int(11) DEFAULT NULL,
  `tassa_no_ospedale` int(11) DEFAULT NULL,
  `numero_reparti` int(11) DEFAULT NULL,
  `efficienza_PS` int(11) DEFAULT NULL
) ;

--
-- Dumping data for table `struttura_ente`
--

INSERT INTO `struttura_ente` (`Codice`, `p_iva`, `tassa_no_ospedale`, `numero_reparti`, `efficienza_PS`) VALUES
(41, NULL, NULL, 11, 90),
(42, 8721160, 5, NULL, NULL),
(43, NULL, NULL, 9, 66),
(44, NULL, NULL, 9, 79),
(45, NULL, NULL, 9, 63),
(46, NULL, NULL, 13, 69),
(47, NULL, NULL, 10, 96),
(48, NULL, NULL, 9, 91),
(49, NULL, NULL, 6, 95),
(50, 4021454, 11, NULL, NULL),
(51, NULL, NULL, 11, 68),
(52, NULL, NULL, 5, 60),
(53, 7250686, 15, NULL, NULL),
(54, 172398, 6, NULL, NULL),
(56, NULL, NULL, 11, 72),
(57, NULL, NULL, 12, 68),
(59, NULL, NULL, 12, 63),
(60, 8223648, 8, NULL, NULL),
(62, 2447955, 5, NULL, NULL),
(63, NULL, NULL, 6, 83),
(64, 5930879, 8, NULL, NULL),
(66, NULL, NULL, 5, 85),
(67, NULL, NULL, 13, 77),
(68, NULL, NULL, 6, 74),
(70, 5286234, 8, NULL, NULL),
(71, 2229480, 15, NULL, NULL),
(73, NULL, NULL, 11, 91),
(74, NULL, NULL, 9, 93),
(75, 6261925, 20, NULL, NULL),
(76, 1920707, 9, NULL, NULL),
(78, 5248788, 3, NULL, NULL),
(79, 7974956, 12, NULL, NULL),
(80, 2726398, 5, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `tampone`
--

DROP TABLE IF EXISTS `tampone`;
CREATE TABLE `tampone` (
  `Codice` char(60) NOT NULL,
  `Produttore` char(60) NOT NULL,
  `Data_creazione` date NOT NULL
) ;

--
-- Dumping data for table `tampone`
--

INSERT INTO `tampone` (`Codice`, `Produttore`, `Data_creazione`) VALUES
('2-Plex', 'Randox', '2020-03-28'),
('Anti-SARS-CoV-2_NCP', 'EUROIMMUN', '2020-04-08'),
('Lumipulse_G_SARS-CoV-2_Ag', 'Fujirebio', '2020-05-08'),
('PrimeStore_MTM', 'EKF', '2020-05-01'),
('YIG-AN-0010', 'ADS Biotec Limited', '2020-04-22'),
('YIG-GM-0010', 'ADS Biotec Limited', '2020-06-19');

-- --------------------------------------------------------

--
-- Table structure for table `tampone_eseguito`
--

DROP TABLE IF EXISTS `tampone_eseguito`;
CREATE TABLE `tampone_eseguito` (
  `Codice` int(11) NOT NULL,
  `Tipo_tampone` char(60) NOT NULL,
  `operatore` int(11) NOT NULL,
  `paziente` int(11) NOT NULL,
  `ente` int(11) NOT NULL,
  `data_effettuazione` date NOT NULL
) ;

--
-- Dumping data for table `tampone_eseguito`
--

INSERT INTO `tampone_eseguito` (`Codice`, `Tipo_tampone`, `operatore`, `paziente`, `ente`, `data_effettuazione`) VALUES
(1, '2-Plex', 118, 181, 41, '2020-07-12'),
(2, '2-Plex', 159, 181, 56, '2020-08-14'),
(3, '2-Plex', 120, 197, 62, '2020-04-04'),
(6, '2-Plex', 149, 184, 67, '2020-08-19'),
(7, '2-Plex', 190, 212, 73, '2020-10-18'),
(8, '2-Plex', 159, 181, 56, '2020-08-15'),
(8, 'YIG-GM-0010', 159, 181, 56, '2020-08-15'),
(11, 'Lumipulse_G_SARS-CoV-2_Ag', 124, 184, 54, '2020-05-22'),
(12, 'PrimeStore_MTM', 165, 181, 66, '2020-06-14'),
(15, '2-Plex', 159, 181, 45, '2020-07-03'),
(17, 'YIG-AN-0010', 131, 218, 64, '2020-06-30'),
(18, 'Anti-SARS-CoV-2_NCP', 178, 199, 43, '2020-09-22'),
(19, 'Anti-SARS-CoV-2_NCP', 118, 184, 68, '2020-07-18'),
(20, 'Anti-SARS-CoV-2_NCP', 178, 185, 67, '2020-06-30'),
(22, '2-Plex', 190, 186, 59, '2020-05-03'),
(23, 'Lumipulse_G_SARS-CoV-2_Ag', 130, 193, 64, '2020-10-12'),
(24, 'YIG-AN-0010', 139, 184, 50, '2020-07-08'),
(25, 'PrimeStore_MTM', 194, 213, 51, '2020-08-01'),
(30, 'YIG-GM-0010', 194, 191, 79, '2020-09-28'),
(32, 'YIG-GM-0010', 121, 185, 49, '2020-09-13'),
(34, '2-Plex', 139, 197, 74, '2020-05-09'),
(34, 'PrimeStore_MTM', 213, 218, 71, '2020-11-26'),
(35, 'PrimeStore_MTM', 213, 200, 75, '2020-11-21'),
(36, 'PrimeStore_MTM', 189, 201, 71, '2020-06-30'),
(38, 'YIG-AN-0010', 147, 188, 62, '2020-07-26'),
(39, 'Anti-SARS-CoV-2_NCP', 147, 186, 57, '2020-11-08'),
(41, 'Anti-SARS-CoV-2_NCP', 118, 183, 53, '2020-06-23'),
(41, 'YIG-GM-0010', 210, 201, 63, '2020-07-07'),
(43, '2-Plex', 145, 213, 48, '2020-11-08'),
(45, 'Lumipulse_G_SARS-CoV-2_Ag', 118, 199, 59, '2020-05-29'),
(47, 'Lumipulse_G_SARS-CoV-2_Ag', 165, 210, 43, '2020-07-09'),
(48, 'Anti-SARS-CoV-2_NCP', 132, 194, 51, '2020-09-16'),
(48, 'Lumipulse_G_SARS-CoV-2_Ag', 186, 207, 80, '2020-05-13'),
(52, 'PrimeStore_MTM', 193, 210, 74, '2020-12-07'),
(53, 'YIG-AN-0010', 149, 213, 60, '2020-11-09'),
(54, '2-Plex', 153, 207, 75, '2020-10-13'),
(54, 'YIG-AN-0010', 208, 191, 50, '2020-08-10'),
(60, 'Anti-SARS-CoV-2_NCP', 190, 191, 78, '2020-06-19'),
(63, 'YIG-AN-0010', 174, 221, 42, '2020-08-30'),
(64, 'PrimeStore_MTM', 208, 199, 75, '2020-07-14'),
(65, 'Lumipulse_G_SARS-CoV-2_Ag', 163, 208, 75, '2020-09-09'),
(67, 'Anti-SARS-CoV-2_NCP', 118, 219, 48, '2020-04-14'),
(69, 'Anti-SARS-CoV-2_NCP', 138, 212, 52, '2020-07-11'),
(70, 'PrimeStore_MTM', 159, 188, 70, '2020-07-17'),
(71, 'Lumipulse_G_SARS-CoV-2_Ag', 128, 210, 59, '2020-10-01'),
(74, 'Lumipulse_G_SARS-CoV-2_Ag', 174, 219, 46, '2020-09-08'),
(75, '2-Plex', 178, 215, 51, '2020-06-28'),
(77, 'PrimeStore_MTM', 187, 189, 44, '2020-11-09'),
(80, 'YIG-AN-0010', 178, 218, 43, '2020-10-05'),
(81, 'PrimeStore_MTM', 196, 218, 76, '2020-10-29'),
(89, '2-Plex', 193, 190, 46, '2020-08-08'),
(94, 'Anti-SARS-CoV-2_NCP', 137, 201, 78, '2020-08-16'),
(94, 'Lumipulse_G_SARS-CoV-2_Ag', 210, 183, 43, '2020-06-13'),
(96, 'YIG-GM-0010', 178, 185, 47, '2020-11-18'),
(97, '2-Plex', 196, 201, 42, '2020-06-21'),
(99, 'YIG-AN-0010', 153, 217, 68, '2020-05-29'),
(99, 'YIG-GM-0010', 163, 185, 43, '2020-07-31'),
(100, '2-Plex', 194, 185, 60, '2020-04-07'),
(219, '2-Plex', 118, 181, 41, '2020-07-01'),
(222, '2-Plex', 118, 181, 41, '2020-07-12'),
(225, '2-Plex', 118, 181, 41, '2020-07-12'),
(229, '2-Plex', 118, 183, 41, '2020-05-12'),
(21933, 'Lumipulse_G_SARS-CoV-2_Ag', 118, 181, 41, '2020-05-12'),
(2321312, 'YIG-AN-0010', 118, 181, 41, '2020-06-12');

--
-- Triggers `tampone_eseguito`
--
DROP TRIGGER IF EXISTS `data_tampone_eseguito_insert`;
DELIMITER $$
CREATE TRIGGER `data_tampone_eseguito_insert` BEFORE INSERT ON `tampone_eseguito` FOR EACH ROW begin
declare msg char(255);
set msg = concat('Il tampone ', new.tipo_tampone, ' non risulta nel database alla data ', new.data_effettuazione);
if(new.data_effettuazione<(select data_creazione from tampone where new.tipo_tampone=codice))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `data_tampone_eseguito_update`;
DELIMITER $$
CREATE TRIGGER `data_tampone_eseguito_update` BEFORE UPDATE ON `tampone_eseguito` FOR EACH ROW begin
declare msg char(255);
set msg = concat('Il tampone ', new.tipo_tampone, ' non risulta nel database alla data ', new.data_effettuazione);
if(new.data_effettuazione<(select data_creazione from tampone where new.tipo_tampone=codice))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `no_decesso`;
DELIMITER $$
CREATE TRIGGER `no_decesso` BEFORE INSERT ON `tampone_eseguito` FOR EACH ROW begin
declare msg char(255);
set msg = concat('In data ', new.data_effettuazione, ' uno tra operatore e paziente risulta deceduto');
if(exists(select * from persona where cf=new.operatore and (data_decesso<=new.data_effettuazione)) or exists(select * from persona where cf=new.paziente and (data_decesso<=new.data_effettuazione)))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `no_decesso_update`;
DELIMITER $$
CREATE TRIGGER `no_decesso_update` BEFORE UPDATE ON `tampone_eseguito` FOR EACH ROW begin
declare msg char(255);
set msg = concat('In data ', new.data_effettuazione, ' uno tra operatore e paziente risulta deceduto');
if(exists(select * from persona where cf=new.operatore and (data_decesso<=new.data_effettuazione)) or exists(select * from persona where cf=new.paziente and (data_decesso<=new.data_effettuazione)))
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `no_stesso_operatore_paziente`;
DELIMITER $$
CREATE TRIGGER `no_stesso_operatore_paziente` BEFORE INSERT ON `tampone_eseguito` FOR EACH ROW begin
declare msg char(255);
set msg = 'I CF dell operatore e del paziente coincidono';
if(new.operatore=new.paziente)
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `no_stesso_operatore_paziente_update`;
DELIMITER $$
CREATE TRIGGER `no_stesso_operatore_paziente_update` BEFORE UPDATE ON `tampone_eseguito` FOR EACH ROW begin
declare msg char(255);
set msg = 'I CF dell operatore e del paziente coincidono';
if(new.operatore=new.paziente)
then
signal sqlstate '45000' set message_text = msg;
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `team_sviluppo`
--

DROP TABLE IF EXISTS `team_sviluppo`;
CREATE TABLE `team_sviluppo` (
  `ID` char(5) NOT NULL,
  `Nome` char(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `team_sviluppo`
--

INSERT INTO `team_sviluppo` (`ID`, `Nome`) VALUES
('09DHJ', 'Eindhoven University of Technology'),
('111SS', 'Munich COVID19 COVID19 centre'),
('3FJHD', 'Houston Medicine for COVID19'),
('74DSS', 'MIT Research Centre'),
('78BSJ', 'Atlanta COVID19 Developement'),
('HJSCS', 'Ricerca Normale di Pisa'),
('HSCII', 'Buenos Aires medical centre'),
('JFWWO', 'Polito Ricerca'),
('KSAKL', 'Hong Kong Covid19 research'),
('LS032', 'La Sapienza Medicine Centre'),
('OIACS', 'MIT Medical Developers'),
('SING1', 'Singapore Medicine Developement');

-- --------------------------------------------------------

--
-- Table structure for table `tecnica`
--

DROP TABLE IF EXISTS `tecnica`;
CREATE TABLE `tecnica` (
  `Nome` char(50) NOT NULL,
  `creatore` char(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tecnica`
--

INSERT INTO `tecnica` (`Nome`, `creatore`) VALUES
('Cromatografia', 'Michail Cvet'),
('Dicroismo Circolare', 'Aime Cotton'),
('Elettroforesi', 'Ferdinand Friedrich Reuss'),
('Elettroporazione', 'Alfred Cazart'),
('Northem Blot', 'James Alwine'),
('Sequenziamento DNA', 'Polimi'),
('Spettroscopia', 'Isaac Newton');

-- --------------------------------------------------------

--
-- Structure for view `full_tampone`
--
DROP TABLE IF EXISTS `full_tampone`;

DROP VIEW IF EXISTS `full_tampone`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `full_tampone`  AS SELECT `t`.`Codice` AS `codice`, `t`.`Tipo_tampone` AS `tampone`, `t1`.`Produttore` AS `prod`, `c`.`Tipo` AS `tipo`, `c`.`Analisi` AS `analisi`, `c`.`Attuazione` AS `attuazione`, `c`.`Efficacia_nominale` AS `e_nominal`, `c`.`Struttura` AS `struttura`, `c`.`Efficacia_reale` AS `e_reale`, `t1`.`Data_creazione` AS `creazione`, `t`.`data_effettuazione` AS `data_effettuaz`, `t`.`operatore` AS `operatore`, `t`.`paziente` AS `paziente`, `t`.`ente` AS `ente` FROM ((`tampone_eseguito` `t` join `tampone` `t1`) join `caratteristiche_tampone` `c`) WHERE `t`.`Tipo_tampone` = `t1`.`Codice` AND `t`.`Tipo_tampone` = `c`.`Codice` ;

-- --------------------------------------------------------

--
-- Structure for view `full_tampone_plus`
--
DROP TABLE IF EXISTS `full_tampone_plus`;

DROP VIEW IF EXISTS `full_tampone_plus`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `full_tampone_plus`  AS SELECT `t`.`Codice` AS `codice`, `t`.`Tipo_tampone` AS `tampone`, `t1`.`Produttore` AS `prod`, `c`.`Tipo` AS `tipo`, `c`.`Analisi` AS `analisi`, `c`.`Attuazione` AS `attuazione`, `c`.`Efficacia_nominale` AS `e_nominal`, `c`.`Struttura` AS `struttura`, `c`.`Efficacia_reale` AS `e_reale`, `t1`.`Data_creazione` AS `creazione`, `t`.`data_effettuazione` AS `data_effettuaz`, `e`.`Data` AS `data_esito`, `e`.`Risultato` AS `esito`, `t`.`operatore` AS `operatore`, `t`.`paziente` AS `paziente`, `t`.`ente` AS `ente` FROM (((`tampone_eseguito` `t` join `tampone` `t1`) join `caratteristiche_tampone` `c`) join `esito` `e`) WHERE `t`.`Tipo_tampone` = `t1`.`Codice` AND `t`.`Tipo_tampone` = `c`.`Codice` AND `t`.`Tipo_tampone` = `e`.`Tipo_tampone` AND `t`.`Codice` = `e`.`Tampone` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `azienda_controllo`
--
ALTER TABLE `azienda_controllo`
  ADD PRIMARY KEY (`Codice`),
  ADD UNIQUE KEY `ente_controllato` (`ente_controllato`),
  ADD KEY `ind_sede` (`sede`);

--
-- Indexes for table `caratteristiche_tampone`
--
ALTER TABLE `caratteristiche_tampone`
  ADD PRIMARY KEY (`Codice`),
  ADD KEY `ind_codice` (`Codice`);

--
-- Indexes for table `caratteristiche_tecnica`
--
ALTER TABLE `caratteristiche_tecnica`
  ADD PRIMARY KEY (`Nome`),
  ADD KEY `ind_nome` (`Nome`);

--
-- Indexes for table `citta`
--
ALTER TABLE `citta`
  ADD PRIMARY KEY (`codice`),
  ADD KEY `ind_lockdown` (`lockdown_attuale`);

--
-- Indexes for table `ente_covid19`
--
ALTER TABLE `ente_covid19`
  ADD PRIMARY KEY (`Codice`),
  ADD UNIQUE KEY `Controllore` (`Controllore`),
  ADD KEY `ind_sede` (`Sede`),
  ADD KEY `ind_controllore` (`Controllore`);

--
-- Indexes for table `esito`
--
ALTER TABLE `esito`
  ADD PRIMARY KEY (`Tampone`,`Tipo_tampone`,`Lab_analisi`,`data_e`),
  ADD KEY `ind_lab_analisi` (`Lab_analisi`),
  ADD KEY `ind_tampone` (`Tampone`,`Tipo_tampone`);

--
-- Indexes for table `lab_analisi`
--
ALTER TABLE `lab_analisi`
  ADD PRIMARY KEY (`codice`),
  ADD KEY `ind_sede` (`sede`);

--
-- Indexes for table `lockdown`
--
ALTER TABLE `lockdown`
  ADD PRIMARY KEY (`tipo`);

--
-- Indexes for table `miglioramento`
--
ALTER TABLE `miglioramento`
  ADD PRIMARY KEY (`codice`,`tampone`,`team`,`tecnica`),
  ADD KEY `ind_tampone` (`tampone`),
  ADD KEY `ind_team` (`team`),
  ADD KEY `ind_tecnica` (`tecnica`);

--
-- Indexes for table `operatore`
--
ALTER TABLE `operatore`
  ADD PRIMARY KEY (`CF`),
  ADD UNIQUE KEY `Matricola` (`Matricola`),
  ADD KEY `ind_CF` (`CF`);

--
-- Indexes for table `paziente`
--
ALTER TABLE `paziente`
  ADD PRIMARY KEY (`CF`),
  ADD UNIQUE KEY `CF` (`CF`),
  ADD KEY `ind_CF` (`CF`);

--
-- Indexes for table `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`CF`),
  ADD KEY `ind_domicilio` (`Domicilio`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`username`),
  ADD KEY `ind_code` (`code`);

--
-- Indexes for table `storico_lockdown`
--
ALTER TABLE `storico_lockdown`
  ADD PRIMARY KEY (`ID`,`Citta`,`Lockdown`,`Data_inizio`),
  ADD KEY `ind_citta` (`Citta`),
  ADD KEY `ind_lockdown` (`Lockdown`);

--
-- Indexes for table `struttura_ente`
--
ALTER TABLE `struttura_ente`
  ADD PRIMARY KEY (`Codice`),
  ADD UNIQUE KEY `p_iva` (`p_iva`),
  ADD KEY `ind_codice` (`Codice`);

--
-- Indexes for table `tampone`
--
ALTER TABLE `tampone`
  ADD PRIMARY KEY (`Codice`);

--
-- Indexes for table `tampone_eseguito`
--
ALTER TABLE `tampone_eseguito`
  ADD PRIMARY KEY (`Codice`,`Tipo_tampone`),
  ADD KEY `ind_tipo_tampone` (`Tipo_tampone`),
  ADD KEY `ind_operatore` (`operatore`),
  ADD KEY `ind_paziente` (`paziente`),
  ADD KEY `ind_ente` (`ente`);

--
-- Indexes for table `team_sviluppo`
--
ALTER TABLE `team_sviluppo`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `tecnica`
--
ALTER TABLE `tecnica`
  ADD PRIMARY KEY (`Nome`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `azienda_controllo`
--
ALTER TABLE `azienda_controllo`
  MODIFY `Codice` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `ente_covid19`
--
ALTER TABLE `ente_covid19`
  MODIFY `Codice` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT for table `lab_analisi`
--
ALTER TABLE `lab_analisi`
  MODIFY `codice` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4712;

--
-- AUTO_INCREMENT for table `miglioramento`
--
ALTER TABLE `miglioramento`
  MODIFY `codice` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `persona`
--
ALTER TABLE `persona`
  MODIFY `CF` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `storico_lockdown`
--
ALTER TABLE `storico_lockdown`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `azienda_controllo`
--
ALTER TABLE `azienda_controllo`
  ADD CONSTRAINT `azienda_controllo_ibfk_1` FOREIGN KEY (`sede`) REFERENCES `citta` (`codice`) ON UPDATE CASCADE;

--
-- Constraints for table `caratteristiche_tampone`
--
ALTER TABLE `caratteristiche_tampone`
  ADD CONSTRAINT `caratteristiche_tampone_ibfk_1` FOREIGN KEY (`Codice`) REFERENCES `tampone` (`Codice`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `caratteristiche_tecnica`
--
ALTER TABLE `caratteristiche_tecnica`
  ADD CONSTRAINT `caratteristiche_tecnica_ibfk_1` FOREIGN KEY (`Nome`) REFERENCES `tecnica` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `citta`
--
ALTER TABLE `citta`
  ADD CONSTRAINT `citta_ibfk_1` FOREIGN KEY (`lockdown_attuale`) REFERENCES `lockdown` (`tipo`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `ente_covid19`
--
ALTER TABLE `ente_covid19`
  ADD CONSTRAINT `ente_covid19_ibfk_1` FOREIGN KEY (`Sede`) REFERENCES `citta` (`codice`) ON UPDATE CASCADE,
  ADD CONSTRAINT `ente_covid19_ibfk_2` FOREIGN KEY (`Controllore`) REFERENCES `azienda_controllo` (`Codice`) ON UPDATE CASCADE;

--
-- Constraints for table `esito`
--
ALTER TABLE `esito`
  ADD CONSTRAINT `esito_ibfk_1` FOREIGN KEY (`Tampone`,`Tipo_tampone`) REFERENCES `tampone_eseguito` (`Codice`, `Tipo_tampone`) ON UPDATE CASCADE,
  ADD CONSTRAINT `esito_ibfk_3` FOREIGN KEY (`Lab_analisi`) REFERENCES `lab_analisi` (`codice`) ON UPDATE CASCADE;

--
-- Constraints for table `lab_analisi`
--
ALTER TABLE `lab_analisi`
  ADD CONSTRAINT `lab_analisi_ibfk_1` FOREIGN KEY (`sede`) REFERENCES `citta` (`codice`) ON UPDATE CASCADE;

--
-- Constraints for table `miglioramento`
--
ALTER TABLE `miglioramento`
  ADD CONSTRAINT `miglioramento_ibfk_1` FOREIGN KEY (`tampone`) REFERENCES `tampone` (`Codice`) ON UPDATE CASCADE,
  ADD CONSTRAINT `miglioramento_ibfk_2` FOREIGN KEY (`team`) REFERENCES `team_sviluppo` (`ID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `miglioramento_ibfk_3` FOREIGN KEY (`tecnica`) REFERENCES `tecnica` (`Nome`) ON UPDATE CASCADE;

--
-- Constraints for table `operatore`
--
ALTER TABLE `operatore`
  ADD CONSTRAINT `operatore_ibfk_1` FOREIGN KEY (`CF`) REFERENCES `persona` (`CF`) ON UPDATE CASCADE;

--
-- Constraints for table `paziente`
--
ALTER TABLE `paziente`
  ADD CONSTRAINT `paziente_ibfk_1` FOREIGN KEY (`CF`) REFERENCES `persona` (`CF`) ON UPDATE CASCADE;

--
-- Constraints for table `persona`
--
ALTER TABLE `persona`
  ADD CONSTRAINT `persona_ibfk_1` FOREIGN KEY (`Domicilio`) REFERENCES `citta` (`codice`) ON UPDATE CASCADE;

--
-- Constraints for table `staff`
--
ALTER TABLE `staff`
  ADD CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`code`) REFERENCES `operatore` (`Matricola`) ON UPDATE CASCADE;

--
-- Constraints for table `storico_lockdown`
--
ALTER TABLE `storico_lockdown`
  ADD CONSTRAINT `storico_lockdown_ibfk_1` FOREIGN KEY (`Citta`) REFERENCES `citta` (`codice`) ON UPDATE CASCADE,
  ADD CONSTRAINT `storico_lockdown_ibfk_2` FOREIGN KEY (`Lockdown`) REFERENCES `lockdown` (`tipo`) ON UPDATE CASCADE;

--
-- Constraints for table `struttura_ente`
--
ALTER TABLE `struttura_ente`
  ADD CONSTRAINT `struttura_ente_ibfk_1` FOREIGN KEY (`Codice`) REFERENCES `ente_covid19` (`Codice`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tampone_eseguito`
--
ALTER TABLE `tampone_eseguito`
  ADD CONSTRAINT `tampone_eseguito_ibfk_1` FOREIGN KEY (`Tipo_tampone`) REFERENCES `tampone` (`Codice`) ON UPDATE CASCADE,
  ADD CONSTRAINT `tampone_eseguito_ibfk_2` FOREIGN KEY (`operatore`) REFERENCES `operatore` (`CF`) ON UPDATE CASCADE,
  ADD CONSTRAINT `tampone_eseguito_ibfk_3` FOREIGN KEY (`paziente`) REFERENCES `paziente` (`CF`) ON UPDATE CASCADE,
  ADD CONSTRAINT `tampone_eseguito_ibfk_4` FOREIGN KEY (`ente`) REFERENCES `ente_covid19` (`Codice`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
