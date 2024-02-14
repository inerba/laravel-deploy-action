# Deploy Automatico di Laravel con GitHub Actions

Questa guida ti offre tutti gli strumenti per automatizzare il deployment del tuo progetto Laravel. Con pochi passaggi, imposterai un flusso di lavoro che assicura deploy rapidi e senza intoppi direttamente al tuo server. Inizia ora e rendi il deployment un processo semplice e senza pensieri.

Prerequisiti:
- Un web server configurato e pronto all'uso con accesso ssh
- Il repository del vostro progetto Laravel su GitHub

## Introduzione:
Per iniziare, copia (non clonare) i file di questo repository nel tuo progetto e segui le istruzioni dettagliate di seguito per impostare il tuo processo di deployment.

## Passo 1: Configura il Workflow di GitHub Action
Rinomina la cartella `github` in `.github` e aggiorna il file `.github/workflows/main.yml` con i dettagli di accesso ssh del tuo webserver. Questa configurazione YAML definisce il vostro workflow di Continuous Deployment (CD).

```yaml
name: CD

on:
  push:
    branches: [ production ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to production
      uses: appleboy/ssh-action@master
      with:
        username: USERNAME ACCESSO SSH
        host: HOSTNAME O IP DEL SERVER
        password: ${{ secrets.SSH_PASSWORD }}
        script: 'cd /home/utente/web/miosito.tld/public_html && ./server_deploy.sh'

```

> SSH_PASSWORD usa i [GitHub Action secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) dove impostarlo?
> Nel **Repo del progetto** -> **Settings** -> **Secrets and variables** -> **Actions**
> Name: SSH_PASSWORD 
> Secret: La tua password


## Passo 2: Prepara lo Script di Deployment per GitHub Actions
Rivedi e rendi eseguibile lo script server_deploy.sh per assicurarti che GitHub Actions possa eseguirlo senza problemi.

``` 
chmod +x server_deploy.sh
git update-index --chmod=+x server_deploy.sh
```

Contenuto del file `server_deploy.sh`
```sh
#!/bin/sh
set -e # Interrompe lo script in caso di errore
 
echo "Deploying application ..."
 
# Mette l'applicazione in modalità manutenzione. Se il comando fallisce, continua comunque grazie a || true
(php artisan down --render="errors::503") || true 

    # Scarica gli ultimi cambiamenti dal branch 'production'
    git pull origin production
    
    # Installa le dipendenze come specificato nel lock file di Composer senza interazione
    composer install --no-interaction --prefer-dist --optimize-autoloader 
    
    # Esegue le migrazioni del database senza chiedere conferma
    php artisan migrate --force 
    
    # ... (Qui andrebbero riavviati i workers delle code, se presenti)
    
    # Pulisce la cache e ottimizza la configurazione, le rotte e le viste
    php artisan optimize 
 
# Esce dalla modalità manutenzione rendendo di nuovo disponibile l'applicazione
php artisan up 
 
echo "Application deployed!"

# Va lanciato il comando seguente dopo la creazione e dopo aver rinominato il file
# git update-index --chmod=+x server_deploy.sh

```

Rendi lo script eseguibile con:
``` 
chmod +x server_deploy.sh
git update-index --chmod=+x server_deploy.sh
```

## Passo 3: Script di Deployment Locale

Contenuto del file `deploy.sh`
```sh
#!/bin/sh
set -e # Interrompe lo script in caso di errore

# Qui potresti inserire i tuoi test unitari

# Prova a eseguire git push. Se fallisce, continua comunque grazie a || true
(git push) || true 

# Cambia il branch corrente in 'production'
git checkout production 

# Unisce i cambiamenti dal branch 'master' al branch 'production' corrente
git merge master

# Effettua il push dei cambiamenti sul branch 'production' al repository remoto
git push origin production

# Cambia il branch corrente ritornando al 'master'
git checkout master
```

## Passo 4: Crea il branch production

```sh
git checkout -b production
git push origin production
git checkout master
```

## Passo 5: Prepara il Tuo Server Remoto

```sh
git clone --depth 1 --branch production git@github.com:username/nome_repo.git . 
chmod +x server_deploy.sh
composer install
```
> L'opzione --depth 1 limita la profondità della clone all'ultimo commit, risparmiando spazio pur mantenendo l'efficienza del deployment.


## Adesso puoi avviare il Deployment Locale
Ogni volta che sei pronto per eseguire un deployment, ti basterà eseguire il comando `sh deploy.sh` dalla tua macchina locale.

---

Seguendo questa guida automatizzi il deployment del tuo progetto Laravel con GitHub Actions, rendendo il processo veloce, sicuro e ripetibile. 

Questa guida è stata volutamente semplificata e resa il più minimale possibile per fornirti una base da cui partire. Ti incoraggio a esplorare ulteriormente le potenzialità delle GitHub Actions e a personalizzare gli script secondo le necessità del tuo progetto, includendo, ad esempio, test unitari o altri controlli di qualità che ritieni importanti.
