# AWS-Setup

* AWS-Benutzer sind bereits angelegt:
  * Kleinbuchstaben
  * erster Buchstabe des ersten Vornamens
  * Nachname mit ä=ae, ö=oe, u=ue, ß=ss
  * Beispiel: `Franz-Wilhelm Schlößer -> fschloesser`
* Login auf https://853161928370.signin.aws.amazon.com/console (Passwort wird im Workshop mitgeteilt)
* Access Key erzeugen
  * https://console.aws.amazon.com/iam/home?region=eu-central-1#/users/<dein-benutzername>?section=security_credentials
  * Button "Create access key" klicken und Pop-Up **nicht** schließen
  * Datei `$HOME/.aws/credentials` (Linux/OS X) bzw. `%USERPROFILE%\.aws\credentials` (Windows) anlegen:
  
    ```shell
    [javaland]
    aws_access_key_id=<your-access-key-id>
    aws_secret_access_key=<your-secret-access-key>
    ```

# Deployment aller Services

* `./gradlew clean buildAndDeploy`

# Abbau aller Services

* Eigene S3-Buckets komplett leeren
* `./gradlew destroy`

