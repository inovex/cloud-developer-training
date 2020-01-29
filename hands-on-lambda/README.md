# Hands-On AWS Lambda

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Bei AWS einloggen](#bei-aws-einloggen)
- [Beispiel 1: SQS Listener](#beispiel-1-sqs-listener)
	- [SQS konfigurieren](#sqs-konfigurieren)
	- [Lambda konfigurieren](#lambda-konfigurieren)
	- [Lambda testen](#lambda-testen)
	- [Nachricht in SQS abschicken](#nachricht-in-sqs-abschicken)
	- [Log-Daten in CloudWatch ansehen](#log-daten-in-cloudwatch-ansehen)
- [Beispiel 2: S3 Listener](#beispiel-2-s3-listener)
	- [S3-Bucket anlegen](#s3-bucket-anlegen)
	- [Lambda konfigurieren](#lambda-konfigurieren)
	- [Datei in S3 Bucket hochladen](#datei-in-s3-bucket-hochladen)
	- [Log-Daten in CloudWatch ansehen](#log-daten-in-cloudwatch-ansehen)
- [Zusatzaufgaben](#zusatzaufgabe)

<!-- /TOC -->

## Bei AWS einloggen
* AWS-Benutzer sind bereits angelegt:
 * Kleinbuchstaben
 * erster Buchstabe des ersten Vornamens
 * Nachname mit ä=ae, ö=oe, u=ue, ß=ss
 * Beispiel: Franz-Wilhelm Schlößer -> fschloesser
 * Passwort wird im Workshop mitgeteilt
* Login auf https://853161928370.signin.aws.amazon.com/console
* Nach dem Login die Sprache der UI auf Englisch ändern (in der Fußleiste unten links), damit die hier verwendeten Begriffe zur UI passen

## Beispiel 1: SQS Listener

### SQS konfigurieren
* SQS-Konfiguration aufrufen: https://eu-central-1.console.aws.amazon.com/sqs/home?region=eu-central-1
* Sicherstellen, dass oben rechts `Frankfurt` ausgewählt ist
* `Create New Queue` anklicken und eigenen, eindeutigen Namen ausdenken (und merken 😉)
* Unten rechts `Quick-Create Queue` anklicken

### Lambda konfigurieren
* Zu Lambdas wechseln: https://eu-central-1.console.aws.amazon.com/lambda/home?region=eu-central-1#/functions
* `Create function` anklicken und `Use a blueprint` auswählen
* In den Blueprints nach `sqs` suchen und den `sqs-poller` auswählen
* Eigenen, eindeutigen Namen für die Funktion angeben
* Unter `Execution role` den Eintrag `Use an existing role` auswählen
* Unter `Existing role` dann den Eintrag `CDTLambda` auswählen
* Unter `SQS Trigger` die zuvor angelegte, eigene Queue auswählen und Haken bei `Enable trigger` setzen
* `Create function` anklicken (dauert einen Moment)

### Lambda testen
* Oben rechts neben `Test` im Drop-Down `Select a test event` den Eintrag `Configure test events` auswählen
* Falls nicht automatisch passiert: `Amazon SQS` als Template auswählen und gerne z.B. den `body` editieren
* `Event name` eingeben und speichern
* Voller Zuversicht auf `Test` klicken, Augen zuhalten und das Beste hoffen

### Nachricht in SQS abschicken
* Wenn alles geklappt hat, den Reiter `Monitoring` auswählen und in einem neuen Tab nochmal zu SQS (https://eu-central-1.console.aws.amazon.com/sqs/home?region=eu-central-1) wechseln
* Eigene Queue auswählen, unter `Queue Actions` den Eintrag `Send a message` anklicken, Nachricht eingeben und abschicken

### Log-Daten in CloudWatch ansehen
* Immer mal wieder auf den Refresh-Button beim `Monitoring`-Tab der Lambda klicken und warten, bis ein weiterer Aufruf auftaucht
* Dann den Link in der Spalte `Log Stream` in einem neuen Tab öffnen

## Beispiel 2: S3 Listener

### S3-Bucket anlegen
* In einem neuen Tab zu S3 wechseln: https://s3.console.aws.amazon.com/s3/home?region=eu-central-1
* `Create bucket` anklicken, eindeutigen Namen ausdenken (und merken 😉) und unten rechts auf `Next` klicken
* Im nächsten Schritt auch `Next` klicken, bis der Schritt `Set permissions` erreicht wurde
* Dort den Haken bei `Block all public access` entfernen (Vorsicht: nur zu Demozwecken!), dann nochmal `Next` und anschließend `Create`

### Lambda konfigurieren
* Zu Lambdas wechseln: https://eu-central-1.console.aws.amazon.com/lambda/home?region=eu-central-1#/functions
* `Create function` anklicken und `Use a blueprint` auswählen
* In den Blueprints nach `s3` suchen und `s3-get-object` auswählen
* Eigenen, eindeutigen Namen für die Funktion angeben
* Unter `Execution role` den Eintrag `Use an existing role` auswählen
* Unter `Existing role` dann den Eintrag `CDTLambda` auswählen
* Unter `S3 Trigger` den zuvor angelegten, eigenen Buckets auswählen und Haken bei `Enable trigger` setzen
* `Create function` anklicken (dauert einen Moment)

### Datei in S3 Bucket hochladen
* In einem neuen Tab nochmal zu S3 wechseln: https://s3.console.aws.amazon.com/s3/home?region=eu-central-1
* Eigenen, zuvor erstellen Bucket auswählen und `Upload` anklicken
* Entweder per Drag & Drop oder über `Add files` eine Datei hochladen, z.B. ein JPG

### Log-Daten in CloudWatch ansehen
* Immer mal wieder auf den Refresh-Button beim `Monitoring`-Tab der Lambda klicken und warten, bis ein weiterer Aufruf auftaucht
* Dann den Link in der Spalte `Log Stream` in einem neuen Tab öffnen

## Zusatzaufgaben
1. Der SQS Listener soll so erweitert werden, dass er den Inhalt der Nachricht ausliest und in eine Text-Datei in den S3 Bucket schreibt. ([Musterlösung](sqs-listener.js))
2. Der S3 Listener soll wiederum so angepasst werden, dass er den Inhalt der geschriebenen Dateien ausliest und in die Logs schreibt. ([Musterlösung](s3-listener.js))
3. Eine weitere, neue Lambda soll über das API Gateway per URL angesprochen werden und den Wert des Query-Parameters `msg` an die oben erstellte Queue schicken (z.B. `https://<url-zum-api-gateway>/default?msg=test123`). ([Musterlösung](sqs-sender.js))
