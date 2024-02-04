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
