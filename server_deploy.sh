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
