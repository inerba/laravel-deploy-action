# Deploy con Github actions

Prerequisiti:
- Un webserver configurato e pronto
- Un repo GitHub del progetto

Copia i file presenti in questo repository e segui le istruzioni:

## 1. La GitHub Action
Prima di tutto rinomina la cartella `github` in `.github` e aggiorna il file `.github/workflows/main.yml` con i tuoi dati

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


## 2. Script che verrà lanciato da Github Actions
Controlliamo lo script per **Github Actions** `server_deploy.sh` e rendiamolo eseguibile con:
`git update-index --chmod=+x server_deploy.sh`

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

## 3. Script per il Deploy Locale

`deploy.sh`
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

## 4. Prepariamo il server remoto
```sh
git clone --depth 1 --branch production git@github.com:username/nome_repo.git . 
chmod +x server_deploy.sh
composer install
```

- La clonazione con l'opzione `--depth 1` crea una copia di lavoro del repository Git, ma limita la profondità della storia all'ultimo commit.
- Serve fondamentalmente per risparmiare spazio, tanto la storia completa ce l'hai su GitHub!

## 5. Adesso possiamo lanciare deploy.sh in Locale
Ogni volta che dovrai eseguire un deploy ti basterà eseguire il comando `sh deploy.sh` dalla tua macchina locale.