USE master;
GO

-- Eliminazione del database
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'PoliziaMunicipale')
BEGIN
    ALTER DATABASE PoliziaMunicipale SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PoliziaMunicipale;
END
GO

-- Creazione del database
CREATE DATABASE PoliziaMunicipale;
GO

USE PoliziaMunicipale;
GO

-- Eliminazione delle tabelle
IF OBJECT_ID('dbo.VERBALE', 'U') IS NOT NULL DROP TABLE dbo.VERBALE;
IF OBJECT_ID('dbo.TIPO_VIOLAZIONE', 'U') IS NOT NULL DROP TABLE dbo.TIPO_VIOLAZIONE;
IF OBJECT_ID('dbo.ANAGRAFICA', 'U') IS NOT NULL DROP TABLE dbo.ANAGRAFICA;
GO

--Creazione delle tabelle

CREATE TABLE ANAGRAFICA (
    idanagrafica INT IDENTITY(1,1) PRIMARY KEY,
    Cognome VARCHAR(50) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Indirizzo VARCHAR(100),
    Città VARCHAR(50),
    CAP CHAR(5),
    Cod_Fisc CHAR(16) UNIQUE NOT NULL
);

CREATE TABLE TIPO_VIOLAZIONE (
    idviolazione INT IDENTITY(1,1) PRIMARY KEY,
    descrizione VARCHAR(255) NOT NULL
);

CREATE TABLE VERBALE (
    idverbale INT IDENTITY(1,1) PRIMARY KEY,
    idanagrafica INT NOT NULL,
    idviolazione INT NOT NULL,
    DataViolazione DATE NOT NULL,
    IndirizzoViolazione VARCHAR(100),
    Nominativo_Agente VARCHAR(100),
    DataTrascrizioneVerbale DATE NOT NULL,
    Importo DECIMAL(10,2) NOT NULL,
    DecurtamentoPunti INT CHECK (DecurtamentoPunti >= 0),
    FOREIGN KEY (idanagrafica) REFERENCES ANAGRAFICA(idanagrafica) ON DELETE CASCADE,
    FOREIGN KEY (idviolazione) REFERENCES TIPO_VIOLAZIONE(idviolazione) ON DELETE CASCADE
);
GO

INSERT INTO ANAGRAFICA (Cognome, Nome, Indirizzo, Città, CAP, Cod_Fisc) VALUES
('Rossi', 'Mario', 'Via Roma 10', 'Palermo', '90100', 'RSSMRA80A01H501Z'),
('Bianchi', 'Luigi', 'Via Milano 5', 'Roma', '00100', 'BNCLGU70M10F205T'),
('Verdi', 'Anna', 'Corso Torino 15', 'Milano', '20100', 'VRDANN85P20M109K'),
('Esposito', 'Giovanni', 'Via Napoli 25', 'Napoli', '80100', 'ESPGBN76T01F205T'),
('Russo', 'Elena', 'Piazza Dante 3', 'Torino', '10100', 'RSSLEN89D50T109X');

INSERT INTO TIPO_VIOLAZIONE (descrizione) VALUES
('Eccesso di velocità'),
('Divieto di sosta'),
('Guida senza cintura'),
('Uso del telefono alla guida'),
('Passaggio con semaforo rosso'),
('Guida in stato di ebbrezza'),
('Mancata revisione del veicolo'),
('Assicurazione scaduta');

