attrib -R content\docs\add\* /S /D # Permisos para borrar 
attrib -R content\docs\biu\* /S /D # Permisos para borrar 
git submodule update --force --remote content/docs/add
git submodule update --force --remote content/docs/biu
git add content/docs/add content/docs/biu
git add .
git pull --rebase
git commit -m "chore: Actualizar $(Get-Date -Format 'dd-MM-yyyy HH:mm')"
git push