INSERT INTO VERBALE (idanagrafica, idviolazione, DataViolazione, IndirizzoViolazione, Nominativo_Agente, DataTrascrizioneVerbale, Importo, DecurtamentoPunti) VALUES
(1, 1, '2024-01-15', 'Via Libertà 20', 'Agente Ferri', '2024-01-16', 450.00, 10),
(2, 2, '2024-01-20', 'Piazza Venezia', 'Agente Bianchi', '2024-01-21', 80.00, 0),
(3, 3, '2024-01-22', 'Via Dante 50', 'Agente Neri', '2024-01-23', 120.00, 5),
(4, 4, '2024-02-10', 'Via Garibaldi 5', 'Agente Rossi', '2024-02-11', 150.00, 2),
(5, 5, '2009-03-15', 'Piazza Duomo', 'Agente Verdi', '2009-03-16', 300.00, 6),
(1, 6, '2009-05-20', 'Corso Italia', 'Agente Bianchi', '2009-05-21', 700.00, 10),
(2, 7, '2009-07-05', 'Viale Regina', 'Agente Ferri', '2009-07-06', 500.00, 0),
(3, 8, '2024-02-25', 'Via della Pace', 'Agente Russo', '2024-02-26', 250.00, 3),
(4, 1, '2024-02-28', 'Via Mazzini', 'Agente Neri', '2024-02-29', 600.00, 8),
(5, 2, '2009-06-30', 'Via Firenze', 'Agente Esposito', '2009-07-01', 200.00, 1);
GO


-- 1. Conteggio dei verbali trascritti
SELECT COUNT(*) AS NumeroVerbali FROM VERBALE;

-- 2. Conteggio dei verbali per ogni persona
SELECT A.Cognome, A.Nome, COUNT(V.idverbale) AS NumeroVerbali
FROM ANAGRAFICA A
JOIN VERBALE V ON A.idanagrafica = V.idanagrafica
GROUP BY A.Cognome, A.Nome;

-- 3. Conteggio dei verbali per tipo di violazione
SELECT T.descrizione, COUNT(V.idverbale) AS NumeroVerbali
FROM TIPO_VIOLAZIONE T
JOIN VERBALE V ON T.idviolazione = V.idviolazione
GROUP BY T.descrizione;

-- 4. Totale punti decurtati per ogni persona
SELECT A.Cognome, A.Nome, SUM(V.DecurtamentoPunti) AS TotalePuntiDecurtati
FROM ANAGRAFICA A
JOIN VERBALE V ON A.idanagrafica = V.idanagrafica
GROUP BY A.Cognome, A.Nome;

-- 5. Violazioni per i residenti di Palermo
SELECT Cognome, Nome, DataViolazione, IndirizzoViolazione, Importo, DecurtamentoPunti
FROM ANAGRAFICA A
JOIN VERBALE V ON A.idanagrafica = V.idanagrafica
WHERE A.Città = 'Palermo';

-- 6. Violazioni tra Febbraio e Luglio 2009
SELECT A.Cognome, A.Nome, A.Indirizzo, V.DataViolazione, V.Importo, V.DecurtamentoPunti
FROM ANAGRAFICA A
JOIN VERBALE V ON A.idanagrafica = V.idanagrafica
WHERE V.DataViolazione BETWEEN '2009-02-01' AND '2009-07-31';

-- 7. Totale importi per ogni persona
SELECT A.Cognome, A.Nome, SUM(V.Importo) AS TotaleImporti
FROM ANAGRAFICA A
JOIN VERBALE V ON A.idanagrafica = V.idanagrafica
GROUP BY A.Cognome, A.Nome;

-- 8. Residenti a Palermo
SELECT * FROM ANAGRAFICA WHERE Città = 'Palermo';

-- 9. Violazioni in una certa data
SELECT DataViolazione, Importo, DecurtamentoPunti 
FROM VERBALE 
WHERE DataViolazione = '2024-01-15';

-- 10. Violazioni per agente
SELECT Nominativo_Agente, COUNT(*) AS NumeroViolazioni
FROM VERBALE
GROUP BY Nominativo_Agente;

-- 11. Violazioni con più di 5 punti decurtati
SELECT * FROM VERBALE WHERE DecurtamentoPunti > 5;

-- 12. Violazioni con importo superiore a 400€
SELECT * FROM VERBALE WHERE Importo > 400;
GO
